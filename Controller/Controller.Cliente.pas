unit Controller.Cliente;

interface

uses
  Horse, System.JSON, System.SysUtils, Model.Cliente;

procedure Registry;

implementation

uses
  FireDAC.Comp.Client, Data.DB, DataSet.Serialize;

procedure ListarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  wCli: TCliente;
  wQuery: TFDQuery;
  wErro: String;
  wArrayClientes: TJSONArray;
begin
  try
    wCli := TCliente.Create;
  except
    Res.Send('Erro ao conectar com o banco de dados!').Status(500);
  end;

  try
    wQuery := TFDQuery.Create(nil);
    wQuery := wCli.ListarCliente('', wErro);

    wArrayClientes := wQuery.ToJSONArray();

    Res.Send<TJSONArray>(wArrayClientes);
  finally
    wQuery.Destroy;
    wCli.Destroy;
  end;
end;

procedure CadastrarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  wCli: TCliente;
  wObjCliente: TJSONObject;
  wErro: String;
  wBody: TJSONValue;
begin
  try
    wCli := TCliente.Create;
  except
    Res.Send('Erro ao conectar com o banco de dados!').Status(500);
    Exit;
  end;

  try
    try
      wBody := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body), 0) as TJSONValue;

      wCli.NOME   := wBody.GetValue<String>('nome', '');
      wCli.EMAIL  := wBody.GetValue<String>('email', '');
      wCli.FONE   := wBody.GetValue<String>('fone', '');
      wCli.Inserir(wErro);

      if wErro <> '' then
        raise Exception.Create(wErro);

    except on E: Exception do
      Res.Send(E.Message).Status(400);
    end;

    wObjCliente := TJSONObject.Create;
    wObjCliente.AddPair('id_cliente', wCli.ID_CLIENTE.ToString);

    Res.Send<TJSONObject>(wObjCliente).Status(201);
  finally
    wCli.Destroy;
  end;

end;

procedure DeletarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  wCli: TCliente;
  wObjCliente: TJSONObject;
  wErro: String;
begin
  try
    wCli := TCliente.Create;
  except
    Res.Send('Erro ao conectar com o banco de dados!').Status(500);
    Exit;
  end;

  try
    try
      wCli.ID_CLIENTE := Req.Params['id'].ToInteger;

      if not(wCli.Excluir(wErro)) then
        raise Exception.Create(wErro);

    except on E: Exception do
      begin
        Res.Send(E.Message).Status(400);
        Exit;
      end;
    end;

    wObjCliente := TJSONObject.Create;
    wObjCliente.AddPair('id_cliente', wCli.ID_CLIENTE.ToString);

    Res.Send<TJSONObject>(wObjCliente);
    
  finally
    wCli.Destroy;
  end;
end;

procedure ListarClientesID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  wCli: TCliente;
  wObjClientes: TJSONObject;
  wQuery: TFDQuery;
  wErro: String;
begin
  try
    wCli := TCliente.Create;
    wCli.ID_CLIENTE := Req.Params['id'].ToInteger;
  except
    Res.Send('Erro ao conectar com o banco').Status(500);
    Exit;
  end;

  try
    wQuery := TFDQuery.Create(nil);
    wQuery := wCli.ListarCliente('', wErro);

    if not(wQuery.IsEmpty) then
    begin
      wObjClientes := wQuery.ToJSONObject;
      Res.Send<TJSONObject>(wObjClientes);
    end
    else
      Res.Send('Cliente não encontrado!').Status(404);
  finally
    wQuery.Destroy;
    wCli.Destroy;
  end;

end;

procedure EditarCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  wCli : TCliente;
  wObjCliente: TJSONObject;
  wErro : string;
  wBody : TJsonValue;
begin
  try
    wCli := TCliente.Create;
  except
    Res.Send('Erro ao conectar com o banco de dados!').Status(500);
    Exit;
  end;

  try
    try
      wBody := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body), 0) as TJSONValue;

      wCli.ID_CLIENTE := wBody.GetValue<Integer>('id_cliente', 0);
      wCli.NOME := wBody.GetValue<String>('nome', '');
      wCli.EMAIL := wBody.GetValue<String>('email', '');
      wCli.FONE := wBody.GetValue<String>('fone', '');
      wCli.Editar(wErro);

      wBody.Free;

      if wErro <> '' then
        raise Exception.Create(wErro);

    except on ex:exception do
      begin
          Res.Send(ex.Message).Status(400);
          Exit;
      end;
    end;


    wObjCliente := TJSONObject.Create;
    wObjCliente.AddPair('id_cliente', wCli.ID_CLIENTE.ToString);

    Res.Send<TJSONObject>(wObjCliente).Status(200);
  finally
    wCli.Destroy;
  end;
end;

procedure Registry;
begin
  THorse.Get('/cliente', ListarClientes);
  THorse.Get('/cliente/:id', ListarClientesID);
  THorse.Post('/cliente', CadastrarClientes);
  THorse.Put('/cliente', EditarCliente);
  THorse.Delete('/cliente/:id', DeletarClientes);
end;

end.
