// Graphic Display Functions
// Date 26.05.22

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit Display;

interface

uses
  Forms, Types, Controls, Graphics, Math, SysUtils, ExtCtrls, USystem,
  SYS, LCD, Global, Data, FLog;

const
  NORMPOS       = 0;        // text position
  LEFTPOS       = 10;
  MIDPOS        = 11;
  RIGHTPOS      = 12;
  POSSPACE      = 10;
  POSMINUS      = 11;
  POSERROR      = 14;

  TINYCHAR      = 1;        // character font
  SMALLCHAR     = 2;
  BOLDCHAR      = 3;
  BIGCHAR       = 4;
  TINYNUMS      = 5;
  SMALLNUMS     = 6;
  BOLDNUMS      = 7;
  BIGNUMS       = 8;
  LARGENUMS     = 9;

  MAXFONTS      = 10;       // max number of fonts defined
  FONTDEFS      = 6;        // number of font definitions
  MAXCHARS      = 5;        // max number of character fonts
  CHARDEFS      = 49;       // number of characters/font
  MAXNUMBS      = 5;        // max number of numerical fonts
  MAXSYMBS      = 52;       // max number of symbols defined
  SYMBDEFS      = 5;        // number of symbol definitions
  MAXICONS      = 9;        // max number of icons defined
  ICONDEFS      = 6;        // number of icon definitions
  ROW2CHAR      = 100;      // characters defined in the 2nd row
  SYMBCODE      = 126;      // ascii code for symbol definitions
  BEARSYMBOL    = 24;       // symbol number for bearing arrows
  MOONSYMBOL    = 38;       // symbol number for moon phases

  ICONNONE      = 0;        // icon number if undefined
  ICONWAITING   = 1;        // icon number for waiting
  ICONDANGER    = 2;        // icon number for danger
  ICONWARNING   = 3;        // icon number for warning
  ICONQUESTION  = 4;        // icon number for question
  ICONOKSIGN    = 5;        // icon number for ok
  ICONTHUMBUP   = 6;        // icon number for thumb up
  ICONCLOCK     = 7;        // icon number for clock
  ICONINFO      = 8;        // icon number for info sign
  ICONMORTAL    = 9;        // icon number for mortal danger

var
  BITMAP00: TImage;
  BITMAP01: TImage;
  BITMAP02: TImage;
  BITMAP03: TImage;

  WINDOW00: TImage;
  WINDOW01: TImage;
  WINDOW02: TImage;
  WINDOW03: TImage;
  WINDOW04: TImage;
  WINDOW05: TImage;
  WINDOW06: TImage;
  WINDOW07: TImage;

  FONT01: TImage;
  FONT02: TImage;
  FONT03: TImage;
  FONT04: TImage;
  FONT05: TImage;
  FONT06: TImage;
  FONT07: TImage;
  FONT08: TImage;
  FONT09: TImage;

  GraBuff: string; //old=[MAXBUFF];

  CharDim: array[0..MAXCHARS, 0..CHARDEFS] of Byte; // character dimension table
  FontDef: array[0..MAXFONTS, 0..FONTDEFS] of Byte; // font definition table
  SymbDef: array[0..MAXSYMBS, 0..SYMBDEFS] of Byte; // symbol definition table
  IconDef: array[0..ICONDEFS] of Byte;              // icon definition table

  procedure InitGraphics;
  procedure InitScreen(Win: Byte);
  procedure ClearBox(Box: Word);
  procedure DispNumValue(Box: Word; Value: Long);
  procedure DispText(Box: Word; Text: string; Mode: Byte);
  procedure DispSymbol(Box: Word; Symbol: Byte);
  procedure DispBitmap(Box, Xof, Yof: Word);
  procedure DispWindow(Win, Ps, Pe: Byte);
  procedure DispBarValue(Box: Word; Value: Long);
  procedure DrawBox(Box: Word);
  procedure DrawLine(Box: Word);
  procedure DrawLineFrom(Px, Py, Mode: Byte);
  procedure DrawLineTo(Px, Py, Dx, Dy: Byte);
  procedure DrawDot(Px, Py, Mode: Byte);
  procedure GetFont(Font, Anum: Byte; var Fpos, Fdim, Fcor: Byte);
  procedure GetBearSymbol(BearDir: Long; var BearCode: Byte);
  
implementation

uses FMain, FGui;

//------------------------------------------------------------------------------
// INITGRAPHICS - Initialize graphic workspace and load fonts and symbols
//------------------------------------------------------------------ 17.02.07 --
procedure InitGraphics;
var
  i, j: Long;
begin
  try // 02.03.07 nk opt - load bitmaps from resource file 'Tiger.res'
    GraBuff := 'Loading bitmaps';

    BITMAP00 := TImage.Create(Gui);
    BITMAP00.Picture.Bitmap.LoadFromResourceName(HInstance, 'BITMAP00');

    BITMAP01 := TImage.Create(Gui);
    BITMAP01.Picture.Bitmap.LoadFromResourceName(HInstance, 'BITMAP01');

    BITMAP02 := TImage.Create(Gui);
    BITMAP02.Picture.Bitmap.LoadFromResourceName(HInstance, 'BITMAP02');

    BITMAP03 := TImage.Create(Gui);
    BITMAP03.Picture.Bitmap.LoadFromResourceName(HInstance, 'BITMAP03');

    GraBuff := 'Loading windows';

    WINDOW00 := TImage.Create(Gui);
    WINDOW00.Picture.Bitmap.LoadFromResourceName(HInstance, 'WINDOW00');

    WINDOW01 := TImage.Create(Gui);
    WINDOW01.Picture.Bitmap.LoadFromResourceName(HInstance, 'WINDOW01');

    WINDOW02 := TImage.Create(Gui);
    WINDOW02.Picture.Bitmap.LoadFromResourceName(HInstance, 'WINDOW02');

    WINDOW03 := TImage.Create(Gui);
    WINDOW03.Picture.Bitmap.LoadFromResourceName(HInstance, 'WINDOW03');

    WINDOW04 := TImage.Create(Gui);
    WINDOW04.Picture.Bitmap.LoadFromResourceName(HInstance, 'WINDOW04');

    WINDOW05 := TImage.Create(Gui);
    WINDOW05.Picture.Bitmap.LoadFromResourceName(HInstance, 'WINDOW05');

    WINDOW06 := TImage.Create(Gui);
    WINDOW06.Picture.Bitmap.LoadFromResourceName(HInstance, 'WINDOW06');

    WINDOW07 := TImage.Create(Gui);
    WINDOW07.Picture.Bitmap.LoadFromResourceName(HInstance, 'WINDOW07');

    GraBuff := 'Loading fonts';

    FONT01 := TImage.Create(Gui);
    FONT01.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT01');

    FONT02 := TImage.Create(Gui);
    FONT02.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT02');

    FONT03 := TImage.Create(Gui);
    FONT03.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT03');

    FONT04 := TImage.Create(Gui);
    FONT04.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT04');

    FONT05 := TImage.Create(Gui);
    FONT05.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT05');

    FONT06 := TImage.Create(Gui);
    FONT06.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT06');

    FONT07 := TImage.Create(Gui);
    FONT07.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT07');

    FONT08 := TImage.Create(Gui);
    FONT08.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT08');

    FONT09 := TImage.Create(Gui);
    FONT09.Picture.Bitmap.LoadFromResourceName(HInstance, 'FONT09');
  except
    LogError('InitGraphics', GraBuff, 'failed!', $A0);
    Main.Close;  // fatal error - abort program
    WaitDuration(DISPDELAY);
    Halt;
  end;

  // clear definition tables
  for i := 0 to MAXCHARS - 1 do begin
    for j := 0 to CHARDEFS - 1 do begin
      CharDim[i, j] := cCLEAR;
    end;
  end;
  
  for i := 0 to MAXFONTS - 1 do begin
    for j := 0 to FONTDEFS - 1 do begin
      FontDef[i, j] := cCLEAR;
    end;
  end;
  
  for i := 0 to MAXSYMBS - 1 do begin
    for j := 0 to SYMBDEFS - 1 do begin
      SymbDef[i, j] := cCLEAR;
    end;
  end;
  
  for j := 0 to ICONDEFS - 1 do begin
    IconDef[j] := cCLEAR;
  end;

  // TINY character font #1 3x5 dots (width in dots)

  CharDim[1, 0]  := 3;  // Numbers
  CharDim[1, 1]  := 3;  // A
  CharDim[1, 2]  := 3;  // B
  CharDim[1, 3]  := 3;  // C
  CharDim[1, 4]  := 3;  // D
  CharDim[1, 5]  := 3;  // E
  CharDim[1, 6]  := 3;  // F
  CharDim[1, 7]  := 3;  // G
  CharDim[1, 8]  := 3;  // H
  CharDim[1, 9]  := 3;  // I
  CharDim[1, 10] := 3;  // J
  CharDim[1, 11] := 3;  // K
  CharDim[1, 12] := 3;  // L
  CharDim[1, 13] := 3;  // M
  CharDim[1, 14] := 3;  // N
  CharDim[1, 15] := 3;  // O
  CharDim[1, 16] := 3;  // P
  CharDim[1, 17] := 3;  // Q
  CharDim[1, 18] := 3;  // R
  CharDim[1, 19] := 3;  // S
  CharDim[1, 20] := 3;  // T
  CharDim[1, 21] := 3;  // U
  CharDim[1, 22] := 3;  // V
  CharDim[1, 23] := 3;  // W
  CharDim[1, 24] := 3;  // X
  CharDim[1, 25] := 3;  // Y
  CharDim[1, 26] := 3;  // Z
  CharDim[1, 27] := 2;  // _
  CharDim[1, 28] := 2;  // (
  CharDim[1, 29] := 2;  // )
  CharDim[1, 30] := 3;  // %
  CharDim[1, 31] := 1;  // .
  CharDim[1, 32] := 1;  // :
  CharDim[1, 33] := 3;  // -
  CharDim[1, 34] := 3;  // +
  CharDim[1, 35] := 3;  // °
  CharDim[1, 36] := 1;  // '
  CharDim[1, 37] := 1;  // !
  CharDim[1, 38] := 3;  // ?
  CharDim[1, 39] := 3;  // /
  CharDim[1, 40] := 1;  // | (US date delimiter)
  CharDim[1, 41] := 1;  // ­ (ISO date delimiter)
  CharDim[1, 42] := 3;  // left arrow
  CharDim[1, 43] := 3;  // right arrow
  CharDim[1, 44] := 0;  // 0=NOT YET DEFINED

  // SMALL character font #2 5x5 dots (width in dots)

  CharDim[2, 0]  := 3;  // Numbers and small characters
  CharDim[2, 1]  := 4;  // A
  CharDim[2, 2]  := 4;  // B
  CharDim[2, 3]  := 4;  // C
  CharDim[2, 4]  := 4;  // D
  CharDim[2, 5]  := 4;  // E
  CharDim[2, 6]  := 4;  // F
  CharDim[2, 7]  := 4;  // G
  CharDim[2, 8]  := 4;  // H
  CharDim[2, 9]  := 3;  // I
  CharDim[2, 10] := 4;  // J
  CharDim[2, 11] := 4;  // K
  CharDim[2, 12] := 3;  // L
  CharDim[2, 13] := 5;  // M
  CharDim[2, 14] := 4;  // N
  CharDim[2, 15] := 4;  // O
  CharDim[2, 16] := 4;  // P
  CharDim[2, 17] := 4;  // Q
  CharDim[2, 18] := 4;  // R
  CharDim[2, 19] := 4;  // S
  CharDim[2, 20] := 3;  // T
  CharDim[2, 21] := 4;  // U
  CharDim[2, 22] := 4;  // V
  CharDim[2, 23] := 5;  // W
  CharDim[2, 24] := 4;  // X
  CharDim[2, 25] := 4;  // Y
  CharDim[2, 26] := 4;  // Z
  CharDim[2, 27] := 2;  // _
  CharDim[2, 28] := 2;  // (
  CharDim[2, 29] := 2;  // )
  CharDim[2, 30] := 3;  // %
  CharDim[2, 31] := 1;  // .
  CharDim[2, 32] := 1;  // :
  CharDim[2, 33] := 3;  // -
  CharDim[2, 34] := 3;  // +
  CharDim[2, 35] := 3;  // °
  CharDim[2, 36] := 1;  // '
  CharDim[2, 37] := 1;  // !
  CharDim[2, 38] := 3;  // ?
  CharDim[2, 39] := 3;  // /
  CharDim[2, 40] := 1;  // | (US date delimiter)
  CharDim[2, 41] := 1;  // ­ (ISO date delimiter)
  CharDim[2, 42] := 5;  // left arrow
  CharDim[2, 43] := 5;  // right arrow
  CharDim[2, 44] := 5;  // Ft (feet symbol ~1)
  CharDim[2, 45] := 5;  // lb (pound symbol ~2)
  CharDim[2, 46] := 5;  // in (inch symbol ~3)
  CharDim[2, 47] := 5;  // X (off symbol ~4)
  CharDim[2, 48] := 4;  // / (on symbol ~5)

  // BOLD character font #3 5x5 dots, (width in dots)

  CharDim[3, 0]  := 4;  // Numbers
  CharDim[3, 1]  := 4;  // A
  CharDim[3, 2]  := 4;  // B
  CharDim[3, 3]  := 4;  // C
  CharDim[3, 4]  := 4;  // D
  CharDim[3, 5]  := 4;  // E
  CharDim[3, 6]  := 4;  // F
  CharDim[3, 7]  := 4;  // G
  CharDim[3, 8]  := 4;  // H
  CharDim[3, 9]  := 4;  // I
  CharDim[3, 10] := 4;  // J
  CharDim[3, 11] := 5;  // K
  CharDim[3, 12] := 4;  // L
  CharDim[3, 13] := 5;  // M
  CharDim[3, 14] := 4;  // N
  CharDim[3, 15] := 4;  // O
  CharDim[3, 16] := 4;  // P
  CharDim[3, 17] := 4;  // Q
  CharDim[3, 18] := 4;  // R
  CharDim[3, 19] := 4;  // S
  CharDim[3, 20] := 4;  // T
  CharDim[3, 21] := 4;  // U
  CharDim[3, 22] := 4;  // V
  CharDim[3, 23] := 5;  // W
  CharDim[3, 24] := 4;  // X
  CharDim[3, 25] := 4;  // Y
  CharDim[3, 26] := 4;  // Z
  CharDim[3, 27] := 3;  // _
  CharDim[3, 28] := 0;  // 0=NOT YET DEFINED

  // BIG character font #4 7x7 dots (width in dots)

  CharDim[4, 0]  := 5;  // Numbers
  CharDim[4, 1]  := 6;  // A
  CharDim[4, 2]  := 6;  // B
  CharDim[4, 3]  := 5;  // C
  CharDim[4, 4]  := 6;  // D
  CharDim[4, 5]  := 6;  // E
  CharDim[4, 6]  := 6;  // F
  CharDim[4, 7]  := 6;  // G
  CharDim[4, 8]  := 6;  // H
  CharDim[4, 9]  := 4;  // I
  CharDim[4, 10] := 5;  // J
  CharDim[4, 11] := 7;  // K
  CharDim[4, 12] := 6;  // L
  CharDim[4, 13] := 7;  // M
  CharDim[4, 14] := 6;  // N
  CharDim[4, 15] := 6;  // O
  CharDim[4, 16] := 6;  // P
  CharDim[4, 17] := 7;  // Q
  CharDim[4, 18] := 6;  // R
  CharDim[4, 19] := 6;  // S
  CharDim[4, 20] := 6;  // T
  CharDim[4, 21] := 6;  // U
  CharDim[4, 22] := 6;  // V
  CharDim[4, 23] := 7;  // W
  CharDim[4, 24] := 6;  // X
  CharDim[4, 25] := 6;  // Y
  CharDim[4, 26] := 6;  // Z
  CharDim[4, 27] := 3;  // _
  CharDim[4, 28] := 3;  // (
  CharDim[4, 29] := 3;  // )
  CharDim[4, 30] := 7;  // %
  CharDim[4, 31] := 1;  // .
  CharDim[4, 32] := 1;  // :
  CharDim[4, 33] := 3;  // -
  CharDim[4, 34] := 3;  // +
  CharDim[4, 35] := 3;  // °
  CharDim[4, 36] := 1;  // '
  CharDim[4, 37] := 1;  // !
  CharDim[4, 38] := 3;  // ?
  CharDim[4, 39] := 3;  // /
  CharDim[4, 40] := 3;  // | (US date delimiter)
  CharDim[4, 41] := 3;  // ­ (ISO date delimiter)
  CharDim[4, 42] := 4;  // left arrow
  CharDim[4, 43] := 4;  // right arrow
  CharDim[4, 44] := 6;  // Ft (feet symbol ~1)
  CharDim[4, 45] := 7;  // lb (pound symbol ~2)
  CharDim[4, 46] := 5;  // in (inch symbol ~3)
  CharDim[4, 47] := 5;  // X (off symbol ~4)
  CharDim[4, 48] := 6;  // / (on symbol ~5)

  GraBuff := IntToStr(MAXCHARS);
  LogEvent('InitGraphics', 'Character sets initialized', GraBuff);

  FontDef[1, 1] :=  3;  // fx    TINY character font 3x5 dots
  FontDef[1, 2] :=  5;  // fy    ABCDE...XYZ_()%.:-+°'!?/|-{}
  FontDef[1, 3] := 22;  // lx    font table length/LCDBYTE
  FontDef[1, 4] :=  7;  // ly    font tabel height
  FontDef[1, 5] :=  1;  // fs

  FontDef[2, 1] :=  5;  // fx    SMALL character / numeric font 5x5 dots
  FontDef[2, 2] :=  5;  // fy    ABCDE...XYZ_()%.:-+°'!?/|-{} Ft lb in on off
  FontDef[2, 3] := 37;  // lx    abcde...xyz0123456789
  FontDef[2, 4] := 14;  // ly
  FontDef[2, 5] :=  1;  // fs

  FontDef[3, 1] :=  5;  // fx    BOLD character font 5x5 dots
  FontDef[3, 2] :=  5;  // fy    ABCDE...XYZ_
  FontDef[3, 3] := 20;  // lx
  FontDef[3, 4] :=  7;  // ly
  FontDef[3, 5] :=  1;  // fs

  FontDef[4, 1] :=  7;  // fx    BIG character font 7x7 dots
  FontDef[4, 2] :=  7;  // fy    ABCDE...XYZ_()%.:-+°'!?/|-{} Ft lb in on off
  FontDef[4, 3] := 49;  // lx    0123456789 // and numbers in 2nd row
  FontDef[4, 4] := 18;  // ly
  FontDef[4, 5] :=  1;  // fs

  FontDef[5, 1] :=  3;  // fx    TINY numeric font 3x5 dots
  FontDef[5, 2] :=  5;  // fy    0123456789_-.:!
  FontDef[5, 3] :=  8;  // lx    last sign is pseudo delimiter for leading zeors
  FontDef[5, 4] :=  7;  // ly
  FontDef[5, 5] :=  1;  // fs

  FontDef[6, 1] :=  4;  // fx    SMALL numeric font 4x7 dots
  FontDef[6, 2] :=  7;  // fy    0123456789_-.:!
  FontDef[6, 3] := 10;  // lx
  FontDef[6, 4] :=  9;  // ly
  FontDef[6, 5] :=  1;  // fs

  FontDef[7, 1] :=  5;  // fx    BOLD numeric font 5x7 dots
  FontDef[7, 2] :=  7;  // fy    0123456789_-.:!
  FontDef[7, 3] := 12;  // lx
  FontDef[7, 4] :=  9;  // ly
  FontDef[7, 5] :=  1;  // fs

  FontDef[8, 1] :=  6;  // fx    BIG numeric font 6x9 dots
  FontDef[8, 2] :=  9;  // fy    0123456789_-.:!
  FontDef[8, 3] := 15;  // lx
  FontDef[8, 4] := 11;  // ly
  FontDef[8, 5] :=  2;  // fs

  FontDef[9, 1] :=  8;  // fx    HUGE numeric font 8x12 dots
  FontDef[9, 2] := 12;  // fy    0123456789_-.:!
  FontDef[9, 3] := 19;  // lx
  FontDef[9, 4] := 14;  // ly
  FontDef[9, 5] :=  2;  // fs

  GraBuff := IntToStr(MAXFONTS);
  LogEvent('InitGraphics', 'Fonts initialized', GraBuff);

  IconDef[0] :=   3;     // bm    number of icon bitmap file (Bitmap03.bmp)
  IconDef[1] :=  20;     // lx    icon tabel length/LCDBYTE
  IconDef[2] :=  18;     // ly    icon tabel height
  IconDef[3] :=  MAXICONS; //     number of icons defined
  IconDef[4] :=  16;     // bx    x-dimension of icons [dots]
  IconDef[5] :=  16;     // by    y-dimension of icons [dots]

  GraBuff := IntToStr(MAXICONS);
  LogEvent('InitGraphics', 'Icons initialized', GraBuff);

  SymbDef[0, 1] :=  14;  // lx    symbol tabel length/LCDBYTE
  SymbDef[0, 2] :=  48;  // ly    symbol tabel height
  SymbDef[0, 3] :=  MAXSYMBS; //  number of symbols defined
  SymbDef[0, 4] :=  0;

  SymbDef[1, 1] :=  1;  // px    big arrow up
  SymbDef[1, 2] :=  1;  // py
  SymbDef[1, 3] :=  7;  // fx
  SymbDef[1, 4] :=  9;  // fy

  SymbDef[2, 1] := 11;  // px    big arrow down
  SymbDef[2, 2] :=  1;  // py
  SymbDef[2, 3] :=  7;  // fx
  SymbDef[2, 4] :=  9;  // fy

  SymbDef[3, 1] := 21;  // px    minus sign [-]
  SymbDef[3, 2] :=  1;  // py
  SymbDef[3, 3] :=  7;  // fx
  SymbDef[3, 4] :=  9;  // fy

  SymbDef[4, 1] := 30;  // px    plus sign [+]
  SymbDef[4, 2] :=  1;  // py
  SymbDef[4, 3] :=  7;  // fx
  SymbDef[4, 4] :=  9;  // fy

  SymbDef[5, 1] := 40;  // px    small arrow rigth
  SymbDef[5, 2] :=  1;  // py
  SymbDef[5, 3] :=  7;  // fx
  SymbDef[5, 4] :=  5;  // fy

  SymbDef[6, 1] := 50;  // px    small arrow up
  SymbDef[6, 2] :=  1;  // py
  SymbDef[6, 3] :=  7;  // fx
  SymbDef[6, 4] :=  7;  // fy

  SymbDef[7, 1] := 60;  // px    percent sign [%]
  SymbDef[7, 2] :=  1;  // py
  SymbDef[7, 3] :=  7;  // fx
  SymbDef[7, 4] :=  7;  // fy

  SymbDef[8, 1] := 70;  // px    centigrade [°C]
  SymbDef[8, 2] :=  1;  // py
  SymbDef[8, 3] :=  8;  // fx
  SymbDef[8, 4] :=  7;  // fy

  SymbDef[9, 1] := 81;  // px    fahrenheit [°F]
  SymbDef[9, 2] :=  1;  // py
  SymbDef[9, 3] :=  8;  // fx
  SymbDef[9, 4] :=  7;  // fy

  SymbDef[10, 1] := 92;  // px    degree sign [°]
  SymbDef[10, 2] :=  1;  // py
  SymbDef[10, 3] :=  3;  // fx
  SymbDef[10, 4] :=  3;  // fy

  SymbDef[11, 1] :=  1;  // px    pointer up
  SymbDef[11, 2] := 12;  // py
  SymbDef[11, 3] :=  7;  // fx
  SymbDef[11, 4] :=  7;  // fy

  SymbDef[12, 1] := 11;  // px    pointer down
  SymbDef[12, 2] := 12;  // py
  SymbDef[12, 3] :=  7;  // fx
  SymbDef[12, 4] :=  7;  // fy

  SymbDef[13, 1] :=  1;  // px    meter [M] symbol
  SymbDef[13, 2] := 29;  // py
  SymbDef[13, 3] :=  5;  // fx
  SymbDef[13, 4] :=  5;  // fy

  SymbDef[14, 1] :=  9;  // px    feet [Ft] symbol
  SymbDef[14, 2] := 29;  // py
  SymbDef[14, 3] :=  5;  // fx
  SymbDef[14, 4] :=  5;  // fy

  SymbDef[15, 1] := 17;  // px    yard [yd] symbol
  SymbDef[15, 2] := 29;  // py
  SymbDef[15, 3] :=  6;  // fx
  SymbDef[15, 4] :=  5;  // fy

  SymbDef[16, 1] := 22;  // px    arrow left/right (select)
  SymbDef[16, 2] := 12;  // py
  SymbDef[16, 3] :=  7;  // fx
  SymbDef[16, 4] :=  5;  // fy

  SymbDef[17, 1] := 48;  // px    heading pointer
  SymbDef[17, 2] := 12;  // py
  SymbDef[17, 3] :=  7;  // fx
  SymbDef[17, 4] :=  4;  // fy

  SymbDef[18, 1] := 58;  // px    surface symbol
  SymbDef[18, 2] := 11;  // py
  SymbDef[18, 3] :=  7;  // fx
  SymbDef[18, 4] :=  7;  // fy

  SymbDef[19, 1] := 68;  // px    not fly symbol
  SymbDef[19, 2] := 11;  // py
  SymbDef[19, 3] :=  7;  // fx
  SymbDef[19, 4] :=  7;  // fy

  SymbDef[20, 1] := 98;  // px    small percent sign [%]
  SymbDef[20, 2] :=  3;  // py
  SymbDef[20, 3] :=  4;  // fx
  SymbDef[20, 4] :=  4;  // fy

  SymbDef[21, 1] := 32;  // px    pointer left
  SymbDef[21, 2] := 12;  // py
  SymbDef[21, 3] :=  4;  // fx
  SymbDef[21, 4] :=  5;  // fy

  SymbDef[22, 1] := 40;  // px    pointer right
  SymbDef[22, 2] := 12;  // py
  SymbDef[22, 3] :=  4;  // fx
  SymbDef[22, 4] :=  5;  // fy

  SymbDef[23, 1] := 98;  // px    desaturation symbol
  SymbDef[23, 2] := 11;  // py
  SymbDef[23, 3] :=  7;  // fx
  SymbDef[23, 4] :=  7;  // fy

  SymbDef[24, 1] :=  1;  // px    bearing symbol #0 (arrow down) - BEARSYMBOL=24
  SymbDef[24, 2] := 20;  // py
  SymbDef[24, 3] := 11;  // fx
  SymbDef[24, 4] :=  7;  // fy

  SymbDef[25, 1] := 14;  // px    bearing symbol #1 (dbl arrow left)
  SymbDef[25, 2] := 20;  // py
  SymbDef[25, 3] := 11;  // fx
  SymbDef[25, 4] :=  7;  // fy

  SymbDef[26, 1] := 27;  // px    bearing symbol #2 (arrow left)
  SymbDef[26, 2] := 20;  // py
  SymbDef[26, 3] := 11;  // fx
  SymbDef[26, 4] :=  7;  // fy

  SymbDef[27, 1] := 40;  // px    bearing symbol #3 (arrow up)
  SymbDef[27, 2] := 20;  // py
  SymbDef[27, 3] := 11;  // fx
  SymbDef[27, 4] :=  7;  // fy

  SymbDef[28, 1] := 53;  // px    bearing symbol #4 (arrow right)
  SymbDef[28, 2] := 20;  // py
  SymbDef[28, 3] := 11;  // fx
  SymbDef[28, 4] :=  7;  // fy

  SymbDef[29, 1] := 66;  // px    bearing symbol #5 (dbl arrow right)
  SymbDef[29, 2] := 20;  // py
  SymbDef[29, 3] := 11;  // fx
  SymbDef[29, 4] :=  7;  // fy

  SymbDef[30, 1] := 26;  // px    bar [BAR] symbol
  SymbDef[30, 2] := 29;  // py
  SymbDef[30, 3] := 11;  // fx
  SymbDef[30, 4] :=  5;  // fy

  SymbDef[31, 1] := 40;  // px    psi [PSI] symbol
  SymbDef[31, 2] := 29;  // py
  SymbDef[31, 3] := 11;  // fx
  SymbDef[31, 4] :=  5;  // fy

  SymbDef[32, 1] := 54;  // px    hekto pascal [hPa] symbol
  SymbDef[32, 2] := 29;  // py
  SymbDef[32, 3] :=  9;  // fx
  SymbDef[32, 4] :=  7;  // fy

  SymbDef[33, 1] := 65;  // px    inch mercury [inHg] symbol
  SymbDef[33, 2] := 29;  // py
  SymbDef[33, 3] :=  9;  // fx
  SymbDef[33, 4] :=  7;  // fy

  SymbDef[34, 1] := 75;  // px    oxygen [O2] symbol
  SymbDef[34, 2] := 29;  // py
  SymbDef[34, 3] :=  8;  // fx
  SymbDef[34, 4] :=  7;  // fy

  SymbDef[35, 1] := 84;  // px    clock alarm symbol
  SymbDef[35, 2] := 29;  // py
  SymbDef[35, 3] :=  6;  // fx
  SymbDef[35, 4] :=  7;  // fy

  SymbDef[36, 1] := 78;  // px    warning symbol
  SymbDef[36, 2] := 11;  // py
  SymbDef[36, 3] :=  7;  // fx
  SymbDef[36, 4] :=  7;  // fy

  SymbDef[37, 1] := 88;  // px    cursor pointer
  SymbDef[37, 2] := 11;  // py
  SymbDef[37, 3] :=  6;  // fx
  SymbDef[37, 4] :=  6;  // fy

  SymbDef[38, 1] :=  1;  // px    moon symbol #0 (new moon) - MOONSYMBOL=38
  SymbDef[38, 2] := 37;  // py
  SymbDef[38, 3] :=  7;  // fx
  SymbDef[38, 4] :=  7;  // fy

  SymbDef[39, 1] := 10;  // px    moon symbol #1
  SymbDef[39, 2] := 37;  // py
  SymbDef[39, 3] :=  7;  // fx
  SymbDef[39, 4] :=  7;  // fy

  SymbDef[40, 1] := 19;  // px    moon symbol #2
  SymbDef[40, 2] := 37;  // py
  SymbDef[40, 3] :=  7;  // fx
  SymbDef[40, 4] :=  7;  // fy

  SymbDef[41, 1] := 28;  // px    moon symbol #3 (half moon)
  SymbDef[41, 2] := 37;  // py
  SymbDef[41, 3] :=  7;  // fx
  SymbDef[41, 4] :=  7;  // fy

  SymbDef[42, 1] := 37;  // px    moon symbol #4
  SymbDef[42, 2] := 37;  // py
  SymbDef[42, 3] :=  7;  // fx
  SymbDef[42, 4] :=  7;  // fy

  SymbDef[43, 1] := 46;  // px    moon symbol #5
  SymbDef[43, 2] := 37;  // py
  SymbDef[43, 3] :=  7;  // fx
  SymbDef[43, 4] :=  7;  // fy

  SymbDef[44, 1] := 55;  // px    moon symbol #6 [full moon)
  SymbDef[44, 2] := 37;  // py
  SymbDef[44, 3] :=  7;  // fx
  SymbDef[44, 4] :=  7;  // fy

  SymbDef[45, 1] := 64;  // px    moon symbol #7
  SymbDef[45, 2] := 37;  // py
  SymbDef[45, 3] :=  7;  // fx
  SymbDef[45, 4] :=  7;  // fy

  SymbDef[46, 1] := 73;  // px    moon symbol #8
  SymbDef[46, 2] := 37;  // py
  SymbDef[46, 3] :=  7;  // fx
  SymbDef[46, 4] :=  7;  // fy

  SymbDef[47, 1] := 82;  // px    moon symbol #9 [half moon)
  SymbDef[47, 2] := 37;  // py
  SymbDef[47, 3] :=  7;  // fx
  SymbDef[47, 4] :=  7;  // fy

  SymbDef[48, 1] := 91;  // px    moon symbol #10
  SymbDef[48, 2] := 37;  // py
  SymbDef[48, 3] :=  7;  // fx
  SymbDef[48, 4] :=  7;  // fy

  SymbDef[49, 1] :=100;  // px    moon symbol #11
  SymbDef[49, 2] := 37;  // py
  SymbDef[49, 3] :=  7;  // fx
  SymbDef[49, 4] :=  7;  // fy

  SymbDef[50, 1] := 91;  // px    no sonar symbol   02.06.07 nk add ff
  SymbDef[50, 2] := 29;  // py
  SymbDef[50, 3] :=  6;  // fx
  SymbDef[50, 4] :=  6;  // fy

  GraBuff := IntToStr(MAXSYMBS);
  LogEvent('InitGraphics', 'Symbols initialized', GraBuff);
end;

//------------------------------------------------------------------------------
// INITSCREEN - Initialize graphic display buffer with background pattern
//------------------------------------------------------------------ 17.02.07 --
procedure InitScreen(Win: Byte);
begin
  case Win of
    0: LcdBuffer.Picture.Assign(WINDOW00.Picture);
    1: LcdBuffer.Picture.Assign(WINDOW01.Picture);
    2: LcdBuffer.Picture.Assign(WINDOW02.Picture);
    3: LcdBuffer.Picture.Assign(WINDOW03.Picture);
    4: LcdBuffer.Picture.Assign(WINDOW04.Picture);
    5: LcdBuffer.Picture.Assign(WINDOW05.Picture);
    6: LcdBuffer.Picture.Assign(WINDOW06.Picture);
    7: LcdBuffer.Picture.Assign(WINDOW07.Picture);
  else
    GraBuff := IntToStr(Win);
    LogError('InitScreen', 'Unsupported window', GraBuff, $90);
  end;
end;

//------------------------------------------------------------------------------
// CLEARBOX - Fast function to clear a box (or fill it with white dots)
//   dot=0 means white dots instead of DOTOFF=1 !
//------------------------------------------------------------------ 17.02.07 --
procedure ClearBox(Box: Word);
var
  dx, dy, bx, by, wx, wy, dot, win: Byte;
begin

  win := BoxSpec[Box, 1];  // actual window
  wx  := WinSpec[win, 1];
  wy  := WinSpec[win, 2];
  bx  := BoxSpec[Box, 2];
  by  := BoxSpec[Box, 3];
  dx  := BoxSpec[Box, 4];
  dy  := BoxSpec[Box, 5];
  dot := BoxSpec[Box, 9] mod 10;

  // show inverse boxes for debugging
  if DebugFlag = cON then begin
    if Box = BoxNum then Exit;
    InvertBit(dot);
    BoxNum := Box;
  end;

  GraphicFillMask(LCDXRANGE, LCDYRANGE, wx + bx, wy + by, dx, dy, dot)
end;

//------------------------------------------------------------------------------
// DISPNUMVALUE - Display given integer value with optional delimiter in a box
//------------------------------------------------------------------------------
//   Specify type of font in BoxSpec[Box, 7]:
//     font 5 - tiny numeric font 3x5 dots
//     font 6 - small numeric font 4x7 dots
//     font 7 - bold numeric font 5x7 dots
//     font 8 - big numeric font 6x9 dots
//     font 9 - large numeric font 8x12 dots
//     pos 0-9 = digits
//     pos 10  = space
//     pos 11  = minus sign
//     pos 12  = decimal point delimiter
//     pos 13  = double point delimiter
//     pos 14  = error sign (!) for range over-/underflow
//     dmod - 0=COPY, 2=OR, 3=AND, 3=INV
//     lead - 0=SPACE, 1=ZERO
//------------------------------------------------------------------ 17.02.07 --
procedure DispNumValue(Box: Word; Value: Long);
var
  d, ds, fd, fs, ly, bx, by, px, py, fx, fy, wx, wy, win: Byte;
  dnum, dmax, dpos, ddel, dmod, digit, fpos, first, lead: Byte;
  lx, fptr: Word;
  mpos, dval, tval, tmax: Long;
begin
  py := cCLEAR;
  px := cCLEAR;

  win := BoxSpec[Box, 1];   // actual window
  wx  := WinSpec[win, 1];   // start x-pos of window
  wy  := WinSpec[win, 2];   // start y-pos of window

  bx  := BoxSpec[Box, 2];   // start x-pos of box
  by  := BoxSpec[Box, 3];   // start y-pos of box
  fd  := BoxSpec[Box, 7];   // font definition

  lead := BoxSpec[Box, 6];         // leading zero
  dmax := BoxSpec[Box, 8] div 10;  // total number of digits
  dnum := BoxSpec[Box, 8] mod 10;  // digits after decimal point
  tmax := Round(Power(10, dmax));  // max value to display

  if Value < 0 then begin          // negative value
    tval := -Value;                // position of minus sign
    mpos := dmax - dnum - Trunc(Log10(tval)) - 1;
  end else begin
    tval := Value;
    mpos := cNEG;
  end;

  if tval >= tmax then begin       // display range overflow
    tmax    := POSERROR;           // special error sign (!)
    GraBuff := IntToStr(Box);
    LogError('DispNumValue', 'Display range overflow in box', GraBuff, $98);
  end else begin
    tmax := cOFF;
  end;

  ddel := BoxSpec[Box, 9] div 10 + POSMINUS;  // delimiter character
  dmod := BoxSpec[Box, 9] mod 10;  // drawing mode

  fs := FontDef[fd, 5];            // font space
  fx := FontDef[fd, 1] + fs;       // font x-dim + x-space
  fy := FontDef[fd, 2] + 2;        // font y-dim + y-space
  lx := FontDef[fd, 3] * LCDBYTE;  // font file length
  ly := FontDef[fd, 4];            // font file height

  first := cOFF;
  dval  := Round(Power(10, (dmax - 1)));

  // show inverse boxes for debugging
  if DebugFlag = cON then begin
    ClearBox(Box);
    if dmod = LCDDOTON then begin
      dmod := LCDDOTNEG;
    end else begin
      dmod := LCDDOTON;
    end;
  end;

  if dmod > LCDDOTNEG then begin
    dmod := LCDDOTON;       // unsupported dot mode
  end;

  if dnum = cOFF then begin // no delimiter
    dpos := MAXBYTE;
  end else begin
    dpos := dmax - dnum;    // position of delimiter
  end;

  if (tval = 0) and (dnum = 0) then begin // disp value = 0
    first := cON;
    px    := fx * (dmax - 1);
    dmax  := 1;
  end;

  if dnum = 0 then begin
    ds := 1;
  end else begin
    ds := 0;
  end;

  for d := ds to dmax do begin  // from left to right digit
    if dval <> 0 then begin
      digit := tval div dval;
    end else begin
      digit := 0;
    end;

    if digit > 0 then begin
      first := cON;
    end;

    if (digit = 0) and (first = cOFF) then begin
      if d = mpos then begin
        fpos := POSMINUS;         // minus sign
        mpos := cNEG;
      end else begin              // fill left digits..
        if lead = cON then begin
          fpos := 0;              // ..with zero character
        end else begin
          fpos := POSSPACE;       // ..with space character
        end;
      end;
    end else begin
      fpos := digit;
    end;

    if d = dpos then begin
      first := cON;
      fpos  := ddel;         // digit delimiter
    end;

    if tmax <> cOFF then begin
      fpos := POSERROR;     // display range overflow
    end;

    fptr := fpos * fx;      // pointer to digit in font table

    case fd of              // select font
      5: GraphicCopy(FONT05, LCDXRANGE, LCDYRANGE, wx + bx + px, wy + by + py, lx, ly, fptr, 0, fx, fy, dmod);
      6: GraphicCopy(FONT06, LCDXRANGE, LCDYRANGE, wx + bx + px, wy + by + py, lx, ly, fptr, 0, fx, fy, dmod);
      7: GraphicCopy(FONT07, LCDXRANGE, LCDYRANGE, wx + bx + px, wy + by + py, lx, ly, fptr, 0, fx, fy, dmod);
      8: GraphicCopy(FONT08, LCDXRANGE, LCDYRANGE, wx + bx + px, wy + by + py, lx, ly, fptr, 0, fx, fy, dmod);
      9: GraphicCopy(FONT09, LCDXRANGE, LCDYRANGE, wx + bx + px, wy + by + py, lx, ly, fptr, 0, fx, fy, dmod);
    else
        GraBuff := IntToStr(fd) + ' in box ' + IntToStr(Box);
        LogError('DispNumValue', 'Unsupported font', GraBuff, $91);
        Exit;
    end;

    if fpos <= POSMINUS then begin // numbers or minus sign
      px   := px + fx;             // position of next digit
      tval := tval - (digit * dval);
      dval := dval div 10;
    end else begin
      px   := px + 2 * fs;         // space for delimiter
    end;
  end;
end;

//------------------------------------------------------------------------------
// DISPTEXT - Display text string of numbers, characters, and symbols in a box
//------------------------------------------------------------------------------
//   Specify type of font in BoxSpec[Box, 7]:
//     font 1 - tiny character font 3x5 dots
//     font 2 - small character font 5x5 dots
//     font 3 - bold character font 5x5 dots
//     font 4 - big character font 7x7 dots
//     tpos   - text position 0=left, 1=mid, 2=right
//     dmod   - 0=COPY, 1=OR, 2=AND, 3=INV
//     Mode   - overload tpos 10=left, 11=mid, 12=right
//------------------------------------------------------------------ 17.02.07 --
procedure DispText(Box: Word; Text: string; Mode: Byte);
var
  d, dx, cx, ox, oy, fd, fs, ly, bx, by, px, py, fx, fy, ft, wx, wy: Byte;
  Anum, dmax, dpos, dmod, don, dof, tpos, fpos, fcor, fdim, fmid, sym, win: Byte;
  lx, fptr: Word;
  c: Char;
label
  NEXTCHAR;
begin
  ox := cCLEAR;
  oy := cCLEAR;
  py := cCLEAR;
  px := cCLEAR;

  win := BoxSpec[Box, 1];           // actual window
  wx  := WinSpec[win, 1];           // start x-pos of window
  wy  := WinSpec[win, 2];           // start y-pos of window

  bx := BoxSpec[Box, 2];            // start x-pos of box
  by := BoxSpec[Box, 3];            // start y-pos of box
  dx := BoxSpec[Box, 4];            // x-dimension of box
  fd := BoxSpec[Box, 7];            // font definition

  dmax := Length(Text);             // total number of characters
  tpos := BoxSpec[Box, 6];          // text position
  dmod := BoxSpec[Box, 9] mod 10;   // drawing mode

  if Mode >= LEFTPOS then begin
    tpos := Mode - LEFTPOS;         // overload text position
  end;

  fs := FontDef[fd, 5];             // font space
  cx := FontDef[fd, 1] + fs;        // font x-dim + x-space
  fy := FontDef[fd, 2] + 2;         // font y-dim + y-space
  lx := FontDef[fd, 3] * LCDBYTE;   // font file length
  ly := FontDef[fd, 4];             // font file height

  // show inverse boxes for debugging
  if DebugFlag = cON then begin
    ClearBox(Box);
    if dmod = LCDDOTON then begin
      dmod := LCDDOTNEG;
    end else begin
      dmod := LCDDOTON;
    end;
  end;

  if dmod > LCDDOTNEG then begin
    dmod := LCDDOTON;                // unsupported dot mode
  end;

  sym := cOFF;                       // symbol offset

  //Tiger: d=0 to dmax-1
  for d := 1 to dmax do begin        // calculate length of text in dots
    c    := Text[d];                 // get next character
    Anum := Ord(c) + sym;            // ascii number of character (A=65)
    if Anum = SYMBCODE then begin
      sym := SYMBCODE - NAL;         // symbol offset (~1 = SYMBCODE + 1)
    end else begin
      GetFont(fd, Anum, fpos, fdim, fcor);
      ox  := ox + fs + fdim;
      sym := cOFF;
    end;
  end;

  ox := ox + fs; //pixels for all chars

  if (ox > dx) or (ox > LCDXRANGE) then begin
    tpos    := cCLEAR;
    GraBuff := IntToStr(Box) + ' (chars ' + IntToStr(dmax) + ')';
    LogError('DispText', 'Text too long in box', GraBuff, $92);
  end;

  case tpos of                       // text orientation
    1: ox := (dx - ox) div 2;        //   middle
    2: ox := dx - ox;                //   right
  else
    ox := cCLEAR;                    //   left
  end;

  sym := cOFF;                       // symbol offset

  //Tiger: d=0 to dmax-1
  for d := 1 to dmax do begin        // print characters from left to right
    c := Text[d];                    // get next character
    Anum := Ord(c) + sym;            // ascii number of character (A=65)
    if Anum = SYMBCODE then begin
      sym := SYMBCODE - NAL;         // symbol offset (~1 = SYMBCODE + 1)
      goto NEXTCHAR;                 // ignore symbol control code
    end else begin
      GetFont(fd, Anum, fpos, fdim, fcor);
      sym := cOFF;
    end;

    if fpos >= ROW2CHAR then begin   // small characters, numbers, and unit symbols
      fpos := fpos - ROW2CHAR;       // are defined in the 2nd row
      ft   := fy;                    // of font bitmap file
    end else begin
      ft := 0;
    end;

    fx   := fdim + fs;
    fptr := fpos * cx;    // pointer to character in font table

    case fd of // select font
      1: begin
           oy := 0;
           GraphicCopy(FONT01, LCDXRANGE, LCDYRANGE, wx + bx + px + ox, wy + by + py, lx, ly, fptr, ft, fx, fy, dmod);
         end;
      2: begin
           oy := 0;
           GraphicCopy(FONT02, LCDXRANGE, LCDYRANGE, wx + bx + px + ox, wy + by + py, lx, ly, fptr, ft, fx, fy, dmod);
         end;
      3: begin
           oy := 0;
           GraphicCopy(FONT03, LCDXRANGE, LCDYRANGE, wx + bx + px + ox, wy +by + py, lx, ly, fptr, ft, fx, fy, dmod);
         end;
      4: begin
           oy := 1;
           GraphicCopy(FONT04, LCDXRANGE, LCDYRANGE, wx + bx + px + ox, wy + by + py, lx, ly, fptr, ft, fx, fy, dmod);
         end;
    else
        GraBuff := IntToStr(fd) + ' in box ' + IntToStr(Box);
        LogError('DispText', 'Unsupported font', GraBuff, $91);
        Exit;
    end;

    if fcor > cOFF then begin        // extended character with accent
      fmid := fdim div 2;
      if dmod > LCDDOTINV then begin // white dots in black box (inverse)
        don := LCDDOTOFF;
        dof := LCDDOTON;
      end else begin                 // black dots in white box (normal)
        don := LCDDOTON;
        dof := LCDDOTOFF;
      end;

      case fcor of                   // accent type
        1: begin // acute
             SetDot(wx+bx+px+ox+1, wy+by+py-oy, don, LCDPEN);
             SetDot(wx+bx+px+ox+2, wy+by+py-oy, don, LCDPEN);
           end;
        2: begin // grave
             SetDot(wx+bx+px+ox+fdim-1, wy+by+py-oy, don, LCDPEN);
             SetDot(wx+bx+px+ox+fdim,   wy+by+py-oy, don, LCDPEN);
           end;
        3: begin // circumflex or tilde
             SetDot(wx+bx+px+ox+fmid,   wy+by+py-oy, don, LCDPEN);
             SetDot(wx+bx+px+ox+fmid+1, wy+by+py-oy, don, LCDPEN);
           end;
        4: begin // umlaut
             SetDot(wx+bx+px+ox+1,    wy+by+py-oy,   don, LCDPEN);
             SetDot(wx+bx+px+ox+1,    wy+by+py-oy+1, dof, LCDPEN);
             SetDot(wx+bx+px+ox+fdim, wy+by+py-oy,   don, LCDPEN);
             SetDot(wx+bx+px+ox+fdim, wy+by+py-oy+1, dof, LCDPEN);
           end;
        5: begin // special circumflex
             SetDot(wx+bx+px+ox+fmid,   wy+by+py-oy,   don, LCDPEN);
             SetDot(wx+bx+px+ox+1,      wy+by+py-oy+1, dof, LCDPEN);
             SetDot(wx+bx+px+ox+fmid+1, wy+by+py-oy,   don, LCDPEN);
             SetDot(wx+bx+px+ox+fdim,   wy+by+py-oy+1, dof, LCDPEN);
           end;
        6: begin // cedil
             SetDot(wx+bx+px+ox+fdim-1, wy+by+py+fy-1, don, LCDPEN);
           end;
      end;
    end;

    px := px + fx;  // pos of next character

NEXTCHAR:
  end;
end;

//------------------------------------------------------------------------------
// DISPSYMBOL - Display special symbol in a box
//   dmod - 0=COPY, 1=OR, 2=AND, 3=INV
//------------------------------------------------------------------ 17.02.07 --
procedure DispSymbol(Box: Word; Symbol: Byte);
var
  dmod, ns, bx, by, fx, fy, ly, tx, ty, px, py, wx, wy, win: Byte;
  lx: Word;
begin
  win := BoxSpec[Box, 1];    // actual window
  wx  := WinSpec[win, 1];    // start x-pos of window
  wy  := WinSpec[win, 2];    // start y-pos of window

  bx := BoxSpec[Box, 2];     // start x-pos of box
  by := BoxSpec[Box, 3];     // start y-pos of box
  px := BoxSpec[Box, 7];     // x-pos of symbol in the box
  py := BoxSpec[Box, 8];     // y-pos of symbol in the box

  dmod := BoxSpec[Box, 9] mod 10; // drawing mode

  // show inverse boxes for debugging
  if DebugFlag = cON then begin
    ClearBox(Box);
    if dmod = LCDDOTON then begin
      dmod := LCDDOTNEG;
    end else begin
      dmod := LCDDOTON;
    end;
  end;

  if dmod > LCDDOTNEG then begin
    dmod := LCDDOTON;                // unsupported dot mode
  end;

  lx := SymbDef[0, 1] * LCDBYTE;     // symbol file length
  ly := SymbDef[0, 2];               // symbol file height
  ns := SymbDef[0, 3];               // max number of symbols

  if Symbol > ns then begin
    GraBuff := IntToStr(Symbol) + ' in box ' + IntToStr(Box);
    LogError('DispSymbol', 'Unsupported symbol', GraBuff , $91);
    Exit;
  end;

  tx := SymbDef[Symbol, 1];  // symbol x-pos in table
  ty := SymbDef[Symbol, 2];  // symbol y-pos in table
  fx := SymbDef[Symbol, 3];  // symbol x-dim
  fy := SymbDef[Symbol, 4];  // symbol y-dim

  GraphicCopy(BITMAP00, LCDXRANGE, LCDYRANGE, wx + bx + px, wy + by + py, lx, ly, tx, ty, fx, fy, dmod);
end;

//------------------------------------------------------------------------------
// DISPBITMAP - Display user defined bitmap in a box
//   dmod - 0=COPY, 1=OR, 2=AND, 3=INV
//------------------------------------------------------------------ 17.02.07 --
procedure DispBitmap(Box, Xof, Yof: Word);
var
  dmod, bx, by, dx, dy,ly, md, wx, wy, win: Byte;
  lx: Word;
begin
  win := BoxSpec[Box, 1];             // actual window
  wx  := WinSpec[win, 1];             // start x-pos of window
  wy  := WinSpec[win, 2];             // start y-pos of window

  bx   := BoxSpec[Box, 2];            // start x pos of box
  by   := BoxSpec[Box, 3];            // start y pos of box
  dx   := BoxSpec[Box, 4];            // x-dim of box
  dy   := BoxSpec[Box, 5];            // y-dim of box
  md   := BoxSpec[Box, 6];            // number of bitmap
  lx   := BoxSpec[Box, 7] * LCDBYTE;  // bitmap file length
  ly   := BoxSpec[Box, 8];            // bitmap file height
  dmod := BoxSpec[Box, 9] mod 10;     // drawing mode

  if dmod > LCDDOTNEG then begin
    dmod := LCDDOTON;                 // unsupported dot mode
  end;

  // show inverse boxes for debugging
  if DebugFlag = cON then begin
    ClearBox(Box);
    if dmod = LCDDOTON then begin
      dmod := LCDDOTNEG;
    end else begin
      dmod := LCDDOTON;
    end;
  end;

  case md of // select bitmap
    1: GraphicCopy(BITMAP01, LCDXRANGE, LCDYRANGE, wx + bx,wy + by, lx, ly, Xof, Yof, dx, dy, dmod);
    2: GraphicCopy(BITMAP02, LCDXRANGE, LCDYRANGE, wx + bx,wy + by, lx, ly, Xof, Yof, dx, dy, dmod);
    3: GraphicCopy(BITMAP03, LCDXRANGE, LCDYRANGE, wx + bx,wy + by, lx, ly, Xof, Yof, dx, dy, dmod);
  else
    GraBuff := IntToStr(md) + ' in box ' + IntToStr(Box);
    LogError('DispBitmap', 'Unsupported bitmap', GraBuff, $91);
  end;
end;

//------------------------------------------------------------------------------
// DISPWINDOW - Show a window on the display screen
//   ps=partial start value (%) - for partial window opening
//   pe=partial end value (%)     from ps% to pe%
//------------------------------------------------------------------ 17.02.07 --
procedure DispWindow(Win, Ps, Pe: Byte);
var
  dx, dy, hx, hy, wt, wx, wy, se, sx, sy, ex, ey: Long;
begin
  wx := WinSpec[Win, 1];  // start x-pos of window
  wy := WinSpec[Win, 2];  // start y-pos of window
  dx := WinSpec[Win, 3];  // x-dim of window
  dy := WinSpec[Win, 4];  // y-dim of window
  se := WinSpec[Win, 5];  // special drawing effect
  wt := WinSpec[Win, 6];  // window type

  hy := dy;
  sx := cCLEAR;
  sy := cCLEAR;
  ex := dx;
  ey := dy;

  if dx mod LCDBYTE = 0 then begin
    hx := dx;
  end else begin
    hx := (dx div LCDBYTE + 1) * LCDBYTE;
  end;

  if se = 1 then begin        // select special effect
    sy := dy * Ps div cFULL;  // open partial window top-down
    ey := dy * Pe div cFULL - sy;
  end;

  case wt of
    1: GraphicCopy(WINDOW01, LCDXRANGE, LCDYRANGE, wx + sx, wy + sy, hx, hy, sx, sy, ex, ey, LCDDOTON);
    2: GraphicCopy(WINDOW02, LCDXRANGE, LCDYRANGE, wx + sx, wy + sy, hx, hy, sx, sy, ex, ey, LCDDOTON);
    3: GraphicCopy(WINDOW03, LCDXRANGE, LCDYRANGE, wx + sx, wy + sy, hx, hy, sx, sy, ex, ey, LCDDOTON);
    4: GraphicCopy(WINDOW04, LCDXRANGE, LCDYRANGE, wx + sx, wy + sy, hx, hy, sx, sy, ex, ey, LCDDOTON);
    5: GraphicCopy(WINDOW05, LCDXRANGE, LCDYRANGE, wx + sx, wy + sy, hx, hy, sx, sy, ex, ey, LCDDOTON);
    6: GraphicCopy(WINDOW06, LCDXRANGE, LCDYRANGE, wx + sx, wy + sy, hx, hy, sx, sy, ex, ey, LCDDOTON);
    7: GraphicCopy(WINDOW07, LCDXRANGE, LCDYRANGE, wx + sx, wy + sy, hx, hy, sx, sy, ex, ey, LCDDOTON);
  else
    GraBuff := IntToStr(wt) + ' in window ' + IntToStr(Win);
    LogError('DispWindow', 'Unsupported window type', GraBuff, $91);
  end;
end;

//------------------------------------------------------------------------------
// DISPBARVALUE - Display value in percent as a bar or pointer line in a box
//   dmod - 0=DOTON, 3=DOTOFF
//   md   - 0=filled, 1=framed, 2=pointer line
//   tp   - 1=left-rigth, 2=bottom-up, 3=right-left, 4=top-down
//------------------------------------------------------------------ 17.02.07 --
procedure DispBarValue(Box: Word; Value: Long);
var
  x, y, dmod, md, tp, dx, dy, bx, by, sx, sy, px, py, wx, wy, dot, win: Byte;
  vx, vy, val: Integer;
begin
  win  := BoxSpec[Box, 1];  // actual window
  wx   := WinSpec[win, 1];
  wy   := WinSpec[win, 2];
  bx   := BoxSpec[Box, 2];
  by   := BoxSpec[Box, 3];
  dx   := BoxSpec[Box, 4];
  dy   := BoxSpec[Box, 5];
  md   := BoxSpec[Box, 7];
  tp   := BoxSpec[Box, 8];
  dmod := BoxSpec[Box, 9] mod 10;

  case dmod of
    0: dot := LCDDOTON;
    3: dot := LCDDOTOFF;
  else
       dot := LCDDOTON;
  end;

  val := Limit(Value + 1, 0, cFULL); // limit value between 0..100%
  
  case tp of
    1: begin                         // bar left-rigth
         val := val * dx;
         sx  := 0;
         sy  := 0;
         vx  := val div cFULL - 1;
         vy  := dy - 1;
         px  := Limit(vx, 0, cFULL);  // 09.05.07 nk add
         py  := 0;
       end;

    2: begin                         // bar bottom-up
         val := val * dy;
         sx  := 0;
         sy  := dy - val div cFULL;
         vx  := dx - 1;
         vy  := dy - 1;
         px  := 0;
         py  := Limit(sy, 0, cFULL);  //09.05.07 nk add
       end;

    3: begin                         // bar rigth-left
         val := val * dx;
         sx  := dx - val div cFULL;
         sy  := 0;
         vx  := dx - 1;
         vy  := dy - 1;
         px  := Limit(sx, 0, cFULL);  //09.05.07 nk add
         py  := 0;
       end;

    4: begin                         // bar top-down
         val := val * dy;
         sx  := 0;
         sy  := 0;
         vx  := dx - 1;
         vy  := val div cFULL - 1;
         px  := 0;
         py  := Limit(vy, 0, cFULL);  //09.05.07 nk add
       end;
    else
      GraBuff := IntToStr(tp) + ' in box ' + IntToStr(Box);
      LogError('DispBarValue', 'Unsupported bar type', GraBuff, $91);
      Exit;
  end;

  case md of
    0: begin                              // filled bar
         if (vx >= sx) and (vy >= sy) then begin
           for x := sx to vx do begin
             for y := sy to vy do begin
               SetDot(wx + bx + x, wy + by + y, dot, LCDPEN);  // fill box
             end;
           end;
         end;
       end;

    1: begin                              // framed bar
         if sx > vx then sx := vx;
         if sy > vy then sy := vy;

         for x := sx to vx do begin
           SetDot(wx + bx + x, wy + by + sy, dot, LCDPEN);   // draw top line
           SetDot(wx + bx + x, wy + by + vy, dot, LCDPEN);   // draw bottom line
         end;

         for y := sy to vy do begin
           SetDot(wx + bx + sx, wy + by + y, dot, LCDPEN);   // draw right line
           SetDot(wx + bx + vx, wy + by + y, dot, LCDPEN);   // draw left line
         end;
       end;

    2: begin                              // line pointer
         if (tp mod 2) = 0 then begin     // draw horizontal line
           for x := sx to vx do begin
             SetDot(wx + bx + x, wy + by + py, dot, LCDPEN);
           end;
         end else begin                   // draw vertical line
           for y := sy to vy do begin
             SetDot(wx + bx + px, wy + by + y, dot, LCDPEN);
           end;
         end;
       end;
  else
    GraBuff := IntToStr(md) + ' in box ' + IntToStr(Box);
    LogError('DispBarValue', 'Unsupported bar mode', GraBuff, $91);
  end;
end;

//------------------------------------------------------------------------------
// DRAWBOX - Draw user box with white, black or inverse dots
//   ftyp - 0=normal, 1=facettes, 2..5=shadows
//   dmod - 0=DOTON, 3=DOTOFF
//------------------------------------------------------------------ 17.02.07 --
procedure DrawBox(Box: Word);
var
  x, y, ftyp, dmod, dx, dy, bx, by, wx, wy, xe, ye, xs, ys, dot, win: Byte;
begin
  win  := BoxSpec[Box, 1];  // actual window
  wx   := WinSpec[win, 1];
  wy   := WinSpec[win, 2];
  bx   := BoxSpec[Box, 2];
  by   := BoxSpec[Box, 3];
  dx   := BoxSpec[Box, 4];
  dy   := BoxSpec[Box, 5];
  ftyp := BoxSpec[Box, 6];          // box frame type
  dmod := BoxSpec[Box, 9] mod 10;  // drawing mode

  if (dx < 2) or (dy < 2) then begin
    GraBuff := IntToStr(Box);
    LogError('DrawBox', 'Invalid parameter in box', GraBuff , $91);
    Exit;
  end;

  case dmod of
    0: dot := LCDDOTON;
    1: dot := LCDDOTOFF;
    2: dot := LCDDOTINV;
    3: dot := LCDDOTINV;
  else
       dot := LCDDOTON;
  end;

  case ftyp of
    1: begin
         xs := 1;       // round facettes
         ys := 1;
         xe := dx - 2;
         ye := dy - 2;
       end;
  else
       begin
         xs := cCLEAR;  // rectangular box
         ys := cCLEAR;
         xe := dx - 1;
         ye := dy - 1;
       end;
  end;

  for x := xs to xe do begin
    SetDot(wx + bx + x, wy + by, dot, LCDPEN);           // draw top line
    SetDot(wx + bx + x, wy + by + dy - 1, dot, LCDPEN);  // draw bottom line
    case ftyp of                      // shadows -ligth source
      2: SetDot(wx + bx + x + 1, wy + by - 1,  dot, LCDPEN); // bottom - left
      3: SetDot(wx + bx + x + 1, wy + by + dy, dot, LCDPEN); // top - left
      4: SetDot(wx + bx + x - 1, wy + by - 1,  dot, LCDPEN); // top - right
      5: SetDot(wx + bx + x - 1, wy + by + dy, dot, LCDPEN); // bottom right
    end;
  end;

  for y := ys to ye do begin
    SetDot(wx + bx, wy + by + y, dot, LCDPEN);           // draw right line
    SetDot(wx + bx + dx - 1, wy + by + y, dot, LCDPEN);  // draw left line
    case ftyp of                      // shadows -ligth source
      2: SetDot(wx + bx + dx, wy + by + y - 1, dot, LCDPEN); // bottom - left
      3: SetDot(wx + bx + dx, wy + by + y + 1, dot, LCDPEN); // top - left
      4: SetDot(wx + bx - 1,  wy + by + y - 1, dot, LCDPEN); // top - right
      5: SetDot(wx + bx - 1,  wy + by + y + 1, dot, LCDPEN); // bottom right
    end;
  end;
end;

//------------------------------------------------------------------------------
// DRAWLINE - Draw horizontal or vertical full or dottet line
//   don - number of black dots (for dotted lines)
//   dof - number of white dots (spaces)
//------------------------------------------------------------------ 17.02.07 --
procedure DrawLine(Box: Word);
var
  d, x, y, don, dof, dx, dy, bx, by, wx, wy, dot, win: Byte;
begin
  win := BoxSpec[Box, 1];           // actual window
  wx  := WinSpec[win, 1];
  wy  := WinSpec[win, 2];
  bx  := BoxSpec[Box, 2];
  by  := BoxSpec[Box, 3];
  dx  := BoxSpec[Box, 4];
  dy  := BoxSpec[Box, 5];
  don := BoxSpec[Box, 8];           // number of black dots
  dof := BoxSpec[Box, 9];           // number of white dots

  d   := don + 1;
  dot := LCDDOTON;

  // 09.05.07 nk opt ff

  if (dy = 0) and (dx > 0) then begin
    for x := 0 to dx - 1 do begin
      if (don > 0) and (dof > 0) then begin  // draw dotted line
        if dot = LCDDOTON then begin
          d := d - 1;
          if d = 0 then begin
            dot := LCDDOTOFF;
            d   := dof + 1;
          end;
        end;

        if dot = LCDDOTOFF then begin
          d := d - 1;
          if d = 0 then begin
            dot := LCDDOTON;
            d   := don;
          end;
        end;
      end;

      SetDot(wx + bx + x, wy + by, dot, LCDPEN); // draw horizontal line
    end;
  end;

  if (dx = 0) and (dy > 0) then begin
    for y := 0 to dy - 1 do begin
      if (don > 0) and (dof > 0) then begin  // draw dotted line
        if dot = LCDDOTON then begin
          d := d - 1;
          if d = 0 then begin
            dot := LCDDOTOFF;
            d   := dof + 1;
          end;
        end;

        if dot = LCDDOTOFF then begin
          d := d - 1;
          if d = 0 then begin
            dot := LCDDOTON;
            d   := don;
          end;
        end;
      end;
      
      SetDot(wx + bx, wy + by + y, dot, LCDPEN); // draw vertical line
    end;
  end;
end;

//------------------------------------------------------------------------------
// DRAWLINEFROM - Start drawing a new (poly) line at start point Px/Py (rel 0/0)
//   Mode - 0=COPY, 2=OR, 3=AND, 3=INV (XOR)
//------------------------------------------------------------------ 17.02.07 --
procedure DrawLineFrom(Px, Py, Mode: Byte);
var
  col: TColor;
begin
  if Mode = 0 then
    col := clBlack
  else
    col := clWhite;

  with LcdBuffer.Canvas do begin
    Pen.Width := 1;
    Pen.Mode  := pmCopy;
    Pen.Style := psSolid;
    Pen.Color := col;
    LcdPenX   := Px;
    LcdPenY   := Py;
    MoveTo(LcdPenX, LcdPenY); // set pen position to start point
  end;
end;

//------------------------------------------------------------------------------
// DRAWLINETO - Draw (poly) line to point Px/Py (rel to pen position)
//------------------------------------------------------------------ 17.02.07 --
procedure DrawLineTo(Px, Py, Dx, Dy: Byte);
begin
  Px := Limit(Px, 0, Dx);  // limit drawing boundries
  Py := Limit(Py, 0, Dy);

  LcdBuffer.Canvas.LineTo(LcdPenX + Px, LcdPenY + Py);
end;

//------------------------------------------------------------------------------
// DRAWDOT - Draw a single dot (graphic pixel) at point Px/Py
//   Mode - 0=ON, 1=OFF, 2=INV
//------------------------------------------------------------------ 17.02.07 --
procedure DrawDot(Px, Py, Mode: Byte);
begin
  SetDot(Px, Py, Mode, LCDPEN);
end;

//------------------------------------------------------------------------------
// GETFONT - Get font table position, dimension and accent code for characters
//------------------------------------------------------------------------------
// Input:    Font: 1=tiny character font 3x5 dots
//                 2=small character font 5x5 dots
//                 3=bold character font 5x5 dots
//                 4=big character font 7x7 dots
//           Anum: ASCII character number of Windows West code table
// Output:   Fpos: 0=A, 1=B .. 25=Z, >25=special character
//                 >=ROW2CHAR=small characters, numbers, or unit symbols
//                 defined in 2nd row of the font bitmap table
//           Fdim: character x-dimension [dots] (w/o space)
//           Fcor: accent code for character layout correction
//                 0=none
//                 1=acute      ´ (ÁÉÍÓÚ)
//                 2=grave      ` (ÀÈÌÒÙ)
//                 3=circumflex ^ (ÂÊÎÔÛ)
//                 4=umlaut     ¨ (ÄëïÖÜ)
//                 5=tilde      ~ (ÃÑÕ)
//                 6=cedil      , (Ç)
//------------------------------------------------------------------ 17.02.07 --
procedure GetFont(Font, Anum: Byte; var Fpos, Fdim, Fcor: Byte);
begin
  Fcor := cOFF;

  if Anum = SYMBCODE then begin      // start of symbol definition
    Fpos := 0;                       // next Anum is a symbol (1..9)
    Fdim := 0;                       // "~2" -> symbol number 2
    Exit;                            // ignore this control sign
  end;

  if (Anum >= ASCII) and (Anum < ASCII + CHARS) then begin // capital characters (A..Z)
    Fpos := Anum - ASCII;                                  // number of character (A=0)
    Fdim := CharDim[Font, (Fpos + 1)];                     // x-dim of character
    Exit;
  end;

  if (Anum >= SMALL) and (Anum < SMALL + CHARS) then begin // small characters (a..z)
    Fpos := ROW2CHAR + Anum - SMALL;                       // defined in the 2nd row of
    Fdim := CharDim[Font, 0];                              // bitmap font file
    Exit;
  end;

  if (Anum >= NAL) and (Anum < NAL + NUMBS) then begin // numbers (0..9)
    Fpos := ROW2CHAR + Anum - NAL + CHARS;             // defined in the 2nd row of
    Fdim := CharDim[Font, 0];                          // bitmap font file
    Exit;
  end;

  case Anum of // special characters
     32: Fpos := 26;         // space
     40: Fpos := 27;         // (
     41: Fpos := 28;         // )
     37: Fpos := 29;         // %
     44: Fpos := 30;         // ,
     46: Fpos := 30;         // .
     58: Fpos := 31;         // :
     59: Fpos := 31;         // ;
     45: Fpos := 32;         // - (minus)
     43: Fpos := 33;         // +
    176: Fpos := 34;         // °
     39: Fpos := 35;         // '
     33: Fpos := 36;         // !
     63: Fpos := 37;         // ?
     47: Fpos := 38;         // /
     92: Fpos := 39;         // \   ISO date delimiter (-)
    124: Fpos := 40;         // |   US date delimiter (/)
    123: Fpos := 41;         // {   (left arrow)
    125: Fpos := 42;         // }   (right arrow)
    127: Fpos := 43;         // Ft  (symbol ~1)   unit symbols = SYMBCODE + symbol number
    128: Fpos := 44;         // lb  (symbol ~2)
    129: Fpos := 45;         // in  (symbol ~3)
    130: Fpos := 46;         // on  (symbol ~4)
    131: Fpos := 47;         // off (symbol ~5)

    192: begin
           Fpos := 0;        // À                extended characters
           Fcor := 2;
         end;
    193: begin
           Fpos := 0;        // Á
           Fcor := 1;
         end;
    194: begin
           Fpos := 0;        // Â
           Fcor := 3;
         end;
    195: begin
           Fpos := 0;        // Ã
           Fcor := 3;
         end;
    196: begin
           Fpos := 0;        // Ä
           Fcor := 4;
         end;
    199: begin
           Fpos := 2;        // ç
           Fcor := 6;
         end;
    200: begin
           Fpos := 4;        // È
           Fcor := 2;
         end;
    201: begin
           Fpos := 4;        // É
           Fcor := 1;
         end;
    202: begin
           Fpos := 4;        // Ê
           Fcor := 3;
         end;
    203: begin
           Fpos := 4;        // ë
           Fcor := 4;
         end;
    204: begin
           Fpos := 8;        // Ì
           Fcor := 2;
         end;
    205: begin
           Fpos := 8;        // Í
           Fcor := 1;
         end;
    206: begin
           Fpos := 8;        // Î
           Fcor := 3;
         end;
    207: begin
           Fpos := 8;        // ï
           Fcor := 4;
         end;
    209: begin
           Fpos := 13;       // Ñ
           Fcor := 3;
         end;
    210: begin
           Fpos := 14;       // Ò
           Fcor := 2;
         end;
    211: begin
           Fpos := 14;       // Ó
           Fcor := 1;
         end;
    212: begin
           Fpos := 14;       // Ô
           Fcor := 3;
         end;
    213: begin
           Fpos := 14;       // Õ
           Fcor := 3;
         end;
    214: begin
           Fpos := 14;       // Ö
           Fcor := 4;
         end;
    217: begin
           Fpos := 20;       // Ù
           Fcor := 2;
         end;
    218: begin
           Fpos := 20;       // Ú
           Fcor := 1;
         end;
    219: begin
           Fpos := 20;       // Û
           Fcor := 5;
         end;
    220: begin
           Fpos := 20;       // Ü
           Fcor := 4;
         end;
  else
         begin
           Fpos := 37;       // ?
           Fcor := 0;
           GraBuff := IntToStr(Anum) + ' = ' + Chr(Anum);
           LogError('GetFont', 'Invalid character', GraBuff, $93);
         end;
  end;

  Fdim := CharDim[Font, (Fpos + 1)] // x-dim of characters

end;

// ------------------------------------------------------------------------------
// GETBEARSYMBOL - Return code of direction symbol for the given bearing [ddeg]
// ------------------------------------------------------------------ 17.02.07 --
procedure GetBearSymbol(BearDir: Long; var BearCode: Byte);
begin
  if BearDir <= 100 then begin
    BearCode := BEARSYMBOL + 3;
    Exit;
  end;

  if BearDir <= 600 then begin
    BearCode := BEARSYMBOL + 4;
    Exit;
  end;

  if BearDir <= 1500 then begin
    BearCode := BEARSYMBOL + 5;
    Exit;
  end;

  if BearDir <= 2100 then begin
    BearCode := BEARSYMBOL + 0;
    Exit;
  end;

  if BearDir <= 3000 then begin
    BearCode := BEARSYMBOL + 1;
    Exit;
  end;

  if BearDir <= 3500 then begin
    BearCode := BEARSYMBOL + 2;
    Exit;
  end;

  if BearDir <= 3600 then begin
    BearCode := BEARSYMBOL + 3;
    Exit;
  end;

  BearCode := BEARSYMBOL;
  GraBuff  := IntToStr(BearDir);
  LogError('GetBearSymbol', 'No valid symbol code for bearing', GraBuff, $90);
end;


end.

