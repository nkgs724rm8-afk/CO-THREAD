unit frmEditItem_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.StdCtrls, dmCoThread_U, Vcl.DBCGrids, Data.db, vcl.extdlgs;

type
  TfrmEditItem = class(TForm)
    imgEditItemBG: TImage;
    imgDeletebtn: TImage;
    imgSoldBtn: TImage;
    imgUpdateBtn: TImage;
    edtTitle: TEdit;
    memDescription: TMemo;
    imgPhoto: TImage;
    imgBackBtn: TImage;
    cbxCategory: TComboBox;
    edtPrice: TEdit;
    cbxSize: TComboBox;
    cbxBrand: TComboBox;
    procedure imgBackBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgUpdateBtnClick(Sender: TObject);
    procedure imgDeletebtnClick(Sender: TObject);
    procedure imgSoldBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgPhotoClick(Sender: TObject);
    procedure cbxCategoryChange(Sender: TObject);
  private
    { Private declarations }
    var
    sNewImagePath : String;
  public
    { Public declarations }
  end;

var
  frmEditItem: TfrmEditItem;

implementation
uses
frmListings_U;

{$R *.dfm}

procedure TfrmEditItem.cbxCategoryChange(Sender: TObject);
begin
cbxSize.Clear;

  cbxSize.Enabled := True;

  case cbxCategory.ItemIndex of

    // T-Shirts, Hoodies, Sweaters, Jackets, Activewear, Formal wear
    0,1,2,3,10,12:
      cbxSize.Items.AddStrings(['XS','S','M','L','XL','XXL']);


    // Jeans, Pants
    4,5:
      cbxSize.Items.AddStrings(['28','30','32','34','36','38','40']);


    // Shorts, Dresses, Skirts
    6, 7, 8:
      cbxSize.Items.AddStrings(['XS','S','M','L','XL']);


    // Shoes (UK Sizes)
    9:
      cbxSize.Items.AddStrings(
        ['3','4','5','6','7','8','9','10','11','12']);



    // Accessories
    11:
      cbxSize.Items.Add('One Size');


    // Other
    13:
      cbxSize.Items.Add('One Size');

  end;

  if cbxSize.Items.Count > 0 then
    cbxSize.ItemIndex := 0;
end;

procedure TfrmEditItem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
application.terminate;
end;

procedure TfrmEditItem.FormShow(Sender: TObject);
var
sImagePath : String;
begin
cbxCategory.Style := csDropDownList;
cbxSize.Style := csDropDownList;
cbxBrand.Style := csDropDownList;
case cbxCategory.ItemIndex of

    // T-Shirts, Hoodies, Sweaters, Jackets, Activewear, Formal wear
    0,1,2,3,10,12:
      cbxSize.Items.AddStrings(['XS','S','M','L','XL','XXL']);


    // Jeans, Pants
    4,5:
      cbxSize.Items.AddStrings(['28','30','32','34','36','38','40']);


    // Shorts, Dresses, Skirts
    6, 7, 8:
      cbxSize.Items.AddStrings(['XS','S','M','L','XL']);


    // Shoes (UK Sizes)
    9:
      cbxSize.Items.AddStrings(
        ['3','4','5','6','7','8','9','10','11','12']);



    // Accessories
    11:
      cbxSize.Items.Add('One Size');


    // Other
    13:
      cbxSize.Items.Add('One Size');

  end;

  if cbxSize.Items.Count > 0 then
    cbxSize.ItemIndex := 0;


sNewImagePath := '';
 dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT * FROM Items WHERE Item_ID = ' + IntToStr(dmCoThread.iSelectedItemID));
  dmCoThread.qrySQL.Open;

  if not dmCoThread.qrySQL.IsEmpty then
  begin
    edtTitle.Text := dmCoThread.qrySQL.FieldByName('Title').AsString;
    cbxBrand.Text := dmCoThread.qrySQL.FieldByName('Brand').AsString;
    cbxCategory.Text := dmCoThread.qrySQL.FieldByName('Category').AsString;
    cbxSize.Text := dmCoThread.qrySQL.FieldByName('Size').AsString;
    edtPrice.Text := dmCoThread.qrySQL.FieldByName('Price').AsString;
    memDescription.Text := dmCoThread.qrySQL.FieldByName('Description').AsString;


  sImagePath := ExtractFilePath(Application.ExeName) + dmCoThread.qrySQL.FieldByName('ImagePath').AsString;
    if FileExists(sImagePath) then
      imgPhoto.Picture.LoadFromFile(sImagePath)
    else
      imgPhoto.Picture := nil;
  end;
  dmCoThread.qrySQL.Close;

  imgPhoto.Cursor := crHandPoint;
  imgPhoto.OnClick := imgPhotoClick;
end;

procedure TfrmEditItem.imgBackBtnClick(Sender: TObject);
begin
 frmListings.Show;
 frmEdititem.hide;
end;

procedure TfrmEditItem.imgDeletebtnClick(Sender: TObject);
var
bAvailable : Boolean;
begin
 dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT * FROM Items WHERE Seller_ID = ' + IntToStr(dmCoThread.iCurrentUserID));
  dmCoThread.qrySQL.Open;

bAvailable := dmCothread.qrysql.fieldbyname('Availability').AsBoolean;
if bAvailable then
begin

  if MessageDlg('Are you sure you want to delete this item? This cannot be undone.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    dmCoThread.qrySQL.Close;
    dmCoThread.qrySQL.SQL.Clear;
    dmCoThread.qrySQL.SQL.Add('DELETE FROM Items WHERE Item_ID = ' + IntToStr(dmCoThread.iSelectedItemID));
    dmCoThread.qrySQL.ExecSQL;

    ShowMessage('Item deleted.');
    frmListings.Show;
    Self.Hide;
  end;

end
else
begin
  showmessage('Item already sold. Can not be deleted');
  exit;
end;
end;


procedure TfrmEditItem.imgPhotoClick(Sender: TObject);
var
  dlgOpen: TOpenPictureDialog;
begin
  dlgOpen := TOpenPictureDialog.Create(Self);
  try
    dlgOpen.Filter := 'Image files (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp';
    dlgOpen.Title := 'Select a new photo';

    if dlgOpen.Execute then
    begin
      sNewImagePath := dlgOpen.FileName;
      imgPhoto.Picture.LoadFromFile(sNewImagePath);
    end;
  finally
    dlgOpen.Free;
  end;
end;
procedure TfrmEditItem.imgSoldBtnClick(Sender: TObject);
var
  sBuyerUsername: String;
  iBuyerID: Integer;
bAvailable : Boolean;
begin
 dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT * FROM Items WHERE Seller_ID = ' + IntToStr(dmCoThread.iCurrentUserID));
  dmCoThread.qrySQL.Open;

bAvailable := dmCothread.qrysql.fieldbyname('Availability').AsBoolean;
if bAvailable then
begin

  if MessageDlg('Are you sure you want to delete this item? This cannot be undone.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
  sBuyerUsername := InputBox('Mark as Sold', 'Enter the buyer''s username:', '');

  if Trim(sBuyerUsername) = '' then
    Exit; // user cancelled or left it blank

  // Look up the buyer's UserID from their username
  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('SELECT User_ID FROM Users WHERE Username = ''' +
    StringReplace(sBuyerUsername, '''', '''''', [rfReplaceAll]) + '''');
  dmCoThread.qrySQL.Open;

  if dmCoThread.qrySQL.IsEmpty then
  begin
    dmCoThread.qrySQL.Close;
    ShowMessage('No user found with that username. Please check and try again.');
    Exit;
  end;

  iBuyerID := dmCoThread.qrySQL.FieldByName('User_ID').AsInteger;
  dmCoThread.qrySQL.Close;

  if MessageDlg('Mark this item as sold to "' + sBuyerUsername + '"?',
                mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  // Update the item status
  dmCoThread.qrySQL.SQL.Clear;
 dmCoThread.qrySQL.SQL.Add('UPDATE Items SET Availability = False WHERE Item_ID = ' +
    IntToStr(dmCoThread.iSelectedItemID));
  dmCoThread.qrySQL.ExecSQL;

  // Insert a record into Purchases
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('INSERT INTO Purchases (Item_ID, Buyer_ID, Seller_ID, Amount, PurchaseDate) VALUES (' +
    IntToStr(dmCoThread.iSelectedItemID) + ', ' +
    IntToStr(iBuyerID) + ', ' +
    IntToStr(dmCoThread.iCurrentUserID) + ', ' +
    edtPrice.Text + ', ' +
    '#' + FormatDateTime('mm/dd/yyyy', Now) + '#)');
  dmCoThread.qrySQL.ExecSQL;

  ShowMessage('Item marked as sold to ' + sBuyerUsername + '.');
  frmListings.Show;
  Self.Hide;
  end;

end
else
begin
  showmessage('Item already sold.');
  exit;
end;



end;

procedure TfrmEditItem.imgUpdateBtnClick(Sender: TObject);
var
  sDestFileName, sDestFullPath, sImageSQL: String;
  rPrice : double;
begin
 if Trim(edtPrice.Text) = '' then
  begin
    ShowMessage('Please enter a price.');
    edtPrice.SetFocus;
    Exit;
  end;

  if not TryStrToFloat(edtPrice.Text, rPrice) then
  begin
    ShowMessage('Please enter a valid price (numbers only).');
    Exit;
  end;

  try
    rPrice := StrToFloat(edtPrice.Text);

    if rPrice <= 0 then
    begin
      ShowMessage('Price must be greater than 0.');
      edtPrice.Clear;
      edtPrice.SetFocus;
      Exit;
    end;

  except
    on EConvertError do
    begin
      ShowMessage('Please enter a valid price.');
      edtPrice.Clear;
      edtPrice.SetFocus;
    end;
  end;
  if Trim(edtTitle.Text) = '' then
  begin
    ShowMessage('Please enter a title.');
    Exit;
  end;

  if cbxCategory.ItemIndex = -1 then
begin
  ShowMessage('Please select a category.');
  cbxCategory.SetFocus;
  Exit;
end;

// Size Validation

if cbxSize.ItemIndex = -1 then
begin
  ShowMessage('Please select a size.');
  cbxSize.SetFocus;
  Exit;
end;

// Brand Validation

if cbxBrand.ItemIndex = -1 then
begin
  ShowMessage('Please select a brand.');
  cbxBrand.SetFocus;
  Exit;
end;

  if Trim(edtTitle.Text) = '' then
  begin
    ShowMessage('Please enter a title.');
    Exit;
  end;

  if Trim(memDescription.Text) = '' then
  begin
    ShowMessage('Please enter a description.');
    Exit;
  end;


  sImageSQL := '';

  if sNewImagePath <> '' then
  begin
    sDestFileName := 'Item_' + IntToStr(dmCoThread.iSelectedItemID) + ExtractFileExt(sNewImagePath);
    sDestFullPath := ExtractFilePath(Application.ExeName) + 'Images\' + sDestFileName;

    ForceDirectories(ExtractFilePath(sDestFullPath));
    CopyFile(PChar(sNewImagePath), PChar(sDestFullPath), False);

    sImageSQL := 'ImagePath = ''Images\' + sDestFileName + ''', ';
  end;

  dmCoThread.qrySQL.Close;
  dmCoThread.qrySQL.SQL.Clear;
  dmCoThread.qrySQL.SQL.Add('UPDATE Items SET ' +
    sImageSQL +
    'Title = ''' + StringReplace(edtTitle.Text, '''', '''''', [rfReplaceAll]) + ''', ' +
    'Brand = ''' + StringReplace(cbxBrand.Text, '''', '''''', [rfReplaceAll]) + ''', ' +
    'Category = ''' + StringReplace(cbxCategory.Text, '''', '''''', [rfReplaceAll]) + ''', ' +
    'Size = ''' + StringReplace(cbxSize.Text, '''', '''''', [rfReplaceAll]) + ''', ' +
    'Price = ' + edtPrice.Text + ', ' +
    'Description = ''' + StringReplace(memDescription.Text, '''', '''''', [rfReplaceAll]) + ''' ' +
    'WHERE Item_ID = ' + IntToStr(dmCoThread.iSelectedItemID));
  dmCoThread.qrySQL.ExecSQL;

  ShowMessage('Item updated successfully.');
  frmListings.Show;
  frmedititem.Hide;
end;

end.
