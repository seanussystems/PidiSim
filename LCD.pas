// Interface to LCD Device Driver (Graphic Display Module)
// Date 26.05.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit LCD;

interface

uses
  Forms, Types, Controls, Graphics, GraphUtil, SysUtils, ExtCtrls, USystem,
  SYS, Global, Data, FLog, UPidi;

const
  LCDTEXT       = 0;   // internal address for text
  LCDGRAF       = 1;   // internal address for graphics
  LCDPEN        = 0;   // default graphic pen
  LCDDOTON      = 0;   // display dot modes
  LCDDOTOFF     = 1;
  LCDDOTINV     = 2;
  LCDDOTNEG     = 3;
  LCDBYTE       = 8;   // number of dots per byte
  LCDLAYER_1    = 1;   // display screen layers
  LCDLAYER_2    = 2;
  LCDLAYER_3    = 3;
  LCDRESETLEN   = 50;  // reset pulse length (50ms)

  LCDSETTYPE    = $90; // set LCD type
  LCDSETCHARS   = $9C; // set LCD characters/line (then make reset)
  LCDSETMODE    = $9D; // set LCD curser mode (0=wrap, 1=stay, 2=stop)
  LCDSETPARAM   = $9E; // set LCD initial parameter
  LCDSETCPULOAD = $9F; // set LCD CPU load (4..128)
  LCDSETINITIAL = $B0; // set LCD to initial state (SW reset)

  LCDTEXTON     = '<1Bh>T<1><0F0h>';   // text mode on
  LCDTEXTOFF    = '<1Bh>T<0><0F0h>';   // text mode off
  LCDGRAFON     = '<1Bh>G<1><0F0h>';   // graphic mode on
  LCDGRAFOFF    = '<1Bh>G<0><0F0h>';   // graphic mode off
  LCDINTFONT    = '<1Bh>m<0><0F0h>';   // internal char font
  LCDEXTFONT    = '<1Bh>m<8><0F0h>';   // external char font
  LCDMODEOR     = '<1Bh>m<0><0F0h>';   // mode OR
  LCDMODEXOR    = '<1Bh>m<1><0F0h>';   // mode XOR
  LCDMODEAND    = '<1Bh>m<3><0F0h>';   // mode AND
  LCDCURSON1    = '<1Bh>c<0><0F0h>';   // cursor 1 pixel
  LCDCURSON2    = '<1Bh>c<1><0F0h>';   // cursor 2 pixel
  LCDCURSON3    = '<1Bh>c<8><0F0h>';   // cursor 1 pixel, blinking
  LCDCURSON4    = '<1Bh>c<15><0F0h>';  // cursor 8 pixel, blinking
  LCDCURSOFF    = '<1Bh>c<10h><0F0h>'; // cursor off
  LCDCURSHOME   = '<02h>';             // cursor home position
  LCDCURS_FS    = '<05h>';             // cursor move right
  LCDCURS_BS    = '<08h>';             // cursor move left
  LCDCURS_LF    = '<0Ah>';             // cursor move down
  LCDCURS_UP    = '<0Bh>';             // cursor move up
  LCDCURS_CR    = '<0Dh>';             // cursor carriage return
  LCDCLEAR      = '<00>';              // display clear pattern

  LCDUNIT       = ' dots';             // display standard unit
  LCDRESUNIT    = ' bits';             // display resolution unit (DELPHI only)

var // module variables
  LcdPenX: Byte;            // DELPHI only
  LcdPenY: Byte;            // remember last line point
  LcdInit: Byte;            // graphic display init flag
  LcdScale: Long;           // graphic display scaling factor [%]
  LcdBuff: string;          // modul message buffer / old=[MAXTEMP]

  LcdScreen: TRect;         // display screen buffer
  LcdBuffer: TImage;        // display working buffer
  LcdLayer1: TImage;        // display layer buffer
  LcdLayer2: TImage;
  LcdLayer3: TImage;

  // Tiger interface to LCD device driver (LCD.INC)
  procedure InitLcd;
  procedure ResetLcd(Delay: Byte);
  procedure UpdateLcd;
  procedure SaveLcd(Layer: Byte);
  procedure LoadLcd(Layer: Byte);

  // Tiger LCD device driver functions (LCD.TDD)
  procedure Put_LCD(LCD: TBitmap; White, Black: Byte);
  procedure SetDot(X, Y, Mode, Pen: Long);
  procedure GraphicCopy(Bitmap: TImage; W, H, X, Y, W2, H2, X2, Y2, W3, H3, Mode: Long);
  procedure GraphicFillMask(W, H, X, Y, W2, H2, Dot: Long);

implementation

uses FMain, FGui;
  
//------------------------------------------------------------------------------
// INITLCD - Initialize graphic display and controller
//------------------------------------------------------------------ 17.02.07 --
procedure InitLcd;
var
  tb, sb: Long; //DELPHI only
  bt, fr, h, w: Cardinal;
begin
  LcdInit := cOFF;
  ErrCode := cOFF;

  LcdBuff := GetScreen(w, h, fr, bt);
  LogEvent('InitLcd', 'Display settings', LcdBuff);

  if bt < 16 then ErrCode := cON; // too little colors

  if ErrCode > cOFF then begin // LCD driver error
    LcdBuff := FloatToStr(bt) + LCDRESUNIT;
    LogError('InitLcd', 'Color resolution too low', LcdBuff, $96);
    ErrCode := cOFF;
  end;

  try
    LcdBuff := 'Creating display buffers';

    LcdBuffer := TImage.Create(Gui);  // display working buffer
    LcdLayer1 := TImage.Create(Gui);  // display layer buffers
    LcdLayer2 := TImage.Create(Gui);
    LcdLayer3 := TImage.Create(Gui);

    LcdBuff := 'Initializing screen buffer';

    with LcdBuffer do begin
      Width := LCDXRANGE;
      Height := LCDYRANGE;
      Visible := False;        //02.03.07 nk del LoadBitmap
      h := Round(Height * (LcdScale / PROCENT)) + Picture.Bitmap.Height;
      w := Round(Width * (LcdScale / PROCENT)) + Picture.Bitmap.Width;
      LcdScreen := Rect(0, 0, w, h);
    end;

    LcdBuff := 'Initializing graphic display';

    with Gui do begin
      sb := Width - ClientWidth; //05.05.07 nk add ff
      tb := Height - ClientHeight;

      if BorderStyle = bsSizeable then begin
        Height := h + tb + 2;
        Width := w + sb + 2;
      end else begin
        Height := h + tb;
        Width := w + sb;
      end;
    end;
  
    with Gui.Display do begin
      Left := 0;
      Top := 0;
      Width := w;
      Height := h;
      Picture.Graphic := nil;
      Visible := True;
      BringToFront;
    end;

    with LcdLayer1 do begin
      Width := LCDXRANGE;
      Height := LCDYRANGE;
    end;

    with LcdLayer2 do begin
      Width := LCDXRANGE;
      Height := LCDYRANGE;
    end;

    with LcdLayer3 do begin
      Width := LCDXRANGE;
      Height := LCDYRANGE;
    end;
  except
    LogError('InitLcd', LcdBuff, 'failed!', $A0);
    Main.Close;  // fatal error - abort program
    WaitDuration(DISPDELAY);
    Halt;
  end;

  LcdInit := cINIT;

  LcdBuff := IntToStr(LCDXRANGE) + sDIM + IntToStr(LCDYRANGE) + LCDUNIT;
  LogEvent('InitLcd', 'Graphic display initialized to ', LcdBuff);
end;

//------------------------------------------------------------------------------
// RESETLCD - Reset graphic display and controller
//------------------------------------------------------------------ 17.02.07 --
procedure ResetLcd(Delay: Byte);
begin
  with Gui.Display do begin
    Visible := False;
    Picture.Graphic := nil;

    if Delay = cOFF then
      WaitDuration(LCDRESETLEN)
    else
      WaitDuration(Delay);

    Visible := True;
    WaitDuration(LCDRESETLEN);
  end;
end;

//------------------------------------------------------------------------------
// UPDATELCD - Update the graphic display screen (for 8x8 font select only)
//------------------------------------------------------------------ 17.02.07 --
procedure UpdateLcd;
begin
  with Gui.Display do begin
    // swap display screen buffers
    Canvas.StretchDraw(LcdScreen, LcdBuffer.Picture.Bitmap);

    // DELPHI: simulate contrast and brightness
    Put_LCD(Picture.Bitmap, Brightness, Contrast);

    Application.ProcessMessages;
  end;
end;

//------------------------------------------------------------------------------
// SAVELCD - Save actual screen buffer to a layer buffer (1..3)
//------------------------------------------------------------------ 17.02.07 --
procedure SaveLcd(Layer: Byte);
var
  let: TRect;
begin
  let := Rect(0, 0, LCDXRANGE, LCDYRANGE);

  case Layer of
    LCDLAYER_1: LcdLayer1.Canvas.CopyRect(let, LcdBuffer.Canvas, let);
    LCDLAYER_2: LcdLayer2.Canvas.CopyRect(let, LcdBuffer.Canvas, let);
    LCDLAYER_3: LcdLayer3.Canvas.CopyRect(let, LcdBuffer.Canvas, let);
  else
    LcdBuff := IntToStr(Layer);
    LogError('SaveLcd', 'Unsupported screen layer', LcdBuff, $91);
  end;
end;

//------------------------------------------------------------------------------
// LOADLCD - Load saved layer buffer into screen buffer
//------------------------------------------------------------------ 17.02.07 --
procedure LoadLcd(Layer: Byte);
var
  let: TRect;
begin
  let := Rect(0, 0, LCDXRANGE, LCDYRANGE);

  case Layer of
    LCDLAYER_1: LcdBuffer.Canvas.CopyRect(let, LcdLayer1.Canvas, let);
    LCDLAYER_2: LcdBuffer.Canvas.CopyRect(let, LcdLayer2.Canvas, let);
    LCDLAYER_3: LcdBuffer.Canvas.CopyRect(let, LcdLayer3.Canvas, let);
  else
    LcdBuff := IntToStr(Layer);
    LogError('LoadLcd', 'Unsupported screen layer', LcdBuff, $91);
  end;
end;

//------------------------------------------------------------------------------
// PUT_LCD - DELPHI implementation for Tiger put #LCD
//------------------------------------------------------------------ 17.02.07 --
procedure Put_LCD(LCD: TBitmap; White, Black: Byte);
var
  x, y: Long;
  p: PByteArray;
begin
  LCD.PixelFormat := pf24Bit;

  // simulate contrast and brightness
  for y := 0 to LCD.Height - 1 do begin
    p := LCD.ScanLine[y];
    for x := 0 to LCD.Width * 3 - 1 do begin
      if p[x] = 255 then p[x] := 12 * White div 10 + 135;  // white dots 147..255
      if p[x] = 0 then p[x]   := 12 * (10 - Black div 10); // black dots 0..108
    end;
  end;
end;

//------------------------------------------------------------------------------
// SETDOT - DELPHI implementation for Tiger set_dot
//------------------------------------------------------------------ 17.02.07 --
procedure SetDot(X, Y, Mode, Pen: Long);
var
  col: TColor;  // Pen not used (=0)
begin
  if Mode = 0 then
    col := clBlack
  else
    col := clWhite;

  LcdBuffer.Canvas.Pixels[X, Y] := col;
end;

//------------------------------------------------------------------------------
// GRAPHICCOPY - DELPHI implementation for Tiger graphic_copy
//------------------------------------------------------------------ 17.02.07 --
procedure GraphicCopy(Bitmap: TImage; W, H, X, Y, W2, H2, X2, Y2, W3, H3, Mode: Long);
var
  mask, copy: TRect;
begin
  copy := Rect(X2, Y2, X2 + W3, Y2 + H3);
  mask := Rect(X, Y, X + W3, Y + H3);

  case Mode of
    0: LcdBuffer.Canvas.CopyMode := cmSrcCopy;
    1: LcdBuffer.Canvas.CopyMode := cmSrcPaint;
    2: LcdBuffer.Canvas.CopyMode := cmSrcAnd;
    3: LcdBuffer.Canvas.CopyMode := cmMergePaint;
  else
       LcdBuffer.Canvas.CopyMode := cmSrcCopy;
  end;

  LcdBuffer.Canvas.CopyRect(mask, Bitmap.Canvas, copy);
end;

//------------------------------------------------------------------------------
// GRAPHICFILLMASK - DELPHI implementation for Tiger graphic_fill_mask
//------------------------------------------------------------------ 17.02.07 --
procedure GraphicFillMask(W, H, X, Y, W2, H2, Dot: Long);
var
  mask: TRect;
begin
  mask := Rect(X, Y, X + W2, Y + H2);

  if Dot = 0 then
    LcdBuffer.Canvas.Brush.Color := clWhite
  else
    LcdBuffer.Canvas.Brush.Color := clBlack;

  LcdBuffer.Canvas.FillRect(mask);
end;


initialization  // Tiger hardware configuration
  LcdPenX := cCLEAR;
  LcdPenY := cCLEAR;
  LcdInit := cOFF;
  LcdScale := 200; // [%]
  LcdScreen := Rect(0, 0, LCDXRANGE, LCDYRANGE);
  LcdBuff := sEMPTY;

finalization
  LcdPenX := cCLEAR;
  LcdPenY := cCLEAR;
  LcdInit := cOFF;
  LcdBuff := sEMPTY;
  
  LcdBuffer := nil;
  LcdLayer1 := nil;
  LcdLayer2 := nil;
  LcdLayer3 := nil;

end.
