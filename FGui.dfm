object Gui: TGui
  Left = 331
  Top = 263
  Hint = 'Display'
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsSingle
  Caption = ' PIDI Display'
  ClientHeight = 184
  ClientWidth = 202
  Color = clGray
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
  object Display: TImage
    Left = 8
    Top = 8
    Width = 185
    Height = 169
  end
end
