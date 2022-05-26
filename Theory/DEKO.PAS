(*------------------------------------------------------------------*)
(* Berechnung von Dekompressionsdaten fÅr TauchgÑnge mit Pressluft  *)
(*                            und Nitrox                            *)
(*                                                                  *)
(*                       (C) 1999 by Peter Rachow                   *)
(*------------------------------------------------------------------*)
Program DecoSim;

Uses Crt, Dos;

Const
  e = 2.71820469;
  kx = -1.629315; (*nach BÅhlmann: -0.69315, erzeugt zu kurze Zeiten!!!*)

Var
 a,b:    Array [1..16] Of Real;
 tchalf: Array [1..16] Of Real;
 pig_te: Array [1..16] Of Real;
 deko:   Array [1..100] Of Word;

 dt_sta:  Array [1..30] Of Word;
 dt_end:  Array [1..30] Of Word;
 dt_step: Array [1..30] Of Word;

 dive_depth  : Word;
 dive_time   : Word;
 air_pressure: Word;
 fig         : Word;

 amv         : Word;
 t1          : Word;

 ch          :Char;
  k          :Real;

(* Wasserdruck in gegebener Tiefe berechnen *)
(*-------------------------------------------*)
Function GetWaterPr(f_depth: Real): Real;
Begin
  GetWaterPr := (f_depth / 10) + (air_pressure / 1000);
End;


(*GewebepartialdrÅcke fÅr Inertgas ausrechnen*)
(*-------------------------------------------*)
Procedure CalcPIOnTime(depth: Real; tE: Real);
Var
  piig: Real;
  t1:   Integer;
  exponent: Real;
Begin
  (*Inertgaspartialdruck fÅr alle 16 Kompartimente berechnen*)

  (*Konstante abhÑngig von Tiefe definieren*)
  k := 3;

  If depth <= 15 Then
    k := 2.7;
  If depth <= 12 Then
    k := 2.6;
  If depth <= 9 Then
    k := 2.5;
  If depth <= 6 Then
    k := 2.2;
  If depth <= 3 Then
    k := 1.6;

  For T1 := 1 To 16 Do
  Begin

    (*Inspiratorischer Inertgasdruck in den Lungenalveolen*)
    piig := (GetWaterPr(depth) - 0.063) * fig / 100;

    (*Inertgasdruck im Kompartiment (mit spec. t1/2) nach geg. Expositionszeit*)
    exponent := k * -1 * tE / tchalf[T1] * ln(e);
    pig_te[T1] := pig_te[T1] + (piig - pig_te[T1]) * (1 - exp(exponent));

  End;
End;

Function GetDecoStep(Metr: Real): Integer;
(*--------------------------------------*)
Var
  T1: Integer;
Begin
  For T1 := 1 To 99 Do
    If (deko[T1] < Metr) And (deko[T1 + 1] >= Metr) Then
    Begin
      GetDecoStep := T1 + 1;
      Exit;
    End;

  GetDecoStep := 1

End;


Function LSpace(s: string; max_len: Integer): String;
(*-------------------------------------------------*)
Var

 t1: Integer;
 s2: String;

Begin

  s2 := '';

  For t1 := 1 To max_len - Length(s) Do
    s2 := ConCat(s2, ' ');

  LSpace := ConCat(s2, s);

End;


(* Berechnen des Umgebungsdruckes, bei dem gerade noch keine *)
(* Gasblasen auftreten (abhÑngig von der bisher erfolgten    *)
(* AufsÑttigung der Gwebe mit N2                             *)
(*-----------------------------------------------------------*)
Function GetTolAmbPress: Real;

Var
  t1:             Integer;
  pambtol, max_p: Real;
Begin
  max_p := 0;

  For t1 := 1 To 16 Do
  Begin
    pambtol := (pig_te[T1] - a[T1]) * b[T1];
    If pambtol > max_p Then
      max_p := pambtol;
  End;

  GetTolAmbPress := max_p;

End;

(*    Dekoberechnung fÅr Rechtecktauchgang   *)
(*-------------------------------------------*)
Procedure CalcDive;

Var

  p_next, p_max, dek1, pambtol:  Real;
  t1, t2, t_elaps, t_last:       Word;
  cur_deco_depth, cur_deco_step: Word;
  p:                             String;
  t_decotime, t_asctime:         Real;
  air:                           Real;
  no_deco:                       Word;

Begin

  (*Arrays initialisieren*)
  For t1 := 1 To 16 Do
    pig_te[T1] := fig / 100;

  no_deco := 1;

  Writeln('++  Dekoberechnung fÅr Tauchgang mit Rechteckprofil  ++');
  Writeln('------------------------------------------------------');
  Writeln;
  Writeln('Stickstoffanteil im Atemgas (in%):', fig);
  Writeln('Luftdruck am Tauchort [mbar]: ', air_pressure);
  Writeln('Tauchtiefe [m]: ', dive_depth);
  Writeln('Tauchzeit [min]: ', dive_time);
  Writeln('--------------------------------------------------------');
  Writeln;

  (*-- ABTAUCHPHASE ----------------------------------*)
  (* Berechnung nach BÅhlmann (nichtintegrierend      *)
  For t1 := 0 To dive_depth Do
    CalcPIOnTime(t1, 0.1);

  (*-- GRUNDZEIT -------------------------------------*)
  For t1 := 1 To dive_time Do
    CalcPIOnTime(dive_depth, 1);

  (*--- Aufstiegsphase (y=10m/min.) ------------------*)
  t_asctime := 0;

  t1 := dive_depth;

  Repeat
    CalcPIOnTime(t1, 0.1);

    t_asctime := t_asctime + 0.1;

    If GetTolAmbPress >= GetWaterPr(t1) Then
    Begin
      textcolor(LightRed);
      Writeln('DECO! DECO! DECO! DECO! DECO! DECO! DECO! DECO! ');
      textcolor(CYAN);
      cur_deco_step := GetDecoStep(t1);
      cur_deco_depth := deko[cur_deco_step];
      Writeln('1. Deko-Stopp auf:  ', cur_deco_depth, ' m');
      Writeln('Aufstiegszeit zu dieser Stufe ', t_asctime:2:1, ' min.');
      no_deco := 0;
      t1 := 0;
    End
    Else
      t1 := t1 - 1;

  Until  (t1 <= 0);
  (*--- Ende Aufstiegsphase ----------------------------*)

  If no_deco = 1 Then
  Begin
    TextColor(LIGHTGREEN);
    Writeln('Keine Deko erforderlich!');
    Exit;
  End;

  TextColor(WHITE);
  WriteLn('------- Dekompressionsphase --------');
  TextColor(YELLOW);


  (*Erwarteter Druck auf nÑchster Deko-Stufe*)
  p_next := GetWaterPr(deko[cur_deco_step]);
  p_max := 0;
  t_elaps := 0;
  t_decotime := 0;
  air := 0;

  (*Gesamt-Deko berechnen*)

  WriteLn('Deko-Stopps');
  TextColor(LIGHTBLUE);
  While True Do
  Begin
    t_elaps := t_elaps + 1; (*iterativ im Minutentakt berechnen*)

    For t1 := 1 to 10 Do
      CalcPIOnTime(deko[cur_deco_step], 0.1);
    p_max := GetTolAmbPress;

    If p_max <= p_next Then (*Aufsteigen zur nÑchsthîheren Deko-Stufe*)
    Begin

      (* ZwischenentsÑttigung wÑhrend Aufsteigens zur nÑchsten Deko-Stufe *)
      (* berechnen v=10m/min.                                             *)
      For t1 := Round(deko[cur_deco_step]) DownTo Round(deko[cur_deco_step - 1]) Do
        CalcPIOnTime(t1, 0.1);

      air := air + amv * GetWaterPr(deko[cur_deco_step]);

      WriteLn(t_elaps, ' min. auf ' ,deko[cur_deco_step], ' m');

      t_decotime := t_decotime + t_elaps;
      t_elaps := 0;
      cur_deco_step := cur_deco_step - 1;

      If (cur_deco_step < 1) Or (cur_deco_step > 99) Then
      Begin
        TextColor(WHITE);
        WriteLn('--- Ende der Dekompressionsphase ---');
        WriteLn('Gesamte Deko-Zeit: ', t_decotime:5:1, ' min. ');
        WriteLn('Gesamte Luftmenge fÅr Deko-Phase: ', air:5:1, ' ltr.');
        Exit;
      End;

      p_next := GetWaterPr(deko[cur_deco_step]);

    End;

  End;
  TextColor(YELLOW);
End;

Procedure CalcTable;

Var

  p_next, p_max, dek1, pambtol:  Real;
  t1, t2, t_elaps, t_last:       Word;
  cur_deco_depth, cur_deco_step: Word;
  p:                             String;
  air:                           Real;
  no_deco:                       Word;
  dd, dt:                        Word;
  a_dstep, a_dtime:              Array [1..20] Of Word;
  s:                             String;
  ch:                            Char;
  f:                             Text;

Begin

  Assign(f, 'DEKO.TXT');
  Rewrite(f);

  WriteLn('Erstelle Deko-Tabelle...');
  WriteLn('ESC drÅcken um abzubrechen.');

  Writeln(f, '++  Dekoberechnung fÅr Tauchgang mit Rechteckprofil  ++');
  Writeln(f, '------------------------------------------------------');
  Writeln(f, '');
  Writeln(f, 'Stickstoffanteil im Atemgas (in%):', fig);
  Writeln(f, 'Luftdruck am Tauchort [mbar]: ', air_pressure);
  Writeln(f, '--------------------------------------------------------');
  Writeln(f, '');

  For t1 := 1 To 20 Do
    a_dstep[t1] := t1 * 3;

  dd := 9;
  Repeat
    dt := dt_sta[Trunc(dd /3)];
      For t1 := 1 To 10 Do
        a_dtime[t1] := 0;

    Write(f, LSpace('Tiefe:', 6));
    Str(dd, s);
    s := ConCat(s, 'm');
    Write(f, LSpace(s, 6));

    WriteLn(f, '');
    Write('Berechne Dekozeiten fÅr Tauchtiefe: ', dd, ' Meter...  ');

    s := 'GZeit';
    Write(f, LSpace(s, 6));

    For t1 := 10 DownTo 1 Do
    Begin
      Str(a_dstep[t1], s);
      s := ConCat(s, 'm');
      Write(f, LSpace(s, 6));
    End;
    WriteLn(f, '');

    Repeat
      (*Arrays initialisieren*)
      For t1 := 1 To 16 Do
        pig_te[T1] := fig / 100;

      no_deco := 1;


      (*-- ABTAUCHPHASE ----------------------------------*)
      For t1 := 0 To dd Do
        CalcPIOnTime(t1, 0.1);

      (*-- GRUNDZEIT -------------------------------------*)
      (*Kompartimente errechnen fÅr Grundzeit            *)
      For t1 := 1 to dt do
        CalcPIOnTime(dd, 1);

      (*--- Aufstiegsphase (v=10m/min.) ------------------*)
      t1 := dd;

      Repeat
        CalcPIOnTime(t1, 0.1);

        If GetTolAmbPress >= GetWaterPr(t1) Then
        Begin
          cur_deco_step := GetDecoStep(t1);
          cur_deco_depth := deko[cur_deco_step];
          no_deco := 0;
          t1 := 0;
        End
        Else
          t1 := t1 - 1;
      Until  t1 <= 0;
      (*--- Ende Aufstiegsphase ----------------------------*)

      (*Erwarteter Druck auf nÑchster Deko-Stufe*)
      p_next := GetWaterPr(deko[cur_deco_step]);
      p_max := 0;
      t_elaps := 0;
      air := 0;

      (*Gesamt-Deko berechnen*)

      While no_deco = 0 Do
      Begin
        t_elaps := t_elaps + 1; (*iterativ im Minutentakt berechnen*)

        CalcPIOnTime(deko[cur_deco_step], 1);
        p_max := GetTolAmbPress;

        If p_max <= p_next Then (*Aufsteigen zur nÑchsthîheren Deko-Stufe*)
        Begin

          (* ZwischenentsÑttigung wÑhrend Aufsteigens zur nÑchsten Deko-Stufe *)
          (* berechnen v=10m/min.                                             *)
          For t1 := Round(deko[cur_deco_step]) DownTo Round(deko[cur_deco_step - 1]) Do
            CalcPIOnTime(t1, 0.1);

          air := air + amv * GetWaterPr(deko[cur_deco_step]);

          a_dtime[cur_deco_Step] := t_elaps;
          t_elaps := 0;
          cur_deco_step := cur_deco_step - 1;

          If cur_deco_step < 1 Then
            no_deco := 1;

          p_next := GetWaterPr(deko[cur_deco_step]);
        End;
      End;

      dt := dt + dt_step[Trunc(dd / 3)];

      Str(dt, s);
      Write(f, LSpace(s, 6));

      For t1 := 10 DownTo 1 Do
      Begin
        Str(a_dtime[t1], s);
        Write(f, LSpace(s, 6));
      End;

      WriteLn(f, '');

      If KeyPressed Then
      Begin
        ch := Readkey;
        If Ord(ch) = 27 Then
        Begin
          Close(f);
          Exit;
        end;
      End;

    Until dt >= dt_end[Trunc(dd / 3)];

    WriteLn(' OK');

    dd := dd + 3;

    WriteLn(f, '');

  Until dd >= 81;
  Close(f);

  WriteLn;
  WriteLn('Beendet. Deko-Tabelle wurde gespeichert als DEKO.TXT');

End;


Begin

  fig := 78;
  amv := 18;
  air_pressure := 1015;

  For t1 := 1 To 16 Do
    pig_te[t1] := fig / 100;

  For t1 := 1 To 100 Do
    deko[t1] := t1 * 3;


  a[1]  := 2.2;   b[1]  := 0.82;  tchalf[1]  := 2.65;
  a[2]  := 1.5;   b[2]  := 0.82;  tchalf[2]  := 7.95;
  a[3]  := 1.08;  b[3]  := 0.825; tchalf[3]  := 12.2;
  a[4]  := 0.9;   b[4]  := 0.835; tchalf[4]  := 18.5;
  a[5]  := 0.75;  b[5]  := 0.845; tchalf[5]  := 26.5;
  a[6]  := 0.58;  b[6]  := 0.86;  tchalf[6]  := 37;
  a[7]  := 0.47;  b[7]  := 0.87;  tchalf[7]  := 53;
  a[8]  := 0.455; b[8]  := 0.89;  tchalf[8]  := 79;
  a[9]  := 0.455; b[9]  := 0.89;  tchalf[9]  := 114;
  a[10] := 0.455; b[10] := 0.934; tchalf[10] := 146;
  a[11] := 0.455; b[11] := 0.934; tchalf[11] := 185;
  a[12] := 0.38; b[12]  := 0.944; tchalf[12] := 238;
  a[13] := 0.255; b[13] := 0.962; tchalf[13] := 304;
  a[14] := 0.255; b[14] := 0.962; tchalf[14] := 397;
  a[15] := 0.255; b[15] := 0.962; tchalf[15] := 503;
  a[16] := 0.255; b[16] := 0.962; tchalf[16] := 635;

  dt_sta[1]  := 0;  dt_end[1]  := 0;   dt_step[1]  := 0; (*3m
  dt_sta[2]  := 0;  dt_end[2]  := 0;   dt_step[2]  := 0; (* 6m  *)
  dt_sta[3]  := 20; dt_end[3]  := 130; dt_step[3]  := 5; (* 9m  *)
  dt_sta[4]  := 15; dt_end[4]  := 130; dt_step[4]  := 5; (* 12m *)
  dt_sta[5]  := 15; dt_end[5]  := 130; dt_step[5]  := 5; (* 15m *)
  dt_sta[6]  := 10; dt_end[6]  := 130; dt_step[6]  := 5; (* 18m *)
  dt_sta[7]  := 8;  dt_end[7]  := 130; dt_step[7]  := 4; (* 21m *)
  dt_sta[8]  := 8;  dt_end[8]  := 130; dt_step[8]  := 4; (* 24m *)
  dt_sta[9]  := 4;  dt_end[9]  := 130; dt_step[9]  := 4; (* 27m *)
  dt_sta[10] := 4;  dt_end[10] := 120; dt_step[10] := 4; (* 30m *)
  dt_sta[11] := 4;  dt_end[11] := 120; dt_step[11] := 4; (* 33m *)
  dt_sta[12] := 4;  dt_end[12] := 120; dt_step[12] := 4; (* 36m *)
  dt_sta[13] := 4;  dt_end[13] := 120; dt_step[13] := 2; (* 39m *)
  dt_sta[14] := 4;  dt_end[14] := 80;  dt_step[14] := 2; (* 42m *)
  dt_sta[15] := 4;  dt_end[15] := 80;  dt_step[15] := 2; (* 45m *)
  dt_sta[16] := 4;  dt_end[16] := 80;  dt_step[16] := 2; (* 48m *)
  dt_sta[17] := 2;  dt_end[17] := 60;  dt_step[17] := 2; (* 51m *)
  dt_sta[18] := 2;  dt_end[18] := 50;  dt_step[18] := 2; (* 54m *)
  dt_sta[19] := 2;  dt_end[19] := 50;  dt_step[19] := 2; (* 57m *)
  dt_sta[20] := 2;  dt_end[20] := 50;  dt_step[20] := 2; (* 60m *)
  dt_sta[21] := 2;  dt_end[21] := 50;  dt_step[21] := 2; (* 63m *)
  dt_sta[22] := 2;  dt_end[22] := 40;  dt_step[22] := 2; (* 66m *)
  dt_sta[23] := 2;  dt_end[23] := 40;  dt_step[23] := 1; (* 69m *)
  dt_sta[24] := 2;  dt_end[24] := 30;  dt_step[24] := 1; (* 72m *)
  dt_sta[25] := 2;  dt_end[25] := 30;  dt_step[25] := 1; (* 75m *)
  dt_sta[26] := 1;  dt_end[26] := 20;  dt_step[26] := 1; (* 78m *)
  dt_sta[27] := 1;  dt_end[27] := 10;  dt_step[27] := 1; (* 81m *)

  k := -1.629;
  ClrScr;
  TextColor(CYAN);
  WriteLn('Dekompressionsberechnung (C) 1999 Peter Rachow');
  WriteLn('Version vom 24.02.99');
  WriteLn;
  TextColor(LIGHTBLUE);
  WriteLn('WÑhlen Sie die Programmfunktion.');
  TextColor(LIGHTGREEN);
  WriteLn('   Einzelnen (T)auchgang berechnen.');
  WriteLn('   (D)eko-Tabelle als Datei erstellen.');
  WriteLn('   Andere Taste: ENDE.');
  ch := UpCase(ReadKey);
  Case ch Of
    'T': Begin
           TextColor(YELLOW);

           WriteLn('Tauchtiefe? [m]');
           ReadLn(dive_depth);

           WriteLn('Grundzeit? [min.]');
           ReadLn(dive_time);

           WriteLn('Stickstoffanteil am Atemgasgemisch? [%]');
           ReadLn(fig);

           WriteLn('Umgebungsluftdruck? [mbar]');
           ReadLn(air_pressure);

           WriteLn('Atemminutenvolumen des Tauchers? [bar*l/min.]');
           ReadLn(amv);

           ClrScr;

           CalcDive;
         End;
    'D': Begin
           TextColor(YELLOW);

           WriteLn('Stickstoffanteil am Atemgasgemisch? [%]');
           ReadLn(fig);

           WriteLn('Umgebungsluftdruck? [mbar]');
           ReadLn(air_pressure);

           TextColor(CYAN);
           WriteLn('Beginne...');
           CalcTable;
         End;
  End;
  Ch := ReadKey;

end.