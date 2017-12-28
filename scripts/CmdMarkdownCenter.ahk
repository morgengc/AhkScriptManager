;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 在 CmdMarkdown 中一键插入<center>标签，使图像居中显示
; 
; 快捷键: F9  使整行内容居中
; 快捷键: F10 为整行添加下划线
;
; gaochao.morgen@gmail.com
; 2016/12/14
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/HexDec.ahk

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

#IfWinActive ahk_class Chrome_WidgetWin_0
F9::
	; hWnd - CmdMarkdown的窗口句柄
	WinGet, hWnd, ID, ahk_class Chrome_WidgetWin_0
	CurrentIME := GetCurrentIME(hWnd)
	SetEnglishIME(hWnd)

	; 为当前行加入<center></center>标签对
	Send {Esc}
	Send {RShift}{^}
	Send {}
	SendInput {Raw}i<center>
	Send {Esc}
	Send {RShift}{$}
	SendInput {Raw}a</center>
	Send {Enter 1}

	; 恢复之前的输入法
	SetIME(CurrentIME, hWnd)
Return 

#IfWinActive ahk_class Chrome_WidgetWin_0
F10::
	; hWnd - CmdMarkdown的窗口句柄
	WinGet, hWnd, ID, ahk_class Chrome_WidgetWin_0
	CurrentIME := GetCurrentIME(hWnd)
	SetEnglishIME(hWnd)

	; 为当前行加入下划线标签对<span style="border-bottom:1px solid black;"></span>
	Send {Esc}
	Send {RShift}{^}
	Send {}
	SendInput {Raw}i<span style="border-bottom:1px solid black;">
	Send {Esc}
	Send {RShift}{$}
	SendInput {Raw}a</span>
	Send {Enter 1}

	; 恢复之前的输入法
	SetIME(CurrentIME, hWnd)
Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 为指定窗口设置英文输入法
; @param hWnd 窗口句柄
SetEnglishIME(hWnd) {
	SetIME("04090409", hWnd)
}

; 获取指定窗口当前的输入法
; @param hWnd 窗口句柄
; @return 输入法对应的十六进制数字符串，无0x前缀
GetCurrentIME(hWnd) {
	dec := DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "UInt", hWnd, "UIntp", 0), UInt)
	hex := Dec2Hex(dec)
	StringTrimLeft, layout, hex, 2
	Return layout
}

; 设置指定窗口的输入法
; @param Layout	输入法代码
; @param hWnd	窗口句柄
SetIME(Layout, hWnd) {
	DllCall("SendMessage", "UInt", hWnd, "UInt", "80", "UInt", "1", "UInt", (DllCall("LoadKeyboardLayout", "Str", Layout, "UInt", "257")))
}

