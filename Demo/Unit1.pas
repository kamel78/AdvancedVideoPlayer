unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,AdvancedVideoPlayer,
  FMX.Layouts, FMX.Edit, FMX.ScrollBox, FMX.Memo;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button3: TButton;
    Edit1: TEdit;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    farc1,FArc2:TArc;
    procedure VLCEventH(Sender:TObject; EventName: String);
    procedure ConnectionLostHandler(Sender:TObject;var ContinuePlaying: boolean);
    procedure OnErrorHandler(Sender: TObject);
  end;

var
  Form1: TForm1;
  Player:TAdvanceVideoPlayer;

implementation
{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
Player.LoadVideo(Edit1.Text);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
Player.LoadVideo(Edit2.Text);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
if (Sender as TButton).Tag=0 then begin
                                  (Sender as TButton).Text:='Hide VLC Debug Output';
                                  (Sender as TButton).Tag:=1;
                                  Memo1.Visible:=True;
                                  Panel2.Height:=240;
                                  ClientHeight:=640;
                                  end
else begin
     (Sender as TButton).Text:='Show VLC Debug Output';
     (Sender as TButton).Tag:=0;
     Memo1.Visible:=False;
     Panel2.Height:=126;
     ClientHeight:=526;
     end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
if OpenDialog1.Execute then Edit1.Text:=OpenDialog1.FileName;
end;

procedure TForm1.ConnectionLostHandler(Sender:TObject;var ContinuePlaying: boolean);
begin
Showmessage('Connection Lost');
ContinuePlaying:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
Player:=TAdvanceVideoPlayer.Create(Self);
//Player.VLCdllPath:={$IFDEF CPUX64}'c:\VLCDll\64Bit'{$ELSE}'c:\VLCDll\32Bit'{$ENDIF};
Player.Align:=TAlignLayout.MostTop;
Player.Height:=400;
Player.OnVLCEvent:=VLCEventH;
Player.OnConnectionLost:=ConnectionLostHandler;
Player.OnError:=OnErrorHandler;
Edit1.Text:=ExtractFilePath(ParamStr(0))+'Sample-Videos-Mp425.mp4';
end;


procedure TForm1.OnErrorHandler(Sender: TObject);
begin
Showmessage(Player.LastError);
end;

procedure TForm1.VLCEventH(Sender: TObject; EventName: String);
begin
Memo1.Lines.Add(EventName);
Memo1.GoToTextEnd;
end;

end.
