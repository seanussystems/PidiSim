object Track: TTrack
  Left = 614
  Top = 209
  Hint = 'Track'
  Caption = ' Dive Track'
  ClientHeight = 235
  ClientWidth = 235
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object TrackStatus: TStatusBar
    Left = 0
    Top = 216
    Width = 235
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = '143 '#176
        Width = 46
      end
      item
        Alignment = taCenter
        Text = '123.4 m'
        Width = 60
      end
      item
        Text = ' Status'
        Width = 200
      end>
  end
  object TrackPanel: TPanel
    Left = 8
    Top = 8
    Width = 217
    Height = 201
    TabOrder = 1
    object TrackChart: TPolChart
      Left = 8
      Top = 6
      Width = 201
      Height = 187
      Cursor = crCross
      AllocSize = 1000
      AngleOffset = 90.000000000000000000
      AutoRedraw = True
      AutoCenter = True
      CenterX = 100
      CenterY = 93
      ClassDefault = 0
      DecPlaceRad = 0
      GridColor = clSilver
      GridStyleAngular = gsAngDots
      GridStyleRadial = gsRadBothMixed
      DataColor = clBlue
      ScaleColor = clNavy
      LabelModeAngular = almDegrees
      LabelModeRadial = rlmNone
      CrossHair1.Color = clBlack
      CrossHair1.LineType = psDash
      CrossHair1.LineWid = 1
      CrossHair1.Mode = chOff
      CrossHair2.Color = clBlack
      CrossHair2.LineType = psSolid
      CrossHair2.LineWid = 1
      CrossHair2.Mode = chOff
      CrossHair2.PosRad = 1.000000000000000000
      CrossHair3.Color = clBlack
      CrossHair3.LineType = psSolid
      CrossHair3.LineWid = 1
      CrossHair3.Mode = chOff
      CrossHair4.Color = clBlack
      CrossHair4.LineType = psSolid
      CrossHair4.LineWid = 1
      CrossHair4.Mode = chOff
      RangeHigh = 50.000000000000000000
      AngleBtwRays = 30.000000000000000000
      MagFactor = 0.720000000000000000
      MouseAction = maNone
      RotationDir = rdCounterCW
      ShadowStyle = ssFlying
      ShadowColor = clGray
      ShadowBakColor = clBtnFace
      TextFontStyle = []
      TextBkStyle = tbSolid
      TextBkColor = clWhite
      TextAlignment = taRightJustify
      UseDegrees = True
      OnMouseMoveInChart = TrackChartMouseMoveInChart
    end
  end
  object TrackLoop: TTimer
    Enabled = False
    Interval = 500
    Left = 176
    Top = 24
  end
end
