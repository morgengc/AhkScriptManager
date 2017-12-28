;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 在 CmdMarkdown 执行全文替换，使得中文和英文之间留出一个空格
; 注意 CmdMarkdown 使用的是 JavaScript 的正则表达式语法
; 
; 使用时，CmdMarkdown 必须位于 Vim 编辑器模式
; 按下 ":" 后再按 Ctrl+L 在英文左边加一个空格
; 按下 ":" 后再按 Ctrl+R 在英文右边加一个空格
; 按上面顺序执行完毕后，中英文间的空格替换完成
; 
; 快捷键: Ctrl+L，完成左边加空格；Ctrl+R，完成右边加空格
;
; gaochao.morgen@gmail.com
; 2017/3/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

; Ctrl + L
#IfWinActive ahk_class Chrome_WidgetWin_0
^l::
	Clipboard := "%s/([^A-z0-9 -@.:<>!\/\[\](){}|'`，。！、；：“‘（）])([A-Za-z0-9%``])/$1 $2/g"
	Send ^v
	Clipboard := 
Return

; Ctrl + R
#IfWinActive ahk_class Chrome_WidgetWin_0
^r::
	Clipboard := "%s/([A-Za-z0-9%``])([^A-z0-9 -@.:<>!\/\[\](){}|'`，。！、；：“‘（）])/$1 $2/g"
	Send ^v
	Clipboard := 
Return

