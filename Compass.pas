// Digital Compass Functions
// Date 26.05.22

// DELPHI simulate the Digital Compass Honeywell HMC6352
// with the Track Bar 'tbCompass' on Form 'Daq'

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit Compass;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, USystem,
  SYS, Global, Data, Texts, FLog;

  procedure InitCompass;
  procedure SetCompass(Mode: Byte);
  procedure ReadCompass(var Heading: Word);

const
  COMPWRITEADDR   = $42;  // digital compass I2C write address
  COMPREADADDR    = $43;  // digital compass I2C read address
                          // RAM internal register addresses
  COMPOUTPUTMODE  = $4E;  //  output mode register (1 byte)
  COMPOPERATMODE  = $74;  //  operation mode register (1 byte)
                          // EEPROM internal register addresses
  COMPMSBXOFFSET  = $01;  //  magnetometer X offset MSB \
  COMPLSBXOFFSET  = $02;  //  magnetometer X offset LSB  factory test
  COMPMSBYOFFSET  = $03;  //  magnetometer Y offset MSB  values
  COMPLSBYOFFSET  = $04;  //  magnetometer Y offset LSB /
  COMPTIMEDELAY   = $05;  //  time delay register (1 byte)
  COMPMEASUREAVG  = $06;  //  measure averaging register (1 byte)
  COMPVERSION     = $07;  //  software version register (1 byte, read only)
  COMPOPERMODE    = $08;  //  operation mode register (1 byte)
                          // digital compass commands
  COMPHEADREAD    = $41;  //  read compass heading
  COMPCALIBON     = $43;  //  enter user calibration mode
  COMPCALIBOFF    = $45;  //  exit user calibration mode
  COMPRAMWRITE    = $47;  //  write to RAM register
  COMPSAVEMODE    = $4C;  //  save operation mode to EEPROM
  COMPUPDATE      = $4F;  //  update bridge offsets (S/R now)
  COMPSLEEP       = $53;  //  enter sleep mode (sleep)
  COMPWAKEUP      = $57;  //  exit sleep mode (wakeup)
  COMPRAMREAD     = $67;  //  read from RAM register
  COMPROMREAD     = $72;  //  read from EEPROM
  COMPROMWRITE    = $77;  //  write to EEPROM
                          // operation modes (D2, D3 and D7 are always 0) add together
  COMPSTANDBY     = $00;  //  standby mode          \
  COMPQUERY       = $01;  //  query mode              bits D0 and D1
  COMPCONT        = $02;  //  continuous mode       /
  COMPCONTOFF     = $00;  //  periodic S/R off      \ bit
  COMPCONTON      = $10;  //  periodic S/R on       / D4  COMPCONT
  COMPRATE01      = $00;  //  measurement rate 1Hz  \
  COMPRATE05      = $20;  //  measurement rate 5Hz    bits D5
  COMPRATE10      = $40;  //  measurement rate 10Hz   and D6
  COMPRATE20      = $60;  //  measurement rate 20Hz /
                          // output modes (D3..D7 are always 0)
  COMPHEADING     = $00;  //  heading mode           \
  COMPMAGRAWX     = $01;  //  raw magnetometer X mode \
  COMPMAGRAWY     = $02;  //  raw magnetometer Y mode  bits D0..D2
  COMPMAGX        = $03;  //  magnetometer X mode     /
  COMPMAXY        = $04;  //  magnetometer Y mode    /

  COMPVERSSET     = $01;  // valid software version if >0
  COMPDELSET      = $01;  // time delay before measurements are made = 1 (1..255ms)
  COMPAVGSET      = $04;  // number of measurements for averaging = 4 (1..16)

  COMPBYTE        = 8;    // I2C bus byte lenght = 8bit
  COMPWORD        = 16;   // I2C bus word lenght = 16bit

  COMPREADLEN     = 2;    // read data lenght = 2bytes MSB first
  COMPWRITEDEL    = 1;    // delay time after writing data [ms]
  COMPREADDEL     = 10;   // delay time after reading data [>6ms]
  COMPCALIBDEL    = 20;   // delay time after calibration [>14ms]
  COMPHEADMIN     = 0;    // valid compass heading from
  COMPHEADMAX     = 3599; // 0..3599ddeg (1/10deg)

  HEADUNIT        = '°';     // compass heading unit
  HEADFORM        = '%3.1f'; // heading format 123.4°

var
  CompBuff: string;          // modul message buffer / old=[MAXBUFF]

implementation

uses FMain, FDaq, FTrack;

//------------------------------------------------------------------------------
// INITCOMPASS - Initialize digital compass and get software version
//------------------------------------------------------------------ 17.02.07 --
procedure InitCompass;
begin
  Heading := cCLEAR;
  Daq.tbCompass.Position := HALFCIRC;

  CompBuff := IntToStr(COMPVERSSET);
  LogEvent('InitCompass', 'Digital compass software version', CompBuff);

  CompBuff := Format(HEADFORM, [Heading / DDEG]) + HEADUNIT;
  LogEvent('InitCompass', 'Digital compass heading', CompBuff);

  CompBuff := IntToStr(COMPWRITEADDR);
  LogEvent('InitCompass', 'Digital compass initialized at address', CompBuff);
end;

//------------------------------------------------------------------------------
// SETCOMPASS - Set digital compass command (wakeup, sleep, calibrate)
//------------------------------------------------------------------ 17.02.07 --
procedure SetCompass(Mode: Byte);
begin
  if (Mode < COMPHEADREAD) or (Mode > COMPWAKEUP) then begin
    CompBuff := IntToStr(Mode);
    LogError('SetCompass', 'Invalid digital compass command', CompBuff, $90);
    Exit;
  end;

  WaitDuration(COMPWRITEDEL);
end;

//------------------------------------------------------------------------------
// READCOMPASS - Get heading [ddeg] from digital compass
//------------------------------------------------------------------ 17.02.07 --
procedure ReadCompass(var Heading: Word);
begin
  Heading := (Daq.tbCompass.Position + HALFCIRC) mod FULLCIRC;
end;


end.
