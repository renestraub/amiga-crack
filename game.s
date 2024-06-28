*****************************************************************************
*                                                                           *
* CRACK                                   Project started  : xx.yy.1987     *
* -----                                           finished : 26.02.1988     *
*                                                                           *
* DAS Arkanoid für den Amiga.                                               *
*                                                                           *
* Author René Straub                Tel.  +41 64 462 661                    *
*        Talstrasse 820             Fax.  +41 64 461 417                    *
*        5726 Unterkulm (Schweiz)   EMail straub@crack.aare.net.ch          *
*                                                                           *
* Modification History:                                                     *
* ---------------------                                                     * 
*                                                                           *
* xx.yy.87  RHS  Created this file                                          *
* 04.02.95  RHS  Updated file, makes it more system friendly                *
* 07.02.95  RHS  First playable version with many,many bugs                 *
* 10.02.95  RHS  Hiscore, CoconutGame, Game itself more or less running     *
*                                                                           *
*****************************************************************************



		INCLUDE "Dos.i"
		INCLUDE "Exec.i"
		INCLUDE "Intuition.i"
		INCLUDE "Graphics.i"



DataDisk:	EQU	512*617
DiskScore:	EQU	185*512
DiskHiPic:	EQU	512*871		
diskBob:	EQU	512*812			
rahmenc:	EQU	512*1328
backgroundc:	EQU	512*1278
stagebase:	EQU	512*1447
picbase:	EQU	512*910
hisc:		EQU	860*512


ballb:		EQU	6
ballh:		EQU	6

namensLaenge:	EQU	8
max_entry:	EQU	100

Menucolor:	EQU	$965
Menucolor2:	EQU	$ECA

pl:		EQU	9600
l1:		EQU	4788
l2:		EQU	1680
l3:		EQU	384

ystart:		EQU	176
yend:		EQU	16


;DEMOVER
;FINAL
;TIME




		SECTION Intro2Code,CODE_C


Main:		lea	dostext,a1
		Exec	OldOpenLibrary
		move.l	d0,_DOSBase

		lea	gfxtext,a1
		Exec	OldOpenLibrary
		move.l	d0,_GfxBase

		lea	inttext,a1
		Last	OldOpenLibrary
		move.l	d0,_IntuitionBase	* Open Libs


		sub.l	a1,a1
		Exec	FindTask

		move.l	d0,a1
		moveq	#20,d0
		Exec	SetTaskPri		* Set Task Pri to 20


		bsr	OpenScr
		tst.l	d0
		bne	ExitDOS


		move.w	#$20,$dff1dc		* PAL-Screen
		move.w	#$0100,$dff096		* Dunkel
		move	#$8400,$dff096		* Blitter Nasty

		bsr	InitCopper2
		move.l	#copperl2,$dff080	* Ganz Dunkel

		lea	$dff000,a6
		move	#$8400,$96(A6)		
		move	#$1000,$98(A6)
	
		bsr	InitTask
		bsr	LoadHiScore

o1:		clr.b	Demo
		bsr	Menu

		cmp.l	#'HISC',d0
		bne.s	.NoShowHiScore

		clr.b	Demo
		move.b	#1,FromMenu
		bsr	DoHiScore

		bra.s	o1		

.NoShowHiScore:	cmp.l	#'EDIT',d0
		bne.s	o2




ExitDOS:	bsr	RemoveTask
		bsr	CloseScr


		sub.l	a1,a1
		Exec	FindTask

		move.l	d0,a1
		moveq	#0,d0
		Exec	SetTaskPri		* Set Task Pri to 20


		move.l	_GfxBase,a6
		move.l	38(a6),$dff080

		sub.l	a1,a1
		Gfx	LoadView
		Intui	RemakeDisplay		* Restore Display

		move.l	_DOSBase,a1		* Close Libs
		Exec	CloseLibrary

		move.l	_GfxBase,a1		* Close Libs
		Exec	CloseLibrary

		move.l	_IntuitionBase,a1
		Last	CloseLibrary

		moveq	#0,d0			* Exit succesfully
		rts



o2:		bsr	o3
		bra	o1



o3:		move	#60,vol1
		clr.l	stc
		clr.l	Score
		clr.l	Stufe2
		move.b	#1,Kept


	;	move	#$8010,$dff09a	
		clr	Power
		clr	PowerSoll
		bsr	RestorePower

		tst.b	Demo
		beq.s	NotDemo

		clr.b	Lives
		move.b	#1,OldLives
		move.l	HiStufe,Stufe2

		bchg	#0,Mode1
		move.b	Mode1,TwoPlayer

		bra.s	Demo66

NotDemo:	move.b	#2,Lives
		move.b	#1,OldLives
		clr.b	Auto

Demo56:		clr.l	Stufe2
Demo66:		clr	BattleTime


		move.b	#-1,Cheat


		move	#$120,$dff096
		bsr	Clear
		bsr	LoadScr
		bsr	LoadStage
		bsr	InitCopper
		bsr	InitMouse
		bsr	BuildLevel
		bsr	ClearBonus
		bsr	ClearSpr

		clr	LGameCnt

		moveq	#4,d0
		lea	MainIntStruct,a1
		Exec	AddIntServer		* CopperInt anhängen


Haupt2:		move	#$8120,$dff096
		clr	EndGame2
		clr	EndGame
		clr.b	Paused
	
		bsr	WaitStart		* Ball abwerfen



Haupt:		Gfx	WaitTOF

		tst	EndGame
		bne.s	.NoTrp

		tst.b	Paused
		bne.s	.EndInt2

		bsr	DrawSchlaeger
		bsr	HandleSchlaeger

		bsr	Flash
		bsr	DoLaser
		bsr	HandleSchlaeger
		bsr	CheckColl

.EndInt2:	cmp.b	#2,Paused
		beq.s	.NoTrp

		nop
		bsr	MoveShoot

		cmp.b	#3,Paused
		beq.s	.NoTrp

		nop
		bsr	MoveFSpr
		bsr	MoveF2Spr
		bsr	DoLoch
	
		cmp.b	#4,Paused
		beq.s	.NoTrp

		nop
		bsr	MakeBlitz

.NoTrp:		bsr	MakeLives

	IFD	Time
		move	#$f00,$dff180
	ENDC

		bsr	AllesGeloescht
		tst	d0
		bne.s	NotAll

		move.b	#1,nlevel

NotAll:		tst	EndGame
		bne	EndIt

		tst.b	Demo
		beq.s	dontsk

		add	#1,Powercnt2
		cmp	#10,Powercnt2
		bne.s	powr

		clr	Powercnt2
		add	#1,PowerSoll

powr:		btst	#6,$bfe001
		beq	Exit
		btst	#7,$bfe001
		beq	Exit


dontsk:		tst.b	nlevel
		bne	NextLevel

		tst.b	plevel
		bne	PreLevel

		tst	waitb
		bne	WaitBall

		tst.b	exploding
		bne	Explosion

		tst.b	rightout
		bne	moveschlright

		tst.b	leftout
		bne	moveschlleft


		tst 	LaserCnt
		beq.s	las
		sub	#1,LaserCnt
		tst	LaserCnt
		bne.s	las

		move.l	#4,schl
		move.l	#4,schl2
		clr.b	laser

las:		tst.b	Battle
		beq	NoBtl
		cmp.l	#5,schl
		beq	NoBtl
		cmp.l	#5,schl2
		beq.s	NoBtl		

		cmp	#30,BattleTime
		bhi.s	NoAddTime
		addq	#1,BattleTime

NoAddTime:	cmp	#25,BattleTime
		bls.s	NoBtl
	
		btst	#6,$bfe001
		bne.s	NC5
		cmp	#5,schl2
		beq.s	NC5

		move.l	#5,schl
		move	#100,LaserCnt
		move.b	#1,laser
		bra.s	NoBtl

NC5:		cmp	#5,schl
		beq.s	NoBtl

		btst	#7,$bfe001
		bne.s	NoBtl
		move.l	#5,schl2	
		move	#50,LaserCnt
		move.b	#1,laser

NoBtl:		move	PowerSoll,d1
		move	Power,d0
		cmp	d0,d1
		beq.s	mp
		bls.s	minus
		bhi.s	plus


minus:		subq	#2,Power
		bra.s	mp

plus:		addq	#2,Power

mp:		cmp	#240,Power
		bhi	Explosion

noPower2:	move	Power,d0
		divu	#10,d0
		move	d0,d5

		lea	orgPowercol,a2
		lea	Powercol,a3
		lea	Powerturm,a0

search:		cmp	#$18a,(a0)+
		bne.s	search

		move	(a3),(a0)
		addq.l	#2,a2
		addq.l	#2,a3
		dbf	d0,search

		moveq	#23,d4
		sub	d5,d4

search23:	cmp	#$18a,(a0)+
		bne.s	search23
		move	(a2)+,(a0)
		dbf	d4,search23



noblink:	move.b	$bfec01,d0
		tst.b	d0
		beq	ENDCheck_key

		cmp.b	#$63,d0			* Cursor Right
		bne.s	notlauter1
		cmp.w	#63,vol1
		bhi.s	notlauter1

		addq.w	#1,vol1

notlauter1:	cmp.b	#$61,d0			* Cursor Left
		bne.s	notleiser1
		tst.w	vol1
		bls.s	notleiser1

		subq	#1,vol1

notleiser1:	cmp.b	#$7f,d0
		beq	Pause

		tst.b	Cheat
		beq.s	NotPreLevel

		cmp.b	#$35,d0
		bne.s	notnextlevl
		move.b	#1,rightout


notnextlevl:	cmp.b	#$37,d0
		bne.s	NotPreLevel
		move.b	#1,leftout


NotPreLevel:	cmp.b	#$75,d0
		beq	Exit


ENDCheck_key:	lea	$dff000,a4
		move	vol1,$a8(A4)
		move	vol1,$b8(A4)
		move	vol1,$c8(A4)
		move	vol1,$d8(A4)

		bsr	Print

	IFD	Time
		move	#0,$dff180
	ENDC

		bra	Haupt



EndIt:		move.l	#copperl4,$dff080
		cmp	#2,EndGame
		bne.s	NotFin

		bsr	ClearScore

		lea	CopCol5+6,a1
		move	#$0f0,(A1)

		bsr	InitHiCopper
		move.l	#copperl5,$dff080
		move	#$8100,$dff096

		lea	CongTable,a6

RepPr:		tst.l	(A6)
		beq.s	EndPr

		move.l	(A6)+,a1
		move.l	(A6)+,a0
		bsr	PrintText2
		bra.s	RepPr	

EndPr:		btst	#6,$bfe001
		bne.s	EndPr

		move	#$100,$dff096
		bra.s	DoHi

NotFin:	;	move	#$10,$dff09a
		bsr	Dunk



DoHi:

		move.l	#20000,Score
		bsr	DoHiScore	

	;	move	#$8010,$dff09a	
;		bra	Exit


Exit:		move	#1,EndGame
		move	#$000f,$dff096		* Audio DMA off

		moveq	#4,d0
		lea	MainIntStruct,a1
		Exec	RemIntServer

		rts




GetBlitter:	movem.l	d0-d2/a0-a2/a6,-(sp)
	;	Gfx	OwnBlitter
		movem.l	(sp)+,d0-d2/a0-a2/a6
		rts

GiveBlitter:	movem.l	d0-d2/a0-a2/a6,-(sp)
	;	Gfx	DisownBlitter
		movem.l	(sp)+,d0-d2/a0-a2/a6
		rts


WaitBlitter:	movem.l	d0-d2/a0-a2/a6,-(sp)

	;;	Gfx	WaitBlit

		lea	$dff000,a0
1$:		btst	#14,2(a0)
		btst	#14,2(a0)
		bne	1$

		lea	$dff000,a0
2$:		btst	#14,2(a0)
		btst	#14,2(a0)
		bne	2$

		movem.l	(sp)+,d0-d2/a0-a2/a6
		rts




OpenScr:	movem.l	d1-d7/a0-a6,-(sp)

		lea	NewScreen,a0		; Open Screen
		Intui	OpenScreen
		tst.l	d0
		beq.s	.Failed

		move.l	d0,MainScreen 

		lea	NewWindow,a0		; Openwindow
		Last	OpenWindow
		tst.l	d0
		beq.s	.Failed

		move.l	d0,Window

		moveq	#0,d0

.Exit:		movem.l	(sp)+,d1-d7/a0-a6
		rts

.Failed:	moveq	#-1,d0
		beq	.Exit





CloseScr:	movem.l	d0-d7/a0-a6,-(sp)

		move.l	Window,a0	; Close Window
		move.l	a0,d0
		tst.l	d0
		beq.s	.NoWindow

		Intui	CloseWindow

.NoWindow:	move.l	MainScreen,a0	; Close Screen
		move.l	a0,d0
		tst.l	d0
		beq.s	.NoScreen

		Intui	CloseScreen

.NoScreen:	movem.l	(sp)+,d0-d7/a0-a6
		rts









RestorePower:	clr	Power
		clr	PowerSoll
		lea	Powerturm+2,a4
	
		moveq	#22,d7
ser:		cmp	#$18a,(a4)+
		bne.s	ser
		dbf	d7,ser	
		subq.l	#2,a4

		lea	orgPowercol+48,a5
		moveq	#23,d7

rploop:		Gfx	WaitTOF
		Last	WaitTOF

		move	-(a5),2(a4)
cp1loop:	cmp	#$18a,-(A4)
		bne.s	cp1loop

		dbf	d7,rploop
		rts



ClearPower:	lea	Powerturm+2,a4
		lea	Powercol,a5

		moveq	#23,d7
cploop:		move	(a5)+,(A4)

cp2loop:	cmp	#$18a,(A4)+	
		bne.s	cp2loop
		dbf	d7,cploop

		rts



MakeLives:	tst	EndGame2
		bne.s	CorrectLives

		move.b	Lives,d4
		cmp.b	OldLives,d4
		bne.s	CorrectLives
		rts	


CorrectLives:	move.b	Lives,OldLives
		sub.l	d0,d0
		moveq	#5,d7

liv2:		sub.l	d1,d1
		bsr	DrawLive
		addq	#1,d0
		dbf	d7,liv2

		sub.l	d2,d2
		move.b	Lives,d2
		tst.b	d2
		beq.s	endLives
		cmp.b	#-1,d2
		beq.s	endLives

		sub.l	d0,d0
liv4:
		moveq	#1,d1
		bsr	DrawLive

		addq	#1,d0
		cmp	#5,d0
		beq.s	endLives	

		cmp	d2,d0
		blo.s	liv4

endLives:	rts




lplay:		move	#20,Tempo
		clr	Tempo2
		clr	PlayCnt

		lea	pic2col+2,a0
		moveq	#5,d7
fill2:
		move	#$777,(a0)
		add	#4,a0
		dbf	d7,fill2

		bsr	Hell
		bsr	RestorePower		
		move.l	#copperl,$dff080

lplay2:		Gfx	WaitTOF

		lea	pic2col+2,a0
		move.l	a0,a1
		moveq	#5,d7
fill:
		move	#$777,(a0)
		add	#4,a0
		dbf	d7,fill

		add	#1,Tempo2
		move	Tempo2,d5
		cmp	Tempo,d5
		bne.s	not67
		clr	Tempo2

		add	#1,PlayCnt
		cmp	#6,PlayCnt
		bne.s	not67
		clr	PlayCnt
not67:
		move	PlayCnt,d4
		lsl	#2,d4
		add	d4,a1
		move	#$0f0,(a1)
	
		btst	#6,$bfe001
		bne.s	lplay2

		tst	PlayCnt
		beq.s	endplay
		cmp	#2,PlayCnt
		beq.s	endplay
		cmp	#4,PlayCnt
		beq.s	endplay

		add.l	#100,Score
		bsr	Print
waitplay:
		btst	#6,$bfe001
		beq.s	waitplay

		moveq	#20,d7
verz23:		Gfx	WaitTOF
		dbf	d7,verz23

		clr	PlayCnt
		sub	#5,Tempo
		cmp	#5,Tempo
		bne	lplay2
endplay:
		bsr	Dunk
		rts




Rnd:		move.b 	$bfe801,d0
		add.b 	$bfd800,d0
		add.b 	$dff008,d0
		add.b 	$dff009,d0
		add.b 	$dff00a,d0
		add.b 	$dff00b,d0
		rts






DoLoch:		tst	Away
		bne.s	nonew
		tst	LochDir
		bne.s	nonew
		bsr	Rnd
		and.b	#$7f,d0
		cmp.b	#4,d0
		bne.s	nonew
		bsr	Rnd
		and.b	#3,d0
		tst.b	d0
		bne.s	nonew
		move	#1,LochDir
nonew:
		cmp	#10,LochCnt
		bne	DrawLoch		

		clr.l	d0
		bsr	Rnd
		and	#$f,d0
		lsl	#2,d0			
		lea	Bahnen_tabelle,a1
		move.l	(a1,d0.w),Bahn
		lea	Bahnen_tabelle2,a1
		move.l	(A1,d0.w),a1		; Zeiger auf moegl. Spr

		tst.b	Battle
		beq	NoBtl3
		lea	Sp5,a1
		bra.s	GotIt
NoBtl3:
		bsr	Rnd
		and	#7,d0
		lsl	#2,d0
		move.l	(A1,d0.w),a1		; Zeiger auf SpriteStrc
GotIt:
		move	(A1)+,ytest1
		move	(A1)+,ytest2
		move	(A1)+,yhoehe
		lea	fsprcol+2,a3
		move	(A1)+,(A3)
		move	(A1)+,4(A3)
		move	(A1)+,d4
		move	(A1)+,d5
		move	(A1)+,Speed
		move.l	A1,Shape
		move.l	A1,PShap
		move	#1,Shapi

		move	yhoehe,d3
		add	d5,d3

		lea	fspr2,a1
		move.b	d5,(A1)
		move.b	d3,2(A1)
		move.b	d4,1(A1)	
		move	#1,Away
		clr	f2cnt



DrawLoch:	bsr	GetBlitter

		move	LochDir,d0
		tst	d0
		beq	4$

		add	d0,LochCnt

		cmp	#10,LochCnt
		bne.s	1$
		move	#-1,LochDir

1$:		tst	LochCnt
		bne.s	2$
		clr	LochDir

2$:		move	LochCnt,d0
		mulu	#40*8,d0

		lea	$dff000,a5
		move.l	Screen2,a0
		add.l	#1714,a0		
		add.l	d0,a0

		move.l	Screen1,a2
		add.l	#13,a2			
	
		moveq	#4,d7
3$:		bsr	WaitBlitter

		move.l	#-1,$44(a5)
		move	#34,$66(A5)
		move	#34,$64(a5)
		clr	$42(A5)
		move	#$9f0,$40(A5)
		move.l	a2,$54(A5)	
		move.l	a0,$50(A5)	
		move	#%00000000111000011,$58(A5)
		add.l	#8000,a2
		add.l	#8000,a0
		dbf	d7,3$

4$:		bsr	GiveBlitter
		rts





DoLaser:	clr	which
		tst.b	laser
		beq	nolaser
		tst.b	Battle
		bne.s	nbtl2
		move.l	#5,schl

nbtl2:		tst.b	Battle
		beq.s	nbtl3

		cmp.l	#5,schl2
		bne.s	nbtl3
		btst	#7,$bfe001
		bne.s	nbtl3
		move	#2,which
		bra.s	dlaser
nbtl3:		cmp.l	#5,schl
		bne	nolaser
		btst	#6,$bfe001
		bne	nolaser
		move	#1,which
dlaser:
		lea	shoot1,a1
		tst.b	(a1)
		bne	nolaser

		lea	$dff000,a5
		move	#8,$96(A5)
		move.l	#Schuss,$d0(A5)
		move	#3992,$d4(A5)
		move	#180,$d6(A5)
		move	#13,SoundcNT4
		move	#$8008,$96(A5)

		move.b	#224,(A1)
		move.b	#229,2(A1)
		add	#5,PowerSoll

		cmp	#2,which
		bne.s	pl1
		move	MousX2,d5
		bra.s	pl2
pl1:
		move	MousX,d5
pl2:
		lsr	#1,d5
		add.b	#84,d5
		move.b	d5,1(a1)
nolaser:
		rts




HandleSchlaeger:
		addq.b #1,excounter
		cmp.b #2,excounter
		bne.s weiterschl
		clr.b excounter
	
		tst.l extend
		beq.s weiterschl
		bmi.s addschl

		sub.l #1,schl
		tst.l schl
		bhi.s weiterschl
		clr.l extend
		clr.l schl
		bra.s weiterschl
addschl:
		add.l #1,schl
		cmp.l #4,schl
		bls.s weiterschl
		clr.l extend
		move.l #4,schl

weiterschl:	addq.b #1,excounter2
		cmp.b #2,excounter2
		bne.s weiterschl
		clr.b excounter2
	
		tst.l extend2
		beq.s weiterschl2
		bmi.s addschl2

		sub.l #1,schl2
		tst.l schl2
		bhi.s weiterschl2
		clr.l extend2
		clr.l schl2
		bra.s weiterschl2

addschl2:	add.l #1,schl2
		cmp.l #4,schl2
		bls.s weiterschl2
		clr.l extend2
		move.l #4,schl2

weiterschl2:	rts






MakeBlitz:	bsr	GetBlitter

		tst.b	level
		beq.s	1$

		moveq	#0,d0
		bra.s	2$

1$:		subq	#1,lcnt
		move	lcnt,d0
		tst	d0
		bpl.s	2$

		move	#32,lcnt
		moveq	#32,d0

2$:		move.l	Screen2,a0
		add.l	#1722,a0

		move.l	Screen2,a1		
		add.l	#5278,a1
		muls	#40,d0
		add.l	d0,a1

		move.l	Screen1,a2		
		add.l	#7026,a2


		lea	$dff000,a6
		moveq	#4,d7

drawit1:	bsr	WaitBlitter

		move	#38,$60(A6)
		move	#38,$62(A6)
		move	#38,$64(A6)
		move	#38,$66(A6)

		move.l	#-1,$44(A6)
		move	#$8fca,$40(a6)
		move	#$8000,$42(A6)

		move.l	a2,$48(A6)	
		move.l	a2,$54(A6)	
		move.l	a0,$50(A6)	
		move.l	a1,$4c(A6)	
		move	#%1111000001,$58(A6)

		add.l	#8000,a2
		add.l	#8000,a1
		dbf	d7,drawit1


		moveq	#15,d7

cl:		clr.b	(a2)
		add.l	#40,a2
		dbf	d7,cl


		move.l	Screen2,a0		
		add.l	#1720,a0

		move.l	Screen2,a1		
		add.l	#5276,a1
		add.l	d0,a1

		move.l	Screen1,a2		
		add.l	#7002+40,a2

		moveq	#5-1,d7

2$:		bsr	WaitBlitter

		move	#38,$60(A6)
		move	#38,$62(A6)
		move	#38,$64(A6)
		move	#38,$66(A6)

		move.l	#-1,$44(A6)
		move	#$8fca,$40(a6)
		move	#$8000,$42(A6)

		move.l	a2,$48(A6)	
		move.l	a2,$54(A6)	
		move.l	a0,$50(A6)	
		move.l	a1,$4c(A6)	
		move	#%1110000001,$58(A6)

		add.l	#8000,a2
		add.l	#8000,a1
		dbf	d7,2$

		bsr	GiveBlitter

		rts



Soundi:		tst	SoundcNT1
		bne.s	NotS11
		move	#1,$dff096		; Kanal 1 off
		bra.s	NS1

NotS11:		subq	#1,SoundcNT1
NS1:		tst	SoundcNT2
		bne.s	NotS21
		move	#2,$dff096		; Kanal 1 off
		bra.s	NS2

NotS21:		subq	#1,SoundcNT2
NS2:		tst	SoundcNT3
		bne.s	NotS31
		move	#4,$dff096		; Kanal 1 off
		bra.s	NS3

NotS31:		subq	#1,SoundcNT3
NS3:		tst	SoundcNT4
		bne.s	NotS41
		move	#$8,$dff096		; Kanal 1 off
		rts

NotS41:		subq	#1,SoundcNT4
		rts




MoveSpr:	tst	slow
		beq.s	okslow
		add	#1,slowcnt
		cmp	#2,slowcnt
		bne.s	endmov
		clr	slowcnt
okslow:		bsr	moveto
endmov:		rts

moveto:		move.l	#sprite1,sprite
		move.l	#spr1,spr
		bsr	movespr2

		tst.b	twoball
		bne.s	twobal
		rts

twobal:		move.l	#sprite2,sprite
		move.l	#spr2,spr
		bsr	movespr2
		rts


movespr2:	tst	Kept2
		beq.s	move2
		rts


ch:		dc.w	$4ef9

move2:		sub.l	d1,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4

		move.l	spr,a1	
		move.l	(A1),a0
		move.b	4(A1),d1		
		move.b	5(A1),d2		
		move.b	6(A1),d3		
		move.b	7(A1),d4		

		move	d1,x
		move	d2,y
		clr	ch

up1:		tst.b	d3
		bmi	up2

		tst.b	d4
		bpl.s	up2			

		move	#1,ch
		movem.l	d0-d7,-(sp)
		add.b	d4,d2
		move	d1,x
		move	d2,y
	
		add	#ballb/2,d1
		move	d1,d5
		move	d2,d6
	
		move.b	7(A1),d4
		bsr	CheckBlock
		move.b	d4,7(A1)
		add	d3,x
		move	x,d5
		move	y,d6
		add	#ballh/2,d6
		add	#ballb,d5	
		tst.b	changed
		bne.s	up11

		move.b	6(A1),d4
		bsr	CheckBlock
		move.b	d4,6(A1)
up11:
		movem.l	(sp)+,d0-d7
		move	x,d1
		move	y,d2
		bra	testit
up2:
		tst.b	d3
		bmi.s	up3
	
		tst.b	d4
		bmi.s	up3

		move	#2,ch
		movem.l	d0-d7,-(sp)
		add.b	d4,d2
		move	d1,x
		move	d2,y

		add	#ballb/2,d1
		add	#ballh,d2
		move	d1,d5
		move	d2,d6

		move.b	7(A1),d4
		bsr	CheckBlock
		move.b	d4,7(A1)
		move	x,d5
		add	d3,d5
		add	d3,x
		tst.b	changed
		bne.s	up21

		move	y,d6
		add	#ballh/2,d6
		add	#ballb,d5	

		move.b	6(A1),d4
		bsr	CheckBlock
		move.b	d4,6(A1)

up21:		movem.l	(sp)+,d0-d7
		move	x,d1
		move	y,d2
		bra	testit

up3:		tst.b	d3
		bpl.s	up4

		tst.b	d4
		bmi.s	up4			

		move	#3,ch
		movem.l	d0-d7,-(sp)
		add.b	d4,d2
		move	d1,x
		move	d2,y

		add	#ballb/2,d1
		add	#ballh,d2
		move	d1,d5
		move	d2,d6

		move.b	7(A1),d4
		bsr	CheckBlock
		move.b	d4,7(A1)

		move	x,d5
		add	d3,d5
		add	d3,x
		tst.b	changed
		bne.s	up31

		move	y,d6
		add	#ballh/2,d6
		move.b	6(A1),d4
		bsr	CheckBlock
		move.b	d4,6(A1)
up31:
		movem.l	(sp)+,d0-d7
		move	x,d1
		move	y,d2
		bra.s	testit
up4:
		tst.b	d3
		bpl.s	up5
	
		tst.b	d4
		bpl.s	up5			

		move	#4,ch
		movem.l	d0-d7,-(sp)
		add.b	d4,d2
		move	d1,x
		move	d2,y

		add	#ballb/2,d1
		move	d1,d5
		move	d2,d6

		move.b	7(A1),d4
		bsr	CheckBlock
		move.b	d4,7(A1)

		move	x,d5
		add	d3,d5
		add	d3,x
		tst.b	changed
		bne.s	up41

		move	y,d6
		add	#ballh/2,d6

		move.b	6(A1),d4
		bsr	CheckBlock
		move.b	d4,6(A1)
up41:
		movem.l	(sp)+,d0-d7
		move	x,d1
		move	y,d2
up5:
testit:
		move.l	spr,a1
		move	x,d1
		move	y,d2

		cmp	#160,d1
		bhi.s	NotAdd
		tst.b	changed
		beq.s	NotAdd
		cmp	#1,ch
		bne.s	notch1

		bsr	Rnd
		btst	#0,d0
		beq.s	notch1
		addq	#1,d1
notch1:
		cmp	#2,ch
		bne.s	notch2
		cmp	#79,d1
		blo	notch2

		bsr	Rnd
		btst	#0,d0
		beq.s	notch2
		subq	#1,d2
notch2:
		cmp	#3,ch
		bne.s	notch3
		cmp	#150,d1
		bhi.s	notch3

		bsr	Rnd
		btst	#0,d0
		beq.s	notch3
		addq	#1,d1
notch3:
		cmp	#4,ch
		bne.s	notch4
		cmp	#180,d2
		bhi.s	notch4

		bsr	Rnd
		btst	#0,d0
		bne.s	notch4
		addq	#1,d2
notch4:
NotAdd:
		cmp.b	#79,d1
		bhi.s	notleft
		tst.b	6(A1)
		bpl.s	notleft
		neg.b	6(A1)
		bsr	SoundOn2
		bra.s	notright
notleft:
		cmp.b	#159,d1
		blo.s	notright		
		tst.b	6(A1)
		bmi.s	notright
		neg.b	6(A1)
		bsr	SoundOn2
notright:	
		tst.b	7(A1)
		bpl	notoben
	
		cmp.b	#53,d2
		bhi.s	notoben
		neg.b	7(A1)
		bsr	SoundOn2
notoben:
		move.l	(A1),a0
		move.b	d1,4(A1)
		move.b	d2,5(A1)
		move.b	d1,1(A0)
		move.b	d2,(A0)
		addq.b	#7,d2
		move.b	d2,2(A0)
		bsr	checkspry
		move.l	spr,a1
		bsr	checkball
	
		tst.b	changed
		beq.s	gorts
	
		move.l	spr,a1
		move.l	sprite,a2	
		add.b	#1,5(A1)
		add.b	#1,(A2)
		add.b	#1,2(A2)
gorts:
		rts





	*** Main Interrupt ***

MainInt:	movem.l d1-d7/a0-a6,-(sp)

	IFD	TIME
		move	#$00f,$dff180
	ENDC
	
		tst	EndGame
		bne.s	NoTrp
	
		tst.b	Paused
		bne.s	EndInt2
	
		bsr	MouseHandler

	;	bsr	DrawSchlaeger
	;	bsr	Flash
	;	bsr	DoLaser
	;	bsr	HandleSchlaeger

		bsr	MoveSpr

	;	bsr	CheckColl

EndInt2:	;cmp.b	#2,Paused
		;beq.s	NoTrp
		;bsr	MoveShoot

		;cmp.b	#3,Paused
		;beq.s	NoTrp
		;bsr	MoveFSpr
		;bsr	MoveF2Spr
		;bsr	DoLoch
	
		;cmp.b	#4,Paused
		;beq.s	NoTrp
		;bsr	MakeBlitz

NoTrp:		;bsr	MakeLives
		bsr	ColorCycle1
		bsr	Soundi

endint:
	IFD	TIME
	 clr	$dff180
	ENDC
		movem.l (sp)+,d1-d7/a0-a6
		moveq	#0,d0
		rts





CheckColl:	move	$dff00e,d0
		btst	#9,d0
		beq.s	NoSprColl

		bsr	Zitter
		bsr	SoundOn4

		lea	fspr2,a1
		clr.l	(A1)
		clr	Away

NoSprColl:	rts





	*** Zum vorherigen Level springen ***

PreLevel:	move.b	#1,Paused
		clr.b	plevel

		tst.l	Stufe2
		bne.s	endPreLevel

		add.l	#190,Stufe2

endPreLevel:	sub.l	#380,Stufe2





	*** Zum nächsten Level springen ***


NextLevel:	move.b	#1,Paused
		btst	#6,$bfe001
		beq.s	NextLevel


	*** Int off ***

		moveq	#4,d0
		lea	MainIntStruct,a1
		Exec	RemIntServer


	*** Sound off ***

		lea	$dff000,a5
		move	#$f,$96(A5)

		Gfx	WaitTOF

	*** Play Fx ***

		move.l	#Harve+2000,$a0(A5)
		move	#12489,$a4(A5)
		move	#180,$a6(A5)
		move.l	#Harve,$b0(A5)
		move	#13489,$b4(A5)
		move	#180,$b6(A5)
		move.l	#Harve,$c0(A5)
		move	#13489,$c4(A5)
		move	#180,$c6(A5)
		move.l	#Harve+2000,$d0(A5)
		move	#12489,$d4(A5)
		move	#180,$d6(A5)
		move	#$800f,$96(A5)

		clr	Away
		bsr	ClearFlash
		clr.b	nlevel

		bsr	ClearSpr
		lea	spr1,a1
		lea	spr2,a2
		clr.b	4(a1)
		clr.b	4(a2)	
	


	*** Check for CCN ***

		tst.b	CCN
		beq.s	NoZGame

		clr	LGame	
		addq	#1,LGameCnt
		cmp	#3,LGameCnt
		bne.s	NoZGame			
	
		clr	LGameCnt
		move	#1,LGame
	
		bra.s	Repeat2


NoZGame:
	*** Load next Dino ***

		bsr	LoadBackPic

	*** Stop SoundFx ***

Repeat2:	lea	$dff000,a5
		move.l	#Leer,$a0(A5)
		move	#2,$a4(A5)
		move.l	#Leer,$b0(A5)
		move	#2,$b4(A5)
		move.l	#Leer,$c0(A5)
		move	#2,$c4(A5)
		move.l	#Leer,$d0(A5)
		move	#2,$d4(A5)


	*** Powerturm abbauen ***

Repeat:		move.l	_GfxBase,a6
	;	not.w	FlipFlag
	;	tst.w	FlipFlag
	;	beq.s	sdf1

		Last	WaitTOF

sdf1:		addq	#2,Power
		addq.l	#1,Score
		cmp	#230,Power
		bhi.s	sdf3
	
		move	Power,d0
		divu	#10,d0

sdf2:		lea	Powerturm,a0
		lea	Powercol,a3

sdf:		cmp	#$18a,(a0)+
		bne.s	sdf
		move	(a3)+,(a0)
		dbf	d0,sdf

		bsr	Print

		bra	Repeat


	*** Ausblenden ***

sdf3:		bsr	Dunk
;		move	#$120,$dff180

		add.l	#190,Stufe2
		cmp.l	#6080,Stufe2
		bne.s	c5

		move	#2,EndGame
		bra	Haupt

c5:		tst	LGame
		beq	NoZGame2

		clr	LGame
	;	move	#$10,$dff09a
		bsr	CCNut				* Play CocoNut Game

		move	NutCounter,d0
		tst	d0
		beq	ENDCCNCNT

		mulu	#25,d0
		move.l	d0,-(sp)

		bsr	Clear

		lea	Mesg,a0
		lea	Page1+$dbf,a1
		bsr	PrintText2

		lea	CopCol5+6,a1
		move	#$ff0,(A1)
		bsr	InitHiCopper
		move.l	#copperl5,$dff080
		move	#$8103,$dff096

		move.l	(sp)+,d4
		move	#400,spe
		move	#1,LochCnt2

CountIt:;	move.l	#50,d1
		DOS	Delay
		Gfx	WaitTOF

		move.l	Score,d3
		moveq	#4,d6
		lea	ScoreAsc+6,a3

RepCI:		divu	#10,d3
		swap	d3
		add.b	#'0',d3
		move.b	d3,-(A3)	
		clr	d3
		swap	d3
		dbf	d6,RepCI

		lea	ScoreAsc,a0
		lea	Page1+$1279,a1
		bsr	PrintText2

		addq.l	#5,Score
		move.l	Score,d0
		bsr	AddLives

		add	#1,LochCnt2
		cmp	#4,LochCnt2
		bne.s	Nodec

		clr	LochCnt2
		subq	#1,spe

Nodec:		lea	$dff000,a5
		move.l	#ScoreSound,$a0(A5)
		move	#1313,$a4(A5)
		move	spe,$a6(A5)
		move.l	#ScoreSound+500,$b0(A5)
		move	#1063,$b4(A5)
		move	spe,$b6(A5)

		subq.l	#1,d4
		tst.l	d4
		bhi	CountIt


ENDCCNCNT:	clr	$a8(A5)
		clr	$b8(A5)

		clr	LGame
	;;	move	#$8010,$9a(a5)
		move	#$103,$96(a5)

		moveq	#30,d7
Ver:		Gfx	WaitTOF
		dbf	d7,Ver

		move.l	#copperl4,$dff080

		bsr	Clear
		bsr	LoadScr
		bsr	LoadStage

;		moveq	#50,d7
;		move.l	_GfxBase,a6
;PleaseWait:	Gfx	WaitTOF
;		dbf	d7,PleaseWait


NoZGame2:	move.l	#copperl4,$dff080		* Schwarz

		bsr	CopyPic

		bsr	ClearBonus
		move.l	#4,schl
		move.l	#4,schl2
		lea	shoot1,a5
		clr.b	(a5)
		move.b	#3,2(A5)
		lea	sprite2,a5
		clr.b	1(a5)
	
		move.b	#1,alter
		clr.b	falling
		lea	fspr1,a3
		clr.b	1(a3)
		clr	MousX

		bsr	BuildLevel
		bsr	Print
		bsr	ClrShadow
		bsr	ShadowAll

	;;	move.l	#Int,$6c

		moveq	#4,d0
		lea	MainIntStruct,a1
		Exec	AddIntServer

		move.l	#copperl2,$dff080
		move	#$8100,$dff096
		bsr	Hell

		move.l	#copperl,$dff080
		bsr	RestorePower

EndNextLevel:	bra	Haupt2




	*** Bildschirm ausblenden ***

Dunk:		lea	coppercol2,a4
		lea	coppercol,a3
		moveq	#31,d7
1$:		move.l	(A3)+,(a4)+
		dbf	d7,1$

		bsr	InitCopper2
		move.l	#copperl2,$dff080
		moveq	#15,d5

2$:		Gfx	WaitTOF

		lea	coppercol2+2,a3
		moveq	#31,d6

3$:		move.b	1(a3),d4
		and.b	#$0f,d4
		tst.b	d4
		beq.s	4$
		sub	#$0001,(a3)

4$:		move.b	1(a3),d4
		and.b	#$f0,d4
		tst.b	d4
		beq.s	5$
		sub	#$0010,(a3)

5$:		move.b	(a3),d4
		and.b	#$0f,d4
		tst.b	d4
		beq.s	6$
		sub	#$0100,(a3)

6$:		addq.l	#4,a3

		dbf	d6,3$
		dbf	d5,2$

		move	#$120,$dff096
		move.l	#copperl4,$dff080

		rts




	*** Bildschirm einblenden ***

Hell:		lea	coppercol+58,a4
		move	#$aab,(a4)
		move	#$950,4(A4)

		moveq	#15,d5
Heller:		Gfx	WaitTOF

		lea	coppercol+2,a4
		lea	coppercol2+2,a3
		moveq	#31,d6
Heller2:
		move.b	1(A4),d3
		and.b	#$f,d3
		move.b	1(a3),d4
		and.b	#$f,d4
	
		cmp.b	d4,d3
		beq.s	okh1
		add	#1,(a3)
okh1:
		move.b	1(A4),d3
		and.b	#$f0,d3	
		move.b	1(a3),d4
		and.b	#$f0,d4

		cmp.b	d4,d3
		beq.s	okh2
		add	#$0010,(a3)
okh2:
		move.b	(A4),d3
		and.b	#$0f,d3
		move.b	(a3),d4
		and.b	#$0f,d4

		cmp.b	d4,d3
		beq.s	okh3
		add	#$0100,(a3)
okh3:
		addq	#4,a3
		addq	#4,a4
		dbf	d6,Heller2
		dbf	d5,Heller

		rts





	*** Farbcycling ***

ColorCycle1:	lea	cycle1+2,a0
		lea	cyclelist1,a1

		tst	c1cnt
		bne.s	notc0
		move	#178,c1cnt

notc0:		sub	#2,c1cnt
		add	c1cnt,a1
		move	#8,d6
notc01:		move	(a1)+,(a0)
notc02:		cmp	#$18a,(a0)+
		bne.s	notc02
		cmp.l	#ENDClist1,a1
		bls.s	snext1
		lea	cyclelist1,a1
snext1:		dbf	d6,notc01

		lea	cycle2+2,a0
		lea	cyclelist2,a1
		tst	c2cnt
		bne.s	notc1
		move	#182,c2cnt

notc1:		subq	#2,c2cnt
		add	c2cnt,a1
		moveq	#22,d6

notc11:		move	(a1)+,(a0)

notc22:		cmp	#$1be,(a0)+
		bne.s	notc22

		cmp.l	#ENDClist2,a1
		bls.s	snext2
		lea	cyclelist2,a1

snext2:		dbf	d6,notc11
		rts





	*** Pause Funktion ***

Pause:		move.b	#2,Paused

		cmp.b	#$7f,$bfec01
		beq.s	Pause


	*** Save Background ***

		move.l	#buffer,a2
		move.l	Screen1,a1
		add.l	#6010,a1

		moveq	#10-1,d7
.copy11:	moveq	#20-1,d6
.copy12:	move.b	(A1),(a2)+
		move.b	8000(A1),(A2)+
		move.b	16000(A1),(A2)+
		move.b	24000(A1),(A2)+
		move.b	32000(A1),(A2)+
		addq.l	#1,a1
		dbf	d6,.copy12

		add.l	#20,a1
		dbf	d7,.copy11


	*** Print Text ***

		lea	Pausetext,a0
		move.l	Screen1,a1
		add.l	#6010,a1
		bsr	Printtext

	*** Wait for Key, Mouse etc. ***


.Pause2:	btst	#6,$bfe001
		beq.s	.Pause3
		btst	#7,$bfe001
		beq.s	.Pause3

		cmp.b	#$7f,$bfec01
		bne.s	.Pause2

.Pause3:	cmp.b	#$7f,$bfec01
		beq.s	.Pause3


	*** Restore Screen ***

		move.l	#buffer,a2		
		move.l	Screen1,a1		
		add.l	#6010,a1

		moveq	#10-1,d7
.copy21:	moveq	#19,d6
.copy22:	move.b	(A2)+,(A1)
		move.b	(A2)+,8000(A1)
		move.b	(A2)+,16000(A1)
		move.b	(A2)+,24000(A1)
		move.b	(A2)+,32000(A1)
		addq	#1,a1
		dbf	d6,.copy22

		add.l	#20,a1
		dbf	d7,.copy21

	*** Return ***

		clr.b	Paused
		bra	Haupt





	*** Ball auf Schlaeger setzen und warten bis Abwurf erfolgt ***

WaitStart:	move.b	#3,Paused
		move	#1,Kept2

		bsr	ClearSpr
		bsr	ClearBonus

		clr	waiter
		clr	BattleTime
		clr	Away

		bsr	FlashAll
		bsr	ClearFlash

		neg.b	Kept
		clr	MousX
		clr	imgX
		clr	LaserCnt
		move.l	#4,schl
		move.l	#4,schl2

		move	#61,MousX2
		move	#124,imgX2

		lea	sprite1,a1
		move.b	#218,(a1)
		move.b	#225,2(a1)
		move.b	#80,1(a1)
	
		lea	spr1,a2
		move.b	#218,5(a2)

		move.b	#80,4(a2)
		move.b	#1,6(A2)
		move.b	#-3,7(a2)

		bsr	Print
		bsr	Rnd
		and	#$003f,d0
		move	d0,DemoRnd

WaitStart2:	Gfx	WaitTOF

		tst.b	Demo
		beq.s	w3

WaSt:		move.l	$dff004,d0
		and.l	#$1ff00,d0
		cmp.l	#$e000,d0
		bne.s	WaSt

		move	DemoRnd,d4
		cmp	waiter,d4
		bne.s	w3
		bra	endwait23

w3:		bsr	MouseHandler
		tst.b	TwoPlayer
		beq	take2

		tst.b	Kept
		bmi.s	take2	
		move	MousX2,XPos
		move.b	$bfe001,d5
		bset	#6,d5
		bra.s	takeit	
take2:
		move.b	$bfe001,d5
		bset	#7,d5
		move	MousX,XPos
takeit:
		btst	#6,d5
		beq	endwait23
		btst	#7,d5
		beq	endwait23

		move	XPos,d0
		move.l	schl,d1
		bsr	DrawSchlaeger

		moveq	#0,d0
		move	XPos,d0
		move.b	d0,d2
		lsr.b	#1,d2
		add.b	#82,d2

		lea	sprite1,a1
		lea	spr1,a2
		move.b	d2,1(a1)	
		move.b	d2,4(a2)

		addq	#1,waiter
		cmp	#250,waiter
		bhi.s	endwait23	
		bra	WaitStart2

endwait23:	btst	#6,$bfe001
		beq.s	endwait23
		btst	#7,$bfe001
		beq.s	endwait23

		clr	Kept2
		clr.b	Paused
		rts






	*** Ball auf Schlaeger setzen und warten bis Abwurf erfolgt ***
	*** wie WaitStart() aber während des Spiels (Bonus)         ***

WaitBall:	move.b	#1,Paused
		clr	waiter
		clr	waitb

		lea	sprite1,a1
		lea	spr1,a2
		move	MousX,d4
		lsr	#1,d4
		move.b	1(a1),d3
		sub.b	d3,d4


WaitBall2:	Gfx	WaitTOF
WaS2:		move.l	$dff004,d0
		and.l	#$1ff00,d0
		cmp.l	#$e800,d0
		bne.s	WaS2

		lea	sprite1,a1
		tst.b	alter
		bne	endwaitball

		tst.b	TwoPlayer
		beq	take22

		tst.b	Kept
		bmi.s	take22			
		move	MousX2,XPos
		move.b	$bfe001,d5
		bset	#6,d5
		bra.s	takeit2	

take22:		move.b	$bfe001,d5
		bset	#7,d5
		move	MousX,XPos

takeit2:	btst	#7,d5
		beq.s	endwaitball
		btst	#6,d5
		beq.s	endwaitball

		lea	sprite1,a1
		lea	spr1,a2
		move.b	d2,1(a1)	
		move.b	d2,4(a2)

		bsr	MouseHandler

		clr.l	d0
		move	XPos,d0
		move.b	d0,d2
		lsr.b	#1,d2
		add.b	#82,d2
		lea	spr1,a2
		move.b	d2,1(A1)	
		move.b	d2,4(a2)

		bsr	DrawSchlaeger

		add	#1,waiter
		cmp	#250,waiter
		bhi.s	endwaitball
		bra	WaitBall2

endwaitball:	btst	#6,$bfe001
		beq.s	endwaitball
		btst	#7,$bfe001
		beq.s	endwaitball
		clr	BattleTime
		clr	Kept2
		clr.b	Paused
		bra	Haupt




	*** Level aufbauen ***

BuildLevel:	move	#$20,$dff096
		bsr	HtoZ
		bsr	SetBlockCols

		lea	ZSpeicher+190,a0

		moveq	#15,d2
2$:		moveq	#10,d1

1$:		moveq	#0,d0
		move.b	-(a0),d0
		and.b	#31,d0
		bsr	DrawBlock

		dbf	d1,1$
		dbf	d2,2$

		move	#1,EndGame2

		bsr	MakeLives

		clr	EndGame2
		rts



	*** Speicher löschen (mit Vorsicht zu geniessen) ***

Clear:		move.l	Screen1,a0
		move	#40*200*6/4-1,d0
2$:		clr.l	(a0)+
		dbf	d0,2$

		rts




	*** DinoPic in Bildschirm kopieren ***

CopyPic:	lea	buffer,a0
		move.l	Screen3,a1
		move.l	#25284,d4
		bsr	Decruncher

		move.l	Screen3,a1
		add.l	#28,a1

		moveq	#1,d7

1$:		moveq	#10,d6

2$:		clr	(A1)
		clr	5044(A1)
		clr	10088(A1)
		clr	15132(A1)
		clr	20176(A1)

		addq.l	#2,a1
		dbf	d6,2$
		addq.l	#4,a1
		dbf	d7,1$

		move.l	Screen3,a1
		addq.l	#2,a1
		move.b	#%10011111,d3
		move	#193,d7

3$:		and.b	d3,(A1)
		and.b	d3,5044(A1)
		and.b	d3,10088(A1)
		and.b	d3,15132(A1)
		and.b	d3,20176(A1)
	;;	or.b	#%01100000,25220(a1)
		add.l	#26,a1
		dbf	d7,3$
	


		move.l	Screen3,a1
		add.l	#25220,a1
		lea	coppercol+2,a2
		moveq	#8-1,d6

4$:		;move	(a1),(a2)
		;clr	(a1)+
		move.w	(a1)+,(a2)
		addq.l	#4,a2
		dbf	d6,4$

		add.l	#16,a1
		add.l	#32,a2

		moveq	#15-1,d6
5$:		;move	(A1),(a2)
		;clr	(A1)+
		move.w	(a1)+,(a2)
		addq.l	#4,a2
		dbf	d6,5$



		move.l	Screen3,a2
		move.l	Screen1,a1
		add.l	#242,a1

		moveq	#5-1,d4
.zloop:		move	#194-1,d5
.yloop:		moveq	#13-1,d6
.xloop:		move	(a2)+,(a1)+
		dbf	d6,.xloop
		add.l	#14,a1
		dbf	d5,.yloop
		add.l	#240,a1
		dbf	d4,.zloop

		clr	loaded

		rts




	*** Hiscore laden ***

LoadHiScore:
	;	move	#2,Command
	;	move.l	#HiList,Ziel
	;	move.l	#DiskScore,Offset
	;	move.l	#$600,Laenge
	;	bsr	StartTask
	;	bsr	WaitLoad

	;	move.l	#200,d1
	;	DOS	Delay

		lea	Hiscore_File,a0
		lea	HiList,a1
		move.l	#$600,d0
		bsr	LoadFile


	;	move.l	#200,d1
	;	DOS	Delay

	;	move	#6,Command
	;	bsr	StartTask

		lea	HiList+8,a1
		move.l	(A1),hiScore

		rts



	*** Bildschirm aufbauen ***

LoadScr:

	*** Geräusche ***

		lea	Sound_File,a0
		lea	BallStein,a1
		move.l	#512*132,d0
		bsr	LoadFile


	*** Flugbahn ***

		lea	Bahn_File,a0
		lea	Bahn1,a1
		move.l	#512*10,d0
		bsr	LoadFile		* Flugbahn


	*** Rahmen ***

	;	lea	Rahmen_File,a0
	;	lea	buffer,a1
	;	move.l	#50*512,d0
	;	bsr	LoadFile		* Rahmen

	;	lea	buffer,a0
	;	move.l	Screen1,a1
	;	move.l	#40000,d4
	;	bsr	Decruncher

	;	lea	Test_File,a0
	;	move.l	Screen1,a1
	;	move.l	#40000,d0
	;	bsr	SaveFile

	;	move.l	#100,d1
	;	DOS	Delay

		lea	Rahmen_File,a0
		move.l	Screen1,a1
		move.l	#79*512,d0
		bsr	LoadFile		* Rahmen


	*** Background (Elements) ***

		lea	Back_File,a0
		move.l	Screen2,a1
		move.l	#512*79,d0
		bsr	LoadFile		* Schlaeger, Kloetzchen


	*** Dino Pictures ***

		bsr	LoadBackPic
		bsr	CopyPic

		rts



	*** Hintergrundbild (Dino) laden ***


LoadBackPic:	movem.l	d0-d7/a0-a6,-(sp)

		lea	Dino_File,a0
		move.b	piccounter,11(a0)
		lea	buffer,a1
		move.l	#512*46,d0
		bsr	LoadFile

		add.b	#1,piccounter
		cmp.b	#'9',piccounter
		bne.s	1$

		move.b	#'1',piccounter

1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts




	*** Bildschirn zittern lassen ***

Zitter:		clr.l	d2
		move	$dff006,d2
		and	#7,d2
		lsl	#1,d2
		lea	shake_table,a3
		add.l	d2,a3
		lea	spr1,a1
		move.b	(a3)+,6(a1)
		move.b	(a3),7(a1)
		lea	spr2,a2
		move	$dff006,d2
		and	#7,d2
		lsl	#1,d2
		lea	shake_table,a3
		add.l	d2,a3
		move.b	(a3)+,6(a2)
		move.b	(a3),7(a2)
		rts




ChkSchl:	move	dist,d2
		tst	d2
		bpl.s	ck1
		neg	d2

ck1:		move	MousX,d0
		cmp	#1,d0
		bne.s	ck2
		cmp	#10,d2
		bls.s	ck2
		bsr	Zitter

ck2:		clr.l	d1
		move	schl,d1
		lsl	#1,d1
		lea	tabelle,a4
		move	(a4,d1.l),d1	
		add.l	#10,d1
		cmp	d1,d0
		bne.s	ck3
		cmp	#10,d2
		bls.s	ck3
		bsr	Zitter

ck3:		rts





Printtext:	moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	1$

		bsr	Printletter
		bra.s	Printtext

1$:		rts



PrintText2:	moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	endpt2

		bsr	Printletter2
		bra.s	PrintText2

endpt2:		rts



Printletter:	move.l	a1,a3
		sub.b	#' ',d0
		mulu	#10,d0
		lea	Font,a2
		add.l	d0,a2

		moveq	#9,d7
1$:		move.b	(A2)+,d2
		or.b	d2,(a3)
		or.b	d2,8000(a3)
		or.b	d2,16000(a3)
		or.b	d2,24000(a3)
		or.b	d2,32000(a3)
		add.l	#40,a3
 		dbf	d7,1$
		addq.l	#1,a1
		rts


Printletter2:	move.l	a1,a3
		sub.b	#' ',d0
		mulu	#10,d0
		lea	Font,a2
		add.l	d0,a2

		moveq	#9,d7
2$:		move.b	(A2)+,(a3)
		add.l	#48,a3
	 	dbf	d7,2$
		addq.l	#1,a1
		rts



AddLives:	move.l	Score,d0
		lea	shiptable,a3
		add.l	stc,a3
		move.l	(A3),d2
		cmp.l	d0,d2
		bhi.s	noLives2

		add.b	#1,Lives
		add.l	#4,stc

noLives2:	rts




Print:		movem.l	d0-d7/a0-a6,-(sp)

		move.l	Score,d0
		bsr	GetPosition
		move.l	d0,Place
		cmp	#1,d0
		bne.s	notfirst
		clr.l	points
		bra.s	Printit2

notfirst:	tst.l	d0
		bne.s	notzero2
		move.l	#max_entry,d0

notzero2:	lea	HiList+8,a1
		subq	#2,d0
		mulu	#12,d0
		add.l	d0,a1

		move.l	(A1),d2
		sub.l	Score,d2
		move.l	d2,points		

Printit2:	move.l	Score,d0
		move.l	hiScore,d1
		cmp.l	d1,d0
		blo.s	notmore
		move.l	Score,hiScore

notmore:	tst.b	Demo
		bne.s	noLives	

		move.l	Score,d0
		bsr	AddLives

noLives:	move.l	Screen1,a2
		add.l	#1876,a2
		move.l	a2,a0
		lea	Font+160,a1
		bsr	wletter
		subq	#1,a2	
		move.l	points,d0
		moveq	#5,d6
		bsr	Printcount		

		move.l	Screen1,a2
		add.l	#5516+40,a2
		move.l	a2,a0
		lea	Font+160,a1
		bsr	wletter
		subq	#1,a2	

		moveq	#0,d0
		move.l	Score,d0
		moveq	#5,d6
		bsr	Printcount	
	
		move.l	Screen1,a2
		add.l	#7396,a2
		move.l	a2,a0
		lea	Font+160,a1
		bsr	wletter
		subq	#1,a2	
		move.l	hiScore,d0
		moveq	#5,d6
		bsr	Printcount	

		move.l	Screen1,a2
		add.l	#3711,a2
		move.l	Stufe2,d0
		divu	#190,d0
		addq	#1,d0
		moveq	#1,d6
		bsr	Printcount		

		move.l	Screen1,a2
		add.l	#3717,a2
		move.l	Place,d0
		moveq	#1,d6
		bsr	Printcount		

		movem.l	(sp)+,d0-d7/a0-a6
		rts





Printcount:	move.l	a2,a0
		lea	Font,a1
ploop2:
		move.l	a2,a0
		divu	#10,d0
		swap	d0
		move	d0,d1
		clr.w	d0
		swap	d0
		add	#16,d1
		mulu	#10,d1
		lea	Font,a1
		add.l	d1,a1
		bsr	wletter
		subq	#1,a2
		dbf	d6,ploop2

		rts



wletter:	moveq	#10-1,d5
1$:		move.b	(a1),(a0)
		move.b	(a1),8000(a0)
		move.b	(a1),16000(a0)
		move.b	(a1),24000(a0)
		move.b	(a1)+,32000(a0)
		add.l	#40,a0
		dbf	d5,1$
		rts



MoveShoot:	lea	shoot1,a4
		tst.b	(a4)
		bne.s	OkShoot
		rts

OkShoot:	sub.b	#6,(a4)
 		sub.b	#6,2(a4)
		cmp.b	#54,(a4)
		blo	zeroit

		lea	shoot1,a1
		clr.l	d2
		move.b	(A1),d2
		sub	#50,d2
		lsr	#3,d2
		clr.l	d1
		move.b	1(A1),d1
		sub	#73,d1	;#77,d1
		lsr	#3,d1
		bsr	CheckBlock2
		tst.b	changed
		bne.s	zeroit

		lea	shoot1,a1
		clr.l	d2
		move.b	(A1),d2
		sub	#50,d2
		lsr	#3,d2
		clr.l	d1
		move.b	1(A1),d1
		sub	#81,d1	;#77,d1
		lsr	#3,d1
		bsr	CheckBlock2
		tst.b	changed
		bne.s	zeroit
		rts

zeroit:		lea	shoot1,a1
		clr	(a1)
		move.b	#4,2(a1)
		rts






MoveF2Spr:	lea	fspr3,a1
		tst.b	(a1)
		beq	nmoveb
		add.b	#2,(A1)
		add.b	#2,2(A1)
		cmp.b	#253,(A1)
		bls.s	nmoveb
		clr.l	(A1)
		add	#40,PowerSoll	
		bsr	SoundOn5
nmoveb:
		lea	fspr3,a1
		lea	shoot1,a2
		tst.b	(A1)
		beq.s	Dan
	
		move.b	1(A1),d0	
		move.b	1(A2),d1	
		add.b	#15,d0
		cmp.b	d0,d1
		bhi.s	Dan
	
		move.b	1(A1),d0	
		move.b	1(A2),d1	
		add.b	#8,d1
		cmp.b	d1,d0
		bhi.s	Dan
	
		move.b	(A1),d0
		move.b	(A2),d1
		cmp.b	d0,d1
		bhi.s	Dan
	
		clr.l	(a1)
		clr.l	(A2)
		add.l	#50,Score
		bsr	SoundOn4
	
		move.w	d0,-(sp)
		move.w	PowerSoll,d0
		lsr	#1,d0
		move.w	d0,PowerSoll
		move.w	(sp)+,d0
	
	;;	lsr	#1,PowerSoll
	
	;;	bra.s	Dan

Dan:
		lea	fspr2,a1
		tst.b	(a1)
		beq	endmove2
	
		addq	#2,f2cnt
		move.l	Bahn,a3
		add	f2cnt,a3
	
		cmp.b	#240,(a1)
		blo.s	endfg1
	
		clr.l	(a1)
		move	#4,f2cnt
		clr	Away
		bra	endmove2
endfg1:
		move.b	(a3)+,d0
		move.b	(a3)+,d1
		move.b	(a3)+,d2
		move.b	(a3)+,d3
		sub.b	d0,d2
		sub.b	d1,d3
		add.b	d3,(A1)
		add.b	d3,2(A1)
		add.b	d2,1(A1)
	
		move.b	1(a1),d1
		cmp.b	#75,d1
		bhi.s	nlkj
		move.b	#76,d1
nlkj:
		cmp.b	#162,d1
		blo.s	nkl
		move.b	#161,d1
nkl:	
		move.b	d1,1(A1)
		move.b	(a1),d2
	
		lea	fspr3,a2
		tst.b	(a2)
		bne.s	nobomb
	
		tst.b	Battle
		beq.s	nobomb
	
		lea	fspr2,a1
		cmp.b	#130,(A1)
		bhi	nobomb
		bsr	Rnd
		and.b	#$3f,d0
		tst.b	d0
		bne.s	nobomb
	
		lea	fspr3,a2
		lea	fspr2,a1
		move	(a1),(A2)
		move.b	(A1),2(A2)
		add.b	#11,2(A2)
nobomb:
		tst	Shapi
		bne.s	DoItoH
	
		addq	#1,ShapCNT
		move	ShapCNT,d3
		cmp	Speed,d3
		bne.s	NoThingChanged
DoItoH:
		clr	ShapCNT
		clr	Shapi
	
		addq.l	#4,PShap
		move.l	PShap,a1
		tst.l	(A1)
	
		bne.s	notendShape
		move.l	Shape,PShap
notendShape:
		move.l	PShap,a1
		cmp.l	oldshap,a1
		beq.s	NoThingChanged
		move.l	(A1),a4
	
		lea	fspr2+4,a3
		moveq	#98,d7
ClFl2Spr:
		clr.l	(A3)+
		dbf	d7,ClFl2Spr
	
		move	yhoehe,d6
		subq	#1,d6
		lea	fspr2+4,a2
copyShape:
		move.l	(A4)+,(A2)+
		dbf	d6,copyShape
		clr.l	(A2)
		move.l	PShap,oldshap
NoThingChanged:
		move	ytest1,d6
		cmp.b	d6,d2
		bls	endmove2
		move	ytest2,d6
		cmp.b	d6,d2
		bhi	endmove2
		move	MousX,d5
		lsr.b	#1,d5
		add.b	#74,d5
		cmp.b	d5,d1
		bls.s	Daneben33
		move.l	schl,d6
		lsl.l	#1,d6
		lea	tabelle2,a2
		add.l	d6,a2
		add	(a2),d5	
		cmp.b	d5,d1
		bhi.s	Daneben33
		bra.s	treffer33
Daneben33:
		move	MousX2,d5
		lsr.b	#1,d5
		add.b	#74,d5
	
		cmp.b	d5,d1
		bls	endmove2
		
		move.l	schl,d6
		lsl.l	#1,d6
		lea	tabelle2,a2
		add.l	d6,a2
		add	(a2),d5	
	
		cmp.b	d5,d1
		bhi.s	endmove2
treffer33:
		add	#30,PowerSoll
		lea	fspr2,a1
		clr.l	(a1)
		clr	Away
		bsr	SoundOn6
		bsr	ClearBonus
endmove2:
		rts



ClearSpr:	lea	sprite1,a1
		lea	sprite2,a2
		lea	fspr1,a3
		lea	fspr2,a4
		lea	fspr3,a5
		lea	shoot1,a6
		clr.l	(A1)
		clr.l	(A2)
		clr.l	(A3)
		clr.l	(A4)
		clr.l	(A5)
		clr.l	(A6)
		rts



ClearBonus:	clr.b	smash
		clr.b	hold
		clr.b	Auto
		clr.b	twoball
		clr.b	twoschl
		clr.b	revers
		clr.b	laser
		clr.b	level
		clr.b	smash
		move.l	#-1,extend
		move.l	#-1,extend2
		lea	sprite2,a1
		clr.b	1(A1)

		tst.b	Demo
		beq.s	nDemo
		move.b	#1,Auto
nDemo:		rts	



MoveFSpr:	movem.l	d0-d7/a0-a5,-(sp)
		clr.b	alter
		tst.b	falling
		beq	f2
	
		lea	fspr1,a3
		add.b	#2,(A3)
		add.b	#2,2(a3)	
		move.b	fdir,d5
		add.b	d5,fcounter
		cmp.b	#10,fcounter
		bne.s	notf10
		move.b	#-1,fdir
		bra.s	notf0
notf10:
		tst.b	fcounter
		bne.s	notf0
		move.b	#1,fdir
notf0:
		lea	fspr1+4,a4
		move.l	a4,a2
		clr.l	d5
		move.b	fcounter,d5
		mulu	#60,d5
		add.l	d5,a4
		move	#12,d6
writef:
		move.l	(a4)+,(a2)+
		dbf	d6,writef
	
		lea	fspr1,a1
		move.b	1(A1),d1
		move.b	(A1),d2
	
		tst.b	Demo
		bne	Hitschl
	
		cmp.b	#220,d2
		bls	Hitschl
		cmp.b	#232,d2
		bhi	Hitschl
	
		move	MousX,d5
		lsr.b	#1,d5
		add.b	#74,d5
	
		cmp.b	d5,d1
		bls.s	Daneben23
	
		move.l	schl,d6
		lsl.l	#1,d6
		lea	tabelle2,a2
		add.l	d6,a2
		add	(a2),d5	
	
		cmp.b	d5,d1
		bhi.s	Daneben23
		bra.s	treffer2
Daneben23:
		move	MousX2,d5
		lsr.b	#1,d5
		add.b	#74,d5
	
		cmp.b	d5,d1
		bls	Hitschl
		
		move.l	schl,d6
		lsl.l	#1,d6
		lea	tabelle2,a2
		add.l	d6,a2
		add	(a2),d5	
	
		cmp.b	d5,d1	
		bhi	Hitschl
treffer2:
		tst.b	bonus
		beq	Hitschl
	
		
		move.w	d0,-(sp)
		move.w	PowerSoll,d0
		lsr	#1,d0
		move.w	d0,PowerSoll
		move.w	(sp)+,d0

	
		cmp.b	#16,bonus
		bne.s	not16		
	
		tst.b	twoball
		bne.s	not16
	
		bsr	ClearBonus
		bsr	starttwo
		bra	cfall
not16:
		cmp.b	#11,bonus
		bne.s	not11
		tst.b	TwoPlayer
		bne.s	not11
	
		tst.b	Battle
		bne.s	not11
	
		tst.b	twoschl
		bne.s	not11
	
		bsr	ClearBonus
		tst.l	schl
		beq.s	endext
		move.l	#1,extend
		move.l	#1,extend2
endext:
		bra	cfall
not11:
		cmp.b	#10,bonus
		bne.s	not10		
	
		bsr	ClearBonus
		addq.b	#1,Lives
		bra	cfall
not10:
		cmp.b	#12,bonus
		bne.s	not12		

		tst.b	Battle
		bne.s	not12

		bsr	ClearBonus
		move.b	#1,hold
		bra	cfall	
not12:
		cmp.b	#13,bonus
		bne.s	not13		

		bsr	ClearBonus
		move.b	#1,Auto
		bra	cfall
not13:
		cmp.b	#9,bonus
		bne.s	not9

		tst.b	TwoPlayer
		bne.s	not9
		tst.b	Battle
		bne.s	not9
		bsr	ClearBonus
		move.b	#1,laser		
		bra	cfall
not9:
		cmp.b	#17,bonus
		bne.s	not17

		bsr	ClearBonus
		move.b	#1,revers

		tst.b	TwoPlayer
		bne.s	givenobonus

		move	MousX,d4
		btst	#0,d4
		bne.s	givenobonus
givebonus:
		move.b	#1,twoschl
		clr.b	revers
givenobonus:
		bra.s	cfall
not17:
		cmp.b	#15,bonus
		bne.s	not15
		bsr	ClearBonus
		move.b	#1,level	
		bra.s	cfall
not15:
Hitschl:
		cmp.b	#240,(a3)
		bls.s	f2
		clr.b	falling
		clr.b	(a3)
		move.b	#$b,2(A3)
f2:
		movem.l (sp)+,d0-d7/a0-a5
		rts



starttwo:	move.b	#1,twoball
		lea	sprite1,a3
		lea	sprite2,a4
		move.l	(a3),(a4)
	
		lea	spr1+4,a3
		lea	spr2+4,a4
		move.l	(a3),(a4)

		move	$dff006,d2
		and	#7,d2
		lsl	#1,d2
		lea	shake_table,a3
		add.l	d2,a3
		move.b	1(a3),3(a4)
		neg.b	2(a4)
		rts



cfall:		move.b	#1,alter
		lea	fspr1,a3
		clr.b	1(a3)
		clr.b	falling
		add.l	#10,Score
		bsr	SoundOn7
		bra	Hitschl




begin:		movem.l d0-d7/a0-a5,-(sp)
		tst.b	falling
		beq.s	okl
		movem.l	(sp)+,d0-d7/a0-a5
		rts


okl:		lea	falling,a2
		move.b	#1,(a2)
		move.b	d2,d6
		move.b	d1,d5
		lsl.b	#3,d5
		lsl.b	#3,d6
		add.b	#50,d6
		add.b	#81,d5

		lea	fspr1,a3
		move.b	d6,(a3)+
		move.b	d5,(a3)+
		add.b	#13,d6
		move.b	d6,(a3)+
		move.b	d7,bonus
		movem.l	(sp)+,d0-d7/a0-a5
		rts



AllesGeloescht:	lea	ZSpeicher+14,a4
		move	#175,d5

aloop:		move.b	(a4)+,d4
		tst.b	d4
		bne.s	aloop2
		dbf	d5,aloop
		moveq	#0,d0
		rts

aloop2:		cmp.b	#8,d4
		bne.s	aloop3
		dbf	d5,aloop
		moveq	#0,d0
		rts

aloop3:		move	#-1,d0
		rts




SetBlockCols:	lea	ZSpeicher+2,a0
		lea	coppercol+32+2,a1

		moveq	#5,d7
1$:		move	(a0)+,(a1)
		addq.l	#4,a1
		dbf	d7,1$

		rts



HtoZ:		lea	ZSpeicher,a0
		lea	HSpeicher,a1
		add.l	Stufe2,a1

		moveq	#94,d7
1$:		move	(a1)+,(a0)+
		dbf	d7,1$

		rts






InitSound:	move	#0,$dff0a8
		move	#0,$dff0b8
		move	#0,$dff0c8
		move	#0,$dff0d8

		move	#$800f,$dff096		
		rts



InitCopper:	lea	copperspr,a0
		bsr	ClearSprites

		lea	copperspr+2,a0

		move.l	#sprite1,d0	
		move	d0,4(a0)		
		swap	d0
		move	d0,(a0)		

		move.l	#sprite2,d0
		move	d0,12(a0)
		swap	d0
		move	d0,8(a0)
	
		move.l	#fspr3,d0
		move	d0,28(a0)
		swap	d0
		move	d0,24(a0)

		move.l	#fspr2,d0
		move	d0,20(a0)
		swap	d0
		move	d0,16(a0)

		move.l	#fspr1,d0
		move	d0,60(a0)
		swap	d0
		move	d0,56(a0)

		move.l	#shoot1,d0
	 	move	d0,52(a0)
		swap	d0
		move	d0,48(a0)


		lea	planes,a0
		move.l	Screen1,d0
		moveq	#6-1,d7
1$:		bsr	SetLong
		addq.l	#8,a0
		add.l	#40*200,d0
		dbf	d7,1$

		move.l	#copperl,$dff080	
		rts



LoadStage:	lea	Stage_File,a0
		move.b	StageName+5,Stage_File+13
		lea	HSpeicher,a1
		move.l	#12*512,d0
		bsr	LoadFile

		rts





	*** Alle Schatten generieren ***

ShadowAll:	move	#1,refy
sh:		bsr	Shadow
		add	#1,refy
		cmp	#15,refy
		bne.s	sh
		rts


	*** Alle Schatten löschen ***

ClrShadow:	move.l	Screen1,a1
		add.l	#40000,a1
		move	#2000-1,d7
clss:		clr.l	(A1)+
		dbf	d7,clss
		rts


	*** Schatten neu zeichnen ***

Shadow:		movem.l	d0-d7/a0-a5,-(sp)

		clr	refresh

		move.l	Screen1,a1
		lea	ZSpeicher+14,a2
		add.l	#40284,a1
	
		move	refy,d0
		tst	d0
		beq.s	nosub
		subq	#1,d0
nosub:
		mulu	#320,d0
		add.l	d0,a1		

		move	refy,d0
		tst	d0
		beq.s	nosub2
		subq	#1,d0
nosub2:
		mulu	#11,d0
		add.l	d0,a2		

		moveq	#2,d7
ylo:
		moveq	#10,d6
		clr	d5
xlo:
		addq	#1,d5
		tst.b	(A2)
		bne.s	wShadow
	
		move	#$0f,d0
		and	d0,162(A1)
		and	d0,202(A1)
		and	d0,242(A1)
		and	d0,282(A1)

		and	d0,322(A1)
		and	d0,362(A1)
		and	d0,402(A1)
		and	d0,442(A1)

		move	#$f000,d0
		and	d0,320(A1)
		and	d0,360(A1)
		and	d0,400(A1)
		and	d0,440(A1)

		bra.s	endShadow
wShadow:
		cmp	#11,d5
		beq.s	nott1

		tst.b	1(A2)
		bne.s	nott1

		move.b	#$f0,d2
		or.b	d2,162(A1)
		or.b	d2,202(A1)
		or.b	d2,242(A1)
		or.b	d2,282(A1)
nott1:
		tst.b	11(A2)
		bne.s	nott2

		move	#$0fff,d2
		or.w	d2,320(A1)
		or.w	d2,360(A1)
		or.w	d2,400(A1)
		or.w	d2,440(A1)
nott2:
		cmp	#11,d5
		beq.s	endShadow

		tst.b	12(A2)
		bne.s	endShadow

		move	#$f000,d2
		or.b	#$f0,322(A1)
		or.b	#$f0,362(A1)
		or.b	#$f0,402(A1)
		or.b	#$f0,442(A1)
endShadow:
		addq	#1,a2
		addq	#2,a1
		dbf	d6,xlo

		add	#320-22,a1
		dbf	d7,ylo

		movem.l	(sp)+,d0-d7/a0-a5
		rts



	*** Element flashen ***

CreateFlash:	lea	Flashlist,a2
		lea	ZSpeicher+14,a1
		move	#175,d7

mfl:		move.b	(a1),d4
		and.b	#$f,d4
		cmp.b	#7,d4
		bne.s	mfl1
		move.b	#1,(A2)
		bra.s	mfl3

mfl1:		cmp.b	#8,d4
		bne.s	mfl3
		move.b	#149,(a2)

mfl3:		addq	#1,a1
		addq	#1,a2
		dbf	d7,mfl
		rts	


	*** Alle Elemente flashen ***

FlashAll:	not	Flashcnt
		tst	Flashcnt
		bne.s	nend2
		rts


nend2:		moveq	#7,d6
		bsr	CreateFlash
flall1:		Gfx	WaitTOF
		bsr	Flash
		dbf	d6,flall1
		rts


	*** Alle Flashs löschen ***

ClearFlash:	lea	Flashlist,a1
		move	#74,d0
cfl:
		clr.l	(a1)+
		dbf	d0,cfl
		rts



Flash:		not	Flashcnt
		tst	Flashcnt
		bne.s	fend
		rts

fend:		moveq	#0,d1
		moveq	#0,d2
		lea	Flashlist,a1
		lea	ZSpeicher+14,a2
		move	#175,d7
floop:		tst.b	(A2)+
		beq.s	endf4
		tst.b	(a1)
		beq.s	endf4
		add.b	#1,(A1)
		cmp.b	#9,(a1)
		bne.s	f22
		clr.b	(A1)
		bra.s	endf4
f22:
		cmp.b	#157,(A1)
		bne.s	f3
		clr.b	(A1)
		bra.s	endf4
f3:
		clr.l	d0
		move.b	(a1),d0
		bsr	DrawFlash
endf4:
		add	#1,d1
		cmp	#11,d1
		bne.s	endf5
		clr	d1
		add	#1,d2
endf5:	
		addq.l	#1,a1
		dbf	d7,floop
		rts




DrawFlash:	movem.l d0-d7/a0-a5,-(sp)

		bsr	GetBlitter

		lea	$dff000,a5
		move.l	Screen2,a1
		add	#22,a1
		lsl	#1,d0
		add	d0,a1		
		move.l	Screen1,a3
		add	#284,a3
		lsl	#1,d1
		add	d1,a3
		mulu	#320,d2
		add	d2,a3		

		moveq	#4,d7

1$:		bsr	WaitBlitter

		move.l	a3,$54(a5)	
		move.l	a1,$50(A5)	
		move	#38,$64(A5)	
		move	#38,$66(A5)	
		clr	$42(A5)	
		move	#$9f0,$40(A5)	
		move.l	#-1,$44(a5) 
		move	#%1000000001,$58(A5)		
		add.l	#8000,a3
		add.l	#8000,a1
		dbf	d7,1$

		bsr	GiveBlitter

		movem.l	(sp)+,d0-d7/a0-a5
		rts	




DrawBlock:	movem.l d0-d7/a0-a5,-(sp)

		bsr	GetBlitter

		lea	$dff000,a5
		move	d2,refy
		bsr	Shadow

nosh:		cmp	#8,d0
		bls.s	nobonus
		moveq	#9,d0

nobonus:	move.l	Screen2,a1		
		lsl	#1,d0			
		add.l	d0,a1			
		move.l	Screen1,a2		
		add.l	#284,a2			
		lsl	#1,d1			
		add.l	d1,a2
		mulu	#320,d2
		add.l	d2,a2
	
		tst.b	d0
		beq	ClearBlock

		move	#38,$64(a5)		
		move	#38,$66(a5)		
		clr	$42(a5)			
		move	#$9f0,$40(a5)		
		move.l	#-1,$44(a5)	 
		moveq	#4,d7

DrawBlock2:	bsr	WaitBlitter

		move.l	a2,$54(a5)		
		move.l	a1,$50(a5)		
		move	#%1000000001,$58(a5)		
		add.l	#8000,a1
		add.l	#8000,a2
		dbf	d7,DrawBlock2

		bsr	GiveBlitter

		movem.l (sp)+,d0-d7/a0-a5
		rts



ClearBlock:	move.l	Screen3,a3
		add.l	#28,a3
		add.l	d1,a3
		divu	#320,d2
		mulu	#208,d2
		add.l	d2,a3
		move	#38,$66(a5)		
		move	#24,$64(a5)		
		clr	$42(a5)			
		move	#$9f0,$40(a5)		
		moveq	#4,d7

ClearBlock2:	bsr	WaitBlitter

		move.l	a3,$50(a5)		
		move.l	a2,$54(a5)		
	 	move.l	#-1,$44(a5)	
		move	#%1000000001,$58(a5)	
		add.l	#5044,a3
		add.l	#8000,a2
		dbf	d7,ClearBlock2

		bsr	GiveBlitter

		movem.l	(sp)+,d0-d7/a0-a5
		rts



DrawLive:	movem.l	d0-d7/a0-a5,-(sp)	

		bsr	GetBlitter

		lea	$dff000,a5
		move.l	Screen2,a0
		add.l	#20,a0
		move.l	a0,a1
		addq.l	#2,a1			
		move.l	Screen1,a2
		add.l	#40*192+24,a2
		lsl	#1,d0
		sub.l	d0,a2
		tst.b	d1
		beq	ClearLive

		move	#38,$60(a5)		
		move	#38,$62(a5)		
		move	#38,$64(a5)		
		move	#38,$66(a5)		
		clr	$42(a5)			
		move	#$fca,$40(a5)		
		move.l	#-1,$44(a5) 	
		moveq	#4,d7

1$:		btst	#14,$2(a5)
		bne.s	1$

		move.l	a0,$4c(a5)	
		move.l	a2,$48(a5)	
		move.l	a2,$54(a5)	
		move.l	a1,$50(a5)	
		move	#%1000000001,$58(a5)		
		add.l	#8000,a0
		add.l	#8000,a2
		dbf	d7,1$

		bsr	GiveBlitter

		movem.l	(sp)+,d0-d7/a0-a5
		rts



ClearLive:	lea	$dff000,a5
		move.l	Screen3,a3
		add.l	#186*26+22,a3
		sub.l	d0,a3
		move	#38,$66(a5)		
		move	#24,$64(a5)		
		clr	$42(a5)			
		move	#$9f0,$40(a5)		
		moveq	#4,d7

1$:		bsr	WaitBlitter

		move.l	a3,$50(a5)		
		move.l	a2,$54(a5)		
	 	move.l	#-1,$44(a5) 
		move	#%1000000001,$58(a5)
		add.l	#5044,a3
		add.l	#8000,a2
		dbf	d7,1$

		bsr	GiveBlitter

		movem.l	(sp)+,d0-d7/a0-a5
		rts






Explosion:	move.b	#1,Paused
		move	#1,EndGame2
		clr.b	exploding

		lea	$dff000,a5
		bsr	ClearBonus
		bsr	ShadowAll

		lea	sprite1,a1
		clr.l	(A1)
		lea	sprite2,a1
		clr.l	(A1)
		lea	shoot1,a1
		clr.l	(A1)
		lea	fspr1,a1
		clr.l	(A1)
		lea	fspr2,a1
		clr.l	(A1)
		lea	fspr3,a1
		clr.l	(A1)

		move	#$F,$96(A5)
		move.l	#StockZerfall,$a0(A5)
		move	#3926,$a4(A5)
		move	#180,$a6(A5)
		move.l	#StockZerfall,$b0(A5)
		move	#3926,$b4(A5)
		move	#180,$b6(A5)
		move	#16,SoundcNT2
		move	#16,SoundcNT1
		move	#$8003,$96(A5)

		clr	Power
		move.l	#4,schl
		move.l	#4,schl2
		move	MousX,x
		move	MousX2,x2
		clr.l	d6

explo2:		Gfx	WaitTOF

		move.l	Screen1,a2
		add.l	#7162,a2
		move.l	Screen3,a3
		add.l	#$1192,a3	

		bsr	GetBlitter

		move	#14,$66(a5)		
		clr	$64(a5)			
		clr	$42(a5)			
		move	#$9f0,$dff040		
		move.l	#-1,$44(a5)	
	

		moveq	#5,d7
1$:		btst	#14,$2(a5)
		bne.s	1$
	
		move.l	a2,$54(a5)		
		move.l	a3,$50(a5)		
		move	#%1010001101,$58(a5)	
		
		add.l	#8000,a2
		add.l	#5044,a3
		dbf	d7,1$

		bsr	GiveBlitter

	
		move.l	Screen2,a0
		lsl	#1,d6	
		lea	expltable,a4
		add.l	d6,a4
		add	(a4),a0	
		lsr	#1,d6
	
		move.l	a0,a1
		add.l	#2880,a1		
	
		move	x,d0
		move	d0,d3	
		and	#$000F,d3
		lsr	#3,d0
		bclr	#0,d0
		
		lsl	#8,d3
		lsl	#4,d3
		move	d3,d2
		add	#$fca,d2		
	
		move.l	Screen1,a2
		add.l	#6804,a2	
		add.l	d0,a2
		
		bsr	GetBlitter

		moveq	#4,d7

2$:		bsr	WaitBlitter
	
		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#34,$60(a5)		
		move	#34,$62(a5)		
		move	#34,$64(a5)		
		move	#34,$66(a5)		
		move	d3,$42(a5)		
		move	d2,$40(a5)		
		move.l	#-1,$44(a5)	
		move	#%10000000011,$58(a5)
		
		add.l	#8000,a0
		add.l	#8000,a2
		dbf	d7,2$
	
		bsr	GiveBlitter


		move.l	Screen2,a0
		lsl	#1,d6			
		lea	expltable,a4
		add.l	d6,a4
		add	(a4),a0			
		lsr	#1,d6
	
		move.l	a0,a1
		add.l	#2880,a1			
	
		move	x2,d0
		move	d0,d3			
		and	#$F,d3		
		lsr	#3,d0			
		bclr	#0,d0
		
		lsl	#8,d3
		lsl	#4,d3
		move	d3,d2			
		add	#$fca,d2		
	
		move.l	Screen1,a2		
		add.l	#6804,a2		
		add.l	d0,a2
		
		bsr	GetBlitter

		moveq	#4,d7

3$:		bsr	WaitBlitter
	
		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#34,$60(a5)
		move	#34,$62(a5)
		move	#34,$64(a5)
		move	#34,$66(a5)
		move	d3,$42(a5)
		move	d2,$40(a5)
		move.l	#-1,$44(a5)	
		move	#%10000000011,$58(a5)
		add.l	#8000,a0
		add.l	#8000,a2
		dbf	d7,3$
	
		bsr	GiveBlitter


		addq	#1,d6
		cmp	#18,d6
		bne	explo2
	
		clr	EndGame2
		sub.b	#1,Lives
		cmp.b	#-1,Lives
		bne.s	notLives
	
		tst.b	Cheat
		beq	GameOver
	
		clr.b	Lives			; Cheat

notLives:	bsr	MakeLives
		bsr	RestorePower
		clr.b	exploding

		bra	Haupt2		





GameOver:	move.l	Stufe2,d0
		cmp.l	HiStufe,d0
		bls.s	1$
		move.l	d0,HiStufe	

1$:		moveq	#25,d7
2$:		Gfx	WaitTOF
		dbf	d7,2$

		move	#1,EndGame
		bra	Haupt		




DoHiScore:	tst.b	Cheat
		bne.s	1$
		tst.b	Demo
		beq.s	2$
1$:		rts


2$:		lea	PlayerName,a0
		moveq	#8-1,d0
.ClearName:	move.b	#'.',(a0)+
		dbf	d0,.ClearName


		move.l	Score,d0
		bsr	GetPosition
		cmp	#100,d0
		beq.s	3$
		tst	d0
		bne.s	.Scored
3$:		rts


.Scored:	move.l	d0,d1
		subq.l	#1,d1
		mulu	#22*12,d1
		move.l	d1,ListcNT	
	
		tst.b	FromMenu
		bne.s	4$

		move.l	#PlayerName,a1	
		move.l	Score,d1
		bsr	InsertScore

4$:		bsr	ShowScore

		lea	Bob1,a1
		clr	8(A1)			
		move	#64,10(A1)		
		move	#-1,12(A1)		
		move	#-1,14(A1)		
		move.l	#AnimSeq1,54(A1)
		move.l	#AnimCoord1,58(A1)
		clr	20(A1)
		clr.l	44(a1)
		clr.l	50(A1)
		clr	62(A1)
		clr	66(A1)			
	

		moveq	#5,d0
		lea	HiscoreIntStruct,a1
		Exec	AddIntServer		* CopperInt anhängen

	
		tst.b	FromMenu
		bne	FMenu2

notre:		lea	Bob1,a1
		cmp	#244,8(A1)
		bne.s	notre
	
		bsr	GetName

		moveq	#50,d7
.WaitJump:	Gfx	WaitTOF
		dbf	d7,.WaitJump

		bsr	DrawEye

		lea	Bob1,a1
		clr.l	50(A1)
		move.l	#AnimSeq3,54(A1)		
		move.l	#AnimCoord3,58(A1)

		moveq	#75,d7
.WaitAnim:	Gfx	WaitTOF
		dbf	d7,.WaitAnim


FMenu2:		move	#1,NoPrint
		bsr	ListScore


		move.l	_GfxBase,a6
;FadeSound:	jsr	-270(A6)
;		subq	#2,$20000+24
;		tst	$20000+24
;		bpl.s	FadeSound

;		jsr	$20014


		moveq	#5,d0
		lea	HiscoreIntStruct,a1
		Exec	RemIntServer


	;;	move	#$10,$dff09a
	;;	move.l	VBlankVeq,$6c		
	;;	move	#$100,$dff096

		bsr	ClearScore
		bsr	SaveHiScore

		move.l	#copperl4,$dff080
	;	move	#$8010,$dff09a		

		clr.b	FromMenu
		clr	EndGame
		clr	NoPrint

		rts






ClearScore:	movem.l	d0-d7/a0-a6,-(sp)

		lea	Page1,a1
		move	#12000-1,d7
1$:		clr.l	(A1)+
		dbf	d7,1$

		movem.l	(sp)+,d0-d7/a0-a6
		rts



ClearPic:	lea	Page4,a1
		move	#10000-1,d7
1$:		clr.l	(A1)+
		dbf	d7,1$
		rts





ListScore:	move	#1,FromList

		bsr	ClearPic		
		bsr	WritePic		

		clr.b	TwoPlayer
		clr.l	Ticks


.Wait:		move	$dff006,d0
		and	#$ff00,d0
		cmp	#$c800,d0
		bne.s	.Wait

		btst	#6,$bfe001
		beq	.EndList

		move.b	$bfec01,d0
		cmp.b	#$75,d0
		beq	.EndList

		addq.l	#1,Ticks
		cmp.l	#1000,Ticks
		beq	.EndList

.NoCount:	bsr	MouseHandler
		move	imgX,d0
		mulu	#66,d0
		move.l	d0,ListcNT2

		cmp.b	#$5f,$bfec01
		bne.s	.ShowNotAll
		btst	#10,$dff016
		bne.s	.ShowNotAll

		cmp.l	#$81f0,ListcNT2
		blo.s	.EndJK
		move.l	#$81f0,ListcNT2
		bra.s	.EndJK

.ShowNotAll:	cmp.l	#$6408,ListcNT2
		blo.s	.EndJK
		move.l	#$6408,ListcNT2

.EndJK:		move.l	ListcNT,d0
		cmp.l	ListcNT2,d0
		beq	.Wait

		move.l	ListcNT2,ListcNT

		clr.l	Ticks
		bsr	CopyToPic		

		bra	.Wait

.EndList:	clr	FromList
		rts





WriteText2:	clr.l	d0
		move.l	d0,d1
		move.b	(A1)+,d0
		move.b	(A1)+,d1
		add.l	#1400,d1
		bsr	Write_Text
		addq.l	#1,a1
		tst.b	1(A1)
		bne.s	WriteText2
		rts



WritePic:	move.l	#1,HiCnt
		moveq	#2,d0
		moveq	#70,d1


Print_Numero:	move.l	HiCnt,d4
		lea	HiCntAscii+2,a3
		moveq	#1,d6
		bsr	MakeASCII

		lea	HiCntAscii,a1
		movem.l	d0-d1,-(sp)
		bsr	Write_Text
		movem.l	(sp)+,d0-d1

		addq.l	#1,HiCnt
		add.l	#12,d1			
		cmp.l	#100,HiCnt		
		bne.s	Print_Numero		

		moveq	#5,d0			
		moveq	#70,d1			
		moveq	#98,d5			
		clr.l	d4

WriteName:	lea	HiName,a4		
		lea	HiList-70,a5		
		add.l	d1,a5			
		move.l	(A5)+,(A4)+		
		move.l	(A5)+,(A4)+		

		lea	HiName,a1
		movem.l	d0-d7/a0-a5,-(sp)
		bsr	Write_Text
		movem.l	(sp)+,d0-d7/a0-a5	

		add.l	#12,d1			
		dbf	d5,WriteName

		lea	TopText,a1
		moveq	#5,d0
		moveq	#40,d1
		bsr	Write_Text		

		moveq	#70,d1
		moveq	#14,d0
		moveq	#98,d7

PrintScore:	lea	ScoreAscii+7,a3			
		lea	HiList+8-70,a4			
		move.l	(A4,d1.l),d4			
		moveq	#5,d6				
		bsr	MakeASCII			
	
		lea	ScoreAscii+2,a1
		movem.l	d0-d7/a0-a6,-(sp)
		bsr	Write_Text			
		movem.l	(sp)+,d0-d7/a0-a6
		add.l	#12,d1
		dbf	d7,PrintScore			

		lea	HUAText,a1
		bsr	WriteText2
		rts




MakeASCII:	divu	#10,d4
		swap	d4
		add.b	#'0',d4
		move.b	d4,-(A3)
		clr	d4
		swap	d4
		dbf	d6,MakeASCII
		rts



Write_Text:	lea	Page4,a2	
		mulu	#22,d1
		add.l	d1,a2
		add.l	d0,a2			

.Not_Finished:	tst.b	(A1)
		beq.s	.EndWrite
		bsr	Write_Letter
		addq.l	#1,a2
		addq.l	#1,a1			
		bra.s	.Not_Finished

.EndWrite:	rts



Write_Letter:	move.l	a2,a0			
		lea	Font,a3			
		clr.l	d0
		move.b	(A1),d0
		sub.b	#' ',d0
		mulu	#10,d0			
	
		add.l	d0,a3
		moveq	#9,d6			

1$:		move.b	(A3)+,(a0)
		add.l	#22,a0
		dbf	d6,1$
		rts



CopyToPic:	bsr	GetBlitter

		lea	$dff000,a5
		lea	Page1+29450,a1
		moveq	#1,d7

1$:		bsr	WaitBlitter

		move.l	#Page4,A4
		add.l	ListcNT,A4		
		move.l	#Page3,$50(A5)		
		move.l	A4,$4c(A5)		
		move.l	A1,$54(a5)		
		move.l	A1,$48(A5)		
		move.l	#$ffffffff,$44(A5)	
		clr	$62(A5)			
		clr	$64(A5)			
		move	#26,$60(A5)		
		move	#26,$66(A5)		
		clr	$42(A5)
		move	#$fca,$40(A5)
		move	#%10100000001011,$58(A5)	

		add.l	#9600,a1
		dbf	d7,1$

		bsr	GiveBlitter

		rts







InitHiCopper:	movem.l	d0-d7/a0-a6,-(sp)

		lea	sprites5,a0
		bsr	ClearSprites

		move.l	#Page1+8,d0
		lea	planes5,a0
		bsr	SetLong

		moveq	#5-1,d7
1$:		bsr	SetLong
		addq.l	#8,a0
		add.l	#48*200,d0
		dbf	d7,1$

		movem.l	(sp)+,d0-d7/a0-a6
		rts


ShowScore:	movem.l	d0-d7/a0-a6,-(sp)

		bsr	LoadAll			
		bsr	InitBobList
		bsr	PrintName		
		move	#$8100,$dff096

		bsr	InitHiCopper
		move.l	#copperl5,$dff080	

		bsr	CopyEye

	;;	bsr	LoadSound
	;;	jsr	$20008

		movem.l	(sp)+,d0-d7/a0-a6
		rts




DrawEye:	lea	EyeBuff,a2
		lea	Page1+30017,a1

		moveq	#3,d7
1$:		move.b	(a2)+,(A1)
		move.b	(a2)+,-19200(A1)
		move.b	(A2)+,-9600(A1)
		move.b	(A2)+,(A1)
		move.b	(A2)+,9600(A1)
		add.l	#48,a1
		dbf	d7,1$

		rts



CopyEye:	lea	EyeBuff,a2
		lea	Page1+30017,a1

		moveq	#3,d7
1$:		move.b	-28800(a1),(A2)+
		move.b	-19200(A1),(a2)+
		move.b	-9600(A1),(A2)+
		move.b	(A1),(A2)+
		move.b	9600(A1),(A2)+
		add.l	#48,a1
		dbf	d7,1$

		rts
	


CloseEye:	lea	Page1+30017,a1

		moveq	#3,d7
1$:		clr.b	-28800(A1)
		clr.b	-19200(A1)
		move.b	#$ff,-9600(A1)
		move.b	#$ff,(A1)
		clr.b	9600(A1)
		add.l	#48,a1
		dbf	d7,1$
		rts



DoPic:		lea	Bobs+43520,a0		
		lea	CopCol5+2,a2

		moveq	#31,d7
1$:		move	(A0)+,(A2)
		addq.l	#4,A2
		dbf	D7,1$

		lea	Bobs+43560,a1
		lea	RCol2+2,a2
		move	(A1),(A2)

		lea	Bobs,a0
		lea	Page3,a1
		move	#879,d7
.CopyMask:	move.l	(A0)+,(A1)+
		dbf	d7,.CopyMask		


		lea	Page1,a1
		moveq	#4,d5
CopyPlane:	move	#199,d6
Copy:		clr.l	(A1)+
		clr.l	(A1)+

		moveq	#9,d7
CopyLine:	move.l	(A0)+,(A1)+
		dbf	d7,CopyLine	
		dbf	d6,Copy
		dbf	d5,CopyPlane

		rts





HiscoreInt:	movem.l	d0-d7/a0-a6,-(a7)

	;;	jsr	$2000c

		btst	#6,$bfe001
		bne.s	notClear

		move	#1,endinter

notClear:	tst.b	FromMenu
		bne.s	NoBobs
	
		tst	NoPrint
		bne.s	NoBobs

		bsr	DrawBobs
		bsr	MoveBobs


NoBobs:		tst	eye2
		beq.s	zeroeye
		subq	#1,eye2
		bra.s	NoNewEye

zeroeye:	bsr	Rnd
		tst.b	d0
		bne.s	NoNewEye	
		move	#5,eye2

NoNewEye:	tst	eye2
		bne.s	ClearEye
		bsr	DrawEye
		bra.s	EndVblank

ClearEye:	bsr	CloseEye

EndVblank:	movem.l	(a7)+,d0-d7/a0-a6
		moveq	#0,d0
		rts




MoveBobs:	movem.l	d0-d5/a0-a2,-(sp)	
		move.l	BobList,a1
RepeatBob:
		add	#1,66(A1)
		move	66(A1),d3
		cmp	64(A1),d3
		bne	endmove
		move	#0,66(A1)

		move.l	58(A1),a3		
		cmp.l	#0,a3
		beq.s	endmove			

		tst.l	(A3)
		beq.s	endmove			

		cmp	#-2,(A3)
		bne.s	testPause		

		move.l	2(A3),8(A1)		
		addq.l	#6,58(A1)		
		bra.s	endmove
testPause:
		cmp	#-1,(A3)
		bne	noPause			

		addq.l	#4,58(A1)		
		move	2(A3),62(A1)		
noPause:
		tst	62(a1)			
		beq.s	doit			

		subq	#1,62(A1)		
		bra.s	endmove			
doit:
		move	8(a1),d0		
		move	10(A1),d1		
		move	(A3),d2			
		move	2(A3),d3		
		move	68(A1),d4
		move	70(A1),d5

		cmp	d0,d2
		bne.s	notreached
		cmp	d1,d3
		bne.s	notreached
		addq.l	#4,58(A1)		
notreached:
		cmp	d0,d2
		beq.s	notx
		bhi.s	subx
		sub	d4,8(A1)		
		bra.s	notx
subx:
		add	d4,8(A1)		
notx:
		cmp	d1,d3
		beq.s	endmove
		bhi.s	suby
		sub	d5,10(A1)		
		bra.s	endmove
suby:
		add	d5,10(A1)		
endmove:
		move.l	(A1),a1			
		cmp.l	#0,a1
		bne	RepeatBob	
		movem.l	(sp)+,d0-d5/a0-a2
		rts




LoadAll:;	move	#2,Command
	;	move.l	#Bobs,Ziel
	;	move.l	#37*512,Laenge
	;	move.l	#DiskHiPic,Offset
	;	bsr	StartTask
	;	bsr	WaitLoad
	;	cmp.l	#$7334c154,Summ
	;	bne.s	LoadAll


		lea	HiPic_File,a0
		lea	Bobs,a1
		move.l	#37*512,d0
		bsr	LoadFile

	;	moveq	#100,d1
	;	DOS	Delay

		move.l	#Bobs+18924,ReadC	
		move.l	#Bobs,LowWr		
		bsr	Decru			
		bsr	DoPic			

		bsr	ClearPic		
		bsr	WritePic		

		moveq	#58,d1
		move.l	Place,d2
		mulu	#12,d2
		add.l	d2,d1
		move	#5,d0

		lea	OverWrite,a1		
		bsr	Write_Text		
		bsr	CopyToPic		

		tst.b	FromMenu
		bne.s	NoLoad

LoadErr5:	;move	#2,Command
		;move.l	#Bobs,Ziel
		;move.l	#58*512,Laenge
		;move.l	#512*812,Offset
		;bsr	StartTask
		;bsr	WaitLoad
		;cmp.l	#$be0ace5a,Summ
		;bne.s	LoadErr5

		lea	HiBobs_File,a0
		lea	Bobs,a1
		move.l	#58*512,d0
		bsr	LoadFile

		;moveq	#100,d1
		;DOS	Delay

		move.l	#Bobs+29480,ReadC
		move.l	#Bobs,LowWr
		bsr	Decru			

NoLoad:		rts



DrawBobs:	movem.l	d0-d7/a0-a6,-(A7)
		move.l	BobList,a0
		lea	$dff000,a6

SearchLastBob:	tst.l	(A0)		
		beq.s	BobReconstLoop
		move.l	(A0),a0
		bra.s	SearchLastBob
	
BobReconstLoop:
		lea	BitmStr1,a2
		move.l	26(a0),a3
		move.l	a0,a5			
		add	#12,a5			
NoFlip3:
		move.l	(A5),d0
		move.l	8(a0),(A5)
		cmp.l	#-1,d0
		beq.s	EndReconst
		moveq	#0,d1
		move	d0,d1
		swap	d0
		and.l	#$ffff,d0
		lsr	#3,d0
		bclr	#0,d0
		mulu	(a2),d1
		add.l	d1,d0
		moveq	#0,d1
		move.b	5(a2),d1
		subq	#1,d1
		addq	#8,a2

BlitWait2:	bsr	WaitBlitter

		move.l	(A2)+,d3
		add.l	d0,d3
		move.l	d3,$54(a6)
		move.l	a3,$50(a6)
		clr	$42(A6)
		move	#$9f0,$40(A6)
		move.l	#-1,$44(A6)
		clr	$64(A6)
		move	24(a0),$66(a6)
		move	22(a0),$58(a6)
		add.l	36(A0),a3
		dbf	d1,BlitWait2
EndReconst:
		tst.l	44(A0)
		beq.s	EndRecLoop
		move.l	44(A0),a0
		bra	BobReconstLoop
EndRecLoop:		

		lea	Page1+$783c,a1
		lea	Page1+4014+28800,a2
		moveq	#1,d7
Wait_Blit78:
		btst	#14,$2(A6)
		bne.s	Wait_Blit78
	
		move	#$9f0,$40(A6)
		move.l	#$00ffff00,$44(A6)
		clr	$42(A6)
		move	#38,$66(A6)
		move	#38,$64(A6)
		move.l	a2,$54(A6)
		move.l	a1,$50(A6)
		move	#%1010000101,$58(A6)
		add.l	#9600,a2
		dbf	d7,Wait_Blit78

		move.l	BobList,a0
BobMainLoop:
		moveq	#0,d0
		move	20(a0),d0
		lsl	#2,d0
		lea	BobImageList,a1
		move.l	(a1,d0.l),a1		
		move.l	a1,a4
		add.l	40(A0),a4		
		lea	BitmStr1,a2
		move.l	26(A0),a3		
NoFlip2:		
		clr.l	d0
		move	8(a0),d0
		move	d0,d2
		and	#15,d2
		moveq	#12,d3
		lsl	d3,d2			
		lsr	#3,d0
		move	10(A0),d1
		mulu	(A2),d1
		add	d1,d0			

		movem.l	a2-a3,-(a7)
		clr	d7
		move.b	5(A2),d7
		subq	#1,d7
		addq	#8,a2

BlitWait3:	bsr	WaitBlitter

		move.l	(A2)+,d3
		add.l	d0,d3
		move.l	a3,$54(a6)		
		move.l	d3,$50(a6)
		clr	$42(a6)			
		move	#$9f0,$40(A6)		
		move	24(a0),$64(A6)		
		clr	$66(a6)
		move.l	#-1,$44(a6)
		move	22(a0),$58(a6)
		add.l	36(A0),a3
		dbf	d7,BlitWait3
		movem.l	(a7)+,a2-a3

		clr	d7
		move.b	5(A2),d7
		subq	#1,d7	
		addq	#8,a2
		cmp	#-2,20(a0)
		beq.s	NoAnimate

BlitWait1:	bsr	WaitBlitter

		move.l	(A2)+,a3
		add.l	d0,a3
		move.l	a3,$48(a6)		
		move.l	a1,$4c(A6)		
		move.l	a4,$50(a6)		
		move.l	a3,$54(a6)		
		move	d2,$42(a6)		
		move	#$0fca,d3
		or	d2,d3
		move	d3,$40(a6)		
		move	24(a0),$60(a6)		
		move	24(a0),$66(A6)		
		clr	$64(a6)
		clr	$62(A6)
		move.l	#$ffffffff,$44(a6)
		move	22(a0),$58(a6)
		add.l	36(A0),a1
		dbf	d7,BlitWait1
NoAnimate:
		addq	#1,50(A0)		
		move	50(A0),d0
		cmp	48(a0),d0		
		bne.s	NoAnim
		clr	50(A0)
AnimLoop:
		tst.l	54(A0)			
		beq.s	NoAnim
		move.l	54(A0),a1
		move	52(a0),d0
		add	d0,a1
		move	(A1),d0			
		cmp	#-3,d0
		beq.s	NoAnim
		cmp	#-1,d0			
		bne.s	LetsAnim
		clr	52(A0)			
		bra.s	AnimLoop
LetsAnim:
		move	d0,20(A0)		
		addq	#2,52(a0)		
NoAnim:
		tst.l	(a0)			
		beq.s	EndDrawBobs
		move.l	(A0),a0			
		bra	BobMainLoop

EndDrawBobs:	movem.l	(a7)+,d0-d7/a0-a6
		rts




InitBobList:	movem.l	d0-d3/a0-a1,-(A7)
		move.l	BobList,a0

BobInitLoop:	lea	BitmStr1,a1
		move	(a1),d1
		move	4(a0),d0
		move	d0,d2
		lsr	#4,d0
		and	#15,d2
		tst	d2
		beq.s	BobEven
		addq	#1,d0

BobEven:	moveq	#0,d2
		move	6(a0),d2
		moveq	#6,d3
		lsl	d3,d2
		or	d0,d2
		move	d2,22(a0)	

		lsl	#1,d0		
		sub	d0,d1
		move	d1,24(a0)	
		mulu 	6(a0),d0
		move.l	d0,36(a0)	
		moveq	#0,d1
		move.b	5(A1),d1
		mulu	d1,d0
		move.l	d0,40(a0)

		tst.l	(a0)
		beq.s	EndInitBobs
		move.l	(A0),a0
		bra.s	BobInitLoop

EndInitBobs:	movem.l	(a7)+,d0-d3/a0-a1
		rts






Decru:		move.l	ReadC,a0
		move.l	LowWr,a1		
		move.l	-(a0),a2		
		add.l	a1,a2		
		move.l	-(a0),d5		
		move.l	-(a0),d0		
		eor.l	d0,d5		
notfinished:
		lsr.l	#1,d0
		bne.S	notempty1
		bsr	getnextlwd
notempty1:
		bcs.S	bigone		

		moveq	#8,d1	
		moveq	#1,d3	
		lsr.l	#1,d0
		bne.S	notempty2
		bsr	getnextlwd
notempty2:
		bcs.S	dodupl	

		moveq	#3,d1	
		clr	d4	
dojmp:		
		bsr	rdd1bits	
		move	d2,d3	
		add	d4,d3	
getd3chr:
		moveq	#7,d1	
get8bits:
		lsr.l	#1,d0
		bne.S	notempty3
		bsr	getnextlwd
notempty3:
		roxl.l	#1,d2
		dbf	d1,get8bits	
		move.b	d2,-(a2)
		dbf	d3,getd3chr	
		bra	nextcmd
bigjmp:
		moveq	#8,d1	
		moveq	#8,d4	
		bra	dojmp
bigone:
		moveq	#2,d1	
		bsr	rdd1bits
		cmp.b	#2,d2	
		blt.S	midjumps	
		cmp.b	#3,d2	
		beq.S	bigjmp	
		moveq	#8,d1	
		bsr	rdd1bits	
		move	d2,d3	
		moveq	#12,d1	
		bra	dodupl	
midjumps:
		moveq	#9,d1	
		add	d2,d1
		addq	#2,d2
		move	d2,d3	
dodupl:
		bsr	rdd1bits	
copyd3bytes:
		subq	#1,a2
		move.b	(a2,d2.w),(a2)
		dbf	d3,copyd3bytes
nextcmd:
		cmp.l	a2,a1
		blt	notfinished
		tst.l	d5
		bne.S	damage
		rts

damage:
		move.w	#$ffff,d0
damloop:
		move.w	d0,$dff180
		sub	#1,d0
		bne.S	damloop
		rts
	
getnextlwd:
		move.l	-(a0),d0
		eor.l	d0,d5
		move	#$10,ccr
		roxr.l	#1,d0
		rts

rdd1bits:	
		subq	#1,d1
		clr	d2

getbits:
		lsr.l	#1,d0
		bne.S	notempty
		move.l	-(a0),d0
		eor.l	d0,d5
		move	#$10,ccr
		roxr.l	#1,d0

notempty:
		roxl.l	#1,d2
		dbf	d1,getbits
		rts





BobImageList:
		dc.l	Bobs		
		dc.l	Bobs+(1*3456)
		dc.l	Bobs+(2*3456)
		dc.l	Bobs+(3*3456)
		dc.l	Bobs+(4*3456)
		dc.l	Bobs+(5*3456)
		dc.l	Bobs+(6*3456)
		dc.l	Bobs+(7*3456)
		dc.l	Bobs+(8*3456)
		dc.l	Bobs+(9*3456)
		dc.l	Bobs+(10*3456)
		dc.l	Bobs+(11*3456)
		dc.l	Bobs+(12*3456)
		dc.l	Bobs+(13*3456)
		dc.l	Bobs+(14*3456)
		dc.l	Bobs+(15*3456)
		dc.l	Bobs+(16*3456)
		dc.l	Bobs+(17*3456)
		dc.l	Bobs+(18*3456)
		dc.l	Bobs+(19*3456)
		dc.l	Bobs+(20*3456)
		dc.l	Bobs+(21*3456)
		dc.l	Bobs+(22*3456)
		dc.l	Bobs+(23*3456)
		dc.l	Bobs+(24*3456)
		dc.l	Bobs+(25*3456)
BobList:	dc.l	Bob1

Bob1:		dc.l	0		
		dc.w	64,72		
		dc.w	100,0		
		dc.w	-1,-1		
		dc.w	-1,-1		
		dc.w	0		
		dc.w	0		
		dc.w	0		
		dc.l	buffer	;Save1		
		dc.l	buffer	;Save1		
		dc.w	0		
		dc.l	0		
		dc.l	0		
		dc.l	0		
		dc.w	4		
		dc.w	0		
		dc.w	0		
		dc.l	AnimSeq1	
		dc.l	AnimCoord1	
		dc.w	0		
		dc.w	1		
		dc.w	0		
		dc.w	1		
		dc.w	1		

AnimSeq1:	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,13,14
		dc.w	-3

AnimSeq2:	dc.w	14,15,16,17,18,16
		dc.w	14,14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	14,14,14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	14,14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	14,14,14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	14,14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	-1

AnimSeq3:	dc.w	19,20,21,21,22,22,22,22,22,22,22,22,22
		dc.w	-2,-3

AnimCoord3:
		dc.w	-2,180+64,64
		dc.w	-2,182+64,62
		dc.w	-2,183+64,60
		dc.w	-2,185+64,57
		dc.w	-2,186+64,55
		dc.w	-2,188+64,53
		dc.w	-2,189+64,51
		dc.w	-2,192+64,49
		dc.w	-2,194+64,47
		dc.w	-2,196+64,45
		dc.w	-2,198+64,44
		dc.w	-2,201+64,42
		dc.w	-2,204+64,41
		dc.w	-2,208+64,40
		dc.w	-2,210+64,39
		dc.w	-2,215+64,38
		dc.w	-2,219+64,37
		dc.w	-2,223+64,37
		dc.w	-2,226+64,36
		dc.w	-2,230+64,36
		dc.w	-2,234+64,36
		dc.w	-2,238+64,37
		dc.w	-2,241+64,37
		dc.w	-2,243+64,38
		dc.w	-2,246+64,38
		dc.w	-2,249+64,39
		dc.w	-2,251+64,40
		dc.w	-2,254+64,40
		dc.w	-2,256+64,41
		dc.w	-2,258+64,42
		dc.w	-2,261+64,43
		dc.w	-2,264+64,44
		dc.w	-2,266+64,45
		dc.w	-2,269+64,47
		dc.w	-2,271+64,48
		dc.w	-2,274+64,50
		dc.w	-2,277+64,51
		dc.w	-2,280+64,53
		dc.w	-2,282+64,54
		dc.w	-2,284+64,56
		dc.w	-2,286+64,57
		dc.w	-2,288+64,59
		dc.w	-2,290+64,60
		dc.w	-2,293+64,63
		dc.w	-2,296+64,65
		dc.w	-2,299+64,68
		dc.w	-2,302+64,71
		dc.w	-2,306+64,75
		dc.w	-2,309+64,78
		dc.w	-2,312+64,82
		dc.w	-2,315+64,86
		dc.w	-2,318+64,90
		dc.w	-2,320+64,93
		dc.w	-2,324+64,97
		dc.w	0,0

AnimCoord1:	dc.w	244,64
		dc.w	0,0


	



moveschlleft:	bsr	GetBlitter

		clr	Timer
		clr.b	leftout
		move.b	#4,Paused

		lea	$dff000,a5
		moveq	#31,d5
moveleft2:	Gfx	WaitTOF

		tst	Timer
		bne.s	w6
		move.l	Screen1,a2
		add.l	#7162,a2
		move.l	Screen3,a3
		add.l	#$1192,a3	

		move	#14,$66(a5)		
		clr	$64(a5)			
		clr	$42(a5)			
		move	#$9f0,$dff040		
		move.l	#-1,$44(a5)	

		moveq	#5,d7

Clear_explo2:	btst	#14,$2(a5)
		bne.s	Clear_explo2

		move.l	a2,$54(a5)		
		move.l	a3,$50(a5)		
		move	#%0000001010001101,$58(a5)	
	
		add.l	#8000,a2
		add.l	#5044,a3
		dbf	d7,Clear_explo2

		move	#1,Timer
w6:		move.l	Screen1,a2
		add.l	#7162,a2
		move.l	Screen3,a3
		add.l	#$1192,a3	

		move	#16,$66(A5)		
		move	#2,$64(a5)		
		clr	$42(A5)			
		move	#$9f0,$40(a5)		
		move.l	#$ffffffff,$44(A5)	
	
		moveq	#5,d7
Clear_left:
		btst	#14,$2(A5)
		bne.s	Clear_left

		move.l	a2,$54(a5)	
		move.l	a3,$50(a5)	
		move	#%0000001110001100,$58(a5)		
	
		add.l	#8000,a2
		add.l	#5044,a3
		dbf	d7,Clear_left		

		move	d5,d3			
		move	d5,d0
		and	#$000F,d3		
		lsr	#3,d0			
		bclr	#0,d0
		lsl	#8,d3
		lsl	#4,d3
		move	d3,d2			
		add	#$fca,d2		

		move.l	Screen2,a0	 
		add.l	#1064,a0		
		move.l	Screen1,a2		
		add.l	#7160,a2		
		add.l	d0,a2
	
		move.l	a0,a1			
		move.l	a0,a4
		add.l	#320,a1

		moveq	#4,d7
draw_left2:
		btst	#14,$2(a5)
		bne.s	draw_left2

		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#32,$60(a5)		
		move	#32,$62(a5)		
		move	#32,$64(a5)		
		move	#32,$66(a5)		
		move	d3,$42(a5)
		move	d2,$40(a5)
		move.l	#$ffff0000,$44(a5)	
		move	#%0000001000000100,$58(a5)
	
		add.l	#8000,a0
		add.l	#8000,a2
		dbf	d7,draw_left2

		move	d3,d2
		add	#$fca,d2
		add.l	#120,a2

		move.l	a4,a0
		sub.l	#400,a0	
		move.l	a0,a1

DrawSchlaeger332:
		btst	#14,$2(a5)
		bne.s	DrawSchlaeger332
	
		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a1,$4c(a5)		
		move.l	a0,$50(a5)		
		move	#32,$60(a5)		
		move	#32,$62(a5)		
		move	#32,$64(a5)		
		move	#32,$66(a5)		
		move	d3,$42(a5)		
		move	d2,$40(a5)		
		move.l	#$ffff0000,$44(a5) 	
		move	#%0000001000000100,$58(a5)
		
		move.l	Screen2,a0
		add.l	#1692,a0		
		move.l	a0,a1
		addq.l	#4,a1
		move.l	Screen1,a2
		add.l	#7000,a2		
		moveq	#4,d7
clr_left4:
		btst	#14,$dff002
		bne.s	clr_left4
		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#36,$60(a5)		
		move	#36,$62(a5)		
		move	#36,$64(a5)		
		move	#36,$66(a5)		
		clr	$42(a5)			
		move	#$fca,$40(a5)		
		move.l	#$ffffffff,$44(a5)	 
		move	#%10000000010,$58(a5)
		add.l	#8000,a2
		add.l	#8000,a0
		dbf	d7,clr_left4		
		moveq	#15,d6
corrd:
		clr.l	(A2)	
		add.l	#40,a2
		dbf	d6,corrd

		dbf	d5,moveleft2

		bsr	GiveBlitter

		bra	PreLevel




moveschlright:	bsr	GetBlitter

		move.b	#4,Paused
		lea	$dff000,a5
		clr.b	rightout
		clr	Timer
		move	#148,d5

moveright2:	Gfx	WaitTOF

		tst	Timer
		bne.s	w7
	
		move.l	Screen1,a2
		add.l	#7162,a2
		move.l	Screen3,a3
		add.l	#$1192,a3	
	
		move	#14,$66(a5)		
		clr	$64(a5)			
		clr	$42(a5)			
		move	#$9f0,$dff040		
		move.l	#-1,$44(a5)	
	
		moveq	#5,d7
Clear_explo3:
		btst	#14,$2(a5)
		bne.s	Clear_explo3
	
		move.l	a2,$54(a5)		
		move.l	a3,$50(a5)		
		move	#%0000001010001101,$58(a5)	
		
		add.l	#8000,a2
		add.l	#5044,a3
		dbf	d7,Clear_explo3
		move	#1,Timer
w7:
		move.l	Screen1,a2
		add.l	#7180,a2
	
		move.l	Screen3,a3
		add.l	#$11a4,a3	
	
		move	#32,$66(a5)		
		move	#18,$64(a5)		
		clr	$42(a5)			
		move	#$9f0,$40(a5)		
		move.l	#$ffffffff,$44(a5) 
	
		moveq	#5,d7
Clear_right:	bsr	WaitBlitter
	
		move.l	a2,$54(a5)		
		move.l	a3,$50(a5)		
		move	#%0000001110000100,$58(a5)	
		
		add.l	#8000,a2
		add.l	#5044,a3
		dbf	d7,Clear_right		
	
		move	d5,d3			
		move	d5,d0
		and	#$000F,d3		
		lsr	#3,d0			
		bclr	#0,d0
		lsl	#8,d3
		lsl	#4,d3
		move	d3,d2			
		add	#$fca,d2		
	
		move.l	Screen2,a0	 
		add.l	#1064,a0		
		move.l	a0,a4
	
		move.l	Screen1,a2		
		add.l	#7164,a2		
		add.l	d0,a2
		move.l	a0,a1			
		add.l	#320,a1	
	
		moveq	#4,d7
draw_right2:
		btst	#14,$2(a5)
		bne.s	draw_right2
	
		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(A5)		
		move	#32,$60(A5)		
		move	#32,$62(A5)		
		move	#32,$64(a5)		
		move	#32,$66(a5)		
		move	d3,$42(a5)		
		move	d2,$40(a5)		
		move.l	#$ffff0000,$44(a5) 	
		move	#%0000001000000100,$58(a5)
		
		add.l	#8000,a0
		add.l	#8000,a2
		dbf	d7,draw_right2
	
		move	d3,d2
		add	#$fca,d2
		add.l	#120,a2
	
		move.l	a4,a0
		sub.l	#400,a0	
		move.l	a0,a1
DrawSchlaeger333:
		btst	#14,$2(a5)
		bne.s	DrawSchlaeger333
	
		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#32,$60(a5)		
		move	#32,$62(a5)		
		move	#32,$64(a5)		
		move	#32,$66(a5)		
		move	d3,$42(a5)		
		move	d2,$40(a5)		
		move.l	#$ffff0000,$44(a5)	
		move	#%0000001000000100,$58(a5)
		move.l	Screen2,a0
		add.l	#1700,a0		
		move.l	a0,a1
		addq.l	#4,a1			
		move.l	Screen1,a2
		add.l	#7026,a2		
		moveq	#4,d7

clr_right4:	btst	#14,$dff002
		bne.s	clr_right4
		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#36,$60(a5)		
		move	#36,$62(a5)		
		move	#36,$64(a5)		
		move	#36,$66(a5)		
		clr	$42(a5)			
		move	#$fca,$40(a5)		
		move.l	#$ffffffff,$44(a5)	 
		move	#%10000000010,$58(a5)
		add.l	#8000,a2
		add.l	#8000,a0
		dbf	d7,clr_right4		
		moveq	#15,d0

clrl:		clr.l	(A2)
		clr	4(A2)
		add.l	#40,a2
		dbf	d0,clrl
		addq	#1,d5
		cmp	#181,d5
		bne	moveright2


		bsr	GiveBlitter

		bra	NextLevel





DrawSchlaeger:	movem.l d0-d7/a0-a5,-(sp)	

		bsr	GetBlitter

		tst.b	TwoPlayer
		bne.s	nt2
		move.l	schl,schl2
		move.l	extend,extend2
nt2:
		move.l	schl,d1
		move	MousX,d0

		clr.l	d5
		move	d0,d5
		move.l	d5,d0

		btst	#6,$bfe001
		bne.s	NotAuto
		tst.b	Demo
		bne.s	NotAuto
		clr.b	Auto

NotAuto:	btst	#7,$bfe001
		bne.s	NotAuto2
		tst.b	Demo
		bne.s	NotAuto2
		clr.b	Auto

NotAuto2:	tst.b	d0
		bhi.s	notcorrect

		tst.b	level
		beq.s	notlevel1

		move.b	#1,leftout
notlevel1:
		moveq	#1,d0
		move	#1,MousX
		move	#2,imgX
		bra.s	lo2
notcorrect:
		move	d1,d3
		lea	tabelle,a5
		lsl	#1,d3
		add.l	d3,a5

		cmp	(a5),d0
		blt.s	lo2

		tst.b	level
		beq.s	notlevel2

		move.b	#1,rightout
notlevel2:				
		move	(a5),d0
		move	(a5),MousX
lo2:
		move.l	Screen1,a2		
		add.l	#7084,a2

		move.l	Screen3,a3
		add.l	#4448,a3	

		lea	$dff000,a5
		moveq	#5,d7

DrawSchlaeger1:	bsr	WaitBlitter

		move	#18,$66(a5)		
		move	#4,$64(a5)		
		clr	$42(a5)		
		move	#$9f0,$40(a5)
		move.l	#$ffffffff,$44(a5)	

		move.l	a2,$54(a5)		
		move.l	a3,$50(a5)		
		move	#%0000001110001011,$58(a5)
	
		add.l	#8000,a2
		add.l	#5044,a3
		dbf	d7,DrawSchlaeger1

		move	d0,d3			
		and	#$000F,d3		
		lsr	#3,d0			
		bclr	#0,d0
		lsl	#8,d3
		lsl	#4,d3
		move	d3,d2			
		add	#$fca,d2		

		move.l	Screen2,a0	 
		add.l	#1040,a0		
		mulu	#6,d1
		add.l	d1,a0	
		move.l	a0,a4

		move.l	Screen1,a2		
		add.l	#7164,a2		
		add.l	d0,a2
	
		move.l	a0,a1			
		add.l	#320,a1	
	
		moveq	#4,d7
DrawSchlaeger2:	bsr	WaitBlitter

		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#32,$60(a5)		
		move	#32,$62(a5)		
		move	#32,$64(a5)		
		move	#32,$66(a5)		
		move	d3,$42(a5)		
		move	d2,$40(a5)		
		move.l	#$ffff0000,$44(a5) 
		move	#%0000001000000100,$58(a5)
	
		add.l	#8000,a0
		add.l	#8000,a2
		dbf	d7,DrawSchlaeger2

		move	d3,d2
		add	#$fca,d2
		add.l	#120,a2

		move.l	a4,a0
		sub.l	#400,a0	
		move.l	a0,a1
DrawSchlaeger3:
		btst	#14,$2(a5)
		bne.s	DrawSchlaeger3

		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#32,$60(a5)		
		move	#32,$62(a5)		
		move	#32,$64(a5)		
		move	#32,$66(a5)		
		move	d3,$42(a5)		
		move	d2,$40(a5)
		move.l	#$ffff0000,$44(a5) 	
		move	#%1000000100,$58(a5)
	
		move	MousX2,d0
		move.l	schl,d1
		tst.b	d0
		bhi.s	notcorrect234

		tst.b	level
		beq.s	notlevel234

		move.b	#1,leftout
notlevel234:
		move	#1,d0
		move	#1,MousX2
		move	#2,imgX2
		bra.s	lo234
notcorrect234:
		move	d1,d3
		lea	tabelle,a3
		lsl	#1,d3
		add.l	d3,a3

		cmp	(a3),d0
		blt.s	lo234

		tst.b	level
		beq.s	notlevel235

		move.b	#1,rightout
notlevel235:				
		move	(a3),d0
		move	(a3),MousX2
lo234:
		move	d0,d3			
		and	#$F,d3		
		lsr	#3,d0			
		bclr	#0,d0
		lsl	#8,d3
		lsl	#4,d3
		move	d3,d2			
		add	#$fca,d2		

		move.l	schl2,d1
		move.l	Screen2,a0	 
		add.l	#1040,a0		
		mulu	#6,d1
		add.l	d1,a0	
		move.l	a0,a4

		move.l	Screen1,a2		
		add.l	#7164,a2		
		add.l	d0,a2
	
		move.l	a0,a1			
		add.l	#320,a1	
	
		moveq	#4,d7
DrawSchlaeger5:
		btst	#14,$2(a5)
		bne.s	DrawSchlaeger5

		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#32,$60(a5)		
		move	#32,$62(a5)		
		move	#32,$64(a5)		
		move	#32,$66(a5)		
		move	d3,$42(a5)		
		move	d2,$40(a5)		
		move.l	#$ffff0000,$44(a5)	 
		move	#%1000000100,$58(a5)
	
		add.l	#8000,a0
		add.l	#8000,a2
		dbf	d7,DrawSchlaeger5

		move	d3,d2
		add	#$fca,d2
		add.l	#120,a2

		move.l	a4,a0
		sub.l	#400,a0	
		move.l 	a0,a1

DrawSchlaeger6:	bsr	WaitBlitter

		move.l	a2,$48(a5)		
		move.l	a2,$54(a5)		
		move.l	a0,$4c(a5)		
		move.l	a1,$50(a5)		
		move	#32,$60(a5)		
		move	#32,$62(a5)		
		move	#32,$64(a5)		
		move	#32,$66(a5)		
		move	d3,$42(a5)		
		move	d2,$40(a5)		
		move.l	#$ffff0000,$44(a5) 	
		move	#%1000000100,$58(a5)		

		bsr	GiveBlitter

		movem.l (sp)+,d0-d7/a0-a5
		rts




Decruncher:	clr.l d0
eloop1:		move.b (a0),d1
		and.b #$80,d1
		cmp.b #$80,d1            
		beq.s crunch
	
		clr.l d1
		move.b (a0),d1
		subq.l #1,d1
		addq.l #1,a0

normloop:	move.b (a0)+,(a1)+
		addq.l #1,d0
		cmp.l d4,d0
		beq.s eende
		dbf d1,normloop
		bra.s eloop1

crunch:		clr.l d1
		move.b (a0),d1
		and.b #$7f,d1	
		move.b 1(a0),d2
		subq #1,d1

eloop2:		move.b d2,(a1)+
		addq.l #1,d0
		cmp.l d4,d0
		beq.s eende
		dbf d1,eloop2
		addq.l #2,a0	
		bra.s eloop1
eende:		rts





InitMouse:	move 	$dff00a,d0
		move	d0,d1
		lsr	#8,d1
		and	#$ff,d0
		move	d0,oldx
		rts
	


MouseHandler:	movem.l	d0-d7/a0-a6,-(sp)

		tst.b	Auto
		beq.s	handler2

		clr.l	d5
		lea	sprite1,a3
		move.b	1(a3),d5
		lsl	#1,d5
		sub	#162,d5

		move	d5,MousX
		lsl	#1,d5
		move	d5,imgX
		bra	endhandler

handler2:	tst.b	Joy1
		beq	m24
		move	$dff00a,d0
		btst	#9,d0
		beq.s	nli1
		sub	#4,MousX
		sub	#8,imgX
		bra.s	endhandler
nli1:
		btst	#1,d0
		beq.s	nre1
		addq	#4,MousX
		add	#8,imgX
		bra.s	endhandler
nre1:
		clr	d0
		bra.s	endhandler
m24:
		move 	$dff00a,d0
		tst	FromList
		beq.s	NoFrom
		lsr	#8,d0
NoFrom:
		move	d0,d1
		lsr	#8,d1			
		and	#$ff,d0
m23:
		tst.b	revers
		beq.s	notrev
		neg.b	d0

notrev:		clr.w	d2

		move.b	oldx,d2
		move.b	d0,oldx

		sub.b	d0,d2			
		tst.b	d2
		beq.s	endhandler
		move.b	d2,d4
		tst.b	d2
		bpl.s	mous1
		neg.b	d2

mous1:		cmp.b	#127,d2
		bgt.s	mous2
		ext	d4
		sub	d4,imgX
		bra.s	endhandler

mous2:		sub.b	#255,d4
		ext	d4
		sub	d4,imgX


endhandler:	move	imgX,d0			
		asr	#1,d0			

		tst	d0
		bgt.s	mous7
		clr	d0
		clr	imgX

mous7:		tst.b	Battle
		bne.s	mous86
		tst.b	TwoPlayer
		bne.s	TwoCheck	

mous86:		tst	FromList
		beq.s	NoList2

		cmp	#254,d0
		blt.s	mous8
		move	#255,d0
		move	#510,imgX
		bra.s	mous8

NoList2:	cmp	#149,d0
		blt.s	mous8
		move	#150,d0
		move	#300,imgX
		bra.s	mous8

TwoCheck:	cmp	#61,d0
		bls.s	mous8
		move	#61,d0
		move	#122,imgX

mous8:		move	d0,d5
		sub	d5,MousX
		move	MousX,dist
		move	d0,MousX

		tst.b	Battle
		bne.s	tpl
		tst.b	TwoPlayer 
		bne.s	tpl
		tst.b	twoschl
		bne.s	tschl
	
		move	d0,MousX2
		lsl	#1,d0
		move	d0,imgX2
		bra	endhand		

tschl:		move.l	schl,d1
		lea	tabelle3,a1
		lsr	#1,d1
		add.l	d1,a1
		move	(a1),d1
		sub	d0,d1
		move	d1,MousX2
		lsl	#1,d1
		move	d1,imgX2
		bra	endhand

tpl:		tst.b	Auto
		beq.s	handler22
	
		clr.l	d5
		lea	sprite1,a3
		move.b	1(a3),d5
		lsl	#1,d5
		sub	#162,d5
	
		move	d5,MousX2
		lsl	#1,d5
		move	d5,imgX2
		bra	endhandler2

handler22:	tst.b	Joy2
		beq.s	m25
		move	#4,d5
		move	#8,d6
		tst.b	revers
		beq.s	nrc

		nop

nrc:		neg.b	d5
		neg.b	d6

		move	$dff00c,d0
		btst	#9,d0
		beq.s	nli2
		sub	#4,MousX2
		sub	#8,imgX2
		bra.s	endhandler2
nli2:
		btst	#1,d0
		beq.s	nre2
		add	#4,MousX2
		add	#8,imgX2
		bra.s	endhandler2
nre2:
		bra.s	endhandler2
m25:
		move.w 	$dff00c,d0
		move.w	d0,d1
		lsr.w	#8,d1			
		and.w	#$ff,d0

		tst.b	revers
		beq.s	notrev2
		neg.b	d0
notrev2:
		clr	d2
		move.b	oldx2,d2
		move.b	d0,oldx2

		sub.b	d0,d2			
		tst.b	d2
		beq.s	endhandler2
		move.b	d2,d4
		tst.b	d2
		bpl.s	mous12
		neg.b	d2
mous12:	
		cmp.b	#127,d2
		bgt.s	mous22
		ext.w	d4
		sub.w	d4,imgX2
		bra.s	endhandler2
mous22:
		sub.b	#255,d4
		ext.w	d4
		sub.w	d4,imgX2

endhandler2:	move.w	imgX2,d0		
		asr.w	#1,d0			

		tst.b	Battle
		beq.s	mous453

		cmp	#0,d0
		bgt.s	mous72
		move.w	#0,d0
		move.w	#0,imgX2
		bra.s	mous72

mous453:	cmp	#90,d0
		bgt.s	mous72
		move.w	#91,d0
		move.w	#182,imgX2

mous72:		cmp.w	#149,d0
		blt.s	mous82
		move.w	#150,d0
		move.w	#300,imgX2

mous82:		move d0,d5
		sub d5,MousX2
		move MousX2,dist2
		move d0,MousX2

endhand:	movem.l	(sp)+,d0-d7/a0-a6
		rts





checkball:	move.l	(A1),a0
		move.b	4(A1),d1
		move.b	5(A1),d2
		move.b	6(A1),d3
		move.b	7(A1),d4

		tst.b	d4
		bmi	ENDCheck

		cmp.b	#218,d2
		bls	ENDCheck
		cmp.b	#222,d2
		bhi	ENDCheck
	
		move	MousX,d5
		lsr.b	#1,d5
		add.b	#74,d5

		tst.b	Battle
		beq.s	Daneben236
		cmp.l	#5,schl
		beq.s	Daneben2
Daneben236:
		cmp.b	d5,d1
		blo.s	Daneben2
		bne.s	nr1
		move.b	#-1,d3
nr1:
		move.l	schl,d6
		lsl.l	#1,d6
		lea	tabelle2,a2
		add.l	d6,a2
		add	(a2),d5			

		cmp.b	d5,d1
		bhi.s	Daneben2
		bne.s	nr2
		move.b	#1,d3
nr2:
		move	dist,d6
		move.b	#-1,Kept
		bra.s	treffer
Daneben2:
		tst.b	Battle
		beq.s	Daneben237
		cmp.l	#5,schl2
		beq	Daneben
Daneben237:
		move	MousX2,d5
		lsr.b	#1,d5
		add.b	#74,d5

		cmp.b	d5,d1
		blo	Daneben
		bne.s	nr3
		move.b	#-1,d3
nr3:
		move.l	schl,d6
		lsl.l	#1,d6
		lea	tabelle2,a2
		add.l	d6,a2
		add	(a2),d5			

		cmp.b	d5,d1
		bhi	Daneben
		bne.s	nr4
		move.b	#1,d3
nr4:
		move	dist2,d6
		move.b	#1,Kept
treffer:
		bsr	SoundOn3
		move.b	#217,d2
		move.b	d2,(a0)
		addq.b	#7,d2
		move.b	d2,2(a0)
		subq.b	#7,d2

		tst.b	hold
		beq.s	donthold
		move	#1,Kept2
		move	#1,waitb
		bra.s	loop2
donthold:
		tst	d6
		beq	loop2
		bpl	schllinks		

		tst.b	d3		
		beq	loop2
		bpl	ballrechts1		
balllinks1:
 		addq.b	#1,d4
		cmp.b	#4,d4
		bhi.s	loop2
		moveq	#3,d4			

		bra.s	loop2
ballrechts1:				
		subq.b	#1,d4
		tst.b	d4
		bne.s	loop2
		moveq	#1,d4			
		bra.s	loop2
schllinks:
		tst.b d4			
		beq.s loop2
		bpl.s ballrechts2
balllinks2:
		subq.b	#1,d4			
		tst.b	d3
		bne.s	loop2
		moveq	#1,d4			
		bra.s	loop2
ballrechts2:				
		addq.b	#1,d4
		cmp.b	#4,d4
		bhi.s	loop2
		moveq	#3,d4		

loop2:				
		neg.b	d4

Daneben:
ENDCheck:
		move.b d4,7(a1)		
		move.b d3,6(a1)		
		move.b d2,5(a1)		
		move.b d1,4(a1)		
		rts


Lc:		dc.w	0




checkspry:	cmp.b	#250,d2
		bhi.s	weiterc5
		rts

weiterc5:	tst.b	twoball
		bne.s	extwo
		move.b	#1,exploding
		rts

extwo:		clr.b	twoball
		cmp.l	#sprite1,a0
		bne.s	notthe2

		lea	sprite1,a4
		lea	sprite2,a5
		move.l	(a5),(a4)
		lea	spr1+4,a4
		lea	spr2+4,a5
		move.l	(a5),(a4)
		move.b	(a5),d1
		move.b	1(a5),d2
		move.b	2(a5),d3
		move.b	3(a5),d4

notthe2:	lea	sprite2,a5
		clr.b	1(a5)
		rts




CheckBlock:	move.b	d5,d1
		move.b	d6,d2
	
		cmp.b	#78,d1
		bhi.s	ok78
		rts


ok78:		sub.b	#78,d1
		sub.b	#50,d2
		lsr	#3,d1
		lsr	#3,d2
		cmp	#13,d1
		bne.s	CheckBlock2
		move	#11,d1
CheckBlock2:
		clr.b	changed
		move	d1,x4
		lea	ZSpeicher+14,a4
		add	d1,a4
		move	d2,d5
		mulu	#11,d5
		move	d5,y4
		add	d5,a4
		move.b	(A4),d7
		move.b	d7,sicher
		and.b	#31,d7
		tst.b	d7
		beq	notcol		
		cmp.b	#8,d7
		beq	notdel		
		cmp.b	#6,d7
		bls.s	notmehr		
		cmp.b	#14,d7
		bne.s	not2		
		movem.l	d0-d7/a0-a3,-(sp)
		add.l	#10,Score
		clr.l	d0		
		clr.l	d1		
		lea	ZSpeicher+14,a5
		mulu	#11,d2
		add	d2,a5
		divu	#11,d2
		moveq	#10,d6
testloop1:
		cmp.b	#8,(a5)
		beq.s	delnot1
		clr.b	(a5)
		bsr	DrawBlock
delnot1:
		addq	#1,d1
		addq	#1,a5
		dbf	d6,testloop1
		movem.l	(sp)+,d0-d7/a0-a3
		bra.s	notmehr
not2:
		cmp.b	#8,d7
		bls.s	not1
		cmp.b	#17,d7
		bhi.s	not1
		bsr	begin
		bra.s	notmehr
not1:
		cmp.b	#7,d7
		bne.s	notmehr	
		move.b	sicher,d7
		sub.b	#32,d7
		move.b	d7,(a4)
		cmp.b	#7,d7
		bne.s	notdel
notmehr:
		clr.b	(a4)
del:
		addq.l	#5,Score
		clr.l	d0
		bsr	DrawBlock
		tst.b	smash
		bne.s	noinv
		neg.b	d4
		move.b	#1,changed
		bsr	SoundOn
		addq	#1,y
noinv:
		bra.s	notcol
notdel:
		and.b	#$f,d7

		cmp.b	#8,d7
		beq.s	c68		

		moveq	#1,d5		
		bra.s	c69
c68:
		move.b	#149,d5		
c69:
		lea	Flashlist,a3
		add	x4,a3
		add	y4,a3
		move.b	d5,(A3)	

		neg.b	d4
		move.b	#1,changed
		bsr	SoundOn2
notcol:
		move.b	sicher,d0
		rts




SoundOn3:	lea	$dff000,a5
		move	#1,$96(A5)
		move.l	#BallStock,$a0(A5)
		move	#2512,$a4(A5)
		move	#180,$a6(A5)
		move	#4,SoundcNT1
		move	#$8001,$96(A5)
		rts

SoundOn5:	lea	$dff000,a5
		move	#4,$96(A5)
		move.l	#SpritePlopp,$c0(A5)
		move	#4217,$c4(A5)
		move	#250,$c6(A5)
		move	#20,SoundcNT3
		move	#$8004,$96(A5)
		rts


SoundOn6:	lea	$dff000,a5
		move	#4,$96(A5)
		move.l	#SpritePlopp,$c0(A5)
		move	#4217,$c4(A5)
		move	#120,$c6(A5)
		move	#8,SoundcNT3
		move	#$8004,$96(A5)
		rts


SoundOn4:	lea	$dff000,a5
		move	#4,$96(A5)
		move.l	#SpritePlopp,$c0(A5)
		move	#4217,$c4(A5)
		move	#180,$c6(A5)
		move	#15,SoundcNT3
		move	#$8004,$96(A5)
		rts


SoundOn7:	lea	$dff000,a5
		move	#4,$96(A5)
		move.l	#Harve,$c0(A5)
		move	#13000,$c4(A5)
		move	#170,$c6(A5)
		move	#35,SoundcNT3
		move	#$8004,$96(A5)
		rts


SoundOn2:	lea	$dff000,a5
		move	#2,$96(A5)
		move.l	#BallHolz,$b0(A5)
		move	#1166,$b4(a5)
		move	#180,$b6(A5)
		move	#2,SoundcNT2
		move	#$8002,$96(A5)
		rts


SoundOn:	lea	$dff000,a5
		move	#1,$96(A5)
		move.l	#BallStein,$a0(a5)
		move	#2382,$a4(A5)
		move	#180,$a6(A5)
		move	#4,SoundcNT1
		move	#$8001,$96(A5)
		rts


LoadSound:	cmp.l	#$600002d6,BallStein
		beq.s	NoLoadSound

;1$:		move	#2,Command
;		move.l	#BallStein,Ziel
;		move.l	#188*512,Offset
;		move.l	#220*512,Laenge
;		bsr	StartTask
;		bsr	WaitLoad
;		cmp.l	#$c0690204,Summ
;		bne.s	1$


;		move.l	#100,d1
;		DOS	Delay

		lea	Music_File,a0
		lea	BallStein,a1
		move.l	#220*512,d0
	;;;	bsr	LoadFile

NoLoadSound:	rts




**********************************************************************************
* File abspeichern
* A0 = Name
* A1 = Buffer
* D0 = Grösse
**********************************************************************************

SaveFile:	movem.l	d0-d7/a0-a6,-(sp)

		move.l	d0,d6			* Size
		move.l	a1,a4

		move.l	a0,d1
		move.l	#1006,d2
		DOS	Open
		move.l	d0,d7

		bne	1$

		move.w	#$f00,$dff180


1$:		move.l	d7,d1
		move.l	a4,d2
		move.l	d6,d3
		Last	Write

		move.l	d7,d1
		Last	Close
	
		movem.l	(sp)+,d0-d7/a0-a6
		rts

**********************************************************************************
* File laden
* A0 = Name
* A1 = Buffer
* D0 = Grösse
* Result : D0  0 = OK, -1 = False
**********************************************************************************

LoadFile:	movem.l	d1-d7/a0-a6,-(sp)

		move.l	d0,d6			* Size
		move.l	a1,a4

		move.l	a0,d1
		move.l	#1005,d2
		DOS	Open
		move.l	d0,d7
		beq.s	.Error


1$:		move.l	d7,d1
		move.l	a4,d2
		move.l	d6,d3
		Last	Read

		cmp.l	#-1,d0
		bne	.Error2

		move.l	d7,d1
		Last	Close

		moveq	#0,d0
	
.End:		movem.l	(sp)+,d1-d7/a0-a6
		rts

.Error:		moveq	#-1,d0
		bra	.End

.Error2:	move.l	d7,d1
		Last	Close
		bra	.Error








InitMenuCopper:	movem.l	d0-d7/a0-a6,-(sp)

		lea	sprites3,a0
		bsr	ClearSprites

		move.l	Screen2,d0
		lea	planes3,a0
		bsr	SetLong

		moveq	#5-1,d7
1$:		bsr	SetLong
		addq.l	#8,a0
		add.l	#40*256,d0
		dbf	d7,1$

		movem.l	(sp)+,d0-d7/a0-a6
		rts



InitCopper2:	movem.l	d0-d7/a0-a6,-(sp)

		lea	sprites2,a0
		bsr	ClearSprites

;		move.l	#Page1,d0
		move.l	Screen1,d0
		lea	planes2,a0
		bsr	SetLong

		moveq	#6-1,d7
1$:		bsr	SetLong
		addq.l	#8,a0
		add.l	#40*200,d0
		dbf	d7,1$

		movem.l	(sp)+,d0-d7/a0-a6
		rts


InitCCNCopper:	movem.l	d0-d7/a0-a6,-(sp)

		lea	ccnsprites,a0
		bsr	ClearSprites

;		move.l	#Page1,d0
;		move.l	Screen1,d0
;		lea	planes2,a0
;		bsr	SetLong

;		moveq	#6-1,d7
;1$:		bsr	SetLong
;		addq.l	#8,a0
;		add.l	#40*200,d0
;		dbf	d7,1$

		movem.l	(sp)+,d0-d7/a0-a6
		rts




*******************************************************************************
* Clear all 8 Sprites in a Copperlist
* a0 = Copperlist Sprites
*******************************************************************************

ClearSprites:	movem.l	d0-d7/a0-a6,-(sp)
		
		moveq	#8-1,d1
		move.l	#DummySprite,d0

1$:		bsr	SetLong
		addq.l	#8,a0
		dbf	d1,1$

		movem.l	(sp)+,d0-d7/a0-a6
		rts



*******************************************************************************
* Set Longword into CopperListe
* d0 = Value, a0 = adr
*******************************************************************************

SetLong:	move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		rts




**********************************************************************************

Menu:		bsr	InitMenuCopper

		lea	$dff000,a5
		move.l	#copperl4,$80(A5)
		clr	$a8(A5)
		clr	$b8(A5)
		clr	$c8(A5)
		clr	$d8(A5)


		bsr	LoadSound
	;;	jsr	$20008			; INIT


	*** Pic laden ***

		lea	MenuGfx_File,a0
		move.l	Screen1,a1
		move.l	#79*512,d0
		bsr	LoadFile

		move.l	#$c840,d4			
		move.l	Screen1,a0			
		move.l	Screen2,a1			
		bsr	Decruncher


	*** Palette setzen ***

		move.l	Screen2,a1
		add.l	#$c800,a1
		lea	colors3+2,a2

		moveq	#32-1,d7
.SetCol:	move.w	(A1)+,(A2)
		addq.l	#4,a2
		dbf	d7,.SetCol

		lea	rightcol2+2,a1
		lea	rightcol+2,a2
		move	(A1),(A2)		


	*** Sprites positionieren ***

		lea	CopMenuSpr+48,a1
		move.l	#MenuSpr,d0
		move	d0,6(A1)
		swap	d0
		move	d0,2(A1)
		lea	MenuSpr,a1
		move.l	#$7bb88900,(A1)


	*** Startwerte ***

		clr	MousePos
		clr	MenuCnt
		move	#10,oldXPos2
		move	$dff00a,suber
		sub	#64,suber

		move.l	#copperl3,$dff080
		move	#$8120,$dff096


		moveq	#5,d0
		lea	MenuIntStruct,a1
		Exec	AddIntServer		* CopperInt anhängen



RepMenu:	Gfx	WaitTOF

		addq.w	#1,MenuCnt
		cmp.w	#4800,MenuCnt
	;	cmp.w	#100,MenuCnt
		bne.s	NotFifteen

		lea	FromMenu+1,a1
		not.b	(A1)
	;;	tst.b	(A1)
		bne.s	GoDemo

GoList:		move.l	hiScore,Score
		move.l	#'HISC',d0
		bra	EndMenu



GoDemo:		move.b	#1,Auto
		move.b	#1,Demo
		clr.b	TwoPlayer
		clr.b	Battle
		clr.l	d0
		bra	EndMenu	



NotFifteen:	clr.l	d0
		move	oldmpos,d1

		move	$dff00a,d0
		sub	suber,d0
		move	d0,oldmpos	

		cmp	d0,d1
		beq	1$
		clr	MenuCnt

1$:		and	#$ff00,d0
		lsr	#8,d0
		lsr	#5,d0
		move	d0,MousePos

		cmp	#7,MousePos
		bne.s	2$
		move	#6,MousePos


2$:		lea	MeNut,a1
3$:		move.l	(A1),a2
		move	#Menucolor,2(A2)
		addq.l	#4,a1
		tst.l	(A1)
		bne.s	3$

		lea	Joystick+2,a1
		lea	mouse+2,a2
		lea	CCNon+2,a3
		lea	CCNoff+2,a4

		tst.b	Joy2
		beq.s	notJoy2

		move	#Menucolor2,(A1)
		move	#Menucolor,(A2)
		bra.s	weiter3

notJoy2:	move	#Menucolor,(A1)
		move	#Menucolor2,(A2)

weiter3:	tst.b	CCN
		beq.s	notCCN2			
		move	#Menucolor2,(A3)
		move	#Menucolor,(A4)
		bra.s	weiter4

notCCN2:	move	#Menucolor,(A3)
		move	#Menucolor2,(A4)

weiter4:	move	MousePos,d0
		lsl	#2,d0
		lea	MeNut,a1
		move.l	(A1,d0.w),a2
		move	#Menucolor2,2(A2)

		bsr	Printl

		clr.b	FastExit

		btst	#10,$dff016
		beq.s	.GoGame

		btst	#6,$bfe001
		beq	.GoGame

		move.b	$bfec01,d7
		tst.b	d7
		beq	RepMenu



	*** Taste gedrückt ***

		cmp.b	#$7f,d7
		beq	GoList			* Show Hiscore (SPACE)

		cmp.b	#$75,d7			* Fast Exit (ESC)
		beq	.Exit
		cmp.b	#$39,d7			* Fast Exit (F10)
		bne	RepMenu


.Exit:		move.b	#-1,FastExit
		bra	.ExitGame



.GoGame:	move	MousePos,d0
		tst	d0
		bne.s	notlb1

.ExitGame:	clr.b	TwoPlayer
		clr.b	Battle
		move.l	#'EDIT',d0
		bra	EndMenu



notlb1:		cmp	#1,d0
		bne.s	notplay1

		clr.b	TwoPlayer
		clr.b	Battle
		clr.l	d0
		bra	EndMenu			

notplay1:	cmp	#2,d0
		bne.s	notplay2

		clr.b	Battle
		move.b	#1,TwoPlayer
		moveq	#0,d0
		bra	EndMenu	


notplay2:	cmp	#3,d0
		bne.s	notplay3
	
		move.b	#1,TwoPlayer
		move.b	#1,Battle

		moveq	#0,d0
		bra	EndMenu			

notplay3:	cmp	#4,d0
		bne.s	notpl2

		bchg	#0,Joy2


waitplease:	btst	#6,$bfe001
		beq.s	waitplease
		btst	#10,$dff016
		beq.s	waitplease
notpl2:
		cmp	#5,d0
		bne.s	notCCNt			
		bchg	#0,CCN


waitplease2:	btst	#6,$bfe001
		beq.s	waitplease2	
		btst	#10,$dff016
		beq.s	waitplease2


notCCNt:	cmp	#6,d0
		bne.s	notst

		move	#5,verz

updown:		move	verz,d7
updown2:	Gfx	WaitTOF

		dbf	d7,updown2

		cmp	#1,verz
		beq.s	nomoresub
		subq	#1,verz


nomoresub:	lea	StageName+5,a1
		btst	#6,$bfe001
		bne.s	NotA

		subq.b	#1,(a1)
		cmp.b	#'A'-1,(A1)
		bne.s	NotA
		move.b	#'A',(A1)
NotA:
		btst	#10,$dff016
		bne.s	notb

		addq.b	#1,(A1)
		cmp.b	#'O'+1,(A1)
		bne.s	notb
		move.b	#'O',(A1)
notb:
		clr	MenuCnt
		bsr	Printl
		btst	#6,$bfe001
		beq.s	updown
		btst	#10,$dff016
		beq.s	updown
notst:
		bra	RepMenu




EndMenu:	lea	MenuSpr,a1
		clr.l	(A1)
		move.l	d0,wert

		tst.b	FastExit
		bne	.Fast

		bsr	DelScrLine

.Fast:		moveq	#5,d0
		lea	MenuIntStruct,a1
		Exec	RemIntServer

	;;	jsr	$20014

		move.l	wert,d0
		rts









MenuInt:	movem.l	d0-d7/a0-a6,-(A7)
	;	jsr	$2000c

	;;	move.w	#$fff,$dff180

		movem.l	(A7)+,d0-d7/a0-a6
		moveq	#0,d0
		rts






DelScrLine2:	move.l	Screen1,scr
		move.l	#8000,plane
		clr.l	d4
		move.l	#199,d5
		move.l	d5,d2
		bra.s	delit23




DelScrLine:	move.l	#$2800,plane
		move.l	Screen2,scr
		moveq	#0,d4
		move.l	#255,d5
		move.l	d5,d2

delit23:	not.b	wert22
		tst.b	wert22
		beq.s	nowait		

		Gfx	WaitTOF
nowait:	
	;	tst	$20000+24
	;	beq.s	SchonNull
	;	subq	#1,$20000+24

SchonNull:	move.l	scr,a1
		move.l	d4,d3
		bsr	delline

		move.l	scr,a1
		move.l	d5,d3
		bsr	delline

		subq.l	#2,d5
		addq.l	#2,d4
		cmp.l	d2,d4
		ble.s	delit23

		move.l	wert,d0
		move.l	#copperl4,$dff080
		rts




delline:	movem.l	d0-d7/a0-a2,-(sp)
		mulu	#40,d3
		add.l	d3,a1

		moveq	#10-1,d7
clline:		move.l	a1,a2
		moveq	#5-1,d6

clbpl:		clr.l	(A2)
		add.l	plane,a2	
		dbf	d6,clbpl	

		addq.l	#4,a1
		dbf	d7,clline	

		movem.l	(sp)+,d0-d7/a0-a2
		rts





EndMenu2:	tst	loading
		bne.s	EndMenu2
		move	#$100,$dff096
		rts




Printl:		lea	StageName+5,a0
		lea	MenuSpr+4,a1
		move.b	(A0),d0
		sub.b	#' ',d0
		mulu	#10,d0
		lea	Font+1,a2
		add	d0,a2

		moveq	#6,d7

prt:		moveq	#0,d0
		move.l	d0,d1
		move.b	(A2)+,d0
		move.b	d0,d1
		moveq	#7,d3

double:		roxr	#1,d0
		roxr	#1,d2
		roxr	#1,d1
		roxr	#1,d2	
		dbf	d3,double

		move	d2,(A1)
		move	d2,2(A1)
		move	d2,4(A1)
		move	d2,6(A1)
		addq.l	#8,a1
		dbf	d7,prt
		rts





OpenTrd:	sub.l	a1,a1
		Exec	FindTask
		move.l	d0,readrep+$10
	
		lea	readrep,a1
		Last	AddPort
	
		lea	diskIO,a1
		moveq	#0,d0
		moveq	#0,d1
		lea	TrdDevice,a0
		Last	OpenDevice
	
		lea	diskIO,a1
		move.l	#readrep,14(A1)
		rts


CloseTrd:	lea	readrep,a1
		Exec	RemPort

		lea	diskIO,a1
		Last	CloseDevice
		rts


motor_off:	lea	diskIO,a1
		move	#9,28(A1)
		clr.l	36(A1)
		Exec	DoIO
		rts


Clearbuff:	lea	diskIO,a1
		move	#5,28(A1)
		Exec	DoIO
		rts





InitTask:	moveq	#0,d1
		move.l	#5000,d0
		Exec	AllocMem
		tst.l	d0
		bne.s	OKmem
		rts


OKmem:		move.l	d0,stackmem
		move.l	d0,stack1
		move.l	d0,stack2
		add.l	#4990,d0
		move.l	d0,stack3

		move.l	#-1,d0
		Last	AllocSignal

		move.l	d0,signalnummer
		moveq	#0,d1
		bset	d0,d1
		move.l	d1,signalmaske	

		lea	Task,a2
		lea	Taskstrc,a1
		sub.l	a3,a3
		Last	AddTask

		rts



RemoveTask:	move	#6,Command
		bsr	StartTask		

		move	#1,Command
		bsr	StartTask		

		move.l	signalnummer,d0
		Exec	FreeSignal
	
		move.l	stackmem,a1
		move.l	#5000,d0
		Exec	FreeMem
		rts



StartTask:	lea	Taskstrc,a1	
		move.l	signalmaske,d0
		Exec	Signal
		rts


Task:		bsr	OpenTrd

Task2:		move.l	signalmaske,d0
		Exec	Wait

		move	Command,d0
		cmp	#1,d0
		beq	EndTask

		cmp	#2,d0
		beq	ReadTrack

		cmp	#3,d0
		beq	WriteTrack

		cmp	#4,d0
		beq	ReadPic

;;;		cmp	#5,d0
;;;		beq	LoadGame

		cmp	#6,d0
		beq	motor0

		cmp	#7,d0
		beq.s	Protect
		bra.s	Task2




Protect:	move	#1,loading

		lea	diskIO,a1
		move	#15,28(A1)
		Exec	DoIO
		move.l	32(A1),Result

		clr	loading
		bra.s	Task2


motor0:		bsr	motor_off
		bra	Task2



	IFD	fdjslk

LoadGame:	move	#1,loading

		lea	diskIO,a1
		move	#2,28(A1)
		move.l	#$5000,36(a1)
		move.l	#buffer,40(A1)
		move.l	#rahmenc,44(A1)
		Exec	DoIO
		tst.l	d0
		beq.s	OkLoadGame
		bsr	Delay2
		bra.s	LoadGame


OkLoadGame:	move.l	Screen1,a1
		lea	buffer,a0
		move.l	#40000,d4
		bsr	Decruncher


	ENDC


ReadPic:	move	#1,loading

		sub.l	d0,d0
		move.b	piccounter,d0
		sub.b	#'1',d0
		mulu	#512*46,d0
		add.l	#picbase,d0

		lea	diskIO,a1
		move	#2,28(A1)
		move.l	#512*46,36(a1)
		move.l	#buffer,40(A1)
		move.l	d0,44(A1)
		Exec	DoIO

		tst.l	d0
		beq.s	OkReadPic
		bsr	Delay2
		bra.s	ReadPic

OkReadPic:	bsr	motor_off
		clr	loading
		move	#1,loaded


		add.b	#1,piccounter
		cmp.b	#'9',piccounter
		bne.s	not65
		move.b	#'1',piccounter

not65:		bra	Task2


Result:		dc.l	0




ReadTrack:	move	#1,loading

		lea	diskIO,a1
		move	#5,28(A1)
		move.l	Offset,44(A1)
		move.l	Laenge,36(A1)
		move.l	Ziel,40(A1)
		Exec	DoIO

		lea	diskIO,a1
		move	#2,28(A1)
		move.l	Offset,44(A1)
		move.l	Laenge,36(A1)
		move.l	Ziel,40(A1)
		Exec	DoIO

		
		tst.l	d0
		beq.s	OkTrack
		bsr	Delay2
		bra.s	ReadTrack

OkTrack:	bsr	Check
		clr	loading
		bra	Task2
	




WriteTrack:	move	#1,loading

		lea	diskIO,a1
		move	#3,28(A1)
		move.l	Offset,44(A1)
		move.l	Laenge,36(A1)
		move.l	Ziel,40(A1)
		Exec	DoIO

		lea	diskIO,a1
		move	#4,28(A1)
		move.l	Offset,44(A1)
		move.l	Laenge,36(A1)
		move.l	Ziel,40(A1)
		Exec	DoIO

		tst.l	d0
		beq.s	OkWrite
		bsr	Delay2
		bra.s	WriteTrack
OkWrite:	clr	loading
		bra	Task2



EndTask:	bsr	CloseTrd
		rts




Check:		move.l	Ziel,a0
		move.l	Laenge,d7
		lsr	#2,d7
		subq	#1,d7
		clr.l	d0


CheckSum:	add.l	(a0)+,d0
		neg.l	d0
		dbf	d7,CheckSum
		move.l	d0,Summ
		rts



Summ:		bra	CheckSum
Delay2:		move.l	_GfxBase,a6
		moveq	#25,d7
Dela:		Last	WaitTOF
		dbf	d7,Dela
		rts


WaitLoad:	tst	loading
		bne.s	WaitLoad
		rts


GetPosition:	movem.l	a0/d1/d2,-(a7)
		lea	HiList,a0
		moveq	#0,d2

hi_Score_loop1:	addq	#1,d2
		cmp	#max_entry+1,d2
		beq.s	found_entry
		add.l	#namensLaenge,a0
		move.l	(A0)+,d1
		cmp.l	d0,d1
		bhi.s	hi_Score_loop1

found_entry:	move	d2,d0
		cmp	#max_entry+1,d2
		bne.s	end_search_Score
		clr	d0
end_search_Score: 
		movem.l	(a7)+,a0/d1/d2
		rts




SaveHiScore:

	*** DiskProtect abfragen ***

		lea	Hiscore_File,a0
		lea	HiList,a1
		move.l	#$600,d0
		bsr	SaveFile

		rts




		lea	CopCol5,a1
		move	#$f00,6(A1)

		move	#7,Command
		bsr	StartTask
		bsr	WaitLoad

		tst.l	Result
		beq.s	Prot

		lea	Page1+(48*70)+16,a1
		lea	ProtText,a0
		bsr	PrintText2

		lea	Page1+(48*100)+10,a1
		lea	ProtText2,a0
		bsr	PrintText2

		clr	Ticks
		move	#$8100,$dff096

waithi:		Gfx	WaitTOF

		move	Ticks,d0
		and	#$3f,d0
		cmp	#$1f,d0
		blo.s	Black

		move	#$f00,d4
		bra.s	DoCol
Black:
		move	#$a00,d4
DoCol:
		lea	CopCol5,a1
		move	d4,6(A1)

		addq	#1,Ticks
		cmp	#500,Ticks
		beq.s	EndTick
	
		btst	#10,$dff016
		bne.s	waithi
EndTick:
		rts




Prot:		move	#3,Command
		move.l	#$600,Laenge
		move.l	#DiskScore,Offset
		move.l	#HiList,Ziel
		bsr	StartTask
		bsr	WaitLoad
		rts





PrintName:	movem.l	d0-d7/a0-a5,-(sp)

		lea	PlayerName,a0
		move.l	#Page1+1981+(3*9600),a1	
		bsr	PrintText2

		movem.l	(sp)+,d0-d7/a0-a5
		rts





GetName:	movem.l	d0-d7/a0-a6,-(sp)

		lea	PlayerName,a4

KeyIt:		bsr	PrintName
		bsr	GetKey
		tst	d1
		beq.s	KeyIt

		lea	Bob1,a1
		cmp.l	#AnimSeq2,54(A1)
		beq.s	notkl
		move.l	#AnimSeq2,54(A1)

notkl:		cmp.b	#$FF,d0
		bne.s	Node

		cmp.l	#PlayerName,a4
		beq.s	KeyIt
		move.b	#44,-(A4)
		bra.s	KeyIt

Node:		cmp.b	#$FD,d0
		beq.s	EndEnter		
		
		cmp.l	#EndName,a4
		beq.s	NoInsert
		move.b	d0,(A4)			

NoInsert:	cmp.l	#EndName,a4		
		beq.s	NoAdd
		addq.l	#1,a4

NoAdd:		bra.s	KeyIt

EndEnter:	lea	PlayerName,a0
		cmp.l	#'AMIG',(A0)
		bne.s	NoCheat
		cmp.l	#'A 88',4(A0)
		bne.s	NoCheat
	
		move.l	#' CRA',(A0)
		move.l	#'CK  ',4(A0)
		move.b	#1,Cheat

NoCheat:	lea	HiList,a1
		move.l	Place,d0
		subq.l	#1,d0
		mulu	#12,d0
		add.l	d0,a1
		move.l	(A0)+,(A1)+
		move.l	(A0)+,(A1)		
		movem.l	(sp)+,d0-d7/a0-a6
		rts




InsertScore:	movem.l	d0-d2/a0-a2,-(a7)
		tst	d0			
		beq.s	3$
	
		subq	#1,d0
		lea	HiList,a0
		move.l	a0,a2
		mulu	#namensLaenge+4,d0
		add.l	d0,a0			
		move	#max_entry,d2
		mulu	#namensLaenge+4,d2
		add.l	d2,a2			

		cmp.l	a2,a0			
		beq.s	2$

1$:		move	-12(a2),(a2)		
		subq	#2,a2			
		cmp.l	a2,a0
		bne.s	1$

2$:		move.l	(a1)+,(a0)+		
		move.l	(a1)+,(a0)+		
		move.l	d1,(a0)			

3$:		movem.l	(a7)+,d0-d2/a0-a2
		rts





GetKey:		movem.l	d2-d7/a0-a5,-(sp)
		moveq	#0,d1

.Get2:		moveq	#0,d0
		move.b	$bfec01,d0
		btst	#0,d0
		beq.s	.Get2		

		move.b	$bfec01,d0
		not.b	d0
		ror.b	#1,d0
		lea	CodeTabelle,a1
		move.b	(A1,d0),d0
		tst.b	d0
		beq.s	.Get2

		move.b	d0,Key
		cmp.b	OldKey,d0
		bne.s	.NotTheOld

		moveq	#8,d7
1$:		Gfx	WaitTOF
		dbf	d7,1$

		clr.b	OldKey
		bra.s	.Get2

.NotTheOld:	move.b	Key,OldKey
		move.b	Key,d0
		moveq	#1,d1

EndGet:		movem.l	(sp)+,d2-d7/a0-a5
		rts


CCNut:		movem.l	d1-d7/a0-a6,-(A7)
		lea	$dff000,a4
		clr	$a8(A4)
		clr	$b8(A4)
		clr	$c8(A4)
		clr	$d8(A4)


		lea	CCNGfx_File,a0
		move.l	#Page1,a1
		move.l	#51200,d0
		bsr	LoadFile


		lea	Nut2,a1
		move	#l3/4-1,d7
CNut:		clr.l	(A1)+
		dbf	d7,CNut			; Nuss loeschen

		lea	CCNBobs_File,a0
		move.l	#Bobs2,a1
		move.l	#512*89,d0
		bsr	LoadFile

		move.l	#Bobs2,LowWr
		move.l	#Bobs2+45448,ReadC
		bsr	Decru			; Bobs



		lea	CCNDigits_File,a0
		move.l	#BildAddr,a1
		move.l	#512*1,d0
		bsr	LoadFile


	IFD	fdsl

		move	#2,Command
		move.l	#CCNFx,Ziel
		move.l	#512*8,Laenge
		move.l	#512*176,Offset
		bsr	StartTask
		bsr	WaitLoad
		move	#6,Command
		bsr	StartTask


		move.l	#200,d1
		DOS	Delay

		lea	CCNFx_File,a0
		move.l	#CCNFx,a1
		move.l	#512*8,d0
		bsr	LoadFile
	ENDC


		lea	Bob32,a1
		clr.l	8(A1)			; Nuss reseten
		lea	Bob22,a1
		clr	8(A1)
		move	#150,10(A1)
		move	#29,20(A1)
		clr.l	50(A1)
		move.l	#AnimSeq22,54(A1)
		move.l	#MovePrg22,58(A1)
		clr	62(A1)
		move	#1,64(A1)
		clr.l	66(A1)		; Wurm reseten
		clr	70(A1)
	
	;	lea	Leer,a1
	;	lea	$dff000,a4
	;	move.l	a1,$a0(a4)
	;	move.l	a1,$b0(A4)
	;	moveq	#1,d4
	;	move	d4,$a4(A4)
	;	move	d4,$b4(A4)
	;;	move.l	#$20064,$c0(A4)
	;	move.l	#CCNFx+64,$c0(A4)
	;	move	#1938,$c4(A4)
	;	move	#500,$c6(A4)
	;	move.l	#$20064,$d0(A4)
	;	move	#1938,$d4(A4)
	;	move	#500,$d6(A4)
	;	move	#$800f,$96(A4)
	
	;	clr.l	d0
	;	move	vol1,d0
	;	divu	#3,d0
	;	move	d0,$dff0c8
	;	move	d0,$dff0d8
	
		lea	Page1,a1
		lea	Page3,a2
		moveq	#4,d3
rcopy2:		move	#2559,d6
recopy:		move.l	(A1)+,(A2)+
		dbf	d6,recopy
		add.l	#640,a2
		dbf	d3,rcopy2

		lea	Bob12,a1	
		lea	Bob22,a2
		lea	Bob32,a3
		move	d3,12(A1)
		move	d3,14(A1)
		move	d3,16(A1)
		move	d3,18(A1)
		move	d3,12(A2)
		move	d3,14(A2)
		move	d3,16(A2)
		move	d3,18(A2)
		move	d3,12(A3)
		move	d3,14(A3)
		move	d3,16(A3)
		move	d3,18(A3)
	

		move.l	#Page3,a1
		move.l	#Page1,a2
		move	#13600-1,d7	
CopyL:		move.l	(A1)+,(A2)+
		dbf	d7,CopyL
	
		move	#160,y2
		move	#160,y1
		clr	StopCnt
		clr	Timer
		clr	flag1
		clr	flag2
		move	#23,Nut22
	
		lea	CCNCopperSpr+2,a1
		move.l	#CNTSpr1,d0
		move	d0,20(A1)
		swap	d0
		move	d0,16(A1)
		move.l	#CNTSpr2,d0
		move	d0,28(A1)
		swap	d0
		move	d0,24(A1)
		move.l	#CCNspr2,d0
		move	d0,4(A1)
		swap	d0
		move	d0,(A1)
		move.l	#CCNspr3,d0
		move	d0,12(A1)
		swap	d0
		move	d0,8(A1)
	
		lea	CNTSpr1,a0
		move.b	#$30,(a0)
		move.b	#$40,2(A0)
		move.b	#176,1(A0)
		lea	CNTSpr2,a0
		move.b	#$30,(a0)
		move.b	#$40,2(A0)
		move.b	#170,1(A0)
	
		lea	CCNspr2,a0
		move	y2,d0
		bsr	WSpr
		lea	CCNspr3,a0
		move	y1,d0
		bsr	WSpr
Start2:
		lea	ColorMap2,a0
		lea	ColorBuffer2,a1
	
		moveq	#31,d7
Colorm2:	move	(A0)+,(A1)+
		dbf	d7,Colorm2
	
		lea	Bob12,a1	
		clr	8(A1)
		move	#123,10(A1)
		clr	20(A1)			
		clr	WaitLock
		clr	AnimCounter2
		clr	WaitCounter
		clr	HupfOffset2
		clr	NutCounter		
		clr	JumpLock		
		clr	GameLock		
		move	#-1,ColorSum
		move	#$8520,$dff096
		move.l	#copperlCCN,$dff080
	
		clr	FlipFlag		
		bsr	InitBobList2

		moveq	#4,d0
		lea	CCNIntStruct,a1
		Exec	AddIntServer

wt:		tst	StopCnt
		beq.s	wt
	
		moveq	#4,d0
		lea	CCNIntStruct,a1
		Exec	RemIntServer

		moveq	#40,d5
fer:		Gfx	WaitTOF
		dbf	d5,fer
	
		move	#$10F,$dff096
		move.l	#copperl4,$dff080
		move	NutCounter,d0		
		ext.l	d0
		movem.l	(a7)+,d1-d7/a0-a6
		rts



BLS:		lea	BildAddr+32,a1
		lsl.l	#5,d3
		add.l	d3,a1
		moveq	#16,d6
1$:		move	(A1)+,(A2)
		addq.l	#4,a2
		dbf	d6,1$
		rts



DoTheSprite:	move	NutCounter,d0
		cmp	Nut22,d0
		beq.s	NoChange
		
		move	d0,Nut22
		clr.l	d3
		ext.l	d0
		divu	#10,d0
		swap	d0
		move	d0,d3
		lea	CNTSpr1+4,a2
		bsr	BLS
		clr	d0
		swap	d0
		divu	#10,d0
		swap	d0
		clr.l	d3
		move	d0,d3
		lea	CNTSpr2+4,a2
		bsr	BLS

NoChange:	subq	#1,y1
		cmp	#yend,y1
		bne.s	notend
	
		move	#ystart,y1	
		move	#1,flag1

notend:		lea	CCNspr3,a0
		move	y1,d0
		bsr	dospr			; letzte Ziffer bewegen
		tst	flag1
		beq.s	notscroll2
	
		subq	#1,y2
		cmp	#yend,y2
		bne.s	noty2
		move	#ystart,y2

noty2:		addq	#1,flag1
		cmp	#17,flag1
		bne.s	notflag1
		clr	flag1

notflag1:	lea	CCNspr2,a0
		move	y2,d0
		bsr	dospr			; 2.Ziffer bewegen
notscroll2:	rts


dospr:		move.l	a0,a1
		add.l	#60,a1
		moveq	#14,d7			; d0=ypos
scroll:					; a1=spr
		move.l	(A1),4(A1)
		subq.l	#4,a1
	
		dbf	d7,scroll		; sprite scrollen
	
		move.l	a0,a1
		addq.l	#4,a1
	
		lea	BildAddr,a5
		move	d0,d4
		lsl	#1,d4			; aktuelle position*2
		add	d4,a5
		move	(A5),(A1)+
		clr	(A1)			; 1 Zeile schreiben
	
		move.l	a0,a1
		clr	60(a1)
		rts
	
WSpr:
		move.l	a0,a1
		add.l	#4,a1
		
		move.l	#BildAddr,a2
		move	d0,d1
		lsl	#1,d1
		add	d1,a2
	
		moveq	#15,d7			; d0=ypos
write23:
		move	(A2)+,(A1)+
		clr	(A1)+
		dbf	d7,write23
		rts

FadeOut:
		lea	ColorBuffer2,a0
		clr.l	d1
		moveq	#31,d7
FadeLoop2:
		move	(a0),d0
		bsr	FadeCol2
		move	d0,(A0)+
		add	d0,d1
		dbf	d7,FadeLoop2
		rts
FadeCol2:
		move	d0,d1
		and	#$00f,d1
		tst	d1
		beq	Bnull
		sub	#$001,d0
Bnull:
		move	d0,d1
		and	#$0f0,d1
		tst	d1
		beq	Gnull
		sub	#$010,d0
Gnull:
		move	d0,d1
		and	#$f00,d1
		beq	Rnull
		sub	#$100,d0
Rnull:
		rts





CCNInt:		movem.l	d0-d7/a0-a6,-(a7)

		bsr	DoTheSprite
		lea	BitmStr12+8,a0
		tst	FlipFlag
		beq.s	NoFlip22
		lea	BitmStr22+8,a0

NoFlip22:	lea	BitmapPtr2+2,a1
		moveq	#4,d7

Page_loop2:	move.l	(a0),d0			
		move	d0,4(a1)
		swap	d0
		move	d0,(A1)
		addq	#4,a0
		addq	#8,a1
		dbf	d7,Page_loop2
	
		addq	#1,Timer
		cmp	#1583,Timer
		bne.s	CCNNotZero
		move	#1,StopCnt

CCNNotZero:	tst	GameLock
		bne	NoMoveNut

LetsGame:	bsr	AskJoy
		move	d0,JoyWert
		tst	WaitLock
		beq	NoSubChris
		subq	#1,WaitLock
		tst	WaitLock
		bne	NoMoveNut
		bsr	Fang
		bra	NoMoveNut	
NoSubChris:
		tst	JumpLock		
		beq	MoveHerbie		
		lea	Bob12,a0			
		lea	HupfTab2,a1		
		clr.l	d0
		move	HupfOffset2,d0		
		move.w	(a1,d0),d1		
		cmp	#-1,d1			
		beq.s	HerbieNoHupf
		cmp	#22,20(A0)		
		bhi.s	JumpRight
		moveq	#5,d2
		sub	d1,d2			
		move	d2,d1			
JumpRight:				
		add	XOffset2,d1
		cmp	#200,d1			
		blt.s	NoHigher		
		move	#210,d1			

NoHigher:
		cmp	#10,d1			
		bpl	NoLower			
		move	#5,d1			
NoLower:
		move	d1,8(A0)		
		move	2(A1,d0),d1		
		add	#37,d1			
		move	d1,10(A0)		
		add	#4,HupfOffset2		

HerbieNoHupf:
		addq	#1,AnimCounter2		
		cmp	#7,AnimCounter2		
		bne	NoJump
		clr	AnimCounter2
		addq	#1,20(A0)		
		cmp	#26,20(A0)		
		beq.s	EndJump
		cmp	#23,20(A0)		
		beq	EndJump2
		bra	NoJump
EndJump:
		clr	JumpLock		
		clr	HupfOffset2		
		move	#19,20(A0)		
		move	#3,AnimCounter2
		bra.s	MoveHerbie
EndJump2:
		clr	JumpLock		
		clr	HupfOffset2		
		clr	20(A0)			
	
MoveHerbie:
		move	JoyWert,d0		
		lea	Bob12,a0			
		move	20(A0),d1
		btst	#1,d0			
		beq	NoLeft
		cmp	#320-110,8(A0)		
		bhi	XMax
		addq	#2,8(A0)		
XMax:
		cmp	#9,d1
		bhi	NoDirCor		
		add	#38,8(A0)		
		move	#10,d1			
		bra.s	NoEnd
NoDirCor:
		addq	#1,AnimCounter2		
		cmp	#4,AnimCounter2		
		bne	NoLeft
		clr	AnimCounter2
		addq	#1,d1			
		cmp	#20,d1
		bne	NoEnd
		moveq	#10,d1			
NoEnd:
		move	d1,20(A0)		
NoLeft:
		btst	#3,d0			
		beq	NoRight			
		cmp	#3,8(A0)		
		blt	XMin
		subq	#2,8(A0)		
		move	8(a0),d7
		tst	d7
		bpl.s	XMin
		clr	8(a0)
XMin:
		addq	#1,AnimCounter2		
		cmp	#4,AnimCounter2		
		bne	NoDirCor2
		clr	AnimCounter2	
		cmp	#10,d1			
		blt	NoXCor			
		sub	#38,8(A0)		
		tst	8(a0)
		bpl.s	NoXCor
		clr	8(a0)
NoXCor:
		addq	#1,d1			
		cmp	#10,d1			
		blt	NoDirCor2	
		clr	d1			
NoDirCor2:
		move	d1,20(A0)		
NoRight:
		btst	#7,d0			
		beq	NoJump
		move	8(A0),XOffset2		
		move	20(A0),d1		
		cmp	#10,d1			
		blt.s	JumpLeft
		moveq	#23,d2			
		move	d2,20(A0)		
		move	#-1,JumpLock		
		bra.s	NoJump
JumpLeft:
		moveq	#20,d2			
		move	d2,20(A0)		
		move	#-1,JumpLock		
NoJump:
		lea	Bob32,a0			
		cmp	#34,20(A0)		
		bne	MoveNut
		addq	#1,WaitCounter
		cmp	#50,WaitCounter		
		bne	NoMoveNut
		clr	WaitCounter		
MoveNut:
		tst	10(A0)			
		bne.s	NoNewX
TakeNewX:
		bsr	Rnd
		add	#20,d0
		move	d0,d1
		move	#33,20(A0)		
		move	d1,8(A0)
NoNewX:
		tst	JumpLock		
		bne	NoFang			
		lea	Bob12,a1
		move	10(A0),d1		
		move	10(a1),d0		
		add	#20,d0			
		move	d0,d2
		add	#10,d2			
		cmp	d0,d1			
		blt	NoFang			
		cmp	d2,d1
		bhi	NoFang
		move	8(a1),d0		
		addq	#5,d0			
		cmp	#10,20(a1)		
		blt	CorHerbX
		add	#50,d0			
CorHerbX:
		move	d0,d2		
		add	#33,d2			
		move	8(A0),d1		
		cmp	d0,d1
		blt	NoFang
		cmp	d2,d1			
		bhi	NoFang
		addq	#1,NutCounter		
					;sound!!!

	;	lea	$dff000,a5
	;	move	#$3,$96(A5)
	;	move.l	#NussFangen+500,$a0(A5)
	;	move	#550,$a4(A5)
	;	move	#180,$a6(A5)
	;	move.l	#NussFangen,$b0(A5)
	;	move	#800,$b4(A5)
	;	move	#170,$b6(A5)
	;	move	#$8003,$96(A5)
	;	move	vol1,$a8(A5)
	;	move	vol1,$b8(A5)

	;	move	#1000,d5
SndLoop:;	dbf	d5,SndLoop

	;	move.l	#Leer,$a0(A5)
	;	move	#1,$a4(A5)
	;	move.l	#Leer,$b0(A5)
	;	move	#1,$b4(A5)

		move	#5,WaitLock	
		bra.s	NoMoveNut

NoFang:		addq	#2,10(A0)	
		cmp	#4,NutCounter
		blt.s	Easy
		addq	#1,10(a0)
Easy:	
		cmp	#10,NutCounter
		blt.s	Easy2
		addq	#1,10(A0)
Easy2:
		cmp	#15,NutCounter
		blt.s	Easy3
		addq	#1,10(A0)
Easy3:
		cmp	#256,10(A0)		
		blt	NoMoveNut	
		bsr	Fang	
		bra	NoMoveNut

Fang:
		lea	Bob32,a0
		clr	10(A0)			
		move	#34,20(A0)		
		rts

NoMoveNut:
		bsr	DrawBobs2		
		bsr	Cycle			
		bsr	SetCol			
		not	FlipFlag

EndVblank2:	movem.l	(a7)+,d0-d7/a0-a6
		moveq	#0,d0
		rts



AskJoy:		movem.l	a0/d1,-(A7)
		tst	JoyMouseFlag
		bne	AskMouse
		move.l	Joy,a0
		move	(A0),d0
		move	d0,d1
		and	#$101,d1
		and	#$202,d0
		lsr	#1,d0
		eor	d0,d1
		lsl	#1,d0
		or	d1,d0
		move	d0,d1
		lsr	#6,d1
		and	#$ff,d0
		or	d1,d0
	
		move.b	$bfe001,d1
		not	d1
		and	#$80,d1
		or	d1,d0
EndAskJoy:
		movem.l	(A7)+,a0/d1
		rts


AskMouse:	move.l	Mouse2,a0
		clr	d2
		move	(A0),d0
		move	d0,d3
		and	#$ff,d0
		move	OldMouse,d1
		and	#$ff,d1
		cmp	d1,d0
		beq	NoXChange
		cmp	#$f0,d1
		blt.s	NoCrit1
		tst.b	d0
		bmi.s	NoCrit1
		bset	#1,d2
		bra.s	NoXChange
NoCrit1:
		cmp	#$10,d1
		bhi.s	NoCrit2
		tst.b	d0
		bpl.s	NoCrit2
		bset	#3,d2
		bra.s	NoXChange	
NoCrit2:
		cmp	d0,d1
		bhi	XLeft
		bset	#1,d2
		bra.s	NoXChange
XLeft:
		bset	#3,d2	

NoXChange:
		move	d3,OldMouse
		move	d2,d0
		move.b	$bfe001,d1
		not	d1
		and	#$40,d1
		lsl	#1,d1
		or	d1,d0
		bra	EndAskJoy


Joy:		dc.l	$dff00c
Mouse2:		dc.l	$dff00a
OldMouse:	dc.w	0
JoyMouseFlag:	dc.w	-1



SetCol:		lea	ColorBuffer2,a0
		lea	$dff180,a1
		moveq	#31,d0
SetColLoop:	move	(A0)+,(A1)+
		dbf	d0,SetColLoop
		rts


Cycle:		addq	#1,CycleCounter
		cmp	#5,CycleCounter
		bne	ENDCycle
		clr	CycleCounter
		lea	ColorBuffer2,a0
		move	62(A0),d0
		move	60(A0),62(A0)
		move	58(A0),60(A0)
		move	56(A0),58(A0)
		move	d0,56(A0)
ENDCycle:	rts



DrawBobs2:	movem.l	d0-d7/a0-a6,-(A7)
		lea	BobList2,a0
		lea	$dff000,a6

SearchLastBob2:				
		tst.l	(A0)		
		beq	BobReconstLoop2
		move.l	(A0),a0
		bra	SearchLastBob2
	
BobReconstLoop2:
		lea	BitmStr12,a2
		move.l	26(a0),a3
		move.l	a0,a5
		add	#12,a5
		tst	FlipFlag
		beq	NoFlip32
		lea	BitmStr22,a2
		move.l	30(a0),a3
		addq	#4,a5
NoFlip32:
		bsr	TestModify2
	
		Move.l	(A5),d1
		move.l	8(a0),(A5)
	
	
		cmp.l	#-1,d1
		beq	EndReconst2
	
		tst	d0
		beq	EndReconst2
	
		move.l	d1,d0
	
		moveq	#0,d1
		move	d0,d1
		swap	d0
		and.l	#$ffff,d0
		lsr	#3,d0
		bclr	#0,d0
		mulu	(a2),d1
		add.l	d1,d0
		moveq	#0,d1
		move.b	5(a2),d1
		subq	#1,d1
		addq	#8,a2

BlitWait22:	bsr	WaitBlitter

		move.l	(A2)+,d3
		add.l	d0,d3
		move.l	d3,$54(a6)
		move.l	a3,$50(a6)
		clr	$42(A6)
		move	#$9f0,$40(A6)
		move.l	#-1,$44(A6)
		clr	$64(A6)
		move	24(a0),$66(a6)
		move	22(a0),$58(a6)
		add.l	36(A0),a3
		dbf	d1,BlitWait22
EndReconst2:

		tst.l	44(A0)
		beq	EndRecLoop2
		move.l	44(A0),a0
		bra	BobReconstLoop2
	
EndRecLoop2:		
		lea	BobList2,a0
BobMainLoop2:
		tst.b	34(A0)
		beq	NoAnimate2
		moveq	#0,d0
		move	20(a0),d0
		lsl	#2,d0
		lea	BobImageList2,a1
		move.l	(a1,d0.l),a1		
		move.l	a1,a4
		add.l	40(A0),a4		
	
		lea	BitmStr12,a2
		move.l	26(A0),a3		
		tst	FlipFlag
		beq	NoFlip222
		lea	BitmStr22,a2
		move.l	30(A0),a3
NoFlip222:		
		clr.l	d0
		move	8(a0),d0
		move	d0,d2
		and	#15,d2
		moveq	#12,d3
		lsl	d3,d2			
		lsr	#3,d0
		move	10(A0),d1
		mulu	(A2),d1
		add	d1,d0			
	
		movem.l	a2-a3,-(a7)
		clr	d7
		move.b	5(A2),d7
		subq	#1,d7
		addq	#8,a2

BlitWait32:	bsr	WaitBlitter
		move.l	(A2)+,d3
		add.l	d0,d3
		move.l	a3,$54(a6)		
		move.l	d3,$50(a6)
		clr	$42(a6)			
		move	#$9f0,$40(A6)		
		move	24(a0),$64(A6)		
		clr	$66(a6)
		move.l	#-1,$44(a6)
		move	22(a0),$58(a6)
		add.l	36(A0),a3
		dbf	d7,BlitWait32
		movem.l	(a7)+,a2-a3
	
		clr	d7
		move.b	5(A2),d7
		subq	#1,d7	
		addq	#8,a2
		cmp	#-2,20(a0)
		beq	NoAnimate2
BlitWait12:	bsr	WaitBlitter

		move.l	(A2)+,a3
		add.l	d0,a3
		move.l	a3,$48(a6)		
		move.l	a1,$4c(A6)		
		move.l	a4,$50(a6)		
		move.l	a3,$54(a6)		
		move	d2,$42(a6)		
		move	#$0fca,d3
		or	d2,d3
		move	d3,$40(a6)		
		move	24(a0),$60(a6)		
		move	24(a0),$66(A6)		
		clr	$64(a6)
		clr	$62(A6)
		move.l	#$ffffffff,$44(a6)
		move	22(a0),$58(a6)
		add.l	36(A0),a1
		dbf	d7,BlitWait12
NoAnimate2:
		addq	#1,50(A0)		
		move	50(A0),d0
		cmp	48(a0),d0		
		bne	NoAnim2
		clr	50(A0)
AnimLoop2:
		tst.l	54(A0)			
		beq	NoAnim2
		move.l	54(A0),a1
		move	52(a0),d0
		add	d0,a1
		move	(A1),d0			
		cmp	#-3,d0
		beq	NoAnim2
		cmp	#-1,d0			
		bne	LetsAnim2
		clr	52(A0)			
		bra	AnimLoop2
LetsAnim2:
		move	d0,20(A0)		
		addq	#2,52(a0)		
NoAnim2:
		tst.l	58(A0)			
		beq	NoMove2
		addq	#1,66(A0)
		move	64(A0),d0
		cmp	66(A0),d0		
		bne	NoMove2
		clr	66(A0)
		tst	70(A0)			
		bne	NoNextCommand2	
MoveIt2:
		move	62(A0),d0
		move.l	58(A0),a1		
		addq	#4,62(a0)
		move	(a1,d0.w),d1		
		cmp	#-1,d1			
		bne	NoEndPrg2
		clr	62(A0)			
		bra.s	NoMove2

NoEndPrg2:
		move	d1,70(A0)		
		move	2(A1,d0.w),68(A0)	

NoNextCommand2:
		subq	#1,70(A0)		
		move	68(A0),d0
		btst	#0,d0
		beq	NoXadd2		
		addq	#1,8(A0)
NoXadd2:
		btst	#1,d0
		beq	NoXsub2	
		subq	#1,8(A0)
NoXsub2:
		btst	#2,d0
		beq	NoYadd2
		addq	#1,10(A0)
NoYadd2:
		btst	#3,d0
		beq	NoYsub2
		subq	#1,10(A0)
NoYsub2:
NoMove2:
		tst.l	(a0)			
		beq	EndDrawBobs2
		move.l	(A0),a0			
		bra	BobMainLoop2
EndDrawBobs2:
		movem.l	(a7)+,d0-d7/a0-a6
		rts


TestModify2:
		movem.l	d1/d2,-(sp)
		clr.l	d0
	
		move	50(A0),d1
		addq	#1,d1
		cmp	48(A0),d1
		beq	Modified2
	
		addq	#1,d1
		cmp	48(A0),d1
		beq	Modified2
	
		move.l	8(A0),d1
		move.l	12(A0),d2
		tst	FlipFlag
		beq	Mody12
		move.l	16(A0),d2
Mody12:
		cmp.l	d2,d1
		bra	Modified2
		movem.l	(sp)+,d1/d2
		move.b	d0,34(A0)
		rts
	
Modified2:
		st	d0
		move.b	d0,34(A0)
		movem.l	(sp)+,d1/d2
		rts
	
InitBobList2:
		movem.l	d0-d3/a0-a1,-(A7)
		lea	BobList2,a0

BobInitLoop2:
		lea	BitmStr12,a1
		move	(a1),d1
		move	4(a0),d0
		move	d0,d2
		lsr	#4,d0
		and	#15,d2
		tst	d2
		beq	BobEven2
		addq	#1,d0
BobEven2:
		moveq	#0,d2
		move	6(a0),d2
		moveq	#6,d3
		lsl	d3,d2
		or	d0,d2
		move	d2,22(a0)	
	
		lsl	#1,d0		
		sub	d0,d1
		move	d1,24(a0)	
		mulu 	6(a0),d0
		move.l	d0,36(a0)	
		moveq	#0,d1
		move.b	5(A1),d1
		mulu	d1,d0
		move.l	d0,40(a0)
	
		tst.l	(a0)
		beq	EndInitBobs2
		move.l	(A0),a0
		bra	BobInitLoop2
EndInitBobs2:	
		movem.l	(a7)+,d0-d3/a0-a1
		rts




WaitSound:	tst	SoundcNT1
		bhi.s	WaitSound
WaitSound2:	tst	SoundcNT2
		bhi.s	WaitSound2
		rts













		SECTION Intro2Data,DATA_C

		INCLUDE	"Sprites.i"


dostext:	dc.b	'dos.library',0
gfxtext:	dc.b	'graphics.library',0
inttext:	dc.b	'intuition.library',0
TrdDevice:	dc.b	'trackdisk.device',0
MenuIntName:	dc.b	'Crack Menu',0
MainIntName:	dc.b	'Crack Main',0
HiscoreIntName:	dc.b	'Crack HiScore',0
CCNIntName:	dc.b	'Crack Coconut Game',0

HUAText:	dc.B	1,000,'--------------------',0
		dc.B	1,012,' SPECIAL THANKS TO',0
		dc.B	1,024,'--------------------',0		
		dc.B	6,040,'- CHRIS -',0
		dc.B	7,052,'- SCA -',0
		dc.B	6,064,'- TIGER -',0
		dc.B	4,076,'- BLACK BIRD -',0
		dc.B	4,088,'- CONTROLLER -',0
		dc.B	1,100,'- SIN - ALFI - DAK -',0
		dc.B	2,112,'AND TO ANYONE ELSE ',0		
		dc.B	3,124,'WHO SUPPORTED ME',0
		dc.B	5,136,'IN ANY WAY.',0
		dc.B	1,160,'--------------------',0
		dc.B	8,172,'CRACK',0
		dc.B	1,184,'--------------------',0
		dc.B	4,196,'PLAY IT OR DIE',0	
		dc.B	1,208,'--------------------',0
		dc.B	16,230,'-C5-',0
		dc.B	0,0,0,0

Pausetext:	dc.b	'GAME PAUSED',0
Mesg:		dc.b	'ADDING BONUS TO YOUR SCORE',0
ScoreAsc:	dc.b	'0000000',0
ProtText:	dc.b	'COULD NOT Save HI-SCORE',0
ProtText2:	dc.b	'PRESS RIGHT MOUSE-BUTTON TO CONTINUE',0
ScoreAscii:	dc.b	'00000000',0,0
HiCntAscii:	dc.b	'XX',0,0
OverWrite:	dc.b	'        ',0
cong1:		dc.b	'CONGRATULATIONS....',0
cong2:		dc.b	'YOU ARE ONE OF THE GREATEST CRACK-PLAYER',0
cong3:		dc.b	'THANK YOU VERY MUCH FOR PLAYING .',0
TopText:	dc.b	'HALL OF FAME',0
StageName:	dc.b	'STAGEA',0
HiName:		dc.b	'12345678',0,0


MenuGfx_File:	dc.b	"Gfx/MenuGfx",0
Hiscore_File:	dc.b	"Datas/Hiscore",0
HiPic_File:	dc.b	"Gfx/HiPic",0
HiBobs_File:	dc.b	"Gfx/HiBobs",0

Bahn_File:	dc.b	"Datas/Bahn",0
Rahmen_File:	dc.b	"Gfx/Rahmen",0
Back_File:	dc.b	"Gfx/Back",0
Dino_File:	dc.b	"Gfx/BackPic0",0

Stage_File:	dc.b	"Stages/Stage_A",0
Sound_File:	dc.b	"Sound/SoundFX",0
Music_File:	dc.b	"Sound/Music",0

CCNGfx_File:	dc.b	"Gfx/CCNGfx",0
CCNBobs_File:	dc.b	"Gfx/CCNBobs",0
CCNDigits_File:	dc.b	"Gfx/CCNDigits",0
CCNFx_File:	dc.b	"Sound/CCNFx",0

Test_File:	dc.b	"Test",0





		CNOP	0,2


NewWindow:	dc.w	0,0		;start-position
		dc.w	320,200		;breite und hoehe
		dc.b	0,1		;farbe fuer menue und gadgets
		dc.l	0	;;$0168		;IDCMP - Flags
		dc.l	$1840		;Aussehen des Windows
		dc.l	0		;pointer zu speziellem gadget
		dc.l	0		;pointer zu user check mark 
		dc.l	0		;pointer zum title
MainScreen:	dc.l	0		;pointer zum Screen 0=A-Dos 
		dc.l	0		;pointer zu superbitmap
		dc.w	0,0		;kleinste groesse
		dc.w	0,0		;groesste Groesse
		dc.w	$000f		;Screen type


NewScreen:	dc.w	0,0		;x,y
		dc.w	320		;Breite
		dc.w	200		;Hoehe
		dc.w	1		;Anzahl Bitplanes
		dc.b	1,0		;Farben fuer Menuebalken und Gadgets
		dc.w	$0000		;Viewmode
		dc.w	$010F		;Screentype
		dc.l	0		;Zeiger auf Zeichensatz
		dc.l	0		;Zeiger auf Title
		dc.l	0		;Zeiger auf spez.Gadgets
		dc.l	0   		;Zeiger auf eigene Bitmap-Structur

		dc.l	0	;;;	ScrTags

ScrTags:	dc.l	$80000000+32+$1a,MyPens
		dc.l	0,0

MyPens:		dc.l	-1,0


MenuIntStruct:	dc.l	0,0
		dc.b	0,0
		dc.l	MenuIntName			* Node
		dc.l	0
		dc.l	MenuInt

HiscoreIntStruct:
		dc.l	0,0
		dc.b	0,0
		dc.l	HiscoreIntName			* Node
		dc.l	0
		dc.l	HiscoreInt

MainIntStruct:	dc.l	0,0
		dc.b	0,0
		dc.l	MainIntName			* Node
		dc.l	0
		dc.l	MainInt

CCNIntStruct:	dc.l	0,0
		dc.b	0,0
		dc.l	CCNIntName			* Node
		dc.l	0
		dc.l	CCNInt








BobImageList2:	dc.l	Bobs2		
		dc.l	Bobs2+(1*l1)	
		dc.l	Bobs2+(2*l1)	
		dc.l	Bobs2+(3*l1)	
		dc.l	Bobs2+(4*l1)	
		dc.l	Bobs2+(5*l1)	
		dc.l	Bobs2+(6*l1)	
		dc.l	Bobs2+(7*l1)	
		dc.l	Bobs2+(8*l1)	
		dc.l	Bobs2+(9*l1)	
		dc.l	Bobs2+(10*l1)	
		dc.l	Bobs2+(11*l1)	
		dc.l	Bobs2+(12*l1)	
		dc.l	Bobs2+(13*l1)	
		dc.l	Bobs2+(14*l1)	
		dc.l	Bobs2+(15*l1)	
		dc.l	Bobs2+(16*l1)	
		dc.l	Bobs2+(17*l1)	
		dc.l	Bobs2+(18*l1)	
		dc.l	Bobs2+(19*l1)				
		dc.l	Bobs2+(20*l1)				
		dc.l	Bobs2+(21*l1)				
		dc.l	Bobs2+(22*l1)				
		dc.l	Bobs2+(23*l1)
		dc.l	Bobs2+(24*l1)
		dc.l	Bobs2+(25*l1)
	
		dc.l	Worm2+(0*l2) 	
		dc.l	Worm2+(1*l2)	
		dc.l	Worm2+(2*l2)	
		dc.l	Worm2+(3*l2)	
		dc.l	Worm2+(4*l2)	
		dc.l	Worm2+(5*l2)	
		dc.l	Worm2+(6*l2)	
		
		dc.l	Nut2		
		dc.l	Nut2+l3

BobList2:
Bob12:
		dc.l	Bob22		
		dc.w	112,57		
		dc.w	0,123		
		dc.w	-1,-1		
		dc.w	-1,-1		
		dc.w	0		
		dc.w	0		
		dc.w	0		
		dc.l	buffer		;Save12		
		dc.l	buffer+3990	;Save22		
		dc.w	0		
		dc.l	0		
		dc.l	0		
		dc.l	0		
		dc.w	1		
		dc.w	0		
		dc.w	0		
		dc.l	0		
		dc.l	0		
		dc.w	0		
		dc.w	1		
		dc.w	0		
		dc.w	0		
		dc.w	0		

Bob22:
		dc.l	Bob32		; Worm
		dc.w	80,28
		dc.w	0,150		
		dc.w	-1,-1		
		dc.w	-1,-1		
		dc.w	29	
		dc.w	0	
		dc.w	0		
		dc.l	buffer+7980	;Save32		
		dc.l	buffer+9380	;Save42		
		dc.w	0	
		dc.l	0	
		dc.l	0	
		dc.l	Bob12		
		dc.w	8		
		dc.w	0		
		dc.w	0		
CCNAnim:
		dc.l	AnimSeq22	
		dc.l	MovePrg22	
		dc.w	0
		dc.w	1		
		dc.w	0		
		dc.w	0		
		dc.w	0		

Bob32:		
		dc.l	0		; NUSS
		dc.w	32,16		
		dc.w	100,0		
		dc.w	-1,-1		
		dc.w	-1,-1		
		dc.w	33		
		dc.w	0		
		dc.w	0		
		dc.l	buffer+10780	;Save52
		dc.l	buffer+11100	;Save62		
		dc.w	0		
		dc.l	0		
		dc.l	0		
		dc.l	Bob22
		dc.w	1		
		dc.w	0		
		dc.w	0		
		dc.l	0		
		dc.l	0		
		dc.w	0		
		dc.w	1		
		dc.w	0		
		dc.w	0		
		dc.w	0		

MovePrg22:	dc.w	247,1		
		dc.w	247,2		
		dc.w	-1


AnimSeq22:	dc.w	26,27,26,27,26,27,26,27,26,27
		dc.w	26,27,26,27,26,27,26,27,26,27
		dc.w	26,27,26,27,26,27,26,27
		dc.w	32,31,30
		dc.w	28,29,28,29,28,29,28,29,28,29
		dc.w	28,29,28,29,28,29,28,29,28,29
		dc.w	28,29,28,29,28,29,28,29
		dc.w	30,31,32
		dc.w	-1

ColorMap2:	dc.L	$00000EBA,$0DA90C98,$0B870A76,$09650854
		dc.L	$07540643,$05320421,$032108C8,$06A60484
		dc.L	$03730252,$03330444,$05550666,$07770999
		dc.L	$0BBB0DDD,$0c7900dd,$0BEF08EF,$07DF00DF

ColorBuffer2:	ds.w	32
HupfOffset2:	dc.w	0
XOffset2:	dc.w	0

HupfTab2:	dc.w	1,87
		dc.w	3,83
		dc.w	11,73
		dc.w	14,70
		dc.w	18,67,26,60,41,52,46,51,51,50,62,52,71,56,73,58
		dc.w	75,61,80,67,83,75,83,80,84,85,85,87,-1
			

CCNspr2:	dc.w	$3046,$4000
		ds.l	17

CCNspr3:	dc.w	$304c,$4000
		ds.l	17


y1:		dc.w	160
y2:		dc.w	160
oldXPos2:	dc.w	6
Flashcnt:	dc.w	1

flag1:		dc.w	0
flag2:		dc.w	0
StopCnt:	dc.w	0
Timer:		dc.w	0
suber:		dc.w	0
Mode1:		dc.b	1


CongTable:	dc.l	Page1+3379
		dc.l	cong1
		dc.l	Page1+4808
		dc.l	cong2
		dc.l	Page1+5771
		dc.l	cong3
		dc.l	0,0,0




Font:		REPT 120
		 dc.b	0
		ENDR

		dc.b	0,0,0,0,0,0,0,0,0,$3e
		dc.b	0,0,0,0,$7e,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,16,0,0

		REPT 10
		 dc.b	0
		ENDR

		dc.b	0,$F8,$48,$48,$48,$48,$48,$7C,0,0
		dc.b	0,$10,$10,$10,$10,$10,$10,$10,0,0
		dc.b	0,$3E,$04,$24,$3C,$20,$20,$7C,0,0
		dc.b	0,$20,$10,$08,$3C,$08,$10,$20,0,0
		dc.b	0,$20,$20,$28,$7C,$28,$08,$08,0,0
		dc.b	0,$78,$20,$20,$78,$08,$08,$7C,0,0
		dc.b	0,$04,$08,$10,$7C,$64,$24,$3C,0,0
		dc.b	0,$7C,$08,$08,$08,$08,$08,$08,0,0
		dc.b	0,$78,$28,$28,$7E,$44,$44,$7E,0,0
		dc.b	0,$7C,$48,$4C,$78,$10,$20,$40,0,0

		REPT 70
		 dc.b	0
		ENDR

		dc.b	0,$3E,$12,$12,$1F,$12,$12,$12,0,0	;a
		dc.b	0,$38,$14,$12,$1E,$12,$14,$38,0,0	;b
		dc.b	0,$04,$08,$10,$20,$10,$08,$04,0,0	;c
		dc.b	0,$30,$18,$14,$12,$14,$18,$30,0,0	;d
		dc.b	0,$04,$08,$10,$3C,$10,$08,$04,0,0	;e
		dc.b	0,$3E,$10,$10,$3C,$10,$10,$10,0,0	;f
		dc.b	0,$04,$08,$10,$23,$11,$0A,$04,0,0	;g
		dc.b	0,$32,$12,$12,$1F,$12,$12,$13,0,0	;h
		dc.b	0,$0C,$08,$08,$08,$08,$08,$18,0,0	;i
		dc.b	0,$06,$04,$04,$04,$24,$14,$08,0,0	;j
		dc.b	0,$12,$14,$18,$30,$18,$14,$12,0,0	;k
		dc.b	0,$30,$10,$10,$10,$10,$10,$1E,0,0	;l
		dc.b	0,$62,$36,$2A,$22,$22,$22,$23,0,0	;m
		dc.b	0,$62,$32,$32,$2A,$26,$26,$23,0,0	;n
		dc.b	0,$3E,$12,$12,$12,$12,$12,$1F,0,0	;o
		dc.b	0,$38,$14,$12,$14,$18,$10,$10,0,0	;p
		dc.b	0,$3E,$12,$12,$12,$16,$13,$1E,0,0	;q
		dc.b	0,$38,$14,$12,$12,$1C,$12,$11,0,0	;r
		dc.b	0,$0C,$32,$10,$08,$04,$26,$18,0,0	;s
		dc.b	0,$7E,$08,$08,$08,$08,$08,$0C,0,0	;t
		dc.b	0,$32,$12,$12,$12,$12,$12,$0F,0,0	;u
		dc.b	0,$32,$12,$12,$12,$12,$12,$0C,0,0	;v
		dc.b	0,$62,$22,$22,$2A,$2A,$1C,$08,0,0	;w
		dc.b	0,$22,$14,$08,$08,$08,$14,$22,0,0	;x
		dc.b	0,$22,$12,$0A,$06,$02,$02,$03,0,0	;y
		dc.b	0,$3E,$04,$04,$08,$10,$10,$3E,0,0	;z





		CNOP 0,2

copperl5:	dc.w	$1021,$fffe
sprites5:	dc.w	$0120,$0000
		dc.w	$0122,$0000
		dc.w	$0124,$0000
		dc.w	$0126,$0000
		dc.w	$0128,$0000
		dc.w	$012a,$0000
		dc.w	$012c,$0000
		dc.w	$012e,$0000
		dc.w	$0130,$0000
		dc.w	$0132,$0000
		dc.w	$0134,$0000
		dc.w	$0136,$0000
		dc.w	$0138,$0000
		dc.w	$013a,$0000
		dc.w	$013c,$0000
		dc.w	$013e,$0000

		dc.w	$1201,$fffe
		dc.w	$009c,$8010	
		dc.w 	$008e,$3a81
	 	dc.w 	$0090,$02c1
		dc.w 	$0104,$0024
		dc.w 	$0092,$0038
		dc.w 	$0094,$00d0
		dc.w 	$0102,$0000
		dc.w 	$0108,$0008
		dc.w 	$010a,$0008

CopCol5:	dc.w	$0180,$0000
		dc.w	$0182,$0001
		dc.w	$0184,$0002
		dc.w	$0186,$0003
		dc.w	$0188,$0004
		dc.w	$018a,$0005
		dc.w	$018c,$0006
		dc.w	$018e,$0007
		dc.w	$0190,$0008
		dc.w	$0192,$0009
		dc.w	$0194,$000a
		dc.w	$0196,$000b
		dc.w	$0198,$000c
		dc.w	$019a,$000d
		dc.w	$019c,$000e
		dc.w	$019e,$000f
		dc.w	$01a0,$0000
		dc.w	$01a2,$0001
		dc.w	$01a4,$0002
		dc.w	$01a6,$0003
		dc.w	$01a8,$0004
		dc.w	$01aa,$0005
		dc.w	$01ac,$0006
		dc.w	$01ae,$0007
		dc.w	$01b0,$0008
		dc.w	$01b2,$0009
		dc.w	$01b4,$000a
		dc.w	$01b6,$000b
		dc.w	$01b8,$000c
		dc.w	$01ba,$000d
		dc.w	$01bc,$000e
		dc.w	$01be,$000f

planes5:	dc.w 	$00e0,$0000
		dc.w 	$00e2,$0000
		dc.w 	$00e4,$0000
		dc.w 	$00e6,$0000
		dc.w 	$00e8,$0000
		dc.w 	$00ea,$0000
		dc.w 	$00ec,$0000
		dc.w 	$00ee,$0000
		dc.w	$00f0,$0000
		dc.w	$00f2,$0000

		dc.w	$0100,$5200

		dc.w	$01a8,$000f
		dc.w	$3821,$fffe
		dc.w	$01b0,$0000
		dc.w	$3c21,$fffe
		dc.w	$01b0,$0100
		dc.w	$4021,$fffe
		dc.w	$01b0,$0200
		dc.w	$4421,$fffe
		dc.w	$01b0,$0300
		dc.w	$4821,$fffe
		dc.w	$01b0,$0400
		dc.w	$4c21,$fffe
		dc.w	$01b0,$0500
		dc.w	$5021,$fffe
		dc.w	$01b0,$0600
		dc.w	$5421,$fffe
		dc.w	$01b0,$0700
		dc.w	$5821,$fffe
		dc.w	$01b0,$0800
		dc.w	$5c21,$fffe
		dc.w	$01b0,$0900
		dc.w	$6021,$fffe
		dc.w	$01b0,$0a00
		dc.w	$6421,$fffe
		dc.w	$01b0,$0b10
		dc.w	$6821,$fffe
		dc.w	$01b0,$0c20
		dc.w	$6c21,$fffe
		dc.w	$01b0,$0d30
		dc.w	$7021,$fffe
		dc.w	$01b0,$0e40

RCol2:		dc.w	$01a8,$0000
		dc.w	$7421,$fffe
		dc.w	$01b0,$0f50
		dc.w	$7821,$fffe
		dc.w	$01b0,$0f60
		dc.w	$7c21,$fffe
		dc.w	$01b0,$0f70
		dc.w	$8021,$fffe
		dc.w	$01b0,$0f80
		dc.w	$8421,$fffe
		dc.w	$01b0,$0f90
		dc.w	$8821,$fffe
		dc.w	$01b0,$0fa0
		dc.w	$8c21,$fffe
		dc.w	$01b0,$0fc0
		dc.w	$9821,$fffe
		dc.w	$01b0,$0fb0
		dc.w	$9e21,$fffe
		dc.w	$01b0,$0fa0
		dc.w	$a221,$fffe
		dc.w	$01b0,$0f90
		dc.w	$a621,$fffe
		dc.w	$01b0,$0f80
		dc.w	$aa21,$fffe
		dc.w	$01b0,$0f70
		dc.w	$ae21,$fffe
		dc.w	$01b0,$0f60
		dc.w	$b221,$fffe
		dc.w	$01b0,$0f50
		dc.w	$b621,$fffe
		dc.w	$01b0,$0f40
		dc.w	$ba21,$fffe
		dc.w	$01b0,$0e30
		dc.w	$be21,$fffe
		dc.w	$01b0,$0d20
		dc.w	$c221,$fffe
		dc.w	$01b0,$0c10
		dc.w	$c621,$fffe
		dc.w	$01b0,$0b00
		dc.w	$ca21,$fffe
		dc.w	$01b0,$0a00
		dc.w	$ce21,$fffe
		dc.w	$01b0,$0900
		dc.w	$d221,$fffe
		dc.w	$01b0,$0800
		dc.w	$d621,$fffe
		dc.w	$01b0,$0700
		dc.w	$da21,$fffe
		dc.w	$01b0,$0600
		dc.w	$de21,$fffe
		dc.w	$01b0,$0500
		dc.w	$e221,$fffe
		dc.w	$01b0,$0400
		dc.w	$e621,$fffe
		dc.w	$01b0,$0300
		dc.w	$ea21,$fffe
		dc.w	$01b0,$0200
		dc.w	$ee21,$fffe
		dc.w	$01b0,$0000
		dc.w	$ffff,$fffe 


copperl4:	dc.w	$1021,$fffe
		dc.w	$008e,$2c81
		dc.w	$0090,$20c1
		dc.w	$0092,$0038
		dc.w	$0094,$00d0
		dc.w	$0100,$1200
		dc.w	$0108,$0000
		dc.w	$010a,$0000
		dc.w	$0180,$0000
		dc.w	$0182,$0000
		dc.w	$0096,$0120
		dc.w	$ffff,$fffe		


copperl3:	dc.w	$1021,$fffe

planes3:	dc.w	$00e0,$0000
		dc.w	$00e2,$0000
		dc.w	$00e4,$0000
		dc.w	$00e6,$0000
		dc.w	$00e8,$0000
		dc.w	$00ea,$0000
		dc.w	$00ec,$0000
		dc.w	$00ee,$0000
		dc.w	$00f0,$0000
		dc.w	$00f2,$0000

		dc.w	$008e,$2c81
		dc.w	$0090,$20c1
		dc.w	$0092,$0038
		dc.w	$0094,$00d0
		dc.w 	$0102,$0000
		dc.w 	$0104,$0024
		dc.w	$0108,$0000
		dc.w	$010a,$0000

		dc.w	$1221,$fffe
		dc.w	$0100,$5200

sprites3:
CopMenuSpr:	dc.w	$0120,$0000
		dc.w	$0122,$0000
		dc.w	$0124,$0000
		dc.w	$0126,$0000
		dc.w	$0128,$0000
		dc.w	$012a,$0000
		dc.w	$012c,$0000
		dc.w	$012e,$0000
		dc.w	$0130,$0000
		dc.w	$0132,$0000
		dc.w	$0134,$0000
		dc.w	$0136,$0000
		dc.w	$0138,$0000
		dc.w	$013a,$0000
		dc.w	$013c,$0000
		dc.w	$013e,$0000

		dc.w	$2021,$fffe

colors3:	dc.w	$0180,$0000
		dc.w	$0182,$0000
		dc.w	$0184,$0000
		dc.w	$0186,$0000
		dc.w	$0188,$0000
		dc.w	$018a,$0000
		dc.w	$018c,$0000
		dc.w	$018e,$0000
		dc.w	$0190,$0000
		dc.w	$0192,$0000
		dc.w	$0194,$0000
		dc.w	$0196,$0000
		dc.w	$0198,$0000

rightcol2:	dc.w	$019a,$0000
		dc.w	$019c,$0000
		dc.w	$019e,$0000
		dc.w	$01a0,$0000
		dc.w	$01a2,$0000
		dc.w	$01a4,$0000
		dc.w	$01a6,$0000
		dc.w	$01a8,$0000
		dc.w	$01aa,$0000
		dc.w	$01ac,$0000
		dc.w	$01ae,$0000
		dc.w	$01b0,$0000
		dc.w	$01b2,$0000

much:		dc.w	$01b4,$0000
stagecol:	dc.w	$01b6,$0000
mouse:		dc.w	$01b8,$0000
Joystick:	dc.w	$01ba,$0000
CCNon:		dc.w	$01bc,$0000
		dc.w	$01be,$0000


		dc.w	$2c21,$fffe
		dc.w	$19a,$7
		dc.w	$3021,$fffe
		dc.w	$19a,$8
		dc.w	$3421,$fffe
		dc.w	$19a,$9
		dc.w	$3821,$fffe
		dc.w	$19a,$a
		dc.w	$3c21,$fffe
		dc.w	$19a,$b
		dc.w	$4021,$fffe
		dc.w	$19a,$c
		dc.w	$4421,$fffe
		dc.w	$19a,$d
		dc.w	$4821,$fffe
		dc.w	$19a,$e
		dc.w	$4c21,$fffe
		dc.w	$19a,$10f
		dc.w	$5021,$fffe
		dc.w	$19a,$20f
		dc.w	$5421,$fffe
		dc.w	$19a,$30f
		dc.w	$5821,$fffe
		dc.w	$19a,$40f
		dc.w	$5c21,$fffe
		dc.w	$19a,$50f
		dc.w	$6021,$fffe
		dc.w	$19a,$60f
		dc.w	$6221,$fffe

much1:		dc.w	$1b4,$fff
		dc.w	$6421,$fffe
		dc.w	$19a,$70f
		dc.w	$1be,Menucolor2
		dc.w	$6821,$fffe
		dc.w	$19a,$80f
		dc.w	$6c21,$fffe
		dc.w	$19a,$90f

much2:		dc.w	$1b4,$f00
		dc.w	$7021,$fffe
		dc.w	$19a,$a0f
		dc.w	$7421,$fffe
		dc.w	$19a,$b0f
		dc.w	$7821,$fffe
		dc.w	$19a,$c0f
		dc.w	$7c21,$fffe
		dc.w	$19a,$d0f

much3:		dc.w	$1b4,$0f0
		dc.w	$8021,$fffe
		dc.w	$19a,$e0f
		dc.w	$8421,$fffe
		dc.w	$19a,$f0f
		dc.w	$8821,$fffe
		dc.w	$19a,$f0e
		dc.w	$8c21,$fffe
		dc.w	$19a,$f0d
		dc.w	$9021,$fffe
		dc.w	$19a,$f0c
		dc.w	$9421,$fffe
		dc.w	$19a,$f0b

		dc.w	$9821,$fffe
		dc.w	$19a,$f0a

much4:		dc.w	$1b4,$f00
		dc.w	$19a,$f09
		dc.w	$9c21,$fffe
		dc.w	$a021,$fffe
		dc.w	$19a,$f08
		dc.w	$a421,$fffe
		dc.w	$19a,$f07
		dc.w	$a821,$fffe
		dc.w	$19a,$f06
		dc.w	$ac21,$fffe
		dc.w	$19a,$f05
CCNoff:
		dc.w	$1be,$f00
		dc.w	$b021,$fffe
		dc.w	$19a,$f04
		dc.w	$b421,$fffe
		dc.w	$19a,$f13
		dc.w	$b821,$fffe
		dc.w	$19a,$f22
		dc.w	$bc21,$fffe
		dc.w	$19a,$f31
		dc.w	$c021,$fffe
		dc.w	$19a,$f40

much5:		dc.w	$1b4,$0ff
		dc.w	$c421,$fffe
		dc.w	$19a,$f50
		dc.w	$c821,$fffe
		dc.w	$19a,$f60
		dc.w	$cc21,$fffe
		dc.w	$19a,$f70
		dc.w	$d021,$fffe
		dc.w	$19a,$f80
		dc.w	$d421,$fffe
rightcol:	dc.w	$19a,$fff
	
		dc.w	$ffff,$fffe





copperl:	dc.w	$1021,$fffe

planes:		dc.w	$00e0,$0000
		dc.w	$00e2,$0000	
		dc.w	$00e4,$0000
		dc.w	$00e6,$0000
		dc.w	$00e8,$0000
		dc.w	$00ea,$0000	
		dc.w	$00ec,$0000
		dc.w	$00ee,$0000	
		dc.w	$00f0,$0000
		dc.w	$00f2,$0000	
		dc.w	$00f4,$0000
		dc.w	$00f6,$0000	

copperspr:	dc.w	$0120,$0000
		dc.w	$0122,$0000	
		dc.w	$0124,$0000
		dc.w	$0126,$0000	
		dc.w	$0128,$0000
		dc.w	$012a,$0000	
		dc.w	$012c,$0000
		dc.w	$012e,$0000	
		dc.w	$0130,$0000
		dc.w	$0132,$0000	
		dc.w	$0134,$0000
		dc.w	$0136,$0000
		dc.w	$0138,$0000
		dc.w	$013a,$0000	
		dc.w	$013c,$0000
		dc.w	$013e,$0000	

coppercol:	dc.w	$0180,$0000
		dc.w $0182,$0fff
		dc.w $0184,$0f00
		dc.w $0186,$0ff0
		dc.w $0188,$0000
		dc.w $018a,$0000
		dc.w $018c,$0000
		dc.w $018e,$0000

		dc.w $0190,$0ddd
		dc.w $0192,$0aaa
		dc.w $0194,$0ccc
		dc.w $0196,$0f00
		dc.w $0198,$0666
		dc.w $019a,$0999
		dc.w $019c,$0aab
		dc.w $019e,$0960

		dc.w $01a0,$0003
		dc.w $01a2,$0ddd
		dc.w $01a4,$0aaa
		dc.w $01a6,$0113
		dc.w $01a8,$0320

fsprcol:	dc.w $01aa,$0310
		dc.w $01ac,$0850
		dc.w $01ae,$0640
pic2col:
		dc.w $01b0,$0740
		dc.w $01b2,$0751
		dc.w $01b4,$0a72
		dc.w $01b6,$0850
		dc.w $01b8,$0862
		dc.w $01ba,$0a71
		dc.w $01bc,$0d93
		dc.w $01be,$0fff

		dc.w $0098,$f208
		dc.w $0180,$0000
	
		dc.w $008e,$2c81	;79
		dc.w $0090,$f4c1
		dc.w $0100,$6200
		dc.w $0104,$0024
		dc.w $0092,$0038
		dc.w $0094,$00d0
	
		dc.w $0102,$0000
		dc.w $0108,$0000
		dc.w $010a,$0000
	

Powerturm:	dc.w $018a,$0000
		dc.w $010a,$0000	
		
		dc.w $2e21,$fffe
		dc.w $018a,$00f0

cycle2:		dc.w $01be,$0f00
		
		dc.w $3521,$fffe
		dc.w $018a,$02f0
		dc.w $01be,$0f20
		
		dc.w $3c21,$fffe
		dc.w $018a,$03f0
		dc.w $01be,$0f40
		
		dc.w $4321,$fffe
		dc.w $018a,$04f0
		dc.w $01be,$0f60
		
		dc.w $4a21,$fffe
		dc.w $018a,$05f0
		dc.w $01be,$0f80
		
		dc.w $5121,$fffe
		dc.w $018a,$06f0
		dc.w $01be,$0fa0
		
		dc.w $5821,$fffe
		dc.w $018a,$07f0
		dc.w $01be,$0fc0
		
		dc.w $5f21,$fffe
		dc.w $018a,$08f0
		dc.w $01be,$0fe0
		
		dc.w $6621,$fffe
		dc.w $018a,$09f0
		dc.w $01be,$0ef0
		
		dc.w $6d21,$fffe
		dc.w $018a,$0af0
		dc.w $01be,$0cf0
		
		dc.w $7421,$fffe
		dc.w $018a,$0bf0
		dc.w $01be,$0af0
		
		dc.w $7b21,$fffe
		dc.w $018a,$0ce0
		dc.w $01be,$08f0
		
		dc.w $8221,$fffe
		dc.w $018a,$0dd0
		dc.w $01be,$06f0
		
		dc.w $8921,$fffe
		dc.w $018a,$0ed0
		dc.w $01be,$04f0
		
		dc.w $009c,$8010		
		
		dc.w $9021,$fffe
		dc.w $018a,$0fc0
		dc.w $01be,$02f0
		
		dc.w $9721,$fffe
		dc.w $018a,$0fb0
		dc.w $01be,$02f0
		
		dc.w $9e21,$fffe
		dc.w $018a,$0fa0
		dc.w $01be,$02f0
		
		dc.w $a521,$fffe
		dc.w $018a,$0f90
		dc.w $01be,$00f0
		
		dc.w $ac21,$fffe
		dc.w $018a,$0f80
		dc.w $01be,$00f2
		
		dc.w $b321,$fffe
		dc.w $018a,$0f70
		dc.w $01be,$00f4
		
		dc.w $ba21,$fffe
		dc.w $018a,$0f60
		dc.w $01be,$00f6
		
		dc.w $c121,$fffe
		dc.w $018a,$0f50
		dc.w $01be,$00f8
		
		dc.w $c821,$fffe
		dc.w $018a,$0f30
		dc.w $01be,$00fa
		
		dc.w $d821,$fffe
	
	
schl_col:	dc.w $018a,$f00
		dc.w $0190,$ddd
		dc.w $0192,$aaa
		dc.w $0194,$ccc
		dc.w $0196,$999
		dc.w $0198,$666
		dc.w $019a,$999
		dc.w $019c,$fff
		dc.w $019e,$aaa
		

cycle1:		dc.w $018a,$f00
		dc.w $e021,$fffe
		dc.w $018a,$c00
		dc.w $e121,$fffe
		dc.w $018a,$b00
		dc.w $e221,$fffe
		dc.w $018a,$a00
		dc.w $e321,$fffe
		dc.w $018a,$900
		dc.w $e421,$fffe
		dc.w $018a,$800
		dc.w $e521,$fffe
		dc.w $018a,$700
		dc.w $e621,$fffe
		dc.w $018a,$600
		dc.w $e721,$fffe
		dc.w $018a,$500
		
		dc.w $0190,$0ddd
		dc.w $019c,$0eee

		dc.w $ffff,$fffe 



copperl2:	dc.w	$1021,$fffe
planes2:	dc.w $00e0,$0000
		dc.w $00e2,$0000
		dc.w $00e4,$0000
		dc.w $00e6,$0000
		dc.w $00e8,$0000
		dc.w $00ea,$0000
		dc.w $00ec,$0000
		dc.w $00ee,$0000
		dc.w $00f0,$0000
		dc.w $00f2,$0000
		dc.w $00f4,$0000
		dc.w $00f6,$0000
	
sprites2:	dc.w $0120,$0000
		dc.w $0122,$0000	
		dc.w $0124,$0000
		dc.w $0126,$0000	
		dc.w $0128,$0000
		dc.w $012a,$0000	
		dc.w $012c,$0000
		dc.w $012e,$0000	
		dc.w $0130,$0000
		dc.w $0132,$0000	
		dc.w $0134,$0000
		dc.w $0136,$0000	
		dc.w $0138,$0000
		dc.w $013a,$0000	
		dc.w $013c,$0000
		dc.w $013e,$0000	

coppercol2:	dc.w $0180,$0000
		dc.w $0182,$0000
		dc.w $0184,$0000
		dc.w $0186,$0000
		dc.w $0188,$0000
		dc.w $018a,$0000
		dc.w $018c,$0000
		dc.w $018e,$0000
		dc.w $0190,$0000
		dc.w $0192,$0000
		dc.w $0194,$0000
		dc.w $0196,$0000
		dc.w $0198,$0000
		dc.w $019a,$0000
		dc.w $019c,$0000
		dc.w $019e,$0000
		dc.w $01a0,$0000
		dc.w $01a2,$0000	
		dc.w $01a4,$0000
		dc.w $01a6,$0003
		dc.w $01a8,$0000
		dc.w $01aa,$0000
		dc.w $01ac,$0000
		dc.w $01ae,$0000
		dc.w $01b0,$0000
		dc.w $01b2,$0000
		dc.w $01b4,$0000
		dc.w $01b6,$0000
		dc.w $01b8,$0000
		dc.w $01ba,$0000
		dc.w $01bc,$0000
		dc.w $01be,$0000		
	
		dc.w $0180,$0000
		dc.w $018a,$0000
		dc.w $008e,$2c81	;2c79
		dc.w $0090,$f4c1
		dc.w $0100,$6200
		dc.w $0104,$0024
		dc.w $0092,$0038
		dc.w $0094,$00d0	;d2
		dc.w $0102,$0000
		dc.w $0108,$0000
		dc.w $010a,$0000

		dc.w $ffff,$fffe






BitmStr1:	dc.w	48
		dc.w	200
		dc.b	0
		dc.b	5
		dc.w	0
		dc.l	Page1
		dc.l	Page1+pl
		dc.l	Page1+(2*pl)
		dc.l	Page1+(3*pl)
		dc.l	Page1+(4*pl)

BitmStr12:	dc.w	40
		dc.w	256
		dc.b	0
		dc.b	5
		dc.w	0
		dc.l	Page1
		dc.l	Page1+(1*10880)
		dc.l	Page1+(2*10880)
		dc.l	Page1+(3*10880)
		dc.l	Page1+(4*10880)

BitmStr22:	dc.w	40
		dc.w	256
		dc.b	0
		dc.b	5
		dc.w	0
		dc.l	Page3
		dc.l	Page3+(1*10880)
		dc.l	Page3+(2*10880)
		dc.l	Page3+(3*10880)
		dc.l	Page3+(4*10880)


CodeTabelle:	dc.B	0,'1','2','3','4','5','6','7','8','9','0'
		dc.B	'-','=',0,0,'0','Q','W','E','R','T','Y','U'
		dc.B	'I','O','P',0,0,0,'1','2','3','A','S','D'
		dc.B	'F','G','H','J','K','L',0,0,0,0,'4','5','6'
		dc.B	0,'Z','X','C','V','B','N','M','.','.','?'
		dc.B	0,'.','7','8','9',' ',$FF,0,$FD,$FD,0,$FF
		dc.b	0,0,0,'-'
		ds.B	100



		CNOP 0,2


;;PlayerName:	dc.b	' CRACK  '
PlayerName:	dc.b	'........'

MeNut:		dc.l	much
		dc.l	much1
		dc.l	much2
		dc.l	much3
		dc.l	much4
		dc.l	much5
		dc.l	stagecol

		dc.l	mouse
		dc.l	Joystick
		dc.l	CCNon
		dc.l	CCNoff
		dc.l	0



verz:		dc.w	50
CCN:		dc.b	1,0



copperlCCN:	dc.w	$1001,$fffe
		dc.w	$009c,$8010
		dc.w 	$008e,$2881
		dc.w 	$0090,$28c1
		dc.w 	$0104,$0024
		dc.w 	$0092,$0038
		dc.w 	$0094,$00d0
		dc.w 	$0102,$0000
		dc.w 	$0108,0
		dc.w 	$010a,0
	
ccnsprites:	dc.w	$0120,$0
		dc.w	$0122,$0
		dc.w	$0124,$0
		dc.w	$0126,$0

CCNCopperSpr:	dc.w	$0128,$0
		dc.w	$012a,$0
		dc.w	$012c,$0
		dc.w	$012e,$0
		dc.w	$0130,$0
		dc.w	$0132,$0
		dc.w	$0134,$0
		dc.w	$0136,$0
		dc.w	$0138,$0
		dc.w	$013a,$0
		dc.w	$013c,$0
		dc.w	$013e,$0

BitmapPtr2:	dc.w 	$00e0,$0000
		dc.w 	$00e2,$0000
		dc.w 	$00e4,$0000
		dc.w 	$00e6,$0000
		dc.w 	$00e8,$0000
		dc.w 	$00ea,$0000
		dc.w 	$00ec,$0000
		dc.w 	$00ee,$0000
		dc.w	$00f0,$0000
		dc.w	$00f2,$0000

		dc.w	$0100,$5200
Color3:
		dc.w	$01aa,$0fff
		dc.w	$01b2,$0fff
		dc.w	$01b6,$000c
		dc.w	$4021,$fffe
		dc.w	$01aa,$0666
		dc.w	$01b2,$0ddd
		dc.w	$ffff,$fffe 




piccounter:	dc.b	'1'

vol1:		dc.w	60
vol2:		dc.w	60
fdir:		dc.b	1
shiptable:	dc.l	2500,5000,10000,25000,100000,250000,-1,-1
LochCnt2:	dc.w	1
open1:		dc.w	280

Powercol:	REPT	25
		 dc.w	$a9b
		ENDR

		;dc.w	$0a0,$1a0,$2a0,$2a0,$3a0,$4a0,$5a0,$6a0,$7a0
		;dc.w	$8a0,$9a0,$aa0,$ba0,$ca0,$da0,$d90,$d80,$d70
		;dc.w	$d60,$d50,$d40,$d30,$d20,$d10,$d00

orgPowercol:	dc.w	$0f0,$2f0,$3f0,$4f0,$5f0,$6f0,$7f0,$8f0,$9f0
		dc.w	$af0,$bf0,$ce0,$dd0,$ed0,$fc0,$fb0,$fa0,$f90
		dc.w	$f80,$f70,$f60,$f50,$f30,$f00,$f00


Tempo:		dc.w	20
fast:		dc.w	1
Joy1:		dc.b	0
Joy2:		dc.b	1

oldx:		dc.b	0,0
imgX:		dc.w	0

oldx2:		dc.b	0,0
imgX2:		dc.w	120

MousX2:		dc.w	60

Screen1:	dc.l	Page1
Screen2:	dc.l	Page3
Screen3:	dc.l	Page4

	
shoot1:		dc.w $0000,$0000
		dc.w $4002,$4002
		dc.w $E007,$E007
		dc.w $E007,$E007
		dc.w $4002,$4002
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		;dc.w $A005,$A005

fspr3:		dc.w 0,0
		dc.w $0080,$0000
		dc.w $0040,$0180
		dc.w $00A0,$0340
		dc.w $0110,$0660
		dc.w $0208,$0C30
		dc.w $0404,$1818
		dc.w $0208,$0C30
		dc.w $0110,$0660
		dc.w $0020,$03C0
		dc.w $0040,$0180
		dc.w $0080,$0000
		ds.l	10

fspr1:
		dc.w $0000,$0000
		dc.w $0F80,$0f80
		dc.w $3FE0,$3fe0
		dc.w $7FF0,$7ff0
		dc.w $78F0,$78f0
		dc.w $F078,$f078
		dc.w $E038,$e038
		dc.w $E038,$e038
		dc.w $E038,$e038
		dc.w $F078,$f078
		dc.w $78F0,$78f0
		dc.w $7FF0,$7ff0
		dc.w $3FE0,$3fe0
		dc.w $0F80,$0f80
		dc.w $0000,$0000
fs2:
		dc.w $0000,$0000
		dc.w $0F00,$0f00
		dc.w $3FC0,$3fc0
		dc.w $7FE0,$7fe0
		dc.w $79E0,$79e0
		dc.w $F0F0,$f0f0
		dc.w $E070,$e070
		dc.w $E070,$e070
		dc.w $E070,$e070
		dc.w $F0F0,$f0f0
		dc.w $79E0,$79e0
		dc.w $7FE0,$7fe0
		dc.w $3FC0,$3fc0
		dc.w $0F00,$0f00
		dc.w $0000,$0000
fs3:
		dc.w $0000,$0000
		dc.w $0700,$0700
		dc.w $1FC0,$1fc0
		dc.w $3FE0,$3fe0
		dc.w $3DE0,$3de0
		dc.w $78F0,$78f0
		dc.w $7070,$7070
		dc.w $7070,$7070
		dc.w $7070,$7070
		dc.w $78F0,$78f0
		dc.w $3DE0,$3de0
		dc.w $3FE0,$3fe0
		dc.w $1FC0,$1fc0
		dc.w $0700,$0700
		dc.w $0000,$0000
fs4:
		dc.w $0000,$0000
		dc.w $0F00,$0f00
		dc.w $1F80,$1f80
		dc.w $3FC0,$3fc0
		dc.w $3FC0,$3fc0
		dc.w $79E0,$79e0
		dc.w $70E0,$70e0
		dc.w $70E0,$70e0
		dc.w $70E0,$70e0
		dc.w $79E0,$79e0
		dc.w $3FC0,$3fc0
		dc.w $3FC0,$3fc0
		dc.w $1F80,$1f80
		dc.w $0F00,$0f00
		dc.w $0000,$0000
fs5:
		dc.w $0000,$0000
		dc.w $0700,$0700
		dc.w $0F80,$0f80
		dc.w $1FC0,$1fc0
		dc.w $1FC0,$1fc0
		dc.w $3DE0,$3de0
		dc.w $38E0,$38e0
		dc.w $38E0,$38e0
		dc.w $38E0,$38e0
		dc.w $3DE0,$3de0
		dc.w $1FC0,$1fc0
		dc.w $1FC0,$1fc0
		dc.w $0F80,$0f80
		dc.w $0700,$0700
		dc.w $0000,$0000
fs6:
		dc.w $0000,$0000
		dc.w $0600,$0600
		dc.w $0F00,$0f00
		dc.w $1F80,$1f80
		dc.w $1F80,$1f80
		dc.w $3FC0,$3fc0
		dc.w $39C0,$39c0
		dc.w $39C0,$39c0
		dc.w $39C0,$39c0
		dc.w $3FC0,$3fc0
		dc.w $1F80,$1f80
		dc.w $1F80,$1f80
		dc.w $0F00,$0f00
		dc.w $0600,$0600
		dc.w $0000,$0000
fs7:
		dc.w $0000,$0000
		dc.w $0200,$0200
		dc.w $0700,$0700
		dc.w $0F80,$0f80
		dc.w $0F80,$0f80
		dc.w $1FC0,$1fc0
		dc.w $1dc0,$1dc0
		dc.w $1dc0,$1dc0
		dc.w $1dc0,$1dc0
		dc.w $1FC0,$1fc0
		dc.w $0F80,$0f80
		dc.w $0F80,$0f80
		dc.w $0700,$0700
		dc.w $0200,$0200
		dc.w $0000,$0000
fs8:
		dc.w $0000,$0000
		dc.w $0600,$0600
		dc.w $0600,$0600
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $1F80,$1f80
		dc.w $1F80,$1f80
		dc.w $1F80,$1f80
		dc.w $1F80,$1f80
		dc.w $1F80,$1f80
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0600,$0600
		dc.w $0600,$0600
		dc.w $0000,$0000
fs9:
		dc.w $0000,$0000
		dc.w $0200,$0200
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0F80,$0f80
		dc.w $0F80,$0f80
		dc.w $0F80,$0f80
		dc.w $0F80,$0f80
		dc.w $0F80,$0f80
		dc.w $0F80,$0f80
		dc.w $0F80,$0f80
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0200,$0200
		dc.w $0000,$0000
fs10:
		dc.w $0000,$0000
		dc.w $0600,$0600
		dc.w $0600,$0600
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0F00,$0f00
		dc.w $0600,$0600
		dc.w $0600,$0600
		dc.w $0000,$0000
fs11:
		dc.w $0000,$0000
		dc.w $0200,$0200
		dc.w $0200,$0200
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0700,$0700
		dc.w $0200,$0200
		dc.w $0200,$0000
		dc.w $0000,$0000


sprite1:	dc.w	$0,$0
		dc.w	$0,$00
		dc.w	$38,$04
		dc.w	$7C,$02
		dc.w	$78,$06
		dc.w	$78,$06
		dc.w	$70,$0E
		dc.w	$0,$3C
		dc.w	$0,$0
sprite2:
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$38,$04
		dc.w	$7C,$02
		dc.w	$78,$06
		dc.w	$78,$06
		dc.w	$70,$0E
		dc.w	$0,$3C
		dc.w	$0,$0

spr1:		dc.l	sprite1		
		dc.b	0,0,1,1	

spr2:		dc.l	sprite2		
		dc.b	0,0,1,2	
hit:		dc.w	0







cyclelist1:	dc.w	$f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70
		dc.w	$f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0
		dc.w	$ef0,$df0,$cf0,$bf0,$af0,$9f0,$8f0,$7f0
		dc.w	$6f0,$5f0,$4f0,$3f0,$2f0,$1f0,$0f0,$0f1
		dc.w	$0f2,$0f3,$0f4,$0f4,$0f5,$0f6,$0f7,$0f8
		dc.w	$0f9,$0fa,$0fb,$0fc,$0fc,$0fd,$0fe,$0ff
		dc.w	$0ef,$0df,$0cf,$0bf,$0af,$09f,$08f,$07f
		dc.w	$06f,$05f,$04f,$03f,$02f,$01f,$00f,$10f
		dc.w	$20f,$30f,$40f,$50f,$60f,$70f,$80f,$90f
		dc.w	$a0f,$b0f,$c0f,$d0f,$e0f,$f0f,$f0e,$f0d
		dc.w	$f0c,$f0b,$f0a,$f09,$f08,$f07,$f06,$f05
		dc.w	$f04,$f03,$f02,$f01

	;	dc.w	$ff0,$ff0,$fe0,$fd0,$fc0,$fb0,$fa0,$f90
	;	dc.w	$f80,$f70,$f60,$f50,$f40,$f30,$f20,$f10
ENDClist1:

cyclelist2:	dc.w	$f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80,$f90
		dc.w	$fa0,$fb0,$fc0,$fd0,$fe0,$ff0,$ff0,$ef0,$df0,$cf0
		dc.w	$bf0,$af0,$9f0,$8f0,$7f0,$6f0,$5f0,$4f0,$3f0,$2f0
		dc.w	$1f0,$0f0,$0f1,$0f2,$0f3,$0f4,$0f5,$0f6,$0f7,$0f8
		dc.w	$0f9,$0fa,$0fb,$0fc,$0fd,$0fe,$0ff,$0ef,$0df,$0cf
		dc.w	$0bf,$0af,$09f,$08f,$07f,$06f,$05f,$04f,$03f,$02f
		dc.w	$01f,$00f,$10f,$20f,$30f,$40f,$50f,$60f,$70f,$80f
		dc.w	$90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f,$f0e,$f0d,$f0c
		dc.w	$f0b,$f0a,$f09,$f08,$f07,$f06,$f05,$f04,$f03,$f02
		dc.w	$f01

ENDClist2:	dc.w	$f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80,$f90




shake_table:	dc.b	1,-1
		dc.b	-1,-3
		dc.b	1,-2
		dc.b	-1,-3
		dc.b	-1,-1
		dc.b	-1,-2
		dc.b	1,-2
		dc.b	1,-1


Bahnen_tabelle:	dc.l	Bahn1
		dc.l	Bahn2
		dc.l	Bahn3
		dc.l	Bahn4
		dc.l	Bahn5
		dc.l	Bahn6
		dc.l	Bahn7
		dc.l	Bahn8
		dc.l	Bahn9
		dc.l	Bahn10
		dc.l	Bahn10
		dc.l	Bahn10
		dc.l	Bahn4
		dc.l	Bahn9
		dc.l	Bahn6
		dc.l	Bahn8

Bahnen_tabelle2:
		dc.l	b9
		dc.l	b9
		dc.l	b9
		dc.l	b9
		dc.l	b9
		dc.l	b9
		dc.l	b9
		dc.l	b9
		dc.l	b9
		dc.l	b10
		dc.l	b10
		dc.l	b10
		dc.l	b9
		dc.l	b9
		dc.l	b9
		dc.l	b9
b9:
		dc.l	sp1
		dc.l	sp2
		dc.l	sp8
		dc.l	sp8
		dc.l	sp1
		dc.l	sp2
		dc.l	sp2
		dc.l	sp8
b10:
		dc.l	sp3
		dc.l	sp3
		dc.l	sp6
		dc.l	sp3
		dc.l	sp6
		dc.l	sp6
		dc.l	sp3
		dc.l	sp6
sp1:
		dc.w	225-20,228,20,$c97,$fca,122,20,3
		dc.l	Blatt1
		dc.l	Blatt2
		dc.l	Blatt3
		dc.l	Blatt4
		dc.l	Blatt5
		dc.l	Blatt6
		dc.l	Blatt5
		dc.l	Blatt4
		dc.l	Blatt3
		dc.l	Blatt2
		dc.l	Blatt1
		dc.l	0
sp2:
		dc.w	225-16,228,16,$ccc,$888,122,20,6
		dc.l	CRACK1
		dc.l	CRACK2
		dc.l	CRACK3
		dc.l	CRACK4
		dc.l	CRACK5
		dc.l	CRACK6
		dc.l	CRACK7
		dc.l	CRACK8
		dc.l	CRACK9
		dc.l	CRACK10
		dc.l	CRACK11
		dc.l	CRACK12
		dc.l	CRACK13
		dc.l	CRACK14
		dc.l	CRACK15
		dc.l	CRACK16
		dc.l	CRACK17
		dc.l	CRACK18
		dc.l	CRACK19
		dc.l	CRACK20
		dc.l	CRACK21
		dc.l	CRACK22
		dc.l	CRACK23
		dc.l	CRACK24
		dc.l	CRACK25
		dc.l	CRACK26
		dc.l	CRACK27
		dc.l	CRACK28
		dc.l	CRACK29
		dc.l	0
sp3:
		dc.w	225-32,228,32,$ccc,$c97,122,20,-1
		dc.l	LANZE1
		dc.l	0
sp4:
		dc.w	225-16,228,16,$fca,$c97,122,30,-1
		dc.l	GKUGEL1
		dc.l	0
Sp5:
		dc.w	225-16,228,16,$a00,$f00,122,30,2
		dc.l	Rotate1
		dc.l	Rotate2
		dc.l	Rotate3
		dc.l	Rotate4
		dc.l	Rotate5
		dc.l	Rotate6
		dc.l	Rotate7
		dc.l	Rotate8
		dc.l	Rotate9
		dc.l	Rotate10
		dc.l	0
sp6:
		dc.w	225-42,228,42,$777,$c97,122,16,10
		dc.l	MAN1
		dc.l	MAN2
		dc.l	0
sp8:
		dc.w	225-11,228,12,$ccc,$888,122,30,-1
		dc.l	Kugel
		dc.l	0


oldshap:	dc.l	-1


Kugel:		dc.w	$0000,$0700
		dc.w	$0000,$1FC0
		dc.w	$0C00,$33E0
		dc.w	$1C00,$23E0
		dc.w	$1800,$67F0
		dc.w	$0000,$7FF0
		dc.w	$0000,$7FF0
		dc.w	$0000,$3FE0
		dc.w	$0000,$3FE0
		dc.w	$0000,$1FC0
		dc.w	$0000,$0700
		dc.l	0

expltable:	dc.w	2280,2286,2292,2298,2304
		dc.w	3240,3246,3252,3258,3264
		dc.w	4200,4206,4212,4218,4224
		dc.w	4230,4230,4230,4230
		dc.w	4230,4230,4230,4230
		dc.w	4230,4230,4230,4230

tabelle:	dc.w 140,142,144,146,148,148
tabelle2:	dc.w 19,18,17,16,15,15
tabelle3:	dc.w 150,152,154,156,158,158

HiCnt:		dc.l	1



		SECTION IntroBSS,BSS_C

_DOSBase:	ds.l	1
_GfxBase:	ds.l	1
_IntuitionBase:	ds.l	1
fspr2:		ds.l	100
;VBlankVeq2:	ds.l	1			
;VBlankVeq:	ds.l	1

DummySprite:	ds.l	4
wert:		ds.l	1
Place:		ds.l	1
points:		ds.l	1
spr:		ds.l	1
sprite:		ds.l	1
Shape:		ds.l	1
PShap:		ds.l	1
scr:		ds.l	1
plane:		ds.l	1
ReadC:		ds.l	1			
LowWr:		ds.l	1			
Leer:		ds.l	2
diskIO:		ds.l	20
readrep:	ds.l	8
CNTSpr1:	ds.l	20
CNTSpr2:	ds.l	20
HiStufe:	ds.l	1
Stufe2:		ds.l	1
schl:		ds.l	1
schl2:		ds.l	1
Ticks:		ds.l	1
ListcNT:	ds.l	1
ListcNT2:	ds.l	1
signalmaske:	ds.l	1
signalnummer:	ds.l	1
stackmem:	ds.l	1
Offset:		ds.l	1
Laenge:		ds.l	1
Ziel:		ds.l	1
Screen:		ds.l	1
Window:		ds.l	1
Bahn:		ds.l	1
sprite3:	ds.l	1
Score:		ds.l	1
hiScore:	ds.l	1
stc:		ds.l	1
locnt1:		ds.l	1
extend:		ds.l 	1
extend2:	ds.l	1

PlayCnt:	ds.w	1
Tempo2:		ds.w	1
waiter:		ds.w	1
blink:		ds.w	1
waitb:		ds.w	1
slow:		ds.w	1
slowcnt:	ds.w	1
dist:		ds.w	1
MousX:		ds.w	1
mousy:		ds.w	1
dist2:		ds.w	1
f2cnt:		ds.w	1
MenuCnt:	ds.w	1
MousePos:	ds.w	1
OldMousePos:	ds.w	1
oldmpos:	ds.w	1
eye:		ds.w	1
ColorSum:	ds.w	1
NutCounter:	ds.w	1
AnimCounter2:	ds.w	1
WaitCounter:	ds.w	1
JoyWert:	ds.w	1
WaitLock:	ds.w	1
spe:		ds.w	1
MenuSpr:	ds.w	50
Shape1:		ds.w	1
Shape2:		ds.w	1
Shape3:		ds.w	1
Shape4:		ds.w	1
Shape5:		ds.w	1
eye2:		ds.w	1
FromMenu:	ds.w	2
FromList:	ds.w	1
refresh:	ds.w	1
blocks:		ds.w	3
docnt:		ds.w	1
refy:		ds.w	1
NoPrint:	ds.w	1
ytest1:		ds.w	1
ytest2:		ds.w	1
yhoehe:		ds.w	1
Speed:		ds.w	1
Shapi:		ds.w	1
count:		ds.w	1
ShapCNT:	ds.w	1
SoundcNT1:	ds.w	1
SoundcNT2:	ds.w	1
SoundcNT3:	ds.w	1
SoundcNT4:	ds.w	1
Nut22:		ds.w	1
FromCCN:	ds.w	1
BattleTime:	ds.w	1
XPos:		ds.w	1
sicher:		ds.w	1
which:		ds.w	1
fcounter:	ds.w	1
EndName:	ds.w	1
EndGame:	ds.w	1
EndGame2:	ds.w	1
loading:	ds.w	1
Command:	ds.w	1
x2:		ds.w	1
x:		ds.w	1
PowerSoll:	ds.w	1
LochDir2:	ds.w	1
LGameCnt:	ds.w	1
locnt2:		ds.w	1
open2:		ds.w	1
y:		ds.w	1
LochCnt:	ds.w	1
LochDir:	ds.w	1
Kept2:		ds.w	1
c1cnt:		ds.w	1
c2cnt:		ds.w	1
LaserCnt:	ds.w	1
Powercnt2:	ds.w	1
Power:		ds.w	1
Power2:		ds.w	1
lcnt:		ds.w	1
loaded:		ds.w	1
x4:		ds.w	1
y4:		ds.w	1
endinter:	ds.w	1
CycleCounter:	ds.w	1
JumpLock:	ds.w	1
GameLock:	ds.w	1
FlipFlag:	ds.w	1
DemoRnd:	ds.w	1
oldXPos:	ds.w	1

wert22:		ds.b	2
EyeBuff:	ds.b	20
changed:	ds.b	1
TwoPlayer:	ds.b	1
Battle:		ds.b	1
twoball:	ds.b	1
twoschl:	ds.b	1
smash:		ds.b	1
falling:	ds.b	1
Cheat:		ds.b	1
bonus:		ds.b	1
Lives:		ds.b	1
OldLives:	ds.b	1
excounter:	ds.b	1
excounter2:	ds.b	1
hold:		ds.b	1
alter:		ds.b	1
Kept:		ds.b	1
Demo:		ds.b	1
Auto:		ds.b	1
Key:		ds.b	1
OldKey:		ds.b	1
revers:		ds.b	1
FastExit:	ds.b	1
laser:		ds.b	1
level:		ds.b	1
Paused:		ds.b	1
exploding:	ds.b	1
leftout:	ds.b	1
rightout:	ds.b	1
nlevel:		ds.b	1
plevel:		ds.b	1
LGame:		ds.b	2
Away:		ds.b	2



Taskstrc:	ds.b	46
stack1:		ds.l	1
stack2:		ds.l	1
stack3:		ds.l	1
start:		ds.l	5		* Dont change order of this block




Bahn1:		ds.b	242
Bahn2:		ds.b	244
Bahn3:		ds.b	316
Bahn4:		ds.b	286
Bahn5:		ds.b	354
Bahn6:		ds.b	552
Bahn7:		ds.b	552
Bahn8:		ds.b	316
Bahn9:		ds.b	514
Bahn10:		ds.b	514+1230

BallStein:	ds.b	4764
BallHolz:	ds.b	2332
BallStock:	ds.b	5024
StockZerfall:	ds.b	7852
Schuss:		ds.b	7984
SpritePlopp:	ds.b	8434
ScoreSound:	ds.b	2626
Harve:		ds.b	26978
NussFangen:	ds.b	1590

Bobs:
Bobs2:		ds.b	26*l1
Worm2:		ds.b	7*l2
Nut2:		ds.b	5*l3

BildAddr:	ds.b	512

Page1:		ds.b	55000
Page3:		ds.b	55000
Page4:		ds.b	51264

buffer:		ds.b	25600	;;196608
HiList:		ds.b	1536

HSpeicher:	ds.b	7168
ZSpeicher:	ds.w	300
Flashlist:	ds.w	300

CCNFx:		ds.b	512*8
