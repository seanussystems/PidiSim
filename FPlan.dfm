object Plan: TPlan
  Left = 362
  Top = 223
  Hint = 'Sym'
  Caption = ' Dive Simulation'
  ClientHeight = 343
  ClientWidth = 614
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
  PixelsPerInch = 96
  TextHeight = 13
  object PlanStatus: TStatusBar
    Left = 0
    Top = 324
    Width = 614
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = '125 min'
        Width = 60
      end
      item
        Alignment = taCenter
        Text = '-120 m'
        Width = 60
      end
      item
        Text = ' Status'
        Width = 50
      end>
    ExplicitTop = 259
    ExplicitWidth = 555
  end
  object PlanPanel: TPanel
    Left = 8
    Top = 8
    Width = 489
    Height = 201
    Ctl3D = True
    UseDockManager = False
    ParentCtl3D = False
    TabOrder = 1
    object PlanChart: TDepthChart
      Left = 26
      Top = 0
      Width = 350
      Height = 172
      AvoidDuplicateMarks = False
      AllocSize = 1000
      AutoRedraw = True
      MarginRight = 20
      MarginTop = 20
      MarginBottom = 40
      MinDupMarkDist = 1
      RRim = 20
      TRim = 20
      BRim = 40
      BackGroundImg.IncludePath = False
      BackGroundImg.FillMode = bfStretch
      BackGroundImg.AreaMode = bamNone
      BackGroundImg.AreaColor = 14540253
      BackGroundImg.AreaLeft = -1.000000000000000000
      BackGroundImg.AreaRight = 1.000000000000000000
      BackGroundImg.AreaTop = 1.000000000000000000
      BackGroundImg.AreaBottom = -1.000000000000000000
      ClassDefault = 0
      GridStyle = gsNone
      Isometric = False
      JointLayers.L01xControlledBy = 1
      JointLayers.L01yControlledBy = 1
      JointLayers.L02xControlledBy = 2
      JointLayers.L02yControlledBy = 2
      JointLayers.L03xControlledBy = 3
      JointLayers.L03yControlledBy = 3
      JointLayers.L04xControlledBy = 4
      JointLayers.L04yControlledBy = 4
      JointLayers.L05xControlledBy = 5
      JointLayers.L05yControlledBy = 5
      JointLayers.L06xControlledBy = 6
      JointLayers.L06yControlledBy = 6
      JointLayers.L07xControlledBy = 7
      JointLayers.L07yControlledBy = 7
      JointLayers.L08xControlledBy = 8
      JointLayers.L08yControlledBy = 8
      JointLayers.L09xControlledBy = 9
      JointLayers.L09yControlledBy = 9
      JointLayers.L10xControlledBy = 10
      JointLayers.L10yControlledBy = 10
      JointLayers.L11xControlledBy = 11
      JointLayers.L11yControlledBy = 11
      JointLayers.L12xControlledBy = 12
      JointLayers.L12yControlledBy = 12
      JointLayers.L13xControlledBy = 13
      JointLayers.L13yControlledBy = 13
      JointLayers.L14xControlledBy = 14
      JointLayers.L14yControlledBy = 14
      JointLayers.L15xControlledBy = 15
      JointLayers.L15yControlledBy = 15
      JointLayers.L16xControlledBy = 16
      JointLayers.L16yControlledBy = 16
      Caption = ''
      CaptionPosX = 0
      CaptionPosY = -16
      CaptionAlignment = taRightJustify
      CaptionAnchorHoriz = cahChartRight
      CaptionAnchorVert = cavChartTop
      CaptionTrim = 100
      MouseTraceColor = clWhite
      MouseTraceInvert = True
      CrossHair1.Color = clRed
      CrossHair1.Layer = 1
      CrossHair1.Mode = chOff
      CrossHair1.LineType = psDashDotDot
      CrossHair1.LineWid = 1
      CrossHair2.Color = clRed
      CrossHair2.Layer = 2
      CrossHair2.Mode = chOff
      CrossHair2.LineType = psDashDotDot
      CrossHair2.LineWid = 1
      CrossHair3.Color = clRed
      CrossHair3.Layer = 3
      CrossHair3.Mode = chOff
      CrossHair3.LineType = psDashDotDot
      CrossHair3.LineWid = 1
      CrossHair4.Color = clRed
      CrossHair4.Layer = 4
      CrossHair4.Mode = chOff
      CrossHair4.LineType = psDashDotDot
      CrossHair4.LineWid = 1
      MouseAction = maNone
      MouseCursorFixed = True
      PanGridDx = 1.000000000000000000
      PanGridDy = 1.000000000000000000
      Scale1X.CaptionPosX = 0
      Scale1X.CaptionPosY = 22
      Scale1X.CaptionAlignment = taCenter
      Scale1X.CaptionAnchor = uaSclCenter
      Scale1X.ColorScale = clBlack
      Scale1X.DateFormat.TimeFormat = tfHHMMSS
      Scale1X.DateFormat.DateSeparator = '-'
      Scale1X.DateFormat.TimeSeparator = ':'
      Scale1X.DateFormat.YearLength = ylYYYY
      Scale1X.DateFormat.MonthName = True
      Scale1X.DateFormat.DateOrder = doDDMMYY
      Scale1X.DateFormat.DateForTime = dtOnePerDay
      Scale1X.DecPlaces = -2
      Scale1X.Font.Charset = DEFAULT_CHARSET
      Scale1X.Font.Color = clWindowText
      Scale1X.Font.Height = -11
      Scale1X.Font.Name = 'Tahoma'
      Scale1X.Font.Style = []
      Scale1X.Logarithmic = False
      Scale1X.LabelType = ftNum
      Scale1X.MinTicks = 3
      Scale1X.MinRange = 0.000000000100000000
      Scale1X.MouseAction = maNone
      Scale1X.RangeHigh = 1.000000000000000000
      Scale1X.ShortTicks = True
      Scale1X.ScalePos = 0
      Scale1X.Visible = True
      Scale1X.ScaleLocation = slBottom
      Scale1Y.CaptionPosX = 0
      Scale1Y.CaptionPosY = -16
      Scale1Y.CaptionAlignment = taLeftJustify
      Scale1Y.CaptionAnchor = uaSclTopLft
      Scale1Y.ColorScale = clBlack
      Scale1Y.DateFormat.TimeFormat = tfHHMMSS
      Scale1Y.DateFormat.DateSeparator = '-'
      Scale1Y.DateFormat.TimeSeparator = ':'
      Scale1Y.DateFormat.YearLength = ylYYYY
      Scale1Y.DateFormat.MonthName = True
      Scale1Y.DateFormat.DateOrder = doDDMMYY
      Scale1Y.DateFormat.DateForTime = dtOnePerDay
      Scale1Y.DecPlaces = -2
      Scale1Y.Font.Charset = DEFAULT_CHARSET
      Scale1Y.Font.Color = clWindowText
      Scale1Y.Font.Height = -11
      Scale1Y.Font.Name = 'Tahoma'
      Scale1Y.Font.Style = []
      Scale1Y.Logarithmic = False
      Scale1Y.LabelType = ftNum
      Scale1Y.MinTicks = 3
      Scale1Y.MinRange = 0.000000000100000000
      Scale1Y.MouseAction = maNone
      Scale1Y.RangeHigh = 1.000000000000000000
      Scale1Y.ShortTicks = True
      Scale1Y.ScalePos = 0
      Scale1Y.Visible = True
      Scale1Y.ScaleLocation = slLeft
      Scale2X.CaptionPosX = 10
      Scale2X.CaptionPosY = 100
      Scale2X.CaptionAlignment = taCenter
      Scale2X.CaptionAnchor = uaSclCenter
      Scale2X.ColorScale = clMaroon
      Scale2X.DateFormat.TimeFormat = tfHHMMSS
      Scale2X.DateFormat.DateSeparator = '-'
      Scale2X.DateFormat.TimeSeparator = ':'
      Scale2X.DateFormat.YearLength = ylYYYY
      Scale2X.DateFormat.MonthName = True
      Scale2X.DateFormat.DateOrder = doDDMMYY
      Scale2X.DateFormat.DateForTime = dtOnePerDay
      Scale2X.DecPlaces = -2
      Scale2X.Font.Charset = DEFAULT_CHARSET
      Scale2X.Font.Color = clWindowText
      Scale2X.Font.Height = -11
      Scale2X.Font.Name = 'Tahoma'
      Scale2X.Font.Style = []
      Scale2X.Logarithmic = False
      Scale2X.LabelType = ftNum
      Scale2X.MinTicks = 3
      Scale2X.MinRange = 0.000000000100000000
      Scale2X.MouseAction = maNone
      Scale2X.RangeHigh = 1.000000000000000000
      Scale2X.ShortTicks = True
      Scale2X.ScalePos = 0
      Scale2X.Visible = False
      Scale2X.ScaleLocation = slBottom
      Scale2Y.CaptionPosX = 10
      Scale2Y.CaptionPosY = 100
      Scale2Y.CaptionAlignment = taRightJustify
      Scale2Y.CaptionAnchor = uaSclTopLft
      Scale2Y.ColorScale = clMaroon
      Scale2Y.DateFormat.TimeFormat = tfHHMMSS
      Scale2Y.DateFormat.DateSeparator = '-'
      Scale2Y.DateFormat.TimeSeparator = ':'
      Scale2Y.DateFormat.YearLength = ylYYYY
      Scale2Y.DateFormat.MonthName = True
      Scale2Y.DateFormat.DateOrder = doDDMMYY
      Scale2Y.DateFormat.DateForTime = dtOnePerDay
      Scale2Y.DecPlaces = -2
      Scale2Y.Font.Charset = DEFAULT_CHARSET
      Scale2Y.Font.Color = clWindowText
      Scale2Y.Font.Height = -11
      Scale2Y.Font.Name = 'Tahoma'
      Scale2Y.Font.Style = []
      Scale2Y.Logarithmic = False
      Scale2Y.LabelType = ftNum
      Scale2Y.MinTicks = 3
      Scale2Y.MinRange = 0.000000000100000000
      Scale2Y.MouseAction = maNone
      Scale2Y.RangeHigh = 1.000000000000000000
      Scale2Y.ShortTicks = True
      Scale2Y.ScalePos = 0
      Scale2Y.Visible = False
      Scale2Y.ScaleLocation = slLeft
      Scale3X.CaptionPosX = 10
      Scale3X.CaptionPosY = 100
      Scale3X.CaptionAlignment = taCenter
      Scale3X.CaptionAnchor = uaSclCenter
      Scale3X.ColorScale = clGreen
      Scale3X.DateFormat.TimeFormat = tfHHMMSS
      Scale3X.DateFormat.DateSeparator = '-'
      Scale3X.DateFormat.TimeSeparator = ':'
      Scale3X.DateFormat.YearLength = ylYYYY
      Scale3X.DateFormat.MonthName = True
      Scale3X.DateFormat.DateOrder = doDDMMYY
      Scale3X.DateFormat.DateForTime = dtOnePerDay
      Scale3X.DecPlaces = -2
      Scale3X.Font.Charset = DEFAULT_CHARSET
      Scale3X.Font.Color = clWindowText
      Scale3X.Font.Height = -11
      Scale3X.Font.Name = 'Tahoma'
      Scale3X.Font.Style = []
      Scale3X.Logarithmic = False
      Scale3X.LabelType = ftNum
      Scale3X.MinTicks = 3
      Scale3X.MinRange = 0.000000000100000000
      Scale3X.MouseAction = maNone
      Scale3X.RangeHigh = 1.000000000000000000
      Scale3X.ShortTicks = True
      Scale3X.ScalePos = 0
      Scale3X.Visible = False
      Scale3X.ScaleLocation = slBottom
      Scale3Y.CaptionPosX = 10
      Scale3Y.CaptionPosY = 100
      Scale3Y.CaptionAlignment = taRightJustify
      Scale3Y.CaptionAnchor = uaSclTopLft
      Scale3Y.ColorScale = clGreen
      Scale3Y.DateFormat.TimeFormat = tfHHMMSS
      Scale3Y.DateFormat.DateSeparator = '-'
      Scale3Y.DateFormat.TimeSeparator = ':'
      Scale3Y.DateFormat.YearLength = ylYYYY
      Scale3Y.DateFormat.MonthName = True
      Scale3Y.DateFormat.DateOrder = doDDMMYY
      Scale3Y.DateFormat.DateForTime = dtOnePerDay
      Scale3Y.DecPlaces = -2
      Scale3Y.Font.Charset = DEFAULT_CHARSET
      Scale3Y.Font.Color = clWindowText
      Scale3Y.Font.Height = -11
      Scale3Y.Font.Name = 'Tahoma'
      Scale3Y.Font.Style = []
      Scale3Y.Logarithmic = False
      Scale3Y.LabelType = ftNum
      Scale3Y.MinTicks = 3
      Scale3Y.MinRange = 0.000000000100000000
      Scale3Y.MouseAction = maNone
      Scale3Y.RangeHigh = 1.000000000000000000
      Scale3Y.ShortTicks = True
      Scale3Y.ScalePos = 0
      Scale3Y.Visible = False
      Scale3Y.ScaleLocation = slLeft
      Scale4X.CaptionPosX = 10
      Scale4X.CaptionPosY = 100
      Scale4X.CaptionAlignment = taCenter
      Scale4X.CaptionAnchor = uaSclCenter
      Scale4X.ColorScale = clOlive
      Scale4X.DateFormat.TimeFormat = tfHHMMSS
      Scale4X.DateFormat.DateSeparator = '-'
      Scale4X.DateFormat.TimeSeparator = ':'
      Scale4X.DateFormat.YearLength = ylYYYY
      Scale4X.DateFormat.MonthName = True
      Scale4X.DateFormat.DateOrder = doDDMMYY
      Scale4X.DateFormat.DateForTime = dtOnePerDay
      Scale4X.DecPlaces = -2
      Scale4X.Font.Charset = DEFAULT_CHARSET
      Scale4X.Font.Color = clWindowText
      Scale4X.Font.Height = -11
      Scale4X.Font.Name = 'Tahoma'
      Scale4X.Font.Style = []
      Scale4X.Logarithmic = False
      Scale4X.LabelType = ftNum
      Scale4X.MinTicks = 3
      Scale4X.MinRange = 0.000000000100000000
      Scale4X.MouseAction = maNone
      Scale4X.RangeHigh = 1.000000000000000000
      Scale4X.ShortTicks = True
      Scale4X.ScalePos = 0
      Scale4X.Visible = False
      Scale4X.ScaleLocation = slBottom
      Scale4Y.CaptionPosX = 10
      Scale4Y.CaptionPosY = 100
      Scale4Y.CaptionAlignment = taRightJustify
      Scale4Y.CaptionAnchor = uaSclTopLft
      Scale4Y.ColorScale = clOlive
      Scale4Y.DateFormat.TimeFormat = tfHHMMSS
      Scale4Y.DateFormat.DateSeparator = '-'
      Scale4Y.DateFormat.TimeSeparator = ':'
      Scale4Y.DateFormat.YearLength = ylYYYY
      Scale4Y.DateFormat.MonthName = True
      Scale4Y.DateFormat.DateOrder = doDDMMYY
      Scale4Y.DateFormat.DateForTime = dtOnePerDay
      Scale4Y.DecPlaces = -2
      Scale4Y.Font.Charset = DEFAULT_CHARSET
      Scale4Y.Font.Color = clWindowText
      Scale4Y.Font.Height = -11
      Scale4Y.Font.Name = 'Tahoma'
      Scale4Y.Font.Style = []
      Scale4Y.Logarithmic = False
      Scale4Y.LabelType = ftNum
      Scale4Y.MinTicks = 3
      Scale4Y.MinRange = 0.000000000100000000
      Scale4Y.MouseAction = maNone
      Scale4Y.RangeHigh = 1.000000000000000000
      Scale4Y.ShortTicks = True
      Scale4Y.ScalePos = 0
      Scale4Y.Visible = False
      Scale4Y.ScaleLocation = slLeft
      ShadowStyle = ssFlying
      ShadowColor = clGrayText
      ShadowBakColor = clBtnFace
      StyleElements = []
      TextFont.Charset = DEFAULT_CHARSET
      TextFont.Color = clWindowText
      TextFont.Height = -11
      TextFont.Name = 'Tahoma'
      TextFont.Style = []
      TextFontStyle = []
      TextBkStyle = tbClear
      TextAlignment = taCenter
      OnMouseDown = PlanChartMouseDown
      OnMouseMoveInChart = PlanChartMouseMoveInChart
    end
  end
  object PlanControls: TPanel
    Left = 0
    Top = 293
    Width = 614
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = True
    UseDockManager = False
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 2
    ExplicitTop = 432
    ExplicitWidth = 704
    DesignSize = (
      614
      31)
    object btDepth: TRzBitBtn
      Left = 16
      Top = 3
      Width = 22
      Height = 22
      Hint = ' Expand depth range '
      DropDownOnEnter = False
      ShowDownPattern = False
      ShowFocusRect = False
      Anchors = [akLeft, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      HighlightColor = clBtnFace
      HotTrack = True
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      TabStop = False
      ThemeAware = False
      OnClick = btDepthClick
      ImageIndex = 0
      Images = PlanIcons
      Layout = blGlyphTop
      Margin = 0
      Spacing = 0
      ExplicitTop = 29
    end
    object cbGasMix: TRzComboBox
      Left = 56
      Top = 4
      Width = 97
      Height = 21
      Hint = ' Select gas mix '
      AllowEdit = False
      Anchors = [akLeft, akBottom]
      AutoComplete = False
      AutoCloseUp = True
      BeepOnInvalidKey = False
      Ctl3D = False
      FrameVisible = True
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnDrawItem = cbGasMixDrawItem
      OnSelect = cbGasMixSelect
      ExplicitTop = 30
    end
    object btClear: TRzButton
      Left = 437
      Top = 3
      Width = 64
      Height = 22
      Hint = ' Clear dive profile '
      ShowDownPattern = False
      ShowFocusRect = False
      Anchors = [akRight, akBottom]
      Caption = 'Clear'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      HotTrack = True
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btClearClick
      ExplicitLeft = 527
    end
    object btStart: TRzButton
      Left = 509
      Top = 3
      Width = 64
      Height = 22
      Hint = ' Start dive simulation '
      ShowDownPattern = False
      ShowFocusRect = False
      Anchors = [akRight, akBottom]
      Caption = 'Start'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      HotTrack = True
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btStartClick
      ExplicitLeft = 599
    end
    object btTime: TRzBitBtn
      Left = 581
      Top = 3
      Width = 22
      Height = 22
      Hint = ' Expand time range '
      DropDownOnEnter = False
      ShowDownPattern = False
      ShowFocusRect = False
      Anchors = [akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      HighlightColor = clBtnFace
      HotTrack = True
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      TabStop = False
      ThemeAware = False
      OnClick = btTimeClick
      ImageIndex = 1
      Images = PlanIcons
      Margin = 0
      Spacing = 0
      ExplicitLeft = 671
    end
  end
  object PlanLoop: TTimer
    Enabled = False
    Interval = 500
    Left = 528
    Top = 32
  end
  object PlanIcons: TImageList
    Left = 528
    Top = 80
    Bitmap = {
      494C010102000500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000959595009595950000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000009595950000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000002004400020044009595950095959500000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000020044009595950095959500000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000200440002004400020044000200440095959500959595000000
      0000000000000000000000000000000000000000000000000000000000009595
      9500959595009595950095959500020044000200440095959500959595000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000020044000200440002004400020044000200440002004400959595009595
      9500000000000000000000000000000000000000000000000000020044000200
      4400020044000200440002004400020044000200440002004400959595009595
      9500000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000200
      4400020044000200440002004400020044000200440002004400020044000000
      0000000000000000000000000000000000000000000000000000020044000200
      4400020044000200440002004400020044000200440002004400020044009595
      9500000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000200440002004400020044000200440095959500000000000000
      0000000000000000000000000000000000000000000000000000020044000200
      4400020044000200440002004400020044000200440002004400020044000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000200440002004400020044000200440095959500000000000000
      0000000000000000000000000000000000000000000000000000020044000200
      4400020044000200440002004400020044000200440002004400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000200440002004400020044000200440095959500000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000020044000200440000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000200440002004400020044000200440095959500000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000020044000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000200440002004400020044000200440000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000FFFFFFFF00000000
      FFFFFFFF00000000FFFFFFFF00000000FE7FFF7F00000000FC3FFE3F00000000
      F81FE01F00000000F00FC00F00000000E01FC00F00000000F83FC01F00000000
      F83FC03F00000000F83FFE7F00000000F83FFEFF00000000F87FFFFF00000000
      FFFFFFFF00000000FFFFFFFF0000000000000000000000000000000000000000
      000000000000}
  end
end
