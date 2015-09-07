;
; It displays the network download/upload KB in progress bar.
; By Sean 
;
#SingleInstance, Force
#NoTrayIcon
#NoEnv

; Adjust X & Y to suit your screen res
StartX := A_ScreenWidth - 380
StartY := 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Gui, -Caption +Border +AlwaysOnTop +ToolWindow
Gui, Color, EEAA99
Gui, +LastFound
WinSet, TransColor, EEAA99
Gui, Add, Progress,      w100 h10 cGreen -0x1 vDn
Gui, Add, Progress, x+10 w100 h10 cRed   -0x1 vUp
Gui, Show, x%StartX% y%StartY% , NetMeter

If GetIfTable(tb)
   ExitApp

Loop, % DecodeInteger(&tb)
{
	If DecodeInteger(&tb + 4 + 860 * (A_Index - 1) + 544) < 4 || DecodeInteger(&tb + 4 + 860 * (A_Index - 1) + 516) = 24
	   Continue
	ptr := &tb + 4 + 860 * (A_Index - 1)
	   Break
}

If !ptr
   ExitApp

SetTimer, NetMeter, On, 1000
Return

NetMeter:
	DllCall("iphlpapi\GetIfEntry", "Uint", ptr)
	
	dnNew := DecodeInteger(ptr + 552)		; Total Incoming Bytes
	upNew := DecodeInteger(ptr + 576)		; Total Outgoing Bytes
	
	dnRate := Round((dnNew - dnOld) / 1024)
	upRate := Round((upNew - upOld) / 1024)
	
	GuiControl,, Dn, %dnRate%
	;FileAppend, %dnRate%, xxx.txt
	;FileAppend, `n, xxx.txt
	GuiControl,, Up, %upRate%
	
	dnOld := dnNew
	upOld := upNew
Return


GetIfTable(ByRef tb, bOrder = False)
{
	nSize := 4 + 860 * GetNumberOfInterfaces() + 8
	VarSetCapacity(tb, nSize)
	Return DllCall("iphlpapi\GetIfTable", "Uint", &tb, "UintP", nSize, "int", bOrder)
}

GetIfEntry(ByRef tb, idx)
{
	VarSetCapacity(tb, 860)
	DllCall("ntdll\RtlFillMemoryUlong", "Uint", &tb + 512, "Uint", 4, "Uint", idx)
	Return DllCall("iphlpapi\GetIfEntry", "Uint", &tb)
}

GetNumberOfInterfaces()
{
	DllCall("iphlpapi\GetNumberOfInterfaces", "UintP", nIf)
	Return nIf
}

DecodeInteger(ptr)
{
	Return *ptr | *++ptr << 8 | *++ptr << 16 | *++ptr << 24
}

