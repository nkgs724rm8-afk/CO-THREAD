unit frmProductDetails_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, dmCoThread_U;

type
  TfrmProductDetails = class(TForm)
    imgItem: TImage;
    lblPrice: TLabel;
    lblTitle: TLabel;
    imgProductBG: TImage;
    imgOfferBtn: TImage;
    lblBrand: TLabel;
    lblSize: TLabel;
    lblCategory: TLabel;
    imgBuyBtn: TImage;
    lblDescription: TLabel;
    imgBackBtn: TImage;
    procedure imgBackBtnClick(Sender: TObject);
    procedure imgBuyBtnClick(Sender: TObject);
    procedure imgOfferBtnClick(Sender: TObject);
    procedure NotifySeller(iSellerID, iUnused: Integer; sType, sMessage: String);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProductDetails: TfrmProductDetails;

implementation
uses
frmMarket_U;

{$R *.dfm}

procedure TfrmProductDetails.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
application.terminate;
end;

procedure TfrmProductDetails.imgBackBtnClick(Sender: TObject);
begin
frmProductDetails.Hide;
frmMarket.show;
end;

procedure TfrmProductDetails.imgBuybtnClick(Sender: TObject);
var
  iSellerID: Integer;
  sPrice: String;
begin
  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT Seller_ID, Price FROM Items WHERE Item_ID = ' + IntToStr(dmCoThread.iSelectedItemID));
  dmCoThread.qrySQL.Open;
  iSellerID := dmCoThread.qrySQL.FieldByName('Seller_ID').AsInteger;
  sPrice := dmCoThread.qrySQL.FieldByName('Price').AsString;
  dmCoThread.qrySQL.Close;

  if iSellerID = dmCoThread.iCurrentUserID then
  begin
    ShowMessage('You cannot buy your own item.');
    Exit;
  end;

  if MessageDlg('Request to buy this item for R' + sPrice + '?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('INSERT INTO Offers (Item_ID, Buyer_ID, Seller_ID, OfferAmount, OfferType, Status, OfferDate) VALUES (' +
    IntToStr(dmCoThread.iSelectedItemID) + ', ' + IntToStr(dmCoThread.iCurrentUserID) + ', ' +
    IntToStr(iSellerID) + ', ' + sPrice + ', ''Buy'', ''Pending'', #' + FormatDateTime('mm/dd/yyyy', Now) + '#)');
  dmCoThread.qrySQL.ExecSQL;

  NotifySeller(iSellerID, dmCoThread.qrySQL.RowsAffected, 'NewBuyRequest', 'Someone wants to buy your item for R' + sPrice + '.');

  ShowMessage('Your purchase request has been sent to the seller.');
  frmMarket.Show;
end;


procedure TfrmProductDetails.imgOfferBtnClick(Sender: TObject);
var
  iSellerID: Integer;
  sOfferAmount: String;
  dOfferAmount: Double;
begin
  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT Seller_ID FROM Items WHERE Item_ID = ' + IntToStr(dmCoThread.iSelectedItemID));
  dmCoThread.qrySQL.Open;
  iSellerID := dmCoThread.qrySQL.FieldByName('Seller_ID').AsInteger;
  dmCoThread.qrySQL.Close;

  if iSellerID = dmCoThread.iCurrentUserID then
  begin
    ShowMessage('You cannot make an offer on your own item.');
    Exit;
  end;

  sOfferAmount := InputBox('Make an Offer', 'Enter your offer amount (R):', '');
  if not TryStrToFloat(sOfferAmount, dOfferAmount) then
  begin
    ShowMessage('Please enter a valid number.');
    Exit;
  end;

  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('INSERT INTO Offers (Item_ID, Buyer_ID, Seller_ID, OfferAmount, OfferType, Status, OfferDate) VALUES (' +
    IntToStr(dmCoThread.iSelectedItemID) + ', ' + IntToStr(dmCoThread.iCurrentUserID) + ', ' +
    IntToStr(iSellerID) + ', ' + FloatToStr(dOfferAmount) + ', ''Offer'', ''Pending'', #' + FormatDateTime('mm/dd/yyyy', Now) + '#)');
  dmCoThread.qrySQL.ExecSQL;

  NotifySeller(iSellerID, 0, 'NewOffer', 'You received a new offer of R' + FloatToStr(dOfferAmount) + '.');

  ShowMessage('Your offer of R' + FloatToStr(dOfferAmount) + ' has been sent.');
  frmMarket.Show;
end;

procedure TfrmProductDetails.NotifySeller(iSellerID, iUnused: Integer; sType, sMessage: String);
var
  iNewOfferID: Integer;
begin
  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT @@IDENTITY AS NewID');
  dmCoThread.qrySQL.Open;
  iNewOfferID := dmCoThread.qrySQL.FieldByName('NewID').AsInteger;
  dmCoThread.qrySQL.Close;

  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('INSERT INTO Notifications (User_ID, Message, NotificationDate, IsRead, Offer_ID, NotificationType) VALUES (' +
    IntToStr(iSellerID) + ', ''' + StringReplace(sMessage, '''', '''''', [rfReplaceAll]) + ''', #' +
    FormatDateTime('mm/dd/yyyy', Now) + '#, False, ' + IntToStr(iNewOfferID) + ', ''' + sType + ''')');
  dmCoThread.qrySQL.ExecSQL;
end;



end.
