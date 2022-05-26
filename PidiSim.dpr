// PidiSim -  Pidi Simulator (Personal Integrated Dive Instrument)
// Version 1.6.0
// Date 26.05.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

// TODO:
// Include FRegister copied from SimWalk SimRegister
// Read and calculate AccuRate

// Raize Components Vers. 6.1.10
// SDL Component Suite Vers. 10.7

// 07.12.04 nk opt - use binary coded dive parameter files (*.pfd)
// 18.10.05 nk opt - one-dim text arrays with dynamic language load
// 22.11.05 nk opt - new Tiger hardware abstraction layer model
// 09.12.05 nk add - new Window BARO shows barometric air pressure
// 11.12.05 nk add - DispNumValue shows negative values with minus sign
// 13.12.05 nk opt - Deco functions moved to UDeco.pas (like Deco.inc)
// 15.12.05 nk add - new unit symbol definition and text numbers (BAR and PSI)
// 18.12.05 nk add - new gas management and selection menu
// 21.12.05 nk add - read tank data with simulation in Delphi
// 25.12.05 nk add - new units USensor, UCompass, USonar, UTank
// 02.02.07 nk add - new window DIVE PLANNER and procedure OpenPlanner
// 02.03.07 nk add - load Tiger bitmaps and texts from resource file 'Tiger.res'
// 05.05.07 nk opt - use SDL TRChart instead of TeeChart TChart (TRIAL)
// 20.10.07 nk upd - migration to CodeGear RAD Studio / Delphi 2007 Pro Win32
// 20.10.07 nk upd - use SDL Component Suite 9.0 for Delphi 2007
// 30.08.10 nk opt - change system font from MS Sans Serife to Tahoma
// 30.08.10 nk opt - to make screenshots for seanus product web site

// 25.07.17 nk opt - migrate to Embarcadero Delphi XE3 Update 2
// 25.07.17 nk opt - update to Raize Components Vers. 6.1.10
// 25.07.17 nk opt - update to SDL Base, Math, and Chart Packs Vers. 10.3
// 25.07.17 nk opt - improvements for XE3 (AnsiString <-> string)
// 25.07.17 nk opt - use string instead of ShortString (e.g. old=string[MAXBUFF])

// 26.05.22 nk opt - migrate to Embarcadero Delphi XE7 Update 1
// 26.05.22 nk opt - update to SDL Base, Math, and Chart Packs Vers. 10.7
// 26.05.22 nk git - Project is now hosted as freeware on GitHub

{$ASSERTIONS ON}

program PidiSim;

uses
  Forms,
  //USystem,
  Global in 'Global.pas',
  Data in 'Data.pas',
  SYS in 'SYS.pas',
  SER in 'SER.pas',
  RTC in 'RTC.pas',
  LCD in 'LCD.pas',
  ADC in 'ADC.pas',
  Display in 'Display.pas',
  Power in 'Power.pas',
  Texts in 'Texts.pas',
  Clock in 'Clock.pas',
  Sensor in 'Sensor.pas',
  Compass in 'Compass.pas',
  Sonar in 'Sonar.pas',
  Tank in 'Tank.pas',
  Flash in 'Flash.pas',
  Deco in 'Deco.pas',
  FMain in 'FMain.pas' {Main},
  FInfo in 'FInfo.pas' {Info},
  FLog in 'FLog.pas' {Log},
  FGui in 'FGui.pas' {Gui},
  FDaq in 'FDaq.pas' {Daq},
  FProfile in 'FProfile.pas' {Profile},
  FTrack in 'FTrack.pas' {Track},
  FPlan in 'FPlan.pas' {Plan},
  FTest in 'FTest.pas' {Test},
  UPidi in 'UPidi.pas';

{$R *.res}
{$R Tiger.res}

begin
  Application.Initialize;
  Application.Title := 'PidiSim';
  Application.OnException := Main.ErrTask;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TInfo, Info);
  Info.ShowLogo(4); // 26.07.17 nk add
  Application.CreateForm(TLog, Log);
  Application.CreateForm(TGui, Gui);
  Application.CreateForm(TDaq, Daq);
  Application.CreateForm(TTest, Test);
  Application.CreateForm(TProfile, Profile);
  Application.CreateForm(TTrack, Track);
  Application.CreateForm(TPlan, Plan);
  Main.MainTask.Enabled := True;
  Application.Run;

end.
