DOS:		MACRO
		movea.l	_DOSBase,a6
		jsr	\1(a6)
		ENDM

Open:		equ	-30
Close:		equ	-36
Read:		equ	-42
Write:		equ	-48
Input:		equ	-54
Output:		equ	-60
Seek:		equ	-66
DeleteFile:	equ	-72
Rename:		equ	-78
Lock:		equ	-84
UnLock:		equ	-90
DupLock:	equ	-96
Examine:	equ	-102
ExNext:		equ	-108
Info:		equ	-114
CreateDir:	equ	-120
CurrentDir:	equ	-126
IoErr:		equ	-132
CreateProc:	equ	-138
xExit:		equ	-144
LoadSeg:	equ	-150
UnLoadSeg:	equ	-156
GetPacket:	equ	-162
QueuePacket:	equ	-168
DeviceProc:	equ	-174
SetComment:	equ	-180
SetProtection:	equ	-186
DateStamp:	equ	-192
Delay:		equ	-198
WaitForChar:	equ	-204
ParentDir:	equ	-210
IsInteractive:	equ	-216
Execute:	equ	-222

