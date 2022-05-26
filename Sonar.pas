// Sonar Module Functions
// Date 25.07.17
// Norbert Koechli
// Copyright ©2005-2017 seanus systems

// DELPHI simulate the Sonar Module with
// the TrackChart.CrossHair1 from Form 'Track'

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit Sonar;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, USystem, SYS, Global, Data,
  Texts, FLog, UPidi;

  procedure InitSonar;
  procedure ReadSonar(var HomeDist, Bearing, SonarSignal: Word);

const
  BEARUNIT  = ' °';         // sonar bearing unit

var
  SonarBuff: string;        // modul message buffer / old=[MAXBUFF]

implementation

uses FMain, FDaq, FTrack;

//------------------------------------------------------------------------------
// INITSONAR - Initialize Sonar Module
//------------------------------------------------------------------ 17.02.07 --
procedure InitSonar;
begin
  HomeDist := cCLEAR;
  Bearing := (HALFCIRC + Heading) mod FULLCIRC; // home is in the opposite

  if SonarFlag = cON then begin //02.06.07 nk opt
    SonarBuff := IntToStr(Bearing div DDEG) + BEARUNIT;
    LogEvent('InitSonar', 'Sonar module initialized at', SonarBuff);
  end else begin
    LogEvent('InitSonar', 'Sonar module not activated', sEMPTY);
  end;
end;

//------------------------------------------------------------------------------
// READSONAR - Get distance [dm] and bearing [ddeg] from Sonar Module
//   and indicate sonar signal strength SonarSignal from 0 (bad) to 5 (excellent)
//------------------------------------------------------------------ 17.02.07 --
procedure ReadSonar(var HomeDist, Bearing, SonarSignal: Word);
const
  RMULT = 4; // range multiplyer
var
  dist, range: Word;
begin
  with Track.TrackChart do begin
    HomeDist := Round(CrossHair1.PosRad * DEZI);   // [dm]
    Bearing  := Round(CrossHair1.PosPhi * DDEG);
    Bearing  := (HALFCIRC + Bearing) mod FULLCIRC; // [ddeg]
  end;

  // simulate sonar signal strength in the range 0m=5 to 200m=0
  dist  := HomeDist div DEZI;      // [m]
  range := RMULT * DEFDISTRANGE;  // 200m
  if dist > range then begin
    SonarSignal := 0;
  end else begin
    SonarSignal := Round((range - dist) / (RMULT * DEZI));
  end;
end;


end.
