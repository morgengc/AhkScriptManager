;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 经常需要从网页中截取一些重要文章，保存为PNG文件
; 用Windows自带的图像浏览器打开，默认会自适应窗口，往往造成图片过小，需要手动调整为100%显示才能正常阅读
; 为此使用该程序，默认就以100%显示
; 
; 使用方法：
; 	1. 注册3rd/ScreenshotView.reg，使右键菜单中加入ScreenshotView. 此操作仅需一次
;   2. 在需要浏览的文件上点击右键，选择ScreenshotView打开
;
; gaochao.morgen@gmail.com
; 2016/6/12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance, Force
#NoEnv
SetBatchLines, -1

#Include ../lib/Gdip.ahk
#Include ../lib/DpiScale.ahk

ToolBarHeight := Round(28*GetDpiScale())			; 任务栏高度
Times := 0											; 鼠标滚动次数
BgHeight := Round((A_ScreenHeight-ToolBarHeight))	; 背景图层高度
Distance := Round((A_ScreenHeight-ToolBarHeight)/2)	; 每次滚动距离

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        GUI                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, GuiClose

; 图片图层
; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!)
Gui, 1: -Caption +E0x80000 +LastFound +OwnDialogs
Gui, 1: Show, Maximize

; Get a handle to this window we have created in order to update it later
hwnd1 := WinExist()

; 获取图片文件全名
Loop, %0%
{
	PicName := %A_Index%
	;MsgBox, %PicName%
	Break
}

; 加载图片文件
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
hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
hdc := CreateCompatibleDC()		; Get a device context compatible with the screen
obm := SelectObject(hdc, hbm)	; Select the bitmap into the device context
G := Gdip_GraphicsFromHDC(hdc)	; Get a pointer to the graphics of the bitmap, for use with drawing functions

; 画一个灰色背景
pBrush := Gdip_BrushCreateSolid(0xFFD9D9D9)
Gdip_FillRectangle(G, pBrush, 0, 0, A_ScreenWidth, BgHeight)
Gdip_DeleteBrush(pBrush)

Gosub PicDown
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                    响应鼠标滚动事件                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 向下滚动图片
#IfWinActive ahk_class AutoHotkeyGUI
WheelDown::
PicDown:
	; 原图像中仅显示(sx, sy, sw, sh)区域
	; 通常原图像的宽度都不会比屏幕宽(因为本程序浏览对象基本上都是网页截图)，但高度通常会比屏幕高
	sx := 0
	sy := Round(Distance*Times)
	sw := Width
	sh := (Round(A_ScreenHeight-ToolBarHeight) < Height) ? Round(A_ScreenHeight-ToolBarHeight) : Height
	if (sy + sh >= Height) {
		sy := Height - sh
		;FileAppend, sy=%sy% sh=%sh%`n, debug.txt
	} else {
		Times++
	}
	
	; 居中显示到这个位置
	dx := Round((A_ScreenWidth/2) - (Width/2))
	dy := Round(((A_ScreenHeight-ToolBarHeight)/2) - (sh/2))
	dw := sw
	dh := sh
	
	; 显示图片
	Gdip_DrawImage(G, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh)
	
	; 更新hwnd1窗口
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
Return

; 向上滚动图片
#IfWinActive ahk_class AutoHotkeyGUI
WheelUp::
	if (Times <= 0) {
		Return
	} else {
		Times--
	}

	; 原图像中仅显示(sx, sy, sw, sh)区域
	; 通常原图像的宽度都不会比屏幕宽(因为本程序浏览对象基本上都是网页截图)，但高度通常会比屏幕高
	sx := 0
	sy := Round(Distance*Times)
	sw := Width
	sh := (Round(A_ScreenHeight-ToolBarHeight) < Height) ? Round(A_ScreenHeight-ToolBarHeight) : Height
	
	; 居中显示到这个位置
	dx := Round((A_ScreenWidth/2) - (Width/2))
	dy := Round(((A_ScreenHeight-ToolBarHeight)/2) - (sh/2))
	dw := sw
	dh := sh
	
	; 显示图片
	Gdip_DrawImage(G, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh)
	
	; 更新hwnd1窗口
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       清理资源                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Esc::
q::
RButton Up::	; 只有右键弹起时才起效. 否则关闭窗口以后，右键事件会传递到后面的窗口
	Gosub GuiClose
Return

GuiClose:
	SelectObject(hdc, obm)			; Select the object back into the hdc
	DeleteObject(hbm)				; Now the bitmap may be deleted
	DeleteDC(hdc)					; Also the device context related to the bitmap may be deleted
	Gdip_DeleteGraphics(G)			; The graphics may now be deleted
	Gdip_DisposeImage(pBitmap)		; The bitmap we made from the image may be deleted
	
	Gdip_Shutdown(pToken)			; gdi+ may now be shutdown on exiting the program
	ExitApp
Return

