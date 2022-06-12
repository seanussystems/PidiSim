// Tank Data Receiver Functions
// Date 26.05.22

// DELPHI simulate the Tank Data Receiver with
// the Spin Edit 'seTankPress' on Form 'Daq'

// 25.07.17 nk opt for XE3 (AnsiString <-> string)
// 25.07.17 nk opt use string instead of ShortString (e.g. old=string[MAXBUFF])

unit Tank;

interface

uses
  Windows, SysUtils, Classes, TypInfo, Variants, USystem,
  SYS, Global, Data, Texts, FLog, UPidi;

  procedure InitTank;
  procedure ReadTank(TankTime: Long; var TankPress: Long);

const
  TANKMAX        = 650000;    // max tank pressure = 650bar (psi<9999)
  TANKFILL       = 200000;    // Tiger initial tank fill pressure [mbar]
  GASRATE        = 15;        // Tiger respiratory minute volume at surface [l/min]
  TANKUNIT       = ' bar';    // tank pressure unit

var
  TankGas: Long;              // remaining tank gas [mbar]
  TankBuff: string;           // modul message buffer / old=[MAXBUFF]

implementation

uses FMain;

//------------------------------------------------------------------------------
// INITTANK - Initialize Tank Data Receiver
//------------------------------------------------------------------ 17.02.07 --
procedure InitTank;
begin                               // 05.06.07 nk opt ff
  TankPress := FillPress;           // initial tank fill pressure [mbar]
  TankGas := TankSize * FillPress;  // tank gas capacity [mbarl]
  BreathRate := cCLEAR;             // breathing rate [mbar/s]

  if TankFlag = cON then begin
    TankBuff := IntToStr(TankPress div MILLI) + TANKUNIT;
    LogEvent('InitTank', 'Tank data receiver initialized at', TankBuff);
  end else begin
    LogEvent('InitTank', 'Tank data receiver not activated', sEMPTY);
  end;
end;

//------------------------------------------------------------------------------
// READTANK - Get tank pressure [mbar] from Tank Data Receiver and set TankFlag
//   DELPHI simulate gas consum [mbarl] while TankTime [ms]
//------------------------------------------------------------------ 17.02.07 --
procedure ReadTank(TankTime: Long; var TankPress: Long);
var
  press: Long;
  gas: Real;
begin
  if WaterFlag = cOFF then begin       // 05.06.07 nk opt ff
    TankGas := TankSize * FillPress;   // fill tank gas capacity [mbarl]
  end else begin
    gas := SurfResp;                   // respiratory minute volume at surface [l/min]
    gas := AmbPress * gas;             // gas rate at depth [mbarl/min]
    gas := TankTime * gas / MSEC_MIN;  // gas consum at depth [mbarl]
    TankGas := TankGas - Round(gas);   // rem tank gas capacity [mbarl]
  end;

  press := TankGas div TankSize;       // rem tank gas pressure [mbar]
  TankPress := Limit(press, 0, TANKMAX); // actual tank pressure [mbar]
end;

end.
