// Program Registration
// Date 20.10.07
// Norbert Koechli
// Copyright ©2006-2007 seanus systems

unit FRegister;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, ImgList, Forms,
  Controls, StdCtrls, StrUtils, ComCtrls, ExtCtrls, Mask, RzEdit, RzButton,
  UGlobal, USystem, UError, URegistry, UInifile, UInternet;

type
  TRegister = class(TForm)
    RegisterStatus: TStatusBar;
    RegisterIcons: TImageList;
    lblProgVers: TLabel;
    lblCompany: TLabel;
    lblFirstName: TLabel;
    lblLastName: TLabel;
    lblLicenseKey: TLabel;
    lblSpace1: TLabel;
    lblSpace2: TLabel;
    lblSpace3: TLabel;
    edProgVers: TRzEdit;
    edCompany: TRzEdit;
    edFirstName: TRzEdit;
    edLastName: TRzEdit;
    edKey1: TRzEdit;
    edKey2: TRzEdit;
    edKey3: TRzEdit;
    edKey4: TRzEdit;
    btnRegister: TRzBitBtn;
    btnOrder: TRzBitBtn;
    btnUpdate: TRzBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMoving(var Msg: TwmMoving); message WM_MOVING;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOrderClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure edKey1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edKey2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edKey3KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edKey4KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edKeyAllKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure ShowLicenseKey(LicenseKey: string);
    procedure ShowRegsitration(Registered: Boolean);
    function ShowStatus(Status: Integer): Boolean;
    function GetUserInput(Order: Boolean): Integer;
    function SetUserInput: Boolean;
  public
    procedure Open;
    function CheckLicenseKey: Boolean;
    function CheckTrialVers: Boolean; //08.08.07 nk add
    function SplitLicenseKey(LicenseKey: string): string; //03.08.07 nk mov from URegister
  end;

  //SimWalk full version function in external SimLib.dll
  function GetSignature: Boolean; stdcall;
  function GetDownload(FileName: ShortString): ShortString; stdcall; //19.10.07 nk add
  function GetLicense(RegPath: ShortString): Boolean; stdcall;
  function SetLicense(RegPath: ShortString): Boolean; stdcall; //nk//TEST

var
  Register: TRegister;

implementation

{$R *.dfm}

function GetSignature: Boolean; stdcall;
  external SIM_LIB_NAME;

function GetLicense(RegPath: ShortString): Boolean; stdcall;
  external SIM_LIB_NAME;

function GetDownload(FileName: ShortString): ShortString; stdcall; //19.10.07 nk add
  external SIM_LIB_NAME;

function SetLicense(RegPath: ShortString): Boolean; stdcall; //nk//TEST
  external SIM_LIB_NAME;

procedure TRegister.FormCreate(Sender: TObject);
begin
  DisableMaxButton(Self); //hide maximize button
  DisableMinButton(Self); //hide minimize button

  Position := poScreenCenter;
  Hide;

  btnUpdate.Left    := btnOrder.Left;
  btnUpdate.Top     := btnOrder.Top;
  btnUpdate.Width   := btnOrder.Width;
  btnUpdate.Height  := btnOrder.Height;
  btnUpdate.Visible := False;
  btnOrder.Visible  := True;

  SimRegOk := CheckLicenseKey;
end;

procedure TRegister.FormShow(Sender: TObject);
begin
  SimRegOk := CheckLicenseKey;
  SimProgVers := SIM_INFO_VERS + GetProgVers(vtLong); //19.10.07 nk old=vers

  edCompany.Text   := SimCompany;
  edFirstName.Text := SimFirstName;
  edLastName.Text  := SimLastName;

  if SimRegOk then begin
    edProgVers.Text := ProductName + cSPACE + SimProgVers;
    ShowLicenseKey(SimLicenseKey);
    ShowStatus(SIM_REG_OK);
  end else begin
    if SimTrial then begin
      edProgVers.Text := ProductName + cSPACE + SimProgVers + cSPLIT + SIM_TRIAL;
      ShowStatus(SIM_REG_TRIAL);
    end else begin
      edProgVers.Text := ProductName + cSPACE + SimProgVers + cSPLIT + REG_UNREG;
      ShowStatus(SIM_REG_UNREG);
    end;
    ShowLicenseKey(cEMPTY);
  end;

  ShowRegsitration(SimRegOk);
  Application.ProcessMessages;
end;

procedure TRegister.FormMoving(var Msg: TwmMoving);
begin
  LimitFormMove(SimArea, Msg);
end;

procedure TRegister.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Screen.Cursor := crDefault;
end;

procedure TRegister.Open;
begin
  ShowModal; //19.10.07 nk old=Show
  //nk//delRegisterStatus.SetFocus;
  Application.ProcessMessages;
end;

function TRegister.CheckLicenseKey: Boolean;
begin
  try //08.08.07 nk opt ff
    SimCompany    := GetRegString(SimRegPath, REG_KEY_COMPANY,   cEMPTY);
    SimFirstName  := GetRegString(SimRegPath, REG_KEY_FIRSTNAME, cEMPTY);
    SimLastName   := GetRegString(SimRegPath, REG_KEY_LASTNAME,  cEMPTY);
    SimLicenseKey := GetRegString(SimRegPath, REG_KEY_LICENSE,   REG_UNREG);
    Result := GetLicense(SimRegPath);
  except
    Result := False;
  end;
end;

function TRegister.CheckTrialVers: Boolean;
begin
  Result := not GetSignature;
end;

function TRegister.SplitLicenseKey(LicenseKey: string): string;
var
  num: Integer; //03.08.07 nk add
begin
  Result := cEMPTY;

  if (LicenseKey <> cEMPTY) and (LicenseKey <> REG_UNREG) then begin
    num := 1;
    Result := Result + Copy(LicenseKey, num, REG_NUMS) + cDASH;
    num := num + REG_NUMS;
    Result := Result + Copy(LicenseKey, num, REG_NUMS) + cDASH;
    num := num + REG_NUMS;
    Result := Result + Copy(LicenseKey, num, REG_NUMS) + cDASH;
    num := num + REG_NUMS;
    Result := Result + Copy(LicenseKey, num, REG_NUMS);
  end;
end;

function TRegister.GetUserInput(Order: Boolean): Integer;
begin
  Result := 0;

  SimLicenseKey := edKey1.Text + edKey2.Text + edKey3.Text + edKey4.Text;
  SimCompany    := Trim(edCompany.Text);
  SimFirstName  := Trim(edFirstName.Text);
  SimLastName   := Trim(edLastName.Text);

  if SimCompany   = cEMPTY then Result := SIM_REG_COMPANY;
  if SimFirstName = cEMPTY then Result := SIM_REG_FIRSTNAME;
  if SimLastName  = cEMPTY then Result := SIM_REG_LASTNAME;

  if not Order then
    if Length(SimLicenseKey) <> REG_CHARS then Result := SIM_REG_LICENSE;
end;

function TRegister.SetUserInput: Boolean;
begin
  try
    SetRegString(SimRegPath, REG_KEY_COMPANY,   SimCompany);
    SetRegString(SimRegPath, REG_KEY_FIRSTNAME, SimFirstName);
    SetRegString(SimRegPath, REG_KEY_LASTNAME,  SimLastName);
    SetRegString(SimRegPath, REG_KEY_LICENSE,   SimLicenseKey);
    Result := True;
  except
    Result := False;
  end;
end;

function TRegister.ShowStatus(Status: Integer): Boolean;
begin
  Screen.Cursor := crDefault;

  if Status = SIM_REG_OK then //19.10.07 nk add
    edProgVers.Text := ProductName + cSPACE + SimProgVers;

  if Status < SIM_REG_OK then
    RegisterStatus.SimpleText := cEMPTY
  else
    RegisterStatus.SimpleText := cSPACE + SimRegMessages[Status];

  case Status of
    SIM_REG_COMPANY:   edCompany.SetFocus;
    SIM_REG_FIRSTNAME: edFirstName.SetFocus;
    SIM_REG_LASTNAME:  edLastName.SetFocus;
    SIM_REG_LICENSE:   edKey1.SetFocus;
  else
    RegisterStatus.SetFocus;
  end;

  if Status >= SIM_REG_SHOPFAIL then Beep;

  RegisterStatus.Update;
  Result := (Status > 0);
end;

procedure TRegister.ShowLicenseKey(LicenseKey: string);
var
  num: Integer; //03.08.07 nk add
begin
  if LicenseKey = cEMPTY then begin
    edKey1.Text := cEMPTY;
    edKey2.Text := cEMPTY;
    edKey3.Text := cEMPTY;
    edKey4.Text := cEMPTY;
  end else begin
    num := 1;
    edKey1.Text := Copy(LicenseKey, num, REG_NUMS);
    num := num + REG_NUMS;
    edKey2.Text := Copy(LicenseKey, num, REG_NUMS);
    num := num + REG_NUMS;
    edKey3.Text := Copy(LicenseKey, num, REG_NUMS);
    num := num + REG_NUMS;
    edKey4.Text := Copy(LicenseKey, num, REG_NUMS);
  end;
end;

procedure TRegister.ShowRegsitration(Registered: Boolean);
begin
  edProgVers.Enabled  := False;
  edCompany.Enabled   := not Registered;
  edFirstName.Enabled := not Registered;
  edLastName.Enabled  := not Registered;
  edKey1.Enabled      := not Registered;
  edKey2.Enabled      := not Registered;
  edKey3.Enabled      := not Registered;
  edKey4.Enabled      := not Registered;

  btnUpdate.Visible   := Registered;
  btnOrder.Visible    := not Registered;
  btnRegister.Enabled := not Registered;
end;

procedure TRegister.btnOrderClick(Sender: TObject);
var
  err: Integer;
  comp: string;
  first: string;
  last: string;
  link: string;
begin
  err := GetUserInput(True);
  if ShowStatus(err) then Exit;

  comp  := AnsiToUtf8(SimCompany);   //convert strings to
  first := AnsiToUtf8(SimFirstName); //UTF-8 character
  last  := AnsiToUtf8(SimLastName);  //encoding

  //19.10.07 nk opt ff - purchase on Simwalk home page
  link := SIM_HOME_PAGE + SIM_PURCHASE;

  //this string conforms to the guidelines of element5
  //link := SIM_REG_PROVIDER + '?' +
  //  SIM_REG_KEYPROD  + SIM_REG_PRODUCT  + ']=1&' +
  //  SIM_REG_KEYCURR  + SIM_REG_CURRENCY + ',all&' +
  //  SIM_REG_KEYLANG  + SIM_REG_LANGUAGE + '&' +
  //  SIM_REG_KEYHADD1 + SIM_REG_PRODUCT  + ']=' + SIM_REG_KEYHADD1 + '&' +
  //  SIM_REG_KEYHADD2 + SIM_REG_PRODUCT  + ']=' + SIM_REG_KEYHADD2 + '&' +
  //  SIM_REG_KEYCOMP  + comp + '&' +
  //  SIM_REG_KEYFIRST + first + '&' +
  //  SIM_REG_KEYLAST  + last;

  try
    ShowStatus(SIM_REG_SHOPOPEN);
    if not OpenWebSite(link) then
      ShowStatus(SIM_REG_SHOPFAIL)
    else
      Close;
  except
    ShowStatus(SIM_REG_SHOPFAIL);
  end;
end;

procedure TRegister.btnRegisterClick(Sender: TObject);
var
  err: Integer;
  lkey: string;
begin
  err := GetUserInput(False);

  if err = SIM_REG_LICENSE then begin //nk//TEST only ff
    lkey := edKey1.Text + edKey2.Text + edKey3.Text + edKey4.Text;
    if lkey = '1234' then
      SetLicense(SimRegPath)
    else
      Exit;
    CheckLicenseKey;
    ShowLicenseKey(SimLicenseKey);
    err := SIM_REG_OK;
  end;

  if ShowStatus(err) then Exit;

  if SetUserInput then begin  //save to registry
    SimRegOk := CheckLicenseKey;

    if SimRegOk then begin
      ShowStatus(SIM_REG_OK);
      ShowRegsitration(True);
      Exit;
    end;
  end;

  ShowStatus(SIM_REG_LICENSE);
end;

procedure TRegister.btnUpdateClick(Sender: TObject);
var
  act: Integer;
  new: Integer;
  update: ShortString;
begin
  ShowStatus(SIM_REG_DOWNLOAD);
  Screen.Cursor := crHourGlass;

  IniFile := ProgPath + SIM_UPDATE_FILE;
  update := GetDownload(SIM_UPDATE_FILE); //19.10.07 nk add
  act := StrToInt(GetProgVers(vtBuild));

  if DownloadFile(update, IniFile) then begin
    new := StrToInt(GetIniValue(SIM_UPDATE, SIM_BUILD, ISFALSE));
    update := GetIniValue(SIM_UPDATE, SIM_UPDATE_KEY, cEMPTY);

    if (new > act) and (update <> cEMPTY) then begin
      ShowStatus(SIM_REG_DOWNLOAD);
      update := GetDownload(update); //19.10.07 nk opt ff
      OpenDownload(update);
    end else begin
      ShowStatus(SIM_REG_NOUPDATE);
    end;
  end else begin
    ShowStatus(SIM_REG_NOUPDATE);
  end;
end;

procedure TRegister.edKey1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  edKey2.SelStart := 0;
  if Length(edKey1.Text) = REG_NUMS then edKey2.SetFocus;
end;

procedure TRegister.edKey2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  edKey3.SelStart := 0;
  if Length(edKey2.Text) = REG_NUMS then edKey3.SetFocus;
end;

procedure TRegister.edKey3KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  edKey4.SelStart := 0;
  if Length(edKey3.Text) = REG_NUMS then edKey4.SetFocus;
end;

procedure TRegister.edKey4KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Length(edKey4.Text) = REG_NUMS) and btnRegister.Enabled then
    btnRegister.SetFocus
end;

procedure TRegister.edKeyAllKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  msg: TMsg;
begin
  if not (Chr(Key) in REG_KEY_VALID) then
    PeekMessage(msg, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
end;

end.
