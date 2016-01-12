;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 经常需要从网页中截取一些重要文章，保存为PNG文件
; 用Windows自带的图像浏览器打开，默认会自适应窗口，往往造成图片过小，需要手动调整为100%显示才能正常阅读
; 为此使用该程序，默认就以100%显示
; 
; 使用方法：
; 		1. 注册3rd/ScreenshotView.reg，使右键菜单中加入ScreenshotView. 此操作仅需一次
;       2. 在需要浏览的文件上点击右键，选择ScreenshotView打开
;
; gaochao.morgen@gmail.com
; 2016/6/12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance, Force
#NoEnv
SetBatchLines, -1

#Include ../lib/Gdip.ahk

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, GuiClose

; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs

; Show the window
Gui, 1: Show, NA
; Get a handle to this window we have created in order to update it later
hwnd1 := WinExist()

; 获取图片文件全名
Loop, %0%
{
	PicName := %A_Index%
	;MsgBox, %PicName%
	Break
}

pBitmap := Gdip_CreateBitmapFromFile(PicName)
If !pBitmap
{
	MsgBox, 48, File loading error!, Could not load the image specified
	ExitApp
}

; 原始图片宽度和高度
Width := Gdip_GetImageWidth(pBitmap)
Height := Gdip_GetImageHeight(pBitmap)

; 这个相当于画布，图像绘制在该区域
hbm := CreateDIBSection(Width, Height)
hdc := CreateCompatibleDC()		; Get a device context compatible with the screen
obm := SelectObject(hdc, hbm)	; Select the bitmap into the device context
G := Gdip_GraphicsFromHDC(hdc)	; Get a pointer to the graphics of the bitmap, for use with drawing functions
Gdip_SetInterpolationMode(G, 7)	; This specifies how a file will be resized (the quality of the resize)

; 显示图片
Gdip_DrawImage(G, pBitmap, 0, 0, Width, Height)

; 更新hwnd1窗口
UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)

SelectObject(hdc, obm)			; Select the object back into the hdc
DeleteObject(hbm)				; Now the bitmap may be deleted
DeleteDC(hdc)					; Also the device context related to the bitmap may be deleted
Gdip_DeleteGraphics(G)			; The graphics may now be deleted
Gdip_DisposeImage(pBitmap)		; The bitmap we made from the image may be deleted

;#######################################################################

Esc::
q::
	Gosub GuiClose
Return

GuiClose:
	; gdi+ may now be shutdown on exiting the program
	Gdip_Shutdown(pToken)
	ExitApp
Return

