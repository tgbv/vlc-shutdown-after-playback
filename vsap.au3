#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon33.ico
#AutoIt3Wrapper_Outfile=vsap_x86.exe
#AutoIt3Wrapper_Outfile_x64=vsap_x64.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=VSAP licensed under MIT
#AutoIt3Wrapper_Res_Fileversion=2.0.0.0
#AutoIt3Wrapper_Res_ProductName=VSAP
#AutoIt3Wrapper_Res_ProductVersion=2.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Teodor Ionescu (MIT License)
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#include <EditConstants.au3>
#include <FileConstants.au3>
#include <GuiConstantsEx.au3>
#include <Misc.au3>
#include <TrayConstants.au3>
#include <WindowsConstants.au3>

Opt("TrayMenuMode", 3)
Opt("TrayIconHide", 1)


If _Singleton("vsap", 1) = 0 Then
	MsgBox(48, "VSAP", "Application is already running.")
	Exit
EndIf

#Region constants
	Const $CONFIG_DIR = @AppDataDir & "\tgbv\vsap\"
	Const $EXECUTABLE_PATH = $CONFIG_DIR & "vsap.exe"
	Const $REPORTING_SIGNATURE = "If problem persists, please report it at https://github.com/tgbv/vlc-shutdown-after-playback/issues"

	Const $ACTION_SHUTDOWN = 0
	Const $ACTION_SLEEP = 1
#EndRegion


#Region startup method
If $CmdLine[0] > 0 Then
	If $CmdLine[1] == "min" Then
		ConsoleWrite("started minimized" & @LF)
		Daemon()
	EndIf
Else
	ConsoleWrite("started maximized" & @LF)
	RenderSettingsGui()
EndIf
#EndRegion


;;;;;;;;;;;;;;;;;;
Func SetCfg($name, $value, $type = "REG_DWORD")
	$v = RegWrite("HKEY_CURRENT_USER\Software\tgbv\vsap", $name, $type, $value)

	If $v == 0 And @error > 0 Then
		MsgBox(16, "VSAP", "Could not write to regedit! Please ensure you have permission to write to HKEY_CURRENT_USER\Software\*. " & $REPORTING_SIGNATURE)
		Exit
	EndIf
EndFunc

;;;;;;;;;;;;;;;;;;
Func GetCfg($name)
	$v = RegRead("HKEY_CURRENT_USER\Software\tgbv\vsap", $name)

	; set the default config in regedit
	If @error == 1 Then
		SetCfg("LaunchOnStartup", 4)
		SetCfg("ActionOnPlaylistEnd", 0)
		SetCfg("CountdownToAction", 20)
		return GetCfg($name)
	EndIf

	If Not (@error == 0) Then
		MsgBox(16, "VSAP", "Could not read from regedit! Please ensure you have permission to read from HKEY_CURRENT_USER\Software\*. " & $REPORTING_SIGNATURE)
		Exit
	EndIf

	return $v
EndFunc

; Render GUI settings panel
Func RenderSettingsGui()
	$Window = GUICreate("VSAP Settings", 220, 250, -1, -1, -1)

	#Region launch on startup
		$LaunchOnStartupCheckbox = GUICtrlCreateCheckbox("Launch on Windows startup", 10, 15, 300, 20)
		GUICtrlSetState($LaunchOnStartupCheckbox, GetCfg("LaunchOnStartup") )
	#EndRegion

	#Region action
		GUICtrlCreateGroup("Action on playlist end", 10, 50, 200, 75)
		$ShutdownPcCheckbox = GUICtrlCreateCheckbox("Shutdown PC", 20, 72, 100, 20)
		GUICtrlSetState(-1, GetCfg("ActionOnPlaylistEnd") == $ACTION_SHUTDOWN ? $GUI_CHECKED : $GUI_UNCHECKED)

		$SleepPcCheckbox = GUICtrlCreateCheckbox("Sleep PC", 20, 92, 95, 20)
		GUICtrlSetState(-1, GetCfg("ActionOnPlaylistEnd") == $ACTION_SLEEP ? $GUI_CHECKED : $GUI_UNCHECKED)
	#EndRegion


	#Region input box
		GUICtrlCreateGroup("Countdown to action (seconds)", 10, 135, 200, 50)
		$CountdownToActionInput = GUICtrlCreateInput(20, 15, 155, 190, 20, $ES_NUMBER + $ES_CENTER)
		GUICtrlSetData($CountdownToActionInput, GetCfg("CountdownToAction"))
	#EndRegion

	#Region button
		$StartWatcherButton = GUICtrlCreateButton("Start Watcher", 10, 200, 200, 40)
	#EndRegion

	GUISetState(@SW_SHOW)

	#Region Events listener
	While 1
		$msg = GUIGetMsg()

		; On exit
		If $msg == $GUI_EVENT_CLOSE Then
			Exit
		EndIf

		; On start watching
		If $msg == $StartWatcherButton Then

			; validation
			If Not (IsNumber(GetCfg("CountdownToAction"))) Then
				MsgBox(48, "Error", "Please ensure countdown to action value is a valid integer")
				ContinueLoop
			EndIf

			SetCfg("ActionOnPlaylistEnd", (GuiCtrlRead($ShutdownPcCheckbox) == $GUI_CHECKED) ? $ACTION_SHUTDOWN : $ACTION_SLEEP )
			SetCfg("LaunchOnStartup", GuiCtrlRead($LaunchOnStartupCheckbox))
			SetCfg("CountdownToAction", GuiCtrlRead($CountdownToActionInput))

			If GetCfg("LaunchOnStartup") == $GUI_CHECKED Then
				If FileExists($EXECUTABLE_PATH) == 0 Then
					If FileCopy(@ScriptFullPath, $EXECUTABLE_PATH, 8) == 0 Then
						MsgBox(48, "VSAP", "Could not copy executable in " & $EXECUTABLE_PATH & ". Please ensure you have the right permissions. " & $REPORTING_SIGNATURE)
					Else
						ConsoleWrite("self copied in %appdata%" & @lf)
					EndIf
				EndIf
				RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "vsap", "REG_SZ", $EXECUTABLE_PATH & " min")
				ConsoleWrite("updated HKCU\..\Run" & @lf)
			Else
				RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "vsap")
				ConsoleWrite("updated HKCU\..\Run" & @lf)
			EndIf

			MsgBox(64, "VSAP", "The settings have been saved! Application will minimise itself in system tray and watch for VLC windows. You may continue controlling it from there.", 0, $Window)

			GUIDelete()

			Daemon()
		EndIf

		; on sleep checkbox
		If $msg == $SleepPcCheckbox Then
			GUICtrlSetState($SleepPcCheckbox, $GUI_CHECKED)
			GUICtrlSetState($ShutdownPcCheckbox, $GUI_UNCHECKED)
		EndIf

		; on shutdown checkbox
		If $msg == $ShutdownPcCheckbox Then
			GUICtrlSetState($SleepPcCheckbox, $GUI_UNCHECKED)
			GUICtrlSetState($ShutdownPcCheckbox, $GUI_CHECKED)
		EndIf

	WEnd
	#EndRegion

EndFunc

; Runs daemon
Func Daemon()

	Opt("TrayIconHide", 0)

	$ConfigItem = TrayCreateItem("Settings")
	$SeparatorItem = TrayCreateItem("")
	$ExitItem = TrayCreateItem("Exit")

	TrayTip ( "VSAP", "VSAP is watching for VLC windows...", 10)

	$windowDetected = false
	$playlistPlayed = false
	While 1

		$msg = TrayGetMsg()

		; On exit
		If $msg == $ExitItem Then
			If MsgBox (4 + 32, "VSAP" ,"Are you sure you want to exit?") == 6 Then
				Exit
			EndIf
		EndIf

		; on config
		If $msg == $ConfigItem Then
			Opt("TrayIconHide", 1)
			TrayItemDelete($ConfigItem)
			TrayItemDelete($SeparatorItem)
			TrayItemDelete($ExitItem)
			RenderSettingsGui()
			return
		EndIf


		$vlcWindowTitle = WinGetTitle("[REGEXPTITLE:.*VLC media player]")

		;
		If StringLen($vlcWindowTitle) > 0 And Not ($windowDetected) Then
			ConsoleWrite("window detected" & @lf)
			$windowDetected = True
		EndIf

		; when playlist is playing
		If $windowDetected And Not $playlistPlayed And Not ($vlcWindowTitle == "VLC media player") Then
			ConsoleWrite("playlist played" & @lf)
			$playlistPlayed = True
		EndIf

		; when user manually closes VLC window
		If $windowDetected And StringLen($vlcWindowTitle) == 0 Then
			ConsoleWrite("user closed window" & @lf)
			$windowDetected = False
			$playlistPlayed = False
		EndIf

		;
		If $vlcWindowTitle == "VLC media player" And $playlistPlayed Then
			; halt script to ensure playlist is indeed empty
			Sleep(400)
			If WinGetTitle("[REGEXPTITLE:.*VLC media player]") == "VLC media player" Then
				$Action = GetCfg("ActionOnPlaylistEnd")
				$CountdownToAction = GetCfg("CountdownToAction")

				$Time = TimerInit()

				$Gui = GUICreate("test", 191, 157, (@DesktopWidth - 191) / 2, (@DesktopHeight - 157) / 2, BitOR($WS_POPUP, $WS_BORDER), $WS_EX_TOPMOST)

				GUICtrlCreateLabel("Countdown to " & (($Action == $ACTION_SHUTDOWN) ? "shutdown" : "sleep")  &": ", 8, 20, 120 , 17)

				$SecondsLabel = GUICtrlCreateLabel($CountdownToAction, 130, 20, 40, 17)

				$AbortButton = GUICtrlCreateButton("STOP " & (($Action == $ACTION_SHUTDOWN) ? "SHUTDOWN" : "SLEEP"), 30, 90, 130, 20)

				GUISetState(@SW_SHOW, $Gui)

				While 1
					$trayMsg = TrayGetMsg()

					; On exit
					If $trayMsg == $ExitItem Then
						GUIDelete($Gui)
						If MsgBox (4 + 32, "VSAP" ,"Are you sure you want to exit?") == 6 Then
							Exit
						EndIf
					EndIf

					; on config
					If $trayMsg == $ConfigItem Then
						GUIDelete($Gui)
						Opt("TrayIconHide", 1)
						TrayItemDelete($ConfigItem)
						TrayItemDelete($SeparatorItem)
						TrayItemDelete($ExitItem)
						RenderSettingsGui()
						return
					EndIf

					$iMsg = GUIGetMsg()
					Select
						Case $iMsg = $AbortButton
							GUIDelete($Gui)
							$windowDetected = False
							$playlistPlayed = False
							ExitLoop
					EndSelect

					GUICtrlSetData ($SecondsLabel, Round( $CountdownToAction-TimerDiff($Time) / 1000, 1) )

					If TimerDiff($Time) / 1000 > $CountdownToAction Then
						GUIDelete($Gui)

						If $Action == $ACTION_SHUTDOWN Then
							WinClose("[REGEXPTITLE:.*VLC media player]")
							Shutdown( BitOr(1, 16) ) ; forceful shutdown
						Else ; sleep
							Shutdown( 32 )
						EndIf
						ConsoleWrite("shutdown/sleep occurred" & @LF)
						ExitLoop
					EndIf

				WEnd
			EndIf
		EndIf
	WEnd
EndFunc