program Pedidos;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitInicial in 'UnitInicial.pas' {FrmInicial},
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  UnitPrincipal in 'UnitPrincipal.pas' {frmPrincipal},
  UnitDM in 'UnitDM.pas' {dm: TDataModule},
  UnitProduto in 'UnitProduto.pas' {FrmProdutos};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.CreateForm(Tdm, dm);
  Application.Run;
end.
