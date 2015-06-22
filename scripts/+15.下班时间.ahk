;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 查看赛迪考勤系统结果
; 
; Chao.Gao@cisdi.com.cn
; 2015/5/26
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoEnv

#Include ../lib/IEAttach.ahk

DOMAIN := "http://cbms.cisdi.com.cn/AQS"

; 先加载空白页面 about:blank , 这样IE窗口应该响应得快一点点
BrowseWebPage("about:blank")

; 考勤系统首页
ie := BrowseWebPage(DOMAIN . "/Login.aspx")
ie.document.getElementById("tbUserID").value := "sa"    ; 设置登录名
ie.document.getElementById("tbUserPsw").value := "sa"   ; 设置密码
ie.document.getElementById("ImageButton1").Click()      ; 点击，登录系统

Sleep, 1000

; 子页面. 登录后直接在子页面上打开新网页，避免处理Cookie
ie := BrowseWebPage(DOMAIN . "/AQSMorning.aspx")
ie.document.getElementById("tbFname").value := "003762" ; 设置登录名
ie.document.getElementById("Button1").Click()           ; 点击查询

; 等待网页加载完成
Loop { 
	Sleep, 200
	if (ie.readyState="complete" or ie.readyState=4 or A_LastError!=0)
		break
}

HWND := ie.HWND
WinSet, AlwaysOnTop, On, %HWND%

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                        函数                           ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

; 打开一个指定URL的网页，返回IE对象
BrowseWebPage(URL)
{
	ComObjError(false) ; 关闭对象错误提示

    ie := 
    ie := IEAttach(DOMAIN, "URL") ; 试图从打开的IE窗口中找出其对象句柄
	if IsObject(ie)=0 {
		ie := ComObjCreate("InternetExplorer.Application") ; 如果连接IE对象失败就创建一个IE窗口
	}

	; 默认不可见，设为可见
	ie.Visible := true
	ie.Navigate(URL) ; 如果先加载空白页面 about:blank , 这样IE窗口应该响应得快一点点

    ; 等待网页加载完成
	Loop { 
		Sleep, 200
		if (ie.readyState="complete" or ie.readyState=4 or A_LastError!=0)
			break
	}

	Return ie
}

