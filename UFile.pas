// File and Disk Functions
// Date 20.04.20

{ TODO : Add TSortMode to GetFiles }

// 16.07.07 nk add in all functions better checks (set global FileError)
// 29.07.07 nk opt ff replace cNULL with cNUL (#0)
// 20.03.08 nk add GetFolderPath returns W2K, XP, and Vista folders
// 27.08.09 nk opt ff - set FileMode depending on read/write access
// 17.09.09 nk opt replace cDOT by MYDIR
// 11.12.09 nk opt try to close already opened file on I/O error 103
// 28.12.09 nk add public FileListing to make file names globally available
// 06.01.10 nk opt do not copy '.' (own folder) and '..' (parent folder) in CopyFiles
// 12.10.10 nk upd to Delphi XE (2011) Unicode UTF-16LE (Code site 1200)
// 12.12.10 nk add CopyFileAdv copies a file and numbers the copy if already exist
// 16.12.10 nk add GetFileFilter to fill combobox with file filters
// 27.12.10 nk add support for ANSI and Unicode UTF-16LE strings in ReplaceInFile
// 08.06.11 nk opt read/write files in ANSI or optional in UTF-8 Unicode compliant format
// 08.06.11 nk add replace WriteLn with WriteALine to write an Unicode string to an UTF-8 encoded file (e.g. XML)
// 08.06.11 nk add replace ReadLn with ReadALine to read an Unicode string from an UTF-8 encoded file (e.g. XML)
// 18.06.11 nk add compiler switch 'VERS400' for UTF-8 support instead of ISO-8859-1
// 27.01.12 nk add TSortMode for file and subdirectory sorting by name or timestamp (e.g. youngest first)
// 23.04.12 nk opt expand file names (with path) from MAXBYTE to MAX_PATH characters
// 23.09.12 nk add div. Application.ProcessMessages to not block application
// 20.02.14 nk upd to Delphi XE3 (VER240 Version 24)
// 17.05.15 nk opt in WriteToFile - assign code page CP_UTF8 and write BOM if file is UTF-8 encoded
// 08.04.16 nk add ReplaceInXML to replace strings in an UTF-8 encoded file
// 20.05.16 nk opt for 64-bit version
// 10.01.17 nk opt replace all cSTAR by ALLOF
// 10.08.18 nk add CopyDir, CopyFilesProgress, and OpenExplorer
// 15.08.18 nk opt DeleteDir - file errors are ignored and message dialog suppressed (set FOF_NOERRORUI)
// 19.11.19 nk add FindFileInSubdirs - check if at least one matching file is in subdirectories
// 20.04.20 nk opt undefine 'TCAD' to include UGraphic enabling GetImageCheckSum

{
  see also System.IOUtils.TDirectory

  File Attributes (defined in SysUtils)
  ===============
  faReadOnly    1  write protected file
  faHidden      2  hidden file
  faSysFile     4  system file
  faVolumeID    8  volume ID
  faDirectory  16  directory
  faArchive    32  archive file
  faSymLink	   64  system link
  faAnyFile    71  any file

  File Access Codes (defined in SysUtils)
  =================
  fmOpenRead       $00
  fmOpenWrite      $01
  fmOpenReadWrite  $02
  fmShareExclusive $10
  fmShareDenyWrite $20
  fmShareDenyRead  $30
  fmShareDenyNone  $40
                  
  Directories
  ===========
  CreateDir('C:\temp');  //einzelnes verzeichnis
  if not ForceDirectories('c:\temp\test') then Error //ganzer pfad anlegen
    NOTE: The FileCtrl version is deprecated, and the SysUtils version preferred
  if not DeleteDir('C:\temp\test.txt') then Error
  if FileCtrl.DirectoryExists('c:\temp') then... (with or without trailing '\') -> deprecated => use SysUtils.DirectoryExists
  SetCurrentDirectory('C:\temp\'); or SetCurrentDir
  GetDir(0, sString); //s aktuelle Arbeitsverzeichnis mit Laufwerksangabe
  sPath := IncludeTrailingPathDelimiter(sPath);
  sPath := ExcludeTrailingPathDelimiter(sPath);
  RenameFile('C:\Alt\','C:\Neu\'); //Verzeichnis umbenennen
  ProgramPath := ExtractFilePath(Application.ExeName);

  Create a Directory : CreateDir('c:\path');
  Remove a Directory : RemoveDir('c:\path') or RmDir('c:\path') => Folder must be empty!
  Change a Directory : ChDir('c:\path')
  Current Directory : GetCurrentDir
  Check if a Directory exists : if DirectoryExists('c:\path') then ...
  SHFileOperation - Copies, moves, renames, or deletes a file system object (see OperFileShell)

  Files
  =====
  if FileExists('C:\Eigene Dateien\textdatei.txt') then ...  => NO wildcards!
  CopyFile(PChar(fileSource), PChar(fileDest), bFailIfExists);
  RenameFile('c:\AlterName.exe', 'c:\NeuerName.exe'); - Returns True=ok, False=failed (e.g. no permission)
  FileSetAttr('C:\io.sys', faReadOnly or faSysFile);
  attribute := FileGetAttr('C:\io.sys');
  FileSetAttr(FileName, FileGetAttr(FileName) xor faReadOnly); //remove flag - toggle all others!
  FileSetAttr(FileName, FileGetAttr(FileName) or faReadOnly);  //set flag
  ShellExecute(Handle, 'open', 'c:\temp\test.doc', nil, nil, SW_SHOWNORMAL);
  Label1.Caption := MinimizeName(FilName, Label1.Canvas, Label1.Width);
  sFile := ChangeFileExt(sFile,'.rtf');

  ExpandFileName  - Liefert einen String, der einen vollständigen Pfad- und Dateinamen enthält.
  ExtractFileDir  - Liefert Laufwerksangabe und Verzeichnispfad des Dateinamens zurück (ohne "\")
  ExtractFilePath - Liefert den vollständigen Pfad zu der angegebenen Datei (mit "\")
  ExtractFileExt  - Liefert die Dateinamenerweiterung mit Punkt zurück (.exe)
  ExtractFileName - Liefert den angegebenen Dateinamen mit Erweiterung zurück (System.ini)

  NewFileName := ChangeFileExt(FilName, ext); - Ersetzt Dateiendung .old = .new;

  Rename a File: RenameFile('file1.txt', 'file2.xyz')
  Delete a File: DeleteFile('c:\text.txt')
  Move a File: MoveFile('C:\file1.txt', 'D:\file1.txt');
  Copy a File: CopyFile(PChar(File1), PChar(File2), bFailIfExists)
  Change a File's Extension: ChangeFileExt('test.txt', '.xls')
  Check if a File exists: if FileExists('c:\filename.tst') then ...  => NO wildcards!

  CopyFile(
    lpExistingFileName : PChar, // name of an existing file
    lpNewFileName : PChar,      // name of new file
    bFailIfExists : Boolean);   // if this parameter is TRUE and the new file specified by
    //lpNewFileName already exists, the function fails.
    //If this parameter is FALSE and the new file already exists,
    //the function overwrites the existing file and succeeds.

  bFailIfExists:
  Specifies how this operation is to proceed if a file of the same name as
  that specified by lpNewFileName already exists.
  If this parameter is TRUE and the new file already exists, the function fails.
  If this parameter is FALSE and the new file already exists,
  the function overwrites the existing file and succeeds.

  //extended file creation (see Microsoft MSDN for detailed description)
  F := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
                  OPEN_ALWAYS,
                  FILE_ATTRIBUTE_TEMPORARY or
                  FILE_ATTRIBUTE_NOT_CONTENT_INDEXED or
                  FILE_FLAG_DELETE_ON_CLOSE or
                  FILE_FLAG_RANDOM_ACCESS, 0);

  Result of 'GetFolderPath' under Windows Vista and later:

  CSIDL_PERSONAL 			        -> C:\Users\Daniel\Documents
  CSIDL_MYPICTURES 		        -> C:\Users\Daniel\Pictures
  CSIDL_APPDATA               -> C:\Users\Daniel\AppData\Roaming
  CSIDL_LOCAL_APPDATA 		    -> C:\Users\Daniel\AppData\Local
  CSIDL_COMMON_APPDATA 		    -> C:\ProgramData
  CSIDL_WINDOWS 			        -> C:\Windows
  CSIDL_SYSTEM 			          -> C:\Windows\system32
  CSIDL_PROGRAM_FILES 		    -> C:\Program Files
  CSIDL_PROGRAM_FILES_COMMON 	-> C:\Program Files\Common Files
  CSIDL_COMMON_DOCUMENTS      -> C:\All Users\Documents

  Result of 'GetFolderPath' under Windows XP

  CSIDL_PERSONAL 			        -> C:\Eigene Dateien
  CSIDL_MYPICTURES 		        -> C:\Eigene Dateien\Eigene Bilder
  CSIDL_APPDATA 			        -> C:\Dokumente und Einstellungen\Daniel\Anwendungsdaten
  CSIDL_LOCAL_APPDATA 		    -> C:\Dokumente und Einstellungen\Daniel\Lokale Einstellungen\Anwendungsdaten
  CSIDL_COMMON_APPDATA 		    -> C:\Dokumente und Einstellungen\All Users\Anwendungsdaten
  CSIDL_WINDOWS 			        -> C:\WINDOWS
  CSIDL_SYSTEM 			          -> C:\WINDOWS\system32
  CSIDL_PROGRAM_FILES 		    -> C:\Programme
  CSIDL_PROGRAM_FILES_COMMON 	-> C:\Programme\Gemeinsame Dateien
}

unit UFile;

{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}

interface

uses //UGraphic / 06.03.12 nk add Graphics
  Windows, Forms, Classes, Math, SysUtils, StrUtils, StdCtrls, ComCtrls, ComObj,
  Messages, Dialogs, Grids, Graphics, ImageHlp, ShellApi, ZLib, SHFolder,
  {$IFNDEF TCAD} UGraphic, {$ENDIF} //52//20.04.20 nk add
  UGlobal, USystem;

type //23.06.13 nk add fmNoFdel / 09.06.12 nk add fmTrim / 27.02.12 nk add fmNoTemp / 22.06.11 nk add fmLim3 / 26.04.08 nk add fmDirs, fmFiles
  TFindMode = set of (fmCase, fmWord, fmSwap, fmAnsi, fmClear, fmExt, fmSort,
                      fmDirs, fmFiles, fmLim3, fmNoTemp, fmTrim, fmNoFdel);

  TSortMode = (smNone, smName, smOldest, smYoungest); //27.01.12 nk add

  TFileSize = (fsTotal, fsFree, fsUsed);

  TFileOper = (foCopy, foDelete, foMove, foRename);

  TDiskType = (dtRemovable, dtHarddisk, dtNetwork, dtLaserdisk, dtRamDisk, dtUnknown); //correspondes with DISK_ constants
                //05.07.08 nk add feException
  TFileError = (feNoError, feEmptyParameter, feInvalidParameter, feDriveNotReady,
                feDirNotExist, feFileNotExist, feInternalError, feException);

  TFileInfo = record
    FileType: string;
    CompanyName: string;
    FileDescription: string;
    FileVersion: string;
    InternalName: string;
    LegalCopyRight: string;
    LegalTradeMarks: string;
    OriginalFileName: string;
    ProductName: string;
    ProductVersion: string;
    Comments: string;
    SpecialBuildStr: string;
    PrivateBuildStr: string;
    FileFunction: string;
    DebugBuild: Boolean;
    PreRelease: Boolean;
    SpecialBuild: Boolean;
    PrivateBuild: Boolean;
    Patched: Boolean;
    InfoInferred: Boolean;
  end;

const
  PATHDEL   = '\';
  DRIVEDEL  = ':';      //17.07.07 nk add
  DISKDEL   = ':\';     //25.07.10 nk add
  NODRIVE   = '-';      //24.07.10 nk add
  FILEDEL   = '_';      //23.06.13 nk add
  EXTDEL    = '.';      //V5//23.06.16 nk add
  MYDIR     = '.';
  UPDIR     = '..';     //52//19.11.19 nk add
  CUTDIR    = '...';
  ALLOF     = '*';
  NONEOF    = '!';      //29.07.12 nk add
  ALLTYPES  = '.*';     //06.03.10 nk add
  OWNDIR    = '.\';
  PARENTDIR = '..\';
  NETDIR    = '\\';
  COMMENT   = '//';     //21.06.11 nk add
  ALLFILES  = '*.*';
  STRINGDEL = ';';      //03.07.08 nk add standard string delimiter
  UTF8_BOM  = #$FEFF;   //V5//17.05.15 nk add UTF-8 BOM (Byte Order Mark) = Byte sequenz 'EF BB BF'

  FILE_ENCODING = ENCODING_UTF8;   //18.06.11 nk add character set encoding (UTF-8/Unicode)

  //20.03.08 nk del TMP_POST  = '.tmp' (use TMP_END from UGlobal)

  //06.09.08 nk opt ff - not defined in SHFolder.pas!?!
  CSIDL_DESKTOP                 = $0000;
  CSIDL_INTERNET                = $0001;
  CSIDL_PROGRAMS                = $0002;
  CSIDL_CONTROLS                = $0003;
  CSIDL_PRINTERS                = $0004;
  CSIDL_PERSONAL                = $0005; //Version 6.0
  CSIDL_FAVORITES               = $0006;
  CSIDL_STARTUP                 = $0007;
  CSIDL_RECENT                  = $0008;
  CSIDL_SENDTO                  = $0009;
  CSIDL_BITBUCKET               = $000A;
  CSIDL_STARTMENU               = $000B;
  CSIDL_MYDOCUMENTS             = $000C;
  CSIDL_MYMUSIC                 = $000D;
  CSIDL_MYVIDEO                 = $000E; //Version 6.0
  CSIDL_DESKTOPDIRECTORY        = $0010;
  CSIDL_DRIVES                  = $0011;
  CSIDL_NETWORK                 = $0012;
  CSIDL_NETHOOD                 = $0013;
  CSIDL_FONTS                   = $0014;
  CSIDL_TEMPLATES               = $0015;
  CSIDL_COMMON_STARTMENU        = $0016;
  CSIDL_COMMON_PROGRAMS         = $0017;
  CSIDL_COMMON_STARTUP          = $0018;
  CSIDL_COMMON_DESKTOPDIRECTORY = $0019;
  CSIDL_APPDATA                 = $001A; //Version 4.71
  CSIDL_PRINTHOOD               = $001B;
  CSIDL_LOCAL_APPDATA           = $001C; //Version 5.0
  CSIDL_ALTSTARTUP              = $001D;
  CSIDL_COMMON_ALTSTARTUP       = $001E;
  CSIDL_COMMON_FAVORITES        = $001F;
  CSIDL_INTERNET_CACHE          = $0020; //Version 4.72
  CSIDL_COOKIES                 = $0021;
  CSIDL_HISTORY                 = $0022;
  CSIDL_COMMON_APPDATA          = $0023; //Version 5.0
  CSIDL_WINDOWS                 = $0024; //Version 5.0
  CSIDL_SYSTEM                  = $0025; //Version 5.0
  CSIDL_PROGRAM_FILES           = $0026; //Version 5.0
  CSIDL_MYPICTURES              = $0027; //Version 5.0
  CSIDL_PROFILE                 = $0028; //Version 5.0
  CSIDL_SYSTEMX86               = $0029;
  CSIDL_PROGRAM_FILESX86        = $002A;
  CSIDL_PROGRAM_FILES_COMMON    = $002B; //Version 5.0
  CSIDL_COMMON_TEMPLATES        = $002D;
  CSIDL_COMMON_DOCUMENTS        = $002E;
  CSIDL_COMMON_ADMINTOOLS       = $002F; //Version 5.0
  CSIDL_ADMINTOOLS              = $0030; //Version 5.0
  CSIDL_CONNECTIONS             = $0031;
  CSIDL_COMMON_MUSIC            = $0035; //Version 6.0
  CSIDL_COMMON_PICTURES         = $0036; //Version 6.0
  CSIDL_COMMON_VIDEO            = $0037; //Version 6.0
  CSIDL_CDBURN_AREA             = $003B; //Version 6.0
  CSIDL_COMPUTERSNEARME         = $003D;

  SHGFP_TYPE_CURRENT = 0;  //20.03.08 nk add

  INVALID_FILE_CHARS = ['/', ':', '*', '<', '>', '|', #39, '?', '.', '\', '"'];
  INVALID_PATH_CHARS = ['/', ':', '*', '<', '>', '|', #39, '?'];

  DISK_REMOVE  = 0;  //10.07.09 nk add ff - correspondes with Ord(TDiskType)
  DISK_HARD    = 1;
  DISK_NET     = 2;
  DISK_LASER   = 3;
  DISK_RAM     = 4;
  DISK_UNKNOWN = 5;

  FORM_COPY    = ' [%d].';   //12.12.10 nk add (file rename like 'Contrast [1].swl'
  FORM_RTFCP   = '\ansicpg'; //14.06.11 nk add
  FORM_INFO    = '\StringFileInfo\%.4x%.4x\%s';  //28.09.09 nk add ff
  FILE_INFO    = '\VarFileInfo\Translation';

  DiskTypes: array[DISK_REMOVE..DISK_UNKNOWN] of string = //corresponds with TDiskType
    ('Removable', 'Harddisk', 'Network', 'Laserdisk', 'RamDisk', 'Unknown');

var
  FileSubDir: Integer;       //V5//23.06.16 nk add
  FileMatching: Integer;     //52//19.11.19 nk add
  FileError: TFileError;
  FileListing: TStringList;  //28.12.09 nk add

  function CheckDir(var DirName: string): Boolean;
  function CheckFile(var FilName: string): Boolean;
  function CopyDir(const FromDir, ToDir: string): Boolean; //09.08.18 nk add
  function GetCheckSum(FilName: string): DWORD;         //26.08.09 nk add
{$IFNDEF TCAD} //52//20.04.20 nk add
  function GetImageCheckSum(FilName: string): Integer;  //06.03.12 nk add
{$ENDIF}
  function GetDrive: string;
  function GetDriveFree: Char;                          //05.09.13 nk old=GetDiveFree / 24.07.10 nk add
  function GetDriveLetter(VolumeLabel: string; NoFloppy: Boolean): Char; //25.07.10 nk add
  function GetTempFile(Ext: string = TMP_END): string;  //07.12.09 nk add
  function GetWinDir: string;
  function GetSysDir: string;
  function GetTmpDir: string;
  function GetAppDir: string;
  function GetProgPath: string; //20.03.08 nk add ff
  function GetDataPath: string;
  function GetFontPath: string;  //26.03.08 nk add
  function GetDocuPath(Common: Boolean): string;
  function GetFolderPath(CSIDL: Integer): string;
  function GetDrives(DiskType: TDiskType; DriveList: TStrings): Integer;
  function GetDiskType(DriveName: string): TDiskType;
  function GetDiskSize(DriveName: string; SizeType: TFileSize): Int64;
  function GetDiskName(DriveName: string): string; 
  function GetDiskCode(DriveName: string): string;
  function GetFileSystem(DriveName: string): string;
  function GetDirSize(DirName: string; WithSub: Boolean): Int64;
  function GetParentDir(DirName: string): string;
  function GetSubFolders(DirName: string; Ignore: string = ''): Boolean; //V5//10.01.17 nk add
  function GetSubDirs(DirName: string; DirList: TStrings): Integer;
  function GetFileSubDirs(DirName, FilName: string; DirList: TStrings; Sortby: TSortMode = smNone): Integer; //27.01.12 nk add Sortby
  function GetFileTree(Tree: TTreeView; DirName: string; Node: TTreeNode; Mode: TFindMode; Excl: string = cEMPTY; Incl: string = cEMPTY): Integer; //V5//30.11.15 nk add Excl and Incl
  function GetFileType(FilName: string): string;
  function GetFileSize(FilName: string): Int64;
  function GetFileDate(FilName, Format: string): string;
  function GetFilePath(FilName, DirName: string): string;
  function GetFileModify(FilName: string): TDateTime;  //26.08.09 nk add
  function GetFileTimes(FilName: string; var Times: array of TDateTime; Local: Boolean = True): Boolean;  //26.08.09 nk add
  function GetFileLines(FilName, Search: string; Mode: TFindMode; Encoding: string = FILE_ENCODING): Integer;
  function GetFiles(FilName: string; FileList: TStrings; Mode: TFindMode): Integer;
  function GetFileFilter(DirName: string; FileList: TStrings; FDel: TCharSet; FLen: Byte = 0; Ignore: string = cEMPTY): Integer; //01.08.12 nk add Ignore / 16.12.10 nk add
  function GetFileCount(DirName, FilName: string; WithDir: Boolean = False): Integer; //22.09.12 nk add WithDir
  function FindFileInSubdirs(DirName, FilName: string): Boolean; //52//19.11.19 nk add
  function GetFileInfo(FilName: string): TFileInfo;  //03.08.07 nk old=TFileName
  function GetFileEncoding(FilName: string): string; //08.06.11 nk add
  function GetLongFileName(FilName: string): string;
  function GetProperFileName(FilName: string): string; //17.07.07 nk add
  function GetFileGrid(FilName: string; Grid: TStringGrid; AltDel: string = ''; Encoding: string = FILE_ENCODING): Integer;  //03.07.08 nk add
  function SetFileGrid(FilName: string; Grid: TStringGrid; NoDups: Boolean; Encoding: string = FILE_ENCODING): Integer;  //05.07.08 nk add
  function SetFileDate(FilName: string; NewDate: TDateTime): Boolean;  //07.09.09 nk add
  function ExpandEnvPath(Path: string): string;  //24.03.08 nk add
  function ExtractFileBody(FilName: string): string;   //17.07.07 nk add
  function TrashFile(FilName: string): Boolean;
  function DeleteDir(DirName: string; HideDialog: Boolean = True): Boolean; //06.02.19 nk opt/old=HideDialog: Boolean = False
  function DeleteFiles(DirName, FilName: string; Size: Integer = 0): Integer;
  function DeleteLines(FilName, Search: string; Mode: TFindMode; Encoding: string = FILE_ENCODING): Integer; //16.07.07 nk add
  function CopyFileAdv(Source, Dest, FilName: string): string;  //12.12.10 nk add
  function CopyFiles(Source, Dest, FilName: string; Overwrite: Boolean = True; Attrib: Integer = 0): Integer; //16.12.09 nk add Overwrite and Attr
  function CreateFolder(DirName: string; Clear: Boolean): Boolean;
  function ReadFromFile(FilName: string; Line: Integer; Encoding: string = FILE_ENCODING): string;
  function WriteToFile(FilName, Text: string; Encoding: string = FILE_ENCODING): Boolean; //xe//08.06.11 nk add encoding
  function CountInFile(FilName, Search: string; Mode: TFindMode; Encoding: string = FILE_ENCODING): Integer; //27.01.08 nk add
  function FindInFile(FilName, Search: string; Mode: TFindMode; Encoding: string = FILE_ENCODING): Integer;
  function ReplaceInXML(FilName, Old, New: string; IsCase: Boolean): Boolean; //V5//08.04.16 nk add
  function ReplaceInFile(FilName, Old, New: string; IsCase: Boolean; AsUnicode: Boolean = False): Boolean; //27.12.10 nk add AsUnicode
  function ReplaceAllInFile(FilName, RepForm: string; RepList: TStringList): Boolean; //28.10.12 nk add
  function WriteSignature(FilName: string; Signature: AnsiString): Integer; //xe//12.01.08 nk add ff
  function ReadSignature(FilName: string): AnsiString;                      //xe//
  function CopyFileProgress(Source, Dest: string; Progress: TProgressBar): Boolean;
  function CopyFilesProgress(Source, Dest, FilName: string; Progress: TProgressBar): Integer;  //10.08.18 nk add
  function OperFileShell(Source, Dest: string; Oper: TFileOper; Head: string = cEMPTY): Boolean; //24.03.08 nk add Head
  function OpenFileProperties(FilName: string): Boolean; //07.12.09 nk add
  function LockFile(FilName, Locked: string): Boolean; //07.05.07 nk add
  procedure ExtractResource(ResType: PChar; ResName, FilName: string);  //xe//13.01.08 nk add ff
  procedure CompressFile(FilIn, FilOut: string);
  procedure DecompressFile(FilIn, FilOut: string);
  procedure OpenExplorer(AFolder: string); //11.08.18 nk add
  procedure ShowFileInfo(FilName: string; ListBox: TListBox);
  procedure ReadALine(var ReadFile: Text; var ReadString: string; Encoding: string = FILE_ENCODING);        //08.06.11 nk add
  procedure WriteALine(var WriteFile: Text; WriteString: string; Encoding: string = FILE_ENCODING);         //08.06.11 nk add
  procedure SetFileEncoding(FilName: string; HeadLine: string = COMMENT; Encoding: string = FILE_ENCODING); //21.06.11 nk add

implementation

function CopyDir(const FromDir, ToDir: string): Boolean;
var //15.08.18 nk opt - call like: if CopyDir('D:\download', 'E:\') then...
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do begin
    wFunc  := FO_COPY;
    fFlags := FOF_SILENT or FOF_NOCONFIRMMKDIR or FOF_FILESONLY or FOF_NOCONFIRMATION or FOF_NOERRORUI;
    pFrom  := PChar(FromDir + cNUL);
    pTo    := PChar(ToDir   + cNUL);
  end;
  Result := (ShFileOperation(fos) = NERR_SUCCESS);
end;

function CheckDir(var DirName: string): Boolean;
// Try to normalize given directory name and check if it exists
// Input:  DirName = directory or drive name to check
//         like: 'A:', 'a:\', '.', '..', '\', '\\', 'C:\Temp', 'm:\net\..'
//         where: 'a:'..'Z:' = drive letter
//               '.'  = current directory
//               '..' = parent directory
//               '\'  = root directory
//               '\\' = network direktory
// Output: DirName = normalized directory name with trailing slash
//         like: 'C:\Temp\' or '\\server\D$\'
// Return: True if successful or False if failed
// Remark: Turn off critical errors to supress error dialog box
var //xe//
  err: Word;
begin
  Result    := False;
  FileError := feNoError;
  err       := NERR_SUCCESS;

  DirName := StringReplace(DirName, cAPHOS, cEMPTY, [rfReplaceAll]);
  DirName := StringReplace(DirName, cQUOTE, cEMPTY, [rfReplaceAll]);
  DirName := Trim(DirName);

  if DirName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if DirName[1] = MYDIR then begin
    DirName := StringReplace(DirName, PARENTDIR, GetParentDir(MYDIR), []);
    DirName := StringReplace(DirName, OWNDIR, GetParentDir(cEMPTY), []);
  end else
  if DirName[1] = PATHDEL then begin
    if Length(DirName) = 1 then begin
      DirName := GetDrive; //root dir
    end else begin
      if Pos(NETDIR, DirName) = 1 then begin //network dir
        DirName := IncludeTrailingPathDelimiter(DirName);
      end else begin
        DirName := StringReplace(DirName, PATHDEL, GetDrive, []);
      end;
    end;
  end else
  if CharInSet(DirName[1], SMALL_CHARS) then begin //xe//
    if Pos(cCOLON, DirName) = 2 then begin
      DirName[1] := Chr(Ord(DirName[1]) - ASCII_SPACE); //upper case
      DirName := IncludeTrailingPathDelimiter(DirName);
    end else begin
      DirName := IncludeTrailingPathDelimiter(ExpandFileName(DirName));
    end;
  end else
  if CharInSet(DirName[1], BIG_CHARS) then begin //xe//
    if Pos(cCOLON, DirName) = 2 then begin
      DirName := IncludeTrailingPathDelimiter(DirName);
    end else begin
      DirName := IncludeTrailingPathDelimiter(ExpandFileName(DirName));
    end;
  end else
  if CharInSet(DirName[1], INVALID_PATH_CHARS) then begin //xe//
    FileError := feInvalidParameter;
    Exit;
  end else begin
    DirName := IncludeTrailingPathDelimiter(ExpandFileName(DirName));
  end;

  try  //ignore critical errors
    err := SetErrorMode(SEM_FailCriticalErrors);
    if (DirName[1] <> PATHDEL) and (DiskSize(Ord(DirName[1]) - 64) = NONE)
      then FileError := feDriveNotReady
    else
      if not DirectoryExists(DirName) then FileError := feDirNotExist;
  finally
    SetErrorMode(err); //restore original error mode
  end;

  Result := (FileError = feNoError);
end;

function CheckFile(var FilName: string): Boolean;
// Try to normalize given file name and check if it exists
// Input:  FilName = file name to check (with optional path)
//         like: 'drv32.dll', '..\Temp\*.txt', '\\neptun\net\bde.cfg'
//         where: 'a:'..'Z:' = drive letter
//                '*' = wild card ('*.*' is not allowed!)
// Output: FilName = normalized file name with full path
//         like: 'C:\Win\Setup.exe' or '\\server\D$\*.ini'
// Return: True if successful or False if failed
// Remark: Turn off critical errors to supress error dialog box
var //xe//
  err: Word;
begin
  Result    := False;
  FileError := feNoError;
  err       := NERR_SUCCESS;

  FilName := StringReplace(FilName, cAPHOS, cEMPTY, [rfReplaceAll]);
  FilName := StringReplace(FilName, cQUOTE, cEMPTY, [rfReplaceAll]);
  FilName := Trim(FilName);

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if FilName[1] = MYDIR then begin
    FilName := StringReplace(FilName, PARENTDIR, GetParentDir(MYDIR), []);
    FilName := StringReplace(FilName, OWNDIR, GetParentDir(cEMPTY), []);
    FilName := ExcludeTrailingPathDelimiter(FilName);
  end else if
    Pos(NETDIR, FilName) = 1 then begin
    FilName := ExcludeTrailingPathDelimiter(FilName);
  end else if
    CharInSet(FilName[1], SMALL_CHARS) then begin //xe//
    if Pos(cCOLON, FilName) = 2 then begin
      FilName[1] := Chr(Ord(FilName[1]) - ASCII_SPACE); //upper case
      FilName := ExcludeTrailingPathDelimiter(FilName);
    end else begin
      FilName := ExcludeTrailingPathDelimiter(ExpandFileName(FilName));
    end;
  end else if
    CharInSet(FilName[1], BIG_CHARS) then begin //xe//
    if Pos(cCOLON, FilName) = 2 then begin
      FilName := ExcludeTrailingPathDelimiter(FilName);
    end else begin
      FilName := ExcludeTrailingPathDelimiter(ExpandFileName(FilName));
    end;
  end else if
    CharInSet(FilName[1], INVALID_FILE_CHARS) then begin //xe//
    FileError := feInvalidParameter;
    Exit;
  end else begin
    FilName := ExcludeTrailingPathDelimiter(ExpandFileName(FilName));
  end;

  try  //ignore critical errors
    err := SetErrorMode(SEM_FailCriticalErrors);
    if (FilName[1] <> PATHDEL) and (DiskSize(Ord(FilName[1]) - 64) = NONE)
      then FileError := feDriveNotReady
    else
      if not FileExists(FilName) then FileError := feFileNotExist;
  finally
    SetErrorMode(err); //restore original error mode
  end;

  Result := (FileError = feNoError);
end;

function GetCheckSum(FilName: string): DWORD;
const //20.02.14 nk opt for XE3 - return checksum of FilName (with path)
  BUFFLEN = 500;  //in hex format like '5FA3DA9F'
var               //CAUTION: FilName must exist!
  p: Pointer;
  fsize: DWORD;
  bfile: file of DWORD; //01.07.11 nk old=f
  buff: array [0..BUFFLEN] of DWORD;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  FileMode  := fmOpenRead or fmShareDenyNone;

  try
    AssignFile(bfile, FilName);

    try
      CloseFile(bfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Reset(bfile);

    Seek(bfile, FileSize(bfile) div 2);
    fsize := FileSize(bfile) - 1 - FilePos(bfile);
    if fsize > BUFFLEN then fsize := BUFFLEN;
    BlockRead(bfile, buff, fsize);
    Close(bfile);
    p := @buff;

{$IFDEF CPUX64} //20.02.14 nk opt for XE3
    raise Exception.Create('GetCheckSum does not work on 64-bit systems!');
{$ELSE}
    asm
      xor eax, eax
      xor ecx, ecx
      mov edi , p
      @again:
        add eax, [edi + 4 * ecx]
        inc ecx
        cmp ecx, fsize
      jl @again
      mov @Result, eax
    end;
{$ENDIF}
  except
    FileError := feException;
  end;
end;

{$IFNDEF TCAD} //52//20.04.20 nk add
function GetImageCheckSum(FilName: string): Integer;
var //29.07.12 nk opt
  i, j, cs: Integer;
  pixel: Integer;
  bmp: TBitmap;
  line: PIntegerArray;
begin
  cs := 0;
  Result := NONE;

  if not FileExists(FilName) then Exit;

  bmp := LoadGraphicFile(FilName);
  bmp.PixelFormat:= pf32bit;

  for j := 0 to bmp.Height - 1 do begin
    line := bmp.ScanLine[j];
    for i := 0 to bmp.Width - 1 do begin
      pixel := line^[i];
      if ((pixel <> 15577344) and (pixel <> 15311104) and (pixel <> 3816255)
      and (pixel <> 10526623) and (pixel <> 12303034) and (pixel <> 9013641)) then cs := cs + pixel;
    end;
  end;

  Result := Abs(cs);
  bmp.Free;
end;
{$ENDIF}

function GetDrives(DiskType: TDiskType; DriveList: TStrings): Integer;
// Return the number and a list of all drives of the requested type
// Input:  DiskType = type of disk (dtRemovable..dtRamDisk) or
//         dtUnknown for all types of disks
// Output: DriveList = strings in the format 'A:\'
// Return: number of drives found or 0 if failed or none
// Remark: DriveList will not be cleard - Drives will be append
var
  num: Longword;
  temp: array[0..MAX_PATH] of Char; //23.04.12 nk old=MAXBYTE
  drive: PChar;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;

  drive := temp;
  num   := GetLogicalDriveStrings(SizeOf(temp), temp);

  if (num <= 0) or (num > SizeOf(temp)) then begin
    FileError := feInternalError;
    Exit;
  end;

  while drive^ <> cNUL do begin
    if (DiskType = dtUnknown) or (GetDiskType(drive) = DiskType) then begin
      DriveList.Append(drive);
      Inc(Result);
    end;
    Inc(drive, 4);
  end;
end;

function GetDiskType(DriveName: string): TDiskType;
// Return the type of a given disk or drive
// Input:  DriveName = name of the drive in the format 'A:\'
// Output: None
// Return: Disk type (dtRemovable..dtRamDisk) or
//         dtUnknown if failed or unknown
// Remark: Only the first character of the drive name is used
begin
  Result    := dtUnknown;
  FileError := feNoError;
  DriveName := Trim(DriveName);

  if DriveName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  case GetDriveType(PChar(DriveName)) of
    DRIVE_REMOVABLE: Result := dtRemovable;
    DRIVE_FIXED    : Result := dtHarddisk;
    DRIVE_REMOTE   : Result := dtNetwork;
    DRIVE_CDROM    : Result := dtLaserdisk;
    DRIVE_RAMDISK  : Result := dtRamDisk;
  else
    if LeftStr(DriveName, 2) = NETDIR then  //09.07.09 nk add
      Result := dtNetwork
    else
      FileError := feDriveNotReady;
  end;
end;

function GetDiskSize(DriveName: string; SizeType: TFileSize): Int64;
// Return the requested size in bytes of the given disk or drive
// Input:  DriveName = name of the drive in the format 'A:\'
//         SizeType = fsTotal, fsFree, or fsUsed
// Output: None
// Return: Disk size in bytes or 0 if failed or not found
// Remark: Only the first character of the drive name is used
var
  size: Int64;
  free: Int64;
  dir: string;
  temp: array[0..4] of Char;
  disk: PChar;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  DriveName := Trim(DriveName);

  if DriveName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  temp[0] := DriveName[1];
  temp[1] := cCOLON;
  temp[2] := PATHDEL;
  temp[3] := cNUL;
  disk := temp;
  DriveName := string(disk);

  if not CheckDir(DriveName) then Exit;

  try
    dir := GetCurrentDir;
    if SetCurrentDir(DriveName) then begin
      GetDiskFreeSpaceEx(disk, free, size, nil);
    end else begin
      FileError := feDriveNotReady;
      Exit;
    end;

    SetCurrentDir(dir); //restore original directory
  except
    FileError := feException;
    Exit;
  end;

  case SizeType of
    fsTotal: Result := size;
    fsFree:  Result := free;
    fsUsed:  Result := size - free;
  end;
end;

function GetDiskName(DriveName: string): string;
// Return the name of the given disk or drive
// Input:  DriveName = name of the drive in the format 'A:\'
// Output: None
// Return: Disk name or empty if failed or not found
// Remark: Only the first character of the drive name is used
//         This call may take a long time because of slower drives like floppy
var
  nop: Cardinal;
  buff: array[0..MAX_PATH] of Char;
  temp: array[0..4] of Char;
  disk: PChar;
begin
  Result    := cEMPTY;
  FileError := feNoError;
  DriveName := Trim(DriveName);

  if DriveName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  buff := cEMPTY;
  temp[0] := DriveName[1];
  temp[1] := cCOLON;
  temp[2] := PATHDEL;
  temp[3] := cNUL;
  disk := temp;
  DriveName := string(disk);

  if not CheckDir(DriveName) then Exit; //this call may take a long time for 'A:'

  try //this call may take a long time for 'A:'
    GetVolumeInformation(disk, buff, SizeOf(buff), nil, nop, nop, nil, 0);
  finally
    Result := StrPas(buff);
  end;
end;

function GetDiskCode(DriveName: string): string;
// Return the serial number code of the given disk or drive
// Input:  DriveName = name of the drive in the format 'A:\'
// Output: None
// Return: Disk serial number code in the format 'XXXXXXXX'
//         (X = 0..F) or empty if failed or not found
// Remark: Only the first character of the drive name is used
//         See also GetSerialNo in USystem
var
  nop: Cardinal;
  num: Cardinal;
  temp: array[0..4] of Char;
  disk: PChar;
begin
  Result    := cEMPTY;
  FileError := feNoError;
  DriveName := Trim(DriveName);

  if DriveName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  //03.08.07 nk del buff := cEMPTY;
  temp[0] := DriveName[1];
  temp[1] := cCOLON;
  temp[2] := PATHDEL;
  temp[3] := cNUL;
  disk := temp;
  DriveName := disk;

  if not CheckDir(DriveName) then Exit;

  try
    //03.08.07 nk opt GetVolumeInformation(disk, buff, SizeOf(buff), @num, nop, nop, nil, 0);
    GetVolumeInformation(disk, nil, MAX_PATH, @num, nop, nop, nil, 0);
  finally
    Result := Format(FORM_SERNO, [num]); //03.08.07 nk old='%8.8X';
  end;
end;

function GetTempFile(Ext: string = TMP_END): string;
begin //07.12.09 nk add - create a unique temporary file name (w/o path)
  Result := FormatDateTime(FORM_FILE_LONG, Now) + Ext;
end;

function GetDirSize(DirName: string; WithSub: Boolean): Int64;
// Return the total bytes of all files in the given directory
// Input:  DirName = name of directory or drive
//         like: 'A:\', 'C:\Temp' or '\\server\D$\'
//         WithSub = search all subdirectories if True
// Output: None
// Return: Size of all files in the directory path in bytes
//         or 0 if failed or directory not exists
// Remark:
var
  drec: TSearchRec;
  files: Integer;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  
  if not CheckDir(DirName) then Exit;

  files := FindFirst(DirName + ALLFILES, faAnyFile, drec);

  while files = NERR_SUCCESS do begin
    Inc(Result, drec.Size);
    if (drec.Attr and faDirectory > NERR_SUCCESS) and (drec.Name[1] <> MYDIR) and (WithSub = True) then
      Inc(Result, GetDirSize(DirName + drec.Name, True));
    files := FindNext(drec);
  end;

  FindClose(drec);
end;

function GetDrive: string;
// Return the currently active drive
// Input:  None
// Output: None
// Return: Current drive in the format 'C:\'
// Remark:
var
  dir: string;
begin
  FileError := feNoError;

  GetDir(0, dir);
  Result := LeftStr(dir, 3);
end;

function GetDriveFree: Char;
// Return the next free drive letter from 'Z' down to 'C'
// Input:  None
// Output: None
// Return: Free drive in the format 'V' or NODRIVE if no letter is free
// Remark:
var
  i: Integer;
  drives: DWORD;
begin
  Result := NODRIVE;
  drives := GetLogicalDrives;

  for i := 25 downto 2 do begin //do not test 'A' and 'B' even if they are free
    if (drives and Round(IntPower(2, i))) = 0 then begin
      Result := Char(ASCII + i);
      Exit;
    end;
  end;
end;

function GetDriveLetter(VolumeLabel: string; NoFloppy: Boolean): Char;
// Return the drive letter of the given volume like 'C'
// Input:  VolumeLabel - Name of volume like 'System'
//         NoFloppy - Ignore slow drives 'A:' and 'B:' if True
// Output: None
// Return: Drive letter in the format 'C' or NODRIVE if volume not found
// Remark: This call may take a long time because slow drives like floppy
var
  i, dnum: Integer;
  disk: string;
  devs: TStringList;
begin
  Result := NODRIVE;
  devs   := TStringList.Create;

  try
    dnum := GetDrives(dtUnknown, devs);

    for i := 0 to dnum - 1 do begin
      disk := devs[i];

      if NoFloppy then //ignore slow floppy disks
        if (disk = 'A:\') or (disk = 'B:\') then Continue;

      if VolumeLabel = GetDiskName(disk) then begin
        Result := disk[1]; //return 1st char = drive letter like 'C'
        Break;
      end;
    end;
  finally
    devs.Free;
  end;
end;

function GetWinDir: string;
// Return the window directory path with trailing slash
// Input:  None
// Output: None
// Return: Path of the windows folder like 'C:\Windows\'
// Remark: 
var
  buff: array[0..MAX_PATH] of Char;
begin
  FileError := feNoError;
  
  GetWindowsDirectory(buff, MAX_PATH);
  Result := StrPas(buff);
  Result := IncludeTrailingPathDelimiter(Result);
end;

function GetSysDir: string;
// Return the system directory path with trailing slash
// Input:  None
// Output: None
// Return: Path of the system folder like 'C:\Windows\System32\'
// Remark: 
var
  buff: array[0..MAX_PATH] of Char;
begin
  FileError := feNoError;
  
  GetSystemDirectory(buff, MAX_PATH);
  Result := StrPas(buff);
  Result := IncludeTrailingPathDelimiter(Result);
end;

function GetTmpDir: string;
// Return the user temporary directory path with trailing slash
// Input:  None
// Output: None
// Return: Path of the temporary folder like 'C:\Users\Benny\AppData\Local\Temp\'
// Remark: 
var
  buff: array[0..MAX_PATH] of Char;
begin
  FileError := feNoError;
  
  GetTempPath(MAX_PATH, buff);
  Result := StrPas(buff);
  Result := IncludeTrailingPathDelimiter(Result);
end;

function GetAppDir: string;
// Return the program directory path with trailing slash
// Input:  None
// Output: None
// Return: Path of the application folder like 'C:\Programs\Test\'
// Remark: 
begin
  FileError := feNoError;

  Result := ExtractFilePath(Application.ExeName);
  Result := IncludeTrailingPathDelimiter(Result);
end;

function GetParentDir(DirName: string): string;
// Return the parent of the given directory with trailing slash
// Input:  DirName = name of the directory like 'C:\Program\Tools'
//         '' gets current directory
//         '.' gets parent of current directory
// Output: None
// Return: Path of the parent directory like 'C:\Program\' or empty if failed
// Remark:
var
  i: Integer;
begin
  Result    := cEMPTY;
  FileError := feNoError;
  DirName   := Trim(DirName);

  try
    if DirName = cEMPTY then begin //get current directory
      Result := IncludeTrailingPathDelimiter(GetCurrentDir);
      Exit;
    end;

    if DirName = MYDIR then DirName := GetCurrentDir;

    for i := Length(DirName) - 1 downto 1 do begin
      if DirName[i] = PATHDEL then begin
        Result := Copy(DirName, 1, i);
        Exit;
      end;
    end;
  except
    FileError := feException;
  end;
end;

function GetSubFolders(DirName: string; Ignore: string = ''): Boolean;
// Return number and list of all subdirectories in a given directory
// Input:  DirName = name of directory like 'C:\Windows'
// Return: Number of subdirectories or 0 if failed or none found
var
  drec: TSearchRec;
begin
  Result    := False;
  FileError := feNoError;

  if FindFirst(DirName + ALLOF, faDirectory, drec) = NERR_SUCCESS then begin
    repeat
      if (drec.Attr and faDirectory > NERR_SUCCESS) and (drec.Name[1] <> MYDIR) and (drec.Name <> Ignore) then begin
        Result := True;
        Break;
      end;
    until FindNext(drec) <> NERR_SUCCESS;
    FindClose(drec);
  end;
end;

function GetSubDirs(DirName: string; DirList: TStrings): Integer;
// Return number and list of all subdirectories in a given directory
// Input:  DirName = name of directory like 'C:\Windows'
// Output: DirList = strings in the format 'System32'
// Return: Number of subdirectories or 0 if failed or none found
// Remark: DirList will not be cleard - SubDirs will be append
var
  drec: TSearchRec;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;

  if not CheckDir(DirName) then Exit;

  if FindFirst(DirName + ALLOF, faDirectory, drec) = NERR_SUCCESS then begin
    repeat
      if (drec.Attr and faDirectory > NERR_SUCCESS) and (drec.Name[1] <> MYDIR) then begin
        DirList.Append(drec.Name);
        Inc(Result);
      end;
    until FindNext(drec) <> NERR_SUCCESS;
    FindClose(drec);
  end;
end;

function GetFileSubDirs(DirName, FilName: string; DirList: TStrings; Sortby: TSortMode = smNone): Integer;
// Modified: 23.09.12 nk - add Sortby to sort DirList by name or timestamp
// Return number and list of all subdirectories in a given directory
// with one or more matching files
// Input:  DirName = name of directory like 'C:\Windows'
//         FilName = name of searched files like 'drv*.dll'
//         Sortby  = smNone     - no sorting (default)
//                   smName     - sort by directory name
//                   smOldest   - sort by timestamp -> oldest first
//                   smYoungest - sort by timestamp -> youngest first
// Output: DirList = strings in the format 'System32'
// Return: Number of subdirectories or 0 if failed or none found
// Remark: DirList will not be cleard - SubDirs found will be append to existing items
const
  MAX_TIM = UInt64(99990101000000); //format 'yyyymmddhhnnss'
var
  i, tvar: Integer; //27.01.12 nk add
  isdir: Boolean;   //23.09.12 nk add
  tim: UInt64;
  dir, key, val: string;
  drec: TSearchRec;
  dlist: TStringList;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  
  if not CheckDir(DirName) then Exit;

  tvar  := CLEAR;                  //23.09.12 nk add
  isdir := Pos(cDOT, FilName) = 0; //23.09.12 nk add - FilName = sub folder name
  dlist := TStringList.Create;     //27.01.12 nk add ff
  dlist.Sorted := False;
  dlist.Duplicates := dupAccept;

  if FindFirst(DirName + ALLOF, faDirectory, drec) = NERR_SUCCESS then begin
    repeat
      if (drec.Attr and faDirectory > NERR_SUCCESS) and (drec.Name[1] <> MYDIR) then begin
        dir := DirName + PATHDEL + drec.Name + PATHDEL;
        if (GetFileCount(dir, FilName, isdir) > NERR_SUCCESS) then begin //23.09.12 nk add isdir
          if Sortby in [smOldest, smYoungest] then begin                 //27.01.12 nk add ff
            Inc(tvar); //23.09.12 nk add/opt ff (prevent the same timestamp)
            key := FormatDateTime(FORM_FILE_LONG, drec.TimeStamp);
            tim := StrToInt64(key) + tvar;
            if Sortby = smYoungest then
              tim := MAX_TIM - tim;
            key := UIntToStr(tim);
          end else begin
            key := drec.Name;
          end;
          val := drec.Name;
          dlist.Values[key] := val; //old=DirList.Append(drec.Name);
          Inc(Result);
        end;
      end;
    until FindNext(drec) <> NERR_SUCCESS;
    FindClose(drec);
  end;

  //27.01.12 nk add ff - sort directories by name or timestamp
  if Sortby <> smNone then dlist.Sort;

  for i := 0 to dlist.Count - 1 do
    DirList.Append(dlist.ValueFromIndex[i]);

  dlist.Free;
end;

function GetProgPath: string;
begin //return program files folder like 'C:\Program Files\'
  Result := IncludeTrailingPathDelimiter(GetFolderPath(CSIDL_PROGRAM_FILES));
end;

function GetDataPath: string;
begin //return common application data folder like 'C:\ProgramData\'
  Result := IncludeTrailingPathDelimiter(GetFolderPath(CSIDL_COMMON_APPDATA));
end;

function GetFontPath: string;
begin //return virtual fonts folder like 'C:\Windows\Fonts\'
  Result := IncludeTrailingPathDelimiter(GetFolderPath(CSIDL_FONTS));
end;

function GetDocuPath(Common: Boolean): string;
begin //if return common or user document folder
  if Common then   //like 'C:\All Users\Documents\'
    Result := IncludeTrailingPathDelimiter(GetFolderPath(CSIDL_COMMON_DOCUMENTS))
  else             //or 'C:\Users\Benny\Documents\'
    Result := IncludeTrailingPathDelimiter(GetFolderPath(CSIDL_PERSONAL));
end;

function GetFolderPath(CSIDL: Integer): string;
var
  path: array [0..MAX_PATH] of Char;
begin
  SHGetFolderPath(0, CSIDL, 0, SHGFP_TYPE_CURRENT, @path[0]);
  Result := path;
end;

function GetFileType(FilName: string): string;
// Return the type of given file (with optional path)
// Input:  FilName = name of the file like 'C:\Temp\drv32.sys'
// Output: None
// Return: Type of the file or empty if failed or not found
// Remark: The file type is in the windows system language
var
  info: TSHFileInfo;
begin
  Result    := cEMPTY;
  FileError := feNoError;

  try
    FillChar(info, SizeOf(info), cNUL);
    SHGetFileInfo(PChar(FilName), 0, info, SizeOf(info), SHGFI_TYPENAME);
    Result := info.szTypeName;
  except
    FileError := feException;
  end;
end;

function GetFileSize(FilName: string): Int64;
// Return the size of the given file in bytes (with optional path)
// Input:  FilName = name of the file like 'C:\Temp\drv32.sys'
// Output: None
// Return: Size of the file in bytes or 0 if failed or file not exits
// Remark: 
var
  frec: TSearchRec;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  
  if FindFirst(FilName, faAnyFile, frec) = NERR_SUCCESS then begin
    Result := frec.Size;
    FindClose(frec);
  end else begin
    FileError := feFileNotExist;
  end;
end;

function GetFileDate(FilName, Format: string): string;
// Return the timestamp of the given file in the requested format
// Input:  FilName = name of the file like 'C:\Temp\drv32.sys'
//         Format = time and date format like 'dd.mm.yyyy hh:nn'
// Output: None
// Return: Formatted string or empty if failed or file not exits
// Remark: Use pre-defined formats for country specific outlook
//         like 'LongDateFormat' or 'ShortTimeFormat'
var        //xe//use Unicode function FileAge
//age: Integer;
  date: TDateTime;
begin
  Result    := cEMPTY;
  FileError := feNoError;

  if FileAge(FilName, date, True) then
    Result := FormatDateTime(Format, date)
  else
    FileError := feInternalError;
end;

function SetFileDate(FilName: string; NewDate: TDateTime): Boolean;
// Set the last write date and time of FilName to NewDate
// Input:  FilName = name of the file like 'C:\Temp\drv32.sys'
//         NewDate = time and date in the TDateTime format
// Output: None
// Return: True if date and time was set successfully, else False
// Remark: Read/Write permission for FilName are required. If the function
//         fails, use GetLastError for extended error information
var
  hfile: Integer;
  ftime: TFileTime;
  lft: TFileTime;
  lst: TSystemTime;
begin
  Result    := False;
  hfile     := NERR_SUCCESS;
  FileError := feNoError;

  try
    DecodeDate(NewDate, lst.wYear, lst.wMonth, lst.wDay);
    DecodeTime(NewDate, lst.wHour, lst.wMinute, lst.wSecond, lst.wMilliSeconds);

    if SystemTimeToFileTime(lst, lft) then begin
      if LocalFileTimeToFileTime(lft, ftime) then begin
        hfile  := FileOpen(FilName, fmOpenReadWrite or fmShareExclusive);
        Result := SetFileTime(hfile, nil, nil, @ftime);
      end;
    end;
  finally
    FileClose(hfile);
  end;
end;

function GetFileModify(FilName: string): TDateTime;
// Return the timestamp of the last modification of the file FilName
// Input:  FilName = name of the file like 'C:\Temp\drv32.sys' (Unicode)
// Output: None
// Return: DateTime or NERR_SUCCESS if failed or file not exits
// Remark: Returns the same as SysUtils.FileAge
begin //xe//use Unicode function FileAge
  Result    := NERR_SUCCESS;
  FileError := feNoError;

  try
    if not FileAge(FilName, Result, True) then
     Result := NERR_SUCCESS;
  except
    FileError := feException;
  end;
end;

function GetFileTimes(FilName: string; var Times: array of TDateTime; Local: Boolean = True): Boolean;
// 14.06.11 nk opt
// Return the date and time that FilName was created, last accessed, and last modified
// Input:  FilName = name of the file or directory like 'C:\Temp\drv32.sys' or 'C:\Temp'
//         Local = True = use local timezone / False = use UTC timezone
// Output: Times[0] = date and time the file or directory was created
//         Times[1] = date and time the file or directory was last accessed
//         Times[2] = date and time the file or directory was last written
// Return: True if successful or False if failed or file not exits
// Remark: Not all file systems can record creation and last access times and not
//         all file systems record them in the same manner. E.g. the write time has
//         a resolution of 2sec and access time has a resolution up to one hour.
//         Therefore, the GetFileTimes function may not return the same file time
//         information as using the SetFileTime function.
//         Last access time is not updated on NTFS volumes by default.
//         NTFS records times on disk in UTC - Set Local = True for timezone correction
//         Use FormatDateTime(FORM_DATE_LOG, Times[0]) for a time and/or date string
var
  bias: Double;
  h: THandle;
  adat, cdat, wdat: TFileTime;
  sts: SYSTEMTIME;
  tzi: TTimeZoneInformation;
begin
  Result    := False;
  bias      := CLEAR;
  FileError := feNoError;

  try //17.09.09 nk opt ff
    h := FileOpen(FilName, fmOpenRead or fmShareDenyNone);

    if h > NERR_SUCCESS then begin
      if not GetFileTime(h, @cdat, @adat, @wdat) then Exit;

      if Local then begin
        if GetTimeZoneInformation(tzi) <> BIT_MASK then
          bias := GetUTCTime - Now;    //14.06.11 nk opt
        //bias := tzi.Bias / MIN_DAY;  //bias may be wrong (-60 instead of -120)!?!
      end;

      if FileTimeToSystemTime(cdat, sts) then   //file creation time
        Times[0] := SystemTimeToDateTime(sts) - bias;

      if FileTimeToSystemTime(adat, sts) then   //last access time
        Times[1] := SystemTimeToDateTime(sts) - bias;

      if FileTimeToSystemTime(wdat, sts) then   //last write time
        Times[2] := SystemTimeToDateTime(sts) - bias;

      FileClose(h);
      Result := True;
    end;
  except
    Result := False;
    FileError := feException;
  end;
end;

function GetFilePath(FilName, DirName: string): string;
// Return the full path of a file searched in given directory
// Input:  FilName = name of searched file like 'drv32.dll'
//         DirName = root of search path like 'C:\Win' (Unicode)
// Output: None
// Return: Full directory path with trailing slash or
//         empty if failed or file not found
// Remark:
var
  buff: array[0..MAX_PATH] of AnsiChar; //xe//
begin
  Result    := cEMPTY;
  FileError := feNoError;
  FilName   := Trim(FilName);
  DirName   := Trim(DirName);

  if (FilName = cEMPTY) or (DirName = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  FillChar(buff, SizeOf(buff), cNUL);

  //nk//NOT Unicode! - Use SearchTreeForFileW (Unicode)
  if SearchTreeForFile(PAnsiChar(AnsiString(DirName)), PAnsiChar(AnsiString(FilName)), buff) then  //xe//
    Result := ExtractFilePath(string(buff)) //xe//
  else
    FileError := feFileNotExist;
end;

function GetFiles(FilName: string; FileList: TStrings; Mode: TFindMode): Integer;
// Return number and list of all files matching given search string
// Input:  FilName = name of searched file (with optional path)
//                   like 'drv*.dll' or 'C:\Windows\*.dll' or
//                   like '!.tmp' to ignore all .tmp files
//         Mode    = fmClear  - clear FileList
//                   fmExt    - file names with file extension
//                   fmSort   - sort FileList
//                   fmCase   - ignore case for sorting
//                   fmNoTemp - ignore .tmp, .sic and .bak files //27.02.12 nk add
//                   fmNoFdel - ignore files with delimiter '_'  //23.06.13 nk add
// Output: FileList = strings of matching file like 'pdriver.sys' (w/o path!)
// Return: Number of files found, -1 if failed or 0 if no files found
var //22.11.15 nk opt - FileList can be nil
  ok: Boolean;
  ext, non: string;
  frec: TSearchRec;
begin
  Result    := CLEAR;
  FileError := feNoError;
  FilName   := Trim(FilName);

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  //29.07.12 nk add ff - find all files except FilName
  if Pos(NONEOF, FilName) > 0 then begin
    non := StrSplit(FilName, NONEOF, 1);
    FilName := StrSplit(FilName, NONEOF, 0);
    FilName := FilName + ALLFILES;
  end else begin
    non := cEMPTY;
  end;

  try
    ok := False; //22.11.15 nk add
    FileListing.Clear;
    FileListing.Sorted := False;
    FileListing.CaseSensitive := not (fmCase in Mode);

    if (fmClear in Mode) and (FileList <> nil) then FileList.Clear; //29.09.12 nk opt

    if FindFirst(FilName, faAnyFile, frec) = NERR_SUCCESS then begin
      repeat
        if (frec.Attr <> faDirectory) and (frec.Name[1] <> MYDIR) then begin
          ext := LowerCase(ExtractFileExt(frec.Name)); //29.07.12 nk mov up - get file extension (with dot)

          if fmNoTemp in Mode then begin               //27.02.12 nk add ff
            ok := ((ext <> BAK_END) and (ext <> SIC_END) and (ext <> TMP_END));
          end else begin
            ok := True;
          end;

          if fmNoFdel in Mode then begin               //23.06.13 nk add ff
            ok := (Pos(FILEDEL, frec.Name) = 0);
          end else begin
            ok := True;
          end;

          if non <> cEMPTY then begin                  //29.07.12 nk add ff
            ok := (ext <> non);
          end;

          if ok then begin
            if fmExt in Mode then                      //file name with extension
              FileListing.Append(frec.Name)
            else                                       //file name w/o extension
              FileListing.Append(ExtractFileBody(frec.Name)); //26.04.08 nk opt
          end;
        end;
      until FindNext(frec) <> NERR_SUCCESS;
      FindClose(frec);
    end;

    if fmSort in Mode then FileListing.Sort;

    if FileList <> nil then      //29.09.12 nk add/opt ff
      FileList.AddStrings(FileListing);

    Result := FileListing.Count; //29.09.12 nk old=FileList
  except
    if FileList <> nil then
      FileList.Clear;            //29.09.12 nk add
    FileError := feException;
    Result := NONE;
  end;
end;

function GetFileFilter(DirName: string; FileList: TStrings; FDel: TCharSet; FLen: Byte = 0; Ignore: string = cEMPTY): Integer;
var //01.08.12 nk opt - fill FileList with available file filters like 'Symbol*' (w/o *)
  i: Integer;           //FileList is case sensitive, sorted, but not cleard
  fname, fitem: string; //Del is a list of delimiting chars like ['0'..'9', '_'] or
  flist: TStringList;   //a simple number determining the length of the file name
  frec: TSearchRec;     //define file ending to Ignore (like '.tmp')
begin
  Result    := CLEAR;
  FileError := feNoError;
  DirName   := Trim(DirName);

  if DirName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  DirName := IncludeTrailingPathDelimiter(DirName) + ALLFILES;
  flist   := TStringList.Create;

  try
    flist.Duplicates    := dupIgnore;
    flist.Sorted        := True;
    flist.CaseSensitive := True;

    if FindFirst(DirName, faAnyFile, frec) = NERR_SUCCESS then begin
      repeat
        if (frec.Attr <> faDirectory) and (frec.Name[1] <> MYDIR) then begin
          fitem := cEMPTY;
          fname := frec.Name;

          if (Ignore = cEMPTY) or (Pos(Ignore, fname) = 0) then begin //01.08.12 nk add
            for i := 1 to Length(fname) do begin
              if FLen = 0 then begin
                if CharInSet(fname[i], FDel) then Break; //xe//
              end else begin
                if i = FLen + 1 then Break;
              end;
              fitem := fitem + fname[i];
            end;

            flist.Append(fitem);
          end;
        end;
      until FindNext(frec) <> NERR_SUCCESS;
      FindClose(frec);
    end;

    flist.Sort; //sort list and remove duplicate items

    for i := 0 to flist.Count - 1 do
      FileList.Append(flist[i]);

    Result := FileList.Count;
  except
    FileList.Clear;
    FileError := feException;
    Result    := NONE;
  end;

  flist.Free;
end;

function GetFileGrid(FilName: string; Grid: TStringGrid; AltDel: string = ''; Encoding: string = FILE_ENCODING): Integer;
// 23.09.12 nk opt - Use ReplaceInFile(True) if FilName is Unicode encoded
// Return string grid filled with comma seperated strings from the file FilName
// Input:  FilName = name of file to load (with optional path)
//                   like 'contacts.csv' or 'C:\Windows\mail.contacts'
//         Grid    = empty string grid (will be overwritten)
//         Encoding = character set encoding ('ISO-8859-1' or 'UTF-8')
// Return: Number of grid rows filled, -1 if failed or 0 if no lines found
// Remark: The string grid will be cleared and dimensioned correctly
var
  c, r: Integer;
  line: string;
  temp: string;
  tfile: TextFile;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  FilName   := Trim(FilName);
  FileMode  := fmOpenRead or fmShareDenyNone; //27.08.09 nk add

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  try
    if AltDel <> cEMPTY then  //05.07.08 nk add - replace alternative delimiter
      ReplaceInFile(FilName, AltDel, cCOMMA, False);

    with Grid do begin
      r := FixedRows - 1;  //05.07.08 nk opt ff

      AssignFile(tfile, FilName);

      try
        CloseFile(tfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
      except
        IOResult;         //ignore if file was already closed
      end;

      Reset(tfile);

      repeat
        ReadALine(tfile, line, Encoding); //08.06.11 nk add Encoding

        if line <> cEMPTY then begin
          c := FixedCols - 1;
          Inc(r);
          while StrCut(line, temp) do begin
            Inc(c);
            if RowCount <= r then RowCount := RowCount + 1;
            if ColCount <= c then ColCount := ColCount + 1;
            Cells[c, r] := temp;
          end;
        end;
      until EOF(tfile);
    end;

    CloseFile(tfile);
    Result := r;
  except
    FileError := feException;
    Result := NONE;
  end;
end;

function SetFileGrid(FilName: string; Grid: TStringGrid; NoDups: Boolean; Encoding: string = FILE_ENCODING): Integer;
// 08.06.11 nk opt - Save the rows of the string grid as comma seperated strings into the file FilName
// Input:  FilName = name of file to save (with optional path)
//                   like 'contacts.csv' or 'C:\Windows\mail.contacts'
//         Grid    = filled string grid to save
//         NoDups  = sort and remove duplicated strings if True
//         Encoding = character set encoding ('ISO-8859-1' or 'UTF-8')
// Return: Number of grid rows saved, -1 if failed or 0 if no rows found
// Remark: The file will be overwrtiien without any warnings!
//         Each row is saved as a single line, each cell of this row is
//         seperated by comma.
//         Multi-word strings would not be quoted !
// Format: col_00, col_01, col_02, col_03
//         col_10, col_11, col_12, col_13...EOF
var
  r: Integer;
  temp: string;
  //28.12.09 nk opt buff: TStringList;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  FilName   := Trim(FilName);

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  try
    if FileExists(FilName) then DeleteFile(FilName);

    FileListing.Clear;

    if NoDups then begin  //05.07.08 nk add
      FileListing.Duplicates := dupIgnore;
      FileListing.Sorted     := True;
    end;

    with Grid do begin
      for r := FixedRows to RowCount - 1 do begin
        temp := StringReplace(Rows[r].CommaText, cQUOTE, cEMPTY, [rfReplaceAll]);
        FileListing.Append(temp);
      end;
    end;

    FileListing.Sort;

    if Encoding = ENCODING_UTF8 then //08.06.11 nk add / opt aff
      FileListing.SaveToFile(FilName, TEncoding.UTF8)
    else
      FileListing.SaveToFile(FilName);
    //28.12.09 nk opt buff.Free;
    Result := GetFileLines(FilName, cCOMMA, [fmCase], Encoding);
  except
    FileError := feException;
    Result := NONE;
  end;
end;

function GetFileTree(Tree: TTreeView; DirName: string; Node: TTreeNode; Mode: TFindMode; Excl: string = cEMPTY; Incl: string = cEMPTY): Integer;
// Return number and tree of all subdirectories and files in the folder DirName
// Input:  DirName = name of root directory (with optional trailing slash)
//                   like 'C:\Windows\system32\'
//         Node    = tree node where tree begins (nil = root)
//         Mode    = fmClear - clear the whole tree
//                   fmFiles - directories with files
//                   fmExt   - file names with file extension
//                   fmDirs  - get only files in sub directories and not in root directory //V5//23.06.16 nk add
//         Excl    = Folders and files must ignore Excl (like 'Models' or '.xlm') not case-sensitive!
//         Incl    = Folders must contain Incl (like 'Video_' or 'Pass_.swt') not case-sensitive!
// Output: Tree    = tree view filled with all directories and files found
// Return: Number of files found, -1 if failed or 0 if no files found
// Remark: The disk is scanned recursively (the function calls itself)
var //07.01.16 nk opt / add Excl and Incl to define file or folder names
  ext, inc: string;
  drec: TSearchRec;
  temp: TTreeNode;
begin
  DirName := IncludeTrailingPathDelimiter(DirName);
  Excl    := LowerCase(Excl);
  Incl    := LowerCase(Incl);
  inc     := cEMPTY;
  ext     := cEMPTY;

  if Pos(EXTDEL, Incl) > 0 then begin  //V5//23.06.16 nk add like 'Pass_.swt'
    ext := EXTDEL + StrSplit(Incl, EXTDEL, 1); //'.swt'
    inc := StrSplit(Incl, EXTDEL, 0);          //'Pass_'
  end else begin
    ext := cEMPTY;
    inc := Incl;
  end;

  try
    with Tree.Items do begin
      BeginUpdate;
      if (fmClear in Mode) then Clear;

      if FindFirst(DirName + ALLFILES, faDirectory, drec) = NERR_SUCCESS then begin
        repeat
          if (drec.Attr and faDirectory = faDirectory) and (drec.Name[1] <> MYDIR) then begin
            if drec.Attr and faDirectory > NERR_SUCCESS then begin      //add folder (parent node)
              if (Excl = cEMPTY) or (Excl = OWNDIR) or (Pos(Excl, LowerCase(drec.Name)) = 0) then begin //30.11.15 nk add ff
                if (Excl <> OWNDIR) or ((Excl = OWNDIR) and (Pos(Incl, LowerCase(drec.Name)) > 0)) then begin
                  Node := AddChild(Node, drec.Name);
                  temp := Node.Parent;
                  GetFileTree(Tree, DirName + drec.Name, Node, Mode - [fmClear] + [fmDirs], OWNDIR, Incl); //V5//23.06.16 nk add fmDirs
                  Node := temp;
                end;
              end;
            end;
          end else begin
            if (fmFiles in Mode) and (drec.Name[1] <> MYDIR) then begin //add file (child node)
              if (fmExt in Mode) then begin
                if (Excl = cEMPTY) or (Excl = OWNDIR) or (Pos(Excl, LowerCase(drec.Name)) = 0) then begin //30.11.15 nk add ff
                  if (inc = cEMPTY) or (Pos(inc, LowerCase(drec.Name)) > 0) then begin //V5//23.06.16 nk add/opt ff
                    if (ext = cEMPTY) or (Pos(ext, LowerCase(drec.Name)) > 0) then begin
                      if (fmDirs in Mode) then AddChild(Node, drec.Name);
                    end;
                  end;
                end;
              end else begin                                            //file name w/o extension
                if (Excl = cEMPTY) or (Excl = OWNDIR) or (Pos(Excl, LowerCase(drec.Name)) = 0) then begin //30.11.15 nk add ff
                  if (inc = cEMPTY) or (Pos(inc, LowerCase(drec.Name)) > 0) then begin //V5//23.06.16 nk add/opt ff
                    if (ext = cEMPTY) or (Pos(ext, LowerCase(drec.Name)) > 0) then begin
                      if (fmDirs in Mode) then AddChild(Node, (ExtractFileBody(drec.Name)));
                    end;
                  end;
                end;
              end;
            end;
          end;
        until FindNext(drec) <> NERR_SUCCESS;
        FindClose(drec);
      end;

      EndUpdate;
      Result := Count;
    end;
  except
    FileError := feException;
    Result    := NONE;
  end;
end;

function GetFileCount(DirName, FilName: string; WithDir: Boolean = False): Integer;
var //52//19.11.19 nk opt - Get number of files (and subdirectories) in DirName
  frec: TSearchRec;   //DirName with or w/o trailing slash
begin                 //FilName may have wildcards like '*.pas'
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  FilName   := Trim(FilName);
  DirName   := IncludeTrailingBackslash(Trim(DirName)); //52//19.11.19 nk opt

  if (FilName = cEMPTY) or (DirName = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if FindFirst(DirName + FilName, faAnyFile, frec) = NERR_SUCCESS then begin
    repeat //22.09.12 nk add WithDir - count subdirectories too
      if (WithDir or (frec.Attr <> faDirectory)) and (frec.Name[1] <> MYDIR) then Inc(Result);
    until FindNext(frec) <> NERR_SUCCESS;
    FindClose(frec);
  end;
end;

function FindFileInSubdirs(DirName, FilName: string): Boolean;
var //52//19.11.19 nk add - return True if at least one matching file is in subdirectories
  frec: TSearchRec;       //DirName with or w/o trailing slash
begin                     //FilName as substring like 'Data' or '.swn' (w/o '*')
  Result    := False;     //Output: Global FileMatching (clear before call this function)
  FileError := feNoError;
  FilName   := Trim(FilName);
  DirName   := IncludeTrailingBackslash(Trim(DirName));

  if FindFirst(DirName + ALLFILES, faAnyFile or faDirectory, frec) = 0 then begin
    try
      repeat
        if (frec.Attr and faDirectory) = NERR_SUCCESS then begin
          if Pos(FilName, frec.Name) > 0 then
            Inc(FileMatching);
        end else begin
          if (frec.Name <> MYDIR) and (frec.Name <> UPDIR) then
            FindFileInSubdirs(DirName + frec.Name, FilName);
        end;
      until FindNext(frec) <> NERR_SUCCESS;
    finally
      FindClose(frec);
    end;
  end;
end;

function TrashFile(FilName: string): Boolean;
// Move given file(s) to the windows recycle bin
// Input:  FilName = name of the file(s) (with optional path)
//         like 'test.log' or 'M:\docu\*.old'
// Output: None
// Return: True if successful or False if failed
// Remark: check * ////
var
  from: array[0..MAX_PATH] of Char; //23.04.12 nk old=MAXBYTE
  info: TSHFileOpStruct;
begin
  Result    := False;
  FileError := feNoError;
  FilName   := Trim(FilName);

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  try
    FillChar(from, SizeOf(from), cNUL);
    StrPcopy(from, ExpandFileName(FilName) + cNUL + cNUL);

    with info do begin
      Wnd                   := Application.Handle;
      wFunc                 := FO_DELETE;
      pFrom                 := from;
      pTo                   := nil;
      fFlags                := FOF_ALLOWUNDO or FOF_NOCONFIRMATION or FOF_SIMPLEPROGRESS; //51/old=FOF_SILENT //FOF_ALLOWUNDO = move to Recycle bin
      fAnyOperationsAborted := False;
      hNameMappings         := nil;
    end;
    
    Result := (ShFileOperation(info) = NERR_SUCCESS);
  except
    FileError := feException;
  end;
end;

function DeleteDir(DirName: string; HideDialog: Boolean = True): Boolean;
// 06.02.19 nk opt/old=HideDialog: Boolean = False
// DirName = 'C:\test.txt'  - delete the file
// DirName = 'C:\test'      - delete the (empty) folder
// DirName = 'C:\test\*.*') - delete all files in the folder
var
  info: TSHFileOpStruct;
begin
  Result    := False;
  FileError := feNoError;
  DirName   := Trim(DirName);

  if DirName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  try
    DirName := ExcludeTrailingBackslash(DirName);
    ZeroMemory(@info, SizeOf(info));

    with info do begin
      wFunc  := FO_DELETE;
      if HideDialog then //51//11.08.18 nk opt ff
        fFlags := FOF_NOCONFIRMATION or FOF_NOERRORUI or FOF_SILENT             //06.02.19 nk add FOF_NOERRORUI
      else
        fFlags := FOF_NOCONFIRMATION or FOF_NOERRORUI or FOF_SIMPLEPROGRESS;    //15.08.18 nk add FOF_NOERRORUI
      pFrom  := PChar(DirName + cNUL);
    end;
    
    Result := (ShFileOperation(info) = NERR_SUCCESS);
  except
    FileError := feException;
  end;
end;

function CopyFileAdv(Source, Dest, FilName: string): string;
var //31.07.12 nk opt - copy FilName from Source to Dest folder
  fnum: integer; //rename the file to FilName[1..n] if already exist and identical
  fname: string; //Returen new file name like 'Contrast [1].swl' (w/o path)
begin            //Source and Dest are folders (full path needed with or without trailing slash)
  Result    := cEMPTY;
  FileError := feNoError;
  Source    := Trim(Source);
  Dest      := Trim(Dest);
  FilName   := Trim(FilName);

  if (Source = cEMPTY) or (Dest = cEMPTY) or (FilName = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  fnum   := CLEAR;
  fname  := FilName;
  Source := IncludeTrailingPathDelimiter(Source);
  Dest   := IncludeTrailingPathDelimiter(Dest);

  while FileExists(Dest + fname) do begin //31.07.12 nk opt/add (Source <> Dest)
    if (fnum = 0) and (Source <> Dest) and (GetCheckSum(Source + FilName) = GetCheckSum(Dest + fname)) then begin
      Result := FilName; //an identical file already exist - we use this file
      Exit;
    end;

    Inc(fnum);
    if fnum > 9 then Break;
    fname := Format(FORM_COPY, [fnum]); //[1]..[9]
    fname := StringReplace(FilName, cDOT, fname, [rfIgnoreCase]);
  end;

  if not DirectoryExists(Dest) then begin //26.12.11 nk add ff
    if not ForceDirectories(Dest) then    //create folder with full path
      FileError := feException;
  end;

  if CopyFile(PChar(Source + FilName), PChar(Dest + fname), True) then
    Result := fname;
end;

function CopyFiles(Source, Dest, FilName: string; Overwrite: Boolean = True; Attrib: Integer = 0): Integer;
var //23.09.12 nk opt - Copy file(s) FilName from Source to Dest folder with the same name
  att: Integer;           //Overwrite existing files if true!
  fname: string;          //FilName may have wildcards like '*.pas'
  frec: TSearchRec;       //Attr > 0 sets copied files attribute(s)
begin                     //Attr < 0 removes copied files attribute(s)
  Result    := NONE;      //Attr can be combined like (faReadOnly + faHidden)
  FileError := feNoError; //Source and Dest are folders (full path needed with or without trailing slash)
  Source    := Trim(Source);
  Dest      := Trim(Dest);
  FilName   := Trim(FilName);
  FileListing.Clear; //28.12.09 nk add

  if (Source = cEMPTY) or (Dest = cEMPTY) or (FilName = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  Source := IncludeTrailingPathDelimiter(Source); //12.12.10 nk add ff
  Dest   := IncludeTrailingPathDelimiter(Dest);

  if FindFirst(Source + FilName, faAnyFile, frec) = NERR_SUCCESS then begin
    Result := CLEAR;

    repeat
      //06.01.10 nk opt do not copy '.' and '..' folders / old=if (frec.Attr <> faDirectory) then begin
      if (frec.Attr <> faDirectory) and (frec.Name[1] <> MYDIR) then begin
        fname := Dest + frec.Name;     //16.12.09 nk opt ff

        if Overwrite then begin
          CopyFile(Pchar(Source + frec.Name), PChar(fname), False);
          Inc(Result);
          FileListing.Append(fname);   //28.12.09 nk add
        end else begin
          if not FileExists(fname) then begin
            CopyFile(Pchar(Source + frec.Name), PChar(fname), False);
            Inc(Result);
            FileListing.Append(fname);  //28.12.09 nk add
          end;
        end;

        att := FileGetAttr(fname);      //23.04.10 nk opt ff

        if Attrib > 0 then              //set file attribute(s)
          FileSetAttr(fname, att or Attrib); //old=FileSetAttr(fname, Attr);

        if Attrib < 0 then begin        //remove file attribute(s)
          if (att and -Attrib) > 0 then //toggle bit only if its set
            FileSetAttr(fname, att xor -Attrib);
        end;
        Application.ProcessMessages;    //23.09.12 nk add - do not block application
      end;
    until FindNext(frec) <> NERR_SUCCESS;

    FindClose(frec);
  end;
end;

function CopyFilesProgress(Source, Dest, FilName: string; Progress: TProgressBar): Integer;
var //10.08.18 nk add - Copy file(s) FilName from Source to Dest folder with the same name and show progress
  fname: string;          //FilName may have wildcards like '*.pas'
  frec: TSearchRec;       //Source and Dest are folders (full path needed with or without trailing slash)
begin
  Result            := NONE;
  FileError         := feNoError;
  Source            := Trim(Source);
  Dest              := Trim(Dest);
  FilName           := Trim(FilName);
  Progress.Position := CLEAR;
//FileListing.Clear;

  if (Source = cEMPTY) or (Dest = cEMPTY) or (FilName = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  Source := IncludeTrailingPathDelimiter(Source);
  Dest   := IncludeTrailingPathDelimiter(Dest);

  if FindFirst(Source + FilName, faAnyFile, frec) = NERR_SUCCESS then begin
    Result := CLEAR;

    repeat
      if (frec.Attr <> faDirectory) and (frec.Name[1] <> MYDIR) then begin
        fname := Dest + frec.Name;
        CopyFile(Pchar(Source + frec.Name), PChar(fname), False);
        Inc(Result);
      //FileListing.Append(fname);
        Progress.Position := Result + 1;
        Application.ProcessMessages;    //do not block application
      end;
    until FindNext(frec) <> NERR_SUCCESS;

    FindClose(frec);
  end;
end;

function DeleteFiles(DirName, FilName: string; Size: Integer = 0): Integer;
var //23.09.12 nk ins (frec.Name[1] <> MYDIR) - delete file if more or less than (optional) Size [Bytes]
  frec: TSearchRec;
begin
  Result    := NONE;
  FileError := feNoError;
  DirName   := Trim(DirName);
  FilName   := Trim(FilName);

  if (DirName = cEMPTY) or (FilName = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if FindFirst(DirName + FilName, faAnyFile, frec) = NERR_SUCCESS then begin
    Result := NERR_SUCCESS;
    repeat
      if Size < NERR_SUCCESS then begin //delete small files
        if (frec.Attr <> faDirectory) and (frec.Name[1] <> MYDIR) and (frec.Size < Abs(Size)) then
          if DeleteFile(DirName + frec.Name) then Inc(Result);
      end else begin
        if (frec.Attr <> faDirectory) and (frec.Name[1] <> MYDIR) and (frec.Size >= Size) then
          if DeleteFile(DirName + frec.Name) then Inc(Result);
      end;
      Application.ProcessMessages;    //23.09.12 nk add - do not block application
    until FindNext(frec) <> NERR_SUCCESS;
    FindClose(frec);
  end;
end;

function CreateFolder(DirName: string; Clear: Boolean): Boolean;
begin  //create new folder with all directories
  Result    := False;
  FileError := feNoError;
  DirName   := Trim(DirName);

  if DirName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  try
    if DirectoryExists(DirName) then begin
      if Clear then
        Result := (DeleteFiles(DirName, ALLFILES) <> NONE)
      else
        Result := True;
    end else begin
      Result := ForceDirectories(DirName);
    end;
  except
    FileError := feException;
  end;
end;

function ReadFromFile(FilName: string; Line: Integer; Encoding: string = FILE_ENCODING): string;
// 08.06.11 nk opt - Return specified text line from the given file
// Input:  FilName = name of file to read (with optional path)
//         Line = requested line number (1..MaxLine)
//         Encoding = character set encoding ('ISO-8859-1' or 'UTF-8')
// Output: None
// Return: Text line or empty string if failed or not found
var
  l: Integer;
  text: string;
  tfile: TextFile;
begin
  Result    := cEMPTY;
  FileError := feNoError;
  FilName   := Trim(FilName);
  FileMode  := fmOpenRead or fmShareDenyNone; //27.08.09 nk add

  if (FilName = cEMPTY) or (Line <= 0) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  try
    l := 0;
    AssignFile(tfile, FilName);

    try
      CloseFile(tfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Reset(tfile);
    
    repeat
      Inc(l);
      ReadALine(tfile, text, Encoding); //08.06.11 nk add Encoding

      if l = Line then begin
        Result := text;
        Break;
      end;
    until EOF(tfile);
  finally
    CloseFile(tfile);
  end;
end;

function WriteToFile(FilName, Text: string; Encoding: string = FILE_ENCODING): Boolean;
//V5//17.05.15 nk opt - Append a text line to an existing file - create file if not exists
// Input:  FilName = name of file to write (with optional path)
//         Text = string to append to the file
//         Encoding = character set encoding ('ISO-8859-1' or 'UTF-8')
// Output: None
// Return: True if successful or False if failed
// Remark: File will be created if not yet exists
var
  tfile: TextFile;
begin
  Result    := False;
  FileError := feNoError;
  FilName   := Trim(FilName);
  FileMode  := fmOpenReadWrite; //22.02.09 nk opt - set read/write file access

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  try
    if Encoding = ENCODING_UTF8 then //V5//17.05.15 nk add ff
      AssignFile(tfile, FilName, CP_UTF8)
    else
      AssignFile(tfile, FilName);

    try
      CloseFile(tfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    if FileExists(FilName) then begin
      Append(tfile);
    end else begin
      Rewrite(tfile);
      if Encoding = ENCODING_UTF8 then //V5//17.05.15 nk add ff
        Write(tfile, UTF8_BOM);
    end;

    WriteALine(tfile, Text, Encoding); // 08.06.11 nk add Encoding

    CloseFile(tfile);  //06.09.08 nk opt
    Result := True;
  except
    FileError := feException;
  end;
end;

function GetFileLines(FilName, Search: string; Mode: TFindMode; Encoding: string = FILE_ENCODING): Integer;
// 08.06.11 nk opt - Return the number of lines containing the given search string
// Input:  FilName = name of file to examine (with optional path)
//         Search = string to search in the lines of the file
//         Mode = fmCase - ignore case
//                fmWord - whole word must match
//                fmSwap - search and line swapped
//                fmAnsi - use multibyte characters for compare
//         Encoding = character set encoding ('ISO-8859-1' or 'UTF-8')
// Output: None
// Return: Number of matching lines or 0 if file not exists or
//         search string has not found
var
  line: string;
  tfile: TextFile;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  FilName   := Trim(FilName);
  FileMode  := fmOpenRead or fmShareDenyNone; //27.08.09 nk add

  if (FilName = cEMPTY) or (Search = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  if fmCase in Mode then begin
    if fmAnsi in Mode then
      Search := AnsiUpperCase(Search)
    else
      Search := UpperCase(Search);
  end;

  if fmWord in Mode then Search := cQUOTE + Search + cQUOTE;

  try
    AssignFile(tfile, FilName);

    try
      CloseFile(tfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Reset(tfile);

    try
      repeat
        ReadALine(tfile, line, Encoding); //08.06.11 nk add Encoding

        if fmCase in Mode then begin
          if fmAnsi in Mode then
            line := AnsiUpperCase(line)
          else
            line := UpperCase(line);
        end;

        if fmWord in Mode then line := cQUOTE + line + cQUOTE;

        if fmSwap in Mode then begin
          if Pos(line, Search) > 0 then begin
            Inc(Result);
          end;
        end else begin
          if Pos(Search, line) > 0 then begin
            Inc(Result);
          end;
        end;
      until EOF(tfile);
    finally
      CloseFile(tfile);
    end;
  except
    FileError := feException;
  end;
end;

function CountInFile(FilName, Search: string; Mode: TFindMode; Encoding: string = FILE_ENCODING): Integer;
// 08.06.11 nk opt - Count all lines (NOT words!) containing the given search string
// Input:  FilName = name of file to examine (with optional path)
//         Search = string to search in the lines of the file
//         Mode = fmCase - ignore case
//                fmWord - whole word must match
//                fmSwap - search and line swapped
//                fmAnsi - use multibyte characters for compare
//         Encoding = character set encoding ('ISO-8859-1' or 'UTF-8')
// Output: None
// Return: Number of matching lines (1..EOF) or 0 if file not exists or
//         search string has not been found
var
  line: string;
  tfile: TextFile;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  FilName   := Trim(FilName);
  FileMode  := fmOpenRead or fmShareDenyNone; //27.08.09 nk add

  if (FilName = cEMPTY) or (Search = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  if fmCase in Mode then begin
    if fmAnsi in Mode then
      Search := AnsiUpperCase(Search)
    else
      Search := UpperCase(Search);
  end;

  if fmWord in Mode then Search := cQUOTE + Search + cQUOTE;

  try
    AssignFile(tfile, FilName);

    try
      CloseFile(tfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Reset(tfile);

    try
      repeat
        ReadALine(tfile, line, Encoding); //08.06.11 nk add Encoding

        if fmCase in Mode then begin
          if fmAnsi in Mode then
            line := AnsiUpperCase(line)
          else
            line := UpperCase(line);
        end;

        if fmWord in Mode then line := cQUOTE + line + cQUOTE;

        if fmSwap in Mode then begin
          if Pos(line, Search) > 0 then
            Inc(Result); //found
        end else begin
          if Pos(Search, line) > 0 then
            Inc(Result); //found
        end;
      until EOF(tfile);
    finally
      CloseFile(tfile);
    end;
  except
    FileError := feException;
    Result := NERR_SUCCESS;
  end;
end;

function FindInFile(FilName, Search: string; Mode: TFindMode; Encoding: string = FILE_ENCODING): Integer;
// 22.06.11 nk opt - Return the first line number containing the given search string (or 0 if not)
// Input:  FilName = name of file to examine (with optional path)
//         Search = string to search in the lines of the file
//         Mode = fmCase - ignore case
//                fmWord - whole word must match
//                fmSwap - search and line swapped
//                fmAnsi - use multibyte characters for compare
//                fmLim3 - limit search to max. 3 lines //22.06.11 nk add
//         Encoding = character set encoding ('ISO-8859-1' or 'UTF-8')
// Output: None
// Return: Number of matching line (1..EOF) or 0 if file not exists or
//         search string could not found
// Remark: Search loop breaks on first line matching
var
  lnum: Integer;
  line: string;
  tfile: TextFile;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  FilName   := Trim(FilName);
  FileMode  := fmOpenRead or fmShareDenyNone; //27.08.09 nk add
  
  if (FilName = cEMPTY) or (Search = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  if fmCase in Mode then begin
    if fmAnsi in Mode then
      Search := AnsiUpperCase(Search)
    else
      Search := UpperCase(Search);
  end;

  if fmWord in Mode then Search := cQUOTE + Search + cQUOTE;

  try
    lnum := 0;
    AssignFile(tfile, FilName);

    try
      CloseFile(tfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Reset(tfile);

    try
      repeat
        Inc(lnum);
        if (fmLim3 in Mode) and (lnum > 3) then Break; //22.06.11 nk add

        ReadALine(tfile, line, Encoding); //08.06.11 nk add Encoding

        if fmCase in Mode then begin
          if fmAnsi in Mode then
            line := AnsiUpperCase(line)
          else
            line := UpperCase(line);
        end;

        if fmWord in Mode then line := cQUOTE + line + cQUOTE;

        if fmSwap in Mode then begin
          if Pos(line, Search) > 0 then begin
            Result := lnum;
            Break;
          end;
        end else begin
          if Pos(Search, line) > 0 then begin
            Result := lnum;
            Break;
          end;
        end;
      until EOF(tfile);
    finally
      CloseFile(tfile);
    end;
  except
  //CloseFile(tfile);  //12.01.18 nk del (is done in try..finally)
    FileError := feException;
    Result    := NERR_SUCCESS;
  end;
end;

function ReplaceInFile(FilName, Old, New: string; IsCase: Boolean; AsUnicode: Boolean = False): Boolean;
// 30.12.10 nk opt - add AsUnicode for UTF-16LE encoded files, otherwise ANSI
// Replace all old texts with new texts in the given file
// Input:  FilName = name of file with path
//         Old = old text string
//         New = new text string
//         IsCase = True - replace is case sensitive
// Output: None
// Return: True if successful
var
  ubuff: string;
  abuff: AnsiString;
  sfile: TFileStream;
  flags: TReplaceFlags;
begin
  Result    := False;
  FileError := feNoError;
  FilName   := Trim(FilName);

  if (FilName = cEMPTY) or (Old = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  if IsCase then //case sensitive
    flags := [rfReplaceAll]
  else
    flags := [rfReplaceAll, rfIgnoreCase];

  sfile := TFileStream.Create(FilName, fmOpenRead or fmShareDenyNone);

  try
    if AsUnicode then begin
      SetLength(ubuff, sfile.Size);
      sfile.ReadBuffer(ubuff[1], sfile.Size);
      ubuff := StringReplace(ubuff, Old, New, flags);
    end else begin
      SetLength(abuff, sfile.Size);
      sfile.ReadBuffer(abuff[1], sfile.Size);
      abuff := AnsiString(StringReplace(string(abuff), Old, New, flags));
    end;

    sfile.Free;
  except
    sfile.Free;
    FileError := feException;
    Exit;
  end; 

  sfile := TFileStream.Create(FilName, fmCreate);

  try
    if AsUnicode then begin
      sfile.WriteBuffer(ubuff[1], Length(ubuff));
    end else begin
      sfile.WriteBuffer(abuff[1], Length(abuff));
    end;

    Result := True;
  except
    FileError := feException;
  end;

  sfile.Free;
  Application.ProcessMessages;
end;

function ReplaceInXML(FilName, Old, New: string; IsCase: Boolean): Boolean;
var //V5//08.04.16 nk add - replace UTF-8 text in a XML file
  ubuff: string;
  flags: TReplaceFlags;
  sread: TStreamReader;
  swrite: TStreamWriter;
begin
  Result    := False;
  FileError := feNoError;
  FilName   := Trim(FilName);

  if (FilName = cEMPTY) or (Old = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  if IsCase then //case sensitive
    flags := [rfReplaceAll]
  else
    flags := [rfReplaceAll, rfIgnoreCase];

  try
    sread := TStreamReader.Create(FilName, TEncoding.UTF8);
    ubuff := sread.ReadToEnd;
    ubuff := StringReplace(ubuff, Old, New, flags);
    sread.Free;

    swrite := TStreamWriter.Create(FilName, False, TEncoding.UTF8);
    swrite.Write(ubuff);
    swrite.Free;
    Result := True;
  except
    FileError := feException;
  end;
end;

function ReplaceAllInFile(FilName, RepForm: string; RepList: TStringList): Boolean;
// 28.10.12 nk add - currently only ANSI is supported
// Replace all RepForm(i) texts with RepList(i) texts in the given file
// Input:  FilName = name of file with path
//         RepForm = replace pattern (like '{%i}')
//         RepList = string list of new texts
// Output: None
// Return: True if successful
var
  i: Integer;
  AsUnicode: Boolean;
  ubuff: string;
  abuff: AnsiString;
  sfile: TFileStream;
  flags: TReplaceFlags;
begin
  Result    := False;
  AsUnicode := False; //currently only ANSI is supported
  FileError := feNoError;
  FilName   := Trim(FilName);

  if (FilName = cEMPTY) or (RepForm = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  flags := []; //do only replace 1st matching pattern
  sfile := TFileStream.Create(FilName, fmOpenRead or fmShareDenyNone);

  try
    if AsUnicode then begin
      SetLength(ubuff, sfile.Size);
      sfile.ReadBuffer(ubuff[1], sfile.Size);
      for i := 0 to RepList.Count - 1 do
        ubuff := StringReplace(ubuff, Format(RepForm, [i]), RepList[i], flags);
    end else begin
      SetLength(abuff, sfile.Size);
      sfile.ReadBuffer(abuff[1], sfile.Size);
      for i := 0 to RepList.Count - 1 do
        abuff := AnsiString(StringReplace(string(abuff), Format(RepForm, [i]), RepList[i], flags));
    end;

    sfile.Free;
  except
    sfile.Free;
    FileError := feException;
    Exit;
  end;

  sfile := TFileStream.Create(FilName, fmCreate);

  try
    if AsUnicode then begin
      sfile.WriteBuffer(ubuff[1], Length(ubuff));
    end else begin
      sfile.WriteBuffer(abuff[1], Length(abuff));
    end;

    Result := True;
  except
    FileError := feException;
  end;

  sfile.Free;
  Application.ProcessMessages;
end;

function WriteSignature(FilName: string; Signature: AnsiString): Integer;
var //xe//16.10.10 nk opt / append an ANSI text signature to compiled file
  s: Integer;  //return number of bytes written or -1 if failed
  fs: TFileStream;
  ms: TMemoryStream;
begin
  Result := NONE;
  if not FileExists(FilName) or (Signature = cEMPTY) then Exit;

  fs := nil;
  ms := TMemoryStream.Create;

  try
    fs := TFileStream.Create(FilName, fmOpenWrite or fmShareDenyWrite);
    ms.Write(Signature[1], Length(Signature)); //ANSI only
    ms.Seek(0, soFromBeginning);
    fs.Seek(0, soFromEnd);
    fs.CopyFrom(ms, 0);
    s := ms.Size + SizeOf(Integer);
    fs.Write(s, SizeOf(s));
    Result := ms.Size;
  except
    FileError := feException;
    Result := NONE;
  end;

  fs.Free;
  ms.Free;
end;

function ReadSignature(FilName: string): AnsiString;
var //xe//25.10.10 opt / return text signature appended to the requested file
  s: Integer; //or empty string if failed / FilName must be ANSI coded
  sl: TStringList;
  fs: TFileStream;
  ms: TMemoryStream;
begin
  Result := cEMPTY;
  if not FileExists(FilName) then Exit;

  fs := nil;
  sl := TStringList.Create;
  ms := TMemoryStream.Create;

  try
    fs := TFileStream.Create(FilName, fmOpenRead or fmShareDenyNone); //25.10.10 nk old=fmShareDenyWrite
    fs.Seek(-SizeOf(Integer), soFromEnd);
    fs.Read(s, SizeOf(s));                    //get number of bytes

    //25.10.10 nk old=Exit / fix - close streams if no signature found
    if (s > 0) and (s <= fs.Size) then begin  //16.10.10 nk add
      fs.Seek(-s, soFromEnd);
      ms.SetSize(s - SizeOf(Integer));
      ms.CopyFrom(fs, s - SizeOf(s));
      ms.Seek(0, soFromBeginning);
      sl.LoadFromStream(ms, TEncoding.ASCII); //xe//ANSI only
      Result := AnsiString(sl[0]);            //xe//
    end;
  except
    FileError := feException;
    Result := cEMPTY;
  end;

  sl.Free;
  fs.Free;
  ms.Free;
end;

function DeleteLines(FilName, Search: string; Mode: TFindMode; Encoding: string = FILE_ENCODING): Integer;
// 09.06.12 nk opt - Remove all lines in the file containing the given search string
// Input:  FilName = name of file to examine (with optional path)
//         Search = string to search in the lines of the file
//         Mode = fmCase - ignore case
//                fmWord - whole word must match
//                fmSwap - search and line swapped
//                fmAnsi - use multibyte characters for compare
//                fmTrim - 09.06.12 nk add - trim lines read (e.g. to remove empty lines)
//         Encoding = character set encoding ('ISO-8859-1' or 'UTF-8')
// Output: None
// Return: Number of deleted lines or 0 if file not exists or
//         search string has not found
var
  temp: string;
  line: string;
  test: string;
  dfile: TextFile;
  sfile: TextFile;
begin
  Result    := NERR_SUCCESS;
  FileError := feNoError;
  FilName   := Trim(FilName);
  FileMode  := fmOpenReadWrite; //27.08.09 nk add - set read/write file access
   
  if (FilName = cEMPTY) {or (Search = cEMPTY)} then begin //09.06.12 nk opt
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(FilName) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  try
    temp := FilName + TMP_END;
    RenameFile(FilName, temp);

    if fmCase in Mode then begin
      if fmAnsi in Mode then
        Search := AnsiUpperCase(Search)
      else
        Search := UpperCase(Search);
    end;

    if fmWord in Mode then Search := cQUOTE + Search + cQUOTE;

    AssignFile(sfile, temp);

    try
      CloseFile(sfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Reset(sfile);

    AssignFile(dfile, FilName); //create new empty file

    try
      CloseFile(dfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Rewrite(dfile);

    try
      repeat
        ReadALine(sfile, line, Encoding); //08.06.11 nk add Encoding

        test := line;

        if fmCase in Mode then begin
          if fmAnsi in Mode then
            test := AnsiUpperCase(test)
          else
            test := UpperCase(test);
        end;

        if fmWord in Mode then test := cQUOTE + test + cQUOTE;

        if fmSwap in Mode then begin
          if Pos(test, Search) > 0 then
            line := cEMPTY;
        end else begin
          if Pos(Search, test) > 0 then
            line := cEMPTY;
        end;

        //09.06.12 nk add ff
        if fmTrim in Mode then begin
          test := Trim(line);
          if Search = test then
            line := cEMPTY;
        end;

        if line <> cEMPTY then
          WriteALine(dfile, line, Encoding); // 08.06.11 nk add Encoding

      until EOF(sfile);
    finally
      CloseFile(dfile);
      CloseFile(sfile);
      DeleteFile(temp);
    end;
  except
    FileError := feException;
    Result := NERR_SUCCESS;
  end;
end;

function CopyFileProgress(Source, Dest: string; Progress: TProgressBar): Boolean;
// Copy source file to new destination and showing the progress
// Input:  Source = source file name
//         Dest   = destination file name
// Output: Progress
// Return: True if done or False if failed
// Remark: do overwrite existing files w/o asking
var
  read: Integer;
  size: LongInt;
  sfile: file of Byte;
  dfile: file of Byte;
  buff: array[0..K4] of Char;
begin
  Result    := False;
  FileError := feNoError;
  FileMode  := fmOpenReadWrite; //27.08.09 nk add - set read/write file access
  Source    := Trim(Source);
  Dest      := Trim(Dest);

  if (Source = cEMPTY) or (Dest = cEMPTY) then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  if not FileExists(Source) then begin
    FileError := feFileNotExist;
    Exit;
  end;

  try
    AssignFile(sfile, Source);

    try
      CloseFile(sfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Reset(sfile);

    AssignFile(dfile, Dest);

    try
      CloseFile(dfile); //11.12.09 nk opt ff - make sometimes I/O error 103 !?!
    except
      IOResult;         //ignore if file was already closed
    end;

    Rewrite(dfile);

    size := FileSize(sfile);
  except
    FileError := feException;
    Exit;
  end;

  with Progress do begin
    try
      Min := 0;
      Max := size + size div 10;
      Position := 0;

      while size > 0 do begin
        BlockRead(sfile, buff[0], SizeOf(buff), read);
        size := size - read;
        BlockWrite(dfile, buff[0], read);
        Position := Position + read;
        Application.ProcessMessages;
      end;

      CloseFile(sfile);
      CloseFile(dfile);
      Position := Max;
    except
      FileError := feException;
      Exit;
    end;
  end;
  Result := True;
end;

function OperFileShell(Source, Dest: string; Oper: TFileOper; Head: string = cEMPTY): Boolean;
// Make file operation using windows API - shows a dialog box with progress
// Input:  Source = source file name - wildcards like 'C:\Temp\*.*' are allowed
//         Dest   = destination file name - ask to create folder if not exist
//         Oper   = foCopy, foDelete, foMove, or foRename
//         Head   = Dialog header line (titel)
// Output: None
// Return: True if done or False if failed or aborted by user
// Remark: Operation can be cancelled by pressing the [Cancel] button
var //xe//
  aborted: Boolean;
  info: TSHFileOpStructW;  //xe//TSHFileOpStructA; //22.03.08 nk opt ff
begin
  Result    := False;
  aborted   := False;
  FileError := feNoError;
  Source    := Trim(Source);
  Dest      := Trim(Dest);
  Head      := Trim(Head);

  try
    if (Source = cEMPTY) or ((Dest = cEMPTY) and (Oper <> foDelete)) then begin //11.08.18 nk opt
      FileError := feEmptyParameter;
      Exit;
    end;

    ZeroMemory(@info, SizeOf(info));

    with info do begin
      case Oper of
        foCopy:   wFunc := FO_COPY;
        foDelete: wFunc := FO_DELETE;
        foMove:   wFunc := FO_MOVE;
        foRename: wFunc := FO_RENAME; //no wildcards allowed!
      else
        FileError := feInvalidParameter;
        Exit;
      end;

      wnd   := Application.Handle;
      pFrom := PChar(Source + cNUL); //must end with #0#0
      if Oper = foDelete then        //11.08.18 nk opt
        pTo := nil                   //nil for foDelete
      else
        pTo := PChar(Dest + cNUL);

      fFlags := FOF_NOCONFIRMATION or FOF_SIMPLEPROGRESS or FOF_NOCONFIRMMKDIR;
      fAnyOperationsAborted := aborted;
      hNameMappings         := nil;
      if Head <> cEMPTY then  //24.03.08 nk opt
        lpszProgressTitle   := PChar(Head + cNUL + cNUL);  //for FOF_SIMPLEPROGRESS only
    end;

    Result := (ShFileOperation(info) = NERR_SUCCESS) and not aborted;
  except
    FileError := feException;
    Result := False;
  end;
end;

function OpenFileProperties(FilName: string): Boolean;
var //07.12.09 nk add improved version - show the windows file properties dialog
  info: TShellExecuteInfo;
begin
  FillChar(info, SizeOf(info), 0);
  info.cbSize := SizeOf(info);
  info.lpFile := PChar(FilName);
  info.lpVerb := FILE_PROPERTY;
  info.fMask  := SEE_MASK_INVOKEIDLIST;
  Result      := ShellExecuteEx(@info);
end;

function GetLongFileName(FilName: string): string;
// Expand short (DOS 8.3) to long file names
// Input:  FilName - short file name (with optional path)
//         like 'C:\DEVELO~1\TESTPR~1.pdf'
// Output: none
// Return: Fully qualified long file and path name
//         like 'C:\Development\TestProcedure.pdf'
// Remark: Return empty string if file not found
var
  i: Integer;
  win: Cardinal; //17.11.07 nk old=THandle;
  find: TWin32FindData;
  ispath: Boolean;
begin
  Result    := cEMPTY;
  FileError := feNoError;
  FilName   := Trim(FilName);

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  FilName := ExpandFileName(FilName);
  i       := Pos(PATHDEL, FilName);
  Result  := Copy(FilName, 1, i);
  Delete(FilName, 1, i);

  repeat
    i := Pos(PATHDEL, FilName);
    ispath := i > 0;
    if not ispath then i := Length(FilName) + 1;

    win := FindFirstFile(PChar(Result + Copy(FilName, 1, i - 1)), find);

    if win <> INVALID_HANDLE_VALUE then begin
      try
        Result := Result + find.cFileName;
        if ispath then Result := Result + PATHDEL;
      finally
        Windows.FindClose(win);
      end;
    end else begin
      FileError := feFileNotExist;
      Exit;
    end;

    Delete(FilName, 1, i);
  until Length(FilName) = NERR_SUCCESS;
end;

function ExpandEnvPath(Path: string): string;
begin //Expand path variables like '%PUBLIC%' to 'C:\Users\Public'
  SetLength(Result, K32);
  SetLength(Result, ExpandEnvironmentStrings(PChar(Path),
            @Result[1], Length(Result)) -1); //-1 = cut ending #0
end; 

function ExtractFileBody(FilName: string): string;
var //10.11.11 nk add/fix - cut file extension (with dot) from file name (remain optional path)
  ext: string; //Improved version (old version fails if path contains a dot)
begin
  Result := Trim(FilName);
  ext    := ExtractFileExt(Result);

  if ext <> cEMPTY then //FilName with ending
    Result := StringReplace(Result, ext, cEMPTY, [rfIgnoreCase]);
end;

function GetProperFileName(FilName: string): string;
var //remove invalid characters from file name (with optional path)
  i: Integer;    //like 'C:\Temp\Template.xml' (NO wildcards allowed)
  fpath: string; //Remark: Path will not be validated
  fname: string;
  fext: string;
begin //xe//
  Result  := cEMPTY;
  FilName := Trim(FilName);

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  fpath := ExtractFilePath(FilName);  //'C:\Temp\'
  fname := ExtractFileName(FilName);  //'Template.xml'
  fext  := ExtractFileExt(FilName);   //'.xml'
  fname := ExtractFileBody(fname);    //'Template'

  if fname = cEMPTY then begin
    FileError := feInvalidParameter;
    Exit;
  end;

  //validate file name
  for i := 1 to Length(fname) do
    if CharInSet(fname[i], INVALID_FILE_CHARS) then fname[i] := cQUEST; //xe//
  
  //validate file extension
  for i := 2 to Length(fext) do //2=ignore 1st char=dot
    if CharInSet(fext[i], INVALID_FILE_CHARS) then fext[i] := cQUEST;   //xe//

  fname  := fpath + fname + fext;
  Result := StringReplace(fname, cQUEST, cEMPTY, [rfReplaceAll]);
end;

function GetFileSystem(DriveName: string): string;
// Determine the file system of the given drive
// Input: DriveName = name of the drive in the format 'C:\'
// Output: none
// Return: File system name like 'NTFS' or 'FAT'
// Remark: Return empty string if drive not found
var
  fso: OleVariant;
  drv: OleVariant;
begin
  Result    := cEMPTY;
  FileError := feNoError;
  DriveName := Trim(DriveName);

  if DriveName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  try
    fso := CreateOleObject('Scripting.FileSystemObject');
    drv := fso.GetDrive(fso.GetDriveName(DriveName));
    Result := drv.FileSystem;
  except
    FileError := feException;
  end;
end;

function GetFileEncoding(FilName: string): string;
var //14.11.11 nk opt - return the encoding of the file
  isrtf, isxml: Boolean;
  pcode: Integer;
  ftemp: string;
  fbuff: AnsiString;
  fs: TFileStream;
const
  RTFHEADLEN = 64;
begin
  try //14.11.11 nk add
    Result := ENCODING_UNKNOWN;
    fs     := nil; //13.07.11 nk add
    ftemp  := LowerCase(ExtractFileExt(FilName));     //like '.txt'
    isrtf  := (ftemp = RTF_END) or (ftemp = SWR_END);
    pcode  := FindInFile(FilName, ENCODING_XMLTAG, [fmCase, fmLim3]); //22.06.11 nk add ff
    isxml  := (pcode > 0);

    try
      if isrtf then begin
        fs    := TFileStream.Create(FilName, fmOpenRead);
        fbuff := AnsiString(StringOfChar(cSPACE, RTFHEADLEN));
        fs.Read(fbuff[1], RTFHEADLEN);
      end else begin
        if isxml then begin //22.06.11 nk add ff
          ftemp := ReadFromFile(FilName, pcode);
          ftemp := UpperCase(Trim(ftemp));
        end else begin
          fs    := TFileStream.Create(FilName, fmOpenRead);
          fbuff := AnsiString(ENCODING_UNKNOWN);
          fs.Read(fbuff[1], 4);
        end;
      end;
    finally
      fs.Free;
    end;

    if not isrtf and not isxml then begin //read BOM (Byte-Order-Mask)
      if Copy(fbuff, 1, 3) = #$EF#$BB#$BF then
        Result := ENCODING_UTF8
      else if fbuff = #$00#$00#$FE#$FF then
        Result := ENCODING_UTF32BE
      else if fbuff = #$FF#$FE#$00#$00 then
        Result := ENCODING_UTF32LE
      else if Copy(fbuff, 1, 2) = #$FE#$FF then
        Result := ENCODING_UTF16BE
      else if Copy(fbuff, 1, 2) = #$FF#$FE then
        Result := ENCODING_UTF16LE
      else
        Result := ENCODING_UNKNOWN;
    end else begin
      if isrtf then begin //read rtf header like '...\ansicpg1252' for U.S. Windows
        Result := ENCODING_ANSI;
        ftemp  := string(fbuff);
        pcode  := Pos(FORM_RTFCP, ftemp);
        if pcode > 0 then begin
          ftemp  := RightStr(ftemp, RTFHEADLEN - pcode + 1);
          ftemp  := PATHDEL + StrSplit(ftemp, PATHDEL, 1);
          ftemp  := StringReplace(ftemp, FORM_RTFCP, cEMPTY, [rfIgnoreCase]);
          Result := ENCODING_ANSI + cSPACE + ftemp;
        end;
      end else begin      //read xml encoding like '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        Result := ENCODING_UNKNOWN;
        pcode  := Pos(UpperCase(ENCODING_XMLTAG), ftemp);
        if pcode > 0 then begin
          ftemp  := RightStr(ftemp, Length(ftemp) - pcode);
          Result := StrSplit(ftemp, cQUOTE, 1);
        end;
      end;
    end;
  except //14.11.11 nk add
    FileError := feException;
    Result := ENCODING_UNKNOWN;
  end;
end;

procedure SetFileEncoding(FilName: string; HeadLine: string = COMMENT; Encoding: string = FILE_ENCODING);
var //21.06.11 nk add - write (or rewrite) FilName with BOM (Byte-Order-Mask)
  fback: string;
  slist: TStrings;
  fcode: TEncoding;
begin
  slist := TStringList.Create;

  try
    fback := FilName + cDOT + FormatDateTime(FORM_FILE_LONG, Now);
    fcode := TEncoding.Default;

    if HeadLine = COMMENT then begin
      slist.LoadFromFile(FilName);
    end else begin
      slist.Append(HeadLine);
    end;

    if Encoding = ENCODING_UTF8 then fcode := TEncoding.UTF8;

    if (Encoding = ENCODING_UTF16LE) or
       (Encoding = ENCODING_UTF16BE) or
       (Encoding = ENCODING_UTF32LE) or
       (Encoding = ENCODING_UTF32BE) then fcode := TEncoding.Unicode;

    RenameFile(FilName, fback);
    slist.SaveToFile(FilName, fcode);
  finally
    slist.Free;
  end;
end;

function GetFileInfo(FilName: string): TFileInfo;
var //xe//
  fileinfo: TSHFileInfo;
  fixedinfo: PVSFixedFileInfo;
  ret: Integer;
  vsize: Integer;
  vbuff: PChar;
  vvalue: Pointer;
  vhandle: Cardinal;
  vbufflen: Cardinal;
  vkey: string;

  function GetFileSubType(fixedinfo: PVSFixedFileInfo): string;
  begin
    case fixedinfo.dwFileType of
      VFT_UNKNOWN: Result    := 'Unknown';
      VFT_APP: Result        := 'Application';
      VFT_DLL: Result        := 'Dynamic Link Library';
      VFT_STATIC_LIB: Result := 'Static Link Library';
      VFT_DRV:
        case
          fixedinfo.dwFileSubtype of
          VFT2_UNKNOWN: Result         := 'Unknown Driver';
          VFT2_DRV_COMM: Result        := 'Communications Driver';
          VFT2_DRV_PRINTER: Result     := 'Printer Driver';
          VFT2_DRV_KEYBOARD: Result    := 'Keyboard Driver';
          VFT2_DRV_LANGUAGE: Result    := 'Language Driver';
          VFT2_DRV_DISPLAY: Result     := 'Display Driver';
          VFT2_DRV_MOUSE: Result       := 'Mouse Driver';
          VFT2_DRV_NETWORK: Result     := 'Network Driver';
          VFT2_DRV_SYSTEM: Result      := 'System Driver';
          VFT2_DRV_INSTALLABLE: Result := 'Installable Driver';
          VFT2_DRV_SOUND: Result       := 'Sound Driver';
        end;
      VFT_FONT:
        case fixedinfo.dwFileSubtype of
          VFT2_UNKNOWN: Result       := 'Unknown Font';
          VFT2_FONT_RASTER: Result   := 'Raster Font';
          VFT2_FONT_VECTOR: Result   := 'Vector Font';
          VFT2_FONT_TRUETYPE: Result := 'Truetype Font';
          else;
        end;
      VFT_VXD: Result := 'Virtual Device Identifier = ' +
          IntToHex(fixedinfo.dwFileSubtype, 8);
    end;
  end;

  function HasdwFileFlags(fixedinfo: PVSFixedFileInfo; Flag: Word): Boolean;
  begin
    Result := (fixedinfo.dwFileFlagsMask and
      fixedinfo.dwFileFlags and Flag) = Flag;
  end;

  function GetFixedFileInfo: PVSFixedFileInfo;
  begin
    if not VerQueryValue(vbuff, cEMPTY, Pointer(Result), vbufflen) then
      Result := nil;
  end;

  function GetInfo(const aKey: string): string;
  begin
    Result := cEMPTY;
    vkey := Format(FORM_INFO, [LoWord(Integer(vvalue^)), HiWord(Integer(vvalue^)), aKey]);
    if VerQueryValue(vbuff, PChar(vkey), vvalue, vbufflen) then
      Result := StrPas(PChar(vvalue)); //xe//
  end;

  function QueryValue(const aValue: string): string;
  begin  //obtain version information about the specified file
    Result := cEMPTY;
    if GetFileVersionInfo(PChar(FilName), vhandle, vsize, vbuff) and
      VerQueryValue(vbuff, FILE_INFO, vvalue, vbufflen) then
      Result := GetInfo(aValue); //return selected version information
  end;

begin
  FileError := feNoError;

  with Result do begin
    FileType         := cEMPTY;
    CompanyName      := cEMPTY;
    FileDescription  := cEMPTY;
    FileVersion      := cEMPTY;
    InternalName     := cEMPTY;
    LegalCopyRight   := cEMPTY;
    LegalTradeMarks  := cEMPTY;
    OriginalFileName := cEMPTY;
    ProductName      := cEMPTY;
    ProductVersion   := cEMPTY;
    Comments         := cEMPTY;
    SpecialBuildStr  := cEMPTY;
    PrivateBuildStr  := cEMPTY;
    FileFunction     := cEMPTY;
    DebugBuild       := False;
    Patched          := False;
    PreRelease       := False;
    SpecialBuild     := False;
    PrivateBuild     := False;
    InfoInferred     := False;
  end;

  //get the file type
  if SHGetFileInfo(PChar(FilName), 0, fileinfo, SizeOf(fileinfo),
    SHGFI_TYPENAME) <> 0 then Result.FileType := fileinfo.szTypeName;

  //29.07.07 nk bug fix old=SHGFI_EXETYPE
  //ret := SHGetFileInfo(PChar(FilName), 0, fileinfo, SizeOf(fileinfo), SHGFI_TYPENAME);
  ret := 1;

  if ret <> NERR_SUCCESS then begin //determine whether the OS can obtain version information
    vsize := GetFileVersionInfoSize(PChar(FilName), vhandle);
    if vsize > NERR_SUCCESS then begin
      vbuff := AllocMem(vsize);
      try
        with Result do begin
          CompanyName      := QueryValue('CompanyName');
          FileDescription  := QueryValue('FileDescription');
          FileVersion      := QueryValue('FileVersion');
          InternalName     := QueryValue('InternalName');
          LegalCopyRight   := QueryValue('LegalCopyRight');
          LegalTradeMarks  := QueryValue('LegalTradeMarks');
          OriginalFileName := QueryValue('OriginalFileName');
          ProductName      := QueryValue('ProductName');
          ProductVersion   := QueryValue('ProductVersion');
          Comments         := QueryValue('Comments');
          SpecialBuildStr  := QueryValue('SpecialBuild');
          PrivateBuildStr  := QueryValue('PrivateBuild');

          //fill the VS_FIXEDFILEINFO structure
          fixedinfo := GetFixedFileInfo;
          DebugBuild    := HasdwFileFlags(fixedinfo, VS_FF_DEBUG);
          PreRelease    := HasdwFileFlags(fixedinfo, VS_FF_PRERELEASE);
          PrivateBuild  := HasdwFileFlags(fixedinfo, VS_FF_PRIVATEBUILD);
          SpecialBuild  := HasdwFileFlags(fixedinfo, VS_FF_SPECIALBUILD);
          Patched       := HasdwFileFlags(fixedinfo, VS_FF_PATCHED);
          InfoInferred  := HasdwFileFlags(fixedinfo, VS_FF_INFOINFERRED);
          FileFunction  := GetFileSubType(fixedinfo);
        end;
      finally
        FreeMem(vbuff, vsize);
      end
    end;
  end
end;

function LockFile(FilName, Locked: string): Boolean;
begin //create a (hidden, protected system) lock file or remove it
  Result    := False;          //FilName = empty  - cancelled
  FileError := feNoError;      //FilName = Locked - just return lock state
  FilName   := Trim(FilName);  //Locked  = empty  - remove lock file
                               //Locked  = text   - create lock file and write text
  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  try //10.04.08 nk opt ff
    if FilName <> Locked then begin
      if FileExists(FilName) then begin
        FileSetAttr(FilName, CLEAR);   //unlocked - delete file
        DeleteFile(FilName);
      end;

      if Locked <> cEMPTY then begin
        WriteToFile(FilName, Locked);  //locked - file will be created
        FileSetAttr(FilName, faReadOnly or faHidden or faSysFile);
      end;
    end;
  except
    FileError := feException;
  end;

  Result := FileExists(FilName);
end;

procedure ExtractResource(ResType: PChar; ResName, FilName: string);
// Save data stored into program resource as a file
// Input:  ResType = type of resource like RT_RCDATA, RT_BITMAP, RT_ICON,
//                   RT_FONT, RT_FONTDIR, RT_DIALOG, RT_MENU, RT_STRING,
//                   RT_CURSOR, RT_VERSION...
//         ResName = name of resource
//         FilName = name of output file
// Remark: Do overwrite existing files w/o asking
//         use RT_RCDATA for binary coded application specific data
var //xe//
  rs: TResourceStream;
begin
  rs := TResourceStream.Create(hInstance, ResName, ResType); //xe//

  try
    rs.SavetoFile(FilName);
  finally
    rs.Free;
  end;
end;

procedure CompressFile(FilIn, FilOut: string);
// 25.10.10 nk opt
// Compress input file to new output file using the ZIP algorithm
// Input:  FilIn  = unzipped file name
//         FilOut = zipped file name
// Remark: do overwrite existing files w/o asking
var
  si: TFileStream;
  so: TFileStream;
  sc: TCompressionStream;
begin                         //25.10.10 nk add fmShareDenyNone
  si := TFileStream.Create(FilIn, fmOpenRead or fmShareDenyNone);

  try
    so := TFileStream.Create(FilOut, fmCreate);
    try
      sc := TCompressionStream.Create(clMax, so);
      try
        sc.CopyFrom(si, si.Size);
      finally
        sc.Free;
      end;
    finally
      so.Free;
    end;
  finally
    si.Free;
  end;
end;

procedure DecompressFile(FilIn, FilOut: string);
// 25.10.10 nk opt
// Decompress input file to new output file using the ZIP algorithm
// Input:  FilIn  = zipped file name
//         FilOut = unzipped file name
// Remark: Existing files will be overwritten w/o asking
var
  cnt: Integer;
  buf: array[0..K4] of Byte;
  si: TFileStream;
  so: TFileStream;
  sd: TDeCompressionStream;
begin                         //25.10.10 nk add fmShareDenyNone
  si := TFileStream.Create(FilIn, fmOpenRead or fmShareDenyNone);

  try
    so := TFileStream.Create(FilOut, fmCreate);
    try
      sd := TDecompressionStream.Create(si);
      try
        while True do begin
          cnt := sd.Read(buf[0], SizeOf(buf));
          if cnt = 0 then
            Break
          else
            so.Write(buf[0], cnt);
        end;
      finally
        sd.Free;
      end;
    finally
      so.Free;
    end;
  finally
    si.Free;
  end;
end;

procedure OpenExplorer(AFolder: string);
begin //11.08.18 nk add
  ShellExecute(Application.Handle,
    PChar('explore'),
    PChar(AFolder),
    nil,
    nil,
    SW_SHOWNORMAL);
end;

procedure ShowFileInfo(FilName: string; ListBox: TListBox);
var //V5//20.05.16 nk opt
  info: TFileInfo;
const
  Tabulator: array[0..0] of Integer = (70);
begin
  FileError := feNoError;
  FilName   := Trim(FilName);

  if FilName = cEMPTY then begin
    FileError := feEmptyParameter;
    Exit;
  end;

  info := GetFileInfo(FilName);
  ListBox.TabWidth := 1;
  SendMessage(ListBox.Handle, LB_SETTABSTOPS, 1, LPARAM(@Tabulator)); //V5//20.05.16 nk old=Longint (64-bit)

  with info, ListBox.Items do begin
    Clear;
    Add('File Name:'         + cTAB + Application.ExeName);
    Add('File Type:'         + cTAB + FileType);
    Add('Company Name:'      + cTAB + CompanyName);
    Add('File Description:'  + cTAB + FileDescription);
    Add('File Version:'      + cTAB + FileVersion);
    Add('Internal Name:'     + cTAB + InternalName);
    Add('Legal Copyright:'   + cTAB + LegalCopyRight);
    Add('Legal Trademarks:'  + cTAB + LegalTradeMarks);
    Add('Original Filename:' + cTAB + OriginalFileName);
    Add('Product Name:'      + cTAB + ProductName);
    Add('Product Version:'   + cTAB + ProductVersion);
    Add('Special Build:'     + cTAB + SpecialBuildStr);
    Add('Private Build:'     + cTAB + PrivateBuildStr);
    Add('File Function:'     + cTAB + FileFunction);
    Add('Debug Build:'       + cTAB + BoolValues[DebugBuild]);
    Add('Pre Release:'       + cTAB + BoolValues[PreRelease]);
    Add('Private Build:'     + cTAB + BoolValues[PrivateBuild]);
    Add('Special Build:'     + cTAB + BoolValues[SpecialBuild]);
  end;
end;

procedure ReadALine(var ReadFile: Text; var ReadString: string; Encoding: string = FILE_ENCODING);
begin //23.09.12 nk add - read an Unicode string from an UTF-8 encoded file (e.g. XML)
  Readln(ReadFile, ReadString);

  if Encoding = ENCODING_UTF8 then
    ReadString := UTF8ToString(RawByteString(ReadString));

  Application.ProcessMessages; //23.09.12 nk add - do not block application
end;

procedure WriteALine(var WriteFile: Text; WriteString: string; Encoding: string = FILE_ENCODING);
begin //V5//16.04.16 nk opt - write an Unicode string to an UTF-8 encoded file (e.g. XML)
  Writeln(WriteFile, WriteString); //Encoding is not used -> code page is determined in AssignFile(tfile, FilName, CP_UTF8)
  Application.ProcessMessages;     //do not block application
end;

initialization //28.12.09 nk add ff
  FileMatching := 0; //52//19.11.19 nk add
  FileSubDir  := 1; //V5//23.06.16 nk add
  FileListing := TStringList.Create;

finalization //28.12.09 nk add ff
  FileListing.Free;

end.
