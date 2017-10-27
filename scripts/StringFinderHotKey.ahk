;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 打开 String Finder 后，按快捷键搜索
; 
; Ctrl+Enter: 搜索   
;
; gaochao.morgen@gmail.com
; 2017/3/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/SystemCursor.ahk

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

; Ctrl + Enter
#IfWinActive ahk_class #32770
^Enter::
	WinMaximize
	ControlClick, Button1 ; 点击"开始"进行搜索

	; 等待搜索结果
	WinWait, Findstr
	{
		;MsgBox, YES
		ControlClick, Button2 ; 点击"否"
		Sleep, 800
		WinActivate, String Finder
	}

	SystemCursor("Off")
	; 不知道什么原因，在WinWait之后就无法获取控件坐标了
	;;;ControlGetPos, X, Y, W, H, SysHeader321 ; , ahk_class #32770; 标题栏控件坐标
	;;;;MsgBox, %X% + %Y% + %W% + %H%
	;;;MouseMove, % X+579, % Y+5	; 控件分隔处
	MouseMove, 596, 429
	Send {LButton 2}			; 双击，长度最大化
	SystemCursor("On")
Return

