;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 一键启动服务窗口
; 
; gaochao.morgen@gmail.com
; 2014/2/4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/SystemCursor.ahk

#SingleInstance Force
#NoTrayIcon
#NoEnv

OnExit, ShowCursor			; 确保到脚本退出时鼠标光标是显示的.

Run, services.msc			; Max参数不能最大化
Sleep, 800
WinActivate, ahk_class MMCMainFrame
Send {Alt Down}{Space}x		; 测试"!{Space}x"不行，只能让Alt按下
Send {Alt Up}				; 再把Alt弹起
SystemCursor("Off")
ControlGetPos, X, Y,,, SysListView321, ahk_class MMCMainFrame	; 标题栏控件坐标
MouseMove, % X+125, % Y+5	; 控件分隔处
Send {LButton 2}			; 双击，长度最大化
ControlGetPos, X, Y,,, SysListView321, ahk_class MMCMainFrame
MouseMove, % X+300, % Y+300	; 内容区域
Send {LButton}
SystemCursor("On")
Return

ShowCursor:
	SystemCursor("On")
ExitApp

