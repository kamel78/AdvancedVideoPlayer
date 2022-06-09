unit AdvancedVideoPlayer;

interface

uses FMX.Layouts,YoutubeProgressBar,FMX.Types,FMX.StdCtrls,System.Classes,FMX.Objects,PasLibVlcUnit,FmxPasLibVlcPlayerUnit,
     FMX.MultiResBitmap,FMX.Graphics,System.UITypes,AdvancedVideoPlayerImages,FMX.Forms,System.sysutils,System.Syncobjs;

type

     TVLCEvent=procedure (Sender:TObject; EventName: String) of object;
     TConnectionLostEvent=procedure (Sender:TObject;var ContinuePlaying: boolean) of object;
     TCrackFmxPasLibVlcPlayer=class(TFmxPasLibVlcPlayer);
     TAdvanceVideoPlayer=class(Tlayout)
     private
     FCurrentTrack:string;
     FYouProgress,FSoundProgress:TYoutubeProgressbar;
     FParentLayout,FSoundLayout,
     FControlButtonLayout,FVideoControlLayout,
     FAnimationLayout: TLayout;
     FBackGroundRectangle,FPlayButton,
     FFullScreenButton,FSoundButton,FShadowRect: TRectangle;
     FArc1,FArc2:TArc;
     FTimeDisplayLabel: TLabel;
     FTimer,FAnimationTimer:TTimer;
     FFocuser:TButton;
     FWaitForConnectionClosePattern,FisChanging,
     FisLoaded,FIsTemporarilyStopped:boolean;
     FTimerIncrement:integer;
     FVLCDllPath:string;
     FVLCEvent:TVLCEvent;
     FConnectionClosed:TConnectionLostEvent;
     Fduration:int64;
     FPlayThread:TThread;
     FOnExit,FOnError:TNotifyEvent;
     procedure PlayPausHandler;
     procedure PlayButtonClick(Sender: TObject);
     procedure SoundButtonMouseEnter(Sender: TObject);
     procedure Layout3MouseLeave(Sender: TObject);
     procedure SoundButtonClick(Sender: TObject);
     procedure SoundProgressChange(Sender:TObject);
     procedure SoundProgressMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
     procedure FullScreenButtonClick(Sender: TObject);
     procedure HintHandler(Sender: TObject;var HintText:string);
     procedure DisplayVideoProgress;
     procedure InteractiveChangeHandler(Sender: TObject);
     procedure FmxPasLibVlcPlayer1MediaPlayerPositionChanged(Sender: TObject;position: Single);
     procedure FmxPasLibVlcPlayer1MouseMove(Sender: TObject; Shift: TShiftState;X, Y: Single);
     procedure FmxPasLibVlcPlayer1MouseLeave(Sender: TObject);
     procedure TimerHandler(Sender:TObject);
     procedure FmxPasLibVlcPlayer1Click(Sender: TObject);
     procedure FocuserHandler(Sender: TObject; var Key: Word;var KeyChar: Char; Shift: TShiftState);
     procedure StartVidoPanelShow;
     procedure SetVLCPath(value:string);
     procedure WaitAnimationHandler(Sender:TObject);
     procedure SetVLCEvent(value:TVLCEvent);
     procedure VLCEventHandler(p_event: libvlc_event_t_ptr; data: Pointer);
     procedure VideoErrorHandler(Sender:TObject);
     procedure ResetPlayer;
     function GetLastError:string;
     public
     FVideoSurface: TFmxPasLibVlcPlayer;
     constructor Create(AOwner: TComponent); override;
     destructor destroy;override;
     Procedure LoadVideo(filename:string);
     procedure StopVideo;
     procedure SetFocus;reintroduce;
     property VLCdllPath:string read FVLCDllPath write SetVLCPath;
     property OnVLCEvent:TVLCEvent read FVLCEvent write SetVLCEvent;
     property OnConnectionLost:TConnectionLostEvent read FConnectionClosed write FConnectionClosed;
     property OnExit:TNotifyEvent read FOnExit write FOnExit;
     property OnError:TNotifyEvent read FOnError write FOnError;
     property LastError:string read GetLastError;
     end;

     procedure HexStringToImage(const HexStr: string;Dest:TBrushBitmap);

implementation
uses FMX.Dialogs;

function VLCEventToString(val:libvlc_event_type_t):string;
begin
case Val  of
libvlc_MediaMetaChanged:Result:='libvlc_MediaMetaChanged';
libvlc_MediaSubItemAdded:Result:='libvlc_MediaSubItemAdded';
libvlc_MediaDurationChanged:Result:='libvlc_MediaDurationChanged';
libvlc_MediaParsedChanged:Result:='libvlc_MediaParsedChanged';
libvlc_MediaFreed:Result:='libvlc_MediaFreed';
libvlc_MediaStateChanged:Result:='libvlc_MediaStateChanged';
libvlc_MediaSubItemTreeAdded:Result:='libvlc_MediaSubItemTreeAdded';
libvlc_MediaPlayerMediaChanged:Result:='libvlc_MediaPlayerMediaChanged';
libvlc_MediaPlayerNothingSpecial:Result:='libvlc_MediaPlayerNothingSpecial';
libvlc_MediaPlayerOpening:Result:='libvlc_MediaPlayerOpening';
libvlc_MediaPlayerBuffering:Result:='libvlc_MediaPlayerBuffering';
libvlc_MediaPlayerPlaying:Result:='libvlc_MediaPlayerPlaying';
libvlc_MediaPlayerPaused:Result:='libvlc_MediaPlayerPaused';
libvlc_MediaPlayerStopped:Result:='libvlc_MediaPlayerStopped';
libvlc_MediaPlayerForward:Result:='libvlc_MediaPlayerForward';
libvlc_MediaPlayerBackward:Result:='libvlc_MediaPlayerBackward';
libvlc_MediaPlayerEndReached:Result:='libvlc_MediaPlayerEndReached';
libvlc_MediaPlayerEncounteredError:Result:='libvlc_MediaPlayerEncounteredError';
libvlc_MediaPlayerTimeChanged:Result:='libvlc_MediaPlayerTimeChanged';
libvlc_MediaPlayerPositionChanged:Result:='libvlc_MediaPlayerPositionChanged';
libvlc_MediaPlayerSeekableChanged:Result:='libvlc_MediaPlayerSeekableChanged';
libvlc_MediaPlayerPausableChanged:Result:='libvlc_MediaPlayerPausableChanged';
libvlc_MediaPlayerTitleChanged:Result:='libvlc_MediaPlayerTitleChanged';
libvlc_MediaPlayerSnapshotTaken:Result:='libvlc_MediaPlayerSnapshotTaken';
libvlc_MediaPlayerLengthChanged:Result:='libvlc_MediaPlayerLengthChanged';
libvlc_MediaPlayerVout:Result:='libvlc_MediaPlayerVout';
libvlc_MediaPlayerScrambledChanged:Result:='libvlc_MediaPlayerScrambledChanged';
libvlc_MediaPlayerESAdded:Result:='libvlc_MediaPlayerESAdded';
libvlc_MediaPlayerESDeleted:Result:='libvlc_MediaPlayerESDeleted';
libvlc_MediaPlayerESSelected:Result:='libvlc_MediaPlayerESSelected';
libvlc_MediaPlayerCorked:Result:='libvlc_MediaPlayerCorked';
libvlc_MediaPlayerUncorked:Result:='libvlc_MediaPlayerUncorked';
libvlc_MediaPlayerMuted:Result:='libvlc_MediaPlayerMuted';
libvlc_MediaPlayerUnmuted:Result:='libvlc_MediaPlayerUnmuted';
libvlc_MediaPlayerAudioVolume:Result:='libvlc_MediaPlayerAudioVolume';
libvlc_MediaPlayerAudioDevice:Result:='libvlc_MediaPlayerAudioDevice';
libvlc_MediaPlayerChapterChanged:Result:='libvlc_MediaPlayerChapterChanged';
libvlc_MediaListItemAdded:Result:='libvlc_MediaListItemAdded';
libvlc_MediaListWillAddItem:Result:='libvlc_MediaListWillAddItem';
libvlc_MediaListItemDeleted:Result:='libvlc_MediaListItemDeleted';
libvlc_MediaListWillDeleteItem:Result:='libvlc_MediaListWillDeleteItem';
libvlc_MediaListEndReached:Result:='libvlc_MediaListEndReached';
libvlc_MediaListViewItemAdded:Result:='libvlc_MediaListViewItemAdded';
libvlc_MediaListViewWillAddItem:Result:='libvlc_MediaListViewWillAddItem';
libvlc_MediaListViewItemDeleted:Result:='libvlc_MediaListViewItemDeleted';
libvlc_MediaListViewWillDeleteItem:Result:='libvlc_MediaListViewWillDeleteItem';
libvlc_MediaListPlayerPlayed:Result:='libvlc_MediaListPlayerPlayed';
libvlc_MediaListPlayerNextItemSet:Result:='libvlc_MediaListPlayerNextItemSet';
libvlc_MediaListPlayerStopped:Result:='libvlc_MediaListPlayerStopped';
libvlc_MediaDiscovererStarted:Result:='libvlc_MediaDiscovererStarted';
libvlc_MediaDiscovererEnded:Result:='libvlc_MediaDiscovererEnded';
libvlc_RendererDiscovererItemAdded:Result:='libvlc_RendererDiscovererItemAdded';
libvlc_RendererDiscovererItemDeleted:Result:='libvlc_RendererDiscovererItemDeleted';
libvlc_VlmMediaAdded:Result:='libvlc_VlmMediaAdded';
libvlc_VlmMediaRemoved:Result:='libvlc_VlmMediaRemoved';
libvlc_VlmMediaChanged:Result:='libvlc_VlmMediaChanged';
libvlc_VlmMediaInstanceStarted:Result:='libvlc_VlmMediaInstanceStarted';
libvlc_VlmMediaInstanceStopped:Result:='libvlc_VlmMediaInstanceStopped';
libvlc_VlmMediaInstanceStatusInit:Result:='libvlc_VlmMediaInstanceStatusInit';
libvlc_VlmMediaInstanceStatusOpening:Result:='libvlc_VlmMediaInstanceStatusOpening';
libvlc_VlmMediaInstanceStatusPlaying:Result:='libvlc_VlmMediaInstanceStatusPlaying';
libvlc_VlmMediaInstanceStatusPause:Result:='libvlc_VlmMediaInstanceStatusPause';
libvlc_VlmMediaInstanceStatusEnd:Result:='libvlc_VlmMediaInstanceStatusEnd';
libvlc_VlmMediaInstanceStatusError:Result:='libvlc_VlmMediaInstanceStatusError';
end;
end;


{ TAdvanceVideoPlayer }

procedure TAdvanceVideoPlayer.PlayPausHandler;
begin
if (not FisLoaded) then exit;
if FPlayButton.Tag=0 then begin
                          HexStringToImage(PauseImage,FPlayButton.Fill.Bitmap);
                          FPlayButton.Tag:=1;
                          FVideoSurface.Resume;
                          end
else begin
     HexStringToImage(PlayImage,FPlayButton.Fill.Bitmap);
     FPlayButton.Tag:=0;
     FVideoSurface.Pause;
     end;
end;

procedure HexStringToBitmap(const HexStr: string;Dest:TBitmap);
var BinaryStream: TMemoryStream;
begin
BinaryStream := TMemoryStream.Create;
  try
    BinaryStream.Size := Length(HexStr) div 2;
    if BinaryStream.Size > 0 then
    begin
      HexToBin(PChar(HexStr), BinaryStream.Memory, BinaryStream.Size);
      try
        Dest.LoadFromStream(BinaryStream);
        except
      end;
    end;
  finally
    BinaryStream.Free;
  end;
end;

procedure HexStringToImage(const HexStr: string;Dest:TBrushBitmap);
var BinaryStream: TMemoryStream;
begin
BinaryStream := TMemoryStream.Create;
  try
    BinaryStream.Size := Length(HexStr) div 2;
    if BinaryStream.Size > 0 then
    begin
      HexToBin(PChar(HexStr), BinaryStream.Memory, BinaryStream.Size);
      try
        Dest.Bitmap.LoadFromStream(BinaryStream);
        except
      end;
    end;
  finally
    BinaryStream.Free;
  end;
end;


constructor TAdvanceVideoPlayer.Create(AOwner: TComponent);
begin
inherited;
Parent:=TFmxObject(AOwner);
FParentLayout:=TLayout.Create(Self);
with FParentLayout do begin
                Parent:=Self;
                Align:=TAlignLayout.Contents;
                HitTest:=false;
                end;
FVideoSurface:=TFmxPasLibVlcPlayer.Create(FParentLayout);
with FVideoSurface do begin
                      Parent:=FParentLayout;
                      WrapMode:=TImageWrapMode.Stretch;
                      Align:=TAlignLayout.Contents;
                   //   HexStringToMultiResImage(BlackImage,MultiResBitmap);
                      HitTest:=true;
                      end;
FBackGroundRectangle:=TRectangle.Create(Self);
with FBackGroundRectangle do begin
                    Parent:=Self;
                    Align:=TAlignLayout.Contents;
                    Stroke.Kind:=TBrushKind.None;
                    Fill.Color:=TalphacolorRec.Black;
                    HitTest:=True;
                    SendToBack;
                    end;
FVideoControlLayout:=TLayout.Create(FParentLayout);
with FVideoControlLayout do begin
                            Parent:=FParentLayout;
                            Align:=TAlignLayout.Bottom;
                            HitTest:=false;
                            Height:=70;
                            BringToFront;
                            end;
FControlButtonLayout:=TLayout.Create(FVideoControlLayout);
with FControlButtonLayout do begin
                 Parent:=FVideoControlLayout;
                 Align:=TAlignLayout.Bottom;
                 HitTest:=True;
                 Height:=47;
                 end;
FShadowRect:=TRectangle.Create(FVideoControlLayout);
with FShadowRect do begin
                    parent:=FVideoControlLayout;
                    HitTest:=false;
                    Align:=TAlignLayout.Contents;
                    Stroke.Kind:=TBrushKind.None;
                    Fill.Kind:=TBrushKind.Gradient;
                    Fill.Gradient.RadialTransform.RotationAngle:=-90;
                    Opacity:=0.3;
                    SendToBack;
                    end;
FSoundLayout:=TLayout.Create(FControlButtonLayout);
with FSoundLayout do begin
                     Parent:=FControlButtonLayout;
                     Align:=TAlignLayout.Left;
                     Width:=5;
                     end;

FTimeDisplayLabel:=TLabel.Create(FControlButtonLayout);
with FTimeDisplayLabel do begin
                Parent:=FControlButtonLayout;
                Align:=TAlignLayout.Left;
                StyledSettings := [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style];
                Margins.Left := 5;
                Margins.Bottom := 16;
                Position.X := 90;
                Size.Width := 104;
                Size.Height := 31;
                TextSettings.FontColor := TAlphaColorRec.White;
                Text := '-- / --';
                end;
FPlayButton:=TRectangle.Create(FControlButtonLayout);
with FPlayButton do begin
                    Parent:=FControlButtonLayout;
                    Align:=TAlignLayout.Left;
                    Cursor:=crHandPoint;
                    Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
                    Fill.Kind := TBrushKind.Bitmap;
                    Margins.Left := 20;
                    Margins.Top := 1;
                    Margins.Bottom := 16;
                    Size.Width := 30;
                    Size.Height := 30;
                    Stroke.Kind := TBrushKind.None;
                    TabOrder:=0;
                    HexStringToImage(PlayImage, Fill.Bitmap);
                    OnClick:=PlayButtonClick;
                    end;
FSoundButton:=TRectangle.Create(FControlButtonLayout);
with FSoundButton do begin
                     Parent:=FControlButtonLayout;
                     Align:=TAlignLayout.Left;
                     Cursor:=crHandPoint;
                     Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
                     Fill.Kind := TBrushKind.Bitmap;
                     Margins.Left := 10;
                     Margins.Top := 6;
                     Margins.Bottom := 20;
                     Position.X := 60;
                     Position.Y := 6;
                     Size.Width := 20;
                     Size.Height := 21;
                     Stroke.Kind := TBrushKind.None;
                     HexStringToImage(SoundImage, Fill.Bitmap);
                     OnMouseEnter:=SoundButtonMouseEnter;
                     OnClick:=SoundButtonClick;
                     end;
FFullScreenButton:=TRectangle.Create(FControlButtonLayout);
with FFullScreenButton do begin
                          Parent:=FControlButtonLayout;
                          Align:=TAlignLayout.Right;
                          Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
                          Fill.Kind := TBrushKind.Bitmap;
                          Cursor:=crHandPoint;
                          Margins.Top := 1;
                          Margins.Right := 20;
                          Margins.Bottom := 16;
                          Position.X := 583;
                          Position.Y := 1;
                          Size.Width := 30;
                          Size.Height := 30;
                          Stroke.Kind := TBrushKind.None;
                          HexStringToImage(FullScreenImage,Fill.Bitmap);
                          OnClick:=FullScreenButtonClick;
                          end;
FYouProgress:=TYoutubeProgressbar.create(FVideoControlLayout);
FYouProgress.OnInteractiveProgressChange:=InteractiveChangeHandler;
FYouProgress.Align:=TAlignLayout.Top;
FVideoSurface.VLC.Path:={$IFDEF CPUX64}'c:\VLCDll\64Bit'{$ELSE}'c:\VLCDll\32Bit'{$ENDIF};
FSoundProgress:=TYoutubeProgressbar.create(FSoundLayout);
with FSoundProgress do begin
                       FSoundProgress.Margins.Bottom:=6;
                       FSoundProgress.Margins.Top:=4;
                       FSoundProgress.Align:=TAlignLayout.Client;
                       FSoundProgress.ProgressColor:=TAlphaColorRec.White;
                       FSoundProgress.BackgroundColor:=$FF676060;
                       FSoundProgress.HighlightAnimation:=false;
                       FSoundProgress.Value:=FSoundProgress.Max;
                       FSoundProgress.OnProgressChange:=SoundProgressChange;
                       FSoundProgress.OnMouseUp:=SoundProgressMouseUp;
                       end;
FAnimationLayout:=TLayout.Create(Self);
with FAnimationLayout do begin
                         Parent:=Self;
                         Align:=TAlignLayout.Center;
                         Width:=80;
                         Height:=80;
                         HitTest:=False;
                         BringToFront;
                         Visible:=false;
                         end;
FArc1:=TArc.Create(FAnimationLayout);
with FArc1 do begin
              Parent:=FAnimationLayout;
              Align:=TAlignLayout.Center;
              Fill.Kind:=TBrushKind.None;
              Width:=60;
              Height:=60;
              Stroke.Kind:=TBrushKind.Gradient;
              Stroke.Gradient.Points[0].Color:=TAlphaColorRec.Black;
              Stroke.Gradient.Points[0].Offset:=0;
              Stroke.Gradient.Points[1].Color:=TAlphaColorRec.White;
              Stroke.Gradient.Points[1].Offset:=1;
              Stroke.Gradient.StartPosition.X := 0.5;
              Stroke.Gradient.StartPosition.Y := 1.0;
              Stroke.Gradient.StopPosition.X := 0.499999970197677600;
              Stroke.Gradient.StopPosition.Y := 0;
              Stroke.Thickness := 6.0;
              Stroke.Join := TStrokeJoin.Bevel;
              EndAngle:=180;
              StartAngle:=0;
              end;
FArc2:=TArc.Create(FArc1);
with FArc2 do begin
              Parent:=FArc1;
              Align:=TAlignLayout.Client;
              Fill.Kind:=TBrushKind.None;
              Stroke.Gradient.StartPosition.X := 0.5;
              Stroke.Gradient.StartPosition.Y := 1.0;
              Stroke.Gradient.StopPosition.X := 0.5;
              Stroke.Gradient.StopPosition.Y := 0;
              Stroke.Thickness := 6.0;
              Stroke.Join := TStrokeJoin.Bevel;
              Stroke.Kind:=TBrushKind.Gradient;
              Stroke.Gradient.Points[0].Color:=TAlphaColorRec.Black;
              Stroke.Gradient.Points[0].Offset:=0;
              Stroke.Gradient.Points[1].Color:=TAlphaColorRec.White;
              Stroke.Gradient.Points[1].Offset:=1;
              EndAngle:=360;
              StartAngle:=0;
              end;
FAnimationTimer:=TTimer.Create(Self);
FAnimationTimer.Interval:=50;
FAnimationTimer.Enabled:=false;
FAnimationTimer.OnTimer:=WaitAnimationHandler;
FisChanging:=false;
FisLoaded:=False;
FVideoControlLayout.Visible:=false;
FPlayButton.Enabled:=false;
FFullScreenButton.Enabled:=false;
FSoundButton.Enabled:=false;
FVideoControlLayout.Enabled:=false;
Ftimer:=TTimer.Create(Self);
FTimer.Enabled:=false;
Ftimer.Interval:=1000;
FTimerIncrement:=5;
FTimer.OnTimer:=TimerHandler;
FFocuser:=TButton.Create(Self);
FFocuser.Parent:=Self;
FFocuser.Visible:=false;
FFocuser.OnKeyDown:=FocuserHandler;
FYouProgress.OnHintProgressRequest:=HintHandler;
FVideoSurface.OnMediaPlayerPositionChanged:=FmxPasLibVlcPlayer1MediaPlayerPositionChanged;
FVideoSurface.OnMouseMove:=FmxPasLibVlcPlayer1MouseMove;
FVideoSurface.OnMouseLeave:=FmxPasLibVlcPlayer1MouseLeave;
FVideoSurface.OnClick:=FmxPasLibVlcPlayer1Click;
FVideoSurface.OnMediaPlayerEvent:=VLCEventHandler;
FVideoSurface.OnMediaPlayerEncounteredError:=VideoErrorHandler;
//Rearange components that are all left aligner
FSoundButton.Position.X:=0;
FPlayButton.Position.X:=0;
FSoundLayout.Position.X:=60;
FIsTemporarilyStopped:=False;
FWaitForConnectionClosePattern:=false;
end;

destructor TAdvanceVideoPlayer.destroy;
begin
if FVideoSurface.IsPlay then begin
                             //FPlayThread.Terminate;
                             FPlayThread.Free;
                             StopVideo;
                             FVideoSurface.Free;
                             end;
inherited;
end;

procedure TAdvanceVideoPlayer.DisplayVideoProgress;
var pos:int64;
    durationmask,positionmask:string;
begin
if not FisLoaded then begin
                      Fduration:=FVideoSurface.GetVideoLenInMs;
                      FYouProgress.Min:=0;
                      FYouProgress.Max:=FDuration;
                      FisLoaded:=true;
                      FPlayButton.Enabled:=True;
                      FFullScreenButton.Enabled:=True;
                      FSoundButton.Enabled:=True;
                      FVideoControlLayout.Enabled:=True;
                      HexStringToImage(PauseImage,FPlayButton.Fill.Bitmap);
                      FPlayButton.Tag:=1;
                      FFocuser.SetFocus;
                      FYouProgress.OneStepPorogressValue:=5000; // 5 Mellisecode
                      FAnimationTimer.Enabled:=false;
                      FAnimationLayout.Visible:=false;
                      end;
if Self.Visible then begin
                     pos:=FVideoSurface.GetVideoPosInMs;
                     if Fduration<3600000 then durationmask:='mm:ss' else durationmask:='hh:mm:ss';
                     if pos<3600000 then positionmask:='mm:ss' else positionmask:='hh:mm:ss';
                     FYouProgress.Value:=pos;
                     FTimeDisplayLabel.Text:=time2str(Pos,positionmask)+' / '+time2str(Round(FYouProgress.Max),durationmask);
                     end;
end;

procedure TAdvanceVideoPlayer.FmxPasLibVlcPlayer1Click(Sender: TObject);
begin
if not FVideoControlLayout.PointInObject(TForm(Owner).ScreenToClient(Screen.MousePos).X,TForm(Owner).ScreenToClient(Screen.MousePos).y) then
PlayPausHandler;
end;

procedure TAdvanceVideoPlayer.FmxPasLibVlcPlayer1MediaPlayerPositionChanged(
  Sender: TObject; position: Single);
begin
DisplayVideoProgress;
end;

procedure TAdvanceVideoPlayer.FmxPasLibVlcPlayer1MouseLeave(Sender: TObject);
begin
if not FVideoSurface.PointInObject(TForm(Owner).ScreenToClient(Screen.MousePos).X,TForm(Owner).ScreenToClient(Screen.MousePos).y) then
FVideoControlLayout.Visible:=false;
end;

procedure TAdvanceVideoPlayer.FmxPasLibVlcPlayer1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
StartVidoPanelShow;
end;

procedure TAdvanceVideoPlayer.FocuserHandler(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
if key=vkBack then begin
                   StopVideo;
                   Application.ProcessMessages;
                   if Assigned(FOnExit) then FOnExit(Self);
                   end;

if not FisLoaded then exit;
case key of
vkLeft:begin
       FYouProgress.OneStepBackward;
       StartVidoPanelShow;
       InteractiveChangeHandler(Self);
       end;
vkRight:begin
        FYouProgress.OneStepForward;
        StartVidoPanelShow;
        InteractiveChangeHandler(Self);
        end;
vkPause :begin
         StartVidoPanelShow;
         PlayPausHandler;
         end;
0: begin
   if KeyChar=chr(32) then begin
                           StartVidoPanelShow;
                           PlayPausHandler;
                           end;
   end;
end;
end;

procedure TAdvanceVideoPlayer.FullScreenButtonClick(Sender: TObject);
var Restart:boolean;
begin
Restart:=FVideoSurface.IsPlay;
if Restart then FVideoSurface.Pause;
if FFullScreenButton.Tag=0 then begin
                            HexStringToImage(NormalScreenImage,FFullScreenButton.Fill.Bitmap);
                            FFullScreenButton.Tag:=1;
                            TForm(Owner).FullScreen:=true;
                            FParentLayout.Parent:=TFmxObject(Owner);
                            end
else begin
     HexStringToImage(FullScreenImage,FFullScreenButton.Fill.Bitmap);
     FFullScreenButton.Tag:=0;
     Tform(Owner).FullScreen:=false;
     FParentLayout.Parent:=Self;
     end;
if Restart then FVideoSurface.Resume;
end;

function TAdvanceVideoPlayer.GetLastError: string;
begin
Result:=FVideoSurface.LastError;
end;

procedure TAdvanceVideoPlayer.HintHandler(Sender: TObject;
  var HintText: string);
var pos:int64;
    positionmask:string;
begin
pos:=Round(FYouProgress.MousePositionProgress);
if pos<3600000 then positionmask:='mm:ss' else positionmask:='hh:mm:ss';
HintText:=time2str(pos,positionmask);
end;

procedure TAdvanceVideoPlayer.InteractiveChangeHandler(Sender: TObject);
var pos:int64;
begin
if FisChanging then exit;
FisChanging:=True;
pos:=Round(FYouProgress.Value);
FVideoSurface.SetVideoPosInMs(pos);
FisChanging:=false;
end;

procedure TAdvanceVideoPlayer.Layout3MouseLeave(Sender: TObject);
begin
if not FControlButtonLayout.PointInObject(Tform(Owner).ScreenToClient(Screen.MousePos).X,Tform(Owner).ScreenToClient(Screen.MousePos).y) then
      begin
      FSoundLayout.AnimateFloat('SoundLayout.Width',5,DisplaySpeed);
      FSoundProgress.Visible:=False;
      end;
if not FVideoSurface.PointInObject(Tform(Owner).ScreenToClient(Screen.MousePos).X,Tform(Owner).ScreenToClient(Screen.MousePos).y) then FVideoControlLayout.Visible:=false;
end;

procedure TAdvanceVideoPlayer.LoadVideo(filename: string);
begin
FPlayThread:= TThread.CreateAnonymousThread(procedure begin
                                        FCurrentTrack:=filename;
                                        FVideoSurface.Play(FileName);
                                        end);
FPlayThread.Start;
FSoundProgress.Value:=FSoundProgress.Max/2;
FVideoSurface.SetAudioMute(False);
FVideoSurface.SetAudioVolume(100);
end;

procedure TAdvanceVideoPlayer.PlayButtonClick(Sender: TObject);
begin
PlayPausHandler;
end;

procedure TAdvanceVideoPlayer.SetFocus;
begin
FFocuser.SetFocus;
end;

procedure TAdvanceVideoPlayer.SetVLCEvent(value: TVLCEvent);
begin
FVLCEvent:=Value;
end;

procedure TAdvanceVideoPlayer.SetVLCPath(value: string);
begin
FVideoSurface.VLC.Path:=Value;
FVLCDllPath:=Value;
end;

procedure TAdvanceVideoPlayer.SoundButtonClick(Sender: TObject);
begin
if FSoundButton.Tag=0 then begin
                           HexStringToImage(MuteImage,FSoundButton.Fill.Bitmap);
                           FSoundButton.Tag:=1;
                           FSoundProgress.Value:=0;
                           FVideoSurface.SetAudioMute(True);
                           end
else begin
     HexStringToImage(SoundImage,FSoundButton.Fill.Bitmap);
     FSoundButton.Tag:=0;
     FSoundProgress.Value:=FSoundProgress.Max/2;
     FVideoSurface.SetAudioMute(False);
     FVideoSurface.SetAudioVolume(100);
     end;
end;

procedure TAdvanceVideoPlayer.SoundButtonMouseEnter(Sender: TObject);
begin
if FSoundLayout.Width=5 then begin
                             FSoundLayout.AnimateFloat('SoundLayout.Width',100,DisplaySpeed);
                             FSoundProgress.Visible:=True;
                             end;
end;

procedure TAdvanceVideoPlayer.SoundProgressChange(Sender: TObject);
var wProgress:byte;
begin
if FSoundProgress.Value=0 then begin
                               HexStringToImage(MuteImage,FSoundButton.Fill.Bitmap);
                               FSoundButton.Tag:=1;
                               end
else begin
     //HexStringToImage(SoundImage,FSoundButton.Fill.Bitmap);
     FSoundButton.Tag:=0;
     wProgress:=Round(FSoundProgress.GetProgressAsPercentage);
     TThread.Synchronize(nil,procedure begin
     FVideoSurface.SetAudioVolume(50);end);
     end;
end;

procedure TAdvanceVideoPlayer.SoundProgressMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin

end;

procedure TAdvanceVideoPlayer.StartVidoPanelShow;
begin
if not FVideoControlLayout.Visible then begin
                                        FVideoControlLayout.Visible:=true;
                                        FYouProgress.Visible:=True;
                                        FTimerIncrement:=5;
                                        if not FTimer.Enabled then FTimer.Enabled:=true;
                                        end;
end;

procedure TAdvanceVideoPlayer.StopVideo;
begin
FVideoSurface.Stop;
FYouProgress.Value:=0;
FTimeDisplayLabel.Text := '-- / --';
FAnimationLayout.Visible:=False;
FAnimationTimer.Enabled:=False;
end;

procedure TAdvanceVideoPlayer.TimerHandler(Sender: TObject);
begin
Dec(FTimerIncrement);
if FTimerIncrement=0 then begin
                          FVideoControlLayout.Visible:=false;
                          FYouProgress.Visible:=false;
                          FTimer.Enabled:=false;
                          end;
end;

procedure TAdvanceVideoPlayer.VideoErrorHandler(Sender: TObject);
begin
if Assigned(FOnError) then begin
                           TThread.Synchronize(nil,procedure begin
                           FOnError(Sender);
                           end);
                           end;
end;


procedure TAdvanceVideoPlayer.ResetPlayer;
begin
repeat Application.ProcessMessages; until not FVideoSurface.IsPlay;
FisChanging:=false;
FisLoaded:=False;
FVideoControlLayout.Visible:=false;
FPlayButton.Enabled:=false;
FFullScreenButton.Enabled:=false;
FSoundButton.Enabled:=false;
FVideoControlLayout.Enabled:=false;
FTimer.Enabled:=false;
FFocuser.Visible:=false;
FYouProgress.Value:=0;
FYouProgress.Reset;
with TCrackFmxPasLibVlcPlayer(FVideoSurface) do DestroyPlayer;
Timage(FVideoSurface).Bitmap.Clear(TAlphaColorRec.Black);
FTimeDisplayLabel.Text := '-- / --';
end;

procedure TAdvanceVideoPlayer.VLCEventHandler(p_event: libvlc_event_t_ptr;  data: Pointer);
var currentpos:int64;
    continueplaying:boolean;
    starttime:string;
begin
if FWaitForConnectionClosePattern then  begin
                                        if p_event.event_type=libvlc_MediaPlayerStopped
                                        then begin
                                             FWaitForConnectionClosePattern:=false;
                                             TThread.Synchronize(nil,procedure begin
                                                  FAnimationLayout.Visible:=true;
                                                  FAnimationTimer.Enabled:=true;
                                                  continueplaying:=false;
                                                  FisLoaded:=false;
                                                  if Assigned(FConnectionClosed) then FConnectionClosed(Self,continueplaying);
                                                  if continueplaying then begin
                                                                          FAnimationLayout.Visible:=False;
                                                                          FAnimationTimer.Enabled:=False;
                                                                          FVideoSurface.Stop;
                                                                          Application.ProcessMessages;
                                                                          starttime:=Round(FYouProgress.Value/1000).ToString+'.0';
                                                                          TThread.CreateAnonymousThread(procedure begin
                                                                          FVideoSurface.PlayNormal(FCurrentTrack,['start-time='+starttime]);
                                                                          end).Start;
                                                                          end
                                                  else StopVideo;
                                                  end);
                                             end
                                        else exit;
                                        end;
 if p_event.event_type=libvlc_MediaPlayerBuffering then
                            begin
                            FIsTemporarilyStopped:=true;
                            TThread.Synchronize(nil,procedure begin
                                    FAnimationLayout.Visible:=true;
                                    FAnimationTimer.Enabled:=true;
                                    end);
                            end;
if (p_event.event_type=libvlc_MediaPlayerPositionChanged)and
    FIsTemporarilyStopped then begin
                               FIsTemporarilyStopped:=False;
                               TThread.Synchronize(nil,procedure begin
                                                 FAnimationLayout.Visible:=False;
                                                 FAnimationTimer.Enabled:=False;
                                                 end);
                               end;
if (p_event.event_type=libvlc_MediaPlayerEndReached) then begin
                               currentpos:=Round(FYouProgress.Value);
                               if ((Fduration-currentpos)>1000) then
                                    begin
                                    if(Assigned(FConnectionClosed) ) then FWaitForConnectionClosePattern:=true;
                                    end;
                               end;
if (p_event.event_type=libvlc_MediaPlayerStopped) then begin
                                                       TThread.CreateAnonymousThread(procedure begin resetPlayer;end).Start;
                                                       end;
if Assigned(FVLCEvent) then TThread.Synchronize(nil,procedure begin FVLCEvent(Self,VLCEventToString(p_event.event_type));end);
end;

procedure TAdvanceVideoPlayer.WaitAnimationHandler(Sender: TObject);
begin
FArc2.RotationAngle:=FArc2.RotationAngle+10;
Application.ProcessMessages;
end;

end.

