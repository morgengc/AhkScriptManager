;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 打开我的电脑，并且不选中"文件夹"
; 
; Win + E: 打开我的电脑
;
; gaochao.morgen@gmail.com
; 2014/2/4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoTrayIcon
#NoEnv

; Win + E
#e::
	Run, ::{20d04fe0-3aea-1069-a2d8-08002b30309d},, Max
Return
