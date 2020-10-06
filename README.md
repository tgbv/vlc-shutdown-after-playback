### It's 2020 and Videolan developers still haven't decided to implement this feature yet

VLC Player is one of the best ones in the world. Though every once in a while at around 10PM I may decide to play a movie on my computer and fall asleep at it. I normally sleep ~8 hours/night but the film I watch is <= 2hours. That means my PC gets to stay awake 6 more hours and wait for my ass to wake up and shut it down. Why should my computer stay awake that long for no reason?? Videolan I'm not a senior software engineer but that's basic feature, a checkbox in settings would do it: **"Shutdown computer after playlist ends"**. Yet such option doesn't exist.

There are workarounds on internet for this issue but all I could see are tedious methods using VBS/Batch/Bash scripts + drag&drops.

So I came up with something slightly better: a trigger which runs independently from vlc thread and checks when movie is over/playlist is empty. The script is witten and compiled for Windows OS using Autoit3: https://www.autoitscript.com

## Instructions:

Before starting VLC run bootstrapper.exe from this repo --- If you're unsure about the file (eg: you believe it's a virus), inspect the source code; take it and compile it yourself using Autoit3.

Now each time your movie/playlist ends, a popup will bounce on your screen warning your PC will shut down in 20 seconds; it has a button to abort the shutdown as well.

If you often watch films at night and fall asleep before playlist ends, you can place bootstrapper.exe in `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup` so the trigger will be online each time Windows boots up.

This app is tested for VLC 3.0.11, it should work with all minor 3.x.x versions
