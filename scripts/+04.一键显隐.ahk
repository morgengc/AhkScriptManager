;------------------------------------------------------------------------
; Show hidden folders and file extension in Windows XP
; 注意：
; 	1. 事先确保Hidden=2，同时HideFileExt=1(或者Hidden=1，同时HideFileExt=0)
; 	2. 要修改注册表以实现文件显隐、后缀显隐，因此需要关闭防火墙和杀毒软件才有效果.
;------------------------------------------------------------------------
; User Key: [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
; Value Name: Hidden
; Data Type: REG_DWORD (DWORD Value)
; Value Data: (1 = show hidden, 2 = do not show)
;
; User Key: [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
; Value Name: HideFileExt
; Data Type: REG_DWORD (DWORD Value)
; Value Data: (0 = show hidden, 1 = do not show)
;

#SingleInstance Force
#NoEnv

; 文件夹显隐
RegRead, ShowHidden_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
if ShowHidden_Status = 2
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
Else
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2

; 后缀名显隐
RegRead, FileExt_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
If FileExt_Status = 1 
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
Else 
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1

; 获取指定窗口的类名
WinGetClass, CabinetWClass

; 刷新desktop/explorer
PostMessage, 0x111, 28931,,, A
PostMessage, 0x111, 28931,,, ahk_class Progman

