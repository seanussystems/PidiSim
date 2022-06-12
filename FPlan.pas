// Dive Planner
// Date 12.06.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

unit FPlan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, StdCtrls, ComCtrls, CommCtrl, ExtCtrls, ImgList, System.ImageList,
  RzButton, RzCmboBx, gl_base, DepthChart, USystem, URegistry, SYS, Global,
  Data, Texts, Sensor, UPidi;

type
  TPlan = class(TForm)
    PlanPanel: TPanel;
    PlanControls: TPanel;
    PlanLoop: TTimer;
    PlanStatus: TStatusBar;
    PlanChart: TDepthChart; // 12.06.22 nk upd to Dive Charts Vers 2.0
    PlanIcons: TImageList;
    btDepth: TRzBitBtn;
    cbGasMix: TRzComboBox;
    btClear: TRzButton;
    btStart: TRzButton;
    btTime: TRzBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMoving(var Msg: TwmMoving); message WM_MOVING;
    procedure PlanLoopTimer(Sender: TObject);
    procedure PlanChartMouseMoveInChart(Sender: TObject; InChart: Boolean; Shift: TShiftState; rMousePosX, rMousePosY: Double);
    procedure PlanChartMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btClearClick(Sender: TObject);
    procedure btTimeClick(Sender: TObject);
    procedure btDepthClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure cbGasMixSelect(Sender: TObject);
    procedure cbGasMixDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
  private
    PlanCtr: Long;
    DivePoint: Long; //20.10.07 nk old=PDrawCan
    MaxTimeRange: Long;
    MaxDepthRange: Long;
    TimeMax: Long;
    DepthMax: Long;  //[m]
    ScaleMult: Long;
    PlanTicks: Long;
    ScanPress: Real;
    DepthLimit: Double;
    DepthMult: Double;
    DepthUnit: string;
    TimeUnit: string;
  public
    procedure InitDivePlan;
    procedure ReadDivePlan(var AmbPress, AmbTemp, ScanTime: Long);
  end;

const //nk// move to / get from Data.pas
  GASMIXES = 9;

  GasMix: array [0..GASMIXES] of string =
    ('Air',
     'Oxygen',
     'Nitrox 24',
     'Nitrox 26',
     'Nitrox 30',
     'Nitrox 36',
     'Nitrox 40',
     'Nitrox 42',
     'Trimix 12',
     'Trimix 15');

  GasColor: array [0..GASMIXES] of TColor =
    (clBlue,    // air
     clRed,     // oxygen
     clGreen,   // mix gas #1
     clYellow,  // mix gas #2
     clFuchsia, // mix gas #3
     clLime,    // mix gas #4
     clPurple,  // mix gas #5
     clNavy,    // mix gas #6
     clTeal,    // mix gas #7
     clOlive);  // mix gas #8

var
  Plan: TPlan;

implementation

uses FMain, FDaq;

{$R *.dfm}

procedure TPlan.FormCreate(Sender: TObject);
var
  i: Long;
begin
  HideMaxButton(self);    // hide maximize button
  HideCloseButton(self);  // hide close button

  with Plan do begin
    Width  := 435;
    Height := 283;
    Left   := 320;
    Top    := 2 * MAINMARGIN;
    GetFormParameter(self);
    Show;
  end;

  with PlanStatus do begin
    Panels[0].Text := sEMPTY;
    Panels[1].Text := sEMPTY;
    Panels[2].Text := sEMPTY;
  end;

  with PlanPanel do begin
    Align := alClient;
    AutoSize := False;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Ctl3D := False;
    Cursor := crCross;
    Caption := sEMPTY;
    DoubleBuffered := True;
    UseDockManager := False;
  end;

  with PlanChart do begin
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
    MouseCursorFixed := False;      //20.10.07 nk add
    MouseAction := maNone;
    PenStyle := psSolid;

    //20.10.07 nk upd ff to SDL 9.0
    with Scale1X do begin           //old vers 7.1 properties
      Caption    := sEMPTY;         //IdAbscissa := sEMPTY;
      DecPlaces  := 0;              //DecPlaceX := 0;
      MinTicks   := MINTIMERANGE;   //MinTickX := 5;
      ShortTicks := False;          //ShortTicksX := False;
      RangeLow   := HOMEPOS;        //RangeLoX := HOMEPOS;
      RangeHigh  := DEFTIMERANGE;   //RangeHiX := DEFTIMERANGE;
    end;

    with Scale1Y do begin           //old vers 7.1 properties
      Caption    := sEMPTY;         //IdOrdinate := sEMPTY;
      DecPlaces  := 0;              //DecPlaceY := 0;
      MinTicks   := MINDEPTHRANGE;  //MinTickY := 5;
      ShortTicks := False;          //ShortTicksY := False;
      RangeLow   := -DEFDEPTHRANGE; //RangeLoY := -DEFDEPTHRANGE;
      RangeHigh  := MINDEPTHRANGE;  //RangeHiY := 5.0;
    end;

    MoveTo(HOMEPOS, HOMEPOS);
    CrossHairSetPos(PENDEPTH, HOMEPOS, HOMEPOS); // 26.07.17 nk opt ff
    CrossHairSetPos(PENPLAN,  HOMEPOS, HOMEPOS);
    Refresh;
  end;

  with btDepth do begin
    //Left      := PlanChart.LRim - Width;
    //Top       := PlanChart.Height - PlanChart.BRim div 2 + 4;
    //Anchors   := [akLeft,akBottom];
    Alignment := taCenter;
    HotTrack  := True;
    ShowHint  := True;
  end;

  with btTime do begin
    //Left      := PlanChart.Width - PlanChart.RRim - Width;
    //Top       := btDepth.Top;
    //Anchors   := [akRight, akBottom];
    Alignment := taCenter;
    HotTrack  := True;
    ShowHint  := True;
  end;

  with cbGasMix do begin
    //Left    := btDepth.Left + 32;
    //Top     := btDepth.Top;
    //Anchors := [akLeft,akBottom];
    Clear;
    for i := Low(GasMix) to High(GasMix) do
      Items.Add(GasMix[i]);
    AllowEdit := False;
    AutoCloseUp := True;
    AutoComplete := False;
    AutoDropDown := False;
    BeepOnInvalidKey := False;
    Ctl3D := False;
    FrameVisible := True;
    ReadOnly := False;
    Style := csOwnerDrawVariable;
    ItemIndex := cCLEAR;
  end;

  with btStart do begin
    //Left      := btTime.Left - 72;
    //Top       := btDepth.Top;
    //Anchors   := [akRight, akBottom];
    Alignment := taCenter;
    HotTrack  := True;
    ShowHint  := True;
  end;

  with btClear do begin
    //Left      := btStart.Left - 72;
    //Top       := btDepth.Top;
    //Anchors   := [akRight, akBottom];
    Alignment := taCenter;
    HotTrack  := True;
    ShowHint  := True;
  end;
end;

procedure TPlan.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PlanLoop.Enabled := False;
  SetFormParameter(self);
  Action := caFree;
end;

procedure TPlan.FormMoving(var Msg: TwmMoving);
begin
  LimitFormMove(MainRect, Msg);
end;

procedure TPlan.PlanLoopTimer(Sender: TObject);
begin // 26.07.17 nk rem - obsolete
  if WindowFromPoint(Mouse.CursorPos) <> PlanPanel.Handle then begin
    Screen.Cursor := crDefault;
    if DivePhase > PHASEPREDIVE then Exit;

    with PlanStatus do begin
      Panels[0].Text := Format(FORMHIPREC, [HOMEPOS, TimeUnit]);
      Panels[1].Text := Format(FORMHIPREC, [HOMEPOS, DepthUnit]);
      Panels[2].Text := Format(FORMRANGE,  [DepthMax * ScaleMult, DepthUnit, TimeMax, TimeUnit]);
    end;
  end;
end;

procedure TPlan.InitDivePlan;
begin
  ScanPress := cCLEAR;
  DivePoint := cCLEAR;
  PlanCtr   := cCLEAR;
  PlanTicks := cNEG;

  MaxTimeRange  := (TIMERANGE + 1) div SEC_MIN;    //[min]
  MaxDepthRange := (DEPTHDISP + CENTI) div CENTI;  //[m]
  DepthMax      := Round(1.2 * WarnDepth / CENTI); //20% more than warn depth [m]
  TimeMax       := DEFTIMERANGE;                   //[min]
  TimeUnit      := TIMEUNIT_ISO;

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

  with PlanChart do begin //20.10.07 nk upd ff to SDL vers. 9.0
    ClearGraf;

    with Scale1X do begin
      Caption   := MakeCaption(131, TimeUnit);
      RangeLow  := HOMEPOS;                    //0min
      RangeHigh := TimeMax;                    //20min
    end;

    with Scale1Y do begin
      Caption   := MakeCaption(130, DepthUnit);
      RangeLow  := -DepthMax * ScaleMult;      //-47m
      RangeHigh := MINDEPTHRANGE * ScaleMult;  //+5m
    end;
    
    MoveTo(HOMEPOS, HOMEPOS);
    CrossHairSetPos(PENDEPTH, HOMEPOS, HOMEPOS);                //26.07.17 nk opt ff
    CrossHairSetup(PENDEPTH, COLORMAXDEPTH, chBoth, psDash, 1); //26.07.17 nk add
    CrossHairSetPos(PENPLAN, -10.0, -DepthLimit / CENTI);
    CrossHairSetup(PENPLAN, COLORMAXDEPTH, chBoth, psDash, 1);
  end;

  with PlanStatus do begin
    Panels[0].Text := Format(FORMHIPREC, [HOMEPOS, TimeUnit]);
    Panels[1].Text := Format(FORMHIPREC, [HOMEPOS, DepthUnit]);
    Panels[2].Text := Format(FORMRANGE,  [DepthMax * ScaleMult, DepthUnit, TimeMax, TimeUnit]);
  end;

  PlanLoop.Enabled := False; // 26.07.17 nk old=True
  Application.ProcessMessages;
end;

procedure TPlan.ReadDivePlan(var AmbPress, AmbTemp, ScanTime: Long);
var //26.07.17 nk opt
  i, last, press, temp: Long;
  cx, cy: Real; //26.07.17 nk add
begin
  with PlanChart do begin
    if PlanTicks = cNEG then begin
      DivePoint := cCLEAR;
      PlanTicks := cCLEAR;
      //nk//get color
    end else begin //get next dive point in chart
      Inc(DivePoint);
    end;

    with DataContainer[DivePoint] do begin
      if ItemKind <> tkNone then begin                                // 26.07.17 nk add/fix ff
        cx := X / (Scale1X.RangeHigh - Scale1X.RangeLow);             // 0..1 => 0..20min
        cy := MINDEPTHRANGE / (Scale1Y.RangeHigh - Scale1Y.RangeLow); // sea level offset = 5m
        cy := Y / (Scale1Y.RangeLow  - Scale1Y.RangeHigh) + cy;       // 0..1 => +5..-47m
        CrossHairSetPos(PENPLAN, cx, 1.0 - cy);                       // X [min] / Y -[m/ft]
        last      := PlanTicks;                                       // last system ticks [ms]
        PlanTicks := Round(X * MSEC_MIN);
        ScanTime  := PlanTicks - last;                                // [ms]

        if UnitFlag = cOFF then begin
          DepthMult := 1.0;
        end else begin
          DepthMult := FEET / 100.0;
        end;

        ScanPress := 1000 * Round(Y / DepthMult * -CENTI);     // [ubar]
        temp      := Daq.seWaterTemp.IntValue - Round(ScanPress / TempGrad);
        press     := AirPress + Round(ScanPress / MILLI);      // [mbar]
        AmbTemp   := Limit(temp,  WATERTEMPMIN, WATERTEMPMAX); // [cdeg]
        AmbPress  := Limit(press, SENSPRESSMIN, SENSPRESSMAX); // [mbar]

        for i := 0 to GASMIXES do begin
          if GasColor[i] = Color then begin
            cbGasMix.ItemIndex := i;
            //nk// return breathing gas mix
            Break;
          end;
        end;
      end else begin
        PlanTicks := cNEG;
        btStart.Click;
      end;

      with PlanStatus do begin
        Panels[0].Text := Format(FORMHIPREC, [X, TimeUnit]);
        Panels[1].Text := Format(FORMHIPREC, [Y, DepthUnit]);
        Panels[2].Text := Format(FORMRANGE,  [DepthMax * ScaleMult, DepthUnit, TimeMax, TimeUnit]);
      end;
    end;
  end;
end;

procedure TPlan.PlanChartMouseMoveInChart(Sender: TObject; InChart: Boolean; Shift: TShiftState; rMousePosX, rMousePosY: Double);
var
  px, py: Double;
begin
  if DivePhase > PHASEPREDIVE then Exit;

  with PlanStatus do begin
    if (rMousePosX < 0) or (rMousePosX > TimeMax) or
      (rMousePosY > 0)  or (rMousePosY < (-DepthMax * ScaleMult)) then begin
      px := HOMEPOS;
      py := HOMEPOS;
    end else begin
      px := rMousePosX;
      py := rMousePosY;
    end;

    Panels[0].Text := Format(FORMHIPREC, [px, TimeUnit]);
    Panels[1].Text := Format(FORMHIPREC, [py, DepthUnit]);
  end;
end;

procedure TPlan.PlanChartMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p, pm: Long;
  dx, dy, px, py, posy: Double;
begin
  with PlanChart do begin
    if (ssLeft in Shift) and (MousePosX > CrossHairPosX[1]) then begin
      if MousePosY > HOMEPOS then
        posy := HOMEPOS
      else
        posy := MousePosY;

      px := MousePosX - CrossHairPosX[1];
      py := posy - CrossHairPosY[1];
      dx := LogInterval / MSEC_MIN;
      dy := py / px * dx;
      pm := Round(px * MSEC_MIN / LogInterval);
      px := CrossHairPosX[1];
      py := CrossHairPosY[1];

      // use gas mix dependend pen color
      DataColor := GasColor[cbGasMix.ItemIndex];

      for p := 0 to pm - 1 do begin
        px := px + dx;
        py := py + dy;
        if py > HOMEPOS then py := HOMEPOS;
        DrawTo(px, py);
      end;

      ShowGraf;
      CrossHairSetPos(PENDEPTH, px, py);
    end;
  end;
end;

procedure TPlan.btClearClick(Sender: TObject);
begin
  InitDivePlan;
end;

procedure TPlan.btStartClick(Sender: TObject);
begin
  InvertBit(PlanFlag);

  //nk// disable form while simulation
  
  with btStart do begin
    if PlanFlag = cON then begin
      Caption := 'Stop';
      PlanChart.CrossHairSetup(PENDEPTH, COLORMAXDEPTH, chBoth, psSolid, 1); // 26.07.17 nk add
    end else begin
      Caption := 'Start';
    end;
    
    Hint := sSPACE + Caption + sSPACE + 'Dive Simulation ';
  end;
end;

procedure TPlan.btDepthClick(Sender: TObject);
begin
  with PlanChart do begin
    DepthMax         := Limit(DepthMax + 10, 0, MaxDepthRange);
    Scale1Y.RangeLow := -DepthMax * ScaleMult; //20.10.07 nk old=RangeLoY
    ShowGraf;
  end;
  PlanStatus.Panels[2].Text := Format(FORMRANGE, [DepthMax, DepthUnit, TimeMax, TimeUnit]);
end;

procedure TPlan.btTimeClick(Sender: TObject);
begin
  with PlanChart do begin
    TimeMax           := Limit(TimeMax + 10, 0, MaxTimeRange);
    Scale1X.RangeHigh := TimeMax; //20.10.07 nk old=RangeHiX
    ShowGraf;
  end;
  PlanStatus.Panels[2].Text := Format(FORMRANGE, [DepthMax, DepthUnit, TimeMax, TimeUnit]);
end;

procedure TPlan.cbGasMixDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with (Control as TRzComboBox).Canvas do begin
    FillRect(Rect);
    TextOut(26, Rect.Top + 1, cbGasMix.Items[Index]);
    Pen.Color   := clBlack;
    Brush.Color := GasColor[Index];
    Rectangle(Rect.Left + 3, Rect.Top + 3, 20, Rect.Top + 13);
  end;
end;

procedure TPlan.cbGasMixSelect(Sender: TObject);
begin
  btStart.SetFocus;
end;

end.
