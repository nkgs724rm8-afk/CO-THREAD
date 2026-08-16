unit frmNotifications_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage, dmCoThread_U,
  Vcl.StdCtrls, Vcl.DBCGrids, Data.db;

type
  TfrmNotifications = class(TForm)
    imgNotificationsBG: TImage;
    imgBackBtn: TImage;
    sbNotifications: TScrollBox;
    pnlRoundedCorners: TPanel;
    procedure imgBackBtnClick(Sender: TObject);
    procedure MarkAsRead(iNotificationID: Integer);
    procedure NotificationClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
      procedure ClearScrollBox(sb: TScrollBox);
      procedure LoadNotifications;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNotifications: TfrmNotifications;

implementation

{$R *.dfm}

uses
  frmRespondOffer_U, frmLeaveReview_U, frmProfile_U;

procedure TfrmNotifications.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
application.terminate;
end;

procedure TfrmNotifications.FormShow(Sender: TObject);
begin
  LoadNotifications;
end;

procedure TfrmNotifications.imgBackbtnClick(Sender: TObject);
begin
  frmProfile.Show;
  Self.Hide;
end;

procedure TfrmNotifications.ClearScrollBox(sb: TScrollBox);
var
  i: Integer;
begin
  for i := sb.ControlCount - 1 downto 0 do
    sb.Controls[i].Free;
end;

procedure TfrmNotifications.LoadNotifications;
var
  pnlTile,pnlAccent: TPanel;
  lblMessage, lblDate: TLabel;
  iTop: Integer;
begin
pnlRoundedCorners.height := 857;
pnlRoundedCorners.width := 1793;
pnlRoundedCorners.top := 136;
pnlRoundedCorners.left := 56;
sbNotifications.width := 1793;
sbNotifications.height := 857;
SetWindowRgn(pnlRoundedCorners.Handle,CreateRoundRectRgn(0,0,pnlRoundedCorners.Width,pnlRoundedCorners.Height,30,30),True);

  ClearScrollBox(sbNotifications);

  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT * FROM Notifications WHERE User_ID = ' +
    IntToStr(dmCoThread.iCurrentUserID) + ' ORDER BY NotificationDate DESC');
  dmCoThread.qrySQL.Open;

  iTop := 15;
  dmCoThread.qrySQL.First;
  while not dmCoThread.qrySQL.Eof do
  begin
    pnlTile := TPanel.Create(sbNotifications);
    pnlTile.Parent := sbNotifications;
    pnlTile.BringToFront;
    pnlTile.Left := 10;
    pnlTile.Top := iTop;
    pnlTile.Width := sbNotifications.Width - 40;
    pnlTile.BevelOuter := bvLowered;
    pnlTile.Cursor := crHandPoint;
    pnlTile.Tag := dmCoThread.qrySQL.FieldByName('Notification_ID').AsInteger;
    pnlTile.OnClick := NotificationClick;

     lblMessage := TLabel.Create(pnlTile);
    lblMessage.BringToFront;
    lblMessage.Parent := pnlTile;
    lblMessage.Left := 26;
    lblMessage.Top := 12;
    lblMessage.Width := pnlTile.Width - 46;
    lblMessage.Height := 40;
    //lblMessage.WordWrap := True;
    lblMessage.autosize := False;
    lblMessage.font.size := 12;
    lblMessage.font.name :='Segoe UI';
    lblmessage.font.color := clBlack;
    lblMessage.Caption := dmCoThread.qrySQL.FieldByName('Message').AsString;
    lblMessage.Cursor := crHandPoint;
    lblMessage.OnClick := NotificationClick;
    lblMessage.autosize := True;


    {if not dmCoThread.qrySQL.FieldByName('IsRead').AsBoolean then
      pnlTile.Color := RGB(50,46,38)
    else
      pnlTile.Color := RGB(38,38,40);}

    pnlAccent := TPanel.Create(pnlTile);
    pnlAccent.Parent := pnlTile;
    pnlAccent.ParentBackground := false;
    pnlAccent.BringToFront;
    pnlAccent.Align := alLeft;
    pnlAccent.Width := 6;
    pnlAccent.BevelOuter := bvNone;
    if not dmCoThread.qrySQL.FieldByName('IsRead').AsBoolean then
      pnlAccent.Color := RGB(212, 175, 55)
    else
      pnlAccent.Color := RGB(70, 70, 72);






    lblDate := TLabel.Create(pnlTile);
    lblDate.bringToFRont;
    lblDate.Parent := pnlTile;
    lblDate.Left := 26;
    lblDate.Top := lblMessage.top + lblmessage.height + 8;
       lblDate.Font.Size := 9;
        lblDate.Font.Color := clGray;
    lblDate.Caption := DateTimeToStr(dmCoThread.qrySQL.FieldByName('NotificationDate').AsDateTime);
    lblDate.Cursor := crHandPoint;
    lblDate.OnClick := NotificationClick;



    pnlTile.Height := lblDate.Top+lbldate.Height+16;

    iTop := iTop + pnlTile.Height+12;
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

procedure TfrmNotifications.MarkAsRead(iNotificationID: Integer);
begin
  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('UPDATE Notifications SET IsRead = True WHERE Notification_ID = ' +
    IntToStr(iNotificationID));
  dmCoThread.qrySQL.ExecSQL;
end;

procedure TfrmNotifications.NotificationClick(Sender: TObject);
var
  pnlClicked: TPanel;
  iNotificationID, iOfferID: Integer;
  sType: String;
begin
  if Sender is TPanel then
    pnlClicked := TPanel(Sender)
  else
    pnlClicked := TPanel((Sender as TControl).Parent);

  iNotificationID := pnlClicked.Tag;

  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT * FROM Notifications WHERE Notification_ID = ' + IntToStr(iNotificationID));
  dmCoThread.qrySQL.Open;

  sType := dmCoThread.qrySQL.FieldByName('NotificationType').AsString;
  iOfferID := dmCoThread.qrySQL.FieldByName('Offer_ID').AsInteger;
  dmCoThread.qrySQL.Close;

  MarkAsRead(iNotificationID);

  if (sType = 'NewOffer') or (sType = 'NewBuyRequest') then
  begin
    dmCoThread.iSelectedOfferID := iOfferID;
    frmRespondOffer.Show;
    Self.Hide;
  end
  else if sType = 'ReviewPrompt' then
  begin
    dmCoThread.iSelectedOfferID := iOfferID;
    frmLeaveReview.Show;
    Self.Hide;
  end
  else
  begin
    // 'Accepted' / 'Declined' — just informational, refresh the list to show it as read
    LoadNotifications;
  end;


end;

end.

