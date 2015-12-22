;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 鼠标选定区域，截取该区域
;
; Ctrl + Shift + 左键: 截图存为PNG图片，并保存到桌面
; Ctrl + Shift + 右键: 截图保存到ClipBoard中，直接粘贴
;
; 已知BUG: 用WinSet设置了TransColor的窗口无法捕捉
;
; gaochao.morgen@gmail.com
; 2014/2/12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/Gdip.ahk
#Include ../lib/DpiScale.ahk

#SingleInstance, Force
#NoTrayIcon
#NoEnv

SetBatchLines, -1	; 让脚本以全速运行

+^LButton::
	screen := MouseCapture("LButton")

	FormatTime, TimeString, A_Now, yyyy-MM-dd HH-mm-ss
	output := A_Desktop . "\" . TimeString . ".png"

	; Start gdi+
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		Return
	}

	pbitmap:=Gdip_BitmapFromScreen(screen)
	Gdip_SaveBitmapToFile(pBitmap, output)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
Return

+^RButton::
	screen := MouseCapture("RButton")

	; Start gdi+
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		Return
	}

	pbitmap:=Gdip_BitmapFromScreen(screen)
	Gdip_SetBitmapToClipboard(pBitmap)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
Return

MouseCapture(BUTTON)
{
	CoordMode, Mouse, Screen	; 屏幕绝对坐标模式，作用于MouseGetPos
	MouseGetPos, MX, MY
	Gui, 1:Color, EEAA99
	Gui, 1:+Lastfound
	WinSet, TransColor, EEAA99
	Gui, 1:-Caption +Border
	Loop
	{
		if GetKeyState(BUTTON, "P")
		{
			MouseGetPos, MXend, MYend
			W := abs(MX - MXend)
			H := abs(MY - MYend)
			DispW := W / GetDpiScale()
			DispH := H / GetDpiScale()
			if (MX < MXend)
				X := MX
			else
				X := MXend
			if (MY < MYend)
				Y := MY
			else
				Y := MYend

			Gui, 1:Show, x%X% y%Y% w%DispW% h%DispH%
		}
		else
			Break
	}
	MouseGetPos, MXend, MYend
	Gui, 1:Destroy

	selection = %MX%|%MY%|%W%|%H%
	Return selection
}

