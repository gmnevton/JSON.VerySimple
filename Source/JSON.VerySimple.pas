{ JSON.VerySimple v1.3.0 - a lightweight, one-unit, cross-platform JSON reader/writer
  for Delphi 2010+ by Grzegorz Molenda
  https://github.com/gmnevton/JSON.VerySimple

  (c) Copyrights 2016-2017 Grzegorz Molenda aka NevTon <gmnevton@gmail.com>
  This unit is free and can be used for any needs. The introduction of
  any changes and the use of those changed library is permitted without
  limitations. Only requirement:
  This text must be present without changes in all modifications of library.

  * The contents of this file are used with permission, subject to    *
  * the Mozilla Public License Version 1.1 (the "License"); you may   *
  * not use this file except in compliance with the License. You may  *
  * obtain a copy of the License at                                   *
  * http:  www.mozilla.org/MPL/MPL-1.1.html                           *
  *                                                                   *
  * Software distributed under the License is distributed on an       *
  * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or    *
  * implied. See the License for the specific language governing      *
  * rights and limitations under the License.                         *
}
unit JSON.VerySimple;

interface

uses
  Classes, SysUtils, Generics.Defaults, Generics.Collections{, uStreamWriter};

const
  TJSONSpaces = #$20 + #$0D + #$0A + #9;

type
  TJSONString = type String;
  TJSONVerySimple = class;
  TJSONNode = class;
  TJSONNodeType = (jtObject, jtArray, jtString, jtNumber, jtTrue, jtFalse, jtNull);
  TJSONNodeTypes = set of TJSONNodeType;
  TJSONRootType = (jrtObject, jrtArray);
  TJSONNodeSearchType = (jsRecursive);
  TJSONNodeSearchTypes = set of TJSONNodeSearchType;
  TJSONNodeList = class;
  TJSONOptions = set of (joNodeAutoIndent, joCompact, joCompactWithBreakes, joPreserveWhiteSpace, joCaseInsensitive, joWriteBOM, joMultilineStrings);
  TJSONExtractTextOptions = set of (jetDeleteToStopChar, jetDeleteWithStopChar, jetStopString);

  TJSONParseException = class(Exception);

  TJSONNodeCallBack = reference to procedure(Node: TJSONNode);

  TJSONNode = class(TObject)
  private
    FName: TJSONString;
    FValue: TJSONString;
    FLevel: Cardinal; // node level in tree structure
    FIndex: Cardinal; // node index in nodes list structure
    FPrevSibling,           // link to the node's previous sibling or nil if it is the first node
    FNextSibling: TJSONNode; // link to the node's next sibling or nil if it is the last node
    FNodeType: TJSONNodeType;

    function IsSame(const Value1, Value2: TJSONString): Boolean;
    procedure _SetNodeType(const Value: TJSONNodeType);
    ///	<summary> Find a child node by its name in tree </summary>
    function FindNodeRecursive(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []; const SearchOptions: TJSONNodeSearchTypes = []): TJSONNode; overload; virtual;
    ///	<summary> Find a child node by name and value in tree </summary>
    function FindNodeRecursive(const Name, Value: TJSONString; NodeTypes: TJSONNodeTypes = []; const SearchOptions: TJSONNodeSearchTypes = []): TJSONNode; overload; virtual;
    ///	<summary> Return a list of child nodes with the given name and (optional) node types in tree </summary>
//    function FindNodesRecursive(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNodeList; virtual;
  protected
    [Weak] FDocument: TJSONVerySimple;
    procedure SetDocument(Value: TJSONVerySimple);
    procedure SetName(Value: TJSONString);
    procedure SetValue(Value: TJSONString);
    function GetName: TJSONString;
    function GetValue: TJSONString;
  public
    ///	<summary> List of child nodes, never NIL </summary>
    ChildNodes: TJSONNodeList;
    ///	<summary> Parent node, may be NIL </summary>
    [Weak] ParentNode: TJSONNode;
    /// <summary> Creates a new JSON node </summary>
    constructor Create(ANodeType: TJSONNodeType); virtual;
    ///	<summary> Removes the node from its parent and frees all of its childs </summary>
    destructor Destroy; override;
    ///	<summary> Clears the attributes, the text and all of its child nodes (but not the name) </summary>
    procedure Clear;
    ///	<summary> Find a child node by its name </summary>
    function FindNode(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []; const SearchOptions: TJSONNodeSearchTypes = []): TJSONNode; overload; virtual;
    ///	<summary> Find a child node by name and attribute name </summary>
    function FindNode(const Name, Value: TJSONString; NodeTypes: TJSONNodeTypes = []; const SearchOptions: TJSONNodeSearchTypes = []): TJSONNode; overload; virtual;
    ///	<summary> Return a list of child nodes with the given name and (optional) node types </summary>
    function FindNodes(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNodeList; virtual;
    // Loops trough childnodes with given Name
    procedure ScanNodes(Name: TJSONString; CallBack: TJSONNodeCallBack);
    ///	<summary> Returns True if a child node with that name exits </summary>
    function HasChild(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): Boolean; virtual;
    ///	<summary> Add a child node with an optional NodeType (default: [])</summary>
    function AddChild(const AName: TJSONString; ANodeType: TJSONNodeType): TJSONNode; virtual;
    ///	<summary> Removes a child node</summary>
    function RemoveChild(const Node: TJSONNode): Integer; virtual;
    ///	<summary> Moves a child node</summary>
    function MoveChild(const FromNode, ToNode: TJSONNode): TJSONNode; virtual;
    ///	<summary> Add a nodes tree from existing node </summary>
    procedure AddNodes(const RootNode: TJSONNode; const AddRootNode: Boolean = False); virtual;
    ///	<summary> Insert a child node at a specific position with a NodeType (default: [])</summary>
    function InsertChild(const Name: TJSONString; Position: Integer; NodeType: TJSONNodeType): TJSONNode; virtual;
    ///	<summary> Fluent interface for setting the text of the node </summary>
    function SetText(const AValue: TJSONString): TJSONNode; virtual;
    ///	<summary> Returns first child or NIL if there aren't any child nodes </summary>
    function FirstChild: TJSONNode; virtual;
    ///	<summary> Returns last child node or NIL if there aren't any child nodes </summary>
    function LastChild: TJSONNode; virtual;
    ///	<summary> Returns previous sibling </summary>
    function PreviousSibling: TJSONNode; overload; virtual;
    ///	<summary> Returns next sibling </summary>
    function NextSibling: TJSONNode; overload; virtual;
    ///	<summary> Returns True if the node has at least one child node </summary>
    function HasChildNodes: Boolean; virtual;
    ///	<summary> Fluent interface for setting the node type </summary>
    function SetNodeType(const Value: TJSONNodeType): TJSONNode; virtual;
    ///	<summary> Name of the node </summary>
    property Name: TJSONString read GetName write SetName;
    ///	<summary> Text value of the node </summary>
    property Value: TJSONString read GetValue write SetValue;
    ///	<summary> The JSON document of the node </summary>
    property Document: TJSONVerySimple read FDocument write SetDocument;
    ///	<summary> The node name, same as property Name </summary>
    property NodeName: TJSONString read GetName write SetName;
    ///	<summary> The node type, see TJSONNodeType </summary>
    property NodeType: TJSONNodeType read FNodeType write _SetNodeType;
    ///	<summary> The node text, same as property Text </summary>
    property NodeValue: TJSONString read GetValue write SetValue;
    ///	<summary> The node Level in tree </summary>
    property Level: Cardinal read FLevel;
    ///	<summary> The node Index in list </summary>
    property Index: Cardinal read FIndex;
  end;

  TJSONNodeList = class(TObjectList<TJSONNode>)
  private
    function IsSame(const Value1, Value2: TJSONString): Boolean;
  public
    ///	<summary> The JSON document of the node list </summary>
    [Weak] Document: TJSONVerySimple;
    ///	<summary> The parent node of the node list </summary>
    [Weak] Parent: TJSONNode;
    ///	<summary> Adds a node and sets the parent of the node to the parent of the list </summary>
    function Add(Value: TJSONNode): Integer; overload; virtual;
    ///	<summary> Creates a new node of type NodeType (default []) and adds it to the list </summary>
    function Add(NodeType: TJSONNodeType): TJSONNode; overload; virtual;
    ///	<summary> Add a child node with an optional NodeType (default: [])</summary>
    function Add(const Name: TJSONString; NodeType: TJSONNodeType): TJSONNode; overload; virtual;
    ///	<summary> Inserts a node at the given position </summary>
    function Insert(const Name: TJSONString; Position: Integer; NodeType: TJSONNodeType): TJSONNode; overload; virtual;
    ///	<summary> Removes a node at the given position </summary>
    procedure Remove(Index: Integer); overload; virtual;
    ///	<summary> Find a node by its name (case sensitive), returns NIL if no node is found </summary>
    function Find(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNode; overload; virtual;
    ///	<summary> Same as Find(), returnsa a node by its name (case sensitive) </summary>
    function FindNode(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNode; virtual;
    ///	<summary> Find a node that has the the given attribute, returns NIL if no node is found </summary>
    function Find(const Name, Value: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNode; overload; virtual;
    ///	<summary> Return a list of child nodes with the given name and (optional) node types </summary>
    function FindNodes(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNodeList; virtual;
    // Loops trough childnodes with given Name
//    procedure ScanNodes(const Name: TJSONString; CallBack: TJSONNodeCallBack);
    ///	<summary> Returns True if the list contains a node with the given name </summary>
    function HasNode(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): Boolean; virtual;
    ///	<summary> Returns the first child node, same as .First </summary>
    function FirstChild: TJSONNode; virtual;
    ///	<summary> Returns previous sibling node </summary>
    function PreviousSibling(Node: TJSONNode): TJSONNode; virtual;
    ///	<summary> Returns next sibling node </summary>
    function NextSibling(Node: TJSONNode): TJSONNode; virtual;
    ///	<summary> Returns the node at the given position </summary>
    function Get(Index: Integer): TJSONNode; virtual;
    ///	<summary> Returns the node count of the given name</summary>
    function CountNames(const Name: TJSONString; var NodeList: TJSONNodeList): Integer; virtual;
  end;

  TJSONEscapeProcedure = reference to procedure (var TextLine: TJSONString);

  TJSONVerySimple = class(TObject)
  private
    FEncoding: TJSONString;
    FDivider: TJSONString;
  protected
    Root: TJSONNode;
    [Weak] FDocumentElement: TJSONNode;
    SkipIndent: Boolean;
    JSONEscapeProcedure: TJSONEscapeProcedure;
    procedure Parse(Reader: TStreamReader); virtual;
    procedure ParseObject(Reader: TStreamReader; var Parent: TJSONNode);
    procedure ParsePair(Reader: TStreamReader; var Parent: TJSONNode);
    procedure ParseValue(Reader: TStreamReader; var Parent: TJSONNode);
    procedure ParseArray(Reader: TStreamReader; var Parent: TJSONNode);
    procedure Walk(Writer: TStreamWriter; const PrefixNode: TJSONString; Node: TJSONNode); virtual;
    procedure SetText(const Value: TJSONString); virtual;
    function  GetText: TJSONString; virtual;
    procedure SetEncoding(const Value: TJSONString); virtual;
    function  GetEncoding: TJSONString; virtual;
    procedure Compose(Writer: TStreamWriter); virtual;
    function  GetChildNodes: TJSONNodeList; virtual;
    function  ExtractText(var Line: TJSONString; const StopChars: TJSONString; Options: TJSONExtractTextOptions): TJSONString; virtual;
    procedure SetDocumentElement(Value: TJSONNode); virtual;
    procedure SetNodeAutoIndent(const Value: Boolean);
    function  GetNodeAutoIndent: Boolean;
    procedure SetPreserveWhitespace(const Value: Boolean);
    function  GetPreserveWhitespace: Boolean;
    procedure SetMultilineStrings(const Value: Boolean);
    function  GetMultilineStrings: Boolean;
    function  IsSame(const Value1, Value2: TJSONString): Boolean;
  public
    ///	<summary> Indent used for the JSON output </summary>
    NodeIndentStr: TJSONString;
    ///	<summary> LineBreak used for the JSON output, default set to sLineBreak which is OS dependent </summary>
    LineBreak: TJSONString;
    ///	<summary> Options for JSON output like indentation type </summary>
    Options: TJSONOptions;
    ///	<summary> Creates a new JSON document parser </summary>
    constructor Create(const RootType: TJSONRootType = jrtObject); virtual;
    ///	<summary> Destroys the JSON document parser </summary>
    destructor Destroy; override;
    ///	<summary> Deletes all nodes </summary>
    procedure Clear; virtual;
    ///	<summary> Adds a new node to the document</summary>
    function AddChild(const Name: TJSONString; NodeType: TJSONNodeType): TJSONNode; virtual;
    ///	<summary> Removes a child node</summary>
    function RemoveChild(const Node: TJSONNode): Integer; virtual;
    ///	<summary> Moves a child node</summary>
    function MoveChild(const FromNode, ToNode: TJSONNode): TJSONNode; virtual;
    ///	<summary> Creates a new node but doesn't adds it to the document nodes </summary>
    function CreateNode(const Name: TJSONString; NodeType: TJSONNodeType): TJSONNode; virtual;
    /// <summary> Escapes JSON control characters </summar>
    class function Escape(const Value: TJSONString): TJSONString; virtual;
    /// <summary> Translates escaped characters back into JSON control characters </summar>
    class function Unescape(const Value: TJSONString): TJSONString; virtual;
    ///	<summary> Loads the JSON from a file </summary>
    function LoadFromFile(const FileName: String; BufferSize: Integer = 4096): TJSONVerySimple; virtual;
    ///	<summary> Loads the JSON from a stream </summary>
    function LoadFromStream(const Stream: TStream; BufferSize: Integer = 4096): TJSONVerySimple; virtual;
    ///	<summary> Saves the JSON to a file </summary>
    function SaveToFile(const FileName: String): TJSONVerySimple; overload; virtual;
    function SaveToFile(const FileName: String; const EscapeProcedure: TJSONEscapeProcedure): TJSONVerySimple; overload; virtual;
    ///	<summary> Saves the JSON to a stream, the encoding is specified in the .Encoding property </summary>
    function SaveToStream(const Stream: TStream): TJSONVerySimple; virtual;
    ///	<summary> A list of all root nodes of the document </summary>
    property ChildNodes: TJSONNodeList read GetChildNodes;
    ///	<summary> Returns the first element node </summary>
    property DocumentElement: TJSONNode read FDocumentElement write SetDocumentElement;
    ///	<summary> Specifies the encoding of the JSON file, anything else then 'utf-8' is considered as ANSI </summary>
    property Encoding: TJSONString read GetEncoding write SetEncoding;
    ///	<summary> Set to True if all spaces and linebreaks should be included as a text node, same as doPreserve option </summary>
    property NodeAutoIndent: Boolean read GetNodeAutoIndent write SetNodeAutoIndent;
    ///	<summary> Set to True if all spaces and linebreaks should be included as a text node, same as doPreserve option </summary>
    property PreserveWhitespace: Boolean read GetPreserveWhitespace write SetPreserveWhitespace;
    ///	<summary> Set to True if all spaces and linebreaks should be included as a text node, same as doPreserve option </summary>
    property MultilineStrings: Boolean read GetMultilineStrings write SetMultilineStrings;
    ///	<summary> The JSON as a string representation </summary>
    property Text: TJSONString read GetText write SetText;
    ///	<summary> The JSON as a string representation, same as .Text </summary>
    property JSON: TJSONString read GetText write SetText;
  end;

function BooleanToNodeType(const ABoolean: Boolean): TJSONNodeType;

implementation

uses
//  WideStrUtils,
  StrUtils;

type
  TStreamWriterHelper = class helper for TStreamWriter
  public
    constructor Create(Stream: TStream; Encoding: TEncoding; WritePreamble: Boolean = True; BufferSize: Integer = 1024); overload;
    constructor Create(Filename: string; Append: Boolean; Encoding: TEncoding; WritePreamble: Boolean = True; BufferSize: Integer = 1024); overload;
  end;

  TStreamReaderHelper = class helper for TStreamReader
  public
    ///	<summary> Assures the read buffer holds at least Value characters </summary>
    function PrepareBuffer(Value: Integer): Boolean;
    ///
    procedure SkipWhitespace;
    ///	<summary> Returns fist char but does not removes it from the buffer </summary>
    function FirstChar: Char;
    ///	<summary> Proceed with the next character(s) (value optional, default 1) </summary>
    procedure IncCharPos(Value: Integer = 1); virtual;
    ///	<summary> Returns True if the first uppercased characters at the current position match Value </summary>
    function IsUppercaseText(const Value: TJSONString): Boolean; virtual;
    ///	<summary> Extract text until chars found in StopChars </summary>
    function ReadText(const StopChars: TJSONString; Options: TJSONExtractTextOptions; const MultilineString: Boolean): TJSONString; virtual;
  end;

const
{$IF CompilerVersion >= 24} // Delphi XE3+ can use Low(), High() and TEncoding.ANSI
  LowStr = Low(String); // Get string index base, may be 0 (NextGen compiler) or 1 (standard compiler)

{$ELSE} // For any previous Delphi version overwrite High() function and use 1 as string index base
  LowStr = 1;  // Use 1 as string index base

function High(const Value: String): Integer; inline;
begin
  Result := Length(Value);
end;

//Delphi XE3 added PosEx as an overloaded Pos function, so we need to wrap it in every other Delphi version
function Pos(const SubStr, S: String; Offset: Integer): Integer; overload; Inline;
begin
  Result := PosEx(SubStr, S, Offset);
end;
{$IFEND}

{$IF CompilerVersion < 23}  //Delphi XE2 added ANSI as Encoding, in every other Delphi version use TEncoding.Default
type
  TEncodingHelper = class helper for TEncoding
    class function GetANSI: TEncoding; static;
    class property ANSI: TEncoding read GetANSI;
  end;

class function TEncodingHelper.GetANSI: TEncoding;
begin
  Result := TEncoding.Default;
end;
{$IFEND}

resourcestring
  sRootTypeNotDefined    = 'Root type not defined!';
  sExpectedButFound      = 'Expected %s, but %s found at ''%s''.';
  sExpectedButNotFound   = 'Expected %s, but nothing found!';
  sExpectedNumberAsValue = 'Expected True/False/Null or Number as %svalue, but found ''%s'' !';

function IfThen(AValue: Boolean; const ATrue: TJSONString; AFalse: TJSONString = ''): TJSONString; overload; inline;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function BooleanToNodeType(const ABoolean: Boolean): TJSONNodeType;
begin
  if ABoolean then
    Result:=jtTrue
  else
    Result:=jtFalse;
end;

{ TVerySimpleJSON }

function TJSONVerySimple.AddChild(const Name: TJSONString; NodeType: TJSONNodeType): TJSONNode;
begin
  Result:=Nil; // satisfy compiler
  try
    Result:=Root.AddChild(Name, NodeType);
  except
    Result.Free;
    raise;
  end;
//  if (NodeType = jtObject) and not Assigned(FDocumentElement) then
//    FDocumentElement := Result;
  Result.Document := Self;
end;

function TJSONVerySimple.RemoveChild(const Node: TJSONNode): Integer;
var
  wasRoot: Boolean;
  Child: TJSONNode;
begin
  Result:=-1;
  if Node <> Nil then begin
    wasRoot:=(DocumentElement = Node);
    Node.Clear;
    Result:=Node.Index;
    Root.ChildNodes.Remove(Result);
    if wasRoot then begin
      if Root.ChildNodes.Count > 0 then begin
        for Child in Root.ChildNodes do begin
          if Child.NodeType = jtObject then begin
            FDocumentElement := Child;
            Exit;
          end;
        end;
        DocumentElement := Nil;
      end
      else
        FDocumentElement := Nil;
    end;
//    Node.Free;
  end;
end;

function TJSONVerySimple.MoveChild(const FromNode, ToNode: TJSONNode): TJSONNode;
begin
  Result:=ToNode;
  if (ToNode <> Nil) and (FromNode <> Nil) then begin
    ToNode.AddNodes(FromNode, True);
    FromNode.ParentNode.RemoveChild(FromNode);
  end;
end;

procedure TJSONVerySimple.Clear;
begin
  FDocumentElement := NIL;
  Root.Clear;
  FDocumentElement := Root;
end;

constructor TJSONVerySimple.Create(const RootType: TJSONRootType = jrtObject);
begin
  inherited Create;
  Root := TJSONNode.Create(jtObject);
  Root.Name:='';
  Root.FLevel := 0;
//  Root.FIndex := 0;
  Root.NodeType := jtNull;
  if RootType = jrtObject then
    Root.NodeType := jtObject
  else if RootType = jrtArray then
    Root.NodeType := jtArray;
  Root.ParentNode := Root;
  Root.Document := Self;
  Encoding := 'utf-8';
  NodeIndentStr := '  ';
  Options := [joNodeAutoIndent];
  LineBreak := sLineBreak;
  JSONEscapeProcedure := Nil;
  FDocumentElement := Root;
end;

function TJSONVerySimple.CreateNode(const Name: TJSONString; NodeType: TJSONNodeType): TJSONNode;
begin
  Result := TJSONNode.Create(NodeType);
  Result.Name := Name;
  Result.Document := Self;
end;

destructor TJSONVerySimple.Destroy;
begin
  Root.ParentNode := NIL;
  Root.Clear;
  Root.Free;
  inherited;
end;

function TJSONVerySimple.GetChildNodes: TJSONNodeList;
begin
  Result := Root.ChildNodes;
end;

function TJSONVerySimple.GetEncoding: TJSONString;
begin
  Result := FEncoding;
end;

function TJSONVerySimple.GetNodeAutoIndent: Boolean;
begin
  Result := joNodeAutoIndent in Options;
end;

function TJSONVerySimple.GetPreserveWhitespace: Boolean;
begin
  Result := joPreserveWhitespace in Options;
end;

function TJSONVerySimple.GetMultilineStrings: Boolean;
begin
  Result := joMultilineStrings in Options;
end;

function TJSONVerySimple.IsSame(const Value1, Value2: TJSONString): Boolean;
begin
  if joCaseInsensitive in Options then
    Result := (CompareText(Value1, Value2) = 0)
  else
    Result := (Value1 = Value2);
end;

function TJSONVerySimple.GetText: TJSONString;
var
  Stream: TStringStream;
begin
  if CompareText(Encoding, 'utf-8') = 0 then
    Stream := TStringStream.Create('', TEncoding.UTF8)
  else
    Stream := TStringStream.Create('', TEncoding.ANSI);
  try
    SaveToStream(Stream);
    Result := Stream.DataString;
  finally
    Stream.Free;
  end;
end;

procedure TJSONVerySimple.Compose(Writer: TStreamWriter);
var
  Child: TJSONNode;
begin
  FDivider:=' : ';
  if joCompact in Options then begin
    Writer.NewLine := '';
    LineBreak := '';
    FDivider:=':';
  end
  else
    Writer.NewLine := LineBreak;

  SkipIndent := False;
  if Root.NodeType = jtObject then
    Writer.Write('{')
  else if Root.NodeType = jtArray then
    Writer.Write('[')
  else
    raise TJSONParseException.Create(sRootTypeNotDefined);
  if not (joCompact in Options) then
    Writer.Write(LineBreak);

  for Child in Root.ChildNodes do begin
    Walk(Writer, IfThen(GetNodeAutoIndent, NodeIndentStr), Child);
    if Child <> Root.ChildNodes.Last then
      Writer.Write(',' + LineBreak);
  end;

  if not (joCompact in Options) then
    Writer.Write(LineBreak);
  if Root.NodeType = jtObject then
    Writer.Write('}')
  else if Root.NodeType = jtArray then
    Writer.Write(']');
end;

function TJSONVerySimple.LoadFromFile(const FileName: String; BufferSize: Integer = 4096): TJSONVerySimple;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
  try
    LoadFromStream(Stream, BufferSize);
  finally
    Stream.Free;
  end;
  Result := Self;
end;

function TJSONVerySimple.LoadFromStream(const Stream: TStream; BufferSize: Integer = 4096): TJSONVerySimple;
var
  Reader: TStreamReader;
begin
  if Encoding = '' then // none specified then use UTF8 with DetectBom
    Reader := TStreamReader.Create(Stream, TEncoding.UTF8, True, BufferSize)
  else if CompareText(Encoding, 'utf-8') = 0 then
    Reader := TStreamReader.Create(Stream, TEncoding.UTF8, False, BufferSize)
  else if CompareText(Encoding, 'windows-1250') = 0 then
    Reader := TStreamReader.Create(Stream, TEncoding.GetEncoding(1250), False, BufferSize)
  else
    Reader := TStreamReader.Create(Stream, TEncoding.ANSI, False, BufferSize);
  try
    Parse(Reader);
  finally
    Reader.Free;
  end;
  Result := Self;
end;

procedure TJSONVerySimple.Parse(Reader: TStreamReader);
var
  Parent: TJSONNode;
  FirstChar: TJSONString;
begin
  Clear;
  Parent := Root;

  while not Reader.EndOfStream do begin
    FirstChar := Reader.FirstChar;
    if FirstChar = '{' then begin // Parse object
      if (Parent = Root) and (Root.NodeType <> jtObject) then
        Root.NodeType:=jtObject;
      ParseObject(Reader, Parent);
    end
    else if FirstChar = '[' then begin // Parse array
      if (Parent = Root) and (Root.NodeType <> jtArray) then
        Root.NodeType:=jtArray;
      ParseArray(Reader, Parent);
    end
    else if FirstChar = ',' then begin // Next element
      Reader.IncCharPos;
    end
    else if FirstChar <> '' then begin // omit whitespace
      Reader.SkipWhitespace;
    end;
  end;

  FDocumentElement := Root;
end;

procedure TJSONVerySimple.ParseObject(Reader: TStreamReader; var Parent: TJSONNode);
var
  FirstChar: TJSONString;
  Opened: Boolean;
begin
  Opened:=True;
  Reader.IncCharPos;
  Reader.SkipWhitespace;
  while True do begin
    FirstChar := Reader.FirstChar;
    if FirstChar = '"' then begin // Parse pair
      ParsePair(Reader, Parent);
    end
    else if FirstChar = ',' then begin // Next element
      Reader.IncCharPos;
      Reader.SkipWhitespace;
    end
    else if FirstChar <> '' then begin // omit whitespace
      if FirstChar = '}' then begin // exit from object
        Opened:=False;
        Reader.IncCharPos;
        Reader.SkipWhitespace;
        Parent:=Parent.ParentNode;
        Break;
      end
      else if FirstChar <> '"' then
        raise TJSONParseException.CreateFmt(sExpectedButFound, ['pair', '''' + FirstChar + '''', Reader.ReadToEnd])
      else begin
        Reader.IncCharPos;
        Reader.SkipWhitespace;
      end;
    end
    else
      raise TJSONParseException.CreateFmt(sExpectedButNotFound, ['pair']);

    if Reader.EndOfStream then
      Break;
  end;
  FirstChar := Reader.FirstChar;
  if (FirstChar <> ',') and ((FirstChar <> '}') and (FirstChar <> ']')) and not Reader.EndOfStream then
    raise TJSONParseException.CreateFmt(sExpectedButFound, [''',''', '''' + FirstChar + '''', Reader.ReadToEnd]);
  if (FirstChar = #0) and Reader.EndOfStream and Opened then
    raise TJSONParseException.CreateFmt(sExpectedButFound, ['''}''', 'end of stream', Reader.ReadToEnd]);
end;

procedure TJSONVerySimple.ParsePair(Reader: TStreamReader; var Parent: TJSONNode);
var
  Node: TJSONNode;
  Quote: Char;
  Line: TJSONString;
  nodeType: TJSONNodeType;
begin
  Reader.IncCharPos;
//  Reader.SkipWhitespace;
  Line:=Reader.ReadText('"', [jetDeleteWithStopChar, jetStopString], joMultilineStrings in Options);
  Node := Parent.AddChild(Line, jtString);

  Line:=Reader.ReadText(':', [jetDeleteWithStopChar, jetStopString], False);
  Reader.SkipWhitespace;
  Quote := Reader.FirstChar;
  if Quote = '"' then begin // set value
    Reader.IncCharPos;
    Line:=Reader.ReadText(Quote, [jetDeleteWithStopChar, jetStopString], joMultilineStrings in Options);
    Node.Value:=Unescape(Line);
    Reader.SkipWhitespace;
  end
  else if Quote = '{' then begin // new object
    Node.NodeType:=jtObject;
    Parent:=Node;
    ParseObject(Reader, Parent);
  end
  else if Quote = '[' then begin // new array
    Node.NodeType:=jtArray;
    Parent:=Node;
    ParseArray(Reader, Parent);
  end
  else if Quote <> '' then begin // set number / string / true / false / null
    nodeType:=jtNumber;
    if not CharInSet(Quote, ['-', '0'..'9']) then begin
      nodeType:=jtString;
      if CharInSet(Quote, ['t', 'T']) then
        nodeType:=jtTrue
      else if CharInSet(Quote, ['f', 'F']) then
        nodeType:=jtFalse
      else if CharInSet(Quote, ['n', 'N']) then
        nodeType:=jtNull;
    end;
    if nodeType = jtString then
      raise TJSONParseException.CreateFmt(sExpectedNumberAsValue, ['pair ', Reader.ReadToEnd]);
    Node.NodeType:=nodeType;
    Reader.IncCharPos;
    Line:=Reader.ReadText(',]}'+TJSONSpaces, [jetDeleteToStopChar], False);
    Node.Value:=Unescape(Quote + Line);
    Reader.SkipWhitespace;
  end;
end;

procedure TJSONVerySimple.ParseValue(Reader: TStreamReader; var Parent: TJSONNode);
var
  Node: TJSONNode;
  Quote: Char;
  Line: TJSONString;
  nodeType: TJSONNodeType;
begin
  Quote := Reader.FirstChar;
  if Quote = '"' then begin // set string value
    Reader.IncCharPos;
    Node := Parent.AddChild('', jtString);
    Line:=Reader.ReadText(Quote, [jetDeleteWithStopChar, jetStopString], joMultilineStrings in Options);
    Node.Value:=Unescape(Line);
    Reader.SkipWhitespace;
  end
  else if Quote = '{' then begin // set object value
    Node := Parent.AddChild('', jtObject);
    Parent:=Node;
    ParseObject(Reader, Parent);
  end
  else if Quote = '[' then begin // set array value
    Node := Parent.AddChild('', jtArray);
    Parent:=Node;
    ParseArray(Reader, Parent);
  end
  else if Quote <> '' then begin // set number / string / true / false / null
    nodeType:=jtNumber;
    if not CharInSet(Quote, ['-', '0'..'9']) then begin
      nodeType:=jtString;
      if CharInSet(Quote, ['t', 'T']) then
        nodeType:=jtTrue
      else if CharInSet(Quote, ['f', 'F']) then
        nodeType:=jtFalse
      else if CharInSet(Quote, ['n', 'N']) then
        nodeType:=jtNull;
    end;
    if nodeType = jtString then
      raise TJSONParseException.CreateFmt(sExpectedNumberAsValue, ['', Reader.ReadToEnd]);
    Node := Parent.AddChild('', nodeType);
    Reader.IncCharPos;
    Line:=Reader.ReadText(',]}'+TJSONSpaces, [jetDeleteToStopChar], False);
    Node.Value:=Unescape(Quote + Line);
    Reader.SkipWhitespace;
  end;
end;

procedure TJSONVerySimple.ParseArray(Reader: TStreamReader; var Parent: TJSONNode);
var
  FirstChar: TJSONString;
  Node: TJSONNode;
  Opened: Boolean;
begin
  Opened:=True;
  Reader.IncCharPos;
  Reader.SkipWhitespace;
  while True do begin
    FirstChar := Reader.FirstChar;
    if FirstChar = '{' then begin // Parse object
      Node:=Parent.AddChild('', jtObject);
      Parent:=Node;
      ParseObject(Reader, Parent);
    end
    else if FirstChar = '[' then begin // Parse array
      Node:=Parent.AddChild('', jtArray);
      Parent:=Node;
      ParseArray(Reader, Parent);
    end
    else if FirstChar = ',' then begin // Next element
      Reader.IncCharPos;
      Reader.SkipWhitespace;
    end
    else if FirstChar <> '' then begin // set value
      if FirstChar = ']' then begin // exit from array
        Opened:=False;
        Reader.IncCharPos;
        Reader.SkipWhitespace;
        Parent:=Parent.ParentNode;
        Break;
      end;
      // here may be string, number, object, array or other types
      ParseValue(Reader, Parent);
    end
    else
      raise TJSONParseException.CreateFmt(sExpectedButNotFound, ['value']);

    if Reader.EndOfStream then
      Break;
  end;
  FirstChar := Reader.FirstChar;
  if (FirstChar <> ',') and ((FirstChar <> '}') and (FirstChar <> ']')) and not Reader.EndOfStream then
    raise TJSONParseException.CreateFmt(sExpectedButFound, [''',''', '''' + FirstChar + '''', Reader.ReadToEnd]);
  if (FirstChar = #0) and Reader.EndOfStream and Opened then
    raise TJSONParseException.CreateFmt(sExpectedButFound, [''']''', 'end of stream', Reader.ReadToEnd]);
end;

function TJSONVerySimple.SaveToFile(const FileName: String): TJSONVerySimple;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
  Result := Self;
end;

function TJSONVerySimple.SaveToFile(const FileName: String; const EscapeProcedure: TJSONEscapeProcedure): TJSONVerySimple;
begin
  JSONEscapeProcedure:=EscapeProcedure;
  try
    Result := SaveToFile(FileName);
  finally
    JSONEscapeProcedure:=Nil;
  end;
end;

function TJSONVerySimple.SaveToStream(const Stream: TStream): TJSONVerySimple;
var
  Writer: TStreamWriter;
begin
  if CompareText(Self.Encoding, 'utf-8') = 0 then
    Writer := TStreamWriter.Create(Stream, TEncoding.UTF8, (joWriteBOM in Options))
  else if CompareText(Encoding, 'windows-1250') = 0 then
    Writer := TStreamWriter.Create(Stream, TEncoding.GetEncoding(1250), (joWriteBOM in Options))
  else
    Writer := TStreamWriter.Create(Stream, TEncoding.ANSI, (joWriteBOM in Options));
  try
    Compose(Writer);
  finally
    Writer.Free;
  end;
  Result := Self;
end;

procedure TJSONVerySimple.SetDocumentElement(Value: TJSONNode);
begin
  FDocumentElement := Value;
  if Value.ParentNode = NIL then
    Root.ChildNodes.Add(Value);
end;

procedure TJSONVerySimple.SetEncoding(const Value: TJSONString);
begin
  FEncoding:=Value;
end;

procedure TJSONVerySimple.SetNodeAutoIndent(const Value: Boolean);
begin
  if Value then
    Options := Options + [joNodeAutoIndent]
  else
    Options := Options - [joNodeAutoIndent];
end;

procedure TJSONVerySimple.SetPreserveWhitespace(const Value: Boolean);
begin
  if Value then
    Options := Options + [joPreserveWhitespace]
  else
    Options := Options - [joPreserveWhitespace];
end;

procedure TJSONVerySimple.SetMultilineStrings(const Value: Boolean);
begin
  if Value then
    Options := Options + [joMultilineStrings]
  else
    Options := Options - [joMultilineStrings];
end;

procedure TJSONVerySimple.SetText(const Value: TJSONString);
var
  Stream: TStringStream;
begin
  Stream := TStringStream.Create('', TEncoding.UTF8);
  try
    Stream.WriteString(Value);
    Stream.Position := 0;
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TJSONVerySimple.Walk(Writer: TStreamWriter; const PrefixNode: TJSONString; Node: TJSONNode);
var
  Child: TJSONNode;
  Line: TJSONString;
  Indent: TJSONString;
begin
  if (Node = Root.ChildNodes.First) or (SkipIndent) then begin
    if joCompact in Options then
      Line := ''
    else
      Line := PrefixNode;
    SkipIndent := False;
  end
  else
    Line := PrefixNode;

  case Node.NodeType of
    jtObject: begin
      Line:=Line + IfThen((Node.ParentNode <> Nil) and (Node.ParentNode.NodeType <> jtArray), '"' + Escape(Node.Name) + '"' + FDivider) + '{';
      if not (joCompact in Options) then
        Line:=Line + LineBreak;
    end;
    jtArray: begin
      Line:=Line + IfThen((Node.ParentNode <> Nil) and (Node.ParentNode.NodeType <> jtArray), '"' + Escape(Node.Name) + '"' + FDivider) + '[';
      if not (joCompact in Options) then
        Line:=Line + LineBreak;
    end;
    jtString: begin
      Line := Line + IfThen((Node.ParentNode <> Nil) and (Node.ParentNode.NodeType <> jtArray), '"' + Escape(Node.Name) + '"' + FDivider) + '"' + Escape(Node.Value) + '"';
    end;
    jtNumber: begin
      Line := Line + IfThen((Node.ParentNode <> Nil) and (Node.ParentNode.NodeType <> jtArray), '"' + Escape(Node.Name) + '"' + FDivider) + Escape(Node.Value);
    end;
    jtTrue: begin
      Line := Line + IfThen((Node.ParentNode <> Nil) and (Node.ParentNode.NodeType <> jtArray), '"' + Escape(Node.Name) + '"' + FDivider) + 'true';
    end;
    jtFalse: begin
      Line := Line + IfThen((Node.ParentNode <> Nil) and (Node.ParentNode.NodeType <> jtArray), '"' + Escape(Node.Name) + '"' + FDivider) + 'false';
    end;
    jtNull: begin
      Line := Line + IfThen((Node.ParentNode <> Nil) and (Node.ParentNode.NodeType <> jtArray), '"' + Escape(Node.Name) + '"' + FDivider) + 'null';
    end;
  end;

  if Assigned(JSONEscapeProcedure) then
    JSONEscapeProcedure(Line);

//  Writer.Write(WideCharToString(PWideChar(Line)));
  Writer.Write(Line);

  // Set indent for child nodes
  if (joCompact in Options) or (joCompactWithBreakes in Options) then
    Indent := ''
  else
    Indent := PrefixNode;

  // Process child nodes
  for Child in Node.ChildNodes do begin
    Walk(Writer, Indent + IfThen(GetNodeAutoIndent, NodeIndentStr), Child);
    if Child <> Node.ChildNodes.Last then
      Writer.Write(',' + IfThen(not (joCompact in Options), LineBreak));
  end;

  case Node.NodeType of
    jtObject: begin
      if joCompact in Options then
        Line:='}'
      else
        Line:=LineBreak + Indent + '}';
      SkipIndent:=True;
    end;
    jtArray: begin
      if joCompact in Options then
        Line:=']'
      else
        Line:=LineBreak + Indent + ']';
      SkipIndent:=True;
    end;
  else
    Line:='';
  end;

  // If node has child nodes and last child node is not a text node then set indent for closing tag
  if (Node.HasChildNodes) and (not SkipIndent) then
    Indent := Line + ',' + LineBreak + PrefixNode
  else
    Indent := Line;

  if Indent <> '' then
    Writer.Write(Indent);
end;

class function TJSONVerySimple.Escape(const Value: TJSONString): TJSONString;
begin
  Result := Value;
//  Result := ReplaceStr(Value, 'u',  '\u');
  Result := ReplaceStr(Result, '\', '\\');
  Result := ReplaceStr(Result, #8,  '\\\\b');
  Result := ReplaceStr(Result, #12, '\\\\f');
  Result := ReplaceStr(Result, #10, '\\\\n');
  Result := ReplaceStr(Result, #13, '\\\\r');
  Result := ReplaceStr(Result, #9,  '\\\\t');
  Result := ReplaceStr(Result, '"', '\"');
  Result := ReplaceStr(Result, '/', '\/');
end;

class function TJSONVerySimple.Unescape(const Value: TJSONString): TJSONString;
begin
  Result := Value;
  Result := ReplaceStr(Result, '\\', '\');
  Result := ReplaceStr(Result, '\"', '"');
  Result := ReplaceStr(Result, '\/', '/');
  Result := ReplaceStr(Result, '\\b', #8);
  Result := ReplaceStr(Result, '\\f', #12);
  Result := ReplaceStr(Result, '\\n', #10);
  Result := ReplaceStr(Result, '\\r', #13);
  Result := ReplaceStr(Result, '\\t', #9);
//  Result := ReplaceStr(Result, '\\u', 'u');
end;

function TJSONVerySimple.ExtractText(var Line: TJSONString; const StopChars: TJSONString; Options: TJSONExtractTextOptions): TJSONString;
var
  CharPos, FoundPos: Integer;
  TestChar: Char;
begin
  FoundPos := 0;
  for TestChar in StopChars do begin
    CharPos := Pos(TestChar, Line);
    if (CharPos <> 0) and ((FoundPos = 0) or (CharPos < FoundPos)) then
      FoundPos := CharPos;
  end;

  if FoundPos <> 0 then begin
    Dec(FoundPos);
    Result := Copy(Line, 1, FoundPos);
    if jetDeleteWithStopChar in Options then
      Inc(FoundPos);
    Delete(Line, 1, FoundPos);
  end
  else begin
    Result := Line;
    Line := '';
  end;
end;

{ TJSONNode }

function TJSONNode.AddChild(const AName: TJSONString; ANodeType: TJSONNodeType): TJSONNode;
var
  Last: TJSONNode;
begin
  Last:=Nil;
  try
    if ChildNodes.Count > 0 then
      Last:=ChildNodes.Last;
  except
    Last:=Nil;
  end;
  Result:=ChildNodes.Add(AName, ANodeType);
  Result.FPrevSibling:=Nil;
  Result.FNextSibling:=Nil;
  if Last <> Nil then begin
    Result.FPrevSibling:=Last;
    Last.FNextSibling:=Result;
  end;
end;

function TJSONNode.RemoveChild(const Node: TJSONNode): Integer;
begin
  Result:=Node.Index;
  if Node.NextSibling <> Nil then
    Node.NextSibling.FPrevSibling:=Node.PreviousSibling
  else if Node.PreviousSibling <> Nil then // last node, so delete reference within previous node to this, which is about to be deleted
    Node.PreviousSibling.FNextSibling:=Nil;
  ChildNodes.Remove(Result);
end;

function TJSONNode.MoveChild(const FromNode, ToNode: TJSONNode): TJSONNode;
begin
  Result:=Nil;
  if (ToNode <> Nil) and (FromNode <> Nil) then begin
    ToNode.AddNodes(FromNode, True);
    FromNode.ParentNode.RemoveChild(FromNode);
    Result:=ToNode;
  end;
end;

procedure TJSONNode.AddNodes(const RootNode: TJSONNode; const AddRootNode: Boolean = False);
var
  Child, Node: TJSONNode;
begin
  Child:=Self;
  if AddRootNode then begin
    Child:=AddChild(RootNode.Name, RootNode.NodeType);
    Child.Value:=RootNode.Value;
  end;
  for Node in RootNode.ChildNodes do // add all root node child nodes to child node
    Child.AddNodes(Node, True);
end;

procedure TJSONNode.Clear;
begin
  Value := '';
  ChildNodes.Clear;
end;

constructor TJSONNode.Create(ANodeType: TJSONNodeType);
begin
  ChildNodes := TJSONNodeList.Create;
  ChildNodes.Parent := Self;
  NodeType := ANodeType;
  Name:='';
  Value:='';
  FLevel:=0;
  FIndex:=0;
end;

destructor TJSONNode.Destroy;
begin
  Clear;
  ChildNodes.Free;
  inherited;
end;

function TJSONNode.IsSame(const Value1, Value2: TJSONString): Boolean;
begin
  Result := ((Assigned(Document) and Document.IsSame(Value1, Value2)) or // use the documents text comparison
    ((not Assigned(Document)) and (CompareText(Value1, Value2) = 0))); // or if not Assigned then compare names case sensitive
end;

{
function RecursiveFindNode(ANode: IJSONNode; const SearchNodeName: TJSONString): IJSONNode;
var
  I: Integer;
begin
  if CompareText(ANode.NodeName, SearchNodeName) = 0 then
    Result := ANode
  else if not Assigned(ANode.ChildNodes) then
    Result := nil
  else begin
    for I := 0 to ANode.ChildNodes.Count - 1 do
    begin
      Result := RecursiveFindNode(ANode.ChildNodes[I], SearchNodeName);
      if Assigned(Result) then
        Exit;
    end;
  end;
end;
}

function TJSONNode.FindNodeRecursive(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []; const SearchOptions: TJSONNodeSearchTypes = []): TJSONNode;
var
  Node: TJSONNode;
begin
  Result:=Nil;
  for Node in ChildNodes do begin
    if ((NodeTypes = []) or (Node.NodeType in NodeTypes)) and IsSame(Node.Name, Name) then begin
      Result:=Node;
      Exit;
    end;
    if Node.HasChildNodes then begin
      Result:=Node.FindNodeRecursive(Name, NodeTypes);
      if Result <> Nil then
        Exit;
    end;
  end;
end;

function TJSONNode.FindNodeRecursive(const Name, Value: TJSONString; NodeTypes: TJSONNodeTypes = []; const SearchOptions: TJSONNodeSearchTypes = []): TJSONNode;
var
  Node: TJSONNode;
begin
  Result:=Nil;
  for Node in ChildNodes do begin
    if ((NodeTypes = []) or (Node.NodeType in NodeTypes)) and // if no type specified or node type in types
       ((Name = '') or ((Name <> '') and IsSame(Node.Name, Name))) and IsSame(Node.Value, Value) then begin
      Result:=Node;
      Exit;
    end;
    if Node.HasChildNodes then begin
      Result:=Node.FindNodeRecursive(Name, Value, NodeTypes);
      if Result <> Nil then
        Exit;
    end;
  end;
end;

{
function TJSONNode.FindNodeRecursive(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNodeList;
begin
  Result := ChildNodes.FindNodes(Name, NodeTypes);
end;
}

function TJSONNode.FindNode(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []; const SearchOptions: TJSONNodeSearchTypes = []): TJSONNode;
begin
  if ((NodeTypes = []) or (Self.NodeType in NodeTypes)) and IsSame(Self.Name, Name) then begin
    Result := Self;
    Exit;
  end;
  Result := ChildNodes.Find(Name, NodeTypes);
  if (Result = Nil) and (jsRecursive in SearchOptions) then
    Result:=FindNodeRecursive(Name, NodeTypes, SearchOptions);
end;

function TJSONNode.FindNode(const Name, Value: TJSONString; NodeTypes: TJSONNodeTypes = []; const SearchOptions: TJSONNodeSearchTypes = []): TJSONNode;
begin
  if ((NodeTypes = []) or (Self.NodeType in NodeTypes)) and IsSame(Self.Name, Name) and IsSame(Self.Value, Value) then begin
    Result := Self;
    Exit;
  end;
  Result := ChildNodes.Find(Name, Value, NodeTypes);
  if (Result = Nil) and (jsRecursive in SearchOptions) then
    Result:=FindNodeRecursive(Name, Value, NodeTypes, SearchOptions);
end;

function TJSONNode.FindNodes(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNodeList;
begin
  Result := ChildNodes.FindNodes(Name, NodeTypes);
end;

procedure TJSONNode.ScanNodes(Name: TJSONString; CallBack: TJSONNodeCallBack);
var
  Node: TJSONNode;
begin
  Name := lowercase(Name);
  for Node in ChildNodes do
    if (Name = '') or ((Name <> '') and (CompareText(Node.Name, Name) = 0)) then
      CallBack(Node);
end;

function TJSONNode.FirstChild: TJSONNode;
begin
  Result := ChildNodes.First;
end;

function TJSONNode.HasChild(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): Boolean;
begin
  Result := ChildNodes.HasNode(Name, NodeTypes);
end;

function TJSONNode.HasChildNodes: Boolean;
begin
  Result := (ChildNodes.Count > 0);
end;

function TJSONNode.InsertChild(const Name: TJSONString; Position: Integer; NodeType: TJSONNodeType): TJSONNode;
begin
  Result := ChildNodes.Insert(Name, Position, NodeType);
  if Assigned(Result) then
    Result.ParentNode := Self;
end;

function TJSONNode.LastChild: TJSONNode;
begin
  if ChildNodes.Count > 0 then
    Result := ChildNodes.Last
  else
    Result := NIL;
end;

function TJSONNode.PreviousSibling: TJSONNode;
begin
  Result:=FPrevSibling;
end;

function TJSONNode.NextSibling: TJSONNode;
begin
  Result:=FNextSibling;
end;

procedure TJSONNode.SetDocument(Value: TJSONVerySimple);
begin
  FDocument := Value;
  ChildNodes.Document := Value;
end;

function TJSONNode.GetName: TJSONString;
begin
  Result:=TJSONVerySimple.Unescape(FName);
end;

function TJSONNode.GetValue: TJSONString;
begin
  Result:=TJSONVerySimple.Unescape(FValue);
end;

procedure TJSONNode.SetName(Value: TJSONString);
begin
//  FName:=TJSONVerySimple.Escape(Value);
  FName:=Value;
end;

procedure TJSONNode.SetValue(Value: TJSONString);
begin
//  FValue:=TJSONVerySimple.Escape(Value);
  FValue:=Value;
end;

procedure TJSONNode._SetNodeType(const Value: TJSONNodeType);
begin
  FNodeType := Value;

  if (Value = jtObject) or (Value = jtArray) then
    NodeValue:=''
  else if Value = jtTrue then
    NodeValue:='true'
  else if Value = jtFalse then
    NodeValue:='false'
  else if Value = jtNull then
    NodeValue:='null';
end;

function TJSONNode.SetNodeType(const Value: TJSONNodeType): TJSONNode;
begin
  _SetNodeType(Value);
  Result := Self;
end;

function TJSONNode.SetText(const AValue: TJSONString): TJSONNode;
begin
  Value := AValue;
  Result := Self;
end;

{ TJSONNodeList }

function TJSONNodeList.Find(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNode;
var
  Node: TJSONNode;
begin
  Result := NIL;
  for Node in Self do
    if ((NodeTypes = []) or (Node.NodeType in NodeTypes)) and (IsSame(Node.Name, Name)) then begin
      Result := Node;
      Break;
    end;
end;

function TJSONNodeList.Add(Value: TJSONNode): Integer;
var
  Index: Integer;
begin
  Index:=-1;
  try
    if Count > 0 then
      Index:=Last.Index;
  except
    Index:=-1;
  end;
  Result := inherited Add(Value);
  Value.ParentNode := Parent;
  Value.FLevel := Parent.Level + 1;
  Value.FIndex := Index + 1;
end;

function TJSONNodeList.Add(NodeType: TJSONNodeType): TJSONNode;
begin
  Result := TJSONNode.Create(NodeType);
  try
    Add(Result);
  except
    Result.Free;
    raise;
  end;
  Result.Document := Document;
end;

function TJSONNodeList.Add(const Name: TJSONString; NodeType: TJSONNodeType): TJSONNode;
begin
  Result := Add(NodeType);
  Result.Name := Name;
end;

function TJSONNodeList.CountNames(const Name: TJSONString; var NodeList: TJSONNodeList): Integer;
begin
  NodeList:=FindNodes(Name, []);
  Result:=NodeList.Count;
end;

function TJSONNodeList.Find(const Name, Value: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNode;
var
  Node: TJSONNode;
begin
  Result := NIL;
  for Node in Self do
    if ((NodeTypes = []) or (Node.NodeType in NodeTypes)) and // if no type specified or node type in types
       IsSame(Node.Name, Name) and IsSame(Node.Value, Value) then begin
      Result := Node;
      Break;
    end;
end;

function TJSONNodeList.FindNode(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNode;
begin
  Result := Find(Name, NodeTypes);
end;

function TJSONNodeList.FindNodes(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): TJSONNodeList;
var
  Node: TJSONNode;
begin
  Result := TJSONNodeList.Create(False);
  Result.Document := Document;
  try
    for Node in Self do
      if ((NodeTypes = []) or (Node.NodeType in NodeTypes)) and IsSame(Node.Name, Name) then begin
        Result.Parent := Node.ParentNode;
        Result.Add(Node);
      end;
    Result.Parent := NIL;
  except
    Result.Free;
    raise;
  end;
end;

function TJSONNodeList.FirstChild: TJSONNode;
begin
  Result := First;
end;

function TJSONNodeList.Get(Index: Integer): TJSONNode;
begin
  Result := Items[Index];
end;

function TJSONNodeList.HasNode(const Name: TJSONString; NodeTypes: TJSONNodeTypes = []): Boolean;
begin
  Result := Assigned(Find(Name, NodeTypes));
end;

function TJSONNodeList.Insert(const Name: TJSONString; Position: Integer; NodeType: TJSONNodeType): TJSONNode;
var
  Node, NodeBefore: TJSONNode;
  Index: Integer;
begin
  try
    Node:=Get(Position);
  except
    Node:=Nil;
  end;
  Index:=0;
  if Node <> Nil then
    Index:=Node.Index;
  Result := TJSONNode.Create(NodeType);
  Result.Name := Name;
  Result.FLevel := Parent.Level + 1;
  Result.Document := Document;
  try
    Insert(Position, Result);
    Result.FIndex := Index;
    if Position > 0 then try
      NodeBefore:=Get(Position - 1);
      Result.FPrevSibling := NodeBefore;
      NodeBefore.FNextSibling := Result;
    except
      // discard this
    end;
    if Node <> Nil then begin
      Result.FNextSibling := Node;
      Node.FPrevSibling := Result;
    end;
    // reindex nodes
    while Node <> Nil do begin
      Node.FIndex:=Index + 1;
      Inc(Index);
      Node:=Node.NextSibling;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TJSONNodeList.Remove(Index: Integer);
var
  Node: TJSONNode;
begin
  if Index >= 0 then begin
    try
      Node:=Get(Index);
    except
      Node:=Nil;
    end;
    if Node <> Nil then
      Node:=Node.NextSibling;
    Delete(Index);
    // reindex nodes
    while Node <> Nil do begin
      Node.FIndex:=Index;
      Inc(Index);
      Node:=Node.NextSibling;
    end;
  end;
end;

function TJSONNodeList.IsSame(const Value1, Value2: TJSONString): Boolean;
begin
  Result := ((Assigned(Document) and Document.IsSame(Value1, Value2)) or // use the documents text comparison
            ((not Assigned(Document)) and (Value1 = Value2))); // or if not Assigned then compare names case sensitive
end;

function TJSONNodeList.PreviousSibling(Node: TJSONNode): TJSONNode;
begin
  Result:=Node.PreviousSibling;
end;

function TJSONNodeList.NextSibling(Node: TJSONNode): TJSONNode;
begin
  Result:=Node.NextSibling;
end;

{ TStreamWriterHelper }

constructor TStreamWriterHelper.Create(Stream: TStream; Encoding: TEncoding; WritePreamble: Boolean; BufferSize: Integer);
begin
  Create(Stream, Encoding, BufferSize);
  if not WritePreamble then begin
    Self.BaseStream.Position:=0;
    Self.BaseStream.Size:=0;
  end;
end;

constructor TStreamWriterHelper.Create(Filename: string; Append: Boolean; Encoding: TEncoding; WritePreamble: Boolean;
  BufferSize: Integer);
begin
  Create(Filename, Append, Encoding, BufferSize);
  if not WritePreamble then begin
    Self.BaseStream.Position:=0;
    Self.BaseStream.Size:=0;
  end;
end;

{ TStreamReaderHelper }

function TStreamReaderHelper.PrepareBuffer(Value: Integer): Boolean;
begin
  Result := False;

  if Self.FBufferedData = NIL then
    Exit;

  if (Self.FBufferedData.Length < Value) and not Self.FNoDataInStream then
    Self.FillBuffer(Self.FEncoding);

  Result := (Self.FBufferedData.Length >= Value);
end;

//procedure TJSONVerySimple.SkipWhitespace(Reader: TStreamReader; Line: TJSONString);
procedure TStreamReaderHelper.SkipWhitespace;
var
  SingleChar: Char;
begin
  while True do begin
    SingleChar:=Self.FirstChar;
    if (SingleChar <> #0) and (AnsiStrScan(TJSONSpaces, SingleChar) = Nil) then
      Break;

    Self.IncCharPos;
    if Self.EndOfStream then  // if no chars available then exit
      Break;
  end;
end;

function TStreamReaderHelper.FirstChar: Char;
begin
  if PrepareBuffer(1) then
    Result := Self.FBufferedData.Chars[0]
  else
    Result := #0;
end;

procedure TStreamReaderHelper.IncCharPos(Value: Integer);
begin
  if PrepareBuffer(Value) then
    Self.FBufferedData.Remove(0, Value);
end;

function TStreamReaderHelper.IsUppercaseText(const Value: TJSONString): Boolean;
var
  ValueLength: Integer;
  Text: TJSONString;
begin
  Result := False;
  ValueLength := Length(Value);

  if PrepareBuffer(ValueLength) then begin
    Text := UpperCase(Self.FBufferedData.ToString(0, ValueLength));
    if Text = UpperCase(Value) then begin
      Self.FBufferedData.Remove(0, ValueLength);
      Result := True;
    end;
    Text:='';
  end;
end;

function TStreamReaderHelper.ReadText(const StopChars: TJSONString; Options: TJSONExtractTextOptions; const MultilineString: Boolean): TJSONString;
var
  NewLineIndex: Integer;
  PostNewLineIndex: Integer;
  StopChar: Char;
  Found, StopCharFound, NewLineFound: Boolean;
  TempIndex: Integer;
  StopCharLength: Integer;
begin
  Result := '';
  if Self.FBufferedData = NIL then
    Exit;
  NewLineIndex := 0;
  NewLineFound := False;
  PostNewLineIndex := 0;
  StopCharLength := Length(StopChars);
  StopCharFound := False;

  while True do begin
    // if we're searching for a string then assure the buffer is wide enough
    if (jetStopString in Options) and (NewLineIndex + StopCharLength > Self.FBufferedData.Length) and not Self.FNoDataInStream then
      Self.FillBuffer(Self.FEncoding);

    if NewLineIndex >= Self.FBufferedData.Length then begin
      if Self.FNoDataInStream then begin
        PostNewLineIndex := NewLineIndex;
        Break;
      end
      else begin
        Self.FillBuffer(Self.FEncoding);
        if Self.FBufferedData.Length = 0 then
          Break;
        if NewLineIndex >= Self.FBufferedData.Length then
          Break;
      end;
    end;

    if jetStopString in Options then begin
      if NewLineIndex + StopCharLength - 1 < Self.FBufferedData.Length then begin
        Found := True;
        TempIndex := NewLineIndex;

        if not MultilineString and (StopCharLength = 1) and ((Self.FBufferedData[TempIndex] = #10) or (Self.FBufferedData[TempIndex] = #13)) and not NewLineFound then begin
          NewLineFound:=True;
          Break;
        end;

        for StopChar in StopChars do
          if Self.FBufferedData[TempIndex] <> StopChar then begin
            Found := False;
            Break;
          end
          else begin
            if (TempIndex > 0) and (Self.FBufferedData[TempIndex - 1] = '\') then begin
              if (TempIndex > 1) and (Self.FBufferedData[TempIndex - 2] = '\') then begin
                Found := True;
                Break;
              end
              else
                Found := False;
            end
            else
              Inc(TempIndex);
          end;

        if Found then begin
          StopCharFound := True;
          if jetDeleteWithStopChar in Options then
            PostNewLineIndex := NewLineIndex + StopCharLength
          else
            PostNewLineIndex := NewLineIndex;
          Break;
        end;
      end
      else
        Break;
    end
    else begin
      Found := False;
      for StopChar in StopChars do
        if Self.FBufferedData[NewLineIndex] = StopChar then begin
          if jetDeleteToStopChar in Options then
            PostNewLineIndex := NewLineIndex;
          if jetDeleteWithStopChar in Options then
            PostNewLineIndex := NewLineIndex + 1;
//          else
//            PostNewLineIndex := NewLineIndex;
          Found := True;
          Break;
        end;
      if Found then begin
        StopCharFound := True;
        Break;
      end;
    end;

    Inc(NewLineIndex);
  end;

  if not StopCharFound and NewLineFound then
    raise TJSONParseException.CreateFmt(sExpectedButFound, [StopChars, 'new line', Self.FBufferedData.ToString(0, NewLineIndex)]);
  if not StopCharFound and not NewLineFound then
    raise TJSONParseException.CreateFmt(sExpectedButFound, [StopChars, 'not', Self.FBufferedData.ToString]);

  if NewLineIndex > 0 then
    Result := Self.FBufferedData.ToString(0, NewLineIndex);
  Self.FBufferedData.Remove(0, PostNewLineIndex);
end;

end.
