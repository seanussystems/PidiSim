// Graphical User Interface Task
// Date 28.05.22

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit FGui;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Math, StrUtils, USystem, URegistry, SYS, RTC,
  LCD, Global, Display, Data, Texts, Flash, Clock, Power, FDaq, FLog, UPidi;

type
  TGui = class(TForm)
    Display: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMoving(var Msg: TwmMoving); message WM_MOVING;
    procedure RunTask;
  private
    //
  public  // TIGER replace all subs
    procedure OpenMessage(Xpos, Ypos, Inum, Tdur, Ddel: Byte; var Knum: Byte; Mhead, Mbody, Mtail: string);
    procedure OpenMenu(Amenu: Byte; var Comm: Word);
    procedure OpenCalendar(var Comm: Word);
    procedure OpenPlanner(var Comm: Word);
    procedure OpenProfile(var Comm, Dive: Word);
    procedure OpenLogbook(var Comm, Dive: Word);
    procedure OpenCatalog(var Comm, Dive: Word);
    procedure CheckSignal;
  end;

var
  Gui: TGui;
  
implementation

uses FMain, FProfile, FTrack, FPlan;

{$R *.dfm}

procedure TGui.FormCreate(Sender: TObject);
begin
  HideMaxButton(Self);   // hide maximize button
  HideCloseButton(Self); // hide close button

  with Gui do begin
    Tag            := TASKGUI;
    HelpKeyword    := IntToStr(PRIOGUI);
    Visible        := False;
    DoubleBuffered := True;
    KeyPreview     := True;
    Left           := MAINMARGIN;
    Top            := MAINMARGIN;
    GetFormParameter(Self);
    Width          := 262;
    Height         := 281;
    Show;
  end;

  with Display do begin
    Align              := alNone;
    AutoSize           := False;
    Center             := False;
    Cursor             := crDefault;
    IncrementalDisplay := False;
    Proportional       := False;
    Transparent        := False;
    Stretch            := False;
    ShowHint           := False;
    Visible            := False;
  end;

  InitGui := cCLEAR;
  Application.ProcessMessages;
end;

procedure TGui.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i, imax: Long;
begin
  SetFormParameter(Self);

  imax := Gui.ComponentCount - 1; // free display buffer and images

  for i := imax downto 0 do begin
    if Gui.Components[i] is TImage then begin
      (Gui.Components[i] as TImage).Free;
    end;
  end;

  Action := caFree;
end;

procedure TGui.FormMoving(var Msg: TwmMoving);
begin
  LimitFormMove(MainRect, Msg);
end;

// GUI - Task handles display, joystick and buzzer user interface

procedure TGui.RunTask;
var
  k, xs, ys, dflag, dclear, inum, lnum, knum, kret, knul, tdur: Byte;
  win, level, prec, pBear, aWin: Byte;
  comm, dive, box, lpos, tctr, rctr, tnum, conv, pHead: Word;
  ttemp, kdel, nop: Long;
  dYear, dMonth, dDay, dHour, dMins, dSecs, dDir, dDose: Long;
  pTankPress, pDecoTime, pAccuVolt, pSaturation, dAccuVolt: Long;
  dDiveDepth, dMaxDepth, dDiveTime, dDiveSpeed, dDecoDepth: Long;
  dTankPress, dAscentTime, dRemTime, dDecoTime: Long;
  dTemp, dHead, dBear, dDist, dAirPress, dAltitude, dHist: Long;
  dIntervalTime, dSurfaceTime, dFlightTime, dDesatTime: Long;
  rTemp: Real;
  sTime, sDate, lMon, sDay, lDay: string;
  tf: string;
  tbuff: string; //old=[MAXBUFF];
  last: array[0..MENULEVEL] of Byte;
begin
  if InitGui <> cINIT then begin
    InitGui := cINIT;    // DELPHI prevent multiple starts

    InitLcd;
    InitGraphics;

    LoadDiveCatalog(dive, DiveLogNum); // 06.02.07 nk opt TIGER

    LoadSettings;        // load saved setting parameters from flash
    SetGlobalData;       // initialize global data and text strings

    InitScreen(INITWIN); // after LoadSettings (Contrast...)
    UpdateLcd;

    //WaitDuration(DISPDELAY);  //show pidi logo

    DebugFlag := cOFF;  // debugger off
    PhaseFlag := cON;
    DivePhase := PHASEINITIAL;
    InitFlag  := cINIT;
    InitGui   := cINIT;
  end;

  // local variables
  GuiCtr := cCLEAR;
  tctr   := cCLEAR;
  rctr   := cCLEAR;
  kdel   := cCLEAR;
  dive   := cCLEAR;
  dclear := cON;
  dflag  := cON;
  aWin   := WINPOWER;

  for k := 0 to MENULEVEL - 1 do begin  // clear last menu levels
    last[k] := cCLEAR;
  end;

  while (InitFlag = cINIT) do begin
    knul := 0;

    if GuiCtr >= MAXLOOP then begin
      GuiCtr := cCLEAR;
    end;

    if PhaseFlag = cON then begin    // phase changed -> refresh display
      LogEvent('GUI', 'Phase changed to', PhaseName[DivePhase]);

      if TankFlag = cON then begin
        aWin := WINGAS;
      end else begin
        aWin := WINPOWER;
      end;

      dclear    := cON;
      PhaseFlag := cOFF;

      case DivePhase of
        PHASEADAPTION: begin
          WinPos1 := WINBARO;
          WinPos2 := WINCLOCK;
          WinPos3 := WINPOWER;
          WinPos4 := WINDECO;
        end;

        PHASEREADY: begin
          WinPos1 := WINBARO;
          WinPos2 := WINCLOCK;
          WinPos3 := aWin;
          WinPos4 := WINDECO;
        end;

        PHASEPREDIVE: begin
          WinPos1 := WINDEPTH;
          WinPos2 := WINTIME;
          WinPos3 := aWin;
          WinPos4 := WINDECO;
        end;

        PHASEDIVE: begin
          WinPos1 := WINDEPTH;
          WinPos2 := WINTIME;
          WinPos3 := aWin;
          WinPos4 := WINDECO;
        end;

        PHASEPOSTDIVE: begin
          WinPos1 := WINDEPTH;
          WinPos2 := WINTIME;
          WinPos3 := aWin;
          WinPos4 := WINDECO;
        end;

        PHASEINTERVAL: begin
          WinPos1 := WINBARO;
          WinPos2 := WINTIME;
          WinPos3 := aWin;
          WinPos4 := WINDECO;
        end;
      end;

      // memorize previous shown windows
      WinPre3 := WinPos3;
      WinPre4 := WinPos4;
    end;

    if WinPos3 = WINNAVIGATION then begin
      lnum := HEADLOOP;
    end else begin
      lnum := DISPLOOP;
    end;

    if GuiCtr mod lnum = 0 then begin  // auto-refreh display every lnum loops
      dflag := cON;
    end;

    if dclear = cON then begin // clear screen and
      dflag := cON;            // rebuild display
      InitScreen(cCLEAR);      // initialize screen with background pattern

      if WinPos1 = WINDEPTH then begin
        DispWindow(1, 0, 100);
        DispText(0, Mask[130], NORMPOS);
        DrawBox(11);  // dive speed frame box
        DispSymbol(5, 7);    // dive speed percent symbol [%]
        DispText(9, Mask[142], NORMPOS); // max dive depth text (MAX)
        if UnitFlag = cOFF then begin
          DispSymbol(3, 13);  // dive depth metric symbol (M)
        end else begin
          DispSymbol(3, 14);  // dive depth imperial symbol (Ft)
        end;
      end;

      if WinPos1 = WINBARO then begin
        DispWindow(1, 0, 100);
        DispText(90, Mask[138], NORMPOS);
        ClearBox(94);          // air pressure history frame
        DrawBox(94);

        if UnitFlag = cOFF then begin
          DispSymbol(93, 32);  // air pressure metric symbol [hPa]
          DispSymbol(97, 13);  // altitude metric symbol (M)
        end else begin
          DispSymbol(93, 33);  // air pressure imperial symbol [inHg]
          DispSymbol(97, 14);  // altitude imperial symbol (Ft)
        end;
      end;

      if WinPos2 = WINCLOCK then begin
        DispWindow(2, 0, 100);
        DispText(80, Mask[136], NORMPOS);
      end;

      if WinPos2 = WINTIME then begin
        DispWindow(2, 0, 100);
        DispText(10, Mask[131], NORMPOS);
      end;

      if WinPos3 = WINPOWER then begin
        DispWindow(3, 0, 100);
        DispText(120, Mask[135], NORMPOS);
        DrawBox(124);          // accu voltage frame box
        DispSymbol(122, 7);    // accu voltage symbol [%]

        if UnitFlag = cOFF then begin
          DispSymbol(126, 8);  // temperature metric symbol (°C)
        end else begin
          DispSymbol(126, 9);  // temperature imperial symbol (°F)
        end;
      end;

      if WinPos3 = WINGAS then begin
        DispWindow(3, 0, 100);
        DispText(30, Mask[133], NORMPOS);
        DrawBox(34);           // tank pressure frame box

        if UnitFlag = cOFF then begin
          DispSymbol(33, 30);  // tank pressure symbol (BAR)
          DispSymbol(37, 8);   // temperature metric symbol (°C)
        end else begin
          DispSymbol(33, 31);  // tank pressure symbol (PSI)
          DispSymbol(37, 9);   // temperature imperial symbol (°F)
        end;
      end;

      if WinPos3 = WINNAVIGATION then begin
        DispWindow(5, 0, 100);
        DispText(40, Mask[134], NORMPOS);
        ClearBox(44);        // fill rectangle
        DispSymbol(43, 10);  // degree symbol (°)
        DispSymbol(45, 17);  // heading pointer symbol (arrow up)
      end else begin
        GlobalSet[0, 1, 2] := cOFF;
      end;

      if WinPos3 = WINSATURATION then begin
        DispWindow(5, 0, 100);
        DispText(130, Mask[137], NORMPOS);
        DispSymbol(147, 20);     // small percent symbol [%]
        DispNumValue(148, 100);  // scale labeling (100%)
        DispNumValue(149, 70);
        DispNumValue(150, 40);
        DrawLine(167);          // draw scaling lines
        DrawLine(168);
        DrawLine(169);
      end else begin
        GlobalSet[0, 2, 2] := cOFF;
      end;

      if WinPos4 = WINDECO then begin // 26.02.07 nk add oxygen toxicity
        ClearBox(28);
        ClearBox(39);
        DispWindow(4, 0, 100);
        DispText(20, Mask[132], NORMPOS);
        DispSymbol(28, 34); // oxygen symbol (O2)
        DrawBox(29);        // leading tissue frame box
        DispText(39, sPROCENT, NORMPOS);
      end;
    end;

    if dflag = cON then begin           // re-write value in the boxes
      if WinPos1 = WINDEPTH then begin
        dDiveDepth := DiveDepth;        // dive depth [cm]
        dMaxDepth := MaxDepth;          // max depth [cm]

        ClearBox(1);
        ClearBox(2);
        ClearBox(4);
        ClearBox(6);
        ClearBox(7);
        ClearBox(8);

        if UnitFlag = cON then begin  // imperial unit system
          prec := 0;
          ConvertValue(dDiveDepth, prec, 247);
          prec := 0;
          ConvertValue(dMaxDepth, prec, 247);
        end;

        if (dDiveDepth > 0) and (dDiveDepth < 10000) then begin
          dDiveDepth := dDiveDepth div DEZI;
          DispNumValue(1, dDiveDepth);
        end else begin
          dDiveDepth := dDiveDepth div CENTI;
          DispNumValue(2, dDiveDepth);
        end;

        if (dMaxDepth > 0) and (dMaxDepth < 10000) then begin
          dMaxDepth := dMaxDepth div DEZI;
          DispNumValue(7, dMaxDepth);
        end else begin
          dMaxDepth := dMaxDepth div CENTI;
          DispNumValue(8, dMaxDepth);
        end;

        if DivePhase = PHASEDIVE then begin
          dDiveSpeed := Abs(DiveSpeed);
          dDir := Sign(DiveSpeed);
        end else begin
          dDiveSpeed := cCLEAR;
          dDir := cCLEAR;
        end;

        DispNumValue(4, dDiveSpeed);

        case dDir of
          cPOS: DispSymbol(6, 1);  // dive up (ascending)
          cNEG: DispSymbol(6, 2);  // dive down (descending)
        else    DispSymbol(6, 3);  // neutral
        end;
      end;

      if WinPos1 = WINBARO then begin
        dAirPress := AirPress;  // air pressure [hPa]
      //dAltitude := Altitude;  // altitude above sea level [m] //TIGER only
        dAltitude := Daq.edAltitude.IntValue; //DELPHI only [m/ft]

        ClearBox(91);
        ClearBox(92);
        ClearBox(96);
        ClearBox(94);
        DrawBox(94);

        for k := 1 to BAROHIST do begin  // air press bar graph
          if (k mod 2) <> 0 then begin
            BoxSpec[95, 2] := 5 + k * 2;
            dHist := BaroPress[k] - BAROMIN; // barometric pressure [hPa]
            dHist := PROCENT * dHist div (BAROMAX - BAROMIN);
            dHist := Limit(dHist, 0, PROCENT);
            DispBarValue(95, dHist);
          end;
        end;

        if UnitFlag = cON then begin
          prec := 0;  // air pressure [inHg]
          ConvertValue(dAirPress, prec, 237);  // hPa -> inHG
          dAirPress := (dAirPress * 100 + prec) div 10;
          DispNumValue(92, dAirPress);
        //prec := 0; // altitude above sea level [ft]  //Tiger only
        //ConvertValue(dAltitude, prec, 229);  // m -> ft
        end else begin
          DispNumValue(91, dAirPress);
        end;
        DispNumValue(96, dAltitude);
      end;

      if WinPos2 = WINCLOCK then begin
        GetClock(TimeDate, dYear, dMonth, dDay, dHour, dMins, nop, nop);
        FormatTimeDate(TimeDate, sTime, sDate, lMon, sDay, lDay, tf);

        ClearBox(81);
        ClearBox(82);
        ClearBox(83);
        ClearBox(84);
        ClearBox(85);
        ClearBox(86);  // TIGER

        DispText(84, lDay, NORMPOS);
        DispText(85, sDate, NORMPOS);

        if TimeFlag = USA then begin  // US time format
          GetUsTime(dHour, tf);       // change time format
          DispNumValue(81, dHour);
          DispNumValue(82, dMins);
          DispText(83, tf, NORMPOS);
        end else begin                // ISO and EU time format
          DispNumValue(81, dHour);
          DispNumValue(82, dMins);
        end;

        if AlarmSet = cON then begin  // TIGER
          DispSymbol(86, 35);         // clock alarm symbol
        end;
      end;

      if WinPos2 = WINTIME then begin
        FormatTime(DiveTime, MSEC_SEC, dDiveTime);

        case DivePhase of
          PHASEPREDIVE: begin
            ClearBox(12);
            ClearBox(13);
            ClearBox(14);
            ClearBox(15);
            ClearBox(16);

            DispNumValue(12, dDiveTime);
            DispNumValue(15, cCLEAR);           // ascent time=0
            DispSymbol(16, 6);                  // ascent time arrow symbol

            //nk//if TankFlag = cON then begin        // remain bottom time [s] 99:59
            //FormatTime(GasTime, 1, dRemTime);

            dRemTime := Min(GasTime, AccuTime); //nk//
            FormatTime(dRemTime, 1, dRemTime);
            DispNumValue(13, dRemTime);
            DispText(14, Mask[143], NORMPOS); // RBT

            //end else begin                      // total bottom time [ms] 99:59
            //  FormatTime(TotalDiveTime, MSEC_SEC, dRemTime);
            //  dRemTime := dRemTime + 1;         // round up to next minute
            //  DispNumValue(13, dRemTime);
            //  DispText(14, Mask[144], NORMPOS); // TBT
            //end;
          end;

          PHASEDIVE: begin
            ClearBox(12);
            ClearBox(13);
            ClearBox(14);
            ClearBox(15);
            ClearBox(16);
            ClearBox(18);

            FormatTime(AscentTime, 1, dAscentTime);
            DispNumValue(15, dAscentTime);
            DispSymbol(16, 6);                  // ascent time arrow symbol

            if dDiveTime <= TENHOUR then begin
              DispNumValue(12, dDiveTime);      // time format 9:59
            end else begin
              DispNumValue(18, dDiveTime);      // time format 99:59
            end;

            //nk//if TankFlag = cON then begin        // remain bottom time [s] 99:59
            dRemTime := Min(GasTime, AccuTime); //nk//
            FormatTime(dRemTime, 1, dRemTime);
            DispNumValue(13, dRemTime);
            DispText(14, Mask[143], NORMPOS); // RBT
            //end else begin                      // total dive time [ms] 99:59
            //  FormatTime(TotalDiveTime, MSEC_SEC, dRemTime);
            //  dRemTime := dRemTime + 1;         // round up to next minute
            //  DispNumValue(13, dRemTime);
            //  DispText(14, Mask[144], NORMPOS); // TBT
            //end;
          end;

          PHASEPOSTDIVE: begin
            ClearBox(12);
            ClearBox(13);
            ClearBox(14);
            ClearBox(15);
            ClearBox(16);
            ClearBox(18);

            FormatTime(IntervalTime, MSEC_SEC, dIntervalTime);
            DispNumValue(15, dIntervalTime);
            DispSymbol(16, 5);                  // dive interval symbol (->)

            if dDiveTime <= TENHOUR then begin
              DispNumValue(12, dDiveTime);      // time format 9:59
            end else begin
              DispNumValue(18, dDiveTime);      // time format 99:59
            end;

            //nk//if TankFlag = cON then begin        // remain bottom time [s] 99:59
            dRemTime := Min(GasTime, AccuTime); //nk//
            FormatTime(dRemTime, 1, dRemTime);
            DispNumValue(13, dRemTime);
            DispText(14, Mask[143], NORMPOS); // RBT
            //end else begin                      // total dive time [ms] 99:59
            //  FormatTime(TotalDiveTime, MSEC_SEC, dRemTime);
            //  dRemTime := dRemTime + 1;         // round up to next minute
            //  DispNumValue(13, dRemTime);
            //  DispText(14, Mask[144], NORMPOS); // TBT
            //end;
          end;

          PHASEINTERVAL: begin
            GetClock(nop, dYear, dMonth, dDay, dHour, dMins, nop, nop);

            ClearBox(13);
            ClearBox(14);
            ClearBox(15);
            ClearBox(16);
            ClearBox(17);
            ClearBox(81);
            ClearBox(82);
            ClearBox(83);

            if TimeFlag = USA then begin    // US time format
              GetUsTime(dHour, tf);         // change time format
              DispNumValue(81, dHour);
              DispNumValue(82, dMins);
              DispText(83, tf, NORMPOS);
            end else begin                  // ISO or EU time format
              DispNumValue(81, dHour);
              DispNumValue(82, dMins);
            end;

            FormatTime(TotalDiveTime, MSEC_SEC, dRemTime); // total dive time [ms] 99:59
            dRemTime := dRemTime + 1;                      // round up to next minute
            DispNumValue(13, dRemTime);
            DispText(14, Mask[144], NORMPOS);              // TDT
            FormatTime(SurfaceTime, MSEC_SEC, dSurfaceTime);
            DispNumValue(15, dSurfaceTime);
            DispSymbol(16, 18);                            // surface symbol
            DrawLine(88);
          end;
        end;

        if DiveDayNum > cOFF then begin
          ClearBox(17);
          DispNumValue(17, DiveDayNum);
        end;
      end;

      if WinPos3 = WINPOWER then begin
        dAccuVolt := AccuPower;  // [%]
        pAccuVolt := AccuPower;

        ClearBox(121);
        ClearBox(123);
        ClearBox(125);

        DispNumValue(121, dAccuVolt);
        DispBarValue(123, pAccuVolt);  // accu volt bar graph (0..100%)

        if DivePhase = PHASEPOSTDIVE then begin
          dTemp := WaterTemp;  // min water temperature [cC]
        end else begin
          dTemp := AmbTemp;    // ambient temperature [cC]
        end;

        if UnitFlag = cON then begin
          prec := 0;
          ConvertValue(dTemp, prec, 241); // temperature [cC -> cF]
        end;

        dTemp := dTemp div 10;
        DispNumValue(125, dTemp);
      end;

      if WinPos3 = WINGAS then begin
        pTankPress := PROCENT * TankPress div FillPress;
        dTankPress := TankPress div 1000;   // tank pressure [bar]

        ClearBox(35);
        ClearBox(36);

        if DivePhase = PHASEPOSTDIVE then begin
          dTemp := WaterTemp;  // min water temperature [cdeg]
        end else begin
          dTemp := AmbTemp;    // ambient temperature [cdeg]
        end;

        if UnitFlag = cOFF then begin
          ClearBox(31);
          DispNumValue(31, dTankPress); // [bar]
        end else begin
          prec := 0;
          ConvertValue(dTemp, prec, 241); // temperature [cC -> cF]
          prec := 0;
          ConvertValue(dTankPress, prec, 235); // tank pressure [bar -> PSI]
          ClearBox(32);
          DispNumValue(32, dTankPress);
        end;

        dTemp := dTemp div 10;
        DispNumValue(36, dTemp);
        DispBarValue(35, pTankPress);  // tank pressure bar graph
      end;

      if WinPos3 = WINNAVIGATION then begin
        ClearBox(41);
        ClearBox(42);
        ClearBox(46);
        ClearBox(47);
        ClearBox(48);

        if SonarFlag = cON then begin  //02.06.07 nk add TIGER ff
          dDist := HomeDist;
          dBear := (FULLCIRC - Heading + Bearing) mod FULLCIRC;
          GetBearSymbol(dBear, pBear);

          if UnitFlag = cON then begin
            prec := 0;
            ConvertValue(dDist, prec, 239);  //TIGER distance [yd]
            DispSymbol(47, 15);   // distance imperial symbol (yd)
          end else begin
            DispSymbol(47, 13);   // distance metric symbol (M)
          end;

          dDist := dDist div 10;
          DispNumValue(46, dDist);
          DispSymbol(48, pBear);
        end else begin
          DispSymbol(47, 50);   //02.06.07 nk add no sonar symbol (X) TIGER
        end;

        dHead := Heading div DDEG;
        pHead := HEADOFFSET - HEADMIDDLE + Heading div HEADPIXEL;
        lpos := LangFlag * LANGOFFSET;

        DispBitmap(41, pHead, lpos); // show language dep compass scale
        DispNumValue(42, dHead);
      end;

      if WinPos3 = WINSATURATION then begin
        DisableTsw;

        for k := 1 to MAXCOMP - 1 do begin
          box := 130 + k;
          ClearBox(box);
          box := 150 + k;
          ClearBox(box);
          box := 130 + k;
          pSaturation := Rg[k] - SATOFFSET;
          DispBarValue(box, pSaturation);
          box := 150 + k;
          pSaturation := Rc[k] - SATOFFSET;
          DispBarValue(box, pSaturation);
        end;

        EnableTsw;
      end;

      if WinPos4 = WINDECO then begin
        case DivePhase of
          PHASEADAPTION: begin
            if DesatTime > SEC_MIN then begin
              ClearBox(24);
              ClearBox(25);
              ClearBox(26);
              FormatTime(DesatTime, 1, dDesatTime);
              pDecoTime := PROCENT * DesatTime div SEC_DAY;
              DispNumValue(24, dDesatTime);
              DispBarValue(25, pDecoTime);
              DispSymbol(26, 23);  // desat symbol
            end;
          end;

          PHASEINTERVAL: begin
            if (FlightTime < SEC_MIN) and (DesatTime > SEC_MIN) then begin
              ClearBox(24);
              ClearBox(25);
              ClearBox(26);
              FormatTime(DesatTime, 1, dDesatTime);
              pDecoTime := PROCENT * DesatTime div SEC_DAY;
              DispNumValue(24, dDesatTime);
              DispBarValue(25, pDecoTime);
              DispSymbol(26, 23);  // desat symbol
            end;

            if FlightTime >= SEC_MIN then begin
              ClearBox(24);
              ClearBox(25);
              ClearBox(26);
              FormatTime(FlightTime, 1, dFlightTime);
              pDecoTime := PROCENT * FlightTime div SEC_DAY;
              DispNumValue(24, dFlightTime);
              DispBarValue(25, pDecoTime);
              DispSymbol(26, 19);  // not fly symbol
            end;
          end;
        else // case default
          begin
            pDecoTime := LeadTissue - SATOFFSET;
            ttemp := PROCENT - SATOFFSET;
            ClearBox(21);
            ClearBox(22);
            ClearBox(23);
            ClearBox(24);
            ClearBox(25);
            ClearBox(26);
            DispBarValue(25, pDecoTime);
            DispBarValue(29, ttemp); // draw the 100% line

            if DecoTime > 0 then begin
              dDecoDepth := DecoDepth div CENTI;  // deco depth [m]
              FormatTime(DecoTime, 1, dDecoTime); // format hhmm [s]

              //03.06.07 nk add ff TIGER
              if dDecoTime > DECODISP then begin  // format 99:59
                BoxSpec[24,2] := 29;              // change box location
                BoxSpec[24,3] := 19;              // and dimension to
                BoxSpec[24,4] := 23;              // use small number font
                BoxSpec[24,5] := 9;
                BoxSpec[24,7] := SMALLNUMS;
              end else begin                      // format :59
                BoxSpec[24,2] := 15;              // restore original
                BoxSpec[24,3] := 17;              // box parameter
                BoxSpec[24,4] := 36;
                BoxSpec[24,5] := 11;
                BoxSpec[24,7] := BIGNUMS;
              end;

              DispNumValue(24, dDecoTime);
              DispSymbol(22, 5);  // deco arrow sign (->) (after box 24!!)

              if UnitFlag = cOFF then begin
                DispSymbol(23, 13);               // deco depth symbol [m]
              end else begin
                prec := 0;
                ConvertValue(dDecoDepth, prec, 253); //deco depth [ft] [3m=10ft]
                DispSymbol(23, 14);               // deco depth symbol [ft]
              end;

              if dDecoDepth > DECODISP then begin // format 'nnn' (100..999m/ft)
                BoxSpec[21,3] := 19;              // change box location
                BoxSpec[21,5] := 9;               // and dimension to
                BoxSpec[21,7] := SMALLNUMS;       // use small number font
                BoxSpec[21,8] := 30;
              end else begin                      // format 'nn' (0..99m/ft)
                BoxSpec[21,3] := 17;              // restore original
                BoxSpec[21,5] := 11;              // box parameter
                BoxSpec[21,7] := BIGNUMS;
                BoxSpec[21,8] := 20;
              end;

              ClearBox(21);
              DispNumValue(21, dDecoDepth);
            end else begin
              if NullTime >= TIMERANGE then begin
                dDecoTime := cCLEAR;
              end else begin
                FormatTime(NullTime, 1, dDecoTime); // format 99:59 [min]
              end;
              DispNumValue(24, dDecoTime);
            end;
          end;
        end; // case

        ClearBox(27);
        ClearBox(38);

        rTemp := OxPress / 100;          // mbar -> bar format n.n
        RoundInt(rTemp, dDose);
        DispNumValue(27, dDose);         // oxygen partial pressure [bar]

        if OxUnits > OxClock then begin  // oxygen units OTU%
          dDose := OxUnits div 10000;    // ppm -> % format nnn
          DispNumValue(38, dDose);
        end else begin                   // oxygen clock CNS%
          dDose := OxClock div 10000;    // ppm -> % format nnn
          DispNumValue(38, dDose);
        end;
      end;   // WinPos=WINDECO
    end;     // dflag=cON

    if dflag = cON then begin
      if ObjFlag = cON then begin
        ObjFlag := cNEW;
      end else begin
        UpdateLcd;     // refresh display screen and show actual values
      end;
    end;

    CheckSignal;   // open message window if required

    GuiCtr := GuiCtr + 1;
    dflag  := cOFF;
    dclear := cOFF;
    level  := cCLEAR;
    knum   := cCLEAR;
    comm   := COMMEXIT;

    WaitDuration(GUIDELAY + kdel);
    kdel := cCLEAR;  // DELPHI

    GetKeyNum(knum);                 // get number of depressed key

    if knum <> cKEYNONE then begin
      tctr := cCLEAR;               // reset task counter if key pressed
    end else begin
      rctr := cCLEAR;              // reset display restart counter
    end;

    case knum of                         // select key command
      cKEYUP: begin                       // up - reset system
        rctr := rctr + 1;                   // wait a few seconds
        if rctr = KEYLOOP then begin        // re-initialize display
          InitLcd;
          UpdateLcd;
          WaitDuration(TASKDELAY);
        end;
        if rctr > 2 * KEYLOOP then begin
          rctr := cCLEAR;
          RunMode := MODEOFF;             // restart system
          InitFlag := cOFF;               // enforce re-initialisation
          //nk// restart_prog                // make a cold-start (ALL DATA WILL BE INITIALIZED!!!);
        end;
      end;

      cKEYLEFT: begin                     // left - backlite on
        //nk// SetPower(PBACKLITE, cON);
        LiteFlag := cON;
      end;

      cKEYRIGHT: begin                    // right - backlite off
        //nk// SetPower[PBACKLITE, cOFF);
        LiteFlag := cOFF;
      end;

      cKEYDOWN: begin                     // down - open selection menu
        comm := cCLEAR;
      end;
    end;

    while (InitFlag = cINIT) and ((comm <> COMMEXIT)) do begin

      if (comm < COMMBACK) and (comm > last[level]) then begin
        level       := level + 1;
        last[level] := comm;
      end;

      case comm of  // select menu command
        59: begin                           // info: no data available!
          OpenMessage(0, 0, ICONINFO, TONESHORT, 3, knul, Mask[259], sEMPTY, sEMPTY);
          comm := COMMEXIT;
        end;

        58: begin                           // info: set clock
          SetGlobalData;
          OpenMessage(0, 0, ICONWAITING, 0, 0, knul, Mask[260], sEMPTY, sEMPTY);
          SetClock(RealYear, RealMonth, RealDay, RealHour, RealMin, RealSec);
          comm := COMMEXIT;
        end;

      // 38:  self test
      // 37:  software update
      // 36:  data export

         35:  OpenCalendar(comm);           // open calendar

      // 34:  OpenGasMixer(comm);
      // 33:  OpenPlanner(comm);            // open dive planner

        32:  OpenCatalog(comm, dive);       // open dive catalog
        132: OpenProfile(comm, dive);       // open dive profile

        31:  OpenCatalog(comm, dive);       // open dive catalog
        131: OpenLogbook(comm, dive);       // open log book

        // 03.06.07 nk change 2x and 3x - TIGER add new menue
        28:  OpenMenu(11, comm);            // open gas mixes
        27:  OpenMenu(10, comm);            // open clock
        26:  OpenMenu(9, comm);             // open display
        25:  OpenMenu(8, comm);             // open parameter
        24:  OpenMenu(7, comm);             // open warnings
        23:  OpenMenu(6, comm);             // open dive gases
        22:  OpenMenu(5, comm);             // open equipment
        21:  OpenMenu(4, comm);             // open person

        8: begin                            // shut down system
          kret := KEYWAIT;
          OpenMessage(0, 0, ICONQUESTION, TONERING, 0, kret, Mask[261], Mask[257], Mask[256]);
          if kret = cKEYLEFT then
            RunMode := MODEOFF;
      	  comm := COMMEXIT;
        end;

        7: begin                            // go to sleep mode
          kret := KEYWAIT;
          OpenMessage(0, 0, ICONQUESTION, TONERING, 0, kret, Mask[262], Mask[257], Mask[256]);
          if kret = cKEYLEFT then
            RunMode := MODESLEEP;
          comm := COMMEXIT;
        end;

        6: begin                            // cold start (re-initialize system)
          kret := KEYWAIT;
          OpenMessage(0, 0, ICONQUESTION, TONERING, 0, kret, Mask[263], Mask[257], Mask[256]);
          if kret = cKEYLEFT then begin
            RunMode := MODESTART;
          end;
      	  comm := COMMEXIT;
        end;
                                            // 03.06.07 nk change 4 and 5 TIGER
        5: OpenMenu(3, comm);               // open services menu

        4: OpenMenu(2, comm);               // open settings menu

        3: OpenMenu(1, comm);               // open gas selection

        2: begin
          if GlobalSet[0, 2, 2] <> cON then begin
            WinPos3 := WINSATURATION;       // open saturation window
            WinPos4 := WINNONE;
            GlobalSet[0, 2, 2] := cON;
          end else begin
            WinPos3 := WinPre3;             // open previous
            WinPos4 := WinPre4;             // shown windows
            GlobalSet[0, 2, 2] := cOFF;
          end;
          comm := COMMEXIT;
        end;

        1: begin
          if GlobalSet[0, 1, 2] <> cON then begin
            WinPos3 := WINNAVIGATION;       // open navigation window
            WinPos4 := WINNONE;
            GlobalSet[0, 1, 2] := cON;
          end else begin
            WinPos3 := WinPre3;             // open previous
            WinPos4 := WinPre4;             // shown windows
            GlobalSet[0, 1, 2] := cOFF;
          end;
          comm := COMMEXIT;
        end;

        0: begin
          OpenMenu(0, comm);                // open main selection menu
          if comm = COMMCLOSE then begin
            comm := COMMEXIT;
          end;
        end;

        COMMBACK: begin
          level := level - 1;
          comm := last[level];              // go back to last menu
        end;

        COMMSAVE: begin
          SetGlobalData;                    // set new global data in database
          comm := COMMEXIT;
        end;
      else
        comm := COMMEXIT;                   // invalid command
        dive := cCLEAR;
      end; // case

      dclear := cON;                        // clear and rebuild screen
      SigNum := SIGNONE;                    // 06.02.07 nk add clear all pending alarms

      // DELPHI: too fast (TIGER too??)
      if comm = COMMEXIT then kdel := 500;  // 500ms extra delay

    end; // while

    // **** program run control logic ****

    if RunMode = MODEOFF then begin    // shut down system
      OpenMessage(0, 0, ICONWAITING, 0, 0, knul, Mask[261], Mask[258], sEMPTY);
      SetRtcAlarm(RTCMAX);             // no automatic alarm wake-up
      LogEvent(TaskName[TASKGUI], 'Switch task', 'OFF');
      WaitDuration(TASKDELAY);         // wait until all tasks has stopped
      SetPower(PWRHOLD, cOFF);         // release hold pin - switch system off
    end;

    if RunMode = MODESLEEP then begin  // go to sleep mode
      OpenMessage(0, 0, ICONWAITING, 0, 0, knul, Mask[262], Mask[258], sEMPTY);
      GetRtcTime(ttemp);
      tbuff := IntToStr(ttemp);
      ttemp := ttemp + SEC_MIN;        // wake-up time (in 1 minute)  //nk//10min
      SetRtcAlarm(ttemp);              // automatic alarm wake-up
      LogEvent(TaskName[TASKGUI], 'Go to sleep at', tbuff);
      InitGui  := cOFF;
      InitFlag := cOFF;
      WaitDuration(TASKDELAY);         // wait until all tasks has stopped
      SetPower(PWRDISP, cOFF);         // switch display off
    end;

    if RunMode = MODESTART then begin  // cold start (re-initialize system)
      LogEvent(TaskName[TASKGUI], 'Switch task', 'OFF');
      OpenMessage(0, 0, ICONWAITING, 0, 0, knul, Mask[263], Mask[258], sEMPTY);
      WaitDuration(TASKDELAY);         // wait until all tasks has stopped
    end;
  end;  //while
end; // of GUI

// ------------------------------------------------------------------------------
// OPENMESSAGE - Open message window and show icon and text in dynamic boxes
// ------------------------------------------------------------------------------
// Xpos - X-pos of window: 1..LCDXRANGE,  0=middle of workspace
// Ypos - Y-pos of window: 1..LCDYRANGE,  0=middle of workspace
// Inum - Icon number: 1..MAXICONS,  0=no icon
// Tdur - Audio tone duration [*10ms],  0=no tone
// Ddel - Message show delay time [s],  0=limitless,  255=repeat tone sequence
// Knum - Return key code if Knum > KEYNONE, else ignore key pad
// Mhead - Head text lines (max 2*16 chars, no icon if empty!)
// Mbody - Body text lines (max 10*19 chars)
// Mtail - Tail text line (max 2*8 chars in one line)
// Important: Text lines must end with a new line delimiter NEW$
// ------------------------------------------------------------------ 19.10.05 --
procedure TGui.OpenMessage(Xpos, Ypos, Inum, Tdur, Ddel: Byte; var Knum: Byte; Mhead, Mbody, Mtail: string);
var
  ax, ay, bm, bx, by, dx, dy, fx, fy, lx, ly, ox, omax, wx, wy, ns, anum, win: Byte;
  mode, font, lnum, hnum, bnum, tnum, lmax, mlen, fpos, fdim, fcor: Byte;
  l, box, icon, tdel, tctr: Word;
  c: Char;
  sLine: array[0..MESSAGELINES] of string;
begin
  for l := 0 to MESSAGELINES - 1 do begin // clear temporary strings
    sLine[l] := sEMPTY;
  end;

  ox   := cCLEAR;
  lmax := cCLEAR;
  omax := cCLEAR;
  lnum := cCLEAR;
  hnum := cCLEAR;

  font := SMALLCHAR;               // character font = small
  mode := MIDPOS;                  // text position = middle
  win  := MAXWIN - 1;              // take pseudo window
  box  := MAXBOX - 1;              // take pseudo box
  tdel := Tdur;                    // audio tone duration [ms]

  fx := FontDef[font, 1];          // x-dim of font [dots]
  fy := FontDef[font, 2];          // y-dim of font [dots]
  ax := FontDef[font, 5];          // x-font space [dots]
  ay := 4;                         // y-font space [dots]

  bm := IconDef[0];                // number of icon bitmap file
  lx := IconDef[1];                // icon tabel length/LCDBYTE
  ly := IconDef[2];                // icon tabel height
  ns := IconDef[3];                // number of icons defined
  bx := IconDef[4];                // x-dim of icon [dots]
  by := IconDef[5];                // y-dim of icon [dots]

  mlen := Length(Mhead);           // header text length [char]

  // Tiger: Mhead(l-1)
  for l := 1 to mlen do begin
    c := Mhead[l];   // get next character
    if c = sNEWDEL then begin
      if ox > omax then omax := ox;
      ox   := 0;
      lnum := Limit(lnum + 1, 0, MESSAGELINES - 1);
      hnum := hnum + 1;
    end else begin
      anum := Ord(c);       // ascii number of character (A=65)
      GetFont(font, anum, fpos, fdim, fcor);
      ox := ox + fdim + ax;            // calc text width [dots]
      sLine[lnum] := sLine[lnum] + c;
    end;
  end;

  if (Inum = ICONNONE) or (Inum > ns) then begin // no or undefined icon
    bx := 0;
    by := 0;
    if Inum > ns then begin
      GraBuff := IntToStr(Inum);
      LogError('OpenMessage', 'Unsupported icon', GraBuff, $91);
    end;
  end else begin
    omax := omax + bx + 3;             // add icon x-dim and space
  end;

  lnum := 2;
  bnum := 0;
  ox   := 0;
  mlen := Length(Mbody);             // body text length [char]

  // Tiger: Mbody(l-1)
  for l := 1 to mlen do begin
    c := Mbody[l];   // get next character
    if c = sNEWDEL then begin
      if ox > omax then omax := ox;
      ox := 0;
      lnum := Limit(lnum + 1, 0, MESSAGELINES - 1);
      bnum := bnum + 1;
    end else begin
      anum := Ord(c);       // ascii number of character (A=65)
      GetFont(font, anum, fpos, fdim, fcor);
      ox := ox + fdim + ax;            // calc text width [dots]
      sLine[lnum] := sLine[lnum] + c;
    end;
  end;

  if (bx > 0) or (hnum > 0) then begin
    lmax := lnum;
  end else begin
    lmax := lnum - 2;
  end;

  lnum := MESSAGELINES - 2;
  tnum := 0;
  ox   := ax;
  mlen := Length(Mtail);   // tail text length [char]

  // Tiger: Mtail(l-1)
  for l := 1 to mlen do begin
    c := Mtail[l];     // get next character
    if c = sNEWDEL then begin
      if ox > omax then omax := ox;
      lnum := Limit(lnum + 1, 0, MESSAGELINES - 1);
      tnum := tnum + 1;
    end else begin
      anum := Ord(c);       // ascii number of character (A=65)
      GetFont(font, anum, fpos, fdim, fcor);
      ox := ox + fdim + ax;            // calc text width [dots]
      sLine[lnum] := sLine[lnum] + c;
    end;
  end;

  // calculate window dimension and position

  if tnum > 0 then lmax := lmax + 1;

  dx := 10 + omax + ax;                // window x-dim [dots]
  dx := Limit(dx, 0, LCDXRANGE);

  dy := 10 + lmax * (fy + ay);         // window y-dim [dots]
  dy := Limit(dy, 0, LCDYRANGE);

  if Xpos = 0 then begin             // window x-pos in the middle
    wx := (LCDXRANGE - dx) div 2;
  end else begin
    wx := Xpos;
  end;

  if Ypos = 0 then begin             // window y-pos in the middle
    wy := (LCDYRANGE - dy) div 2;
  end else begin
    wy := Ypos;
  end;

  WinSpec[win, 1] := wx;
  WinSpec[win, 2] := wy;
  WinSpec[win, 3] := dx;
  WinSpec[win, 4] := dy;
  WinSpec[win, 5] := 0;           // no special effect
  WinSpec[win, 6] := 0;           // window type

  // build message window with frame

  BoxSpec[box, 1] := win;         // pseudo window
  BoxSpec[box, 2] := 0;
  BoxSpec[box, 3] := 0;
  BoxSpec[box, 4] := dx;
  BoxSpec[box, 5] := dy;
  BoxSpec[box, 6] := 0;           // box type = normal (3 = shadow)
  BoxSpec[box, 7] := font;        // font type
  BoxSpec[box, 8] := 0;           // n/u
  BoxSpec[box, 9] := 0;           // black dots on white background

  // save actual screen layer and create new object
  SaveLcd(LCDLAYER_2);

  ClearBox(box);
  DrawBox(box);             // draw outer frame

  BoxSpec[box, 2] := 2;
  BoxSpec[box, 3] := 2;
  BoxSpec[box, 4] := dx - 4;
  BoxSpec[box, 5] := dy - 4;
  BoxSpec[box, 6] := 0;     // box type = normal

  DrawBox(box);             // draw inner frame

  SetDot(wx + 1, wy + 6, LCDDOTON, LCDPEN);    // draw corner posts
  SetDot(wx + 1, wy + dy - 7, LCDDOTON, LCDPEN);
  SetDot(wx + dx - 2, wy + 6, LCDDOTON, LCDPEN);
  SetDot(wx + dx - 2, wy + dy - 7, LCDDOTON, LCDPEN);

  SetDot(wx + 6, wy + 1, LCDDOTON, LCDPEN);
  SetDot(wx + 6, wy + dy - 2, LCDDOTON, LCDPEN);
  SetDot(wx + dx - 7, wy + 1, LCDDOTON, LCDPEN);
  SetDot(wx + dx - 7, wy + dy - 2, LCDDOTON, LCDPEN);

  // show icon in the upper left corner (if icon and head text are defined)

  if (bx > 0) and (hnum > 0) then begin
    icon := (bx + 1) * (Inum - 1) + 1; // icon pos in bitmap
    BoxSpec[box, 2] := 6;
    BoxSpec[box, 3] := 6;
    BoxSpec[box, 4] := bx;           // x-dim of icon
    BoxSpec[box, 5] := by;           // y-dim of icon
    BoxSpec[box, 6] := bm;           // icon bitmap file number
    BoxSpec[box, 7] := lx;           // x-dim of bitmap/LCDBYTE
    BoxSpec[box, 8] := ly;           // y-dim of bitmap
    bx := bx + 3;
    DispBitmap(box, icon, 1);
  end;

  BoxSpec[box, 6] := 0;              // box type = normal
  BoxSpec[box, 7] := font;           // font type
  BoxSpec[box, 8] := 0;              // n/u
  BoxSpec[box, 9] := 0;              // black dots on white background

  // disp header text lines

  if hnum > 2 then begin
    GraBuff := IntToStr(hnum);
    LogError('OpenMessage', 'Too many text lines', GraBuff, $98);
    hnum := 2; // cut text lines
  end;

  if hnum = 2 then begin          // two head lines
    for l := 0 to 1 do begin
      BoxSpec[box, 2] := 5 + bx;
      BoxSpec[box, 3] := 6 + l * (fy + ay);
      BoxSpec[box, 4] := dx - 10 - bx;
      BoxSpec[box, 5] := fy + 2;
      DispText(box, sLine[l], mode);
    end;
  end;

  if hnum = 1 then begin        // one head line in the middle
    BoxSpec[box, 2] := 5 + bx;
    BoxSpec[box, 3] := 11;
    BoxSpec[box, 4] := dx - 10 - bx;
    BoxSpec[box, 5] := fy + 2;
    DispText(box, sLine[0], mode);
    hnum := 2;
  end;

  // disp body text lines

  for l := 2 to bnum + 1 do begin
    BoxSpec[box, 2] := 4;
    BoxSpec[box, 3] := 7 + (hnum + l - 2) * (fy + ay);
    BoxSpec[box, 4] := dx - 8;
    BoxSpec[box, 5] := fy + 2;
    DispText(box, sLine[l], mode);
  end;

  // disp tail text lines

  if tnum = 2 then begin
    l := bnum + 2;
    BoxSpec[box, 2] := 4;
    BoxSpec[box, 3] := 7 + l* (fy + ay);
    BoxSpec[box, 4] := dx - 8;
    BoxSpec[box, 5] := fy + 2;
    BoxSpec[box, 6] := 0;           // box type = normal
    BoxSpec[box, 7] := font;        // font type
    BoxSpec[box, 8] := 0;           // n/u
    l := MESSAGELINES - 2;
    DispText(box, sLine[l], LEFTPOS);  // left position
    l := MESSAGELINES - 1;
    DispText(box, sLine[l], RIGHTPOS); // right position
  end;

  UpdateLcd;
  LoadLcd(LCDLAYER_2);  // restore original screen LCDLAYER_

  if tdel > 0 then begin   // make sound
    SetAudioTone(tdel);
  end else begin
    WaitDuration(KEYDELAY); // wait until window is open
  end;
  
  if Ddel > 0 then begin  // short time living message - close after showing
    WaitDuration(Ddel * MSEC_SEC);
    LoadLcd(LCDLAYER_2);
    UpdateLcd;
    Exit;
  end;

  if Knum > cKEYNONE then begin  // wait on any key - return key code
    tctr := cCLEAR;
    Knum := cKEYNONE;

    while (InitFlag = cINIT) do begin
      tctr := tctr + 1;

      WaitDuration(GUIDELAY div GUISPEEDUP); //DELPHI too slow

      GetKeyNum(Knum); // get number of depressed key

      if tctr > EXITLOOP then begin
        Knum := KEYEXIT;   // no key within timeout pressed
      end;

      if Knum <> cKEYNONE then begin
        UpdateLcd;
        WaitDuration(KEYDELAY); // wait until menu is closed
        Exit;
      end;

      if (tdel = TONEALARM) and (tctr mod TONELOOP = 0) then begin
        SetAudioTone(tdel); // alarm tone repetition
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// OPENMENU - Open menu window for value selections and parameter settings
// ------------------------------------------------------------------ 03.06.07 --
procedure TGui.OpenMenu(Amenu: Byte; var Comm: Word);       // TIGER use this sub!!
var
  k, tl, dl, pe, ps, hpos, kflag, knum, ttop, tuni, tnum, tinc: Byte;
  sym0, sym9, symp, hmin, hmax, toff, poff, voff, win, prec, null: Byte;
  v, hbox, tbox, pbox, vbox, tctr: Word;
  ye, mo, da, ho, mi, val, nop: Long;
  htext, dtext, ptext, pform, tform, tf: string;

  vact: array[0..SETBOX] of Long;
  vmin: array[0..SETBOX] of Long;
  vmax: array[0..SETBOX] of Long;
  vinc: array[0..SETBOX] of Long;
  vuni: array[0..SETBOX] of Byte;
begin
  win := BoxSpec[SETFIRST, 1];       // menu window number
  sym0 := GlobalSet[Amenu, 0, 1];    // header line symbol
  sym9 := GlobalSet[Amenu, 9, 1];    // tail line symbol
  symp := GlobalSet[Amenu, 0, 2];    // pointer symbol

  hmax := SETBOX - 1;                // number of boxs
  toff := SETFIRST;                  // 1st box number of text
  voff := toff + SETBOX;             // 1st box number of value
  poff := voff + SETBOX;             // 1st box number of pointer
  hbox := toff + hmax;               // box number for help text

  pe := cCLEAR;
  hmin := cCLEAR;
  tctr := cCLEAR;
  tinc := cOFF;

  SaveLcd(LCDLAYER_1);

  if Amenu = MENUCLOCK then begin                // time, date and alarm settings
    GetClock(nop, ye, mo, da, ho, mi, nop, nop); // get actual time and date

    GlobalSet[Amenu, 1, 0] :=  ye;           // year
    GlobalSet[Amenu, 2, 0] :=  mo;           // month
    GlobalSet[Amenu, 3, 0] :=  da;           // day
    GlobalSet[Amenu, 4, 0] :=  ho;           // hour
    GlobalSet[Amenu, 5, 0] :=  mi;           // minute
    GlobalSet[Amenu, 6, 0] :=  AlarmSet;     // alarm on/off
    GlobalSet[Amenu, 7, 0] :=  AlarmHour;    // alarm hour
    GlobalSet[Amenu, 8, 0] :=  AlarmMin;     // alarm minute

    if (ye mod 4 = 0) and (mo = 2) then begin
      dl := MonthDays[mo - 1] + 1;           // february of the leap year
    end else begin
      dl := MonthDays[mo - 1];               // last day in month [0 - 30]
    end;
    
    GlobalSet[Amenu, 3, 2] := dl;            // max value for day in actual month
  end;

  DisableTsw;                                // stop task switching while opening window

  for hpos := hmin to hmax do begin          // open menu window in 10% steps
    ttop := GlobalSet[Amenu, 0, 4] + hpos;   // end number of text (pointer to Mask$[])
    vact[hpos] := GlobalSet[Amenu, hpos, 0]; // actual value
    vmin[hpos] := GlobalSet[Amenu, hpos, 1]; // min value
    vmax[hpos] := GlobalSet[Amenu, hpos, 2]; // max value or on/off state
    vinc[hpos] := GlobalSet[Amenu, hpos, 3]; // incremental value
    vuni[hpos] := GlobalSet[Amenu, hpos, 4]; // unit system or text number
    tuni := vuni[hpos] + UnitFlag;           // unit system
    ptext := Mask[ttop];                     // setting text

    if Pos(sCARET, ptext) > 0 then begin     // show ON/OFF state
      htext := Mask[140 + vmax[hpos]];
      ptext := StringReplace(ptext, sCARET, htext, [rfReplaceAll]);
    end;

    if vinc[hpos] > SELTEXT then begin       // convert incremental value
      tinc := cON;
      vinc[hpos] := vinc[hpos] - SELTEXT;
    end else begin
      tinc := cOFF;
    end;

    if (tuni >= 2) and (tuni < 5) then begin
      val := vact[hpos];
      if TimeFlag = USA then begin   // american 12-hour time format
        GetUsTime(val, tf);          // change time format
        tform := sSPACE + tf + MF;   // AM/PM
        ptext := Mask[ttop] + tform;
      end else begin
        tform := sEMPTY;
      end;
    end;

    if (tuni = 9) and (DivePhase >= PHASEPREDIVE) then begin
      ptext := sEMPTY;      //03.06.07 nk add - hide selection while diving
      GlobalSet[Amenu, hpos, 0] := COMMFIX;
    end;

    if tuni >= UNITEXT then begin              // text, value and unit
      ptext := Mask[ttop] + Mask[tuni];

      if UnitFlag = cON then begin             // imperial unit system -> convert value
        prec := 0;
        ConvertValue(vact[hpos], prec, tuni);  // get precision value
        null := 0;
        ConvertValue(vmin[hpos], null, tuni);
        null := 0;
        ConvertValue(vmax[hpos], null, tuni);

        if tinc = cON then begin
          null := 0;
          ConvertValue(vinc[hpos], null, tuni);
        end;

        if prec >= cHALF then begin        // round up actual value
          vact[hpos] := vact[hpos] + 1;
        end;
      end;
    end;

    tbox := toff + hpos;
    vbox := voff + hpos;
    pbox := poff + hpos;

    ps := pe;
    pe := 10 * (hpos + 1) + 1;

    DispWindow(win, ps, pe);            // open partial window
    DispText(tbox, ptext, NORMPOS);     // disp text (with unit)

    if vinc[hpos] <> 0 then begin       // selection box (not a command box)
      if tuni <= 1 then begin
        val := vact[hpos];
        DispNumValue(vbox, val);        // unformated numerical value
      end;

      if (tuni >= 2) and (tuni < 5) then begin
        DispNumValue(vbox, val);        // value in 12h - format
      end;

      if (tuni >= SELTEXT) and (tuni < UNITEXT) then begin
        val := vact[hpos] + vuni[hpos] - SELTEXT;
        ptext := Trim(LeftStr(Help[val], 4));
        DispText(tbox, ptext, RIGHTPOS);  // short text value
      end;

      if (tuni = 232) or (tuni = 233) or (tuni = 254) then begin
        val := vact[hpos];                // do not convert 233 (1bar=1ata)
        FormatValue(tuni, val, ptext);
        DispText(tbox, ptext, RIGHTPOS);  // disp value on rigth side n.nn
      end else begin
        if (tuni >= UNITEXT) and (tuni < 254) then begin
          val := vact[hpos];
          DispNumValue(vbox, val);        // unformated numerical value
        end;
      end;

      if tuni = 255 then begin
        val := vact[hpos];                // [in]
        FormatValue(tuni, val, ptext);    // format in -> ft.in [fii]
        DispText(tbox, ptext, RIGHTPOS);  // disp value on rigth side [ft.in]
      end;
    end;

    case hpos of
      0: DispSymbol(pbox, sym0);    // arrow up
      1: DispSymbol(pbox, symp);    // pointer symbol
      9: begin
           DispSymbol(pbox, sym9);  // arrow down
           dtext := Mask[ttop];     // default help text
         end;
    end;

    UpdateLcd;        // next 10% step top down

    WaitDuration(20); // DELPHI: too fast
  end;
  
  EnableTsw;      // re-activate task switching

  hmin := 1;
  hmax := hmax - 1;
  hpos := hmin;
  pbox := poff + hmin;
  tnum := GlobalSet[Amenu, hpos, 4];     // text or format string value

  k := cCLEAR;
  knum := cKEYNONE;
  kflag := KEYMOVE;

  WaitDuration(KEYDELAY);  // wait until menu is open
  
  while (InitFlag = cINIT) do begin
    Comm := cCLEAR;

    WaitDuration(GUIDELAY div GUISPEEDUP); //DELPHI too slow

    GetKeyNum(knum);                  // get number of depressed key

    if knum = cKEYNONE then begin     // no key depressed -> do nothing
      k := cCLEAR;
    end else begin
      tctr := cCLEAR;                 // reset timeout counter if key pressed
      k := k + 1;                     // increment repetition delay counter
    end;

    if (k = 1) or (k > KEYREP) then begin      // 1st time a key was depressed
      case knum of
        cKEYUP: begin
          hpos := hpos - 1;                    // up key pressed
          Comm := GlobalSet[Amenu, hpos, 0];
          if Comm = COMMNOP then begin         // no operation defined
            hpos := hpos - 1;                  // - so go to next box
          end;
          if hpos < hmin then begin
            kflag := KEYBACK                   // close window and go back
          end else begin
            tnum := GlobalSet[Amenu, hpos, 4]; // text or format string value
            kflag := KEYMOVE;                  // move pointer up
          end;
        end;

        cKEYRIGHT: begin
          if vinc[hpos] = 0 then begin         // it's a command box
            Comm := GlobalSet[Amenu, hpos, 0]; // - so return command number
            if Comm = COMMFIX then begin       // not selectable value
              kflag := cKEYNONE;               // - so do nothing
            end else begin
              kflag := KEYBACK;                // close window and go back
            end;
          end else begin
            if vact[hpos] >= vmax[hpos] then begin
              vact[hpos] := vmin[hpos];        // overrun - go to min value
            end else begin
              vact[hpos] := vact[hpos] + vinc[hpos]; // right key pressed
            end;
            kflag := KEYTURN;
          end;
          if (Amenu = MENUDISP) and (hpos = 8) then begin
            Loudness := vact[hpos];  // TIGER set DigiPot
            SetAudioTone(100);
          end;
        end;

        cKEYDOWN: begin
          hpos := hpos + 1;                    // down key pressed
          Comm := GlobalSet[Amenu, hpos, 0];
          if Comm = COMMNOP then begin         // no operation defined
            hpos := hpos + 1;                  // - so go to next box
          end;
          if hpos > hmax then begin
            kflag := KEYBACK;                  // close window and go back
          end else begin
            tnum := GlobalSet[Amenu, hpos, 4]; // text or format string value
            kflag := KEYMOVE;                  // move pointer down
          end;
        end;

        cKEYLEFT: begin
          if vinc[hpos] = 0 then begin         // it's a command box
            Comm := GlobalSet[Amenu, hpos, 0]; // - so return command number
            if Comm = COMMFIX then begin       // not selectable value
              kflag := cKEYNONE;               // - so do nothing
            end else begin
              kflag := KEYBACK;                // close window and go back
            end;
          end else begin
            if vact[hpos] <= vmin[hpos] then begin
              vact[hpos] := vmax[hpos];        // underrun - go to max value
            end else begin
              vact[hpos] := vact[hpos] - vinc[hpos]; // left key pressed
            end;
            kflag := KEYTURN;
          end;
          if (Amenu = MENUDISP) and (hpos = 8) then begin
            Loudness := vact[hpos];  // TIGER set DigiPot
            SetAudioTone(100);
          end;
        end;
      end;  // case
    end;    // if key depressed

    tctr := tctr + 1;                      // increment timeout counter

    if tctr > EXITLOOP then begin          // timeout - > exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if PhaseFlag = cON then begin          // phase changed -> exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if kflag = KEYMOVE then begin
      ClearBox(hbox);
      ClearBox(pbox);
      tuni := tnum + UnitFlag;
      tbox := toff + hpos;
      pbox := poff + hpos;
      DispSymbol(pbox, symp);

      if (tuni >= SELTEXT) and (tuni < UNITEXT) then begin // show help text if available
        val := vact[hpos] + vuni[hpos] - SELTEXT;
        ptext := Trim(LeftStr(Help[val], 4));
        htext := Trim(Copy(Help[val], 6, 30));  // Tiger = mid$(5, 30)
        htext := ptext + sSPLIT + htext;
        DispText(hbox, htext, LEFTPOS);         // long text value (help text)
        DispText(tbox, ptext, RIGHTPOS);        // short text value
      end else begin
        DispText(hbox, dtext, RIGHTPOS);        // alternate help text (default=CLOSE)
      end;
    end;

    if kflag = KEYTURN then  begin
      tuni := tnum + UnitFlag;
      tbox := toff + hpos;
      vbox := voff + hpos;

      if Amenu = MENUCLOCK then begin          // new month is selected
        if (vact[1] mod 4 = 0) and (vact[2] = 2) then  begin
          dl := MonthDays[vact[2] - 1] + 1;    // february of the leap year
        end else begin
          dl := MonthDays[vact[2] - 1];        // last day in month (0-30)
        end;

        vmax[3] := dl;

        if vact[3] > vmax[3] then begin
          vact[3] := vmax[3];
          v := voff + 3;
          val := vact[3];
          ClearBox(v);
          DispNumValue(v, val);                // correct day
        end;
      end;

      ClearBox(hbox);
      ClearBox(vbox);

      if tuni <= 1 then begin
        val := vact[hpos];
        DispNumValue(vbox, val);               // unformated numerical value
      end;

      if (tuni >= 2) and (tuni < 5) then begin
        val := vact[hpos];
        if TimeFlag = USA then begin             // american 12-hour time format
          ttop := GlobalSet[Amenu, 0, 4] + hpos; // number of text
          GetUsTime(val, tf);                    // change time format
          tform := sSPACE + tf + MF;             // AM/PM
          ptext := Mask[ttop] + tform;
          DispText(tbox, ptext, NORMPOS);        // disp text (with time format)
        end;
        DispNumValue(vbox, val);
      end;

      if (tuni >= SELTEXT) and (tuni < UNITEXT) then begin
        val := vact[hpos] + vuni[hpos] - SELTEXT;
        ptext := Trim(LeftStr(Help[val], 4));
        htext := Trim(Copy(Help[val], 6, 30)); // Tiger = mid$(5, 30)
        htext := ptext + sSPLIT + htext;
        DispText(hbox, htext, LEFTPOS);        // long text value (help text)
        DispText(tbox, ptext, RIGHTPOS);       // short text value
      end;

      if (tuni = 232) or (tuni = 233) or (tuni = 254) then begin
        val := vact[hpos];                     // do not convert 233 (1bar=1ata)
        FormatValue(tuni, val, ptext);
        DispText(tbox, ptext, RIGHTPOS);       // disp value on rigth side n.nn
      end else begin
        if (tuni >= UNITEXT) and (tuni < 254) then begin
          val := vact[hpos];
          DispNumValue(vbox, val);             // unformated numerical value
        end;
      end;

      if tuni = 255 then begin
        val := vact[hpos];                     // [in]
        FormatValue(tuni, val, ptext);         // format in -> ft.in [fii]
        DispText(tbox, ptext, RIGHTPOS);       // disp value on rigth side [ft.in]
      end;

      if Amenu = MENUDISP then begin           // set brightness and contrast
        if hpos = 5 then Brightness := vact[hpos];
        if hpos = 6 then Contrast := vact[hpos];
      end;
    end;

    if kflag = KEYBACK then begin
      for hpos := hmin to hmax do begin        // restore
        tuni := vuni[hpos];                    // unit system

        if (UnitFlag = cON) and (tuni >= UNITEXT) then begin  // imperial unit system -> re-convert value
          prec := 0;                                          // to metrical unit system
          ConvertValue(vact[hpos], prec, tuni);               // get precision value
          if prec > cHALF then begin
            vact[hpos] := vact[hpos] + 1;                     // round up
          end;
        end;

        GlobalSet[Amenu, hpos, 0] := vact[hpos];              // save actual value and
      end;

      LoadLcd(LCDLAYER_1);
      UpdateLcd;                           // close menu window
      Exit;                                // and go back to caller
    end;

    if kflag <> cKEYNONE then begin
      if ObjFlag = cON then begin
        ObjFlag := cNEW;
      end else begin
        UpdateLcd;                         // refresh display screen
      end;
      kflag := cKEYNONE;
    end;

    CheckSignal;                           // open message window if required

  end; //while
end;

// ------------------------------------------------------------------------------
// OPENCALENDAR - Open calendar window with day table and moon phase symbol
// ------------------------------------------------------------------ 17.02.07 --
procedure TGui.OpenCalendar(var Comm: Word);   //TIGER use this sub
var
  d, k, x, y, dx, dy, xs, ys, ox, oy, fd, dl, mp: Byte;
  hd, hmin, hmax, hpos, knum, kflag, wopen: Byte;
  yl, pbox, val, tctr: Word;
  ad, aw, td, wd, fwd, ye, mo, da, nop: Long;
  ptext: string;
begin
  ox := BoxSpec[105, 2];   // x pos of day frame
  oy := BoxSpec[105, 3];   // y pos of day frame

  SaveLcd(LCDLAYER_1);
  GetClock(nop, ye, mo, da, nop, nop, nop, nop);

  DispWindow(8, 0, 100);   // open calendar window
  ClearBox(119);           // clear day table

  DispText(100, Mask[150], NORMPOS);  // disp header text
  DispText(113, Mask[189], NORMPOS);  // disp tail text

  DispSymbol(114, 11);     // arrow up
  DispSymbol(115, 12);     // arrow down
  DispSymbol(116, 16);     // pointer symbol

  // build weekday header line

  xs := BoxSpec[103, 2];   // x pos of weekday box
  dx := BoxSpec[103, 4];   // x dim of weekday box

  for x := 0 to DAY_WEEK - 1 do begin
    BoxSpec[103, 2] := xs + x * (dx + 3);
    DispText(103, Mask[(DAYSHORT + x)], NORMPOS); // disp mo..su as text
  end;

  BoxSpec[103, 2] := xs;   // restore original box specifications

  UpdateLcd;

  dl := cCLEAR;
  tctr := cCLEAR;
  hmin := cCLEAR;
  hmax := 2;      // number of boxs (-1);
  hpos := cCLEAR;
  pbox := 116 + hpos;

  k := cCLEAR;
  wopen := cOFF;
  knum := cKEYNONE;
  kflag := KEYINIT;

  while (InitFlag = cINIT) do begin
    Comm := cCLEAR;

    WaitDuration(GUIDELAY div GUISPEEDUP); //DELPHI too slow

    if kflag <> KEYINIT then begin
      GetKeyNum(knum);    // get number of depressed key
    end;

    if knum = cKEYNONE then begin  // no key depressed -> do nothing
      k := cCLEAR;
    end else begin
      tctr := cCLEAR;   // reset timeout counter if key pressed
      k := k + 1;       // increment repetition delay counter
    end;

    if (k = 1) or (k > KEYREP) then begin // 1st time a key was depressed

      case knum of
        cKEYUP: begin  // up key pressed
          if hpos = hmin then begin
            Comm := COMMBACK;
            kflag := KEYBACK;
          end else begin
            hpos := hpos - 1;
            kflag := KEYMOVE;
          end;
        end;

        cKEYRIGHT: begin  // right key pressed
          if hpos = 0 then begin
            if da = dl + 1 then begin  // select day
              da := 1;
              if mo = MONTH_YEAR then begin
                mo := 1;
                if ye = MAXYEARS - 1 then begin
                  ye := cCLEAR;
                end else begin
                  ye := ye + 1;
                end;
              end else begin
                mo := mo + 1;
              end;
              kflag := KEYINIT;
            end else begin
              da := da + 1;
              kflag := KEYTURN;
            end;
          end;
          if hpos = 1 then begin
            if mo = MONTH_YEAR then begin // select month
              mo := 1;
              if ye = MAXYEARS - 1 then begin
                ye := cCLEAR;
              end else begin
                ye := ye + 1;
              end;
            end else begin
              mo := mo + 1;
            end;
            da := 1;
            kflag := KEYINIT;
          end;
          if hpos = 2 then begin
            if ye = MAXYEARS - 1 then begin // select year
              ye := cCLEAR;
            end else begin
              ye := ye + 1;
            end;
            da := 1;
            mo := 1;
            kflag := KEYINIT;
          end;
        end;

        cKEYDOWN: begin  // down key pressed
          if hpos = hmax then begin
            Comm := COMMEXIT;
            kflag := KEYBACK;
          end else begin
            hpos := hpos + 1;
            kflag := KEYMOVE;
          end;
        end;

        cKEYLEFT: begin  // left key pressed
          if hpos = 0 then begin
            if da = 1 then begin  // select day
              if mo = 1 then begin
                mo := MONTH_YEAR;
                if ye = 0 then begin
                  ye := MAXYEARS - 1;
                end else begin
                  ye := ye - 1;
                end;
              end else begin
                mo := mo-1;
              end;
              if (ye mod 4 = 0) and (mo = 2) then begin
                dl := MonthDays[mo - 1];     // february of the leap year
              end else begin
                dl := MonthDays[mo - 1] - 1; // last day in month (0-30);
              end;
              da := dl + 1;
              kflag := KEYINIT;
            end else begin
              da := da - 1;
              kflag := KEYTURN;
            end;
          end;
          if hpos = 1 then begin
            if mo = 1 then begin // select month
              mo := MONTH_YEAR;
              if ye = 0 then begin
                ye := MAXYEARS - 1;
              end else begin
                ye := ye - 1;
              end;
            end else begin
              mo := mo - 1;
            end;
            da := 1;
            kflag := KEYINIT;
          end;
          if hpos = 2 then begin  // select year
            if ye = 0 then begin
              ye := MAXYEARS - 1;
            end else begin
              ye := ye - 1;
            end;
            da := 1;
            mo := 1;
            kflag := KEYINIT;
          end;
        end;
      end;  // case
    end;  // if

    tctr := tctr + 1;  // increment timeout counter

    if tctr > EXITLOOP then begin  // timeout -> exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if PhaseFlag = cON then begin  // phase changed -> exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if kflag = KEYMOVE then begin
      ClearBox(pbox);
      pbox := 116 + hpos;
      DispSymbol(pbox, 16);
    end;

    if kflag = KEYINIT then begin
      if (ye mod 4 = 0) and (mo = 2) then begin
        dl := MonthDays[mo - 1];      // february of the leap year
      end else begin
        dl := MonthDays[mo - 1] - 1;  // last day in month (0-30);
      end;

      GetTotalDays(td, ad, aw, fwd, ye, mo, 1);  // first weekday of the month

      // build calendar days table

      xs := BoxSpec[104, 2];  // x pos of day box
      ys := BoxSpec[104, 3];  // y pos of day box
      dx := BoxSpec[104, 4];  // x dim of day box
      dy := BoxSpec[104, 5];  // y dim of day box

      val := cCLEAR;

      for d := 0 to CALENDARDIM do begin
        x := d mod DAY_WEEK;
        y := d div DAY_WEEK;

        BoxSpec[104, 2] := xs + x * (dx + 3);
        BoxSpec[104, 3] := ys + y * (dy + 1);

        if (d >= fwd) and (d <= dl + fwd) then begin  // day between 1st and last of month
          val := val + 1;

          GetHoliday(ye, mo, val, hd);     // look if day is a holiday

          if hd <> MAXHOLI then begin      // it's a holyday, so
            BoxSpec[104, 9] := LCDDOTNEG;  // draw day box inverse
          end else begin
            BoxSpec[104, 9] := LCDDOTON;
          end;
          ClearBox(104);
          DispNumValue(104, val);
        end else begin
          BoxSpec[104, 9] := LCDDOTON;
          ClearBox(104);
        end; // if
      end; // for

      BoxSpec[104, 2] := xs;  // restore original box specifications
      BoxSpec[104, 3] := ys;
      BoxSpec[104, 9] := LCDDOTON;
    end;  // if

    if (kflag = KEYTURN) or (kflag = KEYINIT) then begin
      xs := BoxSpec[105, 2];  // x pos of day frame
      ys := BoxSpec[105, 3];  // y pos of day frame
      dx := BoxSpec[105, 4];  // x dim of day frame
      dy := BoxSpec[105, 5];  // y dim of day frame

      d := da + fwd - 1;
      x := d mod DAY_WEEK;
      y := d div DAY_WEEK;

      BoxSpec[105, 2] := ox;
      BoxSpec[105, 3] := oy;
      BoxSpec[105, 9] := LCDDOTOFF;

      GetTotalDays(td, ad, aw, wd, ye, mo, da);  // weekday of the given date
      GetMoonPhase(mp, td);                      // phase of the moon
      GetHoliday(ye, mo, da, hd);                // look if day is a holiday

      if hd <> MAXHOLI then begin                // it's a holyday, so
        ptext := Mask[(HOLTEXT + hd)];  // disp name of holiday as text
      end else begin
        ptext := Mask[(DAYLONG + wd)];  // disp name of weekday
      end;

      ClearBox(101);
      DispText(101, ptext, NORMPOS);    // disp weekday or holiday as text

      yl := FIRSTYEAR + ye;

      if TimeFlag = USA then begin   // US time format    //Tiger no space before IntToStr
        ptext := Mask[(150 + mo)] + sSPACE + IntToStr(da) + sDOT + sSPACE + IntToStr(yl);
      end else begin                 // ISO and EU time format
        ptext := IntToStr(da) + sDOT + sSPACE + Mask[(150 + mo)] + sSPACE + IntToStr(yl);
      end;

      ClearBox(102);
      DispText(102, ptext, NORMPOS);  // disp day, month and year as text

      ClearBox(106);                  // disp number of actual day in this year
      DispText(106, Mask[187] + IntToStr(ad), NORMPOS);

      ClearBox(108);                  // disp number of actual week in this year
      DispText(108, Mask[188] + IntToStr(aw), NORMPOS);

      ClearBox(110);
      DispSymbol(110, mp + MOONSYMBOL); // disp graphical moon phase for this day

      DrawBox(105); // clear the frame around the old day

      ox := xs + x * (dx + 1);
      oy := ys + y * (dy - 1);
      BoxSpec[105, 2] := ox;
      BoxSpec[105, 3] := oy;
      BoxSpec[105, 9] := LCDDOTON;

      DrawBox(105);  // draw a frame around the actual day

      BoxSpec[105, 2] := xs;  // restore original box specifications
      BoxSpec[105, 3] := ys;
    end;  // if

    if kflag = KEYBACK then begin
      LoadLcd(LCDLAYER_1);
      UpdateLcd;   // close menu window
      Exit;        // and go back to caller
    end;

    if kflag <> cKEYNONE then begin
      if ObjFlag = cON then begin
        ObjFlag := cNEW;
      end else begin
        UpdateLcd;   // refresh display screen
        if wopen = cOFF then begin
          WaitDuration(KEYDELAY);  // wait until window is open
        end;
        wopen := cON;
      end;
      kflag := cKEYNONE;
    end;

    CheckSignal;  // open message window if required

  end; // while
end;

// ------------------------------------------------------------------------------
// OPENPROFILE - Open dive profile window to show time/depth diagram of dive
// ------------------------------------------------------------------ 02.06.07 --
procedure TGui.OpenProfile(var Comm, Dive: Word); // TIGER replace this sub  !!
var
  i, k, bx, by, dx, dy, px, py, wx, wy: Byte;
  hmin, hmax, hpos, knum, kflag, prec, tuni: Byte;
  ye, mo, da, ho, mi, wd, nop, tctr, lsig: Word;
  dcat, dmax, pbox, sbox, lpoint: Word;
  drange, dscale, ddiv, trange, tscale, tdiv: Long;
  sval, lval, dtime: Long;
  tf, ptext, stime, sdate, smon, sday, lday: string;
label
  LOADDIVE;
begin
  wx := WinSpec[9, 1];
  wy := WinSpec[9, 2];
  bx := BoxSpec[180, 2] + 1;
  by := BoxSpec[180, 3];
  dx := BoxSpec[180, 4];
  dy := BoxSpec[180, 5];

  pbox := 174;
  dcat := 0;                    // number of dive in catalog (1..dmax)
  dmax := DiveCatalog[0, 4];    // last dive catalog number

  SaveLcd(LCDLAYER_1);

LOADDIVE:
  SigNum := SIGNONE;                  // clear all pending alarms
  DispWindow(9, 0, 100);              // open profile window
  DispText(170, Mask[190], NORMPOS);  // disp header text
  DispText(173, Mask[196], MIDPOS);   // disp 'load data...'

  DispSymbol(171, 11);  // arrow up
  DispSymbol(172, 12);  // arrow down
  DispSymbol(pbox, 16); // pointer symbol

  DrawLine(186);  // horizontal top line
  DrawLine(187);  // x scale axis
  DrawLine(188);  // x scale ticks
  DrawLine(189);  // y scale axis
  DrawLine(190);  // y scale ticks
  DrawLine(198);  // horizontal bottom line

  if dcat > 0 then begin
    Dive := DiveCatalog[dcat, 5]; //get dive log number from catalog number
  end;
                         // load dive data from flash into 'DiveProfile' array
  LoadDiveProfile(Dive); // the meaning of 'Dive' has changed!
                         // its now the dive number in the DiveCatalog

  dcat := Dive;          // actual dive catalog number (1..dmax)

  if dcat = 0 then begin
    LogError('OpenProfile', 'No data found in dive log', IntToStr(dcat), $A2);
    Comm := COMMNODATA;
    LoadLcd(LCDLAYER_1);
    UpdateLcd;           // close profile window
    Exit;
  end;

  // start day, date, time & dive of the day [WD DD.MM.YY hh:mmA/P-N]
  dtime := HIGHWORD * DiveCatalog[dcat, 3] + DiveCatalog[dcat, 4]; // start date & time [s]
  FormatTimeDate(dtime, stime, sdate, smon, sday, lday, tf);       // get time and date as string
  tf    := LowerCase(tf);
  ptext := sday + sSPACE + sdate + sSPACE + stime + tf + sSLASH + IntToStr(DiveCatalog[dcat, 6]);

  ClearBox(173);
  DispText(173, Mask[199], NORMPOS);                      // disp tail text (close)
  DispText(175, ptext, NORMPOS);
  DispText(176, IntToStr(DiveCatalog[dcat, 5]), NORMPOS); // actual dive log number
  DispText(178, Mask[195], NORMPOS);                      // dive time unit [MIN]

  UpdateLcd;

  if UnitFlag = cOFF then begin
    tf := Mask[246];
    DispSymbol(177, 13);  // dive depth metrical symbol [M]
  end else begin
    tf := Mask[247];
    DispSymbol(177, 14);  // dive depth imperial symbol [Ft]
  end;

  // dive time 'mmm.m' or 'hh:mm'
  FormatValue(223, DiveCatalog[dcat, 0], ptext);
  DispText(195, Mask[195] + sCOLON + ptext, NORMPOS);

  // max depth 'nnn.n' [m/ft]
  tuni := 246 + UnitFlag;  //02.06.07 nk opt ff
  FormatValue(tuni, DiveCatalog[dcat, 1], ptext);
  DispText(196, tf + sCOLON + ptext, NORMPOS);

  // find optimal depth range [m]
  drange := LOGDEPTHRANGE;
  lval := DiveCatalog[dcat, 1];  // max dive depth [cm]

  for i := 1 to LOGDEPTHRANGE do begin
    if lval < i * (LOGDEPTHSCALE + 1) * CENTI then begin
      drange := i;
      Break;
    end;
  end;

  dscale := LOGDEPTHSTART * drange;  // depth scaling
  ddiv   := dscale * CENTI div 10;   // depth divider for scaling

  for i := 0 to 4 do begin
    sbox := 181 + i;
    sval := (i + 1) * dscale;        // first depth label and label interval
    if UnitFlag = cON then begin
      prec := 0;
      ConvertValue(sval, prec, 247); // convert m -> feet
    end;
    ClearBox(sbox);
    DispText(sbox, IntToStr(sval), NORMPOS);
  end;

  // find optimal time range [min]
  trange := LOGTIMERANGE;
  ExpandTime(DiveCatalog[dcat, 0], lval); // max log time [s/min]

  for i := 1 to LOGTIMERANGE do begin
    if lval < i * (LOGTIMESCALE + 1) * SEC_MIN then begin
      trange := i;
      Break;
    end;
  end;

  tscale := LOGTIMESTART * trange;  // time scaling
  tdiv := tscale * SEC_MIN div 10;  // time divider for scaling

  for i := 0 to 3 do begin
    sbox := 191 + i;
    sval := tscale + 2 * tscale * i; // first time label and label interval
    ClearBox(sbox);
    DispText(sbox, IntToStr(sval), NORMPOS); // label time scale [min]
  end;

  px := wx + bx - 1;                // start point = 0,0
  py := wy + by + 1;

  ClearBox(180);                    // clear dive profile chart
  DrawLineFrom(px, py, LCDDOTON);

  lpoint := cCLEAR;
  GetNextDivePoint(lpoint, cOFF);   // get 1st dive point

  while (lpoint > 0) do begin       // 0=end of profile reached
    ExpandTime(DiveProfile[lpoint, 1], sval); // logged dive time [s/min]
    px   := sval div tdiv;          // x-value time (s -> min)
    sval := DiveProfile[lpoint, 2]; // logged dive depth [cm]
    py   := sval div ddiv + 1;      // y-value depth (cm -> m)
    DrawLineTo(px, py, dx, dy);     // draw to next dive point
    GetNextDivePoint(lpoint, cOFF);
  end;

  UpdateLcd;

  Profile.DrawDiveProfile;  // DELPHI - draw dive profile and track
  Track.DrawDiveTrack;      // 13.05.07 nk add

  hmin := 0;
  hmax := 1;
  hpos := 0;

  k      := cCLEAR;
  knum   := cKEYNONE;
  kflag  := KEYINIT;
  tctr   := cCLEAR;
  lpoint := cCLEAR;

  while (InitFlag = cINIT) do begin
    Comm := cCLEAR;

    WaitDuration(GUIDELAY div GUISPEEDUP); //DELPHI too slow

    if kflag <> KEYINIT then begin
      GetKeyNum(knum);                 // get number of depressed key
    end;

    if knum = cKEYNONE then begin      // no key depressed -> do nothing
      k := cCLEAR;
    end else begin
      tctr := cCLEAR;                  // reset timeout counter if key pressed
      k := k + 1;                      // increment repetition delay counter
    end;

    if (k = 1) or (k > KEYREP) then begin  // 1st time a key was depressed
      case knum of
        cKEYUP: begin                      // up key pressed
          if hpos = hmin then begin
            Comm  := COMMBACK;
            kflag := KEYBACK;
          end else begin
            hpos  := hpos - 1;
            kflag := KEYMOVE;
          end;
        end;

        cKEYRIGHT: begin                   // right key pressed
          if hpos = hmin then begin
            if dcat < dmax then begin
              dcat := dcat + 1;            // show next dive profile
            end else begin
              dcat := 1;
            end;
          end;
          if hpos = hmax then begin
            GetNextDivePoint(lpoint, cON);
          end;
          kflag := KEYTURN;
        end;

        cKEYDOWN: begin                    // down key pressed
          if hpos = hmax then begin
            Comm  := COMMEXIT;
            kflag := KEYBACK;
          end else begin
            hpos  := hpos + 1;
            kflag := KEYMOVE;
          end;
        end;

        cKEYLEFT: begin                    // left key pressed
          if hpos = hmin then begin
            if dcat > 1 then begin
              dcat := dcat - 1;            // show previous dive profile
            end else begin
              dcat := dmax;
            end;
          end;
          if hpos = hmax then begin
            GetPrevDivePoint(lpoint, cON);
          end;
          kflag := KEYTURN;
        end;
      end;  // case
    end;    // if key pressed

    tctr := tctr + 1;                      // increment timeout counter

    if tctr > EXITLOOP then begin          // timeout -> exit sub
      Comm  := COMMEXIT;
      kflag := KEYBACK;
    end;

    if PhaseFlag = cON then begin          // phase changed -> exit sub
      Comm  := COMMEXIT;
      kflag := KEYBACK;
    end;

    if kflag = KEYINIT then begin
      WaitDuration(KEYDELAY);              // wait until dive profile is open
    end;

    if kflag = KEYMOVE then begin
      if hpos = hmin then begin
        LoadLcd(LCDLAYER_3);               // clear cursor
        ClearBox(pbox);
        pbox := 174;
        DispSymbol(pbox, 16);
      end;

      if hpos = hmax then begin;
        ClearBox(pbox);
        pbox := 179;
        DispSymbol(pbox, 16);
        SaveLcd(LCDLAYER_3);
      end;
      UpdateLcd;
    end;

    if kflag = KEYTURN then begin
      if hpos = hmin then goto LOADDIVE;   // load next/prev dive profile

      if hpos = hmax then begin            // move cursor to dive point
        LoadLcd(LCDLAYER_3);
        ClearBox(195);
        ClearBox(196);
        ClearBox(197);

        lsig := DiveProfile[lpoint, 0];
        if lsig > 0 then begin             // check status word
          DispSymbol(197, 36);             // warning/alarm symbol
          GetSigNum(lsig, SigNum);         // set highest signal number
          ObjFlag := cNEW;                 // force message to open silent
        end else begin
          ObjFlag := cCLOSE;
        end;

        sval := DiveProfile[lpoint, 1];    // logged dive time [s]
        FormatValue(223, sval, ptext);     // dive time 'mmm.m' or 'hh:mm'
        DispText(195, Mask[195] + sCOLON + ptext, NORMPOS);
        ExpandTime(DiveProfile[lpoint, 1], sval);
        px := sval div tdiv;               // x-value time (s -> min)

        sval := DiveProfile[lpoint, 2];    // logged dive depth [cm]
        tuni := 246 + UnitFlag;            //02.06.07 nk opt ff
        FormatValue(tuni, sval, ptext);    // max depth 'nnn.n' [m/ft]
        DispText(196, tf + sCOLON + ptext, NORMPOS);
        py := sval div ddiv + 1;           // y-value depth (cm -> m)
        px := Limit(px, 0, dx);            // limit diagram boundries
        py := Limit(py, 0, dy);            // add 1 pixel for 0m offset

        BoxSpec[199, 2] := bx + px;
        BoxSpec[199, 3] := by + py + 1;
        DispSymbol(199, 37);               // show cursor pointer
        UpdateLcd;
      end;
    end;

    if kflag = KEYBACK then begin
      LoadLcd(LCDLAYER_1);
      UpdateLcd;                           // close menu window
      Exit;                                // and go back to caller
    end;

    if kflag <> cKEYNONE then begin
      if ObjFlag = cON then begin
        ObjFlag := cNEW;
      end else begin
        UpdateLcd;                         // refresh display screen
      end;
      kflag := cKEYNONE;
    end;

    CheckSignal;                           // open message window if required

  end; // while
end;

// ------------------------------------------------------------------------------
// OPENLOGBOOK - Open log book window to show all dive data of saved dives
// ------------------------------------------------------------------ 13.05.07 --
procedure TGui.OpenLogbook(var Comm, Dive: Word);  // TIGER use this sub
var
  k, ys, yp, yinc, lpage, ldat, lpos: Byte;
  hmin, hmax, hpos, knum, kflag, tuni: Byte;
  ye, mo, da, ho, mi, wd, nop, vdat: Word;
  dcat, dmax, lval, dbox, pbox, tbox: Word;
  tctr, sval, lpoint, ldive, dtime, upos: Long;
  tf, ptext, utext, vtext, pform, stime, sdate, smon, sday, lday: string;
label
  LOADDIVE, NEXTPAGE;
begin
  hmax := DIVELINES;         // number of log book lines
  pbox := 174;               // 1st pointer box
  dbox := 200;               // 1st box number of dive parameter
  yinc := 8;                 // y box increment (1..10)
  ys   := BoxSpec[dbox, 3];  // y pos of 1st log book box
  yp   := BoxSpec[pbox, 3];  // y pos of 1st pointer box
  dcat := 0;                 // number of dive in catalog (1..dmax)
  dmax := DiveCatalog[0, 4]; // last dive catalog number

  SaveLcd(LCDLAYER_1);

LOADDIVE:
  DispWindow(9, 0, 100);              // open logbook window
  DispText(170, Mask[191], NORMPOS);  // disp header text
  DispText(173, Mask[196], MIDPOS);   // disp 'load data...'

  DispSymbol(171, 11);   // arrow up
  DispSymbol(172, 12);   // arrow down
  DispSymbol(pbox, 16);  // pointer symbol
  DrawLine(186);         // horizontal top line

  if dcat > 0 then begin
    Dive := DiveCatalog[dcat, 5];  //get dive log number from catalog number
  end;
                         // load dive data from flash into 'DiveData' array
  LoadDiveData(Dive);    // the meaning of 'Dive' has changed!
                         // its now the dive number in the DiveCatalog

  dcat := Dive;          // actual dive catalog number (1..dmax)

  if dcat = 0 then begin
    LogError('OpenLogbook', 'No data found in dive log', IntToStr(dcat), $A2);
    Comm := COMMNODATA;
    LoadLcd(LCDLAYER_1);
    UpdateLcd;           // close logbook window
    Exit;
  end;

  // start day, date, time & dive of the day [WD DD.MM.YY hh:mmA/P-N]
  dtime := HIGHWORD * DiveCatalog[dcat, 3] + DiveCatalog[dcat, 4]; // start date & time [s]
  FormatTimeDate(dtime, stime, sdate, smon, sday, lday, tf);       // get time and date as string
  tf    := LowerCase(tf);
  ptext := sday + sSPACE + sdate + sSPACE + stime + tf + sSLASH + IntToStr(DiveCatalog[dcat, 6]);

  ClearBox(173);
  DispText(173, Mask[199], NORMPOS);  // disp tail text (close)
  DispText(175, ptext, NORMPOS);
  DispText(176, IntToStr(DiveCatalog[dcat, 5]), NORMPOS);  // actual dive log number

  hmin  := 0;
  hpos  := 0;
  k     := cCLEAR;
  knum  := cKEYNONE;
  kflag := KEYINIT;
  tctr  := cCLEAR;
  lpage := 1;

NEXTPAGE: // format new page of log book
  ptext := IntToStr(lpage) + sSLASH + IntToStr(LOGPAGES); // Tiger w/o space
  ClearBox(173);
  DispText(173, Mask[199], NORMPOS);                  // disp tail text (close)
  DispText(173, Mask[197] + sSPACE + ptext, LEFTPOS); // disp page n/m

  for lpos := 0 to DIVELINES - 1 do begin
    BoxSpec[dbox,     3] := ys + lpos * yinc;
    BoxSpec[dbox + 1, 3] := ys + lpos * yinc;

    ldat  := (lpage - 1) * DIVELINES + lpos; // log book parameter 0..39
    vdat  := DiveData[ldat];
    ptext := Mask[300 + ldat];               // log book parameter and unit text
    upos  := Pos(sATSIGN, ptext);            // 05.05.07 nk TIGER upos = instr(ATSIGN$, ptext$, 0, 4)

    if upos > 0 then begin                   // format unit and make converion
      utext := RightStr(ptext, 3);           // cut unit code
      tuni  := StrToInt(utext);

      if tuni >= UNITEXT then begin          // unit (not time) conversion
      //nk//  tuni := tuni + UnitFlag;       // depending on UnitFlag
        if lpage > 2 then  //nk// test
          tuni := tuni + 1;  //imperial
      end;

      FormatValue(tuni, vdat, vtext);
      ptext := LeftStr(ptext, upos - 2);     // cut parameter text

      if pos(TIMESEP, vtext) = 0 then begin  // time format hh:mm w/o unit text
        ptext := ptext + Mask[tuni];
      end;
    end else begin
      vtext := IntToStr(vdat);
    end;

    ClearBox(dbox);
    DispText(dbox, ptext, NORMPOS);          // disp parameter and unit
    ClearBox(dbox + 1);
    DispText(dbox + 1, vtext, NORMPOS);      // disp value
  end;

  UpdateLcd;

  if kflag = KEYINIT then begin
    WaitDuration(KEYDELAY);                  // wait until log book is open
  end;

  while InitFlag = cINIT do begin
    Comm := cCLEAR;

    WaitDuration(GUIDELAY div GUISPEEDUP);   //DELPHI too slow

    if kflag <> KEYINIT then begin
      GetKeyNum(knum);                       // get number of depressed key
    end;

    if knum = cKEYNONE then begin            // no key depressed -> do nothing
      k := cCLEAR;
    end else begin
      tctr := cCLEAR;                        // reset timeout counter if key pressed
      k := k + 1;                            // increment repetition delay counter
    end;

    if (k = 1) or (k > KEYREP) then begin    // 1st time a key was depressed
      case knum of
        cKEYUP: begin                        // up key pressed
          if hpos = hmin then begin
            Comm := COMMBACK;
            kflag := KEYBACK;
          end else begin
            hpos := hpos - 1;
            kflag := KEYMOVE;
          end;
        end;

        cKEYRIGHT: begin                     // right key pressed
          if hpos = hmin then begin
            if dcat < dmax then begin
              dcat := dcat + 1;              // show next dive data log
            end else begin
              dcat := 1;
            end;
          end else begin
            if lpage < LOGPAGES then begin
              lpage := lpage + 1;            // show next log book page
            end else begin
              lpage := 1;
            end;
          end;

          kflag := KEYTURN;
        end;

        cKEYDOWN: begin                      // down key pressed
          if hpos = hmax then begin
            Comm := COMMEXIT;
            kflag := KEYBACK;
          end else begin
            hpos := hpos + 1;
            kflag := KEYMOVE;
          end;
        end;

        cKEYLEFT: begin                      // left key pressed
          if hpos = hmin then begin
            if dcat > 1 then begin
              dcat := dcat - 1;              // show previous dive data log
            end else begin
              dcat := dmax;
            end;
          end else begin
            if lpage > 1 then begin
              lpage := lpage - 1;            // show previous log book page
            end else begin
              lpage := LOGPAGES;
            end;
          end;

          kflag := KEYTURN;
        end;
      end; // case
    end;   // if key pressed

    tctr := tctr + 1;                        // increment timeout counter

    if tctr > EXITLOOP then begin            // timeout -> exit logbook
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if PhaseFlag = cON then begin            // phase changed -> exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if kflag = KEYMOVE then begin
      ClearBox(pbox);

      if (hpos > hmin) and (hpos <= hmax) then begin
        BoxSpec[pbox, 3] := yp + 2 + hpos * yinc;
      end else begin
        BoxSpec[pbox, 3] := yp;
      end;

      DispSymbol(pbox, 16);
      UpdateLcd;
    end;

    if kflag = KEYTURN then begin
      kflag := cKEYNONE;

      if hpos = hmin then begin
        goto LOADDIVE;
      end else begin
        goto NEXTPAGE;
      end;
    end;

    if kflag = KEYBACK then begin
      BoxSpec[pbox, 3] := yp;                // restore
      BoxSpec[dbox, 3] := ys;                // original
      BoxSpec[dbox + 1, 3] := ys;            // box positions

      LoadLcd(LCDLAYER_1);
      UpdateLcd;                             // close menu window
      Exit;                                  // and go back to caller
    end;

    if kflag <> cKEYNONE then begin
      if ObjFlag = cON then begin
        ObjFlag := cNEW;
      end else begin
        UpdateLcd;                           // refresh display screen
      end;
      kflag := cKEYNONE;
    end;

    CheckSignal;                             // open message window if required

  end; // while
end;

// ------------------------------------------------------------------------------
// OPENCATALOG - Open dive catalog window and list all logged dives
// ------------------------------------------------------------------ 02.06.07 --
procedure TGui.OpenCatalog(var Comm, Dive: Word); // TIGER add sub
var
  i, k, xs, ys, yinc, hpos, hinit, hmax: Byte;
  kflag, knum, pnum, rcomm, tuni: Byte;
  dbox, pbox, pmax, dmax, dlog, dnum, ldive: Word;
  ho, mi, da, mo, ya, tctr: Word;
  dtime: Long;
  ptext, stime, sdate, smon, sday, lday, tf: string;
begin
  rcomm := 100 + Comm;       // return code if dive selected
  hmax  := DIVELINES - 1;    // number of dive catalog lines
  dbox  := 224;              // 1st box number of dive data
  pbox  := 228;              // 1st box number of pointer
  yinc  := 8;                // y box increment (1..10)
  ys    := BoxSpec[dbox, 3]; // y pos of 1st dive line box

  SaveLcd(LCDLAYER_1);

  LoadDiveCatalog(dmax, dlog); // read catalog and get number of dives

  if dmax = 0 then begin     // no dives found in catalog
    LogError('OpenCatalog', 'No dives found in catalog', IntToStr(dmax), $A2);
    Comm := COMMNODATA;
    LoadLcd(LCDLAYER_1);
    UpdateLcd;   // close catalog window
    Exit;
  end;

  DispWindow(9, 0, 100);  // open dive catalog window
  DispText(170, Mask[192], NORMPOS); // disp header text
  DrawLine(186);   // horizontal top line

  for i := 0 to 3 do begin
    BoxSpec[dbox + i, 3] :=  ys - 10;
    ClearBox(dbox + i);
  end;

  DispText(dbox + 0, Mask[193], NORMPOS); // start date
  DispText(dbox + 1, Mask[194], NORMPOS); // start time
  DispText(dbox + 2, Mask[195], NORMPOS); // dive time

  if UnitFlag = cOFF then begin
    DispText(dbox + 3, Mask[246], NORMPOS);  // depth unit [M]
  end else begin
    DispText(dbox + 3, Mask[247], NORMPOS);  // depth unit [ft]
  end;
  
  DispSymbol(171, 11);  // arrow up
  DispSymbol(172, 12);  // arrow down

  UpdateLcd;

  if dive > 0 then begin  // show page of last selected dive
    pnum := (dive - 1) div DIVELINES;
    hinit := (dive - 1) mod DIVELINES;
  end else begin
    pnum := cCLEAR;
    hinit := cCLEAR;
  end;

  k := cCLEAR;
  kflag := KEYINIT;
  knum := cKEYNONE;
  pmax := (dmax - 1) div DIVELINES; // max number of pages

  hpos := cCLEAR;
  tctr := cCLEAR;
  dive := cCLEAR;

  while (InitFlag = cINIT) do begin
    Comm := cCLEAR;

    WaitDuration(GUIDELAY div GUISPEEDUP); //DELPHI too slow

    if kflag <> KEYINIT then begin
      GetKeyNum(knum);  // get number of depressed key
    end;

    if knum = cKEYNONE then begin  // no key depressed -> do nothing
      k := cCLEAR;
    end else begin
      tctr := cCLEAR;  // reset timeout counter if key pressed
      k := k + 1;      // increment repetition delay counter
    end;

    if (k = 1) or (k > KEYREP) then begin // 1st time a key was depressed
      case knum of
        cKEYUP: begin  // up key pressed
          if hpos = 0 then begin
            if pnum = 0 then begin
              Comm := COMMBACK;
              kflag := KEYBACK;
            end else begin
              pnum := pnum - 1;  // previous page
              kflag := KEYPAGE;
            end;
          end else begin
            hpos := hpos - 1;
            kflag := KEYMOVE;
          end;
        end;

        cKEYRIGHT: begin  // right key pressed
          kflag := KEYTURN;
        end;

        cKEYDOWN: begin  // down key pressed
          if hpos = hmax then begin
            if pnum >= pmax then begin
              Comm := COMMEXIT;
              kflag := KEYBACK;
            end else begin
              pnum := pnum + 1;  // next page
              kflag := KEYPAGE;
            end;
          end else begin
            hpos := hpos + 1;
            kflag := KEYMOVE;
          end;
        end;

        cKEYLEFT: begin  // left key pressed
          Comm := COMMEXIT;  // abort dive catalog
          kflag := KEYBACK;
        end;
      end;  // case
    end; // if key pressed

    tctr := tctr + 1;  // increment timeout counter

    if tctr > EXITLOOP then begin  // timeout -> exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if PhaseFlag = cON then begin  // phase changed -> exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if kflag = KEYINIT then begin   // show page of last selected dive
      for hpos := 0 to hmax do begin
        for i := 0 to 3 do begin
          BoxSpec[dbox + i, 3] :=  ys + hpos * yinc;
          ClearBox(dbox + i);
        end;

        // format new page of dive catalog
        if hpos < dmax - pnum * DIVELINES then begin
          ldive := pnum * DIVELINES + hpos + 1;
          dtime := DiveCatalog[ldive, 3] * HIGHWORD + DiveCatalog[ldive, 4];
          FormatTimeDate(dtime, stime, sdate, smon, sday, lday, tf); // get time and date as string
          stime := stime + LowerCase(tf);
          DispText(dbox + 0, sdate, NORMPOS);  // regarding time format (EU/US)
          DispText(dbox + 1, stime, NORMPOS);
          FormatValue(223, DiveCatalog[ldive, 0], ptext);
          DispText(dbox + 2, ptext, NORMPOS);  // DiveTime 'mmm.m' or 'hh:mm'
          tuni := 246 + UnitFlag;  //02.06.07 nk opt ff
          FormatValue(tuni, DiveCatalog[ldive, 1], ptext);
          DispText(dbox + 3, ptext, NORMPOS);  // MaxDepth 'nnn.n' [m/ft]
        end;
      end;

      hpos := hinit;  // goto last selected dive
      ClearBox(pbox);
      BoxSpec[pbox, 3] :=  ys + hpos * yinc;
      DispSymbol(pbox, 16);  // reset pointer symbol

      ldive := pnum * DIVELINES + hpos + 1;
      dnum := DiveCatalog[ldive, 5]; // get dive number
      ptext := IntToStr(dnum) + sSLASH + IntToStr(dlog);
      ClearBox(223);      // Tiger: no space
      DispText(223, ptext, LEFTPOS);

      if pnum < pmax then begin
        DispText(223, Mask[198], NORMPOS); // more
      end else begin
        DispText(223, Mask[199], NORMPOS); // close
      end;

      UpdateLcd;
      WaitDuration(KEYDELAY);
    end;

    if kflag = KEYMOVE then begin
      ClearBox(pbox);
      BoxSpec[pbox, 3] :=  ys + hpos * yinc;
      DispSymbol(pbox, 16);  // move pointer symbol

      ldive := pnum * DIVELINES + hpos + 1;
      dnum := DiveCatalog[ldive, 5]; // get dive number
      ClearBox(223);      // Tiger: no space

      if (dnum > 0) and (dnum <= dlog) then begin
        ptext := IntToStr(dnum) + sSLASH + IntToStr(dlog);
        DispText(223, ptext, LEFTPOS);
      end;

      if pnum < pmax then begin
        DispText(223, Mask[198], NORMPOS); // more
      end else begin
        DispText(223, Mask[199], NORMPOS); // close
      end;
    end;

    if kflag = KEYPAGE then begin  // show next/previous page
      for hpos := 0 to hmax do begin
        for i := 0 to 3 do begin
          BoxSpec[dbox + i, 3] :=  ys + hpos * yinc;
          ClearBox(dbox + i);
        end;

        // format new page of dive catalog
        if hpos < dmax - pnum * DIVELINES then begin
          ldive := pnum * DIVELINES + hpos + 1;
          dtime := DiveCatalog[ldive, 3] * HIGHWORD + DiveCatalog[ldive, 4];
          FormatTimeDate(dtime, stime, sdate, smon, sday, lday, tf); // get time and date as string
          stime := stime + LowerCase(tf);
          DispText(dbox + 0, sdate, NORMPOS);  // regarding time format (EU/US)
          DispText(dbox + 1, stime, NORMPOS);
          FormatValue(223, DiveCatalog[ldive, 0], ptext);
          DispText(dbox + 2, ptext, NORMPOS);  // DiveTime 'mmm.m' or 'hh:mm'
          tuni := 246 + UnitFlag;  //02.06.07 nk opt ff
          FormatValue(tuni, DiveCatalog[ldive, 1], ptext);
          DispText(dbox + 3, ptext, NORMPOS);  // MaxDepth 'nnn.n' [m/ft]
        end;
      end;

      hpos := 0;
      ClearBox(pbox);
      BoxSpec[pbox, 3] :=  ys;
      DispSymbol(pbox, 16);  // reset pointer symbol

      ldive := pnum * DIVELINES + hpos + 1;
      dnum := DiveCatalog[ldive, 5]; // get dive number
      ptext := IntToStr(dnum) + sSLASH + IntToStr(dlog);
      ClearBox(223);      // Tiger: no space
      DispText(223, ptext, LEFTPOS);

      if pnum < pmax then begin
        DispText(223, Mask[198], NORMPOS); // more
      end else begin
        DispText(223, Mask[199], NORMPOS); // close
      end;
    end;

    if kflag = KEYTURN then begin
      ldive := pnum * DIVELINES + hpos + 1;
      dnum := DiveCatalog[ldive, 5]; // get dive number
      if (dnum > 0) and (dnum <= dlog) then begin
        Comm := rcomm;
        Dive := dnum;  // return dive number
      end else begin
        Comm := COMMEXIT;
      end;
      kflag := KEYBACK;  // go back to caller
    end;

    if kflag = KEYBACK then begin
      BoxSpec[dbox, 3] := ys; // restore orig setting
      BoxSpec[pbox, 3] := ys;
      LoadLcd(LCDLAYER_1);
      UpdateLcd;  // close menu window
      Exit;        // and go back to caller
    end;

    if kflag <> cKEYNONE then begin
      if ObjFlag = cON then begin
        ObjFlag := cNEW;
      end else begin
        UpdateLcd;  // refresh display screen
      end;
      kflag := cKEYNONE;
    end;

    CheckSignal;  // open message window if required

  end; // while
end;

// ------------------------------------------------------------------------------
// OPENPLANNER - Open dive simulation / dive planner window
// ------------------------------------------------------------------ 03.02.07 --
procedure TGui.OpenPlanner(var Comm: Word);     // TIGER use this sub!!
var
  k, tl, dl, pe, ps, hpos, kflag, knum, ttop, tuni, tnum, tinc: Byte;
  sym0, sym9, symp, hmin, hmax, toff, poff, voff, win, prec, null: Byte;
  v, hbox, tbox, pbox, vbox, tctr: Word;
  ye, mo, da, ho, mi, val, nop: Long;
  htext, dtext, ptext, pform, tform, tf: string;
  
  vact: array[0..SETBOX] of Long;
  vmin: array[0..SETBOX] of Long;
  vmax: array[0..SETBOX] of Long;
  vinc: array[0..SETBOX] of Long;
  vuni: array[0..SETBOX] of Byte;
begin
  win := BoxSpec[SETFIRST, 1];       // dive planner window number
  sym0 := GlobalSet[WINPLAN, 0, 1];  // header line symbol
  sym9 := GlobalSet[WINPLAN, 9, 1];  // tail line symbol
  symp := GlobalSet[WINPLAN, 0, 2];  // pointer symbol

  hmax := SETBOX - 1;                // number of boxs
  toff := SETFIRST;                  // 1st box number of text
  voff := toff + SETBOX;             // 1st box number of value
  poff := voff + SETBOX;             // 1st box number of pointer
  hbox := toff + hmax;               // box number for help text

  pe := cCLEAR;
  hmin := cCLEAR;
  tctr := cCLEAR;
  tinc := cCLEAR;

  SaveLcd(LCDLAYER_1);

  DisableTsw;                                  // stop task switching while opening window

  for hpos := hmin to hmax do begin            // open menu window in 10% steps
    ttop := GlobalSet[WINPLAN, 0, 4] + hpos;   // end number of text (pointer to Mask$[])
    vact[hpos] := GlobalSet[WINPLAN, hpos, 0]; // actual value
    vmin[hpos] := GlobalSet[WINPLAN, hpos, 1]; // min value
    vmax[hpos] := GlobalSet[WINPLAN, hpos, 2]; // max value
    vinc[hpos] := GlobalSet[WINPLAN, hpos, 3]; // incremental value
    vuni[hpos] := GlobalSet[WINPLAN, hpos, 4]; // unit system or text number
    tuni       := vuni[hpos] + UnitFlag;       // unit system
    ptext      := Mask[ttop];                  // setting text

    if vinc[hpos] > 100 then begin             // convert incremental value
      tinc := cON;
      vinc[hpos] := vinc[hpos] - 100;
    end;

    if tuni >= UNITEXT then begin              // text, value and unit
      ptext := Mask[ttop] + Mask[tuni];
      if UnitFlag = cON then begin             // imperial unit system -> convert value
        ConvertValue(vact[hpos], prec, tuni);  // get precision value
        null := 0;
        ConvertValue(vmin[hpos], null, tuni);
        null := 0;
        ConvertValue(vmax[hpos], null, tuni);

        if tinc = cON then begin
          null := 0;
          ConvertValue(vinc[hpos], null, tuni);
        end;
      end;
      
      if prec >= cHALF then begin        // round up actual value
        vact[hpos] := vact[hpos] + 1;
      end;
    end;

    tbox := toff + hpos;
    vbox := voff + hpos;
    pbox := poff + hpos;

    ps := pe;
    pe := 10 * (hpos + 1) + 1;

    DispWindow(win, ps, pe);            // open partial window
    DispText(tbox, ptext, NORMPOS);     // disp text (with unit)

    if vinc[hpos] <> 0 then begin       // selection box (not a command box)
      if tuni <= 1 then begin
        val := vact[hpos];
        DispNumValue(vbox, val);        // unformated numerical value
      end;

      if (tuni >= UNITEXT) and (tuni < 254) then begin
        val := vact[hpos];
        DispNumValue(vbox, val);         // unformated numerical value
      end;

      if (tuni = 232) or (tuni = 233) or (tuni = 254) then begin
        val := vact[hpos];               // do not convert 233 (1bar=1ata)
        FormatValue(tuni, val, ptext);
        DispText(tbox, ptext, RIGHTPOS); // disp value on rigth side n.nn
      end;

      if tuni = 255 then begin
        val := vact[hpos];               // [in]
        FormatValue(tuni, val, ptext);   // format in -> ft.in [fii]
        DispText(tbox, ptext, RIGHTPOS); // disp value on rigth side [ft.in]
      end;
    end;

    case hpos of
      0: DispSymbol(pbox, sym0);   // arrow up
      1: DispSymbol(pbox, symp);   // pointer symbol
      9: begin
           DispSymbol(pbox, sym9);   // arrow down
           dtext := Mask[ttop];  // default help text
         end;
    end;

    UpdateLcd;    // next 10% step top down

    WaitDuration(20); // DELPHI: too fast
  end;
  
  EnableTsw;      // re-activate task switching

  hmin := 1;
  hmax := hmax - 1;
  hpos := hmin;
  pbox := poff + hmin;
  tnum := GlobalSet[WINPLAN, hpos, 4];     // text or format string value

  k := cCLEAR;
  knum := cKEYNONE;
  kflag := KEYMOVE;

  WaitDuration(KEYDELAY);  // wait until window is open
  
  while (InitFlag = cINIT) do begin
    Comm := cCLEAR;

    WaitDuration(GUIDELAY div GUISPEEDUP); //DELPHI too slow

    GetKeyNum(knum);                // get number of depressed key

    if knum = cKEYNONE then begin         // no key depressed -> do nothing
      k := cCLEAR;
    end else begin
      tctr := cCLEAR;                       // reset timeout counter if key pressed
      k := k + 1;                          // increment repetition delay counter
    end;

    if (k = 1) or (k > KEYREP) then begin // 1st time a key was depressed
      case knum of
        cKEYUP: begin
          hpos := hpos - 1;                   // up key pressed
          Comm := GlobalSet[WINPLAN, hpos, 0];
          if Comm = COMMNOP then begin        // no operation defined
            hpos := hpos - 1;                 // - so go to next box
          end;
          if hpos < hmin then begin
            kflag := KEYBACK               // close window and go back
          end else begin
            tnum := GlobalSet[WINPLAN, hpos, 4]; // text or format string value
            kflag := KEYMOVE;               // move pointer up
          end;
        end;

        cKEYRIGHT: begin
          if vinc[hpos] = 0 then begin       // it's a command box
            Comm := GlobalSet[WINPLAN, hpos, 0]; // - so return command number
            if Comm = COMMFIX then begin      // not selectable value
              kflag := cKEYNONE;             // - so do nothing
            end else begin
              kflag := KEYBACK;             // close window and go back
            end;
          end else begin
            if vact[hpos] >= vmax[hpos] then begin
              vact[hpos] := vmin[hpos];     // overrun - go to min value
            end else begin
              vact[hpos] := vact[hpos] + vinc[hpos]; // right key pressed
            end;
            kflag := KEYTURN;
          end;
        end;

        cKEYDOWN: begin
          hpos := hpos + 1;                   // down key pressed
          Comm := GlobalSet[WINPLAN, hpos, 0];
          if Comm = COMMNOP then begin        // no operation defined
            hpos := hpos + 1;                 // - so go to next box
          end;
          if hpos > hmax then begin
            kflag := KEYBACK;               // close window and go back
          end else begin
            tnum := GlobalSet[WINPLAN, hpos, 4]; // text or format string value
            kflag := KEYMOVE;               // move pointer down
          end;
        end;

        cKEYLEFT: begin
          if vinc[hpos] = 0 then begin      // it's a command box
            Comm := GlobalSet[WINPLAN, hpos, 0]; // - so return command number
            if Comm = COMMFIX then begin      // not selectable value
              kflag := cKEYNONE;             // - so do nothing
            end else begin
              kflag := KEYBACK;             // close window and go back
            end;
          end else begin
            if vact[hpos] <= vmin[hpos] then begin
              vact[hpos] := vmax[hpos];     // underrun - go to max value
            end else begin
              vact[hpos] := vact[hpos] - vinc[hpos]; // left key pressed
            end;
            kflag := KEYTURN;
          end;
        end;
      end;  // case
    end;    // if key depressed

    tctr := tctr + 1;                      // increment timeout counter

    if tctr > EXITLOOP then begin          // timeout - > exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if PhaseFlag = cON then begin       // phase changed -> exit sub
      Comm := COMMEXIT;
      kflag := KEYBACK;
    end;

    if kflag = KEYMOVE then begin
      tuni := tnum + UnitFlag;
      //nk// ClearBox(hbox);
      ClearBox(pbox);
      tbox := toff + hpos;
      pbox := poff + hpos;
      DispSymbol(pbox, symp);

      //nk// DispText(hbox, dtext, RIGHTPOS);   // alternate help text (default=CLOSE)
    end;

    if kflag = KEYTURN then  begin
      tbox := toff + hpos;
      vbox := voff + hpos;
      tuni := tnum + UnitFlag;

      //nk// ClearBox(hbox);
      ClearBox(vbox);

      if tuni <= 1 then begin
        val := vact[hpos];
        DispNumValue(vbox, val);        // unformated numerical value
      end;

      if (tuni >= UNITEXT) and (tuni < 254) then begin
        val := vact[hpos];
        DispNumValue(vbox, val);        // unformated numerical value
      end;

      if (tuni = 232) or (tuni = 233) or (tuni = 254) then begin
        val := vact[hpos];                // do not convert 233 (1bar=1ata)
        FormatValue(tuni, val, ptext);
        DispText(tbox, ptext, RIGHTPOS);  // disp value on rigth side n.nn
      end;

      if tuni = 255 then begin
        val := vact[hpos];                // [in]
        FormatValue(tuni, val, ptext);    // format in -> ft.in [fii]
        DispText(tbox, ptext, RIGHTPOS);  // disp value on rigth side [ft.in]
      end;

      if UnitFlag = cON then begin // imperial units
        prec := 0;
        tuni := vuni[1] + UnitFlag;    // unit system
        SimAltitude := vact[1] * 100;  // altitude [Ft]
        ConvertValue(SimAltitude, prec, tuni); // altitude [m]

        Daq.CalcAirPress(SimAltitude, ISOTEMP, val); // air pressure [hPa]

        DispNumValue(64, val div 10); // air press [kPa]
        
      end else begin
        SimAltitude := vact[1] * 100; // altitude [m]
        Daq.CalcAirPress(SimAltitude, ISOTEMP, val);
        DispNumValue(64, val div 10); // air press [kPa]
      end;
    end;

    if kflag = KEYBACK then begin
      LoadLcd(LCDLAYER_1);
      UpdateLcd;             // close menu window
      Exit;                  // and go back to caller
    end;

    if kflag <> cKEYNONE then begin
      if ObjFlag = cON then begin
        ObjFlag := cNEW;
      end else begin
        UpdateLcd;                   // refresh display screen
      end;
      kflag := cKEYNONE;
    end;

    CheckSignal;  // open message window if required

  end; // while

end;

// ------------------------------------------------------------------------------
// CHECKSIGNAL - Signal handler for async warning, alarm, and message objects
// ------------------------------------------------------------------ 17.02.07 --
procedure TGui.CheckSignal;
var
  sig, xpos, ypos, ddel, tdur, inum, knum, kret: Byte;
  bnum, hnum, tnum: Word;
  tnow, tobj, tlife, tlock: Long;
begin
  if SigNum = SIGNONE then begin      // no active signal  - return
    ObjFlag := cOFF;
    Exit;
  end;

  if SigNum < SIGNONE then begin      // signal to close object
    ObjFlag := cCLOSE;
  end;

  sig := Abs(SigNum);                  // signal number
  tnow := Ticks;                       // get actual system time [ms]
  tobj := ObjTime[sig];                // object time stamp [ms]
  tlife := ObjSpec[sig, 8] * MSEC_SEC; // object life time [ms] (OFF=timeless)
  tlock := ObjSpec[sig, 9] * MSEC_SEC; // object lock time [ms] (OFF=no locking)
  tdur := cOFF; // prevent multiple tones (MUST be here!!)

  if ObjFlag = cON then begin          // object is already open
    if (tlife > cOFF) and (tnow > tobj) then begin
      ObjFlag := cCLOSE;               // object live time exceed - close it
    end else begin
      Exit;                            // object still lives - return
    end;
  end;

  if ObjFlag = cOFF then begin         // there is a new object to create
    if (tlock > cOFF) and (tnow < tobj) then begin
      Exit;                            // object locked - return
    end else begin
      ObjFlag := cNEW;
      ObjTime[sig] := tnow + tlife;    // set object life time [ms]
      tdur := ObjSpec[sig, 7];         // audio tone duration [ms] (MUST be here!!)
    end;
  end;

  // entry point for silent messages in OpenProfile
  if ObjFlag = cNEW then begin         // object properties
    xpos := ObjSpec[sig, 0];           // -object x-pos
    ypos := ObjSpec[sig, 1];           // -object y-pos
    hnum := ObjSpec[sig, 2] + OBJTEXT; // -message head number
    bnum := ObjSpec[sig, 3] + OBJTEXT; // -message body number
    tnum := ObjSpec[sig, 4] + OBJTEXT; // -message tail number
    knum := ObjSpec[sig, 5];           // -key waiting
    inum := ObjSpec[sig, 6];           // -icon type
    ddel := cOFF;                      // -display delay

    kret := knum;
    OpenMessage(xpos, ypos, inum, tdur, ddel, kret, Mask[hnum], Mask[bnum], Mask[tnum]);

    if kret > cKEYNONE then begin
      if kret = knum then begin        // closed per key
        ObjFlag := cCLOSE;
      end else begin                   // suspended per key or timeouted
        ObjFlag := cRESET;
      end;
    end else begin
      ObjFlag := cON;
    end;
  end;

  if ObjFlag = cRESET then begin       // close object
    ObjTime[sig] := tnow + tlock;      // set object lock time [ms]
    ObjFlag := cOFF;  // do not clear SigNum - Object will reset after lock time
  end;

  if ObjFlag = cCLOSE then begin       // close object
    UpdateLcd;                         // recover old screen layer
    Mask[SIGTEXT] := sEMPTY;
    ObjTime[sig] := tnow + tlock;      // set object lock time [ms]
    SigNum := SIGNONE;
    ObjFlag := cOFF;
  end;
end;

end.
