unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.TabControl, FMX.Controls.Presentation, FMX.StdCtrls,
  System.Actions, FMX.ActnList, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.Edit, FMX.ListView, FMX.TextLayout;

type
  TfrmPrincipal = class(TForm)
    lyt_aba: TLayout;
    lyt_aba_pedido: TLayout;
    lyt_aba_cliente: TLayout;
    lyt_aba_notificacao: TLayout;
    lyt_aba_mais: TLayout;
    img_tab_pedido: TImage;
    img_tab_cliente: TImage;
    img_tab_notificacao: TImage;
    img_tab_mais: TImage;
    TabControl: TTabControl;
    c_notif: TCircle;
    TabPedido: TTabItem;
    TabCliente: TTabItem;
    TabNotificacao: TTabItem;
    TabMais: TTabItem;
    ActionList1: TActionList;
    ActPedido: TChangeTabAction;
    ActCliente: TChangeTabAction;
    ActNotificacao: TChangeTabAction;
    ActMais: TChangeTabAction;
    Line1: TLine;
    toolbar: TRectangle;
    Layout1: TLayout;
    Label1: TLabel;
    lv_pedido: TListView;
    Rectangle1: TRectangle;
    edt_busca_pedido: TEdit;
    StyleBook1: TStyleBook;
    Image1: TImage;
    Rectangle2: TRectangle;
    Label2: TLabel;
    Image2: TImage;
    Layout2: TLayout;
    Rectangle3: TRectangle;
    edt_busca_cliente: TEdit;
    lv_clientes: TListView;
    Rectangle4: TRectangle;
    Label3: TLabel;
    Rectangle5: TRectangle;
    Label4: TLabel;
    Layout3: TLayout;
    Layout4: TLayout;
    img_produtos: TImage;
    Label5: TLabel;
    img_sincronizar: TImage;
    Label6: TLabel;
    Layout5: TLayout;
    img_perfil: TImage;
    Label7: TLabel;
    img_indicar: TImage;
    Label8: TLabel;
    img_sair: TImage;
    Label9: TLabel;
    img_entregue: TImage;
    img_sinc: TImage;
    img_nao_sinc: TImage;
    img_busca_pedido: TImage;
    img_busca_cliente: TImage;
    lv_notificacao: TListView;
    img_menu_notif: TImage;
    procedure img_tab_pedidoClick(Sender: TObject);
    procedure SelecionaTab(img : TImage);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AddPedido(pedido, cliente, dt_pedido, ind_entregue, ind_sinc : string;
                        valor: double);
    procedure AddCliente(cod_cliente, nome, endereco, cidade, fone: string);
    procedure AddNotificacao(cod_notificacao, dt, titulo, texto, ind_lido, ind_destaque: string);
    procedure ListarPedido(busca: string; ind_clear: boolean; delay : integer);
    procedure ListarCliente(busca: string; ind_clear: boolean; delay : integer);
    procedure ListarNotificacao(delay: integer);
    procedure img_busca_pedidoClick(Sender: TObject);
    procedure lv_pedidoPainting(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure img_busca_clienteClick(Sender: TObject);
    procedure lv_clientesPainting(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure lv_notificacaoUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure img_produtosClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

uses UnitDM, UnitProduto;

function GetTextHeight(const D: TListItemText; const Width: single; const Text: string): Integer;
var
  Layout : TTextLayout;
begin
  //Create a TTextLayout to measure text dimensions
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      //Iniialize Layout parameters with those of the drawable
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign   := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap        := D.WordWrap;
      Layout.Trimming        := D.Trimming;
      Layout.MaxSize         := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text            := Text;
    finally
      Layout.EndUpdate;
    end;
    //Get layout height
    Result := Round(Layout.Height);
    //Add one em to  the height
    Layout.Text := 'm';
    Result      := Result + Round(Layout.Height);
  finally
    Layout.Free
  end;

end;

procedure TfrmPrincipal.AddPedido(pedido, cliente, dt_pedido, ind_entregue,
  ind_sinc: string; valor: double);
var
  item : TListViewItem;
  txt : TListItemText;
  img : TListItemImage;
begin
  try
    item := lv_pedido.Items.Add;

    with item do
    begin
      //Numero do pedido
      txt := TListItemText(Objects.FindDrawable('TxtPedido'));
      if ind_sinc = 'S' then
        txt.Text := 'Pedido #' + pedido
      else
        txt.Text := 'Or?amento #' + pedido;

      //Cliente
      txt := TListItemText(Objects.FindDrawable('TxtCliente'));
      txt.Text := cliente;

      //Data Pedido
      txt := TListItemText(Objects.FindDrawable('TxtData'));
      txt.Text := dt_pedido;


      //Valor do Pedido
      txt := TListItemText(Objects.FindDrawable('TxtValor'));
      txt.Text := 'R$ ' + FormatFloat('#,##0.00', valor);

      //Entregue
      img := TListItemImage(Objects.FindDrawable('ImgEntregue'));
      if ind_entregue = 'S' then
        img.Bitmap := img_entregue.Bitmap
      else
        img.Visible := false;

      //Sincronizado
      img := TListItemImage(Objects.FindDrawable('ImgSinc'));
      if ind_sinc = 'P' then
        img.Bitmap := img_sinc.Bitmap
      else
        img.Bitmap := img_nao_sinc.Bitmap

    end;
  except on ex: Exception do
    ShowMessage('Erro ao inserir pedido na lista:' + ex.Message);
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  TabControl.TabPosition := TTabPosition.None;
  TabControl.ActiveTab   := TabPedido;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  c_notif.Visible := false;

  SelecionaTab(img_tab_pedido);

  lv_pedido.Tag := 0;
  ListarPedido('', True, 0);

  lv_clientes.Tag := 0;
  ListarCliente('', True, 1500);

  ListarNotificacao(2500);
end;

procedure TfrmPrincipal.img_busca_clienteClick(Sender: TObject);
begin
  lv_clientes.Tag := 0;
  ListarCliente(edt_busca_cliente.Text, true, 0);
end;

procedure TfrmPrincipal.img_busca_pedidoClick(Sender: TObject);
begin
  lv_pedido.Tag := 0;
  ListarPedido(edt_busca_pedido.Text, true, 0);
end;

procedure TfrmPrincipal.img_produtosClick(Sender: TObject);
begin
  if not Assigned(FrmProdutos) then
    application.CreateForm(TFrmProdutos, FrmProdutos);

  FrmProdutos.Show;
end;

procedure TfrmPrincipal.img_tab_pedidoClick(Sender: TObject);
begin
  SelecionaTab(TImage(Sender));
end;

procedure TfrmPrincipal.ListarPedido(busca: string; ind_clear: boolean; delay : integer);
begin
    if lv_pedido.TagString = '1' then
      exit;

    lv_pedido.TagString := '1'; //Em processaomento

    TThread.CreateAnonymousThread(procedure
    begin
      sleep(delay);

      dm.qry_pedido.Active := false;
      dm.qry_pedido.SQL.Clear;
      dm.qry_pedido.SQL.Add('SELECT P.*, C.NOME');
      dm.qry_pedido.SQL.Add('FROM TAB_PEDIDO P');
      dm.qry_pedido.SQL.Add('JOIN TAB_CLIENTE C ON (C.COD_CLIENTE = P.COD_CLIENTE)');

      // Filtro...
      if busca <> '' then
      begin
          dm.qry_pedido.SQL.Add('WHERE (C.NOME LIKE ''%'' || :BUSCA || ''%'' ');
          dm.qry_pedido.SQL.Add('      OR P.PEDIDO = :PEDIDO ) ');
          dm.qry_pedido.ParamByName('BUSCA').Value  := busca;
          dm.qry_pedido.ParamByName('PEDIDO').Value := busca;
      end;

      dm.qry_pedido.SQL.Add('ORDER BY PEDIDO_LOCAL DESC');
      dm.qry_pedido.SQL.Add('LIMIT :PAGINA, :QTDE_REG');
      dm.qry_pedido.ParamByName('PAGINA').Value   := lv_pedido.Tag * 10;
      dm.qry_pedido.ParamByName('QTDE_REG').Value := 10;
      dm.qry_pedido.Active := true;

      // Limpar listagem...
      if ind_clear then
          lv_pedido.Items.Clear;

      lv_pedido.Tag := lv_pedido.Tag + 1;
      lv_pedido.BeginUpdate;

      while NOT dm.qry_pedido.Eof do
      begin
          TThread.Synchronize(nil, procedure
          begin
          AddPedido(dm.qry_pedido.FieldByName('PEDIDO').AsString,
                    dm.qry_pedido.FieldByName('NOME').AsString,
                    FormatDateTime('dd/mm/yyyy', dm.qry_pedido.FieldByName('DATA').AsDateTime),
                    dm.qry_pedido.FieldByName('IND_ENTREGUE').AsString,
                    dm.qry_pedido.FieldByName('IND_SINC').AsString,
                    dm.qry_pedido.FieldByName('VALOR_TOTAL').AsFloat);
          end);

          dm.qry_pedido.Next;
      end;

      lv_pedido.EndUpdate;
      lv_pedido.TagString := ''; //Em processaomento

    end).Start;
end;

procedure TFrmPrincipal.AddCliente(cod_cliente, nome, endereco, cidade, fone: string);
var
    item : TListViewItem;
    txt : TListItemText;
begin
    try
        item := lv_clientes.Items.Add;

        with item do
        begin
            // Nome...
            txt := TListItemText(Objects.FindDrawable('TxtNome'));
            txt.Text := nome;

            // Endereco...
            txt := TListItemText(Objects.FindDrawable('TxtEndereco'));
            txt.Text := endereco + ' - ' + cidade;

            // Fone...
            txt := TListItemText(Objects.FindDrawable('TxtFone'));
            txt.Text := fone;
        end;
    except on ex:exception do
        showmessage('Erro ao inserir cliente na lista: ' + ex.Message);
    end;
end;

procedure TFrmPrincipal.ListarCliente(busca: string; ind_clear: boolean; delay : integer);
begin
    if lv_clientes.TagString = '1' then
        exit;

    lv_clientes.TagString := '1'; // Em processamento...

    TThread.CreateAnonymousThread(procedure
    begin
        sleep(delay);

        dm.qry_cliente.Active := false;
        dm.qry_cliente.SQL.Clear;
        dm.qry_cliente.SQL.Add('SELECT C.* ');
        dm.qry_cliente.SQL.Add('FROM TAB_CLIENTE C');

        // Filtro...
        if busca <> '' then
        begin
            dm.qry_cliente.SQL.Add('WHERE C.NOME LIKE ''%'' || :BUSCA || ''%'' ');
            dm.qry_cliente.ParamByName('BUSCA').Value := busca;
        end;

        dm.qry_cliente.SQL.Add('ORDER BY NOME');
        dm.qry_cliente.SQL.Add('LIMIT :PAGINA, :QTD_REG');
        dm.qry_cliente.ParamByName('PAGINA').Value := lv_clientes.Tag * 15;
        dm.qry_cliente.ParamByName('QTD_REG').Value := 15;
        dm.qry_cliente.Active := true;

        // Limpar listagem...
        if ind_clear then
            lv_clientes.Items.Clear;

        lv_clientes.Tag := lv_clientes.Tag + 1;
        lv_clientes.BeginUpdate;

        while NOT dm.qry_cliente.Eof do
        begin
            TThread.Synchronize(nil, procedure
            begin
                AddCliente(dm.qry_cliente.FieldByName('COD_CLIENTE').AsString,
                           dm.qry_cliente.FieldByName('NOME').AsString,
                           dm.qry_cliente.FieldByName('ENDERECO').AsString,
                           dm.qry_cliente.FieldByName('CIDADE').AsString,
                           dm.qry_cliente.FieldByName('FONE').AsString);
            end);

            dm.qry_cliente.Next;
        end;

        lv_clientes.EndUpdate;
        lv_clientes.TagString := ''; // Processamento terminou...

    end).Start;
end;

procedure TFrmPrincipal.AddNotificacao(cod_notificacao, dt, titulo, texto, ind_lido, ind_destaque: string);
var
    item : TListViewItem;
    txt : TListItemText;
    img : TListItemImage;
begin
    try
        item           := lv_notificacao.Items.Add;
        item.TagString := ind_lido;

        with item do
        begin
            // Titulo...
            txt           := TListItemText(Objects.FindDrawable('TxtTitulo'));
            txt.Text      := titulo;
            txt.TagString := ind_destaque;

            // Texto...
            txt      := TListItemText(Objects.FindDrawable('TxtMensagem'));
            txt.Text := texto;

            // Data...
            txt      := TListItemText(Objects.FindDrawable('TxtData'));
            txt.Text := dt;

            // Imagem Menu...
            img           := TListItemImage(Objects.FindDrawable('ImgMenu'));
            img.Bitmap    := img_menu_notif.Bitmap;
            img.TagString  := cod_notificacao;
        end;
    except on ex:exception do
        showmessage('Erro ao inserir cliente na lista: ' + ex.Message);
    end;
end;

procedure TFrmPrincipal.ListarNotificacao(delay: integer);
begin
  TThread.CreateAnonymousThread(procedure
  var
    cont : integer;
  begin
    sleep(delay);
    cont := 0;

    dm.qry_notificacao.Active := false;
    dm.qry_notificacao.SQL.Clear;
    dm.qry_notificacao.SQL.Add('SELECT * ');
    dm.qry_notificacao.SQL.Add('FROM TAB_NOTIFICACAO');
    dm.qry_notificacao.SQL.Add('ORDER BY DATA DESC');
    dm.qry_notificacao.Active := true;

    lv_notificacao.Items.Clear;

    lv_notificacao.BeginUpdate;

    while NOT dm.qry_notificacao.Eof do
    begin
        TThread.Synchronize(nil, procedure
        begin
          AddNotificacao(dm.qry_notificacao.FieldByName('COD_NOTIFICACAO').AsString,
                         FormatDateTime('dd/mm/yy', dm.qry_notificacao.FieldByName('DATA').AsDateTime),
                         dm.qry_notificacao.FieldByName('TITULO').AsString,
                         dm.qry_notificacao.FieldByName('TEXTO').AsString,
                         dm.qry_notificacao.FieldByName('IND_LIDO').AsString,
                         dm.qry_notificacao.FieldByName('IND_DESTAQUE').AsString);
        end);

        if dm.qry_notificacao.FieldByName('IND_LIDO').AsString = 'N' then
          inc(cont);

        dm.qry_notificacao.Next;
    end;

    TThread.Synchronize(nil, procedure
    begin
      c_notif.Visible := cont > 0;
    end);

    lv_notificacao.EndUpdate;

  end).Start;
end;


procedure TfrmPrincipal.lv_clientesPainting(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  if lv_clientes.Items.Count > 0 then
  begin
    if lv_clientes.GetItemRect(lv_clientes.Items.Count - 3).Bottom <= lv_clientes.Height then
        ListarCliente(edt_busca_cliente.Text, false, 0);
  end;
end;

procedure TfrmPrincipal.lv_notificacaoUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
var
  txt : TListItemText;
begin
  // Titulo...
  txt           := TListItemText(AItem.Objects.FindDrawable('TxtTitulo'));
  txt.Font.Size := 13;

  //Destaque
  if txt.TagString = 'S' then
    txt.TextColor := $FFE46868;

  // Texto...
  txt      := TListItemText(AItem.Objects.FindDrawable('TxtMensagem'));
  txt.Font.Size := 13;

  //Ind N?o lido
  if AItem.TagString = 'N' then
  begin
    txt.Font.Style := [TFontStyle.fsBold];
  end;

  txt.Width  := lv_notificacao.Width - 12;
  txt.Height := GetTextHeight(txt, txt.Width, txt.Text) + 5;

  AItem.Height := Trunc(txt.PlaceOffset.Y + txt.Height);
end;

procedure TfrmPrincipal.lv_pedidoPainting(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  if lv_pedido.Items.Count > 0 then
  begin
    if lv_pedido.GetItemRect(lv_pedido.Items.Count - 3).Bottom <= lv_pedido.Height then
        ListarPedido(edt_busca_pedido.Text, false, 0);
  end;
end;

procedure TfrmPrincipal.SelecionaTab(img: TImage);
begin
  img_tab_pedido.Opacity      := 0.4;
  img_tab_cliente.Opacity     := 0.4;
  img_tab_notificacao.Opacity := 0.4;
  img_tab_mais.Opacity        := 0.4;

  img.Opacity := 1;

  case img.Tag of
    1: ActPedido.Execute;
    2: ActCliente.Execute;
    3: ActNotificacao.Execute;
    4: ActMais.Execute;
  end;
end;

end.
