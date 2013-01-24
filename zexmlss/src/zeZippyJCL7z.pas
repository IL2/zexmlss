unit zeZippyJCL7z;

(* Simplistic interface to creating simplistic Zip files.
   Bridge object for avemey.com components.

   This one bridges www.7-zip.org DLL via wrapper by jcl.sf.net
      The wrapper by Henri Gourvest (progdigy.com) is not supported.

   (c) the Arioch, licensed under zLib license *)

interface uses zeZippy, SysUtils, Classes, JclCompression;

type TZxZipJcl7z = class (TZxZipGen)
     public

       /// Implementations should try to create the file for writing
       ///    and throw exception if they can not.
       constructor Create(const ZipFile: TFileName); override;
       procedure BeforeDestruction; override;

     protected
       FZ: TJclCompressArchive;

       procedure DoAbortAndDelete;  override;
       procedure DoSaveAndSeal;  override;
       function  DoNewStream(const RelativeName: TFileName): TStream; override;

       /// Returns True if the stream was flushed and clearance is given to free it.
       /// Otherwise the stream object is transmitted to the sealed list
       function  DoSealStream(const Data: TStream; const RelName: TFileName): boolean;  override;
   end;

implementation

{ TZxZipJcl7z }

procedure TZxZipJcl7z.BeforeDestruction;
begin
  inherited;  // before freeing - may throw exception on unsealed data
  FZ.Free;    // perhaps there can be second attempt ?
end;

constructor TZxZipJcl7z.Create(const ZipFile: TFileName);
begin
  inherited;
  FZ := TJclZipCompressArchive.Create(self.ZipFileName);
end;

procedure TZxZipJcl7z.DoAbortAndDelete;
var i: integer;
begin
  for i := FActiveStreams.Count - 1 downto 0 do begin
      FActiveStreams.Objects[i].Free; // can be nil - that is okay for .Free
      FActiveStreams.Delete(i);
  end;
//  FZ.Close;   - probably nothign is created on disk  before actual compression
//  DeleteFile(ZipFileName);
end;

function TZxZipJcl7z.DoNewStream(const RelativeName: TFileName): TStream;
begin
  Result := TMemoryStream.Create;
end;

procedure TZxZipJcl7z.DoSaveAndSeal;
begin
  FZ.Compress;
end;

function TZxZipJcl7z.DoSealStream(const Data: TStream;
  const RelName: TFileName): boolean;
begin
  Data.Position := 0;
  FZ.AddFile(RelName, Data, False {do not own});
  Result := false; // do not Free
end;

initialization
  RegisterZipGen(TZxZipJcl7z);
end.
