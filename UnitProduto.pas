unit UnitProduto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.ListView, FMX.Objects, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, Data.DB, System.Actions, FMX.ActnList, FMX.TabControl;

type
  TFrmProdutos = class(TForm)
    Layout2: TLayout;
    Rectangle3: TRectangle;
    edt_busca_produto: TEdit;
    img_busca_produto: TImage;
    lv_produtos: TListView;
    Rectangle2: TRectangle;
    Label2: TLabel;
    Image2: TImage;
    img_voltar: TImage;
    img_sem_foto: TImage;
    TabControl: TTabControl;
    TabConsulta: TTabItem;
    TabCadastro: TTabItem;
    ActionList1: TActionList;
    ActConsulta: TChangeTabAction;
    ActCad: TChangeTabAction;
    Rectangle1: TRectangle;
    lbl_titulo: TLabel;
    img_salvar: TImage;
    img_voltar_cad: TImage;
    Layout1: TLayout;
    img_foto: TImage;
    Label1: TLabel;
    Rectangle4: TRectangle;
    Label3: TLabel;
    Image1: TImage;
    lbl_descricao: TLabel;
    Rectangle5: TRectangle;
    Label4: TLabel;
    Image3: TImage;
    lbl_valor: TLabel;
    procedure img_voltarClick(Sender: TObject);
    procedure AddProduto(cod_produto, descricao: string; valor : double; foto : TStream);
    procedure ListarProduto(busca: string; ind_clear: boolean; delay : integer);
    procedure img_busca_produtoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lv_produtosPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lv_produtosUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lv_produtosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure img_voltar_cadClick(Sender: TObject);
    procedure img_salvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmProdutos: TFrmProdutos;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitDM;

procedure TFrmProdutos.AddProduto(cod_produto, descricao : string; valor : double; foto : TStream);
var
    item : TListViewItem;
    txt : TListItemText;
    img : TListItemImage;
    bmp : TBitmap;
begin
    try
        item := lv_produtos.Items.Add;
        item.TagString := cod_produto;

        with item do
        begin
            // Descricao...
            txt := TListItemText(Objects.FindDrawable('TxtDescricao'));
            txt.Text := descricao;

            // Valor...
            txt := TListItemText(Objects.FindDrawable('TxtValor'));
            txt.Text := 'R$ ' + FormatFloat('#,##0.00', valor);

            // Foto...
            img := TListItemImage(Objects.FindDrawable('ImgFoto'));
            if foto <> nil then
            begin
                bmp := TBitmap.Create;
                bmp.LoadFromStream(foto);
                img.OwnsBitmap := true;
                img.Bitmap := bmp;
            end
            else
                img.Bitmap := img_sem_foto.Bitmap;
        end;
    except on ex:exception do
        showmessage('Erro ao inserir produtos na lista: ' + ex.Message);
    end;
end;

procedure TFrmProdutos.ListarProduto(busca: string; ind_clear: boolean; delay : integer);
var
  foto : TStream;
begin
    if lv_produtos.TagString = '1' then
        exit;

    lv_produtos.TagString := '1'; // Em processamento...

    TThread.CreateAnonymousThread(procedure
    begin
        sleep(delay);

        dm.qry_produto.Active := false;
        dm.qry_produto.SQL.Clear;
        dm.qry_produto.SQL.Add('SELECT P.* ');
        dm.qry_produto.SQL.Add('FROM TAB_PRODUTO P');

        // Filtro...
        if busca <> '' then
        begin
            dm.qry_produto.SQL.Add('WHERE P.DESCRICAO LIKE ''%'' || :BUSCA || ''%'' ');
            dm.qry_produto.ParamByName('BUSCA').Value := busca;
        end;

        dm.qry_produto.SQL.Add('ORDER BY DESCRICAO');
        dm.qry_produto.SQL.Add('LIMIT :PAGINA, :QTD_REG');
        dm.qry_produto.ParamByName('PAGINA').Value := lv_produtos.Tag * 15;
        dm.qry_produto.ParamByName('QTD_REG').Value := 15;
        dm.qry_produto.Active := true;

        // Limpar listagem...
        if ind_clear then
            lv_produtos.Items.Clear;

        lv_produtos.Tag := lv_produtos.Tag + 1;
        lv_produtos.BeginUpdate;

        while NOT dm.qry_produto.Eof do
        begin
            TThread.Synchronize(nil, procedure
            begin
                if dm.qry_produto.FieldByName('FOTO').AsString <> '' then
                  foto := dm.qry_produto.CreateBlobStream(dm.qry_produto.FieldByName('FOTO'), TBlobStreamMode.bmRead)
                else
                  foto := nil;

                AddProduto(dm.qry_produto.FieldByName('COD_PRODUTO').AsString,
                           dm.qry_produto.FieldByName('DESCRICAO').AsString,
                           dm.qry_produto.FieldByName('VALOR').AsFloat,
                           foto);
            end);

            dm.qry_produto.Next;
        end;

        lv_produtos.EndUpdate;
        lv_produtos.TagString := ''; // Processamento terminou...

    end).Start;
end;


procedure TFrmProdutos.lv_produtosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  ActCad.Execute;
end;

procedure TFrmProdutos.lv_produtosPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  if lv_produtos.Items.Count > 0 then
  begin
    if lv_produtos.GetItemRect(lv_produtos.Items.Count - 5).Bottom <= lv_produtos.Height then
        ListarProduto(edt_busca_produto.Text, false, 0);
  end;
end;

procedure TFrmProdutos.lv_produtosUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
var
  txt : TListViewItems;
begin
  // Descricao...
  TListItemText(AItem.Objects.FindDrawable('TxtDescricao')).Width := lv_produtos.Width - 85;
end;

procedure TFrmProdutos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmProdutos := nil;
end;

procedure TFrmProdutos.FormShow(Sender: TObject);
begin
  TabControl.ActiveTab := TabConsulta;
  lv_produtos.Tag := 0;
  ListarProduto('', true, 0);
end;

procedure TFrmProdutos.img_busca_produtoClick(Sender: TObject);
begin
  lv_produtos.Tag := 0;
  ListarProduto(edt_busca_produto.Text, true, 0);
end;

procedure TFrmProdutos.img_salvarClick(Sender: TObject);
begin
   ActConsulta.Execute;
end;

procedure TFrmProdutos.img_voltarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmProdutos.img_voltar_cadClick(Sender: TObject);
begin
   ActConsulta.Execute;
end;

end.
