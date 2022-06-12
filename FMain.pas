// Dive Main Task
// Date 12.06.22

unit FMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Dialogs,
  StdCtrls, ExtCtrls, Jpeg, StrUtils, Buttons, Forms, ComCtrls, Menus, ToolWin,
  ImgList, RzBorder, RzCmboBx, USystem, UForm, UGlobal, URegistry, SYS, SER,
  RTC, ADC, LCD, Global, Data, Texts, Power, Flash, Clock, Display, FDaq, FGui,
  FLog, FInfo, FProfile, FTrack, UPidi;

type
  TMain = class(TForm)
    MainTask: TTimer;
    MainBack: TImage;
    MainMenu: TPopupMenu;
    mnuBack: TMenuItem;
    mnuSave: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMove(var Msg: TWMMove); message WM_MOVE;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MainTaskTimer(Sender: TObject);
    procedure RunTask;
  private
    MainLoop: Byte;
    MainDone: Byte; // [%]
    DelLoop: Byte;  //TIGER add
    InitMain: Long;
    TaskCtr: Long;
  public
    procedure RestartProg; //22.05.07 nk add
    procedure ErrTask(Sender: TObject; E: Exception);
  end;

var
  Main: TMain;
  ErrFlag: Boolean;
  
implementation

{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
begin //25.07.17 nk opt
  FormatSettings.DecimalSeparator := cDOT; //25.07.17 nk opt XE3
  RegPath := REG_SOFTWARE + ProductName + cBACK;

  InitForm; //DELPHI only - get form texts

  with Main do begin
    DoubleBuffered := True;
    Tag            := TASKRUN;
    HelpKeyword    := IntToStr(PRIORUN);
    Left           := 20;
    Top            := 20;
    Width          := FORMWIDTH;  //old=800
    Height         := FORMHEIGHT; //old=600
    Caption        := ProductAgent;
    MainBack.Align := alClient;
    Show;
  end;

  GetFormParameter(Self);
  ShowFormContents(true); //old=False // hide form contents while moving

  Screen.Cursor := crDefault;
  Application.ProcessMessages;

  // start Tiger main task
  ErrFlag   := False;  //DELPHI
  InitFlag  := cOFF;
  ErrLog    := cON;
  AlarmFlag := cOFF;
  RunMode   := MODERUN;

  InitMain := cOFF;
  InitGui  := cOFF;
  InitDaq  := cOFF;

  InitSys;
  InitRtc(cINIT);         // initialize real time clock
  SetRtcAlarm(cOFF);      // set alarm pin for self-hold
  InitPower;              // set power self-hold line
  InitKey;                // initialize function keypad
  KeyFlag := KEYINIT;     // clear keyboard buffer DELPHI only
  GetKeyNum(KeyFlag);     // look if a key is depressed

  // start task control timer
  SysCtr   := cCLEAR;
  TaskCtr  := cCLEAR;
  MainLoop := LOWLOOP;    //TIGER opt
  MainDone := cCLEAR;     //DELPHI only
  DelLoop  := cCLEAR;     //TIGER add

  MainTask.Interval := DAQDELAY; //250ms
  //06.05.07 nk mov to PidiSim MainTask.Enabled := True;
  Application.ProcessMessages;
end;

procedure TMain.FormResize(Sender: TObject);
begin //calculate main form client area (moving limits)
  try //30.12.05 nk opt
    MainRect.Top    := Top  + TOPBORDER;
    MainRect.Bottom := Top  + Height - SIDEBORDER;
    MainRect.Left   := Left + SIDEBORDER;
    MainRect.Right  := Left + Width - SIDEBORDER;
  except
    //
  end;
end;

procedure TMain.FormMove(var Msg: TWMMove);
begin
  FormResize(self);
end;

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin //09.05.07 nk add TIGER do it in shut down or low bat
  if LogFlag = cON then CloseDiveLog; // close open dive logs
  SaveSettings;                       // save setting parameter in flash
  Application.ProcessMessages;
  CanClose := True;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  child: Long;
begin
  MainTask.Enabled := False;
  InitFlag         := cOFF;
  LogOpen          := cOFF;
  TaskCtr          := cCLEAR;

  try
    SetCurrentDir(ProgPath);
    SetFormParameter(Self);
    WaitDuration(DAQDELAY);

    for child := MdiChildCount - 1 downto 0 do
      MdiChildren[child].Close;  //close child forms
  finally
    ShowFormContents(True);
    Screen.Cursor := crDefault;
    Halt;
  end;
end;

// simulate Tiger task switching system
procedure TMain.MainTaskTimer(Sender: TObject);
var
  itime, atime: Long;
begin
  if ErrFlag then begin //22.05.07 nk add
    ErrFlag := False;
    if DiveFlag = cOFF then RestartProg;
    Exit;
  end;
  
  if DivePhase > PHASEINITIAL then begin
    Daq.Enabled := True;
  end;

  TaskCtr := TaskCtr + 1;

  if TaskCtr = 1 then Main.RunTask;

  if (TaskCtr mod 4 = 0) and (InitMain = cINIT) and (InitGui <> cINIT) then begin
    Gui.RunTask;
  end;

  if (InitMain = cINIT) and (InitFlag = cINIT) then begin
    Daq.RunTask;
    Main.RunTask;
  end;

  //DELPHI simulation for Tiger alarm clock wake-up
  if (RunMode = MODESLEEP) and (TaskCtr mod LOWLOOP = 0) then begin
    GetRtcTime(atime);
    itime := StrToInt(GetRegString(RegPath + REG_SETTINGS, RTCALARMSET, '0'));
    if atime >= itime then begin
      RunMode := MODERUN;
   // InitGui := cCLEAR;  //nk// löscht Menu asynchron !!??!!
      TaskCtr := cCLEAR;
    end;
  end;
end;

procedure TMain.ErrTask(Sender: TObject; E: Exception);
begin  // DELPHI implementation for Tiger on_errtask_call
  if Sender is TForm then begin
    ErrorHandler((Sender as TForm).Name, E.Message);
  end else begin
    ErrorHandler(Main.Hint, E.Message);
  end;

  ErrFlag := True; //22.05.07 nk add - restart system
end;

procedure TMain.RestartProg;
begin //TIGER add (is this a cold or warm start??)
  ErrFlag          := False; //DELPHI
  MainTask.Enabled := False;
  InitFlag         := cOFF;
  InitMain         := cOFF;
  InitGui          := cOFF;
  InitDaq          := cOFF;
  WaitDuration(TASKDELAY);
  SetPower(PWRDISP, cOFF);
  TaskCtr          := cCLEAR;
  RunMode          := MODERUN;
  MainTask.Enabled := True;
end;

// MAIN task starts here

procedure TMain.RunTask;
begin
  if InitMain <> cINIT then begin
    LogSys;                    // log system and program name and versions
    GetSystem(SystemVers);     // get name and version of runtime system
    GetProcessor(ProcVers);    // get type and version of processor
    GetDevice(DEVMAX, DriverVers); // get version of device drivers
    GetMemFree(MemFree);       // report free flash memory size
    GetRamFree(RamFree);       // report free sram memory size
    InitApplication;           // initialize win and box arrays
    InitGlobalData;            // initialize global data and set default values
    InitTimeDate;              // initialize time and date arrays
    InitHolidays;              // initialize holiday arrays
    InitRtc(cCLEAR);           // initialize real time clock and reset TimeDate

    // Tiger: on every start
    InitMem;
    InitI2c;                   // initialize I2C bus
    InitSpi;                   // initialite SPI bus
    InitAdc;                   // initialize A/D converter (10-bit)
    InitAudio;                 // initialize audio output (beep after init phase)

    InitMain := cINIT;         // system initialized
    //nk//TankFlag := cON;           // assume tank data is available !!!!
    PhaseFlag := cON;
    DivePhase := PHASEINITIAL; // go to initial phase

    SetPower(PWRLITE, cOFF);
    LogTasks;                  // log running task numbers and names
  end;

  if SysCtr > MAXLOOP then begin
    SysCtr := cCLEAR;
  end;

  if DivePhase < PHASEPREDIVE then begin //TIGER opt
    if SysCtr mod MainLoop = 0 then begin   //TIGER exchange this 2 lines
      CheckAlarm(AlarmFlag, AlarmTime, TimeNow);
      if AlarmTime <= MEDLOOP then begin
        MainLoop := ANYLOOP;   // speed up alarm check
      end else begin
        MainLoop := MEDLOOP;   // slow down alarm check
      end;
    end;

    if AlarmFlag = cCLOSE then SigNum := SIGNONE; // kill pending alarms after SIGLIFETIME

    if AlarmFlag = cON then begin  //TIGER move code here
      DelLoop := DelLoop + 1;
    end;

    if DelLoop > MEDLOOP then begin   //MEDLOOP delay for GUI clock refresh
      AlarmFlag     := cOFF;
      Mask[SIGTEXT] := TimeNow + sNEWDEL;
      SysCtr        := cCLEAR;
      DelLoop       := cCLEAR;
      MainLoop      := LOWLOOP;
      SigNum        := SIGCLOCKALARM;    // signal to open clock alarm object
    end;
  end;

  //DELPHI no WaitDuration(DAQDELAY);

  if RunMode = MODESTART then begin
    LogEvent(TaskName[TASKRUN], 'Switch task', 'OFF');
    RestartProg;
  end;

  SysCtr := SysCtr + 1;
  Application.ProcessMessages;
end;

end.
