;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 从所有子目录拷贝文件到一个目录
; Cmd Markdown一键导出的包默认按照Tag进行多目录存储，我需要将所有这些子目录的文件全部集中在一起
;
; gaochao.morgen@gmail.com
; 2016/3/28
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoEnv

BgImage := A_ScriptDir . "/../resources/Cmd.png"
if (!FileExist(BgImage))
{
	MsgBox, % BgImage . "未找到"
	ExitApp
}

; +Owner，任务栏中不出现，ALT-TAB中出现. -Owner，任务栏中出现，ALT-TAB中出现. 默认是-Owner
; +LastFound "上次找到的" 窗口, 让脚本更容易创建和维护
Gui, -Owner +LastFound 

; 设置在没有为控件指定明确的位置时使用的边距/间隔
Gui, Margin, 0, 0

Gui, Add, Picture, vCanvas, %BgImage%
Gui, Show,, 拖拽目录到窗口中

Return

; 响应文件夹拖动事件
GuiDropFiles:
	; 提取文件夹全名
	Loop, parse, A_GuiEvent, `n
	{
		CurrentDir := A_LoopField
		if (CurrentDir = "")
			Return
	    break
	}

	;MsgBox, %CurrentDir%

	; 2 - 仅从子目录中移动文件
	Loop, %CurrentDir%\*, 2
	{
		;MsgBox, %A_LoopFileFullPath%
		SetWorkingDir %A_LoopFileFullPath%
	
		; 依次移动每个文档
		Loop, %A_LoopFileFullPath%\*.md
			MoveMdToDir(A_LoopFileName, CurrentDir, A_LoopFileName)
	}

	SetWorkingDir %CurrentDir%

	; 删除所有子目录
	Loop, %CurrentDir%\*, 2
		FileRemoveDir, %A_LoopFileFullPath%

	SetWorkingDir %A_ScriptDir%
	MsgBox, 全部md文件已经汇总完成
Return

Esc::
q::
	Gosub GuiClose
Return

GuiClose:
ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 将指定文件拷贝到指定目录，并且重命名
MoveMdToDir(OrigName, TargetDir, TargetName := "")
{
	; 源文件不存在，记录错误
	if (!FileExist(OrigName))
	{
		FileAppend, % OrigName . "不存在", Error.log
		FileAppend, `n, Error.log
		Return
	}

	; 目录不存在则创建
	IfNotExist, %TargetDir%
		FileCreateDir, %TargetDir%

	if (TargetName != "")
		TargetName := TargetDir . "\" . TargetName
	else
		TargetName := TargetDir . "\" . OrigName
	
	; 移动源文件到新文件. 覆盖模式
	FileMove, %OrigName%, %TargetName%, 1
	if (ErrorLevel != 0)
	{
		FileAppend, % OrigName . "移动到" . TargetName . "失败", Error.log
		FileAppend, `n, Error.log
		Return
	}
}

