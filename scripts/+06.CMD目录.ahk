;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 在CMD中快速进入指定目录
; 1. 如果当前窗口是"我的电脑"，则进入当前路径
; 2. 如果不是，则进入剪切板中那个路径
;
; gaochao.morgen@gmail.com
; 2014/4/9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TargetDir := ClipBoard

; 如果"我的电脑"窗口位于最前面，则在CMD中进入"我的电脑"那个路径
IfWinActive, ahk_class CabinetWClass
	ControlGetText, TargetDir, Edit1, A		; GuiControlGet始终不行

SplitPath, TargetDir,,,,, OutDrive

Run, cmd.exe
SendInput %OutDrive%{Enter}
SendInput {Raw}cd %TargetDir%
SendInput {Enter}
SendInput clear{Enter}
