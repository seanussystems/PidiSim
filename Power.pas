// Power Supply and Digital Potmeter Functions
// Date 25.07.17
// Norbert Koechli
// Copyright ©2007-2017 seanus systems

// DELPHI: No power control for external voltage regulators implemented

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit Power;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, USystem, SYS, ADC,
  Global, Data, Texts, FLog;

  procedure InitPower;
  procedure SetPower(Channel, Mode: Byte);
  procedure ReadAccu(DeltaTime: Long; var AccuPower, AccuTime: Long);
  procedure InitDigipot(Addr: Byte);
  procedure SetDigipot(Addr, Wiper: Byte);
  procedure StoreDigipot(Addr: Byte);

const
  PWRPOTDVREG     = $011;  // digipot data -> volatile memory
  PWRPOTDNREG     = $021;  // digipot write data -> nonvolatile memory
  PWRPOTVNREG     = $051;  // digipot write volatile -> nonvolatile memory
  PWRPOTNVREG     = $061;  // digipot write nonvolatile -> volatile memory

  PWRPOTWIPEROFF  = 3;     // shift 5 bit data to MSB (D7..D3, D2..D0 ignored)
  PWRPOTWRITEDEL  = 12;    // idle time after write to nonvolatile memory [ms]
  PWRPOTWIPERMAX  = 31;    // max wiper positions (0..31)
  PWRSETDEL       = 20;    // power setting delay time (20ms)

var // module variables
  PwrRet: Long;
  PwrBuff: string;         // modul message buffer / old=[MAXTEMP]

implementation

uses FMain, FGui;

//------------------------------------------------------------------------------
// INITPOWER - Initialize power management and set processor self hold on
//------------------------------------------------------------------ 17.02.07 --
procedure InitPower;
var
  pnum, ppin, pport: Byte;
begin
  ppin := PWRHOLDPIN mod 10;
  pport := PWRHOLDPIN div 10;
  pnum := 10 * pport + ppin;

  PwrBuff := IntToStr(pnum);
  LogEvent('InitPower', 'Set processor self hold at pin', PwrBuff);
end;

//------------------------------------------------------------------------------
// SETPOWER - Power management control for external voltage regulators
//   Mode - ON = pin high, OFF = pin low
//------------------------------------------------------------------ 17.02.07 --
procedure SetPower(Channel, Mode: Byte);
var
  pnum, ppin, pport: Byte;
begin
  if Mode > cON then begin
    PwrBuff := IntToStr(Mode);
    LogError('SetPower', 'Invalid power mode', PwrBuff, $90);
    Exit;
  end;

  case Channel of
    PWRDISP: begin  // switch display on/off
      ppin := PWRDISPPIN mod 10;
      pport := PWRDISPPIN div 10;
      Gui.Display.Visible := (Mode = cON); // DELPHI only
    end;

    PWRLITE: begin  // switch backlite on/off
      ppin := PWRLITEPIN mod 10;
      pport := PWRLITEPIN div 10;
    end;

    PWRHOLD: begin  // switch processor module on/off (self hold)
      ppin := PWRHOLDPIN mod 10;
      pport := PWRHOLDPIN div 10;
      if Mode = cOFF then Main.Close;  // DELPHI: close application
    end;

    PWRSALT: begin  // switch salinity sensor on/off
      ppin := PWRSALTPIN mod 10;
      pport := PWRSALTPIN div 10;
    end;

    PWRSONAR: begin  // switch sonar receiver on/off
      ppin := PWRSONARPIN mod 10;
      pport := PWRSONARPIN div 10;
    end;

    PWRMODUL: begin  // switch external module on/off
      ppin := PWRMODULPIN mod 10;
      pport := PWRMODULPIN div 10;
    end;
  else
    PwrBuff := IntToStr(Channel);
    LogError('SetPower', 'Invalid power channel', PwrBuff, $90);
    Exit;
  end;

  pnum := 10 * pport + ppin;
  PwrBuff := IntToStr(Channel) + ' (pin ' + IntToStr(pnum) + ') to level ' + IntToStr(Mode);
  LogEvent('SetPower', 'Switch power channel', PwrBuff);
end;

//------------------------------------------------------------------------------
// READACCU - Read the accu voltage [cts] and calculate the remaining accu
//   power [%] and the remaining accu time [s]
//   DELPHI read power status if the PC is a battery supplied laptop or
//          simulates accu power decrease if not
//------------------------------------------------------------------ 17.02.07 --
procedure ReadAccu(DeltaTime: Long; var AccuPower, AccuTime: Long);
var       //07.06.07 nk add DeltaTime TIGER
  accu, volt, time: Long;
begin
  ReadAdc(ADCACCU, accu);  // 05.06.07 nk opt get remain accu counts [cts]

  volt := ADCBITVOLT * accu;          // measured input voltage [uV]
  volt := volt * ACCUATTEN div MILLI; // attenuated accu voltage [mV]

  if AccuRate > 0 then begin
    time := MILLI * (volt - ACCUMIN) div AccuRate;
  end else begin
    time := AccuTime;
  end;

  volt := (volt - ACCUMIN) div ((ACCUMAX - ACCUMIN) div PROCENT);

  AccuTime  := Limit(time, 0, TIMEDISP); // remaining accu time [s]
  AccuPower := Limit(volt, 0, PROCENT);  // remaining accu power [%]

 // PwrBuff := 'Volt: ' + IntToStr(AccuPower) + ' Time: ' + IntToStr(AccuTime) + ' Counts: ' + FloatToStr(cts);
 // LogEvent('ReadAccu', 'Accu', PwrBuff); //nk// test

  if DeltaTime = 0 then begin  // 07.06.07 nk add ff
    PwrBuff := IntToStr(AccuPower) + PWRUNIT;
    LogEvent('ReadAccu', 'Remain accu power', PwrBuff);
  end;
end;

//------------------------------------------------------------------------------
// INITDIGIPOT - Initialize digital potmeter
//   DELPHI no Digipots implemented
//------------------------------------------------------------------ 17.02.07 --
procedure InitDigipot(Addr: Byte);
begin
  PwrRet := cCLEAR;
  PwrBuff := IntToStr(Addr);

  WaitDuration(PWRPOTWRITEDEL);

  LogEvent('InitDigipot', 'Digipot initialized at address', PwrBuff);
end;

//------------------------------------------------------------------------------
// SETDIGIPOT - Set new wiper position of digital potmeter - not in NVRAM
//   DELPHI simulate contrast, brightness, and loudness in LCD and SYS
//------------------------------------------------------------------ 17.02.07 --
procedure SetDigipot(Addr, Wiper: Byte);
begin
  if Wiper > PWRPOTWIPERMAX then begin
    PwrBuff := IntToStr(Wiper);
    LogError('SetDigipot', 'Invalid wiper position', PwrBuff, $90);
    Exit;
  end;
end;

//------------------------------------------------------------------------------
// STOREDIGIPOT - Store actual wiper position into NVRAM
//   DELPHI no Digipots implemented
//------------------------------------------------------------------ 17.02.07 --
procedure StoreDigipot(Addr: Byte);
begin
  PwrRet := cCLEAR;
  PwrBuff := IntToStr(Addr);

  LogEvent('StoreDigipot', 'Wiper position stored at address', PwrBuff);
  
  WaitDuration(PWRPOTWRITEDEL);
end;

end.
