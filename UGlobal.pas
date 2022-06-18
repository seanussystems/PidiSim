// Global Constants and Definitions
// Date 03.08.21

// 08.09.07 nk opt replace NULL with NADA (null is reserved by Variants!!)
// 08.09.07 nk opt collect all time/date formates in UGlobal
// 04.10.08 nk add shortcuts (hotheys) with <Ctrl>+<NK_> keys
// 29.09.10 nk upd to Delphi XE (2011) Unicode UTF-16LE (Code site 1200)
// 10.10.10 nk add new button captions 'Save'...
// 20.02.14 nk upd to Delphi XE3 (VER240 Version 24)
// 03.08.21 nk add all non defined ASCII constants from 0..32

// Character encoding scheme is Unicode UTF-16LE (Code site 1200)
// ASCII Character Code Table is 'Windows West' (7-Bit only #0..#127)
// Decimal Separator is the dot (.)
// Thousand Separator is none (cNUL)

{ Mouse buttons (e.g. on WM_MOUSEWHEEL message / 12.04.11 nk add ff
  MK_LBUTTON   = $0001 - left mouse button is down
  MK_RBUTTON   = $0002 - right mouse button is down
  MK_SHIFT     = $0004 - SHIFT key is down
  MK_CONTROL   = $0008 - CTRL key is down
  MK_MBUTTON   = $0010 - middle mouse button is down
  MK_XBUTTON1  = $0020 - first X button is down
  MK_XBUTTON2  = $0040 - second X button is down

  see more self defined MB_ constants below
}

{ Shortcuts / Keyboard Codes: GetKeyState(Int Key) / OnKeyPress(Key: Char) - Use Ord(Key)
  VK_LBUTTON   VK_RBUTTON  VK_CANCEL     VK_MBUTTON   VK_BACK      VK_TAB
  VK_CLEAR     VK_RETURN   VK_SHIFT      VK_CONTROL   VK_MENU      VK_PAUSE
  VK_CAPITAL   VK_ESCAPE   VK_SPACE      VK_PRIOR     VK_NEXT      VK_HOME
  VK_PRINT     VK_LEFT     VK_UP         VK_RIGHT     VK_DOWN      VK_END
  VK_SNAPSHOT  VK_INSERT   VK_DELETE     VK_HELP      VK_NUMLOCK   VK_SCROLL
  VK_NUMPAD0...VK_NUMPAD9  VK_F1.........VK_F24       VK_EXECUTE   VK_SEPARATOR
  VK_MULTIPLY  VK_ADD      VK_SUBTRACT   VK_DIVIDE    VK_DECIMAL   VK_SELECT

  NK_MULTIPLY  NK_ADD      NK_SUBTRACT   NK_DIVIDE (see more self defined NK_constants below)

  NOTE: VK_RETURN = [Enter] on Numeric Block / VK_EXECUTE = [Enter] on Alphanumeric Keyboard
}

unit UGlobal;

interface

type
{$IFDEF WIN64} //20.02.14 nk add - floating point size for 64-bit system
  Float = Double;
{$ELSE}
  Float = Single;
{$ENDIF}

  TNumSet   = set of Byte;
  TCharSet  = set of AnsiChar;  //xe// 12.05.10 nk mov from USystem
  TIntArray = array of Integer; //05.04.10 nk add

//C Data Type    Delphi Type
  LPSTR        = PAnsiChar;  // string > pointer
  LPCSTR       = PAnsiChar;  // string > pointer
  DWORD        = Longword;   // whole numbers
  BOOL         = Longbool;   // boolean values
  PBOOL        = ^BOOL;      // pointer to a Boolean value
  PBYTE        = ^Byte;      // pointer to a byte value
  PINT         = ^Integer;   // pointer to an integer value
  PSINGLE      = ^Single;    // pointer to a single (floating point) value
  PWORD        = ^Word;      // pointer to a 16-bit value
  PDWORD       = ^DWORD;     // pointer to a 32-bit value
  LPDWORD      = PDWORD;     // pointer to a 32-bit value
  UCHAR        = Byte;       // 8-bit values (can represent characters)
  PUCHAR       = ^Byte;      // pointer to 8-bit values
  SHORT        = Smallint;   // 16-bit whole numbers
  UINT         = Integer;    // 32-bit whole numbers
  PUINT        = ^UINT;      // pointer to 32-bit whole numbers
  ULONG        = Longint;    // 32-bit whole numbers
  PULONG       = ^ULONG;     // pointer to 32-bit whole numbers
  PLONGINT     = ^Longint;   // pointer to 32-bit values
  PINTEGER     = ^Integer;   // pointer to 32-bit values
  PSMALLINT    = ^Smallint;  // pointer to 16-bit values
  PDOUBLE      = ^Double;    // pointer to double (floating point) values
  LCID         = DWORD;      // local identifier
  LANGID       = Word;       // language identifier
//THandle      = Integer;    // object handle   / 20.02.14 nk del ff - defined by System
//PHandle      = ^THandle;   // pointer to a handle
  WPARAM       = Longint;    // 32-bit message parameter.
  LPARAM       = Longint;    // 32-bit message parameter
  LRESULT      = Longint;    // 32-bit function return value
  HWND         = Integer;    // handle to a window            //nk//check if Cardinal (same as THandle) !?!
  HHOOK        = Integer;    // handle to an installed Windows system hook
  ATOM         = Word;       // index into the local or global atom table for a string
//HGLOBAL      = THandle;    // handle identifying a globally allocated dynamic memory object
  HLOCAL       = THandle;    // handle identifying a locally allocated dynamic memory object
  FARPROC      = Pointer;    // pointer to a procedure
  HGDIOBJ      = Integer;    // handle to a GDI object (pens, device contexts, brushes...)
  HBITMAP      = Integer;    // handle to a Windows bitmap object
  HBRUSH       = Integer;    // handle to a Windows brush object
  HENHMETAFILE = Integer;    // handle to a Windows enhanced metafile object
  HFONT        = Integer;    // handle to a Windows logical font object
  HICON        = Integer;    // handle to a Windows icon object
  HMENU        = Integer;    // handle to a Windows menu object
  HMETAFILE    = Integer;    // handle to a Windows metafile object
  HINST        = Integer;    // handle to an instance object
  HMODULE      = HINST;      // handle to a module
  HPALETTE     = Integer;    // handle to a Windows color palette
  HPEN         = Integer;    // handle to a Windows pen object
  HRGN         = Integer;    // handle to a Windows region object
  HRSRC        = Integer;    // handle to a Windows resource object
  HKL          = Integer;    // handle to a keyboard layout
  HFILE        = Integer;    // handle to an open file
  HCURSOR      = HICON;      // handle to a Windows mouse cursor object
  COLORREF     = DWORD;      // Windows color reference value (red, green, blue)

const
  //control codes and special characters  21.11.07 nk add ff

  CLEAR = 0;
  DONE  = 1;          //04.03.08 nk add
  NONE  = -1;
  NAL   = 48;         //ASCII code for number '0'
  ASCII = 65;         //ASCII code for capital character 'A'
  SMALL = 97;         //ASCII code for small character 'a'
  LOWER = 32;         //ASCII diff between upper and lower case

  NERR_SUCCESS = 0;   //22.03.08 nk mov from UInternet
  NUM0         = 48;  //19.10.08 nk add ff (ASCII decimal code)
  NUM9         = 57;
  NUM_CHARS    = 26;
  NUM_ALPHA    = 52;  //17.07.09 nk add
  NUM_NUMBS    = 10;
  ASCII_NUMB   = 48;
  ASCII_BIG    = 65;
  ASCII_SMALL  = 97;
  ASCII_SPACE  = 32;   //17.07.07 nk add ff
  ASCII_LAST   = 127;
  FONT_NORM    = 96;   //02.04.08 nk add normal font = 96dpi

  //12.04.11 nk add ff - mouse & control button bits
  MB_LBUTTON   = 0;  //left mouse button is down
  MB_RBUTTON   = 1;  //right mouse button is down
  MB_SHIFT     = 2;  //SHIFT key is down
  MB_CONTROL   = 3;  //CTRL key is down
  MB_MBUTTON   = 4;  //middle mouse button is down
  MB_XBUTTON1  = 5;  //first X button is down
  MB_XBUTTON2  = 6;  //second X button is down

  //13.01.13 nk add ff - special keys for TWmHotKey message (bit-coded - can be or-ed)
  MOD_NONE     = 0;
  MOD_ALT      = 1;
  MOD_CTRL     = 2;
  MOD_SHIFT    = 4;
  MOD_WIN      = 8;

  //29.10.09 nk opt ff - shortcuts (hotkeys) with <Ctrl+NK_>
  //use like: mnPrint.ShortCut := ShortCut(NK_PRINT, [ssCtrl]); //<Crtl+P>
  NK_FIT     = Ord('0');
  NK_ZOOM    = Ord('1');
  NK_ALL     = Ord('A');
  NK_COPY    = Ord('C');
  NK_FIND    = Ord('F');
  NK_IMPORT  = Ord('I');  //V5//19.04.16 nk old=NK_INSPECT
  NK_NEW     = Ord('N');
  NK_frei    = Ord('M');  //V5//19.04.16 nk old=NK_IMPORT
  NK_OPEN    = Ord('O');
  NK_PRINT   = Ord('P');
  NK_QUIT    = Ord('Q');
  NK_RENEW   = Ord('R');
  NK_SAVE    = Ord('S');
  NK_SETTING = Ord('T');  //29.10.09 nk add
  NK_INS     = Ord('V');
  NK_CUT     = Ord('X');
  NK_EXPORT  = Ord('X');  //17.01.09 nk add
  NK_REDO    = Ord('Y');
  NK_UNDO    = Ord('Z');

  //20.02.14 nk mov ff from Menus.pas - unused special shortcuts (hotkeys) on numeric keypad
  NK_MULTIPLY = $2A;      //correspondes with the similar VK_ constants
  NK_ADD      = $2B;
  NK_SUB      = $2D;      //no VK_SUB defined
  NK_DIVIDE   = $2F;
  NK_SUBTRACT = $96;      //long minus sign (hyphen) is NOT on numeric keypad

  //not yet defined
  // NK_FIND  = Ord('B');
  // NK_FIND  = Ord('D');
  // NK_FIND  = Ord('E');
  // NK_FIND  = Ord('G');
  // NK_FIND  = Ord('H');
  // NK_FIND  = Ord('J');
  // NK_FIND  = Ord('K');
  // NK_FIND  = Ord('L');
  // NK_FIND  = Ord('U');

  //17.07.09 nk mov from UError - symbolic constants for button caption texts
//Constants     Captions       Buttons         Results
//======================================================
  txYes       = 'Yes';         //mbYes         mrYes
  txNo        = 'No';          //mbNo          mrNo
  txOk        = 'OK';          //mbOK          mrOK
  txCancel    = 'Cancel';      //mbCancel      mrCancel
  txAbort     = 'Abort';       //mbAbort       mrAbort
  txRetry     = 'Retry';       //mbRetry       mrRetry
  txIgnore    = 'Ignore';      //mbIgnore      mrIgnore
  txAll       = 'All';         //mbAll         mrAll
  txNever     = 'Never';       //mbNoToAll     mrNoToAll     23.07.12 nk add
  txNoToAll   = 'No to all';   //mbNoToAll     mrNoToAll
  txYesToAll  = 'Yes to all';  //mbYesToAll    mrYesToAll
  txSave      = 'Save';        //mbYes         mrYes         10.10.10 nk add
  txChange    = 'Change';      //mbYes         mrYes         20.10.14 nk add
  txOverwrite = 'Overwrite';   //mbYes         mrYes         22.09.12 nk add
  txStart     = 'Start';       //mbYes         mrYes         04.10.13 nk add
  txStop       = 'Stop';       //mbYes         mrYes         06.08.17 nk add
  txSkip       = 'Skip';       //mbYes         mrYes         06.08.17 nk add
  txRestart   = 'Restart';     //mbYes         mrYes         31.05.11 nk add
  txCreate    = 'Create';      //mbYes         mrYes         31.05.11 nk add
  txDelete    = 'Delete';      //mbYes         mrYes         11.10.10 nk add
  txExport    = 'Export';      //mbYes         mrYes         11.10.10 nk add
  txImport    = 'Import';      //mbYes         mrYes         11.10.10 nk add
  txConvert   = 'Convert';     //mbYes         mrYes         08.02.13 nk add
  txDownload  = 'Download';    //mbYes         mrYes         //V5//17.05.15 nk add
  txUpdate     = 'Update';     //mbYes         mrYes         //51//05.05.18 nk add
  txInstall    = 'Install';    //mbYes         mrYes         //52//22.12.19 nk add
  tx3DWorld   = '3D World';    //mbYes         mrYes         27.05.12 nk del '-' / 08.10.11 nk add
  txContinue   = 'Continue';   //52//04.02.20 nk add
  txAgree      = 'Agree';      //52//04.02.20 nk add
  txHelp      = 'Help';        //mbHelp
  txPlay      = 'Play';        //mbYes                       16.05.12 nk add
  txTrue       = 'True';       //52//31.01.20 nk add
  txFalse      = 'False';      //52//31.01.20 nk add
  txApply     = 'Apply';       //12.04.11 nk add ff
  txRetain    = 'Retain';
  txUnknown   = 'Unknown';     //16.09.09 nk add
  txEnabled   = 'Enabled';     //25.11.10 nk add ff
  txDisabled  = 'Disabled';
  txInstalled  = 'Installed';                                 //52//22.12.19 nk old=txInstall
  txAvail     = 'Available';   //29.11.10 nk add ff
  txNotAvail  = 'Not available';
  txNoPrint   = 'No printer installed!';     //27.05.10 nk add
  txNoDefPrint= 'No default printer found!'; //V5//16.02.17 nk add
  txNotAgain   = 'Do not show it again';     //52//04.02.20 nk add

  //30.10.10 nk mov from UFile
  BoolValues: array[Boolean] of string = ('No', 'Yes');

  //01.11.09 nk opt dialog colors
  clInfo     = $00F0F0F0;  //old=$00EAE8EA
  clError    = $00CCFFFF;  //old=$00B3EAFF
  clDialog   = $00FCF7F4;  //old=$00E1DBD5

  COL_MASK   = $FFFFFF;    //12.09.15 nk add
  BIT_MASK   = $FFFFFFFF;  //12.09.15 nk mov from USystem

  MAXLOOP    = 50;         //31.07.07 nk add
  MAXBYTE    = 255;
  MAXSHORT   = 255;        //22.07.10 nk add 255 chars in short string
  MAXBUFF    = 32767;      //23.04.12 nk add
  MAXWORD    = 65535;      //17.04.07 nk add ff
  MAXEXCEL   = 1048576;    //11.12.13 nk add - max. rows in Excel (also XLSX)
  MAXINT     = 2147483647; //+/-
  MAXLONG    = 4294967295;
  LONGLEN    = 4;          //1 Longword = 4 byte 15.06.10 nk add
  BYTELEN    = 8;          //1 byte = 8 bit
  HIGHBYTE   = 256;        //high part multiplier for word
  HIGHWORD   = 65536;      //high part multiplier for long

  HA_CENTER  = 0; //24.10.07 nk add ff
  HA_LEFT    = 1;
  HA_RIGHT   = 2;
  VA_MIDDLE  = 0;
  VA_TOP     = 1;
  VA_BOTTOM  = 2;

  BITOFF     = 0;    //12.04.11 nk add ff
  BITON      = 1;

  INACTIVE   = '-1'; //14.08.12 nk add
  ISTRUE     = '-1';
  ISFALSE    = '0';
  ISOFF      = '0';
  ISON       = '1';

  EMPTY_SET          = [];                    //11.03.08 nk add
  ALL_NUMBS          = ['0'..'9'];
  ALL_NUMSETS        = ['0'..'9', ';'];       //V5//29.08.15 nk add (cCOMMA is not allowed in XML)
  ALL_FLOATS         = ['0'..'9', '.'];       //16.04.08 nk add
  NEG_FLOATS         = ['0'..'9', '.', '-'];  //20.11.14 nk add
  FILTER_DEL         = ['0'..'9', '_'];       //28.05.13 nk del '.' / 16.12.10 nk add
  SMALL_CHARS        = ['a'..'z'];
  BIG_CHARS          = ['A'..'Z'];
  ALL_CHARS          = ['A'..'Z', 'a'..'z'];  //12.03.09 nk add
  BIG_NUMBS          = ['A'..'Z', '0'..'9'];  //30.01.08 nk add ff
  SMALL_NUMBS        = ['a'..'z', '0'..'9'];
  BIG_HEX            = ['A'..'F', '0'..'9'];
  SMALL_HEX          = ['a'..'f', '0'..'9'];
  VALID_CHARS        = ['A'..'Z', 'a'..'z', '0'..'9', '_', '-'];
  VALID_TEXTS        = ['A'..'Z', 'a'..'z', '0'..'9', '_', '-', ' ', '(', ')']; //V5//12.08.15 nk add
  VALID_KEYS         = ['A'..'Z', 'a'..'z', '0'..'9', '_', '-', '+', ' ', '(', ')', '.', ':', ';', '*', #8]; //12.05.10 nk add
  VALID_DELS         = [',', ';', '|', '#'];  //09.10.12 nk add
  EDIT_KEYS          = [#8, #127];                                                         //07.07.10 nk add BACK and DEL keys
  WHITE_CHARS        = [#0..#32, #127, #160];                                              //16.07.11 nk add #160 / //xe//#129, #141, #143, #144, #157, #160];  //18.07.07 nk add ff
  INVALID_XML_CHARS  = ['<', '>', '?', '&', '"', ''''];                                    //13.12.11 nk add - invalid chars for XML entities
  INVALID_FILE_CHARS = ['/', ':', '*', '<', '>', '|', #39, '?', '.', '\', '"', '&', '''']; //13.12.11 nk add - invalid chars for file name and XML entities

  CARET_BLINK_TIME   = 500;   // ms
  HINT_DEFAULT_TIME  = 2500;  // ms
  HINT_DISPLAY_TIME  = 10000; // ms
  SMALL_ICON_DIM     = 16;
  BIG_ICON_DIM       = 32;
  FORM_OFFSET        = 50;    //01.12.10 nk add
  A4_TAB_NUM         = 84;    //16.09.09 nk add 84 chars per A4 side
  IGNORE_TAB         = 'DoIgnoreTabKey';

  K1       = 1024;
  K2       = 2048;
  K4       = 4096;
  K8       = 8192;         //04.03.08 nk add
  K16      = 16384;        //24.03.08 nk add ff
  K32      = 32768;
  M1       = 1048576;

  DECA     = 10.0;         //04.03.13 nk add
  NORM     = 1.0;          //09.12.08 nk add
  NADA     = 0.0;          //08.09.07 nk old=NULL (reserved by Variants)
  DEZI     = 0.1;          //1m = 10m
  CENTI    = 0.01;
  MILLI    = 0.001;
  PPM      = 0.000001;     //parts per million
  MICRO    = 0.000001;
  NANO     = 0.000000001;
  EPSILON  = 0.0000000001; //05.04.10 nk add

  DEKA     = 10;
  HEKTO    = 100;
  KILO     = 1000;
  MEGA     = 1000000;
  GIGA     = 1000000000;

  HALF     = 50;          //50% 22.12.07 nk add
  PROCENT  = 100;         //100%

  BASEDIR  = 90;          //angle base direction = east (90°)
  HALFDEG  = 180;         //half circle degrees (180deg = pi rad)
  FULLDEG  = 360;         //full circle degrees (360deg = 2pi rad)
  FULLDDEG = 3600;        //full circle dezidegrees (3600ddeg) = 1/10deg

  DEG      = 180.0 / PI;  //radiant -> degree
  DDEG     = 1800.0 / PI; //radiant -> decidegree [1/10°] / 19.10.14 nk add / 28.10.14 nk fix/old=18.0
  RAD      = PI / 180.0;  //degree -> radiant
  RAD90    = PI / 2.0;    //90 deg in rad
  RAD180   = PI;          //180 deg in rad  30.05.09 nk add
  RAD360   = PI * 2.0;    //31.03.15 nk add
  SQRTPI   = 1.772453851; //52//11.12.19 nk add

  YDFT     = 3;           //31.07.09 nk add 1yd = 3ft
  FTIN     = 12;          //10.12.07 nk add 1ft = 12in   //old=12.0
  YDIN     = 36;          //31.07.09 nk add 1yd = 36in
  INCM     = 2.54;        //12.01.09 nk add 1in = 2.54cm
  INCH     = 25.4;        //1in = 25.4mm
  NORMAL   = 100.0;       //25.01.13 nk add

  CFACTOR  = 1.8;         // °C -> °F temp gradient  F=Cx1.8+32
  COFFSET  = 32;          // °C -> °F temp offset 32°C
  KELVIN   = 273.15;      // °C -> °K temp offset 0°K = -273.15°C

  //53//03.08.21 nk add all non defined constants
  cNUL     = #0;          //18.07.07 nk old=cNULL
  cSOH     = #1;          //53//Start of Header
  cSTX     = #2;          //53//Start of Text
  cETX     = #3;          //53//End of Text
  cEOT     = #4;          //05.11.07 nk add End of Transmission
  cENQ     = #5;          //53//Enquiry
  cACK     = #6;          //Acknowledge
  cBEL     = #7;          //53//Bell
  cBAK     = #8;          //18.07.07 nk old=cBACKSPACE
  cTAB     = #9;          //Tabulator
  cLF      = #10;
  cVT      = #11;         //53//Vertical Tab
  cFF      = #12;         //53//Form Feed
  cCR      = #13;         //Carriage Return
  cSO      = #14;         //53//Shift Out
  cSI      = #15;         //53//Shift In
  cDLE     = #16;         //53//Dataline Escape
  cDC1     = #17;         //53//DC1
  cXON     = #17;         //53//XON
  cDC2     = #18;         //53//DC2
  cDC3     = #19;         //53//DC3
  cXOF     = #19;         //53//XOFF
  cDC4     = #20;         //53//DC4
  cERR     = #20;         //53//Error (defined by nk)
  cNAK     = #21;         //06.11.07 nk add - Negative Acknowledge
  cSYN     = #22;         //53//Synchronous Idle
  cEOB     = #23;         //53//End of Transmission Block
  cCAN     = #24;         //53//Cancel
  cEOM     = #25;         //53//End of Medium
  cSUB     = #26;         //53//Substitiude
  cESC     = #27;         //Escape
  cFS      = #28;         //53//File Separator
  cGS      = #29;         //53//Group Separator
  cRS      = #30;         //53//Record Separator
  cUS      = #31;         //53//Unit Separator
  cNONE    = #32;         //xe//old=#160

  cDEL     = #127;        //01.07.08 nk add
  cDIS     = #160;        //06.11.11 nk add
  CRLF     = #13#10;      //carriage return / line feed

  cEMPTY   = '';
  cNULL    = '0';         //18.07.07 nk add
  cNOP     = '-1';        //30.03.09 nk add
  cCOMMA   = ',';
  cCOLON   = ':';
  cSEMI    = ';';
  cSPACE   = ' ';
  cAPHOS   = '''';
  cQUOTE   = '"';
  cBACK    = '\';
  cSLASH   = '/';
  cPLUS    = '+';
  cMINUS   = '-';
  cDASH    = '-';
  cSPACER  = '—';         //16.10.11 nk add
  cSTAR    = '*';
  cEQUAL   = '=';
  cULINE   = '_';
  cNADA    = 'x';         //52//03.02.20 nk add
  cAMPER   = '&';
  cDOT     = '.';
  cQUEST   = '?';
  cEXCLAM  = '!';
  cAT      = '@';
  cPERCENT = '%';
  cPIPE    = '|';
  cCOPY    = '©';
  cHEX     = '$';
  cCARET   = '#';
  cMEAN    = 'Ø';         //18.10.09 nk add
  cGREATER = '>';
  cSMALLER = '<';
  cLPARENT = '(';         //29.01.                                         08 nk add ff
  cRPARENT = ')';
  cLBRACK  = '[';         //27.10.09 nk add ff
  cRBRACK  = ']';
  cLBRACE  = '{';         //30.07.09 nk add
  cRBRACE  = '}';
  cALL     = '*';
  cQUAD    = '²';         //18.11.07 nk add ff
  cCUBIC   = '³';
  cSEPAR   = ': ';        //08.11.07 nk add
  cWATCH   = ' !';        //V5//17.06.16 nk add
  cBLANK   = '""';        //07.12.09 nk add
  cMARKUP  = '&#';        //12.10.10 nk add
  cSPLIT   = ' - ';
  cPOS     = ' / ';
  cDIM     = ' x ';
  cIS      = ' = ';       //23.07.07 nk add
  cMORE    = '...';
  cBULLET  = ' • ';       //03.10.08 nk add
  cDARR    = ' » ';       //09.01.08 nk add ff
  cINDENT  = '   ';
  cNAV     = 'n/a';       //52//10.12.19 nk add
  cHIDDEN  = '******';    //06.08.11 nk add hidden password
  cERROR   = ' Error !';  //27.02.16 nk add
  cFREE    = 'free';      //53//11.1.20 nk add

  //time and date constants  //23.12.08 nk add ff
  USEC_MIN    = 60000000;    // microseconds per minute
  USEC_SEC    = 1000000;     // microseconds per second
  USEC_HUND   = 10000;       // microseconds per hundredth seconds
  USEC_MSEC   = 1000;        // microseconds per millisecond
  MSEC_DAY    = 86400000;    // milliseconds per day                            19.09.09 nk add
  MSEC_HOUR   = 3600000;     // milliseconds per hour                           19.09.09 nk add
  MSEC_TENMIN = 600000;      // milliseconds per 10 minutes                     07.11.11 nk add
  MSEC_MIN    = 60000;       // milliseconds per minute
  MSEC_SEC    = 1000;        // milliseconds per second
  MSEC_HUND   = 10;          // milliseconds per hundredth second               08.09.10 nk add
  HUND_DAY    = 8640000;     // hundredth seconds per day                       20.10.14 nk add
  HUND_HOUR   = 360000;      // hundredth seconds per hour                      16.08.11 nk add
  HUND_TENMIN = 60000;       // hundredth seconds per 10 minutes                26.08.12 nk add
  HUND_MIN    = 6000;        // hundredth seconds per minute
  HUND_SEC    = 100;         // hundredth seconds per second
  TENS_MIN    = 600;         // tenth seconds per minute
  TENS_SEC    = 10;          // tenth seconds per second
  SEC_MIN     = 60;          // seconds per minute
  SEC_TENMIN  = 600;         // seconds per 10 minutes                          12.04.11 nk add
  SEC_HOUR    = 3600;        // seconds per hour
  DEC_HOUR    = 6000;        // seconds per hour in decimal format (99:99)
  SEC_DECA    = 35999;       // seconds per 10 hours (9:59:59)
  SEC_DAY     = 86400;       // seconds per day
  SEC_DIGIT   = 356400;      // seconds per digit (99 hours)                    11.10.09 nk add
  SEC_CENT    = 359999;      // seconds per 100 hours (99:59:59)
  SEC_WEEK    = 604800;      // seconds per week
  SEC_YEAR    = 31536000;    // seconds per year
  SEC_4YEAR   = 126230400;   // seconds per four years
  MIN_HOUR    = 60;          // minutes per hour
  MIN_DAY     = 1440;        // minutes per day
  HOUR_DAY    = 24;          // hours per day
  HOUR_YEAR   = 8760;        // hours per year
  HOUR_LEAP   = 8784;        // hours per leap year
  HOUR_4YEAR  = 35064;       // hours per four years
  DAY_NULL    = 0;           // start of time/date range (30.12.1899 00:00)     13.01.11 nk add
  DAY_WEEK    = 7;           // days per week
  DAY_MONTH   = 31;          // days per month (01..31)
  DAY_YEAR    = 365;         // days per year
  DAY_4YEAR   = 1461;        // days per four years
  DAY_1CENT   = 36525;       // days per century (100 years)                    13.01.11 nk add ff
  DAY_2CENT   = 73050;       // days per 2 centuries (200 years)
  WEEK_YEAR   = 52;          // weeks per year
  MONTH_YEAR  = 12;          // month per year (01..12)
  YEAR_CENT   = 100;         // years per century (00..99)
  NEXT_SUNDAY = 76;          // sunday in next month (mm+100, dd-24)
  MAX_HOUR    = 23;
  MAX_MIN     = 59;
  MAX_SEC     = 59;
  MAX_DIGIT   = 99;

  //03.10.09 nk add ff - international standards (ISO/EN/DIN)
  ISO_TEMP    = 15;          //temperature [°C] of ISO standard atmosphere = 15.0°C
  ISO_PRESS   = 1013;        //pressure [mbar] of ISO standard atmosphere (1013.25hPa)
  ISO_RATIO   = 1.414;       //01.11.10 nk add ISO DIN paper size ratio

  //18.03.15 nk add ff - display formats
  FORM_SIZE   = '%d x %d';
  FORM_POS    = '%d / %d';

  //time/date formates (not case sensitive)
  TIME_SEP    = ':';     //08.05.12 nk add
  DATE_SEP    = '.';     //20.01.13 nk add
  UNIT_SEC    = 's';     //25.11.10 nk add ff
  UNIT_MIN    = 'min';
  UNIT_DPI    = 'dpi';
  WEB_SITE    = 'www';   //09.05.12 nk add
  WEB_HTTP    = 'http';  //02.02.19 nk add

  FORM_SORTID = '%3.1d'; //17.08.15 nk add
  FORM_HEX    = '%0.2X'; //30.11.10 nk add
  FORM_SERNO  = '%8.8X';
  FORM_FLOAT  = '%d.%d'; //12.01.09 nk add
  FORM_PITCH  = '  ';    //20.11.15 nk add
  FORM_HOUR   = 'hh';    //03.11.08 nk add ff
  FORM_MIN    = 'nn';
  FORM_MINS   = 'mm';
  FORM_SEC    = 'ss';
  FORM_DAY    = 'dd';    //30.11.10 nk add ff
  FORM_MONTH  = 'mm';
  FORM_YEAR   = 'yy';
  FORM_YEARS  = 'yyyy';

  FORM_TIME_SEC   = '%d s';   //12.04.11 nk add ff
  FORM_TIME_MIN   = '%d min';
  FORM_SHORT_TIME = 'hh:nn';
  FORM_LONG_TIME  = 'hh:nn:ss';
  FORM_SHORT_DATE = 'dd.mm.yy';
  FORM_LONG_DATE  = 'dd.mm.yyyy';
  FORM_DATE_TIME  = 'dd.mm.yyyy hh:nn';
  FORM_FILE_FORM  = 'yymmddhhnnss';
  FORM_MAIL_FILE  = 'yymmddhhnnsszzz';
  FORM_FILE_LONG  = 'yyyymmddhhnnss';
  FORM_DATE_COMP  = 'yy.mm.dd';        //03.11.09 nk add - format to compare file date
  FORM_MAIL_DATE  = 'dd.mm.yyyy  hh:nn:ss';
  FORM_WATCH_DATE = 'dddd dd.mm.yyyy'; //20.01.13 nk add
  FORM_SOM_DATE   = 'd. mmmm yyyy';
  FORM_SORT_DATI  = 'yyyymmddhhnnsszzz';
  FORM_SORT_DATE  = 'yyyymmdd';
  FORM_SORT_TIME  = 'hhnnsszzz';
  FORM_SHORT_YEAR = 'yyyy';
  FORM_DATE_EU    = 'dd.mm.yyyy';
  FORM_DATE_US    = 'MM/DD/YYYY';
  FORM_DATE_ISO   = 'yyyy-mm-dd';
  FORM_DATE_ORDER = 'yyyy-mm-dd hh:nn';
  FORM_DATE_LOG   = 'yyyy-mm-dd hh:nn:ss';
  FORM_DATE_INFO  = 'dddd, yyyy-mm-dd  hh:nn'; //20.11.15 nk add
  FORM_THOUSAND   = '#,##0';             //06.11.12 nk add - like 12'345'678 (Comma = FormatSettings.ThousandSeparator)
  FORM_DIGIT      = '%0.2d';             //11.10.09 nk add ff
  FORM_ALARM      = '%.2d:%.2d';         //20.01.13 nk add (hh:mm)
  FORM_TIME_MODEL = '%.2d%s%.2d';        //17.08.15 nk add
  FORM_CLOCK_TIME = '%0.2d:%0.2d:%0.2d';
  FORM_LOCAL_TIME = '%0.2d#%0.2d#%0.2d'; //08.05.12 nk add - replace '#' by locale time delimiter

  //06.08.11 nk add ff - file encoding formats
  ENCODING_XMLTAG  = 'encoding';   //22.06.11 nk add
  ENCODING_UNKNOWN = '    ';       //4 spaces - not empty
  ENCODING_HTML    = 'HTML';       //22.06.11 nk add
  ENCODING_ANSI    = 'ANSI';
  ENCODING_LATIN1  = 'ISO-8859-1'; //Latin-1 (West European) character set encoding
  ENCODING_UTF8    = 'UTF-8';      //UTF-8 (Unicode) character set encoding
  ENCODING_UTF16LE = 'UTF-16LE';
  ENCODING_UTF16BE = 'UTF-16BE';
  ENCODING_UTF32LE = 'UTF-32LE';
  ENCODING_UTF32BE = 'UTF-32BE';

  //default file prefix
  ICO_END = '.ico';
  BMP_END = '.bmp';
  JPG_END = '.jpg';
  PNG_END = '.png';  //18.12.09 nk add
  GIF_END = '.gif';
  WMF_END = '.wmf';
  EXE_END = '.exe';
  DLL_END = '.dll';
  XML_END = '.xml';
  HTM_END = '.htm';  //22.06.11 nk add
  TXT_END = '.txt';
  RTF_END = '.rtf';
  RES_END = '.res';  //24.01.08 nk add ff
  LOG_END = '.log';
  INI_END = '.ini';  //07.09.09 nk add
  TMP_END = '.tmp';
  WAV_END = '.wav';  //24.08.09 nk add
  DAT_END = '.dat';  //22.11.09 nk add
  SWR_END = '.swr';  //14.06.11 nk add
  BAK_END = '.bak';  //27.02.12 nk add ff
  SIC_END = '.sic';

implementation

end.
