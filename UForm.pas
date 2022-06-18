// Form Component Functions
// Date 26.05.14

// See FParameter for individual row coloring and left/center/right text alignment
// in a StringGrid's OnDrawCell event

// Resource file 'UForm.res' with graphic bitmaps
// Raize Components Vers. 5.2 (10.10.10 rebuilt for Delphi XE)

unit UForm;

interface

uses //XE3//26.05.14 nk add System.UITypes
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Types,
  Forms, StdCtrls, ExtCtrls, ComCtrls, CommCtrl, StrUtils, RichEdit, Grids,
  Menus, Mask, {$IFDEF TMSADVDB}AdvGrid,{$ENDIF} System.UITypes, RzCommon,
  RzEdit, RzBorder, RzPanel, RzPrgres, RzCmboBx, RzStatus, RzTreeVw, UGlobal,
  USystem;

const
  GRIDCOLS  = 255;  //max number of grid cols
  SORTNUMS  = 10;   //expand integer and real numbers to the format
  SORTPREC  = 5;    //10.5 (NNNNNNNNNN.NNNNN) before alpha sorting
  TREEDEL   = '\';
  FILTERDEL = '|';  //25.09.08 nk mov from UOffice
  SORTDOWN  = #0;
  SORTUP    = 'zzzz';

  TTM_SETDELAYTIME    = WM_USER + 3;  //ToolTip messages
  TTM_DELTOOL         = WM_USER + 5;
  TTM_NEWTOOLRECT     = WM_USER + 6;
  TTM_GETTOOLINFO     = WM_USER + 8;
  TTM_SETTOOLINFOA    = WM_USER + 9;
  TTM_TRACKACTIVATE   = WM_USER + 17;
  TTM_TRACKPOSITION   = WM_USER + 18;
  TTM_SETTIPBKCOLOR   = WM_USER + 19;
  TTM_SETTIPTEXTCOLOR = WM_USER + 20;
  TTM_SETMAXTIPWIDTH  = WM_USER + 24;
  TTM_SETTITLE        = WM_USER + 32;
  TTM_ADDTOOL         = WM_USER + 50;

  TTDT_AUTOMATIC      = 0;
  TTDT_AUTOPOP        = 2;
  TTDT_INITIAL        = 3;
  TOOLTIPS_DELAY      = 5000;  //ms
  TTS_ALWAYSTIP       = $01;   //ToolTip styles
  TTS_NOPREFIX        = $02;
  TTS_BALLOON         = $40;
  TTF_IDISHWND        = $0001;
  TTF_CENTERTIP       = $0002;
  TTF_SUBCLASS        = $0010;
  TTF_TRANSPARENT     = $0100;
  ICC_WIN95_CLASSES   = $000000FF;

  SYS_SEPARATOR       = 0;    //05.01.08 nk opt ff
  SYS_HORIZONT        = 101;  //must corresponde with bitmap
  SYS_VERTICAL        = 102;  //ID's of resource file 'UForm.res'
  SYS_CASCADE         = 103;  //add WM_USER in OnMessage event
  SYS_MAXIMIZE        = 104;  //05.01.08 nk add ff
  SYS_MINIMIZE        = 105;
  SYS_CLOSE           = 106;
  SYS_EXIT            = 107;

  BCM_FIRST           = $1600;  //24.03.08 nk add ff
  BCM_SETSHIELD       = BCM_FIRST + $000C;

  APP_ARRUP           = 'ARRUP';  //07.02.08 nk add ff
  APP_ARRDN           = 'ARRDN';
  APP_MAINICON        = 'MAINICON';  //12.01.08 nk add
  TOOLTIPS_CLASS      = 'tooltips_class32';

  MenuCaptions: array[SYS_HORIZONT..SYS_EXIT] of string = (
    'Tile windows horizontally',
    'Tile windows vertically',
    'Cascade windows',
    'Maximize',
    'Minimize',
    'Close',
    'Exit');

var
  GridSortDir: Boolean;
  GridFindNext: Boolean;
  GridSortCol: Integer;
  GridCol: Integer;
  GridRow: Integer;
  FrameBackColor: TColor;
  FrameLineColor: TColor;
  FrameTextColor: TColor;
  StatusBackColor: TColor;
  StatusTextColor: TColor;
  GridColSize: array[0..GRIDCOLS] of Integer;

type
  TUrlClickEvent = procedure(Sender: TObject; const Url: string) of object; //30.07.08 nk add

  TGridEx = class(TCustomGrid);    //reveals protected MoveRow methode

  TRichEditUrl = class(TRichEdit)  //30.07.08 nk add - hyperlink aware RichEdit
  private
    FOnUrlClick: TUrlClickEvent;
    procedure CNNotify(var Msg: TWMNotify); message CN_NOTIFY;
  protected
    procedure DoUrlClick(const Url: string);
    procedure CreateWnd; override;
  published
    property OnUrlClick : TUrlClickEvent read FOnUrlClick write FOnUrlClick;
  end;

  procedure AddStatusImage(Status: TStatusBar; Image: TImage; Panel: Integer);
  procedure AddStatusShape(Status: TStatusBar; Shape: TShape; Panel: Integer; Bord: Byte = 0);
  procedure AddStatusProgress(Status: TStatusBar; Progress: TProgressBar; Panel: Integer);
  procedure AddStatusBar(Status: TStatusBar; Progress: TRzProgressBar; Panel: Integer); //20.04.07 nk add
  procedure AddStatusMeter(Status: TStatusBar; Meter: TRzMeter; Panel: Integer);
  procedure AddStatusLabel(Status: TStatusBar; Text: TLabel; Panel: Integer);
  procedure AddStatusButton(Status: TStatusBar; Button: TButton; Panel: Integer);
  procedure AddPaneMeter(Status: TRzStatusBar; Meter: TRzMeter; Pane: TRzStatusPane);  //29.07.08 nk add
  procedure AddBalloonTip(Control: TWinControl; Icon: Integer; Title: PChar; Text: PWideChar; BackCol, TextCol: TColor);
  procedure AddMenuItem(Menu: THandle; Item: Cardinal; Text: string = cEMPTY); //05.01.08 nk opt
  procedure AddMainIcon(AppName: string); //12.01.08 nk add
  procedure AddShieldButton(Button: TButton; ShowShield: Boolean);  //24.03.08 nk add
  procedure SetProgressColor(Progress: TProgressBar; BarColor, BackColor: TColor);
  procedure Shadow(Pform: TForm; Cont: TControl; Width: Integer = 2; Color: TColor = clBtnShadow); //30.01.08 nk add
  procedure ClearGrid(Grid: TStringGrid);
{$IFDEF TMSADVDB}                               //01.09.12 nk add
  procedure ClearAdvGrid(Grid: TAdvStringGrid); //23.08.12 nk add
{$ENDIF}
  procedure GetGridColSize(Grid: TStringGrid);
  procedure DeleteGridRow(Grid: TStringGrid; DelRow: Integer);
  procedure InsertGridRow(Grid: TStringGrid; InsRow: Integer);
  procedure UnselectGrid(Grid: TStringGrid);
  procedure SortGrid(Grid: TStringGrid; SortCol, SortSub: Integer; SortDir: Boolean);
  procedure SizeGrid(Grid: TStringGrid; Size: Integer);
  procedure SelectListItem(List: TListView; Find: string; Col: Integer); //16.02.13 nk add
  procedure DeselectList(List: TListView);     //12.03.09 nk add
  procedure DeselectGrid(Grid: TStringGrid);   //20.09.08 nk add                    //27.09.09 nk add C(ol) and R(ow)
  procedure ShowGridHint(Grid: TStringGrid; X, Y: Integer; ShowHead: Boolean = False; Acol: Integer = 0; Arow: Integer = 0); //20.02.09 nk add ShowHead
  procedure ShowGridEdit(Grid: TStringGrid; Edit: TEdit; nCol, nRow: Integer);
  procedure ShowGridRzEdit(Grid: TStringGrid; Edit: TRzEdit; nCol, nRow: Integer);
  procedure ShowGridCombo(Grid: TStringGrid; Combo: TComboBox; nCol, nRow: Integer);
  procedure ShowGridRzCombo(Grid: TStringGrid; Combo: TRzComboBox; nCol, nRow: Integer);
  procedure CopyGridToList(Grid: TStringGrid; List: TListView; ColSet: TNumSet; Boxes, Check: Boolean);
  procedure WriteGrid(Grid: TStringGrid; Text: string; Rect: TRect; Alignment: TAlignment; Xcorr: Integer = 3); //16.09.12 nk add Xcorr / 21.01.12 nk add
  procedure OpenComboBox(Combo: TCustomComboBox; OpenIt, ShowIt: Boolean);
  procedure HideComboFrame(Combo: TComboBox; ShowIt: Boolean);
  procedure SortQuick(Grid: TStringGrid; var SortList: array of Integer; Min, Max, SortCol: Integer; SortDir: Boolean);
  procedure FrameLabel(Sender: TObject; Active: Boolean);
  procedure OpenPopupMenu(Control: TControl);  //30.04.10 nk add
  procedure UncheckPopupItems(Popup: TPopupMenu);
  procedure SetTreeNodeBold(Node: TTreeNode; Value: Boolean);
  procedure SetTreeNodesBold(TreeView: TTreeView; Levels: TNumSet); //24.07.07 nk add ff
  procedure ScrollLines(RichEdit: TRichEdit; LineNr: Integer = 1);  //08.10.08 nk add
  procedure SelectLine(RichEdit: TRichEdit; LineNr: Integer; ScrollTop, ScrollLeft: Boolean);
  procedure ReplaceInEdit(RichEdit: TRichEdit; Old, New: string; MatchCase: Boolean); //23.06.11 nk add
  function GetTreePath(Node: TTreeNode): string;
  function GetTreeNode(Tree: TRzTreeView; Search: string; FullPath, MatchCase: Boolean): TTreeNode;  //25.08.08 nk add MatchCase
  function SearchGrid(Grid: TStringGrid; Search: string; MatchCase, WholeWord: Boolean): Boolean;
  function GetComboIndex(Combo: TCustomComboBox; Search: string; MatchCase: Boolean; WholeWord: Boolean = True): Integer; //18.03.09 nk add WholeWord
  function IsFormOpen(const FormName: string): Boolean;
  function IsChildOpen(const FormName: TForm; const ChildName: string): Boolean;
  function IsCellSelected(Grid: TStringGrid; X, Y: Integer): Boolean; //05.07.08 nk add
  function ResourceBitmap(ResName: string): TBitmap; //07.02.08 nk add
  function GetFilterFromIndex(var Filter: string; Index: Integer): string; //25.09.08 nk mov from UOffice
  function GetIndexFromFilter(Filter, FileName: string): Integer;  //25.09.08 nk mov from UOffice

implementation

{$R UForm.res}  //31.12.07 nk add menu bitmaps

procedure TRichEditUrl.DoUrlClick(const Url: string);
begin
  if Assigned(FOnUrlClick) then OnUrlClick(Self, Url);
end;

procedure TRichEditUrl.CNNotify(var Msg: TWMNotify);
var
  p: TENLink;
  url: string;
begin
  if Msg.NMHdr^.code = EN_LINK then begin
    p := TENLink(Pointer(Msg.NMHdr)^);
    if p.Msg = WM_LBUTTONDOWN then begin
      try
        SendMessage(Handle, EM_EXSETSEL, 0, Longint(@(p.chrg)));
        url := SelText;
        DoUrlClick(url);
      except
        //ignore
      end;
    end;
  end;

 inherited;
end;

procedure TRichEditUrl.CreateWnd;
var
  mask: LongWord;   //BUG Word = ERangeError
begin
  inherited CreateWnd;

  SendMessage(Handle, EM_AUTOURLDETECT, 1, 0);
  mask := SendMessage(Handle, EM_GETEVENTMASK, 0, 0);
  SendMessage(Handle, EM_SETEVENTMASK, 0, mask or ENM_LINK);
end;

procedure AddStatusImage(Status: TStatusBar; Image: TImage; Panel: Integer);
var //place an Image in the StatusBar (ComCtrls)
    //call this procedure in the OnShow-Event of the form!!
  rect: TRect;
begin
  Status.Perform(SB_GETRECT, Panel, Integer(@rect));
  rect.Left := rect.Right - Image.Width - 2;
  rect.Right := rect.Right + 2;
  Image.Parent := Status;
  Image.BoundsRect := rect;
end;

procedure AddStatusShape(Status: TStatusBar; Shape: TShape; Panel: Integer; Bord: Byte = 0);
var //place a Shape in the StatusBar (ComCtrls)
    //call this procedure in the OnShow-Event of the form!!
  rect: TRect;
begin
  Status.Perform(SB_GETRECT, Panel, Integer(@rect));

  if Bord > 0 then begin //add border
    rect.Top := rect.Top + Bord;
    rect.Bottom := rect.Bottom - Bord;
    rect.Left := rect.Left + Bord;
    rect.Right := rect.Right - Bord;
  end;
  
  Shape.Parent := Status;
  Shape.BoundsRect := rect;
end;

procedure AddStatusProgress(Status: TStatusBar; Progress: TProgressBar; Panel: Integer);
var //place a ProgressBar in the StatusBar (ComCtrls)
    //call this procedure in the OnShow-Event of the form!!
  rect: TRect;
begin
  Status.Perform(SB_GETRECT, Panel, Integer(@rect));
  Progress.Parent := Status;
  Progress.BoundsRect := rect;
end;

procedure AddStatusBar(Status: TStatusBar; Progress: TRzProgressBar; Panel: Integer);
var //place a RzProgressBar (Raize) in the StatusBar (ComCtrls and RzProgres)
    //call this procedure in the OnShow-Event of the form!!
  rect: TRect;
begin
  Status.Perform(SB_GETRECT, Panel, Integer(@rect));
  Progress.Parent := Status;
  Progress.BoundsRect := rect;
end;

procedure AddStatusMeter(Status: TStatusBar; Meter: TRzMeter; Panel: Integer);
var //place a RzMeter (Raize) in the StatusBar (ComCtrls and RzBorder)
    //call this procedure in the OnShow-Event of the form!!
  rect: TRect;
begin
  Status.Perform(SB_GETRECT, Panel, Integer(@rect));
  rect.Left := rect.Left;
  rect.Right := rect.Right - 2;
  rect.Top := rect.Top + 1;
  rect.Bottom := rect.Bottom - 1;
  Meter.Parent := Status;
  Meter.BoundsRect := rect;
end;

procedure AddStatusLabel(Status: TStatusBar; Text: TLabel; Panel: Integer);
var //place a Label in the StatusBar (ComCtrls)
    //call this procedure in the OnShow-Event of the form!!
  rect: TRect;
begin
  Status.Perform(SB_GETRECT, Panel, Integer(@rect));
  Text.Parent := Status;
  Text.BoundsRect := rect;
end;

procedure AddStatusButton(Status: TStatusBar; Button: TButton; Panel: Integer);
var //place a Button in the StatusBar (ComCtrls)
    //call this procedure in the OnShow-Event of the form!!
  rect: TRect;
begin
  Status.Perform(SB_GETRECT, Panel, Integer(@rect));
  Button.Parent := Status;
  Button.BoundsRect := rect;
end;

procedure AddPaneMeter(Status: TRzStatusBar; Meter: TRzMeter; Pane: TRzStatusPane);
begin //place a RzMeter in the StatusPane (Raize) (ComCtrls, RzStatus, and RzPanel)
  //Important: Place the RzMeter on the Pane of the StatusBar
  //call this procedure in the OnShow-Event of the form!!
  with Meter do begin
    Parent := Status;
    Left   := Pane.Left   + 1;
    Width  := Pane.Width  - 3;
    Top    := Pane.Top    + 3;
    Height := Pane.Height - 6;
    BringToFront;
  end;
end;

procedure SetProgressColor(Progress: TProgressBar; BarColor, BackColor: TColor);
begin
  Progress.Brush.Color := BackColor;
  SendMessage(Progress.Handle, PBM_SETBARCOLOR, 0, BarColor);
end;

procedure Shadow(Pform: TForm; Cont: TControl; Width: Integer = 2; Color: TColor = clBtnShadow);
var //must be places in the OnPaint event of the parent Form (Pform)
  rect: TRect; //ok with TEdit on Form, dont work with TPanel !?!
  old: TColor;
begin
  if Cont.Visible then begin
    rect := Cont.BoundsRect;
    rect.Left := rect.Left + Width;
    rect.Top := rect.Top + Width;
    rect.Right := rect.Right + Width;
    rect.Bottom := rect.Bottom + Width;
    old := Pform.Canvas.Brush.Color;
    Pform.Canvas.Brush.Color := Color;
    Pform.Canvas.FillRect(rect);
    Pform.Canvas.Brush.Color := old;
    Cont.BringToFront;
    Cont.Repaint;
  end;
end;

procedure ClearGrid(Grid: TStringGrid);
var //20.09.08 nk opt ff
  r: Integer;
begin
  with Grid do begin
    try
      for r := 0 to RowCount - 1 do Rows[r].Clear;
      Row := FixedRows;
    except
      //ignore
    end;
  end;
end;

{$IFDEF TMSADVDB} //01.09.12 nk add
procedure ClearAdvGrid(Grid: TAdvStringGrid);
var //23.08.12 nk add
  r: Integer;
begin
  with Grid do begin
    try
      for r := 0 to RowCount - 1 do begin
        RowEnabled[r] := True;
        Rows[r].Clear;
      end;
      Row := FixedRows;
    except
      //ignore
    end;
  end;
end;
{$ENDIF}

procedure GetGridColSize(Grid: TStringGrid);
var //29.11.11 nk opt - grid col size array [bytes]
  c: Integer;
begin
  for c := 0 to GRIDCOLS do GridColSize[c] := CLEAR;

  //col sizes [bytes] are hidden in Grid Header Objects (as TLabel)
  try //29.11.11 nk add
    with Grid do begin
      for c := 0 to ColCount - 1 do
        GridColSize[c] := (Objects[c, 0] as TLabel).Tag;
    end;
  except
    Exit;
  end;
end;

procedure InsertGridRow(Grid: TStringGrid; InsRow: Integer);
var
  r: Integer;
  gridex: TGridEx;
begin
  gridex := TGridEx(Grid);

  with gridex do begin
    r := Row;
    while InsRow < FixedRows do Inc(InsRow);
    RowCount := RowCount + 1;
    MoveRow(RowCount - 1, InsRow);
    Row := r;
  end;
end;

procedure DeleteGridRow(Grid: TStringGrid; DelRow: Integer);
var
  r: Integer;
begin
  with Grid do begin
    if (DelRow < FixedRows) or (DelRow > RowCount - FixedRows) then Exit;

    Row := DelRow;
    if Row < RowCount - FixedRows then begin
      for r := DelRow to RowCount - FixedRows do
        Rows[r] := Rows[r + 1];
    end;
    RowCount := RowCount - 1;
  end;
end;

procedure UnselectGrid(Grid: TStringGrid);
var
  nocell: TGridRect;
begin
  with nocell do begin
    Left := CLEAR;
    Top := CLEAR;
    Right := CLEAR;
    Bottom := CLEAR;
  end;

  Grid.Selection := nocell;
end;

procedure SortGrid(Grid: TStringGrid; SortCol, SortSub: Integer; SortDir: Boolean);
var
  c, r: Integer;
  nCols: Integer;
  nRows: Integer;
  nSort: Integer;
  nNum: Int64;
  rNum: Double;
  aList: array of Integer;
  sCell: string;
  sSort: string;
  dTime: TDateTime;
  gridex: TStringGrid;
begin
  if (SortCol < 0) or (SortCol >= Grid.ColCount) then Exit;
  gridex := TStringGrid.Create(Grid.Parent);

  with Grid do begin
    nRows := RowCount - FixedRows;
    nSort := ColCount;
    ColCount := nSort + 1;
    Cols[nSort].Append('TempCol');
    ColWidths[nSort] := NONE; //add and hide temp col

    if SortDir then //only for ANSI compare (ä=a)
      sSort := SORTDOWN  //descending
    else
      sSort := SORTUP;   //ascending

    SetLength(aList, nRows + 1);
    gridex.RowCount := RowCount;
    gridex.ColCount := ColCount;
    gridex.FixedRows := FixedRows;

    for r := FixedRows to nRows do begin //FixedRows = headline
      aList[r - FixedRows] := r;
      Cols[nSort][r] := cEMPTY;

      if (SortSub > 0) and (SortSub <> SortCol) then
        nCols := 2  //sort by main col and then by sub-col
      else
        nCols := 1; //sort by main col only

      for c := 1 to nCols do begin
        if c = 1 then sCell := Trim(Cols[SortCol][r]);
        if c = 2 then sCell := Trim(Cols[SortSub][r]);

        if sCell = cEMPTY then
          sCell := sSort
        else if TryStrToInt64(sCell, nNum) then begin   //1. sort by integer
          sCell := Format('%.*d', [SORTNUMS, nNum]);
          sCell := sCell +  Format('%.*d', [SORTPREC, 0]);
        end else if TryStrToFloat(sCell, rNum) then begin //2. sort by real
          sCell := Format('%*.*f', [SORTNUMS, SORTPREC, rNum]);
          sCell := StringReplace(sCell, cDOT, cEMPTY, [rfReplaceAll]);
          nNum := StrToInt(sCell);
          sCell := Format('%.*d', [SORTNUMS + SORTPREC, nNum]);
        end else if TryStrToDateTime(sCell, dTime) then //3. sort by date/time
          sCell := FormatDateTime(FORM_SORT_DATI, dTime)
        else if TryStrToDate(sCell, dTime) then     //4. sort by date
          sCell := FormatDateTime(FORM_SORT_DATE, dTime)
        else if TryStrToDateTime(sCell, dTime) then //5. sort by time
          sCell := FormatDateTime(FORM_SORT_TIME, dTime);
        Cols[nSort][r] := Cols[nSort][r] + sCell;
      end;
      gridex.Rows[r].Assign(Grid.Rows[r]);
    end;

    SortQuick(Grid, aList, 0, nRows - 1, nSort, SortDir);

    for r := 0 to nRows - 1 do
      Rows[r + FixedRows].Assign(gridex.Rows[aList[r]]);

    ColCount := nSort; //remove temp col
    Col := FixedCols;
    Row := FixedRows;
    TopRow := 1;
    //07.02.08 nk del Repaint;
  end;

  gridex.Free;
  SetLength(aList, 0);
end;

procedure SortQuick(Grid: TStringGrid; var SortList: array of Integer; Min, Max, SortCol: Integer; SortDir: Boolean);
var //quick grid sort
  i: Integer;
  hi: Integer;
  lo: Integer;
  act: Integer;
begin
    if (Min >= Max) then Exit;

    i := Min + Trunc(Random(Max - Min + 1));
    act := SortList[i];
    SortList[i] := SortList[Min];
    lo := Min;
    hi := Max;

    while True do begin
      while
        (not SortDir and (AnsiCompareText(Grid.Cells[SortCol, SortList[hi]], Grid.Cells[SortCol, act]) >= 0))
         or ((SortDir) and (AnsiCompareText(Grid.Cells[SortCol, SortList[hi]], Grid.Cells[SortCol, act])<=0))
      do begin
        Dec(hi);
        if (hi <= lo) then break;
      end;

      if (hi <= lo) then begin
        SortList[lo] := act;
        Break;
      end;

      SortList[lo] := SortList[hi];
      Inc(lo);

      while
        (not SortDir and (AnsiCompareText(Grid.Cells[SortCol, SortList[lo]], Grid.Cells[SortCol, act]) < 0))
        or ((SortDir) and (AnsiCompareText(Grid.Cells[SortCol, SortList[lo]], Grid.Cells[SortCol, act]) > 0))
      do begin
        Inc(lo);
        if (lo >= hi) then break;
      end;

      if (lo >= hi) then begin
        lo := hi;
        SortList[hi] := act;
        Break;
      end;
      SortList[hi] := SortList[lo];
    end;

    //re-sort the sublists
    sortQuick(Grid, SortList, Min, lo - 1, SortCol, SortDir);
    sortQuick(Grid, SortList, lo + 1, Max, SortCol, SortDir);
end;

procedure SizeGrid(Grid: TStringGrid; Size: Integer);
var //fit grid columns to max cell text width and add Size
  c, r: Integer;
  maxWidth: Integer;
  colWidth: Integer;
  colText: string;
  gridex: TGridEx;
begin
  gridex := TGridEx(Grid);

  with gridex do begin
    for c := 0 to ColCount - 1 do begin
      maxWidth := 0;
      for r := 0 to RowCount - 1 do begin
        colText := GetEditText(c, r);
        colWidth := Canvas.TextWidth(colText);
        if colWidth > maxWidth then maxWidth := colWidth;
      end;
      ColWidths[c] := maxWidth + Size;
    end;
  end;
end;

function GetTreePath(Node: TTreeNode): string;
var
  temp: string;
begin
  temp := Node.Text;

  while Node.Parent <> nil do begin
    temp := Node.Parent.Text + TREEDEL + temp;
    Node := Node.Parent;
  end;

  Result := temp;
end;

function GetTreeNode(Tree: TRzTreeView; Search: string; FullPath, MatchCase: Boolean): TTreeNode;
var //25.08.08 nk add MatchCase
  i: Integer;
  item: string;
begin
  Result := nil;
  if (Tree = nil) or (Search = cEMPTY) then Exit;

  if not MatchCase then Search := LowerCase(Search);

  for i := 0 to Tree.Items.Count - 1 do begin
    if FullPath then
      item := GetTreePath(Tree.Items[i])
    else
      item := Tree.Items[i].Text;

    if not MatchCase then item := LowerCase(item);

    if item = Search then begin
      Result := Tree.Items[i];
      Exit;
    end;
  end;
end;

function SearchGrid(Grid: TStringGrid; Search: string; MatchCase, WholeWord: Boolean): Boolean;
var
  match: Boolean;
  col: Integer;
  row: Integer;
  cell: string;
begin
  Result := False;
  if not MatchCase then Search := UpperCase(Search);

  if GridFindNext then begin
    If GridCol < Grid.ColCount then begin
      GridCol := GridCol + 1;
    end else begin
      GridCol := Grid.FixedCols;
      GridRow := GridRow + 1;
    end;
  end else begin
    GridCol := Grid.FixedCols;
    GridRow := Grid.FixedRows;
  end;

  for row := GridRow to Grid.RowCount - 1 do begin
    for col := GridCol to Grid.ColCount - 1 do begin
      if MatchCase then
        cell := Grid.Cells[col, row]
      else
        cell := UpperCase(Grid.Cells[col, row]);

      if WholeWord then
        match := (cell = Search)
      else
        match := (Pos(Search, cell) > 0);

      if match then begin
        Grid.Col := col;
        Grid.Row := row;
        GridCol := col;
        GridRow := row;
        GridFindNext := True;
        Result := True;
        Exit;
      end else begin
        Grid.Col := Grid.FixedCols;
        Grid.Row := Grid.FixedRows;
        GridFindNext := False;
        Result := False;
      end;
    end;
    GridCol := Grid.FixedCols;
  end;
end;

function GetComboIndex(Combo: TCustomComboBox; Search: string; MatchCase: Boolean; WholeWord: Boolean = True): Integer;
var
  match: string;
begin
  Search := Trim(Search);
  if not MatchCase then Search := UpperCase(Search);

  with (Combo as TCustomComboBox) do begin
    for Result := 0 to Items.Count - 1 do begin
      match := Trim(Items[Result]);
      if not MatchCase then match := UpperCase(match);

      if WholeWord then begin  //18.03.09 nk opt ff
        if Search = match then Exit;         //the whole string must match
      end else begin
        if Pos(Search, match) = 1 then Exit; //only the first chars must match
      end;
    end;
    Result := NONE;
  end;
end;

function IsFormOpen(const FormName: string): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := Screen.FormCount - 1 downto 0 do begin
    if Screen.Forms[i].Name = FormName then begin
      Result := True;
      Exit;
    end;
  end;
end;

function IsChildOpen(const FormName: TForm; const ChildName: string): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := Pred(FormName.MDIChildCount) downto 0 do begin
    if FormName.MDIChildren[i].Name = ChildName then begin
      Result := True;
      Exit;
    end;
  end;
end;

function IsCellSelected(Grid: TStringGrid; X, Y: Integer): Boolean;
begin //Return True if the requested cell at X/Y is selected
  Result := False;
  try
    with Grid do begin
      if (X >= Selection.Left) and (X <= Selection.Right) and
         (Y >= Selection.Top)  and (Y <= Selection.Bottom) then
      Result := True;
    end;
  except
    Result := False;
  end;
end;

procedure SelectListItem(List: TListView; Find: string; Col: Integer);
var //16.02.13 nk add - Col=0 is main column / Col 1.. are sub columns
  i: Integer;
  found: Boolean;
  item: TListItem;
begin
  if not Assigned(List) or (Find = cEMPTY) or (Col < 0) then Exit;

  for i := 0 to List.Items.Count - 1 do begin
    found := False;
    item  := List.Items[i];

    if Col = 0 then begin
      found := Pos(Find, Trim(item.Caption)) = 1;
    end else begin
      if item.SubItems.Count >= Col then
        found := Pos(Find, Trim(item.SubItems[Col - 1])) = 1;
    end;

    if found then begin
      List.Selected := item;
      item.MakeVisible(True); //scroll to selected item
      List.SetFocus;
      Exit;
    end;
  end;

  DeselectList(List);
end;

procedure DeselectList(List: TListView);
var  //07.05.09 nk opt ff - deselect all items in the List
  i: Integer;
begin
  try
    with List do begin
      for i := 0 to Items.Count - 1 do
        Items[i].Selected := False;
      Repaint;
    end;
  except
    //ignore
  end;
end;

procedure DeselectGrid(Grid: TStringGrid);
var  //deselect all cells in the Grid (tricky)
  sel: TGridRect;
begin
  sel.Top    := NONE;
  sel.Left   := NONE;
  sel.Right  := NONE;
  sel.Bottom := NONE;
  Grid.Selection := sel;
end;

procedure ShowGridHint(Grid: TStringGrid; X, Y: Integer; ShowHead: Boolean = False; Acol: Integer = 0; Arow: Integer = 0);
var //18.12.09 nk opt ff - define 1st col and row
  col: Integer;
  row: Integer;
begin
  if not Grid.ShowHint then Exit;

  Grid.MouseToCell(X, Y, col, row);

  if (col >= Acol) and (row >= Arow) then begin    //18.12.09 nk opt
    if Grid.Cells[col, row] <> cEMPTY then begin
      if ShowHead and (row >= Grid.FixedRows) then //18.10.09 nk add row > Grid.FixedRows
        Grid.Hint := Trim(Grid.Cells[col, 0]) + cIS + Trim(Grid.Cells[col, row])
      else
        Grid.Hint := Trim(Grid.Cells[col, row]);
    end;
  end else begin
    Grid.Hint := cEMPTY;
  end;
  
  if (col <> GridCol) or (row <> GridRow) then begin
    Application.CancelHint;
    GridCol := col;
    GridRow := row;
  end;
end;

procedure ShowGridEdit(Grid: TStringGrid; Edit: TEdit; nCol, nRow: Integer);
var
  nRect: TRect;
begin
  Edit.Visible := False;
  nRect := Grid.CellRect(nCol, nRow);
  nRect.Left := nRect.Left + Grid.Left;
  nRect.Right := nRect.Right + Grid.Left - 1;
  nRect.Top := nRect.Top + Grid.Top + 1;
  nRect.Bottom := nRect.Bottom + Grid.Top;

  with Edit do begin
    Text := Grid.Cells[nCol, nRow];
    Left := nRect.Left + 1;
    Top := nRect.Top;
    Width := (nRect.Right + 1) - nRect.Left;
    Height := (nRect.Bottom + 1) - nRect.Top;
    Font := Grid.Font;
    Color := Grid.Color;
    Enabled := True;
    Visible := True;
    SetFocus;
  end;
end;

procedure ShowGridRzEdit(Grid: TStringGrid; Edit: TRzEdit; nCol, nRow: Integer);
var
  nRect: TRect;
begin
  Edit.Visible := False;
  nRect := Grid.CellRect(nCol, nRow);
  nRect.Left := nRect.Left + Grid.Left;
  nRect.Right := nRect.Right + Grid.Left;
  nRect.Top := nRect.Top + Grid.Top + 1;
  nRect.Bottom := nRect.Bottom + Grid.Top;

  with Edit do begin
    Text := Grid.Cells[nCol, nRow];
    Left := nRect.Left;
    Top := nRect.Top;
    Width := nRect.Right - nRect.Left + 2;
    Height := nRect.Bottom - nRect.Top + 1;
    Font := Grid.Font;
    Color := Grid.Color;
    Enabled := True;
    Visible := True;
    SetFocus;
  end;
end;

procedure ShowGridCombo(Grid: TStringGrid; Combo: TComboBox; nCol, nRow: Integer);
var
  nRect: TRect;
begin
  Combo.Visible := False;
  nRect := Grid.CellRect(nCol, nRow);
  nRect.Left := nRect.Left + Grid.Left;
  nRect.Right := nRect.Right + Grid.Left;
  nRect.Top := nRect.Top + Grid.Top;
  nRect.Bottom := nRect.Bottom + Grid.Top;

  with Combo do begin
    Text := Grid.Cells[nCol, nRow];
    Left := nRect.Left + 1;
    Top := nRect.Top;
    Width := nRect.Right - nRect.Left + 1;
    Height := nRect.Bottom - nRect.Top + 1;
    Font := Grid.Font;
    Color := Grid.Color;
    Enabled := True;
    Visible := True;
    SetFocus;
  end;
end;

procedure ShowGridRzCombo(Grid: TStringGrid; Combo: TRzComboBox; nCol, nRow: Integer);
var
  nRect: TRect;
begin
  Combo.Visible := False;
  nRect := Grid.CellRect(nCol, nRow);
  nRect.Left := nRect.Left + Grid.Left;
  nRect.Right := nRect.Right + Grid.Left;
  nRect.Top := nRect.Top + Grid.Top;
  nRect.Bottom := nRect.Bottom + Grid.Top;

  with Combo do begin
    Text := Grid.Cells[nCol, nRow];
    Left := nRect.Left;
    Top := nRect.Top;
    Width := nRect.Right - nRect.Left + 1;
    Height := nRect.Bottom - nRect.Top;
    Font := Grid.Font;
    Color := Grid.Color;
    Enabled := True;
    Visible := True;
    SetFocus;
  end;
end;

procedure CopyGridToList(Grid: TStringGrid; List: TListView; ColSet: TNumSet; Boxes, Check: Boolean);
var //copy String Grid cells to List Items
  nCol: Integer;
  nRow: Integer;
  ListItem: TListItem;
  ListCol: TListColumn;
begin
  with List do begin
    Items.BeginUpdate;
    ViewStyle := vsReport;
    Checkboxes := Check;
    Items.Clear;
  end;

  try
    with Grid, List do begin
      if Columns.Count = 0 then begin
        for nCol := 0 to ColCount - 1 do begin
          if nCol in ColSet then begin
            ListCol := Columns.Add;
            ListCol.Caption := Cells[nCol, 0]; //col header
            ListCol.Width := ColWidths[nCol];
          end;
        end;
      end;

      for nRow := 1 to RowCount - 1 do begin
        if Cells[0, nRow] <> cEMPTY then begin
          ListItem := List.Items.Add;
          ListItem.Caption := Cells[0, nRow];
          ListItem.Checked := True;
          for nCol := 1 to ColCount - 1 do begin
            if nCol in ColSet then ListItem.Subitems.Add(Cells[nCol, nRow]);
          end;
        end;
      end;
    end;
  finally
    List.Items.EndUpdate;
  end;
end;

procedure WriteGrid(Grid: TStringGrid; Text: string; Rect: TRect; Alignment: TAlignment; Xcorr: Integer = 3);
const //16.09.12 nk opt - mov from FParameter.pas
  DX = 2; //Alignment = [taCenter, taLeftJustify, taRightJustify]
  DY = 3;
  Formats: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  buff: array[0..MAXBYTE] of Char;

  procedure WriteText(AGrid: TStringGrid; ACanvas: TCanvas; ARect: TRect; AText: string; AFormat: Word);
  begin
    with AGrid, ACanvas, ARect do begin
      case AFormat of
        DT_LEFT:   ExtTextOut(Handle, Left + DX, Top + DY, ETO_OPAQUE or ETO_CLIPPED, @ARect, StrPCopy(buff, AText), Length(AText), nil);
        DT_RIGHT:  ExtTextOut(Handle, Right - TextWidth(AText) - Xcorr, Top + DY, ETO_OPAQUE or ETO_CLIPPED, @ARect, StrPCopy(buff, AText), Length(AText), nil); //16.09.12 nk add Xcorr
        DT_CENTER: ExtTextOut(Handle, Left + (Right - Left - TextWidth(AText)) div 2, Top + DY, ETO_OPAQUE or ETO_CLIPPED, @ARect, StrPCopy(buff, AText), Length(AText), nil);
      end;
    end;
  end;
begin
  WriteText(Grid, Grid.Canvas, Rect, Text, Formats[Alignment]);
end;

procedure OpenComboBox(Combo: TCustomComboBox; OpenIt, ShowIt: Boolean);
begin
  with (Combo as TCustomComboBox) do begin
    if OpenIt then
      SendMessage(Handle, CB_SHOWDROPDOWN, 1, 0)  //open ComboBox
    else
      SendMessage(Handle, CB_SHOWDROPDOWN, 0, 0); //close ComboBox

    if ShowIt then
      Visible := True
    else
      Visible := False;
  end;
end;

procedure HideComboFrame(Combo: TComboBox; ShowIt: Boolean);
begin //call once in the OnCreate event of the form
  with (Combo as TComboBox) do begin
    SetWindowRgn(Handle, CreateRectRgn(2 , 2, Width - 2, Height - 2), True);
    if ShowIt then
      Visible := True
    else
      Visible := False;
  end;
end;

procedure FrameLabel(Sender: TObject; Active: Boolean);
var //call in the OnMouseEnter / OnMouseLeave events of the label
  nMargin: Integer;
  sText: string;
  rFrame: TRect;
begin
  with (Sender as TLabel) do begin
    rFrame := Rect(0, 0, Width, Height);
    sText := Caption;
    nMargin := (Height - Canvas.TextHeight(sText)) div 2;
    if Active then begin
      Canvas.Brush.Color := FrameBackColor;
      Canvas.Pen.Color := FrameLineColor;
      Canvas.Font.Color := FrameTextColor;
    end else begin
      Canvas.Brush.Color := Parent.Brush.Color;
      Canvas.Pen.Color := Parent.Brush.Color;
      Canvas.Font.Color := clWindowText;
    end;
    Canvas.FillRect(rFrame);
    Canvas.Rectangle(rFrame);
    Inc(rFrame.Left, nMargin);
    DrawText(Canvas.Handle, PChar(sText), Length(sText), rFrame, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  end;
end;

procedure UncheckPopupItems(Popup: TPopupMenu);
var
  i: Integer;
begin
  for i := 0 to Popup.Items.Count - 1 do
    Popup.Items[i].Checked := False;
end;

procedure OpenPopupMenu(Control: TControl);
begin //30.04.10 nk add - open the PopupMenu of the Control or
      //the parent of Control at the current cursor position
  Control.Perform(WM_CONTEXTMENU, 0, Integer(PointToSmallPoint(Control.ClientToScreen(Point(2, 2)))));
end;

procedure SetTreeNodeBold(Node: TTreeNode; Value: Boolean);
var
  TVItem: TTVItem;
begin
  if not Assigned(Node) then Exit;

  with TVItem do begin
    mask := TVIF_STATE or TVIF_HANDLE;
    hItem := Node.ItemId;
    stateMask := TVIS_BOLD;
    if Value then
      state := TVIS_BOLD
    else 
      state := 0;
    TreeView_SetItem(Node.Handle, TVItem);
  end;
end;

procedure SetTreeNodesBold(TreeView: TTreeView; Levels: TNumSet);
var //set all node names of given levels bold
  n: Integer;
  node: TTreeNode;
begin
  with TreeView do begin
    for n := 0 to Items.Count - 1 do begin
      node := Items[n];
      if node.Level in Levels then
        SetTreeNodeBold(node, True);
    end;
  end;
end;

procedure ScrollLines(RichEdit: TRichEdit; LineNr: Integer = 1);
var //scroll LineNr down (if positive) or up (if negative)
  lnr: Integer;
begin
  with RichEdit do begin
    lnr := SendMessage(Handle, EM_LINEFROMCHAR, SelStart, 0);
    SelStart := Perform(EM_LINEINDEX, lnr + LineNr, 0);
    Perform(EM_SCROLLCARET, 0, 0);
  end;
end;

procedure SelectLine(RichEdit: TRichEdit; LineNr: Integer; ScrollTop, ScrollLeft: Boolean);
var //scroll to given line number in RichEdit and select it
  h, scroll: Integer;
begin
  try
    with RichEdit do begin
      HideSelection := False; //20.08.07 nk add
      SelStart := 0;
      Perform(EM_SCROLLCARET, 0, 0);

      if ScrollTop then begin
        h := GetFontHeight(Font);
        scroll := Round(ClientHeight / h);
        SelStart := Perform(EM_LINEINDEX, LineNr + scroll, 0);
        Perform(EM_SCROLLCARET, 0, 0);
      end;

      if ScrollLeft then begin //21.08.07 nk add
        SetScrollPos(Handle, SB_HORZ, 0, True);
        h := 2;
      end else begin
        h := 0;
      end;

      SelStart := Perform(EM_LINEINDEX, LineNr, 0);
      SelLength := Length(Lines[LineNr]) + h; //21.08.07 nk opt
      Perform(EM_SCROLLCARET, 0, 0);
      SetFocus;
      Refresh;
    end;
  except
    //
  end;

  Application.ProcessMessages;
end;

procedure ReplaceInEdit(RichEdit: TRichEdit; Old, New: string; MatchCase: Boolean);
var //23.06.11 nk add - replace all Old text patterns with New in RichEdit
  epos, spos, cpos: Integer;
  flags: TSearchTypes;
begin
  if MatchCase then
    flags := [stMatchCase]
  else
    flags := [];

  spos := 0;

  with RichEdit do begin
    epos := Length(Text);
    Lines.BeginUpdate;
    while FindText(Old, spos, epos, flags) <> NONE do begin
      epos := Length(Text) - spos;
      cpos := FindText(Old, spos, epos, flags);
      Inc(spos, Length(Old));
      SelStart  := cpos;
      SelLength := Length(Old);
      RichEdit.ClearSelection;
      SelText := New;
    end;
    Lines.EndUpdate;
  end;
end;

procedure AddBalloonTip(Control: TWinControl; Icon: Integer; Title: PChar; Text: PWideChar; BackCol, TextCol: TColor);
type //add a balloon tip to the Control that opens as hint (Comctl32.dll 5.8 required)
  ToolInfo = packed record
    cbSize: Integer;
    uFlags: Integer;
    hwnd: THandle;
    uId: Integer;
    rect: TRect;
    hinst: THandle;
    lpszText: PWideChar;
    lParam: Integer;
  end;
var
  hWnd: THandle;
  hWndTip: THandle;
  ti: ToolInfo;
begin
  hWnd := Control.Handle;
  hWndTip := CreateWindow(TOOLTIPS_CLASS, nil,
    WS_POPUP or TTS_NOPREFIX or TTS_BALLOON or TTS_ALWAYSTIP, 0, 0, 0, 0, hWnd, 0, HInstance, nil);

  if hWndTip <> 0 then begin
    SetWindowPos(hWndTip, HWND_TOPMOST, 0, 0, 0, 0,
      SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
    ti.cbSize := SizeOf(ti);
    ti.uFlags := TTF_CENTERTIP or TTF_TRANSPARENT or TTF_SUBCLASS;
    ti.hwnd := hWnd;
    ti.lpszText := Text;
    Windows.GetClientRect(hWnd, ti.rect);
    SendMessage(hWndTip, TTM_SETTIPBKCOLOR, BackCol, 0);
    SendMessage(hWndTip, TTM_SETTIPTEXTCOLOR, TextCol, 0);
    SendMessage(hWndTip, TTM_ADDTOOL, 1, Integer(@ti));
    SendMessage(hWndTip, TTM_SETTITLE, Icon mod 4, Integer(Title));
    SendMessage(hWndTip, TTM_SETDELAYTIME, TTDT_AUTOPOP, TOOLTIPS_DELAY);
  end;
end;

procedure AddMenuItem(Menu: THandle; Item: Cardinal; Text: string = cEMPTY);
var //01.05.14 nk opt - add own items to the system menu
  items: Integer;
  icon: TBitmap;
begin
  items := CLEAR;
  icon  := nil;

  try
    if Item > SYS_SEPARATOR then begin //15.04.11 nk opt
      icon  := TBitmap.Create;
      items := GetMenuItemCount(Menu);
      icon.LoadFromResourceID(HInstance, Item);
    end;
  except
    icon := nil; //no bitmap found in resource
  end;

  try
    if Item in [SYS_HORIZONT..SYS_EXIT] then begin
      if Text = cEMPTY then Text := MenuCaptions[Item];
      AppendMenu(Menu, MF_STRING, Item + WM_USER, PChar(Text));

      if icon <> nil then begin //add an icon if defined in resource
        SetMenuItemBitmaps(Menu, items, MF_BYPOSITION, icon.Handle, icon.Handle);
      end;
    end else begin
      AppendMenu(Menu, MF_SEPARATOR, CLEAR, cNUL);
    end;
  except
    //ignore it - do not free icon bitmap
  end;

  if icon <> nil then //01.05.14 nk add ff
    icon.Free;
end;

procedure AddMainIcon(AppName: string);
var //load application icon from resource or from external ico-file
  icon: TIcon;
begin
  icon := TIcon.Create;

  try
    icon.Handle := LoadIcon(hInstance, APP_MAINICON); //try to get icon from resource
    if icon.Handle = 0 then
      icon.LoadFromFile(AppName + ICO_END); //try to get icon from external file
    Application.Icon := icon;
  except
    //ignore it
  end;

  icon.Free;
end;

procedure AddShieldButton(Button: TButton; ShowShield: Boolean);
begin //show or hide the Administrator shield icon on left side of Button
  SendMessage(Button.Handle, BCM_SETSHIELD, 0, Integer(ShowShield));
end;

function ResourceBitmap(ResName: string): TBitmap;
var //load bitmap from internal resource
  bmp: TBitmap;
begin
  bmp  := TBitmap.Create;

  try
    bmp.LoadFromResourceName(hInstance, ResName);
    Result := bmp;
  except
    Result := nil;
  end;
end;

function GetFilterFromIndex(var Filter: string; Index: Integer): string;
// Return the selected filter setting from TOpenDialog or TSaveDialog
// Input:  Filter - String list of filters (separated by |), like
//         'Text files (*.txt)|*.txt|Pascal files (*.pas)|*.pas'
//         Index - Currently selected FilterIndex (1..OLECONVERTERS)
// Output: Filter - Selected filter like 'Pascal files (*.pas)|*.pas'
// Return: File extension (with dot) of selected filter like '.pas' (lower case)
// Remark: Return empty string if no valid filter is found
var //26.10.09 nk opt ff - add 1x LowerCase
  iscut: Boolean;
  c: Char;
  i: Integer;
  pos: Integer;
  cut: string;
begin
  Result := cEMPTY;
  cut := cEMPTY;
  pos := 0;
  iscut := False;
  Filter := FILTERDEL + Filter + FILTERDEL;

  for i := 1 to Length(Filter) do begin
    c := Filter[i];
    if c = FILTERDEL then begin
      iscut := not iscut;
      if pos = Index then begin
        Filter := MidStr(cut, 2, Length(cut) - 1);
        Result := LowerCase(RightStr(Filter, 4));
        Exit;
      end;
      if iscut then
        cut := cEMPTY
      else
        Inc(pos);
    end;
    cut := cut + c;
  end;
end;

function GetIndexFromFilter(Filter, FileName: string): Integer;
// Return the filter index of file extension for TOpenDialog or TSaveDialog
// Input:  Filter - String list of filters (separated by |), like
//         'Text files (*.txt)|*.txt|Pascal files (*.pas)|*.pas'
//         Ext - File name or file extension like 'file.pas'
// Return: Index of selected file extension (1..)
// Remark: Return 0 if no valid index is found
var //26.10.09 nk opt ff - add 2x LowerCase
  i, imax: Integer;
  flt: string;
  ext: string;
begin
  Result := 0;
  ext := LowerCase(ExtractFileExt(FileName));

  if ext <> cEMPTY then begin
    imax := StrCount(Filter, FILTERDEL) div 2;
    for i := 0 to imax do begin
      flt := LowerCase(StrSplit(Filter, FILTERDEL, i * 2));
      if Pos(ext, flt) > 0 then begin
        Result := i + 1;
        Exit;
      end;
    end;
  end;
end;

initialization
  GridSortDir     := False;
  GridFindNext    := False;
  GridCol         := 0;
  GridRow         := 0;
  GridSortCol     := 1;
  FrameBackColor  := RGB(110, 131, 184);
  FrameLineColor  := RGB(47,  60,  93);
  FrameTextColor  := clWhite;
  StatusBackColor := clBtnFace;
  StatusTextColor := clWindowText;

end.

