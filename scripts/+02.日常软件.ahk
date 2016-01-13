;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 一键启动日常必备程序
; 需要人为指定第几秒启动哪个程序
; 
; gaochao.morgen@gmail.com
; 2013/7/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoEnv

; 设置 ErrorLevel 为这个正在运行脚本的 PID
Process, Exist

ExeList := Object()

; 采用Object.Insert(Index, Value)的方式，Index表示第几秒启动，Value表示程序
ExeList.Insert(0, "E:\DeskWidget\DeskWidget.exe")
ExeList.Insert(5, "C:\Program Files\Tencent\QQ\Bin\QQ.exe")

Delay := 0
Elapse := 0

for Seconds, Target in ExeList
{
	Delay := (Seconds - Elapse) * 1000
	SplitPath, Target, ProcName

	CoordMode, ToolTip, Screen  ; 把ToolTips放置在相对于屏幕坐标的位置
	ToolTip, Launching %ProcName%, (A_ScreenWidth/2-100), A_ScreenHeight/2
	Sleep, 1000

	; 若进程未启动则启动，若已启动则不作任何改动
	Process, Exist, %ProcName%
	if (ErrorLevel = 0)
	{
		Sleep, %Delay%
		Run, %Target%
	}

	Elapse := ((Seconds-1)>0)?Seconds:0
}

ExitApp	

