// Flash Logging of Dive Parameter and Settings
// Date 28.05.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

// Delphi simulates Tiger flash memory as binary hex file

// Limits: Word = MAXWORD, Long = MAXLONG
//   65'536sec = 1092min = 18.2h expand from s to min if >= 16h (TIMELIMIT)
//   65'536min = 1092h = 45.5d
//   65'536 blocks = 2MB dive data memory
//   2'147'483'647s = 24'855d = 68y

unit Flash;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, DateUtils, SYS, Global, Data,
  Clock, Texts, FProfile, FTrack, FPlan, FLog, UPidi;

  procedure ClearDiveCatalog;
  procedure LoadDiveCatalog(var CatDives, LogDives: Word);
  procedure GetCatalogDive(var Dive: Word);
  procedure InitDiveLog;
  procedure LogDiveBlock;
  procedure CloseDiveLog;
  procedure ClearDiveData;
  procedure ClearDiveProfile;
  procedure LoadDiveData(var Dive: Word);
  procedure LoadDiveProfile(var Dive: Word);
  procedure GetNextDivePoint(var DivePoint: Word; GoAround: Byte);
  procedure GetPrevDivePoint(var DivePoint: Word; GoAround: Byte);
  procedure SaveSettings;
  procedure LoadSettings;

var
  LogBuff: string;

implementation

uses FMain;

//------------------------------------------------------------------------------
// CLEARDIVECATALOG - Clear the dive catalog array - set all values to 0
//------------------------------------------------------------------ 17.02.07 --
procedure ClearDiveCatalog;
var
  ldive, lpar: Byte;
begin
  for ldive := 0 to MAXCATDIVE - 1 do begin
    for lpar := 0 to MAXCATPARS - 1 do begin
      DiveCatalog[ldive, lpar] := cCLEAR;
    end;
  end;
end;

//------------------------------------------------------------------------------
// GETCATALOGDIVE - Get catalog dive number from log dive number
//------------------------------------------------------------------ 17.02.07 --
procedure GetCatalogDive(var Dive: Word);
var
  ldive: Word;
begin
  for ldive := 1 to MAXCATDIVE - 1 do begin
    if DiveCatalog[ldive, 5] = Dive then begin
      Dive := ldive;
      Exit;
    end;
  end;

  Dive := cCLEAR; // no dive number found
end;

//------------------------------------------------------------------------------
// LOADDIVECATALOG - Initialize a new dive catalog and load LOGSTART info of the
//   last MAXCATDIVE dives saved in the flash memory (DELPHI = file) and return
//   the number of dives in the catalog (scan backwards for youngest dive first)
//   Limits: Only the youngest MAXCATDIVE dives are listed in the catalog
//------------------------------------------------------------------ 17.02.07 --
procedure LoadDiveCatalog(var CatDives, LogDives: Word);
var
  ldive, ltype, lpar: Byte;
  lident, block, ltmp: Word;
  addr, blocks: Long;
label
  LISTFULL;
begin
  CatDives := cCLEAR;  // number of dives in catalog (0=failed)
  LogDives := cCLEAR;  // max number of dive in flash memory
  blocks   := cCLEAR;

  if MemBlocks <= cCLEAR then begin
    LogBuff := IntToStr(MemBlocks);
    LogError('LoadDiveCatalog', 'No flash memory available', LogBuff, $97);
    Exit;
  end;

  ClearDiveCatalog;  // clear dive catalog array

  for block := 0 to MemBlocks - 1 do begin
    addr := block * MEMBLOCKSIZE;
    addr := MemWrite - addr;          // scan backwards from oldest to youngest dive

    if addr < 0 then begin
      addr := addr + MemFree;         // start scan on 1st empty block
    end;

    MemRead := addr;
    ReadMemWord(lident, cOFF);        // read 1st word of block

    ltype := lident mod HIGHBYTE;     // get lower byte of word (LogType)

    if ltype = LOGSTART then begin
      ldive   := lident div HIGHBYTE; // get higher byte of word (DiveDayNum)
      MemRead := addr;                // reset read address pointer
      ReadMemBlock(LOGBLOCKPAR);      // read dive data block

      if MemBlock[LOGBLOCKPAR, 3] = MEMEMPTYWORD then begin //09.05.07 nk opt - not closed dive
        SysBuff := Format(ADDRFORM, [MemRead]);
        LogError('LoadDiveCatalog', 'Not closed dive at address', SysBuff, $99);
      end else begin
        CatDives := CatDives + 1;     // 1-MAXCATDIVE (DiveCatalog[0, x] for header info)

        //test only
        //SysBuff := Format(ADDRFORM, [addr]);
        //dtime := MemBlock[LOGBLOCKPAR, 4] * HIGHWORD + MemBlock[LOGBLOCKPAR, 5];
        //SysBuff := SysBuff + ' - ' + IntToStr(MemBlock[LOGBLOCKPAR, 3]);
        //LogEvent('LoadDiveCatalog', 'START BLOCK FOUND AT ADDR', SysBuff);

        for lpar := 0 to 5 do begin                   // 0 = DiveTime [s/min]
          ltmp := lpar + 1;                           // 1 = MaxDepth [cm]
          ltmp := MemBlock[LOGBLOCKPAR, ltmp];        // 2 = LogBlock (number of blocks)
          if ltmp = MEMEMPTYWORD then begin           // 3 = StartTime hiword [s]
            ltmp := cCLEAR;                           // 4 = StartTime loword [s]
          end;                                        // 5 = DiveLogNum (1..9999)
          DiveCatalog[CatDives, lpar] := ltmp;        // 6 = DiveDayNum (1..9)
        end; // ltmp=FFFF means invalid data (=0)     // 7 = Start block in flash

        DiveCatalog[CatDives, 6] := ldive;
        DiveCatalog[CatDives, 7] := MemRead div MEMBLOCKSIZE;

        blocks := blocks + DiveCatalog[CatDives, 2];  // total blocks used

        if DiveCatalog[CatDives, 5] > LogDives then begin
          LogDives := DiveCatalog[CatDives, 5];       // find greatest dive number
        end;

        if CatDives >= MAXCATDIVE then goto LISTFULL;
      end;
    end;
  end;

LISTFULL: // dive catalog header info
  MemRead := MEMSTART;

  //nk// fill header info with max / avg data
  DiveCatalog[0, 0] := 0;   //
  DiveCatalog[0, 1] := 0;   //
  DiveCatalog[0, 2] := blocks;   // total used dive blocks
  DiveCatalog[0, 3] := 0;   //
  DiveCatalog[0, 4] := CatDives; // total dives in catalog
  DiveCatalog[0, 5] := LogDives; // last dive number (1..9999)
  DiveCatalog[0, 6] := 0;   //
  DiveCatalog[0, 7] := 0;   //

  LogBuff := IntToStr(blocks) + sSLASH + IntToStr(MemBlocks);
  LogEvent('LoadDiveCatalog', 'Dive data blocks', LogBuff);

  LogBuff := IntToStr(CatDives) + sSLASH + IntToStr(LogDives);
  LogEvent('LoadDiveCatalog', 'Number of dives in catalog', LogBuff);
end;

//------------------------------------------------------------------------------
// CLEARDIVEDATA - Clear the dive data array - set all values to 0
//------------------------------------------------------------------ 17.02.07 --
procedure ClearDiveData;   //TIGER add this sub
var
  ldat: Word;
begin
  for ldat := 0 to MAXDIVEDATA - 1 do begin
    DiveData[ldat] := cCLEAR;
  end;
end;

//------------------------------------------------------------------------------
// LOADDIVEDATA - Load saved dive data from flash into the dive data array
//   Need the dive number (1..9999) in the flash data memory
//   Return the corresponding dive number (1..200) from the dive catalog
//------------------------------------------------------------------ 12.03.07 --
procedure LoadDiveData(var Dive: Word);    //TIGER add sub
var
  ltype: Byte;
  ppoint, ldat: Word;
  block, eblock, sblock, status: Word;
  addr: Long;
begin
  GetCatalogDive(Dive); // get catalog dive number

  eblock := DiveCatalog[Dive, 2]; // number of dive log blocks
  sblock := DiveCatalog[Dive, 7]; // flash start block of dive

  if (Dive = 0) or (eblock = 0) then begin
    LogBuff := IntToStr(Dive);
    LogError('LoadDiveData', 'No data found to load for dive', LogBuff, $A2);
    Dive := cCLEAR;
    Exit;
  end;

  ClearDiveData;    // clear dive data array

  status := cCLEAR;
  ppoint := cCLEAR;
  ldat   := cCLEAR;

  eblock := eblock + sblock;

  {//nk// test only
  DiveData[0]  := 45240;  // 220     // metrical units
  DiveData[1]  := 7404;   // 221
  DiveData[2]  := 754;    // 222
  DiveData[3]  := 57594;  // 223a
  DiveData[4]  := 57600;  // 223b
  DiveData[5]  := 1234;   // 228
  DiveData[6]  := 26;     // 230
  DiveData[7]  := 12;     // 232
  DiveData[8]  := 34450;  // 234
  DiveData[9]  := 1023;   // 236

  DiveData[10] := 6789;   // 238     // metrical units
  DiveData[11] := 28545;  // 240
  DiveData[12] := 123;    // 242
  DiveData[13] := 123;    // 244
  DiveData[14] := 12344;  // 246
  DiveData[15] := 456;    // 248
  DiveData[16] := 1234;   // 250
  DiveData[17] := 123;    // 252
  DiveData[18] := 123;    // 254
  DiveData[19] := 70;     // 255

  DiveData[20] := 45240;  // 220     // imperial units
  DiveData[21] := 7404;   // 221
  DiveData[22] := 754;    // 222
  DiveData[23] := 57594;  // 223a
  DiveData[24] := 57600;  // 223b
  DiveData[25] := 3761;   // 229
  DiveData[26] := 27;     // 231
  DiveData[27] := 12;     // 233
  DiveData[28] := 23832;  // 235
  DiveData[29] := 1057;   // 237

  DiveData[30] := 6206;   // 239     // imperial units
  DiveData[31] := 26221;  // 241
  DiveData[32] := 312;    // 243
  DiveData[33] := 56;     // 245
  DiveData[34] := 3761;   // 247
  DiveData[35] := 152;    // 249
  DiveData[36] := 37020;  // 251
  DiveData[37] := 267;    // 253
  DiveData[38] := 123;    // 254
  DiveData[39] := 70;     // 255   }


  for block := sblock to eblock do begin
    addr    := block * MEMBLOCKSIZE; // flash memory address
    MemRead := addr;
    ReadMemBlock(LOGBLOCKPAR);    // read dive data block

    ltype := MemBlock[LOGBLOCKPAR, 0] mod HIGHBYTE; // get lower byte of word (LogType)

    if (ltype > LOGSTART) and (ltype < LOGEND) then begin
      status := status or MemBlock[LOGBLOCKPAR, 15]; // add status bits

      if ppoint < MAXLOGPOINT then begin
        ppoint := ppoint + 1;  // ppoint=0 for header infos
        DiveProfile[ppoint, 0] := status; // system status word [bit]
        DiveProfile[ppoint, 1] := MemBlock[LOGBLOCKPAR, 1]; // log time [s/min]
        DiveProfile[ppoint, 2] := MemBlock[LOGBLOCKPAR, 2]; // dive depth [cm]
      end;
      status := cCLEAR;

      ldat := ldat + 1;
    end;
  end;

  MemRead := MEMSTART;

  LogBuff := IntToStr(ppoint) + sSLASH + IntToStr(ldat);
  LogEvent('LoadDiveData', 'Number of loaded dive data', LogBuff);
end;

//------------------------------------------------------------------------------
// CLEARDIVEPROFILE - Clear the dive profile array - set all values to 0
//------------------------------------------------------------------ 17.02.07 --
procedure ClearDiveProfile;
var
  lpoint, lpar: Word;
begin
  for lpoint := 0 to MAXLOGPOINT - 1 do begin
    for lpar := 0 to MAXLOGPARS - 1 do begin
      DiveProfile[lpoint, lpar] := cCLEAR;
    end;
  end;

  //22.05.07 nk add - DELPHI initialize dive profile and track
  Profile.InitDiveProfile(cCLEAR); // initialize dive profile
  Track.InitDiveTrack(cCLEAR);     // initialize dive track
end;

//------------------------------------------------------------------------------
// LOADDIVEPROFILE - Load saved dive data from flash into the dive profile array
//   Need the dive number (1..9999) in the flash data memory
//   Return the corresponding dive number (1..200) from the dive catalog
//   DELPHI: Store each dive point and track into dynamic profile arrays
//------------------------------------------------------------------ 17.02.07 --
procedure LoadDiveProfile(var Dive: Word);
var
  ltype: Byte;
  apoint, lpoint, ppoint, tpoint, astep, lstep: Word;
  block, eblock, sblock, status: Word;
  addr: Long;
begin
  GetCatalogDive(Dive); // get catalog dive number

  eblock := DiveCatalog[Dive, 2];         // number of dive log blocks
  sblock := DiveCatalog[Dive, 7];         // flash start block of dive
  astep  := eblock div CHARTLOGPOINT + 1; // DELPHI step width for profile chart

  if (Dive = 0) or (eblock = 0) then begin
    LogBuff := IntToStr(Dive);
    LogError('LoadDiveProfile', 'No data found to load for dive', LogBuff, $A2);
    Dive := cCLEAR;
    Exit;
  end;

  ClearDiveProfile;    // clear dive profile array

  status := cCLEAR;
  apoint := cCLEAR;
  lpoint := cCLEAR;
  ppoint := cCLEAR;
  tpoint := cCLEAR;

  lstep  := eblock div MAXLOGPOINT + 1; // step width for open profile
  eblock := eblock + sblock;

  for block := sblock to eblock do begin
    addr    := block * MEMBLOCKSIZE;    // flash memory address
    MemRead := addr;
    ReadMemBlock(LOGBLOCKPAR);          // read dive data block

    ltype := MemBlock[LOGBLOCKPAR, 0] mod HIGHBYTE;  // get lower byte of word (LogType)

    if (ltype > LOGSTART) and (ltype < LOGEND) then begin
      status := status or MemBlock[LOGBLOCKPAR, 15]; // add status bits

      if lpoint mod lstep = 0 then begin  // limit points to MAXLOGPOINT
        if ppoint < MAXLOGPOINT then begin
          ppoint                 := ppoint + 1;               // ppoint=0 for header infos
          DiveProfile[ppoint, 0] := status;                   // system status word [bit]
          DiveProfile[ppoint, 1] := MemBlock[LOGBLOCKPAR, 1]; // log time [s/min]
          DiveProfile[ppoint, 2] := MemBlock[LOGBLOCKPAR, 2]; // dive depth [cm]
        end;
        status := cCLEAR;
      end;

      //22.05.07 nk opt DELPHI: fill dive profile and track arrays
      if lpoint mod astep = 0 then begin  // limit max number of data points
        if apoint < CHARTLOGPOINT then begin
          Profile.AddDivePoint(apoint, MemBlock[LOGBLOCKPAR, 1], MemBlock[LOGBLOCKPAR, 2], MemBlock[LOGBLOCKPAR, 3]);
          apoint := apoint + 1;
        end;
      end;

      lpoint := lpoint + 1;
    end;

    if ltype = LOGNAV then begin  //02.06.07 nk opt ff - DELPHI only
      if tpoint < MAXLOGPOINT then begin
        Track.AddDivePos(tpoint, MemBlock[LOGBLOCKPAR, 7], MemBlock[LOGBLOCKPAR, 8]);
        tpoint := tpoint + 1;
      end;
    end;
  end;

  //nk// fill more header infos (num of alarms, track points...)
  DiveProfile[0, 0] := ppoint; // number of dive profile points in the array
  DiveProfile[0, 1] := tpoint; // number of dive track points in the array
  MemRead           := MEMSTART;

  LogBuff := IntToStr(ppoint) + sSLASH + IntToStr(lpoint);
  LogEvent('LoadDiveProfile', 'Number of loaded dive points', LogBuff);
end;

//------------------------------------------------------------------------------
// INITDIVELOG - Initialize new dive log and save start of dive header infos
//   This procedure is called once on start of dive
//------------------------------------------------------------------ 17.02.07 --
procedure InitDiveLog;
begin
  if DiveLogNum >= MAXLOGDIVE then begin
    DiveLogNum := cCLEAR;
  end;

  DiveLogNum := DiveLogNum + 1; // count dive number up (1..9999)
  LogWrite   := MemWrite;       // store start address of dive log
  LogStep    := cCLEAR;
  LogBlock   := cCLEAR;         // start dive data block
  LogIdent   := LOGSTART + DiveDayNum * HIGHBYTE;

  ClearMemBlock(LOGBLOCKPAR);

  MemBlock[LOGBLOCKPAR,  0] := LogIdent;                 // log block identifier
  MemBlock[LOGBLOCKPAR,  1] := MEMEMPTYWORD;             // DiveTime will be set at LOGEND
  MemBlock[LOGBLOCKPAR,  2] := MEMEMPTYWORD;             // MaxDepth will be set at LOGEND
  MemBlock[LOGBLOCKPAR,  3] := MEMEMPTYWORD;             // LogBlock will be set at LOGEND
  MemBlock[LOGBLOCKPAR,  4] := StartTime div HIGHWORD;   // dive start hiword [s]
  MemBlock[LOGBLOCKPAR,  5] := StartTime mod HIGHWORD;   // dive start loword [s]
  MemBlock[LOGBLOCKPAR,  6] := DiveLogNum;               // total number of dives
  MemBlock[LOGBLOCKPAR,  7] := FlightTime div SEC_MIN;   // no fly time [min]
  MemBlock[LOGBLOCKPAR,  8] := DesatTime div SEC_MIN;    // desaturation time [min]
  MemBlock[LOGBLOCKPAR,  9] := SurfaceTime div MSEC_MIN; // surface time [min] (before diving)
  MemBlock[LOGBLOCKPAR, 10] := InertPress;               // inertgas pressure [mbar]
  MemBlock[LOGBLOCKPAR, 11] := FillPress div 10;         // tank fill pressure [cbar]
  MemBlock[LOGBLOCKPAR, 12] := AirPress;                 // barometric air pressure [mbar]
  MemBlock[LOGBLOCKPAR, 13] := AirTemp + KELVIN;         // air temperature [cK]
  MemBlock[LOGBLOCKPAR, 14] := Altitude;                 // altitude above sea level [m]
  MemBlock[LOGBLOCKPAR, 15] := StatusWord;               // system status word [bit]

  WriteMemBlock(LOGBLOCKPAR, cON);

  LogBlock := LogBlock + 1;    // inital dive data block
  LogIdent := LOGINIT  + DiveDayNum * HIGHBYTE;

  ClearMemBlock(LOGBLOCKPAR);

  MemBlock[LOGBLOCKPAR,  0] := LogIdent;              // log block identifier
  MemBlock[LOGBLOCKPAR,  1] := LogTime div MSEC_SEC;  // log time [s]
  MemBlock[LOGBLOCKPAR,  2] := DiveDepth;             // dive depth [cm]
  MemBlock[LOGBLOCKPAR,  3] := DecoCeil;              // deco ceiling [cm=mbar]
  MemBlock[LOGBLOCKPAR,  4] := DecoDepth;             // deco depth [cm]
  MemBlock[LOGBLOCKPAR,  5] := NullTime;              // no deco time [s]
  MemBlock[LOGBLOCKPAR,  6] := DiveSpeed + 1000;      // dive speed [%] (positive offset)
  MemBlock[LOGBLOCKPAR,  7] := DesatRate;             // desaturation rate [%]
  MemBlock[LOGBLOCKPAR,  8] := DiverScore;            // diver score [%]
  MemBlock[LOGBLOCKPAR,  9] := OxDose div 1000;       // cumulated oxygen dose [OTU]
  MemBlock[LOGBLOCKPAR, 10] := OxUnits div 1000;      // oxygen OTU units [ppt]
  MemBlock[LOGBLOCKPAR, 11] := OxClock div 1000;      // oxygen CNS clock [ppt]
  MemBlock[LOGBLOCKPAR, 12] := WaterSalt;             // water salinity [ppt]
  MemBlock[LOGBLOCKPAR, 13] := WaterTemp + KELVIN;    // water temperature [cK]
  MemBlock[LOGBLOCKPAR, 14] := AccuPower;             // remain accu voltage [%]
  MemBlock[LOGBLOCKPAR, 15] := StatusWord;            // system status word [bit]

  WriteMemBlock(LOGBLOCKPAR, cON);

  LogFlag := cON;
  LogBuff := IntToStr(DiveLogNum);
  LogEvent('InitDiveLog', 'New dive log initialized', LogBuff);

  ClearDiveProfile; //22.05.07 nk opt
end;

//------------------------------------------------------------------------------
// LOGDIVEBLOCK - Log all dive data in flash memory block while diving
//   This procedure is called every LogInterval time while diving
//------------------------------------------------------------------ 26.07.17 --
procedure LogDiveBlock;
var
  ltype: Byte;
  dtime, ltime: Word;
begin
  LogBlock := LogBlock + 1;  // count dive blocks up
  LogStep  := LogStep  + 1;  // get next log step

  if LogStep >= LOGEND then begin
    LogStep := LOGSTART;
  end;

  case LogStep of
    1: ltype := LOGINIT;
    2: ltype := LOGMAJOR;
    3: ltype := LOGFAST;
    4: ltype := LOGMAJOR;
    5: ltype := LOGMINOR;
    6: ltype := LOGMAJOR;
    7: ltype := LOGFAST;
    8: ltype := LOGMAJOR;
    9: ltype := LOGSLOW;
  else
    LogBuff := IntToStr(LogStep);
    LogError('LogDiveBlock', 'Invalid log step', LogBuff, $99);
    LogStep := cCLEAR;
    Exit;
  end;

  if DecoDepth > 0 then begin
    dtime := DecoTime;
  end else begin
    dtime := NullTime;
  end;

  CompressTime(LogTime, ltime); // compress time range [s/min]
  LogIdent := ltype + DiveDayNum * HIGHBYTE;

  // main dive data (every log cycle)
  ClearMemBlock(LOGBLOCKPAR);

  MemBlock[LOGBLOCKPAR,  0] := LogIdent;
  MemBlock[LOGBLOCKPAR,  1] := ltime;                 // log time [s/min]
  MemBlock[LOGBLOCKPAR,  2] := DiveDepth;             // dive depth [cm]
  MemBlock[LOGBLOCKPAR,  3] := DecoCeil;              // deco ceiling [cm]
  MemBlock[LOGBLOCKPAR,  4] := DecoDepth;             // deco depth [cm]
  MemBlock[LOGBLOCKPAR,  5] := dtime;                 // (no) deco time [s]
  MemBlock[LOGBLOCKPAR,  6] := DiveSpeed + 1000;      // dive speed [%] (positive offset)
  MemBlock[LOGBLOCKPAR, 15] := StatusWord;            // system status word [bit]

  case ltype of
    LOGINIT: begin  // initial dive data
      MemBlock[LOGBLOCKPAR,  7] := DesatRate;         // desaturation rate [%]
      MemBlock[LOGBLOCKPAR,  8] := DiverScore;        // diver score [%]
      MemBlock[LOGBLOCKPAR,  9] := OxDose div 1000;   // cumulated oxygen dose [OTU]
      MemBlock[LOGBLOCKPAR, 10] := OxUnits div 1000;  // oxygen OTU units [ppt]
      MemBlock[LOGBLOCKPAR, 11] := OxClock div 1000;  // oxygen CNS clock [ppt]
      MemBlock[LOGBLOCKPAR, 12] := WaterSalt;         // water salinity [ppt]
      MemBlock[LOGBLOCKPAR, 13] := WaterTemp + KELVIN;// water temperature [cK]
      MemBlock[LOGBLOCKPAR, 14] := AccuPower;         // remain accu power [%]
    end;

    LOGMAJOR: begin  // major dive data   09.05.07 nk opt
      MemBlock[LOGBLOCKPAR,  7] := Limit(AscentTime, 0, MAXWORD); // ascent time [s]
      MemBlock[LOGBLOCKPAR,  8] := Limit(GasTime, 0, MAXWORD);    // remaining gas time [s]
      MemBlock[LOGBLOCKPAR,  9] := BreathRate;        // breathing rate [mbar/s]
      MemBlock[LOGBLOCKPAR, 10] := AmbPress;          // ambient pressure [mbar]
      MemBlock[LOGBLOCKPAR, 11] := TankPress div 10;  // tank pressure [cbar]
      MemBlock[LOGBLOCKPAR, 12] := OxPress;           // oxygen partial pressure [mbar]
      MemBlock[LOGBLOCKPAR, 13] := NiPress;           // nitrogen partial pressure [mbar]
      MemBlock[LOGBLOCKPAR, 14] := HePress;           // helium partial pressure [mbar]
    end;

    LOGFAST: begin  // fast saturation data
      MemBlock[LOGBLOCKPAR,  7] := Round(Pt[0]);      // tissue saturation 0 [mbar]
      MemBlock[LOGBLOCKPAR,  8] := Round(Pt[1]);      // tissue saturation 1 [mbar]
      MemBlock[LOGBLOCKPAR,  9] := Round(Pt[2]);      // tissue saturation 2 [mbar]
      MemBlock[LOGBLOCKPAR, 10] := Round(Pt[3]);      // tissue saturation 3 [mbar]
      MemBlock[LOGBLOCKPAR, 11] := Round(Pt[4]);      // tissue saturation 4 [mbar]
      MemBlock[LOGBLOCKPAR, 12] := Round(Pt[5]);      // tissue saturation 5 [mbar]
      MemBlock[LOGBLOCKPAR, 13] := WaterTemp + KELVIN;// water temperature [cK]
      MemBlock[LOGBLOCKPAR, 14] := AccuPower;         // remain accu power [%]
    end;

    LOGMINOR: begin  // minor dive and medium saturation data
      MemBlock[LOGBLOCKPAR,  7] := Round(Pt[6]);      // tissue saturation 6 [mbar]
      MemBlock[LOGBLOCKPAR,  8] := Round(Pt[7]);      // tissue saturation 7 [mbar]
      MemBlock[LOGBLOCKPAR,  9] := Round(Pt[8]);      // tissue saturation 8 [mbar]
      MemBlock[LOGBLOCKPAR, 10] := Round(Pt[9]);      // tissue saturation 9 [mbar]
      MemBlock[LOGBLOCKPAR, 11] := Round(Pt[10]);     // tissue saturation 10 [mbar]
      MemBlock[LOGBLOCKPAR, 12] := Round(Pt[11]);     // tissue saturation 11 [mbar]
      MemBlock[LOGBLOCKPAR, 13] := WaterTemp + KELVIN;// water temperature [cK]
      MemBlock[LOGBLOCKPAR, 14] := AccuPower;         // remain accu power [%]
    end;

    LOGSLOW: begin  // slow saturation data  09.05.07 nk opt
      MemBlock[LOGBLOCKPAR,  7] := Round(Pt[12]);     // tissue saturation 12 [mbar]
      MemBlock[LOGBLOCKPAR,  8] := Round(Pt[13]);     // tissue saturation 13 [mbar]
      MemBlock[LOGBLOCKPAR,  9] := Round(Pt[14]);     // tissue saturation 14 [mbar]
      MemBlock[LOGBLOCKPAR, 10] := Round(Pt[15]);     // tissue saturation 15 [mbar]
      MemBlock[LOGBLOCKPAR, 11] := Round(Pt[16]);     // tissue saturation 16 [mbar]
      MemBlock[LOGBLOCKPAR, 12] := TotalDecoGas div 10; // total deco gas [cbar] 09.05.07 nk old=mbar
      MemBlock[LOGBLOCKPAR, 13] := Limit(TotalDecoTime, 0, MAXWORD); // total deco time [s]
      MemBlock[LOGBLOCKPAR, 14] := WaterDens;         // water density [g/dl]
    end;
  else
    LogBuff := IntToStr(ltype);
    LogError('LogDiveBlock', 'Invalid log type', LogBuff, $99);
    LogStep := cCLEAR;
    Exit;
  end;

  WriteMemBlock(LOGBLOCKPAR, cON);

  if (ltype = LOGFAST) and ((SonarFlag = cON) or (SwimSpeed > 0)) then begin  //26.07.17 nk opt - DELPHI log track
    LogIdent := LOGNAV + DiveDayNum * HIGHBYTE;
    ClearMemBlock(LOGBLOCKPAR);
    MemBlock[LOGBLOCKPAR,  0] := LogIdent;
    MemBlock[LOGBLOCKPAR,  1] := ltime;             // log time [s/min]
    MemBlock[LOGBLOCKPAR,  2] := DiveDepth;         // dive depth [cm]
    MemBlock[LOGBLOCKPAR,  3] := DecoCeil;          // deco ceiling [cm]
    MemBlock[LOGBLOCKPAR,  4] := DecoDepth;         // deco depth [cm]
    MemBlock[LOGBLOCKPAR,  5] := dtime;             // (no) deco time [s]
    MemBlock[LOGBLOCKPAR,  6] := DiveSpeed + 1000;  // dive speed [%] (positive offset)
    MemBlock[LOGBLOCKPAR,  7] := HomeDist;          // home distance [dm]
    MemBlock[LOGBLOCKPAR,  8] := Bearing;           // home bearing [ddeg]
    MemBlock[LOGBLOCKPAR,  9] := Heading;           // magnetic heading [ddeg]
    MemBlock[LOGBLOCKPAR, 10] := SonarSignal;       // sonar signal strength
    MemBlock[LOGBLOCKPAR, 11] := SoundSpeed;        // sound speed [dm/s]
    MemBlock[LOGBLOCKPAR, 12] := WaterSalt;         // water salinity [ppt]
    MemBlock[LOGBLOCKPAR, 13] := WaterTemp + KELVIN;// water temperature [cK]
    MemBlock[LOGBLOCKPAR, 14] := WaterDens;         // water density [g/dl]
    MemBlock[LOGBLOCKPAR, 15] := StatusWord;        // system status word [bit]
    WriteMemBlock(LOGBLOCKPAR, cON);
  end;

  //DELPHI: draw dive track
  if SwimSpeed > 0 then begin
    Track.AddDivePos(AUTOINC, HomeDist, Bearing);
    Track.DrawDivePos(HomeDist, Bearing, True);
  end;

  //DELPHI: draw dive profile
  Profile.AddDivePoint(AUTOINC, MemBlock[LOGBLOCKPAR, 1], MemBlock[LOGBLOCKPAR, 2], MemBlock[LOGBLOCKPAR, 3]);
  Profile.DrawDivePoint(LogTime div MSEC_SEC, DiveDepth, DecoCeil, True);
end;

//------------------------------------------------------------------------------
// CLOSEDIVELOG - Close open dive log and save dive catalog infos
//   This procedure is called once on end of post dive
//------------------------------------------------------------------ 17.02.07 --
procedure CloseDiveLog;
var
  ltime: Word;
  endwrite: Long;
begin
  endwrite := MemWrite;  // store end address of dive log
  MemWrite := LogWrite;  // re-store start address of dive log
  LogBlock := LogBlock + 2;

  CompressTime(DiveTime, ltime); // compress time range [s/min]
  ClearMemBlock(LOGBLOCKPAR); 

  // fill in dive catalog infos in start block at LOGEND
  MemBlock[LOGBLOCKPAR, 1] := ltime;    // total dive time [s/min]
  MemBlock[LOGBLOCKPAR, 2] := MaxDepth; // max depth [cm]
  MemBlock[LOGBLOCKPAR, 3] := LogBlock; // total number of dive blocks

  WriteMemBlock(LOGBLOCKPAR, cOFF);     // 01.06.07 nk opt - do not clear sector

  LogIdent := LOGEND + DiveDayNum * HIGHBYTE;
  MemWrite := endwrite;  // re-store end address of dive log

  ClearMemBlock(LOGBLOCKPAR);
  
  MemBlock[LOGBLOCKPAR,  0] := LogIdent;                 // log block identifier
  MemBlock[LOGBLOCKPAR,  1] := ltime;                    // total dive time [s/min]
  MemBlock[LOGBLOCKPAR,  2] := MaxDepth;                 // max depth [cm]
  MemBlock[LOGBLOCKPAR,  3] := LogBlock;                 // total number of dive blocks
  MemBlock[LOGBLOCKPAR,  4] := EndTime div HIGHWORD;     // dive end hiword [s]
  MemBlock[LOGBLOCKPAR,  5] := EndTime mod HIGHWORD;     // dive end loword [s]
  MemBlock[LOGBLOCKPAR,  6] := DiveLogNum;               // total number of dives
  MemBlock[LOGBLOCKPAR,  7] := FlightTime div SEC_MIN;   // no fly time [min]
  MemBlock[LOGBLOCKPAR,  8] := DesatTime div SEC_MIN;    // desaturation time [min]
  MemBlock[LOGBLOCKPAR,  9] := SurfaceTime div MSEC_MIN; // surface time [min] (after diving)
  MemBlock[LOGBLOCKPAR, 10] := BreathRate;               // average breath rate [mbar/s]
  MemBlock[LOGBLOCKPAR, 11] := TankPress div 10;         // remain tank pressure [cbar]
  MemBlock[LOGBLOCKPAR, 12] := AirPress;                 // barometric air pressure [mbar]
  MemBlock[LOGBLOCKPAR, 13] := AirTemp + KELVIN;         // air temperature [cK]
  MemBlock[LOGBLOCKPAR, 14] := AccuPower;                // remain accu power [%]
  MemBlock[LOGBLOCKPAR, 15] := StatusWord;               // system status word [bit]

  WriteMemBlock(LOGBLOCKPAR, cON);

  LogFlag  := cOFF;
  LogWrite := MemWrite;  // store start address of dive log
  LogBuff  := IntToStr(DiveLogNum);
  LogEvent('CloseDiveLog', 'Dive log closed', LogBuff);
end;

//------------------------------------------------------------------------------
// GETNEXTDIVEPOINT - Return number of next dive point in DiveProfile array
//------------------------------------------------------------------ 17.02.07 --
procedure GetNextDivePoint(var DivePoint: Word; GoAround: Byte);
var
  pmin, pmax: Word;
begin
  pmin := 1; // number of first dive point (0=header info)
  pmax := DiveProfile[0, 0] - 1; // number of last dive point

  if DivePoint < pmax then begin
    DivePoint := DivePoint + 1;
  end else begin
    if GoAround = cON then begin
      DivePoint := pmin;
    end else begin
      DivePoint := cCLEAR; // end of profile
    end;
  end;
end;

//------------------------------------------------------------------------------
// GETPREVDIVEPOINT - Return number of previous dive point in DiveProfile array
//------------------------------------------------------------------ 17.02.07 --
procedure GetPrevDivePoint(var DivePoint: Word; GoAround: Byte);
var
  pmin, pmax: Word;
begin
  pmin := 1; // number of first dive point (0=header info)
  pmax := DiveProfile[0, 0] - 1; // number of last dive point

  if DivePoint > pmin then begin
    DivePoint := DivePoint - 1;
  end else begin
    if GoAround = cON then begin
      DivePoint := pmax;
    end else begin
      DivePoint := cCLEAR; // start of profile
    end;
  end;
end;

//------------------------------------------------------------------------------
// SAVESETTINGS - Save setting parameters into flash memory
//------------------------------------------------------------------ 17.02.07 --
procedure SaveSettings;
var
  p, x, y, z: Byte;
  lobyte, hibyte, nblock, nword: Byte;
  value: Word;
begin
  if MemBlocks <= cCLEAR then begin
    LogBuff := IntToStr(MemBlocks);
    LogError('SaveSettings', 'No flash memory available', LogBuff, $97);
    Exit;
  end;

  nblock := cCLEAR;
  nword  := cCLEAR;
  
  ClearMemBlock(LOGBLOCKSET);

  LogIdent := LOGSET + nblock * HIGHBYTE;
  MemBlock[LOGBLOCKSET, nword] := LogIdent;
  nword := nword + 1;

  for p := 0 to SETPARS - 1 do begin       // LogIdent + 1 block = 32bytes
    if p mod WORDLEN = 0 then begin
      x      := GlobalPar[p] div 100;      // get lower byte of word
      y      := GlobalPar[p] mod 100;
      y      := y div 10;
      z      := GlobalPar[p] mod 10;
      lobyte := GlobalSet[x, y, z];

      x      := GlobalPar[p + 1] div 100;  // get higher byte of word
      y      := GlobalPar[p + 1] mod 100;
      y      := y div 10;
      z      := GlobalPar[p + 1] mod 10;
      hibyte := GlobalSet[x, y, z];

      value := lobyte + hibyte * HIGHBYTE;    // make word value from
      MemBlock[LOGBLOCKSET, nword] := value;  // lower and higher bytes
      nword := nword + 1;
    end;

    if nword = (MEMBLOCKSIZE div WORDLEN) then begin
      WriteMemBlock(LOGBLOCKSET, cON);        // save parameter block
      ClearMemBlock(LOGBLOCKSET);
      nblock   := nblock + 1;                 // next setting block
      nword    := cCLEAR;
      LogIdent := LOGSET + nblock * HIGHBYTE;
      MemBlock[LOGBLOCKSET, nword] := LogIdent;
      nword    := nword + 1;
    end;
  end;

  LogBuff := IntToStr(SETPARS);
  LogEvent('SaveSettings', 'Setting parameter saved', LogBuff);
end;

//------------------------------------------------------------------------------
// LOADSETTINGS - Load saved setting parameters from flash memory
//------------------------------------------------------------------ 17.02.07 --
procedure LoadSettings;
var
  p, x, y, z: Byte;
  snum, ltype: Byte;
  lobyte, hibyte, nword: Byte;
  lident, block, value: Word;
  addr: Long;
begin
  if MemBlocks <= cCLEAR then begin
    LogBuff := IntToStr(MemBlocks);
    LogError('LoadSettings', 'No flash memory available', LogBuff, $97);
    Exit;
  end;

  for block := 0 to MemBlocks - 1 do begin
    addr := block * MEMBLOCKSIZE;
    addr := MemWrite - addr;           // scan backwards from oldest to youngest parameter

    if addr < 0 then begin
      addr := addr + MemFree;          // start scan on 1st empty block
    end;

    MemRead := addr;
    ReadMemWord(lident, cOFF);         // read 1st word of block

    ltype := lident mod HIGHBYTE;      // get lower byte of word (LogType)

    if ltype = LOGSET then begin       // setting parameter found
      snum    := lident div HIGHBYTE;   // get higher byte of word (SetNum)
      MemRead := addr;                 // reset read address pointer
      ReadMemBlock(LOGBLOCKSET);       // read setting parameter block

      for nword := 1 to MEMBLOCKLEN - 1 do begin
        value  := MemBlock[LOGBLOCKSET, nword];
        lobyte := value mod HIGHBYTE;  // get lower byte of value
        hibyte := value div HIGHBYTE;  // get higher byte of value
        p     := 2 * (snum * (MEMBLOCKLEN - 1) + nword - 1);

        x := GlobalPar[p] div 100;     // set lower byte of value
        y := GlobalPar[p] mod 100;
        y := y div 10;
        z := GlobalPar[p] mod 10;
        GlobalSet[x, y, z] := lobyte;

        x := GlobalPar[p + 1] div 100; // set higher byte of value
        y := GlobalPar[p + 1] mod 100;
        y := y div 10;
        z := GlobalPar[p + 1] mod 10;
        GlobalSet[x, y, z] := hibyte;
      end;

      if snum = 0 then begin
        LogBuff := IntToStr(SETPARS);
        LogEvent('LoadSettings', 'Setting parameter loaded', LogBuff);
        Exit;
      end;
    end;
  end;

  LogEvent('LoadSettings', 'No setting parameter found', sEMPTY);
end;

end.

