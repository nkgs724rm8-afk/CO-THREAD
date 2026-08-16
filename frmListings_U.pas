unit frmListings_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage, dmCoThread_U,
  Vcl.StdCtrls, Vcl.DBCGrids, Data.db;

type
  TfrmListings = class(TForm)
    imgListingsBG: TImage;
    imgBackBtn: TImage;
    sbListings: TScrollBox;
    pnlRoundedCorners: TPanel;
    procedure imgBackBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
     procedure ClearScrollBox(sb: TScrollBox);
     procedure TileClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmListings: TfrmListings;

implementation
uses
frmProfile_U, frmEditItem_U;

{$R *.dfm}

procedure TfrmListings.TileClick(Sender: TObject);
var
  pnlClicked: TPanel;
begin
  if Sender is TPanel then
    pnlClicked := TPanel(Sender)
  else
    pnlClicked := TPanel((Sender as TControl).Parent);

  dmCoThread.iSelectedItemID := pnlClicked.Tag;

  frmEditItem.Show;
  frmListings.Hide;
end;


procedure TfrmListings.ClearScrollBox(sb: TScrollBox);
var
  i: Integer;
begin
  for i := sb.ControlCount - 1 downto 0 do
    sb.Controls[i].Free;
end;

procedure TfrmListings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
application.terminate;
end;

procedure TfrmListings.FormShow(Sender: TObject);
 var
  pnlTile: TPanel;
  imgThumb : TImage;
  sImagePath : String;
  lblName, lblPrice, lblStatus: TLabel;
  iTop: Integer;
  bSold : Boolean;
begin
  ClearScrollBox(sbListings);

   pnlRoundedCorners.height := 857;
pnlRoundedCorners.width := 1793;
pnlRoundedCorners.top := 136;
pnlRoundedCorners.left := 56;
SetWindowRgn(pnlRoundedCorners.Handle,CreateRoundRectRgn(0,0,pnlRoundedCorners.Width,pnlRoundedCorners.Height,30,30),True);

  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT * FROM Items WHERE Seller_ID = ' + IntToStr(dmCoThread.iCurrentUserID));
  dmCoThread.qrySQL.Open;

  iTop := 15;
  dmCoThread.qrySQL.First;
  while not dmCoThread.qrySQL.Eof do
  begin
    pnlTile := TPanel.Create(sbListings);
    pnlTile.Parent := sbListings;
    pnlTile.Left := 15;
    pnlTile.Top := iTop;
    pnlTile.Width := sbListings.Width - 55;
    pnlTile.BevelOuter := bvRaised;
    pnlTile.color := clWhite;
    pnlTile.Cursor := crHandPoint;
    pnlTile.Tag := dmCoThread.qrySQL.FieldByName('Item_ID').AsInteger;
    pnlTile.OnClick := TileClick;

     imgThumb := TImage.Create(pnlTile);
    imgThumb.Parent := pnlTile;
    imgThumb.Left := 15;
    imgThumb.Top := 15;
    imgThumb.Width := 100;
    imgThumb.Height := 100;
    imgThumb.Stretch := True;
    imgThumb.Proportional := True;
    imgThumb.Center := True;
    imgThumb.Cursor := crHandPoint;
    imgThumb.OnClick := TileClick;

    sImagePath := ExtractFilePath(Application.ExeName) + dmCoThread.qrySQL.FieldByName('ImagePath').AsString;
    if FileExists(sImagePath) then
      imgThumb.Picture.LoadFromFile(sImagePath);


    lblName := TLabel.Create(pnlTile);
    lblName.Parent := pnlTile;
    lblName.Left := 135;
    lblName.Top := 18;
    lblName.Font.Size := 16;
    lblName.font.style := [fsBold];
    lblName.font.color := RGB(30,30,30);
    lblName.Caption := dmCoThread.qrySQL.FieldByName('Title').AsString;
     lblName.Cursor := crHandPoint;
    lblName.OnClick := TileClick;

    lblPrice := TLabel.Create(pnlTile);
    lblPrice.Parent := pnlTile;
    lblPrice.Left := 135;
    lblPrice.Top := lblName.Top + lblName.Height + 8;
    lblPrice.Font.Size := 13;
    lblPrice.font.color := RGB(198,162,100);
    lblPrice.font.style := [fsBold];
    lblPrice.Caption := 'R' + dmCoThread.qrySQL.FieldByName('Price').AsString;
    lblPrice.Cursor := crHandPoint;
    lblPrice.OnClick := TileClick;

    bSold := dmCothread.qrysql.fieldbyname('Availability').AsBoolean;


    lblStatus := TLabel.Create(pnlTile);
    lblStatus.Parent := pnlTile;
    lblStatus.Left := 135;
    lblStatus.Top := lblPrice.top+ lblPrice.height +8;
    lblStatus.font.size := 10;
    lblStatus.font.style := [fsBold];
    if bSold then
    begin
    lblStatus.Caption := 'AVAILABLE';
     lblStatus.font.Color := RGB(60,150,60)
    end
    else
    begin
      lblStatus.Caption := 'SOLD';
      lblStatus.Font.color := clRed;
    end;


    lblStatus.Cursor := crHandPoint;
    lblStatus.OnClick := TileClick;

    pnlTile.Height := lblstatus.Top + lblstatus.Height +20;


    iTop := iTop + pnlTile.height +15;
    dmCoThread.qrySQL.Next;
  end;

  dmCoThread.qrySQL.Close;


end;


procedure TfrmListings.imgBackBtnClick(Sender: TObject);
begin
frmListings.Hide;
frmProfile.show;
end;

end.
