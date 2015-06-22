;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 启用虚拟桌面
; 
; virgo是一个开源项目，我修改了源代码使其能够运行在XP上
;
; Alt + 1: 切换到桌面1
; Alt + 2: 切换到桌面2
; Ctrl + 1: 发送到桌面1
; Ctrl + 2: 发送到桌面2
; 
; gaochao.morgen@gmail.com
; 2015/6/1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

OnExit, ExitSub

Run, ../3rd/virgo.exe,, Hide
Return 

ExitSub:
	Process, Close, virgo.exe
ExitApp
