; 执行命令sCmd，并且把命令输出从stdout导入变量
; source: http://www.autohotkey.com/forum/viewtopic.php?p=509873#509873
StdoutToVar_CreateProcess(sCmd, bStream="", sDir="", sInput="")
{
	bStream=   ; not implemented
	sDir=      ; not implemented
	sInput=    ; not implemented
   
	DllCall("CreatePipe", "Ptr*", hStdInRd , "Ptr*", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "Ptr*", hStdOutRd, "Ptr*", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Ptr", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Ptr", hStdOutWr, "Uint", 1, "Uint", 1)

	; Fill a StartupInfo structure
	if A_PtrSize = 4	; We're on a 32-bit system.
	{
		VarSetCapacity(pi, 16, 0)
		sisize := VarSetCapacity(si, 68, 0)
		NumPut(sisize,    si,  0, "UInt")
		NumPut(0x100,     si, 44, "UInt")
		NumPut(hStdInRd , si, 56, "Ptr")	; stdin
		NumPut(hStdOutWr, si, 60, "Ptr")	; stdout
		NumPut(hStdOutWr, si, 64, "Ptr")	; stderr
	}
	else if A_PtrSize = 8	; We're on a 64-bit system.
	{
		VarSetCapacity(pi, 24, 0)
		sisize := VarSetCapacity(si, 96, 0)
		NumPut(sisize,    si,  0, "UInt")
		NumPut(0x100,     si, 60, "UInt")
		NumPut(hStdInRd , si, 80, "Ptr")	; stdin
		NumPut(hStdOutWr, si, 88, "Ptr")	; stdout
		NumPut(hStdOutWr, si, 96, "Ptr")	; stderr
	}

    DllCall("CreateProcess", "Uint", 0			 ; Application Name
						   , "Ptr",  &sCmd       ; Command Line
                           , "Uint", 0			 ; Process Attributes
                           , "Uint", 0			 ; Thread Attributes
						   , "Int",  True		 ; Inherit Handles
                           , "Uint", 0x08000000  ; Creation Flags (0x08000000 = Suppress console window)
                           , "Uint", 0			 ; Environment
                           , "Uint", 0			 ; Current Directory
						   , "Ptr", &si          ; Startup Info
						   , "Ptr", &pi)		 ; Process Information

	DllCall("CloseHandle", "Ptr", NumGet(pi, 0))
	DllCall("CloseHandle", "Ptr", NumGet(pi, A_PtrSize))
	DllCall("CloseHandle", "Ptr", hStdOutWr)
	DllCall("CloseHandle", "Ptr", hStdInRd)
	DllCall("CloseHandle", "Ptr", hStdInWr)

	VarSetCapacity(sTemp, 4095)
	nSize := 0
	loop
	{
		result := DllCall("Kernel32.dll\ReadFile", "Uint", hStdOutRd, "Ptr", &sTemp, "Uint", 4095, "UintP", nSize, "Uint", 0)
		if (result = "0")
			break
		else
		sOutput := sOutput . StrGet(&sTemp, nSize, "CP850")
	}

	DllCall("CloseHandle", "Ptr", hStdOutRd)
	return, sOutput
}

