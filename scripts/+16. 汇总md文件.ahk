;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cmd Markdown一键导出的包默认按照Tag进行多目录存储，我需要将所有这些子目录的文件全部集中在一起
; 目录结构类似于:
; Cmd-Markdowns-2016-03-28-20-44
; |-- AngularJS
; |     AngularJS Phonecat示例学习.md
; |     手动创建AngularJS项目.md
; |     模板创建AngularJS项目.md
; |
; |-- Hadoop
; |     RHadoop安装步骤.md
; |     Sqoop1.4.6安装步骤.md
; |     ZooKeeper3.4.6安装步骤.md
; |     大数据工具链.md
;
; gaochao.morgen@gmail.com
; 2016/3/28
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoEnv

BgImage = %A_ScriptDir%/../resources/Cmd.png
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
Gui, Show,, 拖拽目录或者zip文件到窗口中

Return

; 响应文件拖动事件
GuiDropFiles:
	; 提取文件全名
	Loop, parse, A_GuiEvent, `n
	{
		Target := A_LoopField
		if (Target = "")
			Return
	    break
	}

	CurrentDir := Target

	; 如果是zip文件，则新建目录，并解压缩到该目录，再处理
	; 如果是已经解压缩的目录，则直接处理
	SplitPath, Target,, Dir, Ext, FileNoExt
	if (Ext = "zip")
	{
		OutDir = %Dir%\%FileNoExt%
		if (!IsDirExist(OutDir))
			FileCreateDir, %OutDir%
		
		UnzipCmd := GenerateUnzipCommand(Target, OutDir)
		FileAppend, %UnzipCmd%, xxx
		RunWait, cmd /c %UnzipCmd%,, Hide

		CurrentDir := OutDir
	}

	; 2 - 仅针对子目录
	Loop, %CurrentDir%\*, 2
	{
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

GuiClose:
ExitApp

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

; 生成解压缩命令
GenerateUnzipCommand(zipFile, dstDir)
{
	unzipcmd := "7z.exe x "
    unzipcmd .= zipFile
    unzipcmd .= " -o"
    unzipcmd .= dstDir

    Return unzipcmd
}

