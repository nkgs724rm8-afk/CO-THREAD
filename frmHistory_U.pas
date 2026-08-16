unit frmHistory_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage, dmCoThread_U,
  Vcl.StdCtrls, Vcl.DBCGrids, Data.db;

type
  TfrmHistory = class(TForm)
    imgHistoryBG: TImage;
    imgBackBtn: TImage;
    sbHistory: TScrollBox;
    pnlRoundedCorners: TPanel;
    procedure imgBackBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
      procedure ClearScrollBox(sb: TScrollBox);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHistory: TfrmHistory;

implementation
uses
frmProfile_U;

{$R *.dfm}

 procedure TfrmHistory.ClearScrollBox(sb: TScrollBox);
var
  i: Integer;
begin
  for i := sb.ControlCount - 1 downto 0 do
    sb.Controls[i].Free;
end;

procedure TfrmHistory.FormClose(Sender: TObject; var Action: TCloseAction);
begin
application.terminate;
end;

procedure TfrmHistory.FormShow(Sender: TObject);
var
 pnlTile: TPanel;
  lblName, lblPrice, lblDate: TLabel;
  iTop: Integer;
begin
pnlRoundedCorners.height := 857;
pnlRoundedCorners.width := 1793;
pnlRoundedCorners.top := 136;
pnlRoundedCorners.left := 56;
SetWindowRgn(pnlRoundedCorners.Handle,CreateRoundRectRgn(0,0,pnlRoundedCorners.Width,pnlRoundedCorners.Height,30,30),True);

  ClearScrollBox(sbHistory);

  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT Purchases.*, Items.Title, Items.Price FROM Purchases ' +
  'INNER JOIN Items ON Purchases.Item_ID = Items.Item_ID ' +
  'WHERE Purchases.Buyer_ID = ' + IntToStr(dmCoThread.iCurrentUserID));

  dmCoThread.qrySQL.Open;

  iTop := 10;
  dmCoThread.qrySQL.First;
  while not dmCoThread.qrySQL.Eof do
  begin
    pnlTile := TPanel.Create(sbHistory);
    pnlTile.Parent := sbHistory;
    pnlTile.Left := 10;
    pnlTile.Top := iTop;
    pnlTile.Width := sbHistory.Width - 40;
    pnlTile.BevelOuter := bvLowered;

    lblName := TLabel.Create(pnlTile);
    lblName.Parent := pnlTile;
    lblName.Left := 15;
    lblName.Top := 12;
    lblName.font.size := 12;
    lblName.Font.style := [fsBold];
    lblName.Caption := dmCoThread.qrySQL.FieldByName('Title').AsString;

    lblPrice := TLabel.Create(pnlTile);
    lblPrice.Parent := pnlTile;
    lblPrice.Caption := 'R' + dmCoThread.qrySQL.FieldByName('Amount').AsString;

    lblPrice.Left := 15;
    lblPrice.Top := lblName.Top + lblName.Height + 10;
    lblPrice.Font.Size := 11;
    lblPrice.AutoSize := False;
    lblPrice.WordWrap := True;
    lblPrice.Width := pnlTile.Width - 30;

    // Force the label to size itself to its wrapped text properly
    lblPrice.AutoSize := True;
    lblPrice.WordWrap := True;
    lblPrice.Width := pnlTile.Width - 30;

    lblDate := TLabel.Create(pnlTile);
    lblDate.Parent := pnlTile;
    lblDate.Left := 15;
    lblDate.Top := lblPrice.Top + lblPrice.Height + 12;
    lblDate.Font.Size := 9;
    lblDate.Font.Color := clGray;
    lblDate.Caption := DateToStr(dmCoThread.qrySQL.FieldByName('PurchaseDate').AsDateTime);

     pnlTile.Height := lblDate.Top + lblDate.Height +20;
    iTop := iTop + pnlTile.Height +15;
    dmCoThread.qrySQL.Next;

    { pnlTile := TPanel.Create(sbReviews);
    pnlTile.Parent := sbReviews;
    pnlTile.Left := 10;
    pnlTile.Top := iTop;
    pnlTile.Width := sbReviews.Width - 40;
    pnlTile.BevelOuter := bvLowered;

    lblRating := TLabel.Create(pnlTile);
    lblRating.Parent := pnlTile;
    lblName.Left := 15;
    lblName.Top := 12;
    lblName.font.size := 12;
    lblName.Font.style := [fsBold];
    lblName.Caption := 'Rating: ' + dmCoThread.qrySQL.FieldByName('Rating').AsString + ' / 5';

    lblComment := TLabel.Create(pnlTile);
    lblComment.Parent := pnlTile;
    lblComment.Left := 15;
    lblComment.Top := lblRating.Top + lblRating.Height + 10;
    lblComment.Font.Size := 11;
    lblComment.AutoSize := False;
    lblComment.WordWrap := True;
    lblComment.Width := pnlTile.Width - 30;
    lblComment.Caption := dmCoThread.qrySQL.FieldByName('Comment').AsString;
    lblComment.Height := lblComment.Canvas.TextHeight('Wg') *
      ((lblComment.Canvas.TextWidth(lblComment.Caption) div lblComment.Width) + 1) + 4;

    // Force the label to size itself to its wrapped text properly
    lblComment.AutoSize := True;
    lblComment.WordWrap := True;
    lblComment.Width := pnlTile.Width - 30;

    lblDate := TLabel.Create(pnlTile);
    lblDate.Parent := pnlTile;
    lblDate.Left := 15;
    lblDate.Top := lblComment.Top + lblComment.Height + 12;
    lblDate.Font.Size := 9;
    lblDate.Font.Color := clGray;
    lblDate.Caption := DateToStr(dmCoThread.qrySQL.FieldByName('ReviewDate').AsDateTime);

    pnlTile.Height := lblDate.Top + lblDate.Height +20;
    iTop := iTop + pnlTile.Height +15;


    dmCoThread.qrySQL.Next;}
  end;

  dmCoThread.qrySQL.Close;
end;


procedure TfrmHistory.imgBackBtnClick(Sender: TObject);
begin
frmHistory.Hide;
frmprofile.show;
end;

end.
