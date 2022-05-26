// Interface to RTC Device Driver (Real Time Clock)
// Date 25.07.17
// Norbert Koechli
// Copyright ©2007-2017 seanus systems

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit RTC;

interface

uses
  Windows, Forms, Types, Controls, Graphics, SysUtils, ExtCtrls, DateUtils,
  USystem, URegistry, SYS, Global, Data, FLog, UPidi;

const
  RTCTIME       = 0;               // RTC time address
  RTCALARM      = 1;               // RTC alarm address

  RTCMODE       = $0A0;            // get RTC mode:
  RTCINITIAL    = 0;               // -after initializing
  RTCINSTALL    = 1;               // -RTC is installing
  RTCFAILED     = 2;               // -no RTC hardware found
  RTCPRESENT    = 3;               // -RTC is present
  RTCRETRY      = 4;               // -retry RTC searching

  RTCSTATE      = $0A1;            // get RTC state:
  RTCREADY      = 0;               // -RTC is ready
  RTCBUSY       = 1;               // -RTC is busy

  RTCSETDEL     = 20;              // delay time per RTC status loop [ms]
  RTCLOOPS      = 255;             // RTC retry loops
  RTCMAX        = 2144448000;      // max range of RTC [s] (68 years)
  RTCTICKS      = 2147483647;      // max range of tick counter [ms] (24 hours)

  RTCUNIT       = ' sec';          // RTC standard unit
  RTCALARMSET   = 'Alarm';         // DELPHI reg key for alarm time

var // module variables
  RtcInit: Byte;            // real time clock init flag
  RtcEvent: Long;           // real time clock event (Tiger=Byte)
  RtcCtr: Word;             // RTC loop counter
  RtcBuff: string;          // modul message buffer / old=[MAXTEMP]

  // Tiger interface to RTC device driver (RTC.INC)
  procedure InitRtc(Mode: Byte);
  procedure SetRtcTime(Itime: Long);
  procedure GetRtcTime(var Otime: Long);
  procedure SetRtcAlarm(Atime: Long);

  // Tiger RTC device driver functions (RTC.TDD)
  procedure Get_RTC(Mode: Byte; var Time: Long);
  procedure Put_RTC(Addr: Byte; Time: Long);

implementation

uses FMain, FGui, Clock;

//------------------------------------------------------------------------------
// INITRTC - Initialize the internal real time clock
//------------------------------------------------------------------ 17.02.07 --
procedure InitRtc(Mode: Byte);
var
  r: Long;
begin
  RtcCtr := cCLEAR;
  ErrCode := cOFF;
  RtcInit := cOFF;
  RtcEvent := RTCINITIAL;

  while RtcEvent < RTCFAILED do begin  // wait until driver is installed
    RtcCtr := RtcCtr + 1;
    WaitDuration(RTCSETDEL);
    Get_RTC(RTCMODE, RtcEvent);

    if (RtcCtr >= RTCLOOPS) or (ErrCode > cOFF) then begin // RTC installation error
      RtcBuff := IntToStr(RtcEvent);
      LogError('InitRtc', 'RTC driver installation failed - return', RtcBuff, $9A);
      Exit;
    end;
  end;

  RtcCtr := cCLEAR;
  
  if RtcEvent = RTCPRESENT then begin
    RtcEvent := RTCBUSY;
    while RtcEvent = RTCBUSY do begin
      RtcCtr := RtcCtr + 1;
      WaitDuration(RTCSETDEL);
      Get_RTC(RTCSTATE, RtcEvent);

      if (RtcCtr >= RTCLOOPS) or (ErrCode > cOFF) then begin  // RTC timeout error
        RtcBuff := IntToStr(RtcEvent);
        LogError('InitRtc', 'RTC driver installation timeout - return', RtcBuff, $9A);
        Exit;
      end;
    end;
  end else begin
    RtcBuff := IntToStr(RtcEvent);
    LogError('InitRtc', 'No real time clock found - return', RtcBuff, $9A);
    Exit;
  end;

  if Mode = cCLEAR then begin
    Put_RTC(RTCTIME, cCLEAR);   // reset clock (has no effect in DELPHI)
  end;

  if ErrCode > cOFF then begin  // RTC driver error
    RtcBuff := IntToStr(ErrCode);
    LogError('InitRtc', 'RTC initialisation failed - return', RtcBuff, $9A);
    ErrCode := cOFF;
    Exit;
  end;

  for r := 0 to RTCLOOPS do begin
    WaitDuration(RTCSETDEL);
    Get_RTC(RTCSTATE, RtcEvent);

    if RtcEvent = RTCREADY then begin
      RtcInit := cINIT;
      RtcBuff := IntToStr(r) + ' loops';
      LogEvent('InitRtc', 'Real time clock initialized within', RtcBuff);
      Exit;
    end;
  end;

  RtcBuff := IntToStr(RtcEvent);
  LogError('InitRtc', 'Real time clock not ready - return', RtcBuff, $9A);
end;

//------------------------------------------------------------------------------
// SETRTCTIME - Set new absolute timedate [s] of real time clock
//------------------------------------------------------------------ 17.02.07 --
procedure SetRtcTime(Itime: Long);
var
  r: Long;
begin
  if (RtcInit <> cINIT) and (RtcInit <> cERROR) then begin
    LogError('SetRtcTime', 'Real time clock not initialized', sEMPTY, $96);
    RtcInit := cERROR;
    Exit;
  end;

  RtcEvent := RTCRETRY;

  Put_RTC(RTCTIME, Itime); // set new absolute timedate [s]

  for r := 0 to RTCLOOPS do begin
    WaitDuration(RTCSETDEL);
    Get_RTC(RTCSTATE, RtcEvent);  // check RTC event

    if RtcEvent = RTCREADY then begin
      RtcBuff := IntToStr(Itime) + RTCUNIT;
      LogEvent('SetRtcTime', 'Real time clock set to', RtcBuff);
      Exit;
    end;
  end;

  RtcBuff := IntToStr(RtcEvent);
  LogError('SetRtcTime', 'Real time clock not ready - return', RtcBuff, $9A);
end;

//------------------------------------------------------------------------------
// GETRTCTIME - Get actual timedate [s] of real time clock
//------------------------------------------------------------------------------
// Return: TimeDate in absolute seconds since 01.01.2000 at 00:00:00
//------------------------------------------------------------------ 17.02.07 --
procedure GetRtcTime(var Otime: Long);
var
  r: Long;
begin
  Otime := cCLEAR;

  if (RtcInit <> cINIT) and (RtcInit <> cERROR) then begin
    LogError('GetRtcTime', 'Real time clock not initialized', sEMPTY, $96);
    RtcInit := cERROR;
    Exit;
  end;

  RtcEvent := RTCRETRY;

  for r := 0 to RTCLOOPS do begin
    Get_RTC(RTCSTATE, RtcEvent);  // check RTC event

    if RtcEvent = RTCREADY then begin
      Get_RTC(RTCTIME, Otime);    // get absolute timedate [s]
      Exit;
    end;

    WaitDuration(RTCSETDEL);
  end;

  RtcBuff := IntToStr(RtcEvent);
  LogError('GetRtcTime', 'Real time clock not ready - return', RtcBuff, $9A);
end;

//------------------------------------------------------------------------------
// SETRTCALARM - Set absolute alarm timedate [s] of real time clock
//------------------------------------------------------------------ 18.11.05 --
procedure SetRtcAlarm(Atime: Long);
var
  r: Long;
begin
  if (RtcInit <> cINIT) and (RtcInit <> cERROR) then begin
    LogError('SetRtcAlarm', 'Real time clock not initialized', sEMPTY, $96);
    RtcInit := cERROR;
    Exit;
  end;

  RtcEvent := RTCRETRY;

  Put_RTC(RTCALARM, Atime);  // set alarm timedate [s]

  for r := 0 to RTCLOOPS do begin
    WaitDuration(RTCSETDEL);
    Get_RTC(RTCSTATE, RtcEvent);  // check RTC event

    if RtcEvent = RTCREADY then begin
      RtcBuff := IntToStr(Atime) + RTCUNIT;
      LogEvent('SetRtcAlarm', 'Real time clock alarm set to', RtcBuff);
      Exit;
    end;
  end;

  RtcBuff := IntToStr(RtcEvent);
  LogError('SetRtcAlarm', 'Real time clock not ready - return', RtcBuff, $9A);
end;

//------------------------------------------------------------------------------
// GET_RTC - DELPHI implementation for Tiger get #RTC
//------------------------------------------------------------------ 18.11.05 --
procedure Get_RTC(Mode: Byte; var Time: Long);
var
  ret: Boolean;
  nul, act: TDateTime;
  sek: LongWord;
  tlocal: TSystemTime;
begin
  case Mode of
    RTCTIME: begin
      try
        act := Now;
        nul := EncodeDate(FIRSTYEAR, 01, 01);  // 01.01.2000
        sek := SecondOfTheDay(act);
        Time := sek + SEC_DAY * (Trunc(act - nul));
      except
        ErrCode := cERROR;
        Time := cCLEAR;
      end;
    end;

    RTCMODE: begin
      try // check RTC hardware
        GetLocalTime(tlocal);
        ret := SetLocalTime(tlocal);
        Time := RTCPRESENT;
      except
        ret := False;
      end;

      if ret = True then begin
        Time := RTCPRESENT;
      end else begin
        ErrCode := cERROR;
        Time := RTCFAILED;
      end;
    end;

    RTCSTATE: begin
      try // check RTC access
        GetLocalTime(tlocal);
        Time := RTCREADY;
      except
        Time := RTCFAILED;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// PUT_RTC - DELPHI implementation for Tiger put #RTC
//------------------------------------------------------------------ 17.02.07 --
procedure Put_RTC(Addr: Byte; Time: Long);
var
  ret: Boolean;
  ye, mo, da, ho, mi, se, wd: Long;
  systime: TSystemTime;
begin
  ret := True;

  if Addr = RTCTIME then begin   // set absolute timedate [s]
    try
      if Time = cOFF then Exit;  // DELPHI do not clear system clock

      ConvertTimeDate(ye, mo, da, ho, mi, se, wd, Time);

      with systime do begin
        wYear := FIRSTYEAR + ye;
        wMonth := mo;
        wDay := da;
        wHour := ho;
        wMinute := mi;
        wSecond := se;
        wMilliSeconds := cCLEAR;
      end;

      ret := SetLocalTime(systime);
      Sleep(2000);  // simulate Tiger setting delay
    except
      ret := False;
    end;
  end;

  if Addr = RTCALARM then begin  // set alarm timedate [s]
    try
      ret := SetRegString(RegPath + REG_SETTINGS, RTCALARMSET, IntToStr(Time));
    except
      ret := False;
    end;
  end;

  if ret = True then
    RtcEvent := RTCREADY
  else
    RtcEvent := RTCFAILED;
end;

initialization  // Tiger hardware configuration
  RtcInit := cOFF;
  RtcEvent := RTCINITIAL;
  RtcCtr := cCLEAR;
  RtcBuff := sEMPTY;

finalization
  RtcInit := cOFF;
  RtcEvent := RTCINITIAL;
  RtcCtr := cCLEAR;
  RtcBuff := sEMPTY;

end.
