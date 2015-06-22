;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 事先拷贝注册表路径，该脚本直接定位到那个路径
; 
; gaochao.morgen@gmail.com
; 2014/2/4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoTrayIcon
#NoEnv

StringReplace, Clipboard, Clipboard, ＼, \, All			; 网络文章"＼","\"不分
StringReplace, Clipboard, Clipboard, /, \, All			; "/"改为"\"
StringReplace, Clipboard, Clipboard, \\, \, All			; "/"改为"\"
Clipboard := RegExReplace(Clipboard, "\\$", "")			; 若最后一个字符为"\"则去掉

; 本想先探测是否存在改键，但是此方法无法判断出"(默认)"为空的项
;pos := RegExMatch(Clipboard, "HKEY_(.*?)\\", RootKey)	; "我的电脑\HKEY_CURRENT_USER\Software"与"HKEY_CURRENT_USER\Software"一样
;SubKey := SubStr(Clipboard, pos+StrLen(RootKey))
;StringReplace, RootKey, RootKey, \, , All
;
;RegRead, content, %RootKey%, %SubKey%
;if (content = null && ErrorLevel = 1)
;{
;	MsgBox, %Clipboard% is not found.
;	Return
;}

; 关闭已经打开的注册表
IfWinExist, ahk_class RegEdit_RegEdit
{
	WinClose 
    WinWaitClose
}

; 写入
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %Clipboard%

; 打开，自动定位到写入位置
Run, regedit,, Max
ExitApp

