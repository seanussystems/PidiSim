// Pidi Global Constants and Definitions for Outlook (Delphi only)
// Date 26.05.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

unit UPidi;

interface

uses
  Windows, Classes, Forms, TypInfo, Variants, Graphics, Global, Data;

const
  MINTIMERANGE    = 5;      // 20.10.07 nk add min time range = 5min
  DEFTIMERANGE    = 20;     // time range = 20min
  MINDEPTHRANGE   = 5;      // min depth range = 5m
  DEFDEPTHRANGE   = 40;     // depth range = 40m
  DEFDISTRANGE    = 50;     // distance range = 50m
  MAXDISTRANGE    = 2000;   // max distance range = 2000m/yd
  AUTOINC         = $0FFFF; // automatic array increment

  CHARTLOGPOINT   = 2000;   // max number of time points in profile chart
  PENDEPTH        = 1;
  PENCEIL         = 2;
  PENPLAN         = 2;      // 26.07.17 nk add
  PENLIMIT        = 3;
  HOMEPOS         = 0.0;
  TIMERESCALE     = 0.1;    // re-scale time axes if < 10%
  DEPTHRESCALE    = 20;     // re-scale depth axes if < 20m

  FILLPRESSMIN    = 100;    // min tank fill pressure = 100bar
  FILLPRESSMAX    = 300;    // max tank fill pressure = 300bar
  SURFRESPMIN     = 10;     // min surface RMV (BTPS) = 10l/min
  SURFRESPMAX     = 90;     // max surface RMV (BTPS) = 90l/min
  WATERTEMPMIN    = 400;    // min water temperature [cdeg] = 4°C
  WATERTEMPMAX    = 3600;   // max water temperature [cdeg] = 36°C
  WATERGRADSEA    = 2500;   // temp gradient water at sea level [mdeg] (-2.5°C/m)
  WATERGRADALT    = 3;      // temp gradient water at altitude [mdeg] (-0.3°C/100m)

  RANGERESCALE    = 10;     // re-scale range axes if < 10m
  MAGNITUDE       = 0.72;   // default magnitude = 72%
  QUARTDEG        = 90.0;   // quarter angle = 90deg
  FULLDEG         = 360;    // full circle angle = 360°
  MAINMARGIN      = 24;     // 24 pixels
  SCALE_METER     = 1;      //20.10.07 nk add ff
  SCALE_FEET      = 3;

  DAQALTSTEP      = 100;    // 100m
  DAQTICKSTEP     = 450;    // 45°

  DEF_ALTITUDE    = 0;      // 0m (sea level)
  DEF_AIRTEMP     = 2500;   // 25°C
  DEF_WATERTEMP   = 2200;   // 22°C
  DEF_SURFRESP    = 15;     // 15l/min
  DEF_FILLPRESS   = 200;    // 200bar
  DEF_SCANMULT    = 1;
  DEF_SWIMSPEED   = 0;
  DEF_SERPORT     = 1;      // COM1

  DEPTHUNIT_EU    = 'm';
  DEPTHUNIT_US    = 'ft';
  DISTUNIT_EU     = 'm';
  DISTUNIT_US     = 'yd';
  TEMPUNIT_EU     = '°C';
  TEMPUNIT_US     = '°F';
  TANKUNIT_EU     = 'bar';
  TANKUNIT_US     = 'psi';
  BREATHUNIT_EU   = 'l/min';
  BREATHUNIT_US   = 'CuIn/min';
  TIMEUNIT_ISO    = 'min';
  GRADUNIT_ISO    = '°';

  DEPTHTITLE      = 'Depth';
  CEILTITLE       = 'Ceiling';
  REG_SETTINGS    = 'Settings';

  FORMLOPREC      = '%3.0f %s';  // 123 °
  FORMHIPREC      = '%3.1f %s';  // 123.4 m
  FORMRANGE       = ' Range: %d %s / %d %s';

  COLORWATER      = $00FCEFD6;
  COLORMETER      = $00EBB99D;
  COLORTRACK      = clNavy;
  COLORDEPT       = clNavy;
  COLORMAXDEPTH   = clMaroon;
  COLORCEILING    = clRed;
  COLORGRID       = clGray;

var
  SaltWater: Boolean;
  SwimSpeed: Word;
  ScanMulti: Long;
  ScanDelay: Long;
  TempGrad: Long;
  SurfResp: Long;  //02.06.07 nk add RMV at surface
  ScanPress: Real;
  MainRect: TRect;

  ArrDiveTime: array of Word;
  ArrDiveDepth: array of Word;
  ArrDecoCeil: array of Word;
  ArrHomeDist: array of Word; //13.05.07 nk add ff
  ArrBearing: array of Word;
  PhaseName: array[0..PHASEPOSTDIVE] of string; // names of dive phases

implementation

initialization
  SaltWater := False;
  SwimSpeed := 0;
  ScanMulti := 1;
  ScanDelay := 1;
  TempGrad  := 1;
  SurfResp  := DEF_SURFRESP;
  ScanPress := 1.0;

  PhaseName[PHASENONE]     := sEMPTY;
  PhaseName[PHASEINITIAL]  := 'Initialization';
  PhaseName[PHASEINTERVAL] := 'Surface Interval';
  PhaseName[PHASEADAPTION] := 'Adaption';
  PhaseName[PHASEREADY]    := 'Ready...';
  PhaseName[PHASEPREDIVE]  := 'Pre-Dive';
  PhaseName[PHASEDIVE]     := 'Dive';
  PhaseName[PHASEPOSTDIVE] := 'Post-Dive';

  SetLength(ArrDiveTime, cCLEAR);
  SetLength(ArrDiveDepth, cCLEAR);
  SetLength(ArrDecoCeil, cCLEAR);
  SetLength(ArrHomeDist, cCLEAR); //13.05.07 nk add ff
  SetLength(ArrBearing, cCLEAR);

finalization
  SetLength(ArrDiveTime, cCLEAR);
  SetLength(ArrDiveDepth, cCLEAR);
  SetLength(ArrDecoCeil, cCLEAR);
  SetLength(ArrHomeDist, cCLEAR); //13.05.07 nk add ff
  SetLength(ArrBearing, cCLEAR);

end.
