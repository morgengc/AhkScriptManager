;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 自定义Obsidian快捷键
; 注意Obisidan必须位于Vim编辑器模式
; 
; 快捷键: F8  新建文档后加入作者、时间
; 快捷键: F9  一键插入<center>标签，使整行内容居中
; 快捷键: F10 为整行添加下划线
; 快捷键：F11 在整篇文章的中文和英文之间加入空格
;
; gaochao.morgen@gmail.com
; 2023/12/14
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/SwitchIME.ahk

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       快捷键                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 针对 Obsidian
; 新建文档后加入作者、时间
#IfWinActive ahk_class Chrome_WidgetWin_1
F8::
	; hWnd - CmdMarkdown的窗口句柄
	WinGet, hWnd, ID, ahk_class Chrome_WidgetWin_1
	CurrentIME := GetCurrentIME(hWnd)
	;MsgBox, % CurrentIME
	SetEnglishIME(hWnd)

	; 添加创建时间
	Send {Esc}
	Send {1}{G}
	SendInput {Raw}i
	Send {Enter}
	SendInput %A_YYYY%-%A_MM%-%A_DD%
	Send {Enter 2}
	SendInput {Raw}#
	Send {Enter 2}
	SendInput ---
	Send {Enter}
	Send {Esc}

	; 定位到#那一行
	Send {4}{G}

	; 恢复之前的输入法
	SetIME(CurrentIME, hWnd)
Return

; 针对 Obsidian
; 一键插入<center>标签，使整行内容居中
#IfWinActive ahk_class Chrome_WidgetWin_1
F9::
	; hWnd - CmdMarkdown的窗口句柄
	WinGet, hWnd, ID, ahk_class Chrome_WidgetWin_1
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

; 针对 Obsidian
; 为整行添加下划线
#IfWinActive ahk_class Chrome_WidgetWin_1
F10::
	; hWnd - CmdMarkdown的窗口句柄
	WinGet, hWnd, ID, ahk_class Chrome_WidgetWin_1
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

; 针对 Obsidian
; 快捷键：F11 在中文和英文之间加入空格
#IfWinActive ahk_class Chrome_WidgetWin_1
F11::
	; hWnd - CmdMarkdown的窗口句柄
	WinGet, hWnd, ID, ahk_class Chrome_WidgetWin_1
	CurrentIME := GetCurrentIME(hWnd)
	SetEnglishIME(hWnd)

	; 在英文左边加空格
	LeftSpaceCommand := "%s/([^A-z0-9 -@.:<>!\/\[\](){}|'`，。！、；：“‘（）])([A-Za-z0-9%``])/$1 $2/g"
	ExecuteCommand(LeftSpaceCommand)

	; 在英文右边加空格
	RightSpaceCommand := "%s/([A-Za-z0-9%``])([^A-z0-9 -@.:<>!\/\[\](){}|'`，。！、；：“‘（）])/$1 $2/g"
	ExecuteCommand(RightSpaceCommand)

	; 恢复之前的输入法
	SetIME(CurrentIME, hWnd)
Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 在Obsidian中执行自定义操作
; 注意必须处于vim模式当中
ExecuteCommand(Command) {
	Clipboard := Command
	Send {Esc}					; 进入正常模式
	Send {RShift}{:}			; 进入命令模式
	Send ^v						; Ctrl+V，粘贴
	Send {Enter 1}				; 执行
	Send {Esc}					; 进入正常模式
	Clipboard :=
}

