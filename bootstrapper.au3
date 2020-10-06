#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon33.ico
#AutoIt3Wrapper_Outfile=bootstrapper.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>

Local $time, $idGUI, $Label1, $idAbortSd, $iMsg

TrayTip ( "VLC shutdown bootstrapper", "The bootstrapper is listening for VLC windows...", 10)

Example()

Func Example()
	; wait for VLC to open
	WinWaitActive( "[REGEXPTITLE:.*VLC media player]" )

	; wait for vid to be active in VLC
	WinWaitActive( "[REGEXPTITLE:.+VLC media player]" )

	While 1
		; check title
		if WinGetTitle("[REGEXPTITLE:.*VLC media player]") == "VLC media player" Then
			; halt script to make sure playlist is indeed empty
			Sleep(200)
			If WinGetTitle("[REGEXPTITLE:.*VLC media player]") == "VLC media player" Then
				; create GUI
				$time = TimerInit()
				$idGUI = GUICreate("ShutdownNotice", 191, 157, (@DesktopWidth - 191) / 2, (@DesktopHeight - 157) / 2, BitOR($WS_POPUP, $WS_BORDER), $WS_EX_TOPMOST)
				GUICtrlCreateLabel("Time until shutdown: ", 8, 20, -1, 17)
				$Label1 = GUICtrlCreateLabel("20", 110, 20, -1, 17)
				$idAbortSd = GUICtrlCreateButton("STOP SHUTDOWN", 30, 90, 130, 20)
				GUISetState()

				While 1
					$iMsg = GUIGetMsg()
					Select
						Case $iMsg = $idAbortSd
							GUIDelete("ShutdownNotice")
							ExitLoop
					EndSelect

					$sec = Round(  (15*60*22-TimerDiff($time)) / 1000  )

					If $sec < 1 Then
						WinClose("[REGEXPTITLE:.*VLC media player]")
						Shutdown( BitOr(1, 16) )
						ExitLoop
					EndIf

					GUICtrlSetData ($Label1, $sec)
				WEnd
				ExitLoop
			EndIf
		EndIf
	WEnd

	Example()
EndFunc