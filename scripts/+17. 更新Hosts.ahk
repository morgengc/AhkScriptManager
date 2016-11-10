;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 自动更新Hosts文件
; 源项目参见 https://github.com/racaljk/hosts
;
; gaochao.morgen@gmail.com
; 2016/11/10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

SetWorkingDir %A_ScriptDir%

FileEncoding, UTF-8-RAW

SYSHOSTS := "C:\Windows\System32\drivers\etc\hosts"
URL := "https://raw.githubusercontent.com/racaljk/hosts/master/hosts"

; 手动添加 raw.githubusercontent.com 的IP，否则从这个网站下载文件很困难
; 至于这个IP，可以从 http://tool.chinaz.com/dns 上查询，选择速度快的一个
FileAppend, 
(
`r
151.101.100.133 raw.githubusercontent.com
), % SYSHOSTS

; 刷新DNS
RunWait, cmd /c "ipconfig /flushdns",, Hide

; 下载 hosts 文件
ToolTipX := A_ScreenWidth / 2
ToolTipY := A_ScreenHeight / 2
ToolTip, 正在下载 Hosts 文件, %ToolTipX%, %ToolTipY%
SetTimer, RemoveToolTip, 1000

HostsFile := A_Temp "\hosts"

try {
	URLDownloadToFile, % URL, % HostsFile
	if (ErrorLevel == 1)
		throw Exception("Fail", -1)
}
catch
{
	MsgBox, 下载失败，请重新尝试
	ExitApp
}

FileAppend, 
(
`r
10.65.6.22 BigData1637
10.65.6.33 BigData1635
151.101.100.133 assets-cdn.github.com
151.101.100.133 raw.githubusercontent.com
), % HostsFile

; 备份原来的hosts文件
backupCmd := "copy "
backupCmd .= SYSHOSTS
backupCmd .= " "
backupCmd .= SYSHOSTS
backupCmd .= A_Now
RunWait, cmd /c %backupCmd%,, Hide

; 将新的hosts文件拷贝到系统路径
copyCmd := "copy /Y "
copyCmd .= HostsFile
copyCmd .= " "
copyCmd .= SYSHOSTS
RunWait, cmd /c %copyCmd%,, Hide

; 刷新DNS
RunWait, cmd /c "ipconfig /flushdns",, Hide

MsgBox, 更新完毕!
ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
Return

