;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 蓝蓝小雪 作品
; http://wwww.snow518.cn/
; 修改自：http://ahk.5d6d.com/thread-701-1-3.html
; 增加了快捷键、编辑、重载某个单独的脚本
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Ctrl + Alt + 左键    唤出"启动脚本"菜单
; Ctrl + Alt + 中键    唤出"重载脚本"菜单
; Ctrl + Alt + 右键    唤出"关闭脚本"菜单
; Ctrl + Alt + A       关闭所有脚本
;
; 注意: 当更新系统环境变量时，需要退出本程序后再重启，才能使得环境变量的更改有效
;
; 删除一些不必要的功能，增加非驻守脚本(文件名以"+"开头)的处理
; gaochao.morgen@gmail.com
; 2014/2/1
;
; 增加菜单排序功能
; gaochao.morgen@gmail.com
; 2014/2/10
;
; 增加进程PID显示
; gaochao.morgen@gmail.com
; 2014/2/13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include lib/InsertionSort.ahk

#Persistent
#SingleInstance force

SetWorkingDir %A_ScriptDir%\scripts\

DetectHiddenWindows On  ; 允许探测脚本中隐藏的主窗口. 很多子程序均是以隐藏方式运行的
SetTitleMatchMode 2     ; 避免需要指定如下所示的文件的完整路径

EnvGet, Paths, PATH
EnvSet, PATH, %A_ScriptDir%\3rd`;%Paths%	; 设置环境变量. 通过AhkScriptManager启动的程序均持有该环境变量

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     初始化                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

scriptCount = 0

OnExit ExitSub

GoSub CreateMenus

OpenList := Array()
UnOpenList := Array()

; 遍历scripts目录下的ahk文件
Loop, %A_ScriptDir%\scripts\*.ahk
{
	StringTrimRight, menuName, A_LoopFileName, StrLen(".ahk")
    scriptCount += 1

    ; 已经打开则关闭，否则无法被AHK Manager接管
    IfWinExist, %A_LoopFileName% - AutoHotkey
    {
        scriptsExisted%scriptCount% = 1
        WinKill
    }

    scriptsName%scriptCount% := A_LoopFileName
    scriptsOpened%scriptCount% = 0
    UnOpenList.Insert(menuName)
}

InsertionSort(UnOpenList)
for Index, menuName in UnOpenList
{
    Menu, scripts_unopen, add, %menuName%, tsk_open
}

; 主菜单
Menu, Tray, Icon, %A_ScriptDir%\resources\ahk.ico
Menu, Tray, Click, 1
Menu, Tray, Tip, AHK Script Manager
Menu, Tray, Add, AHK Script Manager, Menu_Show
Menu, Tray, ToggleEnable, AHK Script Manager
Menu, Tray, Default, AHK Script Manager
Menu, Tray, Add
Menu, Tray, Add, 启动脚本(&S)`tCtrl + Alt + 左键, :scripts_unopen           ; S: Start
Menu, Tray, Add
Menu, Tray, Add, 重载脚本(&R)`tCtrl + Alt + 中键, :scripts_restart          ; R: Restart
Menu, Tray, Add, 关闭脚本(&C)`tCtrl + Alt + 右键, :scripts_unclose          ; C: Close
Menu, Tray, Add, 关闭所有脚本(&A)`tCtrl + Alt + A, tsk_closeAll             ; A: All
Menu, Tray, Add
Menu, Tray, Add, 进程管理(&P), tsk_showproc                                 ; P: Process
Menu, Tray, Add
Menu, Tray, Add, 打开源码目录(&D), Menu_Tray_OpenDir                        ; D: Directory
Menu, Tray, Add
Menu, Tray, Add, 重启Manager(&B), Menu_Tray_Reload                          ; B: reBoot
Menu, Tray, Add
Menu, Tray, Add, 退出(&X)`tCtrl + Alt + X, Menu_Tray_Exit
Menu, Tray, NoStandard

; 程序启动时，加载所有可启动脚本
GoSub tsk_openAll

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     快捷键设置                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Ctrl + Alt + LButton, 启动
^!LButton::
    Menu, scripts_unopen, Show
Return

; Ctrl + Alt + RButton, 关闭
^!RButton::
    Menu, scripts_unclose, Show
Return

; Ctrl + Alt + MButton, 重载
^!MButton::
    Menu, scripts_restart, Show
Return

; Ctrl + Alt + A, 关闭所有
^!A::
    Goto tsk_closeAll
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     菜单事件响应                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 启动选中脚本
tsk_open:
    Loop, %scriptCount%
    {
        thisScript := scriptsName%A_Index%
        if thisScript = %A_ThisMenuItem%.ahk
        {
            IfWinNotExist, %thisScript% - AutoHotkey    ; 没有打开
                Run, %A_ScriptDir%\scripts\%thisScript%
    
            IfInString, thisScript, + ; 文件名中含"+"表示非驻守脚本，执行完会立即退出
                Break
    
            scriptsOpened%A_Index% := 1
            Break
        }
    }
GoSub RecreateMenus
Return

; 关闭选中脚本
tsk_close:
    Loop, %scriptCount%
    {
        thisScript := scriptsName%A_Index%
        if thisScript = %A_ThisMenuItem%.ahk
        {
            WinClose, %thisScript% - AutoHotkey
            scriptsOpened%A_Index% := 0
            Break
        }
    }
    GoSub RecreateMenus
Return

; 重新启动选中脚本
tsk_restart:
    Loop, %scriptCount%
    {
        thisScript := scriptsName%A_Index%
        if thisScript = %A_ThisMenuItem%.ahk
        {
            WinClose, %thisScript% - AutoHotkey
            Run, %A_ScriptDir%\scripts\%thisScript%
            Break
        }
    }
Return

; 启动所有可自启动脚本，从读文件开始就已经被排序了，所以无需排序
tsk_openAll:
    Loop, %scriptCount%
    {
        thisScript := scriptsName%A_Index%
        if scriptsOpened%A_Index% = 0 ; 没打开
        {
            IfInString, thisScript, ! ; 文件名中含"!"表示不自动启动脚本，则不启动
            {
                if scriptsExisted%A_Index% != 1 ; AHK Manager启动前该脚本未启动
                    continue
            }
    
            IfInString, thisScript, + ; 文件名中含"+"表示非驻守脚本，不启动
            {
                if scriptsExisted%A_Index% != 1
                    continue
            }
    
            IfWinNotExist, %thisScript% - AutoHotkey ; 没有打开
            {
                Run, %A_ScriptDir%\scripts\%thisScript%
    
                scriptsOpened%A_Index% = 1
                StringRePlace, menuName, thisScript, .ahk
                Menu, scripts_unclose, Add, %menuName%, tsk_close
                Menu, scripts_restart, Add, %menuName%, tsk_restart
                Menu, scripts_unopen, Delete, %menuName%
            }
        }
    }
Return

; 在ListView控件中显示脚本进程PID
tsk_showproc:
    WmiInfo := GetWMI("AutoHotkey.exe")
    ShowIndex := 0
    Gui, Font, s9, Arial
    Gui, Add, ListView, x2 y0 w250 h200, Index|PID|Script Name|Memory
    Loop, %scriptCount%
    {
        thisScript := scriptsName%A_Index%
        if scriptsOpened%A_Index% = 1 ; 已打开
        {
            ShowIndex += 1
            WinGet, procId, PID, %thisScript% - AutoHotkey
            memory := GetMemory(WmiInfo, procId)
            LV_Add("", ShowIndex, procId, thisScript, memory)
        }
    }
    LV_ModifyCol() ; 根据内容自动调整每列的大小
    Gui, Show,, Process List
Return

; 关闭ListView控件
GuiClose:
    Gui, Destroy
Return

; 关闭所有脚本
tsk_closeAll:
    Loop, %scriptCount%
    {
        thisScript := scriptsName%A_Index%
        if scriptsOpened%A_Index% = 1 ; 已打开
        {
            WinClose, %thisScript% - AutoHotkey
            scriptsOpened%A_Index% = 0
    
            StringRePlace, menuName, thisScript, .ahk
            Menu, scripts_unopen, Add, %menuName%, tsk_open
            Menu, scripts_unclose, Delete, %menuName%
            Menu, scripts_restart, Delete, %menuName%
        }
    }
Return

; 打开源码目录
Menu_Tray_OpenDir:
    Run, %A_ScriptDir%\scripts,, Max
Return

; 重启Manager
Menu_Tray_Reload:
    Reload
Return

; 退出
Menu_Tray_Exit:
    ExitApp
Return

Menu_Show:
    Menu, Tray, Show
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     创建菜单                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 创建子菜单
CreateMenus:
    ; "启动脚本"子菜单
    Menu, scripts_unopen, Add, 启动脚本, Menu_Tray_Exit
    Menu, scripts_unopen, ToggleEnable, 启动脚本
    Menu, scripts_unopen, Default, 启动脚本
    Menu, scripts_unopen, Add

    ; "关闭脚本"子菜单
    Menu, scripts_unclose, Add, 关闭脚本, Menu_Tray_Exit
    Menu, scripts_unclose, ToggleEnable, 关闭脚本
    Menu, scripts_unclose, Default, 关闭脚本
    Menu, scripts_unclose, Add

    ; "重载脚本"子菜单
    Menu, scripts_restart, Add, 重载脚本, Menu_Tray_Exit
    Menu, scripts_restart, ToggleEnable, 重载脚本
    Menu, scripts_restart, Default, 重载脚本
    Menu, scripts_restart, Add
Return

; 重建子菜单
RecreateMenus:
    Menu, scripts_unopen, DeleteAll     ; 剩下空菜单
    Menu, scripts_unclose, DeleteAll    ; 剩下空菜单
    Menu, scripts_restart, DeleteAll    ; 剩下空菜单

    GoSub CreateMenus

    OpenList := Array()     ; 已打开脚本列表
    UnOpenList := Array()   ; 未打开脚本列表
    Loop, %scriptCount%
    {
		StringTrimRight, menuName, scriptsName%A_Index%, StrLen(".ahk")
        if scriptsOpened%A_Index% = 1
            OpenList.Insert(menuName)
        if scriptsOpened%A_Index% = 0
            UnOpenList.Insert(menuName)
    }
    
    InsertionSort(OpenList) ; 排序
    for Index, menuName in OpenList
    {
        Menu, scripts_unclose, Add, %menuName%, tsk_close
        Menu, scripts_restart, Add, %menuName%, tsk_restart
    }
    
    InsertionSort(UnOpenList)
    for Index, menuName in UnOpenList
    {
        Menu, scripts_unopen, Add, %menuName%, tsk_open
    }
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     程序清理                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ExitSub:
    Loop, %scriptCount%
    {
        thisScript := scriptsName%A_Index%
        if scriptsOpened%A_Index% = 1 ; 已打开
        {
            WinClose, %thisScript% - AutoHotkey
            scriptsOpened%A_Index% = 0

            StringRePlace, menuName, thisScript, .ahk
        }
    }
    Menu, Tray, NoIcon
    ExitApp
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 给定进程名称，返回该进程的所有信息
GetWMI(ProcessName)
{
    objWMI := ComObjGet("winmgmts:\\.\root\cimv2")    ; 连接到WMI服务
    StrSql := "SELECT * FROM Win32_Process WHERE Name="""
    StrSql .= ProcessName
    StrSql .= """"
    Info := objWMI.ExecQuery(StrSql)
    Return Info
}

; 给定进程PID，获取其内存消耗
GetMemory(WmiInfo, PID)
{
    for ObjProc in WmiInfo
    {
        if (ObjProc.ProcessID = PID)
        {
            usage := Round(ObjProc.WorkingSetSize / 1024)
            Return % usage . "K"
        }
    }

    Return "0K"
}

