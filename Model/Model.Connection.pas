unit Model.Connection;

interface

uses
  FireDAC.DApt, FireDAC.Stan.Option, FireDAC.Stan.Intf, FireDAC.UI.Intf,
  FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,

  FireDAC.Phys.FB, FireDAC.Phys.FBDef, System.Classes,

  System.IniFiles, System.SysUtils;

var
    FConnection : TFDConnection;

function SetupConnection(FConn: TFDConnection): String;
function Connect: TFDConnection;
procedure Disconect;

implementation

function SetupConnection(FConn: TFDConnection): String;
var
  wArqIni: String;
  wIni: TIniFile;
begin
  try
    try
      wArqIni := GetCurrentDir + '\ServerHorse.ini';

      if not FileExists(wArqIni) then
      begin
        Result := 'Arquivo INI não encontrado: ' + wArqIni;
        Exit;
      end;

      wIni := TIniFile.Create(wArqIni);

      FConn.Params.Values['DriverID'] := wIni.ReadString('Banco de Dados', 'DriverID', '');
      FConn.Params.Values['Database'] := wIni.ReadString('Banco de Dados', 'Database', '');
      FConn.Params.Values['user_name'] := wIni.ReadString('Banco de Dados', 'user_name', '');
      FConn.Params.Values['Password'] := wIni.ReadString('Banco de Dados', 'Password', '');
      FConn.Params.Add('Port=' + wIni.ReadString('Banco de Dados', 'Port', '3050'));
      FConn.Params.Add('Server=' + wIni.ReadString('Banco de Dados', 'Server', 'localhost'));

      Result := 'OK';
    except on E: Exception do
      Result := 'Erro ao configurar banco: ' + E.Message;
    end;
  finally
    if Assigned(wIni) then
      wIni.DisposeOf;
  end;
end;

function Connect: TFDConnection;
begin
  FConnection := TFDConnection.Create(nil);
  SetupConnection(FConnection);
  FConnection.Connected := True;

  Result := FConnection;
end;

procedure Disconect;
begin
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;

    FConnection.Destroy;
  end;
end;

end.
