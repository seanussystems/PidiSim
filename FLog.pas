// Log Terminal Task
// Date 26.05.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

unit FLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms, Graphics,
  StdCtrls, ComCtrls, USystem, URegistry, UForm, Global, Data, Texts, UPidi;

type
  TLog = class(TForm)
    Terminal: TListBox;
    LogStatus: TStatusBar; //13.05.07 nk add ff
    btClear: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMoving(var Msg: TwmMoving); message WM_MOVING;
    procedure btClearClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    LogLines: Integer;
  public
    procedure Print(Text: string);
  end;

const
  LOG_FONTNAME = 'Courier New';
  LOG_FONTSIZE = 8;
  LOG_FORM     = ' Lines: %d';

var
  Log: TLog;
  LogOpen: Byte;
  LogBuffer: TStringList;
  
implementation

uses FMain;

{$R *.dfm}

procedure TLog.FormCreate(Sender: TObject);
begin
  HideMaxButton(Self);    // hide maximize button
  HideCloseButton(Self);  // hide close button

  with Log do begin
    Width  := 500;
    Height := 120;
    Left   := MAINMARGIN;
    Top    := MainRect.Bottom - MainRect.Top - Height - MAINMARGIN;
    GetFormParameter(Self);
    Show;
  end;

  with Terminal do begin
    Align := alClient;
    Style := lbStandard;
    AutoComplete := False;
    ExtendedSelect := False;
    IntegralHeight := False;
    MultiSelect := False;
    Color := clCream;
    Ctl3D := False;
    Font.Name := LOG_FONTNAME;
    Font.Size := LOG_FONTSIZE;
    Font.Style := [];
    ShowHint := False;
    Sorted := False;
    Clear;
  end;

  Application.ProcessMessages;
  LogLines := cCLEAR;
  LogOpen  := cINIT;
end;

procedure TLog.FormActivate(Sender: TObject);
begin //13.05.07 nk add
  AddStatusButton(LogStatus, btClear, 0);
end;

procedure TLog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LogOpen := cOFF;
  SetFormParameter(Self);
  Action := caFree;
end;

procedure TLog.FormMoving(var Msg: TwmMoving);
begin
  LimitFormMove(MainRect, Msg);
end;

//------------------------------------------------------------------------------
// PRINT - DELPHI implementation for Tiger print
//------------------------------------------------------------------ 17.02.07 --
procedure TLog.Print(Text: string);
var
  l: Long;
begin
  LogBuffer.Append(Text);

  if (LogOpen = cINIT) and (LogBuffer.Count > cCLEAR) then begin
    for l := 0 to LogBuffer.Count - 1 do begin
      with Terminal do begin
        Items.Append(LogBuffer[l]);
        Selected[Items.Count - 1] := True;
      end;
      Inc(LogLines);
      LogStatus.Panels[1].Text := Format(LOG_FORM, [LogLines]);
    end;

    LogBuffer.Clear;
  end;

  Application.ProcessMessages;
end;

procedure TLog.btClearClick(Sender: TObject);
begin //13.05.07 nk add
  LogLines := cCLEAR;
  LogBuffer.Clear;
  Terminal.Clear;
  Terminal.SetFocus;
  LogStatus.Panels[1].Text := Format(LOG_FORM, [LogLines]);
  Application.ProcessMessages;
end;

initialization
  LogBuffer := TStringList.Create;

finalization
  LogBuffer.Free;

end.
