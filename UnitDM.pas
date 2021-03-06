unit UnitDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, System.IOUtils, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  Tdm = class(TDataModule)
    conn: TFDConnection;
    qry_geral: TFDQuery;
    qry_pedido: TFDQuery;
    qry_cliente: TFDQuery;
    qry_notificacao: TFDQuery;
    qry_produto: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  with conn do
  begin
    Params.Values['DriverID'] := 'SQLite';

    {$IFDEF IOS}
    Params.Values['Database'] := tpath.Combine(TPath.GetDocumentsPath, 'pedidos.db');
    {$ENDIF}

    {$IFDEF ANDROID}
    Params.Values['Database'] := tpath.Combine(TPath.GetDocumentsPath, 'pedidos.db');
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\DB\pedidos.db';
    {$ENDIF}

    try
      Connected := true;
    except on e:exception do
      raise Exception.Create('Erro de conex?o com o banco de dados: ' + e.Message);
    end;
  end;
end;

end.
