;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 将输入文件按照列对齐方式重排，默认分隔符为: 空格, Tab, 逗号, 分号
; 对齐后的内容自动拷贝到剪切板中
;
; 支持的文本编码方式: ANSI, UTF-8, UTF-8+BOM, UTF-16
;
; 注意: 本程序用到了3rd/gawk.exe, 3rd/sed.exe, 3rd/cut.exe, 3rd/iconv.exe
;
; 输入文本的编码，是本脚本重点考虑的问题
; 一方面，AHK处理的外部文件，推荐ANSI和UTF-8+BOM，它处理UTF-8会有问题.
; 另一方面，Linux衍生命令处理外部文件推荐ANSI和UTF-8，它处理UTF-8+BOM会有问题.
; 
; UTF-8上的复杂性，是因为Linux和Windows在对待UTF-8编码是否带BOM上存在分歧，
; 前者建议不带(因此对UTF-8支持很好)后者默认带BOM(因此对UTF-8+BOM支持很好).
;
; 基于此原因，无论输入文件采用何种编码，最后均试图转换成ANSI编码
; 这样一方面Linux衍生命令如gawk, iconv等均执行正常，而AHK脚本也工作正常
; 
; gaochao.morgen@gmail.com
; 2014/3/14
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoTrayIcon
#NoEnv

FileEncoding    ; 脚本默认以ANSI编码处理外部文件

INFILE :=       ; 输入文件，编码方式: ANSI, UTF-8, UTF-8+BOM, UTF-16
ENCODING :=     ; 输入文件的编码方式

ICONVOUTFILE := A_WorkingDir . "\iconvtmp.txt"  ; ICONV处理后的文件，ANSI编码
AWKOUTFILE := A_WorkingDir . "\awktmp.txt"      ; AWK处理后的文件，ANSI编码
SEDOUTFILE := A_WorkingDir . "\sedtmp.txt"      ; SED处理后的文件，ANSI编码

Gui, Add, Button, x6 y7 w80 h20 gSetAnsi, 修正乱码
Gui, Add, Button, x506 y7 w60 h20 gAlignColumn, 对齐
Gui, Add, Edit, x6 y37 w560 h330 vMyEdit, 直接拖动TXT文件到该界面上
Gui, Add, StatusBar,, ANSI
Gui, Show,, 文本竖列对齐
Return

; 响应单个文件拖动事件
GuiDropFiles:
    Loop, parse, A_GuiEvent, `n
    {
        INFILE := A_LoopField
        ENCODING := GetFileEncoding(INFILE)
        if (ENCODING == "UTF-8+BOM")
        {
            UTF8OUTFILE := A_WorkingDir . "\utf8tmp.txt" ; 临时文件，保存UTF-8+BOM文件截掉BOM标志后的内容

			; cut命令有BUG
            ;CUTCMD := GenerateCutCommand(INFILE, UTF8OUTFILE)
            ;RunWait, cmd /c %CUTCMD%,, Hide

			RemoveUTF8BOM(INFILE, UTF8OUTFILE)

            ICONVCMD := GenerateIconvCommand("UTF-8", UTF8OUTFILE, ICONVOUTFILE)
            RunWait, cmd /c %ICONVCMD%,, Hide
            FileDelete, %UTF8OUTFILE%
        } else if (ENCODING == "UTF-16") {
            ICONVCMD := GenerateIconvCommand("UTF-16", INFILE, ICONVOUTFILE)
            RunWait, cmd /c %ICONVCMD%,, Hide
        } else { ; ANSI or UTF-8
            FileCopy, %INFILE%, %ICONVOUTFILE%, 1 ; 1-覆盖
        }

        FileRead, FileContents, %ICONVOUTFILE%
        GuiControl,, MyEdit, %FileContents%
        SB_SetText(ENCODING)
        Return
    }
Return

; 只有显示为乱码时，才手动转换成ANSI编码
SetAnsi:
    ENCODING := "UTF-8"
    SB_SetText("UTF-8? 如果仍为乱码，则输入文件编码非UTF-8")

    ICONVCMD := GenerateIconvCommand("UTF-8", INFILE, ICONVOUTFILE)
    RunWait, cmd /c %ICONVCMD%,, Hide

    FileRead, FileContents, %ICONVOUTFILE%
    GuiControl,, MyEdit, %FileContents%
Return

; 对拖入的文件进行竖列对齐
AlignColumn:
    ; 竖列对齐
    AWKCMD := GenerateAwkCommand(ICONVOUTFILE, AWKOUTFILE)
    RunWait, cmd /c %AWKCMD%,, Hide

    ; 消除行末空格
    SEDCMD := GenerateSedCommand(AWKOUTFILE, SEDOUTFILE)
    RunWait, cmd /c %SEDCMD%,, Hide

    ; 打开处理后的文件
    FileRead, FileContents, %SEDOUTFILE%
    GuiControl,, MyEdit, %FileContents%

    ; 选中全部内容并拷贝
    GuiControl, Focus, MyEdit
    Send ^a
    Send ^c

    CoordMode, ToolTip, Screen  ; 把ToolTips放置在相对于屏幕坐标的位置
    ToolTip, 已拷贝到剪切板, 640, 400
    Sleep, 500
    ToolTip
Return

GuiClose:
    FileDelete, %ICONVOUTFILE%
    FileDelete, %AWKOUTFILE%
    FileDelete, %SEDOUTFILE%
ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 简单探测文件编码
GetFileEncoding(filename)
{
    encoding := "ANSI"
    file := FileOpen(filename, "r")
    if (file.Pos == 3)
        encoding := "UTF-8+BOM"
    else if (file.Pos == 2)
        encoding := "UTF-16"
    else
        encoding := "ANSI" ; 也有可能是UTF-8，这会造成乱码，需要在画面上手动修正
    
    file.Close()
    Return encoding
}

; gawk -f pattern.awk inFile > outFile
GenerateAwkCommand(inFile, outFile)
{
    gawk := "gawk -f "
    pattern := A_WorkingDir . "\..\3rd\alignColumn.awk"

    awkcmd := gawk
    awkcmd .= """"
    awkcmd .= pattern
    awkcmd .= """"
    awkcmd .= " "
    awkcmd .= """"
    awkcmd .= inFile
    awkcmd .= """"
    awkcmd .= " > """
    awkcmd .= outFile
    awkcmd .= """"

    Return awkcmd
}

; sed -f pattern.sed inFile > outFile
GenerateSedCommand(inFile, outFile)
{
    sed := "sed -f "
    pattern := A_WorkingDir . "\..\3rd\trimtail.sed"

    sedcmd := sed
    sedcmd .= """"
    sedcmd .= pattern
    sedcmd .= """"
    sedcmd .= " "
    sedcmd .= """"
    sedcmd .= inFile
    sedcmd .= """"
    sedcmd .= " > """
    sedcmd .= outFile
    sedcmd .= """"

    Return sedcmd
}

; iconv -f UTF-8 -t GBK inFile > outFile
GenerateIconvCommand(coding, inFile, outFile)
{
    iconv := "iconv -f "

    iconvcmd := iconv
    iconvcmd .= coding
    iconvcmd .= " -t GBK "
    iconvcmd .= """"
    iconvcmd .= infile
    iconvcmd .= """"
    iconvcmd .= " > """
    iconvcmd .= outFile
    iconvcmd .= """"

    Return iconvcmd
}

; cut -b 4- inFile > outFile
GenerateCutCommand(inFile, outFile)
{
    cut := "cut -b 4- " ; cut "EF BB BF" BOM to generate outFile with UTF-8 encoding
			 			; 该命令有BUG，会造成每行第一个字符被裁剪
    
    cutcmd := cut
    cutcmd .= """"
    cutcmd .= inFile
    cutcmd .= """"
    cutcmd .= " > """
    cutcmd .= outFile
    cutcmd .= """"

    Return cutcmd
}

; 去掉UTF-8+BOM文件的BOM头
RemoveUTF8BOM(InputFile, OutputFile)
{
	OrigEncoding := A_FileEncoding
	FileEncoding ; 脚本默认以ANSI编码处理外部文件
	FileRead, Content, %InputFile%
	FileEncoding, UTF-8-RAW
	FileAppend, %Content%, %OutputFile%
	FileEncoding, %OrigEncoding% ; 恢复编码
}
