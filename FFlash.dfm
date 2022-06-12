object Flash: TFlash
  Left = 589
  Top = 235
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Flash Maker'
  ClientHeight = 102
  ClientWidth = 158
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbFlash: TLabel
    Left = 8
    Top = 8
    Width = 133
    Height = 13
    Caption = 'Flash file name (w/o ending)'
  end
  object lbSectors: TLabel
    Left = 8
    Top = 56
    Width = 36
    Height = 13
    Caption = 'Sectors'
  end
  object edFlash: TEdit
    Left = 8
    Top = 24
    Width = 139
    Height = 21
    TabStop = False
    AutoSelect = False
    AutoSize = False
    Ctl3D = False
    ParentCtl3D = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    Text = 'Flash.pfd'
    OnChange = edChange
  end
  object edSectors: TEdit
    Left = 8
    Top = 72
    Width = 49
    Height = 21
    TabStop = False
    AutoSelect = False
    AutoSize = False
    Ctl3D = False
    MaxLength = 2
    ParentCtl3D = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 2
    Text = '20'
    OnChange = edChange
  end
  object btMake: TButton
    Left = 72
    Top = 68
    Width = 75
    Height = 25
    Caption = 'Make'
    TabOrder = 0
    OnClick = btMakeClick
  end
end
