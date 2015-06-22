; 判断当前运行的 AutoHotkey Basic/AutoHotkey_L 版本
#SingleInstance Force
#NoTrayIcon
#NoEnv

CheckCurrentVersion()
Return

CheckCurrentVersion()
{
    if (A_AhkVersion = "")
        MsgBox, AutoHotkey Basic, 版本号小于 1.0.22
    else if (A_AhkVersion <= "1.0.48.05")
        MsgBox, AutoHotkey Basic, 版本号为 %A_AhkVersion%
    else
        MsgBox, % "AutoHotkey_L" (A_PtrSize = 4 ? (A_IsUnicode ? " Unicode ":" ANSI "):" 64 位") "版本, 版本号为" A_AhkVersion
    return
}
