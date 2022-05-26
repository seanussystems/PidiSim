// Program Info
// Date 26.07.17
// Norbert Koechli
// Copyright ©2006-2017 seanus systems

unit FInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, Dialogs, Jpeg, ExtCtrls, UGlobal, USystem, URegistry, Global;

type
  TInfo = class(TForm)
    InfoMemo: TMemo;
    InfoLoop: TTimer;
    InfoBlack: TLabel;
    InfoWhite: TLabel;
    InfoLogo: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCatch(var Msg: TwmncHitTest); message WM_NCHITTEST;
    procedure InfoLoopTimer(Sender: TObject);
  private
    InfoDelay: Long;
    InfoYear: string;
    procedure CreateInfoLines(Line: Long);
  public
    procedure ShowLogo(Delay: Long);
    procedure ShowInfo(InfoFile: string);
  end;

const
  INFO_LINE      = 16;
  INFO_DELAY     = 4;
  INFO_FONT      = 'Arial';
  INFO_BLACK     = 'Black';
  INFO_WHITE     = 'White';
  INFO_VERS      = ' Vers. ';
  INFO_YEAR      = 'YYYY';
  INFO_INI_YEAR  = '2005';
  INFO_MIN_YEAR  = '2007';
  INFO_READ_FILE = 'Readme.txt'; //20.10.07 nk add

  INFO_ACT_YEAR  = '#ACT_YEAR';
  INFO_REG_OWNER = '#REG_OWNER';
  INFO_REG_INFO  = '#REG_INFO';
  INFO_REG_USER  = '#REG_USER';

  //20.10.07 nk add ff TODO include FRegister for program registration
  REG_OK        = 1;
  REG_SHOPOPEN  = 2;
  REG_DOWNLOAD  = 3;
  REG_SHOPFAIL  = 4;
  REG_TRIAL     = 5;
  REG_COMPANY   = 6;
  REG_FIRSTNAME = 7;
  REG_LASTNAME  = 8;
  REG_LICENSE   = 9;
  REG_NOUPDATE  = 10;
  REG_UNREG     = 11;

  RegMessages: array[REG_OK..REG_UNREG] of string = (
    'Program is registered',
    'Open web site...',
    'Check for program update...',
    'Could not open web site!',
    'Unregistered trial version',
    'Invalid organisation!',
    'Invalid first name!',
    'Invalid last name!',
    'Invalid license key!',
    'No updates available!',
    'Unregistered program version');

  //20.10.07 nk opt ff
  InfoText: array[1..8] of string = (
    'Copyright ' + cCOPY + INFO_INI_YEAR + cSPLIT + INFO_ACT_YEAR,
    'by ' + INFO_REG_OWNER,
    cEMPTY,
    'all rights reserved',
    cEMPTY,
    'This program is registered to:',
    INFO_REG_INFO,
    INFO_REG_USER);

  //nk//mov to FRegister
  RegKeyOk = True;
  RegCompanyName = 'seanus systems';
  RegFirstName = 'Norbert';
  RegLastName = 'Köchli';

var
  Info: TInfo;
  InfoFile: string;
  
implementation

uses FMain;

{$R *.dfm}

procedure TInfo.FormCreate(Sender: TObject);
begin
  HideMaxButton(Self);   //hide maximize button
  HideMinButton(Self);   //hide minimize button

  Position := poScreenCenter;
  Width := 512;
  Height := 343;
  InfoDelay := INFO_DELAY;
  InfoYear := FormatDateTime(INFO_YEAR, Now);
  
  if InfoYear < INFO_MIN_YEAR then InfoYear := INFO_MIN_YEAR;
  if InfoFile = cEMPTY then InfoFile := ProgPath + INFO_READ_FILE;

  with InfoLogo do begin
    Align := alNone;
    AutoSize := False;
    Center := False;
    Proportional := False;
    Stretch := False;
    Transparent := False;
    ShowHint := False;
    Left := 0;
    Top := 0;
    Width := Info.Width;
    Height := Info.Height;
    Visible := True;
  end;

  with InfoBlack do begin
    Alignment := taLeftJustify;
    AutoSize := True;
    Caption := cEMPTY;
    ParentFont := False;
    Font.Name := INFO_FONT;
    Font.Color := clBlack;
    Font.Style := [fsBold, fsItalic];
    Font.Size := 11;
    Transparent := True;
    Visible := True;
    BringToFront;
  end;

  with InfoWhite do begin
    Alignment := taLeftJustify;
    AutoSize := True;
    Caption := cEMPTY;
    ParentFont := False;
    Font.Name := INFO_FONT;
    Font.Color := clWhite;
    Font.Style := [fsBold, fsItalic];
    Font.Size := 11;
    Transparent := True;
    Visible := True;
    BringToFront;
  end;

  with InfoMemo do begin
    Align := alClient;
    TabOrder := 0;
    Color := clWhite;
    ParentFont := False;
    Font.Name := INFO_FONT;
    Font.Color := clWindowText;
    Font.Style := [];
    Font.Size := 10;
    MaxLength := MAXINT;
    BorderStyle := bsNone;
    Ctl3D := False;
    HideSelection := False;
    ReadOnly := True;
    ScrollBars := ssVertical;
    WordWrap := True;
    ShowHint := False;
    Visible := False;
    Clear;
  end;

  with InfoLoop do begin
    Interval := 1000;  // 1s
    Enabled := False;
  end;
end;

procedure TInfo.FormCatch(var Msg: TwmncHitTest);
begin
  inherited;
  if Msg.Result = HTCAPTION then Msg.Result := HTNOWHERE;
end;

procedure TInfo.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Long;
begin
  Hide;
  InfoLoop.Enabled := False;
  Application.ProcessMessages;
  
  try
    for i := 1 to High(InfoText) do begin
      TLabel(FindComponent(INFO_BLACK + IntToStr(i))).Free;
      TLabel(FindComponent(INFO_WHITE + IntToStr(i))).Free;
    end;
  except
    //ignore
  end;
end;

procedure TInfo.InfoLoopTimer(Sender: TObject);
begin
  Dec(InfoDelay);
  if InfoDelay <= 0 then Info.Close;
end;

procedure TInfo.ShowLogo(Delay: Long);
var
  i: Long;
begin
  if Info.Visible then Exit;

  Show;

  InfoMemo.Visible := False;
  InfoBlack.Caption := ProductName + INFO_VERS + ProductVersion;
  //nk//if not SimRegOk then InfoBlack.Caption := ProductName + INFO_VERS + ProductVersion + cSPLIT + REG_UNREG;
  //nk//if SimTrial then InfoBlack.Caption := ProductName + INFO_VERS + ProductVersion + cSPLIT + SIM_TRIAL;

  InfoWhite.Caption := InfoBlack.Caption;

  for i := 1 to High(InfoText) do //show dynamic info text
    CreateInfoLines(i);

  InfoDelay := Delay;
  InfoLoop.Enabled := True;
end;

procedure TInfo.ShowInfo(InfoFile: string);
begin
  InfoLoop.Enabled := False;
  Show;

  if FileExists(InfoFile) then begin
    with InfoMemo do begin
      Visible := True;
      Lines.LoadFromFile(InfoFile);
      SelStart := 0;
      SelLength := 0;
    end;
  end;

  Application.ProcessMessages;
end;

procedure TInfo.CreateInfoLines(Line: Long);
var
  black: TLabel;
  white: TLabel;
  text: string;
begin
  try
    black := TLabel.Create(Self);
    white := TLabel.Create(Self);
    text := Trim(InfoText[Line]);

    if (Pos(INFO_ACT_YEAR, text) > 0) then
      text := StringReplace(text, INFO_ACT_YEAR, InfoYear, [rfReplaceAll]);

    if (Pos(INFO_REG_OWNER, text) > 0) then
      text := StringReplace(text, INFO_REG_OWNER, RegCompanyName, [rfReplaceAll]);

    if (Pos(INFO_REG_INFO, text) > 0) then begin
      if RegKeyOk then
        text := StringReplace(text, INFO_REG_INFO, RegCompanyName, [rfReplaceAll])
      else
        text := StringReplace(text, INFO_REG_INFO, RegMessages[REG_UNREG], [rfReplaceAll]);
    end;

    if (Pos(INFO_REG_USER, text) > 0) then begin
      if RegKeyOk then
        text := StringReplace(text, INFO_REG_USER, RegFirstName + cSPACE + RegLastName, [rfReplaceAll])
      else
        text := StringReplace(text, INFO_REG_USER, RegMessages[REG_UNREG], [rfReplaceAll]);
    end;

    with black do begin
      Parent := Self;
      Name := INFO_BLACK + IntToStr(Line);
      Alignment := taLeftJustify;
      AutoSize := True;
      ShowAccelChar := False;
      ParentFont := False;
      Font.Name := INFO_FONT;
      Font.Color := clBlack;
      Font.Style := [];
      Font.Size := 8;
      Transparent := True;
      Left := InfoBlack.Left;
      Top := InfoBlack.Top + (Line + 1) * INFO_LINE;
      Caption := text;
      Visible := True;
      BringToFront;
    end;

    with white do begin
      Parent := Self;
      Name := INFO_WHITE + IntToStr(Line);
      Alignment := taLeftJustify;
      AutoSize := True;
      ShowAccelChar := False;
      ParentFont := False;
      Font.Name := INFO_FONT;
      Font.Color := clWhite;
      Font.Style := [];
      Font.Size := 8;
      Transparent := True;
      Left := InfoBlack.Left + 1;
      Top := InfoBlack.Top + (Line + 1) * INFO_LINE + 1;
      Caption := text;
      Visible := True;
      BringToFront;
    end;
  except
    text := cEMPTY;
  end;

  Application.ProcessMessages;
end;

end.
