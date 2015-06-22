;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IBM笔记本ESC键映射F1键
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance, Force
#NoTrayIcon
#NoEnv

#IfWinActive ahk_class WSGAME
~Esc::
	Send {F1}
	;Sleep 200
	;Send {Tab}
Return
