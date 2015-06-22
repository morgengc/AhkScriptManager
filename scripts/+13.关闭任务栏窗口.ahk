;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 一键关闭任务栏上的所有打开窗口
; 
; gaochao.morgen@gmail.com
; 2014/5/22
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/Taskbar.ahk

#SingleInstance Force
#NoEnv

SetBatchLines, -1

CloseAllWindow()
Return

CloseAllWindow()
{
	static WM_SETREDRAW = 0xB 
	TaskbarHwnd := Taskbar_GetHandle()
	SendMessage, WM_SETREDRAW, 0,,, ahk_id %TaskbarHwnd%

	; 获取当前任务栏所有按钮所属窗口的HWND
	HwndsStr := Taskbar_Define("", "w") "`n"

	StringSplit, WindowHwnd, HwndsStr, `n
	Loop %WindowHwnd0%
	{
		Hwnd := WindowHwnd%A_Index%
		WinClose, ahk_id %Hwnd%
	}

	SendMessage, WM_SETREDRAW, 1,,, ahk_id %TaskbarHwnd%
}

