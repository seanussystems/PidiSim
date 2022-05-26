object Log: TLog
  Left = 306
  Top = 226
  Hint = 'Log'
  Caption = ' Dive Log'
  ClientHeight = 113
  ClientWidth = 467
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
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Terminal: TListBox
    Left = 8
    Top = 8
    Width = 457
    Height = 57
    Ctl3D = False
    ItemHeight = 13
    Items.Strings = (
      'Terminal')
    ParentCtl3D = False
    TabOrder = 0
  end
  object LogStatus: TStatusBar
    Left = 0
    Top = 94
    Width = 467
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = 'Clear'
        Width = 50
      end
      item
        Text = ' Status'
        Width = 50
      end>
  end
  object btClear: TButton
    Left = 56
    Top = 72
    Width = 50
    Height = 17
    Caption = 'Clear'
    TabOrder = 2
    OnClick = btClearClick
  end
end
