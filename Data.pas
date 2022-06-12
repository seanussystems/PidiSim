// Application Specific Data Declarations and Definitions
// Date 28.05.22
// Norbert Koechli
// Copyright ©2005-2022 seanus systems

// Limits: Delphi sensor pressure = 80% of 20bar = 16bar = 160m (Sensor.pas)

unit Data;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, Forms, Math, Global;

  procedure InitGlobalData;
  procedure InitApplication;
  procedure SetGlobalData;
  procedure AddGlobalPar(Par: Word);
  procedure GetSigNum(Sig: Word; var Num: Long);
  procedure FormatValue(Dtype: Byte; Ival: Word; var Oval: string);
  procedure ConvertValue(var Vact: Long; var Prec: Byte; Tuni: Byte);
  procedure CompressTime(Itime: Long; var Otime: Word);
  procedure ExpandTime(Itime: Word; var Otime: Long);

const
  DEVSTATUS       = 4;        // development status (2=P2/P2A, 3=P3/P3A/P3B, 4=P4)
  MAINCODE        = 'seanus'; // security code for debugging

// task control and timing
//========================
  DAQDELAY        = 250;      // loop delay for data acquisition [ms]
  LOWLOOP         = 39;       // number of loops for low priority actions (39x250ms)
  MEDLOOP         = 17;       // number of loops for medium priority actions (17x250ms)
  HIGLOOP         = 11;       // number of loops for high priority actions (11x250ms)
  ANYLOOP         = 1;        // number of loops for highest priority (every loop)
  GUIDELAY        = 70;       // loop delay for user interface [ms]
  GUISPEEDUP      = 4;        // loop delay speed up for DELPHI only (70/4=17ms)
  KEYDELAY        = 250;      // key disable time for menu opening [ms]
  DISPLOOP        = 10;       // number of loops for display refresh (10x70ms)
  HEADLOOP        = 5;        // number of loops for compass refresh (5x70ms)
  KEYLOOP         = 50;       // number of loops for key acceptance (50x70ms)
  TONELOOP        = 15;       // number of loops for tone repetition (15x70ms)
  EXITLOOP        = 600;      // number of loops for timeout exit (600x70ms=42s)
  TASKDELAY       = 2000;     // delay time for task starting (2000ms)
  INITDELAY       = 5000;     // delay time for initial phase (5000ms)
  DISPDELAY       = 3000;     // delay time for display messages (3000ms)
  MAXLOOP         = 1000;     // reset value for loop counter
  ALARMDELAY      = 10;       // max alarm life time = 10min
  COMDELAY        = 50;       // loop delay for serial communication [ms]

  MAXTASK         = 5;        // max number of running tasks
  TASKRUN         = 0;        // runtime system
  TASKDAQ         = 1;        // data acquisition
  TASKGUI         = 2;        // user interface
  TASKCOM         = 3;        // host communication

  PRIORUN         = 20;       // task priorities (1=low .. 255=high)
  PRIODAQ         = 40;       // total=100%
  PRIOGUI         = 40;       // RUN=20%, DAQ=40%, GUI=40%

  PHASENONE       = 0;        // dive phases
  PHASEINITIAL    = 1;        // -initial phase
  PHASEINTERVAL   = 3;        // -interval phase
  PHASEADAPTION   = 4;        // -adaption phase
  PHASEREADY      = 5;        // -ready phase
  PHASEPREDIVE    = 6;        // -pre-dive phase
  PHASEDIVE       = 7;        // -dive phase
  PHASEPOSTDIVE   = 8;        // -post-dive phase

  MODEOFF         = 0;        // main run modes
  MODESLEEP       = 1;        // -sleep mode
  MODESTART       = 2;        // -restart mode
  MODERUN         = 3;        // -operation mode
  MODEAUTO        = 4;        // -automatic mode
  MODECOMM        = 5;        // -communication mode
  MODEUSER        = 6;        // -user mode  //nk// obsolete ? !!!!

  SIGMAXNUM       = 15;       // number of signals (Bit 1..16)
  SIGNONE         = 0;        // no signal pending
  SIGWARNTEMP     = 1;        // lowest priority
  SIGWARNBREATH   = 2;
  SIGWARNDEPTH    = 3;
  SIGWARNSPEED    = 4;
  SIGWARNTANK     = 5;
  SIGWARNACCU     = 6;
  SIGWARNOXDOSE   = 7;
  SIGWARNOXPRESS  = 8;
  SIGWARNGAS      = 9;
  SIGALARMSPEED   = 10;
  SIGALARMTANK    = 11;
  SIGALARMACCU    = 12;
  SIGALARMDECO    = 13;
  SIGALARMOXDOSE  = 14;
  SIGALARMOXPRESS = 15;
  SIGALARMGAS     = 16;       // highest priority
  SIGMESSAGE      = 17;       // signal for message window
  SIGCLOCKALARM   = 18;       // signal for alarm clock

// serial communication
//=====================
  SERPINMASK      = $030;     // disable SER0 / enable SER1 08.12.05 nk add
  SERSPEED        = 38400;    // serial port: 38400 baud (Tiger=18=12h)
  SERDATA         = 8;        // 8 data bit / no parity (Tiger=3)
  SERPARAM        = '38400/8/1/N';

// graphic display
//================
  LCDTYPE         = 9;        // display type 128x128 dots/8x8 dot char
  LCDPINS         = $0EE;     // display control pins
  LCDCOMM         = 150;      // display communication speed
  LCDSPEED        = $11;      // display refresh rate
  LCDDPORT        = 6;        // display data port
  LCDCPORT        = 8;        // display control port
  LCDRESET        = 4;        // display reset pin (P84)
  LCDFONTSEL      = 5;        // display font select pin (P85)
  LCDXRANGE       = 128;      // display graphic area X-range [dots]
  LCDYRANGE       = 128;      // display graphic area Y-range [dots]
  LCDBUFFLEN      = 2048;     // display screen buffer size [byte]  (5120 for mode 6)

// power management  // 17.02.07 nk new pwr-definitions and functions
//=================
  PWRHOLD         = 1;        // switch processor module on/off (self hold)
  PWRDISP         = 2;        // switch display on/off
  PWRLITE         = 3;        // switch backlite on/off
  PWRSALT         = 4;        // switch salinity sensor on/off
  PWRSONAR        = 5;        // switch sonar receiver on/off
  PWRMODUL        = 6;        // switch external module on/off

  PWRDISPPIN      = 85;       // display control pin (P85)
  PWRLITEPIN      = 86;       // backlite control pin (P86)
  PWRHOLDPIN      = 87;       // processor control pin (P87)
  PWRSALTPIN      = 90;       // salinity control pin (P90)
  PWRSONARPIN     = 91;       // sonar control pin (P91)
  PWRMODULPIN     = 92;       // external control pin (P92)
                              // digipot write addresses:
  PWRCONTRAST     = $50;      // contrast - suffix L
  PWRBRIGHTNESS   = $54;      // brightness - suffix N
  PWRLOUDNESS     = $58;      // loudness - suffix M

  ACCUMIN         = 6000;     // min accu voltage = 6.0V (0%)
  ACCUMAX         = 8400;     // max accu voltage = 8.4V (100%) 2xLiIon 3.7V/2400mAh
  ACCUATTEN       = 2;        // accu voltage attenuation
  ACCUGRADE       = 100000;   // 26.07.17 nk add for defph to simulate accu discharge (100 -> 0% ~ 400min.)

// analog/digital converter
//=========================
  ADCACCU         = 0;        // adc accu pack voltage (P50) (div 2)
  ADCSENS         = 1;        // adc sensor module voltage (P51) 3.3V
  ADCSALT         = 2;        // adc salinity sensor voltage (P52)
  ADCSONAR        = 3;        // adc sonar signal level (P53)

// MEM flash memory
//=================
//24.05.07 nk TIGER mov to Flash
//MEMSECTSIZE     = 65536;    // flash sector size = 65'536bytes = 64kB
//MEMPROTECT      = 0;        // no protected flash sectors
  MEMSECTMIN      = 2;        // min free flash sectors for dive data

// I2C bus (P4)
//========
  I2CPORT         = 3;        // I2C bus port
  I2CSCL          = 3;        // I2C bus clock pin (P33)
  I2CSDA          = 4;        // I2C bus data I/O pin (P34)
                              // the new low level I2C will be used if defined
  I2CDELAY        = 20;       // I2C bus send delay (0=200kHz, 1=100kHz..20=30kHz)
  I2CMODE         = 0;        // I2C bus mode (0=LSB first, 1=MSB first=ISO7816)

// SPI bus
//========
  SPIPORT         = 3;        // SPI bus port
  SPIMOSI         = 5;        // SPI bus data output pin (P35)
  SPIMISO         = 6;        // SPI bus data input pin (P36)
  SPICLK          = 7;        // SPI bus clock pin (P37)
  SPICS           = -1;       // SPI bus chip select (new SPI feature=n/u)
  SPIMODE         = 1;        // SPI bus mode (0=LSB first, 1=MSB first)

// audio & sound (P4)
//==============
  AUDPORT         = 9;        // audio output port
  AUDPIN          = 5;        // audio output pin (P95)

// joystick
//=========
  KEYPORT         = 7;        // keypad parallel port
  KEYPIN1         = 0;        // key #1 pin (P70)
  KEYPIN2         = 1;        // key #2 pin (P71)
  KEYPIN3         = 2;        // key #3 pin (P72)
  KEYPIN4         = 3;        // key #4 pin (P73)
  KEYPINS         = 15;       // keypad init pattern
  KEYLEVEL        = 0;        // keypad logic level=LO when pressed
  KEYMOVE         = 2;        // up/down key (move pointer)
  KEYTURN         = 4;        // left/right key (turn selection)
  KEYBACK         = 8;        // close menu and go back
  KEYPAGE         = 16;       // next/previous page
  KEYEXIT         = 32;       // no key within timeout
  KEYWAIT         = 255;      // wait on key return code
  KEYINIT         = 255;      // initial state
  KEYREP          = 10;       // key repetition rate [loops]

// compass module
//===============
  HEADMIDDLE      = 56;       // middle position of compass pointer
  HEADOFFSET      = 68;       // bitmap offset for north pointer
  HEADPIXEL       = 15;       // 15ddeg = 1.5°/pixel
  HEADSTEP        = 30;       // 30ddeg = 3°/click (DELPHI only)

// data acquisition
//=================
  MAXCOMP         = 17;       // max number of compartments (-1)
  DECODISP        = 99;       // 05.06.07 nk add deco font change if >99m/ft or >59min
  DECORANGE       = 106;      // max deco ceiling [m] (~75% of max depth range)
  DEPTHDISP       = 19900;    // max display depth range = 199m
  TIMESHORT       = 5999;     // max short time range [s] = 99min
  TIMERANGE       = 35999;    // max operating time range [s] = 9h59
  TIMEDISP        = 359999;   // max display time range [s] = 99h59m
  TIMELIMIT       = 57600;    // time limit for sec/min [s] = 960.0min = 16h00
  TIMELIMMSEC     = 57600000; // time limit for sec/min [ms] = 960.0min = 16h00
  SPEEDBUFLEN     = 8;        // integral lenght for speed buffer
  SPEEDRATE       = 240;      // dive speed = 5cm/s every 12m depth
  SPEEDMIN        = 10;       // min dive speed 10cm/s
  SPEEDMAX        = 50;       // max dive speed 50cm/s
  SPEEDDOWN       = 30;       // max descending dive speed 30cm/s
  SPEEDDISP       = 999;      // max display dive speed range = +/-999%
  ALTITUDEMAX     = 5000;     // max altitude = 5000m above sea level
  AIRPRESSMIN     = 540;      // min air pressure = 540hPa (5000mM)
  AIRPRESSMAX     = 1085;     // max air pressure = 1085hPa
  BAROMIN         = 930;      // barometer range = 930..1030hPa (0..100%)
  BAROMAX         = 1030;     // barometer maximum
  BAROHIST        = 21;       // barometer history time = 20h
  OXPSTEP         = 18;       // number of steps for cns clock calculation
  OXPPART         = 100;      // oxygen partial pressure per step [mbar]
  OXPMIN          = 500;      // min oxygen partial pressure = 500mbar
  OXRANGE         = 9999;     // max oxygen pressure range (9999mbar)
  OXDISP          = 9990000;  // max oxygen toxicity range [ppm] (999%)
  OXMAXDOSE       = 850;      // max oxygen dose per day (100%=850 OTU)
  OXHALFTIME      = 5400;     // oxygen clock half time [s] (CNS=90min)
  FOXYGEN         = 210;      // oxygen fraction in air [ppt] = 21%
  FNITROGEN       = 790;      // nitrogen fraction in air [ppt] = 79%
  FHELIUM         = 10;       // helium fraction in air [ppt] = 1%
  PDESAT          = 30;       // diff pressure for desaturation = 30mbar
  PFLIGHT         = 50;       // diff pressure for flying = 50mbar
  PVAPOR          = 63;       // vapor pressure (pH2O) in lung = 63mbar
  SCOREMIN        = 25;       // min diver score = 25%
  SCOREMAX        = 100;      // max diver score = 100%
  TANKRESERVE     = 20000;    // tank reserve pressure [mbar] = 20bar

// user interface
//===============
  MAXWIN          = 12;       // max number of windows (incl. pseudo window)
  INITWIN         = 7;        // init window (7=seanus logo)
  WINDEF          = 7;        // number of window definitions
  MAXBOX          = 250;      // max number of user boxes (incl. pseudo box)
  BOXDEF          = 10;       // number of box definitions
  MAXOBJ          = 20;       // max number of message objects
  OBJDEF          = 10;       // number of object definitions

  WINNONE         = 0;        // window names and numbers
  WINDEPTH        = 1;
  WINTIME         = 2;
  WINDECO         = 3;
  WINGAS          = 4;
  WINNAVIGATION   = 5;
  WINMENU         = 6;
  WINCLOCK        = 7;
  WINCALENDAR     = 8;
  WINPOWER        = 9;
  WINSATURATION   = 10;
  WINBARO         = 11;
  WINPLAN         = 12;       // 02.02.07 nk add dive planner window

  MENULEVEL       = 5;        // number of menu sub-levels
  MENUDISP        = 9;        // number of display menu
  MENUCLOCK       = 10;       // number of clock menu
  SETMENU         = 12;       // number of selection menus
  SETBOX          = 10;       // number of selection boxes
  SETDEF          = 5;        // number of selection definitions (0..4)
  SETFIRST        = 50;       // number of 1st selection box
  SETPARS         = 60;       // number of setting parameter = 2blocks x 30bytes

  COMMCLOSE       = 0;        // command for close the main window
  COMMNODATA      = 59;       // command for no data info
  COMMSAVE        = 251;      // command for save settings
  COMMFIX         = 252;      // command for fix (not selectable) values
  COMMNOP         = 253;      // command not defined
  COMMBACK        = 254;      // command for return of selection menu
  COMMEXIT        = 255;      // command for close the menu window

  LANGOFFSET      = 15;       // y-offset in bitmap for different languages
  SATOFFSET       = 15;       // bitmap offset for saturation bar graph
  SATMAXLOAD      = 120;      // max saturation overload [%] in bar graph

  MAXDAYDIVE      = 9;        // max number of dives per day to display (1..9)
  MAXLOGDIVE      = 9999;     // max number of dives in flash memory (1..9999)
  MAXCATDIVE      = 200;      // max number of dives in dive catalog (1..200)
  MAXCATPARS      = 8;        // number of parameter in dive catalog (0..7)
  MAXLOGPOINT     = 160;      // max number of dive profile points (0..159)
  MAXLOGPARS      = 3;        // number of profile parameter per point (0..2)
  MAXDIVEDATA     = 40;       // number of dive data for log book (0..40)

  LOGBLOCKPAR     = 0;        // block buffer for dive parameter
  LOGBLOCKSET     = 1;        // block buffer for setting parameter
  LOGPAGES        = 4;        // number of pages for dive log parameters
  LOGHEADER       = 4;        // number of logged header lines

  // LogType = lower byte of LogIdent (1st byte of a block)
  LOGBAD          = 0;        // bad (unusable) block
  LOGSTART        = 1;        // pre dive parameter
  LOGINIT         = 2;        // initial dive point
  LOGMAJOR        = 3;        // major dive parameter
  LOGFAST         = 4;        // fast saturation parameter
  LOGMINOR        = 5;        // minor dive parameter
  LOGSLOW         = 6;        // slow saturation parameter
//reserved          8..9      // reserved for future use
  LOGEND          = 10;       // post dive parameter
  LOGGAS          = 20;       // breathing gas parameter
  LOGNAV          = 30;       // navigation parameter
  LOGSET          = 40;       // setting parameter

  LOGERRORS       = 14;       // system error and status //nk// obsolete ??
  LOGFREE         = 15;       // free (usable) block  //nk// obsolete or 255

  LOGTIMESTART    = 1;        // label of first time range
  LOGTIMESCALE    = 7;        // time scale of 1st range = 1..7min
  LOGTIMERANGE    = 142;      // number of time ranges from 7..994min
  LOGDEPTHSTART   = 2;        // label of first depth range
  LOGDEPTHSCALE   = 10;       // depth scale of 1st range = 2..10m
  LOGDEPTHRANGE   = 30;       // number of depth ranges from 10..300m

  //nk//LOGLINES        = 6;        // number of lines per page for dive parameters
  SIMLINES        = 7;        // number of lines per page for dive simulation
  DIVELINES       = 10;       // number of lines per page for dive data

  CALENDARDIM     = 37;       // dim of calendar table [days]
  LOGPORT         = 1;        // serial port for message logging = SER1
  COMPORT         = 1;        // serial port for communication = SER1

//MESSAGELEN      = 255;      // max length of message buffer [char] //XE3//25.07.17 nk del
  MESSAGELINES    = 15;       // max number of message lines

var // module variables
  DatBuff: string;            // modul message buffer //XE3//25.07.17 nk del MESSAGELEN

// global dive data declaration
//======================================
  Head: string;  // global message buffers  //XE3//25.07.17 nk del MESSAGELEN ff
  Body: string;
  Tail: string;

  WinSpec: array[0..MAXWIN, 0..WINDEF] of Byte;
  BoxSpec: array[0..MAXBOX, 0..BOXDEF] of Byte;
  ObjSpec: array[0..MAXOBJ, 0..OBJDEF] of Byte;
  ObjTime: array[0..MAXOBJ] of Long;

  GlobalSet: array[0..SETMENU, 0..SETBOX, 0..SETDEF] of Byte;
  GlobalPar: array[0..SETPARS] of Word;
  BaroPress: array[0..BAROHIST] of Word;

  DiveCatalog: array[0..MAXCATDIVE,  0..MAXCATPARS] of Word;
  DiveProfile: array[0..MAXLOGPOINT, 0..MAXLOGPARS] of Word;
  DiveData: array[0..MAXDIVEDATA] of Word;

  Pt: array[0..MAXCOMP] of Real; // inert gas pressure in tissues [mbar] for real time
  Px: array[0..MAXCOMP] of Real; // inert gas pressure in tissues [mbar] for simulation

  Rg: array[0..MAXCOMP] of Word; // relation Pt/Pg [%]
  Rc: array[0..MAXCOMP] of Word; // relation Pa/Pc [%]
  Kt: array[0..MAXCOMP] of Word; // tissue half times [min]
  Ka: array[0..MAXCOMP] of Word; // Buehlmann parameter a [mbar]
  Kb: array[0..MAXCOMP] of Word; // Buehlmann parameter b [-]
  Op: array[0..OXPSTEP] of Word; // oxygen cns clock values [ppm/s]


//variable name     type     unit      display      unit      remarks
//==============================================================================
  DivePhase:        Byte; // 0=none 1=init 3=interval 4=adaption 5=ready 6=predive 7=dive 8=postdive
  RunMode:          Byte; // 0=off 1=sleep 2=start 3=run 4=auto 5=user

  WinPos1:          Byte; // window pos top/left        ---------
  WinPos2:          Byte; // window pos top/right       | 1 | 2 |
  WinPos3:          Byte; // window pos bottom/left     | 3 | 4 |
  WinPos4:          Byte; // window pos bottom/right    ---------
  WinPre3:          Byte; // previous opend window at pos 3
  WinPre4:          Byte; // previous opend window at pos 4

  InitFlag:         Byte; // INIT=SYS initialized
  InitDaq:          Byte; // INIT=DAQ initialized
  InitGui:          Byte; // INIT=GUI initialized

  SysCtr:           Long;
  DaqCtr:           Long;
  GuiCtr:           Long;

  ObjFlag:          Byte; // OFF=no object to show
  DebugFlag:        Byte; // OFF=no debugging / ON=debugging
  WaterFlag:        Byte; // OFF=surface / ON=immersed
  DiveFlag:         Byte; // OFF=surface / ON=dived
  DecoFlag:         Byte; // OFF=no deco / ON=deco stop
  TankFlag:         Byte; // OFF=no tank data / ON=tank data available
  SonarFlag:        Byte; // OFF=no sonar / ON=sonar available
  LiteFlag:         Byte; // OFF=no backlite / ON=backlite on
  PhaseFlag:        Byte; // OFF=phase not changed / ON=phase has changed
  SaveFlag:         Byte; // OFF=no setting changed / ON=save settings
  PlanFlag:         Byte; // OFF=no dive planning / ON=dive planning mode
  LogFlag:          Byte; // OFF=dive log closed / ON=dive log open 09.05.07 nk add

  StatusWord:       Word; // -        bit coded status and error flags 0..15
  SigNum:           Long; // -
  BoxNum:           Long; // -
  DiveDayNum:       Long; // -        n            dive number of day (1..9, 0=n/u) long!!
  DiveLogNum:       Word; // -        nnnn         total number of logged dives (1..9999)

  StartTime:        Long; // s        hh:mm        min       absolute RTC time
  EndTime:          Long; // s        hh:mm        min       absolute RTC time
  DecoTime:         Long; // s        hh:mm        min       9:59
  NullTime:         Long; // s        hh:mm        min       9:59
  FlightTime:       Long; // s        hh:mm        min       99:59
  DesatTime:        Long; // s        hh:mm        min       99:59
  GasTime:          Long; // s        hh:mm        min       99:59
  AscentTime:       Long; // s        hh:mm        min       99:59
  TotalDecoTime:    Long; // s
  DirectTime:       Long; // s

  SystemTicks:      Long; // ms
  ScanTime:         Long; // ms
  RunTime:          Long; // ms       07.06.07 nk add
  InitTime:         Long; // ms
  DiveTime:         Long; // ms       hh:mm        min       99:59
  TotalDiveTime:    Long; // ms       hh:mm        min       99:59
  SurfaceTime:      Long; // ms       hh:mm        min       99:59
  LogTime:          Long; // ms

  LogStep:          Byte; // -                     LOGSTART...LOGEND
  LogSectors:       Byte; // -
  LogBlock:         Word; // -                     number of dive data blocks
  LogIdent:         Word; // -                     log block identifier
  LogWrite:         Long; // -                     log start address in flash memory

  DiveDepth:        Long; // cm       nn.n / nnn   m / ft
  MaxDepth:         Long; // cm       nn.n / nnn   m / ft
  DeltaDepth:       Long; // cm
  DecoDepth:        Long; // cm       nnn          m / ft

  InertPress:       Long; // mbar
  DecoCeil:         Long; // mbar                  mbar=cm
  AmbPress:         Long; // mbar     -            mbar=cm
  AirPress:         Long; // mbar     nnnn         mbar=hPa
  FillPress:        Long; // mbar
  TankPress:        Long; // mbar     nnn/nnnn     bar / psi
  LastPress:        Long; // mbar                  tank pressure last measured
  GasConsum:        Long; // mbar     nnn/nnnn     bar / psi    //nk// obsolete ??
  TotalDecoGas:     Long; // mbar

  DiveSpeed:        Long; // %        +/-nnn       %         + = up / - = down
  DesatRate:        Byte; // %        wird wo gesetzt //nk// zZ 100% const
  DiverScore:       Byte; // %
  LeadTissue:       Word; // %

  BreathRate:       Long; // mbar/s                reduced to surface (1bar)
  Altitude:         Long; // m        nnnnn        m / ft above sea level
  AmbTemp:          Long; // cC       -nnn.n       °C / °F    cC=1/100°C
  AirTemp:          Long; // cC       -nnn.n       °C / °F    cC=1/100°C
  WaterTemp:        Long; // cC       -nnn.n       °C / °F    cC=1/100°C
  WaterSalt:        Word; // ppt      n.n          %
  WaterDens:        Word; // g/dl                  100mbar=1m (EN/DIN)

  GasMix:           Byte; // -        n            0=Oxygen, 1=Air, 2..9=Mix Gases
  OxFract:          Word; // ppt
  NiFract:          Word; // ppt
  HeFract:          Word; // ppt
  OxClock:          Long; // ppm      nnn          %CNS
  OxUnits:          Long; // ppm      nnn          %OTU
  OxDose:           Long; // mOTU                  cumulated mOTU (100%=850 OTU)
  OxPress:          Long; // mbar
  NiPress:          Long; // mbar
  HePress:          Long; // mbar

  SonarSignal:      Word; // -                     sonar signal strength 0=bad..5=excellent
  SoundSpeed:       Word; // dm/s     nnnn         m/s / ft/s
  HomeDist:         Word; // dm       nnnn         m / yd
  Heading:          Word; // ddeg     nnn          °
  Bearing:          Word; // ddeg     nnn          °

  WeekDay:          Long; // -        n            0=monday..6=sunday
  AlarmTime:        Long; // s        -            remaining time till alarm
  AccuTime:         Long; // s        hh:mm        min       99:59
  AccuPower:        Long; // %        nnn          remaining accu power
  AccuRate:         Long; // mV/s     -            have to be measured

  SimDiveTime:      Long; // ms
  SimDiveDepth:     Long; // cm
  SimDecoTime:      Long; // s
  SimNullTime:      Long; // s
  SimDecoDepth:     Long; // cm
  SimDesatTime:     Long; // s
  SimFlightTime:    Long; // s
  SimDecoGas:       Long; // mbar
  SimAltitude:      Long; // m

  // PERSON SETTINGS
  DiverAge:         Byte; // -
  DiverHeight:      Word; // cm       nnn          m.cm / ft.in
  DiverWeight:      Word; // kg       nnn          kg / lb
  DiverGender:      Byte; // -        A            0=male, 1=female
  DiverGrade:       Byte; // -        n            1=basic...6=expert
  DiverYears:       Byte; // Y        nn           years diving
  DiverSmoker:      Byte; // -        n            0=never, 1=sometimes, 2=often
  DiverFitness:     Byte; // -        n            1=poor...6=excellent

  // EQUIPMENT SETTINGS
  TankSize:         Byte; // l        nnn          l / hCuFt

  // DIVE GASES SETTING

  // LIMITS SETTINGS
  WarnTemp:         Word; // cC       nn           °C / °F
  WarnBreath:       Byte; // %
  WarnDepth:        Word; // cm       nnn          m / ft
  WarnSpeed:        Byte; // %        nn           % + 100
  WarnTank:         Word; // %        nn           %
  WarnPower:        Byte; // %        nn           %
  WarnOxDose:       Long; // ppm
  WarnOxPress:      Word; // mbar     n.n          bar
  WarnNiPress:      Word; // mbar     n.n          bar
  WarnGas:          Word; // s

  AlarmSpeed:       Byte; // %                     WarnSpeed + 20%
  AlarmTank:        Word; // %        nn           %
  AlarmPower:       Byte; // %
  AlarmOxDose:      Long; // ppm
  AlarmOxPress:     Word; // mbar                  WarnOxPress + 100mbar
  AlarmGas:         Word; // s

  // PARAMETER SETTINGS
  ActivDepth:       Word; // cm       nnn          cm / ft
  DecoStep:         Word; // m        nn           m / ft
  SafetyTime:       Long; // s        mm           min
  DeepFlag:         Byte; // 0=OFF / 1=ON deep deco stops
  DepthFlag:        Byte; // 0=OFF / 1=TRUE depth calculation
  DiveRepTime:      Long; // ms       mm           min
  AutoOffTime:      Long; // s        mm           min
  LogInterval:      Long; // ms       nn           s

  IntervalTime:     Long; // ms       hh:mm        min

  // DISPLAY SETTINGS
  LangFlag:         Byte; // 0=EN 1=DE 2=FR 3=IT
  UnitFlag:         Byte; // OFF=metrical (SI) / ON=imperial
  TimeFlag:         Byte; // 0=EU / 1=US / 2=ISO time format
  SutiFlag:         Byte; // 0=NO / 1=EU / 2=US summer time
  Brightness:       Byte; // %
  Contrast:         Byte; // %
  Backlight:        Byte; // s
  Loudness:         Byte; // %

  // CLOCK SETTINGS
  RealYear:         Long; // real date
  RealMonth:        Long;
  RealDay:          Long;
  RealHour:         Long; // real time
  RealMin:          Long;
  AlarmHour:        Long; // alarm time
  AlarmMin:         Long;
  AlarmSet:         Byte; // alarm activated

  RealSec:          Long;

implementation

uses
  SYS, FMain, FLog, FGui, FDaq, FTrack, FProfile, FPlan, Clock, Texts;

//------------------------------------------------------------------------------
// INITGLOBALDATA - Initialize global data with default values
//------------------------------------------------------------------ 17.02.07 --
procedure InitGlobalData;
var
  i, j, k: Word;
begin
  Head := sEMPTY;                     // clear global text buffers
  Body := sEMPTY;
  Tail := sEMPTY;
  
  DivePhase        := PHASEINITIAL;   // initial phase
  RunMode          := MODERUN;        // run mode

  WinPos1          := WINBARO;
  WinPos2          := WINCLOCK;
  WinPos3          := WINPOWER;
  WinPos4          := WINDECO;
  WinPre3          := WINPOWER;
  WinPre4          := WINDECO;

  SysCtr           := cCLEAR;
  DaqCtr           := cCLEAR;
  GuiCtr           := cCLEAR;

  InitFlag         := cOFF;           // OFF (not initialized)
  InitDaq          := cOFF;           // OFF (not initialized)
  InitGui          := cOFF;           // OFF (not initialized)

  ObjFlag          := cOFF;           // OFF (no object to show)
  DebugFlag        := cOFF;           // OFF (no debugging)
  WaterFlag        := cOFF;           // OFF (not immersed)
  DiveFlag         := cOFF;           // OFF (not dived)
  DecoFlag         := cOFF;           // OFF (no deco)
  TankFlag         := cOFF;           // OFF (no tank data)
  SonarFlag        := cOFF;           // OFF (no sonar navigation)
  LiteFlag         := cOFF;           // OFF (no backlite)
  PhaseFlag        := cOFF;           // OFF (phase not changed)
  SaveFlag         := cOFF;           // OFF (nothing to save)
  PlanFlag         := cOFF;           // OFF (no dive planning)
  LogFlag          := cOFF;           // OFF (dive log closed)

  StatusWord       := cCLEAR;         // initial status / no errors
  SigNum           := SIGNONE;        // object signal number
  BoxNum           := cCLEAR;
  DiveDayNum       := cCLEAR;         // daily dive counter 1..MAXDAYDIVE (0=no dives)
  DiveLogNum       := cCLEAR;         // total dive counter 1..MAXLOGDIVE

  StartTime        := cCLEAR;
  EndTime          := cCLEAR;
  DecoTime         := cCLEAR;
  NullTime         := TIMERANGE;      // 9h59m
  FlightTime       := TIMEDISP;       // 99h59m
  DesatTime        := TIMEDISP;       // 99h59m
  GasTime          := TIMEDISP;       // 99h59m
  AscentTime       := cCLEAR;
  DirectTime       := cCLEAR;
  TotalDecoTime    := cCLEAR;

  SystemTicks      := cCLEAR;
  ScanTime         := cCLEAR;
  RunTime          := cCLEAR;
  InitTime         := cCLEAR;
  DiveTime         := cCLEAR;
  TotalDiveTime    := cCLEAR;
  SurfaceTime      := cCLEAR;
  LogTime          := cCLEAR;

  LogStep          := cCLEAR;
  LogSectors       := cCLEAR;
  LogBlock         := cCLEAR;
  LogIdent         := cCLEAR;
  LogWrite         := cCLEAR;

  DiveDepth        := cCLEAR;
  MaxDepth         := cCLEAR;
  DeltaDepth       := cCLEAR;
  DecoDepth        := cCLEAR;

  DecoCeil         := cCLEAR;
  InertPress       := ISOSAT;         // 750mbar
  AmbPress         := ISOPRESS;       // 1013mbar (initial pressure)
  AirPress         := ISOPRESS;       // 1013mbar (standard sea level)
  FillPress        := cCLEAR;
  TankPress        := cCLEAR;
  LastPress        := cCLEAR;
  GasConsum        := cCLEAR;
  TotalDecoGas     := cCLEAR;

  DiveSpeed        := cCLEAR;
  DesatRate        := PROCENT;        // 100%
  DiverScore       := PROCENT;        // 100%
  LeadTissue       := cCLEAR;

  BreathRate       := cCLEAR;         // 0mbar/s
  Altitude         := cCLEAR;         // 0m (sea level)
  AmbTemp          := ISOTEMP;        // 1500cC = 15°C
  AirTemp          := ISOTEMP;        // 1500cC = 15°C
  WaterTemp        := ISOTEMP;        // 1500cC = 15°C
  WaterSalt        := cCLEAR;         // 0ppt (fresh water)
  WaterDens        := ISODENS;        // 100mbar = 1m (EN/DIN)
  SoundSpeed       := ISOSPEED;       // 15067dm/s = 1506.7m/s

  SonarSignal      := cCLEAR;         // 0=bad..5=excellent
  HomeDist         := cCLEAR;
  Heading          := cCLEAR;
  Bearing          := cCLEAR;

  GasMix           := 1;              // 0=Oxygen, 1=Air, 2..9=Mix gases
  OxClock          := cCLEAR;         // CNS% cumulated
  OxUnits          := cCLEAR;         // OTU% rel 850
  OxDose           := cCLEAR;         // cumulated mOTU (100%=850 OTU)
  OxFract          := FOXYGEN;        // fraction of oxygen in air = 21%
  NiFract          := FNITROGEN;      // fraction of nitrogen in air = 79%
  HeFract          := FHELIUM;        // fraction of helium in air = 1%
  OxPress          := FOXYGEN;        // oxygen partial pressure = 210mbar
  NiPress          := FNITROGEN;      // nitrogen partial pressure = 790mbar
  HePress          := FHELIUM;        // helium partial pressure = 10mbar

  WeekDay          := cCLEAR;
  AlarmTime        := cCLEAR;
  AccuTime         := cCLEAR;
  AccuPower        := cFULL;

  SimDiveTime      := cCLEAR;
  SimDiveDepth     := cCLEAR;
  SimDecoTime      := cCLEAR;
  SimDecoDepth     := cCLEAR;
  SimNullTime      := cCLEAR;
  SimDesatTime     := cCLEAR;
  SimFlightTime    := cCLEAR;
  SimDecoGas       := cCLEAR;

  // PERSON SETTINGS
  DiverAge         := 30;
  DiverHeight      := 178;     // 178cm=70in=5.84ft=5ft10in
  DiverWeight      := 73;      // 73kg=161lb
  DiverGender      := 0;       // 0=male
  DiverGrade       := 2;       // 2=open water
  DiverYears       := 2;       // 2 years diving
  DiverSmoker      := 0;       // 0=never
  DiverFitness     := 3;       // 3=moderate

  // EQUIPMENT SETTINGS
  TankSize         := 20;             // 20l

  // DIVE GASES SETTINGS

  // LIMITS SETTINGS
  WarnTemp         := 1000;           // [cC] 10°C
  WarnBreath       := 120;            // [%] 120%
  WarnDepth        := 3900;           // [cm] 39m
  WarnSpeed        := 120;            // [%] 120%
  WarnTank         := 50;             // [%] 50%
  WarnPower        := 25;             // [%] 25%
  WarnOxDose       := 750000;         // [ppm] 75%
  WarnOxPress      := 1400;           // [mbar] 1.4bar
  WarnNiPress      := 4000;           // [mbar] 4.0bar
  WarnGas          := 120;            // [s] 2min

  AlarmSpeed       := WarnSpeed + 20; // [%] +20%
  AlarmTank        := 20;             // [%] 20%
  AlarmPower       := 10;             // [%] 10%
  AlarmOxDose      := 950000;         // [ppm] 95%
  AlarmOxPress     := WarnOxPress + 100; // [mbar] 1.5bar
  AlarmGas         := 60;             // [s] 1min

  // PARAMETER SETTINGS
  ActivDepth       := 60;             // 60cm
  DecoStep         := 3;              // 3m
  SafetyTime       := 3;              // 3min
  DeepFlag         := cOFF;           // OFF (no deep deco stops)
  DepthFlag        := cOFF;           // OFF (norm depth calculation)
  DiveRepTime      := 300000;         // 5min
  AutoOffTime      := 1800;           // 30min
  LogInterval      := 10000;          // 10s

  IntervalTime     := DiveRepTime;

   // DISPLAY SETTINGS
  LangFlag         := cOFF;    // EN  (english language)
  UnitFlag         := cOFF;    // MET (metrical unit system)
  TimeFlag         := cOFF;    // EU  (european time format)
  SutiFlag         := cOFF;    // OFF (no summer time)
  Brightness       := 90;      // 90%
  Contrast         := 80;      // 80%
  Backlight        := 5;       // 5s
  Loudness         := 70;      // 70%

  // CLOCK SETTINGS
  RealYear         := cCLEAR;
  RealMonth        := cCLEAR;
  RealDay          := cCLEAR;
  RealHour         := cCLEAR;
  RealMin          := cCLEAR;
  AlarmHour        := cCLEAR;
  AlarmMin         := cCLEAR;
  AlarmSet         := cOFF;    // alarm not set

  RealSec          := cCLEAR;

  for i := 0 to MAXOBJ - 1 do begin
    ObjTime[i] := cCLEAR;             // clear object time array
  end;

  BaroPress[0] := cCLEAR;
  
  for i := 1 to BAROHIST do begin
    BaroPress[i] := ISOPRESS;         // init barometer history array
  end;

  for i := 0 to SETMENU - 1 do begin  // clear global settings
    for j := 0 to SETBOX - 1 do begin
      for k := 0 to SETDEF - 1 do begin
        GlobalSet[i, j, k] := cCLEAR;
      end;
    end;
  end;

  for i := 0 to MAXCATDIVE - 1 do begin   // init dive catalog array
    for j := 0 to MAXCATPARS - 1 do begin
      DiveCatalog[i, j] := cCLEAR;
    end;
  end;

  for i := 0 to MAXLOGPOINT - 1 do begin  // init dive profile array
    for j := 0 to MAXLOGPARS - 1 do begin
      DiveProfile[i, j] := cCLEAR;
    end;
  end;

  for i := 0 to MAXCOMP - 1 do begin
    Pt[i] := ISOSAT;  // compartment saturation [mbar] at sea level
    Px[i] := ISOSAT;  // Pt = fNi*(Pb-Pv) = 0.79*(1013-63) = 750mbar
    Rg[i] := PROCENT;
    Rc[i] := cCLEAR;
  end;

  Kt[0]  :=   20;  // compartment half times/10 [min]
  Kt[1]  :=   40;
  Kt[2]  :=   80;
  Kt[3]  :=  125;
  Kt[4]  :=  185;
  Kt[5]  :=  270;
  Kt[6]  :=  383;
  Kt[7]  :=  543;
  Kt[8]  :=  770;
  Kt[9]  := 1090;
  Kt[10] := 1460;
  Kt[11] := 1870;
  Kt[12] := 2390;
  Kt[13] := 3050;
  Kt[14] := 3900;
  Kt[15] := 4980;
  Kt[16] := 6350;

  Ka[0]  :=  3000;  // compartment parameter a/10 [mbar]
  Ka[1]  := 12599;
  Ka[2]  := 10000;
  Ka[3]  :=  8618;
  Ka[4]  :=  7562;
  Ka[5]  :=  6200;
  Ka[6]  :=  5043;
  Ka[7]  :=  4410;
  Ka[8]  :=  4000;
  Ka[9]  :=  3750;
  Ka[10] :=  3500;
  Ka[11] :=  3295;
  Ka[12] :=  3065;
  Ka[13] :=  2835;
  Ka[14] :=  2610;
  Ka[15] :=  2480;
  Ka[16] :=  2327;

  Kb[0]  :=  8300;  // compartment parameter b/10000
  Kb[1]  :=  5050;
  Kb[2]  :=  6514;
  Kb[3]  :=  7222;
  Kb[4]  :=  7825;
  Kb[5]  :=  8126;
  Kb[6]  :=  8434;
  Kb[7]  :=  8693;
  Kb[8]  :=  8910;
  Kb[9]  :=  9092;
  Kb[10] :=  9222;
  Kb[11] :=  9319;
  Kb[12] :=  9403;
  Kb[13] :=  9477;
  Kb[14] :=  9544;
  Kb[15] :=  9602;
  Kb[16] :=  9653;

// NOAA    [ppm/s]      [bar]  [%/min]
//------------------------------------
  Op[0]  :=     0;    // 0.5    0.00   oxygen cns clock
  Op[1]  :=    24;    // 0.6    0.14   1%/min = 167ppm/s
  Op[2]  :=    29;    // 0.7    0.17   (1ata = 1bar)
  Op[3]  :=    37;    // 0.8    0.22
  Op[4]  :=    47;    // 0.9    0.28
  Op[5]  :=    55;    // 1.0    0.33
  Op[6]  :=    70;    // 1.1    0.42
  Op[7]  :=    80;    // 1.2    0.48
  Op[8]  :=    92;    // 1.3    0.55
  Op[9]  :=   112;    // 1.4    0.67
  Op[10] :=   139;    // 1.5    0.83
  Op[11] :=   370;    // 1.6    2.22
  Op[12] :=   477;    // 1.7    2.86
  Op[13] :=   667;    // 1.8    4.00
  Op[14] :=  1112;    // 1.9    6.67
  Op[15] :=  1667;    // 2.0    10.0
  Op[16] :=  3334;    // 2.1    20.0
  Op[17] := 16667;    // 2.2   100.0

  AddGlobalPar(cCLEAR); // clear setting parameter list

  GlobalSet[0, 0, 0] := COMMEXIT;      // MAIN SELECTION (command number = exit)
  GlobalSet[0, 0, 1] := 11;            // arrow symbol
  GlobalSet[0, 0, 2] := 16;            // pointer symbol
  GlobalSet[0, 0, 3] := 0;
  GlobalSet[0, 0, 4] := 0;             // 1st text number (pointer to Mask$)

  GlobalSet[0, 1, 0] := 1;             // NAVIGATION (command number)
  GlobalSet[0, 1, 1] := 0;
  GlobalSet[0, 1, 2] := 0;
  GlobalSet[0, 1, 3] := 0;
  GlobalSet[0, 1, 4] := 0;

  GlobalSet[0, 2, 0] := 2;             // SATURATION (command number)
  GlobalSet[0, 2, 1] := 0;
  GlobalSet[0, 2, 2] := 0;
  GlobalSet[0, 2, 3] := 0;
  GlobalSet[0, 2, 4] := 0;

  GlobalSet[0, 3, 0] := 3;             // GAS SELECTION (command number)
  GlobalSet[0, 3, 1] := 0;
  GlobalSet[0, 3, 2] := 0;
  GlobalSet[0, 3, 3] := 0;
  GlobalSet[0, 3, 4] := 0;
                                       // 03.06.07 nk change pos 4 and 5
  GlobalSet[0, 4, 0] := 4;             // SETTINGS (command number)
  GlobalSet[0, 4, 1] := 0;
  GlobalSet[0, 4, 2] := 0;
  GlobalSet[0, 4, 3] := 0;
  GlobalSet[0, 4, 4] := 0;

  GlobalSet[0, 5, 0] := 5;             // SERVICES (command number)
  GlobalSet[0, 5, 1] := 0;
  GlobalSet[0, 5, 2] := 0;
  GlobalSet[0, 5, 3] := 0;
  GlobalSet[0, 5, 4] := 9;             // 9=hide selection while diving

  GlobalSet[0, 6, 0] := 6;             // COLD START (command number)
  GlobalSet[0, 6, 1] := 0;
  GlobalSet[0, 6, 2] := 0;
  GlobalSet[0, 6, 3] := 0;
  GlobalSet[0, 6, 4] := 9;             // 9=hide selection while diving

  GlobalSet[0, 7, 0] := 7;             // SLEEP MODE (command number)
  GlobalSet[0, 7, 1] := 0;
  GlobalSet[0, 7, 2] := 0;
  GlobalSet[0, 7, 3] := 0;
  GlobalSet[0, 7, 4] := 9;             // 9=hide selection while diving

  GlobalSet[0, 8, 0] := 8;             // SHUT DOWN (command number)
  GlobalSet[0, 8, 1] := 0;
  GlobalSet[0, 8, 2] := 0;
  GlobalSet[0, 8, 3] := 0;
  GlobalSet[0, 8, 4] := 9;             // 9=hide selection while diving

  GlobalSet[0, 9, 0] := COMMEXIT;      // CLOSE (command number = exit)
  GlobalSet[0, 9, 1] := 12;            // arrow symbol
  GlobalSet[0, 9, 2] := 0;
  GlobalSet[0, 9, 3] := 0;
  GlobalSet[0, 9, 4] := 0;

  GlobalSet[1, 0, 0] := COMMBACK;      // GAS SELECTION (command number = return)
  GlobalSet[1, 0, 1] := 11;            // arrow symbol
  GlobalSet[1, 0, 2] := 16;            // pointer symbol
  GlobalSet[1, 0, 3] := 0;
  GlobalSet[1, 0, 4] := 10;            // 1st text number (pointer to Mask$)

  GlobalSet[1, 1, 0] := 11;            // GAS #1 (command number)
  GlobalSet[1, 1, 1] := 0;
  GlobalSet[1, 1, 2] := 0;
  GlobalSet[1, 1, 3] := 0;
  GlobalSet[1, 1, 4] := 0;

  GlobalSet[1, 2, 0] := 12;            // GAS #2 (command number)
  GlobalSet[1, 2, 1] := 0;
  GlobalSet[1, 2, 2] := 0;
  GlobalSet[1, 2, 3] := 0;
  GlobalSet[1, 2, 4] := 0;

  GlobalSet[1, 3, 0] := 13;            // GAS #3 (command number)
  GlobalSet[1, 3, 1] := 0;
  GlobalSet[1, 3, 2] := 0;
  GlobalSet[1, 3, 3] := 0;
  GlobalSet[1, 3, 4] := 0;

  GlobalSet[1, 4, 0] := 14;            // GAS #4 (command number)
  GlobalSet[1, 4, 1] := 0;
  GlobalSet[1, 4, 2] := 0;
  GlobalSet[1, 4, 3] := 0;
  GlobalSet[1, 4, 4] := 0;

  GlobalSet[1, 5, 0] := 15;            // GAS #5 (command number)
  GlobalSet[1, 5, 1] := 0;
  GlobalSet[1, 5, 2] := 0;
  GlobalSet[1, 5, 3] := 0;
  GlobalSet[1, 5, 4] := 0;

  GlobalSet[1, 6, 0] := 16;            // GAS #6 (command number)
  GlobalSet[1, 6, 1] := 0;
  GlobalSet[1, 6, 2] := 0;
  GlobalSet[1, 6, 3] := 0;
  GlobalSet[1, 6, 4] := 0;

  GlobalSet[1, 7, 0] := 17;            // GAS #7 (command number)
  GlobalSet[1, 7, 1] := 0;
  GlobalSet[1, 7, 2] := 0;
  GlobalSet[1, 7, 3] := 0;
  GlobalSet[1, 7, 4] := 0;

  GlobalSet[1, 8, 0] := 18;            // GAS #8 (command number)
  GlobalSet[1, 8, 1] := 0;
  GlobalSet[1, 8, 2] := 0;
  GlobalSet[1, 8, 3] := 0;
  GlobalSet[1, 8, 4] := 0;

  GlobalSet[1, 9, 0] := COMMEXIT;      // CLOSE (command number = exit)
  GlobalSet[1, 9, 1] := 12;            // arrow symbol
  GlobalSet[1, 9, 2] := 0;
  GlobalSet[1, 9, 3] := 0;
  GlobalSet[1, 9, 4] := 0;
                                       // 03.06.07 nk old=3
  GlobalSet[2, 0, 0] := COMMBACK;      // SETTINGS (command number = return)
  GlobalSet[2, 0, 1] := 11;            // arrow symbol
  GlobalSet[2, 0, 2] := 16;            // pointer symbol
  GlobalSet[2, 0, 3] := 0;
  GlobalSet[2, 0, 4] := 20;            // 1st text number (pointer to Mask$)

  GlobalSet[2, 1, 0] := 21;            // PERSON (command number)
  GlobalSet[2, 1, 1] := 0;
  GlobalSet[2, 1, 2] := 0;
  GlobalSet[2, 1, 3] := 0;
  GlobalSet[2, 1, 4] := 0;

  GlobalSet[2, 2, 0] := 22;            // EQUIPMENT (command number)
  GlobalSet[2, 2, 1] := 0;
  GlobalSet[2, 2, 2] := 0;
  GlobalSet[2, 2, 3] := 0;
  GlobalSet[2, 2, 4] := 0;

  GlobalSet[2, 3, 0] := 23;            // DIVE GASES (command number)
  GlobalSet[2, 3, 1] := 0;
  GlobalSet[2, 3, 2] := 0;
  GlobalSet[2, 3, 3] := 0;
  GlobalSet[2, 3, 4] := 0;

  GlobalSet[2, 4, 0] := 24;            // LIMITS (command number)
  GlobalSet[2, 4, 1] := 0;
  GlobalSet[2, 4, 2] := 0;
  GlobalSet[2, 4, 3] := 0;
  GlobalSet[2, 4, 4] := 0;

  GlobalSet[2, 5, 0] := 25;            // PARAMETER (command number)
  GlobalSet[2, 5, 1] := 0;
  GlobalSet[2, 5, 2] := 0;
  GlobalSet[2, 5, 3] := 0;
  GlobalSet[2, 5, 4] := 0;

  GlobalSet[2, 6, 0] := 26;            // DISPLAY (command number)
  GlobalSet[2, 6, 1] := 0;
  GlobalSet[2, 6, 2] := 0;
  GlobalSet[2, 6, 3] := 0;
  GlobalSet[2, 6, 4] := 0;

  GlobalSet[2, 7, 0] := 27;            // CLOCK (command number)
  GlobalSet[2, 7, 1] := 0;
  GlobalSet[2, 7, 2] := 0;
  GlobalSet[2, 7, 3] := 0;
  GlobalSet[2, 7, 4] := 0;

  GlobalSet[2, 8, 0] := 28;            // GAS MIXES (command number)
  GlobalSet[2, 8, 1] := 0;
  GlobalSet[2, 8, 2] := 0;
  GlobalSet[2, 8, 3] := 0;
  GlobalSet[2, 8, 4] := 0;

  GlobalSet[2, 9, 0] := COMMEXIT;      // CLOSE (command number = exit)
  GlobalSet[2, 9, 1] := 12;            // arrow symbol
  GlobalSet[2, 9, 2] := 0;
  GlobalSet[2, 9, 3] := 0;
  GlobalSet[2, 9, 4] := 0;
                                       // 03.06.07 nk old=2
  GlobalSet[3, 0, 0] := COMMBACK;      // SERVICES (command number = return)
  GlobalSet[3, 0, 1] := 11;            // arrow symbol
  GlobalSet[3, 0, 2] := 16;            // pointer symbol
  GlobalSet[3, 0, 3] := 0;
  GlobalSet[3, 0, 4] := 30;            // 1st text number (pointer to Mask$)

  GlobalSet[3, 1, 0] := 31;            // LOG BOOK (command number)
  GlobalSet[3, 1, 1] := 0;
  GlobalSet[3, 1, 2] := 0;
  GlobalSet[3, 1, 3] := 0;
  GlobalSet[3, 1, 4] := 0;

  GlobalSet[3, 2, 0] := 32;            // DIVE PROFILES (command number)
  GlobalSet[3, 2, 1] := 0;
  GlobalSet[3, 2, 2] := 0;
  GlobalSet[3, 2, 3] := 0;
  GlobalSet[3, 2, 4] := 0;

  GlobalSet[3, 3, 0] := 33;            // DIVE PLANNER (command number)
  GlobalSet[3, 3, 1] := 0;
  GlobalSet[3, 3, 2] := 0;
  GlobalSet[3, 3, 3] := 0;
  GlobalSet[3, 3, 4] := 0;

  GlobalSet[3, 4, 0] := 34;            // GAS MIXER (command number)
  GlobalSet[3, 4, 1] := 0;
  GlobalSet[3, 4, 2] := 0;
  GlobalSet[3, 4, 3] := 0;
  GlobalSet[3, 4, 4] := 0;

  GlobalSet[3, 5, 0] := 35;            // CALENDAR (command number)
  GlobalSet[3, 5, 1] := 0;
  GlobalSet[3, 5, 2] := 0;
  GlobalSet[3, 5, 3] := 0;
  GlobalSet[3, 5, 4] := 0;

  GlobalSet[3, 6, 0] := 36;            // DATA EXPORT (command number)
  GlobalSet[3, 6, 1] := 0;
  GlobalSet[3, 6, 2] := 0;
  GlobalSet[3, 6, 3] := 0;
  GlobalSet[3, 6, 4] := 0;

  GlobalSet[3, 7, 0] := 37;            // SOFTWARE UPDATE (command number)
  GlobalSet[3, 7, 1] := 0;
  GlobalSet[3, 7, 2] := 0;
  GlobalSet[3, 7, 3] := 0;
  GlobalSet[3, 7, 4] := 0;

  GlobalSet[3, 8, 0] := 38;            // SELF TEST (command number)
  GlobalSet[3, 8, 1] := 0;
  GlobalSet[3, 8, 2] := 0;
  GlobalSet[3, 8, 3] := 0;
  GlobalSet[3, 8, 4] := 0;

  GlobalSet[3, 9, 0] := COMMEXIT;      // CLOSE (command number = exit)
  GlobalSet[3, 9, 1] := 12;            // arrow symbol
  GlobalSet[3, 9, 2] := 0;
  GlobalSet[3, 9, 3] := 0;
  GlobalSet[3, 9, 4] := 0;

  GlobalSet[4, 0, 0] := COMMBACK;      // PERSON (command number = return)
  GlobalSet[4, 0, 1] := 11;            // arrow symbol
  GlobalSet[4, 0, 2] := 16;            // pointer symbol
  GlobalSet[4, 0, 3] := 0;
  GlobalSet[4, 0, 4] := 40;            // 1st text number (pointer to Mask$)

  AddGlobalPar(410);
  GlobalSet[4, 1, 0] := 30;            // AGE=30
  GlobalSet[4, 1, 1] := 9;
  GlobalSet[4, 1, 2] := 99;
  GlobalSet[4, 1, 3] := 1;
  GlobalSet[4, 1, 4] := 0;

  AddGlobalPar(420);
  GlobalSet[4, 2, 0] := 178;           // HEIGHT=178cm
  GlobalSet[4, 2, 1] := 100;
  GlobalSet[4, 2, 2] := 220;
  GlobalSet[4, 2, 3] := 1;
  GlobalSet[4, 2, 4] := 254;           // unit dep link text (cm/in) format n.nn

  AddGlobalPar(430);
  GlobalSet[4, 3, 0] := 73;            // WEIGHT=73kg
  GlobalSet[4, 3, 1] := 20;
  GlobalSet[4, 3, 2] := 140;
  GlobalSet[4, 3, 3] := 1;
  GlobalSet[4, 3, 4] := 244;           // unit dep link text (kg/lb)

  AddGlobalPar(440);
  GlobalSet[4, 4, 0] := 0;             // GENDER=M (male)
  GlobalSet[4, 4, 1] := 0;
  GlobalSet[4, 4, 2] := 1;
  GlobalSet[4, 4, 3] := 1;
  GlobalSet[4, 4, 4] := 132;           // help text number (+0/1)

  AddGlobalPar(450);
  GlobalSet[4, 5, 0] := 2;             // CERTIFICATION GRADE=2 (advanced)
  GlobalSet[4, 5, 1] := 1;
  GlobalSet[4, 5, 2] := 6;
  GlobalSet[4, 5, 3] := 1;
  GlobalSet[4, 5, 4] := 106;           // help text number (+1..6)

  AddGlobalPar(460);
  GlobalSet[4, 6, 0] := 2;             // EXPERIENCE=2 (years diving)
  GlobalSet[4, 6, 1] := 1;
  GlobalSet[4, 6, 2] := 30;
  GlobalSet[4, 6, 3] := 1;
  GlobalSet[4, 6, 4] := 0;

  AddGlobalPar(470);
  GlobalSet[4, 7, 0] := 0;             // SMOKING=0 (never)
  GlobalSet[4, 7, 1] := 0;
  GlobalSet[4, 7, 2] := 2;
  GlobalSet[4, 7, 3] := 1;
  GlobalSet[4, 7, 4] := 113;           // help text number (+0..2)

  AddGlobalPar(480);
  GlobalSet[4, 8, 0] := 3;             // FITNESS=3 (moderate)
  GlobalSet[4, 8, 1] := 1;
  GlobalSet[4, 8, 2] := 6;
  GlobalSet[4, 8, 3] := 1;
  GlobalSet[4, 8, 4] := 100;           // help text number (+1..6)

  GlobalSet[4, 9, 0] := COMMSAVE;      // CLOSE (command number = save)
  GlobalSet[4, 9, 1] := 12;            // arrow symbol
  GlobalSet[4, 9, 2] := 0;
  GlobalSet[4, 9, 3] := 0;
  GlobalSet[4, 9, 4] := 0;

  GlobalSet[5, 0, 0] := COMMBACK;      // EQUIPMENT (command number = return)
  GlobalSet[5, 0, 1] := 11;            // arrow symbol
  GlobalSet[5, 0, 2] := 16;            // pointer symbol
  GlobalSet[5, 0, 3] := 0;
  GlobalSet[5, 0, 4] := 50;            // 1st text number (pointer to Mask$)

  AddGlobalPar(510);
  GlobalSet[5, 1, 0] := 0;
  GlobalSet[5, 1, 1] := 0;
  GlobalSet[5, 1, 2] := 0;
  GlobalSet[5, 1, 3] := 0;
  GlobalSet[5, 1, 4] := 0;

  AddGlobalPar(520);
  GlobalSet[5, 2, 0] := 0;
  GlobalSet[5, 2, 1] := 0;
  GlobalSet[5, 2, 2] := 0;
  GlobalSet[5, 2, 3] := 0;
  GlobalSet[5, 2, 4] := 0;

  AddGlobalPar(530);
  GlobalSet[5, 3, 0] := 0;
  GlobalSet[5, 3, 1] := 0;
  GlobalSet[5, 3, 2] := 0;
  GlobalSet[5, 3, 3] := 0;
  GlobalSet[5, 3, 4] := 0;

  AddGlobalPar(540);
  GlobalSet[5, 4, 0] := 0;
  GlobalSet[5, 4, 1] := 0;
  GlobalSet[5, 4, 2] := 0;
  GlobalSet[5, 4, 3] := 0;
  GlobalSet[5, 4, 4] := 0;

  AddGlobalPar(550);
  GlobalSet[5, 5, 0] := 0;
  GlobalSet[5, 5, 1] := 0;
  GlobalSet[5, 5, 2] := 0;
  GlobalSet[5, 5, 3] := 0;
  GlobalSet[5, 5, 4] := 0;

  AddGlobalPar(560);
  GlobalSet[5, 6, 0] := 0;
  GlobalSet[5, 6, 1] := 0;
  GlobalSet[5, 6, 2] := 0;
  GlobalSet[5, 6, 3] := 0;
  GlobalSet[5, 6, 4] := 0;

  AddGlobalPar(570);
  GlobalSet[5, 7, 0] := 0;
  GlobalSet[5, 7, 1] := 0;
  GlobalSet[5, 7, 2] := 0;
  GlobalSet[5, 7, 3] := 0;
  GlobalSet[5, 7, 4] := 0;

  AddGlobalPar(580);
  GlobalSet[5, 8, 0] := 0;
  GlobalSet[5, 8, 1] := 0;
  GlobalSet[5, 8, 2] := 0;
  GlobalSet[5, 8, 3] := 0;
  GlobalSet[5, 8, 4] := 0;

  GlobalSet[5, 9, 0] := COMMSAVE;      // CLOSE (command number = save)
  GlobalSet[5, 9, 1] := 12;            // arrow symbol
  GlobalSet[5, 9, 2] := 0;
  GlobalSet[5, 9, 3] := 0;
  GlobalSet[5, 9, 4] := 0;

  GlobalSet[6, 0, 0] := COMMBACK;      // DIVE GASES (command number = return)
  GlobalSet[6, 0, 1] := 11;            // arrow symbol
  GlobalSet[6, 0, 2] := 16;            // pointer symbol
  GlobalSet[6, 0, 3] := 0;
  GlobalSet[6, 0, 4] := 60;            // 1st text number (pointer to Mask$)

  AddGlobalPar(610);
  GlobalSet[6, 1, 0] := 0;
  GlobalSet[6, 1, 1] := 0;
  GlobalSet[6, 1, 2] := 0;
  GlobalSet[6, 1, 3] := 0;
  GlobalSet[6, 1, 4] := 0;

  AddGlobalPar(620);
  GlobalSet[6, 2, 0] := 0;
  GlobalSet[6, 2, 1] := 0;
  GlobalSet[6, 2, 2] := 0;
  GlobalSet[6, 2, 3] := 0;
  GlobalSet[6, 2, 4] := 0;

  AddGlobalPar(630);
  GlobalSet[6, 3, 0] := 0;
  GlobalSet[6, 3, 1] := 0;
  GlobalSet[6, 3, 2] := 0;
  GlobalSet[6, 3, 3] := 0;
  GlobalSet[6, 3, 4] := 0;

  AddGlobalPar(640);
  GlobalSet[6, 4, 0] := 0;
  GlobalSet[6, 4, 1] := 0;
  GlobalSet[6, 4, 2] := 0;
  GlobalSet[6, 4, 3] := 0;
  GlobalSet[6, 4, 4] := 0;

  AddGlobalPar(650);
  GlobalSet[6, 5, 0] := 0;
  GlobalSet[6, 5, 1] := 0;
  GlobalSet[6, 5, 2] := 0;
  GlobalSet[6, 5, 3] := 0;
  GlobalSet[6, 5, 4] := 0;

  AddGlobalPar(660);
  GlobalSet[6, 6, 0] := 0;
  GlobalSet[6, 6, 1] := 0;
  GlobalSet[6, 6, 2] := 0;
  GlobalSet[6, 6, 3] := 0;
  GlobalSet[6, 6, 4] := 0;

  AddGlobalPar(670);
  GlobalSet[6, 7, 0] := 0;
  GlobalSet[6, 7, 1] := 0;
  GlobalSet[6, 7, 2] := 0;
  GlobalSet[6, 7, 3] := 0;
  GlobalSet[6, 7, 4] := 0;

  AddGlobalPar(680);
  GlobalSet[6, 8, 0] := 0;
  GlobalSet[6, 8, 1] := 0;
  GlobalSet[6, 8, 2] := 0;
  GlobalSet[6, 8, 3] := 0;
  GlobalSet[6, 8, 4] := 0;

  GlobalSet[6, 9, 0] := COMMSAVE;      // CLOSE (command number = save)
  GlobalSet[6, 9, 1] := 12;            // arrow symbol
  GlobalSet[6, 9, 2] := 0;
  GlobalSet[6, 9, 3] := 0;
  GlobalSet[6, 9, 4] := 0;

  GlobalSet[7, 0, 0] := COMMBACK;      // WARNINGS (command number = return)
  GlobalSet[7, 0, 1] := 11;            // arrow symbol
  GlobalSet[7, 0, 2] := 16;            // pointer symbol
  GlobalSet[7, 0, 3] := 0;
  GlobalSet[7, 0, 4] := 70;            // 1st text number (pointer to Mask$)

  AddGlobalPar(710);
  GlobalSet[7, 1, 0] := 39;            // WARN DEPTH=39m
  GlobalSet[7, 1, 1] := 0;             // 0 = no warning
  GlobalSet[7, 1, 2] := 120;
  GlobalSet[7, 1, 3] := 103;           // >100 -> convert incremental value too (3m = 10ft)
  GlobalSet[7, 1, 4] := 252;           // unit dep link text (m/ft)

  AddGlobalPar(720);
  GlobalSet[7, 2, 0] := 20;            // ASCENT RATE=20% (+100%)
  GlobalSet[7, 2, 1] := 0;             // 0 = no warning
  GlobalSet[7, 2, 2] := 50;
  GlobalSet[7, 2, 3] := 5;
  GlobalSet[7, 2, 4] := 0;

  AddGlobalPar(730);
  GlobalSet[7, 3, 0] := 50;            // TANK WARNING=50%
  GlobalSet[7, 3, 1] := 0;             // 0 = no warning
  GlobalSet[7, 3, 2] := 80;
  GlobalSet[7, 3, 3] := 10;
  GlobalSet[7, 3, 4] := 0;

  AddGlobalPar(740);
  GlobalSet[7, 4, 0] := 20;            // TANK ALARM=20%
  GlobalSet[7, 4, 1] := 0;             // 0 = no warning
  GlobalSet[7, 4, 2] := 50;
  GlobalSet[7, 4, 3] := 5;
  GlobalSet[7, 4, 4] := 0;

  AddGlobalPar(750);
  GlobalSet[7, 5, 0] := 25;            // POWER WARNING=25%
  GlobalSet[7, 5, 1] := 0;             // 0 = no warning
  GlobalSet[7, 5, 2] := 50;
  GlobalSet[7, 5, 3] := 5;
  GlobalSet[7, 5, 4] := 0;

  AddGlobalPar(760);
  GlobalSet[7, 6, 0] := 10;            // TEMPERATURE WARNING=10°C
  GlobalSet[7, 6, 1] := 4;
  GlobalSet[7, 6, 2] := 20;
  GlobalSet[7, 6, 3] := 1;
  GlobalSet[7, 6, 4] := 230;           // unit dep link text (°C/°F)

  AddGlobalPar(770);
  GlobalSet[7, 7, 0] := 14;            // PPO2 WARNING=14dbar=1.4bar
  GlobalSet[7, 7, 1] := 10;
  GlobalSet[7, 7, 2] := 22;
  GlobalSet[7, 7, 3] := 1;
  GlobalSet[7, 7, 4] := 232;           // unit dep link text (BAR/ATA) format n.n

  AddGlobalPar(780);
  GlobalSet[7, 8, 0] := 40;            // PPN2 WARNING=40dbar=4.0bar
  GlobalSet[7, 8, 1] := 10;
  GlobalSet[7, 8, 2] := 60;
  GlobalSet[7, 8, 3] := 1;
  GlobalSet[7, 8, 4] := 232;           // unit dep link text (BAR/ATA) format n.n

  GlobalSet[7, 9, 0] := COMMSAVE;      // CLOSE (command number = save)
  GlobalSet[7, 9, 1] := 12;            // arrow symbol
  GlobalSet[7, 9, 2] := 0;
  GlobalSet[7, 9, 3] := 0;
  GlobalSet[7, 9, 4] := 0;

  GlobalSet[8, 0, 0] := COMMBACK;      // PARAMETER (command number = return)
  GlobalSet[8, 0, 1] := 11;            // arrow symbol
  GlobalSet[8, 0, 2] := 16;            // pointer symbol
  GlobalSet[8, 0, 3] := 0;
  GlobalSet[8, 0, 4] := 80;            // 1st text number (pointer to Mask$)

  AddGlobalPar(810);
  GlobalSet[8, 1, 0] := 60;            // ACTIVATION DEPTH=60 cm
  GlobalSet[8, 1, 1] := 30;
  GlobalSet[8, 1, 2] := 240;
  GlobalSet[8, 1, 3] := 130;           // >100 -> convert incremental value too (30cm = 1ft)
  GlobalSet[8, 1, 4] := 250;           // unit dep link text (cm/ft)

  AddGlobalPar(820);
  GlobalSet[8, 2, 0] := 3;             // DECO LEVELS=3m
  GlobalSet[8, 2, 1] := 2;
  GlobalSet[8, 2, 2] := 6;
  GlobalSet[8, 2, 3] := 101;           // >100 -> convert incremental value too (1m = 3ft)
  GlobalSet[8, 2, 4] := 248;           // unit dep link text (m/ft)

  AddGlobalPar(830);
  GlobalSet[8, 3, 0] := 3;             // SAFETY TIME=3min
  GlobalSet[8, 3, 1] := 0;
  GlobalSet[8, 3, 2] := 6;
  GlobalSet[8, 3, 3] := 1;
  GlobalSet[8, 3, 4] := 0;

  AddGlobalPar(840);
  GlobalSet[8, 4, 0] := 0;             // DEEP STOPS=OFF
  GlobalSet[8, 4, 1] := 0;
  GlobalSet[8, 4, 2] := 1;
  GlobalSet[8, 4, 3] := 1;
  GlobalSet[8, 4, 4] := 138;           // help text number (+0/1)

  AddGlobalPar(850);
  GlobalSet[8, 5, 0] := 0;             // TRUE DEPTH=OFF
  GlobalSet[8, 5, 1] := 0;
  GlobalSet[8, 5, 2] := 1;
  GlobalSet[8, 5, 3] := 1;
  GlobalSet[8, 5, 4] := 138;           // help text number (+0/1)

  AddGlobalPar(860);
  GlobalSet[8, 6, 0] := 5;             // DIVE END=5min
  GlobalSet[8, 6, 1] := 1;
  GlobalSet[8, 6, 2] := 15;
  GlobalSet[8, 6, 3] := 1;
  GlobalSet[8, 6, 4] := 0;

  AddGlobalPar(870);
  GlobalSet[8, 7, 0] := 30;            // AUTO OFF=30min
  GlobalSet[8, 7, 1] := 10;
  GlobalSet[8, 7, 2] := 60;
  GlobalSet[8, 7, 3] := 5;
  GlobalSet[8, 7, 4] := 0;

  AddGlobalPar(880);
  GlobalSet[8, 8, 0] := 10;            // LOG INTERVAL=10s
  GlobalSet[8, 8, 1] := 4;
  GlobalSet[8, 8, 2] := 20;
  GlobalSet[8, 8, 3] := 2;
  GlobalSet[8, 8, 4] := 0;

  GlobalSet[8, 9, 0] := COMMSAVE;      // CLOSE (command number = save)
  GlobalSet[8, 9, 1] := 12;            // arrow symbol
  GlobalSet[8, 9, 2] := 0;
  GlobalSet[8, 9, 3] := 0;
  GlobalSet[8, 9, 4] := 0;
                                       // MENUDISP=9
  GlobalSet[9, 0, 0] := COMMBACK;      // DISPLAY (command number = return)
  GlobalSet[9, 0, 1] := 11;            // arrow symbol
  GlobalSet[9, 0, 2] := 16;            // pointer symbol
  GlobalSet[9, 0, 3] := 0;
  GlobalSet[9, 0, 4] := 90;            // 1st text number (pointer to Mask$)

  AddGlobalPar(910);
  GlobalSet[9, 1, 0] := 0;             // LANGUAGE=EN (english)
  GlobalSet[9, 1, 1] := 0;
  GlobalSet[9, 1, 2] := 1;
  GlobalSet[9, 1, 3] := 1;
  GlobalSet[9, 1, 4] := 121;           // help text number (+0/1)

  AddGlobalPar(920);
  GlobalSet[9, 2, 0] := 0;             // UNIT SYSTEM=MET (metric)
  GlobalSet[9, 2, 1] := 0;
  GlobalSet[9, 2, 2] := 1;
  GlobalSet[9, 2, 3] := 1;
  GlobalSet[9, 2, 4] := 130;           // help text number (+0/1)

  AddGlobalPar(930);
  GlobalSet[9, 3, 0] := 0;             // TIME FORMAT=EU
  GlobalSet[9, 3, 1] := 0;
  GlobalSet[9, 3, 2] := 2;
  GlobalSet[9, 3, 3] := 1;
  GlobalSet[9, 3, 4] := 135;           // help text number (+0..2)

  AddGlobalPar(940);
  GlobalSet[9, 4, 0] := 0;             // SUMMER TIME=NO
  GlobalSet[9, 4, 1] := 0;
  GlobalSet[9, 4, 2] := 2;
  GlobalSet[9, 4, 3] := 1;
  GlobalSet[9, 4, 4] := 134;           // help text number (+0..2)

  AddGlobalPar(950);
  GlobalSet[9, 5, 0] := 90;            // BRIGHTNESS=90%
  GlobalSet[9, 5, 1] := 10;
  GlobalSet[9, 5, 2] := 100;
  GlobalSet[9, 5, 3] := 10;
  GlobalSet[9, 5, 4] := 0;

  AddGlobalPar(960);
  GlobalSet[9, 6, 0] := 80;            // CONTRAST=80%
  GlobalSet[9, 6, 1] := 10;
  GlobalSet[9, 6, 2] := 100;
  GlobalSet[9, 6, 3] := 10;
  GlobalSet[9, 6, 4] := 0;

  AddGlobalPar(970);
  GlobalSet[9, 7, 0] := 5;             // BACKLIGHT=5sec
  GlobalSet[9, 7, 1] := 1;
  GlobalSet[9, 7, 2] := 30;
  GlobalSet[9, 7, 3] := 1;
  GlobalSet[9, 7, 4] := 0;

  AddGlobalPar(980);
  GlobalSet[9, 8, 0] := 70;            // LOUDNESS=70%
  GlobalSet[9, 8, 1] := 0;
  GlobalSet[9, 8, 2] := 100;
  GlobalSet[9, 8, 3] := 10;
  GlobalSet[9, 8, 4] := 0;

  GlobalSet[9, 9, 0] := COMMSAVE;      // CLOSE (command number = save)
  GlobalSet[9, 9, 1] := 12;            // arrow symbol
  GlobalSet[9, 9, 2] := 0;
  GlobalSet[9, 9, 3] := 0;
  GlobalSet[9, 9, 4] := 0;
                                       // MENUCLOCK=10
  GlobalSet[10, 0, 0] := COMMBACK;     // CLOCK (command number = return)
  GlobalSet[10, 0, 1] := 11;           // arrow symbol
  GlobalSet[10, 0, 2] := 16;           // pointer symbol
  GlobalSet[10, 0, 3] := 0;
  GlobalSet[10, 0, 4] := 100;          // 1st text number (pointer to Mask$)

  GlobalSet[10, 1, 0] := 0;            // YEAR=00
  GlobalSet[10, 1, 1] := 0;
  GlobalSet[10, 1, 2] := 25;
  GlobalSet[10, 1, 3] := 1;
  GlobalSet[10, 1, 4] := 0;

  GlobalSet[10, 2, 0] := 1;             // MONTH=01
  GlobalSet[10, 2, 1] := 1;
  GlobalSet[10, 2, 2] := 12;
  GlobalSet[10, 2, 3] := 1;
  GlobalSet[10, 2, 4] := 0;

  GlobalSet[10, 3, 0] := 1;             // DAY=01
  GlobalSet[10, 3, 1] := 1;
  GlobalSet[10, 3, 2] := 31;
  GlobalSet[10, 3, 3] := 1;
  GlobalSet[10, 3, 4] := 0;

  GlobalSet[10, 4, 0] := 0;             // HOUR=00
  GlobalSet[10, 4, 1] := 0;
  GlobalSet[10, 4, 2] := 23;
  GlobalSet[10, 4, 3] := 1;
  GlobalSet[10, 4, 4] := 2;             // time format dep. link text (AM/PM)

  GlobalSet[10, 5, 0] := 0;             // MINUTE=00
  GlobalSet[10, 5, 1] := 0;
  GlobalSet[10, 5, 2] := 59;
  GlobalSet[10, 5, 3] := 1;
  GlobalSet[10, 5, 4] := 0;

  AddGlobalPar(1060);
  GlobalSet[10, 6, 0] := 0;             // ALARM SET=OFF
  GlobalSet[10, 6, 1] := 0;
  GlobalSet[10, 6, 2] := 1;
  GlobalSet[10, 6, 3] := 1;
  GlobalSet[10, 6, 4] := 138;           // help text number (+0/1)

  AddGlobalPar(1070);
  GlobalSet[10, 7, 0] := 0;             // ALARM HOUR=00
  GlobalSet[10, 7, 1] := 0;
  GlobalSet[10, 7, 2] := 23;
  GlobalSet[10, 7, 3] := 1;
  GlobalSet[10, 7, 4] := 2;             // time format dep. link text (AM/PM)

  AddGlobalPar(1080);
  GlobalSet[10, 8, 0] := 0;             // ALARM MINUTE=00
  GlobalSet[10, 8, 1] := 0;
  GlobalSet[10, 8, 2] := 59;
  GlobalSet[10, 8, 3] := 1;
  GlobalSet[10, 8, 4] := 0;

  GlobalSet[10, 9, 0] := 58;            // CLOSE (command number = set clock)
  GlobalSet[10, 9, 1] := 12;            // arrow symbol
  GlobalSet[10, 9, 2] := 0;
  GlobalSet[10, 9, 3] := 0;
  GlobalSet[10, 9, 4] := 0;

  GlobalSet[11, 0, 0] := COMMBACK;      // GAS MIXES (command number = return)
  GlobalSet[11, 0, 1] := 11;            // arrow symbol
  GlobalSet[11, 0, 2] := 16;            // pointer symbol
  GlobalSet[11, 0, 3] := 0;
  GlobalSet[11, 0, 4] := 110;           // 1st text number (pointer to Mask$)

  AddGlobalPar(1110);
  GlobalSet[11, 1, 0] := 0;
  GlobalSet[11, 1, 1] := 0;
  GlobalSet[11, 1, 2] := 0;
  GlobalSet[11, 1, 3] := 0;
  GlobalSet[11, 1, 4] := 0;

  AddGlobalPar(1120);
  GlobalSet[11, 2, 0] := 0;
  GlobalSet[11, 2, 1] := 0;
  GlobalSet[11, 2, 2] := 0;
  GlobalSet[11, 2, 3] := 0;
  GlobalSet[11, 2, 4] := 0;

  AddGlobalPar(1130);
  GlobalSet[11, 3, 0] := 0;
  GlobalSet[11, 3, 1] := 0;
  GlobalSet[11, 3, 2] := 0;
  GlobalSet[11, 3, 3] := 0;
  GlobalSet[11, 3, 4] := 0;

  AddGlobalPar(1140);
  GlobalSet[11, 4, 0] := 0;
  GlobalSet[11, 4, 1] := 0;
  GlobalSet[11, 4, 2] := 0;
  GlobalSet[11, 4, 3] := 0;
  GlobalSet[11, 4, 4] := 0;

  AddGlobalPar(1150);
  GlobalSet[11, 5, 0] := 0;
  GlobalSet[11, 5, 1] := 0;
  GlobalSet[11, 5, 2] := 0;
  GlobalSet[11, 5, 3] := 0;
  GlobalSet[11, 5, 4] := 0;

  AddGlobalPar(1160);
  GlobalSet[11, 6, 0] := 0;
  GlobalSet[11, 6, 1] := 0;
  GlobalSet[11, 6, 2] := 0;
  GlobalSet[11, 6, 3] := 0;
  GlobalSet[11, 6, 4] := 0;

  AddGlobalPar(1170);
  GlobalSet[11, 7, 0] := 0;
  GlobalSet[11, 7, 1] := 0;
  GlobalSet[11, 7, 2] := 0;
  GlobalSet[11, 7, 3] := 0;
  GlobalSet[11, 7, 4] := 0;

  AddGlobalPar(1180);
  GlobalSet[11, 8, 0] := 0;
  GlobalSet[11, 8, 1] := 0;
  GlobalSet[11, 8, 2] := 0;
  GlobalSet[11, 8, 3] := 0;
  GlobalSet[11, 8, 4] := 0;

  GlobalSet[11, 9, 0] := COMMSAVE;      // CLOSE (command number = save)
  GlobalSet[11, 9, 1] := 12;            // arrow symbol
  GlobalSet[11, 9, 2] := 0;
  GlobalSet[11, 9, 3] := 0;
  GlobalSet[11, 9, 4] := 0;

  //02.02.07 nk add new window DIVE PLANNER  TIGER add ff
  GlobalSet[12, 0, 0] := COMMBACK;      // DIVE PLANNER (command number = return)
  GlobalSet[12, 0, 1] := 11;            // arrow symbol
  GlobalSet[12, 0, 2] := 16;            // pointer symbol
  GlobalSet[12, 0, 3] := 0;
  GlobalSet[12, 0, 4] := 200;           // 1st text number (pointer to Mask$)

  GlobalSet[12, 1, 0] := 0;             // ALTITUDE=0hm
  GlobalSet[12, 1, 1] := 0;
  GlobalSet[12, 1, 2] := 40;
  GlobalSet[12, 1, 3] := 101;           // >100 -> convert incremental value too (1hm = 3hft)
  GlobalSet[12, 1, 4] := 230;           // unit dep link text (hm/hft)

  GlobalSet[12, 2, 0] := 30;            // DIVE DEPTH=30m
  GlobalSet[12, 2, 1] := 9;
  GlobalSet[12, 2, 2] := 198;
  GlobalSet[12, 2, 3] := 103;           // >100 -> convert incremental value too (3m = 10ft)
  GlobalSet[12, 2, 4] := 252;           // unit dep link text (m/ft)

  GlobalSet[12, 3, 0] := 40;            // DIVE TIME=40mim
  GlobalSet[12, 3, 1] := 10;
  GlobalSet[12, 3, 2] := 180;
  GlobalSet[12, 3, 3] := 2;
  GlobalSet[12, 3, 4] := 0;

  GlobalSet[12, 4, 0] := 100;           // AIR PRESSURE=100kPa
  GlobalSet[12, 4, 1] := 0;
  GlobalSet[12, 4, 2] := 1;
  GlobalSet[12, 4, 3] := 101;           // >100 -> convert incremental value too
  GlobalSet[12, 4, 4] := 228;           // unit dep link text (kPa/inHg)

  GlobalSet[12, 5, 0] := 0;             //
  GlobalSet[12, 5, 1] := 0;
  GlobalSet[12, 5, 2] := 1;
  GlobalSet[12, 5, 3] := 1;
  GlobalSet[12, 5, 4] := 0;

  GlobalSet[12, 6, 0] := 5;             //
  GlobalSet[12, 6, 1] := 1;
  GlobalSet[12, 6, 2] := 15;
  GlobalSet[12, 6, 3] := 1;
  GlobalSet[12, 6, 4] := 0;

  GlobalSet[12, 7, 0] := 30;            //
  GlobalSet[12, 7, 1] := 10;
  GlobalSet[12, 7, 2] := 60;
  GlobalSet[12, 7, 3] := 5;
  GlobalSet[12, 7, 4] := 0;

  GlobalSet[12, 8, 0] := 10;            //
  GlobalSet[12, 8, 1] := 4;
  GlobalSet[12, 8, 2] := 20;
  GlobalSet[12, 8, 3] := 2;
  GlobalSet[12, 8, 4] := 0;

  GlobalSet[12, 9, 0] := COMMEXIT;      // CLOSE (command number = exit)
  GlobalSet[12, 9, 1] := 12;            // arrow symbol
  GlobalSet[12, 9, 2] := 0;
  GlobalSet[12, 9, 3] := 0;
  GlobalSet[12, 9, 4] := 0;

  DatBuff := IntToStr(SETMENU * SETBOX);
  LogEvent('InitGlobalData', 'Global sets initialized', DatBuff);
end;

//------------------------------------------------------------------------------
// INITAPPLICATION - Initialize application specific windows, boxes and objects
//------------------------------------------------------------------ 17.02.07 --
procedure InitApplication;
var
  i, j: Long;
begin
  // clear window specifications
  for i := 0 to MAXWIN - 1 do begin
    for j := 0 to WINDEF - 1 do begin
      WinSpec[i, j] := cCLEAR;
    end;
  end;

  // clear box specifications
  for i := 0 to MAXBOX - 1 do begin
    for j := 0 to BOXDEF - 1 do begin
      BoxSpec[i, j] := cCLEAR;
    end;
  end;

  // clear object specifications
  for i := 0 to MAXOBJ - 1 do begin
    for j := 0 to OBJDEF - 1 do begin
      ObjSpec[i, j] := cCLEAR;
    end;
  end;

// 17.02.07 nk opt new priorities
// - bit 00 - temperature warning      - bit 08 - gas time warning
// - bit 01 - breath rate warning      - bit 09 - acsent speed alarm
// - bit 02 - dive depth warning       - bit 10 - tank pressure alarm
// - bit 03 - acsent speed warning     - bit 11 - accu power alarm
// - bit 04 - tank pressure warning    - bit 12 - deco violation alarm
// - bit 05 - accu power warning       - bit 13 - oxygen dose alarm
// - bit 06 - oxygen dose warning      - bit 14 - oxygen pressure alarm
// - bit 07 - oxygen pressure warning  - bit 15 - gas time alarm

// Caution: ObjSpec ranges from 1..16 (0=no signal to handle)

  ObjSpec[1, 0] :=   0;  // xpos = middle     temperature warning
  ObjSpec[1, 1] :=   0;  // ypos = middle
  ObjSpec[1, 2] :=   5;  // head = low temperature = Mask[270+5]
  ObjSpec[1, 3] :=   0;  // body = none
  ObjSpec[1, 4] :=   0;  // tail = none
  ObjSpec[1, 5] :=   0;  // keys = none
  ObjSpec[1, 6] :=   3;  // icon = warning
  ObjSpec[1, 7] := 100;  // tone = 100ms
  ObjSpec[1, 8] :=   2;  // life = 2s
  ObjSpec[1, 9] :=  60;  // lock = 60s

  ObjSpec[2, 0] :=   0;  // xpos = middle     breath rate warning
  ObjSpec[2, 1] :=   0;  // ypos = middle
  ObjSpec[2, 2] :=   6;  // head = slow breath rate = Mask[270+6]
  ObjSpec[2, 3] :=   0;  // body = none
  ObjSpec[2, 4] :=   0;  // tail = none
  ObjSpec[2, 5] :=   0;  // keys = none
  ObjSpec[2, 6] :=   3;  // icon = warning
  ObjSpec[2, 7] := 100;  // tone = 100ms
  ObjSpec[2, 8] :=   2;  // life = 2s
  ObjSpec[2, 9] :=   4;  // lock = 4s

  ObjSpec[3, 0] :=   0;  // xpos = middle     dive depth warning
  ObjSpec[3, 1] :=   0;  // ypos = middle
  ObjSpec[3, 2] :=   7;  // head = check depth = Mask[270+7]
  ObjSpec[3, 3] :=   0;  // body = none
  ObjSpec[3, 4] :=   0;  // tail = none
  ObjSpec[3, 5] :=   0;  // keys = none
  ObjSpec[3, 6] :=   3;  // icon = warning
  ObjSpec[3, 7] := 100;  // tone = 100ms
  ObjSpec[3, 8] :=   2;  // life = 2s
  ObjSpec[3, 9] :=  60;  // lock = 60s

  ObjSpec[4, 0] :=   0;  // xpos = middle     ascent speed warning
  ObjSpec[4, 1] :=   0;  // ypos = middle
  ObjSpec[4, 2] :=   8;  // head = ascend slower = Mask[270+8]
  ObjSpec[4, 3] :=   0;  // body = none
  ObjSpec[4, 4] :=   0;  // tail = none
  ObjSpec[4, 5] :=   0;  // keys = none
  ObjSpec[4, 6] :=   3;  // icon = warning
  ObjSpec[4, 7] := 100;  // tone = 100ms
  ObjSpec[4, 8] :=   2;  // life = 2s
  ObjSpec[4, 9] :=   2;  // lock = 2s

  ObjSpec[5, 0] :=   0;  // xpos = middle     tank pressure warning
  ObjSpec[5, 1] :=   0;  // ypos = middle
  ObjSpec[5, 2] :=   9;  // head = check tank = Mask[270+9]
  ObjSpec[5, 3] :=   0;  // body = none
  ObjSpec[5, 4] :=   0;  // tail = none
  ObjSpec[5, 5] :=   0;  // keys = none
  ObjSpec[5, 6] :=   3;  // icon = warning
  ObjSpec[5, 7] := 100;  // tone = 100ms
  ObjSpec[5, 8] :=   3;  // life = 3s
  ObjSpec[5, 9] := 120;  // lock = 120s

  ObjSpec[6, 0] :=   0;  // xpos = middle     accu power warning
  ObjSpec[6, 1] :=   0;  // ypos = middle
  ObjSpec[6, 2] :=  10;  // head = check accu power = Mask[270+10]
  ObjSpec[6, 3] :=   0;  // body = none
  ObjSpec[6, 4] :=   0;  // tail = none
  ObjSpec[6, 5] :=   0;  // keys = none
  ObjSpec[6, 6] :=   3;  // icon = warning
  ObjSpec[6, 7] := 100;  // tone = 100ms
  ObjSpec[6, 8] :=   2;  // life = 2s
  ObjSpec[6, 9] :=  60;  // lock = 60s

  ObjSpec[7, 0] :=   0;  // xpos = middle     oxygen dose warning
  ObjSpec[7, 1] :=   0;  // ypos = middle
  ObjSpec[7, 2] :=  11;  // head = check oxygen dose = Mask[270+11]
  ObjSpec[7, 3] :=   0;  // body = none
  ObjSpec[7, 4] :=   0;  // tail = none
  ObjSpec[7, 5] :=   0;  // keys = none
  ObjSpec[7, 6] :=   3;  // icon = warning
  ObjSpec[7, 7] := 100;  // tone = 100ms
  ObjSpec[7, 8] :=   2;  // life = 2s
  ObjSpec[7, 9] :=  30;  // lock = 30s

  ObjSpec[8, 0] :=   0;  // xpos = middle     oxygen pressure warning
  ObjSpec[8, 1] :=   0;  // ypos = middle
  ObjSpec[8, 2] :=  12;  // head = check oxygen pressure = Mask[270+12]
  ObjSpec[8, 3] :=   0;  // body = none
  ObjSpec[8, 4] :=   0;  // tail = none
  ObjSpec[8, 5] :=   0;  // keys = none
  ObjSpec[8, 6] :=   3;  // icon = warning
  ObjSpec[8, 7] := 100;  // tone = 100ms
  ObjSpec[8, 8] :=   2;  // life = 2s
  ObjSpec[8, 9] :=  20;  // lock = 20s

  ObjSpec[9, 0] :=   0;  // xpos = middle     gas time warning
  ObjSpec[9, 1] :=   0;  // ypos = middle
  ObjSpec[9, 2] :=  13;  // head = check gas = Mask[270+13]
  ObjSpec[9, 3] :=   0;  // body = none
  ObjSpec[9, 4] :=   0;  // tail = none
  ObjSpec[9, 5] :=   0;  // keys = none
  ObjSpec[9, 6] :=   3;  // icon = warning
  ObjSpec[9, 7] := 100;  // tone = 100ms
  ObjSpec[9, 8] :=   2;  // life = 2s
  ObjSpec[9, 9] :=  20;  // lock = 20s

  ObjSpec[10, 0] :=   0;  // xpos = middle     acsent speed alarm
  ObjSpec[10, 1] :=   0;  // ypos = middle
  ObjSpec[10, 2] :=  14;  // head = ascend slower = Mask[270+14]
  ObjSpec[10, 3] :=   0;  // body = none
  ObjSpec[10, 4] :=   0;  // tail = none
  ObjSpec[10, 5] :=   0;  // keys = none
  ObjSpec[10, 6] :=   2;  // icon = danger
  ObjSpec[10, 7] := 200;  // tone = 200ms
  ObjSpec[10, 8] :=   3;  // life = 3s
  ObjSpec[10, 9] :=   1;  // lock = 1s

  ObjSpec[11, 0] :=   0;  // xpos = middle     tank pressure alarm
  ObjSpec[11, 1] :=   0;  // ypos = middle
  ObjSpec[11, 2] :=  15;  // head = check tank = Mask[270+15]
  ObjSpec[11, 3] :=   0;  // body = none
  ObjSpec[11, 4] :=   0;  // tail = none
  ObjSpec[11, 5] :=   0;  // keys = none
  ObjSpec[11, 6] :=   2;  // icon = danger
  ObjSpec[11, 7] := 250;  // tone = 250ms
  ObjSpec[11, 8] :=   4;  // life = 4s
  ObjSpec[11, 9] :=  20;  // lock = 20s

  ObjSpec[12, 0] :=   0;  // xpos = middle     accu power alarm
  ObjSpec[12, 1] :=   0;  // ypos = middle
  ObjSpec[12, 2] :=  16;  // head = low accu power = Mask[270+16]
  ObjSpec[12, 3] :=   0;  // body = none
  ObjSpec[12, 4] :=   0;  // tail = none
  ObjSpec[12, 5] :=   0;  // keys = none
  ObjSpec[12, 6] :=   2;  // icon = danger
  ObjSpec[12, 7] := 252;  // tone = TONERING
  ObjSpec[12, 8] :=   4;  // life = 4s
  ObjSpec[12, 9] :=  20;  // lock = 20s

  ObjSpec[13, 0] :=   0;  // xpos = middle     deco violation alarm
  ObjSpec[13, 1] :=   0;  // ypos = middle
  ObjSpec[13, 2] :=  17;  // head = deco violation = Mask[270+17]
  ObjSpec[13, 3] :=   0;  // body = none
  ObjSpec[13, 4] :=   0;  // tail = none
  ObjSpec[13, 5] :=   0;  // keys = none
  ObjSpec[13, 6] :=   2;  // icon = danger
  ObjSpec[13, 7] := 252;  // tone = TONERING
  ObjSpec[13, 8] :=   4;  // life = 4s
  ObjSpec[13, 9] :=  10;  // lock = 10s

  ObjSpec[14, 0] :=   0;  // xpos = middle     oxygen dose alarm
  ObjSpec[14, 1] :=   0;  // ypos = middle
  ObjSpec[14, 2] :=  18;  // head = high oxygen dose = Mask[270+18]
  ObjSpec[14, 3] :=   0;  // body = none
  ObjSpec[14, 4] :=   0;  // tail = none
  ObjSpec[14, 5] :=   0;  // keys = none
  ObjSpec[14, 6] :=   2;  // icon = danger
  ObjSpec[14, 7] := 252;  // tone = TONERING
  ObjSpec[14, 8] :=   4;  // life = 4s
  ObjSpec[14, 9] :=  10;  // lock = 10s

  ObjSpec[15, 0] :=   0;  // xpos = middle     oxygen pressure alarm
  ObjSpec[15, 1] :=   0;  // ypos = middle
  ObjSpec[15, 2] :=  19;  // head = check oxygen pressure = Mask[270+19]
  ObjSpec[15, 3] :=   0;  // body = none
  ObjSpec[15, 4] :=   0;  // tail = none
  ObjSpec[15, 5] :=   0;  // keys = none
  ObjSpec[15, 6] :=   2;  // icon = danger
  ObjSpec[15, 7] := 252;  // tone = TONERING
  ObjSpec[15, 8] :=   4;  // life = 4s
  ObjSpec[15, 9] :=  10;  // lock = 10s

  ObjSpec[16, 0] :=   0;  // xpos = middle     gas time alarm
  ObjSpec[13, 1] :=   0;  // ypos = middle
  ObjSpec[16, 2] :=  20;  // head = check gas = Mask[270+20]
  ObjSpec[16, 3] :=   0;  // body = none
  ObjSpec[16, 4] :=   0;  // tail = none
  ObjSpec[16, 5] :=   0;  // keys = none
  ObjSpec[16, 6] :=   2;  // icon = danger
  ObjSpec[16, 7] := 252;  // tone = TONERING
  ObjSpec[16, 8] :=   4;  // life = 4s
  ObjSpec[16, 9] :=  10;  // lock = 10s

  //message windows
  ObjSpec[17, 0] :=   0;  // xpos = middle     save data message //nk// new CLEAR MEM
  ObjSpec[17, 1] :=   0;  // ypos = middle
  ObjSpec[17, 2] :=  21;  // head = save data = Mask[270+21]
  ObjSpec[17, 3] :=   0;  // body = none
  ObjSpec[17, 4] :=   0;  // tail = none
  ObjSpec[17, 5] :=   0;  // keys = none
  ObjSpec[17, 6] :=   1;  // icon = waiting
  ObjSpec[17, 7] :=   0;  // tone = none
  ObjSpec[17, 8] :=   4;  // DELPHI 4s (Tiger=0 live until finished)
  ObjSpec[17, 9] :=   0;  // lock = none

  ObjSpec[18, 0] :=   0;  // xpos = middle     alarm clock message
  ObjSpec[18, 1] :=   0;  // ypos = middle
  ObjSpec[18, 2] :=   1;  // head = dynamic text (actual time)
  ObjSpec[18, 3] :=   0;  // body = none
  ObjSpec[18, 4] :=   2;  // tail = alarm off  = Mask[270+2]
  ObjSpec[18, 5] :=   2;  // keys = right = turn signal off (other key repeat alarm)
  ObjSpec[18, 6] :=   7;  // icon = clock
  ObjSpec[18, 7] := 253;  // tone = alarm (repeated ring)
  ObjSpec[18, 8] :=   0;  // life = endless
  ObjSpec[18, 9] := 120;  // lock = 120s

  DatBuff := IntToStr(MAXOBJ);
  LogEvent('InitApplication', 'Objects initialized', DatBuff);

  // WinSpec[x, 0] reserved for future use (always 0)

  WinSpec[0, 1] :=   0;  // xs  main window = workspace
  WinSpec[0, 2] :=   0;  // ys
  WinSpec[0, 3] :=   LCDXRANGE;
  WinSpec[0, 4] :=   LCDYRANGE;
  WinSpec[0, 5] :=   0;  // special effect
  WinSpec[0, 6] :=   0;  // window type

  WinSpec[1, 1] :=   5;  // xs  depth / baro window
  WinSpec[1, 2] :=   5;  // ys
  WinSpec[1, 3] :=  57;  // dx
  WinSpec[1, 4] :=  62;  // dy
  WinSpec[1, 5] :=   0;  // special effect
  WinSpec[1, 6] :=   1;  // window type

  WinSpec[2, 1] :=  66;  // xs  clock / time window
  WinSpec[2, 2] :=   5;  // ys
  WinSpec[2, 3] :=  57;  // dx
  WinSpec[2, 4] :=  62;  // dy
  WinSpec[2, 5] :=   0;  // special effect
  WinSpec[2, 6] :=   1;  // window type

  WinSpec[3, 1] :=   5;  // xs  power / gas window
  WinSpec[3, 2] :=  71;  // ys
  WinSpec[3, 3] :=  57;  // dx
  WinSpec[3, 4] :=  52;  // dy
  WinSpec[3, 5] :=   0;  // special effect
  WinSpec[3, 6] :=   2;  // window type

  WinSpec[4, 1] :=  66;  // xs  deco window
  WinSpec[4, 2] :=  71;  // ys
  WinSpec[4, 3] :=  57;  // dx
  WinSpec[4, 4] :=  52;  // dy
  WinSpec[4, 5] :=   0;  // special effect
  WinSpec[4, 6] :=   2;  // window type

  WinSpec[5, 1] :=   5;  // xs  navigation / saturation window
  WinSpec[5, 2] :=  71;  // ys
  WinSpec[5, 3] := 118;  // dx
  WinSpec[5, 4] :=  52;  // dy
  WinSpec[5, 5] :=   0;  // special effect
  WinSpec[5, 6] :=   3;  // window type

  WinSpec[6, 1] :=  10;  // xs  main selection / dive planner window
  WinSpec[6, 2] :=  10;  // ys
  WinSpec[6, 3] := 104;  // dx
  WinSpec[6, 4] := 105;  // dy
  WinSpec[6, 5] :=   1;  // special effect
  WinSpec[6, 6] :=   4;  // window type

  WinSpec[8, 1] :=   9;  // xs  calendar window
  WinSpec[8, 2] :=   9;  // ys
  WinSpec[8, 3] := 104;  // dx
  WinSpec[8, 4] := 115;  // dy
  WinSpec[8, 5] :=   0;  // special effect
  WinSpec[8, 6] :=   5;  // window type

  WinSpec[9, 1] :=   8;  // xs  dive profile / log book window
  WinSpec[9, 2] :=   8;  // ys
  WinSpec[9, 3] := 112;  // dx
  WinSpec[9, 4] := 117;  // dy
  WinSpec[9, 5] :=   0;  // special effect
  WinSpec[9, 6] :=   6;  // window type

  WinSpec[10, 1] :=   8;  // xs  dive catalog
  WinSpec[10, 2] :=   8;  // ys
  WinSpec[10, 3] := 112;  // dx
  WinSpec[10, 4] := 117;  // dy
  WinSpec[10, 5] :=   0;  // special effect
  WinSpec[10, 6] :=   7;  // window type

  DatBuff := IntToStr(MAXWIN);
  LogEvent('InitApplication', 'Windows initialized', DatBuff);

  // BoxSpec[x, 0] reserved for future use (always 0)

// Window DEPTH
// ************

  BoxSpec[0, 1] :=   1;  // win    header [DEPTH]
  BoxSpec[0, 2] :=   4;  // xs
  BoxSpec[0, 3] :=   4;  // ys
  BoxSpec[0, 4] :=  49;  // dx
  BoxSpec[0, 5] :=   9;  // dy
  BoxSpec[0, 6] :=   1;  // text orientation (1=mid)
  BoxSpec[0, 7] :=   4;  // font
  BoxSpec[0, 8] :=   0;  // dmax/dnum  [total digits / decimal digits]
  BoxSpec[0, 9] :=  03;  // ddel/dmod  [delimiter sign-10 / drawing mode]

  BoxSpec[1, 1] :=   1;  // win    dive depth 0.1-99.9
  BoxSpec[1, 2] :=   9;  // xs
  BoxSpec[1, 3] :=  17;  // ys
  BoxSpec[1, 4] :=  34;  // dx
  BoxSpec[1, 5] :=  14;  // dy
  BoxSpec[1, 6] :=   0;  // res
  BoxSpec[1, 7] :=   9;  // font
  BoxSpec[1, 8] :=  31;  // dmax/dnum  [total digits / decimal digits]
  BoxSpec[1, 9] :=  10;  // ddel/dmod  [delimiter sign-10 / drawing mode]

  BoxSpec[2, 1] :=   1;  // win    dive depth 100-999
  BoxSpec[2, 2] :=  13;  // xs
  BoxSpec[2, 3] :=  17;  // ys
  BoxSpec[2, 4] :=  30;  // dx
  BoxSpec[2, 5] :=  14;  // dy
  BoxSpec[2, 6] :=   0;  // res
  BoxSpec[2, 7] :=   9;  // font
  BoxSpec[2, 8] :=  30;  // dmax/dnum
  BoxSpec[2, 9] :=  00;  // ddel/dmod

  BoxSpec[3, 1] :=   1;  // win    depth unit symbol [m/ft]
  BoxSpec[3, 2] :=  44;  // xs
  BoxSpec[3, 3] :=  24;  // ys
  BoxSpec[3, 4] :=   7;  // dx
  BoxSpec[3, 5] :=   7;  // dy
  BoxSpec[3, 6] :=   0;  // res
  BoxSpec[3, 7] :=   1;  // px  (x-pos in the box)
  BoxSpec[3, 8] :=   1;  // py  (y-pos in the box)
  BoxSpec[3, 9] :=  00;  // res/dmod

  BoxSpec[4, 1] :=   1;  // win    dive speed
  BoxSpec[4, 2] :=  10;  // xs
  BoxSpec[4, 3] :=  35;  // ys
  BoxSpec[4, 4] :=  19;  // dx
  BoxSpec[4, 5] :=   9;  // dy
  BoxSpec[4, 6] :=   0;  // res
  BoxSpec[4, 7] :=   7;  // font
  BoxSpec[4, 8] :=  30;  // dmax/dnum
  BoxSpec[4, 9] :=  00;  // ddel/dmod

  BoxSpec[5, 1] :=   1;  // win    percent sign symbol
  BoxSpec[5, 2] :=  29;  // xs
  BoxSpec[5, 3] :=  35;  // ys
  BoxSpec[5, 4] :=   9;  // dx
  BoxSpec[5, 5] :=   9;  // dy
  BoxSpec[5, 6] :=   0;  // res
  BoxSpec[5, 7] :=   1;  // px  (x-pos in the box)
  BoxSpec[5, 8] :=   1;  // py  (y-pos in the box)
  BoxSpec[5, 9] :=  00;  // res/dmod

  BoxSpec[6, 1] :=   1;  // win    dive direction symbol
  BoxSpec[6, 2] :=  39;  // xs
  BoxSpec[6, 3] :=  34;  // ys
  BoxSpec[6, 4] :=   9;  // dx
  BoxSpec[6, 5] :=  11;  // dy
  BoxSpec[6, 6] :=   0;  // res
  BoxSpec[6, 7] :=   1;  // px  (x-pos in the box)
  BoxSpec[6, 8] :=   1;  // py  (y-pos in the box)
  BoxSpec[6, 9] :=  00;  // res/dmod

  BoxSpec[7, 1] :=   1;  // win    max depth 0.1-99.9
  BoxSpec[7, 2] :=  12;  // xs
  BoxSpec[7, 3] :=  48;  // ys
  BoxSpec[7, 4] :=  21;  // dx
  BoxSpec[7, 5] :=   9;  // dy
  BoxSpec[7, 6] :=   0;  // res
  BoxSpec[7, 7] :=   7;  // font
  BoxSpec[7, 8] :=  31;  // dmax/dnum
  BoxSpec[7, 9] :=  10;  // ddel/dmod

  BoxSpec[8, 1] :=   1;  // win    max depth 100-999
  BoxSpec[8, 2] :=  14;  // xs
  BoxSpec[8, 3] :=  48;  // ys
  BoxSpec[8, 4] :=  19;  // dx
  BoxSpec[8, 5] :=   9;  // dy
  BoxSpec[8, 6] :=   0;  // res
  BoxSpec[8, 7] :=   7;  // font
  BoxSpec[8, 8] :=  30;  // dmax/dnum
  BoxSpec[8, 9] :=  00;  // ddel/dmod

  BoxSpec[9, 1] :=   1;  // win    maximal depth text [MAX]
  BoxSpec[9, 2] :=  34;  // xs
  BoxSpec[9, 3] :=  50;  // ys
  BoxSpec[9, 4] :=  17;  // dx
  BoxSpec[9, 5] :=   7;  // dy
  BoxSpec[9, 6] :=   0;  // text orientation (0=left)
  BoxSpec[9, 7] :=   2;  // font
  BoxSpec[9, 8] :=   0;  // dmax/dnum
  BoxSpec[9, 9] :=   0;  // res/dmod

  BoxSpec[11, 1] :=   1;  // win    box frame for DiveSpeed
  BoxSpec[11, 2] :=   6;  // xs
  BoxSpec[11, 3] :=  33;  // ys
  BoxSpec[11, 4] :=  45;  // dx
  BoxSpec[11, 5] :=  13;  // dy
  BoxSpec[11, 6] :=   1;  // box type [rounded edges]
  BoxSpec[11, 7] :=   0;  // font
  BoxSpec[11, 8] :=  01;  // dmax/dnum
  BoxSpec[11, 9] :=   0;  // ddel/dmod  [delimiter sign-10 / drawing mode]

// Window TIME
// ***********

  BoxSpec[10, 1] :=   2;  // win    header (TIME)
  BoxSpec[10, 2] :=   4;  // xs
  BoxSpec[10, 3] :=   4;  // ys
  BoxSpec[10, 4] :=  49;  // dx
  BoxSpec[10, 5] :=   9;  // dy
  BoxSpec[10, 6] :=   1;  // text orientation (1=mid)
  BoxSpec[10, 7] :=   4;  // font
  BoxSpec[10, 8] :=   0;  // dmax/dnum
  BoxSpec[10, 9] :=  03;  // ddel/inv

// BoxSpec[11] used in DEPTH !

  BoxSpec[12, 1] :=   2;  // win    dive time   :00-9:59
  BoxSpec[12, 2] :=  11;  // xs
  BoxSpec[12, 3] :=  17;  // ys
  BoxSpec[12, 4] :=  34;  // dx
  BoxSpec[12, 5] :=  14;  // dy
  BoxSpec[12, 6] :=   0;  // res
  BoxSpec[12, 7] :=   9;  // font
  BoxSpec[12, 8] :=  32;  // dmax/dnum
  BoxSpec[12, 9] :=  20;  // ddel/dmod

  BoxSpec[13, 1] :=   2;  // win    remain gas time/total dive time :00- 99:59
  BoxSpec[13, 2] :=   7;  // xs
  BoxSpec[13, 3] :=  35;  // ys
  BoxSpec[13, 4] :=  27;  // dx
  BoxSpec[13, 5] :=   9;  // dy
  BoxSpec[13, 6] :=   0;  // res
  BoxSpec[13, 7] :=   7;  // font
  BoxSpec[13, 8] :=  42;  // dmax/dnum
  BoxSpec[13, 9] :=  20;  // ddel/dmod

  BoxSpec[14, 1] :=   2;  // win    remain gas time/total dive time text (REM/TDT)
  BoxSpec[14, 2] :=  35;  // xs
  BoxSpec[14, 3] :=  37;  // ys
  BoxSpec[14, 4] :=  18;  // dx
  BoxSpec[14, 5] :=   7;  // dy
  BoxSpec[14, 6] :=   0;  // text orientation (0=left)
  BoxSpec[14, 7] :=   2;  // font
  BoxSpec[14, 8] :=   0;  // dmax/dnum
  BoxSpec[14, 9] :=   0;  // res/dmod

  BoxSpec[15, 1] :=   2;  // win    ascent/interval/surface time :00 - 99:59
  BoxSpec[15, 2] :=   7;  // xs
  BoxSpec[15, 3] :=  48;  // ys
  BoxSpec[15, 4] :=  27;  // dx
  BoxSpec[15, 5] :=   9;  // dy
  BoxSpec[15, 6] :=   0;  // res
  BoxSpec[15, 7] :=   7;  // font
  BoxSpec[15, 8] :=  42;  // dmax/dnum
  BoxSpec[15, 9] :=  20;  // ddel/dmod

  BoxSpec[16, 1] :=   2;  // win    arrow up symbol
  BoxSpec[16, 2] :=  35;  // xs
  BoxSpec[16, 3] :=  48;  // ys
  BoxSpec[16, 4] :=   9;  // dx
  BoxSpec[16, 5] :=   9;  // dy
  BoxSpec[16, 6] :=   0;  // res
  BoxSpec[16, 7] :=   1;  // px  (x-pos in the box)
  BoxSpec[16, 8] :=   1;  // py  (y-pos in the box)
  BoxSpec[16, 9] :=  00;  // res/dmod

  BoxSpec[17, 1] :=   2;  // win    dive number 1-9
  BoxSpec[17, 2] :=  44;  // xs
  BoxSpec[17, 3] :=  48;  // ys
  BoxSpec[17, 4] :=   7;  // dx
  BoxSpec[17, 5] :=   9;  // dy
  BoxSpec[17, 6] :=   0;  // res
  BoxSpec[17, 7] :=   7;  // font
  BoxSpec[17, 8] :=  10;  // dmax/dnum
  BoxSpec[17, 9] :=  00;  // res/dmod

  BoxSpec[18, 1] :=   2;  // win    dive time   10:00 - 99:59 (use box 12 if < 9:59)
  BoxSpec[18, 2] :=   6;  // xs
  BoxSpec[18, 3] :=  17;  // ys
  BoxSpec[18, 4] :=  44;  // dx
  BoxSpec[18, 5] :=  14;  // dy
  BoxSpec[18, 6] :=   0;  // res
  BoxSpec[18, 7] :=   9;  // font
  BoxSpec[18, 8] :=  42;  // dmax/dnum
  BoxSpec[18, 9] :=  20;  // ddel/dmod

// Window DECO
// ***********

  BoxSpec[20, 1] :=   4;  // win    header (DECO)
  BoxSpec[20, 2] :=   4;  // xs
  BoxSpec[20, 3] :=   4;  // ys
  BoxSpec[20, 4] :=  49;  // dx
  BoxSpec[20, 5] :=   9;  // dy
  BoxSpec[20, 6] :=   1;  // text orientation (1=mid)
  BoxSpec[20, 7] :=   4;  // font
  BoxSpec[20, 8] :=   0;  // dmax/dnum
  BoxSpec[20, 9] :=  03;  // ddel/inv

  BoxSpec[21, 1] :=   4;  // win    deco depth    0 - 99 (BIGNUMS)
  BoxSpec[21, 2] :=   5;  // xs                   100 - 999 (SMALLNUMS)
  BoxSpec[21, 3] :=  17;  // ys
  BoxSpec[21, 4] :=  16;  // dx
  BoxSpec[21, 5] :=  11;  // dy
  BoxSpec[21, 6] :=   0;  // res
  BoxSpec[21, 7] :=   8;  // font
  BoxSpec[21, 8] :=  20;  // dmax/dnum
  BoxSpec[21, 9] :=  00;  // ddel/dmod

  BoxSpec[22, 1] :=   4;  // win    arrow rigth symbol
  BoxSpec[22, 2] :=  22;  // xs
  BoxSpec[22, 3] :=  15;  // ys
  BoxSpec[22, 4] :=   9;  // dx
  BoxSpec[22, 5] :=   7;  // dy
  BoxSpec[22, 6] :=   0;  // res
  BoxSpec[22, 7] :=   1;  // px  (x-pos in the box)
  BoxSpec[22, 8] :=   1;  // py  (y-pos in the box)
  BoxSpec[22, 9] :=  00;  // res/dmod

  BoxSpec[23, 1] :=   4;  // win     deco depth unit symbol [m/ft]
  BoxSpec[23, 2] :=  21;  // xs
  BoxSpec[23, 3] :=  21;  // ys
  BoxSpec[23, 4] :=   7;  // dx
  BoxSpec[23, 5] :=   7;  // dy
  BoxSpec[23, 6] :=   0;  // res
  BoxSpec[23, 7] :=   1;  // px  (x-pos in the box)
  BoxSpec[23, 8] :=   1;  // py  (y-pos in the box)
  BoxSpec[23, 9] :=  00;  // res/dmod

  BoxSpec[24, 1] :=   4;  // win    adaption/null/deco/desat/nofly time :00- 9:59
  BoxSpec[24, 2] :=  15;  // xs
  BoxSpec[24, 3] :=  17;  // ys
  BoxSpec[24, 4] :=  36;  // dx
  BoxSpec[24, 5] :=  11;  // dy
  BoxSpec[24, 6] :=   0;  // res
  BoxSpec[24, 7] :=   8;  // font
  BoxSpec[24, 8] :=  42;  // dmax/dnum
  BoxSpec[24, 9] :=  20;  // ddel/dmod

  BoxSpec[25, 1] :=   4;  // win    leading tissue bar graph
  BoxSpec[25, 2] :=   7;  // xs
  BoxSpec[25, 3] :=  32;  // ys
  BoxSpec[25, 4] :=  43;  // dx
  BoxSpec[25, 5] :=   2;  // dy
  BoxSpec[25, 6] :=   0;  // res
  BoxSpec[25, 7] :=   0;  // mode [filled]
  BoxSpec[25, 8] :=   1;  // type [left-right]
  BoxSpec[25, 9] :=   0;  // res

  BoxSpec[26, 1] :=   4;  // win    desat/nofly symbol
  BoxSpec[26, 2] :=   5;  // xs
  BoxSpec[26, 3] :=  18;  // ys
  BoxSpec[26, 4] :=   9;  // dx
  BoxSpec[26, 5] :=   9;  // dy
  BoxSpec[26, 6] :=   0;  // res
  BoxSpec[26, 7] :=   1;  // px  (x-pos in the box)
  BoxSpec[26, 8] :=   1;  // py  (y-pos in the box)
  BoxSpec[26, 9] :=  00;  // res/dmod

  BoxSpec[27, 1] :=   4;  // win    oxygen partial pressure n.n [bar]
  BoxSpec[27, 2] :=   6;  // xs
  BoxSpec[27, 3] :=  38;  // ys
  BoxSpec[27, 4] :=  15;  // dx
  BoxSpec[27, 5] :=   9;  // dy
  BoxSpec[27, 6] :=   1;  // leading zero (1=on)
  BoxSpec[27, 7] :=   7;  // font
  BoxSpec[27, 8] :=  21;  // dmax/dnum
  BoxSpec[27, 9] :=  10;  // ddel/dmod

  BoxSpec[28, 1] :=   4;  // win    oxygen symbol (O2)
  BoxSpec[28, 2] :=  21;  // xs
  BoxSpec[28, 3] :=  40;  // ys
  BoxSpec[28, 4] :=   9;  // dx
  BoxSpec[28, 5] :=   7;  // dy
  BoxSpec[28, 6] :=   0;  // res
  BoxSpec[28, 7] :=   1;  // px  (x-pos in the box)
  BoxSpec[28, 8] :=   1;  // py  (y-pos in the box)
  BoxSpec[28, 9] :=  00;  // res/dmod

  BoxSpec[29, 1] :=   4;  // win    box frame for leading tissue
  BoxSpec[29, 2] :=   6;  // xs
  BoxSpec[29, 3] :=  30;  // ys
  BoxSpec[29, 4] :=  45;  // dx
  BoxSpec[29, 5] :=   6;  // dy
  BoxSpec[29, 6] :=   0;  // box type [rect. edges]
  BoxSpec[29, 7] :=   2;  // mode [line inside the box]
  BoxSpec[29, 8] :=   1;  // type [left-right]
  BoxSpec[29, 9] :=   0;  // ddel/dmod

  BoxSpec[38, 1] :=   4;  // win    oxygen dose CNS or OTU [%]
  BoxSpec[38, 2] :=  29;  // xs
  BoxSpec[38, 3] :=  38;  // ys
  BoxSpec[38, 4] :=  18;  // dx
  BoxSpec[38, 5] :=   9;  // dy
  BoxSpec[38, 6] :=   0;  // text orientation (0=left)
  BoxSpec[38, 7] :=   7;  // font
  BoxSpec[38, 8] :=  30;  // dmax/dnum
  BoxSpec[38, 9] :=   0; // res/dmod

  BoxSpec[39, 1] :=   4;  // win    oxygen dose unit text (%)
  BoxSpec[39, 2] :=  47;  // xs
  BoxSpec[39, 3] :=  40;  // ys
  BoxSpec[39, 4] :=   5;  // dx
  BoxSpec[39, 5] :=   7;  // dy
  BoxSpec[39, 6] :=   0;  // text orientation (0=left)
  BoxSpec[39, 7] :=   2;  // font
  BoxSpec[39, 8] :=   0;  // dmax/dnum
  BoxSpec[39, 9] :=   0;  // res/dmod

// Window GAS
// **********

  BoxSpec[30, 1] :=   3;  // win    header [GAS]
  BoxSpec[30, 2] :=   4;  // xs
  BoxSpec[30, 3] :=   4;  // ys
  BoxSpec[30, 4] :=  49;  // dx
  BoxSpec[30, 5] :=   9;  // dy
  BoxSpec[30, 6] :=   1;  // text orientation (1=mid)
  BoxSpec[30, 7] :=   4;  // font
  BoxSpec[30, 8] :=   0;  // dmax/dnum  [total digits / decimal digits]
  BoxSpec[30, 9] :=  03;  // ddel/dmod  [delimiter sign-10 / drawing mode]

  BoxSpec[31, 1] :=   3;  // win    tank pressure [bar]
  BoxSpec[31, 2] :=  14;  // xs
  BoxSpec[31, 3] :=  17;  // ys
  BoxSpec[31, 4] :=  24;  // dx
  BoxSpec[31, 5] :=  11;  // dy
  BoxSpec[31, 6] :=   0;  // res
  BoxSpec[31, 7] :=   8;  // font
  BoxSpec[31, 8] :=  30;  // dmax/dnum
  BoxSpec[31, 9] :=  00;  // ddel/dmod

  BoxSpec[32, 1] :=   3; // win    tank pressure [psi]
  BoxSpec[32, 2] :=   8; // xs
  BoxSpec[32, 3] :=  17; // ys
  BoxSpec[32, 4] :=  32; // dx
  BoxSpec[32, 5] :=  11; // dy
  BoxSpec[32, 6] :=   0; // res
  BoxSpec[32, 7] :=   8; // font
  BoxSpec[32, 8] :=  40; // dmax/dnum
  BoxSpec[32, 9] :=  00; // ddel/dmod

  BoxSpec[33, 1] :=   3; // win    tank pressure unit [bar/psi]
  BoxSpec[33, 2] :=  38; // xs
  BoxSpec[33, 3] :=  21; // ys
  BoxSpec[33, 4] :=  13; // dx
  BoxSpec[33, 5] :=   7; // dy
  BoxSpec[33, 6] :=   0; // res
  BoxSpec[33, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[33, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[33, 9] :=  00; // res/dmod

  BoxSpec[34, 1] :=   3; // win    box frame for gas graph
  BoxSpec[34, 2] :=   6; // xs
  BoxSpec[34, 3] :=  30; // ys
  BoxSpec[34, 4] :=  45; // dx
  BoxSpec[34, 5] :=   6; // dy
  BoxSpec[34, 6] :=   0; // box type (rect. edges)
  BoxSpec[34, 7] :=   0; // mode
  BoxSpec[34, 8] :=   0; // res
  BoxSpec[34, 9] :=   0; // res

  BoxSpec[35, 1] :=   3; // win    tank pressure bar graph
  BoxSpec[35, 2] :=   7; // xs
  BoxSpec[35, 3] :=  32; // ys
  BoxSpec[35, 4] :=  43; // dx
  BoxSpec[35, 5] :=   2; // dy
  BoxSpec[35, 6] :=   0; // res
  BoxSpec[35, 7] :=   0; // mode (filled)
  BoxSpec[35, 8] :=   1; // type (left-right)
  BoxSpec[35, 9] :=   0; // res

  BoxSpec[36, 1] :=   3; // win    ambient temperature
  BoxSpec[36, 2] :=  15; // xs
  BoxSpec[36, 3] :=  38; // ys
  BoxSpec[36, 4] :=  27; // dx
  BoxSpec[36, 5] :=   9; // dy
  BoxSpec[36, 6] :=   0; // res
  BoxSpec[36, 7] :=   7; // font
  BoxSpec[36, 8] :=  41; // dmax/dnum
  BoxSpec[36, 9] :=  10; // ddel/dmod

  BoxSpec[37, 1] :=   3; // win    temperature unit symbol [°C/°F]
  BoxSpec[37, 2] :=  41; // xs
  BoxSpec[37, 3] :=  38; // ys
  BoxSpec[37, 4] :=  10; // dx
  BoxSpec[37, 5] :=   9; // dy
  BoxSpec[37, 6] :=   0; // res
  BoxSpec[37, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[37, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[37, 9] :=  00; // res/dmod

; // Box 38 and 39 used in DECO

// Window NAVIGATION
// *****************

  BoxSpec[40, 1] :=   5; // win    header (NAVIGATION)
  BoxSpec[40, 2] :=   4; // xs
  BoxSpec[40, 3] :=   4; // ys
  BoxSpec[40, 4] := 110; // dx
  BoxSpec[40, 5] :=   9; // dy
  BoxSpec[40, 6] :=   1; // text orientation (1=mid)
  BoxSpec[40, 7] :=   4; // font
  BoxSpec[40, 8] :=   0; // dmax/dnum  [total digits / decimal digits]
  BoxSpec[40, 9] :=  03; // ddel/dmod  [delimiter sign-10 / drawing mode]

  BoxSpec[41, 1] :=   5; // win    compass scale [multi language support]
  BoxSpec[41, 2] :=   3; // xs
  BoxSpec[41, 3] :=  18; // ys
  BoxSpec[41, 4] := 112; // dx
  BoxSpec[41, 5] :=  15; // dy
  BoxSpec[41, 6] :=   2; // bitmap
  BoxSpec[41, 7] :=  47; // lx  [x-dim of bitmap/LCDBYTE]
  BoxSpec[41, 8] :=  30; // ly  [y-dim of bitmap]
  BoxSpec[41, 9] :=  00; // drawing mode

  BoxSpec[42, 1] :=   5; // win    compass heading
  BoxSpec[42, 2] :=  17; // xs
  BoxSpec[42, 3] :=  39; // ys
  BoxSpec[42, 4] :=  19; // dx
  BoxSpec[42, 5] :=   9; // dy
  BoxSpec[42, 6] :=   0; // res
  BoxSpec[42, 7] :=   7; // font
  BoxSpec[42, 8] :=  30; // format NNN
  BoxSpec[42, 9] :=  03; // ddel/inv

  BoxSpec[43, 1] :=   5; // win    degree symbol [°]
  BoxSpec[43, 2] :=  36; // xs
  BoxSpec[43, 3] :=  38; // ys
  BoxSpec[43, 4] :=   5; // dx
  BoxSpec[43, 5] :=   5; // dy
  BoxSpec[43, 6] :=   0; // res
  BoxSpec[43, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[43, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[43, 9] :=  03; // res/inv

  BoxSpec[44, 1] :=   5; // win    box frame for numeric data
  BoxSpec[44, 2] :=   3; // xs
  BoxSpec[44, 3] :=  37; // ys
  BoxSpec[44, 4] := 112; // dx
  BoxSpec[44, 5] :=  13; // dy
  BoxSpec[44, 6] :=   0; // box type (rect. edges)
  BoxSpec[44, 7] :=   0; // font
  BoxSpec[44, 8] :=   0; // dmax/dnum
  BoxSpec[44, 9] :=  03; // res/inv

  BoxSpec[45, 1] :=   5; // win    arrow up symbol
  BoxSpec[45, 2] :=  54; // xs
  BoxSpec[45, 3] :=  32; // ys
  BoxSpec[45, 4] :=   9; // dx
  BoxSpec[45, 5] :=   6; // dy
  BoxSpec[45, 6] :=   0; // res
  BoxSpec[45, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[45, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[45, 9] :=   0; // res/dmod

  BoxSpec[46, 1] :=   5; // win    distance [m/yd]
  BoxSpec[46, 2] :=  71; // xs
  BoxSpec[46, 3] :=  39; // ys
  BoxSpec[46, 4] :=  25; // dx
  BoxSpec[46, 5] :=   9; // dy
  BoxSpec[46, 6] :=   0; // res
  BoxSpec[46, 7] :=   7; // font
  BoxSpec[46, 8] :=  40; // format NNNN
  BoxSpec[46, 9] :=  03; // res/inv

  BoxSpec[47, 1] :=   5; // win    distance symbol [m/yd]
  BoxSpec[47, 2] :=  96; // xs
  BoxSpec[47, 3] :=  41; // ys
  BoxSpec[47, 4] :=   8; // dx
  BoxSpec[47, 5] :=   7; // dy
  BoxSpec[47, 6] :=   0; // res
  BoxSpec[47, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[47, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[47, 9] :=  03; // res/inv

  BoxSpec[48, 1] :=   5; // win    bearing symbol(s)
  BoxSpec[48, 2] :=  52; // xs
  BoxSpec[48, 3] :=  39; // ys
  BoxSpec[48, 4] :=  13; // dx
  BoxSpec[48, 5] :=   9; // dy
  BoxSpec[48, 6] :=   0; // res
  BoxSpec[48, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[48, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[48, 9] :=  03; // res/inv

// Window MAIN SELECTION / DIVE PLANNER
// ************************************

  BoxSpec[50, 1] :=   6; // win     selection text 0 [header]
  BoxSpec[50, 2] :=   4; // xs
  BoxSpec[50, 3] :=   4; // ys
  BoxSpec[50, 4] :=  86; // dx
  BoxSpec[50, 5] :=   7; // dy
  BoxSpec[50, 6] :=   1; // text orientation (1=mid)
  BoxSpec[50, 7] :=   2; // font
  BoxSpec[50, 8] :=   0; // dmax/dnum
  BoxSpec[50, 9] :=  03; // ddel/inv

  BoxSpec[51, 1] :=   6; // win     selection text 1
  BoxSpec[51, 2] :=   4; // xs
  BoxSpec[51, 3] :=  14; // ys
  BoxSpec[51, 4] :=  86; // dx
  BoxSpec[51, 5] :=   7; // dy
  BoxSpec[51, 6] :=   0; // text orientation (0=left)
  BoxSpec[51, 7] :=   2; // font
  BoxSpec[51, 8] :=   0; // dmax/dnum
  BoxSpec[51, 9] :=   0; // ddel/dmod

  BoxSpec[52, 1] :=   6; // win     selection text 2
  BoxSpec[52, 2] :=   4; // xs
  BoxSpec[52, 3] :=  24; // ys
  BoxSpec[52, 4] :=  86; // dx
  BoxSpec[52, 5] :=   7; // dy
  BoxSpec[52, 6] :=   0; // text orientation (0=left)
  BoxSpec[52, 7] :=   2; // font
  BoxSpec[52, 8] :=   0; // dmax/dnum
  BoxSpec[52, 9] :=   0; // ddel/dmod

  BoxSpec[53, 1] :=   6; // win     selection text 3
  BoxSpec[53, 2] :=   4; // xs
  BoxSpec[53, 3] :=  34; // ys
  BoxSpec[53, 4] :=  86; // dx
  BoxSpec[53, 5] :=   7; // dy
  BoxSpec[53, 6] :=   0; // text orientation (0=left)
  BoxSpec[53, 7] :=   2; // font
  BoxSpec[53, 8] :=   0; // dmax/dnum
  BoxSpec[53, 9] :=   0; // ddel/dmod

  BoxSpec[54, 1] :=   6; // win     selection text 4
  BoxSpec[54, 2] :=   4; // xs
  BoxSpec[54, 3] :=  44; // ys
  BoxSpec[54, 4] :=  86; // dx
  BoxSpec[54, 5] :=   7; // dy
  BoxSpec[54, 6] :=   0; // text orientation (0=left)
  BoxSpec[54, 7] :=   2; // font
  BoxSpec[54, 8] :=   0; // dmax/dnum
  BoxSpec[54, 9] :=   0; // ddel/dmod

  BoxSpec[55, 1] :=   6; // win     selection text 5
  BoxSpec[55, 2] :=   4; // xs
  BoxSpec[55, 3] :=  54; // ys
  BoxSpec[55, 4] :=  86; // dx
  BoxSpec[55, 5] :=   7; // dy
  BoxSpec[55, 6] :=   0; // text orientation (0=left)
  BoxSpec[55, 7] :=   2; // font
  BoxSpec[55, 8] :=   0; // dmax/dnum
  BoxSpec[55, 9] :=   0; // ddel/dmod

  BoxSpec[56, 1] :=   6; // win      selection text 6
  BoxSpec[56, 2] :=   4; // xs
  BoxSpec[56, 3] :=  64; // ys
  BoxSpec[56, 4] :=  86; // dx
  BoxSpec[56, 5] :=   7; // dy
  BoxSpec[56, 6] :=   0; // text orientation (0=left)
  BoxSpec[56, 7] :=   2; // font
  BoxSpec[56, 8] :=   0; // dmax/dnum
  BoxSpec[56, 9] :=   0; // ddel/dmod

  BoxSpec[57, 1] :=   6; // win     selection text 7
  BoxSpec[57, 2] :=   4; // xs
  BoxSpec[57, 3] :=  74; // ys
  BoxSpec[57, 4] :=  86; // dx
  BoxSpec[57, 5] :=   7; // dy
  BoxSpec[57, 6] :=   0; // text orientation (0=left)
  BoxSpec[57, 7] :=   2; // font
  BoxSpec[57, 8] :=   0; // dmax/dnum
  BoxSpec[57, 9] :=   0; // ddel/dmod

  BoxSpec[58, 1] :=   6; // win      selection text 8
  BoxSpec[58, 2] :=   4; // xs
  BoxSpec[58, 3] :=  84; // ys
  BoxSpec[58, 4] :=  86; // dx
  BoxSpec[58, 5] :=   7; // dy
  BoxSpec[58, 6] :=   0; // text orientation (0=left)
  BoxSpec[58, 7] :=   2; // font
  BoxSpec[58, 8] :=   0; // dmax/dnum
  BoxSpec[58, 9] :=   0; // ddel/dmod

  BoxSpec[59, 1] :=   6; // win      selection text 9
  BoxSpec[59, 2] :=   4; // xs
  BoxSpec[59, 3] :=  94; // ys
  BoxSpec[59, 4] :=  86; // dx
  BoxSpec[59, 5] :=   7; // dy
  BoxSpec[59, 6] :=   2; // text orientation (2=right)
  BoxSpec[59, 7] :=   2; // font
  BoxSpec[59, 8] :=   0; // dmax/dnum
  BoxSpec[59, 9] :=   0; // ddel/dmod

  BoxSpec[60, 1] :=   6; // win    selection value 0 [header]
  BoxSpec[60, 2] :=  77; // xs
  BoxSpec[60, 3] :=   4; // ys
  BoxSpec[60, 4] :=  12; // dx
  BoxSpec[60, 5] :=   7; // dy
  BoxSpec[60, 6] :=   2; // text orientation (2=right)
  BoxSpec[60, 7] :=   5; // numeric font
  BoxSpec[60, 8] :=   0; // dmax/dnum
  BoxSpec[60, 9] :=   0; // ddel/dmod

  BoxSpec[61, 1] :=   6; // win    selection value 1
  BoxSpec[61, 2] :=  77; // xs
  BoxSpec[61, 3] :=  14; // ys
  BoxSpec[61, 4] :=  12; // dx
  BoxSpec[61, 5] :=   7; // dy
  BoxSpec[61, 6] :=   2; // text orientation (2=right)
  BoxSpec[61, 7] :=   5; // numeric font
  BoxSpec[61, 8] :=  30; // dmax/dnum
  BoxSpec[61, 9] :=  00; // ddel/dmod

  BoxSpec[62, 1] :=   6; // win    selection value 2
  BoxSpec[62, 2] :=  77; // xs
  BoxSpec[62, 3] :=  24; // ys
  BoxSpec[62, 4] :=  12; // dx
  BoxSpec[62, 5] :=   7; // dy
  BoxSpec[62, 6] :=   2; // text orientation (2=right)
  BoxSpec[62, 7] :=   5; // numeric font
  BoxSpec[62, 8] :=  30; // dmax/dnum
  BoxSpec[62, 9] :=  00; // ddel/dmod

  BoxSpec[63, 1] :=   6; // win     selection value 3
  BoxSpec[63, 2] :=  77; // xs
  BoxSpec[63, 3] :=  34; // ys
  BoxSpec[63, 4] :=  12; // dx
  BoxSpec[63, 5] :=   7; // dy
  BoxSpec[63, 6] :=   2; // text orientation (2=right)
  BoxSpec[63, 7] :=   5; // numeric font
  BoxSpec[63, 8] :=  30; // dmax/dnum
  BoxSpec[63, 9] :=  00; // ddel/dmod

  BoxSpec[64, 1] :=   6; // win     selection value 4
  BoxSpec[64, 2] :=  77; // xs
  BoxSpec[64, 3] :=  44; // ys
  BoxSpec[64, 4] :=  12; // dx
  BoxSpec[64, 5] :=   7; // dy
  BoxSpec[64, 6] :=   2; // text orientation (2=right)
  BoxSpec[64, 7] :=   5; // numeric font
  BoxSpec[64, 8] :=  30; // dmax/dnum
  BoxSpec[64, 9] :=  00; // ddel/dmod

  BoxSpec[65, 1] :=   6; // win     selection value 5
  BoxSpec[65, 2] :=  77; // xs
  BoxSpec[65, 3] :=  54; // ys
  BoxSpec[65, 4] :=  12; // dx
  BoxSpec[65, 5] :=   7; // dy
  BoxSpec[65, 6] :=   2; // text orientation (2=right)
  BoxSpec[65, 7] :=   5; // numeric font
  BoxSpec[65, 8] :=  30; // dmax/dnum
  BoxSpec[65, 9] :=  00; // ddel/dmod

  BoxSpec[66, 1] :=   6; // win      selection value 6
  BoxSpec[66, 2] :=  77; // xs
  BoxSpec[66, 3] :=  64; // ys
  BoxSpec[66, 4] :=  12; // dx
  BoxSpec[66, 5] :=   7; // dy
  BoxSpec[66, 6] :=   2; // text orientation (2=right)
  BoxSpec[66, 7] :=   5; // numeric font
  BoxSpec[66, 8] :=  30; // dmax/dnum
  BoxSpec[66, 9] :=  00; // ddel/dmod

  BoxSpec[67, 1] :=   6; // win     selection value 7
  BoxSpec[67, 2] :=  77; // xs
  BoxSpec[67, 3] :=  74; // ys
  BoxSpec[67, 4] :=  12; // dx
  BoxSpec[67, 5] :=   7; // dy
  BoxSpec[67, 6] :=   2; // text orientation (2=right)
  BoxSpec[67, 7] :=   5; // numeric font
  BoxSpec[67, 8] :=  30; // dmax/dnum
  BoxSpec[67, 9] :=  00; // ddel/dmod

  BoxSpec[68, 1] :=   6; // win      selection value 8
  BoxSpec[68, 2] :=  77; // xs
  BoxSpec[68, 3] :=  84; // ys
  BoxSpec[68, 4] :=  12; // dx
  BoxSpec[68, 5] :=   7; // dy
  BoxSpec[68, 6] :=   2; // text orientation (2=right)
  BoxSpec[68, 7] :=   5; // numeric font
  BoxSpec[68, 8] :=  30; // dmax/dnum
  BoxSpec[68, 9] :=  00; // ddel/dmod

  BoxSpec[69, 1] :=   6; // win      selection value 9
  BoxSpec[69, 2] :=  77; // xs
  BoxSpec[69, 3] :=  94; // ys
  BoxSpec[69, 4] :=  12; // dx
  BoxSpec[69, 5] :=   7; // dy
  BoxSpec[69, 6] :=   2; // text orientation (2=right)
  BoxSpec[69, 7] :=   5; // numeric font
  BoxSpec[69, 8] :=   0; // dmax/dnum
  BoxSpec[69, 9] :=  00; // ddel/dmod

  BoxSpec[70, 1] :=   6; // win    selection symbol 0 [header]
  BoxSpec[70, 2] :=  93; // xs
  BoxSpec[70, 3] :=   4; // ys
  BoxSpec[70, 4] :=   7; // dx
  BoxSpec[70, 5] :=   7; // dy
  BoxSpec[70, 6] :=   0; // res
  BoxSpec[70, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[70, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[70, 9] :=  00; // res/dmod

  BoxSpec[71, 1] :=   6; // win    selection symbol 1
  BoxSpec[71, 2] :=  93; // xs
  BoxSpec[71, 3] :=  14; // ys
  BoxSpec[71, 4] :=   7; // dx
  BoxSpec[71, 5] :=   7; // dy
  BoxSpec[71, 6] :=   0; // res
  BoxSpec[71, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[71, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[71, 9] :=  00; // res/dmod

  BoxSpec[72, 1] :=   6; // win    selection symbol 2
  BoxSpec[72, 2] :=  93; // xs
  BoxSpec[72, 3] :=  24; // ys
  BoxSpec[72, 4] :=   7; // dx
  BoxSpec[72, 5] :=   7; // dy
  BoxSpec[72, 6] :=   0; // res
  BoxSpec[72, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[72, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[72, 9] :=  00; // res/dmod

  BoxSpec[73, 1] :=   6; // win    selection symbol 3
  BoxSpec[73, 2] :=  93; // xs
  BoxSpec[73, 3] :=  34; // ys
  BoxSpec[73, 4] :=   7; // dx
  BoxSpec[73, 5] :=   7; // dy
  BoxSpec[73, 6] :=   0; // res
  BoxSpec[73, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[73, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[73, 9] :=  00; // res/dmod

  BoxSpec[74, 1] :=   6; // win    selection symbol 4
  BoxSpec[74, 2] :=  93; // xs
  BoxSpec[74, 3] :=  44; // ys
  BoxSpec[74, 4] :=   7; // dx
  BoxSpec[74, 5] :=   7; // dy
  BoxSpec[74, 6] :=   0; // res
  BoxSpec[74, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[74, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[74, 9] :=  00; // res/dmod

  BoxSpec[75, 1] :=   6; // win    selection symbol 5
  BoxSpec[75, 2] :=  93; // xs
  BoxSpec[75, 3] :=  54; // ys
  BoxSpec[75, 4] :=   7; // dx
  BoxSpec[75, 5] :=   7; // dy
  BoxSpec[75, 6] :=   0; // res
  BoxSpec[75, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[75, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[75, 9] :=  00; // res/dmod

  BoxSpec[76, 1] :=   6; // win    selection symbol 6
  BoxSpec[76, 2] :=  93; // xs
  BoxSpec[76, 3] :=  64; // ys
  BoxSpec[76, 4] :=   7; // dx
  BoxSpec[76, 5] :=   7; // dy
  BoxSpec[76, 6] :=   0; // res
  BoxSpec[76, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[76, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[76, 9] :=  00; // res/dmod

  BoxSpec[77, 1] :=   6; // win    selection symbol 7
  BoxSpec[77, 2] :=  93; // xs
  BoxSpec[77, 3] :=  74; // ys
  BoxSpec[77, 4] :=   7; // dx
  BoxSpec[77, 5] :=   7; // dy
  BoxSpec[77, 6] :=   0; // res
  BoxSpec[77, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[77, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[77, 9] :=  00; // res/dmod

  BoxSpec[78, 1] :=   6; // win    selection symbol 8
  BoxSpec[78, 2] :=  93; // xs
  BoxSpec[78, 3] :=  84; // ys
  BoxSpec[78, 4] :=   7; // dx
  BoxSpec[78, 5] :=   7; // dy
  BoxSpec[78, 6] :=   0; // res
  BoxSpec[78, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[78, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[78, 9] :=  00; // res/dmod

  BoxSpec[79, 1] :=   6; // win    selection symbol 9
  BoxSpec[79, 2] :=  93; // xs
  BoxSpec[79, 3] :=  94; // ys
  BoxSpec[79, 4] :=   7; // dx
  BoxSpec[79, 5] :=   7; // dy
  BoxSpec[79, 6] :=   0; // res
  BoxSpec[79, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[79, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[79, 9] :=  00; // res/dmod

// Window CLOCK
// ************

  BoxSpec[80, 1] :=   2; // win    header (CLOCK)
  BoxSpec[80, 2] :=   4; // xs
  BoxSpec[80, 3] :=   4; // ys
  BoxSpec[80, 4] :=  49; // dx
  BoxSpec[80, 5] :=   9; // dy
  BoxSpec[80, 6] :=   1; // text orientation (1=mid)
  BoxSpec[80, 7] :=   4; // font
  BoxSpec[80, 8] :=   0; // dmax/dnum  [total digits / decimal digits]
  BoxSpec[80, 9] :=  03; // ddel/dmod  [delimiter sign-10 / drawing mode]

  BoxSpec[81, 1] :=   2; // win   hours
  BoxSpec[81, 2] :=   6; // xs
  BoxSpec[81, 3] :=  17; // ys
  BoxSpec[81, 4] :=  20; // dx
  BoxSpec[81, 5] :=  11; // dy
  BoxSpec[81, 6] :=   0; // res
  BoxSpec[81, 7] :=   8; // font
  BoxSpec[81, 8] :=  22; // dmax/dnum
  BoxSpec[81, 9] :=  40; // ddel/dmod; // leading zero

  BoxSpec[82, 1] :=   2; // win   minutes
  BoxSpec[82, 2] :=  26; // xs
  BoxSpec[82, 3] :=  17; // ys
  BoxSpec[82, 4] :=  20; // dx
  BoxSpec[82, 5] :=  11; // dy
  BoxSpec[82, 6] :=   0; // res
  BoxSpec[82, 7] :=   8; // font
  BoxSpec[82, 8] :=  22; // dmax/dnum
  BoxSpec[82, 9] :=  20; // ddel/dmod

  BoxSpec[83, 1] :=   2; // win    A/P
  BoxSpec[83, 2] :=  46; // xs
  BoxSpec[83, 3] :=  21; // ys
  BoxSpec[83, 4] :=   5; // dx
  BoxSpec[83, 5] :=   7; // dy
  BoxSpec[83, 6] :=   0; // text orientation (0=left)
  BoxSpec[83, 7] :=   1; // font
  BoxSpec[83, 8] :=   0; // dmax/dnum
  BoxSpec[83, 9] :=   0; // res/dmod

  BoxSpec[84, 1] :=   2; // win    weekday
  BoxSpec[84, 2] :=   3; // xs
  BoxSpec[84, 3] :=  34; // ys
  BoxSpec[84, 4] :=  51; // dx
  BoxSpec[84, 5] :=   7; // dy
  BoxSpec[84, 6] :=   1; // text orientation (1=mid)
  BoxSpec[84, 7] :=   2; // font
  BoxSpec[84, 8] :=   0; // dmax/dnum
  BoxSpec[84, 9] :=  00; // ddel/dmod

  BoxSpec[85, 1] :=   2; // win    date (EU/US/ISO format)
  BoxSpec[85, 2] :=   3; // xs
  BoxSpec[85, 3] :=  48; // ys
  BoxSpec[85, 4] :=  51; // dx
  BoxSpec[85, 5] :=   9; // dy
  BoxSpec[85, 6] :=   1; // text orientation (1=mid)
  BoxSpec[85, 7] :=   4; // font
  BoxSpec[85, 8] :=  22; // dmax/dnum
  BoxSpec[85, 9] :=   0; // ddel/dmod

  BoxSpec[86, 1] :=   2; // win    clock alarm symbol
  BoxSpec[86, 2] :=   3; // xs
  BoxSpec[86, 3] :=  15; // ys
  BoxSpec[86, 4] :=   7; // dx
  BoxSpec[86, 5] :=   8; // dy
  BoxSpec[86, 6] :=   0; // res
  BoxSpec[86, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[86, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[86, 9] :=   0; // res/dmod

 //Box 87 not used

  BoxSpec[88, 1] :=   2; // win    horizontal line
  BoxSpec[88, 2] :=   6; // xs
  BoxSpec[88, 3] :=  31; // ys
  BoxSpec[88, 4] :=  45; // dx
  BoxSpec[88, 5] :=   0; // dy
  BoxSpec[88, 6] :=   0; // res
  BoxSpec[88, 7] :=   0; // res
  BoxSpec[88, 8] :=   0; // don
  BoxSpec[88, 9] :=   0; // doff

  BoxSpec[89, 1] :=   2; // win
  BoxSpec[89, 2] :=   6; // xs
  BoxSpec[89, 3] :=  30; // ys
  BoxSpec[89, 4] :=  45; // dx
  BoxSpec[89, 5] :=   6; // dy
  BoxSpec[89, 6] :=   0; // box type [rect. edges]
  BoxSpec[89, 7] :=   0; // font
  BoxSpec[89, 8] :=   0; // dmax/dnum
  BoxSpec[89, 9] :=   0; // ddel/dmod  [delimiter sign-10 / drawing mode]

// Window BARO
// ***********

  BoxSpec[90, 1] :=   1; // win    header [BARO]
  BoxSpec[90, 2] :=   4; // xs
  BoxSpec[90, 3] :=   4; // ys
  BoxSpec[90, 4] :=  49; // dx
  BoxSpec[90, 5] :=   9; // dy
  BoxSpec[90, 6] :=   1; // text orientation (1=mid)
  BoxSpec[90, 7] :=   4; // font
  BoxSpec[90, 8] :=   0; // dmax/dnum  [total digits / decimal digits]
  BoxSpec[90, 9] :=  03; // ddel/dmod  [delimiter sign-10 / drawing mode]

  BoxSpec[91, 1] :=   1; // win    air pressure [hPa]
  BoxSpec[91, 2] :=   9; // xs
  BoxSpec[91, 3] :=  17; // ys
  BoxSpec[91, 4] :=  32; // dx
  BoxSpec[91, 5] :=  11; // dy
  BoxSpec[91, 6] :=   0; // res
  BoxSpec[91, 7] :=   8; // font
  BoxSpec[91, 8] :=  40; // format NNNN
  BoxSpec[91, 9] :=  00; // ddel/dmod

  BoxSpec[92, 1] :=   1; // win    air pressure [inHg]
  BoxSpec[92, 2] :=  13; // xs
  BoxSpec[92, 3] :=  17; // ys
  BoxSpec[92, 4] :=  28; // dx
  BoxSpec[92, 5] :=  11; // dy
  BoxSpec[92, 6] :=   0; // res
  BoxSpec[92, 7] :=   8; // font
  BoxSpec[92, 8] :=  31; // format NN.N
  BoxSpec[92, 9] :=  10; // decimal point as delimiter

  BoxSpec[93, 1] :=   1; // win    air pressure unit symbol [hPa/inHg]
  BoxSpec[93, 2] :=  41; // xs
  BoxSpec[93, 3] :=  21; // ys
  BoxSpec[93, 4] :=  11; // dx
  BoxSpec[93, 5] :=   9; // dy
  BoxSpec[93, 6] :=   0; // res
  BoxSpec[93, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[93, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[93, 9] :=  00; // res/dmod

  BoxSpec[94, 1] :=   1; // win    box frame for air press history
  BoxSpec[94, 2] :=   6; // xs
  BoxSpec[94, 3] :=  30; // ys
  BoxSpec[94, 4] :=  45; // dx
  BoxSpec[94, 5] :=  16; // dy
  BoxSpec[94, 6] :=   1; // box type [rounded edges]
  BoxSpec[94, 7] :=   0; // font
  BoxSpec[94, 8] :=  01; // dmax/dnum
  BoxSpec[94, 9] :=   0; // ddel/dmod

  BoxSpec[95, 1] :=   1; // win    air pressure history bar (11x moved)
  BoxSpec[95, 2] :=   6; // xs
  BoxSpec[95, 3] :=  31; // ys
  BoxSpec[95, 4] :=   3; // dx
  BoxSpec[95, 5] :=  13; // dy
  BoxSpec[95, 6] :=   0; // box type
  BoxSpec[95, 7] :=   2; // mode (pointer line)
  BoxSpec[95, 8] :=   2; // type (bottom-up)
  BoxSpec[95, 9] :=   0; // res

  BoxSpec[96, 1] :=   1; // win    altitude above sea level [m/ft]
  BoxSpec[96, 2] :=  10; // xs
  BoxSpec[96, 3] :=  48; // ys
  BoxSpec[96, 4] :=  31; // dx
  BoxSpec[96, 5] :=   9; // dy
  BoxSpec[96, 6] :=   0; // res
  BoxSpec[96, 7] :=   7; // font
  BoxSpec[96, 8] :=  50; // format NNNNN
  BoxSpec[96, 9] :=  00; // ddel/dmod

  BoxSpec[97, 1] :=   1; // win    altitude unit symbol [m/ft]
  BoxSpec[97, 2] :=  41; // xs
  BoxSpec[97, 3] :=  50; // ys
  BoxSpec[97, 4] :=   7; // dx
  BoxSpec[97, 5] :=   7; // dy
  BoxSpec[97, 6] :=   0; // res
  BoxSpec[97, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[97, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[97, 9] :=  00; // res/dmod

//nk// 98..99 free

// Window CALENDAR
// ***************

  BoxSpec[100, 1] :=   8; // win     calendar [header]
  BoxSpec[100, 2] :=   4; // xs
  BoxSpec[100, 3] :=   4; // ys
  BoxSpec[100, 4] :=  86; // dx
  BoxSpec[100, 5] :=   7; // dy
  BoxSpec[100, 6] :=   1; // text orientation (1=mid)
  BoxSpec[100, 7] :=   2; // font
  BoxSpec[100, 8] :=   0; // dmax/dnum
  BoxSpec[100, 9] :=  03; // ddel/inv

  BoxSpec[101, 1] :=   8; // win     weekday [as text]
  BoxSpec[101, 2] :=   4; // xs
  BoxSpec[101, 3] :=  14; // ys
  BoxSpec[101, 4] :=  86; // dx
  BoxSpec[101, 5] :=   7; // dy
  BoxSpec[101, 6] :=   1; // text orientation (1=mid)
  BoxSpec[101, 7] :=   2; // font
  BoxSpec[101, 8] :=   0; // dmax/dnum
  BoxSpec[101, 9] :=   0; // ddel/dmod

  BoxSpec[102, 1] :=   8; // win     day, month and year [as text]
  BoxSpec[102, 2] :=   4; // xs
  BoxSpec[102, 3] :=  24; // ys
  BoxSpec[102, 4] :=  86; // dx
  BoxSpec[102, 5] :=   7; // dy
  BoxSpec[102, 6] :=   1; // text orientation (1=mid)
  BoxSpec[102, 7] :=   2; // font
  BoxSpec[102, 8] :=   0; // dmax/dnum
  BoxSpec[102, 9] :=   0; // ddel/dmod

  BoxSpec[103, 1] :=   8; // win     weekdays mo-su
  BoxSpec[103, 2] :=   6; // xs
  BoxSpec[103, 3] :=  34; // ys
  BoxSpec[103, 4] :=   9; // dx
  BoxSpec[103, 5] :=   7; // dy
  BoxSpec[103, 6] :=   0; // text orientation (0=left)
  BoxSpec[103, 7] :=   1; // font
  BoxSpec[103, 8] :=   0; // dmax/dnum
  BoxSpec[103, 9] :=   0; // ddel/dmod

  BoxSpec[104, 1] :=   8; // win     days table
  BoxSpec[104, 2] :=   6; // xs
  BoxSpec[104, 3] :=  44; // ys
  BoxSpec[104, 4] :=   9; // dx
  BoxSpec[104, 5] :=   7; // dy
  BoxSpec[104, 6] :=   0; // res
  BoxSpec[104, 7] :=   5; // font
  BoxSpec[104, 8] :=  20; // dmax/dnum
  BoxSpec[104, 9] :=   0; // ddel/dmod

  BoxSpec[105, 1] :=   8; // win     day frame in table
  BoxSpec[105, 2] :=   5; // xs
  BoxSpec[105, 3] :=  43; // ys
  BoxSpec[105, 4] :=  11; // dx
  BoxSpec[105, 5] :=   9; // dy
  BoxSpec[105, 6] :=   0; // box type [rect. edges]
  BoxSpec[105, 7] :=   0; // font
  BoxSpec[105, 8] :=  00; // dmax/dnum
  BoxSpec[105, 9] :=  00; // ddel/dmod

  BoxSpec[106, 1] :=   8; // win     D: daynumber
  BoxSpec[106, 2] :=   6; // xs
  BoxSpec[106, 3] :=  94; // ys
  BoxSpec[106, 4] :=  23; // dx
  BoxSpec[106, 5] :=   7; // dy
  BoxSpec[106, 6] :=   0; // text orientation (0=left)
  BoxSpec[106, 7] :=   2; // font
  BoxSpec[106, 8] :=   0; // dmax/dnum
  BoxSpec[106, 9] :=  00; // ddel/dmod

; //18.10.05 nk box 107 obsolete (free for further use)

  BoxSpec[108, 1] :=   8; // win     W: weeknumber
  BoxSpec[108, 2] :=  32; // xs
  BoxSpec[108, 3] :=  94; // ys
  BoxSpec[108, 4] :=  20; // dx
  BoxSpec[108, 5] :=   7; // dy
  BoxSpec[108, 6] :=   0; // text orientation (0=left)
  BoxSpec[108, 7] :=   2; // font
  BoxSpec[108, 8] :=   0; // dmax/dnum
  BoxSpec[108, 9] :=  00; // ddel/dmod

; //18.10.05 nk box 109 obsolete (free for further use)

  BoxSpec[110, 1] :=   8; // win    moon phase symbol
  BoxSpec[110, 2] :=  81; // xs
  BoxSpec[110, 3] :=  94; // ys
  BoxSpec[110, 4] :=   7; // dx
  BoxSpec[110, 5] :=   7; // dy
  BoxSpec[110, 6] :=   0; // res
  BoxSpec[110, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[110, 8] :=   0; // py  (y-pos in the box)
  BoxSpec[110, 9] :=  00; // res/dmod

  BoxSpec[113, 1] :=   8; // win     close
  BoxSpec[113, 2] :=   4; // xs
  BoxSpec[113, 3] := 104; // ys
  BoxSpec[113, 4] :=  86; // dx
  BoxSpec[113, 5] :=   7; // dy
  BoxSpec[113, 6] :=   2; // text orientation (2=right)
  BoxSpec[113, 7] :=   2; // font
  BoxSpec[113, 8] :=   0; // dmax/dnum
  BoxSpec[113, 9] :=   0; // ddel/dmod

  BoxSpec[114, 1] :=   8; // win    arrow up symbol
  BoxSpec[114, 2] :=  93; // xs
  BoxSpec[114, 3] :=   4; // ys
  BoxSpec[114, 4] :=   7; // dx
  BoxSpec[114, 5] :=   7; // dy
  BoxSpec[114, 6] :=   0; // res
  BoxSpec[114, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[114, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[114, 9] :=  00; // res/dmod

  BoxSpec[115, 1] :=   8; // win    arrow down symbol
  BoxSpec[115, 2] :=  93; // xs
  BoxSpec[115, 3] := 104; // ys
  BoxSpec[115, 4] :=   7; // dx
  BoxSpec[115, 5] :=   7; // dy
  BoxSpec[115, 6] :=   0; // res
  BoxSpec[115, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[115, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[115, 9] :=  00; // res/dmod

  BoxSpec[116, 1] :=   8; // win    select day symbol
  BoxSpec[116, 2] :=  93; // xs
  BoxSpec[116, 3] :=  14; // ys
  BoxSpec[116, 4] :=   7; // dx
  BoxSpec[116, 5] :=   7; // dy
  BoxSpec[116, 6] :=   0; // res
  BoxSpec[116, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[116, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[116, 9] :=  00; // res/dmod

  BoxSpec[117, 1] :=   8; // win    select month symbol
  BoxSpec[117, 2] :=  93; // xs
  BoxSpec[117, 3] :=  24; // ys
  BoxSpec[117, 4] :=   7; // dx
  BoxSpec[117, 5] :=   7; // dy
  BoxSpec[117, 6] :=   0; // res
  BoxSpec[117, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[117, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[117, 9] :=  00; // res/dmod

  BoxSpec[118, 1] :=   8; // win    select year symbol
  BoxSpec[118, 2] :=  93; // xs
  BoxSpec[118, 3] :=  94; // ys
  BoxSpec[118, 4] :=   7; // dx
  BoxSpec[118, 5] :=   7; // dy
  BoxSpec[118, 6] :=   0; // res
  BoxSpec[118, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[118, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[118, 9] :=  00; // res/dmod

  BoxSpec[119, 1] :=   8; // win     day table
  BoxSpec[119, 2] :=   3; // xs
  BoxSpec[119, 3] :=  43; // ys
  BoxSpec[119, 4] :=  88; // dx
  BoxSpec[119, 5] :=  49; // dy
  BoxSpec[119, 6] :=   0; // res
  BoxSpec[119, 7] :=   0; // res
  BoxSpec[119, 8] :=   0; // dmax/dnum
  BoxSpec[119, 9] :=   0; // ddel/dmod

// Window POWER
// ************

  BoxSpec[120, 1] :=   3; // win    header (POWER)
  BoxSpec[120, 2] :=   4; // xs
  BoxSpec[120, 3] :=   4; // ys
  BoxSpec[120, 4] :=  49; // dx
  BoxSpec[120, 5] :=   9; // dy
  BoxSpec[120, 6] :=   1; // text orientation (1=mid)
  BoxSpec[120, 7] :=   4; // font
  BoxSpec[120, 8] :=   0; // dmax/dnum  [total digits / decimal digits]
  BoxSpec[120, 9] :=  03; // ddel/dmod  [delimiter sign-10 / drawing mode]

  BoxSpec[121, 1] :=   3; // win    accu power
  BoxSpec[121, 2] :=  18; // xs
  BoxSpec[121, 3] :=  17; // ys
  BoxSpec[121, 4] :=  24; // dx
  BoxSpec[121, 5] :=  11; // dy
  BoxSpec[121, 6] :=   0; // res
  BoxSpec[121, 7] :=   8; // font
  BoxSpec[121, 8] :=  30; // dmax/dnum
  BoxSpec[121, 9] :=  00; // ddel/dmod

  BoxSpec[122, 1] :=   3; // win    accu power unit [%]
  BoxSpec[122, 2] :=  43; // xs
  BoxSpec[122, 3] :=  19; // ys
  BoxSpec[122, 4] :=   9; // dx
  BoxSpec[122, 5] :=   9; // dy
  BoxSpec[122, 6] :=   0; // res
  BoxSpec[122, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[122, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[122, 9] :=  00; // res/dmod

  BoxSpec[123, 1] :=   3; // win    accu power bar graph
  BoxSpec[123, 2] :=   7; // xs
  BoxSpec[123, 3] :=  32; // ys
  BoxSpec[123, 4] :=  43; // dx
  BoxSpec[123, 5] :=   2; // dy
  BoxSpec[123, 6] :=   0; // res
  BoxSpec[123, 7] :=   0; // mode [filled]
  BoxSpec[123, 8] :=   1; // type [left-right]
  BoxSpec[123, 9] :=   0; // res

  BoxSpec[124, 1] :=   3; // win    box frame for power graph
  BoxSpec[124, 2] :=   6; // xs
  BoxSpec[124, 3] :=  30; // ys
  BoxSpec[124, 4] :=  45; // dx
  BoxSpec[124, 5] :=   6; // dy
  BoxSpec[124, 6] :=   0; // box type [rect. edges]
  BoxSpec[124, 7] :=   0; // mode
  BoxSpec[124, 8] :=   0; // res
  BoxSpec[124, 9] :=   0; // res

  BoxSpec[125, 1] :=   3; // win    ambient temperature
  BoxSpec[125, 2] :=  15; // xs
  BoxSpec[125, 3] :=  38; // ys
  BoxSpec[125, 4] :=  27; // dx
  BoxSpec[125, 5] :=   9; // dy
  BoxSpec[125, 6] :=   0; // res
  BoxSpec[125, 7] :=   7; // font
  BoxSpec[125, 8] :=  41; // dmax/dnum
  BoxSpec[125, 9] :=  10; // ddel/dmod

  BoxSpec[126, 1] :=   3; // win    temperature unit symbol [°C/°F]
  BoxSpec[126, 2] :=  41; // xs
  BoxSpec[126, 3] :=  38; // ys
  BoxSpec[126, 4] :=  10; // dx
  BoxSpec[126, 5] :=   9; // dy
  BoxSpec[126, 6] :=   0; // res
  BoxSpec[126, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[126, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[126, 9] :=  00; // res/dmod

// Window SATURATION
// *****************

  BoxSpec[130, 1] :=   5; // win    header [SATURATION]
  BoxSpec[130, 2] :=   4; // xs
  BoxSpec[130, 3] :=   4; // ys
  BoxSpec[130, 4] := 110; // dx
  BoxSpec[130, 5] :=   9; // dy
  BoxSpec[130, 6] :=   1; // text orientation (1=mid)
  BoxSpec[130, 7] :=   4; // font
  BoxSpec[130, 8] :=   0; // dmax/dnum  [total digits / decimal digits]
  BoxSpec[130, 9] :=  03; // ddel/dmod  [delimiter sign-10 / drawing mode]

  BoxSpec[131, 1] :=   5; // win    tissue #1 bar graph [framed]
  BoxSpec[131, 2] :=  19; // xs
  BoxSpec[131, 3] :=  15; // ys
  BoxSpec[131, 4] :=   3; // dx
  BoxSpec[131, 5] :=  35; // dy
  BoxSpec[131, 6] :=   0; // res
  BoxSpec[131, 7] :=   1; // mode [framed]
  BoxSpec[131, 8] :=   2; // type [bottom-up]
  BoxSpec[131, 9] :=   0; // res

  BoxSpec[132, 1] :=   5; // win    tissue #2 bar graph [framed]
  BoxSpec[132, 2] :=  25; // xs
  BoxSpec[132, 3] :=  15; // ys
  BoxSpec[132, 4] :=   3; // dx
  BoxSpec[132, 5] :=  35; // dy
  BoxSpec[132, 6] :=   0; // res
  BoxSpec[132, 7] :=   1; // mode
  BoxSpec[132, 8] :=   2; // type
  BoxSpec[132, 9] :=   0; // res

  BoxSpec[133, 1] :=   5; // win    tissue #3 bar graph [framed]
  BoxSpec[133, 2] :=  31; // xs
  BoxSpec[133, 3] :=  15; // ys
  BoxSpec[133, 4] :=   3; // dx
  BoxSpec[133, 5] :=  35; // dy
  BoxSpec[133, 6] :=   0; // res
  BoxSpec[133, 7] :=   1; // mode
  BoxSpec[133, 8] :=   2; // type
  BoxSpec[133, 9] :=   0; // res

  BoxSpec[134, 1] :=   5; // win    tissue #4 bar graph [framed]
  BoxSpec[134, 2] :=  37; // xs
  BoxSpec[134, 3] :=  15; // ys
  BoxSpec[134, 4] :=   3; // dx
  BoxSpec[134, 5] :=  35; // dy
  BoxSpec[134, 6] :=   0; // res
  BoxSpec[134, 7] :=   1; // mode
  BoxSpec[134, 8] :=   2; // type
  BoxSpec[134, 9] :=   0; // res

  BoxSpec[135, 1] :=   5; // win    tissue #5 bar graph [framed]
  BoxSpec[135, 2] :=  43; // xs
  BoxSpec[135, 3] :=  15; // ys
  BoxSpec[135, 4] :=   3; // dx
  BoxSpec[135, 5] :=  35; // dy
  BoxSpec[135, 6] :=   0; // res
  BoxSpec[135, 7] :=   1; // mode
  BoxSpec[135, 8] :=   2; // type
  BoxSpec[135, 9] :=   0; // res

  BoxSpec[136, 1] :=   5; // win    tissue #6 bar graph [framed]
  BoxSpec[136, 2] :=  49; // xs
  BoxSpec[136, 3] :=  15; // ys
  BoxSpec[136, 4] :=   3; // dx
  BoxSpec[136, 5] :=  35; // dy
  BoxSpec[136, 6] :=   0; // res
  BoxSpec[136, 7] :=   1; // mode
  BoxSpec[136, 8] :=   2; // type
  BoxSpec[136, 9] :=   0; // res

  BoxSpec[137, 1] :=   5; // win    tissue #7 bar graph [framed]
  BoxSpec[137, 2] :=  55; // xs
  BoxSpec[137, 3] :=  15; // ys
  BoxSpec[137, 4] :=   3; // dx
  BoxSpec[137, 5] :=  35; // dy
  BoxSpec[137, 6] :=   0; // res
  BoxSpec[137, 7] :=   1; // mode
  BoxSpec[137, 8] :=   2; // type
  BoxSpec[137, 9] :=   0; // res

  BoxSpec[138, 1] :=   5; // win    tissue #8 bar graph [framed]
  BoxSpec[138, 2] :=  61; // xs
  BoxSpec[138, 3] :=  15; // ys
  BoxSpec[138, 4] :=   3; // dx
  BoxSpec[138, 5] :=  35; // dy
  BoxSpec[138, 6] :=   0; // res
  BoxSpec[138, 7] :=   1; // mode
  BoxSpec[138, 8] :=   2; // type
  BoxSpec[138, 9] :=   0; // res

  BoxSpec[139, 1] :=   5; // win    tissue #9 bar graph [framed]
  BoxSpec[139, 2] :=  67; // xs
  BoxSpec[139, 3] :=  15; // ys
  BoxSpec[139, 4] :=   3; // dx
  BoxSpec[139, 5] :=  35; // dy
  BoxSpec[139, 6] :=   0; // res
  BoxSpec[139, 7] :=   1; // mode
  BoxSpec[139, 8] :=   2; // type
  BoxSpec[139, 9] :=   0; // res

  BoxSpec[140, 1] :=   5; // win    tissue #10 bar graph [framed]
  BoxSpec[140, 2] :=  73; // xs
  BoxSpec[140, 3] :=  15; // ys
  BoxSpec[140, 4] :=   3; // dx
  BoxSpec[140, 5] :=  35; // dy
  BoxSpec[140, 6] :=   0; // res
  BoxSpec[140, 7] :=   1; // mode
  BoxSpec[140, 8] :=   2; // type
  BoxSpec[140, 9] :=   0; // res

  BoxSpec[141, 1] :=   5; // win    tissue #11 bar graph [framed]
  BoxSpec[141, 2] :=  79; // xs
  BoxSpec[141, 3] :=  15; // ys
  BoxSpec[141, 4] :=   3; // dx
  BoxSpec[141, 5] :=  35; // dy
  BoxSpec[141, 6] :=   0; // res
  BoxSpec[141, 7] :=   1; // mode
  BoxSpec[141, 8] :=   2; // type
  BoxSpec[141, 9] :=   0; // res

  BoxSpec[142, 1] :=   5; // win    tissue #12 bar graph [framed]
  BoxSpec[142, 2] :=  85; // xs
  BoxSpec[142, 3] :=  15; // ys
  BoxSpec[142, 4] :=   3; // dx
  BoxSpec[142, 5] :=  35; // dy
  BoxSpec[142, 6] :=   0; // res
  BoxSpec[142, 7] :=   1; // mode
  BoxSpec[142, 8] :=   2; // type
  BoxSpec[142, 9] :=   0; // res

  BoxSpec[143, 1] :=   5; // win    tissue #13 bar graph [framed]
  BoxSpec[143, 2] :=  91; // xs
  BoxSpec[143, 3] :=  15; // ys
  BoxSpec[143, 4] :=   3; // dx
  BoxSpec[143, 5] :=  35; // dy
  BoxSpec[143, 6] :=   0; // res
  BoxSpec[143, 7] :=   1; // mode
  BoxSpec[143, 8] :=   2; // type
  BoxSpec[143, 9] :=   0; // res

  BoxSpec[144, 1] :=   5; // win    tissue #14 bar graph [framed]
  BoxSpec[144, 2] :=  97; // xs
  BoxSpec[144, 3] :=  15; // ys
  BoxSpec[144, 4] :=   3; // dx
  BoxSpec[144, 5] :=  35; // dy
  BoxSpec[144, 6] :=   0; // res
  BoxSpec[144, 7] :=   1; // mode
  BoxSpec[144, 8] :=   2; // type
  BoxSpec[144, 9] :=   0; // res

  BoxSpec[145, 1] :=   5; // win    tissue #15 bar graph [framed]
  BoxSpec[145, 2] := 103; // xs
  BoxSpec[145, 3] :=  15; // ys
  BoxSpec[145, 4] :=   3; // dx
  BoxSpec[145, 5] :=  35; // dy
  BoxSpec[145, 6] :=   0; // res
  BoxSpec[145, 7] :=   1; // mode
  BoxSpec[145, 8] :=   2; // type
  BoxSpec[145, 9] :=   0; // res

  BoxSpec[146, 1] :=   5; // win    tissue #16 bar graph [framed]
  BoxSpec[146, 2] := 109; // xs
  BoxSpec[146, 3] :=  15; // ys
  BoxSpec[146, 4] :=   3; // dx
  BoxSpec[146, 5] :=  35; // dy
  BoxSpec[146, 6] :=   0; // res
  BoxSpec[146, 7] :=   1; // mode
  BoxSpec[146, 8] :=   2; // type
  BoxSpec[146, 9] :=   0; // res

  BoxSpec[147, 1] :=   5; // win    small percent symbol [%]
  BoxSpec[147, 2] :=   3; // xs
  BoxSpec[147, 3] :=  43; // ys
  BoxSpec[147, 4] :=  13; // dx
  BoxSpec[147, 5] :=   6; // dy
  BoxSpec[147, 6] :=   0; // res
  BoxSpec[147, 7] :=   6; // px  (x-pos in the box)
  BoxSpec[147, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[147, 9] :=   0; // res

  BoxSpec[148, 1] :=   5; // win     scale label 100%
  BoxSpec[148, 2] :=   3; // xs
  BoxSpec[148, 3] :=  17; // ys
  BoxSpec[148, 4] :=  13; // dx
  BoxSpec[148, 5] :=   7; // dy
  BoxSpec[148, 6] :=   0; // res
  BoxSpec[148, 7] :=   5; // font
  BoxSpec[148, 8] :=  30; // dmax/dnum
  BoxSpec[148, 9] :=  00; // ddel/dmod

  BoxSpec[149, 1] :=   5; // win     scale label 70%
  BoxSpec[149, 2] :=   3; // xs
  BoxSpec[149, 3] :=  27; // ys
  BoxSpec[149, 4] :=  13; // dx
  BoxSpec[149, 5] :=   7; // dy
  BoxSpec[149, 6] :=   0; // res
  BoxSpec[149, 7] :=   5; // font
  BoxSpec[149, 8] :=  30; // dmax/dnum
  BoxSpec[149, 9] :=  00; // ddel/dmod

  BoxSpec[150, 1] :=   5; // win     scale label 40%
  BoxSpec[150, 2] :=   3; // xs
  BoxSpec[150, 3] :=  37; // ys
  BoxSpec[150, 4] :=  13; // dx
  BoxSpec[150, 5] :=   7; // dy
  BoxSpec[150, 6] :=   0; // res
  BoxSpec[150, 7] :=   5; // font
  BoxSpec[150, 8] :=  30; // dmax/dnum
  BoxSpec[150, 9] :=  00; // ddel/dmod

  BoxSpec[151, 1] :=   5; // win    tissue #1 bar graph [filled]
  BoxSpec[151, 2] :=  21; // xs
  BoxSpec[151, 3] :=  15; // ys
  BoxSpec[151, 4] :=   3; // dx
  BoxSpec[151, 5] :=  34; // dy
  BoxSpec[151, 6] :=   0; // res
  BoxSpec[151, 7] :=   0; // mode [filled]
  BoxSpec[151, 8] :=   2; // type [bottom-up]
  BoxSpec[151, 9] :=   0; // res

  BoxSpec[152, 1] :=   5; // win    tissue #2 bar graph [filled]
  BoxSpec[152, 2] :=  27; // xs
  BoxSpec[152, 3] :=  15; // ys
  BoxSpec[152, 4] :=   3; // dx
  BoxSpec[152, 5] :=  34; // dy
  BoxSpec[152, 6] :=   0; // res
  BoxSpec[152, 7] :=   0; // mode
  BoxSpec[152, 8] :=   2; // type
  BoxSpec[152, 9] :=   0; // res

  BoxSpec[153, 1] :=   5; // win    tissue #3 bar graph [filled]
  BoxSpec[153, 2] :=  33; // xs
  BoxSpec[153, 3] :=  15; // ys
  BoxSpec[153, 4] :=   3; // dx
  BoxSpec[153, 5] :=  34; // dy
  BoxSpec[153, 6] :=   0; // res
  BoxSpec[153, 7] :=   0; // mode
  BoxSpec[153, 8] :=   2; // type
  BoxSpec[153, 9] :=   0; // res

  BoxSpec[154, 1] :=   5; // win    tissue #4 bar graph [filled]
  BoxSpec[154, 2] :=  39; // xs
  BoxSpec[154, 3] :=  15; // ys
  BoxSpec[154, 4] :=   3; // dx
  BoxSpec[154, 5] :=  34; // dy
  BoxSpec[154, 6] :=   0; // res
  BoxSpec[154, 7] :=   0; // mode
  BoxSpec[154, 8] :=   2; // type
  BoxSpec[154, 9] :=   0; // res

  BoxSpec[155, 1] :=   5; // win    tissue #5 bar graph [filled]
  BoxSpec[155, 2] :=  45; // xs
  BoxSpec[155, 3] :=  15; // ys
  BoxSpec[155, 4] :=   3; // dx
  BoxSpec[155, 5] :=  34; // dy
  BoxSpec[155, 6] :=   0; // res
  BoxSpec[155, 7] :=   0; // mode
  BoxSpec[155, 8] :=   2; // type
  BoxSpec[155, 9] :=   0; // res

  BoxSpec[156, 1] :=   5; // win    tissue #6 bar graph [filled]
  BoxSpec[156, 2] :=  51; // xs
  BoxSpec[156, 3] :=  15; // ys
  BoxSpec[156, 4] :=   3; // dx
  BoxSpec[156, 5] :=  34; // dy
  BoxSpec[156, 6] :=   0; // res
  BoxSpec[156, 7] :=   0; // mode
  BoxSpec[156, 8] :=   2; // type
  BoxSpec[156, 9] :=   0; // res

  BoxSpec[157, 1] :=   5; // win    tissue #7 bar graph [filled]
  BoxSpec[157, 2] :=  57; // xs
  BoxSpec[157, 3] :=  15; // ys
  BoxSpec[157, 4] :=   3; // dx
  BoxSpec[157, 5] :=  34; // dy
  BoxSpec[157, 6] :=   0; // res
  BoxSpec[157, 7] :=   0; // mode
  BoxSpec[157, 8] :=   2; // type
  BoxSpec[157, 9] :=   0; // res

  BoxSpec[158, 1] :=   5; // win    tissue #8 bar graph [filled]
  BoxSpec[158, 2] :=  63; // xs
  BoxSpec[158, 3] :=  15; // ys
  BoxSpec[158, 4] :=   3; // dx
  BoxSpec[158, 5] :=  34; // dy
  BoxSpec[158, 6] :=   0; // res
  BoxSpec[158, 7] :=   0; // mode
  BoxSpec[158, 8] :=   2; // type
  BoxSpec[158, 9] :=   0; // res

  BoxSpec[159, 1] :=   5; // win    tissue #9 bar graph [filled]
  BoxSpec[159, 2] :=  69; // xs
  BoxSpec[159, 3] :=  15; // ys
  BoxSpec[159, 4] :=   3; // dx
  BoxSpec[159, 5] :=  34; // dy
  BoxSpec[159, 6] :=   0; // res
  BoxSpec[159, 7] :=   0; // mode
  BoxSpec[159, 8] :=   2; // type
  BoxSpec[159, 9] :=   0; // res

  BoxSpec[160, 1] :=   5; // win    tissue #10 bar graph [filled]
  BoxSpec[160, 2] :=  75; // xs
  BoxSpec[160, 3] :=  15; // ys
  BoxSpec[160, 4] :=   3; // dx
  BoxSpec[160, 5] :=  34; // dy
  BoxSpec[160, 6] :=   0; // res
  BoxSpec[160, 7] :=   0; // mode
  BoxSpec[160, 8] :=   2; // type
  BoxSpec[160, 9] :=   0; // res

  BoxSpec[161, 1] :=   5; // win    tissue #11 bar graph [filled]
  BoxSpec[161, 2] :=  81; // xs
  BoxSpec[161, 3] :=  15; // ys
  BoxSpec[161, 4] :=   3; // dx
  BoxSpec[161, 5] :=  34; // dy
  BoxSpec[161, 6] :=   0; // res
  BoxSpec[161, 7] :=   0; // mode
  BoxSpec[161, 8] :=   2; // type
  BoxSpec[161, 9] :=   0; // res

  BoxSpec[162, 1] :=   5; // win    tissue #12 bar graph [filled]
  BoxSpec[162, 2] :=  87; // xs
  BoxSpec[162, 3] :=  15; // ys
  BoxSpec[162, 4] :=   3; // dx
  BoxSpec[162, 5] :=  34; // dy
  BoxSpec[162, 6] :=   0; // res
  BoxSpec[162, 7] :=   0; // mode
  BoxSpec[162, 8] :=   2; // type
  BoxSpec[162, 9] :=   0; // res

  BoxSpec[163, 1] :=   5; // win    tissue #13 bar graph [filled]
  BoxSpec[163, 2] :=  93; // xs
  BoxSpec[163, 3] :=  15; // ys
  BoxSpec[163, 4] :=   3; // dx
  BoxSpec[163, 5] :=  34; // dy
  BoxSpec[163, 6] :=   0; // res
  BoxSpec[163, 7] :=   0; // mode
  BoxSpec[163, 8] :=   2; // type
  BoxSpec[163, 9] :=   0; // res

  BoxSpec[164, 1] :=   5; // win    tissue #14 bar graph [filled]
  BoxSpec[164, 2] :=  99; // xs
  BoxSpec[164, 3] :=  15; // ys
  BoxSpec[164, 4] :=   3; // dx
  BoxSpec[164, 5] :=  34; // dy
  BoxSpec[164, 6] :=   0; // res
  BoxSpec[164, 7] :=   0; // mode
  BoxSpec[164, 8] :=   2; // type
  BoxSpec[164, 9] :=   0; // res

  BoxSpec[165, 1] :=   5; // win    tissue #15 bar graph [filled]
  BoxSpec[165, 2] := 105; // xs
  BoxSpec[165, 3] :=  15; // ys
  BoxSpec[165, 4] :=   3; // dx
  BoxSpec[165, 5] :=  34; // dy
  BoxSpec[165, 6] :=   0; // res
  BoxSpec[165, 7] :=   0; // mode
  BoxSpec[165, 8] :=   2; // type
  BoxSpec[165, 9] :=   0; // res

  BoxSpec[166, 1] :=   5; // win    tissue #16 bar graph [filled]
  BoxSpec[166, 2] := 111; // xs
  BoxSpec[166, 3] :=  15; // ys
  BoxSpec[166, 4] :=   3; // dx
  BoxSpec[166, 5] :=  34; // dy
  BoxSpec[166, 6] :=   0; // res
  BoxSpec[166, 7] :=   0; // mode
  BoxSpec[166, 8] :=   2; // type
  BoxSpec[166, 9] :=   0; // res

  BoxSpec[167, 1] :=   5; // win    100% horizontal line [dotted]
  BoxSpec[167, 2] :=  18; // xs
  BoxSpec[167, 3] :=  20; // ys
  BoxSpec[167, 4] :=  97; // dx
  BoxSpec[167, 5] :=   0; // dy
  BoxSpec[167, 6] :=   0; // res
  BoxSpec[167, 7] :=   0; // res
  BoxSpec[167, 8] :=   1; // don
  BoxSpec[167, 9] :=   5; // doff

  BoxSpec[168, 1] :=   5; // win    vertical line
  BoxSpec[168, 2] :=  17; // xs
  BoxSpec[168, 3] :=  15; // ys
  BoxSpec[168, 4] :=   0; // dx
  BoxSpec[168, 5] :=  34; // dy
  BoxSpec[168, 6] :=   0; // res
  BoxSpec[168, 7] :=   0; // res
  BoxSpec[168, 8] :=   0; // don
  BoxSpec[168, 9] :=   0; // doff

  BoxSpec[169, 1] :=   5; // win    vertical scale [dotted]
  BoxSpec[169, 2] :=  16; // xs
  BoxSpec[169, 3] :=  20; // ys
  BoxSpec[169, 4] :=   0; // dx
  BoxSpec[169, 5] :=  28; // dy
  BoxSpec[169, 6] :=   0; // res
  BoxSpec[169, 7] :=   0; // res
  BoxSpec[169, 8] :=   1; // don
  BoxSpec[169, 9] :=   4; // doff

// Window DIVE PROFILE / LOG BOOK
// ******************************

  BoxSpec[170, 1] :=   9; // win     dive profile / log book [header]
  BoxSpec[170, 2] :=   4; // xs
  BoxSpec[170, 3] :=   4; // ys
  BoxSpec[170, 4] :=  94; // dx
  BoxSpec[170, 5] :=   7; // dy
  BoxSpec[170, 6] :=   1; // text orientation (1=mid)
  BoxSpec[170, 7] :=   2; // font
  BoxSpec[170, 8] :=   0; // dmax/dnum
  BoxSpec[170, 9] :=  03; // ddel/inv

  BoxSpec[171, 1] :=   9; // win    arrow up symbol
  BoxSpec[171, 2] := 101; // xs
  BoxSpec[171, 3] :=   4; // ys
  BoxSpec[171, 4] :=   7; // dx
  BoxSpec[171, 5] :=   7; // dy
  BoxSpec[171, 6] :=   0; // res
  BoxSpec[171, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[171, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[171, 9] :=  00; // res/dmod

  BoxSpec[172, 1] :=   9; // win    arrow down symbol
  BoxSpec[172, 2] := 101; // xs
  BoxSpec[172, 3] := 106; // ys
  BoxSpec[172, 4] :=   7; // dx
  BoxSpec[172, 5] :=   7; // dy
  BoxSpec[172, 6] :=   0; // res
  BoxSpec[172, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[172, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[172, 9] :=  00; // res/dmod

  BoxSpec[173, 1] :=   9; // win     close / page n/m
  BoxSpec[173, 2] :=   4; // xs
  BoxSpec[173, 3] := 106; // ys
  BoxSpec[173, 4] :=  94; // dx
  BoxSpec[173, 5] :=   7; // dy
  BoxSpec[173, 6] :=   2; // text orientation (2=right)
  BoxSpec[173, 7] :=   2; // font
  BoxSpec[173, 8] :=   0; // dmax/dnum
  BoxSpec[173, 9] :=   0; // ddel/dmod

  BoxSpec[174, 1] :=   9; // win    select dive symbol
  BoxSpec[174, 2] := 101; // xs
  BoxSpec[174, 3] :=  14; // ys  (ys = 14 + 0..10 * 8)
  BoxSpec[174, 4] :=   7; // dx
  BoxSpec[174, 5] :=   7; // dy
  BoxSpec[174, 6] :=   0; // res
  BoxSpec[174, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[174, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[174, 9] :=  00; // res/dmod

  BoxSpec[175, 1] :=   9; // win     start date & time [dd DD.MM.YY hh:mmA/P]
  BoxSpec[175, 2] :=   4; // xs      and dive number of the day (0..9)
  BoxSpec[175, 3] :=  14; // ys
  BoxSpec[175, 4] :=  79; // dx
  BoxSpec[175, 5] :=   7; // dy
  BoxSpec[175, 6] :=   0; // text orientation (0=left)
  BoxSpec[175, 7] :=   2; // font
  BoxSpec[175, 8] :=   0; // dmax/dnum
  BoxSpec[175, 9] :=  00; // ddel/dmod

  BoxSpec[176, 1] :=   9; // win     log dive number (nnnn)
  BoxSpec[176, 2] :=  81; // xs
  BoxSpec[176, 3] :=  14; // ys
  BoxSpec[176, 4] :=  17; // dx
  BoxSpec[176, 5] :=   7; // dy
  BoxSpec[176, 6] :=   2; // text orientation (2=right)
  BoxSpec[176, 7] :=   2; // font
  BoxSpec[176, 8] :=   0; // dmax/dnum
  BoxSpec[176, 9] :=  00; // ddel/dmod

  BoxSpec[177, 1] :=   9; // win    depth unit symbol [m/ft]
  BoxSpec[177, 2] :=   4; // xs
  BoxSpec[177, 3] :=  24; // ys
  BoxSpec[177, 4] :=   7; // dx
  BoxSpec[177, 5] :=   7; // dy
  BoxSpec[177, 6] :=   0; // res
  BoxSpec[177, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[177, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[177, 9] :=  00; // res/dmod

  BoxSpec[178, 1] :=   9; // win    dive time unit [MIN]
  BoxSpec[178, 2] :=   4; // xs
  BoxSpec[178, 3] :=  86; // ys
  BoxSpec[178, 4] :=  16; // dx
  BoxSpec[178, 5] :=   7; // dy
  BoxSpec[178, 6] :=   0; // text orientation (0=left)
  BoxSpec[178, 7] :=   2; // font
  BoxSpec[178, 8] :=   0; // dmax/dnum
  BoxSpec[178, 9] :=   0; // res/dmod

  BoxSpec[179, 1] :=   9; // win    move dive point symbol
  BoxSpec[179, 2] := 101; // xs
  BoxSpec[179, 3] :=  96; // ys
  BoxSpec[179, 4] :=   7; // dx
  BoxSpec[179, 5] :=   7; // dy
  BoxSpec[179, 6] :=   0; // res
  BoxSpec[179, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[179, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[179, 9] :=  00; // res/dmod

  BoxSpec[180, 1] :=   9; // win     dive profile graphic
  BoxSpec[180, 2] :=  18; // xs
  BoxSpec[180, 3] :=  23; // ys
  BoxSpec[180, 4] :=  81; // dx
  BoxSpec[180, 5] :=  61; // dy
  BoxSpec[180, 6] :=   0; // box type [rect. edges]
  BoxSpec[180, 7] :=   0; // font
  BoxSpec[180, 8] :=  00; // dmax/dnum
  BoxSpec[180, 9] :=  00; // ddel/dmod

  BoxSpec[181, 1] :=   9; // win     depth scale label 1
  BoxSpec[181, 2] :=   3; // xs
  BoxSpec[181, 3] :=  31; // ys
  BoxSpec[181, 4] :=  13; // dx
  BoxSpec[181, 5] :=   7; // dy
  BoxSpec[181, 6] :=   2; // text orientation (2=right)
  BoxSpec[181, 7] :=   2; // font
  BoxSpec[181, 8] :=  30; // dmax/dnum
  BoxSpec[181, 9] :=  00; // ddel/dmod

  BoxSpec[182, 1] :=   9; // win     depth scale label 2
  BoxSpec[182, 2] :=   3; // xs
  BoxSpec[182, 3] :=  41; // ys
  BoxSpec[182, 4] :=  13; // dx
  BoxSpec[182, 5] :=   7; // dy
  BoxSpec[182, 6] :=   2; // text orientation (2=right)
  BoxSpec[182, 7] :=   2; // font
  BoxSpec[182, 8] :=  30; // dmax/dnum
  BoxSpec[182, 9] :=  00; // ddel/dmod

  BoxSpec[183, 1] :=   9; // win     depth scale label 3
  BoxSpec[183, 2] :=   3; // xs
  BoxSpec[183, 3] :=  51; // ys
  BoxSpec[183, 4] :=  13; // dx
  BoxSpec[183, 5] :=   7; // dy
  BoxSpec[183, 6] :=   2; // text orientation (2=right)
  BoxSpec[183, 7] :=   2; // font
  BoxSpec[183, 8] :=  30; // dmax/dnum
  BoxSpec[183, 9] :=  00; // ddel/dmod

  BoxSpec[184, 1] :=   9; // win     depth scale label 4
  BoxSpec[184, 2] :=   3; // xs
  BoxSpec[184, 3] :=  61; // ys
  BoxSpec[184, 4] :=  13; // dx
  BoxSpec[184, 5] :=   7; // dy
  BoxSpec[184, 6] :=   2; // text orientation (2=right)
  BoxSpec[184, 7] :=   2; // font
  BoxSpec[184, 8] :=  30; // dmax/dnum
  BoxSpec[184, 9] :=  00; // ddel/dmod

  BoxSpec[185, 1] :=   9; // win     depth scale label 5
  BoxSpec[185, 2] :=   3; // xs
  BoxSpec[185, 3] :=  71; // ys
  BoxSpec[185, 4] :=  13; // dx
  BoxSpec[185, 5] :=   7; // dy
  BoxSpec[185, 6] :=   2; // text orientation (2=right)
  BoxSpec[185, 7] :=   2; // font
  BoxSpec[185, 8] :=  30; // dmax/dnum
  BoxSpec[185, 9] :=  00; // ddel/dmod

  BoxSpec[186, 1] :=   9; // win    horizontal top line
  BoxSpec[186, 2] :=   3; // xs
  BoxSpec[186, 3] :=  22; // ys
  BoxSpec[186, 4] :=  96; // dx
  BoxSpec[186, 5] :=   0; // dy
  BoxSpec[186, 6] :=   0; // res
  BoxSpec[186, 7] :=   0; // res
  BoxSpec[186, 8] :=   0; // don
  BoxSpec[186, 9] :=   0; // doff

  BoxSpec[187, 1] :=   9; // win    x scale axis
  BoxSpec[187, 2] :=   3; // xs
  BoxSpec[187, 3] :=  84; // ys
  BoxSpec[187, 4] :=  96; // dx
  BoxSpec[187, 5] :=   0; // dy
  BoxSpec[187, 6] :=   0; // res
  BoxSpec[187, 7] :=   0; // res
  BoxSpec[187, 8] :=   0; // don
  BoxSpec[187, 9] :=   0; // doff

  BoxSpec[188, 1] :=   9; // win    x scale ticks (dotted)
  BoxSpec[188, 2] :=  27; // xs
  BoxSpec[188, 3] :=  85; // ys
  BoxSpec[188, 4] :=  62; // dx
  BoxSpec[188, 5] :=   0; // dy
  BoxSpec[188, 6] :=   0; // res
  BoxSpec[188, 7] :=   0; // res
  BoxSpec[188, 8] :=   1; // don
  BoxSpec[188, 9] :=   9; // doff

  BoxSpec[189, 1] :=   9; // win    y scale axis
  BoxSpec[189, 2] :=  17; // xs
  BoxSpec[189, 3] :=  23; // ys
  BoxSpec[189, 4] :=   0; // dx
  BoxSpec[189, 5] :=  61; // dy
  BoxSpec[189, 6] :=   0; // res
  BoxSpec[189, 7] :=   0; // res
  BoxSpec[189, 8] :=   0; // don
  BoxSpec[189, 9] :=   0; // doff

  BoxSpec[190, 1] :=   9; // win    x scale ticks (dotted)
  BoxSpec[190, 2] :=  16; // xs
  BoxSpec[190, 3] :=  24; // ys
  BoxSpec[190, 4] :=   0; // dx
  BoxSpec[190, 5] :=  59; // dy
  BoxSpec[190, 6] :=   0; // res
  BoxSpec[190, 7] :=   0; // res
  BoxSpec[190, 8] :=   1; // don
  BoxSpec[190, 9] :=   4; // doff

  BoxSpec[191, 1] :=   9; // win     time scale label 1
  BoxSpec[191, 2] :=  21; // xs
  BoxSpec[191, 3] :=  86; // ys
  BoxSpec[191, 4] :=  13; // dx
  BoxSpec[191, 5] :=   7; // dy
  BoxSpec[191, 6] :=   1; // text orientation (1=mid)
  BoxSpec[191, 7] :=   2; // font
  BoxSpec[191, 8] :=  30; // dmax/dnum
  BoxSpec[191, 9] :=  00; // ddel/dmod

  BoxSpec[192, 1] :=   9; // win     time scale label 2
  BoxSpec[192, 2] :=  41; // xs
  BoxSpec[192, 3] :=  86; // ys
  BoxSpec[192, 4] :=  13; // dx
  BoxSpec[192, 5] :=   7; // dy
  BoxSpec[192, 6] :=   1; // text orientation (1=mid)
  BoxSpec[192, 7] :=   2; // font
  BoxSpec[192, 8] :=  30; // dmax/dnum
  BoxSpec[192, 9] :=  00; // ddel/dmod

  BoxSpec[193, 1] :=   9; // win     time scale label 3
  BoxSpec[193, 2] :=  61; // xs
  BoxSpec[193, 3] :=  86; // ys
  BoxSpec[193, 4] :=  13; // dx
  BoxSpec[193, 5] :=   7; // dy
  BoxSpec[193, 6] :=   1; // text orientation (1=mid)
  BoxSpec[193, 7] :=   2; // font
  BoxSpec[193, 8] :=  30; // dmax/dnum
  BoxSpec[193, 9] :=  00; // ddel/dmod

  BoxSpec[194, 1] :=   9; // win     time scale label 4
  BoxSpec[194, 2] :=  81; // xs
  BoxSpec[194, 3] :=  86; // ys
  BoxSpec[194, 4] :=  13; // dx
  BoxSpec[194, 5] :=   7; // dy
  BoxSpec[194, 6] :=   1; // text orientation (1=mid)
  BoxSpec[194, 7] :=   2; // font
  BoxSpec[194, 8] :=  30; // dmax/dnum
  BoxSpec[194, 9] :=  00; // ddel/dmod

  BoxSpec[195, 1] :=   9; // win     dive time 'nnn' [MIN]
  BoxSpec[195, 2] :=   4; // xs
  BoxSpec[195, 3] :=  96; // ys
  BoxSpec[195, 4] :=  40; // dx
  BoxSpec[195, 5] :=   7; // dy
  BoxSpec[195, 6] :=   0; // text orientation (0=left)
  BoxSpec[195, 7] :=   2; // font
  BoxSpec[195, 8] :=   0; // dmax/dnum
  BoxSpec[195, 9] :=  00; // ddel/dmod

  BoxSpec[196, 1] :=   9; // win     dive depth nnn.n [m/ft]
  BoxSpec[196, 2] :=  47; // xs
  BoxSpec[196, 3] :=  96; // ys
  BoxSpec[196, 4] :=  33; // dx
  BoxSpec[196, 5] :=   7; // dy
  BoxSpec[196, 6] :=   0; // text orientation (0=left)
  BoxSpec[196, 7] :=   2; // font
  BoxSpec[196, 8] :=   0; // dmax/dnum
  BoxSpec[196, 9] :=  00; // ddel/dmod

  BoxSpec[197, 1] :=   9; // win     warning/alarm symbol
  BoxSpec[197, 2] :=  90; // xs
  BoxSpec[197, 3] :=  96; // ys
  BoxSpec[197, 4] :=   7; // dx
  BoxSpec[197, 5] :=   7; // dy
  BoxSpec[197, 6] :=   0; // res
  BoxSpec[197, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[197, 8] :=   0; // py  (y-pos in the box)
  BoxSpec[197, 9] :=  00; // ddel/dmod

  BoxSpec[198, 1] :=   9; // win    horizontal bottom line
  BoxSpec[198, 2] :=   3; // xs
  BoxSpec[198, 3] :=  94; // ys
  BoxSpec[198, 4] :=  96; // dx
  BoxSpec[198, 5] :=   0; // dy
  BoxSpec[198, 6] :=   0; // res
  BoxSpec[198, 7] :=   0; // res
  BoxSpec[198, 8] :=   0; // don
  BoxSpec[198, 9] :=   0; // doff

  BoxSpec[199, 1] :=   9; // win     cursor pointer symbol
  BoxSpec[199, 2] :=   1; // xs      dyn xs/ys
  BoxSpec[199, 3] :=   1; // ys
  BoxSpec[199, 4] :=   7; // dx
  BoxSpec[199, 5] :=   7; // dy
  BoxSpec[199, 6] :=   0; // res
  BoxSpec[199, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[199, 8] :=   0; // py  (y-pos in the box)
  BoxSpec[199, 9] :=  00; // ddel/dmod

  BoxSpec[200, 1] :=   9; // win     log parameter (dyn ys)
  BoxSpec[200, 2] :=   4; // xs
  BoxSpec[200, 3] :=  24; // ys      (ys = 24 + 0..9 * 8)
  BoxSpec[200, 4] :=  73; // dx
  BoxSpec[200, 5] :=   7; // dy
  BoxSpec[200, 6] :=   0; // text orientation (0=left)
  BoxSpec[200, 7] :=   2; // font
  BoxSpec[200, 8] :=   0; // dmax/dnum
  BoxSpec[200, 9] :=  00; // ddel/dmod

  BoxSpec[201, 1] :=   9; // win     log value nnn.n (dyn ys)
  BoxSpec[201, 2] :=  79; // xs
  BoxSpec[201, 3] :=  24; // ys      (ys = 24 + 0..9 * 8)
  BoxSpec[201, 4] :=  19; // dx
  BoxSpec[201, 5] :=   7; // dy
  BoxSpec[201, 6] :=   2; // text orientation (2=right)
  BoxSpec[201, 7] :=   2; // font
  BoxSpec[201, 8] :=   0; // dmax/dnum
  BoxSpec[201, 9] :=  00; // ddel/dmod

  { //nk// obsolete !?!       TIGER
  BoxSpec[202, 1] :=   9; // win
  BoxSpec[202, 2] :=   4; // xs
  BoxSpec[202, 3] :=  34; // ys
  BoxSpec[202, 4] :=  92; // dx
  BoxSpec[202, 5] :=   7; // dy
  BoxSpec[202, 6] :=   0; // text orientation (0=left)
  BoxSpec[202, 7] :=   2; // font
  BoxSpec[202, 8] :=   0; // dmax/dnum
  BoxSpec[202, 9] :=   0; // ddel/dmod

  BoxSpec[203, 1] :=   9; // win     text field #3
  BoxSpec[203, 2] :=   4; // xs
  BoxSpec[203, 3] :=  44; // ys
  BoxSpec[203, 4] :=  92; // dx
  BoxSpec[203, 5] :=   7; // dy
  BoxSpec[203, 6] :=   0; // text orientation (0=left)
  BoxSpec[203, 7] :=   2; // font
  BoxSpec[203, 8] :=   0; // dmax/dnum
  BoxSpec[203, 9] :=   0; // ddel/dmod

  BoxSpec[204, 1] :=   9; // win     text field #4
  BoxSpec[204, 2] :=   4; // xs
  BoxSpec[204, 3] :=  54; // ys
  BoxSpec[204, 4] :=  92; // dx
  BoxSpec[204, 5] :=   7; // dy
  BoxSpec[204, 6] :=   0; // text orientation (0=left)
  BoxSpec[204, 7] :=   2; // font
  BoxSpec[204, 8] :=   0; // dmax/dnum
  BoxSpec[204, 9] :=   0; // ddel/dmod

  BoxSpec[205, 1] :=   9; // win     text field #5
  BoxSpec[205, 2] :=   4; // xs
  BoxSpec[205, 3] :=  64; // ys
  BoxSpec[205, 4] :=  92; // dx
  BoxSpec[205, 5] :=   7; // dy
  BoxSpec[205, 6] :=   0; // text orientation (0=left)
  BoxSpec[205, 7] :=   2; // font
  BoxSpec[205, 8] :=   0; // dmax/dnum
  BoxSpec[205, 9] :=   0; // ddel/dmod

  BoxSpec[206, 1] :=   9; // win     text field #6
  BoxSpec[206, 2] :=   4; // xs
  BoxSpec[206, 3] :=  74; // ys
  BoxSpec[206, 4] :=  92; // dx
  BoxSpec[206, 5] :=   7; // dy
  BoxSpec[206, 6] :=   0; // text orientation (0=left)
  BoxSpec[206, 7] :=   2; // font
  BoxSpec[206, 8] :=   0; // dmax/dnum
  BoxSpec[206, 9] :=   0; // ddel/dmod

  BoxSpec[207, 1] :=   9; // win     text field #7
  BoxSpec[207, 2] :=   4; // xs
  BoxSpec[207, 3] :=  84; // ys
  BoxSpec[207, 4] :=  92; // dx
  BoxSpec[207, 5] :=   7; // dy
  BoxSpec[207, 6] :=   0; // text orientation (0=left)
  BoxSpec[207, 7] :=   2; // font
  BoxSpec[207, 8] :=   0; // dmax/dnum
  BoxSpec[207, 9] :=   0; // ddel/dmod

  BoxSpec[208, 1] :=   9; // win     FREI (old=close)
  BoxSpec[208, 2] :=   4; // xs
  BoxSpec[208, 3] :=  94; // ys
  BoxSpec[208, 4] :=  92; // dx
  BoxSpec[208, 5] :=   7; // dy
  BoxSpec[208, 6] :=   2; // text orientation (2=right)
  BoxSpec[208, 7] :=   2; // font
  BoxSpec[208, 8] :=   0; // dmax/dnum
  BoxSpec[208, 9] :=   0; // ddel/dmod
  }

  //nk// 210-219 ????
  BoxSpec[210, 1] :=   9; // win    2nd horizontal line
  BoxSpec[210, 2] :=   3; // xs
  BoxSpec[210, 3] :=  42; // ys
  BoxSpec[210, 4] :=  96; // dx
  BoxSpec[210, 5] :=   0; // dy
  BoxSpec[210, 6] :=   0; // res
  BoxSpec[210, 7] :=   0; // res
  BoxSpec[210, 8] :=   0; // don
  BoxSpec[210, 9] :=   0; // doff

  BoxSpec[212, 1] :=   9; // win    select surface time symbol
  BoxSpec[212, 2] := 100; // xs
  BoxSpec[212, 3] :=  14; // ys
  BoxSpec[212, 4] :=   8; // dx
  BoxSpec[212, 5] :=   6; // dy
  BoxSpec[212, 6] :=   0; // res
  BoxSpec[212, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[212, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[212, 9] :=  00; // res/dmod

  BoxSpec[213, 1] :=   9; // win    select bottom time symbol
  BoxSpec[213, 2] := 100; // xs
  BoxSpec[213, 3] :=  24; // ys
  BoxSpec[213, 4] :=   8; // dx
  BoxSpec[213, 5] :=   6; // dy
  BoxSpec[213, 6] :=   0; // res
  BoxSpec[213, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[213, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[213, 9] :=  00; // res/dmod

  BoxSpec[214, 1] :=   9; // win    select dive depth symbol
  BoxSpec[214, 2] := 100; // xs
  BoxSpec[214, 3] :=  34; // ys
  BoxSpec[214, 4] :=   8; // dx
  BoxSpec[214, 5] :=   6; // dy
  BoxSpec[214, 6] :=   0; // res
  BoxSpec[214, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[214, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[214, 9] :=  00; // res/dmod

  BoxSpec[215, 1] :=   9; // win    select surface time symbol
  BoxSpec[215, 2] := 100; // xs
  BoxSpec[215, 3] :=  84; // ys
  BoxSpec[215, 4] :=   8; // dx
  BoxSpec[215, 5] :=   6; // dy
  BoxSpec[215, 6] :=   0; // res
  BoxSpec[215, 7] :=   1; // px  (x-pos in the box)
  BoxSpec[215, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[215, 9] :=  00; // res/dmod

 //OBSOLETE ??!!
  BoxSpec[219, 1] :=   0; // win    seanus logo
  BoxSpec[219, 2] :=  13; // xs
  BoxSpec[219, 3] :=  13; // ys
  BoxSpec[219, 4] := 104; // dx
  BoxSpec[219, 5] :=  60; // dy
  BoxSpec[219, 6] :=   1; // bitmap
  BoxSpec[219, 7] :=  13; // lx  [x-dim of bitmap/LCDBYTE]
  BoxSpec[219, 8] :=  60; // ly  [y-dim of bitmap]
  BoxSpec[219, 9] :=  00; // drawing mode

// Window DIVE CATALOG
// *******************

  BoxSpec[220, 1] :=   9; // win     dive catalog [header]
  BoxSpec[220, 2] :=   4; // xs
  BoxSpec[220, 3] :=   4; // ys
  BoxSpec[220, 4] :=  94; // dx
  BoxSpec[220, 5] :=   7; // dy
  BoxSpec[220, 6] :=   1; // text orientation (1=mid)
  BoxSpec[220, 7] :=   2; // font
  BoxSpec[220, 8] :=   0; // dmax/dnum
  BoxSpec[220, 9] :=  03; // ddel/inv

  BoxSpec[221, 1] :=   9; // win    arrow up symbol
  BoxSpec[221, 2] := 101; // xs
  BoxSpec[221, 3] :=   4; // ys
  BoxSpec[221, 4] :=   7; // dx
  BoxSpec[221, 5] :=   7; // dy
  BoxSpec[221, 6] :=   0; // res
  BoxSpec[221, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[221, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[221, 9] :=  00; // res/dmod

  BoxSpec[222, 1] :=   9; // win    arrow down symbol
  BoxSpec[222, 2] := 101; // xs
  BoxSpec[222, 3] := 106; // ys
  BoxSpec[222, 4] :=   7; // dx
  BoxSpec[222, 5] :=   7; // dy
  BoxSpec[222, 6] :=   0; // res
  BoxSpec[222, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[222, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[222, 9] :=  00; // res/dmod

  BoxSpec[223, 1] :=   9; // win     close
  BoxSpec[223, 2] :=   4; // xs
  BoxSpec[223, 3] := 106; // ys
  BoxSpec[223, 4] :=  94; // dx
  BoxSpec[223, 5] :=   7; // dy
  BoxSpec[223, 6] :=   2; // text orientation (2=right)
  BoxSpec[223, 7] :=   2; // font
  BoxSpec[223, 8] :=   0; // dmax/dnum
  BoxSpec[223, 9] :=  00; // ddel/dmod

  BoxSpec[224, 1] :=   9; // win     start date [DD.MM.YY] (dyn ys)
  BoxSpec[224, 2] :=   4; // xs
  BoxSpec[224, 3] :=  24; // ys      (ys = 24 + 0..9 * 8)
  BoxSpec[224, 4] :=  29; // dx
  BoxSpec[224, 5] :=   7; // dy
  BoxSpec[224, 6] :=   0; // text orientation (0=left)
  BoxSpec[224, 7] :=   2; // font
  BoxSpec[224, 8] :=   0; // dmax/dnum
  BoxSpec[224, 9] :=  00; // ddel/dmod

  BoxSpec[225, 1] :=   9; // win     start time [hh:mmA/P] (dyn ys)
  BoxSpec[225, 2] :=  35; // xs
  BoxSpec[225, 3] :=  24; // ys      (ys = 24 + 0..9 * 8)
  BoxSpec[225, 4] :=  23; // dx
  BoxSpec[225, 5] :=   7; // dy
  BoxSpec[225, 6] :=   0; // text orientation (0=left)
  BoxSpec[225, 7] :=   2; // font
  BoxSpec[225, 8] :=   0; // dmax/dnum
  BoxSpec[225, 9] :=  00; // ddel/dmod

  BoxSpec[226, 1] :=   9; // win     dive time 'hh:mm' [min] (dyn ys)
  BoxSpec[226, 2] :=  59; // xs
  BoxSpec[226, 3] :=  24; // ys      (ys = 24 + 0..9 * 8)
  BoxSpec[226, 4] :=  19; // dx
  BoxSpec[226, 5] :=   7; // dy
  BoxSpec[226, 6] :=   2; // text orientation (2=right)
  BoxSpec[226, 7] :=   2; // font
  BoxSpec[226, 8] :=   0; // dmax/dnum
  BoxSpec[226, 9] :=  00; // ddel/dmod

  BoxSpec[227, 1] :=   9; // win     max depth nnn.n [M/ft] (dyn ys)
  BoxSpec[227, 2] :=  79; // xs
  BoxSpec[227, 3] :=  24; // ys      (ys = 24 + 0..9 * 8)
  BoxSpec[227, 4] :=  19; // dx
  BoxSpec[227, 5] :=   7; // dy
  BoxSpec[227, 6] :=   2; // text orientation (2=right)
  BoxSpec[227, 7] :=   2; // font
  BoxSpec[227, 8] :=   0; // dmax/dnum
  BoxSpec[227, 9] :=  00; // ddel/dmod

  BoxSpec[228, 1] :=   9; // win    select dive symbol 1..10 (dyn ys)
  BoxSpec[228, 2] := 101; // xs
  BoxSpec[228, 3] :=  24; // ys     (ys = 24 + 0..9 * 8)
  BoxSpec[228, 4] :=   7; // dx
  BoxSpec[228, 5] :=   7; // dy
  BoxSpec[228, 6] :=   0; // res
  BoxSpec[228, 7] :=   0; // px  (x-pos in the box)
  BoxSpec[228, 8] :=   1; // py  (y-pos in the box)
  BoxSpec[228, 9] :=  00; // res/dmod

  BoxSpec[229, 1] :=   9; // win    horizontal header line
  BoxSpec[229, 2] :=   3; // xs
  BoxSpec[229, 3] :=  22; // ys
  BoxSpec[229, 4] :=  96; // dx
  BoxSpec[229, 5] :=   0; // dy
  BoxSpec[229, 6] :=   0; // res
  BoxSpec[229, 7] :=   0; // res
  BoxSpec[229, 8] :=   0; // don
  BoxSpec[229, 9] :=   0; // doff

  DatBuff := IntToStr(MAXBOX);
  LogEvent('InitApplication', 'Boxes initialized', DatBuff);
end;

//------------------------------------------------------------------------------
// SETGLOBALDATA - Set new global data in database
//------------------------------------------------------------------ 17.02.07 --
procedure SetGlobalData;
begin
  // PERSON SETTINGS
  DiverAge      := GlobalSet[4, 1, 0];             // divers age
  DiverHeight   := GlobalSet[4, 2, 0];             // divers height [cm]
  DiverWeight   := GlobalSet[4, 3, 0];             // divers weight [kg]
  DiverGender   := GlobalSet[4, 4, 0];             // divers gender
  DiverGrade    := GlobalSet[4, 5, 0];             // divers certification grade
  DiverYears    := GlobalSet[4, 6, 0];             // divers experience (years diving)
  DiverSmoker   := GlobalSet[4, 7, 0];             // divers smoking level
  DiverFitness  := GlobalSet[4, 8, 0];             // divers actual fitness

  // EQUIPMENT SETTINGS
  // TankSize      :=  GlobalSet[5, 1, 0]

  // DIVE GAS SETTINGS

  // LIMITS SETTINGS
  WarnDepth     := GlobalSet[7, 1, 0] * CENTI;     // dive depth warning [m -> cm]
  WarnSpeed     := GlobalSet[7, 2, 0] + PROCENT;   // dive speed warning [%]
  WarnTank      := GlobalSet[7, 3, 0];             // tank warning [%]
  AlarmTank     := GlobalSet[7, 4, 0];             // tank alarm [%]
  WarnPower     := GlobalSet[7, 5, 0];             // power warning [%]
  WarnTemp      := GlobalSet[7, 6, 0] * CDEG;      // temp warning [cC]
  WarnOxPress   := GlobalSet[7, 7, 0] * CENTI;     // PPO2 warning [dbar -> mbar]
  WarnNiPress   := GlobalSet[7, 8, 0] * CENTI;     // PPN2 warning [dbar -> mbar]

  AlarmSpeed    := WarnSpeed + 20;                 // dive speed alarm [%]
  AlarmOxPress  := WarnOxPress + 100;              // PPO2 alarm [mbar]

  // PARAMETER SETTINGS
  ActivDepth    := GlobalSet[8, 1, 0];             // activation depth [cm]
  DecoStep      := GlobalSet[8, 2, 0];             // deco stop levels [m]
  SafetyTime    := GlobalSet[8, 3, 0];             // safety stop time [min]
  DeepFlag      := GlobalSet[8, 4, 0];             // depp stops [on/off]
  DepthFlag     := GlobalSet[8, 5, 0];             // true depth [on/off]
  DiveRepTime   := GlobalSet[8, 6, 0] * MSEC_MIN;  // dive end time [ms]
  AutoOffTime   := GlobalSet[8, 7, 0] * SEC_MIN;   // auto off time [s]
  LogInterval   := GlobalSet[8, 8, 0] * MSEC_SEC;  // log interval time [ms]

  IntervalTime  := DiveRepTime;                    // dive interval time [ms]

  // DISPLAY SETTINGS
  LangFlag      := GlobalSet[9, 1, 0];             // language
  UnitFlag      := GlobalSet[9, 2, 0];             // unit system
  TimeFlag      := GlobalSet[9, 3, 0];             // date and time format
  SutiFlag      := GlobalSet[9, 4, 0];             // summer time format
  Brightness    := GlobalSet[9, 5, 0];             // brightness of display [%]
  Contrast      := GlobalSet[9, 6, 0];             // contrast of display [%]
  Backlight     := GlobalSet[9, 7, 0];             // backlight time [s]
  Loudness      := GlobalSet[9, 8, 0];             // loudness of sound [%]

  // CLOCK SETTINGS
  RealYear      := GlobalSet[10, 1, 0];            // year
  RealMonth     := GlobalSet[10, 2, 0];            // month
  RealDay       := GlobalSet[10, 3, 0];            // day
  RealHour      := GlobalSet[10, 4, 0];            // hour
  RealMin       := GlobalSet[10, 5, 0];            // minute
  AlarmSet      := GlobalSet[10, 6, 0];            // alarm setting [on/off]
  AlarmHour     := GlobalSet[10, 7, 0];            // alarm hour
  AlarmMin      := GlobalSet[10, 8, 0];            // alarm minute

  RealSec       := cCLEAR;                         // seconds=00

  // GAS MIXES SETTINGS

  InitText(LangFlag);
  Daq.CalcDiverScore(DiverScore);                  // calc new diver score

  // DELPHI: not used in Tiger
  Daq.InitEnvironment(False);     // 22.05.07 nk add DoClear=False
  Profile.InitDiveProfile(cNEG);  // 03.05.07 nk opt - cNEG=redraw chart
  Track.InitDiveTrack(cNEG);
  Plan.InitDivePlan;
end;

//------------------------------------------------------------------------------
// ADDGLOBALPAR - Add GlobalSet number to dynamic setting parameter list
//------------------------------------------------------------------ 17.02.07 --
procedure AddGlobalPar(Par: Word);
var
  p: Long;
begin
  if Par = cCLEAR then begin
    for p := 0 to SETPARS - 1 do begin
      GlobalPar[p] := cCLEAR; // clear setting parameter list
    end;
    LogEvent('AddGlobalPar', 'Global parameter list cleard', sEMPTY);
    Exit;
  end else begin
    for p := 0 to SETPARS - 1 do begin
      if GlobalPar[p] = cCLEAR then begin // next free element found
        GlobalPar[p] := Par; // GlobalSet number
        Exit;
      end;
    end;
  end;

  DatBuff := IntToStr(Par);
  LogError('AddGlobalPar', 'Global parameter list full for parameter', DatBuff, $98);
end;

//------------------------------------------------------------------------------
// GETSIGNUM - Get highest number (16..1) of pending warning/alarm signal
//------------------------------------------------------------------ 17.02.07 --
procedure GetSigNum(Sig: Word; var Num: Long);
var
  i, lim: Long;
begin
  Num := cCLEAR;

  for i := SIGMAXNUM downto 0 do begin
    lim := Round(Power(2, i));
    if lim <= Sig then begin
      Num := i + 1;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
// FORMATVALUE - Return formatted string from given numeric value (rounded)
//   depending on conversion type
//   DELPHI rounds up in floating point formats like '%3.1f'
//   e.g.: 123.98 = 124.0 but 123.9 = 123.9
//------------------------------------------------------------------ 17.02.07 --
procedure FormatValue(Dtype: Byte; Ival: Word; var Oval: string);
var
  prec: Byte;
  ho, mi, se: Word;
  vact: Long;
  vprec: Real;
  pform: string;
begin
  prec := 0;
  Oval := sEMPTY;

  case Dtype of
    220: begin // time [s] -> 'hh:mm'
      pform := '%2d:%.2d';
      ho := Ival div SEC_HOUR;           // time [h]
      se := Ival mod SEC_HOUR;           // rest [s]
      mi := se div SEC_MIN;              // time [min]
      Oval := Format(pform, [ho, mi]);
    end;

    221: begin // time [s] -> 'mmm.m' [min]
      pform := '%3.1f';
      mi := Ival div SEC_MIN;            // time [min]
      se := Ival mod SEC_MIN;            // time [s]
      vprec := mi + se / SEC_MIN;
      Oval := Format(pform, [vprec]);
    end;

    222: begin // time [min] -> 'hh:mm'
      pform := '%2d:%.2d';
      ho := Ival div MIN_HOUR;           // time [h]
      mi := Ival mod MIN_HOUR;           // time [min]
      Oval := Format(pform, [ho, mi]);
    end;

    223: begin // expand time [s/min] -> [min/h]
      if Ival < TIMELIMIT then begin     // time [s] -> 'mmm.m' [min]
        pform := '%3.1f';
        mi := Ival div SEC_MIN;          // time [min]
        se := Ival mod SEC_MIN;          // time [s]
        vprec := mi + se / SEC_MIN;
        Oval := Format(pform, [vprec]);  // 'mmm.m'
      end else begin                     // time [min] -> 'hh:mm' [h]
        pform := '%2d:%.2d';
        vact := Ival - TIMELIMIT;
        vact := vact + TIMELIMIT div SEC_MIN;
        ho := vact div MIN_HOUR;         // time [h]
        mi := vact mod MIN_HOUR;         // time [min]
        Oval := Format(pform, [ho, mi]); // 'hh:mm'
      end;
    end;

    // 224-227 reserved

    228: begin // altitude [m] -> 'nnnn' [m]
      pform := '%4d';
      vact := Ival;                      // altitude [m]
      Oval := Format(pform, [vact]);
    end;

    229: begin // altitude [m] -> 'nnnn' [Dft]
      pform := '%4d';
      vact := Ival;                      // altitude [m]
      prec := 0;
      ConvertValue(vact, prec, 229);     // m -> ft
      prec := (vact mod DEZI) * DEZI;
      vact := vact div DEZI;             // Dft (10ft)
      if prec >= cHALF then begin
        vact := vact + 1;                // round up
      end;
      Oval := Format(pform, [vact]);
    end;

    230: begin // temperature [°C] -> '+/-nnn' [°C]
      pform := '%3d';
      vact := Ival;
      Oval := Format(pform, [vact]);
    end;

    231: begin // temperature [°C] -> '+/-nnn' [°F]  (round)
      pform := '%3d';
      vact := Ival;
      prec := 0;
      ConvertValue(vact, prec, 231);     // °C -> °F
      if prec >= cHALF then begin
        vact := vact + 1;                // round up
      end;
      Oval := Format(pform, [vact]);
    end;

    232: begin // pressure [dbar] -> 'n.n' [bar]
      pform := '%1.1f';
      vprec := Ival / DEZI;
      Oval := Format(pform, [vprec]);
    end;

    233: begin // pressure [dbar] -> 'n.n' [ATA]
      pform := '%1.1f';
      vprec := Ival / DEZI;
      Oval := Format(pform, [vprec]);
    end;

    234: begin // pressure [cbar] -> 'nnnn' [bar]  (round 34450cbar = 345bar)
      pform := '%4d';
      vact := Ival div CENTI;            // pressure [bar]
      prec := Ival mod CENTI;
      if prec >= cHALF then begin
        vact := vact + 1;                // round up
      end;
      Oval := Format(pform, [vact]);
    end;

    235: begin // pressure [cbar] -> 'nnnn' [PSI]
      pform := '%4d';
      vact := Ival div CENTI;            // pressure [bar]
      prec := Ival mod CENTI;            // pressure [cbar]
      ConvertValue(vact, prec, 235);     // bar -> psi
      if prec >= cHALF then begin
        vact := vact + 1;                // round up
      end;
      Oval := Format(pform, [vact]);
    end;

    236: begin // air pressure [hPa] -> 'nnnn' [hPa]
      pform := '%4d';
      vact := Ival;                      // air pressure [hPa]
      Oval := Format(pform, [vact]);
    end;

    237: begin // air pressure [hPa] -> 'nn.n' [inHG]
      pform := '%2.1f';
      vact := Ival;                      // air pressure [hPa]
      prec := 0;
      ConvertValue(vact, prec, 237);     // hPa -> inHG
      vprec := vact + prec / RESOLUT;
      Oval := Format(pform, [vprec]);
    end;

    238: begin // length [dm] -> 'nnn.n' [m]
      pform := '%3.1f';
      vprec := Ival / DEZI;              // length [m]
      Oval := Format(pform, [vprec]);
    end;

    239: begin // length [dm] -> 'nnn.n' [yd]
      pform := '%3.1f';
      vact := Ival div DEZI;             // length [m]
      prec := (Ival mod DEZI) * DEZI;    // length [cm]
      ConvertValue(vact, prec, 239);     // m -> yd
      vprec := vact + prec / RESOLUT;
      Oval := Format(pform, [vprec]);
    end;

    240: begin // temperature [cK] -> '+/-nnn.n' [°C]
      pform := '%3.1f';
      vact := Ival;
      vprec := (vact - KELVIN) / CENTI;
      Oval := Format(pform, [vprec]);
    end;

    241: begin // temperature [cK] -> '+/-nnn.n' [°F]
      pform := '%3.1f';
      vact := Ival - KELVIN;             // [cC]
      prec := 0;
      ConvertValue(vact, prec, 241);     // cC -> cF (1/100°F)
      vprec := (vact + prec / RESOLUT) / CENTI; // [°F]
      Oval := Format(pform, [vprec]);
    end;

    242: begin // length [cm] -> 'nnn' [cm]
      pform := '%3d';
      vact := Ival;
      Oval := Format(pform, [vact]);
    end;

    243: begin // length [cm] -> 'nnn' [in]
      pform := '%3d';
      vact := Ival;
      prec := 0;
      ConvertValue(vact, prec, 243);     // cm -> in
      if prec >= cHALF then begin
        vact := vact + 1;                // round up
      end;
      Oval := Format(pform, [vact]);
    end;

    244: begin // weight [kg] -> 'nnn' [kg]
      pform := '%3d';
      vact := Ival;
      Oval := Format(pform, [vact]);
    end;

    245: begin // weight [kg] -> 'nnn' [lb]
      pform := '%3d';
      vact := Ival;
      prec := 0;
      ConvertValue(vact, prec, 245);     // kg -> lb
      if prec >= cHALF then begin
        vact := vact + 1;                // round up
      end;
      Oval := Format(pform, [vact]);
    end;

    246: begin // length [cm] -> 'nnn.n' [m]
      pform := '%3.1f';
      vact := Ival div CENTI;           // length [m]
      prec := Ival mod CENTI;           // length [cm]
      vprec := vact + prec / RESOLUT;
      Oval := Format(pform, [vprec]);
    end;

    247: begin // length [cm] -> 'nnn.n' [ft]
      pform := '%3.1f';
      vact := Ival div CENTI;            // length [m]
      prec := Ival mod CENTI;            // length [cm]
      ConvertValue(vact, prec, 247);     // m -> ft
      vprec := vact + prec / RESOLUT;
      Oval := Format(pform, [vprec]);
    end;

    248: begin // length [m] -> 'nnn' [m]
      pform := '%3d';
      vact := Ival;                      // length [m];
      Oval := Format(pform, [vact]);
    end;

    249: begin // length [m] -> 'nnn' [ft] (round 1m = 3ft)
      pform := '%3d';
      vact := Ival;                      // length [m]
      prec := 0;
      ConvertValue(vact, prec, 249);     // m -> ft
      Oval := Format(pform, [vact]);
    end;

    250: begin // length [cm] -> 'nnnn' [cm]
      pform := '%4d';
      vact := Ival;                      // length [cm]
      Oval := Format(pform, [vact]);
    end;

    251: begin // length [cm] -> 'nnnn' [ft] (round 30cm = 1ft)
      pform := '%4d';
      vact := Ival;                      // length [cm]
      prec := 0;
      ConvertValue(vact, prec, 251);     // cm -> ft
      Oval := Format(pform, [vact]);
    end;

    252: begin // length [m] -> 'nnn' [m]
      pform := '%3d';
      vact := Ival;                      // length [m]
      Oval := Format(pform, [vact]);
    end;

    253: begin // length [m] -> 'nnn' [ft] (round 3m = 10ft)
      pform := '%3d';
      vact := Ival;                      // length [m]
      prec := 0;
      ConvertValue(vact, prec, 253);     // m -> ft
      Oval := Format(pform, [vact]);
    end;

    254: begin // length [cm] -> 'n.nn' [m.cm]
      pform := '%1.2f';
      vprec := Ival / CENTI;
      Oval := Format(pform, [vprec]);
    end;

    255: begin // length [in] -> 'n.nn' [ft.in]
      pform := '%1.2f';
      ho := Ival div INCH_FEET;          // length [ft]
      mi := Ival mod INCH_FEET;          // length [in]
      vact := RESOLUT * ho + mi;         // format 'fii'
      vprec := vact / CENTI;
      Oval := Format(pform, [vprec]);
    end;

    else begin
      DatBuff := IntToStr(Dtype);
      LogError('FormatValue', 'Unsupported unit', DatBuff, $90);
    end;
  end;
end;

//------------------------------------------------------------------------------
// CONVERTVALUE - Convert numeric value from metrical to imperial unit system
//   or vice versa with the best possible accuracy (not rounded)
//   Return: Converted numeric value in the format Vact.Prec (resolution = 1/100)
//   Note: Tuni is also the pointer to the unit text Mask[Tuni]
//------------------------------------------------------------------ 17.02.07 --
procedure ConvertValue(var Vact: Long; var Prec: Byte; Tuni: Byte);
var
  vtemp: Long;
  vprec: Real;
begin
  vprec := Vact + Prec / RESOLUT;

  case Tuni of

    // 220 - 223 reserved for time conversion
    // 224 - 227 reserved for unit conversion

    228: vprec := vprec * 100 / FEET;                              // ft -> m
    229: vprec := vprec * FEET / 100;                              // m -> ft

    230: vprec := ((vprec * MILLI - COFFSET) / CFACTOR) / CENTI;   // °F -> °C
    231: vprec := (vprec * CENTI * CFACTOR + COFFSET) / MILLI;     // °C -> °F

    232: vprec := vprec;                                           // ata -> bar
    233: vprec := vprec;                                           // bar -> ata

    234: vprec := vprec * 10 / PSI;                                // psi -> bar
    235: vprec := vprec * PSI / 10;                                // bar -> psi

    236: vprec := vprec * 100000 / INHG;                           // inHG -> hPa
    237: vprec := vprec * INHG / 100000;                           // hPa -> inHG

    238: vprec := vprec * 1000 / YARD;                             // yd -> m
    239: vprec := vprec * YARD / 1000;                             // m -> yd

    240: vprec := (vprec * 10 - COFFSET) / CFACTOR;                // cF -> cC
    241: vprec := (vprec * CFACTOR + COFFSET) / 10;                // cC -> cF

    242: vprec := vprec * 1000 / INCH;                             // in -> cm
    243: vprec := vprec * INCH / 1000;                             // cm -> in

    244: vprec := vprec * 100 / POUND;                             // lb -> kg
    245: vprec := vprec * POUND / 100;                             // kg -> lb

    246: vprec := vprec * 100 / FEET;                              // ft -> m
    247: vprec := vprec * FEET / 100;                              // m -> ft

    248: vprec := vprec * 100 / THREEFEET;                         // ft -> m (3ft = 1m)
    249: vprec := vprec * THREEFEET / 100;                         // m -> ft (1m = 3ft)

    250: vprec := vprec * 100000 / TENFEET;                        // ft -> cm (1ft = 30cm)
    251: vprec := vprec * TENFEET / 100000;                        // cm -> ft (30cm = 1ft)

    252: vprec := vprec * 1000 / TENFEET;                          // ft -> m (10ft = 3m)
    253: vprec := vprec * TENFEET / 1000;                          // m -> ft (3m = 10ft)

    254: vprec := vprec * 1000 / INCH;                             // in -> cm
    255: vprec := vprec * INCH / 1000;                             // cm -> in
  else
    begin
      DatBuff := IntToStr(Tuni);
      LogError('ConvertValue', 'Unsupported unit', DatBuff, $90);
      Exit;
    end;
  end;

  Vact := Trunc(vprec);
  vprec := RESOLUT * (vprec - Vact);
  RoundInt(vprec, vtemp);
  Prec := Limit(vtemp, 0, RESOLUT - 1);
end;

//------------------------------------------------------------------------------
// COMPRESSTIME - Compress time range [ms] to seconds or minutes if > TIMELIMIT
//------------------------------------------------------------------ 17.02.07 --
procedure CompressTime(Itime: Long; var Otime: Word);
var
  tout: Long;
begin
  if Itime < TIMELIMMSEC then begin
    Otime := Itime div MSEC_SEC; // [s]
  end else begin
    tout := Itime - TIMELIMMSEC; // [ms]
    tout := tout div MSEC_MIN;   // [min]
    Otime := tout + TIMELIMIT;
  end;
end;

//------------------------------------------------------------------------------
// EXPANDTIME - Expand time range [s/min] to seconds if > TIMELIMIT
//------------------------------------------------------------------ 17.02.07 --
procedure ExpandTime(Itime: Word; var Otime: Long);
begin
  if Itime < TIMELIMIT then begin // time [s]
    Otime := Itime;
  end else begin                  // time [min] -> [s]
    Otime := (Itime - TIMELIMIT) * SEC_MIN;
    Otime := Otime + TIMELIMIT;
  end;
end;


end.
