# AdvancedVideoPlayer

![http://url/to/img.png](https://github.com/kamel78/AdvancedVideoPlayer/blob/main/DemoiImage.png)

Delphi video player interface for video (a youtube like's interface), that offer the following possibilities:

- Automatic progression bar with visual effect when entering leaving the progress zone
- Several video information’s display : time, length, progress ....
- Load for both files and URLs (streaming)
- Handling connection lost with possibility of auto-resuming (handling the OnConnectionLost event ..) 
- Fullscreen supported !
- Volume control , Play/Pause

In order to demonstrate the capabilities of the interface, the VLC Pascal library (http://prog.olsztyn.pl/paslibvlc) has been used as a demo to read and stream videos. It suffer from many (many.....) bugs and problems, but unfortunately it is the unique video playing interface adapted to Delphi under Windows. I am working on a version for the Zeus64/alcino implementation but it handle only Android and IOS (No windows)

Remarks and bug reports are welcome.

Important remark :when compiling the demo version, use Run-without-Debug (Maj-Ctrl-F9) instead of Direct run with F9 since the VLC library with crach at a hight probability under debug mode 
