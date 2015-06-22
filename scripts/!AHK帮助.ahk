;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 一键启动AHK帮助文件，并检索剪切板中的内容
; 注意: 跟使用的AutoHotkey.chm有关系，不同版本的chm可能搜索框的classNN不同
; 我所使用的是: http://sourceforge.net/projects/ahkcn/
; 版本为: v1.1.13.01
; 
; Alt + H: 在AHK帮助文件中查找剪切板内容
;
; gaochao.morgen@gmail.com
; 2014/2/4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/SystemCursor.ahk

#SingleInstance Force	; 跳过对话框并自动替换旧实例
#NoTrayIcon				; 不显示托盘图标
#NoEnv					; 不检查空变量是否为环境变量（建议所有新脚本使用）

OnExit, ShowCursor		; 确保到脚本退出时鼠标光标是显示的

; Alt + H
!h::
	IfWinExist, ahk_class HH Parent
	{
	    WinActivate  ; 自动使用上面找到的窗口.
	    WinMaximize  ; 同上
		Sleep, 200
	}
	else
	{
		Run, %ProgramFiles%\AutoHotkey\AutoHotkey.chm,, Max
		Sleep, 700
		WinActivate
	}

	MouseGetPos, X, Y	; 获取鼠标原来的位置
	SystemCursor("Off")	; 隐藏鼠标，否则眼睛受不了

	; 测试发现，CHM文件Edit控件的ClassNN会发生变化，所以先移动到控件位置获取其ClassNN
	MouseMove, 100, 150
	MouseGetPos,,,, CtrlHwnd

	Send !n				; Alt+N 切换到索引标签
	ControlSetText, %CtrlHwnd%, %ClipBoard%, ahk_class HH Parent	; 设置搜索框内容
	Send {Enter} 		; 回车确认检索

	MouseMove, %X%, %Y% ; 到达文本正文
	SystemCursor("On")	; 恢复鼠标
Return

ShowCursor:
	SystemCursor("On")
ExitApp
