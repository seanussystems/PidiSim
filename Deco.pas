// Tissue Saturation and Decompression Calculations
// Date 17.02.07
// Norbert Koechli
// Copyright ©2005-2007 seanus systems

unit Deco;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, DateUtils, Math, UGlobal,
  USystem, SYS, Global, Data, Tank, Texts, FLog, UPidi;

  procedure InitSaturation;
  procedure CalcSaturation(Dtime: Long; var NullTime, DesatTime, FlightTime: Long);
  procedure CalcDecoStop(var DecoTime, DecoDepth: Long);
  procedure CalcDecoTime(var TotalDecoTime, TotalDecoGas: Long);
  procedure CalcSimulation(Dtime, Ddepth: Long; var SimNullTime, SimDesatTime, SimFlightTime: Long);

const
  PRESSUNIT = ' mbar';  // standard pressure unit

var
  DecBuff: string;

implementation

uses FMain;

//------------------------------------------------------------------------------
// INITSATURATION - Initialize inert gas saturation [mbar] for all tissues
//   to actual air pressure [mbar] at surface
//------------------------------------------------------------------ 17.02.07 --
procedure InitSaturation;
var
  ic: Long;
  pg: Real;
begin
  // inert gas pressure for air at surface [mbar]
  pg := (AirPress - PVAPOR) * FNITROGEN / 1000.0;
  ic := Trunc(pg) + 1;
  InertPress := Limit(ic, 0, DEPTHDISP);

  for ic := 0 to MAXCOMP - 1 do begin
    Pt[ic] := InertPress;          // compartment saturation [mbar]
    Px[ic] := InertPress;          // at air pressure
    Rg[ic] := PROCENT;
    Rc[ic] := cCLEAR;
  end;

  DecBuff := IntToStr(MAXCOMP) + sDIM + IntToStr(InertPress) + PRESSUNIT;
  LogEvent('InitSaturation', 'Compartments initialized', DecBuff);
end;

//------------------------------------------------------------------------------
// CALCSATURATION - Calculate inert gas saturation [mbar] for all tissues
//------------------------------------------------------------------ 17.02.07 --
procedure CalcSaturation(Dtime: Long; var NullTime, DesatTime, FlightTime: Long);
var
  k, kl, dr, sr: Byte;
  Pa, Pb, dc, ht, nt, dt, ft, fn, lt, rt: Long;
  a, b, t, th, tn, td, tf, ex, dP, Pc, Pg, Ph, Pn, Po, nk: Real;
begin
  kl := 0;                         // initial leading compartment
  dt := 1;                         // initial desaturation time [s] (>0)
  ft := 1;                         // initial no fly time time [s] (>0)
  dc := 0;                         // initial deco ceiling [mbar=cm]
  lt := 0;                         // initial leading tissue [%]
  nt := TIMERANGE;                 // initial null time [s] (9:59h)

// input
//------------------------------------------------------------------------------
  t := Dtime / MSEC_SEC;           // measuring time interval [s]

// globals
//------------------------------------------------------------------------------
  dr := DesatRate;                 // desaturation slow down rate [%]
  sr := DiverScore;                // personal dive score rate [%]
  Pa := AmbPress;                  // absolute ambient pressure [mbar]
  Pb := AirPress;                  // barometric air pressure at surface [mbar]
  fn := NiFract;                   // nitrogen fraction in tank gas [ppt]

  Pn := (Pb - PVAPOR) * FNITROGEN / 1000.0;  // inert gas pressure in air at surface [mbar]
  Pg := (Pa - PVAPOR) * fn / 1000.0;  // inert gas pressure in breathing gas at depth [mbar]

// main calculation loop
//------------------------------------------------------------------------------
  for k := 1 to MAXCOMP - 1 do begin  // for each compartment

    ht := Kt[k] * 6;               // compartment half time [s]
    a := Ka[k] / 1000.0 * sr;      // buehlmann parameter a [mbar] (scored)
    b := Kb[k] / 10000.0;          // buehlmann parameter b

    //**** calculate tissue saturation *****

    if Pt[k] > Pg then begin       // ascending - tissues are gassing off
      th := ht / PROCENT * dr;     // -->  slow down desaturation rate
    end else begin                 // descending - tissues are gassing on
      th := ht;                    // -->  standard for saturation
    end;

    ex := 1.0 - Exp(-t / th * LN2); // exponential time function of tissue in/out-gassing
    dP := ex * (Pg - Pt[k]);       // inert gas pressure (+/-) take [mbar] in tissue while t [s]
    Pt[k] := Pt[k] + dP;           // new cumulated tissue pressure [mbar]

    Po := (Pb / b) + a;            // tolerated ambient pressure at surface [mbar]
    Pc := (Pa / b) + a;            // tolerated ambient pressure at depth [mbar]

    if Pg > 0 then begin
      nk := PROCENT * Pt[k] / Pg;  // DELPHI: Real -> Long
      rt := Trunc(nk);             // tissue pressure rel breathing inert gas pressure [%]
      Rg[k] := Limit(rt, 0, SATMAXLOAD);
    end else begin
      Rg[k] := SATMAXLOAD;
    end;

    if Pc > 0 then begin
      nk := PROCENT * Pt[k] / Pc;  // DELPHI: Real -> Long
      rt := Trunc(nk);             // tissue pressure rel tolerated ambient pressure [%]
      Rc[k] := Limit(rt, 0, SATMAXLOAD);
    end else begin
      Rc[k] := 0;
    end;

    if Rc[k] > lt then begin       // get leading tissue loading [%]
      lt := Rc[k];
    end;

    if DivePhase > PHASEPREDIVE then begin

      //**** calculate deepest deco ceiling *****

      Ph := (Pt[k] - a) * b - Pb;  // highest allowed deco ceiling [mbar=cm] rel. surface (Pb)
      if Ph > dc then begin
        dc := Trunc(Ph);           // get deepest deco ceiling [mbar=cm] rel. 0m
      end;

      //**** calculate remaining no deco time *****

      th := ht;

      if (Pg > Po) and (Pg > Pt[k]) then begin  // on-gassing: Po>=Pt=>tn>=0 => no deco
        tn := -th * Log2((Pg - Po) / (Pg - Pt[k]));  // remaining no deco time [s] Po<Pt=>tn<0 => deco!
        if tn < nt then begin
          nt := Trunc(tn);         // get shortest no deco time [s]
          kl := k;                 // get leading compartment
        end;
      end;
    end;

    if DivePhase <> PHASEDIVE then begin

      //**** calculate desaturation and no fly time *****

      th := ht / PROCENT * dr;     // slow down desaturation rate

      if Pt[k] > Pn then begin
        td := -th * Log2(PDESAT / (Pt[k] - Pn));  // desaturation time [s]
        if td > dt then begin
          dt := Trunc(td);         // get longest desaturation time [s]
        end;
      end;

      if Pt[k] > Pn then begin
        tf := -th * Log2(PFLIGHT / (Pt[k] - Pn));  // no fly time time [s]
        if tf > ft then begin
          ft := Trunc(tf);         // get longest time to fly [s]
        end;
      end;
    end;
  end;

// output
//------------------------------------------------------------------------------
  NullTime := Limit(nt, 0, TIMERANGE);     // remaining no deco time [s] (0..9:59)
  DesatTime := Limit(dt, 0, TIMEDISP);     // desaturation time [s] (0..99:59)
  FlightTime := Limit(ft, 0, TIMEDISP);    // waiting time to fly [s] (0..99:59)
  InertPress := Limit(Trunc(Pg), 0, DEPTHDISP);  // inert gas pressure [mbar] (0..19900)
  DecoCeil := Limit(dc, 0, DEPTHDISP);     // deepest ceiling [mbar=cm] (0..19900)
  LeadTissue := Limit(lt, 0, SATMAXLOAD);  // leading tissue pressure [%] (0..120)
end;

//------------------------------------------------------------------------------
// CALCDECOSTOP - Calculate the deepest deco stop depth [cm] and time [s]
//------------------------------------------------------------------ 17.02.07 --
procedure CalcDecoStop(var DecoTime, DecoDepth: Long);
var
  k, l, dr, sr, sd: Byte;
  Pb, Ps, fn, ht, ds, st, dl: Long;
  a, b, th, td, Da, Dc, Dg, Di, Dn, Dt, Ph: Real;
  dd: array[0..DECORANGE] of Word;
begin
  ds := 0;                         // initial deco stop depth [cm]
  st := 0;                         // initial deco stop time [s]

  for l := 0 to DECORANGE - 1 do begin  // clear temporary array
    dd[l] := cCLEAR;
  end;

// globals
//------------------------------------------------------------------------------
  dr := DesatRate;                 // desaturation slow down rate [%]
  sr := DiverScore;                // personal dive score rate [%]
  sd := DecoStep;                  // deco depth step [m] (3m=300mbar)

  Pb := AirPress;                  // barometric air pressure at surface [mbar]
  Ps := DecoStep * WaterDens;      // deco pressure step [mbar] (3m=300mbar)
  fn := NiFract;                   // nitrogen fraction in tank gas [ppt]

// main calculation loop for each compartment
//------------------------------------------------------------------------------
  for k := 1 to MAXCOMP - 1 do begin

    ht := Kt[k] * 6;               // compartment half time [s]
    a := Ka[k] / 1000.0 * sr;      // buehlmann parameter a [mbar] (scored)
    b := Kb[k] / 10000.0;          // buehlmann parameter b

    Dt := Pt[k];                   // actual tissue inert gas pressure [mbar]
    Ph := (Pt[k] - a) * b - Pb;    // highest allowed deco ceiling [mbar=cm] rel. surface (Pb)

    Di := Ps * (1 + Trunc(Ph / Ps));  // get next deeper deco level [mbar]
    dl := Trunc(Di / WaterDens);   // get deco level [m] on a deco step level
    dl := Limit(dl, 0, DECORANGE - 1);

    //**** calculate stop times for each deco level *****

    th := ht / PROCENT * dr;       // slow down desaturation rate

    if Di > 0 then begin
      Di := dl * WaterDens;  // 05.06.07 nk opt - limit deco level to DECORANGE

      for l := dl downto sd do begin  // dl is a multiple of sd
        if l mod sd = 0 then begin    // Tiger: step -sd
          Da := Di + Pb;           // ambient pressure at deco level [mbar]
          Dg := (Da - PVAPOR) * fn / 1000.0;  // inert gas pressure in breathing gas [mbar] at deco level
          Dc := Da - Ps;           // end deeper deco level
          Dn := (Dc / b) + a;      // tolerated ambient pressure for next deeper deco level

          if (Dg < Dt) and (Dg < Dn) then begin
            td := -th * Log2((Dg - Dn) / (Dg - Dt));  // desaturation time for end deco level [s]
            if td > dd[l] then begin  // get longest desat time [s] for each deco level
              dd[l] := 1 + Trunc(td);
            end;
          end;

	        Di := Di-Ps;             // calc next deco level [mbar]
	        Dt := Dn;                // tissue saturation at end level [mbar]
        end;
      end; //for
    end;
  end;

  for l := sd to DECORANGE - 1 do begin  // get deepest deco level [m]
    if l mod sd = 0 then begin     // Tiger: step -sd
      if dd[l] > 0 then begin      // deco required at level l
        ds := l * WaterDens;       // get last deco stop level [cm]
        st := dd[l] + SEC_MIN;     // get deco stop time [s] at last level
      end;
    end;
  end;

// output
//------------------------------------------------------------------------------
  DecoDepth := Limit(ds, 0, DEPTHDISP); // deepest deco stop depth [cm] (0..19900)
  DecoTime := Limit(st, 0, TIMERANGE);  // deepest deco stop time [s] (0..9:59)
end;                                    // 05.06.07 nk old=TIMESHORT

//------------------------------------------------------------------------------
// CALCDECOTIME - Calculate true deco time and gas consum for all deco stops
//------------------------------------------------------------------ 17.02.07 --
procedure CalcDecoTime(var TotalDecoTime, TotalDecoGas: Long);
var
  k: Byte;
  tt, tg: Long;
begin
  tt := 0;                         // initial total deco time [s]
  tg := 0;                         // initial total deco gas [mbar]

  SimDecoDepth := 0;
  SimDecoGas := 0;

  for k := 0 to MAXCOMP - 1 do begin  // initialize simulation tissues with
    Px[k] := Pt[k];                   // actual inert gas saturation [mbar]
  end;

// globals
//------------------------------------------------------------------------------
  k := 0;
  SimDecoTime := DecoTime;
  SimDiveTime := DecoTime;         // 1st deco stop time [s] and deepest
  SimDiveDepth := DecoDepth;       // deco depth [cm] from CalcDecoStop

  while SimDiveTime > 0 do begin   // calculate true deco time
    k := k + 1;
    tt := tt + SimDecoTime;        // cummulate deco time [s] and
    tg := tg + SimDecoGas;         // deco gas [mbar] for each deco stop

    CalcSimulation(SimDiveTime, SimDiveDepth, SimNullTime, SimDesatTime, SimFlightTime);

    SimDiveTime := SimDecoTime;
    SimDiveDepth := SimDecoDepth;
    
    if k > DECORANGE then begin    // emergency exit
      Exit;
    end;
  end;

  TotalDecoTime := Limit(tt, 0, TIMEDISP); // cummulated deco stop time [s] (0..99:59)
  TotalDecoGas := Limit(tg, 0, TANKMAX);   // cummulated deco stop gas [mbar] (0..650bar)
end;

//------------------------------------------------------------------------------
// CALCSIMULATION - Calculate all dive parameter for a simulated dive
//------------------------------------------------------------------ 17.02.07 --
procedure CalcSimulation(Dtime, Ddepth: Long; var SimNullTime, SimDesatTime, SimFlightTime: Long);
var
  k, l, dr, sr, sd: Byte;
  Pa, Pb, Ps, gd, ds, fn, st, br, ht, nt, dt, ft, dl: Long;
  a, b, t, th, tn, td, tf, ex, dP: Real;
  Da, Dc, Dg, Di, Dn, Dx, Pg, Ph, Pn, Po: Real;
  dd: array[0..DECORANGE] of Word;
begin
  dt := 1;                         // initial desaturation time [s] (>0)
  ft := 1;                         // initial no fly time time [s] (>0)
  ds := 0;                         // initial deco stop depth [m]
  st := 0;                         // initial deco stop time [s]
  gd := 0;                         // initial deco stop gas [mbar]
  nt := TIMERANGE;                 // initial null time [s] (9:59h)

  for l := 0 to DECORANGE - 1 do begin  // clear temporary array
    dd[l] := cCLEAR;
  end;

// input
//------------------------------------------------------------------------------
  t := Dtime;                      // planned dive time [s]
  Pa := AirPress + Ddepth;         // absolute ambient pressure [mbar]

// globals
//------------------------------------------------------------------------------
  dr := DesatRate;                 // desaturation slow down rate [%]
  sr := DiverScore;                // personal dive score [%]
  br := BreathRate;                // diver breathing rate [mbar/s]
  sd := DecoStep;                  // deco depth step [m] (3m=300mbar)

  Pb := AirPress;                  // barometric air pressure at surface [mbar]
  Ps := DecoStep * WaterDens;      // deco pressure step [mbar] (3m=300mbar)
  fn := NiFract;                   // nitrogen fraction in tank gas [ppt]

  Pn := (Pb - PVAPOR) * FNITROGEN / 1000.0;  // inert gas pressure in air at surface [mbar]
  Pg := (Pa - PVAPOR) * fn / 1000.0;  // inert gas pressure in breathing gas at depth [mbar]

// main calculation loop
//------------------------------------------------------------------------------
  for k := 1 to MAXCOMP - 1 do begin

    ht := Kt[k] * 6;               // compartment half time [s]
    a := Ka[k] / 1000.0 * sr;      // buehlmann parameter a [mbar] (scored)
    b := Kb[k] / 10000.0;          // buehlmann parameter b

    //**** calculate tissue saturation ****

    if Px[k] > Pg then begin       // ascending - tissues are gassing off
      th := ht / PROCENT * dr;     // --> slow down desaturation rate
    end else begin                 // descending - tissues are gassing on
      th := ht;                    // --> standard for saturation
    end;

    ex := 1.0 - Exp(-t / th * LN2);  // exponential time function of tissue in/out-gassing
    dP := ex * (Pg - Px[k]);       // inert gas pressure (+/-)take [mbar] in tissue while t [s]
    Px[k] := Px[k] + dP;           // new cumulated tissue pressure [mbar]

    Dx := Px[k];                   // temporary tissue pressure for simulation [mbar]
    Ph := (Px[k] - a) * b - Pb;    // highest allowed deco ceiling [mbar=cm]
    Po := (Pb / b) + a;            // tolerated ambient pressure at surface [mbar]

    Di := Ps * (1 + Trunc(Ph / Ps));  // get next deeper deco level [mbar]
    dl := Trunc(Di / WaterDens);   // get deco level [m] on a deco step level

    //**** calculate remaining no deco time *****

    th := ht;

    if (Pg > Po) and (Pg > Px[k]) then begin
      tn := -th * Log2((Pg - Po) / (Pg - Px[k]));  // remaining no deco time [s]
      if tn < nt then begin
        nt := Trunc(tn);           // get shortest no deco time [s]
      end;
    end;

    //**** calculate desaturation and no fly time *****

    th := ht / PROCENT * dr;       // slow down desaturation rate

    if Px[k] > Pn then begin
      td := -th * Log2(PDESAT / (Px[k] - Pn));  // desaturation time [s]
      if td > dt then begin
        dt := Trunc(td);           // get longest desaturation time [s]
      end;
    end;

    if Px[k] > Pn then begin
      tf := -th * Log2(PFLIGHT / (Px[k] - Pn));  // no fly time time [s]
      if tf > ft then begin
        ft := Trunc(tf);           // get longest time to fly [s]
      end;
    end;
    
    //**** calculate deco stop depth and time *****

    if Di > 0 then begin
      Di := dl * WaterDens;  // 05.06.07 nk opt - limit deco level to DECORANGE

      for l := dl downto sd do begin  // dl is a multiple of sd
        if l mod sd = 0 then begin    // Tiger: step -sd
	        Da := Di + Pb;              // ambient pressure at deco level [mbar]
          Dg := (Da - PVAPOR) * fn / 1000.0;  // inert gas pressure in tank gas [mbar] at deco level
          Dc := Da - Ps;              // next deeper deco level
          Dn := (Dc / b) + a;         // tolerated ambient pressure for next deeper deco level

	        if (Dg < Dx) and (Dg < Dn) then begin
	          td := -th * Log2((Dg - Dn) / (Dg - Dx));  // desaturation time for next deco level [s]
            if td > dd[l] then begin                  // get longest desat time [s] for each deco level
              dd[l] := 1 + Trunc(td);
            end;
          end;

	        Di := Di - Ps;           // calc next deco level [mbar]
      	  Dx := Dn;                // tissue saturation at next level [mbar]
        end;
      end;
    end;
  end;

  for l := sd to DECORANGE - 1 do begin  // get deepest deco level [m]
    if l mod sd = 0 then begin           // Tiger: step -sd
      if dd[l] > 0 then begin            // deco required at level l
        ds := l * WaterDens;             // get last deco stop level [cm]
        st := dd[l] + SEC_MIN;           // get deco stop time [s] at last level
        gd := st * br * (10 + l);        // gas needed for deco stop [mbar*10]
      end;
    end;
  end;

  gd := gd div 10;                       // deco gas needed [mbar]

// output
//------------------------------------------------------------------------------
  SimDecoDepth := Limit(ds, 0, DEPTHDISP); // deepest deco stop depth [cm] (0..19900)
  SimDecoTime := Limit(st, 0, TIMERANGE);  // deepest deco stop time [s] (0..9:59)
  SimDecoGas := Limit(gd, 0, TANKMAX);     // gas consum for deco stop [mbar] (0..650bar)
  SimNullTime := Limit(nt, 0, TIMERANGE);  // remaining no deco time [s] (0..9:59)
  SimDesatTime := Limit(dt, 0, TIMEDISP);  // desaturation time [s] (0..99:59)
  SimFlightTime := Limit(ft, 0, TIMEDISP); // waiting time to fly [s] (0..99:59)
                                           // 05.06.07 nk old=TIMESHORT
end;

end.
