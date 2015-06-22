;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 重新启动explorer.exe
; 
; gaochao.morgen@gmail.com
; 2013/7/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoEnv

; 将ErrorLevel置为本脚本PID
Process, Exist

; 获取explorer进程PID，保存在ErrorLevel中
Process, Exist, explorer.exe
PID := ErrorLevel
if (PID)
{
	Process, Close, %PID%
	Process, Wait, %PID%, 5	; 会自动重新启动，如果没有自动重启，则手动重启
	if (ErrorLevel = 0)
		Run, %A_WinDir%\explorer.exe
}
else
{
	Run, %A_WinDir%\explorer.exe
}

