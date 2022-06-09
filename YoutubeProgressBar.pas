unit YoutubeProgressBar;

interface

uses FMX.Layouts,FMX.Objects,System.Classes,FMX.Graphics,System.UITypes,FMX.Types,System.sysutils,System.Types,
     FMX.Forms,FMX.StdCtrls,FMX.Dialogs;

Const DisplaySpeed=0.1;

Type

  TRequestHintEvent = procedure(Sender: TObject;var HintText:string) of object;
  TMouseMoveOverProgressBarEvent = procedure(Sender: TObject;ProgressValue:Single) of object;
  TYoutubeProgressbar=class(TLayout)
        private
        FMousePositionRaliveProgress:single;
        FCircle:TCircle;
        FRoundRect:TRoundRect;
        FProgressbar:TRoundRect;
        FBufferProgressbar:TRoundRect;
        FFocusCapter:Tbutton;
        Frect:TRectangle;
        FLayout:TLayout;
        FMin,FMax,FValue,FBufferValue,FStepProgressValue:single;
        FFocused:boolean;
        FProgressColor,FBufferProgressColor,FBackgroundColor:TAlphaColor;
        FHighlightAnimation:boolean;
        FOnClick,FOnInteractiveProgressChange,
        FOnProgressChange,FOnBufferProgressChange:TNotifyEvent;
        FOnMouseMoveOverProgressbar:TMouseMoveOverProgressBarEvent;
        FHint:TLabel;
        FHintText:string;
        FOnHintRequest:TRequestHintEvent;
        procedure SetHighlightedStyle;
        procedure SetUnHighlightedStyle;
        procedure SetBarProgress(wValue: single;indicator:byte=0;withEvent:boolean=true);
        procedure MouseDownHandler(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Single);
        procedure MouseMoveHandler(Sender: TObject; Shift: TShiftState; X,Y: Single);
        procedure MouseLeaveHandler(Sender:TObject);
        procedure MouseUpHandler(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Single);
        procedure FocusCapterHandler(Sender: TObject; var Key: Word;var KeyChar: Char; Shift: TShiftState);
        procedure FocuserExit(Sender:TObject);
        procedure SelResizeHandler(Sender: TObject);
        procedure SetValue(value:single);
        procedure SetBufferValue(value:single);
        procedure SetMax(value:single);
        procedure SetMin(Value:single);
        procedure SetProgressColor(Value:TAlphaColor);
        procedure SetBufferProgressColor(Value:TAlphaColor);
        procedure SetBackgroundColor(Value:TAlphaColor);
        procedure SetHighlightAnimation(Value:boolean);
        public
        constructor create(AOwner: TComponent);
        function GetProgressAsPercentage(indicator: byte=0): Single;
        procedure SetFocus;
        procedure OneStepForward;
        procedure OneStepBackward;
        procedure Reset;
        published
        property Value:single read FValue write SetValue;
        property BufferValue:single read FBufferValue write SetBuffervalue;
        property Min :single read Fmin write SetMin;
        property Max:single read Fmax write SetMax;
        property MousePositionProgress:single read FMousePositionRaliveProgress;
        property ProgressColor:TAlphaColor read FProgressColor write SetProgressColor;
        property BufferProgressColor:TAlphaColor read FBufferProgressColor write SetBufferProgressColor;
        property BackgroundColor:TAlphaColor read FBackgroundColor write SetBackgroundColor;
        property OneStepPorogressValue:single read FStepProgressValue write FStepProgressValue;
        property HighlightAnimation:boolean read FHighlightAnimation write SetHighlightAnimation;
        property OnClick:TNotifyEvent read FOnClick write FOnClick;
        property OnInteractiveProgressChange:TNotifyEvent read FOnInteractiveProgressChange write FOnInteractiveProgressChange;
        property OnProgressChange:TNotifyEvent read FOnProgressChange write FOnProgressChange;
        property OnBufferProgressChange:TNotifyEvent read FOnBufferProgressChange write FOnBufferProgressChange;
        property OnHintProgressRequest: TRequestHintEvent read FOnHintRequest write FOnHintRequest;
     end;
implementation

{ TYoutubeProgressbar }

constructor TYoutubeProgressbar.create(AOwner: TComponent);
var mm:TMouseEvent;
begin
inherited;
FBackgroundColor:=$FF676060;
FProgressColor:=$FFFC0D1B;
FBufferProgressColor:=$FFECECEC;
Parent:=TFmxObject(AOwner);
Height:=23;
Width:=360;
Frect:=TRectangle.Create(Self);
with Frect do begin
              Fill.Kind:=TBrushKind.None;
              Stroke.Thickness:=2;
              Stroke.Color:=TAlphaColorRec.Gainsboro;
              Align:=TAlignLayout.Client;
              Parent:=Self;
              HitTest:=false;
              end;
OnResize:=SelResizeHandler;
FLayout:=TLayout.Create(Self);
with FLayout do begin
                Margins.Top:=2;
                Margins.Bottom:=2;
                Margins.Left:=3;
                Margins.Right:=3;
                Align:=TAlignLayout.Contents;
                HitTest:=true;
                AutoCapture:=True;
                Parent:=Self;
                OnMouseMove:=MouseMoveHandler;
                OnMouseDown:=MouseDownHandler;
                OnMouseLeave:=MouseLeaveHandler;
                Cursor:=crHandPoint;
                end;
FCircle:=TCircle.Create(Self);
with FCircle do begin
                Fill.Color:=ProgressColor;
                HitTest:=false;
                Height:=0;
                Width:=0;
                Stroke.Kind:=TBrushKind.None;
                Position.X:=7;
                Position.Y:=9;
                Tag:=0;
                Parent:=FLayout;
                end;
FRoundRect:=TRoundRect.Create(Self);
with FRoundRect do begin
                   Align:=TAlignLayout.Contents;
                   Fill.Color:=FBackgroundColor;
                   HitTest:=false;
                   Margins.Top:=8;
                   Margins.Bottom:=8;
                   Margins.Left:=15;
                   Margins.Right:=15;
                   Stroke.Kind:=TBrushKind.None;
                   Parent:=Flayout;
                   FRoundRect.SendToBack;
                   end;
FBufferProgressbar:=TRoundRect.Create(FRoundRect);
with FBufferProgressbar do begin
                           Align:=TAlignLayout.FitLeft;
                           Fill.Color:=FBufferProgressColor;
                           Stroke.Kind:=TBrushKind.None;
                           Width:=0;
                           HitTest:=false;
                           Parent:=FRoundRect;
                           end;
FProgressbar:=TRoundRect.Create(FRoundRect);
with FProgressbar do begin
                     Align:=TAlignLayout.Left;
                     Fill.Color:=FProgressColor;
                     Stroke.Kind:=TBrushKind.None;
                     Width:=0;
                     HitTest:=false;
                     Parent:=FRoundRect;
                     end;
FHint:=TLabel.create(Self);
with FHint do begin
              Parent:=Self;
              StyledSettings:=[TStyledSetting.Family];
              Visible:=False;
              FHint.TextSettings.Font.Style:=TextSettings.Font.Style+[TFontStyle.fsbold];
              FHint.TextSettings.FontColor:=TAlphaColorRec.White;
              WordWrap:=false;
              AutoSize:=true;
              Position.y:=-15;
              Text:='';
              end;
FFocusCapter:= TButton.Create(Self);
FFocusCapter.Parent:=Self;
FFocusCapter.OnKeyDown:=FocusCapterHandler;
FFocusCapter.OnExit:=FocuserExit;
Fmin:=0;
Fmax:=1000;
FValue:=0;
FBufferValue:=0;
FFocused:=false;
Frect.Visible:=false;
FFocusCapter.Visible:=false;
FStepProgressValue:=10;
FOnClick:=nil;
FOnInteractiveProgressChange:=nil;
FOnProgressChange:=nil;
FHighlightAnimation:=true;
FHintText:='';
end;

procedure TYoutubeProgressbar.SetHighlightAnimation(Value: boolean);
begin
FHighlightAnimation:=Value;
if not Value then begin
                  FCircle.Height:=13;
                  FCircle.Width:=13;
                  FCircle.Fill.Color:=FProgressColor;
                  FRoundRect.Fill.Color:=FBackgroundColor;
                  FCircle.Position.Y:=3;
                  end;
end;

procedure TYoutubeProgressbar.SetFocus;
begin
FFocusCapter.SetFocus;
FFocused:=true;
Frect.Visible:=true;
end;

procedure TYoutubeProgressbar.SetHighlightedStyle;
begin
if FHighlightAnimation then
    begin
    FCircle.AnimateFloat(FCircle.Name+'.Width',13,DisplaySpeed);
    FCircle.AnimateFloat(FCircle.Name+'.Height',13,DisplaySpeed);
    FCircle.AnimateFloat(FCircle.Name+'.Position.X',FProgressbar.Width+8,DisplaySpeed);
    FCircle.AnimateFloat(FCircle.Name+'.Position.Y',3,DisplaySpeed);
    FRoundRect.Margins.Top:=7;
    FRoundRect.Margins.Bottom:=7;
    FBufferProgressbar.Width:=FBufferValue*(FRoundRect.Width/(FMax-FMin)); // Defete FitLeft Margin Effect
    end;
end;

procedure TYoutubeProgressbar.SetUnHighlightedStyle;
begin
if FHighlightAnimation then
    begin
    FCircle.AnimateFloat(FCircle.Name+'.Width',0,DisplaySpeed);
    FCircle.AnimateFloat(FCircle.Name+'.Height',0,DisplaySpeed);
    FCircle.AnimateFloat(FCircle.Name+'.Position.X',FProgressbar.Width+15,DisplaySpeed);
    FCircle.AnimateFloat(FCircle.Name+'.Position.Y',9,DisplaySpeed);
    FRoundRect.Margins.Top:=8;
    FRoundRect.Margins.Bottom:=8;
    FBufferProgressbar.Width:=FBufferValue*(FRoundRect.Width/(FMax-FMin)); // Defete FitLeft Margin Effect
    FHint.Visible:=false;
    end;
end;

procedure TYoutubeProgressbar.SetMax(value: single);
begin
if Value<Fmin then raise Exception.Create('Maximal value cannot be lower than the minimum one.')
else begin
     Fmax:=Value;
     SetBarProgress(Fvalue,0,false);
     SetBarProgress(FBufferValue,1,false);
     end;
end;

procedure TYoutubeProgressbar.SetMin(Value: single);
begin
if Value>Fmax then raise Exception.Create('Minimal value cannot be higher than the maximum one.')
else begin
     Fmin:=Value;
     SetBarProgress(Fvalue,0,false);
     SetBarProgress(FBufferValue,1,false);
     end;
end;

procedure TYoutubeProgressbar.SetProgressColor(Value: TAlphaColor);
begin
FProgressColor:=Value;
FProgressbar.Fill.Color:=value;
end;

procedure TYoutubeProgressbar.SetValue(value: single);
begin
SetBarProgress(value,0);
end;

procedure TYoutubeProgressbar.SetBufferValue(value: single);
begin
SetBarProgress(value,1);
end;

procedure TYoutubeProgressbar.SelResizeHandler(Sender: TObject);
begin
(Sender as  TLayout).Height:=23;
SetBarProgress(value,0,false);
SetBarProgress(BufferValue,1,false);
end;

procedure TYoutubeProgressbar.SetBackgroundColor(Value: TAlphaColor);
begin
FBackgroundColor:=Value;
FRoundRect.Fill.Color:=value;
end;

procedure TYoutubeProgressbar.SetBarProgress(wValue: single;indicator:byte=0;withEvent:boolean=true);
var xValue:single;
begin
if (wValue<FMin) then xValue:=FMin
else if (wValue>FMax) then xValue:=FMax
else xValue:=wValue;
if indicator=0 then begin
                    FValue:=xValue;
                    FProgressbar.Width:=xValue*(FRoundRect.Width/(FMax-FMin));
                    FCircle.Position.X:=FProgressbar.Width+7;
                    if withEvent and Assigned(FOnProgressChange) then FOnProgressChange(Self);
                    end
else begin
     fBufferValue:=xValue;
     FBufferProgressbar.Width:=xValue*(FRoundRect.Width/(FMax-FMin));
     if withEvent and Assigned(FOnBufferProgressChange) then FOnBufferProgressChange(Self);
     end;
Application.ProcessMessages;
end;

procedure TYoutubeProgressbar.SetBufferProgressColor(Value: TAlphaColor);
begin
FBufferProgressColor:=Value;
FBufferProgressbar.Fill.Color:=value;
end;

procedure TYoutubeProgressbar.FocusCapterHandler(Sender: TObject; var Key: Word;  var KeyChar: Char; Shift: TShiftState);
begin
case key of
vkLeft:OneStepBackward;
vkRight:OneStepForward;
end;
end;

procedure TYoutubeProgressbar.FocuserExit(Sender: TObject);
begin
Frect.Visible:=false;
FFocused:=false;
end;

function TYoutubeProgressbar.GetProgressAsPercentage(indicator: byte=0): Single;
begin
if indicator=0 then Result:=(FValue/(FMax-FMin))*100
else Result:=(FBufferValue/(FMax-FMin))*100
end;

procedure TYoutubeProgressbar.MouseDownHandler(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
FCircle.Tag:=1;
if not PtInRect(FCircle.ParentedRect,PointF(x,y))and(x>=15)and(x<=FLayout.Width-12)
 then begin
      SetBarProgress( (x-15)/ (FRoundRect.Width/(FMax-FMin)),0);
      if Assigned(FOnClick) then FOnClick(Self);
      if Assigned(FOnInteractiveProgressChange) then FOnInteractiveProgressChange(Self);
      end;
end;

procedure TYoutubeProgressbar.MouseLeaveHandler(Sender: TObject);
begin
SetUnHighlightedStyle;
SetBarProgress(0,1);
FHintText:='';
end;

procedure TYoutubeProgressbar.MouseMoveHandler(Sender: TObject; Shift: TShiftState; X,Y: Single);
begin
if(x>=15)and(x<=FLayout.Width-15) then begin
                                       FMousePositionRaliveProgress:=(x-15)/ (FRoundRect.Width/(FMax-FMin));
                                       Fhint.Position.x:=x-(Fhint.Width/2)+5;
                                       FHintText:=(Round(((x-15)/FRoundRect.Width)*1000)/1000).ToString;
                                       if Assigned(FOnHintRequest) then begin
                                                                       FOnHintRequest(Self,FHintText);
                                                                       FHint.Text:=FHintText;
                                                                       FHint.Visible:=true;
                                                                       end;
                                       SetBarProgress(FMousePositionRaliveProgress,1);
                                       if Assigned(FOnMouseMoveOverProgressbar) then FOnMouseMoveOverProgressbar(Self,FMousePositionRaliveProgress);
                                       if (ssLeft in Shift)and(FCircle.Tag=1)
                                        then begin
                                             SetBarProgress(FMousePositionRaliveProgress,0);
                                             if Assigned(FOnInteractiveProgressChange) then FOnInteractiveProgressChange(Self);
                                             end;
                                       end;
if (FRoundRect.Margins.Top<>7) then SetHighlightedStyle;

end;

procedure TYoutubeProgressbar.MouseUpHandler(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
FCircle.Tag:=0;
end;

procedure TYoutubeProgressbar.OneStepBackward;
begin
SetBarProgress(FValue-FStepProgressValue,0);
end;

procedure TYoutubeProgressbar.OneStepForward;
begin
SetBarProgress(FValue+FStepProgressValue,0);
end;

procedure TYoutubeProgressbar.Reset;
begin
Value:=0;
SetUnHighlightedStyle;
end;

end.
