;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 双击快速启动/停止Oracle服务
; 
; gaochao.morgen@gmail.com
; 2014/2/24
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/StdoutToVar.ahk

#SingleInstance Force
#NoTrayIcon
#NoEnv

Gui, Font,, Arial
Gui, Font, s10
Gui, Add, ListView, -Multi x2 y0 w350 h350 gFastOperate, Index|Service|Status

; 刷新ListView
Gosub, REFRESH

Gui, Show,, Oracle Service List
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 刷新ListView
REFRESH:
	LV_Delete()	; 清空列表内容

	scCmd := "sc.exe queryex state= all"	; 获取所有服务的数据
	sc := StdoutToVar_CreateProcess(scCmd)	; 命令输出从stdout定向到变量中
	idx := 0
	pos := 0
	
	Loop, Parse, sc, `n, `r
	{
		If A_LoopField=
			Continue
		IfInString, A_LoopField, SERVICE_NAME:
		{
			StringGetPos, pos, A_LoopField, :
			pos+=1
			StringTrimLeft, service_name, A_LoopField, %pos%
			Continue
		}
		IfInString, A_LoopField, STATE              :
		{
			StringGetPos, pos, A_LoopField, :
			pos+=6
			StringMid, state, A_LoopField, %pos%, 7
			StringLower, state, state, T
			IfInString, service_name, OracleService		; 过滤Oracle服务
			{
				idx++
				LV_Add("", idx, service_name, state)
			}
			;IfInString, service_name, OracleOraDb11g_home1TNSListener	; 过滤Listener
			IfInString, service_name, TNSListener	; 过滤Listener
			{
				idx++
				LV_Add("", idx, service_name, state)
			}
			Continue
		}
	}
	
	LV_ModifyCol()  ; 根据内容自动调整每列的大小
Return

; 双击时快速切换服务状态(未启动则启动，已启动则关闭)
FastOperate:
	if A_GuiEvent = DoubleClick
	{
	    LV_GetText(SrvName, A_EventInfo, 2)		; 从第二个字段中获取文本.
	    LV_GetText(SrvStatus, A_EventInfo, 3)	; 从第三个字段中获取文本.
		if (SrvStatus = "Running")
		{
			RunWait, cmd /c net stop %SrvName%
			Gosub, REFRESH
		}
		else
		{
			RunWait, cmd /c net start %SrvName%
			Gosub, REFRESH
		}
	}
Return

; 当窗口关闭时, 自动退出脚本
GuiClose:
	Gui, Destroy
ExitApp
