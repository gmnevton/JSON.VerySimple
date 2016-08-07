unit uStreamWriter;

interface

uses Classes, SysUtils;

type
  TStreamWriter = class(TTextWriter)
  private
    FStream: TStream;
    FEncoding: TEncoding;
    FNewLine: string;
    FAutoFlush: Boolean;
    FOwnsStream: Boolean;
    FBufferIndex: Integer;
    FBuffer: TBytes;
    procedure WriteBytes(Bytes: TBytes);
  public
    constructor Create(Stream: TStream); overload;
    constructor Create(Stream: TStream; Encoding: TEncoding; WritePreamble: Boolean = True; BufferSize: Integer = 1024); overload;
    constructor Create(Filename: string; Append: Boolean = False); overload;
    constructor Create(Filename: string; Append: Boolean; Encoding: TEncoding; WritePreamble: Boolean = True; BufferSize: Integer = 1024); overload;
    destructor Destroy; override;
    procedure Close; override;
    procedure Flush; override;
    procedure Write(Value: Boolean); override;
    procedure Write(Value: Char); override;
    procedure Write(const Value: TCharArray); override;
    procedure Write(Value: Double); override;
    procedure Write(Value: Integer); override;
    procedure Write(Value: Int64); override;
    procedure Write(Value: TObject); override;
    procedure Write(Value: Single); override;
    procedure Write(const Value: string); override;
    procedure Write(Value: Cardinal); override;
    procedure Write(Value: UInt64); override;
    procedure Write(const Format: string; Args: array of const); override;
    procedure Write(Value: TCharArray; Index, Count: Integer); override;
    procedure WriteLine; override;
    procedure WriteLine(Value: Boolean); override;
    procedure WriteLine(Value: Char); override;
    procedure WriteLine(const Value: TCharArray); override;
    procedure WriteLine(Value: Double); override;
    procedure WriteLine(Value: Integer); override;
    procedure WriteLine(Value: Int64); override;
    procedure WriteLine(Value: TObject); override;
    procedure WriteLine(Value: Single); override;
    procedure WriteLine(const Value: string); override;
    procedure WriteLine(Value: Cardinal); override;
    procedure WriteLine(Value: UInt64); override;
    procedure WriteLine(const Format: string; Args: array of const); override;
    procedure WriteLine(Value: TCharArray; Index, Count: Integer); override;
    property AutoFlush: Boolean read FAutoFlush write FAutoFlush;
    property NewLine: string read FNewLine write FNewLine;
    property Encoding: TEncoding read FEncoding;
    property BaseStream: TStream read FStream;
  end;

implementation

{ TStreamWriter }

procedure TStreamWriter.Close;
begin
  Flush;
  if FOwnsStream and (FStream <> nil) then
  begin
    FStream.Free;
    FStream := nil;
  end;
end;

constructor TStreamWriter.Create(Stream: TStream);
begin
  inherited Create;
  FOwnsStream := False;
  FStream := Stream;
  FEncoding := TEncoding.UTF8;
  SetLength(FBuffer, 1024);
  FBufferIndex := 0;
  FNewLine := sLineBreak;
  FAutoFlush := True;
end;

constructor TStreamWriter.Create(Stream: TStream; Encoding: TEncoding; WritePreamble: Boolean; BufferSize: Integer);
begin
  inherited Create;
  FOwnsStream := False;
  FStream := Stream;
  FEncoding := Encoding;
  SetLength(FBuffer, BufferSize);
  FBufferIndex := 0;
  FNewLine := sLineBreak;
  FAutoFlush := True;
  if WritePreamble then
    WriteBytes(FEncoding.GetPreamble);
end;

constructor TStreamWriter.Create(Filename: string; Append: Boolean);
begin
  if (not FileExists(Filename)) or (not Append) then
    FStream := TFileStream.Create(Filename, fmCreate)
  else
  begin
    FStream := TFileStream.Create(Filename, fmOpenWrite);
    FStream.Seek(0, soEnd);
  end;
  Create(FStream);
  FOwnsStream := True;
end;

constructor TStreamWriter.Create(Filename: string; Append: Boolean; Encoding: TEncoding; WritePreamble: Boolean; BufferSize: Integer);
begin
  if (not FileExists(Filename)) or (not Append) then
    FStream := TFileStream.Create(Filename, fmCreate)
  else
  begin
    FStream := TFileStream.Create(Filename, fmOpenWrite);
    FStream.Seek(0, soEnd);
  end;
  Create(FStream, Encoding, WritePreamble, BufferSize);
  FOwnsStream := True;
end;

destructor TStreamWriter.Destroy;
begin
  Close;
  SetLength(FBuffer, 0);
  inherited;
end;

procedure TStreamWriter.Flush;
begin
  if FBufferIndex = 0 then
    Exit;
  if FStream = nil then
    Exit;

  FStream.Write(FBuffer[0], FBufferIndex);
  FBufferIndex := 0;
end;

procedure TStreamWriter.Write(Value: Cardinal);
begin
  WriteBytes(FEncoding.GetBytes(UIntToStr(Value)));
end;

procedure TStreamWriter.Write(const Value: string);
begin
  WriteBytes(FEncoding.GetBytes(Value));
end;

procedure TStreamWriter.Write(Value: UInt64);
begin
  WriteBytes(FEncoding.GetBytes(UIntToStr(Value)));
end;

procedure TStreamWriter.Write(Value: TCharArray; Index, Count: Integer);
var
  Bytes: TBytes;
begin
  SetLength(Bytes, Count * 4);
  SetLength(Bytes, FEncoding.GetBytes(Value, Index, Count, Bytes, 0));
  WriteBytes(Bytes);
end;

procedure TStreamWriter.WriteBytes(Bytes: TBytes);
var
  ByteIndex: Integer;
  WriteLen: Integer;
begin
  ByteIndex := 0;

  while ByteIndex < Length(Bytes) do
  begin
    WriteLen := Length(Bytes) - ByteIndex;
    if WriteLen > Length(FBuffer) - FBufferIndex then
      WriteLen := Length(FBuffer) - FBufferIndex;

    Move(Bytes[ByteIndex], FBuffer[FBufferIndex], WriteLen);

    Inc(FBufferIndex, WriteLen);
    Inc(ByteIndex, WriteLen);

    if FBufferIndex >= Length(FBuffer) then
      Flush;
  end;

  if FAutoFlush then
    Flush;
end;

procedure TStreamWriter.Write(const Format: string; Args: array of const);
begin
  WriteBytes(FEncoding.GetBytes(SysUtils.Format(Format, Args)));
end;

procedure TStreamWriter.Write(Value: Single);
begin
  WriteBytes(FEncoding.GetBytes(FloatToStr(Value)));
end;

procedure TStreamWriter.Write(const Value: TCharArray);
begin
  WriteBytes(FEncoding.GetBytes(Value));
end;

procedure TStreamWriter.Write(Value: Double);
begin
  WriteBytes(FEncoding.GetBytes(FloatToStr(Value)));
end;

procedure TStreamWriter.Write(Value: Integer);
begin
  WriteBytes(FEncoding.GetBytes(IntToStr(Value)));
end;

procedure TStreamWriter.Write(Value: Char);
begin
  WriteBytes(FEncoding.GetBytes(Value));
end;

procedure TStreamWriter.Write(Value: TObject);
begin
  WriteBytes(FEncoding.GetBytes(Value.ToString));
end;

procedure TStreamWriter.Write(Value: Int64);
begin
  WriteBytes(FEncoding.GetBytes(IntToStr(Value)));
end;

procedure TStreamWriter.Write(Value: Boolean);
begin
  WriteBytes(FEncoding.GetBytes(BoolToStr(Value, True)));
end;

procedure TStreamWriter.WriteLine(const Value: TCharArray);
begin
  WriteBytes(FEncoding.GetBytes(Value));
  WriteBytes(FEncoding.GetBytes(FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: Double);
begin
  WriteBytes(FEncoding.GetBytes(FloatToStr(Value) + FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: Integer);
begin
  WriteBytes(FEncoding.GetBytes(IntToStr(Value) + FNewLine));
end;

procedure TStreamWriter.WriteLine;
begin
  WriteBytes(FEncoding.GetBytes(FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: Boolean);
begin
  WriteBytes(FEncoding.GetBytes(BoolToStr(Value, True) + FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: Char);
begin
  WriteBytes(FEncoding.GetBytes(Value));
  WriteBytes(FEncoding.GetBytes(FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: Int64);
begin
  WriteBytes(FEncoding.GetBytes(IntToStr(Value) + FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: UInt64);
begin
  WriteBytes(FEncoding.GetBytes(UIntToStr(Value) + FNewLine));
end;

procedure TStreamWriter.WriteLine(const Format: string; Args: array of const);
begin
  WriteBytes(FEncoding.GetBytes(SysUtils.Format(Format, Args) + FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: TCharArray; Index, Count: Integer);
var
  Bytes: TBytes;
begin
  SetLength(Bytes, Count * 4);
  SetLength(Bytes, FEncoding.GetBytes(Value, Index, Count, Bytes, 0));
  WriteBytes(Bytes);
  WriteBytes(FEncoding.GetBytes(FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: Cardinal);
begin
  WriteBytes(FEncoding.GetBytes(UIntToStr(Value) + FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: TObject);
begin
  WriteBytes(FEncoding.GetBytes(Value.ToString + FNewLine));
end;

procedure TStreamWriter.WriteLine(Value: Single);
begin
  WriteBytes(FEncoding.GetBytes(FloatToStr(Value) + FNewLine));
end;

procedure TStreamWriter.WriteLine(const Value: string);
begin
  WriteBytes(FEncoding.GetBytes(Value + FNewLine));
end;

end.
