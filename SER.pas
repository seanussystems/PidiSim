// Interface to SER Device Driver (Serial Port RS-232C)
// Date 25.07.17
// Norbert Koechli
// Copyright ©2005-2017 seanus systems

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit SER;

interface

uses
  Windows, Forms, Types, Controls, Classes, Graphics, SysUtils, ExtCtrls,
  Registry, USystem, SYS, Global, Data, FLog, UPidi;

const
  SERNUM            = 9;     // number of serial ports (Tiger=2)

  SERSPEED0300      = 5;     // 05h     300 baud
  SERSPEED0600      = 6;     // 06h     600 baud
  SERSPEED1200      = 8;     // 08h    1200 baud
  SERSPEED2400      = 10;    // 0Ah    2400 baud
  SERSPEED4800      = 12;    // 0Ch    4800 baud
  SERSPEED9600      = 14;    // 0Eh    9600 baud
  SERSPEED19K2      = 16;    // 10h   19200 baud
  SERSPEED38K4      = 18;    // 12h   38400 baud
  SERSPEED76K8      = 20;    // 14h   76800 baud
  SERSPEED153K      = 22;    // 16h  153600 baud

  SERDATA7N         = 0;     // 7 data bit / no parity
  SERDATA7E         = 1;     // 7 data bit / even parity
  SERDATA7O         = 2;     // 7 data bit / odd parity
  SERDATA8N         = 3;     // 8 data bit / no parity
  SERDATA8E         = 4;     // 8 data bit / even parity
  SERDATA8O         = 5;     // 8 data bit / odd parity
  SERDATA9N         = 6;     // 9 data bit / no parity
  SERDATA9E         = 7;     // 9 data bit / even parity
  SERDATA9O         = 8;     // 9 data bit / odd parity

  SERRETRY          = 100;   // DELPHI number of retries until timeout
  SERIBUFSIZE       = 1024;  // input buffer size=1kB
  SEROBUFSIZE       = 1024;  // output buffer size=1kB

  SERPINSET         = $0AA;  // enables port and pin definition

  SERCLEARIBUFF     = $001;  // clear input buffer
  SERCLEAROBUFF     = $021;  // clear output buffer
  SERGETIBUFFILL    = $001;  // input buffer fill (bytes)
  SERGETIBUFFREE    = $002;  // input buffer free space (bytes)
  SERGETIBUFSIZE    = $003;  // input buffer size (bytes)
  SERGETOBUFFILL    = $021;  // output buffer fill (bytes)
  SERGETOBUFFREE    = $022;  // output buffer free space (bytes)
  SERGETOBUFSIZE    = $023;  // output buffer size (bytes)
  SERSETPARAM       = $05E;  // set baud, data/parity, error
  SERSETSEPARATOR   = $080;  // set separator sign
  SERCLEARSEPARATOR = $081;  // clear separator sign
  SERSETECHO        = $082;  // set local echo (on/off)
  SERSET9BIT        = $083;  // set bit 9 to 1 or 0
  SERSET9ADR        = $084;  // set address 00...FFh
  SERGETSTATUS      = $090;  // get error / buffer overrun
  SERGET9STATUS     = $091;  // get status (0=wait / 1=receive)
  SERGET9ADR        = $092;  // last received address

  SERHKEY           = 'Hardware\Devicemap\Serialcomm'; // DELPHI only
  SERUNIT           = ' bytes'; // SER standard unit
  SERNAME           = 'COM';    // DELPHI port name

var // module variables
  SerInit: Byte;            // serial port init flag
  SerPort: Byte;            // DELPHI selected port
  SerBuff: string;          // modul message buffer / old=[MAXTEMP]
  SerHandle: THandle;       // DELPHI serial port handle

  // Tiger interface to SER device driver (SER.INC)
  procedure InitSer(Port: Byte);
  procedure ResetSer(Port: Byte);
  procedure CheckSerError(Port: Byte);
  procedure SendSerData(Port, Size: Byte; Data: string);
  procedure ReadSerData(Port, Size: Byte; var Data: string);

  // Tiger SER device driver functions (SER.TDD)
  procedure Get_SER(Port, Size: Byte; var Data: string);
  procedure Put_SER(Port: Byte; Data: string);
  procedure Print_SER(Port: Byte; Data: string);
  procedure Input_SER(Port: Byte; var Data: string);

  // DELPHI internal function
  function GetSerPorts(Ports: TStrings): Long;

implementation

uses FMain, FGui;

//------------------------------------------------------------------------------
// INITSER - Initialize serial port and clear input and output buffer
//------------------------------------------------------------------ 17.02.07 --
procedure InitSer(Port: Byte);
var
  config: string;
  com: array[0..4] of Char;
  dcb: TDCB; // device control block structure for RS-232 serial devices
  timeout: TCommTimeouts;
begin
  SerInit := cOFF;
  ErrCode := cOFF;
  
  if Port >= SERNUM then begin
    SerBuff := IntToStr(Port);
    LogError('InitSer', 'Unsupported serial port', SerBuff, $90);
    Exit;
  end;

  StrPCopy(com, SERNAME + IntToStr(Port) + ':');
  com[4] := NUL;

  SerHandle := CreateFile(com, // try to open serial port
               GENERIC_READ or GENERIC_WRITE, 0, nil,
               OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  if (SerHandle = cOFF) or (SerHandle = INVALID_HANDLE_VALUE) then begin
    SerBuff := IntToStr(Port);
    LogError('InitSer', 'Could not open serial port', SerBuff, $9A);
    Exit;
  end;

  // setup serial port parameter
  config := 'baud=' + IntToStr(SERSPEED) + sSPACE +
            'parity=n' + sSPACE +
            'data=' + IntToStr(SERDATA) + sSPACE +
            'stop=1';

  with timeout do begin
    ReadIntervalTimeout         := 0;
    ReadTotalTimeoutMultiplier  := 0;
    ReadTotalTimeoutConstant    := 1000;
    WriteTotalTimeoutMultiplier := 0;
    WriteTotalTimeoutConstant   := 1000;
  end;

  if not SetupComm(SerHandle, SERIBUFSIZE, SEROBUFSIZE) then ErrCode := cON;

  if not GetCommState(SerHandle, dcb) then ErrCode := cON;

  if not BuildCommDCB(@config[1], dcb) then ErrCode := cON;

  if not SetCommState(SerHandle, dcb) then ErrCode := cON;

  if not SetCommTimeouts(SerHandle, timeout) then ErrCode := cON;

  if ErrCode > cOFF then begin  // SER driver error
    SerBuff := IntToStr(Port);
    LogError('InitSer', 'Could not setup serial port', SerBuff, $9A);
    ErrCode := cOFF;
    Exit;
  end;

  SerInit := cINIT;

  SerBuff := IntToStr(Port) + ' with ' + SERPARAM;
  LogEvent('InitSer', 'Serial port initialized at port', SerBuff);

  SerBuff := IntToStr(SERIBUFSIZE) + ' / ' + IntToStr(SEROBUFSIZE) + SERUNIT;
  LogEvent('InitSer', 'Input / output buffer size', SerBuff);

  CheckSerError(Port);
end;

//------------------------------------------------------------------------------
// RESETSER - Reset serial port and clear input and output buffer
//------------------------------------------------------------------ 17.02.07 --
procedure ResetSer(Port: Byte);
begin
  PurgeComm(SerHandle, PURGE_RXABORT or PURGE_RXCLEAR or
                       PURGE_TXABORT or PURGE_TXCLEAR);

  CheckSerError(Port);
end;

//------------------------------------------------------------------------------
// CHECKSERERROR - Check for serial port receiving errors and buffer overflows
//------------------------------------------------------------------ 17.02.07 --
procedure CheckSerError(Port: Byte);
var
  err: Dword;
  stat: TComStat;
begin
  if not ClearCommError(SerHandle, err, @stat) then ErrCode := cON;

  if err > cOFF then begin
    SerBuff := IntToStr(Port) + ' - return ' + IntToStr(err);
  end else begin
    SerBuff := IntToStr(Port);
  end;

  if (err > cOFF) or (ErrCode > cOFF) then begin
    LogError('CheckSerError', 'Faulty serial port', SerBuff, $9F);
  end;

  ErrCode := cOFF;
end;

//------------------------------------------------------------------------------
// SENDSERDATA - Send binary or text data over the serial port
//------------------------------------------------------------------ 17.02.07 --
procedure SendSerData(Port, Size: Byte; Data: string);
begin
  if SerInit <> cINIT then begin  // serial communication not initialized
    Exit;
  end;

  if Size = cOFF then begin  // text mode with <CR> as end of text delimiter
    Print_SER(Port, Data);
  end else begin             // binary mode without any control codes
    Put_SER(Port, Data);
  end;

  CheckSerError(Port);
end;

//------------------------------------------------------------------------------
// READSERDATA - Read serial port and return data as string of bytes
//------------------------------------------------------------------ 17.02.07 --
procedure ReadSerData(Port, Size: Byte; var Data: string);
begin
  Data := sEMPTY;

  if SerInit <> cINIT then begin  // serial communication not initialized
    Exit;
  end;

  if Size = cOFF then begin  // text mode with <CR> as end of text delimiter
    Input_SER(Port, Data);   // wait until <CR> has received!
  end else begin             // binary mode with fix block length
    Get_SER(Port, Size, Data);
  end;

  CheckSerError(Port);
end;

//------------------------------------------------------------------------------
// PUT_SER - DELPHI implementation for Tiger put #SER
//------------------------------------------------------------------ 17.02.07 --
procedure Put_SER(Port: Byte; Data: string);
var
  size: Dword;
  sent: Dword;
begin
  ErrCode := cOFF;
  size := Length(Data);

  WriteFile(SerHandle, Data[1], size, sent, nil);

  if sent <> size then ErrCode := cON;
end;

//------------------------------------------------------------------------------
// GET_SER - DELPHI implementation for Tiger get #SER
//------------------------------------------------------------------ 17.02.07 --
procedure Get_SER(Port, Size: Byte; var Data: string);
var
  i: Long;
  read: Dword;
  buff: array[1..SERIBUFSIZE] of Char;
begin
  ErrCode := cOFF;
  Data := sEMPTY;

  if not ReadFile(SerHandle, buff, Size, read, nil) then begin
    ErrCode := cON;
    Exit;
  end;

  for i := 1 to read do begin
    Data := Data + buff[i];
  end;
end;

//------------------------------------------------------------------------------
// PRINT_SER - DELPHI implementation for Tiger print #SER
//------------------------------------------------------------------ 17.02.07 --
procedure Print_SER(Port: Byte; Data: string);
var
  size: Dword;
  sent: Dword;
begin
  ErrCode := cOFF;
  Data := Data + CR + LF;
  size := Length(Data);

  WriteFile(SerHandle, Data[1], size, sent, nil);

  if sent <> size then ErrCode := cON;
end;

//------------------------------------------------------------------------------
// INPUT_SER - DELPHI implementation for Tiger input_line
//------------------------------------------------------------------ 17.02.07 --
procedure Input_SER(Port: Byte; var Data: string);
var
  c: Char;
  i: Long;
  read: Dword;
begin
  ErrCode := cOFF;
  Data := sEMPTY;
  i := cCLEAR;
  read := cCLEAR;
  
  repeat // read text until CR
    Inc(i);
    c := LF;

    if i >= SERRETRY then begin  // timeout
      Data := sEMPTY;
      ErrCode := cON;
      Exit;
    end;

    if ReadFile(SerHandle, c, 1, read, nil) then begin
      if ((c <> LF) and (c <> CR)) then Data := Data + c;
    end;
  until c = CR;
end;

//------------------------------------------------------------------------------
// GETSERPORTS - DELPHI return number and list of available ser ports
//------------------------------------------------------------------ 17.02.07 --
function GetSerPorts(Ports: TStrings): Long;
var
  i: Long;
  port: string;
  reg: TRegistry;
  names: TStringList;
begin
  Result := cCLEAR;
  reg := TRegistry.Create;
  names := TStringList.Create;

  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if not reg.OpenKey(SERHKEY, False) then Exit;

    reg.GetValueNames(names);

    for i := 0 to names.Count - 1 do begin
      port := reg.ReadString(names.Strings[i]);
      Ports.Add(port);
      Inc(Result);
    end;

    reg.CloseKey;
  finally
    reg.Free;
    names.Free;
  end;
end;


initialization  // Tiger hardware configuration
  SerInit := cOFF;
  SerPort := cOFF;
  SerBuff := sEMPTY;

finalization
  SerInit := cOFF;
  SerPort := cOFF;
  SerBuff := sEMPTY;
  CloseHandle(SerHandle);

end.
