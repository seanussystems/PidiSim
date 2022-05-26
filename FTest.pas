// PidiSim Test and Debug Functions
// Date 01.06.07
// Norbert Koechli
// Copyright ©2006-2007 seanus systems

unit FTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, RzButton, RzEdit, RzSpnEdt, USystem, SYS,
  ADC, SER, Global, Data, Flash, Deco, Texts, Clock, Power, Sensor, Compass,
  Sonar, Tank, FLog, FProfile, FTrack, FPlan, FDaq, FGui, FMain, UPidi;

type
  TTest = class(TForm)
    TestLoop: TTimer;
    FlashMem: TPaintBox;
    FlashStatus: TGroupBox;
    seSectors: TRzSpinEdit;
    lbWriteSector: TLabel;
    lbTotalBlocks: TLabel;
    lbFreeBlocks: TLabel;
    lbUsedBlocks: TLabel;
    lbWriteAddr: TLabel;
    txWriteAddr: TLabel;
    txFreeBlocks: TLabel;
    txUsedBlocks: TLabel;
    txTotalBlocks: TLabel;
    txWriteSector: TLabel;
    btClearSector: TRzButton;
    btWriteMany: TRzButton;
    btClearFlash: TRzButton;
    btWriteOnce: TRzButton;
    btWriteLog: TRzButton;
    btChangeUnit: TRzButton;
    btTest: TRzButton;
    RzButton1: TRzButton;
    RzButton2: TRzButton;
    RzButton3: TRzButton;
    RzButton4: TRzButton;
    RzButton5: TRzButton;
    procedure FormCreate(Sender: TObject);
    procedure FormMoving(var Msg: TwmMoving); message WM_MOVING;
    procedure TestLoopTimer(Sender: TObject);
    procedure btWriteManyClick(Sender: TObject);
    procedure btWriteOnceClick(Sender: TObject);
    procedure btWriteLogClick(Sender: TObject);
    procedure btClearSectorClick(Sender: TObject);
    procedure btClearFlashClick(Sender: TObject);
    procedure btChangeUnitClick(Sender: TObject);
    procedure btTestClick(Sender: TObject);
    procedure RzButton1Click(Sender: TObject);
    procedure RzButton2Click(Sender: TObject);
    procedure RzButton3Click(Sender: TObject);
    procedure RzButton4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RzButton5Click(Sender: TObject);
  private
    MemInit: Boolean;
    MemWidth: Integer;
    MemHeight: Integer;
    procedure InitFlashBar;
    procedure ShowFlashBar;
  public
    //
  end;

var
  Test: TTest;

implementation

{$R *.dfm}

procedure TTest.FormCreate(Sender: TObject);
begin
  Randomize;
  HideMaxButton(Self);   //hide maximize button

  with Test do begin
    Left := MainRect.Right - MainRect.Left - Width - MAINMARGIN;
    Top  := MAINMARGIN;
    Show;
  end;

  with FlashMem do begin
    MemInit := False;
    MemWidth  := Width;
    MemHeight := Height;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Mode := pmCopy;
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := clBlack;
  end;

  Application.ProcessMessages;
end;

procedure TTest.FormMoving(var Msg: TwmMoving);
begin
  LimitFormMove(MainRect, Msg);
end;

procedure TTest.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TestLoop.Enabled := False;
  Action := caFree;
end;

procedure TTest.TestLoopTimer(Sender: TObject);
begin
  if MemSectors > 0 then begin
    if MemInit then
      ShowFlashBar
    else
      InitFlashBar;
  end;
end;

procedure TTest.InitFlashBar;
var
  x, dx: Word;
begin
  lbTotalBlocks.Caption := '0';
  lbFreeBlocks.Caption  := '0';
  lbUsedBlocks.Caption  := '0';
  lbWriteAddr.Caption   := '0';
  lbWriteSector.Caption := '0';
  seSectors.Min         := 1;
  seSectors.Max         := MemSectors;
  seSectors.Value       := 1;

  dx := Round(MemWidth / MemSectors);

  for x := 0 to MemSectors - 1 do
    FlashMem.Canvas.Rectangle(Rect(x * dx, 0, (x + 1) * dx, MemHeight));

  MemInit := True;
end;

procedure TTest.ShowFlashBar;
var
  f, u, s, x, lident: Word;
  block: Long;
  fx: Real;
begin
  f := cCLEAR;
  u := cCLEAR;
  s := cCLEAR;
  x := cCLEAR;
  fx := MemBlocks / MemWidth;

  with FlashMem do begin
    for block := 0 to MemBlocks - 1 do begin
      MemRead := block * MEMBLOCKSIZE;
      ReadMemWord(lident, cOFF);           // read 1st word of block

      if lident = MEMEMPTYWORD then begin  // empty block found
        Inc(f);
        Canvas.Pen.Color := clGreen;
      end else begin
        Inc(u);
        Canvas.Pen.Color := clRed;
      end;

      x := Round(block / fx);
      Canvas.MoveTo(x, 4);
      Canvas.LineTo(x, MemHeight - 4);
    end;
  end;

  s := MemWrite div MEMSECTSIZE + 1;  // number of write sector

  lbTotalBlocks.Caption := IntToStr(MemBlocks);
  lbFreeBlocks.Caption  := IntToStr(f);
  lbUsedBlocks.Caption  := IntToStr(u);
  lbWriteAddr.Caption   := Format(ADDRFORM, [MemWrite]);
  lbWriteSector.Caption := IntToStr(s);
end;

procedure TTest.btWriteManyClick(Sender: TObject);
var
  comm, dive: Word;
  i, tim: Long;
  val: Real;
  ptext: string;
begin
  //nk// test - fill flash memory to test circular buffer concept
  for comm := LOGSET + 1 to 127 do begin
    for i := 0 to 15 do
      MemBlock[0, i] := comm;

    WriteMemBlock(0, cON);
  end;

  Exit;

 // Profile.InitDiveProfile(cCLEAR);

  //Log.Print('GlobalSet: HEIGHT = ' + IntToStr(GlobalSet[4, 2, 0])); //nk//
  //Log.Print('GlobalSet: WEIGHT = ' + IntToStr(GlobalSet[4, 3, 0]));

  //LoadSettings;

  //InitGlobalData;
  //Application.ProcessMessages;

 { dive := 4;
  Gui.OpenProfile(comm, dive);
  }

 { for comm := 572 to 3599 do begin
    tim := comm * 100000; // ms
    CompressTime(tim, dive);

   // LogEvent('EXPAND ms', IntToStr(tim), IntToStr(dive));

    FormatValue(104, dive, ptext);

    LogEvent('Test01', IntToStr(tim), ptext);

  end; }

{  val := 1.6;
  RoundInt(val, tim);

  for i := -20 to 20 do begin
    tim := i;
    val := tim / 10.0;
    RoundInt(val, tim);
    LogEvent('RoundInt', Format('%.1f => %d', [val, tim]), '');
  end;}
end;

procedure TTest.btWriteOnceClick(Sender: TObject);
begin
  WriteMemBlock(0, cON);
end;

procedure TTest.btWriteLogClick(Sender: TObject);
begin
  Flash.LogDiveBlock;
end;

procedure TTest.btClearSectorClick(Sender: TObject);
begin
  SYS.ClearMem(seSectors.IntValue);
end;

procedure TTest.btClearFlashClick(Sender: TObject);
begin
  SYS.ClearMem(MEMSTART);
end;

procedure TTest.btChangeUnitClick(Sender: TObject);
begin
  if UnitFlag = cON then
    UnitFlag := cOFF
  else
    UnitFlag := cON;

  PhaseFlag := cON;

  Profile.InitDiveProfile(cNEG);
  Track.InitDiveTrack(cNEG);
  Plan.InitDivePlan;
  Daq.InitEnvironment(False);
end;

procedure TTest.btTestClick(Sender: TObject);
begin
  Track.DrawDivePos(200, 450, True);
end;

procedure TTest.RzButton1Click(Sender: TObject);
begin
  Assert(False, 'Heap Violation!');
end;

procedure TTest.RzButton2Click(Sender: TObject);
begin
  raise Exception.Create('Missing parameter');
end;

procedure TTest.RzButton3Click(Sender: TObject);
begin
  asm  //access violation
    xor EAX, EAX;   //here we zero CPU regiser
    mov EAX, [EAX]; //here we try to access to memory with zero address
  end;
end;

procedure TTest.RzButton4Click(Sender: TObject);
var
  i, x: Integer;
begin
  i := 0;
  x := 25 div i;
  RzButton4.Caption := IntToStr(x);
end;

procedure TTest.RzButton5Click(Sender: TObject);
begin
  NiFract := 100;  // 10%
  OxFract := 20;   // 2%
end;

end.
