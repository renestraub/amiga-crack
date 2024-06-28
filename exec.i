Exec:		MACRO
		movea.l	4.w,a6
		jsr	\1(a6)
		ENDM

Last:		MACRO
		jsr	\1(a6)
		ENDM

LibCall:	MACRO
		jsr	\1(a6)
		ENDM


LinkLib:	MACRO	* functionOffset,libraryBase
		IFNE NARG-2
			FAIL    LinkLib MACRO - bad arguments
		ENDC
			move.l  a6,-(SP)
			move.l  \2,a6
			jsr	\1(a6)
			move.l  (SP)+,a6
	    	ENDM

clra:		MACRO
			suba.l	 \1,\1
		ENDM

AbortIO:		EQU	-480
AddDevice:		EQU	-432
AddHead:		EQU	-240
AddIntServer:		EQU	-168
AddLibrary:		EQU	-396
AddMemList:		EQU	-618
AddPort:		EQU	-354
AddResource:		EQU	-486
AddSemaphore:		EQU	-600
AddTail:		EQU	-246
AddTask:		EQU	-282
Alert:			EQU	-108
AllocAbs:		EQU	-204
Allocate:		EQU	-186
AllocEntry:		EQU	-222
AllocMem:		EQU	-198
AllocSignal:		EQU	-330
AllocTrap:		EQU	-342
AttemptSemaphore:	EQU	-576
AvailMem:		EQU	-216
Cause:			EQU	-180
CheckIO:		EQU	-468
CloseDevice:		EQU	-450
CloseLibrary:		EQU	-414
CopyMem:		EQU	-624
CopyMemQuick:		EQU	-630
Deallocate:		EQU	-192
Debug:			EQU	-114
Disable:		EQU	-120
Dispatch:		EQU	 -60
DoIO:			EQU	-456
Enable:			EQU	-126
Enqueue:		EQU	-270
Exception:		EQU	 -66
ExitIntr:		EQU	 -36
FindName:		EQU	-276
FindPort:		EQU	-390
FindResident:		EQU	 -96
FindSemaphore:		EQU	-594
FindTask:		EQU	-294
Forbid:			EQU	-132
FreeEntry:		EQU	-228
FreeMem:		EQU	-210
FreeSignal:		EQU	-336
FreeTrap:		EQU	-348
GetCC:			EQU	-528
GetMsg:			EQU	-372
InitCode:		EQU	 -72
InitResident:		EQU	-102
InitSemaphore:		EQU	-558
InitStruct:		EQU	 -78
Insert:			EQU	-234
MakeFunctions:		EQU	 -90
MakeLibrary:		EQU	 -84
ObtainSemaphore:	EQU	-564
ObtainSemaphoreList:	EQU	-582
OldOpenLibrary:		EQU	-408
OpenDevice:		EQU	-444
OpenLibrary:		EQU	-552
OpenResource:		EQU	-498
Permit:			EQU	-138
Procure:		EQU	-540
PutMsg:			EQU	-366
RawDoFmt:		EQU	-522
RawIOInit:		EQU	-504
RawMayGetChar:		EQU	-510
RawPutChar:		EQU	-516
ReleaseSemaphore:	EQU	-570
ReleaseSemaphoreList:	EQU	-588
RemDevice:		EQU	-438
RemHead:		EQU	-258
RemIntServer:		EQU	-174
RemLibrary:		EQU	-402
Remove:			EQU	-252
RemPort:		EQU	-360
RemResource:		EQU	-492
RemSemaphore:		EQU	-606
RemTail:		EQU	-264
RemTask:		EQU	-288
ReplyMsg:		EQU	-378
Reschedule:		EQU	 -48
Schedule:		EQU	 -42
SendIO:			EQU	-462
SetExcept:		EQU	-312
SetFunction:		EQU	-420
SetIntVector:		EQU	-162
SetSignal:		EQU	-306
SetSR:			EQU	-144
SetTaskPri:		EQU	-300
Signal:			EQU	-324
SumKickData:		EQU	-612
SumLibrary:		EQU	-426
SuperState:		EQU	-150
Supervisor:		EQU	 -30
Switch:			EQU	 -54
TypeOfMem:		EQU	-534
UserState:		EQU	-156
Vacate:			EQU	-546
Wait:			EQU	-318
WaitIO:			EQU	-474
WaitPort:		EQU	-384

