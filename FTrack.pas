// Dive Track Chart
// Date 12.06.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

unit FTrack;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Math, Dialogs, ExtCtrls, StdCtrls, ComCtrls, {SDL_Sdlbase,
  SDL_Polchart,} USystem, UGraphic, URegistry, SYS, Global, Data, Texts,
  Clock, FLog, UPidi, PolarChart;

type
  TTrack = class(TForm)
    TrackPanel: TPanel;
    TrackLoop: TTimer;
    TrackStatus: TStatusBar;
    TrackChart: TPolarChart; // 12.06.22 nk upd to Dive Charts Vers 2.0
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormMoving(var Msg: TwmMoving); message WM_MOVING;
    procedure TrackLoopTimer(Sender: TObject);
    procedure TrackChartMouseMoveInChart(Sender: TObject; InChart: Boolean; Shift: TShiftState; rad, phi: Double);
  private
    RangeMax: Long;
    DistMax: Long;
    DistMult: Double;
    DistUnit: string;
    GradUnit: string;
  public
    procedure InitDiveTrack(Pos: Long);  //13.05.07 nk add Pos
    procedure DrawDiveTrack;             //13.05.07 nk add
    procedure DrawDivePos(HomeDist, Bearing: Word; DoShow: Boolean);
    procedure AddDivePos(Pos, HomerDist, HomerBear: Word); //22.05.07 nk add
    procedure MoveDiver(SwimSpeed, Heading: Word);
  end;

var
  Track: TTrack;

implementation

uses FMain;

{$R *.dfm}

procedure TTrack.FormCreate(Sender: TObject);
begin
  HideMaxButton(self);   // hide maximize button
  HideCloseButton(self); // hide close button

  with Track do begin
    Width  := 250;
    Height := 283;
    Left   := 300;
    Top    := MAINMARGIN;
    GetFormParameter(self);
    WindowState := wsMinimized;
    Show;
  end;

  with TrackStatus do begin
    Panels[0].Text := sEMPTY;
    Panels[1].Text := sEMPTY;
    Panels[2].Text := sEMPTY;
  end;

  with TrackPanel do begin
    Align := alClient;
    AutoSize := False;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Ctl3D := False;
    Caption := sEMPTY;
    DoubleBuffered := True;
    UseDockManager := False;
  end;

  with TrackChart do begin
    Align := alClient;
    DoubleBuffered := True;
    CenterChart;
    ClearGraf;
    RangeLow := HOMEPOS;
    RangeHigh := DEFDISTRANGE;
    LineWidth := 1;
    MagFactor := MAGNITUDE;
    AngleOffset := -QUARTDEG;
    DecPlaceRad := 0;
    ChartColor := COLORWATER;
    DataColor := COLORTRACK;
    GridColor := COLORGRID;
    TransparentItems := True;
    UseDegrees := True;
    RotationDir := rdClockwise;
    LabelModeAngular := almDegrees;
    LabelModeRadial := rlmNone;
    GridStyleAngular := gsAngDots;
    GridStyleRadial := gsRadBothMixed;
    MoveTo(HOMEPOS, HOMEPOS);
    CrossHair1.PosRad := HOMEPOS;
    CrossHair1.PosPhi := HOMEPOS;
    CrossHair1.Mode := chOff;     //diver position
    CrossHair2.PosRad := HOMEPOS; //02.06.07 nk add ff
    CrossHair2.PosPhi := HOMEPOS;
    CrossHair2.Mode := chOff;     //track pointer
    Refresh;
  end;
end;

procedure TTrack.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TrackLoop.Enabled := False;
  SetFormParameter(self);
  Action := caFree;
end;

procedure TTrack.FormResize(Sender: TObject);
begin
  TrackChart.CenterChart;
end;

procedure TTrack.FormMoving(var Msg: TwmMoving);
begin
  LimitFormMove(MainRect, Msg);
end;

procedure TTrack.TrackLoopTimer(Sender: TObject);
begin // 26.07.17 nk rem - obsolete
  if WindowFromPoint(Mouse.CursorPos) <> TrackPanel.Handle then begin
    Screen.Cursor := crDefault;
    if DivePhase > PHASEPREDIVE then Exit;

    with TrackStatus do begin
      Panels[0].Text := Format(FORMLOPREC, [HOMEPOS, GradUnit]);
      Panels[1].Text := Format(FORMHIPREC, [HOMEPOS, DistUnit]);
      Panels[2].Text := Format(FORMRANGE,  [DistMax, DistUnit, FULLDEG, GradUnit]);
    end;
  end;
end;

procedure TTrack.InitDiveTrack(Pos: Long);
var
  p: Word;
begin
  GradUnit := GRADUNIT_ISO;
  RangeMax := DEFDISTRANGE; // [m]

  if Pos >= 0 then begin
    SetLength(ArrHomeDist, Pos + 1);
    SetLength(ArrBearing,  Pos + 1);

    for p := 0 to Pos do begin
      ArrHomeDist[p] := cCLEAR;
      ArrBearing[p]  := cCLEAR;
    end;
  end;

  if UnitFlag = cOFF then begin
    DistUnit := DISTUNIT_EU;
    DistMult := 1.0;
  end else begin
    DistUnit := DISTUNIT_US;
    DistMult := YARD / 1000.0;
  end;

  DistMax := Round(DistMult * RangeMax); // [m/yd]

  with TrackChart do begin
    ClearGraf;
    RangeHigh         := DistMax;
    MoveTo(HOMEPOS, HOMEPOS);
    CrossHair2.PosRad := HOMEPOS;
    CrossHair2.PosPhi := HOMEPOS;

    if Pos = cNEG then
      DrawDiveTrack  //02.06.07 nk opt - update chart
    else
      MarkAt(HOMEPOS, HOMEPOS, 24); // 26.07.17 nk old=15

    CrossHair1.PosRad := CrossHair2.PosRad;  // move diver position
    CrossHair1.PosPhi := CrossHair2.PosPhi;  // to the end of his track

    with TrackStatus do begin
      Panels[0].Text := Format(FORMLOPREC, [CrossHair1.PosPhi, GradUnit]);
      Panels[1].Text := Format(FORMHIPREC, [CrossHair1.PosRad, DistUnit]);
      Panels[2].Text := Format(FORMRANGE,  [DistMax, DistUnit, FULLDEG, GradUnit]);
    end;
  end;

  TrackLoop.Enabled := False; // 26.07.17 nk old=True
  Application.ProcessMessages;
end;

procedure TTrack.DrawDiveTrack;
var
  p, points: Long;
begin
  DisableTsw; //01.06.07 nk add

  points := High(ArrHomeDist);

  for p := 0 to points do begin
    DrawDivePos(ArrHomeDist[p], ArrBearing[p], False);
  end;

  TrackChart.ShowGraf;
  EnableTsw;
end;

procedure TTrack.DrawDivePos(HomeDist, Bearing: Word; DoShow: Boolean);
var
  dDist, dBear, dGrad: Double;
begin;
  dDist := DistMult * HomeDist / DEZI;         // home distance [dm -> m/yd]
  dBear := (HALFCIRC + Bearing) mod FULLCIRC;  // home bearing [ddeg] view
  dBear := dBear   / DDEG;                     // from home to diver [deg]
  dGrad := Bearing / DDEG;

  with TrackChart do begin // re-scale distance axis on overflow
    if dDist > RangeHigh - RANGERESCALE then begin
      RangeMax  := Round(dDist) + RANGERESCALE;
      DistMax   := Round(DistMult * RangeMax); // [m/yd]
      RangeHigh := Min(DistMax, MAXDISTRANGE); //03.06.07 nk opt
    end;

    DrawTo(dDist, dBear);
    CrossHair2.PosRad := dDist; // 02.06.07 nk add
    CrossHair2.PosPhi := dBear;

    if DoShow then ShowGraf;    // update graph
  end;

  with TrackStatus do begin
    if DoShow then begin
      Panels[0].Text := Format(FORMLOPREC, [dGrad, GradUnit]);
      Panels[1].Text := Format(FORMHIPREC, [dDist, DistUnit]);
    end;
    Panels[2].Text := Format(FORMRANGE, [DistMax, DistUnit, FULLDEG, GradUnit]);
  end;

  Application.ProcessMessages;
end;

procedure TTrack.AddDivePos(Pos, HomerDist, HomerBear: Word);
var
  p: Long;
begin
  if Pos = AUTOINC then begin
    p := High(ArrHomeDist) + 1; // auto array increment
  end else begin
    p := Pos;
  end;

  SetLength(ArrHomeDist, p + 1);
  SetLength(ArrBearing,  p + 1);

  ArrHomeDist[p] := HomerDist; // home distance [dm]
  ArrBearing[p]  := HomerBear; // home bearing [ddeg]
end;

procedure TTrack.MoveDiver(SwimSpeed, Heading: Word);
var
  q: Long;
  dRad, dPhi: Double;
  x, x1, x2, y, y1, y2: Double;
begin;
  if SwimSpeed <= 0 then Exit;

  x := 0;
  y := 0;

  dRad := SwimSpeed / DEZI;
  dPhi := Heading   / DDEG;

  q    := Round(dPhi / QUARTDEG);
  dPhi := dPhi - q * QUARTDEG;
  q    := q mod 4;

  // get actual diver position
  with TrackChart.CrossHair1 do begin
    x1 := PosRad * Sin(PosPhi * RAD);
    y1 := PosRad * Cos(PosPhi * RAD);
  end;

  case q of
    0: begin
       x2 := dRad * Sin(dPhi * RAD);
       y2 := dRad * Cos(dPhi * RAD);
       x  := x1 + x2;
       y  := y1 + y2;
    end;

    1: begin
       x2 := dRad * Cos(dPhi * RAD);
       y2 := dRad * Sin(dPhi * RAD);
       x  := x1 + x2;
       y  := y1 - y2;
    end;

    2: begin
       x2 := dRad * Sin(dPhi * RAD);
       y2 := dRad * Cos(dPhi * RAD);
       x  := x1 - x2;
       y  := y1 - y2;
    end;

    3: begin
       x2 := dRad * Cos(dPhi * RAD);
       y2 := dRad * Sin(dPhi * RAD);
       x  := x1 - x2;
       y  := y1 + y2;
    end;
  end;

  q := 0;
  if (x >= 0) and (y < 0)  then q := 1;
  if (x < 0)  and (y < 0)  then q := 2;
  if (x < 0)  and (y >= 0) then q := 3;

  if (q = 0) or (q = 2) then begin
    if y = 0 then begin
      dPhi := QUARTDEG;
    end else begin
      dPhi := ArcTan(Abs(x) / Abs(y)) * DEG;
    end;
  end else begin
    if x = 0 then begin
      dPhi := QUARTDEG;
    end else begin
      dPhi := ArcTan(Abs(y) / Abs(x)) * DEG;
    end;
  end;

  // calc new vector in polar coordinates
  dPhi := dPhi + q * QUARTDEG;
  dRad := Sqrt(Sqr(x) + Sqr(y));

  // move diver to the new position
  with TrackChart do begin
    CrossHair1.PosRad := dRad;
    CrossHair1.PosPhi := dPhi;
    MarkAt(dRad, dPhi, 1); // 26.07.17 nk add
  end
end;

procedure TTrack.TrackChartMouseMoveInChart(Sender: TObject; InChart: Boolean; Shift: TShiftState; rad, phi: Double);
begin
  if DivePhase > PHASEPREDIVE then Exit;

  with TrackStatus do begin
    Panels[0].Text := Format(FORMLOPREC, [phi, GradUnit]);
    Panels[1].Text := Format(FORMHIPREC, [rad, DistUnit]);
  end;
end;

end.
