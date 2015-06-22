; 名称: IEAttach()
; 作者: amnesiac
; 用途:
; 根据选择的匹配模式, 附加到指定的 InternetExplorer 或 WebBrowser 对象.
;
; 参数:
;     s_string [可选参数] 要搜索的字符串 (对于"embedded"或者"dialogbox", 使用标题子字符串或者窗口句柄)
;     s_mode [可选参数]: 指定搜索模式
;         Title = (默认) 主文档标题的子字符串
;         WindowTitle = 完整窗口标题的子字符串(替代文档标题)
;         URL = 当前网页的url或者url子字符串
;         Text = 当前网页body标记内的文本或者文本子字符串
;         HTML = 当前网页body标签内的HTML代码或者HTML代码子字符串
;         HWND = 浏览器窗口句柄
;         Embedded = 嵌入了控件的窗口的句柄或者标题子字符串
;         DialogBox = 模态/非模态的对话框的句柄或者标题子字符串
;         Instance = 忽略 s_string, 从所有可用的浏览器实例中返回一个浏览器引用(通过匹配实例号)
;     i_instance [可选参数]: 按照 $s_string 和 $s_mode 匹配的浏览器组/嵌入式浏览器组返回一个基于1开始的索引数组. 参考备注.
; 返回值
;     成功: 返回一个指向 InternetExplorer 对象的变量,嵌入式浏览器与对话框模块将返回一个窗口对象
;     失败: 没有返回值
; 注意事项
;     1. 这个函数提供了通过 "dialogbox" 附加到由浏览器创建的模式/非模式对话框的功能, 需要注意并非由浏览器创建的所有对话框都可以进行控制, 
;        许多这种对话框是标准的 Windows 窗口, 应该使用普通的窗口控制函数进行操作. 要区分这两种窗口可以用 Active Window Info 工具, 
;        如果窗口中含有类名为 Internet Explorer_Server 的控件, 那么可以用这种方法进行附加, 否则需要用普通的窗口控制函数.
;     2. 此函数可能返回 WebBrowser 或 InternetExplorer 对象, 需要注意它们的区别. 如果通过 WebBrowser 对象访问状态栏/地址栏文本, 则可能出现错误.

IEAttach(s_string = "", s_mode = "Title", i_instance = 1)
{
    If (s_mode = "embedded" Or s_mode = "dialogbox")
    {
        iWinTitleMatchMode := A_TitleMatchMode
        SetTitleMatchMode, 2
        if s_string is xdigit ; 这里有更好的方法判断是否为句柄吗? 这里需要用更好的方法判断是否为句柄, 否则空字符串也会被视为十六进制数
        {    
            i_instance := 1
        }
        Else
        {
            WinGet, aWinList, List, %s_string%
            Loop, %aWinList%
            {
                hWin := aWinList%A_Index%
                WinGet, sCtrlList, ControlList, ahk_id %hWin%
                Loop, Parse, sCtrlList, `n
                {
                    if (A_LoopField = "Internet Explorer_Server" i_instance)
                    {
                        s_string := hWin
                        break, 2
                    }
                }
            }
        }
        ControlGet, hIECtrl, hwnd, , Internet Explorer_Server%i_instance%, ahk_id %s_string%
        oResult := _IEObjGetFromHwnd(hIECtrl)
        SetTitleMatchMode, %iWinTitleMatchMode%
        If IsObject(oResult)
            Return, oResult
        Else
            Return
    }
    if (s_mode = "hwnd")
        i_instance := 1
    oIECtrlSet := _IEHwndGetFromClassNN(i_instance)
    if !oIECtrlSet
        return
    for nIndex, hIECtrl in oIECtrlSet
    {
        oIE := _IEObjGetFromHwnd(hIECtrl)
        if (s_mode = "title")
        {
            If InStr(oIE.document.title, s_string) > 0
            {
                return, oIE
            }
        }
        else if (s_mode = "instance")
        {
            return, oIE
        }
        else if (s_mode = "windowtitle")
        {
            RegRead, sTemp, HKEY_CURRENT_USER, Software\Microsoft\Internet Explorer\Main\, Window Title
            If !ErrorLevel
            {
                If InStr(oIE.document.title " - " sTemp, s_string)
                    return, oIE
            }
            Else
            {
                If InStr(oIE.document.title " - Microsoft Internet Explorer", s_string) or InStr(oIE.document.title " - Windows Internet Explorer", s_string)
                    return, oIE
            }
        }
        else if (s_mode = "url")
        {
            If InStr(oIE.LocationURL, s_string) > 0
            {
                return, oIE
            }
        }
        else if (s_mode = "text")
        {
            If InStr(oIE.document.body.innerText, s_string) > 0
            {
                return, oIE
            }
        }
        else if (s_mode = "html")
        {
            If InStr(oIE.document.body.innerHTML, s_string) > 0
            {
                return, oIE
            }
        }
        else if (s_mode = "hwnd")
        {
            If (oIE.hwnd() = s_string)    ; 可能存在问题
                Return, oIE
        }
    }
    return
}

; 内部函数: 根据 WebBrowser 控件的 ClassNN （即 Internet Explorer_Server 加上数字）获取当前存在的所有这种控件的 ID
_IEHwndGetFromClassNN(i_instance = 1)
{
    WinGet, aWinList, List, ahk_class IEFrame
    if (aWinList = 0)
        return
    oIECtrlSet := Object()
    Loop, %aWinList%
    {
        hWin := aWinList%A_Index%
        WinGet, sCtrlList, ControlList, ahk_id %hWin%
        Loop, Parse, sCtrlList, `n
        {
            if (A_LoopField = "Internet Explorer_Server" i_instance)
            {
                ControlGet, hCtrl, Hwnd,, Internet Explorer_Server%i_instance%, ahk_id %hWin%
                oIECtrlSet.Insert(hCtrl)
            }
        }
    }
    return, oIECtrlSet.MaxIndex()="" ? "" : oIECtrlSet
}

; 内部函数: 根据 WebBrowser 控件的句柄，获取它所在的 WebBrowser 对象
_IEObjGetFromHwnd(h_IECtrl)
{
    static Msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
    SendMessage, Msg, 0, 0, , ahk_id %h_IECtrl%    
    if (ErrorLevel = "FAIL")
        return    
    lResult := ErrorLevel
    VarSetCapacity(GUID, 16, 0)
    GUID := IID_IHTMLDocument2    ; 这里 IID_IHTMLDocument2 不是个变量，为什么不会出错呢？
    sGUID := "{332C4425-26CB-11D0-B483-00C04FD90119}"
    CLSID := DllCall("ole32\CLSIDFromString", "wstr", sGUID, "ptr", &GUID) >= 0 ? &GUID : ""
    DllCall("oleacc\ObjectFromLresult", "ptr", lResult, "ptr", CLSID, "ptr", 0, "ptr*", pDoc)
    static IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
    static SID_SWebBrowserApp := IID_IWebBrowserApp
    pWeb := ComObjQuery(pDoc, SID_SWebBrowserApp, IID_IWebBrowserApp)
    ObjRelease(pDoc)
    static VT_DISPATCH := 9, F_OWNVALUE := 1
    oIE := ComObjParameter(VT_DISPATCH, pWeb, F_OWNVALUE)
    return, oIE
}
