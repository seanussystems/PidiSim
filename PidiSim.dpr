// PidiSim -  Pidi Simulator (Personal Integrated Dive Instrument)
// Version 1.6.0
// Date 12.06.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

// 3rd Party Components
// - Konopka Signature VCL Controls Vers. 6.1.10
// - Dive Charts Vers 2.0

// 07.12.04 1.0.0  opt - use binary coded dive parameter files (*.pfd)
// 18.10.05 1.0.1  opt - one-dim text arrays with dynamic language load
// 22.11.05 1.0.1  opt - new Tiger hardware abstraction layer model
// 09.12.05 1.0.2  add - new Window BARO shows barometric air pressure
// 11.12.05 1.1.0  add - DispNumValue shows negative values with minus sign
// 13.12.05 1.1.1  opt - Deco functions moved to UDeco.pas (like Deco.inc)
// 15.12.05 1.2.0  add - new unit symbol definition and text numbers (BAR and PSI)
// 18.12.05 1.2.1  add - new gas management and selection menu
// 21.12.05 1.2.2  add - read tank data with simulation in Delphi
// 25.12.05 1.2.3  add - new units USensor, UCompass, USonar, UTank
// 02.02.07 1.3.0  add - new window DIVE PLANNER and procedure OpenPlanner
// 02.03.07 1.3.1  add - load Tiger bitmaps and texts from resource file 'Tiger.res'
// 05.05.07 1.3.2  opt - use Dive Charts instead of TeeChart TChart (TRIAL)
// 20.10.07 1.4.0  upd - migration to CodeGear RAD Studio / Delphi 2007 Pro Win32
// 20.10.07 1.4.0  upd - use Dive Charts for Delphi 2007
// 30.08.10 1.4.1  opt - change system font from MS Sans Serife to Tahoma
// 30.08.10 1.4.1  opt - to make screenshots for seanus product web site
// 25.07.17 1.5.0  opt - migrate to Embarcadero Delphi XE3 Update 2
// 25.07.17 1.5.0  opt - update to Raize Components Vers. 6.1.10
// 25.07.17 1.5.0  opt - update to Dive Charts Vers. 1.3
// 25.07.17 1.5.0  opt - improvements for XE3 (AnsiString <-> string)
// 25.07.17 1.5.0  opt - use string instead of ShortString (e.g. old=string[MAXBUFF])
// 26.05.22 1.6.0  opt - migrate to Embarcadero Delphi XE7 Update 1
// 26.05.22 1.6.0  opt - update to Dive Charts Vers. 1.7
// 26.05.22 1.6.0  add - multi-resolution icon container (16, 24, 32, 48, and 256 pixels, 256 colors)
// 26.05.22 1.6.0  opt - remove TXPManifest component due to duplicate resource warning
// 26.05.22 2.0.0  git - Project is now open source hosted on GitHub
// 12.06.22 2.0.0  opt - migrate to Embarcadero Delphi 10.4
// 12.06.22 2.0.0  opt - update to Dive Charts Vers 2.0

{$ASSERTIONS ON}

program PidiSim;

uses
  Forms,
  Global in 'Global.pas',
  Data in 'Data.pas',
  SYS in 'SYS.pas',
  SER in 'SER.pas',
  RTC in 'RTC.pas',
  LCD in 'LCD.pas',
  ADC in 'ADC.pas',
  Display in 'Display.pas',
  Power in 'Power.pas',
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
  Application.CreateForm(TProfile, Profile);
  Application.CreateForm(TTrack, Track);
  Application.CreateForm(TPlan, Plan);
  Main.MainTask.Enabled := True;
  Application.Run;

end.
