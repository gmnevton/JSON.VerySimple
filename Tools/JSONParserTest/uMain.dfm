object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'JSON Parser Test'
  ClientHeight = 663
  ClientWidth = 1027
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 700
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object SplitterEx1: TSplitterEx
    Left = 521
    Top = 43
    Width = 7
    Height = 620
    AssignedControl = Panel2
    AutoSnap = False
    DrawSpacer = True
    MinSize = 100
    ResizeStyle = rsUpdate
    ExplicitLeft = 321
    ExplicitTop = 89
    ExplicitHeight = 580
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1027
    Height = 43
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 121
      Height = 25
      Caption = 'Load JSON file...'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 144
      Top = 8
      Width = 121
      Height = 25
      Caption = 'Tree to JSON...'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 280
      Top = 8
      Width = 121
      Height = 25
      Caption = 'Save JSON to file...'
      TabOrder = 2
      OnClick = Button3Click
    end
    object CheckBox1: TCheckBox
      Left = 424
      Top = 12
      Width = 97
      Height = 17
      Caption = 'Auto indent'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = CheckBox1Click
    end
    object CheckBox2: TCheckBox
      Left = 528
      Top = 12
      Width = 97
      Height = 17
      Caption = 'Compact'
      TabOrder = 4
      OnClick = CheckBox2Click
    end
    object CheckBox3: TCheckBox
      Left = 631
      Top = 12
      Width = 97
      Height = 17
      Caption = 'Multiline strings'
      TabOrder = 5
      OnClick = CheckBox3Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 43
    Width = 521
    Height = 620
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object vstJSONTree: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 521
      Height = 620
      Align = alClient
      BevelEdges = [beRight]
      BevelKind = bkFlat
      BorderStyle = bsNone
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.MainColumn = -1
      Header.Options = [hoDrag]
      TabOrder = 0
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoDeleteMovedNodes, toAutoChangeScale]
      TreeOptions.MiscOptions = [toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect]
      TreeOptions.StringOptions = [toShowStaticText]
      OnGetText = vstJSONTreeGetText
      OnPaintText = vstJSONTreePaintText
      OnGetNodeDataSize = vstJSONTreeGetNodeDataSize
      Columns = <>
    end
  end
  object Memo1: TMemo
    Left = 528
    Top = 43
    Width = 499
    Height = 620
    Align = alClient
    BevelEdges = [beLeft]
    BevelKind = bkFlat
    BorderStyle = bsNone
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.json'
    Filter = 'JSON files (*.json)|*.json|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofExtensionDifferent, ofPathMustExist, ofFileMustExist, ofNoTestFileCreate, ofEnableSizing]
    Left = 56
    Top = 64
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.json'
    Filter = 'JSON files (*.json)|*.json|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofExtensionDifferent, ofPathMustExist, ofFileMustExist, ofCreatePrompt, ofEnableSizing, ofDontAddToRecent]
    Left = 136
    Top = 64
  end
end
