;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 十六进制与十进制互相转换
;
; gaochao.morgen@gmail.com
; 2017/3/13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 十进制转换为十六进制的函数
; @param d 十进制数整数
; @return 十六进制数，以0x打头
Dec2Hex(d)
{
	SetFormat, integer, hex
	h := d+0
	h = %h%
	SetFormat, integer, dec ; 恢复至正常的10进制计算习惯
	Return %h%
}

; 十六进制转换为十进制的函数
; @param h 十六进制数整数，以0x打头
; @return 十进制数
Hex2Dec(h)
{
	SetFormat, integer, dec
	d := h+0
	d = %d%
	SetFormat, integer, hex
	Return %d%
}

