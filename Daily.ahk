; Last Revision: 2019-02-02

; AUTO EXECUTE ====================================================================================
 
; details for script optimization: 
	; https://autohotkey.com/docs/misc/Performance.htm
	; https://www.autohotkey.com/boards/viewtopic.php?t=6413

; ensure a consistent starting directory
SetWorkingDir %A_ScriptDir%  

; prevent empty variables from being looked up as environment variables
#NoEnv

; default script run speed == sleep 10 ms/line. Make it -1 to not sleep (run at maximum speed)
SetBatchLines -1

; set priority higher than normal Windows programs to improve performance
Process, Priority, , High

; ensure that there is only a single instance of this script running
#SingleInstance Force

; disable logging keys as they are only useful for debugging
#KeyHistory 0
ListLines Off

; set SendMode to SendInput, which has no delay between keystrokes
SendMode Input

; if SendInput unavailable, SendEvent is used; set delays at -1 to improve SendEvent's speed
SetKeyDelay, -1, -1
SetMouseDelay, -1

; a short delay is done after every command (i.e. WinActivate) to give a window a chance to update and respond. A delay of -1 (no delay) is allowed but it is recommended to use at least 0 to increase confidence that the script will run correctly when CPU is under load
SetWinDelay, 0
SetControlDelay, 0
SetDefaultMouseSpeed, 0

; hide system tray icon
#NoTrayIcon

; prevent task bar icons from flashing when different windows are activated quickly one after the other
#WinActivateForce

; turn off CapsLock and ScrollLock
SetNumLockState, AlwaysOn
SetCapsLockState, AlwaysOff
SetScrollLockState, AlwaysOff

; set title matching to search for "containing" instead of "exact"
SetTitleMatchMode, 2

; add only Explorer windows to group
GroupAdd, explorerGroup, ahk_class CabinetWClass

; custom scripts
#include %A_ScriptDir%
#include AutoCorrect.ahk

; end of auto execute section
return

; FUNCTIONS =======================================================================================

; activate program, if not exist open it, if active minimize it
ActivateProgram(program, program_path)
{
	if (!WinExist(program))
		Run, % program_path
	else if (!WinActive(program))
		WinActivate
	else
		WinMinimize
	return
}

; http://the-automator.com/?s=encode
; encode str to uri format
UriEncode(str)
{
	; set new_str's capacity == buffer size of str + "\0"(null terminator)
    VarSetCapacity(new_str, StrPut(str, "UTF-8"), 0)
	; write str to new_str with UTF-8 encoding
	StrPut(str, &new_str, "UTF-8")
	; set code == binary number of each character in new_str
    while (code := NumGet(new_str, A_Index-1, "UChar"))
		; concatenate chr, if Chr(code) matches regex, use chr, else use hex of code
		; e.g. code == 15, %X == F (in hex), %02X == 0F (expect >2 characters, prepend with zeros if less)
		; need to prepend zeros to single hex character to decode correctly later
    	res .= (chr := Chr(code)) ~= "[0-9A-Za-z]" ? chr : Format("%{:02X}", code)
    return res
}

; decode uri str to original format
UriDecode(str)
{
    loop
	{
		if (RegExMatch(str, "i)(?<=%)[0-9a-f]{1,2}", hex))
			StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
		else break
	}
	return str
}

; search website by selected words
SearchWebsite(website)
{
	Clipboard := ""
	Send, ^c
	ClipWait, 0
	if (InStr(Clipboard, "http"))
		Run, % Clipboard
	else if (website = "YouTube")
		Run, % "https://www.youtube.com/results?search_query=" . UriEncode(Clipboard)
	else if (website = "Google")
		Run, % "http://www.google.com/search?q=" . UriEncode(Clipboard)
	return
} 

; find tab by user input in current active program
FindTab()
{
	WinGet, program, ProcessName, A
	Input, user_input, B T5 E, {Enter}
	WinGetTitle, current_tab, A
	original_tab := current_tab
	if (program = "chrome.exe") {
		loop {
			if (InStr(current_tab, user_input))
				return
			Send, ^{PgDn}
			Sleep, 30
			WinGetTitle, current_tab, A
			if (current_tab == original_tab) {
				Run, % "http://www.google.com/search?q=" . UriEncode(user_input)
				return
			}
		}
	}
	else if (program = "Explorer.EXE") {
		loop {
			if (InStr(current_tab, user_input))
				return
			GroupActivate, explorerGroup, R
			Sleep, 30
			WinGetTitle, current_tab, A
			if (current_tab == original_tab) {
				Run, find G:\
				return
			}
		}
	}
	return
}

; check if mouse is hovering an existing window
MouseHover(window_class)
{
	MouseGetPos, , , A
	return WinExist(window_class . " ahk_id " . A)
}

; check if mouse is over an active window
MouseOver(window_class, y_target)
{
	MouseGetPos, x, y, A
	return WinActive(window_class . " ahk_id " . A) AND (y < y_target)
}

; move active window to specified position and size
MoveWindow(position := "default")
{
	WinRestore, A
	if (position = "default") {
		width := A_ScreenWidth / 1.3
		height := A_ScreenHeight / 1.3
		WinMove, A, , (A_ScreenWidth/2)-(width/2), (A_ScreenHeight/2)-(height/2), width, height
	}
	else if (position = "left")
		WinMove, A, , 0, 0, A_ScreenWidth/2, A_ScreenHeight
	else if (position = "top")
		WinMove, A, , 0, 0, A_ScreenWidth, A_ScreenHeight/2
	else if (position = "right")
		WinMove, A, , A_ScreenWidth/2, 0, A_ScreenWidth/2, A_ScreenHeight
	else if (position = "bottom")
		WinMove, A, , 0, A_ScreenHeight/2, A_ScreenWidth, A_ScreenHeight/2
	else if (position = "overlap")
		WinMove, A, , 0, 30, A_ScreenWidth, A_ScreenHeight-30
	return
}

; set active window always on top and transparent, 0 == invisible, 1 == opaque
FocusWindow(transparency)
{
	transparency := Floor(transparency * 255)
	WinSet, AlwaysOnTop, toggle, A
	WinGet, current_transparency, Transparent, A
	if (current_transparency == transparency)
    	WinSet, Transparent, Off, A
	else
   		WinSet, Transparent, % transparency, A
	return
}


; SCRIPT ==========================================================================================

; AHK control
CapsLock & F5::Reload
CapsLock & F10::Run, C:\Program Files\AutoHotkey\WindowSpy.ahk
CapsLock & Pause::
	Suspend
	Pause, , 1
return

; program shortcut
CapsLock & a::ActivateProgram("ahk_exe AcroRd32.exe", "AcroRd32.exe")
CapsLock & e::ActivateProgram("ahk_class CabinetWClass", "explorer.exe")
CapsLock & c::ActivateProgram("ahk_exe Code.exe" ,"C:\Users\kentl\AppData\Local\Programs\Microsoft VS Code\Code.exe")
CapsLock & g::ActivateProgram("ahk_exe chrome.exe", "chrome.exe")
CapsLock & t::ActivateProgram("ahk_exe mintty.exe", "C:\Program Files\Git\git-bash.exe")
CapsLock & o::ActivateProgram("ahk_exe Battle.net.exe", "C:\Program Files (x86)\Battle.net\Battle.net.exe")
CapsLock & l::ActivateProgram("ahk_class RCLIENT", "D:\Games\League of Legends\LeagueClient.exe")
CapsLock & f::FindTab()

; windows navigation
CapsLock & Space::Send, !{Tab}
CapsLock & m::MoveWindow()
CapsLock & z::FocusWindow(0.75)
CapsLock & p::MoveWindow("overlap")

; editing macros
+Left::Send, +{Home}
+Right::Send, +{End}
+BackSpace::Send, +{Home}{Del}
+Del::Send, +{End}{Del}
CapsLock & v::
	Clipboard := Clipboard
	Send, ^v
	return

; media control
CapsLock & Numpad5::Send, {Media_Play_Pause}
CapsLock & Numpad4::Send, {Media_Prev}
CapsLock & Numpad6::Send, {Media_Next}
CapsLock & Numpad8::Send, {Volume_Up 5}
CapsLock & Numpad2::Send, {Volume_Down 5}

; system control
#Del::FileRecycleEmpty
#c::Run, control
#l::
	DllCall("LockWorkStation")
	SendMessage 0x112, 0xF170, 2, , Program Manager
	return

; mouse control
CapsLock & Mbutton::
	MouseGetPos, mouse_x, mouse_y
	WinGetPos, win_x, win_y, win_w, win_h, A
	MouseMove, win_w-15, mouse_y, 0
	Send, +{LButton}
	MouseMove, mouse_x, mouse_y, 0
	return
#If MouseHover("ahk_class Shell_TrayWnd")
	WheelUp::Send, {Volume_Up}
	WheelDown::Send, {Volume_Down}
#If MouseOver("ahk_class Chrome_WidgetWin_1", 100)
	WheelUp::Send ^{PgUp}
	WheelDown::Send ^{PgDn}
#If
return

; special function
F2::SearchWebsite("Google")
F3::SearchWebsite("YouTube")
F4::GroupActivate, explorerGroup, R

; macros in programs
#IfWinActive ahk_exe Code.exe
	CapsLock & i::Send, {Up}
	CapsLock & l::Send, {Right}
	CapsLock & k::Send, {Down}
	CapsLock & j::Send, {Left}
	CapsLock & u::Send, ^{PgUp}
	CapsLock & o:: Send, ^{PgDn}
	CapsLock & Enter:: Send, {End}{Enter}
	CapsLock & r::Send, ^+t
#IfWinActive ahk_exe mintty.exe
	^v::Send, {Raw}%Clipboard%
#IfWinActive ahk_exe chrome.exe
	CapsLock & r::Send, ^+t
	$^f::
		Send, ^c^f
		Sleep, 30
		Send, % Clipboard
		return
#IfWinActive ahk_class OpusApp
	^Left::Send, ^+{Left}
	^Right::Send, ^+{Right}
	CapsLock & i::Send, {Up}
	CapsLock & l::Send, {Right}
	CapsLock & k::Send, {Down}
	CapsLock & j::Send, {Left}
	:*B0:(::){Left}
	:*B0:[::]{Left}
	:*B0:<::>{Left}
	:*B0:{::{}}{Left}
#IfWinActive ahk_class CabinetWClass
	Esc::Send, !{F4}
#IfWinActive
return

; NOT USE =========================================================================================
; snippet - it is here for reference only
; issues:
	; inconsistent input in certain applications
	; no longer needed as editors have this feature built in
/*
:*B0:(::){Left}
:*B0:[::]{Left}
:*B0:<::>{Left}
:*B0:{::{}}{Left}

:*B0O:if`t::()`n{{}`n`n{}}{Up}`t{Up 2}{End}{Left}
:*B0O:else if`t::()`n{{}`n`n{}}{Up}`t{Up 2}{End}{Left}
:*B0O:else`t:: {Bs}`n{{}`n`n{}}{Up}`t
:*B0O:for`t::()`n{{}`n`n{}}{Up}`t{Up 2}{End}{Left}
:*B0O:while`t::()`n{{}`n`n{}}{Up}`t{Up 2}{End}{Left}
*/

; change MTU to 576 (for Mabinogi)/1500 (check MTU value with cmd --> netsh interface ipv4 show subinterfaces)
/*
CapsLock & 5::Run, %comspec% /c netsh interface ipv4 set subinterface "Ethernet" mtu=576 store=persistent
CapsLock & 1::Run, %comspec% /c netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
*/
; =================================================================================================