unit unitFirst;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.IconFontImage, System.ImageList, FMX.ImgList,
  FMX.IconFontsImageList, FMX.Controls.Presentation, FMX.Edit,FMX.SVGIconImageList, FMX.StdCtrls, FMX.Ani, FMX.TabControl,
  Skia, Skia.FMX, FMX.Effects, FMX.Memo.Types, FMX.ScrollBox;

type
  TfrmFirst = class(TForm)
    lytBar: TLayout;
    rectBar: TRectangle;
    rectClose: TRectangle;
    btnClose: TGlyph;
    ColorAnimation1: TColorAnimation;
    iconApp: TGlyph;
    lytMain: TLayout;
    rectMain: TRectangle;
    lytSlider: TLayout;
    lytTitle: TLayout;
    lytDescription: TLayout;
    lytImage: TLayout;
    iconSlider: TGlyph;
    lblTitle: TSkLabel;
    animSlider: TFloatAnimation;
    lblSlideTitle: TSkLabel;
    lblSlideDescription: TSkLabel;
    lytCredentials: TLayout;
    lytServer: TLayout;
    rectServer: TRectangle;
    iconServer: TGlyph;
    edtServer: TEdit;
    lytPassword: TLayout;
    rectPassword: TRectangle;
    iconPassword: TGlyph;
    edtPassword: TEdit;
    lytUsername: TLayout;
    rectUsername: TRectangle;
    iconUsername: TGlyph;
    edtUsername: TEdit;
    lytButtons: TLayout;
    rectCancel: TRectangle;
    rectSave: TRectangle;
    lblSave: TSkLabel;
    lblCancel: TSkLabel;
    animCancel: TColorAnimation;
    GlowEffect1: TGlowEffect;
    imgLoading: TSkAnimatedImage;
    lytError: TLayout;
    rectError: TRectangle;
    Glyph3: TGlyph;
    lblError: TSkLabel;
    rectInfo1: TRectangle;
    imgInfo1: TGlyph;
    rectInfo2: TRectangle;
    imgInfo2: TGlyph;
    procedure rectCloseClick(Sender: TObject);
    procedure rectBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormCreate(Sender: TObject);
    procedure animSliderFinish(Sender: TObject);
    procedure edtServerEnter(Sender: TObject);
    procedure edtServerExit(Sender: TObject);
    procedure rectSaveClick(Sender: TObject);
    procedure edtServerKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
   
  private
    arrSlider:  array of array[0..2] of Variant;
    currentSlide:integer;
    procedure initSliderData;
    procedure setSliderData(aTitle:string;aDescription:string;aImage:integer);

    procedure setError(aText:string);
  public
    { Public declarations }
  end;

var
  frmFirst: TfrmFirst;

implementation

{$R *.fmx}

uses unitCommon,System.Net.URLClient, unitSearch;

procedure TfrmFirst.setError(aText: string);
begin
lytError.Visible:=true;
lblError.Text:=aText;
end;

procedure TfrmFirst.animSliderFinish(Sender: TObject);
begin
  if currentSlide=high(arrSlider) then
  currentSlide:=low(arrSlider)
  else
  currentSlide:=currentSlide+1;
  setSliderData(arrSlider[currentSlide][0],arrSlider[currentSlide][1],arrSlider[currentSlide][2]);
  lytSlider.Opacity:=1;
  animSlider.Start;
end;

procedure TfrmFirst.edtServerEnter(Sender: TObject);
begin
  with sender as TEdit do
    if (Parent is TRectangle) and (TRectangle(parent).Stroke.Kind<>TBrushKind.Solid) then
     begin
     TRectangle(Parent).Stroke.Color:=$FF7F44C4;
     TRectangle(parent).Stroke.Kind:=TBrushKind.Solid;
     end;
end;

procedure TfrmFirst.edtServerExit(Sender: TObject);
begin
with sender as TEdit do
  if Parent is TRectangle then
   begin
   TRectangle(parent).Stroke.Kind:=TBrushKind.None;
   end;
end;

procedure TfrmFirst.edtServerKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
case  Key of
vktab:
 begin
  if sender=edtServer then
   edtUsername.SetFocus
  else
    if sender=edtUsername then
   edtPassword.SetFocus
 end;
 vkReturn:
 begin
 rectSaveClick(rectSave);
 end;
end;


end;

procedure TfrmFirst.FormCreate(Sender: TObject);
begin
initSliderData;
currentSlide:=0;
setSliderData(arrSlider[currentSlide][0],arrSlider[currentSlide][1],arrSlider[currentSlide][2]);
animSlider.Start;
end;

procedure TfrmFirst.FormShow(Sender: TObject);
begin
lblCancel.Text:=dmCommon.getStringByName('btnCancel');
lblSave.Text:=dmCommon.getStringByName('btnSave');
edtUsername.TextPrompt:=dmCommon.getStringByName('johnDoe');
rectInfo1.Hint:=dmCommon.getStringByName('cucmHint');
rectInfo2.Hint:=dmCommon.getStringByName('usernameHint');
end;

procedure TfrmFirst.setSliderData(aTitle:string;aDescription:string;aImage:integer);
begin
lblSlideTitle.Text:=aTitle;
lblSlideDescription.Text:=aDescription;
iconSlider.ImageIndex:=aImage;
end;

procedure TfrmFirst.initSliderData;
begin
 //Three slides
 setlength(arrSlider,4);

{$REGION 'first slide'}
 //Slide's title
 arrSlider[0][0] := dmCommon.getStringByName('slideFirstTitle');//slide text
 //Slide's description
 arrSlider[0][1] := dmCommon.getStringByName('slideFirstDescription');
 //Slide's Image
 arrSlider[0][2] := 0;
{$ENDREGION}

{$REGION 'second slide'}
 //Slide's title
 arrSlider[1][0] := dmCommon.getStringByName('slideSecondTitle');//slide text
 //Slide's description
 arrSlider[1][1] := dmCommon.getStringByName('slideSecondDescription');
 //Slide's Image
 arrSlider[1][2] := 1;
{$ENDREGION}

{$REGION 'third slide'}
 //Slide's title
 arrSlider[2][0] := dmCommon.getStringByName('slideThirdTitle');//slide text
 //Slide's description
 arrSlider[2][1] := dmCommon.getStringByName('slideThirdDescription');
 //Slide's Image
 arrSlider[2][2] := 2;
{$ENDREGION}

{$REGION 'fourth slide'}
 //Slide's title
 arrSlider[3][0] := dmCommon.getStringByName('slideFourthTitle');//slide text
 //Slide's description
 arrSlider[3][1] := dmCommon.getStringByName('slideFourthDescription');
 //Slide's Image
 arrSlider[3][2] := 3;
{$ENDREGION}
end;


procedure TfrmFirst.rectBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
StartWindowDrag;
end;

procedure TfrmFirst.rectCloseClick(Sender: TObject);
begin
Application.Terminate;
end;

procedure TfrmFirst.rectSaveClick(Sender: TObject);
var status,version:string;
begin
  if dmCommon.validateCredentials(edtServer.Text,edtUsername.Text,edtPassword.Text,status) then
  begin
    //
    rectsave.Enabled:=false;
    lblSave.Visible:=false;
    imgLoading.Visible:=true;

    dmCommon.setCredentials(edtServer.Text,edtUsername.Text,edtPassword.text);
    //get Cisco Unified Communication Manager version.
    version:=dmCommon.getCCMVersion(dmCommon.makeUrl(edtServer.Text,axlService),status);
    if version='' then
     setError(status)
    else
    begin
    lytError.Visible:=false;
    dmCommon.writeParameter('cucm','baseUrl',edtServer.Text,'cucm base url',true);
    dmCommon.writeParameter('cucm','username',edtUsername.Text,'cucm services authentication username',true);
    dmCommon.writeParameter('cucm','password',edtPassword.Text,'cucm services authentication password',true);
    frmSearch.ccmVersion:=version.Split(['.'],2)[0]+'.'+version.Split(['.'],2)[1];
    frmSearch.axlURL:=dmCommon.makeURL(edtServer.Text,axlService);
    frmSearch.Show;
    close;
    exit;
    end;
    rectsave.Enabled:=true;
    lblSave.Visible:=true;
    imgLoading.Visible:=false;
  end
  else
  setError(status);
end;

end.
