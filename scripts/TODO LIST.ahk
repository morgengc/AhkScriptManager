;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 在桌面显示TODO LIST
;
; 用法: 首次点击按钮更新TODO条目，再次点击按钮保存并显示为背景透明
;
; 快捷键:
; Enter: 保存
; Ctrl + Enter: 文本换行
;
; NOTE:
; 	本程序将Edit控件设置为透明. 当点击Edit控件时，在Edit空白区域会穿透控件，导致事件无法触发
; 	虽然点击Edit控件文字部分有时候会触发事件，但有时候不能触发，完全取决于点击的位置
;	因此设置了按钮使Edit控件临时变得不透明，以便更新条目，更新完毕再次点击按钮变成透明显示
;
; 修改自Uberi的To-Do List / Reminders
; URL: http://www.autohotkey.com/board/topic/57455-to-do-list-reminders
;
; gaochao.morgen@gmail.com
; 2014/5/24
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

#Include ../lib/DpiScale.ahk

; 若配置文件目录不存在，则创建
ConfigPath = %A_ScriptDir%\..\config
if (!IsDirExist(ConfigPath))
	FileCreateDir, %ConfigPath%

; 若配置文件不存在，则创建空白文件
ConfigFile = %ConfigPath%\TODO.config
IfNotExist, %ConfigFile%
	FileAppend,, %ConfigFile%

WINDOW_X := A_ScreenWidth - (380*GetDpiScale())	; 窗口起始X
WINDOW_Y := 250	* GetDpiScale()					; 窗口起始Y
WINDOW_W := 250									; 窗口宽度
WINDOW_H := 300 								; 窗口高度
EDIT_H := 20									; Edit控件高度
EDIT_SPACE := 1									; Edit控件垂直间距
TEXT_W := 18									; Text控件宽度
BUTTON_H := 20									; Button控件高度
BUTTON_SPACE := 7								; Button控件与Edit控件的垂直间距
BGCOLOR = 00FF00								; 背景颜色RGB

FieldCount := Round((WINDOW_H-BUTTON_H-BUTTON_SPACE) / (EDIT_H+EDIT_SPACE))	; TODOLIST最大条目为FieldCount条

Changed := false	; 记录窗口是否激活
LastField = 0		; 记录最后一个显示出来的Edit控件索引

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        GUI                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CoordMode, Mouse
Gui, -Caption +ToolWindow +LastFound
Gui, Margin, 0, 0

Gui, Color, %BGCOLOR%				; 窗口背景颜色
WinSet, Transparent, Off			; 窗口设置为不透明
WinSet, TransColor, %BGCOLOR% 255	; 让窗口中指定颜色的所有像素透明

Gui, Font, cRed S9, Arial
Gui, Add, Button, x%TEXT_W% h%BUTTON_H% +0x8000 HwndHwndButton gBtClick, TODO LIST

; 添加所有Edit控件
Gui, Font, cRed S10 underline, SIMSUN
Loop, %FieldCount%
{
	; 相对于窗口的坐标
	Coordinate := " x" . TEXT_W
	Coordinate .= " y" . (A_Index * (EDIT_H+EDIT_SPACE) + BUTTON_SPACE)
	Coordinate .= " w" . WINDOW_W - TEXT_W
	Coordinate .= " h" . EDIT_H

	Style := Coordinate
	Style .= " Hidden -E0x200 " 		; E0x200 = WS_EX_CLIENTEDGE
	Style .= " vField" . A_Index
	Style .= " HwndHwndField" . A_Index
	Gui, Add, Edit, %Style%

	Gui, Color,, %BGCOLOR%				; 控件背景颜色
	Gui +LastFound						; 刚刚创建的Edit控件
	WinSet, TransColor, %BGCOLOR% 255	; 控件设置为透明
}

; 添加索引
Gui, Font	; 先恢复默认字体，再设置字体，否则仍然会有下划线
Gui, Font, cRed
Loop, %FieldCount%
{
	Coordinate := " x0"
	Coordinate .= " y" . (A_Index * (EDIT_H+EDIT_SPACE) + BUTTON_SPACE)
	Coordinate .= " w" . TEXT_W
	Coordinate .= " h" . EDIT_H

	Style := Coordinate
	Style .= " Hidden +0x2"
	Style .= " vIndex" . A_Index

	Gui, Add, Text, %Style%, % A_Index . "."
}

Gui, Show, x%WINDOW_X% y%WINDOW_Y% w%WINDOW_W% h%WINDOW_H%, TODOLIST

SetFormat, Integer, Hex
OnMessage(0x111, "ClickedEdit")
Gosub, Load
OnExit, GuiClose
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                      主画面响应                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 加载文件内容到TODOLIST
Load:
	Critical				; 防止当前线程被其他线程中断
	SetFormat, Integer, D	; 运算结果为10进制

	IfNotExist, %ConfigFile%
	{
		AddNewField()
		HideEditBorder(LastField)
		GuiControl,, Field1, 点击按钮添加新条目
		Return
	}

	LineCount := 0
	Loop, Read, %ConfigFile%
	{
		; 跳过空行
		pos := RegExMatch(A_LoopReadLine, "^([ \t]*)$")
		if (ErrorLevel = 0 && pos > 0)
			continue

		LineCount++
		AddNewField()
		GuiControl,, Field%LineCount%, %A_LoopReadLine%
	}

	if (LineCount = 0)
	{
		AddNewField()
		HideEditBorder(LastField)
		GuiControl,, Field1, 点击按钮添加新条目
	}
	else
	{
		ClearEmptyFields()
		Loop %FieldCount%
			HideEditBorder(A_Index)
	}
Return

; 将TODOLIST中的内容保存到文件
Save:
	Critical
	SetFormat, Integer, D
	NewFileContent = 
	Loop, %LastField%
	{
		GuiControlGet, EditContent,, Field%A_Index%
		NewFileContent .= EditContent . "`n"
	}
	StringTrimRight, NewFileContent, NewFileContent, 1
	IfExist, %ConfigFile%
		FileDelete, %ConfigFile%
	FileAppend, %NewFileContent%, %ConfigFile%
Return

; 修改TODOLIST的内容
; 首次点击时，Edit控件将处于激活状态，允许添加新的TODO条目
; 再次点击时，Edit控件将处于非激活状态(只是变透明了，实际上还是激活的)
BtClick:
	if (!Changed)
	{
		Gui, Color,, cDefault		; 设置控件背景颜色为默认颜色，使他们不再透明
		Loop, %LastField%			; 为当前可见的所有Edit控件设置边框
			ShowEditBorder(A_Index)
		AddNewField()				; 加一行空行，以便添加新内容
		GuiControl, Focus, % HwndField%LastField%
	}
	else
	{
		Gui, Color,, %BGCOLOR%		; 设置控件背景颜色，使他们再次透明
		Loop, %FieldCount%			; 隐藏所有Edit控件的边框
			HideEditBorder(A_Index)
		ClearEmptyFields()
		Gosub, Save
	}

	Changed := !Changed
Return

; 保存并退出程序
GuiClose:
	Gosub, Save
	ExitApp
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        热键                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 回车保存. 仅在处于激活状态时才有效
#IfWinActive TODOLIST
Enter::
	if (!Changed)
		Return

	Gui, Submit, Nohide
	Gui, Color,, %BGCOLOR%		; 设置控件背景颜色，使他们再次透明
	Loop, %FieldCount%			; 隐藏所有Edit控件的边框
		HideEditBorder(A_Index)
	ClearEmptyFields()
	Gosub, Save
	Changed := false
Return
#IfWinActive

; Ctrl + Enter 换行
#IfWinActive TODOLIST
^Enter::
	Gosub, Save
	FocusIndex := LastField
	GuiControl, Focus, % HwndField%FocusIndex%
	AddNewField()
	GuiControl, Focus, % HwndField%FocusIndex%
Return
#IfWinActive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 判断目录是否存在
IsDirExist(DirName)
{
	if (FileExist(DirName))
	{
		if InStr(FileExist(DirName), "D")
			return true
	}

	return false
}

; 给Edit控件加上边框
ShowEditBorder(EditIndex)
{
	EditHwnd := HwndField%EditIndex%
	; 0x800000 = WS_BORDER = Border
	Control, Style, +0x800000,, ahk_id %EditHwnd%
	; 按理说设置样式后，紧跟着WinSet, Redraw就可以了, 但是测试不行
	; 但先禁用后启用，则可以
	Control, Disable,,, ahk_id %EditHwnd%
	Control, Enable,,, ahk_id %EditHwnd%
}

; 去掉Edit控件的边框
HideEditBorder(EditIndex)
{
	EditHwnd := HwndField%EditIndex%
	Control, Style, -0x800000,, ahk_id %EditHwnd%
	Control, Disable,,, ahk_id %EditHwnd%
	Control, Enable,,, ahk_id %EditHwnd%
}

; 点击最后一个Edit控件时，产生一个新的Edit控件
ClickedEdit(wParam, lParam)
{
	global
	wParam := (wParam&0xFFFF0000) >> 16
	if wParam = 0x100
	{
		if (lParam = HwndField%LastField%)
			AddNewField()
	}
	else if wParam = 0x200
	{
  		ClearEmptyFields()
		AddNewField()
	}
}

; 显示一个新的带边框Edit控件
AddNewField()
{
	global
	SetFormat, Integer, D
	if LastField = %FieldCount%
		Return
	LastField++
	ShowEditBorder(LastField)
	GuiControl, Show, Field%LastField%
	GuiControl, Show, Index%LastField%
}

; 隐藏所有内容为空的Edit控件
ClearEmptyFields()
{
	global
	SetFormat, Integer, D
	if LastField = 1
		Return

	VisiableField := LastField

	; 处理到倒数第二行
	Loop, % VisiableField - 1
	{
		; 碰到一个空行，则把其后的所有TODO条目均向上移动一行
		GuiControlGet, EditLine,, Field%A_Index%
		if EditLine = 
		{
			A_Index1 = %A_Index%
			Loop, % VisiableField - A_Index1
			{
				A_Index1++
				GuiControlGet, EditLine,, Field%A_Index1%
				GuiControl,, Field%A_Index1%
				GuiControl,, % "Field" . (A_Index1 - 1), %EditLine%
			}

			; 空行被移动到了最后一行，因此将最后一行隐藏
			GuiControl, Hide, Field%LastField%
			GuiControl, Hide, Index%LastField%
			LastField--
		}
	}

	; 最后一行若为空行，则直接隐藏
	GuiControlGet, EditLine,, Field%LastField%
	if EditLine = 
	{
		GuiControl, Hide, Field%LastField%
		GuiControl, Hide, Index%LastField%
		LastField--
	}
}

