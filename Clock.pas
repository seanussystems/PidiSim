// Time, Date and Calendar Functions
// Date 26.05.22

unit Clock;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, DateUtils, USystem,
  SYS, RTC, Global, Data, Texts, FLog;

  procedure InitTimeDate;
  procedure InitHolidays;
  procedure GetTotalDays(var Td, Ad, Aw, Wd: Long; Ye, Mo, Da: Long);
  procedure CreateTimeDate(var Otime: Long; Ye, Mo, Da, Ho, Mi, Se: Long);
  procedure ConvertTimeDate(var Ye, Mo, Da, Ho, Mi, Se, Wd: Long; Dtime: Long);
  procedure GetSummerTime(var Tdiff: Long; Ye, Mo, Da, Ho: Long; Mode: Byte);
  procedure GetClock(var Otime, Ye, Mo, Da, Ho, Mi, Se, Wd: Long);
  procedure SetClock(Ye, Mo, Da, Ho, Mi, Se: Long);
  procedure CheckAlarm(var Aflag: Byte; var Dtime: Long; var Alarm: string);
  procedure GetUsTime(var Ho: Long; var Tf: string);
  procedure GetHoliday(Ye, Mo, Da: Long; var Hd: Byte);
  procedure GetTimeStamp(var TimeStamp: string);
  procedure FormatTime(Itime, Tdiv: Long; var Otime: Long);
  procedure FormatTimeDate(Itime: Long; var Stime, Sdate, Lmon, Sday, Lday, Tf: string);
  procedure GetMoonPhase(var Mphase: Byte; DayNum: Long);

const
  TENHOUR        = 959;             // formatted time for 10 hours
  MIDDAY         = 12;              // middle of a day = 12:00
  FIRSTDAY       = 6;               // first day at 01.01.2000 is saturday
  FIRSTYEAR      = 2000;            // first year is 2000
  MAXYEARS       = 26;              // number of supported years (2000..2025)
  MAXHOLI        = 10;              // number of defined holidays per year

  AM             = 'A';             // american time format (00:00-11:59)
  PM             = 'P';             //                      (12:00-23:59)
  MF             = 'M';
  TIMESEP        = ':';             // time separator

  // time and date format constants (with leading 0)
  TIMESHORTFORM  =  '%.2d:%.2d';           // short time format     'hh:mm'
  TIMELONGFORM   =  '%.2d:%.2d:%.2d';      // long time format      'hh:mm:ss'
  TIMEPRECFORM   =  '%.2d:%.2d:%.2d.%.3d'; // precise time format   'hh:mm:ss.ttt'
  DATESHORTFORM  =  '%.2d.%.2d.%.2d';      // short date format     'DD.MM.YY'
  DATELONGFORM   =  '%.2d.%.2d.%.4d';      // long date format      'DD.MM.YYYY'
  DATESHORT_EU   =  '%.2d.%.2d.%.2d';      // EU short date format  'DD.MM.YY'
  DATESHORT_US   =  '%.2d|%.2d|%.2d';      // US short date format  'MM/DD/YY'
  DATESHORT_ISO  =  '%.2d\%.2d\%.2d';      // ISO short date format 'YY-MM-DD'

var
  AlarmFlag: Byte;    // OFF=alarm not set / ON=alarm set
  
  TimeDate: Long;  // absolute time since last setting [s]
  TimeDiff: Long;  // time correction for summer time [s]

  TimeNow: string;    // actual time in the format 'hh:mm'
  TimeStamp: string;  // time stamp in the format 'DD.MM.YY hh:mm:ss.ttt'

  MonthDays: array[0..MONTH_YEAR] of Byte;  // number of days in month
  DsavBeg: array[0..MAXYEARS] of Word;      // begin of daylight saving time
  DsavEnd: array[0..MAXYEARS] of Word;      // end of daylight saving time
  HoliDate: array[0..MAXHOLI, 0..MAXYEARS] of Word; // date of holidays

implementation

uses FMain;

//------------------------------------------------------------------------------
// INITTIMEDATE - Initialize time and date constants for the years 2000 to 2025
//------------------------------------------------------------------ 17.02.07 --
procedure InitTimeDate;
begin
  AlarmFlag := cOFF;
  TimeDate  := cCLEAR;
  TimeDiff  := cCLEAR;

  MonthDays[0]  :=  31;  // number of days in january..december
  MonthDays[1]  :=  28;
  MonthDays[2]  :=  31;
  MonthDays[3]  :=  30;
  MonthDays[4]  :=  31;
  MonthDays[5]  :=  30;
  MonthDays[6]  :=  31;
  MonthDays[7]  :=  31;
  MonthDays[8]  :=  30;
  MonthDays[9]  :=  31;
  MonthDays[10] :=  30;
  MonthDays[11] :=  31;

  DsavBeg[00] :=  0326;  // definition of DST start [YY] = 'MMDD' [Europe]
  DsavBeg[01] :=  0325;
  DsavBeg[02] :=  0331;
  DsavBeg[03] :=  0330;
  DsavBeg[04] :=  0328;
  DsavBeg[05] :=  0327;
  DsavBeg[06] :=  0326;
  DsavBeg[07] :=  0325;
  DsavBeg[08] :=  0330;
  DsavBeg[09] :=  0329;
  DsavBeg[10] :=  0328;
  DsavBeg[11] :=  0327;
  DsavBeg[12] :=  0325;
  DsavBeg[13] :=  0331;
  DsavBeg[14] :=  0330;
  DsavBeg[15] :=  0329;
  DsavBeg[16] :=  0327;
  DsavBeg[17] :=  0326;
  DsavBeg[18] :=  0325;
  DsavBeg[19] :=  0331;
  DsavBeg[20] :=  0329;
  DsavBeg[21] :=  0328;
  DsavBeg[22] :=  0327;
  DsavBeg[23] :=  0326;
  DsavBeg[24] :=  0331;
  DsavBeg[25] :=  0330;

  DsavEnd[00] :=  1029;  // definition of DST end [YY] = 'MMDD' [Europe]
  DsavEnd[01] :=  1028;
  DsavEnd[02] :=  1027;
  DsavEnd[03] :=  1026;
  DsavEnd[04] :=  1031;
  DsavEnd[05] :=  1030;
  DsavEnd[06] :=  1029;
  DsavEnd[07] :=  1028;
  DsavEnd[08] :=  1026;
  DsavEnd[09] :=  1025;
  DsavEnd[10] :=  1031;
  DsavEnd[11] :=  1030;
  DsavEnd[12] :=  1028;
  DsavEnd[13] :=  1027;
  DsavEnd[14] :=  1026;
  DsavEnd[15] :=  1025;
  DsavEnd[16] :=  1030;
  DsavEnd[17] :=  1029;
  DsavEnd[18] :=  1028;
  DsavEnd[19] :=  1027;
  DsavEnd[20] :=  1025;
  DsavEnd[21] :=  1031;
  DsavEnd[22] :=  1030;
  DsavEnd[23] :=  1029;
  DsavEnd[24] :=  1027;
  DsavEnd[25] :=  1026;
end;

//------------------------------------------------------------------------------
// INITHOLIDAYS - Initialize holiday array for the years 2000 to 2025
//------------------------------------------------------------------ 17.02.07 --
procedure InitHolidays;
var
  i, d, m, y: Byte;
  gf: Word;
begin
  HoliDate[ 0, 00] :=  0421;  // definition of good friday [0, year] = 'MMDD'
  HoliDate[ 0, 01] :=  0413;  // - this is the base holiday for all others
  HoliDate[ 0, 02] :=  0329;
  HoliDate[ 0, 03] :=  0418;;
  HoliDate[ 0, 04] :=  0409;
  HoliDate[ 0, 05] :=  0325;
  HoliDate[ 0, 06] :=  0414;
  HoliDate[ 0, 07] :=  0406;
  HoliDate[ 0, 08] :=  0321;
  HoliDate[ 0, 09] :=  0410;
  HoliDate[ 0, 10] :=  0402;
  HoliDate[ 0, 11] :=  0422;
  HoliDate[ 0, 12] :=  0406;
  HoliDate[ 0, 13] :=  0329;
  HoliDate[ 0, 14] :=  0418;
  HoliDate[ 0, 15] :=  0403;
  HoliDate[ 0, 16] :=  0325;
  HoliDate[ 0, 17] :=  0414;
  HoliDate[ 0, 18] :=  0330;
  HoliDate[ 0, 19] :=  0419;
  HoliDate[ 0, 20] :=  0410;
  HoliDate[ 0, 21] :=  0402;
  HoliDate[ 0, 22] :=  0415;
  HoliDate[ 0, 23] :=  0407;
  HoliDate[ 0, 24] :=  0329;
  HoliDate[ 0, 25] :=  0418;

  for y := 0 to MAXYEARS - 1 do begin
    gf := HoliDate[0, y];  // date of good friday in the format 'MMDD'
    d := gf mod 100;       // get day of good friday
    m := gf div 100;       // get month of good friday

    for i := 1 to 52 do begin
      if d = MonthDays[m - 1] then begin
        m := m + 1;
        d := 1;
      end else begin
        d := d + 1;
      end;

      case i of
        2:  HoliDate[1, y] := m * 100 + d;  // date of easter sunday
        3:  HoliDate[2, y] := m * 100 + d;  // date of easter monday
        41: HoliDate[3, y] := m * 100 + d;  // date of ascension day
        51: HoliDate[4, y] := m * 100 + d;  // date of whitsuntide
        52: HoliDate[5, y] := m * 100 + d;  // date of whitmonday
      end;
    end;

    HoliDate[6, y] := 0101;                  // date of new years day
    HoliDate[7, y] := 1225;                  // date of christmas day
  end;
end;

//------------------------------------------------------------------------------
// GETTOTALDAYS - Compute the number of days elapsed since 01.01.2000,
//   the daynumber, weeknumber and weekday of a given date
//------------------------------------------------------------------ 17.02.07 --
procedure GetTotalDays(var Td, Ad, Aw, Wd: Long; Ye, Mo, Da: Long);
var
  j, m, y: Byte;
  d: Long;
begin
  y := Ye div 4;
  j := Ye mod 4;                   // 0 = leap year
  m := Mo - 1;
  Td := Da - 1;

  while (m > 0) do begin
    Td := Td + MonthDays[m - 1];   // total days from 01.01. of given year to now
    m := m - 1;
  end;

  if (j = 0) and (Mo > 2) then begin  // this year is leap => add a day from february
    Td := Td + 1;
  end;

  Ad := Td;                        // calculate number of day in the actual year (0..365);

  if j > 0 then Td := Td + 1;      // add a day for the 29.02.2000 (leap year)

  Td := Td + y * DAY_4YEAR ;
  Td := Td + j * DAY_YEAR;         // total days from 01.01.2000

  d := Td + FIRSTDAY - Ad;
  Wd := d mod DAY_WEEK;            // find day of the week for 01.01.

  if Wd = 0 then begin
    Wd := 6;                       // sunday is last (=6)
  end else begin
    Wd := Wd - 1;                  // monday is first (=0)
  end;
  
  Aw := (Ad + Wd) div DAY_WEEK;    // find the number of week
  Ad := Ad + 1;

  if Wd > 3 then begin             // ISO definition: week 01 must have >= 4 days
    if Aw = 0 then begin           //                 in the new year
      if Ye = 5 then begin
        Aw := WEEK_YEAR + 1;       // year 2004 is leap with 366 days and 53 weeks
      end else begin               // -> 1st week of 2005 is in week 53
        Aw := WEEK_YEAR;
      end;
    end
  end else begin
    Aw := Aw + 1;
    if (Aw = WEEK_YEAR + 1) and (Ye <> 4) then Aw := 1;
  end;

  d := Td + FIRSTDAY;
  Wd := d mod DAY_WEEK;            // find day of the week for the given date

  if Wd = 0 then begin
    Wd := 6;                       // sunday is last (=6)
  end else begin
    Wd := Wd - 1;                  // monday is first (=0)
  end;
end;

//------------------------------------------------------------------------------
// CREATETIMEDATE - Calculate TimeDate [s] for the given date
//   Return: TimeDate in absolute seconds since 01.01.00 at 00:00:00
//           without daylight saving correction
//------------------------------------------------------------------ 17.02.07 --
procedure CreateTimeDate(var Otime: Long; Ye, Mo, Da, Ho, Mi, Se: Long);
var
  td, ad, aw, wd: Long;
begin
  GetTotalDays(td, ad, aw, wd, Ye, Mo, Da);

  Otime := td * SEC_DAY + Ho * SEC_HOUR + Mi * SEC_MIN + Se;
end;

//------------------------------------------------------------------------------
// CONVERTTIMEDATE - Calculate Time and Date from absolute TimeDate [s]
//   Return: Day, Month, Year, Hour, Minutes, Seconds and Weekday in the
//           format 'DD.MM.YY hh:mm:ss w'
//------------------------------------------------------------------ 17.02.07 --
procedure ConvertTimeDate(var Ye, Mo, Da, Ho, Mi, Se, Wd: Long; Dtime: Long);
var
  m, j, y, tk: Byte;
  d, td, atime: Long;
begin
  atime := Dtime;
  td := atime div SEC_DAY;         // number of days since 01.01.2000
  d := td + FIRSTDAY;
  Wd := d mod DAY_WEEK;            // find day of the week for actual date

  if Wd = 0 then begin
    Wd := 6;                       // sunday is last (=6)
  end else begin
    Wd := Wd - 1;                  // monday is first (=0)
  end;
  
  for y := 0 to MAXYEARS - 1 do begin
    d := td;
    j := y mod 4;

    if j = 0 then begin  // sub a day for the 29.02. for each leap year
      tk := 1;
    end else begin
      tk := 0;
    end;
    
    td := td - DAY_YEAR - tk;
    if td < 0 then break;
  end;

  Ye := y;
  atime := atime mod SEC_DAY;

  Ho := atime div SEC_HOUR;
  atime := atime mod SEC_HOUR;

  Mi := atime div SEC_MIN;
  Se := atime mod SEC_MIN;

  for m := 1 to MONTH_YEAR do begin  // find actual month
    Da := d + 1;
    Mo := m;

    if (j = 0) and (Mo = 2) then begin  // sub a day for the 29.02. of the actual (leap) year
      tk := 1;
    end else begin
      tk := 0;
    end;

    d := d - MonthDays[m - 1] - tk;

    if d < 0 then Exit;
  end;
end;

//------------------------------------------------------------------------------
// GETSUMMERTIME - Determine if given date is in summer time period or not
//   Mode: 0=check RTC time / 1=check LCD time
//   Return: Time difference [s] (0=Normal time / >0=Summer time)
//------------------------------------------------------------------ 17.02.07 --
procedure GetSummerTime(var Tdiff: Long; Ye, Mo, Da, Ho: Long; Mode: Byte);
var
  dbeg, dend: Byte;
  adate, edate, sdate: Word;
begin
  adate := 100 * Mo + Da;  // actual date in the format 'MMDD'

  case SutiFlag of
    EUR: begin  // EU summer time
      sdate := DsavBeg[Ye];  // last sunday in march
      dbeg := 2;             // starts at 02:00
      edate := DsavEnd[Ye];  // last sunday in october
      dend := 2 + Mode;      // ends at 03:00 (=> 02:00 in RTC)
    end;

    USA: begin  // US summer time
      sdate := DsavBeg[Ye] + NEXT_SUNDAY; // first sunday in april
      dbeg := 2;             // starts at 02:00
      edate := DsavEnd[Ye];  // last sunday in october
      dend := 1 + Mode;      // ends at 02:00 (=> 01:00 in RTC)
    end;

  else begin    // no summer time switching
      Tdiff := cCLEAR;
      Exit;
    end;
  end;

  if (adate > sdate) and (adate < edate) then begin
    Tdiff := SEC_HOUR;  // it's summer time -> add an hour
    Exit;
  end;

  if (adate = sdate) and (Ho >= dbeg) then begin
    Tdiff := SEC_HOUR;  // it's summer time -> add an hour
    Exit;
  end;

  if (adate = edate) and (Ho < dend) then begin
    Tdiff := SEC_HOUR;  // it's summer time -> add an hour
    Exit;
  end;

  Tdiff := cCLEAR;  // not in summer time -> no time correction
end;

//------------------------------------------------------------------------------
// GETCLOCK - Get TimeDate from RTC [s] and (DELPHI not) make DST corrections
//   Return: Day, Month, Year, Hour, Minutes, Seconds, and Weekday in the
//           format 'DD.MM.YY hh:mm:ss w' and TimeDate in absolute seconds
//           since 01.01.00 at 00:00:00 with daylight saving correction
//------------------------------------------------------------------ 17.02.07 --
procedure GetClock(var Otime, Ye, Mo, Da, Ho, Mi, Se, Wd: Long);
var
  atime, tdiff: Long;
begin
  Otime := cCLEAR;
  Ye := cCLEAR;
  Mo := cCLEAR;
  Da := cCLEAR;
  Ho := cCLEAR;
  Mi := cCLEAR;
  Se := cCLEAR;
  Wd := cCLEAR;

  if (RtcInit <> cINIT) and (RtcInit <> cERROR) then begin
    LogError('GetClock', 'Real time clock not initialized', sEMPTY, $96);
    RtcInit := cERROR;
    Exit;
  end;

  GetRtcTime(atime);  // get absolute time [s] from RTC

  ConvertTimeDate(Ye, Mo, Da, Ho, Mi, Se, Wd, atime);

  //09.05.07 nk opt - DELPHI do not make summer time correction
  tdiff := 0; //GetSummerTime(tdiff, Ye, Mo, Da, Ho, 0);

  Otime := atime + tdiff;

  if tdiff > 0 then begin
    atime := atime + tdiff;
    ConvertTimeDate(Ye, Mo, Da, Ho, Mi, Se, Wd, atime);
  end;
end;

//------------------------------------------------------------------------------
// SETCLOCK - Make (DELPHI not) DST corrections and set RTC to absolute time [s]
//------------------------------------------------------------------ 17.02.07 --
procedure SetClock(Ye, Mo, Da, Ho, Mi, Se: Long);
var
  atime, tdiff: Long;
begin
  //13.05.07 nk opt - DELPHI do not make summer time correction
  tdiff := 0; //GetSummerTime(tdiff, Ye, Mo, Da, Ho, 1);
  CreateTimeDate(atime, Ye, Mo, Da, Ho, Mi, Se);

  atime := atime - tdiff;  // set time w/o summer time correction [s]

  SetRtcTime(atime);
end;

//------------------------------------------------------------------------------
// CHECKALARM - Return remaining seconds till alarm time and set alarm flag
//------------------------------------------------------------------ 17.02.07 --
procedure CheckAlarm(var Aflag: Byte; var Dtime: Long; var Alarm: string);
var
  atime, ctime, etime, ho, mi, se, nop: Long;
  tf: string;
begin
  Aflag := cOFF;
  Alarm := sEMPTY;
  Dtime := SEC_DAY;

  if (AlarmHour = cOFF) and (AlarmMin = cOFF) then begin
    Exit;  // alarn not set - return
  end;

  GetClock(nop, nop, nop, nop, ho, mi, se, nop);  // get actual time [hh:mm:ss]

  ctime := ho * SEC_HOUR + mi * SEC_MIN;      // convert time to seconds
  atime := AlarmHour * SEC_HOUR + AlarmMin * SEC_MIN + SEC_DAY;
  Dtime := (atime - ctime - se) mod SEC_DAY;  // remain alarm time [s]
  etime := atime + ALARMDELAY * SEC_MIN;      // max alarm life time = ALARMDELAY [min]

  if (atime - ctime) mod SEC_DAY = 0 then begin
    Aflag := cON;    // current time = alarm time
  end;

  if (etime - ctime) mod SEC_DAY = 0 then begin
    Aflag := cCLOSE; // alarm life time exceeded
  end;

  if TimeFlag = USA then begin  // US time format
    GetUsTime(ho, tf);
  end else begin                // EU time format
    tf := sEMPTY;
  end;

  Alarm := Format(TIMESHORTFORM, [ho, mi]) + tf;  // actual time as text 'hh:mmA/P'
end;

//------------------------------------------------------------------------------
// GETUSTIME - Make time corrections for american 12-hour time format
//   Return: Corrected hour and time format label (AM/PM)
//------------------------------------------------------------------ 17.02.07 --
procedure GetUsTime(var Ho: Long; var tf: string);
begin
  if Ho >= MIDDAY then begin
    tf := PM;
  end else begin
    tf := AM;
  end;

  if Ho > MIDDAY then Ho := Ho - MIDDAY;
end;

//------------------------------------------------------------------------------
// GETHOLIDAY - Check if given date is a holiday or not
//   Return: Number of holiday or MAXHOLI if none
//------------------------------------------------------------------ 17.02.07 --
procedure GetHoliday(Ye, Mo, Da: Long; var Hd: Byte);
var
  h, adate: Word;
begin
  adate := 100 * Mo + Da;  // date in the format 'MMDD'

  for h := 0 to MAXHOLI - 3 do begin  // look if day is a holiday
    if adate = HoliDate[h, Ye] then begin
      Hd := h;  // it's a holyday, so
      Exit;     // return holiday number
    end;
  end;

  Hd := MAXHOLI;  // it's not a holiday
end;

//------------------------------------------------------------------------------
// GETTIMESTAMP - Get timestamp from tick counter [ms] and format as string
//   Return: Day, Month, Year, Hour, Minutes, Seconds and Milliseconds in the
//           format 'DD.MM.YY hh:mm:ss.ttt'
//------------------------------------------------------------------ 17.02.07 --
procedure GetTimeStamp(var TimeStamp: string);
var
  ye, mo, da, ho, mi, se, ms, nop: Long;
begin
  GetClock(nop, ye, mo, da, ho, mi, se, nop);

  ms := Ticks;            // get timestamp [ms] from tick counter
  ms := ms mod MSEC_SEC;  // get milliseconds in actual second

  TimeStamp := Format(DATESHORTFORM, [da, mo, ye]) + sSPACE +
               Format(TIMEPRECFORM, [ho, mi, se, ms]);
end;

//------------------------------------------------------------------------------
// FORMATTIME - Format time variable from seconds to hours and minutes
//   Input:  tdiv - time predivider (1..n), 0=decimal time format (1h=100min)
//   Return: Time in minutes in the format 'hhmm' (w/o any range limitations!)
//------------------------------------------------------------------ 17.02.07 --
procedure FormatTime(Itime, Tdiv: Long; var Otime: Long);
var
  ti, ho, mi, se: Long;
begin
  if Tdiv = 0 then begin  // decimal time format 99:99
    ti := Itime;              // 1h = 100min
    ho := ti div DEC_HOUR;    // get hours
    se := ti mod DEC_HOUR;    // get rest in seconds
    mi := se div SEC_MIN;     // get minutes
  end else begin          // normal time format 99:59
    ti := Itime div Tdiv;
    ho := ti div SEC_HOUR;    // get hours
    se := ti mod SEC_HOUR;    // get rest in seconds
    mi := se div SEC_MIN;     // get minutes
  end;

  Otime := 100 * ho + mi;     // new format 'hhmm' (no leading zeros!)
end;

//------------------------------------------------------------------------------
// FORMATTIMEDATE - Format time date from seconds to string in hours and minutes
//   Input:  TimeDate in absolute seconds since 01.01.2000 at 00:00:00
//   Return: Time string in the format 'hh:mm'
//           Date string in the EU, US or ISO time format (with leading zeros)
//           Month name long (january..december)
//           Day name short (Mo..Su) and long (Monday..Sunday)
//           Time format 'A/P' for US or empty string for ISO and EU
//------------------------------------------------------------------ 17.02.07 --
procedure FormatTimeDate(Itime: Long; var Stime, Sdate, Lmon, Sday, Lday, Tf: string);
var
  ye, mo, da, ho, mi, se, wd: Long;
begin
  //get time and date from absolute seconds
  ConvertTimeDate(ye, mo, da, ho, mi, se, wd, Itime);

  Sday := Mask[wd + DAYSHORT]; // short day name (mo..su)
  Lday := Mask[wd + DAYLONG];  // long day name (monday..sunday)
  Lmon := Mask[mo + MONLONG];  // long month name (january..december)

  case TimeFlag of
    EUR: begin  // EU time format
      Tf := sEMPTY;
      Sdate := Format(DATESHORT_EU, [da, mo, ye]);  // date format 'DD.MM.YY'
    end;

    USA: begin  // US time format
      GetUsTime(ho, Tf);
      Sdate := Format(DATESHORT_US, [mo, da, ye]);  // date format 'MM/DD/YY'
    end;

  else begin    // ISO time format
      Tf := sEMPTY;
      Sdate := Format(DATESHORT_ISO, [ye, mo, da]); // date format 'YY-MM-DD'
    end;
  end;

  Stime := Format(TIMESHORTFORM, [ho, mi]); // short time format 'hh:mm'
end;

//------------------------------------------------------------------------------
// GETMOONPHASE - Calculate the phase of the moon for a given date
//   Input the number of days elapsed since 01.01.2000 in the format 'DDDD'
//   This routine use a reference moon phase 0 (new) at 07.11.1999
//   Return: 0-11   0 - new moon                4/4 dark  \
//                  2 - waxing crescent         3/4 dark    increasing
//                  3 - in its first quarter    2/4 dark    to full
//                  4 - waxing gibbous          1/4 dark  /
//                  6 - full moon               4/4 light \
//                  8 - waning gibbous          3/4 light   decreasing
//                  9 - in its last quarter     2/4 light   from full
//                 11 - waning crescent         1/4 light /
//------------------------------------------------------------------ 17.02.07 --
procedure GetMoonPhase(var Mphase: Byte; DayNum: Long);
var
  ph: Long;
begin
  ph := DayNum + 54;     // reference at 01.01.2000 - 54 days = 07.11.1999
  ph := ph * 128;        // 315 / 128 * 12 = 29.53 = moon cycle
  ph := ph div 315;
  ph := ph mod 12;       // 12 phases for a complete moon cycle
  Mphase := ph;
end;


end.
