;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 显示鼠标下的颜色RGB值
; 
; gaochao.morgen@gmail.com
; 2017/3/13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/HexDec.ahk

#Persistent
#SingleInstance, Force
#NoEnv

Loop
{
	Sleep, 200
	MouseGetPos, x, y
	PixelGetColor, rgb, x, y, RGB

	r := SubStr(rgb, 3, 2)
	g := SubStr(rgb, 5, 2)
	b := SubStr(rgb, 7, 2)
	
	rd := Hex2Dec("0x" . r)
	gd := Hex2Dec("0x" . g)
	bd := Hex2Dec("0x" . b)

	ToolTip, %rgb%`n%rd%`,%gd%`,%bd%`n`nPress MButton to copy RGB hex`nPress Esc to exit
	GetKeyState, state, MButton
	if state = D
	{
		Clipboard := rgb
		ToolTip, %rgb% Copied.
	}
}

Esc::
	ExitApp
Return

