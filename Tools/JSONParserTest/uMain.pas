unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SplitEx, VirtualTrees, ExtCtrls, JSON.VerySimple;

type
  TJSONTreeNode = record
    JSONNode: TJSONNode;
  end;
  PJSONTreeNode = ^TJSONTreeNode;

  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    vstJSONTree: TVirtualStringTree;
    SplitterEx1: TSplitterEx;
    Memo1: TMemo;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    SaveDialog1: TSaveDialog;
    CheckBox3: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure vstJSONTreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure vstJSONTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstJSONTreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
  private
    json: TJSONVerySimple;

    procedure MakeJSONTree(const AJSONTree: TJSONVerySimple);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  json:=TJSONVerySimple.Create;
  json.NodeAutoIndent:=False;
//  json.Options:=json.Options + [joCompact];
//  json.Options:=json.Options + [joCompactWithBreakes];
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  json.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
begin
  if OpenDialog1.Execute then begin
    i:=Pos(' - ', Caption);
    if i > 0 then begin
      Caption:=Copy(Caption, 1, i - 1);
    end;
    Caption:=Caption + ' - ' + ExtractFileName(OpenDialog1.FileName);
    json.LoadFromFile(OpenDialog1.FileName);
    MakeJSONTree(json);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  json.NodeIndentStr := '  ';
  json.LineBreak := sLineBreak;
  json.NodeAutoIndent:=CheckBox1.Checked;
  if CheckBox2.Checked then
    json.Options:=json.Options + [joCompact]
  else
    json.Options:=json.Options - [joCompact];
  Memo1.Lines.Text:=json.Text;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  json.NodeIndentStr := '  ';
  json.LineBreak := sLineBreak;
  if SaveDialog1.Execute then begin
    if json.ChildNodes.Count > 0 then
      json.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if Memo1.Lines.Text <> '' then
    Button2Click(Button2);
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if Memo1.Lines.Text <> '' then
    Button2Click(Button2);
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
  json.MultilineStrings:=CheckBox3.Checked;
end;

procedure TForm1.MakeJSONTree(const AJSONTree: TJSONVerySimple);
var
  TreeParent, TreeNode: PVirtualNode;

  procedure DoTree(const ANode: TJSONNode);
  var
    NodeData: PJSONTreeNode;
    Node: TJSONNode;
  begin
    if ANode <> Nil then begin
      TreeNode:=vstJSONTree.AddChild(TreeParent);
      NodeData:=vstJSONTree.GetNodeData(TreeNode);
      with NodeData^ do begin
        JSONNode:=ANode;
      end;

      TreeParent:=TreeNode;
      try
        if ANode.HasChildNodes then
          for Node in ANode.ChildNodes do
            DoTree(Node);
      finally
        TreeParent:=TreeParent.Parent;
      end;
    end;
  end;

begin
  TreeParent:=Nil;
  vstJSONTree.BeginUpdate;
  try
    vstJSONTree.Clear;
    DoTree(AJSONTree.DocumentElement);
    vstJSONTree.FullExpand;
  finally
    vstJSONTree.EndUpdate;
  end;
end;

procedure TForm1.vstJSONTreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize:=SizeOf(TJSONTreeNode);
end;

procedure TForm1.vstJSONTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  NodeData: PJSONTreeNode;
begin
  NodeData:=Sender.GetNodeData(Node);
  if TextType = ttNormal then begin
    CellText:=Format('[%d]', [NodeData.JSONNode.Index]);
    if NodeData.JSONNode.Name <> '' then
      CellText:=CellText + Format(' "%s"', [NodeData.JSONNode.Name]);
  end
  else begin
    case NodeData.JSONNode.NodeType of
      jtObject: CellText:=Format('Object {%d}', [NodeData.JSONNode.ChildNodes.Count]);
      jtArray : CellText:=Format('Array {%d}', [NodeData.JSONNode.ChildNodes.Count]);
      jtString: CellText:='[' + NodeData.JSONNode.Value + ']';
      jtNumber: CellText:='{' + NodeData.JSONNode.Value + '}';
      jtTrue:   CellText:='True';
      jtFalse:  CellText:='False';
      jtNull:   CellText:='Null';
    else
      CellText:='';
    end;
  end;
end;

procedure TForm1.vstJSONTreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
var
  NodeData: PJSONTreeNode;
begin
  NodeData:=Sender.GetNodeData(Node);
  if TextType = ttStatic then begin
    case NodeData.JSONNode.NodeType of
      jtObject,
      jtArray  : TargetCanvas.Font.Color:=clLime;
      jtNumber : TargetCanvas.Font.Color:=clRed;
      jtTrue,
      jtFalse  : TargetCanvas.Font.Color:=clWindowText;
      jtNull   : TargetCanvas.Font.Color:=clGrayText;
    else
      TargetCanvas.Font.Color:=clBlue;
    end;
  end;
end;

end.
