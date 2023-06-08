unit Model.Cliente;

interface

uses
  FireDAC.Comp.Client, Data.DB, System.SysUtils, Model.Connection;

type
  TCliente = class
    private
      FFONE: String;
      FEMAIL: String;
      FID_CLIENTE: Integer;
      FNOME: String;
    public
      constructor Create;
      destructor Destroy; override;

      function ListarCliente(prOrderBy: String; out prErro: String): TFDQuery;
      function Inserir(out prErro: String): Boolean;
      function Excluir(out prErro: String): Boolean;
      function Editar(out prErro: String): Boolean;

      property ID_CLIENTE : Integer read FID_CLIENTE  write FID_CLIENTE;
      property NOME       : String  read FNOME        write FNOME;
      property EMAIL      : String  read FEMAIL       write FEMAIL;
      property FONE       : String  read FFONE        write FFONE;
  end;

implementation

{ TCliente }

constructor TCliente.Create;
begin
  Model.Connection.Connect;
end;

destructor TCliente.Destroy;
begin
  Model.Connection.Disconect;
end;

function TCliente.ListarCliente(prOrderBy: String; out prErro: String): TFDQuery;
var
  wQuery: TFDQuery;
begin
  try
    wQuery := TFDQuery.Create(nil);
    wQuery.Connection := Model.Connection.FConnection;

    wQuery.Active := False;
    wQuery.SQL.Clear;
    wQuery.SQL.Add('SELECT * FROM TAB_CLIENTE WHERE 1 = 1');

    if ID_CLIENTE > 0 then
    begin
      wQuery.SQL.Add('AND ID_CLIENTE = :ID_CLIENTE');
      wQuery.ParamByName('ID_CLIENTE').Value := ID_CLIENTE;
    end;

    if prOrderBy = '' then
      wQuery.SQL.Add('ORDER BY NOME')
    else
      wQuery.SQL.Add('ORDER BY ' + prOrderBy);

    wQuery.Active := True;

    Result := wQuery;

  except on E: Exception do
    begin
      prErro := 'Erro ao consultar clientes: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TCliente.Editar(out prErro: String): Boolean;
var
    wQuery: TFDQuery;
begin
  if ID_CLIENTE <= 0 then
  begin
    Result := false;
    prErro := 'Informe o id. cliente';
    Exit;
  end;

  try
    wQuery := TFDQuery.Create(nil);
    wQuery.Connection := Model.Connection.FConnection;

    wQuery.Active := false;
    wQuery.sql.Clear;
    wQuery.SQL.Add('UPDATE TAB_CLIENTE SET NOME = :NOME, EMAIL = :EMAIL, FONE = :FONE');
    wQuery.SQL.Add('WHERE ID_CLIENTE = :ID_CLIENTE');
    wQuery.ParamByName('NOME').Value  := NOME;
    wQuery.ParamByName('EMAIL').Value := EMAIL;
    wQuery.ParamByName('FONE').Value  := FONE;
    wQuery.ParamByName('ID_CLIENTE').Value := ID_CLIENTE;
    wQuery.ExecSQL;

    wQuery.Destroy;
    prErro := '';
    Result := True;

  except on E:Exception do
    begin
      prErro := 'Erro ao alterar cliente: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TCliente.Excluir(out prErro: String): Boolean;
var
    wQuery: TFDQuery;
begin
  try
    wQuery := TFDQuery.Create(nil);
    wQuery.Connection := Model.Connection.FConnection;

    wQuery.Active := false;
    wQuery.sql.Clear;
    wQuery.SQL.Add('DELETE FROM TAB_CLIENTE WHERE ID_CLIENTE = :ID_CLIENTE');
    wQuery.ParamByName('ID_CLIENTE').Value := ID_CLIENTE;
    wQuery.ExecSQL;

    wQuery.Destroy;
    prErro := '';
    Result := True;

  except on E:exception do
    begin
      prErro := 'Erro ao excluir cliente: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TCliente.Inserir(out prErro: String): Boolean;
var
  wQuery: TFDQuery;
begin
  if NOME.IsEmpty then
  begin
    Result := False;
    prErro := 'Informe o nome do cliente';
    Exit;
  end;

  try
    wQuery := TFDQuery.Create(nil);
    wQuery.Connection := Model.Connection.FConnection;

    wQuery.Active := false;
    wQuery.SQL.Clear;
    wQuery.SQL.Add('INSERT INTO TAB_CLIENTE(NOME, EMAIL, FONE)');
    wQuery.SQL.Add('VALUES(:NOME, :EMAIL, :FONE)');

    wQuery.ParamByName('NOME').Value  := NOME;
    wQuery.ParamByName('EMAIL').Value := EMAIL;
    wQuery.ParamByName('FONE').Value  := FONE;

    wQuery.ExecSQL;

    // Busca ID inserido...
    wQuery.Params.Clear;
    wQuery.SQL.Clear;
    wQuery.SQL.Add('SELECT MAX(ID_CLIENTE) AS ID_CLIENTE FROM TAB_CLIENTE');
    wQuery.SQL.Add('WHERE EMAIL = :EMAIL');
    wQuery.ParamByName('EMAIL').Value := EMAIL;
    wQuery.Active := True;

    ID_CLIENTE := wQuery.FieldByName('ID_CLIENTE').AsInteger;

    wQuery.Destroy;
    prErro := '';
    Result := True;

  except on E:exception do
    begin
      prErro := 'Erro ao cadastrar cliente: ' + E.Message;
      Result := false;
    end;
  end;
end;

end.
