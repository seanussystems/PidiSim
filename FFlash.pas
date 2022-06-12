// Pidi Flash File Maker
// Date 26.05.22
// Norbert Koechli
// Copyright ©2007-2022 seanus systems

// 26.05.22 migrate to Embarcadero Delphi XE7 Update
// 26.05.22 add multi-resolution icon container (16, 24, 32, 48, and 256 pixels, 256 colors)
// 26.05.22 opt create Flash file in 'Flash' subfolder of program folder 'bin'
// 26.05.22 Project is now open source hosted on GitHub

unit FFlash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  StdCtrls, USystem;

type
  TFlash = class(TForm)
    lbFlash: TLabel;
    lbSectors: TLabel;
    edFlash: TEdit;
    edSectors: TEdit;
    btMake: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btMakeClick(Sender: TObject);
    procedure edChange(Sender: TObject);
  private
    procedure CreateFlash(FlashFile: string; Sectors: Integer);
  public
    //
  end;

const
  FLASH_PROG    = ' Flash Maker 1.1';
  FLASH_PATH    = 'Flash\'; // working dir = home dir / 26.05.22 nk old= '.\'
  FLASH_FILE    = 'Flash';  // default flash file name
  FLASH_POST    = '.pfd';   // flash file ending
  FLASH_BACK    = '.bak';   // flash file backup copy
  MEMSTART      = 0;        // flash memory start address
  MEMBYTE       = 1;        // flash memory cell size=1byte
  MEMDEFSECT    = 20;       // default number of sectors
  MEMMAXSECT    = 32;       // maximum number of sectors
  MEMBLOCKLEN   = 16;       // flash memory block buffer length=16words
  MEMBLOCKSIZE  = 32;       // flash data block size (16x2bytes=32bytes)
  MEMSECTSIZE   = 65536;    // flash sector size = 65'536bytes = 64kB
  MEMEMPTYBYTE  = $0FF;     // empty flash cell (1byte)

var
  Flash: TFlash;

implementation

{$R *.dfm}

procedure TFlash.FormCreate(Sender: TObject);
begin
//DisableMaxButton(Self);  // hide maximize button
//DisableMinButton(Self);  // hide minimize button
  
  Caption        := FLASH_PROG;
  btMake.Tag     := 0;
  btMake.Caption := 'Make';
  edFlash.Text   := FLASH_FILE;
  edSectors.Text := IntToStr(MEMDEFSECT);
end;

procedure TFlash.btMakeClick(Sender: TObject);
var
  sectors: Integer;
  fname: string;
begin
  if btMake.Tag = 9 then begin
    Close;
    Exit;
  end;
  
  sectors := 0;
  fname   := Trim(edFlash.Text);

  if Pos(FLASH_POST, fname) > 0 then begin
    Beep;
    edFlash.Text := FLASH_FILE;
    edFlash.SetFocus;
    Exit;
  end;

  if not TryStrToInt(edSectors.Text, sectors) then begin
    Beep;
    edSectors.Text := IntToStr(MEMDEFSECT);
    edSectors.SetFocus;
    Exit;
  end;

  if (sectors < 1) or (sectors > MEMMAXSECT) then begin
    Beep;
    edSectors.Text := IntToStr(MEMDEFSECT);
    edSectors.SetFocus;
    Exit;
  end;

  // 26.05.22 nk add ProgPath
  fname := ProgPath + FLASH_PATH + fname + FLASH_POST;

  CreateFlash(fname, sectors);
end;

procedure TFlash.edChange(Sender: TObject);
begin
  btMake.Tag     := 0;
  btMake.Caption := 'Make';
end;

procedure TFlash.CreateFlash(FlashFile: string; Sectors: Integer);
var
  val: Byte;
  s, w: Integer;
  ret, err: Integer;
  flash: file of byte; // binary coded flash file
begin
  err            := 0;
  btMake.Tag     := 1;
  btMake.Caption := 'Working...';
  btMake.Enabled := False;

  RenameFile(FlashFile, FlashFile + FLASH_BACK); //rename to backup file

  try // to create empty flash file (block write buffer = 1 byte)
    err := 0;
    val := MEMEMPTYBYTE;

    AssignFile(flash, FlashFile);
    Rewrite(flash);

    for s := MEMSTART to sectors - 1 do begin
      for w := MEMSTART to MEMSECTSIZE - 1 do begin
        BlockWrite(flash, val, MEMBYTE, ret);
        if ret <> MEMBYTE then Inc(err);
      end;
    end;
  except
    Inc(err);
  end;

  CloseFile(flash);
  btMake.Enabled := True;

  if err > 0 then begin
    Beep;
    btMake.Tag     := 5;
    btMake.Caption := 'ERRORS: ' + IntToStr(err);
  end else begin
    btMake.Tag     := 9;
    btMake.Caption := 'Done';
  end;

  Application.ProcessMessages;
end;

end.
