;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 在CMD中快速进入指定目录
; 1. 如果当前窗口是"我的电脑"，则进入当前路径
; 2. 如果不是，则进入剪切板中那个路径
;
; 注意: 打开cmd窗口后会自动输入命令，命令均是英文，因此需要设置默认输入语言为英文
;
; gaochao.morgen@gmail.com
; 2014/4/9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TargetDir := ClipBoard

; 如果"我的电脑"窗口位于最前面，则在CMD中进入"我的电脑"那个路径
IfWinActive, ahk_class CabinetWClass
{
	if A_OSVersion in WIN_7, WIN_8
	{
		; 因为Win7地址栏默认没有展开，所以Edit1的值默认是空的，取ToolbarWindow322代替
		ControlGetText, DirDesc, ToolbarWindow322, A
		pos := RegExMatch(DirDesc, "[^:]*: (.*)", Result)
		if (ErrorLevel = 0 && pos > 0)
			TargetDir := Result1
	}
	else ; WIN_VISTA, WIN_2003, WIN_XP, WIN_2000
	{
		ControlGetText, TargetDir, Edit1, A		; GuiControlGet始终不行
	}
	
}

SplitPath, TargetDir,,,,, OutDrive

; 优先启动Cmder，若未安装Cmder则启动cmd
try {
	Run, Cmder.exe,, Max, pid
	Sleep, 1000 ; Cmder比cmd的启动速度慢很多，给它一定时间启动
}
catch
{
	Run, cmd.exe,, Max, pid
}

BringWindowToFront(pid)

/*
Sleep, 100
WinGet, hWnd, ID, ahk_class ConsoleWindowClass	; hWnd - cmd窗口的窗口句柄
SetEnglishIME(hWnd)
*/

SendInput %OutDrive%{Enter}
SendInput {Raw}cd %TargetDir%
SendInput {Enter}
SendInput clear{Enter}	; clear.cmd内容如下, 需要将clear.cmd放入PATH中. cls也可以直接用，但顶端一行空行无法清除

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                  clear.cmd                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; @echo off
; cls %*

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                   函数                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 为指定窗口设置英文输入法
; @param hWnd 窗口句柄
SetEnglishIME(hWnd) {
	DllCall("SendMessage", "UInt", hWnd, "UInt", "80", "UInt", "1", "UInt", (DllCall("LoadKeyboardLayout", "Str", "04090409", "UInt", "257")))
}

; 让指定进程的窗口置顶
BringWindowToFront(pid)
{
	WinSet, AlwaysOnTop, On, ahk_pid %pid%
	Sleep, 100
	WinSet, AlwaysOnTop, Off, ahk_pid %pid%
}

