// System Functions
// Date 25.07.17
// Norbert Koechli
// Copyright ©2004-2017 seanus systems

// CAUTION: Some functions try to access to the HKEY_LOCAL_MACHINE registry key
//          resulting in an empty string if the UAC is active on Windows Vista
//          and the user has no Administrator privileges!
//          ==> Open in read only mode KEY_READ (default is KEY_ALL_ACCESS)

{ TODO : Check NativeInt for 64-bit }
{ TODO : Check all time/date functions if regarding locale time/date delimiters }
{ TODO : Multi processor core to process assignment }
{ TODO : mov ..Form.. procedures to UForm }
{ TODO : all Print.. functions Titel is NOT the document header line !?! }

// Use Delphi/Project/Options/Version/OriginalFileName to check if application
// is already running, value 'MyProg.exe' is shown as 'MyProg.exe is already
// running!' (.exe is required!)

// Use Delphi/Project/Options/Version/Comments to check minimum system version
// like 'MyProg runs on Windows version 5.0 or higher only!' (dot is required!)

// 03.09.09 nk opt show build '.0' as '.Beta' version
// 16.09.09 nk add detection for Windows Server 2003, 2008, 2008 R2, and Windows 7
// 21.09.09 nk add GetMemoryEx for memory > 2GB / get page, virtual, and extended memory
// 30.09.10 nk upd to Delphi XE (2011) Unicode UTF-16LE (Code site 1200)
// 01.07.11 nk opt disable all FPU exceptions to prevent Floating Point Errors
// 17.11.11 nk opt StrToHex and HexToStr functions work on ANSI chars/strings only
// 04.01.12 nk add check if 32-Bit application is running in the WoW64-Subsystem
// 04.01.12 nk add function StrVal to get position of substring in a string list
// 04.02.12 nk add detection for Windows Server 8 and Windows 8 (Version 6.2)
// 23.04.12 nk opt expand buffer lengths from MAXBYTE to MAXBUFF charachers
// 21.01.13 nk add ExitWindows, LockSystem, MinimizeToTray, ShowTitleBar, and BeepTones
// 29.05.14 nk upd to Delphi XE3 (VER240 Version 24)
// 18.12.14 nk add detection of Windows 8.1 and Windows Server 2012 R2
// 20.12.14 nk upd to Delphi XE7 (VER280 Version 28) 32/64-Bit / Indy 10.6
// 24.04.15 nk add support for registry reading under 32 and 64-Bit systems
// 14.08.15 nk add ClockToMins and MinsToClock to convert time models
// 28.11.15 nk add SetWebbrowserMode to set WebBrowser IE compatibility version in registry
// 28.11.15 nk add GetWebbrowserMode to get WebBrowser IE compatibility version from registry
// 28.11.15 nk add detection of Windows 10 and Windows Server 2016
// 28.12.15 nk add SetFormIcon / fix bug in VCL styles regarding LoadIcon()
// 04.01.16 nk opt UNDO all Single, Double, and Extended by Float
// 10.03.16 nk add Is64BitSystem to detect if Windows system is 64-bit or not
// 20.05.16 nk opt for 64-bit version
// 27.03.17 nk fix in SetSystemTime: Regard Daylight Bias
// 25.07.17 nk add GetAllocMemSize as replacement for deprecated AllocMemSize

unit USystem;

interface

{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, Messages, SysUtils, StrUtils, Classes, Vcl.Forms, StdCtrls, Grids, Math,
  Controls, ComCtrls, PsApi, ExtCtrls, Dialogs, Printers, Variants, Graphics,
  ExtDlgs, ShlObj, Jpeg, ShellApi, Tlhelp32, WinSpool, TypInfo, UITypes, WinSvc,
  Registry, MMSystem, ActiveX, ComObj, SHFolder, UGlobal, URegistry;

const
  WM_ACTIVATED    = WM_USER + 300;
  WM_WINMESSAGE   = WM_USER + 301; //V5//11.07.16 nk add
  BCM_FIRST       = $1600;  //button control messages
  BCM_SETSHIELD   = BCM_FIRST + $000C;
  SC_DRAGMOVE     = $F012;  //03.02.10 nk add
  KEY_WOW64_64KEY = $0100;  //24.04.15 nk add ff
  KEY_WOW64_32KEY = $0200;

  PROC_INTEL    = 0;
  PROC_MIPS     = 1;
  PROC_ALPHA    = 2;
  PROC_PPC      = 3;
  PROC_SHX      = 4;
  PROC_ARM      = 5;
  PROC_IA64     = 6;    //Intel Itanium Processor Family (IPF)
  PROC_ALPHA64  = 7;
  PROC_MSIL     = 8;    //Microsoft Intermediate Language
  PROC_AMD64    = 9;    //x64 (AMD or Intel)
  PROC_WOW64    = 10;   //WOW64

  SOUND_STOP    = 0;    //Mode of PlaySoundFile
  SOUND_SYNC    = 1;
  SOUND_ASYNC   = 2;
  SOUND_LOOP    = 3;

  SM_TABLEPC    = 86;
  SM_MEDIA      = 87;
  SM_STARTER    = 88;
  SM_SERVERR2   = 89;

  BETA_BUILD    = 0;    //03.09.09 nk old=999
  WORKSTATION   = 1;    //16.09.09 nk add
  SERVICE_NOP   = 8;    //21.11.09 nk add
  FOOT_SIZE     = 9;    //17.12.09 nk add
  KEY_MASK      = 128;
  KEY_DELAY     = 250;   //ms
  WAIT_DELAY    = 50;    //ms
  BEEP_DUR      = 100;   //ms
  BEEP_FREQ     = 2500;  //Hz
  BEEP_MAX      = 16000; //Hz
  SHELL_ERROR   = 32;    //must be <= 32 (Error code - see GetShellError)
  KMULT         = 1024.0;

  PROCESS_TERM  = $0001;
  PROC_UNKNOWN  = $FFFF;
  CMD_MASK      = $FFF0;
//BIT_MASK      = $FFFFFFFF; //12.09.15 nk mov to UGlobal

  AMULT         = ' kMGTPE';
  FORMERR       = '?';      //03.11.08 nk add
  UBYTE         = 'B';
  UHERTZ        = 'Hz';
  MHERTZ        = 'MHz';
  MILLISEC      = 'ms';     //24.11.09 nk add ff
  MICROSEC      = 'us';
  VERS          = 'Vers. ';
  BUILD         = 'Build ';
  BETA_TEXT     = 'Beta';   //28.06.09 nk add ff
  GROUP_ADMIN   = 'Administrator';  //20.09.09 nk add ff
  GROUP_USER    = 'Standard User';
  PRINT_FONT    = 'Arial'; //17.12.09 nk add

  WIN16         = 'Windows';             //06.10.07 nk add (do NOT change!)
  WINNT         = 'Windows NT';
  WIN2K         = 'Windows 2000';
  WINXP         = 'Windows XP';
  WINVS         = 'Windows Vista';       //03.05.07 nk add
  WIN95         = 'Windows 95';
  WIN98         = 'Windows 98';
  WINME         = 'Windows ME';
  WIN32         = 'Windows 32';
  WIN3S         = 'Windows 3.x (Win32s)';
  WINSE         = 'Windows 98 SE';       //16.09.09 nk add ff
  WIN03         = 'Windows Server 2003';
  WIN08         = 'Windows Server 2008';
  W08R2         = 'Windows Server 2008 R2';
  WIN_7         = 'Windows 7';
  WIN_8         = 'Windows 8';           //04.02.12 nk add ff
  WIN_8S        = 'Windows Server 8';
  WIN12         = 'Windows Server 2012'; //13.09.13 nk add
  WIN_81        = 'Windows 8.1';         //20.12.14 nk add ff
  WIN12R2       = 'Windows Server 2012 R2';
  WIN_10        = 'Windows 10';          //28.11.15 nk add ff
  WINS16        = 'Windows Server 2016';
  WINSYS32      = ' (32-bit)';           //V5//18.03.16 nk add ff
  WINSYS64      = ' (64-bit)';

  //29.05.14 nk add ff - Application's Target system
  IMAGE_FILE_MACHINE_I386     = $014c; // Intel x86
  IMAGE_FILE_MACHINE_IA64     = $0200; // Intel Itanium Processor Family (IPF)
  IMAGE_FILE_MACHINE_AMD64    = $8664; // x64 (AMD64 or EM64T)
  IMAGE_FILE_MACHINE_R3000_BE = $160;  // MIPS big-endian
  IMAGE_FILE_MACHINE_R3000    = $162;  // MIPS little-endian, 0x160 big-endian
  IMAGE_FILE_MACHINE_R4000    = $166;  // MIPS little-endian
  IMAGE_FILE_MACHINE_R10000   = $168;  // MIPS little-endian
  IMAGE_FILE_MACHINE_ALPHA    = $184;  // Alpha_AXP
  IMAGE_FILE_MACHINE_POWERPC  = $1F0;  // IBM PowerPC Little-Endian

  SHELL_EXEC    = 'open';
  SHELL_RUNAS   = 'runas';               //27.11.09 nk add
  SHELL_WHERE   = 'where';               //15.12.09 nk add
  SHELL_NOTEPAD = 'notepad';             //16.01.10 nk add
  SHELL_TASKMAN = 'taskmgr';             //21.01.13 nk add
  SHELL_SYSCONF = 'msconfig';            //21.01.13 nk add
  SHELL_REGSVR  = 'regsvr32';            //12.04.11 nk add ff
  SHELL_DLLREG  = 'DllRegisterServer';
  SHELL_TRAY    = 'Shell_TrayWnd';       //06.10.07 nk add
  SHELL_CMD     = 'COMSPEC';             //12.09.08 nk add - dos console (cmd)
  SHELL_SWITCH  = 'SwitchToThisWindow';  //30.11.10 nk add
  TRAY_NOTIFY   = 'TrayNotifyWnd';       //16.12.07 nk add
  TRAY_PAGER    = 'SysPager';            //16.02.08 nk add ff
  TRAY_TOOLBAR  = 'ToolbarWindow32';
  SHUTDOWN_NAME = 'SeShutdownPrivilege'; //20.01.13 nk add ff
  LOCK_SYSTEM   = 'LockWorkStation';
  KEY_DEV       = 'device';
  FILE_PROPERTY = 'properties';          //07.12.09 nk old=FILE_INFO
  CLASS_BUTTON  = 'Button';              //31.12.07 nk add
  DESKTOP_APP   = 'Program Manager';
  DELPHI_APP    = 'TAppBuilder';
  THEME_ISACT   = 'IsThemeActive';       //14.04.08 nk old=ThemeAct
  PROC_IS64     = 'IsWow64Process';      //04.01.12 nk add
  ADO_CONNECT   = 'adodb.connection';    //30.11.10 nk add

  API_KERNEL    = 'kernel32.dll';        //04.01.12 nk add
  API_UXTHEME   = 'uxtheme.dll';         //25.11.10 nk old=THEME_LIB / 14.04.08 nk old=ThemeLib
  API_NETAPI    = 'netapi32.dll';        //25.11.10 nk mov from UInternet as INET_API_
  API_SHDOCVW   = 'shdocvw.dll';
  API_SHELL     = 'shell32.dll';
  API_USER      = 'user32.dll';          //20.01.13 nk add
  API_IPHLP     = 'iphlpapi.dll';
  API_MAPI      = 'MAPI32.dll';
  API_RUNDLL    = 'rundll32.exe';
  API_MSINFO    = 'msinfo32.exe';        //30.05.11 nk add
  API_NT        = 'ntdll.dll';           //25.11.10 nk mov from UDiag
  API_MSJET     = 'msjet40.dll';
  API_MSSQL     = 'sqlservr.exe';
  API_WMP       = 'wmp.dll';             //25.11.10 nk add
  API_DXDIAG    = 'dxdiag.exe';          //11.10.11 nk add

  REG_SMW_KEY   = '\Software\Microsoft\Windows NT\CurrentVersion';  //20.09.09 nk add ff
  REG_CDROM_KEY = '\Software\Microsoft\Windows\CurrentVersion\Explorer\CD Burning';
  REG_UAC_KEY   = '\Software\Microsoft\Windows\CurrentVersion\Policies\System'; //30.11.10 nk add
  REG_ERROR_KEY = '\Software\Microsoft\Windows\Windows Error Reporting\';       //13.05.11 nk add
  REG_IEM_KEY   = '\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION'; //28.11.15 nk add
  REG_DX_KEY    = '\Software\Microsoft\DirectX';
  REG_HWD_KEY   = '\Hardware\Description\System';
  REG_DEV_KEY   = '\Hardware\Devicemap';
  REG_CLASS_KEY = '\System\CurrentControlSet\Control\Class';             //30.11.10 nk add
  REG_KBD_KEY   = '\System\CurrentControlSet\Control\Keyboard Layouts\'; //29.11.10 nk add
  REG_DESK_KEY  = '\Control Panel\Desktop';        //25.11.10 nk add
  REG_INT_KEY   = '\Control Panel\International';  //01.10.10 nk add

  REG_CPU_NAME  = 'ProcessorNameString';
  REG_CPU_PID   = 'Identifier';
  REG_CPU_VID   = 'VendorIdentifier';
  REG_BIOS      = '\BIOS';                  //20.09.09 nk add ff
  REG_VERSION   = 'Version';
  REG_NAME      = 'Name';                   //30.11.10 nk add ff
  REG_CLASS     = 'Class';
  REG_SUBCLASS  = '0000';
  REG_MOUSE     = 'Mouse';
  REG_PROVIDER  = 'ProviderName';
  REG_DRDESC    = 'DriverDesc';
  REG_INSTVERS  = 'InstalledVersion';       //03.01.09 nk add
  REG_UAC       = 'EnableLUA';              //30.11.10 nk add
  REG_SHOWUI    = 'DontShowUI';             //13.05.11 nk add ff
  REG_DISABLE   = 'Disabled';
  REG_CDROM     = 'CD Recorder Drive';

  REG_BIOS_MANU = 'BIOSVendor';             //28.11.10 nk opt ff
  REG_BIOS_VERS = 'BIOSVersion';
  REG_BIOS_RDAT = 'BIOSReleaseDate';
  REG_BIOS_DATE = 'SystemBiosDate';
  REG_BORD_MANU = 'BaseBoardManufacturer';
  REG_BORD_NAME = 'BaseBoardProduct';
  REG_COMP_MANU = 'SystemManufacturer';
  REG_COMP_NAME = 'SystemProductName';
  REG_COMP_TYPE = 'Identifier';

  REG_VID_VERS  = 'VideoBiosVersion';
  REG_VID_DATE  = 'VideoBiosDate';
  REG_ORGANISAT = 'RegisteredOrganization'; //19.09.09 nk add
  REG_OWNER     = 'RegisteredOwner';        //23.11.10 nk add ff
  REG_PRODNAME  = 'ProductName';
  REG_PRODCODE  = 'ProductId';
  REG_EDITION   = 'EditionID';
  REG_CURVERS   = 'CurrentVersion';
  REG_CURBUILD  = 'CurrentBuild';
  REG_CSDBUILD  = 'CSDBuildNumber';
  REG_CSDVERS   = 'CSDVersion';
  REG_LAYOUT    = 'Layout Text';            //29.11.10 nk add
  REG_LOCALE    = 'LocaleName';             //01.10.10 nk add
  REG_SCOUNTRY  = 'sCountry';               //25.02.16 nk old=REG_COUNTRY -> conflict with URegistry
  REG_SS_ACTIVE = 'ScreenSaveActive';       //25.11.10 nk add ff
  REG_SS_DELAY  = 'ScreenSaveTimeOut';

  REG_DOS_DEVS  = '\DosDevices\';
  REG_CPU_SPEED = '~MHz';
  REG_KEY_ICON  = '\DefaultIcon';           //04.03.08 nk mov ff from RegisterFileType
  REG_KEY_OPEN  = '\Shell\Open\Command';
  REG_KEY_ATTR  = ' "%1"';
  REG_PAR_ICON  = ',0';
  REG_COM_KEY   = REG_DEV_KEY + '\Serialcomm';
  REG_LPT_KEY   = REG_DEV_KEY + '\Parallel Ports';
  REG_CPU_KEY   = REG_HWD_KEY + '\CentralProcessor\0';

  DOS_PIPE      = ' > '; //15.12.09 nk add
  VER_SLASH     = '\\';  //14.04.08 nk mov ff
  VER_VARFILE   = VER_SLASH + 'VarFileInfo\\Translation';
  VER_STRING    = VER_SLASH + 'StringFileInfo' + VER_SLASH;

  //20.09.09 nk add ff
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS     = $00000220;

  FORM_VERS     = '%d.%d';                 //14.04.08 nk mov ff
  FORM_SBUILD   = '%d.%d.%d';
  FORM_SSHORT   = '%s (%d.%d)';
  FORM_SLONG    = '%s (%d.%d.%d)';
  FORM_SPACK    = '%s (%s)';
  FORM_VFULL    = '%d.%d.%d %s Build %d';  //23.11.10 nk add
  FORM_PSHORT   = '%d.%d.%d';
  FORM_PLONG    = '%d.%d.%d.%s';           //28.06.09 nk old=%d';
  FORM_PNAME    = '%s%d.%d';
  FORM_PPACK    = '%s%d';
  FORM_CHECK    = '%s.%s';                 //16.04.08 nk add
  FORM_EXECUTE  = '"%s" "%s"';             //30.11.10 nk add
  FORM_SCREEN   = '%d x %d x %d (%d %s)';  //06.10.07 nk add
  FORM_SCREENS  = '%d x %d x %d';          //24.08.13 nk add
  FORM_HEADER   = ' %s Vers. %s - %s';     //18.04.08 nk add ff
  FORM_AGENT    = ' %s Vers. %s';          //12.12.08 nk add
  FORM_TIMEZONE = '%s (UTC%s%d)';          //like 'Central Time (UTC-8)'
  FORM_FOOTER   = 'Page %d of %d';         //30.11.10 nk add ff
  FORM_MEMORY   = 'Total: %s / Free: %s';
  FORM_UPTIME   = '%d Days, %d Hours, %d Minutes, %d Seconds';
  FORM_FORMSET  = 'Decimal Separator is "%s", Thousand Separator is "%s"';
  FORM_RUNNING  = 'An instance of %s is already running!';
  FORM_ABORTJOB = 'Print job is being aborted!';

  //14.04.08 nk mov / old=InfoStr - must corresponde with TAppInfo
  InfoStrings: array[1..10] of string = ('CompanyName', 'FileDescription',
    'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks',
    'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');

  //21.11.09 nk opt / add SERVICE_NOP / old=SERVICE_PAUSED
  InfoService: array[NERR_SUCCESS..SERVICE_NOP] of string = (
    'Service is not installed',
    'Service is stopped',
    'Service is starting...',
    'Service is stopping...',
    'Service is running',
    'Service is continuing...',
    'Service is pausing...',
    'Service is paused',
    'Unknown service status!');

type  //03.09.09 nk mov up
  //21.09.09 nk add msPTotal..msXFree / opt new ordering
  TMemSize = (msTotal, msFree, msUsed, msPTotal, msPFree, msVTotal, msVFree,
              msXFree, msPLoad, msBlock, msHeap, msProc, msSpace, msUncom,
              msCom, msAlloc, msTfree, msSfree, msBfree, msUnuse, msOver,
              msLoad, msError);

  TSizeFormat = (sfByte, sfKilo, sfMega, sfGiga, sfTera, sfPeta, sfExa, sfAuto);

  TVersType = (vtVerMaj, vtVerMin, vtRelMaj, vtRelMin, vtBuild, vtVers,
               vtPack, vtName, vtShort, vtLong, vtDesc, vtFull, vtSP); //13.09.13 nk add vtSP / 23.11.10 nk add vtFull / 16.09.09 nk add vtDesc

  TFormComm = (fcClose, fcMinimize, fcMaximize, fcRestore);

  TDevType = (dtScreen, dtPrinter);

  TIEMode = (iemIE7, iemIE8, iemIE9, iemIE10, iemIE11); //28.11.15 nk add - WebBrowser compatibility versions

  TAppInfo = (piCompanyName, piFileDescription, piFileVersion, piInternalName,
              piLegalCopyright, piLegalTradeMarks, piOriginalFileName,
              piProductName, piProductVersion, piComments, piProjectName,
              piFileName, piProgName, piProgPath);

  TWmMoving = record
    Msg   : Cardinal;
    fwSide: Cardinal;
    lpRect: PRect;
    Result: Integer;
  end;

  type TOsVersionInfoEx = packed record  //16.09.09 nk add
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion     : DWORD;
    dwMinorVersion     : DWORD;
    dwBuildNumber      : DWORD;
    dwPlatformId       : DWORD;
    szCSDVersion       : array [0..127] of WideChar;
    wServicePackMajor  : Word;
    wServicePackMinor  : Word;
    wSuiteMask         : Word;
    wProductType       : Byte;
    wReserved          : Byte;
  end;

  type TMemoryStatusEx = packed record  //21.09.09 nk add
    dwLength: DWORD; 
    dwMemoryLoad: DWORD; 
    ullTotalPhys: Int64; 
    ullAvailPhys: Int64;
    ullTotalPageFile: Int64; 
    ullAvailPageFile: Int64; 
    ullTotalVirtual: Int64; 
    ullAvailVirtual: Int64; 
    ullAvailExtendedVirtual: Int64; 
  end;

var
  SIDEBORDER:     Integer = 6;    //window metrics will be
  TOPBORDER:      Integer = 25;   //corrected by GetWindowMetric
  CAPTIONHEIGHT:  Integer = 28;   //04.02.16 nk add
  SCROLLBARWIDTH: Integer = 22;   //on initialization
  BORDERCORR:     Integer = 0;    //25.10.07 nk add ff
  TABLECORR:      Integer = 0;    //18.07.09 nk add
  SCREENWIDTH:    Integer = 800;  //screen width
  SCREENHEIGHT:   Integer = 600;  //and height [pixel]
  SCREENCENTER:   Integer = 400;  //26.03.08 nk add ff
  SCREENMIDDLE:   Integer = 300;
  FORMLEFT:       Integer = 100;
  FORMTOP:        Integer = 100;
  VIEWWIDTH:      Integer = 720;  //V5//21.01.16 nk add ff
  VIEWHEIGHT:     Integer = 480;
  VIEWTOP:        Integer = 20;
  FORMWIDTH:      Integer = 800;  //V5//09.01.16 nk opt ff
  FORMHEIGHT:     Integer = 600;

  PrinterLeftMargin: Integer;     //printer margins [mm]
  PrinterTopMargin: Integer;
  PrinterHeaderSize: Integer;
  PrinterFooterSize: Integer;
  PrinterRowHeight: Integer;
  PrinterFontHeight: Integer;

  PaperA4Width: Integer;   //26.11.15 nk add - get A4 portrait size [pixels]
  PaperA4Height: Integer;

  ScreenDelay: Integer;  //25.11.10 nk add [min] (0=Off)
  ExecCode: Cardinal;    //20.02.08 nk add
  TimerRes: Int64;
  MutexHandle: THandle;

  //set this infos on program initialization
  SysError: string;      //04.03.08 nk add
  SysLogFile: string;    //27.02.17 nk add
  StringPart: string;
  ComputerUser: string;
  TimeFormatShort: string;    //03.11.08 nk add ff
  TimeFormatLong: string;
  DateFormatShort: string;
  DateFormatLong: string;     //20.11.15 nk add

  //fill in this infos in Delphi/Project/Options/Version
  CompanyName: string;
  FileDescription: string;
  FileVersion: string;
  InternalName: string;
  LegalCopyright: string;
  LegalTradeMarks: string;
  OriginalFileName: string;  //use original file name to check if already running
  ProductName: string;
  ProductVersion: string;
  Comments: string;          //use comments to check minimum system version

  //this infos will be set on initialization
  FontScale: Single;     //02.04.08 nk add (1.0 = 96dpi / 1.25 = 120dpi)
  ProjectName: string;   //Personal Integrated Dive Instrument
  FileName: string;      //Pidi.exe
  ProgName: string;      //Pidi
  ProgPath: string;      //C:\Program Files\Pidi\
  ProgBuild: string;     //24.03.08 nk add like '715'
  ProductHeader: string; //Mail Reader Vers. 1.8 - Copyright by seanus systems
  ProductAgent: string;  //Mail Sender Vers. 1.6 by seanus systems
  ProductTitle: string;  //01.04.16 nk add

  function IsEven(Val: Byte): Boolean; //V5//06.08.15 nk add
  function Iff(const Condition: Boolean; const TruePart, FalsePart: Variant): Variant; //25.11.10 nk add
  function Digits(const Val: Cardinal): Byte;    //30.07.09 nk add
  function NotEmpty(Val: string): Boolean;       //30.10.09 nk add
  function GetBit(const Opr: Cardinal; const Bit: Byte): Boolean;
  function SetBit(const Opr: Cardinal; const Bit: Byte; Val: Boolean): Cardinal;
  function ToggleBit(const Opr: Cardinal; const Bit: Byte): Cardinal;
  function Toggle(Bit: Integer): Integer;           //09.12.07 nk add
  function StrIsNumeric(Input: string): Boolean;    //22.11.13 nk add
  function StrContain(Str1, Str2: string): Boolean; //05.10.13 nl add
  function StrEqual(Str1, Str2: string; Len: Integer = 0): Boolean; //12.10.12 nk old=Word / 27.12.10 nk add
  function StrSplit(Input: string; Del: Char; Pos: Integer): string;
  function StrCut(Input: string; var Output: string; Del: Char = cCOMMA): Boolean; //15.03.10 nk add Del
  function StrVal(Instr, Substr: string; Del: Char = cCOMMA): Integer;             //04.01.12 nk add
  function StrStrip(Input: string; StripChars: TCharSet): string;                  //28.07.10 nk add
  function StrTrim(Input: string): string;                                         //22.02.13 nk add
  function StrCount(Input: string; Search: Char): Integer;
  function StrNum(Input: string): string;            //16.02.10 nk add
  function CutNum(Input: string): string;            //V5//07.10.15 nk add
  function StrVers(Version: string): Single;
  function StrToIntRange(Input: string; Lmin, Lmax: Integer): Integer; //V5//18.11.16 nk add
  function StrToClock(Seconds: Integer): TDateTime;  //20.12.14 nk add
  function StrToVers(Version: string): Single;       //18.11.08 nk opt
  function StrToHex(Text: AnsiString): AnsiString;   //17.11.11 nk old=string xe
  function HexToStr(Hex: AnsiString): AnsiString;    //17.11.11 nk old=string xe
  function StringIndex(Input: string; List: array of string): Integer; //06.10.07 nk add
//function ProperAnsi(Input: string): string;        //obsolete / 05.06.12 nk add
  function ProperString(Input: string): string;      //11.07.12 nk add
  function ProperCase(Input: string; FirstOnly: Boolean = False): string; //25.08.08 nk add FirstOnly
  function CamelCase(Input: string): string;
  function TrimEx(Input: string): string;     //06.11.11 nk add
  function TrimAll(Input: string; ValidChars: TCharSet = EMPTY_SET): string; //18.07.07 nk add
  function CreateHint(HeadText: string; TailText: string = cEMPTY): string;
  function WinToDos(Input: string): string;   //18.07.07 nk add
  function DosToWin(Input: string): string;   //18.07.07 nk add
  function CharToPhon(Input: string): string; //18.07.07 nk add
  function Limit(Val, Min, Max: Integer): Integer; //11.02.08 nk add
  function RoundUp(Val: Double): Integer;     //30.05.09 nk add
  function RoundIt(Val: Double; Lim: Double = 0.5): Double; //18.11.10 nk add
  function IntToByte(Int: Integer): Byte;
  function FloatToByte(Float: Single): Byte;  //24.03.09 nk add      //19.09.09 nk add Gap
  function FormatByte(Bytes: Int64; Format: TSizeFormat; Digit: Byte; Gap: string = cSPACE): string;
  function DeFormatByte(Bytes: string): Int64;
  function IsAlive(ProgName: string; UseClass: Boolean = False): Boolean; //10.04.08 nk add
  function IsAdmin: Boolean;        //20.09.09 nk upd
  function IsUACEnabled: Boolean;   //30.11.10 nk add
  function Is32AppOn64Bit: Boolean; //04.01.12 nk add
  function Is64BitSystem: Boolean;  //10.03.16 nk add
  function GetTargetSystem(var AppName: string): Boolean; //29.05.14 nk add
  function GetDelphi: Boolean;
  function GetBurner: Boolean;      //19.09.09 nk add
  function GetFont(out FontSize: Integer): Boolean;
  function GetFontSize: string;     //19.09.09 nk add
  function GetFontScale: Single;    //02.04.08 nk add
  function GetScreenFont(FontName: string): Boolean; //22.09.09 nk add ff
  function GetPrinterFont(FontName: string): Boolean;
  function GetFontHeight(FontType: TFont): Integer; //10.06.11 nk opt / 24.07.07 nk add
  function GetFontWidth(FontType: TFont): Integer;  //10.06.11 nk add
  function GetMin(x, y: Extended): Extended;
  function GetMax(x, y: Extended): Extended;
  function GetMouse: string; //30.11.10 nk add
  function GetMouseButtons: Integer;
  function GetMouseWheel: Integer;
  function GetPorts(Ports, Devices: TStrings): Integer;
  function GetProcessorSpeed: Int64;
  function GetProcessorName: string;
  function GetProcessorClock: string;
  function GetProcessorVers(VersType: TVersType): string;
  function GetMemory(SizeType: TMemSize): Int64;
  function GetMemoryEx(SizeType: TMemSize): Int64; //05.09.13 nk opt (was missed!?!)
  function GetPhysicalMemory: string;  //19.09.09 nk add
  function GetVirtualMemory: string;   //21.09.09 nk add
  function GetAllocMemSize: Integer;   //25.07.17 nk add
  function GetProcessList(ProcList: TStrings; Filter: string = cEMPTY): Integer; //14.04.08 nk add
  function GetProcessMemory(InPercent: Boolean = False; ProcHandle: Cardinal = 0): Int64; //27.11.15 nk add InPercent
  function GetProcessID(ProgName: string): Cardinal;  //04.11.07 nk add
  function GetProcessPrio(var ProgName: string): Integer; //27.05.10 nk add
  function GetProcessHandle(ProgName: string; UseClass: Boolean = False): HWND; //27.05.10 nk add
  function GetTimer: Int64;
  function GetIdleTime: Cardinal; //02.06.11 nk add
  function GetUTCTime: TDateTime; //14.06.11 nk add
  function GetUpTime: string;     //19.09.09 nk add
  function GetBootTime: string;   //22.09.09 nk add
  function GetServiceStatus(Machine, Service: PChar): DWORD;  //03.09.09 nk add
  function GetPowerStatus(out Remain: Integer): Boolean;
  function GetDirectXVers: string;  //20.09.09 nk add
  function GetADOVers: string;      //20.09.09 nk add
  function GetProgVers(VersType: TVersType; ProgName: string = cEMPTY): string; //22.01.08 nk add ProgName
  function GetSystemVers(VersType: TVersType): string;     //16.09.09 nk add improved version
  function GetAppInfo(AppInfo: TAppInfo): string;
  function GetEnvVar(EnvName: string): string;
  function GetWindowMetric(Metric: Byte = 0): Integer; //25.10.07 nk add
  function GetTopWindow(Win: HWND): Boolean;  //27.03.08 nk add
  function GetFocusWindow: Cardinal;  //10.04.08 nk add
  function GetXpStyle: Boolean;
  function GetSoundCard: Boolean;  //13.08.09 nk add
  function GetBiosVers(Video: Boolean = False): string; //20.09.09 nk add Video
  function GetBiosDate(Video: Boolean = False): string; //20.09.09 nk add Video
  function GetSystemLang: string;
  function GetKeyboardLang(Code: string = cEMPTY): string; //29.11.10 nk add Code
  function GetLocalSettings(Default: Boolean): string;     //19.09.09 nk add
  function GetCompName: string;
  function GetCompUser: string;
  function GetOrganisation: string;  //19.09.09 nk add
  function GetSerialNo(UseWinDrive: Boolean = False): string; //09.11.09 nk add UseWinDrive
  function GetDefPrinter: string; //27.05.10 nk add
  function GetDefaultPrinter: string;
  function GetProductData(DataTyp: Byte): string;  //20.09.09 nk add
  function GetWindowsData(DataTyp: Byte): string;  //23.11.10 nk add
  function GetClock(Seconds: Integer; DoLimit: Boolean = False): string; //11.10.09 nk add DoLimit
  function ClockToMins(Clock: string): Word;       //V5//14.08.15 nk add
  function MinsToClock(Minutes: Word): string;     //V5//14.08.15 nk add
  function GetTimeZone: string;                    //19.09.09 nk add
  function GetValidTime(TimeValue, TimeFormat: string; var Seconds: Integer; DoLimit: Boolean = False): string; //11.10.09 nk add DoLimit
  function GetPrinterFormats(FormatList: TStrings): Integer;
  function GetScreen(out Width, Height, Freq, Bits: Cardinal): string;
  function GetScreenSaver: Integer;  //25.11.10 nk add
  function GetResolution(Device: TDevType): Integer;
  function GetShellError(ErrCode: Integer): string;  //17.04.07 nk add
  function GetLastErrorText: string; //08.12.09 nk add
  function GetUserAccount: string;   //20.09.09 nk add
  function GetUserPrivileges(UserList: TStringList): Integer;  //18.09.09 nk add
  function GetHtmlChar(Code: string): Char;  //21.10.10 nk mov from UInternet
  function GetWebbrowserMode(AppName: string = cEMPTY): Integer; //28.11.15 nk add
  function PreventFormMove(Msg: TwmSysCommand): Boolean;
  function PreventFormSize(Msg: TwmSysCommand): Boolean;
  function PreventFormChange(Msg: TwmSysCommand): Boolean;
  function CheckMinSystem(MinVers: string): Boolean;    //16.04.08 nk add
  function LockSystem: Boolean;                         //20.01.13 nk add
  function KillTask(TaskName: string): Integer;
  function ExitWindows(RebootParam: Longword): Boolean; //20.01.13 nk add
  function MinimizeToTray(Handle: HWND): Boolean;       //20.01.13 nk add
  function ExecuteAndWait(FileName: string; Params: PChar; PathName: string = cEMPTY): Boolean; //06.09.11 nk old=procedure
  function ExecuteEmbedded(FileName, ProgCaption: string; Params: PChar; ProgParent: THandle; PathName: string = cEMPTY): THandle; //17.03.15 nk add
  function DoStartService(Machine, Service: string): Boolean;  //03.09.09 nk add
  function DoStopService(Machine, Service: string): Boolean;   //04.09.09 nk add
  function MimeToHtml(Code: string): string; //21.10.10 nk mov from UInternet
  function SetScreen(Width, Height, Freq: Cardinal): Boolean;
  function SetFormIcon(FormHandle: HWND; IconName: string): Integer; //V5//28.12.15 nk add
  function SetSystemTime(SysTime: TDateTime): Boolean;   //V5//05.01.17 nk add
  function MessageSend(ProgName, Text: string; UseClass: Boolean = False): Boolean; //V5//11.07.16 nk add
  procedure SetBackGround(BitMap: string);
  procedure SetTopWindow(Win: HWND; Restore: Bool); stdcall; //10.04.08 nk add
  procedure SetDefaultPrinter(PrinterName: string); //06.07.08 nk add
  procedure SetLocalSettings(Dsep, Tsep: Char);  //24.09.09 nk add
  procedure SetAdminShield(Control: TWinControl; Requiered: Boolean); //27.11.09 nk add
  procedure SetScreenSaver(Delay: Integer); //25.11.10 nk add
  procedure SetErrDialog(Mode: Boolean);    //13.05.11 nk add
  procedure SetKeyboardState(Key: Byte; State: Boolean);
  procedure SetWebbrowserMode(Mode: TIEMode; AppName: string = cEMPTY); //28.11.15 nk add
  procedure Delay(MilliSeconds: Longword);
  procedure DelayMicro(MicroSeconds: Int64);
  procedure Beep(Freq: Integer = BEEP_FREQ; Dur: Integer = BEEP_DUR);
  procedure BeepTones;                                 //21.01.13 nk add
  procedure ShowScreen(Mode: Boolean);
  procedure ShowTaskBar(Mode: Boolean);
  procedure ShowTitleBar(Form: TForm; Mode: Boolean);  //21.01.13 nk add
  procedure ShowStartButton(Mode: Boolean);
  procedure ShowDesktopIcons(Mode: Boolean);
  procedure SwapMouseButtons(Mode: Boolean);
  procedure ClipMouseCursor(Area: TRect);
  procedure EnableCloseButton(Window: TForm);   //19.04.08 nk add
  procedure DisableCloseButton(Window: TForm);  //19.04.08 nk add
  procedure HideCloseButton(Window: TForm);     //19.04.08 nk old=Disable...
  procedure HideMinButton(Window: TForm);       //19.04.08 nk old=Disable...
  procedure HideMaxButton(Window: TForm);       //19.04.08 nk old=Disable...
  procedure ShowFormContents(Mode: Boolean);
  procedure LimitFormMove(Area: TRect; Msg: TwmMoving);
  procedure RestartApplication(Param: string = cEMPTY);  //V5//08.02.17 nk add Param
  procedure PerformApplication(ProgName: string; Comm: TFormComm; UseClass: Boolean = False); //UseClass 22.01.13 nk add hhh / 20.02.08 nk add ff PathName
  procedure ExecuteDocument(FileName: string; WaitForClose: Boolean = False);  //13.01.09 nk add
  procedure ExecuteProgram(FileName: string; Params: PChar; PathName: string = cEMPTY);
  procedure ExecuteAsAdmin(FileName, Params: string; PathName: string = cEMPTY); //27.11.09 nk add
  procedure ExecuteDosComm(DosComm: string; Hidden: Boolean);  //12.09.08 nk add
  procedure PressKey(const CtrlKey: array of Byte);
  procedure SetWaveVolume(Left, Right: Word);
  procedure PlaySoundFile(SoundFile: string; Mode: Byte = SOUND_ASYNC);
  procedure PlaySoundSystem(SystemSound: Integer);  //13.08.09 nk add
  procedure MakeSound(Freq, Dur, Vol: Integer);
  procedure PrintText(Header: string; Text: TRichEdit);
  procedure PrintGrid(Header: string; Grid: TStringGrid);
  procedure PrintImage(LeftFooter, RightFooter: string; Image: TImage; Zoom: Integer); //17.12.09 nk opt ff
  procedure CloneObject(Source, Target: TObject);
  procedure RegisterLibrary(LibName: string); //12.04.11 nk add
  procedure RegisterFileType(Prefix, AppFile, AppName: string);
  procedure WaitOnKey(Key: Integer = NONE);  //03.03.15 nk opt
  procedure ClearKeyboardBuffer;
  procedure ClearMouseBuffer;
  procedure RemoveZombies;     //16.12.07 nk add
  procedure TrimAppMemorySize; //02.06.11 nk add

implementation

function GlobalMemoryStatusEx(var lpBuffer: TMemoryStatusEx): BOOL; stdcall;
  external kernel32;  //21.09.09 nk add

procedure SetTopWindow(Win: HWND; Restore: Bool); stdcall;
  external user32 Name SHELL_SWITCH;
  //use like 'SetTopWindow(FindWindow('notepad', nil), True);
  //NOTE: Better use SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NoMove or SWP_NoSize);

function Iff(const Condition: Boolean; const TruePart, FalsePart: Variant): Variant;
begin //25.11.10 nk add - Replacement for the C ternary conditional operator ? (JEDI JclSysUtils)
  if Condition then     //If Condition=True then Result=TruePart else Result=FalsePart
    Result := TruePart
  else
    Result := FalsePart;
end;

function IsEven(Val: Byte): Boolean;
begin //V5//06.08.15 nk add - return True if Val is even and False if odd
  Result := Val mod 2 = 0;
end;

function GetBit(const Opr: Cardinal; const Bit: Byte): Boolean;
begin //Bit counts from 0 (LSB) to 31 (MSB) / return True if Bit is set in Opr
  Result := (Opr and (1 shl Bit)) <> 0;
end;

function SetBit(const Opr: Cardinal; const Bit: Byte; Val: Boolean): Cardinal;
begin //Bit counts from 0 (LSB) to 31 (MSB)
  if Val then
    Result := Opr or (1 shl Bit)
  else
    Result := Opr and ((1 shl Bit) xor BIT_MASK);
end;

function ToggleBit(const Opr: Cardinal; const Bit: Byte): Cardinal;
begin //Bit counts from 0 (LSB) to 31 (MSB)
  Result := Opr xor (1 shl Bit);
end;

function Toggle(Bit: Integer): Integer;
begin //toggle bit from 0 -> 1 -> 0..
  Result := abs(Bit - 1);
end;

function Digits(const Val: Cardinal): Byte;
begin //12.12.09 nk opt - return number of digits of Val
  if Val <= 0 then      //e.g. Val=1249 => Digits=4
    Result := 1
  else
    Result := Trunc(Log10(Val)) + 1;
end;

function NotEmpty(Val: string): Boolean;
begin //06.11.11 nk opt - Return True if Val is empty or has only space(s)
  Result := (TrimEx(Val) <> cEMPTY); //06.11.11 nk old=Trim
end;

function WinToDos(Input: string): string;
begin //xe//convert Win (ANSI) character codes to DOS
  Result := Input;
  if Input = cEMPTY then Exit;  //12.09.08 nk opt
  UniqueString(Result);
  CharToOem(PChar(Result), PAnsiChar(AnsiString(Result)));  //xe//
end;

function DosToWin(Input: string): string;
begin //xe//convert DOS character codes to Win (ANSI)
  Result := Input;
  if Input = cEMPTY then Exit;  //12.09.08 nk opt
  UniqueString(Result);
  OemToChar(PAnsiChar(AnsiString(Result)), PChar(Result));  //xe//
end;

function CharToPhon(Input: string): string;
var //xe//convert special character codes to homonymic phonemes
  i: Integer;
  ch: string;
begin
  Result := cEMPTY;

  for i := 1 to Length(Input) do begin
    ch := cEMPTY;  //ignore control codes
    if (Ord(Input[i]) >= ASCII_SPACE) and (Ord(Input[i]) < ASCII_LAST) then ch := Input[i];
    if CharInSet(Input[i], ['à','á','â','ã','å']) then ch := 'a';
    if CharInSet(Input[i], ['À','Á','Â','Ã','Å']) then ch := 'A';
    if CharInSet(Input[i], ['ò','ó','ô','õ','ø']) then ch := 'o';
    if CharInSet(Input[i], ['Ò','Ó','Ô','Õ','Ø']) then ch := 'O';
    if CharInSet(Input[i], ['ù','ú','û','µ'])     then ch := 'u';
    if CharInSet(Input[i], ['Ù','Ú','Û'])         then ch := 'U';
    if CharInSet(Input[i], ['è','é','ê','ë'])     then ch := 'e';
    if CharInSet(Input[i], ['È','É','Ê','Ë','€']) then ch := 'E';
    if CharInSet(Input[i], ['ì','í','î','ï'])     then ch := 'i';
    if CharInSet(Input[i], ['Ì','Í','Î','Ï'])     then ch := 'I';
    if CharInSet(Input[i], ['ý','ÿ'])             then ch := 'y';
    if CharInSet(Input[i], ['Ý','Ÿ','¥'])         then ch := 'Y';
    if CharInSet(Input[i], ['ä','æ'])             then ch := 'ae';
    if CharInSet(Input[i], ['Ä','Æ'])             then ch := 'Ae';
    if CharInSet(Input[i], ['ö','œ'])             then ch := 'oe';
    if CharInSet(Input[i], ['Ö','Œ'])             then ch := 'Oe';
    if CharInSet(Input[i], ['ç','¢'])             then ch := 'c';
    if CharInSet(Input[i], ['Ç','©'])             then ch := 'C';
    if (Input[i] = 'ü')                           then ch := 'ue';
    if (Input[i] = 'Ü')                           then ch := 'Ue';
    if (Input[i] = 'Ð')                           then ch := 'D';
    if (Input[i] = 'ñ')                           then ch := 'n';
    if (Input[i] = 'Ñ')                           then ch := 'N';
    if (Input[i] = '£')                           then ch := 'L';
    if (Input[i] = 'š')                           then ch := 's';
    if (Input[i] = 'Š')                           then ch := 'S';
    if (Input[i] = '®')                           then ch := 'R';
    if (Input[i] = 'ž')                           then ch := 'z';
    if (Input[i] = 'Ž')                           then ch := 'Z';
    if (Input[i] = 'ß')                           then ch := 'ss';
    Result := Result + ch;
  end;
end;

function IntToByte(Int: Integer): Byte;
begin //convert an Integer to a Byte (limited to 0..255)
  if Int > MAXBYTE then
    Result := MAXBYTE
  else if Int < 0 then
    Result := CLEAR
  else
    Result := Int;
end;

function FloatToByte(Float: Single): Byte;
begin  //24.03.09 nk add - convert a Float to a Byte (rounded and limited to 0..255)
  Result := IntToByte(Round(Float));
end;

function Limit(Val, Min, Max: Integer): Integer;
begin //limit Val between (inclusive) Min and Max
  if Val < Min then Val := Min;
  if Val > Max then Val := Max;
  Result := Val;
end;

function RoundUp(Val: Double): Integer;
var //round real value Val up to the next integer value
  fix: Integer; //e.g. 12.35 => 13, but 12.0 => 12
begin
  fix := Trunc(Val);       //integer part

  if Frac(Val) > NADA then //fractional part
    Result := fix + 1
  else
    Result := fix;
end;

function RoundIt(Val: Double; Lim: Double = 0.5): Double;
var //round real value Val up to next Lim value
  fix: Integer; //e.g. 12.3 => 12.5, 12.6 => 13.0 (for Lim = 0.5)
  frc: Double;  //but  12.0 => 12.0, 12.5 => 12.5
begin
  fix := Trunc(Val);       //integer part
  frc := Frac(Val);

  if frc > Lim then begin  //fractional part
    Result := fix + 1.0;
  end else begin
    if frc > NADA then
      Result := fix + Lim
    else
      Result := Val;
  end;
end;

function StrEqual(Str1, Str2: string; Len: Integer = 0): Boolean;
begin //27.12.10 nk add - Return True if both strings are identical (not case-sensitive)
  Str1 := LowerCase(Str1);
  Str2 := LowerCase(Str2);

  if Len < 0 then begin    //12.10.12 nk add ff
    Str1 := TrimEx(Str1);  //compare strings w/o leading
    Str2 := TrimEx(Str2);  //and trailing white spaces
  end;

  if Len <= 0 then //12.10.12 nk old=Len = 0
    Result := (Str1 = Str2)
  else
    Result := (LeftStr(Str1, Len) = LeftStr(Str2, Len));
end;

function StrContain(Str1, Str2: string): Boolean;
var //05.10.13 nk add - Return True if Str1 is part of Str2 (not case-sensitive)
  part: string;       //Str1 may be comma delimited (e.g. 'world,floor,scene')
begin
  Result := False;
  Str1 := LowerCase(Str1);
  Str2 := LowerCase(Str2);

  while StrCut(Str1, part) do //do NOT exit while loop
    if Pos(part, Str2) > 0 then Result := True;
end;

function StrSplit(Input: string; Del: Char; Pos: Integer): string;
//22.01.10 nk opt - returns part of a string based on defined delimiter, such as ';'
// 1st part has Pos=0
// StrSplit('this is a test ', ' ', 1) = 'is' or
// StrSplit('data;another;yet;again;more;', ';', 2) = 'yet'
var
  b, t: Integer;
  buff: array of Integer;
begin
  Result := cEMPTY;
  if Input = cEMPTY then Exit;

  t := CLEAR;
  Input := Input + Del;
  SetLength(buff, Length(Input));

  for b := 0 to Pred(High(buff)) do begin
    buff[b + 1] := PosEx(Del, Input, Succ(buff[b]));
    if (buff[b + 1] < buff[b]) or (Pos < t) then
      Break
    else 
      Inc(t);
  end;

  try //do not trim - white spaces are valid
    Result := Copy(Input, Succ(buff[Pos]), Pred(buff[Pos + 1] - buff[Pos]));
  except
    Result := cEMPTY; //22.01.10 nk add try..except (buff is empty if Input=Del)
  end;
end;

function StrCut(Input: string; var Output: string; Del: Char = cCOMMA): Boolean;
var //09.10.12 nk add Del - returns comma delimited (trimmed) parts of an input string
  i, l: Integer; //Unicode compliant - VALID_DELS = [',', ';', '|', '#'];
begin
  if Input = cEMPTY then begin //20.05.11 nk add ff
    Output     := cEMPTY;
    StringPart := cEMPTY;
    Result     := False;
    Exit;
  end;

  if StringPart = Del then begin
    StringPart := cEMPTY;
    Result     := False;
    Exit;
  end else begin //09.10.12 nk fix/add ff
    if Length(StringPart) = 1 then begin
      if CharInSet(StringPart[1], VALID_DELS) then
        StringPart := cEMPTY;
    end;
  end;

  if StringPart = cEMPTY then begin
    StringPart := Input;
    Output     := cEMPTY;
  end;

  i := Pos(Del, StringPart);
  l := Length(StringPart);
  Result := (l > 0);

  if i > 0 then begin
    Output := TrimEx(LeftStr(StringPart, i - 1)); //06.11.11 nk old=Trim
    if i = l then  //05.07.08 nk opt (if last char is a comma)
      StringPart := Del
    else
      StringPart := RightStr(StringPart, l - i);  //06.11.11 nk old=Trim
  end else begin
    Output := TrimEx(StringPart);
    StringPart := Del;
  end;
end;

function StrVal(Instr, Substr: string; Del: Char = cCOMMA): Integer;
var //04.01.12 nk add - returns position value (0..n) of Substr in Instr (-1=not found)
  subpos: Integer;
  outstr: string;
begin
  Result := NONE;
  subpos := NONE;

  while StrCut(Instr, outstr, Del) do begin //do NOT exit while loop
    Inc(subpos);
    if outstr = Substr then
      Result := subpos;
  end;
end;

function StrStrip(Input: string; StripChars: TCharSet): string; //28.07.10 nk add
var //xe//remove unwanted chars defined in StripChars from the Input string
  i: Integer;  //StripChars = ANSI character set
begin
  Result := cEMPTY;

  for i := 1 to Length(Input) do begin
    if not CharInSet(Input[i], StripChars) then //xe//
      Result := Result + Input[i];
  end;
end;

function StrTrim(Input: string): string;
var //22.02.13 nk add - replace all control and white characters by one space
  newword: Boolean;
  i: Integer;
begin
  Result  := cEMPTY;
  newword := False;

  for i := 1 to Length(Input) do begin
    if not CharInSet(Input[i], WHITE_CHARS) then begin
      Result  := Result + Input[i];
      newword := True;
    end else begin
      if newword then
        Result := Result + cSPACE;
      newword  := False;
    end;
  end;
end;

function StrCount(Input: string; Search: Char): Integer;
var //return number of matching characters in given string
  i: Integer;
begin
  Result := CLEAR;
  for i := 1 to Length(Input) do
    if Input[i] = Search then Inc(Result);
end;

function StrNum(Input: string): string;
var //return number in given string e.g. 'Agent_123_5' = '123'
  i: Integer;
begin
  Result := cEMPTY;

  for i := 1 to Length(Input) do begin
    if CharInSet(Input[i], ALL_NUMBS) then //xe//
      Result := Result + Input[i]
    else
      if Result <> cEMPTY then Exit; //ignore leading letters
  end;                               //cut trailing characters
end;

function CutNum(Input: string): string;
var //remove leading non-alphabethic chars from string e.g. '6 -> Bus 31' = 'Bus 31'
  isalpha: Boolean;
  i: Integer;
begin
  Result  := cEMPTY;
  isalpha := False;

  for i := 1 to Length(Input) do begin
    if CharInSet(Input[i], ALL_CHARS) then isalpha := True;
    if isalpha then
      Result := Result + Input[i];
  end;
end;

function StrIsNumeric(Input: string): Boolean;
var //22.11.13 nk add
  i: Integer;
begin
  Result := True;

  for i := 1 to Length(Input) do begin
    if not CharInSet(Input[i], ALL_NUMBS) then begin
      Result := False;
      Exit;
    end;
  end;
end;

function StrVers(Version: string): Single;
var //xe//extract the version in the format V.R from given string
  i: Integer;  //old version handles only one decimal point
  temp: string;
begin
  temp := cEMPTY;

  for i := 1 to Length(Version) do begin
    if CharInSet(Version[i], ALL_FLOATS) then
      temp := temp + Version[i]; //xe//
  end;

  if not TryStrToFloat(temp, Result) then Result := NADA;
end;

function StrToVers(Version: string): Single;
var //extract the version in the format V.R from given string
  v, r: string; //returns 0.0 if failed or invalid version
begin
  try                                 //e.g. '3.2.7'
    v := StrSplit(Version, cDOT, 0);  //ver = '3'
    r := StrSplit(Version, cDOT, 1);  //rel = '2'
    v := v + cDOT + r;                //res = 3.2
  except
    v := cNULL;
  end;

  Result := StrToFloatDef(v, NADA);
end;

function StrToHex(Text: AnsiString): AnsiString;
var //17.11.11 nk opt for xe - convert Text string to a hex string (1 char = 2 hex)
  i, c: Integer;
begin;
  Result := cEMPTY;

  for i := 1 to Length(Text) do begin
    c := Ord(Text[i]);
    Result := Result + AnsiString(Format(FORM_HEX, [c])); //xe
  end;
end;

function HexToStr(Hex: AnsiString): AnsiString;
var //17.11.11 nk opt for xe - convert Hex string to a text string (2 hex = 1 char)
  i, c, x: Integer;
  s: AnsiString; //xe
begin;
  c := CLEAR;
  Result := cEMPTY;

  for i := 1 to (Length(Hex) div 2) do begin
    Inc(c);
    s := AnsiString(cHEX + Hex[c]);      //xe
    Inc(c);
    s := s + Hex[c];                     //Hex = '$3E'
    x := StrToInt(string(s));            //Dec = 62  / xe
    Result := Result + AnsiChar(Chr(x)); //Chr = '>' / xe
  end;
end;

function StringIndex(Input: string; List: array of string): Integer;
begin
  Result := CLEAR;
  while (Result < Length(List)) and (List[Result] <> Input) do
    Inc(Result);
  if List[Result] <> Input then
    Result := NONE;
end;

function CreateHint(HeadText: string; TailText: string = cEMPTY): string;
var //06.11.11 nk opt TailText=cEMPTY
  head, tail: string;  //19.04.07 nk opt
begin
  head := TrimEx(HeadText); //06.11.11 nk old=Trim
  tail := TrimEx(TailText);

  if (head <> cEMPTY) and (tail <> cEMPTY) then
    Result := cSPACE + head + cSPLIT + tail + cSPACE
  else
    Result := cSPACE + head + tail + cSPACE;
end;

function ProperString(Input: string): string;
var //11.07.12 nk add - set 1st char upper case (chars not in the range a..z are unaffected)
  unichar: Char; //improved Unicode version
begin
  Result    := Trim(Input);
  unichar   := Result[1];
  Result[1] := UpCase(unichar);
end;

function ProperCase(Input: string; FirstOnly: Boolean = False): string;
var //06.11.11 nk opt - set 1st char upper case - if not FirstOnly then all others lower case
  big: string;
begin
  Result := TrimEx(Input); //06.11.11 nk old=Trim
  if Result = cEMPTY then Exit;

  //25.08.08 nk opt
  if not FirstOnly then Result := LowerCase(Result);

  big := UpperCase(Result);
  Result[1] := big[1];
end;

function CamelCase(Input: string): string;
var //06.11.11 nk opt - convert 'Many words' to 'ManyWords'
  p: Integer;
  big: string;
begin
  Result := TrimEx(Input);        //06.11.11 nk old=Trim
  if Result = cEMPTY then Exit;

  if Pos(cSPACE, Result) > 0 then //23.02.09 nk opt
    Result := LowerCase(Result);

  Result := StringReplace(Result, cULINE, cSPACE, [rfReplaceAll]);
  big := UpperCase(Result);
  Result[1] := big[1];

  while (Pos(cSPACE, Result) > 0) do begin
    p := Pos(cSPACE, Result);
    Result[p] := cULINE;
    Result[p + 1] := big[p + 1];
  end;

  Result := StringReplace(Result, cULINE, cEMPTY, [rfReplaceAll]);
  Result := StringReplace(Result, cSLASH, cEMPTY, [rfReplaceAll]); //05.09.11 nk add
end;

function TrimEx(Input: string): string;
begin //08.11.11 nk opt - remove leading and trailing white spaces (Unicode conform)
  Result := StringReplace(Input, cDIS, cSPACE, [rfReplaceAll]); //remove #160
  Result := Trim(Result);
end;

function TrimAll(Input: string; ValidChars: TCharSet = EMPTY_SET): string;
var //xe//remove all control and white characters from input string
  doval: Boolean; //ValidChars = ANSI character set (Unicode conform)
  i: Integer;
begin
  Result := cEMPTY;
  doval := (ValidChars <> EMPTY_SET);

  for i := 1 to Length(Input) do begin
    if doval then begin //check for valid characters
      if CharInSet(Input[i], ValidChars) then
        Result := Result + Input[i]; //xe//
    end else begin
      if not CharInSet(Input[i], WHITE_CHARS) then
        Result := Result + Input[i]; //xe//
    end;
  end;
end;

function DeFormatByte(Bytes: string): Int64;
var //06.11.11 nk opt - use StrToFloatDef
  i: Integer;
  v: Double;
  m: Double;
  part: string;
  mult: string;
begin
  Result := CLEAR;         //01.07.11 nk add ff
  Bytes  := TrimEx(Bytes); //06.11.11 nk old=Trim
  if Bytes = cEMPTY then Exit;

  m := NORM;
  mult := TrimEx(AMULT);   //06.11.11 nk old=Trim

  try
    part := StrSplit(Bytes, cSPACE, 0);
    v := StrToFloatDef(part, NADA);
    part := StrSplit(Bytes, cSPACE, 1);

    for i := 1 to Length(mult) do begin
      m := m * KMULT;
      if Pos(mult[i], part) > 0 then v := v * m;
    end;

    Result := Round(v);
  except
    Result := CLEAR;
  end;
end;

function FormatByte(Bytes: Int64; Format: TSizeFormat; Digit: Byte; Gap: string = cSPACE): string;
// 06.11.11 nk opt
// Format given bytes to a dot separated string with a multiply letter
// Input:  Bytes = number of bytes
//         Format = size format (sfKilo..sfExa, sfAuto=auto range)
//         Digit = precision (0..8, 9=auto scaling)
//         Gap = spacing between the value and the unit (default is 1 space)
// Output: None
// Return: Formatted string with trailing letter for multiplier:
//         k=Kilo, M=Mega, G=Giga, T=Tera, P=Peta, E=Exa
// Remark: Auto range/scaling try to optimize the outlook
//         e.g. 433500 bytes will be formatted as 433.5 k
var
  n: Integer;
  nBytes: Extended; //01.07.11 nk old=Double
begin
  Result := cEMPTY;
  n := CLEAR;

  Set8087CW($133F); //01.07.11 nk add ff - disable all FPU exceptions
  SetRoundMode(rmNearest); //prevent EInvalidOp Error on RoundTo()

  if Bytes < 0 then Exit;
  nBytes := NORM * Bytes;

  try //01.07.11 nk add
    if Format = sfAuto then begin
      while nBytes > KMULT do begin
        Inc(n);
        nBytes := nBytes / KMULT;
      end;
    end else begin
      while Ord(Format) > n do begin
        Inc(n);
        nBytes := nBytes / KMULT;
      end;
    end;

    if Digit > 8 then begin
      Digit := 1;
      if nBytes < 10.0   then Digit := 2;
      if nBytes > 1000.0 then Digit := 0;
    end;

    nBytes := RoundTo(nBytes, -Digit); //19.09.09 nk add Gap / old=cSPACE
    Result := FloatToStr(nBytes) + Gap + TrimEx(AMULT[n + 1]); //06.11.11 nk old=Trim
  except
    Result := cEMPTY;
  end;
end;

procedure Delay(MilliSeconds: Longword);
var
  start: Longword;
  stop: Longword;
begin
  start := GetTickCount;
  repeat
    stop := GetTickCount;
    Application.ProcessMessages;
  until (stop - start) >= MilliSeconds;
end;

procedure DelayMicro(MicroSeconds: Int64);
var
  t1, t2: Int64;
  dif, res: Int64;
begin
  if QueryPerformanceFrequency(res) then begin
    if res <= 0 then Exit;

    QueryPerformanceCounter(t1);

    repeat
      QueryPerformanceCounter(t2);
      dif := (t2 - t1) * MEGA div res; //[us]
      Application.ProcessMessages;
    until dif > MicroSeconds;
  end;
end;

procedure WaitOnKey(Key: Integer = NONE);
begin //wait until the requested key was pressed (non-blocking)
  if Key = NONE then begin
    repeat
      Delay(KEY_DELAY);
    until (GetKeyState(VK_RETURN) and KEY_MASK = KEY_MASK);
  end else begin
    while (GetKeyState(Key) and KEY_MASK <> KEY_MASK) do
      Delay(KEY_DELAY);
  end;
end;

procedure Beep(Freq: Integer = BEEP_FREQ; Dur: Integer = BEEP_DUR);
begin //sound output over the PC speaker w/o volume control
  if (Dur <= 0) or (Freq < 100) then Exit;

  Freq := Min(Freq, BEEP_MAX);
  Windows.Beep(Freq, Dur);
end;

function GetMouse: string;
var //01.12.10 nk opt - get Mouse provider and type
  i: Integer;
  reg: TRegistry;
  dlist: TStringList;
begin
  Result := cEMPTY;
  reg    := TRegistry.Create(KEY_READ);
  dlist  := TStringList.Create;

  //HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{XY}\0000\
  with reg do begin
    try
      CloseKey;
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(REG_CLASS_KEY, False) then begin
        if HasSubKeys then GetKeyNames(dlist);
        for i := 0 to dlist.Count - 1 do begin
          if OpenKey(REG_CLASS_KEY + cBACK + dlist[i], False) then begin
            if ValueExists(REG_CLASS) then begin
              if ReadString(REG_CLASS) = REG_MOUSE then begin
                if OpenKey(REG_CLASS_KEY + cBACK + dlist[i] + cBACK + REG_SUBCLASS, False) then begin
                  if ValueExists(REG_PROVIDER) then
                    Result := ReadString(REG_PROVIDER);
                  if ValueExists(REG_DRDESC) then
                    Result := Result + cSPACE + ReadString(REG_DRDESC);
                  Break;
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      CloseKey;
    end;
  end;

  dlist.Free;
  Result := Trim(Result);
end;

function GetMouseButtons: Integer;
begin //return number of mouse buttons or -1 if no mouse
  if GetSystemMetrics(SM_MOUSEPRESENT) <> NERR_SUCCESS then
    Result := GetSystemMetrics(SM_CMOUSEBUTTONS)
  else
    Result := NONE;
end;

function GetMouseWheel: Integer;
begin //30.11.10 nk opt - return 1 if mouse has a wheel, else 0
  if GetSystemMetrics(SM_MOUSEPRESENT) <> NERR_SUCCESS then
    Result := GetSystemMetrics(SM_MOUSEWHEELPRESENT)
  else
    Result := CLEAR;
end;

function GetPorts(Ports, Devices: TStrings): Integer;
var //20.09.09 nk opt ff - return the number of available hardware ports (0=none)
  i: Integer;  //and a list of ports (COM1, COM2, LPT1...)
  com: string; //and a list of device names (Serial0, Serial1, Parallel0...)
  reg: TRegistry;    //Read only - else needs admin privilege!
  dlist: TStringList;
begin
  Result := CLEAR;
  dlist  := TStringList.Create;
  reg    := TRegistry.Create(KEY_READ); //12.09.08 nk opt

  with reg do begin
    try
      RootKey := HKEY_LOCAL_MACHINE;

      if OpenKey(REG_COM_KEY, False) then begin //get COM ports
        GetValueNames(dlist);

        for i := 0 to dlist.Count - 1 do begin
          com := ExtractFileName(dlist.Strings[i]);
          Devices.Append(com); //get device name
          com := ReadString(dlist.Strings[i]);
          com := StringReplace(com, REG_DOS_DEVS, cEMPTY, [rfReplaceAll]);
          Ports.Append(com);   //get port name
          Inc(Result);
        end;
        CloseKey;
      end;

      dlist.Clear;

      if OpenKey(REG_LPT_KEY, False) then begin //get LPT ports
        GetValueNames(dlist);

        for i := 0 to dlist.Count - 1 do begin
          com := ExtractFileName(dlist.Strings[i]);
          Devices.Append(com); //get device name
          com := ReadString(dlist.Strings[i]);
          com := StringReplace(com, REG_DOS_DEVS, cEMPTY, [rfReplaceAll]);
          Ports.Append(com);   //get port name
          Inc(Result);
        end;
        CloseKey;
      end;
    finally
      Free;
      dlist.Free;
    end;
  end;
end;

function GetBiosVers(Video: Boolean = False): string;
var //20.09.09 nk opt ff - return the version of the System or Video BIOS
  reg: TRegistry;  //Read only - else needs admin privilege!
begin
  Result := cEMPTY;
  reg    := TRegistry.Create(KEY_READ); //12.09.08 nk opt

  with reg do begin
    RootKey := HKEY_LOCAL_MACHINE;
    if Video then begin    //get the Video BIOS version
      if OpenKey(REG_HWD_KEY, False) then begin
        if ValueExists(REG_VID_VERS) then
          Result := ReadMultiString(reg, REG_VID_VERS, 1); //1=get 1st part (0=all)
        CloseKey;
      end;
    end else begin         //get the System BIOS version
      if OpenKey(REG_HWD_KEY + REG_BIOS, False) then begin
        if ValueExists(REG_BIOS_VERS) then
          Result := ReadString(REG_BIOS_VERS);
        CloseKey;
      end;
    end;
    Free;
  end;
end;

function GetBiosDate(Video: Boolean = False): string;
var //20.09.09 nk opt ff - return the date of the System or Video BIOS
  reg: TRegistry;  //Read only - else needs admin privilege!
begin
  Result := cEMPTY;
  reg    := TRegistry.Create(KEY_READ); //12.09.08 nk opt

  with reg do begin
    RootKey := HKEY_LOCAL_MACHINE;
    if Video then begin    //get the Video BIOS date
      if OpenKey(REG_HWD_KEY, False) then begin
        if ValueExists(REG_VID_DATE) then
          Result := ReadString(REG_VID_DATE);
        CloseKey;
      end;
    end else begin        //get the System BIOS date
      if OpenKey(REG_HWD_KEY, False) then begin
        if ValueExists(REG_BIOS_DATE) then
          Result := ReadString(REG_BIOS_DATE);
        CloseKey;
      end;
    end;
    Free;
  end;
end;

function GetProductData(DataTyp: Byte): string;
var //12.11.11 nk opt - return the requested data of the Computer Product from Registry
  key, sub: string;
  reg: TRegistry;  //Read only - else needs admin privilege!
begin
  Result := cEMPTY;

  case DataTyp of            //like:
    1: key := REG_BIOS_MANU; //'Award'
    2: key := REG_BIOS_VERS; //'786F1 v01.04'
    3: key := REG_BIOS_RDAT; //'07/18/2007'
    4: key := REG_BORD_MANU; //'ASUS'
    5: key := REG_BORD_NAME; //'P612-C'
    6: key := REG_COMP_MANU; //'Hewlett-Packard'
    7: key := REG_COMP_NAME; //'HP Compaq DC7800'
    8: key := REG_COMP_TYPE; //'AT/AT COMPATIBLE'
  else
    Exit;
  end;

  if DataTyp = 8 then
    sub := cEMPTY
  else
    sub := REG_BIOS;

  reg := TRegistry.Create(KEY_READ);

  with reg do begin
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey(REG_HWD_KEY + sub, False) then begin
      if ValueExists(key) then
        Result := ReadString(key);
      CloseKey;
    end;
    Free;
  end;
end;

function GetWindowsData(DataTyp: Byte): string;
var //24.04.15 nk add - return the requested data of the Windows System from Registry
  key: string;
  reg: TRegistry;  //Read only - else needs admin privilege!
begin
  Result := cEMPTY;

  case DataTyp of            //like:
    1: key := REG_ORGANISAT; //'seanus systems'
    2: key := REG_OWNER;     //'Benny Huber'
    3: key := REG_PRODNAME;  //'Windows Vista (TM) Business'
    4: key := REG_PRODCODE;  //'89576-OEM-7332141-00039'
    5: key := REG_EDITION;   //'Business'
    6: key := REG_CURVERS;   //'6.0'
    7: key := REG_CURBUILD;  //'6002'
    8: key := REG_CSDBUILD;  //'1621'
    9: key := REG_CSDVERS;   //'Service Pack 2'
  else
    Exit;
  end;

  reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY); //24.04.15 nk opt for 64-Bit systems

  with reg do begin
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey(REG_SMW_KEY, False) then begin
      if ValueExists(key) then
        Result := ReadString(key);
      CloseKey;
    end;
    Free;
  end;
end;

function GetOrganisation: string;
var //24.04.15 nk add - return registerd organisation name
  reg: TRegistry; //Read only - else needs admin privilege!
begin
  Result := cEMPTY;
  reg    := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY); //24.04.15 nk opt for 64-Bit systems

  with reg do begin
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey(REG_SMW_KEY, False) then begin
      if ValueExists(REG_ORGANISAT) then
        Result := ReadString(REG_ORGANISAT);
      CloseKey;
    end;
    Free;
  end;
end;

function GetScreenSaver: Integer;
var //25.11.10 nk add - return screen saver time out [min] (0 = Off)
  reg: TRegistry;
begin
  Result := 0;
  reg    := TRegistry.Create(KEY_READ);

  with reg do begin
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REG_DESK_KEY, False) then begin
      if ValueExists(REG_SS_ACTIVE) then begin
        if ReadString(REG_SS_ACTIVE) = ISON then begin
          if ValueExists(REG_SS_DELAY) then
            Result := StrToIntDef(ReadString(REG_SS_DELAY), 0) div SEC_MIN;
        end;
      end;
      CloseKey;
    end;
    Free;
  end;
end;

procedure SetScreenSaver(Delay: Integer);
var //25.11.10 nk add - set the screen saver time out [s] / 0 = Off
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);

  with reg do begin
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REG_DESK_KEY, True) then begin //True=Create key if not exist
      if Delay > 0 then begin
        WriteString(REG_SS_DELAY, IntToStr(Delay));
        WriteString(REG_SS_ACTIVE, ISON);
      end else begin
        WriteString(REG_SS_ACTIVE, ISOFF);
      end;
      CloseKey;
    end;
    Free;
  end;
end;

function GetSystemLang: string;
var
  cLang: array [0..MAXBYTE] of Char;
begin 
  VerLanguageName(GetSystemDefaultLangID, cLang, MAXBYTE);
  Result := StrPas(cLang);
end;

function GetKeyboardLang(Code: string = cEMPTY): string;
var //25.02.16 nk opt - return keyboard country and language setting like 'DE-CH'
  reg: TRegistry;  //Read only - else needs admin privilege!
begin
  Result := cEMPTY;
  reg    := TRegistry.Create(KEY_READ);

  with reg do begin
    if Length(Code) = 8 then begin  //29.11.10 nk add ff
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(REG_KBD_KEY + Code, False) then begin
        if ValueExists(REG_LAYOUT) then
          Result := ReadString(REG_LAYOUT);
        CloseKey;
      end;
    end;

    if Result = cEMPTY then begin //try alternative
      RootKey := HKEY_CURRENT_USER;
      if OpenKey(REG_INT_KEY, False) then begin
        if ValueExists(REG_LOCALE) then begin //Is not supported on W2000 and XP
          Result := UpperCase(ReadString(REG_LOCALE));
        end else begin
          if ValueExists(REG_SCOUNTRY) then   //25.02.16 nk old=REG_COUNTRY
            Result := ReadString(REG_SCOUNTRY);
        end;
        CloseKey;
      end;
    end;
    Free;
  end;
end;

function GetLocalSettings(Default: Boolean): string;
const //19.02.14 nk opt for XE3 - get application's local or user's local settings
  BLEN = 10;
var
  ddat, tdat: PWideChar; //xe//PAnsiChar;
  dsep, tsep: string;
begin
  ddat := StrAlloc(BLEN);
  tdat := StrAlloc(BLEN);

  if Default then begin  //get user's settings from registry
    GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL,  ddat, BLEN);
    dsep := string(ddat);
    GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_STHOUSAND, tdat, BLEN);
    tsep := string(tdat);
  end else begin         //get application's local settings
    if FormatSettings.DecimalSeparator = cNUL then
      dsep := cEMPTY
    else
      dsep := FormatSettings.DecimalSeparator;//xe3//

    if FormatSettings.ThousandSeparator = cNUL then //xe3//
      tsep := cEMPTY
    else
      tsep := FormatSettings.ThousandSeparator;//xe3//
  end;

  Result := Format(FORM_FORMSET, [dsep, tsep]); //30.11.10 nk opt
//Result := 'Decimal Separator is "' + dsep + '", Thousand Separator is "' + tsep + '"';

  //01.10.10 nk add ff
  StrDispose(ddat);
  StrDispose(tdat);
end;

procedure SetLocalSettings(Dsep, Tsep: Char);
var //19.02.14 nk opt for XE3 - change the user's registry settings for ALL applications!
  buf: array[0..1] of Char;
begin
  Application.UpdateFormatSettings := True;

  StrPCopy(buf, Dsep);
  if SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, buf) then
    FormatSettings.DecimalSeparator := Dsep; //xe3//

  StrPCopy(buf, Tsep);
  if SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_STHOUSAND, buf) then
    FormatSettings.ThousandSeparator := Tsep; //xe//

  Application.UpdateFormatSettings := False;
end;

function SetSystemTime(SysTime: TDateTime): Boolean;
var //V5//27.03.17 nk opt
  dtset: TDateTime;
  tbias: Variant;
  tinfo: TTimeZoneInformation;
  stime: TSystemTime;
begin
  GetTimeZoneInformation(tinfo);
  tbias := (tinfo.Bias + tinfo.DaylightBias) / 1440; //V5//27.03.17 nk add DaylightBias
  dtset := SysTime + tbias;

  with stime do begin
    wYear   := StrToInt(FormatDateTime('yyyy', dtset));
    wMonth  := StrToInt(FormatDateTime('mm',   dtset));
    wDay    := StrToInt(FormatDateTime('dd',   dtset));
    wHour   := StrToInt(FormatDateTime('hh',   dtset));
    wMinute := StrToInt(FormatDateTime('nn',   dtset));
    wSecond := StrToInt(FormatDateTime('ss',   dtset));
    wMilliseconds := 0;
  end;

  Result := Windows.SetSystemTime(stime); //Windows makes time zone and daylight corrections
end;

function GetCompUser: string;
var
  sUser: string;
  nLen: Cardinal;
begin
  nLen := MAXBYTE - 2;
  SetLength(sUser, MAXBYTE - 1);
  GetUserName(PChar(sUser), nLen);
  SetLength(sUser, nLen - 1);
  Result := sUser;
end;

function GetUserAccount: string;
begin //20.09.09 nk add
  if IsAdmin then
    Result :=  GROUP_ADMIN
  else
    Result :=  GROUP_USER;
end;

function GetUserPrivileges(UserList: TStringList): Integer;
const //19.02.14 nk opt for XE3 - return list of users privileges
  TOKEN_SIZE = 800; //SizeOf(Pointer)=4*200
var
  i: Integer;
  rlen, lid: Cardinal;
  sname, sdisp: Cardinal;
  htok: System.THandle; //xe3//
  pname, dname: PChar;
  pinfo: PTOKENPRIVILEGES;
begin
  Result := CLEAR;
  UserList.Clear;
  GetMem(pinfo, TOKEN_SIZE);

  if not OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, htok) then Exit; //xe3//
  if not GetTokenInformation(htok, TokenPrivileges, pinfo, TOKEN_SIZE, rlen) then Exit;

  GetMem(pname, MAXBYTE);
  GetMem(dname, MAXBYTE);

  for i := 0 to pinfo.PrivilegeCount - 1 do begin
    sdisp := MAXBYTE;
    sname := MAXBYTE;
    LookupPrivilegeName(nil, pinfo.Privileges[i].Luid, pname, sname);
    LookupPrivilegeDisplayName(nil, pname, dname, sdisp, lid);
    UserList.Append(pname + cSEMI + dname);
  end;

  FreeMem(pname);
  FreeMem(dname);
  FreeMem(pinfo);

  Result := UserList.Count;
end;

function GetSerialNo(UseWinDrive: Boolean = False): string;
var //25.11.09 nk opt - get the serial number of the application folder drive
  nop: Cardinal;     // or the windows system drive (if True)
  num: Cardinal;     // see also GetDiskCode in UFile
  drv: string;
  path: array [0..MAX_PATH] of Char; //09.11.09 nk add
const
  SHGFP_TYPE_CURRENT  = 0;
  CSIDL_PROGRAM_FILES = $0026;
begin
  num := CLEAR;

  try //25.11.09 nk opt ff - old=CSIDL_PROGRAM_FILES like 'C:\Program Files\'
    if UseWinDrive then begin //get the windows folder like 'C:\Windows\'
      SHGetFolderPath(0, CSIDL_WINDOWS, 0, SHGFP_TYPE_CURRENT, @path[0]);
      drv := path;
    end else begin
      drv := Application.ExeName; //get application folder (the folder where the application was launched)
    end;

    drv := LeftStr(drv, 3);       //get the drive (like 'C:\')
    GetVolumeInformation(PChar(drv), nil, MAX_PATH, @num, nop, nop, nil, 0);
  finally
    Result := Format(FORM_SERNO, [num]);
  end;
end;

function GetDefPrinter: string;
begin //V5//16.02.17 nk opt improved version
  Result := txNoDefPrint; //V5//old=txNoPrint

  try //V5//16.02.17 nk add
    with Printer do begin
      if Printers.Count > 0 then
        Result := Printers[PrinterIndex];
    end;
  except
    //ignore if no default printer is selected
  end;
end;

function GetDefaultPrinter: string;
var //27.05.10 nk opt
  dev: array[0..MAXBYTE] of Char;
begin
  Result := txNoPrint; //27.05.10 nk add ff
  if Printer.Printers.Count = 0 then Exit;                //NOTE: This function is provided only
  GetProfileString(WIN16, KEY_DEV, cEMPTY, dev, MAXBYTE); //for compatibility with 16-bit
  Result := Trim(dev) + cCOMMA;                           //Windows-based applications!
  Result := LeftStr(Result, Pos(cCOMMA, Result) - 1);
end;

procedure SetDefaultPrinter(PrinterName: string);
var //V5//20.05.16 nk opt / new=PrinterName, old=Printer (reserved)
  dev: array[0..MAXBYTE] of Char;
begin
  StrPCopy(dev, PrinterName);                             //NOTE: This function is provided only
  WriteProfileString(WIN16, KEY_DEV, dev);                //for compatibility with 16-bit
  StrCopy(dev, WIN16);                                    //Windows-based applications!
  SendMessage(HWND_BROADCAST, WM_WININICHANGE, 0, LPARAM(@dev)); //V5//20.05.16 nk old=Longint (64-bit)
end;

function GetPrinterFormats(FormatList: TStrings): Integer;
type //19.02.14 nk opt for XE3
  TPaperName = array [0..63] of Char;
  TPaperNameArray = array [1..High(Word) div SizeOf(TPaperName)] of TPaperName;
  PPapernameArray = ^TPaperNameArray;
var
  i: Integer;
  device, driver, port: array [0..MAXBYTE] of Char;
  mode: System.THandle; //xe3//old=Cardinal;
  formats: PPaperNameArray;
begin
  Result := NERR_SUCCESS;  //27.05.10 nk opt ff
  FormatList.Clear;
  if Printer.Printers.Count = 0 then Exit;

  Printer.PrinterIndex := NONE; //standard printer
  Printer.GetPrinter(device, driver, port, mode);
  Result := WinSpool.DeviceCapabilities(device, port, DC_PAPERNAMES, nil, nil);

  if Result > NERR_SUCCESS then begin
    GetMem(formats, Result * SizeOf(TPaperName));
    try
      WinSpool.DeviceCapabilities(device, port, DC_PAPERNAMES, PChar(formats), nil);
      for i := 1 to Result do
        FormatList.Add(formats^[i]);
    finally
      FreeMem(formats);
    end;
  end;
end;

function GetCompName: string;
var
  buff: array[0..MAX_COMPUTERNAME_LENGTH + 1] of Char;
  size: Cardinal;
begin 
  size := MAX_COMPUTERNAME_LENGTH + 1;
  GetComputerName(@buff, size);
  Result := StrPas(buff);
end;

function GetScreen(out Width, Height, Freq, Bits: Cardinal): string;
var //03.05.07 nk opt ff
  win: HDC; //19.06.07 nk old THandle;
begin
  Width  := CLEAR;
  Height := CLEAR;
  Freq   := CLEAR;
  Bits   := CLEAR;
  win    := GetDC(HWND_DESKTOP);

  if win <> NERR_SUCCESS then begin
    try
      Width  := GetDeviceCaps(win, HORZRES);
      Height := GetDeviceCaps(win, VERTRES);
      Freq   := GetDeviceCaps(win, VREFRESH);
      Bits   := GetDeviceCaps(win, BITSPIXEL);
    finally
      ReleaseDC(HWND_DESKTOP, win);
    end;
  end;

  Result := Format(FORM_SCREEN, [Width, Height, Bits, Freq, UHERTZ]);
end;

function GetResolution(Device: TDevType): Integer;
var //27.05.10 nk opt - return the resolution of the requested device type [dpi]
  win: HDC; //19.06.07 nk old THandle;
begin
  Result := CLEAR;
  if Printer.Printers.Count = 0 then Exit; //27.05.10 nk add

  if Device = dtPrinter then begin
    win := Printer.Handle;
    if win <> NERR_SUCCESS then
      Result := GetDeviceCaps(win, LOGPIXELSX);
  end else begin
    win := GetDC(HWND_DESKTOP);
    if win <> NERR_SUCCESS then begin //19.06.07 nk opt
      try
        Result := GetDeviceCaps(win, LOGPIXELSX);
      finally
        ReleaseDC(HWND_DESKTOP, win);
      end;
    end;
  end;
end;

function GetShellError(ErrCode: Integer): string;
begin //20.02.08 nk opt - ErrCode retrived from GetShellError
  Result := cEMPTY;

  case ErrCode of
     0: Result := 'The operating system is out of memory or resources';
     2: Result := 'The specified file was not found';
     3: Result := 'The specified path was not found';
     5: Result := 'The operating system denied access to the specified file';
     6: Result := 'The library needs separate memory segments for each task';
     8: Result := 'There was not enough memory to complete the operation';
    10: Result := 'Invalid Windows version';
    11: Result := 'Invalid file type - no Windows program or invalid EXE-file';
    12: Result := 'This is not a Windows application';
    13: Result := 'This is a MS-DOS application';
    14: Result := 'Unknown file type';
    15: Result := 'Real mode application cannot be executed';
    16: Result := 'An instance of the application is already running';
    19: Result := 'Compressed file cannot be loaded';
    20: Result := 'Invalid DLL';
    26: Result := 'A sharing violation occurred';
    27: Result := 'The file name association is incomplete or invalid';
    28: Result := 'The DDE transaction request timed out';
    29: Result := 'The DDE transaction failed';
    30: Result := 'The DDE transaction could not be completed';
    31: Result := 'There is no application associated with the given file name extension';
    32: Result := 'The specified DLL was not found';
  else
    if ErrCode < SHELL_ERROR then
      Result := 'Unknown error ' + IntToStr(ErrCode);
  end;
end;

function GetLastErrorText: string;
var //08.12.09 nk add - return the last error (from GetLastError) as text string
  size: DWORD;
  tmp: PWideChar; //xe//PAnsiChar;
begin
  size := 512;
  tmp := nil;

  try
    GetMem(tmp, size);
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ARGUMENT_ARRAY,
      nil,
      GetLastError,
      LANG_NEUTRAL,
      tmp,
      size,
      nil)
  finally
    Result := tmp;
    FreeMem(tmp);
  end
end;

function GetFont(out FontSize: Integer): Boolean;
var //return True if font size is normal, False if big
  win: HDC; //19.06.07 nk old THandle;
begin  //02.04.08 nk opt ff
  FontSize := FONT_NORM;
  win := GetDC(HWND_DESKTOP);

  if win <> NERR_SUCCESS then begin //19.06.07 nk opt ff
    try
      FontSize := GetDeviceCaps(win, LOGPIXELSX);
    finally
      ReleaseDC(HWND_DESKTOP, win);
    end;
  end;

  Result := (FontSize = FONT_NORM);
end;

function GetFontSize: string;
var //30.11.10 nk opt
  fs: Integer;
begin
  GetFont(fs);
  Result := IntToStr(fs) + cSPACE + UNIT_DPI;
end;

function GetFontScale: Single;
var //return font scaling factor rel to normal font (96dpi = 1.0 / 120dpi = 1.25)
  fs: Integer;
begin
  GetFont(fs);

  if fs > 0 then
    Result := fs / FONT_NORM
  else
    Result := NORM;
end;

function GetFontHeight(FontType: TFont): Integer;
var //10.06.11 nk opt - return text height of given font with top and bottom margins
  bm: TBitmap;
begin
  bm := TBitmap.Create;

  try
    with bm.Canvas do begin  //02.04.08 nk opt
      Font.Name := FontType.Name;
      Font.Size := FontType.Size;
      Result    := TextHeight(UBYTE) + 2;
    end;
  finally
    bm.Free;
  end;
end;

function GetFontWidth(FontType: TFont): Integer;
var //10.06.11 nk add - return text width of given font with left and right margins
  bm: TBitmap;
begin
  bm := TBitmap.Create;

  try
    with bm.Canvas do begin
      Font.Name := FontType.Name;
      Font.Size := FontType.Size;
      Result    := TextWidth(UBYTE) + 2;
    end;
  finally
    bm.Free;
  end;
end;

function GetScreenFont(FontName: string): Boolean;
begin //22.09.09 nk add - return True if FontName is a valid screen font
  Result := (Screen.Fonts.IndexOf(FontName) > NONE);
end;

function GetPrinterFont(FontName: string): Boolean;
begin //27.05.10 nk opt - return True if FontName is a valid printer font
  Result := False;
  if Printer.Printers.Count = 0 then Exit; //27.05.10 nk add
  Result := (Printer.Fonts.IndexOf(FontName) > NONE);
end;

function GetDelphi: Boolean;
begin //True if Delphi IDE is running
  try
    Result := (FindWindow(DELPHI_APP, nil) > NERR_SUCCESS);
  except
    Result := False;
  end;
end;

function GetMin(x, y: Extended): Extended;
begin
  Result := Min(x, y);
end;

function GetMax(x, y: Extended): Extended;
begin
  Result := Max(x, y);
end;

function GetBurner: Boolean;
var //30.11.10 nk opt - return True if a CD/DVD-burner is available
  reg: TRegistry;
begin
  Result := False;
  reg    := TRegistry.Create(KEY_READ);

  with reg do begin
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REG_CDROM_KEY, False) then begin
      if ValueExists(REG_CDROM) then
        Result := True;
      CloseKey;
    end;
    Free;
  end;
end;

function GetProcessorVers(VersType: TVersType): string;
var //16.09.09 nk opt ff
  sInfo: TSystemInfo;
  nVerMaj: Integer;
  nVerMin: Integer;
  sType: string;
  sName: string;
  sCore: string;
begin
  Result := cEMPTY;

  try
    sName := GetProcessorName;
    GetSystemInfo(sInfo);
  except
    Exit;
  end;

  with sInfo do begin
    nVerMaj := Hi(wProcessorRevision);
    nVerMin := Lo(wProcessorRevision);
    sType   := 'Unknown Processor ' + IntToStr(dwProcessorType); //16.09.09 nk add

    case dwNumberOfProcessors of //16.09.09 nk add ff
      0: sCore := cEMPTY;
      1: sCore := 'Single Core';
      2: sCore := 'Dual Core';
      3: sCore := 'Tri Core';
      4: sCore := 'Quad Core';
    else
      sCore := IntToStr(dwNumberOfProcessors) + ' Core';
    end;

    case wProcessorArchitecture of
      PROC_INTEL: begin
        case (wProcessorLevel and 15) of
          3: sType := 'Intel 386';
          4: sType := 'Intel 486';
          5: sType := 'Intel Pentium';
          6: case Hi(wProcessorRevision) of
               1:  sType := 'Intel Pentium Pro';
               3:  sType := 'Intel Pentium 2';
               5:  sType := 'Intel Pentium 2';
               6:  sType := 'Intel Celeron';
               7:  sType := 'Intel Pentium 3';
               8:  sType := 'Intel Pentium 3';
               10: sType := 'Intel Pentium 3';
               11: sType := 'Intel Pentium 3';
             else
               sType := 'Intel ' + IntToStr(dwProcessorType) + cSPACE + sCore;
             end;
          15: sType := 'Intel Pentium 4';
        else
          sType := 'Intel ' + IntToStr(dwProcessorType);
        end;
      end;

      PROC_MIPS:    sType := 'MIPS';
      PROC_ALPHA:   sType := 'ALPHA';
      PROC_PPC:     sType := 'PPC';
      PROC_SHX:     sType := 'SHX';
      PROC_ARM:     sType := 'ARM';
      PROC_IA64:    sType := 'IA64';
      PROC_ALPHA64: sType := 'ALPHA64';
      PROC_AMD64:   sType := 'AMD64';   //16.09.09 nk add
    end;

    case VersType of
      vtVerMaj: Result := IntToStr(nVerMaj);              //processor model
      vtVerMin: Result := IntToStr(nVerMin);              //processor stepping
      vtVers:   Result := IntToStr(wProcessorLevel);      //family level
      vtBuild:  Result := IntToStr(dwNumberOfProcessors); //16.09.09 nk add
      vtName:   Result := sName;
      vtShort:  Result := IntToStr(dwProcessorType);      //16.09.09 nk old=sType
      vtDesc:   Result := sType;                          //16.09.09 nk add
      vtPack:   Result := sCore;                          //16.09.09 nk add
      vtLong:   if sName = cEMPTY then
                  Result := sType
                else
                  Result := sName;
    end;
  end;
end;

function GetProcessorName: string;
// Return the registered name of the processor
// Input:  None
// Output: None
// Return: Processor name like 'Intel(R) Pentium(R) 4 CPU 1500MHz'
// Remark: Read only - else needs admin privilege!
var //19.09.09 nk opt ff
  i: Integer;
  val, gap: string;
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_READ); //12.09.08 nk opt

  try
    with reg do begin
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(REG_CPU_KEY, False) then begin
        val := Trim(ReadString(REG_CPU_NAME));

        if val = cEMPTY then begin //get alternate infos
          val := Trim(ReadString(REG_CPU_PID));
          val := Trim(ReadString(REG_CPU_VID)) + cSPACE + val;
        end;

        for i := 8 downto 2 do begin //19.09.09 nk opt ff - remove surplus spaces
          gap := StringOfChar(cSPACE, i);
          val := StringReplace(val, gap, cEMPTY, [rfReplaceAll]);
        end;

        CloseKey;
      end;
    end;
  except
    val := cEMPTY;
  end;

  reg.Free;
  Result := Trim(val);
end;

function GetProcessorClock: string;
// Return the registered clock frequency of the processor in MHz
// Input:  None
// Output: None
// Return: Processor speed in MHz like '1500 MHz'
// Remark: Read only - else needs admin privilege!
var
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_READ); //12.09.08 nk opt

  with reg do begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(REG_CPU_KEY, False) then begin
        Result := IntToStr(ReadInteger(REG_CPU_SPEED)) + cSPACE + MHERTZ;
        CloseKey;
      end;
    except
      Result := cEMPTY;
    end;
    Free;
  end;
end;

function GetProcessorSpeed: Int64;
// Return the speed (clock frequency) of the processor in kHz
// Input:  None
// Output: None
// Return: Processor speed in kHz
// Remark: Call this function more than one time for an accurate result
{$IFDEF CPUX64} //20.02.14 nk opt for XE3
begin
  Result := 0;
end;
{$ELSE}
const
  SDELAY = 10;  //05.01.08 nk add
  LDELAY = 500;
var 
  Hi, Lo: Longword;
  PriorityClass, ThreadPriority: Integer;
begin
  PriorityClass  := GetPriorityClass(GetCurrentProcess);
  ThreadPriority := GetThreadPriority(GetCurrentThread);

  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS); 
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);

  Sleep(SDELAY);

  asm 
    dw 310Fh 
    mov Lo, eax
    mov Hi, edx
  end;

  Sleep(LDELAY);

  asm
    dw 310Fh 
    sub eax, Lo
    sbb edx, Hi
    mov Lo, eax
    mov Hi, edx
  end;

  SetThreadPriority(GetCurrentThread, ThreadPriority);
  SetPriorityClass(GetCurrentProcess, PriorityClass); 

  Result := Lo div LDELAY;
end;
{$ENDIF}

function GetMemory(SizeType: TMemSize): Int64;
// Return the requested size in bytes of the system, heap or process memory
// Input:   SizeType = msTotal, msFree...msError
// Output:  None
// Return:  Memory size in bytes or 0 if failed
// Remark:  msProc calls the internal function GetProcessMemory
// Caution: This function is limited to 2GB of memory - use GetMemoryEx instead
var
  hMem: THeapStatus; //12.10.07 nk add
  sMem: TMemoryStatus;
begin
  try
    hMem := GetHeapStatus;
    sMem.dwLength := SizeOf(sMem);
    GlobalMemoryStatus(sMem);

    //21.01.08 nk opt ff - exception occured 'IntegerOverflow'
    case SizeType of
      msTotal: Result := sMem.dwTotalPhys;
      msFree:  Result := sMem.dwAvailPhys;
      msUsed:  Result := sMem.dwTotalPhys - sMem.dwAvailPhys;
      msBlock: Result := AllocMemCount;
      msHeap:  Result := AllocMemSize;
      msProc:  Result := GetProcessMemory;  //nk//add InPercent
      msSpace: Result := hMem.TotalAddrSpace; //12.10.07 nk add ff
      msUncom: Result := hMem.TotalUncommitted;
      msCom:   Result := hMem.TotalCommitted;
      msAlloc: Result := hMem.TotalAllocated;
      msTfree: Result := hMem.TotalFree;
      msSfree: Result := hMem.FreeSmall;
      msBfree: Result := hMem.FreeBig;
      msUnuse: Result := hMem.Unused;
      msOver:  Result := hMem.Overhead;
      msError: Result := hMem.HeapErrorCode;
      msLoad:  Result := Round(PROCENT * hMem.TotalAllocated / hMem.TotalAddrSpace);
    else
      Result := CLEAR;
    end;
  except
    if SizeType = msLoad then
      Result := PROCENT
    else
      Result := CLEAR;
  end;
end;

function GetMemoryEx(SizeType: TMemSize): Int64;
// Return the requested size in bytes of the system, heap or process memory
// Input:   SizeType = msTotal, msFree...msXFree
// Output:  None
// Return:  Memory size in bytes or 0 if failed
// Remark:  msProc calls the internal function GetProcessMemory
//          Improved version for total memory size > 2GB RAM
//          Get also page, virtual, and extended memory
// Caution: Is not very accurate (mostly too little) - use UDiag.GetTotalMemory instead
var //21.09.09 nk add
  hMem: THeapStatus;
  sMem: TMemoryStatusEx;
begin
  try
    if SizeType in [msTotal..msPLoad] then begin  //get system memory (RAM)
      ZeroMemory(@sMem, SizeOf(TMemoryStatusEx));
      sMem.dwLength := SizeOf(TMemoryStatusEx);
      GlobalMemoryStatusEx(sMem);
    end;

    if SizeType in [msSpace..msError] then begin  //get program memory (Heap)
      hMem := GetHeapStatus;
    end;

    case SizeType of
      msTotal:  Result := sMem.ullTotalPhys;       //total bytes of physical memory
      msFree:   Result := sMem.ullAvailPhys;       //free bytes of physical memory
      msUsed:   Result := sMem.ullTotalPhys - sMem.ullAvailPhys; //used bytes of physical memory
      msPTotal: Result := sMem.ullTotalPageFile;   //total bytes of paging file
      msPFree:  Result := sMem.ullAvailPageFile;   //free bytes of paging file
      msVTotal: Result := sMem.ullTotalVirtual;    //total bytes of virtual memory
      msVFree:  Result := sMem.ullAvailVirtual;    //free bytes of virtual memory
      msXFree:  Result := sMem.ullAvailExtendedVirtual; //free bytes of extended memory
      msPLoad:  Result := sMem.dwMemoryLoad;       //percent of memory in use
      msBlock:  Result := AllocMemCount;
      msHeap:   Result := AllocMemSize;
      msProc:   Result := GetProcessMemory;        //nk//add InPercent
      msSpace:  Result := hMem.TotalAddrSpace;     //total program address range
      msUncom:  Result := hMem.TotalUncommitted;
      msCom:    Result := hMem.TotalCommitted;
      msAlloc:  Result := hMem.TotalAllocated;     //total dynamically allocated heap
      msTfree:  Result := hMem.TotalFree;          //free dynamically allocated heap
      msSfree:  Result := hMem.FreeSmall;
      msBfree:  Result := hMem.FreeBig;
      msUnuse:  Result := hMem.Unused;
      msOver:   Result := hMem.Overhead;
      msLoad:   Result := Round(PROCENT * hMem.TotalAllocated / hMem.TotalAddrSpace);
      msError:  Result := hMem.HeapErrorCode;      //status of the heap
    else
      Result := CLEAR;
    end;
  except
    Result := CLEAR;
  end;
end;

function GetPhysicalMemory: string;
var //30.11.10 nk opt - get physical memory usage (RAM)
  mt, mf: string; //Is not very accurate (mostly too little) - use UDiag.GetTotalMemory instead
begin
  mt := FormatByte(GetMemoryEx(msTotal), sfMega, 0) + UBYTE;
  mf := FormatByte(GetMemoryEx(msFree),  sfMega, 0) + UBYTE;
  Result := Format(FORM_MEMORY, [mt, mf]); //30.11.10 nk opt
//Result := 'Total: ' + mt + ' / Free: ' + mf;
end;

function GetVirtualMemory: string;
var //30.11.10 nk opt  - get virtual memory usage (pagefile)
  mt, mf: string;
begin
  mt := FormatByte(GetMemoryEx(msPTotal), sfMega, 0) + UBYTE;
  mf := FormatByte(GetMemoryEx(msPFree),  sfMega, 0) + UBYTE;
  Result := Format(FORM_MEMORY, [mt, mf]); //30.11.10 nk opt
//Result := 'Total: ' + mt + ' / Free: ' + mf;
end;

function GetAllocMemSize: Integer;
//25.07.17 nk add (replacement for deprecated AllocMemSize)
{$IF CompilerVersion >= 18}
var
  i: Integer;
  MemMgrState: TMemoryManagerState;
{$IFEND}
begin
{$IF CompilerVersion < 18}
  Result := AllocMemSize;
{$ELSE}
  GetMemoryManagerState(MemMgrState);
  Result := MemMgrState.TotalAllocatedMediumBlockSize + MemMgrState.TotalAllocatedLargeBlockSize;
  for i := 0 to High(MemMgrState.SmallBlockTypeStates) do
    Result := Result + MemMgrState.SmallBlockTypeStates[i].InternalBlockSize + MemMgrState.SmallBlockTypeStates[i].UseableBlockSize;
{$IFEND}
end;

function GetProcessList(ProcList: TStrings; Filter: string = cEMPTY): Integer;
var //return list of running processes which contains the word 'Filter'
  hwin: Cardinal;
  info: TProcessEntry32;
begin
  hwin := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  Filter := UpperCase(Trim(Filter));  //ignore case, cut whitespaces
  ProcList.Clear;

  if hwin > NERR_SUCCESS then begin
    info.dwSize := SizeOf(info);
    if Process32First(hwin, info) = True then begin
      while Process32Next(hwin, info) = True do begin
        if (Filter = cEMPTY) or (Pos(Filter, UpperCase(info.szExeFile)) > 0) then
          ProcList.Append(info.szExeFile);
      end;
    end;
    CloseHandle(hwin);
  end;

  Result := ProcList.Count;
end;

function GetProcessID(ProgName: string): Cardinal;
var //return process ID from given program name (like 'nero.exe') or 0 if not found
  hwin: Cardinal; //14.04.08 nk opt ff
  info: TProcessEntry32;
begin
  Result := CLEAR;
  ProgName := UpperCase(progName);
  hwin := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);

  if hwin > NERR_SUCCESS then begin
    info.dwSize := SizeOf(info);
    if Process32First(hwin, info) = True then begin
      while Process32Next(hwin, info) = True do begin
        if Pos(ProgName, UpperCase(info.szExeFile)) <> 0 then
          Result := info.th32ProcessID;
      end;
    end;
    CloseHandle(hwin);
  end;
end;

function GetProcessPrio(var ProgName: string): Integer;
var //return process priority from given program name (like 'nero.exe') or -1 if not found
  hwin: Cardinal; //27.05.10 nk add
  info: TProcessEntry32;
  //  4 - Idle      IDLE_PRIORITY_CLASS
  //  8 - Normal    NORMAL_PRIORITY_CLASS
  // 13 - High      HIGH_PRIORITY_CLASS
  // 24 - RealTime  REALTIME_PRIORITY_CLASS
begin
  Result := NONE;
  ProgName := UpperCase(progName);
  hwin := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);

  if hwin > NERR_SUCCESS then begin
    info.dwSize := SizeOf(info);
    if Process32First(hwin, info) = True then begin
      while Process32Next(hwin, info) = True do begin
        if Pos(ProgName, UpperCase(info.szExeFile)) <> 0 then begin
          Result := info.pcPriClassBase;
          case Result of
            4:  ProgName := 'Idle';
            8:  ProgName := 'Normal';
            13: ProgName := 'High';
            24: ProgName := 'RealTime';
          else
            ProgName := IntToStr(Result);
          end;
        end;
      end;
    end;
    CloseHandle(hwin);
  end;
end;

function GetProcessHandle(ProgName: string; UseClass: Boolean = False): HWND;
begin //27.05.10 nk add - return the handle of the given process (top-level window) or 0 if not found (e.g. MDI form)
  if UseClass then
    Result := FindWindow(PChar(ProgName), nil)  //find by class name like 'TSimServer'
  else
    Result := FindWindow(nil, PChar(ProgName)); //find by window name like 'SimWalk Database Server'
end;

function GetProcessMemory(InPercent: Boolean = False; ProcHandle: Cardinal = 0): Int64;
// Return the size in bytes of the used process memory
// 27.11.15 nk opt - or the percental of memory used if InPercent = True
// Input:  ProcHandle - handle of the requested process (0 = own process)
// Output: None
// Return: Memory size in bytes or 0 if failed
// Remark: Is the same as the used memory shown in the Task Manager
//         Works only on Windows NT systems (WINNT, WIN2K, WINXP, WINVS)
//         Commit Charge is the total amount of memory that the memory manager
//         has committed for the requested process in bytes
var
  nMem: Int64;
  pmCtr: PPROCESS_MEMORY_COUNTERS;
begin
  Result := CLEAR;
  nMem   := SizeOf(_PROCESS_MEMORY_COUNTERS);
  GetMem(pmCtr, nMem);

  if ProcHandle = 0 then ProcHandle := GetCurrentProcess;

  try
    pmCtr^.cb := nMem;
    if GetProcessMemoryInfo(ProcHandle, pmCtr, nMem) then begin //27.11.15 nk add / opt ff
      nMem := pmCtr^.WorkingSetSize;                            //peak working set size [bytes]
      if InPercent then begin
        Result := Round(PROCENT * nMem / pmCtr^.PagefileUsage); //commit charge value [bytes]
      end else begin
        Result := nMem;
      end;
    end;
  finally
    FreeMem(pmCtr);
  end;
end;

function GetProgVers(VersType: TVersType; ProgName: string = cEMPTY): string;
var //18.12.11 nk opt
  nSize: Cardinal;
  nDummy: Cardinal;
  nVerMaj: Word;
  nVerMin: Word;
  nRelMaj: Word;
  nRelMin: Word;
  sProg: string;
  sBuild: string;
  pBuff: Pointer;
  pInfo: Pointer;
begin
  Result  := cEMPTY;
  nVerMaj := CLEAR;
  nVerMin := CLEAR;
  nRelMaj := CLEAR;
  nRelMin := CLEAR;

  if ProgName = cEMPTY then //22.01.08 nk opt ff
    sProg := Application.ExeName
  else
    sProg := ProgName;

  nSize := GetFileVersionInfoSize(PChar(sProg), nDummy);

  if nSize > 0 then begin
    GetMem(pBuff, nSize);
    try  //get version infos
      GetFileVersionInfo(PChar(sProg), 0, nSize, pBuff);
      VerQueryValue(pBuff, cBACK, pInfo, nDummy);
      nVerMaj := HiWord(PvsFixedFileInfo(pInfo)^.dwFileVersionMS);
      nVerMin := LoWord(PvsFixedFileInfo(pInfo)^.dwFileVersionMS);
      nRelMaj := HiWord(PvsFixedFileInfo(pInfo)^.dwFileVersionLS);
      nRelMin := LoWord(PvsFixedFileInfo(pInfo)^.dwFileVersionLS);
    finally
      FreeMem(pBuff);
    end;
  end;

  //28.06.09 nk add ff - replace build 0 by 'Beta'
  if nRelMin = BETA_BUILD then
    sBuild := BETA_TEXT
  else
    sBuild := IntToStr(nRelMin);

  case VersType of
    vtVerMaj: Result := IntToStr(nVerMaj);
    vtVerMin: Result := IntToStr(nVerMin);
    vtRelMaj: Result := IntToStr(nRelMaj);
    vtRelMin: Result := IntToStr(nRelMin);
    vtBuild:  Result := IntToStr(nRelMin);  //14.04.08 nk opt ff
    vtVers:   Result := Format(FORM_VERS,   [nVerMaj, nVerMin]);
    vtShort:  Result := Format(FORM_PSHORT, [nVerMaj, nVerMin, nRelMaj]);
    vtLong:   Result := Format(FORM_PLONG,  [nVerMaj, nVerMin, nRelMaj, sBuild]); //28.06.09 nk old=nRelMin
    vtName:   Result := Format(FORM_PNAME,  [VERS, nVerMaj, nVerMin]);
    vtPack:   Result := Format(FORM_PPACK,  [BUILD, nRelMin]);
    vtDesc:   Result := Application.Title;  //16.09.09 nk add
    vtFull:   Result := Format(FORM_VFULL,  [nVerMaj, nVerMin, nRelMaj, cEMPTY, nRelMin]); //18.12.11 nk add
  end;
end;

function GetAppInfo(AppInfo: TAppInfo): string;
var //xe//16.04.08 nk opt ff
  info: Longword;
  pnum: Longword;
  pver: PChar;
  sapp: string;
  lang: string;

  function GetInfoValue(const sInfo: string): string;
  var
    pval: Pointer;
    nlen: Longword;
  begin
    if VerQueryValue(pver, PChar(lang + sInfo),
      Pointer(pval), nlen) then begin
      Result := string(PChar(pval)); //xe//AnsiString
    end else begin
      Result := cEMPTY;
    end;
  end;

  function GetLangStr: string;
  var
    tptr: Pointer;
    size: Longword;
  begin
    if VerQueryValue(pver, VER_VARFILE, tptr, size) then begin
      Result := VER_STRING + IntToHex(LoWord(LongInt(tptr^)), 4) +
                IntToHex(HiWord(LongInt(tptr^)), 4) + VER_SLASH;
    end else begin
      Result := cEMPTY;
    end;
  end;

begin      
  Result := cEMPTY;
  sapp   := Application.ExeName;
  pnum   := Ord(AppInfo) + 1;  //21.05.08 nk opt ff

  case pnum of
    11: Result := Application.Title;                   //ProjectName
    12: Result := ExtractFileName(sapp);               //FileName
    13: Result := StringReplace(ExtractFileName(sapp), //ProgName
                  ExtractFileExt(sapp), cEMPTY, [rfIgnoreCase]);
    14: Result := ExtractFilePath(sapp);
  else
    info := GetFileVersionInfoSize(PChar(sapp), pnum);

    if info > 0 then begin
      pver := AllocMem(info);
      try
        GetFileVersionInfo(PChar(sapp), 0, info, pver);
        lang   := GetLangStr;
        Result := GetInfoValue(InfoStrings[Ord(AppInfo) + 1]);
      finally
        FreeMem(pver);
      end;
    end;
  end;
end;

function GetSystemVers(VersType: TVersType): string;
var //28.11.15 nk opt - improved version with detection for Win2008, Win7,
  ptyp: Byte;        // Win2008R2, Win8, Win2012, Win10, Win2016
  i: Integer;
  vmaj: Integer;
  vmin: Integer;
  bnum: Integer;
  pnum: Integer; //13.09.13 nk add (service pack number like 2)
  otyp: string;
  pack: string;
  desc: string;
  via: TOsVersionInfoA;
  viw: TOsVersionInfoEx;
begin
  Result := cEMPTY;
  otyp   := cEMPTY;
  pack   := cEMPTY;
  desc   := cEMPTY;

  try //calling GetVersionExW - if that fails try using GetVersionExA
    viw.wProductType := WORKSTATION;

    if GetVersion and $80000000 = 0 then begin
      ZeroMemory(@viw, SizeOf(viw));
      viw.dwOSVersionInfoSize := SizeOf(TOsVersionInfoEx);

      if not GetVersionExW(POsVersionInfo(@viw)^) then begin
        viw.dwOSVersionInfoSize := SizeOf(TOsVersionInfow);
        GetVersionExW(POsVersionInfo(@viw)^);
      end;

      Move(viw, via, SizeOf(via));

      for i := Low(via.szCSDVersion) to high(via.szCSDVersion) do
        via.szCSDVersion[i] := AnsiChar(viw.szCSDVersion[i]);
    end else begin
      ZeroMemory(@via, SizeOf(via));
      via.dwOSVersionInfoSize := SizeOf(via);
      GetVersionExA(via);
    end;

    vmaj := via.dwMajorVersion;
    vmin := via.dwMinorVersion;
    bnum := via.dwBuildNumber;
    ptyp := viw.wProductType;
    pack := string(via.szCSDVersion);     //like 'Service Pack 3'
    pnum := StrToIntDef(StrNum(pack), 0); //13.09.13 nk add - service pack number like 3 (0 = none)
  except
    Exit;
  end;

// Operating system otyp    Vers.  vmaj   vmin  ptyp
// -----------------------------------------------------------------------------
// Windows 10               10.0   10     0     WORKSTATION
// Windows Server 2016      10.0   10     0     SERVER
// Windows 8.1               6.3    6     3     WORKSTATION
// Windows Server 2012 R2    6.3    6     3     SERVER
// Windows 8                 6.2    6     2     WORKSTATION
// Windows Server 2012       6.2    6     2     SERVER
// Windows 7                 6.1    6     1     ORKSTATION
// Windows Server 2008 R2    6.1    6     1     SERVER
// Windows Server 2008       6.0    6     0     SERVER
// Windows Vista             6.0    6     0     WORKSTATION
// Windows Server 2003 R2    5.2    5     2     GetSystemMetrics(SM_SERVERR2) != 0
// Windows Server 2003       5.2    5     2     GetSystemMetrics(SM_SERVERR2) == 0
// Windows XP                5.1    5     1     Not applicable
// Windows 2000              5.0    5     0     Not applicable

  case via.dwPlatformId of
    VER_PLATFORM_WIN32_NT:  //Windows NT/2K/XP/Vista/2003/2008/Win7/Win8/WinS8/Win10/WinS16
      case vmaj of
        0..3 : otyp := WIN32;                   //Windows 32 (old NT)
        4    : otyp := WINNT;                   //Windows NT 4.0
        5    : case vmin of
                 0 : otyp := WIN2K;             //Windows 2000
                 1 : otyp := WINXP;             //Windows XP
                 else begin
                   if ptyp = WORKSTATION then
                     otyp := WINXP              //Windows XP
                   else
                     otyp := WIN03;             //Windows Server 2003 / 2003 R2
                 end;
               end;
        6    : case vmin of
                 0 : if ptyp = WORKSTATION then
                       otyp := WINVS            //Windows Vista
                     else
                       otyp := WIN08;           //Windows Server 2008
                 1 : if ptyp = WORKSTATION then
                       otyp := WIN_7            //Windows 7
                     else
                       otyp := W08R2;           //Windows Server 2008 R2
                 2 : if ptyp = WORKSTATION then //04.02.12 nk add ff
                       otyp := WIN_8            //Windows 8
                     else
                       otyp := WIN12;           //13.09.13 nk opt Windows Server 2012 / old=WIN_8S Windows Server 8
                 3 : if ptyp = WORKSTATION then //20.12.14 nk add ff
                       otyp := WIN_81           //Windows 8.1
                     else
                       otyp := WIN12R2;         //Windows Server 2012 R2
                 else
                   otyp := WINNT;               //Windows NT (new version)
               end;
        10   : case vmin of                     //28.11.15 nk add ff
                 0 : if ptyp = WORKSTATION then
                       otyp := WIN_10           //Windows 10
                     else
                       otyp := WINS16;          //Windows Server 2016
               end;
        else
          otyp := WINNT;                        //Windows NT (new version)
      end;

    VER_PLATFORM_WIN32_WINDOWS: //Windows 95/98/ME
      case vmaj of
        0..3 : otyp := WIN16;
        4    : case vmin of
                 00..09 : case bnum of         //Windows 95/A/B/C
                            0..950    : otyp := WIN95;
                            951..1000 : otyp := WIN95 + 'A';
                            1001..1200: otyp := WIN95 + 'B';
                          else
                            otyp := WIN95 + 'C';
                          end;
                 10     : if bnum > 2700 then
                            otyp := WINME      //Windows ME
                          else if bnum > 2000 then
                            otyp := WINSE      //Windows SE
                          else
                            otyp := WIN98;     //Windows 98
                 11..90 : otyp := WINME;       //Windows ME
               else
                 otyp := WIN32;                //Windows 32
               end;
        else
          otyp := WIN32;                       //Windows 32
      end;

    VER_PLATFORM_WIN32s:  //Windows 3.x
      otyp := WIN3S;
  end;

  try
    if GetSystemMetrics(SM_SERVERR2) <> 0 then desc := 'R2';
    if GetSystemMetrics(SM_TABLEPC)  <> 0 then desc := 'Tablet PC';
    if GetSystemMetrics(SM_STARTER)  <> 0 then desc := 'Starter';
    if GetSystemMetrics(SM_MEDIA)    <> 0 then desc := 'Media Center';
  except
    desc := cEMPTY;
  end;

  case VersType of
    vtVerMaj: Result := IntToStr(vmaj);
    vtVerMin: Result := IntToStr(vmin);
    vtRelMaj: Result := IntToStr(bnum);
    vtSP:     Result := IntToStr(pnum); //13.09.13 nk add - service pack number
    vtRelMin: Result := pack;
    vtVers:   Result := Format(FORM_VERS,   [vmaj, vmin]);
    vtBuild:  Result := Format(FORM_SBUILD, [vmaj, vmin, bnum]);
    vtShort:  Result := Format(FORM_SSHORT, [otyp, vmaj, vmin]);
    vtLong:   Result := Format(FORM_SLONG,  [otyp, vmaj, vmin, bnum]);
    vtName:   Result := otyp;
    vtPack:   Result := Format(FORM_SPACK,  [otyp, pack]);
    vtFull:   Result := Format(FORM_VFULL,  [vmaj, vmin, bnum, pack, bnum]); //23.11.10 nk add
    vtDesc:   Result := desc;
  end;
end;

function GetWebbrowserMode(AppName: string = cEMPTY): Integer;
var //28.11.15 nk add - get WebBrowser IE compatibility version
  val: Integer;
  reg: TRegistry;
begin
  Result := 6;
  val    := 0;

  if AppName = cEMPTY then
    AppName := ExtractFileName(Application.ExeName);

  reg := TRegistry.Create(KEY_READ);

  with reg do begin
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REG_IEM_KEY, False) then begin
      if ValueExists(AppName) then
        val := ReadInteger(AppName);
      CloseKey;
    end;
    Free;
  end;

  case val of
    7000..7999:   Result := 7;
    8000..8999:   Result := 8;
    9000..9999:   Result := 9;
    10000..10999: Result := 10;
    11000..11999: Result := 11;
  end;
end;

procedure SetWebbrowserMode(Mode: TIEMode; AppName: string = cEMPTY);
var //28.11.15 nk add - set WebBrowser IE compatibility version
  val: Integer;
  reg: TRegistry;
begin
  if AppName = cEMPTY then
    AppName := ExtractFileName(Application.ExeName);

  case Mode of
    iemIE7 : val := $1B58;
    iemIE8 : val := $1F40;
    iemIE9 : val := $2328;
    iemIE10: val := $2710;
    iemIE11: val := $2AF8;
  else
    val := $270F; //default IE9 quirk mode
  end;

  reg := TRegistry.Create(KEY_READ or KEY_WRITE);

  with reg do begin
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REG_IEM_KEY, True) then begin
      WriteInteger(AppName, val);
      CloseKey;
    end;
    Free;
  end;
end;

function GetDirectXVers: string;
var //04.01.10 nk opt - return the version of DirextX like '9.0 (4.9.0)'
  min, maj: Byte;
  fver: string;
  iver: array [0..1] of Cardinal;
  reg: TRegistry;  //read only - else needs admin privilege!
begin
  Result := cEMPTY;
  reg    := TRegistry.Create(KEY_READ);

  with reg do begin
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey(REG_DX_KEY, False) then begin
      if ValueExists(REG_VERSION) then begin
        ReadBinaryData(REG_INSTVERS, iver, SizeOf(iver));
        maj := HiByte(HiWord((iver[0])));
        min := HiByte(HiWord((iver[1])));
        Result := IntToStr(maj) + cDOT + IntToStr(min);
      end;

      if ValueExists(REG_VERSION) then
        fver := ReadString(REG_VERSION);

      if fver <> cEMPTY then
        Result := Result + cSPACE + cLPARENT + fver + cRPARENT;

      CloseKey;
    end;
    Free;
  end;
end;

function GetADOVers: string;
var //30.11.10 nk opt
  ado: OLEVariant;
begin
  CoInitialize(nil);

  try
    ado := CreateOleObject(ADO_CONNECT);
    Result := ado.Version;
    ado := null;
  except
    Result := cEMPTY;
  end;
end; 

function GetEnvVar(EnvName: string): string;
//23.04.12 nk opt - Return the value of the requested environment variable (not case sensitive)
var //see also Get/SetEnvVariable in URegistry
  val: Word;
  buf: string;
begin
  Result := cEMPTY;
  SetLength(buf, MAXBUFF); //23.04.12 nk old=MAXBYTE
  val := GetEnvironmentVariable(PChar(EnvName), @buf[1], MAXBUFF);

  if val <> 0 then begin
    SetLength(buf, val);
    Result := buf;
  end;
end;

function GetWindowMetric(Metric: Byte = 0): Integer;
begin //V5//get system metrics to compensate different window dimensions
  TOPBORDER      := GetSystemMetrics(SM_CYMIN) - GetSystemMetrics(SM_CYFRAME) + 2;
  SIDEBORDER     := GetSystemMetrics(SM_CXFRAME) + 2;
  CAPTIONHEIGHT  := GetSystemMetrics(SM_CYCAPTION); //04.02.16 nk add
  SCROLLBARWIDTH := GetSystemMetrics(SM_CXVSCROLL) + 4;
  SCREENWIDTH    := GetSystemMetrics(SM_CXSCREEN);
  SCREENHEIGHT   := GetSystemMetrics(SM_CYSCREEN);
  SCREENCENTER   := SCREENWIDTH  div 2;      //26.03.08 nk add ff
  SCREENMIDDLE   := SCREENHEIGHT div 2;

  //21.01.16 nk add/opt ff - default application form dimension and position
  VIEWWIDTH      := 3 * SCREENWIDTH  div 4;  //31.03.16 nk old=div 5
  VIEWHEIGHT     := 3 * SCREENHEIGHT div 5;  //31.03.16 nk old=div 6
  FORMWIDTH      := 7 * SCREENWIDTH  div 8;  //28.01.08 nk old=6
  FORMHEIGHT     := 6 * SCREENHEIGHT div 8;
  FORMLEFT       := SCREENWIDTH  div 16;
  FORMTOP        := SCREENHEIGHT div 16;

  if (Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion = 6) then
    BORDERCORR := 4; //Vista border correction for child windows

  if (Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion = 5) and (Win32MinorVersion = 0) then
    TABLECORR := 2;  //18.07.09 nk add W2K StringGrid ClientWidth correction

  case Metric of
    1:  Result := SCREENHEIGHT;
    2:  Result := TOPBORDER;
    3:  Result := BORDERCORR;
    4:  Result := SIDEBORDER;
    5:  Result := SCROLLBARWIDTH;
    6:  Result := FORMWIDTH;    //11.01.08 nk add ff
    7:  Result := FORMHEIGHT;
    8:  Result := FORMLEFT;
    9:  Result := FORMTOP;
    10: Result := SCREENCENTER; //26.03.08 nk add ff
    11: Result := SCREENMIDDLE;
  else
       Result := SCREENWIDTH;
  end;
end;

function GetTopWindow(Win: HWND): Boolean;
begin
  Result := ((GetWindowLong(Win, GWL_EXSTYLE) and WS_EX_TOPMOST) <> 0);
end;

function GetFocusWindow: Cardinal;
var //return Thread ID of the focussed window (not the same as top most)
  win: Cardinal;
  tid: Cardinal;
begin
  win := GetForegroundWindow;
  tid := GetWindowThreadProcessID(win, nil);

  if AttachThreadInput(GetCurrentThreadID, tid, True) then begin
    Result := GetFocus;
    AttachThreadInput(GetCurrentThreadID, tid, False);
  end else begin
    Result := GetFocus;
  end;
end;

function GetXpStyle: Boolean;
type //14.04.08 nk opt - returns True if the user uses XP style
  TIsThemeActive = function: Bool; stdcall;
var 
  isThemeActive: TIsThemeActive;
  hUx: HINST;
begin 
  Result := False;

  if (Win32Platform = VER_PLATFORM_WIN32_NT) and
     (Win32MajorVersion >= 5) then //25.10.07 nk add Vista
  begin 
    hUx := LoadLibrary(API_UXTHEME);
    if hUx <> NERR_SUCCESS then begin
      try
        isThemeActive := GetProcAddress(hUx, THEME_ISACT);
        Result := isThemeActive;
      finally 
        if hUx > NERR_SUCCESS then FreeLibrary(hUx);
      end; 
    end; 
  end; 
end;

function GetServiceStatus(Machine, Service: PChar): DWORD;
// Machine: Specifies the name of the target computer (UNC path or nil if local)
// Service: Specifies the name of the service to open
//          Do not use the service display name (as displayed in the services
//          control panel applet) You must use the real service name, as
//          referenced in the registry under
//          HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\
// Usage:   if GetServiceStatus(nil, 'Eventlog') = SERVICE_RUNNING then...
// Return Values (get text from InfoService array):
//  0 = Service not installed
//  1 = SERVICE_STOPPED
//  2 = SERVICE_START_PENDING
//  3 = SERVICE_STOP_PENDING
//  4 = SERVICE_RUNNING
//  5 = SERVICE_CONTINUE_PENDING
//  6 = SERVICE_PAUSE_PENDING
//  7 = SERVICE_PAUSED
//  8 = SERVICE_NOP (defined in USystem)
var
  scm, svc: SC_Handle;
  stat: TServiceStatus;
  ret: DWORD;
begin
  ret := NERR_SUCCESS;
  scm := OpenSCManager(Machine, nil, SC_MANAGER_CONNECT);

  if scm > NERR_SUCCESS then begin
    svc := OpenService(scm, Service, SERVICE_QUERY_STATUS);
    if svc > NERR_SUCCESS then begin   //service is installed
      if (QueryServiceStatus(svc, stat)) then
        ret := stat.dwCurrentState;
      CloseServiceHandle(svc);
    end;
    CloseServiceHandle(scm);
  end;

  Result := Limit(ret, NERR_SUCCESS, SERVICE_NOP); //21.11.09 nk opt
end;

function DoStartService(Machine, Service: string): Boolean;
// Machine: Specifies the name of the target computer (UNC path or cEMPTY if local)
// Service: Specifies the name of the service to open
var
  scm, svc: SC_Handle;
  stat: TServiceStatus;
  cp: DWORD;
  arg: PChar;
begin
  scm := OpenSCManager(PChar(Machine), nil, SC_MANAGER_CONNECT);

  if scm > NERR_SUCCESS then begin
    svc := OpenService(scm, PChar(Service), SERVICE_START or SERVICE_QUERY_STATUS or SC_MANAGER_ALL_ACCESS);

    if svc > NERR_SUCCESS then begin
      if StartService(svc, 0, arg) then begin
        if QueryServiceStatus(svc, stat) then begin
          while stat.dwCurrentState <> SERVICE_RUNNING do begin
            cp := stat.dwCheckPoint;
            sleep(stat.dwWaitHint);
            if not QueryServiceStatus(svc, stat) then Break;
            if stat.dwCheckPoint < cp then Break;
          end;
        end;
      end;
      CloseServiceHandle(svc);
    end;
    CloseServiceHandle(scm);
  end;

  Result := (stat.dwCurrentState = SERVICE_RUNNING);
end;

function DoStopService(Machine, Service: string): Boolean;
// Machine: Specifies the name of the target computer (UNC path or cEMPTY if local)
// Service: Specifies the name of the service to open
var
  scm, svc: SC_Handle;
  stat: TServiceStatus;
  cp: DWORD;
begin
  scm := OpenSCManager(PChar(Machine), nil, SC_MANAGER_CONNECT);

  if scm > NERR_SUCCESS then begin
    svc := OpenService(scm, PChar(Service), SERVICE_STOP or SERVICE_QUERY_STATUS);

    if svc > NERR_SUCCESS then begin
      if ControlService(svc, SERVICE_CONTROL_STOP, stat) then begin
        if QueryServiceStatus(svc, stat) then begin
          while stat.dwCurrentState <> SERVICE_STOPPED do begin
            cp := stat.dwCheckPoint;
            sleep(stat.dwWaitHint);
            if not QueryServiceStatus(svc, stat) then Break;
            if stat.dwCheckPoint < cp then Break;
          end;
        end;
      end;
      CloseServiceHandle(svc);
    end;
    CloseServiceHandle(scm);
  end;

  Result := (stat.dwCurrentState = SERVICE_STOPPED);
end;

function GetPowerStatus(out Remain: Integer): Boolean;
var //Return True if running on Mains, False if on battery
  spStatus: TSystemPowerStatus; // and the remain accu power [%]
begin
  GetSystemPowerStatus(spStatus);

  if Boolean(spStatus.ACLineStatus) then begin
    Remain := PROCENT;
    Result := True;
  end else begin
    Remain := spStatus.BatteryLifePercent;
    Result := False;
  end;
end;

function StrToIntRange(Input: string; Lmin, Lmax: Integer): Integer; //V5//18.11.16 nk add
var //V5//18.11.16 nk add
  lval: Integer;
begin
  lval   := StrToIntDef(Input, CLEAR);
  Result := Max(Lmin, Min(Lmax, lval));
end;

function StrToClock(Seconds: Integer): TDateTime;
var //20.12.14 nk add
  days, time: Integer;
begin
  days   := Seconds div SEC_DAY;
  time   := Seconds mod SEC_DAY;
  Result := StrToTime(GetClock(time)) + days;
end;

function GetClock(Seconds: Integer; DoLimit: Boolean = False): string;
var //19.02.14 nk opt for XE3 - converts given Seconds (per day) in a clock format like 'hh:mm:ss'
  h, m, s: Word;   //Remark: Clock format is LongTimeFormat with TimeSeparator
  ftime: string;   //DoLimit: True=Hours 00..23 / False= Hours 00..99
  time: TDateTime; //08.05.12 nk opt/fix regard locale time separator
begin              //return 'hh:mm:ss' (CH-DE) or 'hh.mm.ss' (IT-IT)
  if DoLimit then
    h := (Seconds mod SEC_DAY) div SEC_HOUR       //00..23
  else
    h := (Seconds mod SEC_DIGIT) div SEC_HOUR;    //00..99

  m := ((Seconds mod SEC_DAY) mod SEC_HOUR) div SEC_MIN;
  s := ((Seconds mod SEC_DAY) mod SEC_HOUR) mod SEC_MIN;

  if DoLimit then begin                           //23:59:59
    time   := EncodeTime(h, m, s, 0);
    Result := TimeToStr(time);
  end else begin //08.05.12 nk add/opt ff / old=FORM_CLOCK_TIME
    ftime  := FORM_LOCAL_TIME;
    ftime  := StringReplace(ftime, cCARET, FormatSettings.TimeSeparator, [rfReplaceAll]); //xe3//
    Result := Format(ftime, [h, m, s]);           //99:59:59
  end;
end;

function ClockToMins(Clock: string): Word;
var //V5//14.08.15 nk add - convert Clock (hh:mm) into minutes
  m, h: Integer;
  tmp: string;
begin
  Result := CLEAR;
  if Length(Clock) <> 5 then Exit;

  tmp := LeftStr(Clock, 2);
  h   := StrToIntDef(tmp, 0);
  tmp := RightStr(Clock, 2);
  m   := StrToIntDef(tmp, 0);
  Result := h * MIN_HOUR + m;
end;

function MinsToClock(Minutes: Word): string;
var //V5//14.08.15 nk add - convert Minutes into string (hh:mm)
  m, h: Integer;
begin
  if Minutes > MIN_DAY then Minutes := MIN_DAY;
  m := Minutes mod MIN_HOUR;
  h := Minutes div MIN_HOUR;
  Result := Format(FORM_ALARM, [h, m]);
  Result := StringReplace(Result, TIME_SEP, FormatSettings.TimeSeparator, [rfReplaceAll]);
end;

function GetTimeZone: string;
var //30.11.10 nk opt - return Timezone like 'Central Time (UTC-8)'
  bias: Integer;
  sign: string;
  tzone: TTimeZoneInformation;
begin
  GetTimeZoneInformation(tzone);
  bias := tzone.Bias div -MIN_HOUR;
  sign := Iff(bias < 0, '-', '+');

  Result := Format(FORM_TIMEZONE, [tzone.StandardName, sign, Abs(bias)]);  //30.11.10 nk opt
//if bias < 0 then
//  Result := tzone.StandardName + ' (UTC-' + IntToStr(bias) + ')'
//else
//  Result := tzone.StandardName + ' (UTC+' + IntToStr(bias) + ')';
end;

function GetValidTime(TimeValue, TimeFormat: string; var Seconds: Integer; DoLimit: Boolean = False): string;
var //19.02.14 nk opt for XE3 - validate, correct, and return the TimeValue string in the requested TimeFormat
  i, h, m, s: Word;    //and return total number of seconds
  fsep, vsep: Char;    //Remark: The time separator of TimeValue is returnd
  val, typ, time: string; //11.10.09 nk add DoLimit: True=Hours 00..23 / False=Hours 00..99

  procedure SetTimeVal(Tval, Ttyp: string);
  begin
    if (Tval <> cEMPTY) and (Ttyp <> cEMPTY) then begin
      Ttyp := LowerCase(Ttyp);

      if Pos(FORM_HOUR, Ttyp) > 0 then begin
        h := StrToIntDef(Tval, CLEAR); //hours
        if DoLimit then                //11.10.09 nk opt ff
          h := Min(h, MAX_HOUR)        //00..23
        else
          h := Min(h, MAX_DIGIT);      //00..99
        time := StringReplace(time, FORM_HOUR, Format(FORM_DIGIT, [h]), [rfIgnoreCase]);
      end;

      if Pos(FORM_MIN, Ttyp) > 0 then begin
        m := StrToIntDef(Tval, CLEAR);  //minutes
        m := Min(m, MAX_MIN);
        time := StringReplace(time, FORM_MIN, Format(FORM_DIGIT, [m]), [rfIgnoreCase]);
      end;

      if Pos(FORM_SEC, Ttyp) > 0 then begin
        s := StrToIntDef(Tval, CLEAR);  //seconds
        s := Min(s, MAX_SEC);
        time := StringReplace(time, FORM_SEC, Format(FORM_DIGIT, [s]), [rfIgnoreCase]);
      end;
    end;
  end;

begin
  h := CLEAR;
  m := CLEAR;
  s := CLEAR;
  Seconds := CLEAR;
  Result  := cEMPTY;

  TimeValue  := Trim(TimeValue);
  TimeFormat := Trim(TimeFormat);

  time := LowerCase(TimeFormat);
  fsep := FormatSettings.TimeSeparator; //xe3//
  vsep := FormatSettings.TimeSeparator; //xe3//

  for i := 1 to Length(TimeValue) - 1 do begin
    if not CharInSet(TimeValue[i], SMALL_NUMBS) then begin //xe//
      vsep := TimeValue[i];  //get time value separator
      Break;
    end;
  end;

  for i := 1 to Length(TimeFormat) - 1 do begin
    if not CharInSet(TimeFormat[i], SMALL_NUMBS) then begin //xe//
      fsep := TimeFormat[i];  //get time format separator
      Break;
    end;
  end;

  val := StrSplit(TimeValue,  vsep, 0);   //1st time part
  typ := StrSplit(TimeFormat, fsep, 0);
  SetTimeVal(val, typ);

  val := StrSplit(TimeValue,  vsep, 1);   //2nd time part
  typ := StrSplit(TimeFormat, fsep, 1);
  SetTimeVal(val, typ);

  val := StrSplit(TimeValue,  vsep, 2);   //3rd time part
  typ := StrSplit(TimeFormat, fsep, 2);
  SetTimeVal(val, typ);

  Seconds := h * SEC_HOUR + m * SEC_MIN + s;
  Result  := StringReplace(time, fsep, vsep, [rfReplaceAll]);
end;

procedure HideMinButton(Window: TForm);
var  //hide the minimize button of the window
  nSet: Longword;
begin
  nSet := GetWindowLong(Window.Handle, GWL_STYLE);
  nSet := nSet and not WS_MINIMIZEBOX;
  SetWindowLong(Window.Handle, GWL_STYLE, nSet);
end;

procedure HideMaxButton(Window: TForm);
var  //hide the maximize button of the window
  nSet: Longword;
begin
  nSet := GetWindowLong(Window.Handle, GWL_STYLE);
  nSet := nSet and not WS_MAXIMIZEBOX;
  SetWindowLong(Window.Handle, GWL_STYLE, nSet);
end;

procedure HideCloseButton(Window: TForm);
var  //hide the close button of the window
  nSet: Longword;
begin
  nSet := GetSystemMenu(Window.Handle, False);

  if nSet <> NERR_SUCCESS then
    DeleteMenu(nSet, SC_CLOSE, MF_BYCOMMAND);
end;

procedure DisableCloseButton(Window: TForm);
begin //disable (grayed) the close button of the window (Alt+F4 still works)
  EnableMenuItem(GetSystemMenu(Window.Handle, LongBool(False)),
    SC_CLOSE, MF_BYCOMMAND or MF_GRAYED);
end;

procedure EnableCloseButton(Window: TForm);
begin //enable the close button of the window
  EnableMenuItem(GetSystemMenu(Window.Handle, LongBool(False)),
    SC_CLOSE, MF_BYCOMMAND and not MF_GRAYED);
end;

procedure ShowDesktopIcons(Mode: Boolean);
begin  //show (True) or hide (False) all Icons of the Desktop
  if Mode then                
    ShowWindow(FindWindow(nil, DESKTOP_APP), SW_SHOW)
  else
    ShowWindow(FindWindow(nil, DESKTOP_APP), SW_HIDE);
end;

procedure ShowTaskBar(Mode: Boolean);
var  //show (True) or hide (False) the Task Bar completely
  win: HWND;
begin
  win := FindWindow(SHELL_TRAY, nil);

  if win <> NERR_SUCCESS then begin
    if Mode then begin
      EnableWindow(win, True);  //show taskbar
      ShowWindow(win, SW_SHOW);
    end else begin
      EnableWindow(win, False); //hide taskbar
      ShowWindow(win, SW_HIDE);
    end;
  end;
end;

procedure ShowTitleBar(Form: TForm; Mode: Boolean);
var //21.01.13 nk add - Mode: True = Show / False = Hide title bar of Form
  style: Longint;
begin
  if Form.BorderStyle = bsNone then Exit;

  style := GetWindowLong(Form.Handle, GWL_STYLE);

  if Mode then begin //show title bar
    if (style and WS_CAPTION) <> WS_CAPTION then begin
      case Form.BorderStyle of
        bsSingle,
        bsSizeable: SetWindowLong(Form.Handle, GWL_STYLE, style or WS_CAPTION or WS_BORDER);
        bsDialog:   SetWindowLong(Form.Handle, GWL_STYLE, style or WS_CAPTION or DS_MODALFRAME or WS_DLGFRAME);
      end;
      Form.Height := Form.Height + GetSystemMetrics(SM_CYCAPTION);
    end;
  end else begin    //hide tilte bar
    if (style and WS_CAPTION) = WS_CAPTION then begin
      case Form.BorderStyle of
        bsSingle,
        bsSizeable: SetWindowLong(Form.Handle, GWL_STYLE, style and (not (WS_CAPTION)) or WS_BORDER);
        bsDialog:   SetWindowLong(Form.Handle, GWL_STYLE, style and (not (WS_CAPTION)) or DS_MODALFRAME or WS_DLGFRAME);
      end;
      Form.Height := Form.Height - GetSystemMetrics(SM_CYCAPTION);
    end;
  end;

  Form.Refresh;
end;

procedure ShowStartButton(Mode: Boolean);
var //enable (True) or disable (False) the Start Button in the Task Bar
  win: HWND;
begin
  win := FindWindow(SHELL_TRAY, nil);

  if win <> NERR_SUCCESS then
    EnableWindow(FindWindowEx(win, 0, CLASS_BUTTON, nil), Mode);
end;

procedure ShowScreen(Mode: Boolean);
begin
  if Mode = False then //turn monitor screen OFF
    SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MONITORPOWER, 2)
  else                 //turn monitor screen ON
    SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MONITORPOWER, -1);
end;

function SetScreen(Width, Height, Freq: Cardinal): Boolean;
var //24.08.13 nk opt
  devmode: TDeviceMode;
begin
  Result := EnumDisplaySettings(nil, 0, devmode);
  if Result then begin
    devmode.dmFields           := DM_PELSWIDTH or DM_PELSHEIGHT or DM_DISPLAYFREQUENCY;
    devmode.dmPelsWidth        := Width;
    devmode.dmPelsHeight       := Height;
    devmode.dmDisplayFrequency := Freq;
    Result := ChangeDisplaySettings(devmode, CDS_UPDATEREGISTRY) = DISP_CHANGE_SUCCESSFUL;
  end;
end;

procedure ClipMouseCursor(Area: TRect);
//Area in absolute screen coordinates (0/0 is Left/Top corner)
//from 0/0 to Screen.Width/Screen.Height
begin
  with Area do begin
    if (Left >= 0) and (Top >= 0) and (Right > Left) and (Bottom > Top) then
      ClipCursor(@Area)
    else
      ClipCursor(nil);
  end;
end;

procedure SwapMouseButtons(Mode: Boolean);
begin
  if Mode then begin
    SystemParametersInfo(SPI_SETMOUSEBUTTONSWAP, 1, nil, 0)
  end else begin
    SystemParametersInfo(SPI_SETMOUSEBUTTONSWAP, 0, nil, 0);
  end;
end;

procedure SetBackGround(BitMap: string);
begin  //load new desktop background bitmap from file
  SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(BitMap), SPIF_SENDCHANGE OR SPIF_UPDATEINIFILE);
end;

procedure SetKeyboardState(Key: Byte; State: Boolean);
var //Key: VK_SCROLL, VK_CAPITAL, VK_NUMLOCK
  kState: TKeyboardState;
begin
  GetKeyboardState(kState);
  if Boolean(kState[Key]) <> State then begin
    Keybd_Event(Key, MapVirtualKey(Key, 0),
                KEYEVENTF_EXTENDEDKEY, 0);
    Keybd_Event(Key, MapVirtualKey(Key, 0),
                KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
  end;
end;

function SetFormIcon(FormHandle: HWND; IconName: string): Integer;
var //15.12.16 nk opt - set form icon (16x16 pixel) on upper/left corner of caption bar
  hicon: Integer; //CAUTION: Icon names should have names that appear after MAINICON in the alphabet
begin
  Result := NERR_SUCCESS;
  hicon  := LoadIcon(hInstance, PChar(IconName));

  if hicon > NERR_SUCCESS then begin
    SendMessage(FormHandle, WM_SETICON, ICON_SMALL, hicon);
    Result := hicon;
  end;
end;

procedure ShowFormContents(Mode: Boolean);
begin //True=show contents while moving
  SystemParametersInfo(SPI_SETDRAGFULLWINDOWS, Ord(Mode), nil, 0);
end;

function PreventFormChange(Msg: TwmSysCommand): Boolean;
begin //prevent the moving and sizing of a Form - use it like shown below:
// procedure FormChange(var Msg: TwmSysCommand); message WM_SYSCOMMAND;
// procedure TForm.FormChange(var Msg: TwmSysCommand);
// begin
//   if PreventFormChange(Msg) then Exit;
//   inherited;
// end;
  Result := False;
  if (((Msg.CmdType and CMD_MASK) = SC_MOVE) or
      ((Msg.CmdType and CMD_MASK) = SC_SIZE) or
      ((Msg.CmdType and CMD_MASK) = SC_RESTORE)) then begin
    Msg.Result := CLEAR;
    Result := True;
  end;
end;

function PreventFormMove(Msg: TwmSysCommand): Boolean;
begin //prevent the moving of a Form - use it like shown below:
// procedure FormMove(var Msg: TwmSysCommand); message WM_SYSCOMMAND;
// procedure TForm.FormMove(var Msg: TwmSysCommand);
// begin
//   if PreventFormMove(Msg) then Exit;
//   inherited;
// end;
  Result := False;
  if ((Msg.CmdType and CMD_MASK) = SC_MOVE) then begin
    Msg.Result := CLEAR;
    Result := True; 
  end;
end;

function PreventFormSize(Msg: TwmSysCommand): Boolean;
begin //prevent the sizing of a Form - use it like shown below:
// procedure FormSize(var Msg: TwmSysCommand); message WM_SYSCOMMAND;
// procedure TForm.FormSize(var Msg: TwmSysCommand);
// begin
//   if PreventFormSize(Msg) then Exit;
//   inherited;
// end;
  Result := False;
  if (((Msg.CmdType and CMD_MASK) = SC_SIZE) or
      ((Msg.CmdType and CMD_MASK) = SC_RESTORE)) then begin
    Msg.Result := CLEAR;
    Result := True;
  end;
end;

procedure LimitFormMove(Area: TRect; Msg: TwmMoving);
begin // limit the movement of a MDI child on the parent form
  if Msg.Lprect^.Left < Area.Left then
    OffsetRect(Msg.Lprect^, Area.Left - Msg.Lprect^.Left, 0);
  if Msg.lprect^.Top < Area.Top then
    OffsetRect(Msg.Lprect^, 0, Area.Top - Msg.Lprect^.Top);
  if Msg.lprect^.Right > Area.Right then
    OffsetRect(Msg.Lprect^, Area.Right - Msg.Lprect^.Right, 0);
  if Msg.lprect^.Bottom > Area.Bottom then
    OffsetRect(Msg.Lprect^, 0, Area.Bottom - Msg.Lprect^.Bottom);
end;

procedure RestartApplication(Param: string = cEMPTY);
var //V5//08.02.17 nk opt - restart the own application
  app, par: PChar;
begin
  //15.04.08 nk add - remove mutex handle
  if MutexHandle <> NERR_SUCCESS then CloseHandle(MutexHandle);

  par      := PChar(Param); //V5//add ff Param
  app      := PChar(Application.ExeName);
  ExecCode := ShellExecute(Application.Handle, SHELL_EXEC, app, par, nil, SW_SHOWNORMAL);

  Application.Terminate; //close calling application
end;

procedure PerformApplication(ProgName: string; Comm: TFormComm; UseClass: Boolean = False);
//22.01.13 nk opt/add UseClass - perform a command on the given application (form caption)
var
  win: HWND;
begin
  if UseClass then //22.01.13 nk add/opt ff
    win := FindWindow(PChar(ProgName), nil)   //find by class name
  else
    win := FindWindow(nil, PChar(ProgName));  //find by window name

  if win <> NERR_SUCCESS then begin
    case Comm of
      fcClose    : PostMessage(win, WM_SYSCOMMAND, SC_CLOSE,    CLEAR);
      fcMinimize : PostMessage(win, WM_SYSCOMMAND, SC_MINIMIZE, CLEAR);
      fcMaximize : PostMessage(win, WM_SYSCOMMAND, SC_MAXIMIZE, CLEAR);
      fcRestore  : PostMessage(win, WM_SYSCOMMAND, SC_RESTORE,  CLEAR);
    end;
  end;
end;

procedure ExecuteDosComm(DosComm: string; Hidden: Boolean);
const //xe//execute a DOS command in the console shell using cmd.exe
  sw: array [Boolean] of Integer = (SW_SHOWNORMAL, SW_HIDE);
var
  cmd: string;
begin
  try
    cmd := GetEnvVar(SHELL_CMD);  //dos console program (cmd.exe)
    cmd := cmd + ' /C ' + cQUOTE + DosComm + cQUOTE;
    ExecCode := WinExec(PAnsiChar(PAnsiString(cmd)), sw[Hidden]); //xe//
  except
    ExecCode := SHELL_ERROR;
  end;
end;

procedure ExecuteDocument(FileName: string; WaitForClose: Boolean = False);
var //30.11.10 nk opt - open any document with its associated application (opt wait until closed)
  app: string;
  pinfo: TProcessInformation;
  sinfo: TStartupInfo;
begin
  SetLength(app, MAX_PATH);
  ExecCode := FindExecutable(PChar(FileName), nil, PChar(app));

  if ExecCode >= SHELL_ERROR then begin
    SetLength(app, StrLen(PChar(app)));
    FillChar(sinfo, SizeOf(sinfo), 0);

    with sinfo do begin
      cb := SizeOf(sinfo);
      wShowWindow := SW_SHOW;
    end;

    if CreateProcess(PChar(app), PChar(Format(FORM_EXECUTE, [app, FileName])),
      nil, nil, False, NORMAL_PRIORITY_CLASS, nil, nil, sinfo, pinfo) then begin
      if WaitForClose then begin
        WaitForSingleObject(pinfo.hProcess, INFINITE);
        GetExitCodeProcess(pinfo.hProcess, ExecCode);
        CloseHandle(pinfo.hProcess);
        CloseHandle(pinfo.hThread);
      end else begin
        Application.ProcessMessages;
      end;
    end else begin
      ExecCode := GetLastError;
    end;
  end;
end;

procedure ExecuteProgram(FileName: string; Params: PChar; PathName: string = cEMPTY);
begin //20.02.08 nk add ExecCode
  if PathName <> cEMPTY then SetCurrentDir(PathName); //20.02.08 nk add
  ExecCode := ShellExecute(Application.Handle, SHELL_EXEC, PChar(FileName), Params, nil, SW_SHOW);
end;

function ExecuteAndWait(FileName: string; Params: PChar; PathName: string = cEMPTY): Boolean;
var //06.09.11 nk opt - return True if execution was successful, False if failed
  info: TShellExecuteInfo;
  hWin: DWORD;
begin
  Result := False; //06.09.11 nk add
  FillChar(info, SizeOf(info), 0);

  if PathName <> cEMPTY then SetCurrentDir(PathName); //20.02.08 nk add

  with info do begin
    cbSize       := SizeOf(info);
    fMask        := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_DDEWAIT;
    Wnd          := GetActiveWindow;
    lpVerb       := SHELL_EXEC;
    lpParameters := Params;
    lpFile       := PChar(FileName);
    nShow        := SW_SHOWNORMAL;
  end;

  if ShellExecuteEx(@info) then
    hWin := info.HProcess
  else
    Exit;

  while WaitForSingleObject(info.hProcess, WAIT_DELAY) <> WAIT_OBJECT_0 do
    Application.ProcessMessages;

  Result := True; //06.09.11 nk add
  CloseHandle(hWin);
  Application.ProcessMessages;
end;

procedure ExecuteAsAdmin(FileName, Params: string; PathName: string = cEMPTY);
var //xe//27.11.09 nk add - Elevates the program to Admin privileges in Vista's UAC
  info: TShellExecuteInfoA;       //NOT YET TESTED!
begin 
  FillChar(info, SizeOf(info), 0);

  if PathName <> cEMPTY then SetCurrentDir(PathName);

  with info do begin
    cbSize       := SizeOf(info);
    fMask        := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
    Wnd          := GetActiveWindow;
    lpVerb       := SHELL_RUNAS;
    lpParameters := PAnsiChar(AnsiString(Params));   //xe//
    lpFile       := PAnsiChar(AnsiString(FileName)); //xe//
    nShow        := SW_SHOWNORMAL;
  end;

  if not ShellExecuteEx(@info) then
    RaiseLastOSError; 
end;

function ExecuteEmbedded(FileName, ProgCaption: string; Params: PChar; ProgParent: THandle; PathName: string = cEMPTY): THandle;
var //17.03.15 nk add - launch FileName inside ProgParent Panel or Form
  abort: Integer;
begin
  Result := NERR_SUCCESS;
  abort  := MAXLOOP;

  if PathName <> cEMPTY then SetCurrentDir(PathName);
  ExecCode := ShellExecute(Application.Handle, SHELL_EXEC, PChar(FileName), Params, nil, SW_NORMAL);

  while (Result = NERR_SUCCESS) and (abort > 0) do begin
    Dec(abort);
    Result := FindWindow(nil, PChar(ProgCaption));
    Delay(WAIT_DELAY);
  end;

  Windows.SetParent(Result, ProgParent);
  Windows.ShowWindow(Result, SW_SHOWMAXIMIZED);
end;

procedure SetAdminShield(Control: TWinControl; Requiered: Boolean);
var //27.11.09 nk add - show the Admin Shield icon in the Control if Requiered
  req: Integer;
begin 
  req := Integer(Requiered);
  SendMessage(Control.Handle, BCM_SETSHIELD, 0, req);
end;

procedure SetErrDialog(Mode: Boolean);
var //13.05.11 nk add - Enable (True) or disable (False) the Windows Error Reporting (WER)
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);

  with reg do begin
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REG_ERROR_KEY, False) then begin
      if ValueExists(REG_SHOWUI) then begin
        if Mode then begin
          WriteInteger(REG_DISABLE, 0);
          WriteInteger(REG_SHOWUI,  0);
        end else begin
          WriteInteger(REG_DISABLE, 1);
          WriteInteger(REG_SHOWUI,  1);
        end;
      end;
      CloseKey;
    end;
    Free;
  end;
end;

procedure PressKey(const CtrlKey: array of Byte);
var //CtrlKey like: [Ord('A'] or multiple key pressings like: [VK_CTRL, Ord('C']
  k: Word;
begin
  for k := Low(CtrlKey) to High(CtrlKey) do
    Keybd_Event(CtrlKey[k], 0, 0, 0);  // key down
  for k := High(CtrlKey) downto Low(CtrlKey) do
    Keybd_Event(CtrlKey[k], 0, KEYEVENTF_KEYUP, 0); // key up
end;

procedure SetWaveVolume(Left, Right: Word);
// The low-order word contains the left-channel volume setting,
// and the high-order word contains the right-channel setting.
// A value of 65535 represents full volume, and a value of 0 is silence.
// If a device does not support both left and right volume control,
// the low-order word of volume specifies the total volume level,
// and the high-order word is ignored
var
  wave: HWaveOut;
  buff: TWaveFormatex;
  volume: DWORD;
begin
  try
    volume := Left + Right shl 16;
    FillChar(buff, SizeOf(buff), 0);
    WaveOutOpen(@wave, WAVE_MAPPER, @buff, 0, 0, 0);
    WaveOutSetVolume(wave, volume);
    WaveOutClose(wave);
  except
    //ignore it
  end;
end;

function GetSoundCard: Boolean;
begin //True if sound card is available
  Result := WaveOutGetNumDevs > 0;
end;

procedure PlaySoundFile(SoundFile: string; Mode: Byte = SOUND_ASYNC);
begin //23.01.13 nk opt - SoundFile like 'C:\Doggie.wav'
  if FileExists(SoundFile) then begin //16.08.12 nk opt ff
    case Mode of
      SOUND_SYNC:  PlaySound(PChar(SoundFile), 0, SND_FILENAME + SND_SYNC);
      SOUND_ASYNC: PlaySound(PChar(SoundFile), 0, SND_FILENAME + SND_ASYNC);
      SOUND_LOOP:  PlaySound(PChar(SoundFile), 0, SND_FILENAME + SND_ASYNC + SND_LOOP);
    else
      PlaySound(nil, 0, 0); //stop playing
    end;
  end else begin
    PlaySound(nil, 0, 0);   //stop playing
  end;

  //possible settings:
  //SND_ASYNC - Start playing, and don't wait to return
  //SND_SYNC  - Start playing, and wait for the sound to finish
  //SND_LOOP  - Keep looping the sound until another sound is played
  //PlaySound(nil, 0, 0) - stops the sound
end;

procedure PlaySoundSystem(SystemSound: Integer);
var //play system sound
  sound: string;
begin
  case SystemSound of
    1: sound := 'SYSTEMSTART';
    2: sound := 'SYSTEMEXIT';
    3: sound := 'SYSTEMHAND';
    4: sound := 'SYSTEMASTERISK';
    5: sound := 'SYSTEMQUESTION';
    6: sound := 'SYSTEMEXCLAMATION';
    7: sound := 'SYSTEMWELCOME';
  else
       sound := 'SYSTEMDEFAULT';
  end;

  PlaySound(PChar(sound), 0, SND_ASYNC);
end;

procedure BeepTones;
var //21.01.13 nk add - play simple beep tones
  i: Integer;
begin
  for i := 1 to 5 do begin
    Beep(3000, 20); //nk//const
    Delay(50);
  end;
end;

procedure MakeSound(Freq, Dur, Vol: Integer); //Vol=0..127
var //write tones to memory and plays it on the sound card
  sound: Byte;
  i, temp, dsize, rsize: Integer;
  omega: Double;
  wrec: TWaveFormatEx;
  wave: TMemoryStream;
const
  BPS           = 8;
  mono: Word    = $0001;
  rate: Integer = 11025; // 8000, 11025, 22050, or 44100
  rid: string   = 'RIFF';
  wid: string   = 'WAVE';
  fid: string   = 'fmt ';
  did: string   = 'data';
begin
  if Freq > rate then Exit;

  if WaveOutGetNumDevs = 0 then begin  // no sound card found
    Windows.Beep(Freq, Dur);
    Exit;
  end;

  with wrec do begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := mono;
    nSamplesPerSec := rate;
    wBitsPerSample := BPS;
    nBlockAlign := (nChannels * wBitsPerSample) div BPS;
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize := 0;
  end;

  wave := TMemoryStream.Create;

  with wave do begin
    try
      dsize := (Dur * rate) div 1000; // sound data
      rsize := Length(wid) + Length(fid) + SizeOf(DWORD) +
        SizeOf(TWaveFormatEx) + Length(did) + SizeOf(DWORD) + dsize;

      // write out the wave header
      Write(rid[1], 4);                   // 'RIFF'
      Write(rsize, SizeOf(DWORD));        // file data size
      Write(wid[1], Length(wid));         // 'WAVE'
      Write(fid[1], Length(fid));         // 'fmt '
      temp := SizeOf(TWaveFormatEx);
      Write(temp, SizeOf(DWORD));         // TWaveFormat data size
      Write(wrec, SizeOf(TWaveFormatEx)); // WaveFormatEx record
      Write(did[1], Length(did));         // 'data'
      Write(dsize, SizeOf(DWORD));        // sound data size

      // calculate and write out the tone signal
      omega := 2 * Pi * Freq / rate;

      // and the sound data values
      for i := 0 to dsize - 1 do begin
        sound := 127 + Trunc(Vol * Sin(i * omega));
        Write(sound, SizeOf(Byte));
      end;

      // now play the sound
      SndPlaySound(Memory, SND_MEMORY or SND_SYNC);
    finally
      Free;
    end;
  end;
end;

procedure PrintText(Header: string; Text: TRichEdit);
var //27.05.10 nk opt
  plain: Boolean;
  dpix: Extended;
  dpiy: Extended;
  area: TRect;
begin
  with Printer do begin
    if Printers.Count = 0 then Exit; //27.05.10 nk add
    Title := Header;   //get printer resolution [dpi]
    dpix  := GetDeviceCaps(Handle, LOGPIXELSX) / INCH;
    dpiy  := GetDeviceCaps(Handle, LOGPIXELSY) / INCH;
  end;

  with Text do begin
    plain     := PlainText;
    PlainText := True;

    with area do begin
      Left   := Round(dpix * PrinterLeftMargin);
      Top    := Round(dpiy * PrinterTopMargin);
      Right  := Printer.PageWidth  - Left;
      Bottom := Printer.PageHeight - Top;
    end;

    PageRect  := area;
    Print(Name);
    PlainText := plain;
  end;
end;

procedure PrintGrid(Header: string; Grid: TStringGrid);
var //30.11.10 nk opt
  c, r, y, x: Integer;
  hsize, vsize: Integer;
  page, pages, rows: Integer;
  mmx, mmy: Extended;
  footer: string;
begin
  with Printer do begin
    if Printers.Count = 0 then Exit; //27.05.10 nk add
    Title := Header;
    BeginDoc;

    //get printer resolution [mm]
    mmx := GetDeviceCaps(Canvas.Handle, LOGPIXELSX);
    mmx := GetDeviceCaps(Canvas.Handle, PHYSICALWIDTH)  / mmx * INCH;
    mmy := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);
    mmy := GetDeviceCaps(Canvas.Handle, PHYSICALHEIGHT) / mmy * INCH;

    vsize := Trunc(mmy - PrinterTopMargin)  * 10;
    hsize := Trunc(mmx - PrinterLeftMargin) * 10;

    SetMapMode(Canvas.Handle, MM_LOMETRIC);

    rows := (vsize - PrinterHeaderSize - PrinterFooterSize) div PrinterRowHeight;

    if Grid.RowCount mod rows <> 0 then
      pages := Grid.RowCount div rows + 1
    else
      pages := Grid.RowCount div rows;

    for page := 1 to pages do begin //header line
      y := 10 * PrinterTopMargin;
      Canvas.Font.Height := 48;
      Canvas.TextOut((hsize div 2 - (Canvas.TextWidth(Title) div 2)), -y, Title);

      y := 10 * PrinterTopMargin + PrinterHeaderSize;
      Canvas.Pen.Width := 5;
      Canvas.MoveTo(0, -y);
      Canvas.LineTo(hsize, -y);

      //footer line    //nk//footer as argument NOT hard coded!
      Canvas.MoveTo(0, -vsize);
      Canvas.LineTo(hsize, -vsize);
      Canvas.Font.Height := 36;
      footer := Format(FORM_FOOTER, [page, pages]); //30.11.10 nk opt
    //footer := 'page ' + IntToStr(page) + ' of ' + IntToStr(pages);
      Canvas.TextOut((hsize div 2 - (Canvas.TextWidth(footer) div 2)), -vsize - Canvas.Font.Height, footer);
      Canvas.Font.Height := PrinterFontHeight;

      //print grid rows
      y := y + PrinterRowHeight;

      for r := 1 to rows do begin
        if Grid.RowCount >= r + (page - 1) * rows then begin
          x := 10 * PrinterLeftMargin;
          for c := 0 to Grid.ColCount - 1 do begin
            Canvas.TextOut(x, - y, Grid.Cells[c, r + (page - 1) * rows - 1]);
            x := x + Grid.ColWidths[c] * 3;
          end;
          y := y + PrinterRowHeight;
        end;
      end;

      if page <= pages then NewPage;
    end;
    EndDoc;
  end;

  Application.ProcessMessages;
end;

procedure PrintImage(LeftFooter, RightFooter: string; Image: TImage; Zoom: Integer);
var //30.11.10 nk opt - improved version - Image will be printed across the whole page
  rx, ry: Integer;
begin
  //21.12.09 nk opt ff - old=with Printer do begin => conflict with Image.Picture.Bitmap.Width/Height
  try
    if Printer.Printers.Count = 0 then Exit; //27.05.10 nk add
    Printer.Title := RightFooter;
    Printer.BeginDoc;

    with Image.Picture do begin
      if ((Width / Height) > (Printer.PageWidth / Printer.PageHeight)) then begin
        rx := Printer.PageWidth;                         //stretch Bitmap to width of PrinterPage
        ry := MulDiv(Height, Printer.PageWidth, Width);
      end else begin
        rx := MulDiv(Width, Printer.PageHeight, Height); //stretch Bitmap to height of PrinterPage
        ry := Printer.PageHeight;
      end;

      rx := Round(rx * Zoom / PROCENT);
      ry := Round(ry * Zoom / PROCENT);

      with Printer.Canvas do begin
        StretchDraw(Rect(0, 0, rx, ry), Image.Picture.Graphic); //21.12.09 nk add

        if LeftFooter <> cEMPTY then
          TextOut(PrinterLeftMargin, Printer.PageHeight - TextHeight(LeftFooter) - PrinterLeftMargin, LeftFooter);

        if RightFooter <> cEMPTY then
          TextOut(Printer.PageWidth - TextWidth(RightFooter) - PrinterLeftMargin, Printer.PageHeight - TextHeight(RightFooter) - PrinterLeftMargin, RightFooter);
      end;
    end;

    Printer.EndDoc; //print out canvas
  except
    on E: Exception do begin //21.12.09 nk add ff
      Printer.Abort;
      MessageDlg(E.Message + CRLF + FORM_ABORTJOB, mtWarning, [mbOK], 0, mbOK);
    end;
  end;

  Application.ProcessMessages;
end;

function KillTask(TaskName: string): Integer;
var  //14.04.08 nk opt ff
  cont: Bool;
  hwin: Cardinal;
  info: TProcessEntry32;
begin
  Result   := CLEAR;
  TaskName := UpperCase(TaskName);
  hwin     := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  if hwin > NERR_SUCCESS then begin
    info.dwSize := SizeOf(info);
    cont := Process32First(hwin, info);

    while Integer(cont) <> NERR_SUCCESS do begin
      if ((UpperCase(ExtractFileName(info.szExeFile)) = TaskName) or
          (UpperCase(info.szExeFile) = TaskName)) then
          Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERM, Bool(0), info.th32ProcessID), 0));
      cont := Process32Next(hwin, info);
    end;
    CloseHandle(hwin);
  end;
end;

function LockSystem: Boolean;
type //20.01.13 nk add
  TLockWorkStation = function: Boolean;
var
  hUser32: HMODULE;
  LockWorkStation: TLockWorkStation;
begin
  Result  := False;
  hUser32 := GetModuleHandle(API_USER);

  if hUser32 <> NERR_SUCCESS then begin
    @LockWorkStation := GetProcAddress(hUser32, LOCK_SYSTEM);
    if @LockWorkStation <> nil then begin
      LockWorkStation;
      Result := True;
    end;
  end;
end;

function ExitWindows(RebootParam: Longword): Boolean;
var //19.02.14 nk opt for XE3
  TTokenHd: System.THandle; //xe3//
  TTokenPvg: TTokenPrivileges;
  cbtpPrevious: DWORD;
  rTTokenPvg: TTokenPrivileges;
  pcbtpPreviousRequired: DWORD;
  tpResult: Boolean;

{ EWX_LOGOFF      Shuts down all processes running and logs the user off.
  EWX_POWEROFF    Shuts down the system and turns off the power (SHUTDOWN_NAME privilege).
  EWX_REBOOT      Shuts down the system and then restarts the system (SHUTDOWN_NAME privilege).
  EWX_SHUTDOWN    Shuts down the system to a point at which it is safe to turn off the power.
                  All file buffers have been flushed to disk, and all running processes have stopped.
  EWX_FORCE       Forces all processes to terminate itself.
  EWX_FORCEIFHUNG Forces processes to terminate if they do not respond to the
}
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    tpResult := OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, TTokenHd);
    if tpResult then begin
      tpResult := LookupPrivilegeValue(nil, SHUTDOWN_NAME, TTokenPvg.Privileges[0].Luid);
      TTokenPvg.PrivilegeCount := 1;
      TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      cbtpPrevious := SizeOf(rTTokenPvg);
      pcbtpPreviousRequired := 0;
      if tpResult then
        Windows.AdjustTokenPrivileges(TTokenHd, False, TTokenPvg, cbtpPrevious, rTTokenPvg, pcbtpPreviousRequired);
    end;
  end;

  Result := ExitWindowsEx(RebootParam, 0);
end;

function MinimizeToTray(Handle: HWND): Boolean;
var //20.01.13 nk add
  hwndTray: HWND;
  rcTray: TRect;
  rcWindow: TRect;
begin
  Result := False;

  if IsWindow(Handle) then begin
    hwndTray := FindWindowEx(FindWindow(SHELL_TRAY, nil), 0, TRAY_NOTIFY, nil);
    if hwndTray <> NERR_SUCCESS then begin
      GetWindowRect(Handle, rcWindow);
      GetWindowRect(hwndTray, rcTray);
      DrawAnimatedRects(Handle, IDANI_CAPTION, rcWindow, rcTray);
      ShowWindow(Handle, SW_HIDE);
    end;
  end;
end;

function CheckMinSystem(MinVers: string): Boolean;
var //return True if Windows version is at least MinVers
  vact, vmin: Single;
begin
  vmin   := StrVers(MinVers); //get minimum required version in the format 'V.R'
  vact   := StrVers(GetSystemVers(vtVers)); //get actual system version
  Result := (vact >= vmin);
end;

function IsAlive(ProgName: string; UseClass: Boolean = False): Boolean;
var //25.02.14 nk opt for XE3
  res: Cardinal; //xe3//
  win: HWND;
begin
  if UseClass then
    win := FindWindow(PChar(ProgName), nil)   //find by class name
  else
    win := FindWindow(nil, PChar(ProgName));  //find by window name

  if win <> NERR_SUCCESS then
    Result := (SendMessageTimeOut(win, WM_NULL, 0, 0, SMTO_NORMAL or SMTO_ABORTIFHUNG, WAIT_DELAY, {$IF CompilerVersion >= 24.0}@{$ENDIF}res) <> NERR_SUCCESS) //xe7//old=IFEND //xe3// add @
  else
    Result := False;
end;

function IsAdmin: Boolean;
var //19.02.14 nk opt for XE3
  isok: BOOL;
  x: Integer;
  bsize: DWORD;
  atok: System.THandle; //xe3//
  tgrp: PTokenGroups;
  admin: PSID;
begin 
  Result := False;

  isok := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, atok);

  if not isok then begin
    if GetLastError = ERROR_NO_TOKEN then 
      isok := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, atok);
  end; 

  if isok then  begin
    GetMem(tgrp, K1);
    isok := GetTokenInformation(atok, TokenGroups, tgrp, K1, bsize);
    CloseHandle(atok); 

    if isok then begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, admin);
      {$R-}
      for x := 0 to tgrp.GroupCount - 1 do begin
        if EqualSid(admin, tgrp.Groups[x].Sid) then begin
          Result := True; 
          Break; 
        end;
      end;
      {$R+} 
      FreeSid(admin);
    end; 
    FreeMem(tgrp);
  end; 
end;

function IsUACEnabled: Boolean;
var //02.12.10 nk opt - return True if UAC is activated
  reg: TRegistry;
begin
  Result := False;
  reg    := TRegistry.Create(KEY_READ);

  with reg do begin
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey(REG_UAC_KEY, False) then begin
      if ValueExists(REG_UAC) then
        Result := (ReadInteger(REG_UAC) > 0);
      CloseKey;
    end;
    Free;
  end;
end;

function Is32AppOn64Bit: Boolean;
type //20.02.14 nk opt for XE3 - return False if our 32-bit application is running on Windows x86 (32-bit) or True for x64 (64-bit)
  TIsWow64Process = function(Handle: THandle; var IsWow64: Boolean): Boolean; stdcall;
var
  hdll: System.THandle; //xe3//
  IsWow64Process: TIsWow64Process;
  err: string; //20.02.14 nk add
begin
  Result := False;

  try
    hdll := LoadLibrary(API_KERNEL);
    if hdll = NERR_SUCCESS then Exit;

    try
      @IsWow64Process := GetProcAddress(hdll, PROC_IS64);
      if Assigned(IsWow64Process) then
        IsWow64Process(GetCurrentProcess, Result);
    finally
      FreeLibrary(hdll);
    end;
  except
    on E: Exception do //20.02.14 nk add
      err := E.Message;
  end;
end;

function Is64BitSystem: Boolean;
var //10.03.16 nk add - Return True if Windows system is 64-bit, otherwise False
  info: SYSTEM_INFO;
begin
  GetNativeSystemInfo(&info);
  Result := info.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64;
end;

function GetTargetSystem(var AppName: string): Boolean;
var //29.05.14 nk add - return the Target System of AppName and True if running on 64-Bit machine
  FS: TFileStream;
  Header: TImageDosHeader;
  ImageNtHeaders: TImageNtHeaders;
begin
  Result := False;

  try
    FS      := TFileStream.Create(AppName, fmOpenRead + fmShareDenyNone);
    AppName := 'Unknown';
    try
      FS.ReadBuffer(Header, SizeOf(Header));
      if (Header.e_magic <> IMAGE_DOS_SIGNATURE) or (Header._lfanew = 0) then
        Exit; //Invalid executable

      FS.Position := Header._lfanew;
      FS.ReadBuffer(ImageNtHeaders, SizeOf(ImageNtHeaders));

      if ImageNtHeaders.Signature <> IMAGE_NT_SIGNATURE then
        Exit; //Invalid executable

      case ImageNtHeaders.FileHeader.Machine of
        IMAGE_FILE_MACHINE_I386     : begin Result := False; AppName := 'Intel x86'; end;
        IMAGE_FILE_MACHINE_IA64     : begin Result := True;  AppName := 'Intel Itanium Processor Family (IPF)'; end;
        IMAGE_FILE_MACHINE_AMD64    : begin Result := True;  AppName := 'x64 (AMD64 or EM64T)'; end;
        IMAGE_FILE_MACHINE_R3000_BE : begin Result := True;  AppName := 'MIPS big-endian'; end;
        IMAGE_FILE_MACHINE_R3000    : begin Result := True;  AppName := 'MIPS little-endian, 0x160 big-endian'; end;
        IMAGE_FILE_MACHINE_R4000    : begin Result := True;  AppName := 'MIPS little-endian'; end;
        IMAGE_FILE_MACHINE_R10000   : begin Result := True;  AppName := 'MIPS little-endian'; end;
        IMAGE_FILE_MACHINE_ALPHA    : begin Result := True;  AppName := 'Alpha_AXP'; end;
        IMAGE_FILE_MACHINE_POWERPC  : begin Result := True;  AppName := 'IBM PowerPC Little-Endian'; end;
      end;
    finally
      FS.Free;
    end;
  except
    //
  end;
end;

function GetTimer: Int64;
var //19.11.13 nk opt - return time of the high-resolution performance counter [us]
  cts: Int64;
begin
  if QueryPerformanceFrequency(TimerRes) then //[counts/s]
    QueryPerformanceCounter(cts) //[counts]
  else
    cts := CLEAR;

  if (TimerRes > 0) and (cts > 0) then //19.11.13 nk opt ff
    Result := cts * MEGA div TimerRes  //[us]
  else
    Result := GetTickCount * 1000;     //[us] 19.11.13 nk old=NONE
end;

function GetIdleTime: Cardinal;
var //02.06.11 nk add - return idle time (no mouse nor keyboard action) in seconds
  info: TLastInputInfo;
begin
  info.cbSize := SizeOf(TLastInputInfo);
  GetLastInputInfo(info);
  Result := (GetTickCount - info.dwTime) div MSEC_SEC;
end;

function GetUpTime: string;
var //30.11.10 nk opt - return computer running time
  t: Cardinal;
  d, h, m, s: Integer;
begin
  t := GetTickCount;  //ms

  d := t div MSEC_DAY;
  Dec(t, d * MSEC_DAY);

  h := t div MSEC_HOUR;
  Dec(t, h * MSEC_HOUR);

  m := t div MSEC_MIN;
  Dec(t, m * MSEC_MIN);

  s := t div MSEC_SEC;

  Result := Format(FORM_UPTIME, [d, h, m, s]);
end;

function GetBootTime: string;
var //22.09.09 nk add - return computer booting time
  t: Cardinal;
  d: Double;
  td: TDateTime;
begin
  t := GetTickCount;  //ms
  d := t / MSEC_DAY;
  td := Now - d;

  Result := FormatDateTime(FORM_DATE_LOG, td);
end;

function GetUTCTime: TDateTime;
var //14.06.11 nk add
  tsys: TSystemTime;
begin
  GetSystemTime(tsys);
  with tsys do
    Result := EncodeDate(wYear, wMonth, wDay) +
              EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
end;

procedure CloneObject(Source, Target: TObject);
var //xe//30.11.10 nk opt
  i, count, size: Integer;
  plist: PPropList;
  pinfo: PPropInfo;
  pname: string;
begin
  count := GetPropList(Source.ClassInfo, tkAny, nil);
  size  := Count * SizeOf(Pointer);
  GetMem(plist, size);

  try
    count := GetPropList(Source.ClassInfo, tkAny, plist);
    for i := 0 to count - 1 do begin
      pinfo := plist^[i];
      pname := string(pinfo^.Name); //xe//
      if pname <> REG_NAME then begin
        case PropType(Source, pname) of
          tkClass:
            SetObjectProp(Target, pname, GetObjectProp(Source, pname));
          tkMethod:
            SetMethodProp(Target, pname, GetMethodProp(Source, pname));
          else
            SetPropValue(Target, pname, GetPropValue(Source, pname));
        end;
      end;
    end;
  finally
    FreeMem(plist);
  end;
end;

procedure RegisterLibrary(LibName: string);
type //12.04.11 nk add - register OCX or DLL library file
  TRegFunc = function: HResult; stdcall;
var //LibName like 'Flash.ocx' must be in the program path
  err: Boolean;
  lib: string;
  hnd: THandle;
  com: TRegFunc;
begin
  err := True;
  hnd := CLEAR;
  
  try
    lib := ExtractFilePath(Application.ExeName) + LibName;
    hnd := LoadLibrary(PChar(lib));

    if hnd > 31 then begin
      com := GetProcAddress(hnd, SHELL_DLLREG);
      if com = 0 then err := False;
    end;
  except
    //
  end;

  FreeLibrary(hnd);

  if err then
    ShowMessage('Unable to register ' + lib);
end;

procedure RegisterFileType(Prefix, AppFile, AppName: string);
//25.11.10 nk opt - VISTA needs Administrator privileges to write to HKEY_CLASSES_ROOT
var //prefix with or without dot (swd or .swd)
  reg: TRegistry;
  app: string;
begin
  try //04.03.08 nk add - catch registry access errors
    if Pos(cDOT, Prefix) = 0 then Prefix := cDOT + Prefix;

    reg := TRegistry.Create(KEY_READ or KEY_WRITE); //25.11.10 nk opt
    app := StringReplace(AppFile, cSPACE, cEMPTY, [rfReplaceAll]);

    try //to create prefix key
      reg.RootKey := HKEY_CLASSES_ROOT;
      reg.OpenKey(Prefix, True);
      try
        reg.WriteString(cEMPTY, app); //cEMPTY means Name = (Standard)
      finally
        reg.CloseKey;
      end;

      //create application key
      reg.OpenKey(app, True);
      try
        reg.WriteString(cEMPTY, AppFile);
      finally
        reg.CloseKey;
      end;

      //create default icon key
      reg.OpenKey(app + REG_KEY_ICON, True);
      try
        reg.WriteString(cEMPTY, AppName + REG_PAR_ICON);
      finally
        reg.CloseKey;
      end;

      //create shell open key
      reg.OpenKey(app + REG_KEY_OPEN, True);
      try
        reg.WriteString(cEMPTY, AppName + REG_KEY_ATTR);
      finally
        reg.CloseKey;
      end;
    finally
      reg.Free;
    end;

    SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
  except //04.03.08 nk add
    on E: Exception do
      SysError := E.ClassName + cSEPAR + E.Message;
  end;
end;

procedure ClearKeyboardBuffer;
var
  msg: TMsg;
begin
  while PeekMessage(msg, 0, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE or PM_NOYIELD) do;
end;

procedure ClearMouseBuffer;
var
  msg: TMsg;
begin
  while PeekMessage(msg, 0, WM_MOUSEFIRST, WM_MOUSELAST, PM_REMOVE or PM_NOYIELD) do;
end;

procedure RemoveZombies;
var //remove dead program icons from the system tray
  c, r, h, w: Integer;
  win: HWND;
  rec: TRect;
  cur: TPoint;
begin
  win := FindWindowEx(FindWindow(SHELL_TRAY, nil), 0, TRAY_NOTIFY, nil);
  if not GetWindowRect(win, rec) then Exit;

  GetCursorPos(cur); //save actual cursor position
  w := GetSystemMetrics(SM_CXSMICON);
  h := GetSystemMetrics(SM_CYSMICON);

  with rec do begin
    Top := Top + h div 2;

    for r := 0 to (Bottom - Top) div h do begin
      for c := 0 to (Right - Left) div w do begin
        SetCursorPos(Left + c * w, Top + r * h);
        Sleep(1);
      end;
    end;
  end;

  SetCursorPos(cur.X, cur.Y); //restore last cursor position
  RedrawWindow(win, nil, 0, RDW_INVALIDATE OR RDW_ERASE OR RDW_UPDATENOW);
end;

procedure TrimAppMemorySize;
var //02.06.11 nk add - free unused memory blocks allocated by the Windows Memory Manager
  win: THandle;
begin
  try
    win := OpenProcess(PROCESS_ALL_ACCESS, False, GetCurrentProcessID);
    SetProcessWorkingSetSize(win, $FFFFFFFF, $FFFFFFFF);
    CloseHandle(win);
  except
    //ignore
  end;

  Application.ProcessMessages;
end;

function MimeToHtml(Code: string): string;
var //21.10.10 nk mov from UInternet - convert MIME to HTML code ('=F6' -> '&#246;')
  ascii: Integer;
begin
  try
    Code   := StringReplace(Code, cEQUAL, cHEX, []);
    ascii  := StrToInt(Code);
    Result := cMARKUP + IntToStr(ascii) + ';';
  except
    Result := cEMPTY;
  end;
end;

function GetHtmlChar(Code: string): Char;
var //21.10.10 nk mov from UInternet - convert UTF-8 markups to Unicode character
  c: Integer; //either in the form '&micro' or '&#181'
begin         //only the 8-Bit Code Page ISO 8859-1 (Windows West) is supported
  Result := cNUL;
  if (Code = '&quot;')   or (Code = cMARKUP + '34;')  then Result := '”'; //'"' is illegal in XML
  if (Code = '&amp;')    or (Code = cMARKUP + '38;')  then Result := '&';
  if (Code = '&lt;')     or (Code = cMARKUP + '60;')  then Result := '<';
  if (Code = '&gt;')     or (Code = cMARKUP + '62;')  then Result := '>';
  if (Code = '&nbsp;')   or (Code = cMARKUP + '160;') then Result := ' ';
  if (Code = '&iexl;')   or (Code = cMARKUP + '161;') then Result := '¡';
  if (Code = '&cent;')   or (Code = cMARKUP + '162;') then Result := '¢';
  if (Code = '&pound;')  or (Code = cMARKUP + '163;') then Result := '£';
  if (Code = '&curren;') or (Code = cMARKUP + '164;') then Result := '¤';
  if (Code = '&yen;')    or (Code = cMARKUP + '165;') then Result := '¥';
  if (Code = '&brkbar;') or (Code = cMARKUP + '166;') then Result := '¦';
  if (Code = '&sect;')   or (Code = cMARKUP + '167;') then Result := '§';
  if (Code = '&uml;')    or (Code = cMARKUP + '168;') then Result := '¨';
  if (Code = '&copy;')   or (Code = cMARKUP + '169;') then Result := '©';
  if (Code = '&ordf;')   or (Code = cMARKUP + '170;') then Result := 'ª';
  if (Code = '&laquo;')  or (Code = cMARKUP + '171;') then Result := '«';
  if (Code = '&not;')    or (Code = cMARKUP + '172;') then Result := '¬';
  if (Code = '&shy;')    or (Code = cMARKUP + '173;') then Result := '­';
  if (Code = '&reg;')    or (Code = cMARKUP + '174;') then Result := '®';
  if (Code = '&hibar;')  or (Code = cMARKUP + '175;') then Result := '¯';
  if (Code = '&deg;')    or (Code = cMARKUP + '176;') then Result := '°';
  if (Code = '&plusmn;') or (Code = cMARKUP + '177;') then Result := '±';
  if (Code = '&sup2;')   or (Code = cMARKUP + '178;') then Result := '²';
  if (Code = '&sup3;')   or (Code = cMARKUP + '179;') then Result := '³';
  if (Code = '&acute;')  or (Code = cMARKUP + '180;') then Result := '´';
  if (Code = '&micro;')  or (Code = cMARKUP + '181;') then Result := 'µ';
  if (Code = '&para;')   or (Code = cMARKUP + '182;') then Result := '¶';
  if (Code = '&middot;') or (Code = cMARKUP + '183;') then Result := '·';
  if (Code = '&cedil;')  or (Code = cMARKUP + '184;') then Result := '¸';
  if (Code = '&sup1;')   or (Code = cMARKUP + '185;') then Result := '¹';
  if (Code = '&ordm;')   or (Code = cMARKUP + '186;') then Result := 'º';
  if (Code = '&raquo;')  or (Code = cMARKUP + '187;') then Result := '»';
  if (Code = '&frac14;') or (Code = cMARKUP + '188;') then Result := '¼';
  if (Code = '&frac12;') or (Code = cMARKUP + '189;') then Result := '½';
  if (Code = '&frac34;') or (Code = cMARKUP + '190;') then Result := '¾';
  if (Code = '&iquest;') or (Code = cMARKUP + '191;') then Result := '¿';
  if (Code = '&Agrave;') or (Code = cMARKUP + '192;') then Result := 'À';
  if (Code = '&Aacute;') or (Code = cMARKUP + '193;') then Result := 'Á';
  if (Code = '&Acirc;')  or (Code = cMARKUP + '194;') then Result := 'Â';
  if (Code = '&Atilde;') or (Code = cMARKUP + '195;') then Result := 'Ã';
  if (Code = '&Auml;')   or (Code = cMARKUP + '196;') then Result := 'Ä';
  if (Code = '&Aring;')  or (Code = cMARKUP + '197;') then Result := 'Å';
  if (Code = '&AEling;') or (Code = cMARKUP + '198;') then Result := 'Æ';
  if (Code = '&Ccedil;') or (Code = cMARKUP + '199;') then Result := 'Ç';
  if (Code = '&Egrave;') or (Code = cMARKUP + '200;') then Result := 'È';
  if (Code = '&Eacute;') or (Code = cMARKUP + '201;') then Result := 'É';
  if (Code = '&Ecirce;') or (Code = cMARKUP + '202;') then Result := 'Ê';
  if (Code = '&Euml;')   or (Code = cMARKUP + '203;') then Result := 'Ë';
  if (Code = '&Igrave;') or (Code = cMARKUP + '204;') then Result := 'Ì';
  if (Code = '&Iacute;') or (Code = cMARKUP + '205;') then Result := 'Í';
  if (Code = '&Icirce;') or (Code = cMARKUP + '206;') then Result := 'Î';
  if (Code = '&Iuml;')   or (Code = cMARKUP + '207;') then Result := 'Ï';
  if (Code = '&ETH;')    or (Code = cMARKUP + '208;') then Result := 'Ð';
  if (Code = '&Ntilde;') or (Code = cMARKUP + '209;') then Result := 'Ñ';
  if (Code = '&Ograve;') or (Code = cMARKUP + '210;') then Result := 'Ò';
  if (Code = '&Oacute;') or (Code = cMARKUP + '211;') then Result := 'Ó';
  if (Code = '&Ocirc;')  or (Code = cMARKUP + '212;') then Result := 'Ô';
  if (Code = '&Otilde;') or (Code = cMARKUP + '213;') then Result := 'Õ';
  if (Code = '&Ouml;')   or (Code = cMARKUP + '214;') then Result := 'Ö';
  if (Code = '&times;')  or (Code = cMARKUP + '215;') then Result := '×';
  if (Code = '&Oslash;') or (Code = cMARKUP + '216;') then Result := 'Ø';
  if (Code = '&Ugrave;') or (Code = cMARKUP + '217;') then Result := 'Ù';
  if (Code = '&Uacute;') or (Code = cMARKUP + '218;') then Result := 'Ú';
  if (Code = '&Ucirc;')  or (Code = cMARKUP + '219;') then Result := 'Û';
  if (Code = '&Uuml;')   or (Code = cMARKUP + '220;') then Result := 'Ü';
  if (Code = '&Yacute;') or (Code = cMARKUP + '221;') then Result := 'Ý';
  if (Code = '&THORN;')  or (Code = cMARKUP + '222;') then Result := 'Þ';
  if (Code = '&szlig;')  or (Code = cMARKUP + '223;') then Result := 'ß';
  if (Code = '&agrave;') or (Code = cMARKUP + '224;') then Result := 'à';
  if (Code = '&aacute;') or (Code = cMARKUP + '225;') then Result := 'á';
  if (Code = '&acirc;')  or (Code = cMARKUP + '226;') then Result := 'â';
  if (Code = '&atilde;') or (Code = cMARKUP + '227;') then Result := 'ã';
  if (Code = '&auml;')   or (Code = cMARKUP + '228;') then Result := 'ä';
  if (Code = '&aring;')  or (Code = cMARKUP + '229;') then Result := 'å';
  if (Code = '&aeling;') or (Code = cMARKUP + '230;') then Result := 'æ';
  if (Code = '&ccedil;') or (Code = cMARKUP + '231;') then Result := 'ç';
  if (Code = '&egrave;') or (Code = cMARKUP + '232;') then Result := 'è';
  if (Code = '&eacute;') or (Code = cMARKUP + '233;') then Result := 'é';
  if (Code = '&ecirc;')  or (Code = cMARKUP + '234;') then Result := 'ê';
  if (Code = '&euml;')   or (Code = cMARKUP + '235;') then Result := 'ë';
  if (Code = '&igrave;') or (Code = cMARKUP + '236;') then Result := 'ì';
  if (Code = '&iacute;') or (Code = cMARKUP + '237;') then Result := 'í';
  if (Code = '&icirc;')  or (Code = cMARKUP + '238;') then Result := 'î';
  if (Code = '&iuml;')   or (Code = cMARKUP + '239;') then Result := 'ï';
  if (Code = '&eth;')    or (Code = cMARKUP + '240;') then Result := 'ð';
  if (Code = '&ntilde;') or (Code = cMARKUP + '241;') then Result := 'ñ';
  if (Code = '&ograve;') or (Code = cMARKUP + '242;') then Result := 'ò';
  if (Code = '&oacute;') or (Code = cMARKUP + '243;') then Result := 'ó';
  if (Code = '&ocirc;')  or (Code = cMARKUP + '244;') then Result := 'ô';
  if (Code = '&otilde;') or (Code = cMARKUP + '245;') then Result := 'õ';
  if (Code = '&ouml;')   or (Code = cMARKUP + '246;') then Result := 'ö';
  if (Code = '&divide;') or (Code = cMARKUP + '247;') then Result := '÷';
  if (Code = '&oslash;') or (Code = cMARKUP + '248;') then Result := 'ø';
  if (Code = '&ugrave;') or (Code = cMARKUP + '249;') then Result := 'ù';
  if (Code = '&uacude;') or (Code = cMARKUP + '250;') then Result := 'ú';
  if (Code = '&ucirc;')  or (Code = cMARKUP + '251;') then Result := 'û';
  if (Code = '&uuml;')   or (Code = cMARKUP + '252;') then Result := 'ü';
  if (Code = '&yacute;') or (Code = cMARKUP + '253;') then Result := 'ý';
  if (Code = '&thorn;')  or (Code = cMARKUP + '254;') then Result := 'þ';
  if (Code = '&yuml;')   or (Code = cMARKUP + '255;') then Result := 'ÿ';

  if Result = cNUL then begin
    if (Pos(cMARKUP, Code) > 0) then begin
      Code := StringReplace(Code, cAMPER, cEMPTY, [rfReplaceAll]);
      Code := StringReplace(Code, cCARET, cEMPTY, [rfReplaceAll]);
      Code := StringReplace(Code, cSEMI,  cEMPTY, [rfReplaceAll]);
      c := StrToIntDef(Code, 32);  //32 = cSPACE
      Result := Char(c);
    end else begin
      Result := cSPACE;
    end;
  end;
end;

function MessageSend(ProgName, Text: string; UseClass: Boolean = False): Boolean;
var //V5//11.07.16 nk add - send Text message to another application
  win: HWND;
  cds: CopyDataStruct;
begin
  if UseClass then
    win := FindWindow(PChar(ProgName), nil)  //find by class name
  else
    win := FindWindow(nil, PChar(ProgName)); //find by window name

  if win <> NERR_SUCCESS then begin
    cds.dwData := WM_WINMESSAGE;
    cds.cbData := Length(Text) * SizeOf(Char);
    cds.lpData := PChar(Text);
    SendMessage(win, WM_COPYDATA, Application.Handle, LPARAM(@cds));
    Result := True;
  end else begin
    Result := False;
  end;
end;

{$IFDEF VCLSTYLES} //V5//28.12.15 nk add ff - fix bug in VCL styles regarding LoadIcon
                   //see: http://stackoverflow.com/questions/10257353/delphi-xe2-vcl-styles-changing-window-icon-doesnt-update-on-the-caption-bar-un
procedure PatchCode(Address: Pointer; const NewCode; Size: Integer);
var
  OldProtect: DWORD;
begin
  if VirtualProtect(Address, Size, PAGE_EXECUTE_READWRITE, OldProtect) then
  begin
    Move(NewCode, Address^, Size);
    FlushInstructionCache(GetCurrentProcess, Address, Size);
    VirtualProtect(Address, Size, OldProtect, @OldProtect);
  end;
end;

type
  PInstruction = ^TInstruction;
  TInstruction = packed record
    Opcode: Byte;
    Offset: Integer;
  end;

procedure RedirectProcedure(OldAddress, NewAddress: Pointer);
var //nk//check NativeInt for 64-bit
  NewCode: TInstruction;
begin
  NewCode.Opcode := $E9;//jump relative
  NewCode.Offset := NativeInt(NewAddress) - NativeInt(OldAddress )- SizeOf(NewCode);
  PatchCode(OldAddress, NewCode, SizeOf(NewCode));
end;

type
  TFormStyleHookHelper = class helper for TFormStyleHook
    function GetIconFastAddress: Pointer;
    function GetIconAddress: Pointer;
  end;

function TFormStyleHookHelper.GetIconFastAddress: Pointer;
var
  MethodPtr: function: TIcon of object;
begin
  MethodPtr := Self.GetIconFast;
  Result := TMethod(MethodPtr).Code;
end;

function TFormStyleHookHelper.GetIconAddress: Pointer;
var
  MethodPtr: function: TIcon of object;
begin
  MethodPtr := Self.GetIcon;
  Result := TMethod(MethodPtr).Code;
end;
{$ENDIF}

initialization
{$IFDEF VCLSTYLES}
  RedirectProcedure(
    Vcl.Forms.TFormStyleHook(nil).GetIconFastAddress,
    Vcl.Forms.TFormStyleHook(nil).GetIconAddress);
{$ENDIF}

  Set8087CW($133F);      //01.07.11 nk add - disable all FPU exceptions
{$IFDEF CPUX64}          //06.04.12 nk add ff
  SetMXCSR($1F80);       //20.02.14 nk opt ff for XE3
  {$EXCESSPRECISION OFF}
{$ENDIF CPUX64}

  SetRoundMode(rmNearest); //prevent EInvalidOp Error on RoundTo()

  GetWindowMetric;  //25.10.07 nk add

  PrinterLeftMargin := 15;  //set default printer
  PrinterTopMargin  := 15;  //margins [mm]
  PrinterHeaderSize := 100;
  PrinterFooterSize := 200;
  PrinterRowHeight  := 36;
  PrinterFontHeight := 36;

  FontScale         := GetResolution(dtScreen);  //26.11.15 nk add ff [dpi]
  PaperA4Width      := Round(8.27  * FontScale);      //get A4 portrait size [pixels]
  PaperA4Height     := Round(11.69 * FontScale);

  TimerRes          := CLEAR;   //20.02.08 nk add ff
  MutexHandle       := CLEAR;
  ExecCode          := CLEAR;
  SysError          := cEMPTY;   //04.03.08 nk add
  StringPart        := cEMPTY;
  ComputerUser      := cEMPTY;

  FontScale         := GetFontScale;  //02.04.08 nk add
  CompanyName       := GetAppInfo(piCompanyName);       //'seanus systems'
  FileDescription   := GetAppInfo(piFileDescription);   //'Mail Server'
  FileVersion       := GetAppInfo(piFileVersion);       //'3.5.0.127'
  InternalName      := GetAppInfo(piInternalName);
  LegalCopyright    := GetAppInfo(piLegalCopyright);
  LegalTradeMarks   := GetAppInfo(piLegalTradeMarks);
  OriginalFileName  := GetAppInfo(piOriginalFileName);
  ProductName       := GetAppInfo(piProductName);
  ProductVersion    := GetAppInfo(piProductVersion);
  Comments          := GetAppInfo(piComments);
  ProjectName       := GetAppInfo(piProjectName);
  FileName          := GetAppInfo(piFileName);
  ProgName          := GetAppInfo(piProgName);
  ProgPath          := GetAppInfo(piProgPath);
  ProgBuild         := GetProgVers(vtBuild); //24.03.08 nk add
  ProductHeader     := Format(FORM_HEADER, [ProductName, ProductVersion, LegalCopyright]);
  ProductTitle      := Format(FORM_HEADER, [FileDescription, ProductVersion, LegalCopyright]); //01.04.16 nk add
  ProductAgent      := Format(FORM_AGENT,  [ProductName, ProductVersion]);

  //16.04.08 nk add - check minimum Windows version
  if Comments <> cEMPTY then begin
    if not CheckMinSystem(Comments) then begin
      Beep(3000, 200); //10.01.17 nk opt
      ShowMessage(Comments);
      Halt;
    end;
  end;

  //03.11.08 nk add - correct time and date format with unknown or invalid characters
  TimeFormatShort := FormatDateTime(FormatSettings.ShortTimeFormat, 0);    //xe3//
  if (Pos(FORMERR, TimeFormatShort) > 0) or (Length(TimeFormatShort) > 8) then
    FormatSettings.ShortTimeFormat := FORM_SHORT_TIME;                     //xe3//

  TimeFormatLong := FormatDateTime(FormatSettings.LongTimeFormat, 0);      //xe3//
  if (Pos(FORMERR, TimeFormatLong) > 0) or (Length(TimeFormatLong) > 11) then
    FormatSettings.LongTimeFormat := FORM_LONG_TIME;                       //xe3//

  DateFormatShort := FormatDateTime(FormatSettings.ShortDateFormat, 0);    //xe3//
  if (Pos(FORMERR, DateFormatShort) > 0) or (Length(DateFormatShort) > 12) then
    FormatSettings.ShortDateFormat := FORM_DATE_ISO;                       //xe3//

  TimeFormatShort := FORM_HOUR  + FormatSettings.TimeSeparator   + FORM_MIN; //xe3//
  TimeFormatLong  := FORM_HOUR  + FormatSettings.TimeSeparator   + FORM_MIN   + FormatSettings.TimeSeparator + FORM_SEC; //xe3//
  DateFormatShort := FORM_YEARS + FormatSettings.DateSeparator   + FORM_MONTH + FormatSettings.DateSeparator + FORM_DAY; //xe3//
  DateFormatLong  := 'dddd, '   + FormatSettings.ShortDateFormat + FORM_PITCH + FormatSettings.ShortTimeFormat; //20.11.15 nk add

  //25.11.10 nk add - remember screen saver delay time [min] (0=Off)
  ScreenDelay := GetScreenSaver;

finalization //25.11.10 nk opt
  if MutexHandle <> NERR_SUCCESS then begin
    ReleaseMutex(MutexHandle);
    CloseHandle(MutexHandle);
  end;

  //25.11.10 nk add - restore screen saver delay time [min] (0=Off)
  SetScreenSaver(ScreenDelay);

end.
