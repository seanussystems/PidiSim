// Data Acquisition Task
// Date 26.07.17
// Norbert Koechli
// Copyright ©2005-2017 seanus systems

//nk// use Function for Unit conversion

unit FDaq;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Mask, Dialogs, ExtCtrls, StdCtrls, ComCtrls, Buttons, ImgList, StrUtils, Math,
  RzCommon, RzTabs, RzRadChk, RzEdit, RzSpnEdt, RzTrkBar, RzButton, RzBorder,
  RzDBTrak, RzCmboBx, USystem, URegistry, SYS, ADC, SER, Global, Data, Flash,
  Deco, Texts, Clock, Power, Sensor, Compass, Sonar, Tank, FLog, FInfo, UPidi;

type
  TDaq = class(TForm)
    DaqPageControl: TRzPageControl;
    DaqStatus: TStatusBar;
    DaqLoop: TTimer;
    DaqIcons: TImageList; //10.04.07 nk add
    TabControl: TRzTabSheet;
    TabSettings: TRzTabSheet;
    TabHelp: TRzTabSheet; //20.10.07 nk add
    rbSaltWater: TRzRadioButton;
    rbFreshWater: TRzRadioButton;
    seScanMulti: TRzSpinEdit;
    seSwimSpeed: TRzSpinEdit;
    seAltitude: TRzSpinEdit;
    seAirTemp: TRzSpinEdit;
    seWaterTemp: TRzSpinEdit;
    seSurfResp: TRzSpinEdit;
    seFillPress: TRzSpinEdit;
    edScanMulti: TRzNumericEdit;
    edSwimSpeed: TRzNumericEdit;
    edAltitude: TRzNumericEdit;
    edWaterTemp: TRzNumericEdit;
    edAirTemp: TRzNumericEdit;
    edSurfResp: TRzNumericEdit;
    edFillPress: TRzNumericEdit;
    lbScanMulti: TLabel;
    lbSwimSpeed: TLabel;
    lbAltitude: TLabel;
    lbAltitudeUnit: TLabel;
    lbAirTemp: TLabel;
    lbAirTempUnit: TLabel;
    lbWaterTemp: TLabel;
    lbWaterTempUnit: TLabel;
    lbSurfResp: TLabel;
    lbSurfRespUnit: TLabel;
    lbFillPress: TLabel;
    lbFillPressUnit: TLabel;
    btUp: TRzBitBtn;
    btDown: TRzBitBtn;
    btLeft: TRzBitBtn;
    btRight: TRzBitBtn;
    btStop: TRzBitBtn;
    btInfo: TRzButton;
    pnCompass: TPanel;
    pnPressure: TPanel;
    tbCompass: TRzTrackBar;
    tbPressure: TRzTrackBar;
    cbTank: TRzCheckBox;
    cbSonar: TRzCheckBox;

    //DELHP dive control panel functions
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMoving(var Msg: TwmMoving); message WM_MOVING;
    procedure DaqLoopTimer(Sender: TObject);
    procedure RunTask;
    procedure btUpClick(Sender: TObject);
    procedure btDownClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btLeftClick(Sender: TObject);
    procedure btRightClick(Sender: TObject);
    procedure btInfoClick(Sender: TObject); //20.10.07 nk add
    procedure rbWaterClick(Sender: TObject);
    procedure seScanMultiChange(Sender: TObject);
    procedure seSwimSpeedChange(Sender: TObject);
    procedure seAltitudeChange(Sender: TObject);
    procedure seWaterTempChange(Sender: TObject);
    procedure seAirTempChange(Sender: TObject);
    procedure seSurfRespChange(Sender: TObject);
    procedure seFillPressChange(Sender: TObject);
    procedure edScanMultiClick(Sender: TObject);
    procedure edSwimSpeedClick(Sender: TObject);
    procedure edAltitudeClick(Sender: TObject);
    procedure edAirTempClick(Sender: TObject);
    procedure edWaterTempClick(Sender: TObject);
    procedure edFillPressClick(Sender: TObject);
    procedure edSurfRespClick(Sender: TObject);
    procedure cbTankClick(Sender: TObject);
    procedure cbSonarClick(Sender: TObject);
  private
    //
  public  // Tiger DAQ functions (DAQ.INC)
    procedure CalcDiveTime(Stime: Long; var DiveTime, SurfaceTime, IntervalTime, DiveDayNum: Long; var DivePhase: Byte);
    procedure CalcDiveDepth(Apress: Long; var DiveDepth, MaxDepth: Long);
    procedure CalcAscentRate(Stime, Ddepth: Long; var AscentTime, DiveSpeed: Long);
    procedure CalcAltitude(Apress, Atemp: Long; var Altitude: Long);
    procedure CalcAirPress(Aalti, Atemp: Long; var AirPress: Long);
    procedure CalcBarometer(Apress: Long; var AirPress: Long);
    procedure CalcWater(Wsalt: Word; Atemp: Long; var WaterDens, SoundSpeed: Word); //13.05.07 nk add TIGER
    procedure CalcGasRate(Stime, AmbPress, TankPress, TotalDecoGas: Long; var BreathRate, GasTime: Long);
    procedure CalcOxygenDose(Stime: Long; var OxPress, OxClock, OxUnits, OxDose: Long);
    procedure CalcDiverScore(var DiverScore: Byte);
    procedure CheckLimits(var StatusWord: Word; var SigNum: Long);
    procedure InitEnvironment(DoClear: Boolean); //DELPHI only
  end;

var
  Daq: TDaq;

// Tiger declaration - must be global
//===================================
  DaqBuff: string;
  Ltime: Long;
  Mtime: Long;
  Htime: Long;
  Ptime: Long;

implementation

uses FMain, FGui, FProfile, FTrack, FPlan;

{$R *.dfm}

procedure TDaq.FormCreate(Sender: TObject);
var
  i: Long;
begin
  HideMaxButton(Self);   //hide maximize button
  HideCloseButton(Self); //hide close button

  DaqCtr    := cCLEAR;
  ScanPress := cCLEAR;

  with Daq do begin
    Tag         := TASKDAQ;
    HelpKeyword := IntToStr(PRIODAQ);
    Left        := MainRect.Right  - MainRect.Left - Width  - MAINMARGIN;
    Top         := MainRect.Bottom - MainRect.Top  - Height - MAINMARGIN;
    GetFormParameter(self);
    Width   := 248;
    Height  := 192 + TOPBORDER;
    Enabled := False;
    Show;
  end;

  with DaqPageControl do begin
    ActivePageIndex := 0;
    HotTrack := True;
  end;

  with DaqStatus do begin
    for i := 0 to Panels.Count - 1 do
      Panels[i].Text := sEMPTY;
  end;

  with DaqLoop do begin
    Interval := DAQDELAY;
    Enabled  := True;
  end;

  with tbCompass do begin
    Enabled := True;
    ShowHint := False;
    ShowTicks := True;
    Transparent := True;
    TabStop := False;
    ThumbStyle := tsPointer;
    TickStep := DAQTICKSTEP; // 45°
    Min := 0;
    Max := FULLCIRC;         // 360°
    Position := HALFCIRC;    // 180° (North)
  end;

  with tbPressure do begin
    Enabled := True;
    ShowHint := False;
    ShowTicks := True;
    Transparent := True;
    TabStop := False;
    ThumbStyle := tsPointer;
    TickStep := 10;
    Min := -SPEEDMAX;
    Max := SPEEDMAX;       // 50cm/s
    Position := cCLEAR;
  end;

  with pnCompass do begin
    AutoSize := False;
    Ctl3D := False;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Caption := sEMPTY;
    FullRepaint := True;
    Enabled := False;
  end;

  with pnPressure do begin
    AutoSize := False;
    Ctl3D := False;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Caption := sEMPTY;
    FullRepaint := True;
    Enabled := False;
  end;

  with seSwimSpeed do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AllowKeyEdit := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    Direction := sdUpDown;
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := False;
    ShowHint := False;
    TabStop := False;
    Increment := 1;
    Min := 0;
    Max := 20;
    Value := Min;
  end;

  with edSwimSpeed do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    DisplayFormat := '0';
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := True;
    ShowHint := False;
    TabStop := False;
  end;

  with seScanMulti do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AllowKeyEdit := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    Direction := sdUpDown;
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := False;
    ShowHint := False;
    TabStop := False;
    Increment := 1;
    Min := 1;
    Max := 15; //DO NOT CHANGE (ScanDelay)
    Value := Min;
  end;

  with edScanMulti do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    DisplayFormat := '0';
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := True;
    ShowHint := False;
    TabStop := False;
  end;

  with seAltitude do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AllowKeyEdit := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    Direction := sdUpDown;
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := False;
    ShowHint := False;
    TabStop := False;
    Increment := DAQALTSTEP;  // 100m
    Min := 0;
    Max := ALTITUDEMAX;
  end;

  with edAltitude do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    DisplayFormat := '0';
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := True;
    ShowHint := False;
    TabStop := False;
  end;

  with seAirTemp do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AllowKeyEdit := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    Direction := sdUpDown;
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := False;
    ShowHint := False;
    TabStop := False;
    Increment := CDEG;    // 100cdeg = 1°C
    Min := SENSTEMPMIN;
    Max := SENSTEMPMAX;
  end;

  with edAirTemp do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    DisplayFormat := '0';
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := True;
    ShowHint := False;
    TabStop := False;
  end;

  with seWaterTemp do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AllowKeyEdit := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    Direction := sdUpDown;
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := False;
    ShowHint := False;
    TabStop := False;
    Increment := CDEG;     // 100cdeg = 1°C
    Min := WATERTEMPMIN;
    Max := WATERTEMPMAX;
  end;

  with edWaterTemp do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    DisplayFormat := '0';
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := True;
    ShowHint := False;
    TabStop := False;
  end;

  with seSurfResp do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AllowKeyEdit := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    Direction := sdUpDown;
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := False;
    ShowHint := False;
    TabStop := False;
    Increment := 1;
    Min := SURFRESPMIN; // surface RMV [l/min]
    Max := SURFRESPMAX;
  end;

  with edSurfResp do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    DisplayFormat := '0';
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := True;
    ShowHint := False;
    TabStop := False;
  end;

  with seFillPress do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AllowKeyEdit := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    Direction := sdUpDown;
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := False;
    ShowHint := False;
    TabStop := False;
    Increment := 10;
    Min := FILLPRESSMIN;      // [bar]
    Max := FILLPRESSMAX;
  end;

  with edFillPress do begin
    Alignment := taRightJustify;
    AllowBlank := False;
    AutoSelect := False;
    AutoSize := False;
    CheckRange := False;
    Ctl3D := True;
    DisplayFormat := '0';
    FrameVisible := True;
    HideSelection := True;
    IntegersOnly := True;
    ReadOnly := True;
    ShowHint := False;
    TabStop := False;
  end;

  with cbTank do begin
    AlignmentVertical := avCenter;
    AllowGrayed := False;
    Checked := False;
    HotTrack := True;
    ShowHint := False;
    TabStop := False;
    Transparent := False;
    TabOnEnter := False;
  end;

  btDown.Hint  := MakeHint(0); //DELPHI only
  btUp.Hint    := MakeHint(1);
  btStop.Hint  := MakeHint(2);
  btLeft.Hint  := MakeHint(3);
  btRight.Hint := MakeHint(4);

  //nk// 22.05.07 nk del - do not load environment

  Application.ProcessMessages;
end;

procedure TDaq.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DaqLoop.Enabled := False;
  SetFormParameter(self);

  //nk// 22.05.07 nk del - do not save environment

  Action := caFree;
end;

procedure TDaq.FormMoving(var Msg: TwmMoving);
begin
  LimitFormMove(MainRect, Msg);
end;

procedure TDaq.DaqLoopTimer(Sender: TObject);
var
  enab: Boolean;
  tnow: TDateTime;
begin
  tnow := Now;
  enab := (DivePhase < PHASEPREDIVE); //27.05.07 nk add

  with DaqStatus, FormatSettings do begin //25.07.17 nk opt XE3
    Panels[0].Text := FormatDateTime(ShortDateFormat, tnow);
    Panels[1].Text := FormatDateTime(LongTimeFormat, tnow);
    Panels[2].Text := sSPACE + PhaseName[DivePhase];
  end;

  cbTank.Enabled  := enab;
  cbSonar.Enabled := enab;
  DaqPageControl.Pages[1].TabEnabled := enab;

  Application.ProcessMessages;
end;

procedure TDaq.InitEnvironment(DoClear: Boolean);
var // DELPHI only
  hour, nop: Long;
begin
  if DoClear then begin //22.05.07 nk add
    cbTank.Checked       := False;
    cbSonar.Checked      := False;
    tbPressure.Position  := cCLEAR;
    tbCompass.Position   := HALFCIRC;
    seAltitude.IntValue  := DEF_ALTITUDE;
    seAirTemp.IntValue   := DEF_AIRTEMP;
    seWaterTemp.IntValue := DEF_WATERTEMP;
    seSurfResp.IntValue  := DEF_SURFRESP;
    seFillPress.IntValue := DEF_FILLPRESS;
    seScanMulti.IntValue := DEF_SCANMULT;
    seSwimSpeed.IntValue := DEF_SWIMSPEED;

    SerPort   := DEF_SERPORT;
    ScanPress := cCLEAR;
    SaltWater := (seAltitude.IntValue = 0);
    ScanMulti := seScanMulti.IntValue;
    ScanDelay := Round(seScanMulti.Max - seScanMulti.IntValue) + 1;
    SwimSpeed := seSwimSpeed.IntValue;
  end;

  edScanMulti.IntValue := ScanMulti;
  edSwimSpeed.IntValue := SwimSpeed;
  rbFreshWater.Checked := not SaltWater;
  rbSaltWater.Checked  := SaltWater;

  if cbTank.Checked then begin
    TankFlag := cON;
  end else begin
    TankFlag := cOFF;
  end;

  if cbSonar.Checked then begin
    SonarFlag := cON;
  end else begin
    SonarFlag := cOFF;
  end;

  with seAltitude do begin
    if SaltWater then begin
      Increment := cCLEAR; // locked
      Value     := cCLEAR;
    end else begin
      Increment := DAQALTSTEP;  // 100m
    end;

    if UnitFlag = cOFF then begin  // metrical unit system
      edAltitude.Value       := Value;
      lbAltitudeUnit.Caption := DISTUNIT_EU;
    end else begin                 // imperial unit system
      edAltitude.Value       := Value * 3;  // 100m = 300ft
      lbAltitudeUnit.Caption := DEPTHUNIT_US;
    end;
  end;

  with seAirTemp do begin
    if UnitFlag = cOFF then begin  // metrical unit system
      edAirTemp.Value       := Value / CDEG;  // [°C]
      lbAirTempUnit.Caption := TEMPUNIT_EU;
    end else begin                 // imperial unit system
      edAirTemp.Value       := (Value * CFACTOR + COFFSET) / 1000; // [°F]
      lbAirTempUnit.Caption := TEMPUNIT_US;
    end;
  end;

  with seWaterTemp do begin
    if UnitFlag = cOFF then begin  // metrical unit system
      edWaterTemp.Value       := Value / CDEG;  // [cC]
      lbWaterTempUnit.Caption := TEMPUNIT_EU;
    end else begin                 // imperial unit system
      edWaterTemp.Value       := (Value * CFACTOR + COFFSET) / 1000; // [cF]
      lbWaterTempUnit.Caption := TEMPUNIT_US;
    end;
  end;

  with seSurfResp do begin
    SurfResp := IntValue;          // RMV at surface [l/min]
    if UnitFlag = cOFF then begin  // metrical unit system
      edSurfResp.Value       := Value;   // [l/min]
      lbSurfRespUnit.Caption := BREATHUNIT_EU;
    end else begin                 // imperial unit system
      edSurfResp.Value       := Value * CUIN / 10; // [CuIn/min]
      lbSurfRespUnit.Caption := BREATHUNIT_US;
    end;
  end;

  with seFillPress do begin
    FillPress := IntValue * MILLI; // tank fill pressure [mbar]
    if UnitFlag = cOFF then begin  // metrical unit system
      edFillPress.Value       := Value;  // [bar]
      lbFillPressUnit.Caption := TANKUNIT_EU;
    end else begin                 // imperial unit system
      edFillPress.Value       := Value * PSI / 10; // [PSI]
      lbFillPressUnit.Caption := TANKUNIT_US;
    end;
  end;

  Altitude := seAltitude.IntValue; // altitude above sea level [m]
  AirTemp  := seAirTemp.IntValue;  // air temperature [cdeg]

  CalcAirPress(Altitude, AirTemp, AmbPress); // get ambient pressure [mbar]
  CalcBarometer(AmbPress, AirPress);         // at altitude = air pressure [hPa]

  if SaltWater then begin
    TempGrad := 10000000 div WATERGRADSEA;
  end else begin
    TempGrad := 10000000 div (WATERGRADSEA + Altitude * WATERGRADALT);
  end;

  // simulates real air pressure history [hPa]
  if DoClear then begin
    GetClock(nop, nop, nop, nop, hour, nop, nop, nop);
    BaroPress[0]  := hour; // pointer to actual hour (00..23)
    BaroPress[1]  := ISOPRESS - 15;  // oldest air pressure -20h
    BaroPress[2]  := ISOPRESS - 14;
    BaroPress[3]  := ISOPRESS - 14;
    BaroPress[4]  := ISOPRESS - 12;
    BaroPress[5]  := ISOPRESS - 12;
    BaroPress[6]  := ISOPRESS - 8;
    BaroPress[7]  := ISOPRESS - 5;
    BaroPress[8]  := ISOPRESS;
    BaroPress[9]  := ISOPRESS;
    BaroPress[10] := ISOPRESS - 5;
    BaroPress[11] := ISOPRESS - 6;
    BaroPress[12] := ISOPRESS - 7;
    BaroPress[13] := ISOPRESS - 9;
    BaroPress[14] := ISOPRESS - 9;
    BaroPress[15] := ISOPRESS - 8;
    BaroPress[16] := ISOPRESS - 8;
    BaroPress[17] := ISOPRESS - 6;
    BaroPress[18] := ISOPRESS - 6;
    BaroPress[19] := ISOPRESS;
    BaroPress[20] := ISOPRESS;      // youngest air pressure -1h
    BaroPress[21] := ISOPRESS;      // actual air pressure
  end;

  Application.ProcessMessages;
end;

//DAQ application starts here

procedure TDaq.RunTask;
var
  press: Long;
begin
  if InitDaq <> cINIT then begin
    InitDaq := cINIT;     // DELPHI prevent multiple starts
    DaqCtr  := cCLEAR;
    Ltime   := cCLEAR;
    Mtime   := cCLEAR;
    Htime   := cCLEAR;
    Ptime   := cCLEAR;

    LastPress     := cCLEAR;  // TIGER add in task
    InitTime      := cCLEAR;
    TotalDecoTime := cCLEAR;

    InitEnvironment(True); //22.05.07 nk add DELPHI

    // initialize hardware modules
    ReadAccu(cCLEAR, AccuPower, AccuTime);
    InitSensor;        // get initial pressure, temperature, and salinity
    InitSaturation;
    InitTank;
    InitCompass;
    InitSonar;
    InitDaq := cINIT;
  end else begin // while (InitFlag = cINIT) do begin  (Tiger use a while loop)
    if DaqCtr >= MAXLOOP then begin
      DaqCtr := cCLEAR;
    end;

    // DELPHI get ambient values from dive plan or from control panel
    if PlanFlag = cON then begin
      if DaqCtr mod ScanDelay = 0 then begin
        Plan.ReadDivePlan(AmbPress, AmbTemp, ScanTime);
      end else begin
        ScanTime := cCLEAR;
      end;
    end else begin
      ReadPressure(AmbPress, AmbTemp, ScanTime);
    end;

    RunTime := RunTime + ScanTime;  // 07.06.07 nk add TIGER [ms]
    Ltime   := Ltime   + ScanTime;  // low priority loop time counter [ms]
    Mtime   := Mtime   + ScanTime;  // medium priority loop time counter [ms]
    Htime   := Htime   + ScanTime;  // high priority loop time counter [ms]
    Ptime   := Ptime   + ScanTime;  // log point interval time [ms]

    if DivePhase = PHASEREADY then begin
      ReadSalinity(WaterSalt, WaterFlag); //TIGER add check if immersed
    end;

    CalcDiveDepth(AmbPress,  DiveDepth, MaxDepth);
    CalcDiveTime(ScanTime,   DiveTime,  SurfaceTime, IntervalTime, DiveDayNum, DivePhase);
    CalcAscentRate(ScanTime, DiveDepth, AscentTime,  DiveSpeed);

    if (WinPos3 = WINNAVIGATION) or (DaqCtr mod 4 = 0) then begin
      ReadCompass(Heading);
      if SonarFlag = cON then begin
        ReadSonar(HomeDist, Bearing, SonarSignal);

        Track.AddDivePos(AUTOINC, HomeDist, Bearing);    //nk//test
        Track.DrawDivePos(HomeDist, Bearing, True);
        Track.MoveDiver(SwimSpeed, Heading); // DELPHI diver tracking simulation
      end;
    end;

    if DaqCtr mod HIGLOOP = 0 then begin  // high priority actions every 7 loops   TIGER opt
      CalcOxygenDose(Htime, OxPress, OxClock, OxUnits, OxDose); //TIGER add
      CalcSaturation(Htime, NullTime, DesatTime, FlightTime);

      if (NullTime <= 0) or (TotalDecoTime > 0) then begin // deco situation - deco stop required
        DecoFlag := cON;
        NullTime := cCLEAR;
        CalcDecoStop(DecoTime, DecoDepth);  // calculate 1st (deepest) deco level [m] and time [s]
        CalcDecoTime(TotalDecoTime, TotalDecoGas); // calculate total deco time [s] and gas consum [mbar]
      end else begin
        DecoFlag     := cOFF;
        DecoTime     := cCLEAR;
        DecoDepth    := cCLEAR;
        TotalDecoGas := cCLEAR;
      end;

      Htime := cCLEAR;
    end;

    if DaqCtr mod MEDLOOP = 0 then begin  // medium priority actions every 11 loops  TIGER add ff
      if TankFlag = cON then begin  //02.06.07 nk add TankFlag
        ReadTank(Mtime, TankPress);
        CalcGasRate(Mtime, AmbPress, TankPress, TotalDecoGas, BreathRate, GasTime);
      end;

      Mtime := cCLEAR;
    end;

    if DaqCtr mod LOWLOOP = 0 then begin    // low priority actions every 39 loops
      ReadAccu(Ltime, AccuPower, AccuTime); // 07.06.07 nk add Ltime TIGER
      ReadSalinity(WaterSalt, WaterFlag);   // TIGER add

      if WaterFlag = cON then begin         // TIGER add
        CalcWater(WaterSalt, AmbTemp, WaterDens, SoundSpeed); //13.05.07 nk TIGER add
      end else begin
        CalcBarometer(AmbPress, press);     //Tiger=AirPress
        CalcAltitude(AmbPress, AmbTemp, Altitude);
      end;

      Ltime := cCLEAR;
    end;

    if DivePhase > PHASEPREDIVE then begin
      if DivePhase < PHASEPOSTDIVE then begin
        CheckLimits(StatusWord, SigNum);     // check warning and alarm limits
      end;

      if (LogInterval > cOFF) and (Ptime >= LogInterval) then begin
        if LogTime > cOFF then begin
          LogDiveBlock;        // log dive parameter and status while diving
        end;
        Ptime      := cCLEAR;
        StatusWord := cCLEAR;  // clear all warning and alarm status bits
      end;
    end;

    if RunMode = MODESTART then begin
      LogEvent(TaskName[TASKDAQ], 'Switch task', 'OFF');
      DaqLoop.Enabled := False;   // stop task DAQ
    end;

    DaqCtr := DaqCtr + 1;
  end; // while
end;

procedure TDaq.btInfoClick(Sender: TObject);
begin //20.10.07 nk add
  Info.ShowLogo(10);
end;

//------------------------------------------------------------------------------
// CALCDIVETIME - Calculate the absolute start time [s], the current dive phase
//   and dive number, and all dive, log and surface times [ms]
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcDiveTime(Stime: Long; var DiveTime, SurfaceTime, IntervalTime, DiveDayNum: Long; var DivePhase: Byte);
var
  nop: Long;
begin
  //TIGER del PhaseFlag := cOFF;

  if Stime <= 0 then begin
    Exit;
  end;
  
  case DivePhase of
    PHASEINITIAL:	begin
      InitTime := InitTime + Stime;            // wait until initialized
      //nk//InitTime := INITDELAY; //nk// test

      if InitTime >= INITDELAY then begin
        PhaseFlag := cON;
        DivePhase := PHASEADAPTION;            // initialized -> ADAPTION PHASE
        Exit;
      end;
    end;

    PHASEADAPTION: begin
      SurfaceTime := SurfaceTime + Stime;      // count surface time up [ms]

      if DiveFlag = cON then begin             // check if dived
        PhaseFlag := cON;
        DivePhase := PHASEREADY;               // direct dive -> READY PHASE
        Exit;
      end;

      if WaterFlag = cON then begin            // check if inside water
        PhaseFlag := cON;
        DivePhase := PHASEREADY;               // immersed -> READY PHASE
        Exit;
      end;

      if DesatTime < SEC_MIN then begin        // check if desaturated = adapted
        PhaseFlag := cON;
        DivePhase := PHASEREADY;               // adapted -> READY PHASE
        Exit;
      end;

      AirTemp := AmbTemp;
    end;

    PHASEREADY: begin
      SurfaceTime := SurfaceTime + Stime;      // count surface time up [ms]
      //02.06.07 nk del TIGER FillPress := TankPress;

      if DiveFlag = cON then begin             // check if dived
        PhaseFlag := cON;
        DivePhase := PHASEPREDIVE;             // direct dive -> PREDIVE PHASE
        Exit;
      end;

      if WaterFlag = cON then begin            // check if inside water
        PhaseFlag := cON;
        DivePhase := PHASEPREDIVE;             // immersed -> PREDIVE PHASE
        Exit;
      end;

      if DesatTime > SEC_HOUR then begin       // check if in altitude
        PhaseFlag := cON;
        DivePhase := PHASEADAPTION;            // unadapted -> ADAPTION PHASE
        Exit;
      end;

      AirTemp := AmbTemp;
    end;

    PHASEPREDIVE:	begin
      SurfaceTime := SurfaceTime + Stime;      // count surface time up [ms]
      SigNum := SIGNONE;                       // clear all pending signals

      if DiveFlag = cON then begin             // check if dived
        ////// START OF DIVE //////
        GetClock(StartTime, nop, nop, nop, nop, nop, nop, nop);

        if DiveDayNum >= MAXDAYDIVE then begin
          DiveDayNum := cCLEAR;
        end;

        DiveDayNum := DiveDayNum + 1;          // count daily dives up (1..9)
        StatusWord := cCLEAR;
        DaqCtr     := cCLEAR;
        DiveTime   := cCLEAR;                  // clear all timers and counters
        LogTime    := cCLEAR;
        WaterTemp  := AmbTemp;

        InitDiveLog;                           // initialize a new dive log

        SurfaceTime  := cCLEAR;
        IntervalTime := DiveRepTime;
        PhaseFlag    := cON;
        DivePhase    := PHASEDIVE;             // dived -> DIVE PHASE
        Exit;
      end;

      if WaterFlag = cOFF then begin           // check if already inside water
        PhaseFlag := cON;
        DivePhase := PHASEREADY;               // outside water -> READY PHASE
        Exit;
      end;
    end;

    PHASEDIVE: begin
      LogTime       := LogTime + Stime;        // count log time up [ms]
      DiveTime      := DiveTime + Stime;       // count dive time up [ms]
      TotalDiveTime := TotalDiveTime + Stime;  // count total dive time up [ms]

      if AmbTemp < WaterTemp then begin        // get min water temperature [cdeg]
        WaterTemp := AmbTemp;
      end;

      if DiveFlag = cOFF then begin            // check if alredy dived
        PhaseFlag := cON;
        DivePhase := PHASEPOSTDIVE;            // dive paused -> POSTDIVE PHASE
        Exit;
      end;
    end;

    PHASEPOSTDIVE: begin
      SurfaceTime  := SurfaceTime + Stime;     // count surface time up [ms]
      IntervalTime := DiveRepTime - SurfaceTime + MSEC_MIN; // count interval time down [ms]
      LogTime      := LogTime + Stime;         // count log time up [ms]

      if DiveFlag = cON then begin             // check if dived again
        SurfaceTime  := cCLEAR;
        IntervalTime := DiveRepTime;
        PhaseFlag    := cON;
        DivePhase    := PHASEDIVE;             // dive continue -> DIVE PHASE
        Exit;
      end;

      if SurfaceTime > DiveRepTime then begin  // check if dive timeouted
        ////// END OF DIVE //////
        GetClock(EndTime, nop, nop, nop, nop, nop, nop, nop);

        CloseDiveLog;

        IntervalTime := DiveRepTime;
        PhaseFlag    := cON;
        DivePhase    := PHASEINTERVAL;         // end of dive -> INTERVAL PHASE
        DiveTime     := cCLEAR;                // clear old dive data
        DiveDepth    := cCLEAR;
        MaxDepth     := cCLEAR;
        Exit;
      end;
    end;

    PHASEINTERVAL: begin
      SurfaceTime := SurfaceTime + Stime;      // count surface time up [ms]

      if DiveFlag = cON then begin             // check if dived
        PhaseFlag := cON;
        DivePhase := PHASEREADY;               // repetition dive -> READY PHASE
        Exit;
      end;

      if DesatTime < SEC_MIN then begin        // check if desaturated
        OxUnits       := cCLEAR;               // clear oxygen units [mOTU]
        OxClock       := cCLEAR;               // and CNS clock [ppm]
        DiveDayNum    := cCLEAR;               // clear daily dive counter
        TotalDiveTime := cCLEAR;
        PhaseFlag     := cON;
        DivePhase     := PHASEREADY;           // desaturated -> READY PHASE
        Exit;
      end;

      AirTemp := AmbTemp;
    end;
  else
    DaqBuff := IntToStr(DivePhase);
    LogError('CalcDiveTime', 'Invalid dive phase', DaqBuff, $90);
  end;
end;

//------------------------------------------------------------------------------
// CALCDIVEDEPTH - Calculate the dive depth [cm] and the maximal dive depth [cm]
//   and check if dived for the given ambient pressure [mbar]
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcDiveDepth(Apress: Long; var DiveDepth, MaxDepth: Long);
var
  depth: Long;
begin
  depth := Apress - AirPress;       // difference pressure at depth [mbar] rel surface

  //nk// make true depth corrections here - using WaterDens

  if depth > ActivDepth then begin  // check activation depth [mbar=cm]
    DiveFlag  := cON;               // -> dived
    WaterFlag := cON;
  end else begin
    DiveFlag := cOFF;               // -> not dived
  end;

  DiveDepth := Limit(depth, 0, DEPTHDISP);        // actual dive depth [cm] (0..199m)
  MaxDepth  := Limit(depth, MaxDepth, DEPTHDISP); // max dive depth [cm] (0..199m)
end;

//------------------------------------------------------------------------------
// CALCASCENTRATE - Calculate dive speed [%] and the total time to surface [s]
//   inclusive resting time for all deco stops
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcAscentRate(Stime, Ddepth: Long; var AscentTime, DiveSpeed: Long);
var
  ad, at, dd, ds, sd: Long;
  t, cs, av, ms : Real;
begin
  if Stime <= 0 then begin
    Exit;
  end;

  t  := Stime / MSEC_SEC;          // measuring time interval [s]
  ad := Ddepth;                    // actual dive depth [cm]
  sd := DiveSpeed;                 // last calculated dive speed [%]
  dd := DeltaDepth - ad;           // depth difference while scan time [cm]

  av := ad / (2 * SPEEDRATE) + SPEEDMIN; // average dive speed [cm/s] to surface
  ms := ad / SPEEDRATE + SPEEDMIN;  // max allowed ascending speed [cm/s]

  if ms > SPEEDMAX then begin
    ms := SPEEDMAX;
  end;

  if dd < 0 then begin             // pos=ascending / neg=descending
    ms := SPEEDDOWN;               // max descending dive speed [cm/s]
  end;
  
  if (t > 0) and (ms > 0) then begin
    cs := dd / t;                  // actual dive speed [cm/s]
    cs := (PROCENT * cs) / ms;
    ds := Trunc(cs);               // relative dive speed [%]
    if Abs(ds) < SPEEDMIN then begin
      ds := cCLEAR;
    end;
  end else begin
    ds := cCLEAR;
  end;

  if av > 0 then begin
    av := ad / av;
    at := Round(av) + SEC_MIN;     // shortest ascent time to surface [s]
  end else begin
    at := 0;
  end;

  dd := at;                        // direct time to surface [s]
  at := dd + TotalDecoTime;        // add deco time to ascent time [s]
  ds := (sd + ds) div 2;           // smooth dive speed and round to tenth [%]

  DeltaDepth := ad;                      // memorize depth for next function call [cm]
  DiveSpeed  := Limit(ds, -SPEEDDISP, SPEEDDISP); // dive speed [%] (+/-990)
  DirectTime := Limit(dd, 0, TIMEDISP);  // direct time to surface [s] (99:59)
  AscentTime := Limit(at, 0, TIMEDISP);  // total time to surface [s] (99:59)
end;

//------------------------------------------------------------------------------
// CALCALTITUDE - Calculate altitude above sea level [m] from ambient pressure
//   [hPa] and ambient temperature [cdeg] - corrected to standard atmosphere
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcAltitude(Apress, Atemp: Long; var Altitude: Long);
var
  t: Long;
  r: Real;
begin
  t := Atemp + KELVIN;               // air temperature [cK] at altitude
  r := ISOPRESS / Apress;            // pressure relation sea level/altitude
  Pow(r, 0.19);
  r := -t / ISOSLOPE * (1 - r);
  RoundInt(r, t);                    // temp corrected altitude [m]

  Altitude := Limit(t, 0, ALTITUDEMAX);
end;

//------------------------------------------------------------------------------
// CALCAIRPRESS - Calculate air pressure [hPa] from altitude above sea level [m]
//   and air temperature [cdeg] - corrected to standard atmosphere
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcAirPress(Aalti, Atemp: Long; var AirPress: Long);
var
  t: Long;
  r: Real;
begin
  t := Atemp + KELVIN;               // air temperature [cK] at altitude
  r := t / (t + ISOSLOPE * Aalti);   // temp correction
  Pow(r, 5.255);
  r := ISOPRESS * r;
  RoundInt(r, t);                    // air pressure [hPa] at altitude

  AirPress := Limit(t, AIRPRESSMIN, AIRPRESSMAX);
end;

//------------------------------------------------------------------------------
// CALCBAROMETER - Calculate barometer history [hPa] for the last 20 hours
//   and smooth air pressure [hPa] from ambient pressure [mbar]
//   BaroPress[0]  = actual hour pointer (00..23)
//   BaroPress[1]  = oldest air pressure [hPa] -20 hour
//   BaroPress[20] = youngest air pressure [hPa] -1 hour
//   BaroPress[21] = actual air pressure [hPa] (smoothed)
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcBarometer(Apress: Long; var AirPress: Long);
var
  p, ptr: Word;
  hour, tmp: Long;
begin
  if Apress > AIRPRESSMAX then begin           // may be dived - ignore it
    Exit;
  end;

  tmp      := (BaroPress[BAROHIST] + Apress) div 2; // smooth air pressure [hPa]
  AirPress := Limit(tmp, AIRPRESSMIN, AIRPRESSMAX);
  ptr      := BaroPress[0];                         // actual hour pointer
  BaroPress[BAROHIST] := AirPress;

  //nk//DaqBuff := IntToStr(Apress) + sSPLIT + IntToStr(AirPress);
  //LogEvent('CalcBarometer', 'Air pressure smoothed', DaqBuff);

  GetClock(tmp, tmp, tmp, tmp, hour, tmp, tmp, tmp); // get full hour

  if hour <> ptr then begin
    DaqBuff := IntToStr(ptr) + sSPLIT + IntToStr(hour);
    LogEvent('CalcBarometer', 'Shift hour from', DaqBuff);

    for p := 1 to BAROHIST - 1 do begin        // shift baro pressure [hPa] to next full hour
      BaroPress[p] := BaroPress[p + 1];
    end;

    ptr := ptr + 1;

    if ptr >= HOUR_DAY then begin              // hour overflow on a new day
      ptr := cCLEAR;
    end;

    BaroPress[0] := ptr;                       // memorize new hour pointer
  end;
end;

//------------------------------------------------------------------------------
// CALCWATER - Calculate the sound speed [dm/s] and the density [g/dl] of water
//   from given water salinity [ppt] and temperature [cdeg]
//------------------------------------------------------------------ 13.05.07 --
procedure TDaq.CalcWater(Wsalt: Word; Atemp: Long; var WaterDens, SoundSpeed: Word);
begin //TODO use true calc formel
  WaterDens  := ISODENS;   // [g/dl]
  SoundSpeed := ISOSPEED;  // [dm/s]
end;

//------------------------------------------------------------------------------
// CALCGASRATE - Calculate the breathing rate at surface [mbar/s] and the
//   remaining gas time [s] including gas forecast for all deco stops based
//   on decrease in tank pressure [mbar] since the last measuring time [ms]
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcGasRate(Stime, AmbPress, TankPress, TotalDecoGas: Long; var BreathRate, GasTime: Long);
var           //TIGER add sub ff
  gs: Long;
  t, br: Real;
begin
  BreathRate := cCLEAR;                 // breathing rate [mbar/s]

  if TankPress > LastPress then begin   // tank pressure is not decreased
    LastPress := TankPress;             // [mbar]
  end;

  gs := LastPress - TankPress;          // gas consum since last measuring [mbar]

  if (Stime <= 0) or (AmbPress <= 0) or (gs <= 0) then begin
    Exit;
  end;

  t  := Stime / MSEC_SEC;               // measuring time interval [s]
  br := gs / t;                         // breating rate at depth [mbar/s]
  gs := TankPress - TotalDecoGas - TANKRESERVE; // remain gas at depth [mbar]
  gs := Trunc(gs / br) - DirectTime;    // remain time at depth [s]
  br := br * MILLI / AmbPress;          // breating rate at surface [mbar/s]
  RoundInt(br, BreathRate);             // breating rate at surface (rounded)

  GasTime   := Limit(gs, 0, TIMEDISP);  // remain gas time (RBT) [s] (99:59)
  LastPress := TankPress;               // memorize tank pressure [mbar]
{
Log.Print('total deco stop gas [mbar]: ' + IntToStr(TotalDecoGas)); //nk//
Log.Print('breating rate at surface [mbar/s]: ' + IntToStr(BreathRate));
Log.Print('direct time to surface [s]: ' + IntToStr(DirectTime));
Log.Print('remain gas time at depth [s]: ' + IntToStr(GasTime));
}
end;

//------------------------------------------------------------------------------
// CALCOXYGENDOSE - Calculate oxygen toxicity dose and oxygen partial pressure
//   Calculations based on NOAA using 1ata = 1bar (ata=bar/1.01325)
//   CNS (central nervous system) defined as cns clock [ppm] use
//     interpolation algorithm 1%/min = 167ppm/s
//   OTU (oxygen tolerance unit) cumulated pulmonary oxygen toxicity [mOTU]
//     rel to max single day exposure dose (850 OTU) [ppm]
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcOxygenDose(Stime: Long; var OxPress, OxClock, OxUnits, OxDose: Long);
var
  s, ot, os: Byte;
  Px, Pp: Long;
  fo, th, cns, otu, upd: Long;
  t, ec, eu: Real;
label
  FINI;
begin
  if Stime <= 0 then begin
    Exit;
  end;

  t   := Stime / MSEC_SEC;             // measuring time interval [s]
  cns := OxClock;                      // actual CNS oxygen clock [ppm]
  otu := OxDose;                       // actual OTU oxygen dose [mOTU]
  th  := OXHALFTIME;                   // cns clock half time [s] (=90min)
  os  := OXPSTEP - 1;                  // steps for cns clock calculation
  ot  := OXPPART;                      // oxygen partial pressure per step [mbar]
  Px  := OXPMIN;                       // min oxygen partial pressure [mbar]
  fo  := OxFract;                      // oxygen fraction in tank gas [ppt]
  Pp  := AmbPress * fo div 1000;       // oxygen partial pressure in tank gas [mbar] at depth

  if Pp <= Px then begin               // oxygen desaturation at surface
    ec := 1.0 - exp(-t / th * LN2);    // exponential time function of cns clock
    ec := ec * cns;                    // oxygen clock desaturation [ppm] while t [s]
    t  := -1.0;
    goto FINI;
  end;

  // OTU calculation
  eu  := (Pp - Px) / Px;
  Pow(eu, 0.83);                       // oxygen dose uptake [OTU/min]
  eu  := 1000 * t * eu / SEC_MIN;      // formulae is based on min
  otu := otu + Trunc(eu);              // oxygen dose uptake [mOTU] while t [s]

  // CNS calculation
  ec := Op[os];                        // oxygen clock uptake [ppm/s] at max ppO2 (>2200mbar)

  for s := 1 to os do begin
    Px := Px + ot;
    if Pp < Px then begin
      upd := Pp mod ot;
      ec  := (Op[s] - Op[s - 1]) / ot;
      ec  := Op[s - 1] + upd * ec;     // oxygen clock uptake [ppm/s] (cns clock)
      goto FINI;
    end;
  end;

FINI:
  ec  := t * ec;
  cns := cns + Trunc(ec);              // cumulated oxygen clock CNS [ppm]
  upd := 100 * otu div OXMAXDOSE;      // cumulated oxygen units OTU [ppm]

  OxPress := Limit(Pp,  0, OXRANGE);   // oxygen partial pressure [mbar] (0..9999)
  OxClock := Limit(cns, 0, OXDISP);    // cumulated oxygen clock CNS [ppm] (0..999%)
  OxUnits := Limit(upd, 0, OXDISP);    // cumulated oxygen units OTU [ppm] (0..999%)
  OxDose  := Limit(otu, 0, OXDISP);    // cumulated oxygen dose [mOTU] (0..9990 OTU)

//Log.Print('========================================='); //nk// test
//Log.Print('PPO2 [mbar]: ' + IntToStr(OxPress));
//Log.Print('CNS [ppm]  : ' + IntToStr(OxClock));
//Log.Print('OTU [ppm]  : ' + IntToStr(OxUnits));
//Log.Print('OTU [mOTU] : ' + IntToStr(OxDose));
end;

//------------------------------------------------------------------------------
// CALCDIVERSCORE - Calculate the diver score from persons constitution and
//   physical condition and his body mass index (BMI)
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CalcDiverScore(var DiverScore: Byte);
var
  ds, dh, dw: Long;
  DiverBmi: Real;
begin
  if (DiverWeight = 0) or (DiverHeight = 0) then begin //24.05.07 nk add TIGER
    LogError('CalcDiverScore', 'Invalid diver data', sEMPTY, $90);   //nk// code??
    Exit;
  end;

  ds := SCOREMAX;                      // initial diver score = 100%
  dw := DiverWeight * 1000;            // weight of diver [g]
  dh := DiverHeight;                   // height of diver [cm]
  DiverBmi := 10 * dw / (dh * dh);     // calculate body mass index (BMI) [-]

  DaqBuff := Format('%2.1f', [DiverBmi]);
  LogEvent('CalcDiverScore', 'Diver BMI', DaqBuff);

  if DiverAge < 20 then begin          // diver age (20..39 = 100%)
    ds := ds - 3;
  end;

  if (DiverAge >= 40) and (DiverAge < 50) then begin
    ds := ds - 3;
  end;

  if (DiverAge >= 50) and (DiverAge < 60) then begin
    ds := ds - 8;
  end;

  if (DiverAge >= 60) and (DiverAge < 70) then begin
    ds := ds - 13;
  end;

  if DiverAge >= 70 then begin
    ds := ds - 18;
  end;

  if DiverBmi < 16 then begin          // body mass index (20..24 = 100%)
    ds := ds - 15;
  end;

  if (DiverBmi >= 16) and (DiverBmi < 18) then begin
    ds := ds - 10;
  end;

  if (DiverBmi >= 18) and (DiverBmi < 20) then begin
    ds := ds - 5;
  end;

  if (DiverBmi >= 25) and (DiverBmi < 28) then begin
    ds := ds - 5;
  end;

  if (DiverBmi >= 28) and (DiverBmi < 31) then begin
    ds := ds - 10;
  end;

  if (DiverBmi >= 31) and (DiverBmi < 34) then begin
    ds := ds - 15;
  end;

  if (DiverBmi >= 34) and (DiverBmi < 37) then begin
    ds := ds - 20;
  end;

  if (DiverBmi >= 37) and (DiverBmi < 40) then begin
    ds := ds - 25;
  end;

  if (DiverBmi >= 40) and (DiverBmi < 44) then begin
    ds := ds - 30;
  end;

  if (DiverBmi >= 44) and (DiverBmi < 48) then begin
    ds := ds - 35;
  end;

  if DiverBmi >= 48 then begin
    ds := ds - 40;
  end;

  if DiverGender > 0 then begin        // diver gender (0=m, 1=f)
    ds := ds - 3;
  end;

  if DiverGrade = 1 then begin         // diver certification grade (1=basic..6=expert)
    ds := ds - 8;
  end;

  if DiverGrade = 2 then begin
    ds := ds - 3;
  end;

  if DiverYears < 3 then begin         // diver experience (years diving)
    ds := ds - 3;
  end;

  if DiverSmoker = 1 then begin        // diver smoking (0=never, 1=sometimes, 2=often)
    ds := ds - 8;
  end;

  if DiverSmoker = 2 then begin
    ds := ds - 15;
  end;

  if DiverFitness = 1 then begin       // diver fitness (1=poor..6=excellent)
    ds := ds - 63;
  end;

  if DiverFitness = 2 then begin
    ds := ds - 48;
  end;

  if DiverFitness = 3 then begin
    ds := ds - 20;
  end;

  if DiverFitness = 4 then begin
    ds := ds - 8;
  end;

  if DiverFitness = 5 then begin
    ds := ds - 3;
  end;

  DiverScore := Limit(ds, SCOREMIN, SCOREMAX); // return diver score [%] (25..100)
  DaqBuff    := IntToStr(DiverScore);
  LogEvent('CalcDiverScore', 'Diver Score %', DaqBuff);
end;

//------------------------------------------------------------------------------
// CHECKLIMITS - Check if any warning or alarm limits are exceeded and create
//   status word and object signal number for async message
//   Clear status bits after logging, CheckSignal clears object signal number
//   Lowest priority has bit 00 - highest priority has bit 15:
//     - bit 00 - temperature warning      - bit 08 - gas time warning
//     - bit 01 - breath rate warning      - bit 09 - dive speed alarm
//     - bit 02 - dive depth warning       - bit 10 - tank pressure alarm
//     - bit 03 - dive speed warning       - bit 11 - accu power alarm
//     - bit 04 - tank pressure warning    - bit 12 - deco violation alarm
//     - bit 05 - accu power warning       - bit 13 - oxygen toxicity alarm
//     - bit 06 - oxygen toxicity warning  - bit 14 - oxygen pressure alarm
//     - bit 07 - oxygen pressure warning  - bit 15 - gas time alarm
//   Caution: SigNum ranges from 1..16 (0=No signal to handle)
//------------------------------------------------------------------ 17.02.07 --
procedure TDaq.CheckLimits(var StatusWord: Word; var SigNum: Long);
var                   //TIGER use this sub
  snum, onum: Word;   //02.06.07 nk add TankFlag ff
begin
  snum := StatusWord;  // set bit 0..15 (Word) not 1..16
  onum := cCLEAR;

  // SIGWARNTEMP - temperature warning [cdeg]
  if WaterTemp < WarnTemp then begin
    onum := SIGWARNTEMP;
    SetBit(snum, onum - 1);
  end;

  // SIGWARNBREATH - breath rate warning [%]
  if (BreathRate > WarnBreath) and (TankFlag = cON) then begin
    onum := SIGWARNBREATH;
    SetBit(snum, onum - 1);
  end;

  // SIGWARNDEPTH - dive depth warning [cm]
  if WarnDepth > cOFF then begin
    if DiveDepth > WarnDepth then begin
      onum := SIGWARNDEPTH;
      SetBit(snum, onum - 1);
    end;
  end;

  // SIGWARNSPEED - dive speed warning [%]
  if DiveSpeed > cOFF then begin
    if DiveSpeed > WarnSpeed then begin
      onum := SIGWARNSPEED;
      SetBit(snum, onum - 1);
    end;
  end;

  // SIGWARNTANK - tank pressure warning [%]
  if (WarnTank > cOFF) and (TankFlag = cON) then begin
    if TankPress < (WarnTank * FillPress div PROCENT) then begin
      onum := SIGWARNTANK;
      SetBit(snum, onum - 1);
    end;
  end;

  // SIGWARNACCU - remain accu power warning [%]
  if AccuPower < WarnPower then begin
    onum := SIGWARNACCU;
    SetBit(snum, onum - 1);
  end;

  // SIGWARNOXDOSE - oxygen toxicity warning [ppm]
  if (OxClock > WarnOxDose) or (OxUnits > WarnOxDose) then begin
    onum := SIGWARNOXDOSE;
    SetBit(snum, onum - 1);
  end;

  // SIGWARNOXPRESS - oxygen pressure warning [mbar]
  if OxPress > WarnOxPress then begin
    onum := SIGWARNOXPRESS;
    SetBit(snum, onum - 1);
  end;

  // SIGWARNGAS - remain gas time warning [s]
  if (GasTime < WarnGas) and (TankFlag = cON) then begin
    onum := SIGWARNGAS;
    SetBit(snum, onum - 1);
  end;

  // SIGALARMSPEED - dive speed alarm [%]
  if DiveSpeed > cOFF then begin
    if DiveSpeed > AlarmSpeed then begin
      onum := SIGALARMSPEED;
      SetBit(snum, onum - 1);
    end;
  end;

  // SIGALARMTANK - tank pressure alarm [%]
  if (AlarmTank > cOFF) and (TankFlag = cON) then begin
    if TankPress < (AlarmTank * FillPress div PROCENT) then begin
      onum := SIGALARMTANK;
      SetBit(snum, onum - 1);
    end;
  end;

  // SIGALARMACCU - remain accu power alarm [%]
  if AccuPower < AlarmPower then begin
    onum := SIGALARMACCU;
    SetBit(snum, onum - 1);
  end;

  // SIGALARMDECO - deco violation alarm [cm]
  if DiveDepth < (DecoCeil - 20) then begin
    onum := SIGALARMDECO;
    SetBit(snum, onum - 1);
  end;

  // SIGALARMOXDOSE - oxygen toxicity alarm [ppm]
  if (OxClock > AlarmOxDose) or (OxUnits > AlarmOxDose) then begin
    onum := SIGALARMOXDOSE;
    SetBit(snum, onum - 1);
  end;

  // SIGALARMOXPRESS - oxygen pressure alarm [mbar]
  if OxPress > AlarmOxPress then begin
    onum := SIGALARMOXPRESS;
    SetBit(snum, onum - 1);
  end;

  // SIGALARMGAS - remain gas time alarm [s]
  if (GasTime < AlarmGas) and (TankFlag = cON) then begin
    onum := SIGALARMGAS;
    SetBit(snum, onum - 1);
  end;

  StatusWord := snum;  // log all warnings and alarms (bit-wise)

  // prefer highest signal priority
  if onum > SigNum then begin
    SigNum := onum;
  end;
end;


//DELPHI: dive control panel
////////////////////////////

procedure TDaq.btStopClick(Sender: TObject);
begin
  ResetSensor;
end;

procedure TDaq.btDownClick(Sender: TObject);
begin
  with tbPressure do begin
    if Position > -SPEEDMAX then
      Position := Position - 2;
  end;
end;

procedure TDaq.btUpClick(Sender: TObject);
begin
  if WaterFlag = cOFF then Exit;
  
  with tbPressure do begin
    if Position < SPEEDMAX then
      Position := Position + 2;
  end;
end;

procedure TDaq.btRightClick(Sender: TObject);
begin
  with tbCompass do begin
    if Position >= (FULLCIRC - HEADSTEP) then
      Position := cCLEAR
    else
      Position := Position + HEADSTEP;
  end;
end;

procedure TDaq.btLeftClick(Sender: TObject);
begin
  with tbCompass do begin
    if Position <= cCLEAR then
      Position := FULLCIRC - HEADSTEP
    else
      Position := Position - HEADSTEP;
  end;
end;

procedure TDaq.rbWaterClick(Sender: TObject);
begin
  SaltWater := rbSaltWater.Checked;

  with seAltitude do begin
    if SaltWater then begin
      Increment := cCLEAR;      // locked
      Value     := cCLEAR;
      edAltitude.Value := cCLEAR;
    end else begin
      Increment := DAQALTSTEP;  // 100m
    end;
  end;
end;

procedure TDaq.seAltitudeChange(Sender: TObject);
begin
  with seAltitude do begin
    if UnitFlag = cOFF then begin  // metrical unit system
      edAltitude.Value       := Value;
      lbAltitudeUnit.Caption := DISTUNIT_EU;
    end else begin                 // imperial unit system
      edAltitude.Value       := Value * 3;  // 100m = 300ft
      lbAltitudeUnit.Caption := DEPTHUNIT_US;
    end;
  end;
end;

procedure TDaq.seWaterTempChange(Sender: TObject);
begin
  with seWaterTemp do begin
    if UnitFlag = cOFF then begin  // metrical unit system
      edWaterTemp.Value       := Value / CDEG;  // [cC]
      lbWaterTempUnit.Caption := TEMPUNIT_EU;
    end else begin                 // imperial unit system
      edWaterTemp.Value       := (Value * CFACTOR + COFFSET) / 1000; // [cF]
      lbWaterTempUnit.Caption := TEMPUNIT_US;
    end;
  end;
end;

procedure TDaq.seAirTempChange(Sender: TObject);
begin
  with seAirTemp do begin
    if UnitFlag = cOFF then begin  // metrical unit system
      edAirTemp.Value       := Value / CDEG;  // [cC]
      lbAirTempUnit.Caption := TEMPUNIT_EU;
    end else begin                 // imperial unit system
      edAirTemp.Value       := (Value * CFACTOR + COFFSET) / 1000; // [cF]
      lbAirTempUnit.Caption := TEMPUNIT_US;
    end;
  end;
end;

procedure TDaq.seSurfRespChange(Sender: TObject);
begin
  with seSurfResp do begin
    SurfResp := IntValue;          // RMV at surface [l/min]
    if UnitFlag = cOFF then begin  // metrical unit system
      edSurfResp.Value       := Value;   // [l/min]
      lbSurfRespUnit.Caption := BREATHUNIT_EU;
    end else begin                 // imperial unit system
      edSurfResp.Value       := Value * CUIN / 10; // [CuIn/min]
      lbSurfRespUnit.Caption := BREATHUNIT_US;
    end;
  end;
end;

procedure TDaq.seFillPressChange(Sender: TObject);
begin
  with seFillPress do begin
    FillPress := IntValue * MILLI; // tank fill pressure [mbar]
    TankPress := FillPress;
    
    if UnitFlag = cOFF then begin  // metrical unit system
      edFillPress.Value       := Value;  // [bar]
      lbFillPressUnit.Caption := TANKUNIT_EU;
    end else begin                 // imperial unit system
      edFillPress.Value       := Value * PSI / 10; // [PSI]
      lbFillPressUnit.Caption := TANKUNIT_US;
    end;
  end;
end;

procedure TDaq.seScanMultiChange(Sender: TObject);
begin
  ScanMulti := seScanMulti.IntValue;
  ScanDelay := Round(seScanMulti.Max - seScanMulti.IntValue) + 1;
  edScanMulti.IntValue := ScanMulti;
end;

procedure TDaq.seSwimSpeedChange(Sender: TObject);
begin
  SwimSpeed := seSwimSpeed.IntValue;
  edSwimSpeed.IntValue := SwimSpeed;
end;

procedure TDaq.edAltitudeClick(Sender: TObject);
begin
  seAltitude.SetFocus;
end;

procedure TDaq.edAirTempClick(Sender: TObject);
begin
  seAirTemp.SetFocus;
end;

procedure TDaq.edWaterTempClick(Sender: TObject);
begin
  seWaterTemp.SetFocus;
end;

procedure TDaq.edFillPressClick(Sender: TObject);
begin
  seFillPress.SetFocus;
end;

procedure TDaq.edSurfRespClick(Sender: TObject);
begin
  seSurfResp.SetFocus;
end;

procedure TDaq.edScanMultiClick(Sender: TObject);
begin
  seScanMulti.SetFocus;
end;

procedure TDaq.edSwimSpeedClick(Sender: TObject);
begin
  seSwimSpeed.SetFocus;
end;

procedure TDaq.cbTankClick(Sender: TObject);
begin
  if cbTank.Checked then begin
    TankFlag := cON;
  end else begin
    TankFlag := cOFF;
  end;

  Tank.InitTank;
  PhaseFlag := cON;
end;

procedure TDaq.cbSonarClick(Sender: TObject);
begin
  if cbSonar.Checked then begin
    SonarFlag := cON;
    Track.WindowState := wsNormal;
  end else begin
    SonarFlag := cOFF;
    Track.WindowState := wsMinimized;
  end;

  Sonar.InitSonar;
  PhaseFlag := cON;
end;

end.
