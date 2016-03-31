;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 自动关闭QQ右下角弹窗
;
; 稻米鼠的板块
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

; 若配置文件目录不存在，则创建
LogPath = %A_ScriptDir%\..\log
if (!IsDirExist(LogPath))
	FileCreateDir, %LogPath%

; 日志文件
LogFile = %LogPath%\QQPopLog.txt

SetTimer, KillQQPop, 1000
return

KillQQPop:
	IfWinExist, ahk_class TXGuiFoundation
	{
		;sleep 1000
		WinGetPos, Xpos, Ypos, Width, Height
		if (Width < 400 AND A_ScreenWidth <(Xpos + 400) AND A_ScreenHeight <(Ypos + 400))
		{
			WinGetTitle, Title
			if (StrLen(Title)!= 0 AND Title!= "QQ" AND !(Title~="@") AND !(Title~="(") AND !(Title="TXMenuWindow"))
			{
				WinClose
				;TrayTip,喵了腾讯, 关闭了 %Title%
				file := FileOpen(LogFile, "a")
				file.WriteLine(A_YYYY " " A_MM " " A_DD " " A_Hour ":" A_Min ":" A_Sec " —— " Title  "`n`r")
				file.Close()
				;sleep 1000
				;TrayTip
			}
		}
	}
Return

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

