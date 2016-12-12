;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cmd Markdown一键导出的包默认按照Tag进行多目录存储，我需要将所有这些子目录的文件全部集中在一起
; 并且下载*.md文档中引用的资源(包括图片，附件等)
; 
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
	;ExitApp
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
		RunWait, cmd /c %UnzipCmd%,, Hide

		CurrentDir := OutDir
	}
	else if (Ext = "md")
	{
		MsgBox, 请将所有md文件放置到一个目录中，并将该目录拖动到本程序上
		Return
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
		FileRemoveDir, %A_LoopFileFullPath%, 1
	
	; 查询所有.md文件，找到资源URL
	ParseUrlList()

	; 设置进度条
	Progress, FS8 FM10 H80 W300,, 正在下载资源,, Courier New

	; 统计资源数量
	ResCount := 0
	Loop, Read, url.txt
		ResCount := ResCount + 1
	
	; 依次下载资源
	Loop, Read, url.txt
	{
		; 更新进度条
		Percent := Round(A_Index*100/ResCount)
		Progress, %Percent%, %A_LoopReadLine%

		SplitPath, A_LoopReadLine, name
		dirname := GetDirName(A_LoopReadLine)
		FileCreateDir, %dirname%	; 该目录及其父目录如果不存在，均会创建
		if (ErrorLevel != 0)
		{
			MsgBox, 创建目录失败
			continue
		}

		name := dirname . name
		UrlDownloadToFile, %A_LoopReadLine%, %name%
	}

	Progress,,, 正在打包,, Courier New 

	ZipFile := "resource.zip"
	Progress, 99, %ZipFile%

	; 将资源目录进行压缩，并删除
	Loop, %CurrentDir%\*, 2
	{
		ZipCmd := GenerateZipCommand(A_LoopFileFullPath, ZipFile)
		RunWait, cmd /c %ZipCmd%,, Hide
		FileRemoveDir, %A_LoopFileFullPath%, 1
	}

	; 将url.txt加入压缩文件，并删除
	ZipCmd := GenerateZipCommand("url.txt", ZipFile)
	RunWait, cmd /c %ZipCmd%,, Hide
	FileDelete, url.txt

	ZipFile := FileNoExt . ".zip"
	Progress, 100, %ZipFile%

	; 将*.md文档进行压缩，并删除
	ZipCmd := GenerateZipCommand("*.md", ZipFile)
	RunWait, cmd /c %ZipCmd%,, Hide
	FileDelete, *.md

	Progress, Off

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

; 生成压缩命令
GenerateZipCommand(dir, zipFile)
{
    zipcmd := "7z.exe a "
    zipcmd .= zipFile
    zipcmd .= " "
    zipcmd .= dir

    Return zipcmd
}

; 从*.md文件中解析所有资源的URL
ParseUrlList()
{
	; 采用PCRE正则. 匹配的字符串格式为"[1]: http://static.zybuluo.com/morgen/9nvm3lj1u4hjc5zk3h4iu79r/bash.png"
	; 这是Cmd Markdown特有的格式，上传到服务器上的资源均采用这种格式
	; 按理说，保存为url.txt后，使用"wget -p -i url.txt"即可以下载全部资源，然而Windows下的wget并不能很好地处理中文URL，因此放弃wget
	; -H 总是打印文件名. 只有一个文件时默认不打印，会对解析造成影响
	cmd := "grep -P -H ""\[\d+\]: [a-zA-z]+://[^\s]*\.[a-zA-Z]{3,4}$"" *.md | gawk ""BEGIN{FS=\"": \""} {print $3}"" > url.txt"
	RunWait, cmd /c %cmd%,, Hide

	; 匹配的字符串格式为"![cmd-markdown-logo](https://www.zybuluo.com/static/img/logo.png)"
	; 这是外链格式，适合外部图床. 追加到url.txt中. 这种模式下仅考虑图片资源
	cmd := "grep -P -H ""\([a-zA-z]+://[^\s]*\.(png|PNG|jpg|JPG|jpeg|JPEG)\)"" *.md | gawk ""BEGIN{FS=\""[()]\""} {print $2}"" >> url.txt"
	RunWait, cmd /c %cmd%,, Hide
}

; 从URL中解析目录结构
GetDirName(url)
{
	StringGetPos, pos1, url, //	    	; "//"的位置
	StringGetPos, pos2, url, /, R1  	; 从右开始，第1个"/"的位置
	dir := SubStr(url, pos1+1+2, pos2-pos1-1)
	StringReplace, out, dir, /, \, All	; 
	Return out
}


