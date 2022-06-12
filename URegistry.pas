// Registry Handling and Program Registration
// Date 20.12.20
// Norbert Koechli
// Copyright ©2006-2020 seanus systems

/// NOTE: A standard user on XP/Vista/W7 does NOT have read/write permissions
///       to HKLM, but on it's own HKCU (RegProfil=rpUser)
///       User needs Administration privileges to write to HKLM (RegProfil=rpSystem)

// 28.08.08 nk add RegInitFolder in ReadSettings and SaveSettings
// 06.09.08 nk add RegOperator (written to registry by InstallShield)
// 23.06.09 nk add bit coded RegEnable (REG_KEY_ENABLE) to enable program features
// 25.08.09 nk add compiler switch STANDALONE for Freely Distributable Edition
// 31.08.09 nk opt set access permissions Reg.Access := KEY_READ or KEY_WRITE
// 16.06.10 nk add RegDepartment and REG_KEY_DEPT for users 'Department'
// 22.06.10 nk opt expand the enabling code from 6 to 8 chars
// 29.09.10 nk upd to Delphi XE (2011) Unicode UTF-16LE (Code site 1200)
// 23.10.10 nk add RegScreenSnap and REG_SCREEN_SNAP to set TForm.ScreenSnap
// 21 11.10 nk add support for reading and writing REG_MULTI_SZ Unicode values
// 17.12.11 nk add status texts for 'Invalid department' and 'Invalid installation'
// 19.02.14 nk upd to Delphi XE3 (VER240 Version 24)
// 11.10.15 nk opt for XE7 / V5 / Visual styles
// 25.02.16 nk add RegAddress and RegLocation for new client-based installation
// 08.03.17 nk add REG_KEY_PROGRAM = 'ProgramFolder' and REG_KEY_REGPATH = 'RegistryPath'
// 18.05.19 nk add REG_KEY_UPDATE and RegUpdate to check for current update build in registry

unit URegistry;

interface

uses
  Windows, Messages, SysUtils, Forms, Classes, Menus, Variants, Math, StrUtils,
  Registry, UGlobal;

type
  TRegProfil = (rpUser, rpSystem);

const
  REG_NUMS      = 4;
  REG_CODES     = 6;                                                            //length of enabling code
  REG_CODELEN   = 8;
  REG_CHARS     = 16;
  REG_MINPOS    = 0;
  REG_MINDIM    = 10;
  REG_TIMEOUT   = 5000; //[ms]

  REG_FULL      = 0;                                                            //correspondes with RegMessages
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
  REG_ISUPDATE  = 12;
  REG_ENABLE    = 13;
  REG_DEPT      = 14;
  REG_NOINSTALL = 15;
  REG_ADDRESS   = 16; //27.02.16 nk add
  REG_LOCATION  = 17; //25.02.16 nk add
  REG_NOFILE    = 18; //03.03.16 nk add
  REG_DOWNFILES = 19; //V5//04.01.17 nk add

  REG_MULTIDEL      = ';';
  REG_NUM_VALID     = [#8, #13, #46, #48..#57];                                 //0..9
  REG_KEY_VALID     = [#8, #13, #46, #48..#57, #65..#90];                       //0..9, A..Z
  REG_KEY_LEFT      = 'Left';
  REG_KEY_TOP       = 'Top';
  REG_KEY_WIDTH     = 'Width';
  REG_KEY_HEIGHT    = 'Height';
  REG_KEY_STATE     = 'State';
  REG_HEADER        = 'REGEDIT4';
  REG_SOFTWARE      = '\SOFTWARE\';
  REG_DEFAULT       = 'seanus systems\Settings\';
  REG_FULLVERS      = 'Full Version';
  REG_TRIALVERS     = 'Trial Version';
  REG_FREEDEMO      = 'Free Demo Version'; //51//08.07.18 nk add
  REG_TESTVERS      = 'Test Version';
  REG_CLIENTVERS    = 'Client Version';
  REG_TRAININGVERS  = 'Training Version';
  REG_REGISTERED    = 'registered';            //V5//17.05.15 nk add
  REG_UNREGISTER    = 'unregistered';
  REG_ENV_PATH      = 'Path';
  REG_ENV_USER      = 'Environment';
  REG_ENV_MACHINE   = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

  REG_SHOW_HINTS    = 'ShowHints';
  REG_SHOW_BALLOON  = 'ShowBalloon';
  REG_BEEP_ERROR    = 'BeepError';
  REG_BEEP_MESSAGE  = 'BeepMessage';
  REG_INIT_FOLDER   = 'InitFolder';
  REG_SCREEN_SNAP   = 'ScreenSnap';

  REG_KEY_CONTROL   = 'ControlCode';
  REG_KEY_LICENSE   = 'License';
  REG_KEY_ENABLE    = 'EnableCode';
  REG_KEY_FIRSTNAME = 'FirstName';
  REG_KEY_LASTNAME  = 'LastName';
  REG_KEY_ADDRESS   = 'Address';   //27.02.16 nk add
  REG_KEY_LOCATION  = 'Location';  //25.02.16 nk add
  REG_KEY_DATABASE  = 'Database';  //28.02.16 nk add
  REG_KEY_OPERATOR  = 'Operator';
  REG_KEY_FULLVERS  = 'FullVersion';
  REG_KEY_COMPANY   = 'Organisation';
  REG_KEY_DEPT      = 'Department';
  REG_KEY_VERSION   = 'Version';
  REG_KEY_UPDATE    = 'Update';
  REG_KEY_SAVESET   = 'SaveSettings';
  REG_KEY_DATETIME  = 'DateTime';
  REG_KEY_SIGNUM    = 'Signature';
  REG_KEY_PROGRAM   = 'ProgramFolder'; //V5//08.03.17 nk add ff
  REG_KEY_REGPATH   = 'RegistryPath';

  REG_VAL_LICENSE   = 'License key: ';
  REG_VAL_ENABLE    = 'Enabling code: ';
  REG_VAL_FIRSTNAME = 'First name: ';
  REG_VAL_LASTNAME  = 'Last name: ';
  REG_VAL_ADDRESS   = 'Address: ';   //27.02.16 nk add
  REG_VAL_LOCATION  = 'Location: ';  //25.02.16 nk add
  REG_VAL_COMPANY   = 'Organisation: ';
  REG_VAL_DEPT      = 'Department: ';
  REG_VAL_VERSION   = 'Version: ';
  REG_VAL_UPDATE    = 'Update: ';
  REG_VAL_PORGRAM   = 'Program: ';
  REG_VAL_ORDER     = 'Order: ';
  REG_VAL_LICENSING = 'Licensing: ';
  REG_VAL_USER      = 'Registered user: ';
  REG_VAL_LIBNAME   = 'Library file name: ';
  REG_VAL_LIBFULL   = 'Library full size: ';
  REG_VAL_LIBSIZE   = 'Library file size: ';
  REG_VAL_LIBPATH   = 'Library file path: ';
  REG_VAL_SIGNUM    = 'Signature: ';
  REG_VAL_STATUS    = 'Status: ';
  REG_VAL_DATETIME  = 'Date and time: ';

  HK_CR = 'HKEY_CLASSES_ROOT';
  HK_CU = 'HKEY_CURRENT_USER';
  HK_LM = 'HKEY_LOCAL_MACHINE';
  HK_US = 'HKEY_USERS';
  HK_PD = 'HKEY_PERFORMANCE_DATA';
  HK_CC = 'HKEY_CURRENT_CONFIG';
  HK_DD = 'HKEY_DYN_DATA';
  HK_UK = 'HKEY_UNKNOWN';

  //NOTE: User needs Admin privileges to write to HKEY_LOCAL_MACHINE (RegProfil=rpSystem)
  RegEnviroment: array[TRegProfil] of record
    Root: HKEY;
    Key: string
  end = ((Root: HKEY_CURRENT_USER;  Key: REG_ENV_USER),
         (Root: HKEY_LOCAL_MACHINE; Key: REG_ENV_MACHINE));

  RegFreeVers: array[0..2] of string = (
    'Freely',
    'Distributable',
    'Edition');

  //03.03.16 nk old=REG_NOFILE / add REG_ADDRESS and REG_LOCATION
  //V5//04.01.17 nk old=REG_NOFILE
  RegMessages: array[REG_FULL..REG_DOWNFILES] of string = (
    'Program is installed and registered',
    'Program is registered',
    'Open web site...',
    'Check for program updates...',
    'Cannot contact web server!',
    'Unregistered trial version',
    'Invalid organisation!',
    'Invalid first name!',
    'Invalid last name!',
    'Invalid registration - verify your license data!',
    'No updates available',
    'Unregistered program version - enter your license data', //V5//add enter...
    'Update available',
    'Invalid enabling code!',
    'Invalid department!',
    'Invalid installation!',
    'Invalid address',         //27.02.16 nk add
    'Invalid location',        //25.02.16 nk add
    'Cannot download file',    //03.03.16 nk add
    'Download files from web server...'); //V5//04.01.17 nk add

var
  RegOk: Boolean;
  RegTrial: Boolean;
  RegInit: Boolean;
  RegShowHints: Boolean;
  RegShowBalloon: Boolean;
  RegBeepError: Boolean;
  RegBeepMessage: Boolean;
  RegScreenSnap: Boolean;
  RegRoot: HKey;
  RegDefRoot: HKey;
  RegSize: Int64;
  RegWidth: Integer;
  RegHeight: Integer;
  RegVers: string;
  RegUpdate: string; //51//18.05.19 nk add
  RegPath: string;
  RegMain: string;
  RegDefPath: string;
  RegFirstName: string;
  RegLastName: string;
  RegAddress: string;  //27.02.16 nk add
  RegLocation: string; //25.02.16 nk add
  RegOperator: string;
  RegCompany: string;
  RegDepartment: string;
  RegEnable: string;
  RegLicenseKey: string;
  RegControlKey: string;
  RegMail: string;
  RegProg: string;
  RegInitFolder: string;
  RegSignum: string;
  function GetRegString(RegKey, RegName, RegDefault: string; RegRoot: HKey = HKEY_CURRENT_USER): string;
  function SetRegString(RegKey, RegName, RegValue: string; RegRoot: HKey = HKEY_CURRENT_USER): Boolean;
  function GetRegStrings(RegKey, RegName: string; RegPart: Integer; RegRoot: HKey = HKEY_CURRENT_USER): string;
  function SetRegStrings(RegKey, RegName: string; RegValues: TStrings; RegRoot: HKey = HKEY_CURRENT_USER): Boolean;
  function GetFormValue(Sender: TObject; Key, Def: string): string;
  function SetFormValue(Sender: TObject; Key, Val: string): Boolean;
  function ReadSettings: Boolean;
  function SaveSettings: Boolean;
  function ReadMultiString(Reg: TRegistry; RegKey: string; RegPart: Integer = 0): string;
  function DeleteRegKey(RegKey: string; RegRoot: HKey = HKEY_CURRENT_USER): Boolean;
  function ValidLicenseKey(LicenseKey: string; WithDel: Boolean = True): string;
  function SplitLicenseKey(LicenseKey: string): string;
  function GetEnvVariable(RegProfil: TRegProfil; EnvKey: string): string;
  procedure SetEnvVariable(RegProfil: TRegProfil; EnvKey, EnvVal: string);
  procedure SetFormParameter(Sender: TObject);                                  //same names as in IniUnit!!
  procedure GetFormParameter(Sender: TObject; PosOnly: Boolean = False);
  procedure ExportRegistry(RegRoot: HKEY; RegPath, RegFile: string);

implementation

function GetRegString(RegKey, RegName, RegDefault: string; RegRoot: HKey = HKEY_CURRENT_USER): string;
var //RegKey like '\SOFTWARE\seanus systems\MailReader\'
  reg: TRegistry;
begin
  Result := cEMPTY;
  reg := TRegistry.Create(KEY_READ);

  with reg do begin
    try
      Access := KEY_READ;

      if RegRoot = null then
        RootKey := RegDefRoot
      else
        RootKey := RegRoot;

      if OpenKey(RegKey, False) then begin                                      //False=Do not create key
        Result := ReadString(RegName);
        CloseKey;
      end;
    except
      //ignore
    end;
    Free;
  end;

  if Result = cEMPTY then Result := RegDefault;
end;

function SetRegString(RegKey, RegName, RegValue: string; RegRoot: HKey = HKEY_CURRENT_USER): Boolean;
var //RegKey like '\SOFTWARE\seanus systems\MailReader\'
  reg: TRegistry;
begin
  Result := False;
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);

  with reg do begin
    try
      Access := KEY_READ or KEY_WRITE;

      if RegRoot = null then
        RootKey := RegDefRoot
      else
        RootKey := RegRoot;

      if OpenKey(RegKey, True) then begin                                       //True=Create key if not exist
        WriteString(RegName, RegValue);
        if ReadString(RegName) = RegValue then Result := True;
        CloseKey;
      end;
    except
      //ignore
    end;
    Free;
  end;
end;

function GetRegStrings(RegKey, RegName: string; RegPart: Integer; RegRoot: HKey = HKEY_CURRENT_USER): string;
var //get REG_MULTI_SZ strings from registry and return delimiter separated values as string
  reg: TRegistry;     //RegPart 1..n, 0=all - delimiter = REG_MULTIDEL
begin
  Result := cEMPTY;
  reg := TRegistry.Create(KEY_READ);

  with reg do begin
    try
      Access := KEY_READ;

      if RegRoot = null then
        RootKey := RegDefRoot
      else
        RootKey := RegRoot;

      if OpenKey(RegKey, False) then begin                                      //False=Do not create key
        Result := ReadMultiString(reg, RegName, RegPart);
        CloseKey;
      end;
    except
      //ignore
    end;
    Free;
  end;
end;

function SetRegStrings(RegKey, RegName: string; RegValues: TStrings; RegRoot: HKey = HKEY_CURRENT_USER): Boolean;
var //write RegValue string list as REG_MULTI_SZ into the registry
  i, rnum: Integer;   //delete value(s) if RegValues is empty
  list, val: string;
  reg: TRegistry;
begin
  Result := False;
  list := cEMPTY;
  rnum := RegValues.Count;

  if rnum > 0 then begin
    for i := 0 to rnum - 1 do begin
      val := Trim(RegValues[i]);
      if val <> cEMPTY then
        list := list + val + cNUL;                                              //like 'multiple'#0'strings'#0'in one'#0'registry'#0'value'#0
    end;
  end else begin
    list := cNUL;                                                               //delete value(s)
  end;

  reg := TRegistry.Create(KEY_READ or KEY_WRITE);

  with reg do begin
    try
      Access := KEY_READ or KEY_WRITE;

      if RegRoot = null then
        RootKey := RegDefRoot
      else
        RootKey := RegRoot;

      if OpenKey(RegKey, True) then begin                                       //True=Create key if not exist
        rnum   := Length(list) * SizeOf(list[1]);                               //size in byte for Unicode string
        Result := (RegSetValueEx(
                   CurrentKey,
                   PChar(RegName),
                   0,
                   REG_MULTI_SZ,
                   PChar(list),
                   rnum + 1) = ERROR_SUCCESS);                                  //add 1 to automatic append one cNUL
      end;
    except
      //ignore
    end;
    Free;
  end;
end;

function ReadMultiString(Reg: TRegistry; RegKey: string; RegPart: Integer = 0): string;
//read REG_MULTI_SZ strings from registry - delimiter = REG_MULTIDEL
var               //RegKey like 'HistoryList'
  size: Integer;  //Remark: Registry key must be open - RegPart 1..n, 0=all
  buff: Pointer;

  function Bin2String(Buff: Pointer): string;
  var
    p: Integer;
    b: PChar;
    s: string;
  begin
    Result := cEMPTY;
    p := 1;
    b := Buff;

    while b^ <> cNUL do begin
      s := Trim(string(b));
      if s <> cEMPTY then
        Result := Result + s;
      if p = RegPart then Exit;
      Result := Result + REG_MULTIDEL;
      Inc(b, StrLen(b) + 1);
      Inc(p);
    end;
  end;

begin
  Result := cEMPTY;
  buff := nil;

  try
    size := Reg.GetDataSize(RegKey);
    GetMem(buff, size);
    Reg.ReadBinaryData(RegKey, buff^, size);
    Result := Bin2String(buff);
  finally
    FreeMem(buff);
  end;
end;

function DeleteRegKey(RegKey: string; RegRoot: HKey = HKEY_CURRENT_USER): Boolean;
var //RegKey like '\SOFTWARE\seanus systems\MailReader\'
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);

  with reg do begin
    try
      Access := KEY_READ or KEY_WRITE;

      if RegRoot = null then
        RootKey := RegDefRoot
      else
        RootKey := RegRoot;

      Result := DeleteKey(RegKey);
    except
      Result := False;
    end;
    Free;
  end;
end;

function ValidLicenseKey(LicenseKey: string; WithDel: Boolean = True): string;
var //validate LicenseKey key and return the format:
  i, cnum: Integer;  //WithDel = True : 'AAAA-BBBB-CCCC-DDDD'
  c: Char;           //WithDel = False: 'AAAABBBBCCCCDDDD'
  license: string;
begin
  Result  := cEMPTY;
  license := cEMPTY;
  cnum    := Length(LicenseKey);

  if cnum = REG_CHARS then begin                                                //format 'AAAABBBBCCCCDDDD'
    for i := 1 to cnum do begin
      c := LicenseKey[i];
      if not CharInSet(c, REG_KEY_VALID) then Exit;
    end;
    license := SplitLicenseKey(LicenseKey);
  end;

  if cnum = REG_CHARS + 3 then begin                                            //format 'AAAA-BBBB-CCCC-DDDD'
    for i := 1 to cnum do begin
      c := LicenseKey[i];
      if (i mod (REG_NUMS + 1)) = 0 then begin
        if c <> cDASH then Exit;
      end else begin
        if not CharInSet(c, REG_KEY_VALID) then Exit;
      end;
    end;
    license := LicenseKey;
  end;

  if WithDel then
    Result := license
  else
    Result := StringReplace(license, cDASH, cEMPTY, [rfReplaceAll]);
end;

function SplitLicenseKey(LicenseKey: string): string;
var //return the license key string in the format 'AAAA-BBBB-CCCC-DDDD'
  num: Integer;
begin
  Result := cEMPTY;

  if (LicenseKey <> cEMPTY) and (LicenseKey <> REG_UNREGISTER) then begin
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

procedure SetFormParameter(Sender: TObject);
begin //save form position and dimension to registry
  with Sender as TForm do begin
    if RegPath = cEMPTY then RegPath := RegDefPath;
    if WindowState = wsMinimized then Exit;                                     //ignore minimized windows
    if WindowState = wsMaximized then begin
      SetRegString(RegPath + Name, REG_KEY_STATE,  ISON);
    end else begin
      SetRegString(RegPath + Name, REG_KEY_STATE,  ISOFF);
      SetRegString(RegPath + Name, REG_KEY_LEFT,   IntToStr(Left));
      SetRegString(RegPath + Name, REG_KEY_TOP,    IntToStr(Top));
      SetRegString(RegPath + Name, REG_KEY_WIDTH,  IntToStr(Width));
      SetRegString(RegPath + Name, REG_KEY_HEIGHT, IntToStr(Height));
    end;
  end;
end;

procedure GetFormParameter(Sender: TObject; PosOnly: Boolean = False);
begin //load form position and dimension from registry
  with Sender as TForm do begin
    if RegPath = cEMPTY then RegPath := RegDefPath;
    Left := Max(StrToInt(GetRegString(RegPath + Name, REG_KEY_LEFT, IntToStr(Left))), REG_MINPOS);
    Top  := Max(StrToInt(GetRegString(RegPath + Name, REG_KEY_TOP,  IntToStr(Top))),  REG_MINPOS);

    if not PosOnly then begin
      Width  := Max(StrToInt(GetRegString(RegPath + Name, REG_KEY_WIDTH,  IntToStr(Width))),  REG_MINDIM);
      Height := Max(StrToInt(GetRegString(RegPath + Name, REG_KEY_HEIGHT, IntToStr(Height))), REG_MINDIM);

      if (GetRegString(RegPath + Name, REG_KEY_STATE, ISOFF) = ISON) or         //maximized = ISON and no overboarding
         (Width > RegWidth) or (Height > RegHeight) then begin
        WindowState := wsMaximized;
      end else begin
        WindowState := wsNormal;
      end;
    end;
  end;
end;

function SetFormValue(Sender: TObject; Key, Val: string): Boolean;
begin //save form value to registry
  with Sender as TForm do
    Result := SetRegString(RegPath + Name, Key, Val);
end;

function GetFormValue(Sender: TObject; Key, Def: string): string;
begin //load form value from regitry - Def = default value
  with Sender as TForm do
    Result := GetRegString(RegPath + Name, Key, Def);
end;

function GetEnvVariable(RegProfil: TRegProfil; EnvKey: string): string;
var //read environment variable from users or system registry key EnvKey
  reg: TRegistry;
begin
  Result := cEMPTY;
  reg := TRegistry.Create(KEY_READ);

  with reg, RegEnviroment[RegProfil] do begin
    try
      Access  := KEY_READ;
      RootKey := Root;
      if OpenKey(Key, False) then begin
        Result := ReadString(EnvKey);
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

procedure SetEnvVariable(RegProfil: TRegProfil; EnvKey, EnvVal: string);
var //write environment variable EnvVal to users or system registry key EnvKey
  res: Cardinal;   //NOTE: User needs Admin privileges to write to HKLM (RegProfil=rpSystem)
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);

  with reg, RegEnviroment[RegProfil] do begin
    try
      Access  := KEY_READ or KEY_WRITE;
      RootKey := Root;
      if OpenKey(Key, True) then begin
        WriteExpandString(EnvKey, EnvVal);
        CloseKey;
        SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0,
                           lParam(PChar(REG_ENV_USER)),
                           SMTO_ABORTIFHUNG, REG_TIMEOUT, {$IF CompilerVersion >= 24.0}@{$ENDIF}res);
      end;
    finally
      Free;
    end;
  end;
end;

function SaveSettings: Boolean;
begin //save global program settings into registry
  Result := False;
  if RegMain = cEMPTY then Exit;

  try
    SetRegString(RegMain, REG_SHOW_HINTS,   BoolToStr(RegShowHints));
    SetRegString(RegMain, REG_SHOW_BALLOON, BoolToStr(RegShowBalloon));
    SetRegString(RegMain, REG_BEEP_ERROR,   BoolToStr(RegBeepError));
    SetRegString(RegMain, REG_BEEP_MESSAGE, BoolToStr(RegBeepMessage));
    SetRegString(RegMain, REG_SCREEN_SNAP,  BoolToStr(RegScreenSnap)); //V5//11.10.15 nk add
    SetRegString(RegMain, REG_INIT_FOLDER,  RegInitFolder);
    Result := True;
  except
    Result := False;
  end;
end;

function ReadSettings: Boolean;
begin //read saved program settings from registry into global values
  Result := False;
  if RegMain = cEMPTY then Exit;

  try
    RegShowHints   := StrToBool(GetRegString(RegMain, REG_SHOW_HINTS,   ISTRUE));
    RegShowBalloon := StrToBool(GetRegString(RegMain, REG_SHOW_BALLOON, ISTRUE));
    RegBeepError   := StrToBool(GetRegString(RegMain, REG_BEEP_ERROR,   ISTRUE));
    RegBeepMessage := StrToBool(GetRegString(RegMain, REG_BEEP_MESSAGE, ISFALSE));
    RegScreenSnap  := StrToBool(GetRegString(RegMain, REG_SCREEN_SNAP,  ISTRUE));
    RegInitFolder  := ExtractFilePath(Application.ExeName);
    RegInitFolder  := GetRegString(RegMain, REG_INIT_FOLDER,  RegInitFolder);

    if RegInitFolder <> cEMPTY then
      RegInitFolder := IncludeTrailingPathDelimiter(RegInitFolder);
    Result := True;
  except
    Result := False;
  end;
end;

procedure ExportRegistry(RegRoot: HKEY; RegPath, RegFile: string);
var //export a registry path recursively in a file
  slen: Integer;  //a .reg file can be used to import the whole registry path
  p: PChar;       //Source: Arthur Hoornweg (www.swissdelphicenter.ch)
  tmp: TextFile;
  reg: TRegistry;

  function DblBackSlash(T: string): string;
  var //replace single '\' with double backslashes '\\'
    k: Longint;
  begin
    Result := T;
    for k := Length(T) downto 1 do
      if Result[k] = cBACK then Insert(cBACK, Result, k);
  end;

  procedure ProcessBranch(root: string);
  var //recursive sub-procedure
    i, j, k: Longint;
    s, t: string;
    vals, keys: TStringList;
  begin
    s    := HK_UK;
    keys := nil;
    WriteLn(tmp);

    if RegRoot = HKEY_CLASSES_ROOT     then s := HK_CR;                         //case RegRoot of //case (32bit) doesn't work with HKEY (64bit)
    if RegRoot = HKEY_CURRENT_USER     then s := HK_CU;
    if RegRoot = HKEY_LOCAL_MACHINE    then s := HK_LM;
    if RegRoot = HKEY_USERS            then s := HK_US;
    if RegRoot = HKEY_PERFORMANCE_DATA then s := HK_PD;
    if RegRoot = HKEY_CURRENT_CONFIG   then s := HK_CC;
    if RegRoot = HKEY_DYN_DATA         then s := HK_DD;

    WriteLn(tmp, cLBRACK + s + root + cRBRACK);                                 //write section name in brackets
    reg.OpenKey(root, False);

    try
      vals := TStringList.Create;
      try
        keys := TStringList.Create;
        try
          reg.GetValueNames(vals);                                              //get all value names
          reg.GetKeyNames(keys);                                                //get all sub-branches

          for i := 0 to vals.Count - 1 do begin                                 //write all the values first
            s := vals[i];
            t := s;                                                             //s=value name

            if s = cEMPTY then
              s := cAT                                                          //empty means "default value" written as @
            else
              s := cQUOTE + s + cQUOTE;                                         //else put in quotes

            Write(tmp, DblBackSlash(s) + cEQUAL);                               //write the name of the key to the file

            case reg.GetDataType(t) of
              rdString, rdExpandString:                                         //string type
                WriteLn(tmp, cQUOTE + DblBackSlash(reg.ReadString(t) + cQUOTE));

              rdInteger:                                                        //32-bit unsigned long integer
                WriteLn(tmp, 'dword:' + IntToHex(reg.ReadInteger(t), 8));

              rdBinary:                                                         //write an array of hex bytes if data is 'binary.' Perform a line feed
                begin                                                           //after approx. 25 numbers so the line length stays within limits
                  Write(tmp, 'hex:');
                  j := reg.GetDataSize(t);
                  GetMem(p, j);
                  reg.ReadBinaryData(t, p^, J);                                 //read in the data, treat as pchar

                  for k := 0 to j - 1 do begin
                    Write(tmp, IntToHex(Byte(p[k]), 2));                        //write byte as hex
                    if k <> j - 1 then begin                                    //not yet last byte?
                      Write(tmp, cCOMMA);                                       //then write comma
                      if (k > 0) and ((k mod 25) = 0) then                      //line too long?
                        WriteLn(tmp, cBACK);                                    //then write BackSlash + LineFeed
                    end;
                  end;

                  FreeMem(p, j);
                  WriteLn(tmp);
                end;
              else
                WriteLn(tmp, cBLANK);                                           //write an empty string if datatype illegal/unknown
            end;
          end;
        finally
          reg.CloseKey;
        end;
      finally
        vals.Free;
      end;

      for i := 0 to keys.Count - 1 do                                           //now all values are written, we process all subkeys
        ProcessBranch(root + cBACK + keys[i]);                                  //perform this process recursively...
    finally
      keys.Free;
    end;
  end;

begin
  slen := Length(RegPath);
  if RegPath[slen] = cBACK then                                                 //cut trailing backslash
    SetLength(RegPath, slen - 1);

  FileMode  := fmOpenReadWrite;
  Assignfile(tmp, RegFile);                                                     //create an empty text file

  try
    CloseFile(tmp);                                                             //make sometimes I/O error 103 !?!
  except
    IOResult;                                                                   //ignore if file was already closed
  end;

  Rewrite(tmp);
  WriteLn(tmp, REG_HEADER);                                                     //write the 'magic key' for regedit

  reg := TRegistry.Create;

  try
    reg.Rootkey := RegRoot;
    ProcessBranch(RegPath);                                                     //main function that writes the branch and all subbranches
  finally
    reg.Free;
    Close(tmp);
  end;
end;

initialization
  RegOk          := False;
  RegTrial       := False;
  RegInit        := False;
  RegShowHints   := True;
  RegShowBalloon := True;
  RegBeepError   := True;
  RegBeepMessage := False;
  RegScreenSnap  := True;
  RegFirstName   := cEMPTY;
  RegLastName    := cEMPTY;
  RegAddress     := cEMPTY;  //27.02.16 nk add
  RegLocation    := cEMPTY;  //25.02.16 nk add
  RegOperator    := cEMPTY;
  RegCompany     := cEMPTY;
  RegDepartment  := cEMPTY;
  RegUpdate      := cEMPTY;  //51//18.05.19 nk add
  RegEnable      := cEMPTY;
  RegLicenseKey  := cEMPTY;
  RegControlKey  := cEMPTY;
  RegMail        := cEMPTY;
  RegPath        := cEMPTY;
  RegMain        := cEMPTY;
  RegRoot        := HKEY_CURRENT_USER;
  RegDefRoot     := HKEY_CURRENT_USER;
  RegDefPath     := REG_SOFTWARE + REG_DEFAULT;
  RegWidth       := GetSystemMetrics(SM_CXSCREEN);
  RegHeight      := GetSystemMetrics(SM_CYSCREEN);

end.
