// Dive Profile Chart
// Date 12.06.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

unit FProfile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, ComCtrls, gl_base, DepthChart,
  USystem, UGraphic, URegistry, SYS, Global, Data, Texts, Clock, FLog, UPidi;

type
  TProfile = class(TForm)
    ProfileLoop: TTimer;
    ProfileStatus: TStatusBar;
    ProfilePanel: TPanel;
    ProfileChart: TDepthChart; // 12.06.22 nk upd to Dive Charts Vers 2.0
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMoving(var Msg: TwmMoving); message WM_MOVING;
    procedure ProfileLoopTimer(Sender: TObject);
    procedure ProfileChartMouseMoveInChart(Sender: TObject; InChart: Boolean; Shift: TShiftState; rMousePosX, rMousePosY: Double);
  private
    TimeMax: Long;      //[min]
    DepthMax: Long;     //[m]
    ScaleMult: Long;
    DepthLimit: Double; //[cm]
    DepthMult: Double;
    DepthUnit: string;
    TimeUnit: string;
  public
    procedure InitDiveProfile(Points: Long);
    procedure DrawDiveProfile;
    procedure DrawDivePoint(DiverTime, DiverDepth, DiverCeil: Long; DoShow: Boolean);
    procedure AddDivePoint(Point, DiverTime, DiverDepth, DiverCeil: Word); //22.05.07 nk add
  end;

var
  Profile: TProfile;
  
implementation

uses FMain, FDaq;

{$R *.dfm}

procedure TProfile.FormCreate(Sender: TObject);
begin
  HideMaxButton(self);   // hide maximize button
  HideCloseButton(self); // hide close button

  with Profile do begin
    Width  := 435;
    Height := 283;
    Left   := MainRect.Right - MainRect.Left - Width - MAINMARGIN;
    Top    := MAINMARGIN;
    GetFormParameter(self);
    WindowState := wsMinimized;
    Show;
  end;

  with ProfileStatus do begin
    Panels[0].Text := sEMPTY;
    Panels[1].Text := sEMPTY;
    Panels[2].Text := sEMPTY;
  end;

  with ProfilePanel do begin
    Align := alClient;
    AutoSize := False;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Ctl3D := False;
    Caption := sEMPTY;
    Cursor := crCross;
    DoubleBuffered := True;
    UseDockManager := False;
  end;

  with ProfileChart do begin
    ClearGraf;
    LRim := 40;
    RRim := 20;
    TRim := 20;
    BRim := 40;
    Align := alClient;
    AutoRedraw := True;
    Isometric := False;
    Caption := sEMPTY;
    ChartColor := COLORWATER;
    DataColor := COLORTRACK;
    GridColor := COLORGRID;
    GridDx := 0;
    GridDy := 0;
    LineWidth := 1;
    MouseCursorFixed := False;    //20.10.07 nk add
    MouseAction := maNone;
    PenStyle := psSolid;

    //20.10.07 nk upd ff to SDL 9.0
    with Scale1X do begin         //old vers 7.1 properties
      Caption := sEMPTY;          //IdAbscissa := sEMPTY;
      DecPlaces := 0;             //DecPlaceX := 0;
      MinTicks := MINTIMERANGE;   //MinTickX := 5;
      ShortTicks := False;        //ShortTicksX := False;
      RangeLow := HOMEPOS;        //RangeLoX := HOMEPOS;
      RangeHigh := DEFTIMERANGE;  //RangeHiX := DEFTIMERANGE;
    end;

    with Scale1Y do begin          //old vers 7.1 properties
      Caption := sEMPTY;          //IdOrdinate := sEMPTY;
      DecPlaces := 0;             //DecPlaceY := 0;
      MinTicks := MINDEPTHRANGE;  //MinTickY := 5;
      ShortTicks := False;        //ShortTicksY := False;
      RangeLow := -DEFDEPTHRANGE; //RangeLoY := -DEFDEPTHRANGE;
      RangeHigh := MINDEPTHRANGE; //RangeHiY := 5.0;
    end;

    MoveTo(HOMEPOS, HOMEPOS);
    CrossHairSetPos(PENDEPTH, HOMEPOS, HOMEPOS); //depth
    CrossHairSetPos(PENCEIL,  HOMEPOS, HOMEPOS); //ceiling
    CrossHairSetPos(PENLIMIT, HOMEPOS, HOMEPOS); //limit
    Refresh;
  end;
end;

procedure TProfile.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ProfileLoop.Enabled := False;
  SetFormParameter(self);
  Action := caFree;
end;

procedure TProfile.FormMoving(var Msg: TwmMoving);
begin
  LimitFormMove(MainRect, Msg);
end;

procedure TProfile.ProfileLoopTimer(Sender: TObject);
begin // 26.07.17 nk rem - obsolete
  if WindowFromPoint(Mouse.CursorPos) <> ProfilePanel.Handle then begin
    Screen.Cursor := crDefault;
    if DivePhase > PHASEPREDIVE then Exit;

    with ProfileStatus do begin
      Panels[0].Text := Format(FORMHIPREC, [HOMEPOS, TimeUnit]);
      Panels[1].Text := Format(FORMHIPREC, [HOMEPOS, DepthUnit]);
      Panels[2].Text := Format(FORMRANGE,  [DepthMax * ScaleMult, DepthUnit, TimeMax, TimeUnit]);
    end;
  end;
end;

procedure TProfile.InitDiveProfile(Points: Long);
var
  p: Word;
begin
  TimeUnit := TIMEUNIT_ISO;
  TimeMax  := DEFTIMERANGE;
  DepthMax := Round(1.2 * WarnDepth / CENTI); //20% more than warn depth [m]

  if Points >= 0 then begin
    SetLength(ArrDiveTime,  Points + 1);
    SetLength(ArrDiveDepth, Points + 1);
    SetLength(ArrDecoCeil,  Points + 1);

    for p := 0 to Points do begin
      ArrDiveTime[p]  := cCLEAR;
      ArrDiveDepth[p] := cCLEAR;
      ArrDecoCeil[p]  := cCLEAR;
    end;
  end;

  if UnitFlag = cOFF then begin
    DepthUnit  := DEPTHUNIT_EU;
    DepthMult  := 1.0;
    DepthLimit := 1.0 * WarnDepth;
    ScaleMult  := SCALE_METER;
  end else begin
    DepthUnit  := DEPTHUNIT_US;
    DepthMult  := FEET / 100.0;
    DepthLimit := WarnDepth * TENFEET / 1000.0;
    ScaleMult  := SCALE_FEET;
  end;

  with ProfileChart do begin //20.10.07 nk upd ff to SDL vers. 9.0
    ClearGraf;

    with Scale1X do begin
      Caption   := MakeCaption(131, TimeUnit);
      RangeLow  := HOMEPOS;
      RangeHigh := TimeMax;
    end;

    with Scale1Y do begin
      Caption   := MakeCaption(130, DepthUnit);
      RangeLow  := -DepthMax * ScaleMult;
      RangeHigh := MINDEPTHRANGE * ScaleMult;
    end;

    MoveTo(HOMEPOS, HOMEPOS);
    CrossHairSetPos(PENDEPTH, HOMEPOS, HOMEPOS); // depth
    CrossHairSetPos(PENCEIL,  HOMEPOS, HOMEPOS); // ceiling
    CrossHairSetPos(PENLIMIT, -10.0, -DepthLimit / CENTI);
    CrossHairSetup(PENLIMIT, COLORMAXDEPTH, chBoth, psDash, 1); // show WarnDepth line
  end;

  with ProfileStatus do begin
    Panels[0].Text := Format(FORMHIPREC, [HOMEPOS, TimeUnit]);
    Panels[1].Text := Format(FORMHIPREC, [HOMEPOS, DepthUnit]);
    Panels[2].Text := Format(FORMRANGE,  [DepthMax * ScaleMult, DepthUnit, TimeMax, TimeUnit]);
  end;

  if Points = cNEG then DrawDiveProfile; //13.05.07 nk opt - update chart

  ProfileLoop.Enabled := False; // 26.07.17 nk old=True
  Application.ProcessMessages;
end;

procedure TProfile.DrawDiveProfile;
var
  p, points, ltime: Long;
begin
  DisableTsw; //01.06.07 nk add
  points := High(ArrDiveTime);

  for p := 0 to points do begin
    ExpandTime(ArrDiveTime[p], ltime);
    DrawDivePoint(ltime, ArrDiveDepth[p], ArrDecoCeil[p], False);
  end;

  ProfileChart.ShowGraf;
  EnableTsw;
end;

procedure TProfile.DrawDivePoint(DiverTime, DiverDepth, DiverCeil: Long; DoShow: Boolean);
var
  dMax: Long;
  dTime, dDepth, dCeil: Double;
begin
  if DiverTime <= 0 then Exit; //ignore invalid dive point

  dTime  := DiverTime / SEC_MIN;            // dive time [s -> min]
  dDepth := DepthMult * DiverDepth / CENTI; // dive depth [cm -> m/ft]
  dCeil  := DepthMult * DiverCeil  / CENTI; // deco ceiling [cm -> m/ft]

  with ProfileChart do begin //20.10.07 nk upd ff to SDL vers. 9.0
    with Scale1X do begin    //re-scale time axis on overflow
      dMax := Round(TIMERESCALE * RangeHigh);
      if dTime > (RangeHigh - dMax) then begin
        TimeMax   := TimeMax + dMax;
        RangeHigh := TimeMax;
      end;
    end;

    with Scale1Y do begin //re-scale depth axis on overflow
      if dDepth > (-RangeLow - DEPTHRESCALE) then begin
        DepthMax := DepthMax + DEPTHRESCALE;
        RangeLow := -DepthMax * ScaleMult;
      end;
    end;
    
    //draw ceiling graph
    DataColor := COLORCEILING;
    MoveTo(CrossHairPosX[PENCEIL], CrossHairPosY[PENCEIL]);
    DrawTo(dTime, -dCeil);
    CrossHairSetPos(PENCEIL, dTime, -dCeil);

    //draw depth graph
    DataColor := COLORDEPT;
    MoveTo(CrossHairPosX[PENDEPTH], CrossHairPosY[PENDEPTH]);
    DrawTo(dTime, -dDepth);
    CrossHairSetPos(PENDEPTH, dTime, -dDepth);

    if DoShow then ShowGraf; //update graph
  end;

  with ProfileStatus do begin
    if DoShow then begin
      Panels[0].Text := Format(FORMHIPREC, [dTime,   TimeUnit]);
      Panels[1].Text := Format(FORMHIPREC, [-dDepth, DepthUnit]);
    end;
    Panels[2].Text := Format(FORMRANGE, [DepthMax * ScaleMult, DepthUnit, TimeMax, TimeUnit]);
  end;
  
  Application.ProcessMessages;
end;

procedure TProfile.AddDivePoint(Point, DiverTime, DiverDepth, DiverCeil: Word);
var
  p: Long;
begin
  if Point = AUTOINC then begin
    p := High(ArrDiveTime) + 1; // auto array increment
  end else begin
    p := Point;
  end;

  SetLength(ArrDiveTime,  p + 1);
  SetLength(ArrDiveDepth, p + 1);
  SetLength(ArrDecoCeil,  p + 1);

  ArrDiveTime[p]  := DiverTime;  // log time [s/min]
  ArrDiveDepth[p] := DiverDepth; // dive depth [cm]
  ArrDecoCeil[p]  := DiverCeil;  // deco ceiling [cm]
end;

procedure TProfile.ProfileChartMouseMoveInChart(Sender: TObject; InChart: Boolean; Shift: TShiftState; rMousePosX, rMousePosY: Double);
var
  dTime, dDepth: Double;
begin
  if DivePhase > PHASEPREDIVE then Exit;

  with ProfileStatus do begin
    if (rMousePosX < HOMEPOS) or (rMousePosX > TimeMax) or
      (rMousePosY > HOMEPOS) or (rMousePosY < (-DepthMax * ScaleMult)) then begin
      dTime  := HOMEPOS;
      dDepth := HOMEPOS;
    end else begin
      dTime  := rMousePosX;
      dDepth := rMousePosY;
    end;

    Panels[0].Text := Format(FORMHIPREC, [dTime, TimeUnit]);
    Panels[1].Text := Format(FORMHIPREC, [dDepth, DepthUnit]);
  end;
end;

end.
