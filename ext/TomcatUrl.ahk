;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 在Tomcat\webapps目录的子目录下右键点击网页，生成测试URL，并自动打开Firefox测试
; NOTE: 给文件右键添加菜单需要运行注册表3rd/webpage.test.reg
; 需要定义三个环境变量:
; set TomcatHome=F:\编程与优化\Java\apache-tomcat-7.0.59\webapps
; set BrowserHome=C:\Program Files\Internet Explorer\iexplore.exe
; set TomcatPrefix=http://localhost:8080/
;
; Chao.Gao@cisdi.com.cn
; 2015/5/12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WebPageFullName := ""

; 获取文件全名
Loop, %0%
{
	WebPageFullName := %A_Index%
	;MsgBox, %WebPageFullName%
	Break
}

; 获取webapps下子目录名称 TomcatDir := "F:\编程与优化\Java\apache-tomcat-7.0.59\webapps\"
EnvGet, TomcatDir, TomcatHome

; 若环境变量最后一个字符不是"\"，则在结尾处追加一个"\"字符
if (SubStr(TomcatDir, 0, 1) <> "\")
	TomcatDir .= "\"

;MsgBox, %TomcatDir%

; 若选取的文件不在Tomcat的子目录下，则不做任何操作
if (!InStr(WebPageFullName, TomcatDir))
	Return

; 构造URL Url := "http://localhost:8080/"
EnvGet, Url, TomcatPrefix
if (SubStr(Url, 0, 1) <> "/")
	Url .= "/"

; 获取web项目名称
UrlSuffix := SubStr(WebPageFullName, StrLen(TomcatDir)+1)
; 本地文件路径分隔符"\"改为URL分隔符"/"
StringReplace, UrlSuffix, UrlSuffix, \, /, All 
Url .= UrlSuffix

; 用浏览器打开 Navigator := "C:\Program Files\Mozilla Firefox\firefox.exe"
EnvGet, Navigator, BrowserHome
BroweCmd := Navigator
BroweCmd .= " "
BroweCmd .= Url

Run, %BroweCmd%

