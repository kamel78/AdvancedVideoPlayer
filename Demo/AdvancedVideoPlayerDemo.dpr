﻿(*
 *******************************************************************************
 *
 * Copyright (c) 2020 Robert Jędrzejczyk
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 *******************************************************************************
 *)

{$I ..\PasVLC\compiler.inc}

program AdvancedVideoPlayerDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  PasLibVlcClassUnit in '..\PasVLC\PasLibVlcClassUnit.pas',
  PasLibVlcUnit in '..\PasVLC\PasLibVlcUnit.pas',
  FmxPasLibVlcPlayerUnit in '..\PasVLC\FmxPasLibVlcPlayerUnit.pas',
  YoutubeProgressBar in '..\YoutubeProgressBar.pas',
  AdvancedVideoPlayer in '..\AdvancedVideoPlayer.pas',
  Unit1 in 'Unit1.pas' {Form1},
  AdvancedVideoPlayerImages in '..\AdvancedVideoPlayerImages.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.Title := 'FmxDemoPasLibVlcPlayer'  + ' - ' + {$IFDEF CPUX64}'64'{$ELSE}'32'{$ENDIF} + ' bit';;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
