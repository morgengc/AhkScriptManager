;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 统计字符数. 小众计数器未提供源码，自己实现
;
; F12: 统计当前选中文字中的中英文单词数
;
; gaochao.morgen@gmail.com
; 2015/6/21
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

; 英文标点符号
global Symbols := "^[:;,_!'\-\\\.\*\?\+\[\{\|\(\)\^\$]"
global ToolTipX := A_ScreenWidth / 2
global ToolTipY := A_ScreenHeight / 2

F12::
	ClipSaved := ClipboardAll   ; 保存剪切板的内容

	; 把当前选中的文本拷贝到剪切板，然后统计剪切板的内容
	ClipBoard :=  
	Send ^c 
	ClipWait, 5 

	ChCount := ChineseCount(ClipBoard)
	EnCount := EnglishCount(ClipBoard)

	ClipBoard := ClipSaved 		; 恢复剪切板的内容

	ToolTip, % ShowResult(ChCount, EnCount), %ToolTipX%, %ToolTipY%
	SetTimer, RemoveToolTip, 3000
Return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 统计中文字符
ChineseCount(Input)
{
	Count := 0
	
	; AHKL对一个UTF-8编码的汉字，会循环2次
	Loop, Parse, Input
	{
		if A_LoopField is alnum	; 仅当A_LoopField包含[0-9a-zA-Z]时为真
		{
			continue
		}
		else if A_LoopField is space
		{
			continue
		}
		else
		{
			pos := RegExMatch(A_LoopField, Symbols)
			if (ErrorLevel = 0 && pos > 0)
				continue
			else
				Count := Count + 1
		}
	}

	Return Count
}

; 统计英文字符
EnglishCount(Input)
{
	StringReplace, Input, Input, ', x, All	; It's -> Itxs，视为一个单词
	StringReplace, Input, Input, -, x, All	; well-defined -> wellxdefined，视为一个单词
	RegExReplace(Input, "\w+", "", Count) 	; PhiLho 

	Return Count
}

; 显示统计结果
ShowResult(ChCount, EnCount)
{
	Result := "中文: "
	Result .= ChCount
	Result .= "`r`n"
	Result .= "英文: "
	Result .= EnCount
	Result .= "`r`n"
	Result .= "总共: "
	Result .= ChCount + EnCount

	Return Result
}

