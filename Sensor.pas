// Sensor Module Functions and Declarations
// Date 26.05.22

// DELPHI simulate the DSM Sensor Module with Salinity, Pressure,
// and Temperature Sensor with the Daq Control Panel

// Limits: Delphi sensor pressure = 80% of 20bar = 16bar = 160m

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit Sensor;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, USystem, SYS, Global, Data,
  Texts, FLog, UPidi;

  procedure InitSensor;
  procedure ResetSensor;
  procedure ReadPressure(var AmbPress, AmbTemp, ScanTime: Long);
  procedure ReadSalinity(var WaterSalt: Word; var WaterFlag: Byte);
  
const
  SENSPRESSMIN   = 300;    // min sensor pressure [mbar] = 300mbar
  SENSPRESSMAX   = 20000;  // max sensor pressure [mbar] = 20bar
  SENSTEMPMIN    = -4000;  // min sensor temperature [cdeg] = -40°C
  SENSTEMPMAX    = 6000;   // max sensor temperature [cdeg] = 60°C
  SENSALTMIN     = 10;     // min sensor salinity [ppt] = 1%
  SENSALTMAX     = 40;     // max sensor salinity [ppt] = 4%

  SENSREADDEL    = 5;      // sensor module read delay time [ms]
  SENSRESETDEL   = 100;    // pressure sensor reset delay time [ms]
  SENSCONVERT    = 40;     // pressure sensor conversion time [ms]
  SENSSETDEL     = 10;     // salinity sensor settling time [ms]
  SENSREADMODE   = -2;     // spi read mode = 2 bytes MSB first

  SENSCALW1      = '<1Dh><50h>';
  SENSCALW2      = '<1Dh><60h>';
  SENSCALW3      = '<1Dh><90h>';
  SENSCALW4      = '<1Dh><A0h>';
  SENSDATA1      = '<1Eh><80h>';
  SENSDATA2      = '<1Eh><40h>';
  SENSREAD       = '<00h><00h>';
  SENSRESET      = '<15h><55h><40h>';

  PRESSUNIT      = ' mbar';  // pressure standard unit
  SALTUNIT       = ' %';     // salinity standard unit
  TEMPUNIT       = ' °C';    // temperature standard unit
  SALTFORM       = '%1.1f';  // salinity format 3.4%
  TEMPFORM       = '%2.2f';  // temperature format -12.34 C

var // module variables
  SensErr: Byte;             // sensor module error flag
  C1, C2, C3: Long;          // pressure sensor compensation coefficients
  C4, C5, C6: Long;
  SensBuff: string;          // modul message buffer / old=[MAXBUFF]

implementation

uses FMain, FDaq;

//------------------------------------------------------------------------------
// INITSENSOR - Initialize Pressure, Temperature, and Salinity Sensors and read
//   factory calibration words to build compensation coefficients (Tiger only)
//------------------------------------------------------------------ 17.02.07 --
procedure InitSensor;
var
  temp, press: Long;
begin
  SystemTicks := cCLEAR;
  AmbPress := ISOPRESS;
  AmbTemp := ISOTEMP;
  WaterSalt := cCLEAR;
   
  temp := KELVIN;
  press := cOFF;

  // Intersema test coefficients
  C1 := 2636;
  C2 := 5419;
  C3 := 404;
  C4 := 226;
  C5 := 1865;
  C6 := 58;

  ResetSensor;

  if Daq.tbPressure.Position <> cOFF then begin
    SensBuff := IntToStr(Daq.tbPressure.Position);
    LogError('InitSensor', 'Pressure sensor not responding', SensBuff, $9A);
    Exit;
  end;

  ReadPressure(press, temp, ScanTime);

  if temp = KELVIN then begin
    LogError('InitSensor', 'Temperature sensor not initialized', sEMPTY, $9A);
  end else begin
    AmbTemp := temp;
    SensBuff := Format(TEMPFORM, [AmbTemp / CDEG]) + TEMPUNIT;
    LogEvent('InitSensor', 'Temperature sensor initialized at', SensBuff);
  end;
  
  if press = cOFF then begin
    LogError('InitSensor', 'Pressure sensor not initialized', sEMPTY, $9A);
  end else begin
    AmbPress := press;
    SensBuff := IntToStr(AmbPress) + PRESSUNIT;
    LogEvent('InitSensor', 'Pressure sensor initialized at', SensBuff);
  end;

  ReadSalinity(WaterSalt, WaterFlag);

  SensBuff := Format(SALTFORM, [WaterSalt / DEZI]) + SALTUNIT;
  LogEvent('InitSensor', 'Salinity sensor initialized at', SensBuff);
end;

//------------------------------------------------------------------------------
// RESETSENSOR - Reset Pressure and Temperature Sensor and set SPI idle state
//------------------------------------------------------------------ 17.02.07 --
procedure ResetSensor;
begin
  Daq.tbPressure.Position := cCLEAR;  // reset pressure sensor
  WaitDuration(SENSRESETDEL);
end;

//------------------------------------------------------------------------------
// READPRESSURE - Get ambient pressure [mbar], ambient temperature [cdeg] and
//   scan time [ms] from Pressure and Temperature Sensor
//   ScanTime is the number of milliseconds passed since the last reading
//------------------------------------------------------------------ 17.02.07 --
procedure ReadPressure(var AmbPress, AmbTemp, ScanTime: Long);
var
  last, press, temp: Long;
begin
  last := SystemTicks;  // last system ticks [ms]

  SystemTicks := Ticks;

  if SystemTicks > last then begin
    ScanTime := SystemTicks - last;  // get scan repetition time [ms]
  end else begin
    ScanTime := DAQDELAY;            // counter overrun - reset counter
  end;

  ScanTime := ScanMulti * ScanTime; // fasten up scan time for simulation
  ScanPress := ScanPress - ScanTime * Daq.tbPressure.Position;  // [ubar]

  if ScanPress <= 0 then begin  // diver has emerged
    ScanPress := cCLEAR;
    ResetSensor;
  end;

  if ScanPress > (800 * SENSPRESSMAX) then begin  // diver has 'grounded'
    ScanPress := (800 * SENSPRESSMAX);  // 80% of 20bar=16bar=160m
    ResetSensor;
  end;

  if WaterFlag = cON then begin  // immersed
    temp := Daq.seWaterTemp.IntValue - Round(ScanPress / TempGrad);
    temp := Limit(temp, WATERTEMPMIN, WATERTEMPMAX);  // [cdeg]
  end else begin  // DELPHI get air pressure [mbar] from altitude [m]
    temp := Daq.seAirTemp.IntValue;
    last := Daq.seAltitude.IntValue; // altitude above sea level [m]
    Daq.CalcAirPress(last, temp, AirPress);
  end;

  press := AirPress + Round(ScanPress / MILLI);         // [mbar]
  AmbTemp := Limit(temp, SENSTEMPMIN, SENSTEMPMAX);     // [cdeg]
  AmbPress := Limit(press, SENSPRESSMIN, SENSPRESSMAX); // [mbar]
end;

//------------------------------------------------------------------------------
// READSALINITY - Get adc counts [cts] from Salinity Sensor output voltage
//   and calculate the water salinity [ppt] and generate the water flag
//------------------------------------------------------------------ 17.02.07 --
procedure ReadSalinity(var WaterSalt: Word; var WaterFlag: Byte);
var
  salt: Long;
begin
  WaitDuration(SENSSETDEL);  // wait until signal is stable

  with Daq do begin // DELPHI only
    if (PlanFlag = cON) or (DiveDepth > 1) then begin
      if rbSaltWater.Checked  then begin
        salt := ISOSALT;    // salt water (sea)
      end else begin
        salt := SENSALTMIN; // fresh water (lake)
      end;
    end else begin
      salt := cCLEAR;       // not immersed
    end;
  end;

  WaterSalt := Limit(salt, 0, SENSALTMAX);  // [ppt]

  if WaterSalt >= SENSALTMIN then begin
    WaterFlag := cON;
  end else begin
    WaterFlag := cOFF;
  end;
end;

end.
