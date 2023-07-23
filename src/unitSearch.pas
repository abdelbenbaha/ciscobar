unit unitSearch;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.IconFontImage, System.ImageList, FMX.ImgList,
  FMX.IconFontsImageList, FMX.Controls.Presentation, FMX.Edit,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.SVGIconImageList, FMX.Ani, Skia, Skia.FMX, FMX.StdCtrls,
  FMX.Menus;

type
  TfrmSearch = class(TForm)
    lytSearch: TLayout;
    rectSearch: TRectangle;
    edtSearch: TEdit;
    lytResult: TLayout;
    rectResult: TRectangle;
    imgSearch: TGlyph;
    animSearch: TFloatAnimation;
    scrList: TVertScrollBox;
    lytHint: TLayout;
    lblHint: TSkLabel;
    procedure rectSearchMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormCreate(Sender: TObject);
    procedure animSearchFinish(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtSearchTyping(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure scrListCalcContentBounds(Sender: TObject;
      var ContentBounds: TRectF);
    procedure animSearchProcess(Sender: TObject);
  private
   procedure animItemFinish(Sender: TObject);
   procedure addListItem(aText,aSecondaryText:string;index:integer);
   function generateInitials(aText:string):string;
  public
   ccmVersion:string;
   axlURL:string;
  end;

var
  frmSearch: TfrmSearch;

implementation

{$R *.fmx}

uses unitCommon, unitFirst,Neslib.Xml{$ifdef MSWINDOWS},Fmx.Platform.Win, Winapi.ShellAPI{$endif};

const colorPalette:array[0..8] of TAlphaColor=($ffE91E63,$ffC21858,$ff9C2780,$ff572780,$ff272AB0,$ff276880,$ff57AC0C,$ff570CBE,$ff60C689);

procedure TfrmSearch.animItemFinish(Sender: TObject);
begin
  with sender as TColorAnimation do
  if assigned(Tglyph(tag)) then
    begin
     if Trectangle(parent).Fill.Color=StopValue then
      Tglyph(tag).ImageIndex:=10
     else
     Tglyph(tag).ImageIndex:=9;
    end;
end;



function TfrmSearch.generateInitials(aText:string):string;
var words:TArray<string>;
begin
words:=aText.Split([' '],TStringSplitOptions.ExcludeEmpty);
 if length(words)>=2 then
  result:=words[0].Chars[0]+words[1].Chars[0]
 else
 result:=aText.Chars[0]+aText.Chars[1];
result:=result.ToUpper;
end;

procedure TfrmSearch.addListItem(aText,aSecondaryText:string;index:integer);
var lytItem,lytImage,lytText,lytButtons:Tlayout;
    rectItem,rectImage:Trectangle;
    lblInitials,lblText,lblSecondary:TSkLabel;
    imgCall:Tglyph;
    animItem:TColorAnimation;
begin
 lytItem:= TLayout.Create(self);
 with lytItem do
  begin
   Parent:=scrList;
   Align:=TAlignLayout.top;
   Height:=60;
   rectItem:=TRectangle.Create(self);
   rectItem.Parent:=lytItem;
   rectItem.Align:=TAlignLayout.Contents;
   rectItem.Stroke.Kind:=TBrushKind.None;
   rectItem.Fill.Kind:=TBrushKind.Solid;
   rectItem.Fill.Color:=TAlphaColors.Null;

   animItem:=TColorAnimation.Create(self);
   animItem.Parent:=rectItem;
   animItem.Trigger:='IsMouseOver=true';
   animItem.TriggerInverse:='IsMouseOver=false';
   animItem.Duration:=0.1;
   animItem.StartValue:=TAlphaColors.Null;
   animItem.StopValue:=$FF2F363D;
   animItem.Inverse:=true;
   animItem.PropertyName:='Fill.Color';
   animItem.OnFinish:=animItemFinish;

   lytImage:=TLayout.Create(self);
   lytImage.Parent:=rectItem;
   lytImage.Align:=TAlignLayout.MostLeft;
   lytImage.Width:=60;

   rectImage:=TRectangle.Create(self);
   rectImage.Parent:=lytImage;
   rectImage.Align:=TAlignLayout.Client;
   rectImage.Margins.Rect:=RectF(5,5,5,5);
   rectImage.Stroke.Kind:=TBrushKind.None;
   rectImage.XRadius:=4;
   rectImage.YRadius:=4;
   rectImage.Fill.Color:=colorPalette[index mod 9];
   rectImage.HitTest:=false;

   lblInitials:=TSkLabel.Create(self);
   lblInitials.parent:=rectImage;
   lblInitials.Align:=TAlignLayout.Client;
   lblInitials.TextSettings.FontColor:=TAlphaColorRec.White;
   lblInitials.TextSettings.Font.Size:=16;
   lblInitials.TextSettings.HorzAlign:=TSkTextHorzAlign.Center;
   lblInitials.Text:=generateInitials(aText);

   lytText:=TLayout.Create(self);
   lytText.Parent:=rectItem;
   lytText.Align:=TAlignLayout.Client;
   lytText.Margins.Rect:=RectF(5,5,5,5);

   lblText:=TSkLabel.Create(self);
   lblText.parent:=lytText;
   lblText.Align:=TAlignLayout.MostTop;
   lblText.TextSettings.FontColor:=TAlphaColorRec.White;
   lblText.TextSettings.Font.Size:=14;
   lblText.TextSettings.HorzAlign:=TSkTextHorzAlign.Justify;
   lblText.Text:=aText;

   lblSecondary:=TSkLabel.Create(self);
   lblSecondary.parent:=lytText;
   lblSecondary.Align:=TAlignLayout.Bottom;
   lblSecondary.TextSettings.FontColor:=TAlphaColorRec.White;
   lblSecondary.TextSettings.Font.Size:=12;
   lblSecondary.TextSettings.HorzAlign:=TSkTextHorzAlign.Justify;
   lblSecondary.Text:=aSecondaryText;

   lytButtons:=TLayout.Create(self);
   lytButtons.Parent:=rectItem;
   lytButtons.Align:=TAlignLayout.MostRight;
   lytButtons.Margins.Rect:=RectF(5,5,5,5);

   imgCall:=TGlyph.Create(self);
   imgCall.parent:=lytButtons;
   imgCall.Align:=TAlignLayout.Center;
   imgCall.Images:=dmCommon.iconsSmall;
   imgCall.ImageIndex:=9;
   animItem.Tag:=NativeInt(imgCall);
  end;
end;

procedure TfrmSearch.animSearchFinish(Sender: TObject);
begin
if rectSearch.Opacity=animSearch.StopValue then
 begin
  edtSearch.Visible:=true;
  ActiveControl:=edtSearch;
  edtSearch.SetFocus;
  edtSearch.TextPrompt:=dmCommon.getStringByName('searchPrompt');
 end
 else
 begin
 edtSearch.Visible:=false;
 edtSearch.ResetFocus;
 edtSearch.TextPrompt:='';
 edtSearch.ResetSelection;
 end;

end;

procedure TfrmSearch.animSearchProcess(Sender: TObject);
begin
if lytResult.Visible then
 begin
 animSearch.StartValue:=animSearch.StopValue;
 end
 else
 animSearch.StartValue:=0.3;

end;

function properCase(aText:string):string;
begin
 result:=Atext.Substring(0,1).ToUpper+Atext.Substring(1,length(aText)).ToLower;
end;

procedure TfrmSearch.edtSearchTyping(Sender: TObject);
var status:string;response:string;
    rows:TXmlNode;
begin
 lytResult.Visible:=false;
  for var i:= scrList.Content.ChildrenCount - 1 downto 0 do
  scrList.Content.Children.Items[I].DisposeOf;
  if edtSearch.Text.Length>=2 then
   begin
   var dummy:integer;
   if TryStrToInt(edtSearch.Text,dummy) then

    response:=dmCommon.execSearchQuery(axlURL,
                                      ccmVersion,
                                      'sql=SELECT firstname,lastname,telephonenumber from enduser where telephonenumber like '+format('%s%%',[edtSearch.Text]).QuotedString,
                                      status)
    else
    response:=dmCommon.execSearchQuery(axlURL,
                             ccmVersion,
                            'sql=SELECT firstname,lastname,telephonenumber from enduser where firstname like '+
                            format('%s%%',[edtSearch.Text.ToUpper]).QuotedString+
                            ' or firstname like '+
                            format('%s%%',[edtSearch.Text.ToLower]).QuotedString+
                            ' or firstname like '+
                            format('%s%%',[propercase(edtSearch.Text)]).QuotedString+
                            ' or lastname like '+
                            format('%s%%',[edtSearch.Text.ToUpper]).QuotedString+
                            ' or lastname like '+
                            format('%s%%',[edtSearch.Text.ToLower]).QuotedString+
                            ' or lastname like '+
                            format('%s%%',[propercase(edtSearch.Text)]).QuotedString,
                             status);

   end;
   if dmCommon.isValidXML(response) then
    with TXmlDocument.Create do
     try
      parse(response);
      rows:=DocumentElement.ElementByName('soapenv:Body').ElementByName('ns:executeSQLQueryResponse').ElementByName('return');
      if  not rows.FirstChild.IsEmpty then
      begin
       var index:integer:=0;
       lytResult.Visible:=true;
        for var child:TXmlNode in rows do
        begin
        var fullName:string;
          if SameText(child.ElementByName('firstname').Text,child.ElementByName('lastname').Text) then
           fullName:=child.ElementByName('firstname').Text
          else
          fullName:=child.ElementByName('firstname').Text+' '+child.ElementByName('lastname').Text;

          fullname:=fullName.TrimLeft;
          fullname:=fullname.Replace('  ',' ');

          addListItem(fullname,child.ElementByName('telephonenumber').Text,index);
          index:=index+1;
        end;
      end;
        finally
      Clear;
     end;
end;

procedure TfrmSearch.FormCreate(Sender: TObject);
var status,cServer,cUsername,cPassword:string;
begin
  FindCmdLineSwitch('s',cserver,true,[clstValueAppended]);
  FindCmdLineSwitch('u',cUsername,true,[clstValueAppended]);
  FindCmdLineSwitch('p',cPassword,true,[clstValueAppended]);
  if (cServer='') or (cUsername='') or (cPassword='')  then
   begin
    cServer:=dmCommon.readParameter('cucm','baseUrl');
    cUsername:=dmCommon.readParameter('cucm','username');
    cPassword:=dmCommon.readParameter('cucm','password');
   end;
  if dmCommon.validateCredentials(cserver,cUsername,cPassword,status) then
  begin
  dmCommon.setCredentials(cServer,cUsername,cPassword);
  axlURL:=dmCommon.makeURL(cServer,axlService);
  ccmVersion:=dmCommon.getCCMVersion(axlURL,status);
  end;
  if ccmVersion='' then
   begin
     hide;
     Application.CreateForm(TfrmFirst, frmFirst);
     frmFirst.ShowModal;
   end
   else
   ccmVersion:=ccmVersion.Split(['.'],2)[0]+'.'+ccmVersion.Split(['.'],2)[1];
end;

procedure TfrmSearch.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
if key=vkEscape then
 begin
 lytResult.Visible:=false;
 edtSearch.Text:='';
 end;

end;

procedure TfrmSearch.FormShow(Sender: TObject);
begin
left:=Round(Screen.Width / 2)  -Round(Width / 2);
top:=0;
lblHint.Words.Clear;
var words:Tarray<string>;
    words:=dmCommon.getStringByName('pressEsc').Split([' '],TStringSplitOptions.ExcludeEmpty);
    for var word:string in words do
     with lblHint.Words.Add(word+' ') do
      if word='esc' then
      begin
       BackgroundColor:=TAlphaColors.White;
       FontColor:=TAlphaColors.Black;
       StyledSettings:=StyledSettings-[TStyledSetting.fontColor];
      end
end;

procedure TfrmSearch.rectSearchMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
StartWindowDrag;
end;

procedure TfrmSearch.scrListCalcContentBounds(Sender: TObject;
  var ContentBounds: TRectF);
begin
if ContentBounds.Height<265 then
frmSearch.height:=trunc(lytSearch.Height+ContentBounds.Height)+25
else
frmSearch.height:=320;
end;

end.
