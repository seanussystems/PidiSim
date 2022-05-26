object Test: TTest
  Left = 509
  Top = 218
  BorderStyle = bsSingle
  Caption = ' Dive Test'
  ClientHeight = 206
  ClientWidth = 330
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
  object FlashMem: TPaintBox
    Left = 8
    Top = 8
    Width = 313
    Height = 20
    Color = clBtnFace
    ParentColor = False
  end
  object btWriteMany: TRzButton
    Left = 248
    Top = 48
    Caption = 'Write many'
    HotTrack = True
    TabOrder = 0
    OnClick = btWriteManyClick
  end
  object FlashStatus: TGroupBox
    Left = 8
    Top = 40
    Width = 153
    Height = 97
    Caption = ' Flash Memory Status '
    TabOrder = 1
    object txFreeBlocks: TLabel
      Left = 8
      Top = 32
      Width = 76
      Height = 13
      AutoSize = False
      Caption = 'Free blocks:'
    end
    object txUsedBlocks: TLabel
      Left = 8
      Top = 48
      Width = 76
      Height = 13
      AutoSize = False
      Caption = 'Used blocks:'
    end
    object txTotalBlocks: TLabel
      Left = 8
      Top = 16
      Width = 76
      Height = 13
      AutoSize = False
      Caption = 'Total blocks:'
    end
    object lbTotalBlocks: TLabel
      Left = 88
      Top = 16
      Width = 6
      Height = 13
      Caption = '0'
    end
    object lbFreeBlocks: TLabel
      Left = 88
      Top = 32
      Width = 6
      Height = 13
      Caption = '0'
    end
    object lbUsedBlocks: TLabel
      Left = 88
      Top = 48
      Width = 6
      Height = 13
      Caption = '0'
    end
    object txWriteAddr: TLabel
      Left = 8
      Top = 64
      Width = 76
      Height = 13
      AutoSize = False
      Caption = 'Write address:'
    end
    object lbWriteAddr: TLabel
      Left = 88
      Top = 64
      Width = 6
      Height = 13
      Caption = '0'
    end
    object txWriteSector: TLabel
      Left = 8
      Top = 80
      Width = 76
      Height = 13
      AutoSize = False
      Caption = 'Write sector:'
    end
    object lbWriteSector: TLabel
      Left = 88
      Top = 80
      Width = 6
      Height = 13
      Caption = '0'
    end
  end
  object btWriteOnce: TRzButton
    Left = 248
    Top = 80
    Caption = 'Write once'
    HotTrack = True
    TabOrder = 2
    OnClick = btWriteOnceClick
  end
  object btWriteLog: TRzButton
    Left = 248
    Top = 112
    Caption = 'Write Log'
    HotTrack = True
    TabOrder = 3
    OnClick = btWriteLogClick
  end
  object btClearSector: TRzButton
    Left = 168
    Top = 80
    Caption = 'Clear sector'
    HotTrack = True
    TabOrder = 4
    OnClick = btClearSectorClick
  end
  object seSectors: TRzSpinEdit
    Left = 168
    Top = 48
    Width = 47
    Height = 21
    Max = 100.000000000000000000
    AutoSelect = False
    AutoSize = False
    FrameHotTrack = True
    FrameVisible = True
    TabOrder = 5
  end
  object btClearFlash: TRzButton
    Left = 168
    Top = 112
    Caption = 'Clear flash'
    HotTrack = True
    TabOrder = 6
    OnClick = btClearFlashClick
  end
  object btChangeUnit: TRzButton
    Left = 168
    Top = 144
    Caption = 'Change unit'
    HotTrack = True
    TabOrder = 7
    OnClick = btChangeUnitClick
  end
  object btTest: TRzButton
    Left = 8
    Top = 144
    Caption = 'Test'
    HotTrack = True
    TabOrder = 8
    OnClick = btTestClick
  end
  object RzButton1: TRzButton
    Left = 8
    Top = 176
    Caption = 'Assertion'
    HotTrack = True
    TabOrder = 9
    OnClick = RzButton1Click
  end
  object RzButton2: TRzButton
    Left = 88
    Top = 176
    Caption = 'Exception'
    HotTrack = True
    TabOrder = 10
    OnClick = RzButton2Click
  end
  object RzButton3: TRzButton
    Left = 168
    Top = 176
    Caption = 'Violation'
    HotTrack = True
    TabOrder = 11
    OnClick = RzButton3Click
  end
  object RzButton4: TRzButton
    Left = 248
    Top = 176
    Caption = 'Division 0'
    HotTrack = True
    TabOrder = 12
    OnClick = RzButton4Click
  end
  object RzButton5: TRzButton
    Left = 248
    Top = 144
    Caption = 'Change gas'
    HotTrack = True
    TabOrder = 13
    OnClick = RzButton5Click
  end
  object TestLoop: TTimer
    OnTimer = TestLoopTimer
    Left = 216
    Top = 32
  end
end
