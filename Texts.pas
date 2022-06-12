// Application Specific Multilingual Text Strings
// Date 28.05.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

// Read text lines from internal resource compiled into 'Tiger.res'
// from Tiger include file 'Texts.inc'

unit Texts;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, Dialogs, Global, UPidi;

  procedure InitText(LangNum: Byte); // 02.03.07 nk new resource version

  // Delphi internal helper functions
  procedure InitForm;                // 25.03.07 nk add DELPHI only
  function CutLine(var Line: string; var Num: Long): Long;
  function ProperStr(Text: string): string;
  function MakeHint(HintNr: Word): string; //05.05.07 nk add
  function MakeCaption(MaskNr: Word; MaskUnit: string): string; //03.05.07 nk add

const
  TYPLANG   = 0;    // text types (DELPHI only)
  TYPMASK   = -1;
  TYPHELP   = -2;
  RCFILE    = 'TEXTS';

  MAXLANG   = 2;    // number of supported languages (EN and DE)
  LANGEN    = 0;    // english
  LANGDE    = 1;    // german
  LANGFR    = 2;    // french  (not yet supported)
  LANGIT    = 3;    // italian (not yet supported)
  LANGES    = 4;    // spanish (not yet supported)

  MAXTEXT   = 350;  // number of mask text per language
  MAXHELP   = 60;   // number of help text per language
  MAXFORM   = 10;   // number of form text per language - DELPHI only
  HELPLANG  = 0;    // number of language help text

  MONLONG   = 151;  // number of first month (january)
  DAYSHORT  = 163;  // number of first weekday (mo)
  DAYLONG   = 170;  // number of first weekday (monday)
  HOLTEXT   = 177;  // number of first holiday
  LOGTEXT   = 200;  // number of first log book text
  UNITEXT   = 224;  // number of first unit text
  OBJTEXT   = 270;  // number of first object text
  SIGTEXT   = 271;  // number of dynamic signal text
  SELTEXT   = 100;  // offset for selection text

var
  Mask: array[0..MAXTEXT] of string; // mask text table
  Help: array[0..MAXHELP] of string; // help text table
  Form: array[0..MAXFORM] of string; // form text table - DELPHI only

implementation

uses SYS, FMain, FLog, Data;

//------------------------------------------------------------------------------
// INITTEXT - Initialize multilingual text string array
//   DELPHI: Get texts from internal resource RCFILE compiled from 'Texts.inc'
//------------------------------------------------------------------ 17.02.07 --
procedure InitText(LangNum: Byte);
var
  ok: Boolean;
  l, n: Long;
  typ: Long;
  line: string;
  lang: string;
  rcdat: TResourceStream;
  texts: TStringList;
begin
  lang := IntToStr(LangNum);

  if LangNum >= MAXLANG then begin
    LogError('InitText', 'Unsupported language', lang, $90);
    LangNum := LANGEN;
  end;

  for n := 0 to MAXTEXT - 1 do begin
    Mask[n] := sEMPTY;  // clear mask texts
  end;

  for n := 0 to MAXHELP - 1 do begin
    Help[n] := sEMPTY;  // clear help texts
  end;

  texts := TStringList.Create;
  rcdat := TResourceStream.Create(Hinstance, RCFILE, RT_RCDATA);
  
  try // to read text resources
    ok := False;
    texts.LoadFromStream(rcdat);

     for l := 0 to texts.Count - 1 do begin
      line := texts[l];
      typ  := CutLine(line, n);

      if (typ >= TYPLANG) and (typ < MAXLANG) then begin
        if typ = LangNum then
          ok := True
        else
          ok := False;
      end;

      if ok then begin
        case typ of
          TYPMASK: Mask[n] := line;
          TYPHELP: Help[n] := line;
        end;
      end;
    end;
  except
    LogError('InitText', 'Could not read text resource', RCFILE, $9E);
    Help[HELPLANG] := sEMPTY;
  end;

  rcdat.Free;
  texts.Free;

  if Help[HELPLANG] = sEMPTY then begin
    LogError('InitText', 'Texts not initialized - Language', lang, $99);
  end else begin
    LogEvent('InitText', 'Texts initialized - Language', Help[HELPLANG]);
  end;
end;

//------------------------------------------------------------------------------
// INITFORM - Initialize multilingual form text string array
//   DELPHI function only
//------------------------------------------------------------------ 25.03.07 --
procedure InitForm;
var
  n: Integer;
begin
  for n := 0 to MAXFORM - 1 do begin
    Form[n] := sEMPTY;  // clear form texts
  end;

  //nk//make language dep switch
  
  Form[0] := 'descend';
  Form[1] := 'ascend';
  Form[2] := 'stop';
  Form[3] := 'left';
  Form[4] := 'right';
end;

//------------------------------------------------------------------------------
// CUTLINE - Cut text lines to extract Tiger multilingual text strings
//   DELPHI function only
//------------------------------------------------------------------ 28.05.22 --
function CutLine(var Line: string; var Num: Long): Long;
var
  i: Long;
  cut: Long;
  c: Char;
  text: string;
  numb: string;
  temp: string;
begin
  Result := MAXLANG;
  Num    := TYPLANG;
  cut    := 0;
  temp   := Line;
  Line   := sEMPTY;
  numb   := sEMPTY;
  text   := sEMPTY;

  if Pos('LANGEN', temp) > 0 then Result := LANGEN;
  if Pos('LANGDE', temp) > 0 then Result := LANGDE;
  if Pos('LANGFR', temp) > 0 then Result := LANGFR;
  if Pos('LANGIT', temp) > 0 then Result := LANGIT;
  if Pos('LANGES', temp) > 0 then Result := LANGES;

  if Pos('Mask$(', temp) > 0 then Result := TYPMASK;
  if Pos('Help$(', temp) > 0 then Result := TYPHELP;

  if Result >= TYPLANG then Exit;

  temp := Trim(temp);

  for i := 1 to Length(temp) do begin
    c := temp[i];
    if c = '''' then Break;  // comment
    if (cut = 1) and (c = ')') then cut := 2;
    case cut of
      1: numb := numb + c;  // text number
      3: text := text + c;  // text line
    end;
    if (cut = 0) and (c = '(') then cut := 1;
    if (cut = 2) and (c = '=') then cut := 3;
  end;

  numb := Trim(numb); // 09.03.07 nk del try..except

  if TryStrToInt(numb, Num) then begin
    text   := Trim(text);  // 1st trim, 2nd replace => leave spaces
    Line   := StringReplace(text, '"', sEMPTY, [rfReplaceAll]);
  end else begin
    Line   := sEMPTY;
    Num    := TYPLANG;
    Result := MAXLANG;
  end;
end;

//------------------------------------------------------------------------------
// PROPERSTR - Make proper strings - 1st char in upper case rest in lower case
//   DELPHI function only
//------------------------------------------------------------------ 17.02.07 --
function ProperStr(Text : string): string;
var
  i: Long;
  cut: Long;
  len: Long;
  c: Char;
  temp: string;
begin
  Result := sEMPTY;
  cut := 0;
  temp := Trim(Text);
  len := Length(temp);

  if len > 0 then begin
    for i := 1 to len do begin
      c := Text[i];
      case cut of
        0: Result := Result + UpperCase(c);
        1: Result := Result + LowerCase(c);
      end;
      if cut = 0 then cut := 1;
      if (cut = 1) and (c = sSPACE) then cut := 0;
    end;
  end;
end;

//------------------------------------------------------------------------------
// MAKECAPTION - Return language dependend caption with unit from mask number
//   DELPHI function only
//------------------------------------------------------------------ 17.02.07 --
function MakeCaption(MaskNr: Word; MaskUnit: string): string;
begin
  Result := ProperStr(Mask[MaskNr]) + ' [' + MaskUnit + ']';
end;

//------------------------------------------------------------------------------
// MAKEHINT - Return language dependend hint from hint number
//   DELPHI function only
//------------------------------------------------------------------ 17.02.07 --
function MakeHint(HintNr: Word): string;
begin
  Result := sSPACE + Trim(Form[HintNr]) + sSPACE;
end;

end.
