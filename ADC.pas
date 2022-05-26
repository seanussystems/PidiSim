// Interface to ADC Device Driver (Analog/Digital Converter)
// Date 26.07.17
// Norbert Koechli
// Copyright ©2007-2017 seanus systems

// DELPHI no A/D converter implemented
//        Read power status if the PC is a battery supplied laptop
//        or simulates accu power decrease if not

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit ADC;

interface

uses
  Windows, Forms, Types, Controls, Math, SysUtils, ExtCtrls,
  USystem, SYS, Global, Data, FLog;

const
  ADCPORT         = 5;      // ADC port
  ADCNUM          = 4;      // ADC channel number
  ADCCH0          = 0;      // ADC channel 0..3
  ADCCH1          = 1;
  ADCCH2          = 2;
  ADCCH3          = 3;
  ADCERR          = -1;     // ADC error value
  ADCDELAY        = 5;      // ADC read delay [ms]
  ADCAVG          = 4;      // ADC averaging
  ADCSPREAD       = 10;     // ADC spreading [cts]
  ADCBYTES        = 2;      // ADC value size (2bytes=1word)
  ADCRES          = 10;     // ADC resolution (10bit)
  ADCCOUNTS       = 1024;   // ADC counts [cts] (10bit)
  ADCREFVOLT      = 5000;   // ADC reference voltage [mV]
  ADCBITVOLT      = 4883;   // ADC bit resolution voltage [uV]

  ADCUNIT         = ' bit'; // ADC standard unit
  PWRUNIT         = ' %';   // remain accu power unit

var // module variables
  AdcMains: Boolean;        // 05.06.07 nk add DELPHI ON=mains, OFF=accu power supply
  AdcInit: Byte;            // init flag of ADC converter
  AdcTime: Long;            // 05.06.07 nk add DELPHI simulated battery life time
  AdcBuff: string;          // modul message buffer / old=[MAXTEMP]

  // Tiger interface to ADC device driver (ADC.INC)
  procedure InitAdc;
  procedure ReadAdc(Channel: Byte; var Counts: Long);
  function SimAdc: Long;    // 05.06.07 nk add DELPHI
  
implementation

uses FMain, FGui, FDaq;

//------------------------------------------------------------------------------
// INITADC - Initialize a/d converter and check conversion of each channel
//   DELPHI no A/D converter implemented
//------------------------------------------------------------------ 17.02.07 --
procedure InitAdc;
var
  ch, adok: Byte;
  value: Long;
begin
  Randomize;

  adok := cOFF;
  AdcInit := cOFF;
  ErrCode := cOFF;

  for ch := 0 to ADCNUM - 1 do begin
    value := cCLEAR;  // no A/D converter implemented in DELPHI

    if (value > ADCERR) and (value < ADCCOUNTS) then begin
      adok := adok + 1;
    end;

    WaitDuration(ADCDELAY);
  end;

  AdcBuff := IntToStr(adok);

  if adok <> ADCNUM then begin  // ADC conversion error
    LogError('InitAdc', 'ADC conversion check failed - return', AdcBuff, $9A);
    Exit;
  end;

  AdcInit := cINIT;
  AdcBuff := AdcBuff + sDIM + IntToStr(ADCRES) + ADCUNIT;

  LogEvent('InitAdc', 'ADC channels initialized', AdcBuff);

  // 05.06.07 nk add DELPHI ff
  if GetPowerStatus(value) then begin // mains powered
    AdcMains := True;
    LogEvent('InitAdc', 'Mains power supply detected', sEMPTY);
  end else begin                      // accu powered
    AdcMains := False;
    AdcBuff := IntToStr(value) + PWRUNIT;
    LogEvent('InitAdc', 'Accu power supply detected at', AdcBuff);
  end;
end;

//------------------------------------------------------------------------------
// READADC - Read A/D converter channel and build average value [cts]
//   DELPHI no A/D converter implemented
//------------------------------------------------------------------------------
// Input:   Channel - ADC channel and buffer number (0..3)
// Output:  Counts - analog value from ADC channel (0..1023cts)
//------------------------------------------------------------------ 26.07.17 --
procedure ReadAdc(Channel: Byte; var Counts: Long);
var
  aderr: Byte;
  lctr: Word;
  value, vmin, vmax: Long;
begin
  aderr   := cOFF;
  Counts  := cCLEAR;
  AdcBuff := IntToStr(Channel);
  
  if AdcInit <> cINIT then begin
    LogError('ReadAdc', 'ADC not initialized', sEMPTY, $96);
    Exit;
  end;

  if Channel >= ADCNUM then begin
    LogError('ReadAdc', 'Unsupported ADC channel', AdcBuff, $90);
    Exit;
  end;

  vmin := ADCCOUNTS;
  vmax := ADCERR;

  for lctr := 1 to ADCAVG do begin
    if Channel = ADCACCU then begin // 05.06.07 nk opt ff
      value := SimAdc;              // get simulated accu voltage [cts]
    end else begin                  // no A/D converter implemented in DELPHI - take random value for test
      value := RandomRange(500, 510);
    end;

    if (value <= ADCERR) or (value > ADCCOUNTS) then begin
      aderr := cON;
    end;

    Counts := Counts + value;

    if value < vmin then begin
      vmin := value;
    end;

    if value > vmax then begin
      vmax := value;
    end;

    WaitDuration(ADCDELAY);
  end;

  if (Abs(vmax - vmin) > ADCSPREAD) then begin // check value spreading
    aderr := cON;
  end;
  
  if aderr = cOFF then begin
    Counts := Counts div ADCAVG;  // do averaging
  end else begin
    Counts := ADCERR;
    LogError('ReadAdc', 'Invalid ADC value on channel', AdcBuff, $99);
  end;

//if Channel = ADCACCU then //nk//
//  Log.Print('RunTime: ' + IntToStr(RunTime) + ' - CTS: ' + IntToStr(Counts));
end;

//------------------------------------------------------------------------------
// SIMADC - DELPHI simulate accu power decrease and return ADC counts
//------------------------------------------------------------------ 26.07.17 --
function SimAdc: Long;
var
  rem: Long;
  val: Real;
begin
  val := 1.0;
  rem := cCLEAR;

  if AdcMains then begin                          // mains powered
    AdcTime := (ACCUMAX - ACCUMIN) div AccuRate;  // simulated accu
    AdcTime := ACCUGRADE * AdcTime;               // 26.07.17 nk old=MICRO
    if AdcTime > 0 then                           // get simulated accu power
      val := val - RunTime / AdcTime;             // [ms]
    rem := Round(MAXPPT * val);                   // [ppt]
  end else begin                                  // accu powered
    GetPowerStatus(rem);                          // get remain accu power [%]
    rem := rem * 10;                              // [ppt]
  end;

  // convert accu power [ppt] into ADC counts
  rem    := Limit(rem, 0, MAXPPT);
  val    := rem * (ACCUMAX - ACCUMIN) / ADCBITVOLT;
  val    := val / 2.0;
  val    := val + 500.0 * (ACCUMIN / ADCBITVOLT);
  Result := Round(val + 0.5);
end;

initialization // Tiger hardware configuration
  AdcInit  := cOFF;
  AdcBuff  := sEMPTY;
  AdcMains := True;
  AccuRate := 10;                                // 05.06.07 nk add DELPHI ff
  AdcTime  := (ACCUMAX - ACCUMIN) div AccuRate;  // simulated accu
  AdcTime  := ACCUGRADE * AdcTime;               // life time [ms] / 26.07.17 nk old=MICRO

finalization
  AdcInit := cOFF;
  AdcBuff := sEMPTY;

end.
