'******************************************************************************
' TEXTS.INC      : Application Specific Multilingual Text Strings
'------------------------------------------------------------------------------
' Author         : Norbert Koechli CH-8048 Zurich           (c)seanus 1999-2007
' First version  : 16.05.00 nk  0.01  initial version
' Last update    : 25.09.00 nk  0.10  new dive profile window
'                  24.10.00 nk  0.11  openlogbook added
'                  14.10.01 nk  0.12  new texts added
'                  22.10.01 nk  0.13  new texts added / MAXTEXT=300
'                  11.11.01 nk  0.20  new numbers for unit texts
'                  07.12.01 nk  0.30  multi language character support
'                  25.12.01 nk  0.31  new texts for openmessage added
'                  12.01.02 nk  0.32  new message text added
'                  21.01.02 nk  0.40  new short and long selection text
'                  29.06.02 nk  0.41  improved unit conversion
'                  29.07.04 nk  0.42  new name texts.inc (old = divetext.inc)
'                  04.08.04 nk  0.43  opt Mitwoch -> Mittwoch
'                  06.08.04 nk  0.44  opt yes/no changed (yes = KEYLEFT)
'                  08.08.04 nk  0.45  add new # for replace with texts 140/141
'                  13.08.04 nk  0.46  add new text 192
'                  16.08.04 nk  0.47  opt remove all unit brackets (M)
'                  21.08.04 nk  0.48  opt test 61/62 add 1 space
'                  27.08.04 nk  0.49  add text 236..239
'                  27.08.04 nk  0.50  opt text 200..229 free (moved to 3xx)
'                  27.08.04 nk  0.51  opt text 230..235 res for unit conversions
'                  08.09.04 nk  0.52  opt change Text$ with Mask$
'                  26.11.04 nk  0.80  migration to Tiger 5.2 - beautified
'                  18.10.05 nk  0.81  InitText with dynamic language load
'                  08.12.05 nk  0.90  new hardware abstraction layer model
'                  12.12.05 nk  0.92  new window BARO shows air pressure
'                  15.12.05 nk  0.94  text 248/249 moved to 234/235 (BAR/PSI)
'                  27.12.05 nk  0.95  new gas management and selection menu
'                  17.02.07 nk  0.96  new texts for PidiSim added
'------------------------------------------------------------------------------
' Compiler       : Wilke Technology Tiger Basic 5.2
'------------------------------------------------------------------------------
' Comment        : String length is defined as 'user string size' in Task Main
'                  Message text lines must end with a new line delimiter NEWDEL$
'                  Use round bracket { for left or } for right symbolic arrows
'                  Use caret character # to dynamically replace text  
'                  Small characters are only supported by font #2 (SMALLCHAR)
'******************************************************************************

#define MAXLANG    2        ' number of supported languages (EN and DE)
#define LANGEN     0        ' english
#define LANGDE     1        ' german
#define LANGFR     2        ' french
#define LANGIT     3        ' italian
#define LANGES     4        ' spanisch

#define MAXTEXT    350      ' number of mask text per language
#define MAXHELP    60       ' number of help text per language
#define HELPLANG   0        ' number of language help text

#define MONLONG    151      ' number of first month (january)
#define DAYSHORT   163      ' number of first weekday (mo)
#define DAYLONG    170      ' number of first weekday (monday)
#define HOLTEXT    177      ' number of first holiday
#define LOGTEXT    200      ' number of first log book text
#define UNITEXT    224      ' number of first unit text
#define OBJTEXT    270      ' number of first object text
#define SIGTEXT    271      ' number of dynamic signal text
#define SELTEXT    100      ' offset for selection text 

array Mask$(MAXTEXT) of strings  ' mask text table
array Help$(MAXHELP) of strings  ' help text table

'------------------------------------------------------------------------------
' INITTEXT - Initialize multilingual text string array
'------------------------------------------------------------------ 17.02.07 --
sub InitText(byte LangNum)

  word n
  string buff$
  
  buff$ = trim$(str$(LangNum), SPACE$, 0)

  if LangNum >= MAXLANG then
    call LogError("InitText", "Unsupported language", buff$, 90h)
    return
  endif

  for n = 0 to MAXTEXT - 1
    Mask$(n) = EMPTY$  ' clear mask texts
  next

  for n = 0 to MAXHELP - 1
    Help$(n) = EMPTY$  ' clear help texts
  next
   
  if LangNum = LANGEN then  ' EN (english)

    Mask$(0) = "MAIN SELECTION"
    Mask$(1) = "NAVIGATION #"
    Mask$(2) = "SATURATION #"
    Mask$(3) = "GAS SWITCHING"
    Mask$(4) = "SETTINGS"
    Mask$(5) = "SERVICES"
    Mask$(6) = "COLD START"
    Mask$(7) = "SLEEP MODE"
    Mask$(8) = "SHUT DOWN"
    Mask$(9) = "CLOSE"

    Mask$(10) = "GAS SWITCHING"  ''nk'' dynamic depth
    Mask$(11) = "GAS 1   32 M"
    Mask$(12) = "GAS 2   46 M"
    Mask$(13) = "GAS 3   59 M"
    Mask$(14) = "GAS 4   71 M"
    Mask$(15) = "GAS 5   85 M"
    Mask$(16) = "GAS 6   98 M"
    Mask$(17) = "GAS 7  113 M"
    Mask$(18) = "GAS 8  125 M"
    Mask$(19) = "CLOSE"

    Mask$(20) = "SETTINGS"
    Mask$(21) = "PERSON"
    Mask$(22) = "EQUIPMENT"
    Mask$(23) = "GASES"
    Mask$(24) = "WARNINGS"
    Mask$(25) = "PARAMETER"
    Mask$(26) = "DISPLAY"
    Mask$(27) = "CLOCK"
    Mask$(28) = "GAS MIXES"
    Mask$(29) = "CLOSE"

    Mask$(30) = "SERVICES"
    Mask$(31) = "LOG BOOK"
    Mask$(32) = "DIVE PROFILES"
    Mask$(33) = "DIVE PLANNER"
    Mask$(34) = "GAS CALCULATOR"
    Mask$(35) = "CALENDAR"
    Mask$(36) = "DATA EXPORT"
    Mask$(37) = "SOFTWARE UPDATE"
    Mask$(38) = "SELF TEST"
    Mask$(39) = "CLOSE"

    Mask$(40) = "PERSON"
    Mask$(41) = "AGE"
    Mask$(42) = "HEIGHT"
    Mask$(43) = "WEIGHT"
    Mask$(44) = "GENDER"
    Mask$(45) = "CERTIFICATE"
    Mask$(46) = "EXPERIENCE"
    Mask$(47) = "SMOKING"
    Mask$(48) = "FITNESS"
    Mask$(49) = ""
    
    Mask$(50) = "EQUIPMENT"
    Mask$(51) = ""
    Mask$(52) = ""
    Mask$(53) = ""
    Mask$(54) = ""
    Mask$(55) = ""
    Mask$(56) = ""
    Mask$(57) = ""
    Mask$(58) = ""
    Mask$(59) = ""
    
    Mask$(60) = "DIVE GASES"
    Mask$(61) = ""
    Mask$(62) = ""
    Mask$(63) = ""
    Mask$(64) = ""
    Mask$(65) = ""
    Mask$(66) = ""
    Mask$(67) = ""
    Mask$(68) = ""
    Mask$(69) = ""

    Mask$(70) = "WARNINGS"
    Mask$(71) = "DIVE DEPTH"
    Mask$(72) = "ASCENT RATE %"
    Mask$(73) = "GAS WARNING %"
    Mask$(74) = "GAS ALARM %"
    Mask$(75) = "POWER WARNING %"
    Mask$(76) = "TEMPERATURE"
    Mask$(77) = "O2 PRESS."
    Mask$(78) = "N2 PRESS."
    Mask$(79) = ""
    
    Mask$(80) = "PARAMETER"
    Mask$(81) = "START DEPTH"
    Mask$(82) = "DECO LEVELS"
    Mask$(83) = "SAFETY STOP"
    Mask$(84) = "DEEP STOPS"
    Mask$(85) = "TRUE DEPTH"
    Mask$(86) = "DIVE END M~3"
    Mask$(87) = "AUTO OFF M~3"
    Mask$(88) = "LOG INTERVAL S"
    Mask$(89) = ""
    
    Mask$(90) = "DISPLAY"
    Mask$(91) = "LANGUAGE"
    Mask$(92) = "UNIT SYSTEM"
    Mask$(93) = "TIME FORMAT"
    Mask$(94) = "SUMMER TIME"
    Mask$(95) = "BRIGHTNESS %"
    Mask$(96) = "CONTRAST %"
    Mask$(97) = "BACKLIGHT S"
    Mask$(98) = "LOUDNESS %"
    Mask$(99) = ""

    Mask$(100) = "CLOCK"
    Mask$(101) = "YEAR"
    Mask$(102) = "MONTH"
    Mask$(103) = "DAY"
    Mask$(104) = "HOUR"
    Mask$(105) = "MINUTE"
    Mask$(106) = "ALARM CLOCK"
    Mask$(107) = "ALARM HOUR"
    Mask$(108) = "ALARM MINUTE"
    Mask$(109) = "SET CLOCK"

    Mask$(110) = "GAS MIXES"
    Mask$(111) = ""
    Mask$(112) = ""
    Mask$(113) = ""
    Mask$(114) = ""
    Mask$(115) = ""
    Mask$(116) = ""
    Mask$(117) = ""
    Mask$(118) = ""
    Mask$(119) = ""
    

    Mask$(130) = "DEPTH"
    Mask$(131) = "TIME"
    Mask$(132) = "DECO"
    Mask$(133) = "GAS"
    Mask$(134) = "NAVIGATION"
    Mask$(135) = "POWER"
    Mask$(136) = "CLOCK"
    Mask$(137) = "SATURATION"
    Mask$(138) = "BARO"
    Mask$(139) = ""

    Mask$(140) = "ON"
    Mask$(141) = "OFF"
    Mask$(142) = "MAX"
    Mask$(143) = "RBT"
    Mask$(144) = "TBT"
    Mask$(145) = ""
    Mask$(146) = ""
    Mask$(147) = ""
    Mask$(148) = ""
    Mask$(149) = ""
    
    Mask$(150) = "CALENDAR"
    Mask$(151) = "JANUARY"
    Mask$(152) = "FEBRUARY"
    Mask$(153) = "MARCH"
    Mask$(154) = "APRIL"
    Mask$(155) = "MAY"
    Mask$(156) = "JUNE"
    Mask$(157) = "JULY"
    Mask$(158) = "AUGUST"
    Mask$(159) = "SEPTEMBER"
    Mask$(160) = "OCTOBER"
    Mask$(161) = "NOVEMBER"
    Mask$(162) = "DECEMBER"

    Mask$(163) = "MO"
    Mask$(164) = "TU"
    Mask$(165) = "WE"
    Mask$(166) = "TH"
    Mask$(167) = "FR"
    Mask$(168) = "SA"
    Mask$(169) = "SU"

    Mask$(170) = "MONDAY"
    Mask$(171) = "TUESDAY"
    Mask$(172) = "WEDNESDAY"
    Mask$(173) = "THURSDAY"
    Mask$(174) = "FRIDAY"
    Mask$(175) = "SATURDAY"
    Mask$(176) = "SUNDAY"

    Mask$(177) = "GOOD FRIDAY"
    Mask$(178) = "EASTER"
    Mask$(179) = "EASTER MONDAY"
    Mask$(180) = "ASCENSION DAY"
    Mask$(181) = "WHITSUNTIDE"
    Mask$(182) = "WHIT MONDAY"
    Mask$(183) = "NEW YEAR'S DAY"
    Mask$(184) = "CHRISTMAS DAY"
    Mask$(185) = "SUMMER TIME"
    Mask$(186) = "WINTER TIME"
    Mask$(187) = "D: "
    Mask$(188) = "W: "
    Mask$(189) = "CLOSE"

    Mask$(190) = "DIVE PROFILE"
    Mask$(191) = "LOG BOOK"
    Mask$(192) = "DIVE CATALOG"
    Mask$(193) = "DATE"
    Mask$(194) = "TIME"
    Mask$(195) = "MIN"
    Mask$(196) = "LOAD DATA..."
    Mask$(197) = "PAGE"
    Mask$(198) = "MORE"
    Mask$(199) = "CLOSE"

    '02.02.07 nk add window DIVE PLANNER
    Mask$(200) = "DIVE PLANNER"
    Mask$(201) = "DIVE DEPTH"
    Mask$(202) = "DIVE TIME M~3"
    Mask$(203) = "RMV"
    Mask$(204) = "ASCENT TIME"
    Mask$(205) = "MAX PPO2"
    Mask$(206) = "MAX O2 %"
    Mask$(207) = "MAX N2 %"
    Mask$(208) = "GAS CONSUM"
    Mask$(209) = "CLOSE"

  ' text 210..219 free

    Mask$(220) = " "     ' 220-223 time conversions
    Mask$(221) = " M~3"  ' only small characters are supported
    Mask$(222) = " "     ' by character font #2 (SMALLCHAR)
    Mask$(223) = " M~3"  ' [min]

    Mask$(224) = " "     ' UNITEXT = 224 unit conversions
    Mask$(225) = " "
    Mask$(226) = " "
    Mask$(227) = " "
    Mask$(228) = " M"
    Mask$(229) = " D~1"  ' [Dft]
    Mask$(230) = " �C"
    Mask$(231) = " �F"
    Mask$(232) = " BAR"
    Mask$(233) = " ATA"
    Mask$(234) = " BAR"
    Mask$(235) = " PSI"
    Mask$(236) = " hPa"
    Mask$(237) = " iHg"
    Mask$(238) = " M"
    Mask$(239) = " yd"
    Mask$(240) = " �C"
    Mask$(241) = " �F"
    Mask$(242) = " cm"
    Mask$(243) = " in"
    Mask$(244) = " kg"
    Mask$(245) = " ~2"   ' lb symbol
    Mask$(246) = " M"
    Mask$(247) = " ~1"   ' ft symbol
    Mask$(248) = " M"    ' rounded 1m = 30ft
    Mask$(249) = " ~1"
    Mask$(250) = " cm"   ' rounded 30cm = 1ft
    Mask$(251) = " ~1"
    Mask$(252) = " M"    ' rounded 3m = 10ft
    Mask$(253) = " ~1"
    Mask$(254) = " M"    ' format m.cm
    Mask$(255) = " ~1"   ' format ft.in

    Mask$(256) = "{YES|NO}|"
    Mask$(257) = "ARE YOU SHURE?|"
    Mask$(258) = "PLEASE WAIT...|"
    Mask$(259) = "NO DATA|AVAILABLE|"
    Mask$(260) = "SETTING|CLOCK...|"
    Mask$(261) = "SHUT DOWN|"
    Mask$(262) = "SLEEP MODE|"
    Mask$(263) = "RESTART|"

  ' dynamic object texts 270...299
    Mask$(270) = ""         ' must be empty !
    Mask$(271) = ""         ' dynamic signal text
    Mask$(272) = "|ALARM OFF}|"
    Mask$(274) = "STORE|DATA...|"
    
    Mask$(275) = "WATER IS|TOO COLD|"
    Mask$(276) = "BREATH|SLOWER|"
    Mask$(277) = "CHECK|YOUR DEPTH|"
    Mask$(278) = "ASCEND|SLOWER|"
    Mask$(279) = "CHECK|YOUR GAS|" 
    Mask$(280) = "BATTERY POWER|IS LOW|"
    Mask$(281) = "O2 TOXICITY|IS TOO HIGH|"
    Mask$(282) = "O2 PRESSURE|IS TOO HIGH|"
    Mask$(283) = "GAS IS LOW|ASCEND NOW|"
    Mask$(284) = "ASCEND|SLOWER|"
    Mask$(285) = "CHECK|YOUR GAS|"
    Mask$(286) = "BATTERY POWER|IS VERY LOW|"
    Mask$(287) = "DECO STOP|VIOLATION|"
    Mask$(288) = "O2 TOXICITY|IS VERY HIGH|"
    Mask$(289) = "O2 PRESSURE|IS VERY HIGH|"
    Mask$(290) = "GAS IS LOW|ASCEND NOW|"

    ''nk'' make description of special chars @, #..
    
  ' 27.08.04 nk add - text 300..349 reserved for log book !!

    ''nk'' test only MaskX ff

    Mask$(300) = "METRICAL @220"
    Mask$(301) = "METRICAL @221"
    Mask$(302) = "METRICAL @222"
    Mask$(303) = "METRICAL @223"
    Mask$(304) = "METRICAL @223"
    Mask$(305) = "METRICAL @228"
    Mask$(306) = "METRICAL @230"
    Mask$(307) = "METRICAL @232"
    Mask$(308) = "METRICAL @234"
    Mask$(309) = "METRICAL @236"

    Mask$(310) = "METRICAL @238"
    Mask$(311) = "METRICAL @240"
    Mask$(312) = "METRICAL @242"
    Mask$(313) = "METRICAL @244"
    Mask$(314) = "METRICAL @246"
    Mask$(315) = "METRICAL @248"
    Mask$(316) = "METRICAL @250"
    Mask$(317) = "METRICAL @252"
    Mask$(318) = "METRICAL @254"
    Mask$(319) = "METRICAL @255"

    Mask$(320) = "IMPERIAL @220"
    Mask$(321) = "IMPERIAL @221"
    Mask$(322) = "IMPERIAL @222"
    Mask$(323) = "IMPERIAL @223"
    Mask$(324) = "IMPERIAL @223"
    Mask$(325) = "IMPERIAL @228"
    Mask$(326) = "IMPERIAL @230"
    Mask$(327) = "IMPERIAL @232"
    Mask$(328) = "IMPERIAL @234"
    Mask$(329) = "IMPERIAL @236"

    Mask$(330) = "IMPERIAL @238"
    Mask$(331) = "IMPERIAL @240"
    Mask$(332) = "IMPERIAL @242"
    Mask$(333) = "IMPERIAL @244"
    Mask$(334) = "IMPERIAL @246"
    Mask$(335) = "IMPERIAL @248"
    Mask$(336) = "IMPERIAL @250"
    Mask$(337) = "IMPERIAL @252"
    Mask$(338) = "IMPERIAL @253"
    Mask$(339) = "IMPERIAL @254"

    ''nk'' test only MaskX

    'Mask$(300) = "DIVE TIME @223"      ' s/min -> min/h (compressed)
    'Mask$(301) = "MAX. DEPTH @246"     ' cm -> m/ft
    'Mask$(302) = "AVG. DEPTH @246"     ' cm -> m/ft
    'Mask$(303) = "ASCENT RATE %"       ' %
    'Mask$(304) = "ADAPTION TIME @222"  ' min -> hh:mm
    'Mask$(305) = "INTERVAL TIME @222"  ' min -> hh:mm
    'Mask$(306) = "NO FLY TIME @222"    ' min -> hh:mm
    'Mask$(307) = "DESATURATION @222"   ' min -> hh:mm
    'Mask$(308) = "DECO TIME @221"      ' s -> min
    'Mask$(309) = "DECO DEPTH @252"     ' cm -> m/ft (round 3m=10ft)

    'Mask$(310) = "FILL PRESS. @234"    ' cbar -> bar/PSI
    'Mask$(311) = "ALTITUDE @228"       ' m -> m/Dft
    'Mask$(312) = "AIR TEMP. @240"      ' cK -> �C/�F
    'Mask$(313) = "AIR PRESS. @236"     ' mbar -> hPa/inHg
    'Mask$(314) = ""
    'Mask$(315) = ""
    'Mask$(316) = ""
    'Mask$(317) = ""
    'Mask$(318) = ""
    'Mask$(319) = ""


    Help$(0)   = "EN"
    Help$(1)   = "1   ,POOR"       ' max 13 chars for long help text
    Help$(2)   = "2   ,FAIR"
    Help$(3)   = "3   ,MODERATE"
    Help$(4)   = "4   ,GOOD"
    Help$(5)   = "5   ,VERY GOOD"
    Help$(6)   = "6   ,EXCELLENT"

    Help$(7)   = "1   ,BASIC DIVER"
    Help$(8)   = "2   ,ADVANCED"
    Help$(9)   = "3   ,DIVE LEADER"
    Help$(10)  = "4   ,DIVE MASTER"
    Help$(11)  = "5   ,INSTUCTOR"
    Help$(12)  = "6   ,EXPERT"

    Help$(13)  = "0   ,NEVER"
    Help$(14)  = "1   ,SOMETIMES"
    Help$(15)  = "2   ,OFTEN"

    Help$(21)  = "EN  ,ENGLISH"
    Help$(22)  = "GE  ,GERMAN"
    Help$(23)  = "FR  ,FRENCH"
    Help$(24)  = "IT  ,ITALIAN"
    Help$(25)  = ""
    Help$(26)  = ""
    Help$(27)  = ""
    Help$(28)  = ""
    Help$(29)  = ""

    Help$(30)  = "MET ,METRICAL"
    Help$(31)  = "IMP ,IMPERIAL"
    Help$(32)  = "M   ,MALE"
    Help$(33)  = "F   ,FEMALE"
    Help$(34)  = "~4  ,OFF"
    Help$(35)  = "EU  ,EUROPEAN"
    Help$(36)  = "US  ,AMERICAN"
    Help$(37)  = "INT ,INTERNATIONAL"
    Help$(38)  = "~4  ,OFF"
    Help$(39)  = "~5  ,ON"
    
    Help$(58)  = "}   ,EXECUTE"   ' command no 58
  
  endif

'------------------------------------------------------------------------------

  if LangNum = LANGDE then  ' DE (DEUTSCH)

    Mask$(0) = "HAUPTAUSWAHL"
    Mask$(1) = "NAVIGATION #"
    Mask$(2) = "S�TTIGUNG #"
    Mask$(3) = "GASUMSCHALTUNG"
    Mask$(4) = "EINSTELLUNGEN"
    Mask$(5) = "DIENSTE"
    Mask$(6) = "KALTSTART"
    Mask$(7) = "SCHLAFMODUS"
    Mask$(8) = "ABSCHALTEN"
    Mask$(9) = "SCHLIESSEN"

    Mask$(10) = "GASUMSCHALTUNG"
    Mask$(11) = "GAS 1   32 M"  ''nk'' dyn depth
    Mask$(12) = "GAS 2   46 M"
    Mask$(13) = "GAS 3   59 M"
    Mask$(14) = "GAS 4   71 M"
    Mask$(15) = "GAS 5   85 M"
    Mask$(16) = "GAS 6   98 M"
    Mask$(17) = "GAS 7  113 M"
    Mask$(18) = "GAS 8  125 M"
    Mask$(19) = "SCHLIESSEN"

    Mask$(20) = "EINSTELLUNGEN"
    Mask$(21) = "PERSON"
    Mask$(22) = "AUSR�STUNG"
    Mask$(23) = "TAUCHGASE"
    Mask$(24) = "WARNUNGEN"
    Mask$(25) = "PARAMETER"
    Mask$(26) = "ANZEIGE"
    Mask$(27) = "UHR"
    Mask$(28) = "GASGEMISCHE"
    Mask$(29) = "SCHLIESSEN"

    Mask$(30) = "DIENSTE"
    Mask$(31) = "LOGBUCH"
    Mask$(32) = "TAUCHPROFILE"
    Mask$(33) = "TAUCHPLANER"
    Mask$(34) = "GASRECHNER"
    Mask$(35) = "KALENDER"
    Mask$(36) = "DATENEXPORT"
    Mask$(37) = "SOFTWARE LADEN"
    Mask$(38) = "SELBSTTEST"
    Mask$(39) = "SCHLIESSEN"

    Mask$(40) = "PERSON"
    Mask$(41) = "ALTER"
    Mask$(42) = "GR�SSE"
    Mask$(43) = "GEWICHT"
    Mask$(44) = "GESCHLECHT"
    Mask$(45) = "ZERTIFIKAT"
    Mask$(46) = "ERFAHRUNG"
    Mask$(47) = "RAUCHEN"
    Mask$(48) = "FITNESS"
    Mask$(49) = ""

    Mask$(50) = "AUSR�STUNG"
    Mask$(51) = ""
    Mask$(52) = ""
    Mask$(53) = ""
    Mask$(54) = ""
    Mask$(55) = ""
    Mask$(56) = ""
    Mask$(57) = ""
    Mask$(58) = ""
    Mask$(59) = ""
    
    Mask$(60) = "TAUCHGASE"
    Mask$(61) = ""
    Mask$(62) = ""
    Mask$(63) = ""
    Mask$(64) = ""
    Mask$(65) = ""
    Mask$(66) = ""
    Mask$(67) = ""
    Mask$(68) = ""
    Mask$(69) = ""
    
    Mask$(70) = "WARNUNGEN"
    Mask$(71) = "TAUCHTIEFE"
    Mask$(72) = "AUFSTIEG %"
    Mask$(73) = "GASWARNUNG %"
    Mask$(74) = "GASALARM %"
    Mask$(75) = "AKKUWARNUNG %"
    Mask$(76) = "TEMPERATUR"
    Mask$(77) = "O2-DRUCK"
    Mask$(78) = "N2-DRUCK"
    Mask$(79) = ""
    
    Mask$(80) = "PARAMETER"
    Mask$(81) = "STARTTIEFE"
    Mask$(82) = "DEKOSTUFEN"
    Mask$(83) = "SICHER.STOPP"
    Mask$(84) = "TIEFE STOPPS"
    Mask$(85) = "WAHRE TIEFE"
    Mask$(86) = "TAUCHENDE M~3"
    Mask$(87) = "AUTO AUS M~3"
    Mask$(88) = "LOGINTERVALL S"
    Mask$(89) = ""
    
    Mask$(90) = "ANZEIGE"
    Mask$(91) = "SPRACHE"
    Mask$(92) = "EINHEITEN"
    Mask$(93) = "ZEITFORMAT"
    Mask$(94) = "SOMMERZEIT"
    Mask$(95) = "HELLIGKEIT %"
    Mask$(96) = "KONTRAST %"
    Mask$(97) = "LEUCHTDAUER S"
    Mask$(98) = "LAUTST�RKE %"
    Mask$(99) = ""

    Mask$(100) = "UHR"
    Mask$(101) = "JAHR"
    Mask$(102) = "MONAT"
    Mask$(103) = "TAG"
    Mask$(104) = "STUNDE"
    Mask$(105) = "MINUTE"
    Mask$(106) = "ALARM WECKER"
    Mask$(107) = "ALARM STUNDE"
    Mask$(108) = "ALARM MINUTE"
    Mask$(109) = "UHR STELLEN"

    Mask$(110) = "GASGEMISCHE"
    Mask$(111) = ""
    Mask$(112) = ""
    Mask$(113) = ""
    Mask$(114) = ""
    Mask$(115) = ""
    Mask$(116) = ""
    Mask$(117) = ""
    Mask$(118) = ""
    Mask$(119) = ""


    Mask$(130) = "TIEFE"
    Mask$(131) = "ZEIT"
    Mask$(132) = "DEKO"
    Mask$(133) = "GAS"
    Mask$(134) = "NAVIGATION"
    Mask$(135) = "AKKU"
    Mask$(136) = "UHR"
    Mask$(137) = "S�TTIGUNG"
    Mask$(138) = "BARO"
    Mask$(139) = ""

    Mask$(140) = "EIN" 
    Mask$(141) = "AUS"
    Mask$(142) = "MAX"
    Mask$(143) = "VGZ"
    Mask$(144) = "TGZ"
    Mask$(145) = ""
    Mask$(146) = ""
    Mask$(147) = ""
    Mask$(148) = ""
    Mask$(149) = ""
    
    Mask$(150) = "KALENDER"
    Mask$(151) = "JANUAR"
    Mask$(152) = "FEBRUAR"
    Mask$(153) = "M�RZ"
    Mask$(154) = "APRIL"
    Mask$(155) = "MAI"
    Mask$(156) = "JUNI"
    Mask$(157) = "JULI"
    Mask$(158) = "AUGUST"
    Mask$(159) = "SEPTEMBER"
    Mask$(160) = "OKTOBER"
    Mask$(161) = "NOVEMBER"
    Mask$(162) = "DEZEMBER"

    Mask$(163) = "MO"
    Mask$(164) = "DI"
    Mask$(165) = "MI"
    Mask$(166) = "DO"
    Mask$(167) = "FR"
    Mask$(168) = "SA"
    Mask$(169) = "SO"

    Mask$(170) = "MONTAG"
    Mask$(171) = "DIENSTAG"
    Mask$(172) = "MITTWOCH"
    Mask$(173) = "DONNERSTAG"
    Mask$(174) = "FREITAG"
    Mask$(175) = "SAMSTAG"
    Mask$(176) = "SONNTAG"

    Mask$(177) = "KARFREITAG"
    Mask$(178) = "OSTERN"
    Mask$(179) = "OSTERMONTAG"
    Mask$(180) = "AUFFAHRT"
    Mask$(181) = "PFINGSTEN"
    Mask$(182) = "PFINGSTMONTAG"
    Mask$(183) = "NEUJAHRSTAG"
    Mask$(184) = "WEIHNACHTEN"
    Mask$(185) = "SOMMERZEIT"
    Mask$(186) = "WINTERZEIT"
    Mask$(187) = "T: "
    Mask$(188) = "W: "
    Mask$(189) = "SCHLIESSEN"
    
    Mask$(190) = "TAUCHPROFIL"
    Mask$(191) = "LOGBUCH"
    Mask$(192) = "TAUCHVERZEICHNIS"
    Mask$(193) = "DATUM"
    Mask$(194) = "ZEIT"
    Mask$(195) = "MIN"
    Mask$(196) = "LADE DATEN..."
    Mask$(197) = "SEITE"
    Mask$(198) = "WEITER"
    Mask$(199) = "SCHLIESSEN"

    '02.02.07 nk add window DIVE PLANNER
    Mask$(200) = "TAUCHPLANER"
    Mask$(201) = "TAUCHTIEFE"
    Mask$(202) = "TAUCHZEIT"
    Mask$(203) = "ATMUNG"
    Mask$(204) = "AUFSTIEGSZEIT"
    Mask$(205) = "MAX PPO2"
    Mask$(206) = "MAX O2"
    Mask$(207) = "MAX N2"
    Mask$(208) = "GASPROGNOSE"
    Mask$(209) = ""

  ' text 210..219 free

    Mask$(220) = " "     ' 220-223 time conversions
    Mask$(221) = " M~3"  ' only small characters are supported
    Mask$(222) = " "     ' by character font #2 (SMALLCHAR)
    Mask$(223) = " M~3"  ' [min]

    Mask$(224) = " "     ' UNITEXT = 224 unit conversions
    Mask$(225) = " "
    Mask$(226) = " "
    Mask$(227) = " "
    Mask$(228) = " M"
    Mask$(229) = " D~1"  ' [Dft]
    Mask$(230) = " �C"
    Mask$(231) = " �F"
    Mask$(232) = " BAR"
    Mask$(233) = " ATA"
    Mask$(234) = " BAR"
    Mask$(235) = " PSI"
    Mask$(236) = " hPa"
    Mask$(237) = " iHg"
    Mask$(238) = " M"
    Mask$(239) = " yd"
    Mask$(240) = " �C"
    Mask$(241) = " �F"
    Mask$(242) = " cm"
    Mask$(243) = " in"
    Mask$(244) = " kg"
    Mask$(245) = " ~2"   ' lb symbol
    Mask$(246) = " M"
    Mask$(247) = " ~1"   ' ft symbol
    Mask$(248) = " M"    ' rounded 1m = 30ft
    Mask$(249) = " ~1"
    Mask$(250) = " cm"   ' rounded 30cm = 1ft
    Mask$(251) = " ~1"
    Mask$(252) = " M"    ' rounded 3m = 10ft
    Mask$(253) = " ~1"
    Mask$(254) = " M"    ' format m.cm
    Mask$(255) = " ~1"   ' format ft.in

    Mask$(256) = "{JA|NEIN}|"
    Mask$(257) = "SIND SIE SICHER?|"
    Mask$(258) = "BITTE WARTEN...|"
    Mask$(259) = "KEINE DATEN|VORHANDEN|"
    Mask$(260) = "UHR WIRD|GESTELLT...|"
    Mask$(261) = "ABSCHALTEN|"
    Mask$(262) = "SCHLAFMODUS|"
    Mask$(263) = "NEUSTART|"


    Mask$(270) = ""         ' must be empty !
    Mask$(271) = ""         ' dynamic signal text
    Mask$(272) = "|ALARM AUS}|"
    Mask$(274) = "DATEN WERDEN|GESPEICHERT...|"
    
    Mask$(275) = "WASSER IST|ZU KALT|"
    Mask$(276) = "LANGSAMER|ATMEN|"
    Mask$(277) = "TIEFE|PR�FEN|"
    Mask$(278) = "LANGSAM|AUFSTEIGEN|"
    Mask$(279) = "GAS|PR�FEN|" 
    Mask$(280) = "AKKU|IST KNAPP|"
    Mask$(281) = "O2-TOXIZIT�T|IST ZU HOCH|"
    Mask$(282) = "O2-DRUCK|IST ZU HOCH|"
    Mask$(283) = "GAS IST KNAPP|AUFSTEIGEN|"
    Mask$(284) = "LANGSAM|AUFSTEIGEN|"
    Mask$(285) = "GAS|PR�FEN|"
    Mask$(286) = "AKKU IST|SEHR KNAPP|"
    Mask$(287) = "DEKO STOP|VERLETZUNG|"
    Mask$(288) = "O2-TOXIZIT�T|IST SEHR HOCH|"
    Mask$(289) = "O2-DRUCK|IST SEHR HOCH|"
    Mask$(290) = "GAS IST KNAPP|AUFSTEIGEN|"
    
  ' 27.08.04 nk add - text 300..349 reserved for log book !!

    Mask$(300) = ""
    Mask$(301) = ""
    Mask$(302) = ""
    Mask$(303) = ""
    Mask$(304) = ""
    Mask$(305) = ""
    Mask$(306) = ""
    Mask$(307) = ""
    Mask$(308) = ""
    Mask$(309) = ""

    Mask$(310) = ""
    Mask$(311) = ""
    Mask$(312) = ""
    Mask$(313) = ""
    Mask$(314) = ""
    Mask$(315) = ""
    Mask$(316) = ""
    Mask$(317) = ""
    Mask$(318) = ""
    Mask$(319) = ""

    Mask$(320) = ""
    Mask$(321) = ""
    Mask$(322) = ""
    Mask$(323) = ""
    Mask$(324) = ""
    Mask$(325) = ""
    Mask$(326) = ""
    Mask$(327) = ""
    Mask$(328) = ""
    Mask$(329) = ""

    Help$(0)   = "DE"
    Help$(1)   = "1   ,SCHLECHT"       ' max 13 chars for long help text
    Help$(2)   = "2   ,M�SSIG"
    Help$(3)   = "3   ,MITTEL"
    Help$(4)   = "4   ,GUT"
    Help$(5)   = "5   ,SEHR GUT"
    Help$(6)   = "6   ,AUSGEZEICHNET"

    Help$(7)   = "1   ,GRUNDKURS"
    Help$(8)   = "2   ,ADVANCED"
    Help$(9)   = "3   ,TAUCHLEITER"
    Help$(10)  = "4   ,DIVEMASTER"
    Help$(11)  = "5   ,INSTUKTOR"
    Help$(12)  = "6   ,EXPERTE"

    Help$(13)  = "0   ,NIE"
    Help$(14)  = "1   ,MANCHMAL"
    Help$(15)  = "2   ,OFT"

    Help$(21)  = "EN  ,ENGLISCH"
    Help$(22)  = "DE  ,DEUTSCH"
    Help$(23)  = "FR  ,FRANZ�SISCH"
    Help$(24)  = "IT  ,ITALIENISCH"
    Help$(25)  = ""
    Help$(26)  = ""
    Help$(27)  = ""
    Help$(28)  = ""
    Help$(29)  = ""

    Help$(30)  = "MET ,METRISCH"
    Help$(31)  = "IMP ,IMPERIAL"
    Help$(32)  = "M   ,M�NNLICH"
    Help$(33)  = "W   ,WEIBLICH"
    Help$(34)  = "~4  ,AUS"
    Help$(35)  = "EU  ,EUROP�ISCH"
    Help$(36)  = "US  ,AMERIKANISCH"
    Help$(37)  = "INT ,INTERNATIONAL"
    Help$(38)  = "~4  ,AUS"
    Help$(39)  = "~5  ,AN"

    Help$(58)  = "}   ,AUSF�HREN"   ' command no 58
  endif

  if Help$(HELPLANG) = EMPTY$ then
    call LogError("InitText", "Texts not initialized - Language", buff$, 99h)
  else
    call LogEvent("InitText", "Texts initialized - Language", Help$(HELPLANG))
  endif

end
