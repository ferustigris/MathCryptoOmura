object Form1: TForm1
  Left = 319
  Top = 197
  Width = 451
  Height = 748
  Caption = #1052#1101#1089#1089#1080'-'#1054#1084#1091#1088#1072
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mm
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object mMsg: TMemo
    Left = 0
    Top = 0
    Width = 443
    Height = 209
    Align = alTop
    Lines.Strings = (
      '12')
    TabOrder = 0
  end
  object sbbar: TStatusBar
    Left = 0
    Top = 684
    Width = 443
    Height = 18
    Panels = <
      item
        Width = 200
      end>
  end
  object bProgress: TProgressBar
    Left = 0
    Top = 668
    Width = 443
    Height = 16
    Align = alBottom
    Anchors = [akRight, akBottom]
    Max = 10000
    TabOrder = 2
  end
  object log: TMemo
    Left = 0
    Top = 394
    Width = 443
    Height = 274
    Align = alClient
    TabOrder = 3
  end
  object mReceive: TMemo
    Left = 0
    Top = 209
    Width = 443
    Height = 185
    Align = alTop
    Lines.Strings = (
      'mReceive')
    TabOrder = 4
  end
  object mm: TMainMenu
    Left = 136
    Top = 104
    object N1: TMenuItem
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084
      object nGen: TMenuItem
        Caption = #1055#1077#1088#1077#1076#1072#1095#1072
        OnClick = nGenClick
      end
      object nClose: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = nCloseClick
      end
    end
  end
end
