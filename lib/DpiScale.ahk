;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 获取当前DPI和默认DPI(96)的比值，以便于某些UI程序调整位置、字体等
; 当设置字体为"中等(M)-125%"时，实际上是设置DPI为120，120/96=1.25
;
; gaochao.morgen@gmail.com
; 2015/12/22
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetDpiScale()
{
	; 当前DPI
	RegRead, AppliedDPI, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI
	; 默认DPI
	RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels

	Return AppliedDPI/LogPixels
}

