;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 一键锁屏并让屏幕关闭，节约用电
; 
; Win + L: 锁屏并关闭屏幕
;
; gaochao.morgen@gmail.com
; 2014/2/4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoTrayIcon
#NoEnv

; Win + L
#l::
	; Lock Screen. 模拟Win+L没有成功，执行后Win似乎一直处于按下状态
	Run, %A_WinDir%\System32\rundll32.exe user32.dll LockWorkStation 

	Sleep, 500

	; Power off the screen
	; 0x112: WM_SYSCOMMAND
	; 0xF170: SC_MONITORPOWER
	; 2: the display is being shut off
	SendMessage, 0x112, 0xF170, 2,, Program Manager
Return
