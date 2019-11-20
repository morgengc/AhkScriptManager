;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 在Chrome浏览器的标签上双击，关闭该标签页
; 不过目前仍有一点问题，不在标签页上双击，在浏览器标题栏空白处双击，仍然会关闭激活的标签页，无法解决
;
; gaochao.morgen@gmail.com
; 2019/11/12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/DpiScale.ahk

#SingleInstance Force	; 跳过对话框并自动替换旧实例
#NoTrayIcon
#NoEnv					; 不检查空变量是否为环境变量（建议所有新脚本使用）

; 双击标签关闭标签页(模拟Ctrl+W键)
; 如果是Chrome浏览器(最大化状态)，且鼠标y轴小于34，则判定为鼠标位于标签页上
#IfWinActive ahk_class Chrome_WidgetWin_1
~LButton::
	; 如果未处于最大化状态，则不起作用
	WinGet, state, MinMax
	if (state != 1) {
		Return
	}

	; 仅在最大化时起作用
	CoordMode, Mouse, Screen
	MouseGetPos, X, Y
	Y := Y / GetDpiScale()	; 考虑系统缩放对UI显示的影响
	if (Y <= 34) {
		if (A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 600) {
			Send, ^w
		}
	}
Return

