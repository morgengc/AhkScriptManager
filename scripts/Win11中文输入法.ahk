;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 调整微软拼音输入法，用键盘的`/`键输出中文顿号`、`
; 源自：https://blog.csdn.net/goocheez/article/details/132899579
; 我将其转换为了AHK的旧语法
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance, Force
#NoTrayIcon
#NoEnv

is_chinese_mode() {
    WinGet, hWnd, ID, A

    origin_detect_hidden_window := A_DetectHiddenWindows
    DetectHiddenWindows, On

    ; 获取当前输入法窗口句柄
    IMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "UInt", hWnd, "UInt")
    
    ; 使用 DllCall 调用 SendMessage
    result := DllCall("SendMessage", "UInt", IMEWnd, "UInt", 0x283, "UInt", 0x001, "UInt", 0)
        
    DetectHiddenWindows, %origin_detect_hidden_window%
    
    ; 微软拼音（英-中，新/旧，新旧/新旧）0/1024-1/1025
    return  (result == 1 or result == 1025)
}

$/:: 
{
    if (is_chinese_mode()) {
        SendInput, \
    } else {
        SendInput, /
    }
}
