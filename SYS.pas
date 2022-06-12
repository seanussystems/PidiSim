// Interface to SYS (Processor Hardware and Runtime System)
// Date 28.05.22

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit SYS;

interface

uses
  Forms, Windows, Messages, Types, Controls, Graphics, SysUtils, ExtCtrls,
  StrUtils, Classes, Math, MMSystem, USystem, UFile, Global, Data, FLog;

const
  COMPILER_NAME = 'Embarcadero Delphi'; // 26.07.17 nk old=Borland
  COMPILER_VERS = CompilerVersion;

  DEVMAX        = 19;     // number of supported devices
  RUN           = 0;      // processor runtime system
  LAB           = 1;      // plug and play lab device number
  PRN           = 2;      // printer device number
  RTC           = 3;      // real time clock device number
  CNT           = 4;      // counter device number
  SER           = 5;      // serial port device number
  ADC           = 6;      // A/D converter device number
  ADF           = 7;      // A/D fast converter device number
  ENC           = 8;      // encoder device number
  PWM           = 9;      // pulse width modulation device number
  LCD           = 10;     // graphic display device number
  FRQ           = 11;     // frequency counter device number
  PLI           = 12;     // pulse input device number
  GEN           = 13;     // pulse generator device number
  TIM           = 14;     // timer device number
  PAR           = 15;     // parallel input device number
  TCH           = 16;     // touch memory device number
  MF2           = 17;     // MF2 keyboard device number
  PS2           = 18;     // PS/2 device number

  RUNDRV        = 'RUN.SYS';    // processor runtime system
  LABDRV        = 'LAB.TDD';    // plug and play lab device driver
  PRNDRV        = 'PRN.TDD';    // printer device driver
  RTCDRV        = 'RTC.TDD';    // real time clock driver
  CNTDRV        = 'CNT.TDD';    // counter device driver
  SERDRV        = 'SER.TDD';    // serial port driver
  ADCDRV        = 'ADC.TDD';    // A/D converter driver
  ADFDRV        = 'ADF.TDD';    // A/D fast converter driver
  ENCDRV        = 'ENC.TDD';    // encoder device driver
  PWMDRV        = 'PWM.TDD';    // pulse modulation driver
  LCDDRV        = 'LCD.TDD';    // display device driver
  FRQDRV        = 'FRQ.TDD';    // frequency meter driver
  PLIDRV        = 'PLI.TDD';    // pulse in device driver
  GENDRV        = 'GEN.TDD';    // pulse generator device driver
  TIMDRV        = 'TIM.TDD';    // timer device driver
  PARDRV        = 'PAR.TDD';    // parallel port driver
  TCHDRV        = 'TCH.TDD';    // touch memory driver
  MF2DRV        = 'MF2.TDD';    // MF2 keyboard driver
  PS2DRV        = 'PS2.TDD';    // PS/2 device driver

  MAXBUFF       = 240;          // max lenght of message buffers [bytes]
  MAXTEMP       = 64;           // max lenght of temporary buffers [bytes]
  MAXSYS        = 32;           // max lenght of system strings [bytes]
  MAXTIG        = 8;            // max lenght of Tiger strings [bytes]
  MAXERR        = 64;           // max lenght of error strings [bytes]

  FREQDIV       = 255;          // timer max frequency divider
  FREQMIN       = 610;          // timer min frequency (610Hz)
  FREQMAX       = 25000;        // timer max frequency (25kHz)
  FREQRES       = 400;          // timer max resolution [ns]

  TIGASCII      = 42;           // convert HEX->ASCII (A=k, B=l.. Tiger)
  HEXASCII      = 49;           // convert HEX->ASCII (0=a, 1=b.. standard)

  cLO           = 0;            // set pin to low level
  cHI           = 255;          // set pin to high level
  DIROUT        = 0;            // set pin as output
  DIRIN         = 1;            // set pin as input
  ALLPIN        = 255;          // all pins of a port

  ACT           = 1;            // user eport parameter
  ACTIVE        = 1;            //  - eport active
  NOACTIVE      = 0;            //  - eport not used

  RAMTEST       = 101;          // options for RAM test
  SYSTEST       = 102;          // options for SYS test
  PWRTEST       = 103;          // options for PWR start up delay (1000=1sec)
  MEMTEST       = 104;          // options for MEM test
  SYSMEM        = 131072;       // system memory segment=128kB
  SYSMINSTACK   = 512;          // min stack size=512bytes
  SYSMAXSTACK   = 8192;         // max stack size=8kbytes

  TESTNO        = 0;            // no test
  TESTMIN       = 1;            // minimal (fragmented) test
  TESTFAST      = 2;            // fast (standard) test
  TESTFULL      = 3;            // full (intensive) test

  cKEYNONE      = 0;            // key return codes - no key pressed
  cKEYUP        = 1;            //  - up key pressed
  cKEYRIGHT     = 2;            //  - right key pressed
  cKEYDOWN      = 3;            //  - down key pressed
  cKEYLEFT      = 4;            //  - left key pressed

  TONESHORT     = 50;           // short audio tone (50ms)
  TONELONG      = 250;          // long audio tone (250ms)
  TONEBELL      = 251;          // bell audio tones (3*50ms)
  TONERING      = 252;          // ring audio tones (4*40ms)
  TONEALARM     = 253;          // alarm audio tones (5*30ms)
  TONEERROR     = 254;          // error audio tones (6*20ms) 24.05.07 nk add

  TONEFREQ      = 2500;         // DELPHI tone frequency [Hz]
  TONEON        = 30000;        // DELPHI set audio tone on (max. 30s)
  TONEOFF       = 0;            // DELPHI set audio tone off

  GENPIN        = 86;           // GEN output pin (P86 fix defined in GEN.tdd)
  GENSTART      = 0;            // GEN start pulse out (endless)
  GENSTOP       = -1;           // GEN stop pulse out (not interrupted)
  GENSETRANGE   = $090;         // set pulse frequency range (1..3)
  GENSETPULSE   = $091;         // set generator number of pulses (-1=stop, 0=endless)
  GENGETPULSE   = $0B0;         // get generator rest of pulses (-1=stopped)

  MEMSTART      = 0;            // flash memory start address
  MEMBYTE       = 1;            // flash memory cell size=1byte
  MEMMODEEMPTY  = 0;            // flash cells must be empty to write
  MEMUNDEF      = -1;           // undefined flash address
  MEMBLOCKNUM   = 2;            // number of flash memory block buffers
  MEMLOGDEL     = 500;          // log delay time before clear flash (500ms)
  MEMBLOCKLEN   = 16;           // flash memory block buffer length=16words
  MEMBLOCKSIZE  = 32;           // flash data block size (16x2bytes=32bytes)
  MEMSECTSIZE   = 65536;        // flash sector size = 65'536bytes = 64kB 01.06.07 nk mov

  MEMERRNONE    = 0;            // clear flash error (>0=write error address)
  MEMERRSOURCE  = -1;           // source variable is too small
  MEMERREOF     = -2;           // end of flash memory reached
  MEMERRBYTES   = -3;           // no source bytes
  MEMERRADDR    = -4;           // address out of flash memory range
  MEMERRPARAM   = -16;          // wrong parameter
  MEMERRPOKEM   = -17;          // pokem_flash not supported
  MEMERRSECTOR  = -21;          // invalid flash sector size
  MEMERRLITTLE  = -22;          // too little flash memory
  MEMERRNOSECT  = -23;          // unsupported flash sector
  MEMERRERASE   = -24;          // flash memory erasing failed
  MEMERRREAD    = -25;          // flash memory reading failed
  MEMERRWRITE   = -26;          // flash memory writing failed

  MEMEMPTYBYTE  = $0FF;         // empty flash cell (1byte)
  MEMEMPTYWORD  = $0FFFF;       // empty flash word (2bytes)

  I2CERROR      = $0F0;         // I2C error code limit (I2C_result)
  I2CDATALEN    = 1;            // I2C data lenght = 1byte
  I2CNAKLIMIT   = 3;            // I2C NAK conditions limit (I2C_write)
  I2CISO        = 7816;         // ISO 7816 mode for I2C bus (LSB first)

  SERIALBYTES   = 128;          // flash memory size for serial number [bytes]
  SERIALLEN     = 8;            // serial number length
  SERIALNONE    = 'FFFFFFFF';   // undefined serial number
  SERIALTEXT    = 'S/N';

  SERIALFORM    = '%*.*X';      // serial number format (HEX)
  ERRFORM       = '%.2X';       // error code format (HEX)
  VERSFORM      = '%.2X';       // version format (HEX)
  ADDRFORM      = '%.3Xh';      // address format (HEX)

  SPACE         = ' ';          // 28.05.22 nk add
  VERSTEXT      = ' Vers.';
  TIMUNIT       = ' Hz';        // TIM standard unit
  GENUNIT       = ' ns';        // GEN standard unit
  MEMUNIT       = ' bytes';     // MEM standard unit

  // definitions for system internals

  SYSNOFUNCT          =   $00;  // (rw) inactive - no function
  SYSCLEARIBUF        =   $01;  // ( w) clear input buffer
  SYSCLEAROBUF        =   $21;  // ( w) clear output buffer
  SYSRESETERROR       =   $41;  // ( w) reset last error code
  SYSRESETACTION      =   $42;  // ( w) reset last action code
  SYSRESETLOST        =   $43;  // ( w) reset last lost data code
  SYSGETIBUFFILL      =   $01;  // (r ) input buffer fill [bytes]
  SYSGETIBUFFREE      =   $02;  // (r ) input buffer free space [bytes]
  SYSGETIBUFSIZE      =   $03;  // (r ) input buffer size [bytes]
  SYSGETOBUFFILL      =   $21;  // (r ) output buffer fill [bytes]
  SYSGETOBUFFREE      =   $22;  // (r ) output buffer free space [bytes]
  SYSGETOBUFSIZE      =   $23;  // (r ) output buffer size [bytes]
  SYSGETERROR         =   $41;  // (r ) last error code
  SYSGETACTION        =   $42;  // (r ) last action code
  SYSGETLOST          =   $43;  // (r ) last lost data code
  SYSGETCPULOAD       =   $44;  // (r ) cpu load (10000=100%)
  SYSGETDEVVERS       =   $63;  // (r ) device driver version (106Dh=1.06n)

  // return codes from SYSVARN and SYSVAR$

  SYSGETTASKERROR     =   0;   // last runtime error in task
  SYSGETERRORCOUNT    =   1;   // runtime error counter
  SYSGETERRORFLAG     =   2;   // actual error flag (0=ok, 1=error)
  SYSGETERRORCODE     =   15;  // actual error code (reset flag)
  SYSGETSTACKLEVEL    =   16;  // stack level
  SYSGETSTACKFILL     =   17;  // stack fill [bytes]
  SYSGETSTACKFREE     =   18;  // stack free space [bytes]
  SYSGETSTACKSIZE     =   19;  // stack size [bytes]
  SYSGETDRAMSIZE      =   30;  // 0=size, 1=prog free, 2=prog size, 3=free
  SYSGETSRAMSIZE      =   31;  // 0=size, 1=prog free, 2=prog size, 3=free

  SYSGETMEMCHIPNUM    =   32;  // number of flash chips
  SYSGETMEMCHIPSIZE   =   33;  // size of flash chips
  SYSGETMEMCHIPSECT   =   34;  // number of sectors per chip
  SYSGETMEMSECTSIZE   =   35;  // size of flash sectors
  SYSGETMEMASECTNUM   =   36;  // number of flash sectors
  SYSGETMEMSIZE       =   37;  // size of flash memory [bytes]
  SYSGETMEMUSERSECT   =   38;  // number of flash sectors for user data
  SYSGETMEMUSERSIZE   =   39;  // size of flash memory for user data
  SYSGETMEMMODE       =   40;  // flash mode (0=program must wait, 1=program can run)

  SYSGETTASKACTNUM    =   48;  // number of running task
  SYSGETTASKACTPRIO   =   49;  // priority of running task
  SYSGETTASKALLPRIO   =   50;  // total priority of all tasks
  SYSGETTASKALLNUM    =   51;  // total tasks in program
  SYSGETTASKALLACTIVE =   52;  // total activated tasks

  SYSGETBOOTMODE      =   65;  // 0=reset, 1=watchdog, 2=basic error, 3=system error
  SYSGETSYSSPEED      =   66;  // 0=full speed, 1=low power mode, 2=ultra low power mode
  SYSGETPROCMODE      =   67;  // 0=RUN mode, 1=PC mode (debug mode)
  SYSGETPROCVERS      =   68;  // version of processor module
  SYSGETPROCTYPE      =   69;  // type of processor module (131='T', 170='A')
  SYSGETWDOGSTATE     =   70;  // actual watchdog state (0..6)
  SYSGETWDOGMAX       =   71;  // maximal watchdog state (0..6)

// ErrCode decimal coded - LogError shows HEX value, eg:
//   ErrorHandler: ERROR 22: Gerätefehler in task Runtime System
//   InitRtc: ERROR 9A: RTC driver installation failed - return 0
//   ErrorHandler: ERROR 23: Hier kein PUBLIC-Zugriff in task User Interface

  SYSNOERR            =   0;   // clear error code
  SYSTASKAVAILERR     =   7;   // task number not availlable
  SYSSTRINGERR        =   8;   // string too long
  SYSPARAMETERERR     =   11;  // illegal parameter
  SYSCHANNELERR       =   32;  // device channel error
  SYSPORTADRERR       =   33;  // port address error
  SYSDEVICEERR        =   34;  // device hardware error
  SYSPINUSEDERR       =   35;  // pin already in use
  SYSNODEVICEERR      =   38;  // device driver not installed
  SYSMEMCELLERR       =   47;  // flash cell not empty (DELPHI only)
  SYSMEMAVAILERR      =   48;  // flash not availlable
  SYSMEMWRITEERR      =   49;  // flash write error
  SYSMEMBUSYERR       =   50;  // flash is busy
  SYSMEMADRERR        =   52;  // flash address error
  SYSMEMPEEKERR       =   53;  // flask illegal peek length
  SYSMEMTIMEOUT       =   55;  // flash timeout error
  SYSFIFOERR          =   64;  // fifo error
  SYSFIFOEMPTY        =   65;  // fifo is empty
  SYSFIFOFULL         =   66;  // fifo is full

  SYSTASKERRTEXT      =   0;   // text of last runtime error in task
  SYSERRCODETEXT      =   1;   // text of error code

  // 24.05.07 nk add  DELPHI constants
  FLASH_PATH          = 'Flash\';
  FLASH_FILE          = 'Flash';
  FLASH_POST          = '.pfd';
  FLASH_SERNO         = 'Serno';

var // DELPHI variables
  FlashOpen: Boolean;            // flash memory file status
  SoundCard: Boolean;            // PC sound card available
  SysTickNull: Long;             // system tick correction
  InitialMem: Int64;             // initial process memory [bytes]
  SernoFile: string;             // simulate user flash area (128 bytes)
  FlashFile: string;             // simulate flash memory
  Flash: file;                   // binary coded flash file

  // module variables
  SysBuff: string;               // modul message buffer
  CompilerName: string;          // compiler name
  CompilerVers: string;          // compiler version
  ProgOwner: string;             // program owner identification (DELPHI w/o [MAXSYS])
  ProgVers: string;              // program version and release (DELPHI w/o [MAXSYS])
  DeviceName: string;            // device identification
  SystemName: string;            // runtime system name
  SystemVers: string;            // runtime system version (DELPHI w/o [MAXSYS])
  ProcType: string;              // processor module type
  ProcVers: string;              // processor module version (DELPHI w/o [MAXSYS])
  DriverVers: string;            // device driver version (DELPHI w/o [MAXSYS])
  SerialNumber: string;          // serial number of device (DELPHI w/o [MAXSYS])
  UserNumber: string;            // user identification number

  TaskName: array[0..MAXTASK] of string; // names of running tasks
  DevDriver: array[0..DEVMAX] of string; // name of device drivers
  DevVers: array[0..DEVMAX] of Long;     // DELPHI version of device drivers
  MemBlock: array[0..MEMBLOCKNUM, 0..MEMBLOCKLEN] of Word; // block buffers

  ErrCode: Long;                 // last global error code (decimal)
  RamFree: Long;                 // free sram for user [bytes]
  MemFree: Long;                 // free flash memory for user data [bytes]
  MemError: Long;                // global flash error code (must be long!)
  MemRead: Long;                 // read pointer to flash address
  MemWrite: Long;                // write pointer to flash address
  MemSize: Long;                 // total user flash memory size [bytes]
  MemSectors: Long;              // usable flash memory sectors
  MemBlocks: Long;               // number of flash memory logging blocks
  StackFree: Long;               // free program stack size [bytes]

  TimeRes: Word;                 // timer resolution [ns]
  PulseMin: Word;                // min number of pulses

  ErrLog: Byte;                  // error logger flag (OFF=no error logs)
  KeyFlag: Byte;                 // OFF=no key depressed, <>OFF=number of depressed key
  
  Key1: Byte;                    // bit value of system keys 1..4
  Key2: Byte;
  Key3: Byte;
  Key4: Byte;

  // Tiger interface to SYS device driver (SYS.INC)
  procedure InitSys;
  procedure LogSys;
  procedure ErrorHandler(Task, Error: string);
  procedure LogError(ErrModul, ErrText, ErrVal: string; ErrNum: Long);
  procedure LogEvent(LogModul, LogText, LogVal: string);
  procedure LogTasks;
  procedure InitAudio;
  procedure SetAudioTone(Dur: Word);
  procedure InitI2c;
  procedure InitSpi;
  procedure SetSpi(Ready: Byte);
  procedure InitKey;
  procedure GetKeyNum(var KeyNum: Byte);
  procedure GetDevice(DevNum: Byte; var Vers: string);
  procedure GetSystem(var Vers: string);
  procedure GetProcessor(var Vers: string);
  procedure GetSerial(var SerNum: string);
  procedure GetMemFree(var Free: Long);
  procedure GetRamFree(var Free: Long);
  procedure GetStackFree(var Free: Long);
  procedure CheckStack(Logon: Byte);
  procedure GetVers(VersNum: Long; var Vers: string);
  procedure InitGen(Range: Byte);
  procedure SetGen(Freq: Word);
  procedure InitTim(Freq: Word);
  procedure InitMem;
  procedure ClearMem(Sector: Word);
  procedure WriteMemWord(Value: Word; GoAhead: Byte);
  procedure ReadMemWord(var Value: Word; GoAhead: Byte);
  procedure ClearMemBlock(BlockNum: Byte);
  procedure ReadMemBlock(BlockNum: Byte);
  procedure WriteMemBlock(BlockNum, ClearSect: Byte); // 01.06.07 nk add ClearSect

  // Tiger runtime system function
  function Ticks: Long;
  function Limit(Val, Min, Max: Long): Long;
  function EraseFlash(Addr, Size: Long): Boolean;
  function PeekFlash(Addr: Long; var Value: Long; Size: Long): Long;
  function PokemFlash(Addr, Value, Index, Size, Mode: Long): Long;
  procedure SetBit(var Val: Word; Bit: Byte);
  procedure WaitDuration(Msec: Long);
  procedure OutAudport(Tones, Dur, Pause: Word);
  procedure DisableTsw;
  procedure EnableTsw;

implementation

uses FMain, FGui;

//------------------------------------------------------------------------------
// INITSYS - Initialize system and program parameter and clear tick counter
//------------------------------------------------------------------ 17.02.07 --
procedure InitSys;
begin
  SysTickNull := GetTickCount;  // clear tick counter

  TaskName[TASKRUN] := 'Runtime System';  //05.05.07 nk mov from main ff
  TaskName[TASKDAQ] := 'Data Acquisition';
  TaskName[TASKGUI] := 'User Interface';
  TaskName[TASKCOM] := 'Host Communication';

  UserNumber   := 'P4M01RT56'; //nk//const
  CompilerName := COMPILER_NAME;
  CompilerVers := FloatToStr(COMPILER_VERS);
  ProgOwner    := CompanyName;
  ProgVers     := ProductVersion;
  DeviceName   := ProductName;

  GetSerial(SerialNumber);
end;

//------------------------------------------------------------------------------
// LOGSYS - Log program owner, device name, compiler name, and versions
//------------------------------------------------------------------ 17.02.07 --
procedure LogSys;
begin
  LogEvent(DeviceName,   VERSTEXT,   ProgVers);
  LogEvent(ProgOwner,    SERIALTEXT, SerialNumber);
  LogEvent(CompilerName, VERSTEXT,   CompilerVers);
end;

//------------------------------------------------------------------------------
// ERRORHANDLER - Handle program and system errors and get error message
//------------------------------------------------------------------ 25.07.17 --
procedure ErrorHandler(Task, Error: string);
var
  errtask: string;
  errtext: string;
begin
  ErrCode := GetLastError;  // get error code (decimal long)
  errtext := Trim(Error);
  errtask := 'in task ' + Task;

  LogError('ErrorHandler', errtext, errtask, ErrCode);
end;

//------------------------------------------------------------------------------
// LOGERROR - Send messages via serial port for error logging
//------------------------------------------------------------------ 17.02.07 --
procedure LogError(ErrModul, ErrText, ErrVal: string; ErrNum: Long);
var
  timestamp: Long;
  modul: string;
  text: string;
  val: string;
  num: string;
begin
  if ErrLog = cOFF then begin  // error logging supressed
    Exit;
  end;

  timestamp := Ticks;          // get timestamp
  modul    := Trim(ErrModul);
  text     := Trim(ErrText);
  val      := Trim(ErrVal);

  if ErrNum > SYSNOERR then begin
    num := Format(ERRFORM, [ErrNum]) + sCOLON;  // make HEX string
  end else begin
    num := sEMPTY;
  end;

  text := IntToStr(timestamp) + sCOLON + modul + sCOLON + 'ERROR ' + num + text + sSPACE + val;
  Log.Print(text);

  SetAudioTone(TONEERROR); // 24.05.07 nk opt

  ErrCode := SYSNOERR;
end;

//------------------------------------------------------------------------------
// LOGEVENT - Send messages via serial port for event logging
//------------------------------------------------------------------ 17.02.07 --
procedure LogEvent(LogModul, LogText, LogVal: string);
var
  timestamp: Long;
  modul: string;
  text: string;
  val: string;
begin
  timestamp := Ticks;          // get timestamp
  modul     := Trim(LogModul);
  text      := Trim(LogText);
  val       := Trim(LogVal);
  text      := IntToStr(timestamp) + sCOLON + modul + sCOLON + text + sSPACE + val;

  Log.Print(text);
end;

//------------------------------------------------------------------------------
// LOGTASKS - Log number, name, and priority of all running tasks
//------------------------------------------------------------------ 25.07.17 --
procedure LogTasks;
var
  task: Byte;
  tasknum: Byte;
  aprio, tprio: Long;
  taskprio: string;  //old=[6];
begin
  aprio := PROCENT;  // get total of task priorities

  for task := 0 to Main.MdiChildCount do begin
    if task = 0 then begin
      SysBuff  := Main.Name;
      tasknum  := Main.Tag;
      taskprio := Main.HelpKeyword;
      if taskprio <> sEMPTY then
        tprio := StrToInt(taskprio)
      else
        tprio := cOFF;
    end else begin
      SysBuff  := Main.MdiChildren[task - 1].Name;
      tasknum  := Main.MdiChildren[task - 1].Tag;
      taskprio := Main.MdiChildren[task - 1].HelpKeyword;
      if taskprio <> sEMPTY then
        tprio := StrToInt(string(taskprio))
      else
        tprio := cOFF;
    end;

    if (aprio > cOFF) and (tprio > cOFF) then begin
      tprio    := tprio * PROCENT div aprio;  // get task priority [%]
      taskprio := IntToStr(tprio) + sPROCENT;
      SysBuff  := TaskName[tasknum] + ' running at priority ';
      LogEvent('LogTasks', SysBuff, taskprio);
    end;
  end;
end;

//------------------------------------------------------------------------------
// INITAUDIO - Initialize audio port for external tone generator
//------------------------------------------------------------------ 17.02.07 --
procedure InitAudio;
begin
  if (AUDPORT = cOFF) or (AUDPIN = cOFF) then begin
    SoundCard := False;
    LogError('InitAudio', 'Audio output not defined', sEMPTY, $96);
    Exit;
  end;

  //enable system beep
  SystemParametersInfo(SPI_SETBEEP, cON, nil, SPIF_SENDWININICHANGE);

  OutAudport(1, TONELONG, TONEOFF);

  SysBuff := IntToStr(AUDPORT) + Trim(IntToStr(AUDPIN));

  if SoundCard then begin
    LogEvent('InitAudio', 'Audio card initialized at pin', SysBuff);
  end else begin
    LogEvent('InitAudio', 'Audio speaker initialized at pin', SysBuff);
  end;
end;

//------------------------------------------------------------------------------
// SETAUDIOTONE - Generate audio tones for warnings and alarms
//   Dur - 0=OFF, 1=ON, >1=tone duration [ms], >250=sound pattern
//------------------------------------------------------------------ 17.02.07--
procedure SetAudioTone(Dur: Word);
begin
  if Loudness = cOFF then begin
    Exit;
  end;

  if Dur = cOFF then begin
    Windows.Beep(TONEFREQ, TONEOFF);  // set audio tone off
    Exit;
  end;

  if Dur = cON then begin
    Windows.Beep(TONEFREQ, TONEON);   // set audio tone on
    Exit;
  end;

  if Dur = TONEBELL then begin
    OutAudport(3, 50, 50);
    Exit;
  end;

  if Dur = TONERING then begin
    OutAudport(4, 40, 40);
    Exit;
  end;

  if Dur = TONEALARM then begin
    OutAudport(5, 30, 30);
    Exit;
  end;

  if Dur = TONEERROR then begin  // 24.05.07 nk add audio error tone
    OutAudport(6, 20, 20);
    Exit;
  end;

  OutAudport(1, Dur, TONEOFF);  // audio beep tone
end;

//------------------------------------------------------------------------------
// INITI2C - Initialize and setup I2C bus and set both lines to high-impedance
//   DELPHI no I2C bus implemented
//------------------------------------------------------------------ 17.02.07 --
procedure InitI2c;
begin
  if I2CMODE = cOFF then begin
    SysBuff := 'MSB first';
  end else begin
    SysBuff := 'LSB first (ISO7816)';
  end;
  
  LogEvent('InitI2c', 'I2C bus set to mode', SysBuff);

  SysBuff := IntToStr(I2CPORT);
  LogEvent('InitI2c', 'I2C bus initialized at port', SysBuff);
end;

//------------------------------------------------------------------------------
// INITSPI - Initialize and setup SPI bus
//   DELPHI no SPI bus implemented
//------------------------------------------------------------------ 17.02.07 --
procedure InitSpi;
begin
  if SPIMODE = cOFF then begin
    SysBuff := 'LSB first';
  end else begin
    SysBuff := 'MSB first';
  end;
  
  LogEvent('InitSpi', 'SPI bus set to mode', SysBuff);

  SysBuff := IntToStr(SPIPORT);
  LogEvent('InitSpi', 'SPI bus initialized at port', SysBuff);
end;

//------------------------------------------------------------------------------
// SETSPI - Set SPI bus to ready or idle state - pin CS (Chip Select) not used
//   DELPHI no SPI bus implemented
//------------------------------------------------------------------ 17.02.07 --
procedure SetSpi(Ready: Byte);
begin
  // do nothing
end;

//------------------------------------------------------------------------------
// INITKEY - Initialize parallel key port for joystick (DELPHI=Keyboard)
//------------------------------------------------------------------ 17.02.07 --
procedure InitKey;
var
  dmask: Long;
begin
  dmask := GetKeyboardType(0);
  GetKeyState(0); //09.05.07 nk add ff
  ClearKeyboardBuffer; // clear keyboard input buffer

  if dmask = cOFF then begin
    SysBuff := IntToStr(dmask);
    LogError('InitKey', 'Keyboard initialisation failed', SysBuff, $91);
  end else begin
    SysBuff := IntToStr(KEYPORT);
    LogEvent('InitKey', 'Keyboard initialized at port', SysBuff);
  end;
end;

//------------------------------------------------------------------------------
// GETKEYNUM - Get highest number (4..1) of depressed key or KEYNONE if none
//------------------------------------------------------------------ 17.02.07 --
procedure GetKeyNum(var KeyNum: Byte);
begin
  try  // may block at start-up
    if KeyNum = KEYINIT then begin // DELPHI clear keyboard buffer
      KeyNum := cKEYNONE;
      Exit;
    end;

    //09.05.07 nk opt - use negative return value of GetKeyState instead of HiWord
    if GetKeyState(VK_LEFT) < cKEYNONE then
      KeyNum := cKEYLEFT
    else if
      GetKeyState(VK_DOWN) < cKEYNONE then
      KeyNum := cKEYDOWN
    else if
      GetKeyState(VK_RIGHT) < cKEYNONE then
      KeyNum := cKEYRIGHT
    else if
      GetKeyState(VK_UP) < cKEYNONE then
      KeyNum := cKEYUP
    else
      KeyNum := cKEYNONE;
  except
    on E: Exception do begin //09.05.07 nk DELPHI add ff
      LogError('GetKeyNum', E.Message, IntToStr(KeyNum), $B0);
      KeyNum := cKEYNONE;
      Exit;
    end;
  end;
  
  try //DELPHI: set focus to GUI
    if KeyNum > cKEYNONE then begin
      Gui.WindowState := wsNormal;
      Gui.SetFocus;
    end;
  except
    // ignore
  end;
end;

//------------------------------------------------------------------------------
// GETDEVICE - Get actual version of device driver(s)
//------------------------------------------------------------------ 17.02.07 --
procedure GetDevice(DevNum: Byte; var Vers: string);
var
  dev, dmin, dmax, elog: Byte;
  ver: Long;
begin
  DevDriver[RUN] := 'Runtime System';
  DevDriver[LAB] := 'Plug and Play Lab';
  DevDriver[PRN] := 'Parallel Printer';
  DevDriver[RTC] := 'Real Time Clock';
  DevDriver[CNT] := 'Counter';
  DevDriver[SER] := 'Serial Port';
  DevDriver[ADC] := 'A/D Converter';
  DevDriver[ADF] := 'A/D Fast Converter';
  DevDriver[ENC] := 'Encoder';
  DevDriver[PWM] := 'Pulse Width Modulator';
  DevDriver[LCD] := 'Graphic Display';
  DevDriver[FRQ] := 'Frequency Meter';
  DevDriver[PLI] := 'Pulse Input';
  DevDriver[GEN] := 'Pulse Generator';
  DevDriver[TIM] := 'Timer';
  DevDriver[PAR] := 'Parallel Port';
  DevDriver[TCH] := 'Touch Memory';
  DevDriver[MF2] := 'MF2 Keyboard';
  DevDriver[PS2] := 'PS/2 Device';

  elog := ErrLog;

  if DevNum >= DEVMAX then begin  // get version of all loaded device drivers
    ErrLog := cOFF;               // supress errors from not loaded drivers
    dmin   := 1;
    dmax   := DEVMAX - 1;
  end else begin                  // get version of specified device driver
    dmin   := DevNum;
    dmax   := DevNum;
  end;

  for dev := dmin to dmax do begin
    ErrCode := SYSNOERR;          // get version of device driver
    ver     := DevVers[dev];      // SYSNOERR if not loaded

    if ver <> SYSNOERR then begin // driver has been successfully loaded
      GetVers(ver, Vers);
      SysBuff := DevDriver[dev] + VERSTEXT;
      LogEvent('Device driver loaded', SysBuff, Vers);
    end;
  end;

  ErrCode := SYSNOERR;
  ErrLog  := elog;  // re-activate error logging
end;

//------------------------------------------------------------------------------
// GETSYSTEM - Get name and version of runtime system
//------------------------------------------------------------------ 28.05.22 --
procedure GetSystem(var Vers: string);
begin
  Vers       := GetSystemVers(vtBuild);
  SystemName := GetSystemVers(vtName) + SPACE + UpdateWinVersion; //28.05.22 nk add UpdateWinVersion
  SysBuff    := SystemName + VERSTEXT;
  LogEvent('Runtime system', SysBuff, Vers);
end;

//------------------------------------------------------------------------------
// GETPROCESSOR - Get type and version of processor module
//------------------------------------------------------------------ 17.02.07 --
procedure GetProcessor(var Vers: string);
begin
  Vers     := GetProcessorVers(vtVers);
  ProcType := GetProcessorVers(vtShort);
  SysBuff  := ProcType + VERSTEXT;
  LogEvent('Processor module', SysBuff, Vers);
end;

//------------------------------------------------------------------------------
// GETSERIAL - Get serial number from system harddisk (Tiger from flash area)
//------------------------------------------------------------------ 17.02.07 --
procedure GetSerial(var SerNum: string);
var
  maxlen: DWORD;
  flags: DWORD;
  serno: DWORD;
  drive: string;
begin
  try
    drive := LeftStr(Application.ExeName, 3);
    GetVolumeInformation(PChar(drive), nil, MAX_PATH,
      @serno, maxlen, flags, nil, 0);
    if @serno <> nil then
      SerNum := LeftStr(Format(SERIALFORM, [SERIALLEN, SERIALLEN, serno]), SERIALLEN)
    else
      SerNum := SERIALNONE;
  except
    SerNum := SERIALNONE;
  end;
end;

//------------------------------------------------------------------------------
// GETMEMFREE - Get size and number of free user flash sectors
//------------------------------------------------------------------ 17.02.07 --
procedure GetMemFree(var Free: Long);
var
  ret: Long;
begin
  try
    Free := GetFileSize(FlashFile);  // size of user flash
  except
    Free := MEMSTART;
  end;

  SysBuff := IntToStr(Free);
  LogEvent('User flash size', SysBuff, MEMUNIT);

  ret     := Free div MEMSECTSIZE;   // number of user flash sectors
  SysBuff := IntToStr(ret);
  LogEvent('User flash sectors', SysBuff, sEMPTY);

  ret     := MEMSECTSIZE;            // size of flash sectors
  SysBuff := IntToStr(ret);
  LogEvent('Flash sector size', SysBuff, MEMUNIT);
end;

//------------------------------------------------------------------------------
// GETRAMFREE - Get size of used and free working memory (RAM)
//------------------------------------------------------------------ 17.02.07 --
procedure GetRamFree(var Free: Long);
var
  ret: Int64;
  ram: TMemoryStatus;
begin
  try
    ram.dwLength := SizeOf(ram);
    GlobalMemoryStatus(ram);
  except
    Free := cCLEAR;
    Exit;
  end;
  
  ret := ram.dwTotalPhys;  // RAM memory size
  SysBuff := IntToStr(ret);
  LogEvent('RAM memory size', SysBuff, MEMUNIT);

  Free := ram.dwAvailPhys; // RAM memory free
  SysBuff := IntToStr(Free);
  LogEvent('RAM memory free', SysBuff, MEMUNIT);

  ret := ret - Free;       // RAM memory used
  SysBuff := IntToStr(ret);
  LogEvent('RAM memory used', SysBuff, MEMUNIT);
end;

//------------------------------------------------------------------------------
// GETSTACKFREE - Get bytes of total, used, and free program stack
//   works only on 32bit Windows systems (WINNT, WIN2K, WINXP, VISTA)
//------------------------------------------------------------------ 25.07.17 --
procedure GetStackFree(var Free: Long);
var
  ret: Int64;
begin
  SysBuff := IntToStr(SYSMAXSTACK); // program stack size [bytes]
  LogEvent('Program stack size', SysBuff, MEMUNIT);

  ret     := GetAllocMemSize - InitialMem; //25.07.17 nk old=AllocMemSize (deprecated)
  SysBuff := IntToStr(ret);     // program stack used [bytes]
  LogEvent('Program stack used', SysBuff, MEMUNIT);

  Free    := SYSMAXSTACK - ret;
  SysBuff := IntToStr(Free);    // program stack free [bytes]
  LogEvent('Program stack free', SysBuff, MEMUNIT);
end;

//------------------------------------------------------------------------------
// CHECKSTACK - Check if a program stack overflow may occur (< 512 bytes)
//------------------------------------------------------------------ 25.07.17 --
procedure CheckStack(Logon: Byte);
begin
  StackFree := SYSMAXSTACK - (GetAllocMemSize - InitialMem); //25.07.17 nk old=AllocMemSize (deprecated)

  if StackFree < SYSMINSTACK then begin  // program stack free [bytes]
    SysBuff := IntToStr(StackFree) + MEMUNIT;
    LogError('CheckStack', 'Stack overflow may occur', SysBuff, $A1);
  end;

  if Logon = cON then begin  // program stack free [%]
    StackFree := PROCENT * StackFree div SYSMAXSTACK;
    SysBuff   := IntToStr(StackFree);
    LogEvent('Program stack free', SysBuff, sPROCENT);
  end;
end;

//------------------------------------------------------------------------------
// GETVERS - Get version string from HEX coded version number
//   All Tiger versions are HEX coded (e.g. 106Dh = 1.06n)
//------------------------------------------------------------------ 17.02.07 --
procedure GetVers(VersNum: Long; var Vers: string);
var
  ver: Long;
  rel: string; //old=[1];
begin
  ver  := VersNum and MAXWORD;  // ignore beta version
  Vers := Format(VERSFORM, [ver]);
  rel  := RightStr(Vers, 1);
  ver  := Ord(rel[1]);

  if ver >= ASCII then begin
    ver := ver + TIGASCII;  // convert HEX->ASCII (A=k, B=l..)
  end else begin
    ver := ver + HEXASCII;  // convert HEX->ASCII (0=a, 1=b..)
  end;

  Vers := LeftStr(Vers, 1) + sDOT + Copy(Vers, 2, 2) + Chr(ver);
end;

//------------------------------------------------------------------------------
// INITGEN - Initialize pulse generator and set frequency range (1..3)
//------------------------------------------------------------------ 17.02.07 --
procedure InitGen(Range: Byte);
begin
  PulseMin := cOFF;
  TimeRes  := cOFF;
  ErrCode  := SYSNOERR;

  case Range of
    1: begin
         TimeRes  := 1 * FREQRES; // timer resolution [ns]
         PulseMin := 31;          // min number of pulses
       end;

    2: begin
         TimeRes  := 4 * FREQRES;
         PulseMin := 7;
       end;

    3: begin
         TimeRes  := 16 * FREQRES;
         PulseMin := 2;
       end;

    else
      SysBuff := IntToStr(Range);
      LogError('InitGen', 'Unsupported frequency range', SysBuff, $90);
      Exit;
  end;

  // no pulse generator implemented in DELPHI

  SysBuff := IntToStr(TimeRes) + GENUNIT;
  LogEvent('InitGen', 'Pulse generator initialized with', SysBuff);
end;

//------------------------------------------------------------------------------
// SETGEN - Set pulse generator frequency [Hz] On or Off
//------------------------------------------------------------------ 17.02.07 --
procedure SetGen(Freq: Word);
var
  duty, cycle: Word;
  peri: Long;
begin
  if Freq = cOFF then begin
    LogEvent('SetGen', 'Pulse generator stopped', sEMPTY);
    Exit;
  end;
  
  if (TimeRes = cOFF) or (TimeRes mod FREQRES <> cOFF) then begin
    SysBuff := IntToStr(TimeRes) + GENUNIT;
    LogError('SetGen', 'Invalid time resolution', SysBuff, $91);
    Exit;
  end;

  if (Freq < FREQMIN) or (Freq > FREQMAX) then begin
    SysBuff := IntToStr(Freq) + TIMUNIT;
    LogError('SetGen', 'Unsupported frequency', SysBuff, $90);
    Exit;
  end;

  peri  := NANO div Freq;  // pulse periode [ns]
  cycle := peri div TimeRes;
  duty  := cycle div 2;    // duty cycle 50%
  peri := cycle * TimeRes;

  if (duty < PulseMin) or (cycle > FREQDIV) or (peri <= 0) then begin
    SysBuff := IntToStr(Freq) + TIMUNIT;
    LogError('SetGen', 'Impossible frequency setting', SysBuff, $98);
    Exit;
  end;

  cycle := NANO div peri;
  
  SysBuff := IntToStr(cycle) + TIMUNIT;
  LogEvent('InitGen', 'Pulse generator set to frequency', SysBuff);
end;

//------------------------------------------------------------------------------
// INITTIM - Initialize hardware timer and set frequency [Hz]
//------------------------------------------------------------------ 17.02.07 --
procedure InitTim(Freq: Word);
begin
  if Freq = cOFF then begin  // switch timer off
    LogEvent('InitTim', 'Timer stopped', sEMPTY);
    Exit;
  end;

  if (Freq < FREQMIN) or (Freq > FREQMAX) then begin
    SysBuff := IntToStr(Freq) + TIMUNIT;
    LogError('InitTim', 'Unsupported frequency', SysBuff, $90);
    Exit;
  end;

  // no hardware timer implemented in DELPHI

  SysBuff := IntToStr(Freq) + TIMUNIT;
  LogEvent('InitTim', 'Timer initialized with', SysBuff);
end;

//------------------------------------------------------------------------------
// INITMEM - Initialize flash memory sectors available for application use
//   and find next free write address in flash memory
//------------------------------------------------------------------ 17.02.07 --
procedure InitMem;
var
  lident: Word;
  i, j, ret: Long;
  addr, block: Long;
begin
  MemError   := MEMERRNONE;
  MemSize    := cCLEAR;
  MemSectors := cCLEAR;
  MemBlocks  := cCLEAR;
  MemRead    := MEMUNDEF;
  MemWrite   := MEMUNDEF;
  FlashOpen  := False;

  for i := 0 to MEMBLOCKNUM - 1 do begin  // clear block buffers
    for j := 0 to MEMBLOCKLEN - 1 do begin
      MemBlock[i, j] := MEMEMPTYWORD;
    end;
  end;

  if not FileExists(FlashFile) then begin
    LogError('InitMem', 'Could not open flash memory', FlashFile, $9E);
    Exit;
  end;

  MemSize := GetFileSize(FlashFile); // get total flash size [bytes]

  ret := MemSize mod MEMSECTSIZE;

  if ret <> 0 then begin
    MemError := MEMERRSECTOR;
    SysBuff  := IntToStr(ret) + MEMUNIT;
    LogError('InitMem', 'Invalid flash sector size', SysBuff, $97);
  end;

  ret := MemSize div MEMSECTSIZE;  // get number of user flash sectors

  if ret <= MEMSECTMIN then begin
    MemError := MEMERRLITTLE;
    SysBuff  := IntToStr(ret) + sDIM + IntToStr(MEMSECTSIZE) + MEMUNIT;
    LogError('InitMem', 'Too little flash memory', SysBuff, $97);
    Exit;
  end;

  try // to open flash memory (block write buffer = 1 byte)
    AssignFile(Flash, FlashFile);
    FileMode := fmOpenReadWrite;
    Reset(Flash, MEMBYTE);  // open flash memory (file must exist!)
    FlashOpen := True;
  except
    LogError('InitMem', 'Could not access flash memory', FlashFile, $9E);
    Exit;
  end;

  MemSectors := ret;
  MemBlocks  := (MemSectors * MEMSECTSIZE) div MEMBLOCKSIZE;

  SysBuff := IntToStr(MemSectors) + sDIM + IntToStr(MEMSECTSIZE) + MEMUNIT;
  LogEvent('InitMem', 'Flash memory sectors initialized', SysBuff);

  for block := 0 to MemBlocks - 1 do begin // find next free flash cell
    addr    := block * MEMBLOCKSIZE;
    MemRead := addr;
    ReadMemWord(lident, cOFF);  // read 1st word of block

    if lident = MEMEMPTYWORD then begin  // empty block found
      MemRead  := MEMSTART;
      MemWrite := addr;
      SysBuff  := Format(ADDRFORM, [MemWrite]);
      LogEvent('InitMem', 'Flash memory write address at', SysBuff);
      Exit;
    end;
  end;

  MemRead  := MEMSTART;
  MemWrite := MEMSTART;
  SysBuff  := IntToStr(MemBlocks) + ' blocks';
  LogError('InitMem', 'No empty flash block found in', SysBuff, $9E);
end;

//------------------------------------------------------------------------------
// CLEARMEM - Clear specified sector (1..MemSectors) of flash memory (0=all)
//   Clearing a flash byte means overwrite it with 0FFh
//------------------------------------------------------------------ 17.02.07 --
procedure ClearMem(Sector: Word);
var
  addr, size: Long;
begin
  if Sector > MemSectors then begin
    MemError := MEMERRNOSECT;
    SysBuff  := IntToStr(Sector);
    LogError('ClearMem', 'Unsupported flash sector', SysBuff, $90);
    Exit;
  end;

  if Sector = MEMSTART then begin // erase all user flash sectors
    addr := MEMSTART;
    size := MEMSECTSIZE * MemSectors;
  end else begin                  // erase the specified flash sector
    addr := MEMSECTSIZE * (Sector - 1);
    size := MEMSECTSIZE;
  end;

  DisableTsw;  // 01.06.07 nk add DELPHI only (prevent multiple procedure call)

  SysBuff := Format(ADDRFORM, [addr]);
  SysBuff := IntToStr(Sector) + sSPLIT + IntToStr(size) + MEMUNIT + ' at address ' + SysBuff;
  LogEvent('ClearMem', 'Clear flash sector', SysBuff);

  WaitDuration(MEMLOGDEL);  // wait until message has been logged

  if EraseFlash(addr, size) then begin
    MemRead  := MEMSTART;
    MemWrite := addr;
    SysBuff  := IntToStr(Sector) + ' successfully cleared';
    LogEvent('ClearMem', 'Flash sector', SysBuff);
  end else begin
    MemError := MEMERRERASE;
    SysBuff  := IntToStr(Sector) + ' - code ' + IntToStr(ErrCode);
    LogError('ClearMem', 'Could not clear flash sector', SysBuff, $9E);
  end;

  EnableTsw;  // 01.06.07 nk add DELPHI only
end;

//------------------------------------------------------------------------------
// WRITEMEMWORD - Write data word (2 bytes - LSB first) into flash memory
//   if GoAhead = cON then flash cell writing errors are ignored
//------------------------------------------------------------------ 17.02.07 --
procedure WriteMemWord(Value: Word; GoAhead: Byte);
var
  ret, val: Long;
begin
  ret      := MEMERRNONE;
  MemError := MEMERRNONE;
  MemWrite := MemWrite mod MemSize;    // 03.06.07 nk add ring buffer overflow

  if Value <> MEMEMPTYWORD then begin  // do not write empty values
    val := Long(Value);                // error if cell not empty
    ret := PokemFlash(MemWrite, val, 0, WORDLEN, MEMMODEEMPTY);
  end;

  if (GoAhead = cON) or (ret = MEMERRNONE) then begin
    MemWrite := MemWrite + WORDLEN;    // move write pointer to next word
  end else begin
    MemError := MEMERRWRITE;
    SysBuff  := Format(ADDRFORM, [MemWrite]) + ' - code ' + IntToStr(ret);
    LogError('WriteMemWord', 'Writing failed at address', SysBuff, $9E);
  end;
end;

//------------------------------------------------------------------------------
// READMEMWORD - Read data word (2 bytes - LSB first) from flash memory
//   if GoAhead = cON then flash cell reading errors are ignored
//------------------------------------------------------------------ 17.02.07 --
procedure ReadMemWord(var Value: Word; GoAhead: Byte);
var
  ret, val: Long;
begin
  Value    := MEMEMPTYWORD;
  MemError := MEMERRNONE;
  MemRead  := MemRead mod MemSize; //03.06.07 nk add ring buffer overflow
  ret      := PeekFlash(MemRead, val, WORDLEN);

  if (GoAhead = cON) or (ret = MEMERRNONE) then begin
    Value   := Word(val);
    MemRead := MemRead + WORDLEN;  // move read pointer to next word
  end else begin
    MemError := MEMERRREAD;
    SysBuff  := IntToStr(MemRead) + ' - code ' + IntToStr(ErrCode);
    LogError('ReadMemWord', 'Reading failed at address', SysBuff, $9E);
  end;
end;

//------------------------------------------------------------------------------
// CLEARMEMBLOCK - Clear data block buffer
//------------------------------------------------------------------ 17.02.07 --
procedure ClearMemBlock(BlockNum: Byte);
var
  w: Word;
begin
  if BlockNum >= MEMBLOCKNUM then begin
    SysBuff := IntToStr(BlockNum);
    LogError('ClearMemBlock', 'Invalid block buffer number', SysBuff, $90);
    Exit;
  end;

  for w := 0 to MEMBLOCKLEN - 1 do begin // clear block buffer
    MemBlock[BlockNum, w] := MEMEMPTYWORD;
  end;
end;

//------------------------------------------------------------------------------
// READMEMBLOCK - Read data block buffer from flash memory (16word = 32bytes)
//------------------------------------------------------------------ 17.02.07 --
procedure ReadMemBlock(BlockNum: Byte);
var
  w, value: Word;
begin
  if BlockNum >= MEMBLOCKNUM then begin
    SysBuff := IntToStr(BlockNum);
    LogError('ReadMemBlock', 'Invalid block buffer number', SysBuff, $90);
    Exit;
  end;

  for w := 0 to MEMBLOCKLEN - 1 do begin
    ReadMemWord(value, cOFF);

    if MemError <> MEMERRNONE then begin
      ReadMemWord(value, cON);  // 2nd try - then go ahead
    end;

    MemBlock[BlockNum, w] := value;
  end;
end;

//------------------------------------------------------------------------------
// WRITEMEMBLOCK - Write data block buffer into flash memory (16word = 32bytes)
//   Clear sector if 1st cell is not empty and ClearSect = cON
//------------------------------------------------------------------ 17.02.07 --
procedure WriteMemBlock(BlockNum, ClearSect: Byte); // 01.06.07 nk add ClearSect
var
  w, sect, value: Word;
begin
  if BlockNum >= MEMBLOCKNUM then begin
    SysBuff := IntToStr(BlockNum);
    LogError('WriteMemBlock', 'Invalid block buffer number', SysBuff, $90);
    Exit;
  end;

  if (MemWrite mod MEMSECTSIZE) = 0 then begin  // 24.05.07 nk add ff
    MemWrite := MemWrite mod MemSize;           // ring buffer overflow

    if ClearSect = cON then begin
      MemRead := MemWrite;
      sect    := MemWrite div MEMSECTSIZE + 1;    // number of next sector

      SysBuff := Format(ADDRFORM, [MemWrite]);
      LogEvent('WriteMemBlock', 'New sector ' + IntToStr(sect) + ' at address', SysBuff);

      ReadMemWord(value, cOFF);  // read 1st word of next sector

      if value <> MEMEMPTYWORD then begin // next sector is not empty - clear it
        ClearMem(sect);
      end else begin
        SysBuff := IntToStr(sect);
        LogEvent('WriteMemBlock', 'Sector is already empty', SysBuff);
      end;
    end;
  end;

  for w := 0 to MEMBLOCKLEN - 1 do begin
    value := MemBlock[BlockNum, w];
    WriteMemWord(value, cOFF);

    if MemError <> MEMERRNONE then begin
      WriteMemWord(value, cON);  // 2nd try - then go ahead
    end;
  end;
end;

//------------------------------------------------------------------------------
// TICKS - DELPHI implementation for Tiger ticks
//------------------------------------------------------------------ 17.02.07 --
function Ticks: Long;
begin
  Result := GetTickCount - SysTickNull;  // read system tick counter
end;

//------------------------------------------------------------------------------
// LIMIT - DELPHI implementation for Tiger limit
//------------------------------------------------------------------ 17.02.07 --
function Limit(Val, Min, Max: Long): Long;
begin
  if Val < Min then Val := Min;
  if Val > Max then Val := Max;
  Result := Val;
end;

//------------------------------------------------------------------------------
// SETBIT - DELPHI implementation for Tiger set_bit
//   Limit: Word (16bytes)
//------------------------------------------------------------------ 17.02.07 --
procedure SetBit(var Val: Word; Bit: Byte);
var
  opr: Word;
begin
  if Bit < MEMBLOCKLEN then begin
    opr := Round(Power(2, Bit));
    Val := Val or opr;
  end;
end;

//------------------------------------------------------------------------------
// WAITDURATION - DELPHI implementation for Tiger wait_duration [ms]
//------------------------------------------------------------------ 17.02.07 --
procedure WaitDuration(Msec: Long);
begin
  Sleep(Msec);  // delay dont work (sleep is blocking!!)
  Application.ProcessMessages;
end;

//------------------------------------------------------------------------------
// DISABLETSW - DELPHI implementation for Tiger disable_tsw
//------------------------------------------------------------------ 17.02.07 --
procedure DisableTsw;
begin
  Main.MainTask.Enabled := False;
end;

//------------------------------------------------------------------------------
// ENABLETSW - DELPHI implementation for Tiger enable_tsw
//------------------------------------------------------------------ 17.02.07 --
procedure EnableTsw;
begin
  Main.MainTask.Enabled := True;
end;

//------------------------------------------------------------------------------
// OUTAUDPORT - DELPHI implementation for Tiger out AUDPORT using the PC speaker
//   Tones - cON or cOFF, Dur, Pause - tone and pause duration [ms]
//------------------------------------------------------------------ 17.02.07 --
procedure OutAudport(Tones, Dur, Pause: Word);
var
  sound: Byte;
  i, j, temp: Long;
  dsize, psize, tsize, rsize: Long;
  omega: double;
  wrec: TWaveFormatEx;
  wave: TMemoryStream;
const
  BPS         = 8;
  mono: Word  = $0001;
  rate: Long  = 8000;             // 11025, 22050, 44100
  rid: string = 'RIFF';
  wid: string = 'WAVE';           //DO NOT WORK - use WAV fiels as RESOURCE
  fid: string = 'fmt ';
  did: string = 'data';
begin
  if Tones = cOFF then Exit;

  if not SoundCard then begin     // no sound card found
    for i := 1 to Tones do begin  // use PC speaker
      Windows.Beep(TONEFREQ, Dur);
      Sleep(Pause);
    end;
    Exit;
  end;

  //nk// PlaySound('SYSTEMEXCLAMATION', 0, SND_ASYNC);  // 27.07.17 nk add ff
  //nk//Exit;

  //ff do NOT work !!

  with wrec do begin
    wFormatTag      := WAVE_FORMAT_PCM;
    nChannels       := Mono;
    nSamplesPerSec  := rate;
    wBitsPerSample  := BPS;
    nBlockAlign     := (nChannels * wBitsPerSample) div BPS;
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize          := 0;
  end;

  wave := TMemoryStream.Create;

  with wave do begin // write tones to memory and plays it on the sound card
    try
      omega := 2 * Pi * TONEFREQ / rate;
      dsize := Dur * rate div 1000;
      psize := Pause * rate div 1000;
      tsize := Tones * (dsize + psize);
      rsize := Length(wid) + Length(fid) + SizeOf(DWord) +
        SizeOf(TWaveFormatEx) + Length(did) + SizeOf(DWord) + tsize;

      // write out the wave header
      Write(rid[1], 4);                   // 'RIFF'
      Write(rsize, SizeOf(DWord));        // file data size
      Write(wid[1], Length(wid));         // 'WAVE'
      Write(fid[1], Length(fid));         // 'fmt '
      temp := SizeOf(TWaveFormatEx);
      Write(temp, SizeOf(DWord));         // TWaveFormat data size
      Write(wrec, SizeOf(TWaveFormatEx)); // WaveFormatEx record
      Write(did[1], Length(did));         // 'data'
      Write(tsize, SizeOf(DWord));        // tone data size

      // write out the tone signal
      for j := 1 to Tones do begin
        for i := 0 to dsize - 1 do begin  // beep
          sound := 127 + Trunc(Loudness * Sin(i * omega));
          Write(sound, SizeOf(Byte));
        end;

        for i := 0 to psize - 1 do begin  // pause
          sound := 127;
          Write(sound, SizeOf(Byte));
        end;
      end;

      // now play the sound
      SndPlaySound(Memory, SND_MEMORY or SND_SYNC or SND_NODEFAULT);
    finally
      Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ERASEFLASH - DELPHI implementation for Tiger erase_flash
//  Addr: Start address - must coincide with a sector start address
//  Size: Number of bytes to erase - must be a multiple of sector size
//------------------------------------------------------------------ 17.02.07 --
function EraseFlash(Addr, Size: Long): Boolean;
var
  value: Byte;
  i: Long;
  ret: Long;
begin
  Result  := False;
  ErrCode := SYSNOERR;

  if Addr < 0                  then ErrCode := MEMERRPARAM;
  if Addr mod MEMSECTSIZE <> 0 then ErrCode := MEMERRPARAM;
  if Addr > MemSize            then ErrCode := MEMERRADDR;
  if Size <= 0                 then ErrCode := MEMERRPARAM;
  if Size mod MEMSECTSIZE <> 0 then ErrCode := MEMERRPARAM;
  if (Addr + Size) > MemSize   then ErrCode := MEMERREOF;

  if ErrCode <> SYSNOERR then Exit;

  try // to access flash memory (file must be open)
    Seek(Flash, Addr);
  except
    ErrCode := SYSMEMAVAILERR;
    Exit;
  end;

  ErrCode := SYSMEMWRITEERR;
  value   := MEMEMPTYBYTE;

  try // to fill flash memory with 0FFh (=empty cell)
    for i := Addr to (Addr + Size - 1) do begin
      BlockWrite(Flash, value, MEMBYTE, ret); // clear next byte in the flash memory
      if ret <> MEMBYTE then Exit;
      if i mod KILO = 0 then Sleep(50);       // simulate flash write delay
    end;
  except
    Exit;
  end;

  ErrCode := SYSNOERR;
  Result  := True;
end;

//------------------------------------------------------------------------------
// PEEKFLASH - DELPHI implementation for Tiger peek_flash
//------------------------------------------------------------------ 17.02.07 --
function PeekFlash(Addr: Long; var Value: Long; Size: Long): Long;
var
  ret: Long;
begin
  Result  := MEMERRREAD;
  Value   := MEMEMPTYBYTE;
  ErrCode := SYSNOERR;

  if Addr < 0                then ErrCode := MEMERRPARAM;
  if Addr > MemSize          then ErrCode := MEMERRADDR;
  if Size <= 0               then ErrCode := MEMERRPARAM;
  if (Addr + Size) > MemSize then ErrCode := MEMERREOF;

  if ErrCode <> SYSNOERR then Exit;

  try // to access flash memory (DELPHI file must be open)
    Seek(Flash, Addr);
  except
    ErrCode := SYSMEMAVAILERR;
    Exit;
  end;

  ErrCode := SYSMEMPEEKERR;

  try // to read flash memory cell
    BlockRead(Flash, Value, Size, ret);
    if ret <> Size then Exit;
  except
    Exit;
  end;

  ErrCode := SYSNOERR;
  Result  := MEMERRNONE;
end;

//------------------------------------------------------------------------------
// POKEMFLASH - DELPHI implementation for Tiger pokem_flash
//------------------------------------------------------------------ 17.02.07 --
function PokemFlash(Addr, Value, Index, Size, Mode: Long): Long;
var
  cell: Word;
  ret: Long;
begin
  Result := MEMERRNONE;

  if Addr < 0                           then Result := MEMERRPARAM;
  if Addr > MemSize                     then Result := MEMERRADDR;
  if Size <= 0                          then Result := MEMERRPARAM;
  if (Addr + Size) > MemSize            then Result := MEMERREOF;
  if Value < 0                          then Result := MEMERRBYTES;
  if Value > Power(2, (Size * BYTELEN)) then Result := MEMERRSOURCE;
  if Index <> 0                         then Result := MEMERRPARAM;
  if (Mode < 0) or (Mode > 1)           then Result := MEMERRPARAM;

  if Result <> MEMERRNONE then Exit;

  if Mode = MEMMODEEMPTY then begin  // check if cell is empty
    Result := SYSMEMCELLERR;
    try // to read flash memory cell (file must be open)
      Seek(Flash, Addr);
      BlockRead(Flash, cell, WORDLEN, ret);
      if ((ret <> WORDLEN) or (cell <> MEMEMPTYWORD)) then Exit;
    except
      Exit;
    end;
  end;

  Result := SYSMEMWRITEERR;

  try // to write flash memory cell
    Seek(Flash, Addr);
    BlockWrite(Flash, Value, Size, ret);
    if ret <> Size then Exit;
  except
    Exit;
  end;

  Result := MEMERRNONE;
end;

initialization  // Tiger hardware configuration

  for ErrCode  := 0 to DEVMAX do DevVers[ErrCode] := cOFF;

  DevVers[RUN] := $106D;  // Processor Module Vers. 1.06n
  DevVers[RTC] := $1009;  // Real Time Clock Vers. 1.00j
  DevVers[SER] := $1028;  // Serial Port Vers. 1.02i
  DevVers[ADC] := $1013;  // A/D Converter Vers. 1.01d
  DevVers[LCD] := $1015;  // Graphic Display Vers. 1.01f

  FlashFile    := ProgPath + FLASH_PATH + FLASH_FILE  + FLASH_POST;
  SernoFile    := ProgPath + FLASH_PATH + FLASH_SERNO + FLASH_POST;
  FlashOpen    := False;
  SysTickNull  := cCLEAR;
  SoundCard    := (WaveOutGetNumDevs > 0);
  InitialMem   := GetAllocMemSize; //25.07.17 nk old=AllocMemSize (deprecated)
  ErrCode      := SYSNOERR;

finalization
  if FlashOpen then CloseFile(Flash);

  FlashOpen := False;
  FlashFile := sEMPTY;
  SernoFile := sEMPTY;

end.
