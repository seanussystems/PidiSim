// Global Symbolic Constants and Functions
// Date 26.05.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

unit Global;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, Math;

type
  Long = Integer; // DELPHI type cast

const
// control codes and special characters

  NAL            = 48;             // ASCII code for number '0'
  ASCII          = 65;             // ASCII code for capital character 'A'
  SMALL          = 97;             // ASCII code for small character 'a'
  LOWER          = 32;             // ASCII diff between upper and lower case

  NUL            = #0;             // ASCII nul
  SOH            = #1;             // start of header
  STX            = #2;             // start of telegram
  ETX            = #3;             // end of telegram
  EOT            = #4;             // end of text
  ENQ            = #5;             // enquiry
  ACK            = #6;             // acknowledge
  BEL            = #7;             // bell
  BS             = #8;             // back space
  TAB            = #9;             // tabulator   21.11.07 nk add TIGER
  EOL            = #10;            // end of line
  LF             = #10;            // line feed
  FF             = #12;            // form feed
  CR             = #13;            // carriage return
  SO             = #14;
  SI             = #15;
  DLE            = #16;
  XON            = #17;
  DC2            = #18;
  XOFF           = #19;
  DC4            = #20;
  NAK            = #21;            // not acknowledge
  SYN            = #22;            // sync
  CAN            = #23;
  ESC            = #27;            // escape

  sEMPTY         = '';             // empty string constant (ASCII code 0)
  sSPACE         = ' ';            // space character (ASCII code 32)
  sCARET         = '#';            // caret character (ASCII code 35)
  sAMPER         = '&';            // ampersand character (ASCII code 38)
  sDASH          = '-';            // dash character (ASCII code 45)
  sNEWDEL        = '|';            // new line delimiter (ASCII code 124)
  sDOT           = '.';            // dot character (ASCII code 46)
  sPROCENT       = '%';            // procent character (ASCII code 37)
  sSLASH         = '/';            // slash character (ASCII code 47)
  sATSIGN        = '@';            // at sign character (ASCII code 64)  05.05.07 nk add
  sCOLON         = ': ';           // colon delimiter                    20.05.07 nk add
  sSPLIT         = ' - ';          // split delimiter
  sDIM           = ' x ';          // dimension delimiter

// system constants

  CHARS          = 26;             // number of alphabetic characters 'A'..'Z'
  NUMBS          = 10;             // number of numeric characters '0'..'9'

  cNUL           = 0;              // use c to prevent DELPHI keyword conflicts
  cPOS           = 1;
  cNEG           = -1;
  cOFF           = 0;
  cON            = 1;
  cNEW           = 2;
  cCLOSE         = 3;
  cRESET         = 4;
  cINIT          = 163;
  cCLEAR         = 0;
  cERROR         = 255;
  cHOLD          = 255;
  cHALF          = 50;
  cFULL          = 100;

  EUR            = 0;
  USA            = 1;
  ISO            = 2;

  BYTELEN        = 8;              // 1 byte = 8 bit
  WORDLEN        = 2;              // 1 word = 2 bytes
  LONGLEN        = 4;              // 1 long = 4 bytes
  REALLEN        = 8;              // 1 real = 8 bytes
  STRINGLEN      = 64;             // default string lenght = 64chars

  HIGHBYTE       = 256;            // high part multiplier for word
  HIGHWORD       = 65536;          // high part multiplier for long

  KILO           = 1024;           // 1kbit = 1024bit
  MEGA           = 1048576;        // 1Mbit = 1024kbit = 1048576bit

  MAXBYTE        = $0FF;           // max value of byte (0..255)
  MAXWORD        = $0FFFF;         // max value of word (0..65'535)
  MAXLONG        = $7FFFFFFF;      // max positive value of long (+/-2'147'483'647)

// time and date constants

  MSEC_SEC       = 1000;           // millisecondes per second
  MSEC_MIN       = 60000;          // millisecondes per minute
  SEC_MIN        = 60;             // seconds per minute
  SEC_HOUR       = 3600;           // seconds per hour
  DEC_HOUR       = 6000;           // seconds per hour in decimal format (99:99)
  SEC_DECA       = 35999;          // seconds per 10 hours (9:59:59)
  SEC_DAY        = 86400;          // seconds per day
  SEC_CENT       = 359999;         // seconds per 100 hours (99:59:59)
  SEC_WEEK       = 604800;         // seconds per week
  SEC_YEAR       = 31536000;       // seconds per year
  SEC_4YEAR      = 126230400;      // seconds per four years
  MIN_HOUR       = 60;             // minutes per hour
  MIN_DAY        = 1440;           // minutes per day
  HOUR_DAY       = 24;             // hours per day
  HOUR_YEAR      = 8760;           // hours per year
  HOUR_LEAP      = 8784;           // hours per leap year
  HOUR_4YEAR     = 35064;          // hours per four years
  DAY_WEEK       = 7;              // days per week
  DAY_MONTH      = 31;             // days per month (01..31)
  DAY_YEAR       = 365;            // days per year
  DAY_4YEAR      = 1461;           // days per four years
  WEEK_YEAR      = 52;             // weeks per year
  MONTH_YEAR     = 12;             // month per year (01..12)
  YEAR_CENT      = 100;            // years per century (00..99)
  NEXT_SUNDAY    = 76;             // sunday in next month (mm+100, dd-24)

// mathematical constants

  E              = 2.71828182846;
  LOG2E          = 1.442695041;
  LOG10E         = 0.4342944819;
  LN2            = 0.69314718056;
  LN10           = 2.302585092994;
  PI             = 3.1415926535898;
  PI_2           = 1.5707963267949;
  PI_4           = 0.7853981634;
  _1_PI          = 0.31831;
  _2_PI           = 0.63662;
  SQRTPI_1       = 0.56419;
  SQRTPI_2       = 1.12838;
  SQRT2          = 1.41421356;
  SQRT_2         = 0.70710687812;

  DEG            = 57.29578;       // radiant -> degree
  RAD            = 0.01745329;     // degree -> radiant

  DDEG           = 10;             // 1ddeg = 1/10°
  CDEG           = 100;            // 1cdeg = 1/100°

  FULLCIRC       = 3600;           // 3600ddeg = 360°
  HALFCIRC       = 1800;           // 1800ddeg = 180°

  MIDCENT        = 50;             // 50%
  PROCENT        = 100;            // 100%
  RESOLUT        = 100;            // 1/100 precise resolution
  MAXPPT         = 1000;           // 1000ppt = 100%
  MAXPPM         = 1000000;        // 1000000ppm = 100%

// physical constants and conversion factors

//symbol           factor         divider  conversion
//----------------------------------------------------------------------
  PSI            = 145;        // 10       bar -> PSI
  INCH           = 394;        // 1000     cm -> inch
  FEET           = 328;        // 100      meter -> feet
  THREEFEET      = 300;        // 100      meter -> feet (1m = 3ft)
  TENFEET        = 3334;       // 1000     meter -> feet (3m = 10ft)
  YARD           = 1094;       // 1000     meter -> yard
  POUND          = 220;        // 100      kg -> pound
  CUFT           = 353;        // 10000    liter -> cubic feet
  CUIN           = 610;        // 10       liter -> cubic inch
  INHG           = 2953;       // 100000   hPa -> inch Hg
  MMHG           = 750;        // 1000     hPa -> mm Hg

  CFACTOR        = 18;         // °C -> °F (factor [mC])
  COFFSET        = 32000;      // °C -> °F (temp offset [mC] = 32°C)
  KELVIN         = 27315;      // °C -> °K (temp offset [cC] = 0°K = -273.15°C)

  DEZI           = 10;         // 1m = 10m
  CENTI          = 100;        // 1m = 100cm
  MILLI          = 1000;       // 1m = 1000mm
  MICRO          = 1000000;    // 1m = 1000000um
  NANO           = 1000000000; // 1m = 1000000000nm

  INCH_FEET      = 12;         // 12 inch = 1 foot

// international standards (ISO/EN/DIN)

  ISOTEMP        = 1500;     // temperature [cC] of standard atmosphere (15.0°C)
  ISOPRESS       = 1013;     // pressure [mbar] of standard atmosphere (1013.25hPa)
  ISOSALT        = 35;       // salinity [ppt] of standard sea water (3.5%)
  ISODENS        = 100;      // pressure/depth relation 100mbar = 1m (EN/DIN)
  ISOSPEED       = 15067;    // sound speed [dm/s] of standard sea water (1506.7m/s)
  ISOSAT         = 750;      // inert gas pressure [mbar] at sea level (750mbar)
  ISOSLOPE       = 0.651;    // temperature slope [cC/m] (0,00651°C/m)

  NORMDENS       = 1019700;  // water density [g/m3] for norm depth calculations
  GRAVITY        = 981;      // earth gravity constant = 9.81m/s2 (DIV 100)

  procedure Pow(var Value: Real; Expo: Real);
  procedure RoundInt(Vin: Real; var Vout: Long);
  procedure InvertBit(var Value: Byte);

implementation

//------------------------------------------------------------------------------
// POW - Return floating point potence Value^Expo
//   If exponent < 1 then base must > 0 else floating point exception
//   DELPHI the same as Power(Base, Expo) but conflict with unit Power
//------------------------------------------------------------------ 17.02.07 --
procedure Pow(var Value: Real; Expo: Real);
begin
  Value := Exp(Expo * Ln(Value));
end;

//------------------------------------------------------------------------------
// ROUNDINT - Round floating point value to next integer
//   1.4 => 1.0, 1.5 => 2.0
//   DELPHI the same as Vout = Round(Vin)
//------------------------------------------------------------------ 17.02.07 --
procedure RoundInt(Vin: Real; var Vout: Long);
var
  vc: Long;
  nc: Real;
begin
  vc := Trunc(Vin);
  nc := Vin - vc;

  if Abs(nc) < 0.5 then begin
    Vout := vc;
  end else begin
    Vout := vc + Sign(Vin);
  end;
end;

//------------------------------------------------------------------------------
// INVERTBIT - Invert given logic value (ON->OFF, OFF->ON)
//------------------------------------------------------------------ 17.02.07 --
procedure InvertBit(var Value: Byte);
begin
  if Value > cOFF then begin
    Value := cOFF;
  end else begin
    Value := cON;
  end;
end;

end.
