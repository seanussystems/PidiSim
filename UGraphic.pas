// Global Graphic Functions
// Date 01.02.17
// Norbert Koechli
// Copyright ©2006-2017 seanus systems

// 03.01.09 nk add support for png file format (Portable Network Graphics)
// 21.12.09 nk opt expand image color from Integer to Int64 (32bit > MaxInt)
// 10.11.10 nk add fmShareDenyNone in read-only file mode
// 12.11.10 nk upd to Delphi XE (2011) Unicode (most parts remain ANSI)
// 12.12.10 nk add ThumbnailBitmap makes a thumbnail preview with given size
// 08.12.11 nk add GetBitmapSize and IsBitmapTiled
// 14.01.12 nk add GetContrastColor to define the best contrasted (readable) color
// 17.01.12 nk add ResizeBitmap to rescale a given bitmap to a new size
// 29.07.12 nk add support for .gif and .png image file formats / include GifImg and PngImage
// 29.07.12 nk add LoadGraphicFile to load different graphic files as bitmap
// 26.05.14 nk upd to Delphi XE3 (VER240 Version 24)
// 25.05.16 nk add GetHeatColor for improved coloring modes for heatmaps
// 01.02.17 nk add CropBitmap and CropBitmaps to cut out desired rectangle from bitmap

unit UGraphic;

interface

uses //XE3//26.05.14 nk add System.UITypes
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, Graphics, GraphUtil,
  Math, Jpeg, GifImg, PngImage, TypInfo, Variants, ExtDlgs, ShellApi, UITypes,
  UGlobal, USystem;

const
  RGB_BIT        = 8;
  RGB_HALF       = 127;
  RGB_FULL       = 255;
  RGB_GAMMA      = 0.80;
  MODE_CONTRAST  = -6;   //V5//25.05.16 nk add
  MODE_LAVA      = -15;  //V5//25.05.16 nk add
  MODE_AQUA      = -16;  //V5//23.06.16 nk add
  MODE_BIPOLAR   = -21;  //V5//25.05.16 nk add
  JPG_BIT        = 24;
  JPG_RES        = 16777216;
  GIF_BIT        = 8;
  GIF_RES        = 256;
  GIF_HEADER     = 'GIF';
  GIF_VER87      = 'GIF87A';
  GIF_VER89      = 'GIF89A';
  JPG_PARAM      = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
  JPG_VALID:  array[0..1] of Byte = ($FF, $D8);
  PNG_VALID:  array[0..7] of Byte = (137, 80, 78, 71, 13, 10, 26, 10);          //03.01.09 nk add
  TILE_SIZES: array[0..8] of Word = (8, 16, 32, 64, 128, 256, 512, 1024, 2048); //08.12.11 nk add

  //03.01.09 nk add ff - avaliable color modes for PNG
  PNG_GRAYSCALE      = 0;
  PNG_RGB            = 2;
  PNG_PALETTE        = 3;
  PNG_GRAYSCALEALPHA = 4;
  PNG_RGBALPHA       = 6;

type
  TColArray = array[0..2] of Byte;
  TPngSig   = array[0..7] of Byte; //03.01.09 nk add

  TImageSize = record  //03.08.08 nk add
    Width:  Integer;
    Height: Integer;
    Colors: Int64;     //21.12.09 nk old=Integer - may result in RangeCheckError
    Bits:   Integer;   //03.01.09 nk add         //if 32bit color=2^32 > MaxInt!
  end;

  TGifHead = record  //12.11.10 nk old=TGifHeader (conflict with UGif) / 03.08.08 nk add
    Signature: array [0..5] of AnsiChar; //xe//
    Width, Height: Word;
  end;

  TMotorolaWord = record  //03.08.08 nk add
    case Byte of
      0: (Value: Word);
      1: (Byte1, Byte2: Byte);
  end;

  TRGB24 = packed record //12.12.10 nk add ff
    B: Byte;
    G: Byte;
    R: Byte;
  end;
  PRGB24 = ^TRGB24;

  procedure SetContrast(Image: TBitmap; Value: Integer);
  procedure SetLightness(Image: TBitmap; Value: Integer);
  procedure Sharpen(sbm, tbm: TBitmap; alpha: Single);  //nk//not tested!
  procedure SetTint(Image: TBitmap; White, Black: Byte);
  procedure SetColor(Image: TBitmap; Red, Green, Blue: Byte);
  procedure SetGradient(Canvas: TCanvas; Hdir: Boolean; Colors: array of TColor);
  procedure FlipHorizontal(Source, Target: TBitmap);
  procedure FlipVertical(Source, Target: TBitmap);
  procedure CopyBitmap(Source, Target: TBitmap);                          //17.12.09 nk add
  procedure ResizeBitmap(var Image: TBitmap; Dx, Dy: Integer);            //17.01.12 nk add
  procedure CropBitmap(Bitmap: TBitmap; X, Y, W, H: Integer);               //01.02.17 nk add
  procedure CropBitmaps(InBitmap, OutBitmap: TBitmap; X, Y, W, H: Integer); //01.02.17 nk add
  procedure TransparentBitmap(Source, Target: TBitmap; Color: TColor);    //31.12.07 nk add
  procedure AntialiasBitmap(Bitmap: TBitmap; Percent: Integer);           //31.01.10 nk add
  procedure ThumbnailBitmap(Source, Target: TBitmap; SizeX, SizeY: Word); //12.12.10 nk add
  function InvertBitmap(Bitmap: TBitmap): TBitmap;
  function ChangeColor(Bitmap: TBitmap; ColOld, ColNew: TColor): TBitmap; //14.04.10 nk add
  function IsPngFormat(PngFile: string): Boolean;                         //19.10.09 nk add
  function IsGifFormat(GifFile: string): Boolean;                         //20.11.10 nk add
  function IsBitmapTiled(BitmapFile: string): Boolean;                    //08.12.11 nk add
  function GetInvWord(Stream: TFileStream): Word;                         //03.08.08 nk add
  function GetBitmapFormat(Bitmap: TBitmap): Integer;
  function GetWaveColor(Wave: Word): TColor;                              //05.08.09 nk add
  function GetGradientColor(GradPos, GradMax: Integer; MinColor, MaxColor: TColor): TColor; //12.04.11 nk add
  function GetHeatColor(GradPos, GradMax, Mode: Integer): TColor;         //V5//25.05.16 nk add
  function GetInverseColor(Color: TColor): TColor;                        //03.02.10 nk add
  function GetContrastColor(Color: TColor): TColor;                       //14.01.12 nk add
  function GetBrighterColor(Color: TColor; Percent: Byte): TColor;
  function GetDarkerColor(Color: TColor; Percent: Byte): TColor;
  function GetMixedColor(Color1, Color2: TColor; Blend: Real): TColor;    //31.01.10 nk add
  function GetBitmapSize(BitmapFile: string): TImageSize;                 //07.12.11 nk add
  function GetBmpSize(BmpFile: string): TImageSize;                       //03.08.08 nk add ff
  function GetGifSize(GifFile: string): TImageSize;
  function GetJpgSize(JpgFile: string): TImageSize;
  function GetPngSize(PngFile: string): TImageSize;                       //03.01.09 nk add ff
  function GetPngColors(ColorType, BitDepth: Byte): Integer;
  function GetRgbColors(Color: TColor; var R, G, B: Byte): Integer;       //12.12.08 nk add
  function LoadGraphicFile(const FileName: string): TBitmap;              //29.07.12 nk add

implementation

procedure SetGradient(Canvas: TCanvas; Hdir: Boolean; Colors: array of TColor);
var
  x, y, z: Integer;
  wid, cnum, dim: Integer;
  pos, pto, sto: Integer;
  mult: Double;
  rect: TRect;
  col: TColor;
  pen: TPenStyle;
  a: TColArray;
  b: array of TColArray;
begin
  rect := Canvas.ClipRect;
  cnum := High(Colors);

  if cnum > 0 then begin
    if Hdir then  //horizontal
      dim := rect.Right - rect.Left
    else          //vertical
      dim := rect.Bottom - rect.Top;

    SetLength(b, cnum + 1);

    for x := 0 to cnum do begin
      Colors[x] := ColorToRGB(Colors[x]); 
      b[x][0]   := GetRvalue(Colors[x]);
      b[x][1]   := GetGvalue(Colors[x]);
      b[x][2]   := GetBvalue(Colors[x]);
    end;

    wid := Canvas.Pen.Width;
    pen := Canvas.Pen.Style;
    col := Canvas.Pen.Color;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psSolid;
    sto := Round(dim / cnum);

    for y := 0 to cnum - 1 do begin
      if y = cnum - 1 then
        pto := dim - y * sto - 1
      else
        pto := sto; 

      for x := 0 to pto do begin
        pos := x + y * sto;
        mult := x / pto;

        for z := 0 to 2 do
          a[z] := Trunc(b[y][z] + ((b[y + 1][z] - b[y][z]) * mult));

        Canvas.Pen.Color := RGB(a[0], a[1], a[2]);

        if Hdir then begin //horizontal
          Canvas.MoveTo(rect.Left + pos, rect.Top);
          Canvas.LineTo(rect.Left + pos, rect.Bottom);
        end else begin     //vertical
          Canvas.MoveTo(rect.Left, rect.Top + pos);
          Canvas.LineTo(rect.Right, rect.Top + pos);
        end;
      end; 
    end;

    b := nil;
    Canvas.Pen.Width := wid;
    Canvas.Pen.Style := pen;
    Canvas.Pen.Color := col;
  end;
end;

procedure SetContrast(Image: TBitmap; Value: Integer);
var
  p: PByteArray;
  r, g, b, x, y: Integer;
  rg, gg, bg: Integer;
begin
  for y := 0 to Image.Height - 1 do begin
    p := Image.ScanLine[y];
    for x := 0 to Image.Width - 1 do begin
      r  := p[x * 3];
      g  := p[x * 3 + 1];
      b  := p[x * 3 + 2];
      rg := (Abs(RGB_HALF - r) * Value) div RGB_FULL;
      gg := (Abs(RGB_HALF - g) * Value) div RGB_FULL;
      bg := (Abs(RGB_HALF - b) * Value) div RGB_FULL;
      if r > RGB_HALF then r := r + rg else r := r - rg;
      if g > RGB_HALF then g := g + gg else g := g - gg;
      if b > RGB_HALF then b := b + bg else b := b - bg;
      p[x * 3 ]    := IntToByte(r);
      p[x * 3 + 1] := IntToByte(g);
      p[x * 3 + 2] := IntToByte(b);
    end;
  end;
end;

procedure SetLightness(Image: TBitmap; Value: Integer);
var
  p: PByteArray;
  r, g, b, x, y: Integer;
begin
  for y := 0 to Image.Height - 1 do begin
    p := Image.ScanLine[y];
    for x := 0 to Image.Width - 1 do begin
      r := p[x * 3];
      g := p[x * 3 + 1];
      b := p[x * 3 + 2];
      p[x * 3]     := IntToByte(r + ((RGB_FULL - r) * Value) div RGB_FULL);
      p[x * 3 + 1] := IntToByte(g + ((RGB_FULL - g) * Value) div RGB_FULL);
      p[x * 3 + 2] := IntToByte(b + ((RGB_FULL - b) * Value) div RGB_FULL);
    end;
  end;
end;

procedure Sharpen(sbm, tbm: TBitmap; alpha: Single);
//to sharpen, alpha must be >1.
//pixelformat pf24bit
//sharpens sbm to tbm
var
  i, j, k: integer;
  sr: array[0..2] of PByte;
  st: array[0..4] of pRGBTriple;
  tr: PByte;
  tt, p: pRGBTriple;
  beta: Single;
  inta, intb: integer;
  bmh, bmw: integer;
  re, gr, bl: integer;
  BytesPerScanline: integer;

begin
  //sharpening is blending of the current pixel
  //with the average of the surrounding ones,
  //but with a negative weight for the average
  Assert((sbm.Width > 2) and (sbm.Height > 2), 'Bitmap must be at least 3x3');
  Assert((alpha > 1) and (alpha < 6), 'Alpha must be >1 and <6');
  beta := (alpha - 1) / 5; //we assume alpha>1 and beta<1
  intb := round(beta * $10000);
  inta := round(alpha * $10000); //integer scaled alpha and beta
  sbm.PixelFormat := pf24bit;
  tbm.PixelFormat := pf24bit;
  tbm.Width := sbm.Width;
  tbm.Height := sbm.Height;
  bmw := sbm.Width - 2;
  bmh := sbm.Height - 2;
  BytesPerScanline := (((bmw + 2) * 24 + 31) and not 31) div 8;

  tr := tbm.Scanline[0];
  tt := pRGBTriple(tr);

  sr[0] := sbm.Scanline[0];
  st[0] := pRGBTriple(sr[0]);
  for j := 0 to bmw + 1 do
  begin
    tt^ := st[0]^;
    inc(tt); inc(st[0]); //first row unchanged
  end;

  sr[1] := PByte(integer(sr[0]) - BytesPerScanline);
  sr[2] := PByte(integer(sr[1]) - BytesPerScanline);
  for i := 1 to bmh do
  begin
    Dec(tr, BytesPerScanline);
    tt := pRGBTriple(tr);
    st[0] := pRGBTriple(integer(sr[0]) + 3); //top
    st[1] := pRGBTriple(sr[1]); //left
    st[2] := pRGBTriple(integer(sr[1]) + 3); //center
    st[3] := pRGBTriple(integer(sr[1]) + 6); //right
    st[4] := pRGBTriple(integer(sr[2]) + 3); //bottom
    tt^ := st[1]^; //1st col unchanged
    for j := 1 to bmw do
    begin
    //calcutate average weighted by -beta
      re := 0; gr := 0; bl := 0;
      for k := 0 to 4 do
      begin
        re := re + st[k]^.rgbtRed;
        gr := gr + st[k]^.rgbtGreen;
        bl := bl + st[k]^.rgbtBlue;
        inc(st[k]);
      end;
      re := (intb * re + $7FFF) shr 16;
      gr := (intb * gr + $7FFF) shr 16;
      bl := (intb * bl + $7FFF) shr 16;

    //add center pixel weighted by alpha
      p := pRGBTriple(st[1]); //after inc, st[1] is at center
      re := (inta * p^.rgbtRed + $7FFF) shr 16 - re;
      gr := (inta * p^.rgbtGreen + $7FFF) shr 16 - gr;
      bl := (inta * p^.rgbtBlue + $7FFF) shr 16 - bl;

    //clamp and move into target pixel
      inc(tt);
      if re < 0 then
        re := 0
      else
        if re > 255 then
          re := 255;
      if gr < 0 then
        gr := 0
      else
        if gr > 255 then
          gr := 255;
      if bl < 0 then
        bl := 0
      else
        if bl > 255 then
          bl := 255;
      //this looks stupid, but avoids function calls

      tt^.rgbtRed := re;
      tt^.rgbtGreen := gr;
      tt^.rgbtBlue := bl;
    end;
    inc(tt);
    inc(st[1]);
    tt^ := st[1]^; //Last col unchanged
    sr[0] := sr[1];
    sr[1] := sr[2];
    Dec(sr[2], BytesPerScanline);
  end;
  // copy last row
  Dec(tr, BytesPerScanline);
  tt := pRGBTriple(tr);
  st[1] := pRGBTriple(sr[1]);
  for j := 0 to bmw + 1 do
  begin
    tt^ := st[1]^;
    inc(tt); inc(st[1]);
  end;
end;

procedure CropBitmap(Bitmap: TBitmap; X, Y, W, H: Integer);
begin //01.02.17 nk add
  BitBlt(Bitmap.Canvas.Handle, 0, 0, W, H, Bitmap.Canvas.Handle, X, Y, SRCCOPY);
  Bitmap.Width  := W;
  Bitmap.Height := H;
end;

procedure CropBitmaps(InBitmap, OutBitmap: TBitmap; X, Y, W, H: Integer);
begin //01.02.17 nk add
  OutBitmap.PixelFormat := InBitmap.PixelFormat;
  OutBitmap.Width  := W;
  OutBitmap.Height := H;
  BitBlt(OutBitmap.Canvas.Handle, 0, 0, W, H, InBitmap.Canvas.Handle, X, Y, SRCCOPY);
end;

procedure ResizeBitmap(var Image: TBitmap; Dx, Dy: Integer);
var //17.01.12 nk add - rescale Image to new width Dx and height Dy
  new: TRect;
  bmp: TBitmap;
begin
  try
    bmp := TBitmap.Create;
    try
      new := Rect(0, 0, Dx, Dy);
      bmp.Width  := Dx;
      bmp.Height := Dy;
      bmp.Canvas.StretchDraw(new, Image);
      Image.Assign(bmp);
    finally
      bmp.Free;
    end;
  except
    //ignore
  end;
end;

procedure TransparentBitmap(Source, Target: TBitmap; Color: TColor);
begin //change the transparent color of a bitmap //nk//NOT TESTED
  Source.Transparent      := True;
  Source.TransparentMode  := tmFixed;
  Source.TransparentColor := Color;
  Target.Canvas.Draw(0, 0, Source);
end;

procedure CopyBitmap(Source, Target: TBitmap);
begin //17.12.09 nk add - NOT yet tested!
  with Target do begin
    Width := Source.Width;
    Height:= Source.Height;
    StretchBlt(Canvas.Handle, 0, 0, Width, Height, Source.Canvas.Handle, 0, 0, Source.Width, Source.Height, SRCCOPY);
  end;
end;

procedure FlipHorizontal(Source, Target: TBitmap);
begin
  with Target do begin
    Width  := Source.Width;
    Height := Source.Height;
    StretchBlt(Canvas.Handle, 0, 0, Width, Height, Source.Canvas.Handle,
               Source.Width,  0, -Source.Width, Source.Height, SRCCOPY);
  end;
end;

procedure FlipVertical(Source, Target: TBitmap);
begin
  with Target do begin
    Width  := Source.Width;
    Height := Source.Height;
    StretchBlt(Canvas.Handle, 0, 0, Width, Height, Source.Canvas.Handle,
               0, Source.Height, Source.Width, -Source.Height, SRCCOPY);
  end;
end;

procedure SetTint(Image: TBitmap; White, Black: Byte);
var
  x, y: Integer;
  p: PByteArray;
begin
  Image.PixelFormat := pf24Bit;

  for y := 0 to Image.Height - 1 do begin
    p := Image.ScanLine[y];
    for x := 0 to Image.Width * 3 - 1 do begin
      if (p[x] = RGB_FULL) then p[x] := 12 * White div 10 + 135; // white dots 147..255
      if (p[x] = 0) then p[x] := 12 * (10 - Black div 10);       // black dots 0..108
    end;
  end;
end;

procedure SetColor(Image: TBitmap; Red, Green, Blue: Byte);
var
  r, g, b: Byte;
  x, y: Integer;
  col: TColor;
begin
  for y := 0 to Image.Height do begin
    for x := 0 to Image.Width do begin
      col := Image.Canvas.Pixels[x, y];
      r := GetRValue(col) + Red;
      g := GetGValue(col) + Green;
      b := GetBValue(col) + Blue;
      Image.Canvas.Pixels[x, y] := RGB(r, g, b);
    end;
  end;
end;

function IsPngFormat(PngFile: string): Boolean;
var //20.11.10 nk opt - return True if PngFile is a PNG image file
  x: Integer;
  ps: TPngSig;
  fs: TFileStream;
begin
  Result := False;

  if PngFile = cEMPTY then Exit;
  //20.11.10 nk mov down FillChar(ps, SizeOf(ps), cNUL);
  fs := TFileStream.Create(PngFile, fmOpenRead or fmShareDenyNone); //10.11.10 nk add fmShareDenyNone

  try
    FillChar(ps, SizeOf(ps), cNUL);
    fs.read(ps[0], SizeOf(ps));
    for x := Low(ps) to High(ps) do
      if ps[x] <> PNG_VALID[x] then Exit;
    Result := True;
  finally
    fs.Free;
  end;
end;

function IsGifFormat(GifFile: string): Boolean;
var //20.11.10 nk add - return True if GifFile is a GIF image file
  gh: TGifHead;
  fs: TFileStream;
begin
  Result := False;
  if GifFile = cEMPTY then Exit;

  fs := TFileStream.Create(GifFile, fmOpenRead or fmShareDenyNone);

  try
    FillChar(gh, SizeOf(TGifHead), cNULL);

    with fs do begin
      Seek(0, soFromBeginning);
      ReadBuffer(gh, SizeOf(TGifHead));
    end;

    Result := (Pos(GIF_HEADER, string(gh.Signature)) = 1);
  finally
    fs.Free;
  end;
end;

function InvertBitmap(Bitmap: TBitmap): TBitmap;
var //fast function to invert the colors of a bitmap
  x, y: Integer;
  p: PByteArray;
begin
  with Bitmap do begin
    PixelFormat := pf24Bit;
    for y := 0 to Height - 1 do begin
      p := ScanLine[y];
      for x := 0 to Width * 3 - 1 do p[x] := RGB_FULL - p[x];
    end;
  end;

  Result := Bitmap;
end;

function ChangeColor(Bitmap: TBitmap; ColOld, ColNew: TColor): TBitmap;
var //14.04.10 nk add
  x, y: Longint;
  bmp: TBitmap;
  col: TColor;
begin
  bmp := TBitmap.Create;

  with bmp do begin
    PixelFormat := pf24bit;
    Width       := Bitmap.Width;
    Height      := Bitmap.Height;
  end;

  for x := 0 to Bitmap.Width - 1 do begin
    for y := 0 to Bitmap.Height - 1 do begin
      col := Bitmap.Canvas.Pixels[x, y];
      if col = ColOld then //replace pixel color
        col := ColNew;
      bmp.Canvas.Pixels[x, y] := col;
    end;
  end;

  Result := bmp; //do NOT free bitmap here
end;

procedure AntialiasBitmap(Bitmap: TBitmap; Percent: Integer);
var //31.01.10 nk add (Source http://www.delphipraxis.net)
  r1, r2, g1, g2, b1, b2: Byte;
  l, p: Integer;
  r, g, b: Integer;
  area: TRect;
  pix, prevscan, nextscan, hpix: ^TColArray;
begin
  area := Rect(0, 0, Bitmap.Width, Bitmap.Height);
  Bitmap.PixelFormat := pf24bit;

  with Bitmap.Canvas do begin
    Brush.Style := bsClear;

    for l := area.Top to area.Bottom - 1 do begin
      pix := Bitmap.ScanLine[l];
      if l <> area.Top then
        prevscan := Bitmap.ScanLine[l - 1]
      else
        prevscan := nil;

      if l <> area.Bottom - 1 then
        nextscan := Bitmap.ScanLine[l + 1]
      else
        nextscan := nil;

      for p := area.Left to area.Right - 1 do begin
        r1 := pix^[2]; 
        g1 := pix^[1]; 
        b1 := pix^[0]; 

        if p <> area.Left then begin //pixel left
          hpix := pix; 
          Dec(hpix);
          r2 := hpix^[2]; 
          g2 := hpix^[1]; 
          b2 := hpix^[0]; 

          if (r1 <> r2) or (g1 <> g2) or (b1 <> b2) then begin
            r := r1 + (r2 - r1) * HALF div (Percent + HALF);
            g := g1 + (g2 - g1) * HALF div (Percent + HALF);
            b := b1 + (b2 - b1) * HALF div (Percent + HALF);
            hpix^[2] := r;
            hpix^[1] := g;
            hpix^[0] := b;
          end; 
        end; 

        if p <> area.Right - 1 then begin //pixel right
          hpix := pix; 
          Inc(hpix);
          r2 := hpix^[2]; 
          g2 := hpix^[1]; 
          b2 := hpix^[0]; 

          if (r1 <> r2) or (g1 <> g2) or (b1 <> b2) then begin
            r := r1 + (r2 - r1) * HALF div (Percent + HALF);
            g := g1 + (g2 - g1) * HALF div (Percent + HALF);
            b := b1 + (b2 - b1) * HALF div (Percent + HALF);
            hpix^[2] := r;
            hpix^[1] := g;
            hpix^[0] := b;
          end; 
        end; 

        if prevscan <> nil then begin //pixel up
          r2 := prevscan^[2]; 
          g2 := prevscan^[1]; 
          b2 := prevscan^[0]; 

          if (r1 <> r2) or (g1 <> g2) or (b1 <> b2) then begin
            r := r1 + (r2 - r1) * HALF div (Percent + HALF);
            g := g1 + (g2 - g1) * HALF div (Percent + HALF);
            b := b1 + (b2 - b1) * HALF div (Percent + HALF);
            prevscan^[2] := r;
            prevscan^[1] := g;
            prevscan^[0] := b;
          end;
          Inc(prevscan);
        end; 

        if nextscan <> nil then begin //pixel down
          r2 := nextscan^[2]; 
          g2 := nextscan^[1]; 
          b2 := nextscan^[0]; 

          if (r1 <> r2) or (g1 <> g2) or (b1 <> b2) then begin
            r := r1 + (r2 - r1) * HALF div (Percent + HALF);
            g := g1 + (g2 - g1) * HALF div (Percent + HALF);
            b := b1 + (b2 - b1) * HALF div (Percent + HALF);
            nextscan^[2] := r;
            nextscan^[1] := g;
            nextscan^[0] := b;
          end;
          Inc(nextscan);
        end;
        Inc(pix);
      end;
    end;
  end;
end;

procedure ThumbnailBitmap(Source, Target: TBitmap; SizeX, SizeY: Word);
var //V5//20.03.16 nk opt (Source http://www.swissdelphicenter.ch)
  r, g, b: Integer;
  h, w, x, y, ix, iy: Integer;
  x1, x2, x3, ny1, ny2, ny3: Integer;
  iSrc, iDst, s1: Integer;
  dx, dy: Integer;
  rb, rd, rs: Integer;
  iRed, iGrn, iBlu, iRatio: Longword;
  xscale, yscale: Single;
  c1, c2, c3, c4, c5: TRGB24;
  pt, pt1: PRGB24;
  lutX, lutY: array of Integer;
begin
  if Source.PixelFormat <> pf24bit then Source.PixelFormat := pf24bit;
  if Target.PixelFormat <> pf24bit then Target.PixelFormat := pf24bit;

  Target.Width  := SizeX;
  Target.Height := SizeY;
  w := SizeX;
  h := SizeY;

  if (Source.Width <= SizeX) and (Source.Height <= SizeY) then begin
    Target.Assign(Source);
    Exit;
  end;

  iDst := (w * 24 + 31) and not 31;
  iDst := iDst div RGB_BIT; //BytesPerScanline
  iSrc := (Source.Width * 24 + 31) and not 31;
  iSrc := iSrc div RGB_BIT;

  xscale := 1.0 / (w / Source.Width);
  yscale := 1.0 / (h / Source.Height);

  //create x lookup table
  SetLength(lutX, w);
  x1 := 0;
  x2 := Trunc(xscale);

  for x := 0 to w - 1 do begin
    lutX[x] := x2 - x1;
    x1 := x2;
    x2 := Trunc((x + 2) * xscale);
  end;

  //create y lookup table
  SetLength(lutY, h);
  x1 := 0;
  x2 := Trunc(yscale);

  for x := 0 to h - 1 do begin
    lutY[x] := x2 - x1;
    x1 := x2;
    x2 := Trunc((x + 2) * yscale);
  end;

  dec(w);
  dec(h);
  rd := Integer(Target.ScanLine[0]);
  rb := Integer(Source.ScanLine[0]);
  rs := rb;

  for y := 0 to h do begin
    dy := lutY[y];
    x1 := 0;
    x3 := 0;

    for x := 0 to w do begin
      dx   := lutX[x];
      iRed := 0;
      iGrn := 0;
      iBlu := 0;
      rs   := rb;

      for iy := 1 to dy do begin
        pt := PRGB24(rs + x1);
        for ix := 1 to dx do begin
          iRed := iRed + pt.R;
          iGrn := iGrn + pt.G;
          iBlu := iBlu + pt.B;
          Inc(pt);
        end;
        rs := rs - iSrc;
      end;

      iRatio := MAXWORD div (dx * dy);
      pt1    := PRGB24(rd + x3);
      pt1.R  := (iRed * iRatio) shr 16;
      pt1.G  := (iGrn * iRatio) shr 16;
      pt1.B  := (iBlu * iRatio) shr 16;
      x1     := x1 + 3 * dx;
      Inc(x3, 3);
    end;

    rd := rd - iDst;
    rb := rs;
  end;

  if Target.Height < 3 then Exit;

  //anti-alias...
  s1   := Integer(Target.ScanLine[0]);
  iDst := Integer(Target.ScanLine[1]) - s1;
  ny1  := Integer(s1);
  ny2  := ny1 + iDst;
  ny3  := ny2 + iDst;

  for y := 1 to Target.Height - 2 do begin
    for x := 0 to Target.Width - 3 do begin
      x1 := x * 3;
      x2 := x1 + 3;
      x3 := x1 + 6;

      c1 := PRGB24(ny1 + x1)^;
      c2 := PRGB24(ny1 + x3)^;
      c3 := PRGB24(ny2 + x2)^;
      c4 := PRGB24(ny3 + x1)^;
      c5 := PRGB24(ny3 + x3)^;

      r := (c1.R + c2.R + (c3.R * -12) + c4.R + c5.R) div -8;
      g := (c1.G + c2.G + (c3.G * -12) + c4.G + c5.G) div -8;
      b := (c1.B + c2.B + (c3.B * -12) + c4.B + c5.B) div -8;

      if r < 0 then r := 0 else if r > RGB_FULL then r := RGB_FULL;
      if g < 0 then g := 0 else if g > RGB_FULL then g := RGB_FULL;
      if b < 0 then b := 0 else if b > RGB_FULL then b := RGB_FULL;

      pt1   := PRGB24(ny2 + x2);
      pt1.R := r;
      pt1.G := g;
      pt1.B := b;
    end;

    Inc(ny1, iDst);
    Inc(ny2, iDst);
    Inc(ny3, iDst);
  end;
end;

function GetInvWord(Stream: TFileStream): Word;
var //invert Motorola to Intel byte order
  mw: TMotorolaWord;
begin
  Result := 0;
  if Stream = nil then Exit;

  Stream.Read(mw.Byte2, SizeOf(Byte));
  Stream.Read(mw.Byte1, SizeOf(Byte));
  Result := mw.Value;
end;

function GetBitmapFormat(Bitmap: TBitmap): Integer;
begin //get pixel format (color depth) [bit] of a bitmap
  case Bitmap.PixelFormat of
    pf1bit:  Result := 1;
    pf4bit:  Result := 4;
    pf8bit:  Result := 8;
    pf15bit: Result := 15;
    pf16bit: Result := 16;
    pf24bit: Result := 24;
    pf32bit: Result := 32;
  else
    Result := CLEAR;
  end;
end;

function GetBrighterColor(Color: TColor; Percent: Byte): TColor;
begin //Percent 0..100%
  if Color = clBlack then  //12.05.09 nk opt
    Result := clSilver
  else
    Result := ColorAdjustLuma(ColorToRGB(Color), Percent, False);
end;

function GetDarkerColor(Color: TColor; Percent: Byte): TColor;
begin //Percent 0..100%
  if Color = clWhite then  //12.05.09 nk opt
    Result := clSilver
  else
    Result := ColorAdjustLuma(ColorToRGB(Color), -Percent, False);
end;

function GetMixedColor(Color1, Color2: TColor; Blend: Real): TColor;
var //31.01.10 nk add Blend 0.0..1.0 (Source http://www.delphipraxis.net)
  r, g, b: Byte;  //nk//not yet tested !
  y1, y2: Byte;
begin 
  Color1 := ColorToRGB(Color1);
  Color2 := ColorToRGB(Color2);

  y1 := GetRValue(Color1);
  y2 := GetRValue(Color2);
  r  := Round(y1 + (y2 - y1) * Blend);

  y1 := GetGValue(Color1);
  y2 := GetGValue(Color2);
  g  := Round(y1 + (y2 - y1) * Blend);

  y1 := GetBValue(Color1);
  y2 := GetBValue(Color2);
  b  := Round(y1 + (y2 - y1) * Blend);

  Result := RGB(r, g, b);
end;

function IsBitmapTiled(BitmapFile: string): Boolean;
var //08.12.11 nk add - return True if Bitmap can be tiled
  i: Integer;        //to tile a bitmap, width and height must be equal
  bsize: TImageSize; //and must be a multiple of 8 (e.g. 512x512 pixels)
begin
  Result := False;
  bsize  := GetBitmapSize(BitmapFile);

  if bsize.Width = bsize.Height then begin
    for i := 0 to High(TILE_SIZES) do begin
      if bsize.Width = TILE_SIZES[i] then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function GetBitmapSize(BitmapFile: string): TImageSize;
var //07.12.11 nk add - return size of requested bitmap
  ext: string;
begin
  Result.Width  := NONE;
  Result.Height := NONE;
  Result.Colors := NONE;
  Result.Bits   := NONE;

  ext := LowerCase(ExtractFileExt(BitmapFile));

  if ext = BMP_END then begin
    Result := GetBmpSize(BitmapFile);
    Exit;
  end;

  if ext = GIF_END then begin
    Result := GetGifSize(BitmapFile);
    Exit;
  end;
  if ext = JPG_END then begin
    Result := GetJpgSize(BitmapFile);
    Exit;
  end;
  if ext = PNG_END then begin
    Result := GetPngSize(BitmapFile);
    Exit;
  end;
end;

function GetBmpSize(BmpFile: string): TImageSize;
var //10.11.10 nk opt
  fs: TFileStream;
  ih: TBitmapInfoHeader;
  fh: TBitmapFileHeader;
begin
  Result.Width  := NONE;
  Result.Height := NONE;
  Result.Colors := NONE;
  Result.Bits   := NONE;

  if BmpFile = cEMPTY then Exit;

  fs := TFileStream.Create(BmpFile, fmOpenRead or fmShareDenyNone); //10.11.10 nk add fmShareDenyNone

  try
    fs.Read(fh, SizeOf(fh));  //1st we have to read the file header
    fs.Read(ih, SizeOf(ih));  //else the info header is corrupted
    Result.Width  := ih.biWidth;
    Result.Height := ih.biHeight;
    Result.Bits   := ih.biBitCount;
    Result.Colors := Round(Power(2, ih.biBitCount));
  finally
    fs.Free;
  end;
end;

function GetGifSize(GifFile: string): TImageSize;
var //12.11.10 nk opt - returm width and height in [pixels] of GIF image file
  gh: TGifHead;
  fs: TFileStream;
begin
  Result.Width  := NONE;
  Result.Height := NONE;
  Result.Colors := GIF_RES;  //03.01.09 nk opt ff
  Result.Bits   := GIF_BIT;

  if GifFile = cEMPTY then Exit;

  fs := TFileStream.Create(GifFile, fmOpenRead or fmShareDenyNone); //10.11.10 nk add fmShareDenyNone

  try
    FillChar(gh, SizeOf(TGifHead), cNULL);

    with fs do begin
      Seek(0, soFromBeginning);
      ReadBuffer(gh, SizeOf(TGifHead));
    end;

    if Pos(GIF_HEADER, string(gh.Signature)) = 1 then begin //xe//
      Result.Width  := gh.Width;
      Result.Height := gh.Height;
    end;
  finally
    fs.Free;
  end;
end;

function GetJpgSize(JpgFile: string): TImageSize;
var //10.11.10 nk opt - returm width and height in [pixels] of JPG image file
  seg: Byte;
  len: Word;
  x: Integer;
  rlen: LongInt;
  sig: array[0..1] of Byte;
  dum: array[0..15] of Byte;
  fs: TFileStream;
begin
  Result.Width  := NONE;
  Result.Height := NONE;
  Result.Colors := JPG_RES;  //03.01.09 nk opt ff
  Result.Bits   := JPG_BIT;

  if JpgFile = cEMPTY then Exit;

  fs := TFileStream.Create(JpgFile, fmOpenRead or fmShareDenyNone); //10.11.10 nk add fmShareDenyNone

  try
    FillChar(sig, SizeOf(sig), cNULL);
    rlen := fs.Read(sig[0], SizeOf(sig));

    for x := Low(sig) to High(sig) do
      if sig[x] <> JPG_VALID[x] then rlen := 0;

    if rlen > 0 then begin
      rlen := fs.Read(seg, 1);
      while (seg = $FF) and (rlen > 0) do begin
        rlen := fs.Read(seg, 1);
        if seg <> $FF then begin
          if (seg = $C0) or (seg = $C1) then begin
            rlen := fs.Read(dum[0], 3);
            Result.Height := GetInvWord(fs);
            Result.Width  := GetInvWord(fs);
          end else begin
            if not (seg in JPG_PARAM) then begin
              len := GetInvWord(fs);
              fs.Seek(len - 2, 1);
              fs.Read(seg, 1);
            end else begin
              seg := $FF;
            end;
          end;
        end;
      end;
    end;
  finally
    fs.Free;
  end;
end;

function GetPngSize(PngFile: string): TImageSize;
var //10.11.10 nk opt - returm width and height in [pixels] of PNG image file
  x: Integer;
  ps: TPngSig;
  fs: TFileStream;
begin
  Result.Width  := NONE;
  Result.Height := NONE;
  Result.Colors := NONE;
  Result.Bits   := NONE;

  if PngFile = cEMPTY then Exit;

  FillChar(ps, SizeOf(ps), cNUL);

  fs := TFileStream.Create(PngFile, fmOpenRead or fmShareDenyNone); //10.11.10 nk add fmShareDenyNone

  try
    fs.read(ps[0], SizeOf(ps));
    for x := Low(ps) to High(ps) do
      if ps[x] <> PNG_VALID[x] then Exit;
    fs.Seek(18, 0);
    Result.Width := GetInvWord(fs);
    fs.Seek(22, 0);
    Result.Height := GetInvWord(fs);
  finally
    fs.Free;
  end;
end;

function GetPngColors(ColorType, BitDepth: Byte): Integer;
begin //get color depth [bit] from png header chunk
  Result := BitDepth;

  if BitDepth = 8 then begin
    if ColorType = PNG_GRAYSCALEALPHA then Result := 16;
    if ColorType = PNG_RGB            then Result := 24;
    if ColorType = PNG_RGBALPHA       then Result := 32;
  end;

  if BitDepth = 16 then begin
    if ColorType = PNG_GRAYSCALE      then Result := 16;
    if ColorType = PNG_GRAYSCALEALPHA then Result := 32;
    if ColorType = PNG_RGB            then Result := 48;
    if ColorType = PNG_RGBALPHA       then Result := 64;
  end;
end;

function GetRgbColors(Color: TColor; var R, G, B: Byte): Integer;
begin
  Result := ColorToRGB(Color);
  R := GetRvalue(Color);
  G := GetGvalue(Color);
  B := GetBvalue(Color);
end;

function GetInverseColor(Color: TColor): TColor;
var //03.02.10 nk add
  l: Longint;
  r, g, b: Byte;
begin  
  l := ColorToRGB(Color);
  r := RGB_FULL - Byte(l);
  g := RGB_FULL - Byte(l shr 8);
  b := RGB_FULL - Byte(l shr 16);

  Result := (b shl 16) + (g shl 8) + r;
end;

function GetContrastColor(Color: TColor): TColor;
//14.01.12 nk add - Return the best contrasted color to given Color
//Calculate the luminance of the color using the formula: luminance = 0.25*R + 0.625*G + 0.125*B
var
  R, G, B: Integer;
begin
  R := GetRValue(Color) * 2;
  G := GetGValue(Color) * 5;
  B := GetBValue(Color) * 1;

  if R + G + B < 1024 then
    Result := clWhite
  else
    Result := clBlack;
end;

function GetWaveColor(Wave: Word): TColor;
var //return color to the given wavelength from 380..780nm (violet..red)
  cr, cg, cb: Integer; //add SIM_RGB_WAVE to Wave to start at blue (instead of violet)
  r, g, b: Double;
  factor:  Double;

  function Adjust(Color, Factor: Double): Integer;
  begin //don't want 0^x = 1 for x <> 0
    if Color = 0.0 then
      Result := 0
    else
      Result := Round(RGB_FULL * Power(Color * Factor, RGB_GAMMA));
  end;

begin
  case Wave of
    380..439: begin
      r := -(Wave - 440) / (440 - 380);
      g := 0.0;
      b := 1.0;
    end;

    440..489: begin
      r := 0.0;
      g := (Wave - 440) / (490 - 440);
      b := 1.0;
    end;

    490..509: begin
      r := 0.0;
      g := 1.0;
      b := -(Wave - 510) / (510 - 490)
    end;

    510..579: begin
      r := (Wave - 510) / (580 - 510);
      g := 1.0;
      b := 0.0;
    end;

    580..644: begin
      r := 1.0;
      g := -(Wave - 645) / (645 - 580);
      b := 0.0;
    end;

    645..780: begin
      r := 1.0;
      g := 0.0;
      b := 0.0;
    end;
  else
    r := 0.0;
    g := 0.0;
    b := 0.0;
  end;

  //let the intensity fall off near the vision limits
  case Wave of
    380..419: factor := 0.3 + 0.7 * (Wave - 380) / (420 - 380);
    420..700: factor := 1.0;
    701..780: factor := 0.3 + 0.7 * (780 - Wave) / (780 - 700);
  else
    factor := 0.0;
  end;

  cr := Adjust(r, factor);
  cg := Adjust(g, factor);
  cb := Adjust(b, factor);

  Result := RGB(cr, cg, cb);
end;

function GetGradientColor(GradPos, GradMax: Integer; MinColor, MaxColor: TColor): TColor;
var //12.04.11 nk add - return color of the given position in the gradient (0 = MinColor...GradMax = TMaxColor)
  R, G, B: Byte;
  R1, R2: Byte;
  G1, G2: Byte;
  B1, B2: Byte;
  dr, dg, db: Extended;
begin
  R1 := GetRValue(MinColor);
  G1 := GetGValue(MinColor);
  B1 := GetBValue(MinColor);

  R2 := GetRValue(MaxColor);
  G2 := GetGValue(MaxColor);
  B2 := GetBValue(MaxColor);

  dr := (R2 - R1) / GradMax;
  dg := (G2 - G1) / GradMax;
  db := (B2 - B1) / GradMax;

  R := R1 + Ceil(dr * GradPos);
  G := G1 + Ceil(dg * GradPos);
  B := B1 + Ceil(db * GradPos);

  Result := RGB(R,G,B);
end;

function GetHeatColor(GradPos, GradMax, Mode: Integer): TColor;
var //V5//07.09.16 nk opt
  lim: Integer;
begin
  Result := clRed;

  if Mode = MODE_CONTRAST then begin //high contrast coloring
    lim := Round(GradMax / -MODE_CONTRAST);
    lim := Trunc(GradPos / lim);
    case lim of
      0: Result := clBlue;
      1: Result := clAqua;
      2: Result := clLime;
      3: Result := clYellow;
      4: Result := clFuchsia;
    end;
    Exit;
  end;

  if Mode = MODE_BIPOLAR then begin //red-blue bipolar coloring
    lim := Round(GradMax / -MODE_BIPOLAR);
    lim := Trunc(GradPos / lim);
    case lim of
       0: Result := RGB(  0,   0, 255); //clBlue
       1: Result := RGB( 35,  35, 255);
       2: Result := RGB( 50,  50, 255);
       3: Result := RGB( 75,  75, 255);
       4: Result := RGB(100, 100, 255);
       5: Result := RGB(125, 125, 255);
       6: Result := RGB(150, 150, 255);
       7: Result := RGB(175, 175, 255);
       8: Result := RGB(200, 200, 255);
       9: Result := RGB(225, 225, 255);
      10: Result := RGB(255, 255, 255); //clWhite
      11: Result := RGB(255, 225, 225);
      12: Result := RGB(255, 200, 200);
      13: Result := RGB(255, 175, 175);
      14: Result := RGB(255, 150, 150);
      15: Result := RGB(255, 125, 125);
      16: Result := RGB(255, 100, 100);
      17: Result := RGB(255,  80,  80);
      18: Result := RGB(255,  60,  60);
      19: Result := RGB(255,  45,  45);
      20: Result := RGB(255,   0,   0); //clRed
    end;
    Exit;
  end;

  if Mode = MODE_LAVA then begin //lava coloring
    lim := Round(GradMax / -MODE_LAVA);
    lim := Trunc(GradPos / lim);
    case lim of
       0: Result := RGB( 12,  12,  12);
       1: Result := RGB(  8,  28,  47);
       2: Result := RGB( 19,  46,  79);
       3: Result := RGB( 78,  43,  99);
       4: Result := RGB(152,  35, 114);
       5: Result := RGB(197,  32, 110);
       6: Result := RGB(227,  78,  85);
       7: Result := RGB(240, 115,  71);
       8: Result := RGB(245, 158,  62);
       9: Result := RGB(249, 200,  53);
      10: Result := RGB(252, 226,  47);
      11: Result := RGB(254, 246,  43);
      12: Result := RGB(255, 251,  86);
      13: Result := RGB(255, 253, 177);
      14: Result := RGB(255, 254, 251);
    end;
    Exit;
  end;

  if Mode = MODE_AQUA then begin //V5//23.06.16 nk add - aqua coloring
    lim := Round(GradMax / -MODE_AQUA);
    lim := Trunc(GradPos / lim);
    case lim of
       0: Result := RGB( 53,  42, 134);
       1: Result := RGB( 54,  54, 159);
       2: Result := RGB( 46,  70, 191);
       3: Result := RGB( 10,  93, 220);
       4: Result := RGB( 17, 121, 216);
       5: Result := RGB( 19, 138, 210);
       6: Result := RGB( 13, 147, 209);
       7: Result := RGB(  5, 164, 199);
       8: Result := RGB( 35, 180, 170);
       9: Result := RGB(125, 191, 123);
      10: Result := RGB(175, 189, 103);
      11: Result := RGB(225, 185,  82);
      12: Result := RGB(246, 218,  36);
      13: Result := RGB(245, 227,  29);
      14: Result := RGB(246, 239,  20);
      15: Result := RGB(246, 246,  16);
    end;
    Exit;
  end;

  lim := Round(GradMax * Mode / PROCENT); //threshold [0-100%] coloring

  if GradPos > lim then
    Result := clYellow
  else
    Result := clNavy;
end;

function LoadGraphicFile(const FileName: string): TBitmap;
var //07.08.12 nk opt - load a graphic file and return it as bitmap
  ext: string;
  icon: TIcon;
  JPGImage: TJpegImage;
  GIFImage: TGifImage;
  PNGImage: TPngImage;
  Metafile: TMetafile;
begin
  Result := TBitmap.Create;

  if FileExists(FileName) then begin
    ext := LowerCase(ExtractFileExt(FileName));

    if ext = BMP_END then begin
      Result.PixelFormat := pf24bit;     //avoid palette problems
      Result.LoadFromFile(FileName);
    end;

    if ext = ICO_END then begin
      icon := TIcon.Create;
      try
        try
          icon.LoadFromFile(FileName);
          Result.Height := icon.Height;
          Result.Width  := icon.Width;
          Result.PixelFormat := pf24bit; //avoid palette problems
          Result.Canvas.Draw(0, 0, icon);
        except
          //ignore problems e.g. stream read errors
        end;
      finally
        icon.Free;
      end;
    end;

    if ext = JPG_END then begin
      JPGImage := TJpegImage.Create;
      try
        JPGImage.LoadFromFile(FileName);
        Result.Height      := JPGImage.Height;
        Result.Width       := JPGImage.Width;
        Result.PixelFormat := pf24bit;   //avoid palette problems
        Result.Canvas.Draw(0, 0, JPGImage);
      finally
        JPGImage.Free;
      end;
    end;

    if ext = GIF_END then begin
      GIFImage := TGifImage.Create;
      try
        GIFImage.LoadFromFile(FileName);
        Result.Height      := GIFImage.Height;
        Result.Width       := GIFImage.Width;
        Result.PixelFormat := pf24bit;   //avoid palette problems
        Result.Canvas.Draw(0, 0, GIFImage);
      finally
        GIFImage.Free;
      end;
    end;

    if ext = PNG_END then begin
      PNGImage := TPngImage.Create;
      try
        PNGImage.LoadFromFile(FileName);
        Result.Height      := PNGImage.Height;
        Result.Width       := PNGImage.Width;
        Result.PixelFormat := pf24bit;   //avoid palette problems
        Result.Canvas.Draw(0, 0, PNGImage);
      finally
        PNGImage.Free;
      end;
    end;

    if ext = WMF_END then begin
      Metafile := TMetafile.Create;
      try
        Metafile.LoadFromFile(FileName);
        Result.Height      := Metafile.Height;
        Result.Width       := Metafile.Width;
        Result.PixelFormat := pf24bit;   //avoid palette problems
        Result.Canvas.Draw(0, 0, Metafile);
      finally
        Metafile.Free;
      end;
    end;
  end;
end;

end.
