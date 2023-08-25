## VCL shutdowner 

VLC Media Player does not have a built-in option to automatically shutdown computer after playlist ends.

There are workarounds on internet for this issue but all I could find are tedious methods using VBS/Batch/Bash scripts + drag&drops (eg: https://wiki.videolan.org/VLC_HowTo/Shut_down_the_computer_at_the_end_of_the_playlist/) which I believe is terrible

So I came up with something slightly better: a watcher process which runs independently from vlc thread and checks when movie is over/playlist is empty. The script is witten and compiled for Windows OS using Autoit3: https://www.autoitscript.com

## Instructions:

Before starting VLC run bootstrapper.exe

Now each time your movie/playlist ends, a pop-up will bounce on your screen warning your PC will shut down in 20 seconds; it has a button to abort the shutdown as well.

<img src="https://github.com/tgbv/vlc-shutdown-after-playback/blob/main/Screenshot_2.jpg?raw=true" />

If you often watch films at night and fall asleep before playlist ends, you can place bootstrapper.exe in `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup` so the trigger will be online each time Windows boots up.

This app is tested for VLC 3.0.11, it should work with all minor 3.x.x versions
