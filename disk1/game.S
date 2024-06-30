
; Name    : CRACK-AMIGAnoid
; Version : V2.14
; Date    : 26. Februar 1988
; Author  : -C5-,CHRIS
; Errors  : ?
; Project : ?

	org	$12000
	load	$12000

	leer=$70000
	abprall=$44000
	datadisk=512*617
	buffer=$42000
	bahn1=$75000
	bahn2=bahn1+242
	bahn3=bahn2+244
	bahn4=bahn3+316
	bahn5=bahn4+286
	bahn6=bahn5+354
	bahn7=bahn6+552
	bahn8=bahn7+552
	bahn9=bahn8+316
	bahn10=bahn9+514
	BallStein=$20000
	BallHolz=BallStein+4764
	BallStock=BallHolz+2332
	StockZerfall=BallStock+5024
	Schuss=StockZerfall+7852
	SpritePlopp=Schuss+7984
	ScoreSound=SpritePlopp+8434
	Harve=ScoreSound+2626
	NussFangen=Harve+26978

	DemoVer=0
	Final=1
	Time=1

o:
	clr.l	$70000
	lea	$dff000,a6
	move	#$8400,$96(A6)		
	move	#$1000,$98(A6)
	
	bsr	InitLib
	bsr	InitTask
	bsr	LoadHiScore
o1:
	clr.b	Demo
	bsr	Menu

	cmp.l	#'HISC',d0
	bne.s	NoShowHiscore

	clr.b	Demo
	move.b	#1,FromMenu
	bsr	DoHiScore
	bra.s	o1		
NoShowHiscore:
	cmp.l	#'EDIT',d0
	bne.s	o2

	bsr	RemoveTask
If	Final
	move.l	#copperl4,$dff080
Else
	move.l	GfxBase(pc),a6
	move.l	38(a6),$dff080
	move	#$8100,$dff096
	clr.l	d0
EndIf
	rts

o2:
	bsr	o3
	bra.s	o1
o3:
	move	#60,vol1
	clr.l	stc
	clr.l	Score
	clr.l	stufe2
	move.b	#1,Kept
	move.l	$6c,OldVek
	move.l	OldVek,IntVek
	move	#$8010,$dff09a	
	clr	Power
	clr	PowerSoll
	bsr	RestorePower

If	DemoVer
	clr.l	$70000
Else
	tst.b	Demo
	beq.s	NotDemo
EndIf
	clr.b	Lives
	move.b	#1,OldLives
	move.l	HiStufe,Stufe2
If	DemoVer
	clr.l	Stufe2
Else
	bchg	#0,Mode1
	move.b	mode1,twoplayer
EndIf
	bra.s	demo66
If	DemoVer
Else
notdemo:
	move.b	#2,lives
	move.b	#1,oldlives
	clr.b	auto
EndIf
demo56:
	clr.l	stufe2
demo66:
	clr	BattleTime
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
	move.l	#Int,$6c
	move	#6,command
	bsr	StartTask
haupt2:
	move	#$8120,$dff096
	clr	endgame2
	clr	endgame
	clr.b	paused
	bsr	wait_start
haupt:
w9:
	move.l	gfxbase,a6
	jsr	-270(A6)
If	Time
	move	#$f00,$dff180
EndIf
	bsr	alles_geloescht
	tst	d0
	bne.s	notall
	move.b	#1,nlevel
notall:
	tst	endgame
	bne	endit

	tst.b	demo
	beq.s	dontsk

	add	#1,powercnt2
	cmp	#10,powercnt2
	bne.s	powr
	clr	powercnt2
	add	#1,powersoll
powr:	
	btst	#6,$bfe001
	beq	exit2
	btst	#7,$bfe001
	beq	exit2
dontsk:
	tst.b	nlevel
	bne	nextlevel
	tst.b	plevel
	bne	prelevel
	tst	waitb
	bne	wait_ball
	tst.b	exploding
	bne	explosion
	tst.b	rightout
	bne	moveschlright
	tst.b	leftout
	bne	moveschlleft

	tst 	lasercnt
	beq.s	las
	sub	#1,lasercnt
	tst	lasercnt
	bne.s	las
	move.l	#4,schl
	move.l	#4,schl2
	clr.b	laser
las:
	tst.b	battle
	beq	nobtl
	cmp.l	#5,schl
	beq	nobtl
	cmp.l	#5,schl2
	beq.s	nobtl		

	cmp	#30,BattleTime
	bhi.s	NoAddTime
	addq	#1,BattleTime
NoAddTime:
	cmp	#25,BattleTime
	bls.s	nobtl
	
	btst	#6,$bfe001
	bne.s	nc5
	cmp	#5,schl2
	beq.s	NC5

	move.l	#5,schl
	move	#100,lasercnt
	move.b	#1,laser
	bra.s	nobtl
nc5:
	cmp	#5,schl
	beq.s	NoBtl

	btst	#7,$bfe001
	bne.s	nobtl
	move.l	#5,schl2	
	move	#50,lasercnt
	move.b	#1,laser
nobtl:
	move	powersoll,d1
	move	power,d0
	cmp	d0,d1
	beq.s	mp
	bls.s	minus
	bhi.s	plus
minus:
	subq	#2,power
	bra.s	mp
plus:
	addq	#2,power
mp:
	cmp	#240,power
If	DemoVer
	blo.s	Nothing

	add	#1,Lc
	cmp	#3,Lc
	beq.s	NoN
	bra	NextLevel
NoN:
	bra	explosion
Nothing:
	Else
	bhi	explosion
EndIf
nopower2:
	move	power,d0
	divu	#10,d0
	move	d0,d5

	lea	orgpowercol(pc),a2
	lea	powercol(pc),a3
	lea	powerturm(pc),a0
search:	
	cmp	#$18a,(a0)+
	bne.s	search
	move	(a3),(a0)
	addq.l	#2,a2
	dbra	d0,search
	moveq	#23,d4
	sub	d5,d4
search23:	
	cmp	#$18a,(a0)+
	bne.s	search23
	move	(a2)+,(a0)
	dbra	d4,search23
noblink:
	move.b	$bfec01,d0
	tst.b	d0
	beq	endcheck_key

	cmp.b	#$63,d0
	bne.s	notlauter1
	cmp	#63,vol1
	bhi.s	notlauter1
	addq	#1,vol1
notlauter1:
	cmp.b	#$61,d0
	bne.s	notleiser1
	tst	vol1
	bls.s	notleiser1
	subq	#1,vol1
notleiser1:
	cmp.b	#$7f,d0
	beq	pause

	tst	Cheat
	beq.s	NotPreLevel

	cmp.b	#$35,d0
	bne.s	notnextlevl
	move.b	#1,rightout
notnextlevl:
	cmp.b	#$37,d0
	bne.s	notprelevel
	move.b	#1,leftout
notprelevel:
	cmp.b	#$75,d0
	beq	exit2
endcheck_key:
	lea	$dff000,a4
	move	vol1,$a8(A4)
	move	vol1,$b8(A4)
	move	vol1,$c8(A4)
	move	vol1,$d8(A4)
If	Time
	move	#0,$dff180
EndIf
	bsr	print
	bra	haupt

EndIt:
	move	#copperl4,$dff080
	cmp	#2,endgame
	bne.s	NotFin

	lea	$60000,a1
	move	#11999,d7
clre:
	clr.l	(A1)+
	dbra	d7,clre
	lea	copcol5+6,a1
	move	#$0f0,(A1)
	lea	CongTable,a6
	move.l	#copperl5,$dff080
	move	#$8100,$dff096
RepPr:
	tst.l	(A6)
	beq.s	EndPr

	move.l	(A6)+,a1
	move.l	(A6)+,a0
	bsr	PrintText2
	bra.s	RepPr	
EndPr:
	btst	#6,$bfe001
	bne.s	EndPr
	move	#$100,$dff096
	bra.s	DoHi
NotFin:
	move	#$10,$dff09a
	bsr	dunk
DoHi:
	bsr	DoHiScore	
	move	#$8010,$dff09a	
	bra	exit2		

restorepower:
	clr	power
	clr	powersoll
	lea	powerturm+2,a4
	
	moveq	#22,d7
ser:
	cmp	#$18a,(a4)+
	bne.s	ser
	dbra	d7,ser	
	subq.l	#2,a4

	lea	orgpowercol+48,a5

	moveq	#23,d7
rploop:
	move.l	gfxbase(pc),a6
	jsr	-270(A6)
	jsr	-270(A6)

	move	-(a5),2(a4)
cp1loop:
	cmp	#$18a,-(A4)
	bne.s	cp1loop

	dbra	d7,rploop
	rts

clearpower:
	lea	powerturm+2,a4
	lea	powercol(pc),a5
	moveq	#23,d7
cploop:
	move	(a5)+,(A4)
cp2loop:
	cmp	#$18a,(A4)+	
	bne.s	cp2loop
	dbra	d7,cploop
	rts

DoLives:
	tst	endgame2
	bne.s	correctlives

	move.b	lives,d4
	cmp.b	oldlives,d4
	bne.s	correctlives
	rts	
correctlives:
	move.b	lives,oldlives
	sub.l	d0,d0
	moveq	#5,d7
liv2:	
	sub.l	d1,d1
	bsr	draw_live
	addq	#1,d0
	dbra	d7,liv2

	sub.l	d2,d2
	move.b	lives,d2
	tst.b	d2
	beq.s	endlives
	cmp.b	#-1,d2
	beq.s	endlives

	sub.l	d0,d0
liv4:
	moveq	#1,d1
	bsr	draw_live

	addq	#1,d0
	cmp	#5,d0
	beq.s	endlives	

	cmp	d2,d0
	blo.s	liv4
endlives:
	rts

lplay:
	move	#20,tempo
	clr	tempo2
	clr	playcnt

	lea	pic2col+2,a0
	moveq	#5,d7
fill2:
	move	#$777,(a0)
	add	#4,a0
	dbra	d7,fill2

	bsr	hell
	bsr	restorepower		
	move.l	#copperl,$dff080
lplay2:
	move.l	gfxbase(pc),a6
	jsr	-270(a6)

	lea	pic2col+2,a0
	move.l	a0,a1
	moveq	#5,d7
fill:
	move	#$777,(a0)
	add	#4,a0
	dbra	d7,fill

	add	#1,tempo2
	move	tempo2,d5
	cmp	tempo,d5
	bne.s	not67
	clr	tempo2

	add	#1,playcnt
	cmp	#6,playcnt
	bne.s	not67
	clr	playcnt
not67:
	move	playcnt,d4
	lsl	#2,d4
	add	d4,a1
	move	#$0f0,(a1)
	
	btst	#6,$bfe001
	bne.s	lplay2

	tst	playcnt
	beq.s	endplay
	cmp	#2,playcnt
	beq.s	endplay
	cmp	#4,playcnt
	beq.s	endplay

	add.l	#100,score
	bsr	print
waitplay:
	btst	#6,$bfe001
	beq.s	waitplay

	moveq	#20,d7
verz23:
	move.l	gfxbase(pc),a6
	jsr	-270(a6)
	dbf	d7,verz23

	clr	playcnt
	sub	#5,tempo
	cmp	#5,tempo
	bne	lplay2
endplay:
	bsr	dunk
	rts

Rnd:
	move.b 	$bfe801,d0
	add.b 	$bfd800,d0
	add.b 	$dff008,d0
	add.b 	$dff009,d0
	add.b 	$dff00a,d0
	add.b 	$dff00b,d0
	rts

shapi:
	dc.w	0
DoLoch:
	tst	away
	bne.s	nonew
	tst	lochdir
	bne.s	nonew
	bsr	rnd
	and.b	#$7f,d0
	cmp.b	#4,d0
	bne.s	nonew
	bsr	rnd
	and.b	#3,d0
	tst.b	d0
	bne.s	nonew
	move	#1,lochdir
nonew:
	cmp	#10,lochcnt
	bne	draw_loch		

	clr.l	d0
	bsr	rnd
	and	#$f,d0
	lsl	#2,d0			
	lea	bahnen_tabelle(pc),a1
	move.l	(a1,d0.w),bahn
	lea	bahnen_tabelle2(pc),a1
	move.l	(A1,d0.w),a1		; Zeiger auf moegl. Spr

	tst.b	battle
	beq	NoBtl3
	lea	Sp5,a1
	bra.s	GotIt
NoBtl3:
	bsr	rnd
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
	move	(A1)+,speed
	move.l	A1,shape
	move.l	A1,pshap
	move	#1,shapi

	move	yhoehe,d3
	add	d5,d3

	lea	fspr2,a1
	move.b	d5,(A1)
	move.b	d3,2(A1)
	move.b	d4,1(A1)	
	move	#1,away
	clr	f2cnt
draw_loch:
	move.l	Gfxbase,a6
	jsr	-456(A6)
	move	lochdir,d0
	tst	d0
	beq	endloch
	add	d0,lochcnt

	cmp	#10,lochcnt
	bne.s	noth
	move	#-1,lochdir
noth:
	tst	lochcnt
	bne.s	notl
	clr	lochdir
notl:
	move	lochcnt,d0
	mulu	#40*8,d0

	lea	$dff000,a5
	move.l	screen2,a0
	add.l	#1714,a0		
	add.l	d0,a0

	move.l	screen1,a2
	add.l	#13,a2			

	moveq	#4,d7
paintit:
	btst	#14,2(A5)
	bne.s	paintit

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
	dbra	d7,paintit
endloch:
	jsr	-462(A6)
	rts

which:
	dc.w	0
DoLaser:
	clr	which
	tst.b	laser
	beq	nolaser
	tst.b	battle
	bne.s	nbtl2
	move.l	#5,schl
nbtl2:
	tst.b	battle
	beq.s	nbtl3

	cmp.l	#5,schl2
	bne.s	nbtl3
	btst	#7,$bfe001
	bne.s	nbtl3
	move	#2,which
	bra.s	dlaser
nbtl3:
	cmp.l	#5,schl
	bne	nolaser
	btst	#6,$bfe001
	bne	nolaser
	move	#1,which
dlaser:
	lea	shoot1(pc),a1
	tst.b	(a1)
	bne	nolaser

	lea	$dff000,a5
	move	#8,$96(A5)
	move.l	#schuss,$d0(A5)
	move	#3992,$d4(A5)
	move	#180,$d6(A5)
	move	#13,SoundCNT4
	move	#$8008,$96(A5)

	move.b	#224,(A1)
	move.b	#229,2(A1)
	add	#5,powersoll

	cmp	#2,which
	bne.s	pl1
	move	mousx2,d5
	bra.s	pl2
pl1:
	move	mousx,d5
pl2:
	lsr	#1,d5
	add.b	#84,d5
	move.b	d5,1(a1)
nolaser:
	rts

do_schl:
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
weiterschl:
	addq.b #1,excounter2
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
addschl2:
	add.l #1,schl2
	cmp.l #4,schl2
	bls.s weiterschl2
	clr.l extend2
	move.l #4,schl2
weiterschl2:
	rts

Do_Blitz:
	tst.b	level
	beq.s	npl34
	clr.l	d0
	bra.s	nolevel2
npl34:
	sub	#1,lcnt
	move	lcnt,d0
	tst	d0
	bpl.s	nolevel2
	move	#32,lcnt
nolevel2:
	move.l	screen2,a0		
	add.l	#1722,a0

	move.l	screen2,a1		
	add.l	#5278,a1
	mulu	#40,d0
	add.l	d0,a1

	move.l	screen1,a2		
	add.l	#7026,a2

	lea	$dff000,a6
	moveq	#4,d7
drawit1:
	btst	#14,2(A6)
	bne.s	drawit1

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
	dbra	d7,drawit1

	moveq	#15,d7
cl:
	clr.b	(a2)
	add.l	#40,a2
	dbra	d7,cl

	move.l	screen2,a0		
	add.l	#1720,a0

	move.l	screen2,a1		
	add.l	#5276,a1
	add.l	d0,a1

	move.l	screen1,a2		
	add.l	#7002+40,a2

	moveq	#4,d7
drawit2:
	btst	#14,2(A6)
	bne.s	drawit2

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
	dbra	d7,drawit2
	rts

	ballb=6
	ballh=6

SoundCNT1:
	dc.w	0
SoundCNT2:
	dc.w	0
SoundCNT3:
	dc.w	0
SoundCNT4:
	dc.w	0

Soundi:
	tst	SoundCNT1
	bne.s	NotS11
	move	#1,$dff096		; Kanal 1 off
	bra.s	NS1
NotS11:
	subq	#1,SoundCNT1
NS1:
	tst	SoundCNT2
	bne.s	NotS21
	move	#2,$dff096		; Kanal 1 off
	bra.s	NS2
NotS21:
	subq	#1,SoundCNT2
NS2:
	tst	SoundCNT3
	bne.s	NotS31
	move	#4,$dff096		; Kanal 1 off
	bra.s	NS3
NotS31:
	subq	#1,SoundCNT3
NS3:
	tst	SoundCNT4
	bne.s	NotS41
	move	#$8,$dff096		; Kanal 1 off
	rts
NotS41:
	subq	#1,SoundCNT4
	rts

MoveSpr:
	tst	slow
	beq.s	okslow
	add	#1,slowcnt
	cmp	#2,slowcnt
	bne.s	endmov
	clr	slowcnt
okslow:
	bsr	moveto
endmov:
	rts

moveto:
	move.l	#sprite1,sprite
	move.l	#spr1,spr
	bsr	movespr2

	tst.b	twoball
	bne.s	twobal
	rts
twobal:
	move.l	#sprite2,sprite
	move.l	#spr2,spr
	bsr	movespr2
	rts

	dc.w	$4e71,$4e71
	dc.w	$6021,$0ef0
movespr2:
	tst	kept2
	beq.s	move2
	rts
ch:
	dc.w	$4ef9

move2:
	sub.l	d1,d1
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
up1:
	tst.b	d3
	bmi.L	up2

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
	bsr	checkblock
	move.b	d4,7(A1)
	add	d3,x
	move	x,d5
	move	y,d6
	add	#ballh/2,d6
	add	#ballb,d5	
	tst.b	changed
	bne.s	up11

	move.b	6(A1),d4
	bsr	checkblock
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
	bsr	checkblock
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
	bsr	checkblock
	move.b	d4,6(A1)
up21:
	movem.l	(sp)+,d0-d7
	move	x,d1
	move	y,d2
	bra	testit
up3:
	tst.b	d3
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
	bsr	checkblock
	move.b	d4,7(A1)

	move	x,d5
	add	d3,d5
	add	d3,x
	tst.b	changed
	bne.s	up31

	move	y,d6
	add	#ballh/2,d6
	move.b	6(A1),d4
	bsr	checkblock
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
	bsr	checkblock
	move.b	d4,7(A1)

	move	x,d5
	add	d3,d5
	add	d3,x
	tst.b	changed
	bne.s	up41

	move	y,d6
	add	#ballh/2,d6

	move.b	6(A1),d4
	bsr	checkblock
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
	bhi.s	notadd
	tst.b	changed
	beq.s	notadd
	cmp	#1,ch
	bne.s	notch1

	bsr	rnd
	btst	#0,d0
	beq.s	notch1
	addq	#1,d1
notch1:
	cmp	#2,ch
	bne.s	notch2
	cmp	#79,d1
	blo	notch2

	bsr	rnd
	btst	#0,d0
	beq.s	notch2
	subq	#1,d2
notch2:
	cmp	#3,ch
	bne.s	notch3
	cmp	#150,d1
	bhi.s	notch3

	bsr	rnd
	btst	#0,d0
	beq.s	notch3
	addq	#1,d1
notch3:
	cmp	#4,ch
	bne.s	notch4
	cmp	#180,d2
	bhi.s	notch4

	bsr	rnd
	btst	#0,d0
	bne.s	notch4
	addq	#1,d2
notch4:
notadd:
	cmp.b	#79,d1
	bhi.s	notleft
	tst.b	6(A1)
	bpl.s	notleft
	neg.b	6(A1)
	bsr	soundon2
	bra.s	notright
notleft:
	cmp.b	#159,d1
	blo.s	notright		
	tst.b	6(A1)
	bmi.s	notright
	neg.b	6(A1)
	bsr	soundon2
notright:	
	tst.b	7(A1)
	bpl	notoben

	cmp.b	#53,d2
	bhi.s	notoben
	neg.b	7(A1)
	bsr	soundon2
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

int:
	movem.l d0-d7/a0-a6,-(sp)
	btst	#4,$dff01f
	beq	endint
	btst	#5,$dff01f
	bne	endint

	If	Final
	move.l	4,a1
	addq.l	#1,82(A1)
	addq.l	#1,36(A1)
	EndIf

	IF	TIME
	move	#$00f,$dff180
	ENDIF

	cmp.b	#$75,$bfec01
	bne.s	NoExi
	move	#1,EndGame
NoExi:
	tst	EndGame
	bne.s	NotRP

	tst.b	paused
	bne.s	endint2

	bsr	Mousehandler
	bsr	Draw_Schl
	bsr	Flash
	bsr	DoLaser
	bsr	Do_Schl
	bsr	MoveSpr
	bsr	CheckColl
endint2:
	cmp.b	#2,paused
	beq.s	notrp
	bsr	MoveShoot
	cmp.b	#3,paused
	beq.s	notrp
	bsr	MoveFSpr	
	bsr	MoveF2Spr
	bsr	DoLoch

	cmp.b	#4,paused
	beq.s	notrp
	bsr	Do_Blitz
NotRP:
	bsr	DoLives
	bsr	ColorCycle1
	bsr	Soundi
endint:
	if	TIME
	clr	$dff180
	EndIF
	move	#$10,$dff09c
	movem.l (sp)+,d0-d7/a0-a6
	dc.w	$4ef9
intvek:
	dc.l	0

CheckColl:
	move	$dff00e,d0
	btst	#9,d0
	beq.s	NoSprColl
	bsr	Zitter
	bsr	SoundOn4
	lea	FSpr2,a1
	clr.l	(A1)
	clr	away
NoSprColl:
	rts

PreLevel:
	move.b	#1,paused
	clr.b	plevel
	tst.l	stufe2
	bne.s	endprelevel
	add.l	#190,stufe2
endprelevel:
	sub.l	#380,stufe2
NextLevel:	
	move.b	#1,paused
	btst	#6,$bfe001
	beq.s	nextlevel
	move.l	oldvek,$6c

	lea	$dff000,a5
	move	#$f,$96(A5)

	move.l	gfxbase,a6
	jsr	-270(A6)

	move.l	#harve+2000,$a0(A5)
	move	#12489,$a4(A5)
	move	#180,$a6(A5)
	move.l	#harve,$b0(A5)
	move	#13489,$b4(A5)
	move	#180,$b6(A5)
	move.l	#harve,$c0(A5)
	move	#13489,$c4(A5)
	move	#180,$c6(A5)
	move.l	#harve+2000,$d0(A5)
	move	#12489,$d4(A5)
	move	#180,$d6(A5)
	move	#$800f,$96(A5)

	clr	away
	bsr	clearflash
	clr.b	nlevel

	bsr	ClearSpr
	lea	spr1(pc),a1
	lea	spr2(pc),a2
	clr.b	4(a1)
	clr.b	4(a2)	

If	DemoVer
	lsl.l	#1,d5
Else	
	tst.b	CCN
	beq.s	NoZGame
EndIf
	clr	Lgame	
	addq	#1,LGameCnt
If	demover
	cmp	#2,LGameCnt
Else
	cmp	#3,LGameCnt
EndIf
	bne.s	NoZGame			

	clr	LGameCnt
	move	#1,Lgame

	move	#2,command
	move.l	#bobs2,ziel
	move.l	#512*96,laenge
	move.l	#512*627,offset
	bsr	StartTask
	bra.s	Repeat2
NoZGame:
	move	#4,command
	bsr	starttask
Repeat2:
	lea	$dff000,a5
	move.l	#leer,$a0(A5)
	move	#2,$a4(A5)
	move.l	#leer,$b0(A5)
	move	#2,$b4(A5)
	move.l	#leer,$c0(A5)
	move	#2,$c4(A5)
	move.l	#leer,$d0(A5)
	move	#2,$d4(A5)
Repeat:
	move.l	gfxbase(pc),a6
	jsr	-270(a6)
sdf1:	
	addq	#2,power
	addq.l	#1,score
	cmp	#230,power
	bhi.s	sdf3

	move	power,d0
	divu	#10,d0
sdf2:
	lea	powerturm(pc),a0
	lea	powercol(pc),a3
sdf:
	cmp	#$18a,(a0)+
	bne.s	sdf
	move	(a3)+,(a0)
	dbra	d0,sdf
	bsr	Print
	bra	Repeat
sdf3:
	bsr	Dunk
;	move	#$120,$dff180

	add.l	#190,stufe2
	cmp.l	#6080,stufe2
	bne.s	c5
	move	#2,EndGame
	bra	haupt
c5:
	tst	LGame
	beq	NoZGame2

	clr	lgame
	move	#$10,$dff09a
	bsr	CCNut
	move.l	oldvek,$6c
	move	NutCounter,d0
	tst	d0
	beq	EndCCNCNT
	mulu	#25,d0
	move.l	d0,-(sp)

	bsr	Clear
	lea	$60dbf,a1
	lea	Mesg,a0
	bsr	printtext2
	lea	CopCol5+6,a1
	move	#$ff0,(A1)
	move.l	#copperl5,$dff080
	move	#$8103,$dff096

	move.l	(sp)+,d4
	move	#400,spe
	move	#1,lochcnt2
CountIt:
	move.l	gfxbase,a6
	jsr	-270(a6)

	move.l	score,d3
	moveq	#4,d6
	lea	ScoreAsc+6,a3
RepCI:
	divu	#10,d3
	swap	d3
	add.b	#'0',d3
	move.b	d3,-(A3)	
	clr	d3
	swap	d3
	dbra	d6,RepCI

	lea	ScoreAsc,a0
	lea	$61279,a1
	bsr	printtext2

	addq.l	#5,score
	move.l	score,d0
	bsr	AddLives

	add	#1,LochCNT2
	cmp	#4,LochCNT2
	bne.s	NoDec
	clr	LochCNT2
	subq	#1,spe
NoDec:
	lea	$dff000,a5
	move.l	#ScoreSound,$a0(A5)
	move	#1313,$a4(A5)
	move	spe,$a6(A5)
	move.l	#ScoreSound+500,$b0(A5)
	move	#1063,$b4(A5)
	move	spe,$b6(A5)

	subq.l	#1,d4
	tst.l	d4
	bhi	CountIt
EndCCNCNT:
	clr	$a8(A5)
	clr	$b8(A5)

	clr	LGame
	move	#$8010,$9a(a5)
	move	#$103,$96(a5)
	moveq	#30,d7
Ver:
	jsr	-270(A6)
	dbra	d7,Ver

	move.l	#copperl4,$dff080
	bsr	Clear
	bsr	LoadScr
	bsr	LoadStage
	moveq	#50,d7
	move.l	gfxbase,a6
pleasewait:
	jsr	-270(A6)
	dbra	d7,pleasewait
NoZGame2:
	move.l	#copperl4,$dff080
	bsr	Wait_Load
	move	#6,command
	bsr	StartTask
	bsr	Wait_Load
	bsr	CopyPic

	bsr	ClearBonus
	move.l	#4,schl
	move.l	#4,schl2
	lea	shoot1(pc),a5
	clr.b	(a5)
	move.b	#3,2(A5)
	lea	sprite2(pc),a5
	clr.b	1(a5)
	
	move.b	#1,alter
	clr.b	falling
	lea	fspr1(pc),a3
	clr.b	1(a3)
	clr	mousx
	bsr	BuilDlevel
	bsr	Print
	bsr	ClrShadow
	bsr	ShadowAll
	move.l	#Int,$6c
	move.l	#copperl2,$dff080
	move	#$8100,$dff096
	bsr	Hell
	move.l	#Copperl,$dff080
	bsr	RestorePower
EndNextLevel:
	bra	Haupt2

schl:
	dc.l 4
schl2:
	dc.l 4
dunk:
	lea	coppercol2(pc),a4
	lea	coppercol(pc),a3
	moveq	#31,d7
copycopper:
	move.l	(A3)+,(a4)+
	dbra	d7,copycopper

	move.l	#copperl2,$dff080
	moveq	#15,d5
dunkel:
	move.l	gfxbase(pc),a6
	jsr	-270(A6)

	lea	coppercol2+2(pc),a3
	moveq	#31,d6
dunkel2:
	move.b	1(a3),d4
	and.b	#$0f,d4
	tst.b	d4
	beq.s	okd1
	sub	#$0001,(a3)
okd1:
	move.b	1(a3),d4
	and.b	#$f0,d4
	tst.b	d4
	beq.s	okd2
	sub	#$0010,(a3)
okd2:
	move.b	(a3),d4
	and.b	#$0f,d4
	tst.b	d4
	beq.s	okd3
	sub	#$0100,(a3)
okd3:
	addq	#4,a3
	dbra	d6,dunkel2
	dbra	d5,dunkel
	move	#$120,$dff096
	move.l	#copperl4,$dff080
	rts

hell:
	lea	coppercol+58(pc),a4
	move	#$aab,(a4)
	move	#$950,4(A4)

	moveq	#15,d5
heller:
	move.l	gfxbase(pc),a6
	jsr	-270(A6)

	lea	coppercol+2(pc),a4
	lea	coppercol2+2(pc),a3
	moveq	#31,d6
heller2:
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
	dbra	d6,heller2
	dbra	d5,heller
	rts
exit2:
exit:
	move	#$000f,$dff096		
	move.l	oldvek,$6c		
	rts
count:
	dc.w	0

ColorCycle1:
	lea	cycle1+2(pc),a0
	lea	cyclelist1(pc),a1

	tst	c1cnt
	bne.s	notc0
	move	#178,c1cnt
notc0:
	sub	#2,c1cnt
	add	c1cnt,a1
	move	#8,d6
notc01:
	move	(a1)+,(a0)
notc02:
	cmp	#$18a,(a0)+
	bne.s	notc02
	cmp.l	#endclist1,a1
	bls.s	snext1
	lea	cyclelist1(pc),a1
snext1:
	dbra	d6,notc01

	lea	cycle2+2(pc),a0
	lea	cyclelist2(pc),a1
	tst	c2cnt
	bne.s	notc1
	move	#182,c2cnt
notc1:
	subq	#2,c2cnt
	add	c2cnt,a1
	moveq	#22,d6
notc11:
	move	(a1)+,(a0)
notc22:
	cmp	#$1be,(a0)+
	bne.s	notc22

	cmp.l	#endclist2,a1
	bls.s	snext2
	lea	cyclelist2(pc),a1
snext2:
	dbra	d6,notc11
	rts

cyclelist1:
	dc.w $f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70
	dc.w $f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0
	dc.w $ef0,$df0,$cf0,$bf0,$af0,$9f0,$8f0,$7f0
	dc.w $6f0,$5f0,$4f0,$3f0,$2f0,$1f0,$0f0,$0f1
	dc.w $0f2,$0f3,$0f4,$0f4,$0f5,$0f6,$0f7,$0f8
	dc.w $0f9,$0fa,$0fb,$0fc,$0fc,$0fd,$0fe,$0ff
	dc.w $0ef,$0df,$0cf,$0bf,$0af,$09f,$08f,$07f
	dc.w $06f,$05f,$04f,$03f,$02f,$01f,$00f,$10f
	dc.w $20f,$30f,$40f,$50f,$60f,$70f,$80f,$90f
	dc.w $a0f,$b0f,$c0f,$d0f,$e0f,$f0f,$f0e,$f0d
	dc.w $f0c,$f0b,$f0a,$f09,$f08,$f07,$f06,$f05
	dc.w $f04,$f03,$f02,$f01

;	dc.w $ff0,$ff0,$fe0,$fd0,$fc0,$fb0,$fa0,$f90
;	dc.w $f80,$f70,$f60,$f50,$f40,$f30,$f20,$f10
endclist1:
cyclelist2:
	dc.w $f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80,$f90
	dc.w $fa0,$fb0,$fc0,$fd0,$fe0,$ff0,$ff0,$ef0,$df0,$cf0
	dc.w $bf0,$af0,$9f0,$8f0,$7f0,$6f0,$5f0,$4f0,$3f0,$2f0
	dc.w $1f0,$0f0,$0f1,$0f2,$0f3,$0f4,$0f5,$0f6,$0f7,$0f8
	dc.w $0f9,$0fa,$0fb,$0fc,$0fd,$0fe,$0ff,$0ef,$0df,$0cf
	dc.w $0bf,$0af,$09f,$08f,$07f,$06f,$05f,$04f,$03f,$02f
	dc.w $01f,$00f,$10f,$20f,$30f,$40f,$50f,$60f,$70f,$80f
	dc.w $90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f,$f0e,$f0d,$f0c
	dc.w $f0b,$f0a,$f09,$f08,$f07,$f06,$f05,$f04,$f03,$f02
	dc.w $f01
endclist2:
	dc.w $f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80,$f90

pausetext:
	dc.b 'GAME PAUSED',0

pause:
	move.b	#2,paused
	cmp.b	#$7f,$bfec01
	beq.s	pause

	move.l	#buffer,a2
	move.l	screen1,a1
	add.l	#6010,a1

	moveq	#9,d7
copy11:
	moveq	#19,d6			
copy12:		
	move.b	(A1),(a2)+
	move.b	8000(A1),(A2)+
	move.b	16000(A1),(A2)+
	move.b	24000(A1),(A2)+
	move.b	32000(A1),(A2)+
	addq	#1,a1

	dbra	d6,copy12
	add.l	#20,a1
	dbra	d7,copy11

	lea	pausetext(pc),a0
	move.l	screen1,a1
	add.l	#6010,a1
	bsr	printtext
pause2:
	btst	#6,$bfe001
	beq.s	pause3
	btst	#7,$bfe001
	beq.s	pause3

	cmp.b	#$7f,$bfec01
	bne.s	pause2
pause3:
	cmp.b	#$7f,$bfec01
	beq.s	pause3

	move.l	#buffer,a2		
	move.l	screen1,a1		
	add.l	#6010,a1

	moveq	#9,d7			
copy21:
	moveq	#19,d6			
copy22:		
	move.b	(A2)+,(A1)
	move.b	(A2)+,8000(A1)
	move.b	(A2)+,16000(A1)
	move.b	(A2)+,24000(A1)
	move.b	(A2)+,32000(A1)
	addq	#1,a1

	dbra	d6,copy22
	add.l	#20,a1
	dbra	d7,copy21

	clr.b	paused
	bra	haupt

Xpos:
	dc.w	0

Wait_Start:
	move.b	#3,paused
	move	#1,kept2
	bsr	ClearSpr
	bsr	ClearBonus
	clr	waiter
	clr	BattleTime
	clr	away
	bsr	FlashAll
	bsr	ClearFlash

	neg.b	kept
	clr	mousx
	clr	imgx
	clr	lasercnt
	move.l	#4,schl
	move.l	#4,schl2

	move	#61,mousx2
	move	#124,imgx2

	lea	sprite1(pc),a1
	move.b	#218,(a1)
	move.b	#225,2(a1)
	move.b	#80,1(a1)
	
	lea	spr1(pc),a2
	move.b	#218,5(a2)

	move.b	#80,4(a2)
	move.b	#1,6(A2)
	move.b	#-3,7(a2)

	bsr	print
	bsr	rnd
	and	#$003f,d0
	move	d0,demornd
wait_start2:
	move.l	gfxbase(pc),a6
	jsr	-270(a6)
	tst.b	demo
	beq.s	w3
WaSt:
	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#$e000,d0
	bne.s	WaSt

	move	demornd,d4
	cmp	waiter,d4
	bne.s	w3
	bra	endwait23
w3:
	bsr	mousehandler
	tst.b	twoplayer
	beq	take2

	tst.b	kept
	bmi.s	take2	
	move	mousx2,xpos
	move.b	$bfe001,d5
	bset	#6,d5
	bra.s	takeit	
take2:
	move.b	$bfe001,d5
	bset	#7,d5
	move	mousx,xpos
takeit:
	btst	#6,d5
	beq	endwait23
	btst	#7,d5
	beq	endwait23

	move	xpos,d0
	move.l	schl,d1
	bsr	draw_schl

	clr.l	d0
	move	xpos,d0
	move.b	d0,d2
	lsr.b	#1,d2
	add.b	#82,d2

	lea	sprite1(pc),a1
	lea	spr1(pc),a2
	move.b	d2,1(a1)	
	move.b	d2,4(a2)

	addq	#1,waiter
	cmp	#250,waiter
	bhi.s	endwait23	
	bra.L	wait_start2
endwait23:
	btst	#6,$bfe001
	beq.s	endwait23
	btst	#7,$bfe001
	beq.s	endwait23

	clr	kept2
	clr.b	paused
	rts

Wait_Ball:
	move.b	#1,paused
	clr	waiter
	clr	waitb

	lea	sprite1(pc),a1
	lea	spr1(pc),a2
	move	mousx,d4
	lsr	#1,d4
	move.b	1(a1),d3
	sub.b	d3,d4
wait_ball2:
	move.l	gfxbase(pc),a6
	jsr	-270(a6)
WaS2:
	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#$e800,d0
	bne.s	WaS2

	lea	sprite1(pc),a1
	tst.b	alter
	bne.L	endwaitball

	tst.b	twoplayer
	beq	take22

	tst.b	kept
	bmi.s	take22			
	move	mousx2,xpos
	move.b	$bfe001,d5
	bset	#6,d5
	bra.s	takeit2	
take22:
	move.b	$bfe001,d5
	bset	#7,d5
	move	mousx,xpos
takeit2:
	btst	#7,d5
	beq.s	endwaitball
	btst	#6,d5
	beq.s	endwaitball

	lea	sprite1(pc),a1
	lea	spr1(pc),a2
	move.b	d2,1(a1)	
	move.b	d2,4(a2)

	bsr	mousehandler

	clr.l	d0
	move	xpos,d0
	move.b	d0,d2
	lsr.b	#1,d2
	add.b	#82,d2
	lea	spr1(pc),a2
	move.b	d2,1(A1)	
	move.b	d2,4(a2)

	bsr	draw_schl

	add	#1,waiter
	cmp	#250,waiter
	bhi.s	endwaitball
	bra	wait_ball2
endwaitball:
	btst	#6,$bfe001
	beq.s	endwaitball
	btst	#7,$bfe001
	beq.s	endwaitball
	clr	BattleTime
	clr	kept2
	clr.b	paused
	bra	haupt

buildlevel:
	move	#$20,$dff096
	bsr	htoz
	bsr	initblockcolors
	lea	zspeicher+190(pc),a0
buildlevel2:
	moveq	#15,d2
verti:
	moveq	#10,d1
horiz:
	clr.l	d0
	move.b	-(a0),d0
	and.b	#31,d0
	bsr	draw_block
	dbra	d1,horiz
	dbra	d2,verti
	move	#1,endgame2
	bsr	dolives
	clr	endgame2
	rts

clear:
	lea	$42000,a0
	move	#$c000,d7
cloop:
	clr.l	(a0)+
	dbra	d7,cloop
	rts

CopyPic:
	lea	buffer,a0
	move.l	screen3,a1
	move.l	#25284,d4
	bsr	decruncher
cc:
	move.l	screen3,a1
	add.l	#28,a1
	moveq	#1,d7			
doshad:
	moveq	#10,d6			
doshad2:
	clr	(A1)
	clr	5044(A1)
	clr	10088(A1)
	clr	15132(A1)
	clr	20176(A1)
	addq.l	#2,a1
	dbra	d6,doshad2
	addq.l	#4,a1
	dbra	d7,doshad		
	move.l	screen3,a1
	addq.l	#2,a1
	move.b	#%10011111,d3
	move	#193,d7
doshad3:
	and.b	d3,(A1)
	and.b	d3,5044(A1)
	and.b	d3,10088(A1)
	and.b	d3,15132(A1)
	and.b	d3,20176(A1)
	add.l	#26,a1
	dbra	d7,doshad3		
	
	move.l	screen3,a1
	add.l	#25220,a1
	lea	coppercol+2(pc),a2
	moveq	#7,d6
writecols:
	move	(a1),(a2)
	clr	(a1)+
	addq.l	#4,a2
	dbra	d6,writecols	

	add.l	#16,a1
	add.l	#32,a2
	moveq	#14,d6
wrcol2:
	move	(A1),(a2)
	clr	(A1)+
	addq.l	#4,a2
	dbra	d6,wrcol2

	move.l	screen3,a2
	move.l	screen1,a1
	add.l	#242,a1

	moveq	#4,d4
zloop:
	move	#193,d5
yloop:
	moveq	#12,d6
xloop:
	move	(a2)+,(a1)+
	dbra	d6,xloop
	add.l	#14,a1
	dbra	d5,yloop
	add.l	#240,a1
	dbra	d4,zloop
	clr	loaded
	rts

LoadHiScore:
	move	#2,command
	move.l	#hilist,ziel
	move.l	#diskscore,offset
	move.l	#$600,laenge
	bsr	starttask
	bsr	wait_load
	lea	hilist+8,a1
	move.l	(A1),hiscore
	rts

Codier:
	lea	hilist+1300,a1
	move.b	(A1),d6
	move	#1280,d7
Coder:
	eor.b	d6,(A1)+
	dbra	d7,Coder
	rts

LoadScr:
	move	#2,command
	move.l	#512*1627,offset
	move.l	#$20000,ziel
	move.l	#512*132,laenge
	bsr	StartTask
	bsr	Wait_Load		; Sound
	cmp.l	#$88ae9c9c,Summ
	bne.s	LoadScr
LoadErr1:
	move	#2,command
	move.l	#datadisk,offset
	move.l	#bahn1,ziel
	move.l	#512*10,laenge
	bsr	StartTask
	bsr	Wait_Load		; Flugdaten
	cmp.l	#$ec4b8514,Summ
	bne.s	LoadErr1
LoadErr2:
	move	#2,command
	move.l	#buffer,ziel
	move.l	#36*512,laenge
	move.l	#rahmenc,offset
	bsr	starttask
	bsr	wait_load		; Rahmen
	cmp.l	#$7caeb5d4,Summ
	bne.s	LoadErr2

	move.l	#buffer,a0
	move.l	screen1,a1
	move.l	#40000,d4
	bsr	decruncher
LoadErr3:
	move	#2,command
	move.l	#buffer,ziel
	move.l	#50*512,laenge
	move.l	#backgroundc,offset
	bsr	starttask		; hintergrund
	bsr	wait_load
	cmp.l	#$483f65f8,Summ
	bne.s	LoadErr3

	move.l	laenge1,d4
	move.l	#buffer,a0
	move.l	screen2,a1
	bsr	decruncher

	move	#4,command
	bsr	starttask
	bsr	wait_load		; Bild	
	bsr	copypic
	rts

zitter:
	clr.l d2
	move $dff006,d2
	and #7,d2
	lsl #1,d2
	lea shake_table(pc),a3
	add.l d2,a3
	lea spr1(pc),a1
	move.b (a3)+,6(a1)
	move.b (a3),7(a1)
	lea spr2(pc),a2
	move $dff006,d2
	and #7,d2
	lsl #1,d2
	lea shake_table(pc),a3
	add.l d2,a3
	move.b (a3)+,6(a2)
	move.b (a3),7(a2)
	rts

ChkSchl:
	move	dist,d2
	tst	d2
	bpl.s	ck1
	neg	d2
ck1:
	move	mousx,d0
	cmp	#1,d0
	bne.s	ck2
	cmp	#10,d2
	bls.s	ck2
	bsr	zitter
ck2:
	clr.l	d1
	move	schl,d1
	lsl	#1,d1
	lea	tabelle(pc),a4
	move	(a4,d1.l),d1	
	add.l	#10,d1
	cmpi	d1,d0
	bne.s	ck3
	cmpi	#10,d2
	bls.s	ck3
	bsr	zitter
ck3:
	rts

shake_table:
	dc.b 1,-1
	dc.b -1,-3
	dc.b 1,-2
	dc.b -1,-3
	dc.b -1,-1
	dc.b -1,-2
	dc.b 1,-2
	dc.b 1,-1

;del_shoot:
	lea	shoot1(pc),a2
dsloop1:
	clr.b	(a2)
	move.b	#3,2(A2)

printtext:
	clr.l	d0
	move.b	(a0)+,d0
	tst.b	d0
	beq.s	endpt
	bsr	printletter
	bra.s	printtext
endpt:
	rts

printtext2:
	clr.l	d0
	move.b	(a0)+,d0
	tst.b	d0
	beq.s	endpt
	bsr	printletter2
	bra.s	printtext2
endpt2:
	rts

printletter:
	move.l	a1,a3
	sub.b	#' ',d0
	mulu	#10,d0
	lea	font(pc),a2
	add.l	d0,a2
	moveq	#9,d7
asc:
	move.b	(A2)+,d2
	or.b	d2,(a3)
	or.b	d2,8000(a3)
	or.b	d2,16000(a3)
	or.b	d2,24000(a3)
	or.b	d2,32000(a3)
	add.l	#40,a3
 	dbra	d7,asc
	addq.l	#1,a1
	rts

printletter2:
	move.l	a1,a3
	sub.b	#' ',d0
	mulu	#10,d0
	lea	font(pc),a2
	add.l	d0,a2
	moveq	#9,d7
asc2:
	move.b	(A2)+,(a3)
	add.l	#48,a3
 	dbra	d7,asc2
	addq.l	#1,a1
	rts

AddLives:
	move.l	score,d0
	lea	shiptable(pc),a3
	add.l	stc,a3
	move.l	(A3),d2
	cmp.l	d0,d2
	bhi.s	nolives2

	add.b	#1,lives
	add.l	#4,stc
nolives2:
	rts

print:
	move.l	score,d0
	bsr	GetPosition
	move.l	d0,place
	cmp	#1,d0
	bne.s	notfirst
	clr.l	points
	bra.s	printit2
notfirst:
	tst.l	d0
	bne.s	notzero2
	move.l	#max_entry,d0
notzero2:
	lea	hilist+8(pc),a1
	subq	#2,d0
	mulu	#12,d0
	add.l	d0,a1

	move.l	(A1),d2
	sub.l	score,d2
	move.l	d2,points		
printit2:
	move.l	score(pc),d0
	move.l	hiscore(pc),d1
	cmp.l	d1,d0
	blo.s	notmore
	move.l	score,hiscore
notmore:
	tst.b	demo
	bne.s	nolives	
	move.l	score(pc),d0
	bsr	AddLives
nolives:
	move.l	screen1,a2
	add.l	#1876,a2
	move.l	a2,a0
	lea	font+160(pc),a1
	bsr	wletter
	subq	#1,a2	
	move.l	points,d0
	moveq	#5,d6
	bsr	printcount		

	move.l	screen1,a2
	add.l	#5516+40,a2
	move.l	a2,a0
	lea	font+160(pc),a1
	bsr	wletter
	subq	#1,a2	

	clr.l	d0
	move.l	score,d0
	moveq	#5,d6
	bsr	printcount	
	
	move.l	screen1,a2
	add.l	#7396,a2
	move.l	a2,a0
	lea	font+160(pc),a1
	bsr	wletter
	subq	#1,a2	
	move.l	hiscore,d0
	moveq	#5,d6
	bsr	printcount	

	move.l	screen1,a2
	add.l	#3711,a2
	move.l	stufe2,d0
	divu	#190,d0
	addq	#1,d0
	moveq	#1,d6
	bsr	printcount		

	move.l	screen1,a2
	add.l	#3717,a2
	move.l	place,d0
	moveq	#1,d6
	bsr	printcount		
	rts

printcount:
	move.l	a2,a0
	lea	font(pc),a1
ploop2:
	move.l	a2,a0
	divu	#10,d0
	swap	d0
	move	d0,d1
	clr	d0
	swap	d0
	add	#16,d1
	mulu	#10,d1
	lea	font(pc),a1
	add.l	d1,a1
	bsr	wletter
	subq	#1,a2
	dbra	d6,ploop2
	rts

wletter:
	moveq #9,d5
writeletter:
	move.b	(a1),(a0)
	move.b	(a1),8000(a0)
	move.b	(a1),16000(a0)
	move.b	(a1),24000(a0)
	move.b	(a1)+,32000(a0)
	add.l	#40,a0
	dbra	d5,writeletter
	rts

MoveShoot:
	lea	shoot1(pc),a4
	tst.b	(a4)
	bne.s	okshoot
	rts
OkShoot:
	sub.b	#6,(a4)
 	sub.b	#6,2(a4)
	cmp.b	#54,(a4)
	blo	zeroit

	lea	shoot1(pc),a1
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

	lea	shoot1(pc),a1
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
zeroit:
	lea	shoot1,a1
	clr	(a1)
	move.b	#4,2(a1)
	rts


bahnen_tabelle:
	dc.l	bahn1
	dc.l	bahn2
	dc.l	bahn3
	dc.l	bahn4
	dc.l	bahn5
	dc.l	bahn6
	dc.l	bahn7
	dc.l	bahn8
	dc.l	bahn9
	dc.l	bahn10
	dc.l	bahn10
	dc.l	bahn10
	dc.l	bahn4
	dc.l	bahn9
	dc.l	bahn6
	dc.l	bahn8

bahnen_tabelle2:
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
sp5:
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
speed:
	dc.w	0
ytest1:
	dc.w	0
ytest2:
	dc.w	0
yhoehe:
	dc.w	0
shape:
	dc.l	0
pshap:
	dc.l	0
oldshap:
	dc.l	-1
Kugel:
	dc.w $0000,$0700
	dc.w $0000,$1FC0
	dc.w $0C00,$33E0
	dc.w $1C00,$23E0
	dc.w $1800,$67F0
	dc.w $0000,$7FF0
	dc.w $0000,$7FF0
	dc.w $0000,$3FE0
	dc.w $0000,$3FE0
	dc.w $0000,$1FC0
	dc.w $0000,$0700
	dc.l 0
ShapCNT:
	dc.w	0
movef2spr:
	lea	fspr3(pc),a1
	tst.b	(a1)
	beq	nmoveb
	add.b	#2,(A1)
	add.b	#2,2(A1)
	cmp.b	#253,(A1)
	bls.s	nmoveb
	clr.l	(A1)
	add	#40,powersoll	
	bsr	SoundOn5
nmoveb:
	lea	fspr3(pc),a1
	lea	shoot1(pc),a2
	tst.b	(A1)
	beq.s	dan

	move.b	1(A1),d0	
	move.b	1(A2),d1	
	add.b	#15,d0
	cmp.b	d0,d1
	bhi.s	dan

	move.b	1(A1),d0	
	move.b	1(A2),d1	
	add.b	#8,d1
	cmp.b	d1,d0
	bhi.s	dan

	move.b	(A1),d0
	move.b	(A2),d1
	cmp.b	d0,d1
	bhi.s	dan

	clr.l	(a1)
	clr.l	(A2)
	add.l	#50,score
	bsr	SoundOn4
	lsr	#1,powersoll
	bra.s	dan
dan:
	lea	fspr2(pc),a1
	tst.b	(a1)
	beq	endmove2

	addq	#2,f2cnt
	move.l	bahn,a3
	add	f2cnt,a3

	cmp.b	#240,(a1)
	blo.s	endfg1

	clr.l	(a1)
	move	#4,f2cnt
	clr	away
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

	lea	fspr3(pc),a2
	tst.b	(a2)
	bne.s	nobomb

	tst.b	battle
	beq.s	nobomb

	lea	fspr2(pc),a1
	cmp.b	#130,(A1)
	bhi	nobomb
	bsr	rnd
	and.b	#$3f,d0
	tst.b	d0
	bne.s	nobomb

	lea	fspr3(pc),a2
	lea	fspr2(pc),a1
	move	(a1),(A2)
	move.b	(A1),2(A2)
	add.b	#11,2(A2)
nobomb:
	tst	Shapi
	bne.s	DoIToh

	addq	#1,ShapCNT
	move	ShapCNT,d3
	cmp	Speed,d3
	bne.s	NoThingChanged
DoItOh:
	clr	ShapCNT
	clr	Shapi

	addq.l	#4,pshap
	move.l	pshap,a1
	tst.l	(A1)

	bne.s	notendshape
	move.l	shape,pshap
notendshape:
	move.l	pshap(pc),a1
	cmp.l	oldshap,a1
	beq.s	NoThingChanged
	move.l	(A1),a4

	lea	fspr2+4(pc),a3
	moveq	#98,d7
ClFl2Spr:
	clr.l	(A3)+
	dbra	d7,ClFl2spr

	move	yhoehe,d6
	subq	#1,d6
	lea	fspr2+4(pc),a2
copyshape:
	move.l	(A4)+,(A2)+
	dbra	d6,copyshape
	clr.l	(A2)
	move.l	pshap,oldshap
NoThingChanged:
	move	ytest1,d6
	cmpi.b	d6,d2
	bls	endmove2
	move	ytest2,d6
	cmpi.b	d6,d2
	bhi	endmove2
	move	mousx,d5
	lsr.b	#1,d5
	add.b	#74,d5
	cmp.b	d5,d1
	bls.s	daneben33
	move.l	schl,d6
	lsl.l	#1,d6
	lea	tabelle2(pc),a2
	add.l	d6,a2
	add	(a2),d5	
	cmp.b	d5,d1
	bhi.s	daneben33
	bra.s	treffer33
daneben33:
	move	mousx2,d5
	lsr.b	#1,d5
	add.b	#74,d5

	cmp.b	d5,d1
	bls	endmove2
	
	move.l	schl,d6
	lsl.l	#1,d6
	lea	tabelle2(pc),a2
	add.l	d6,a2
	add	(a2),d5	

	cmp.b	d5,d1
	bhi.s	endmove2
treffer33:
	add	#30,powersoll
	lea	fspr2(pc),a1
	clr.l	(a1)
	clr	away
	bsr	SoundOn6
	bsr	ClearBonus
endmove2:
	rts

ClearSpr:
	lea	sprite1(pc),a1
	lea	sprite2(pc),a2
	lea	fspr1(pc),a3
	lea	fspr2(pc),a4
	lea	fspr3(pc),a5
	lea	shoot1(pc),a6
	clr.l	(A1)
	clr.l	(A2)
	clr.l	(A3)
	clr.l	(A4)
	clr.l	(A5)
	clr.l	(A6)
	rts

ClearBonus:
	clr.b	smash
	clr.b	hold
	clr.b	auto
	clr.b	twoball
	clr.b	twoschl
	clr.b	revers
	clr.b	laser
	clr.b	level
	clr.b	smash
	move.l	#-1,extend
	move.l	#-1,extend2
	lea	sprite2(pc),a1
	clr.b	1(A1)

	tst.b	demo
	beq.s	nDemo
	move.b	#1,auto
nDemo:
	rts	

movefspr:
	movem.l	d0-d7/a0-a5,-(sp)
	clr.b	alter
	tst.b	falling
	beq.L	f2

	lea	fspr1(pc),a3
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
	lea	fspr1+4(pc),a4
	move.l	a4,a2
	clr.l	d5
	move.b	fcounter,d5
	mulu	#60,d5
	add.l	d5,a4
	move	#12,d6
writef:
	move.l	(a4)+,(a2)+
	dbra	d6,writef

	lea	fspr1(pc),a1
	move.b	1(A1),d1
	move.b	(A1),d2

	tst.b	demo
	bne	hitschl

	cmpi.b	#220,d2
	bls	hitschl
	cmpi.b	#232,d2
	bhi	hitschl

	move	mousx,d5
	lsr.b	#1,d5
	add.b	#74,d5

	cmp.b	d5,d1
	bls.s	daneben23

	move.l	schl,d6
	lsl.l	#1,d6
	lea	tabelle2(pc),a2
	add.l	d6,a2
	add	(a2),d5	

	cmp.b	d5,d1
	bhi.s	daneben23
	bra.s	treffer2
daneben23:
	move	mousx2,d5
	lsr.b	#1,d5
	add.b	#74,d5

	cmp.b	d5,d1
	bls.L	hitschl
	
	move.l	schl,d6
	lsl.l	#1,d6
	lea	tabelle2(pc),a2
	add.l	d6,a2
	add	(a2),d5	

	cmp.b	d5,d1	
	bhi	hitschl
treffer2:
	tst.b	bonus
	beq	hitschl

	lsr	#1,powersoll
	cmp.b	#16,bonus
	bne.s	not16		

	tst.b	twoball
	bne.s	not16

	bsr	ClearBonus
	bsr	starttwo
	bra.L	cfall
not16:
	cmp.b	#11,bonus
	bne.s	not11		
	tst.b	twoplayer
	bne.s	not11

	tst.b	battle
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
	addq.b	#1,lives
	bra.L	cfall
not10:
	cmp.b	#12,bonus
	bne.s	not12		

	tst.b	battle
	bne.s	not12

	bsr	ClearBonus
	move.b	#1,hold
	bra	cfall	
not12:
	cmp.b	#13,bonus
	bne.s	not13		

	bsr	ClearBonus
	move.b	#1,auto
	bra.L	cfall
not13:
	cmp.b	#9,bonus
	bne.s	not9

	tst.b	twoplayer
	bne.s	not9
	tst.b	battle
	bne.s	not9
	bsr	ClearBonus
	move.b	#1,laser		
	bra.L	cfall
not9:
	cmp.b	#17,bonus
	bne.s	not17

	bsr	ClearBonus
	move.b	#1,revers

	tst.b	twoplayer
	bne.s	givenobonus

	move	mousx,d4
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
hitschl:
	cmp.b	#240,(a3)
	bls.s	f2
	clr.b	falling
	clr.b	(a3)
	move.b	#$b,2(A3)
f2:
	movem.l (sp)+,d0-d7/a0-a5
	rts

starttwo:
	move.b	#1,twoball
	lea	sprite1(pc),a3
	lea	sprite2(pc),a4
	move.l	(a3),(a4)
	
	lea	spr1+4(pc),a3
	lea	spr2+4(pc),a4
	move.l	(a3),(a4)

	move	$dff006,d2
	and	#7,d2
	lsl	#1,d2
	lea	shake_table(pc),a3
	add.l	d2,a3
	move.b	1(a3),3(a4)
	neg.b	2(a4)
	rts

cfall:
	move.b	#1,alter
	lea	fspr1(pc),a3
	clr.b	1(a3)
	clr.b	falling
	add.l	#10,score
	bsr	SoundOn7
	bra	hitschl

begin:
	movem.l d0-d7/a0-a5,-(sp)
	tst.b	falling
	beq.s	okl
	movem.l	(sp)+,d0-d7/a0-a5
	rts
okl:
	lea	falling(pc),a2
	move.b	#1,(a2)
	move.b	d2,d6
	move.b	d1,d5
	lsl.b	#3,d5
	lsl.b	#3,d6
	add.b	#50,d6
	add.b	#81,d5

	lea	fspr1(pc),a3
	move.b	d6,(a3)+
	move.b	d5,(a3)+
	add.b	#13,d6
	move.b	d6,(a3)+
	move.b	d7,bonus
	movem.l	(sp)+,d0-d7/a0-a5
	rts

alles_geloescht:
	lea	zspeicher+14(pc),a4
	move	#175,d5
aloop:
	move.b	(a4)+,d4
	tst.b	d4
	bne.s	aloop2
	dbra	d5,aloop
	clr	d0
	rts
aloop2:
	cmp.b	#8,d4
	bne.s	aloop3
	dbra	d5,aloop
	clr	d0
	rts
aloop3:
	move	#$ffff,d0
	rts

initblockcolors:
	lea	zspeicher+2(pc),a0
	lea	coppercol+32+2(pc),a1
	moveq	#5,d7
ibcloop1:
	move	(a0)+,(a1)
	addq.l	#4,a1
	dbra	d7,ibcloop1
	rts
htoz:
	lea	zspeicher(pc),a0
	move.l	hspeicher,a1
	add.l	stufe2,a1
	moveq	#94,d7
htoz1:
	move	(a1)+,(a0)+
	dbra	d7,htoz1
	rts
ztoh:
	move.l	hspeicher(pc),a0
	lea	zspeicher(pc),a1
	add.l	stufe2,a0	
	moveq	#94,d7
ztohloop:
	move	(a1)+,(a0)+
	dbra	d7,ztohloop
	rts
histufe:
	dc.l	0
stufe2:
	dc.l	0*190
allocmem:
	move.l	4,a6
	move.l	#$56000,d0
	move.l	#$28000,a1
	jsr	-204(a6)
	rts

initlib:
	move.l	4,a6
	lea	gfxlib(pc),a1
	jsr	-408(a6)
	beq	exit
	move.l	d0,gfxbase
	rts

initsound:
	move	#0,$dff0a8
	move	#0,$dff0b8
	move	#0,$dff0c8
	move	#0,$dff0d8

	move	#$800f,$dff096		
	rts

InitCopper:
	lea	copperspr+2(pc),a0	
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

	move.l	#copperl,$dff080	
	rts

loadstage:
	move.l	4,a6
	move	#2,command
	
	sub.l	d0,d0
	lea	stagename(pc),a2
	move.b	5(A2),d0
	sub.b	#'A',d0
	mulu	#6144,d0
	add.l	#stagebase,d0
	move.l	d0,offset		
	move.l	#6144,laenge		
	move.l	hspeicher,ziel		
	bsr	starttask
	bsr	wait_load
	rts

StageName:
	dc.b	'STAGEA',0
even
HSpeicher:
	dc.l	$5e400

ShadowAll:
	move	#1,refy
sh:
	bsr	Shadow
	add	#1,refy
	cmp	#15,refy
	bne.s	sh
	rts

clrshadow:
	move.l	screen1(pc),a1
	add.l	#40000,a1
	move	#1999,d7
clss:
	clr.l	(A1)+
	dbra	d7,clss
	rts

Shadow:
	movem.l	d0-d7/a0-a5,-(sp)
	clr	refresh

	move.l	screen1,a1
	lea	zspeicher+14,a2
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
	bne.s	wshadow
	
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

	bra.s	endshadow
wshadow:
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
	beq.s	endshadow

	tst.b	12(A2)
	bne.s	endshadow

	move	#$f000,d2
	or.b	#$f0,322(A1)
	or.b	#$f0,362(A1)
	or.b	#$f0,402(A1)
	or.b	#$f0,442(A1)
endshadow:
	addq	#1,a2
	addq	#2,a1
	dbra	d6,xlo

	add	#320-22,a1
	dbra	d7,ylo
	movem.l	(sp)+,d0-d7/a0-a5
	rts

makeflash:
	lea	flashlist(pc),a2
	lea	zspeicher+14(pc),a1
	move	#175,d7
mfl:
	move.b	(a1),d4
	and.b	#$f,d4
	cmp.b	#7,d4
	bne.s	mfl1
	move.b	#1,(A2)
	bra.s	mfl3
mfl1:
	cmp.b	#8,d4
	bne.s	mfl3
	move.b	#149,(a2)
mfl3:
	addq	#1,a1
	addq	#1,a2
	dbra	d7,mfl
	rts	

flashall:
	not	flashcnt
	tst	flashcnt
	bne.s	nend2
	rts
nend2:	
	moveq	#7,d6
	bsr	makeflash
flall1:
	move.l	gfxbase(pc),a6
	jsr	-270(A6)
	bsr	flash
	dbra	d6,flall1
	rts

clearflash:
	lea	flashlist(pc),a1
	move	#74,d0
cfl:
	clr.l	(a1)+
	dbra	d0,cfl
	rts
Flash:	
	not	flashcnt
	tst	flashcnt
	bne.s	fend
	rts
fend:
	clr	d1
	clr	d2
	lea	flashlist(pc),a1
	lea	zspeicher+14(pc),a2
	move	#175,d7
floop:
	tst.b	(A2)+
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
	bsr	draw_flash
endf4:
	add	#1,d1
	cmp	#11,d1
	bne.s	endf5
	clr	d1
	add	#1,d2
endf5:
	addq.l	#1,a1
	dbra	d7,floop
	rts

draw_flash:
	movem.l d0-d7/a0-a5,-(sp)
	move.l	gfxbase,a6
	jsr	-456(a6)
	lea	$dff000,a5
	move.l	screen2,a1
	add	#22,a1
	lsl	#1,d0
	add	d0,a1		
	move.l	screen1,a3
	add	#284,a3
	lsl	#1,d1
	add	d1,a3
	mulu	#320,d2
	add	d2,a3		
	moveq #4,d7
draw_flash2:
	btst #14,2(a5)
	bne.s draw_flash2
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
	dbra	d7,draw_flash2
	move.l	gfxbase,a6
	jsr	-462(a6)
	movem.l	(sp)+,d0-d7/a0-a5
	rts	

	dc.w	$6200
Draw_Block:
	movem.l d0-d7/a0-a5,-(sp)
	lea	$dff000,a5
	move.l	gfxbase,a6
	jsr	-456(A6)

	move	d2,refy
	bsr	shadow
nosh:
	cmp	#8,d0
	bls.s	nobonus
	moveq	#9,d0
nobonus:
	move.l	screen2,a1		
	lsl	#1,d0			
	add.l	d0,a1			
	move.l	screen1,a2		
	add.l	#284,a2			
	lsl	#1,d1			
	add.l	d1,a2
	mulu	#320,d2
	add.l	d2,a2

	tst.b	d0
	beq	clear_block

	move	#38,$64(a5)		
	move	#38,$66(a5)		
	clr	$42(a5)			
	move	#$9f0,$40(a5)		
	move.l	#-1,$44(a5)	 
	moveq	#4,d7
draw_block2:
	btst	#14,2(a5)
	bne.s	draw_block2
	move.l	a2,$54(a5)		
	move.l	a1,$50(a5)		
	move	#%1000000001,$58(a5)		
	add.l	#8000,a1
	add.l	#8000,a2
	dbra	d7,draw_block2
	move.l	gfxbase,a6
	jsr	-462(a6)
	movem.l (sp)+,d0-d7/a0-a5
	rts
clear_block:
	move.l	screen3,a3
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
clear_block2:
	btst	#14,2(a5)
	bne.s	clear_block2
	move.l	a3,$50(a5)		
	move.l	a2,$54(a5)		
 	move.l	#-1,$44(a5)	
	move	#%1000000001,$58(a5)	
	add.l	#5044,a3
	add.l	#8000,a2
	dbra	d7,clear_block2
	move.l	gfxbase,a6
	jsr	-462(a6)
	movem.l	(sp)+,d0-d7/a0-a5
	rts

draw_live:
	movem.l	d0-d7/a0-a5,-(sp)	
	lea	$dff000,a5
	move.l	screen2,a0
	add.l	#20,a0			
	move.l	a0,a1
	addq.l	#2,a1			
	move.l	screen1,a2
	add.l	#40*192+24,a2
	lsl	#1,d0
	sub.l	d0,a2
	tst.b	d1
	beq	clear_live
	move	#38,$60(a5)		
	move	#38,$62(a5)		
	move	#38,$64(a5)		
	move	#38,$66(a5)		
	clr	$42(a5)			
	move	#$fca,$40(a5)		
	move.l	#-1,$44(a5) 	
	moveq	#4,d7
draw_live2:
	btst	#14,$2(a5)
	bne.s	draw_live2
	move.l	a0,$4c(a5)	
	move.l	a2,$48(a5)	
	move.l	a2,$54(a5)	
	move.l	a1,$50(a5)	
	move	#%1000000001,$58(a5)		
	add.l	#8000,a0
	add.l	#8000,a2
	dbra	d7,draw_live2
	movem.l	(sp)+,d0-d7/a0-a5
	rts
clear_live:
	lea	$dff000,a5
	move.l	screen3,a3
	add.l	#186*26+22,a3
	sub.l	d0,a3
	move	#38,$66(a5)		
	move	#24,$64(a5)		
	clr	$42(a5)			
	move	#$9f0,$40(a5)		
	moveq	#4,d7
clear_live2:
	btst	#14,2(a5)
	bne.s	clear_live2
	move.l	a3,$50(a5)		
	move.l	a2,$54(a5)		
 	move.l	#-1,$44(a5) 
	move	#%1000000001,$58(a5)
	add.l	#5044,a3
	add.l	#8000,a2
	dbra	d7,clear_live2
	movem.l	(sp)+,d0-d7/a0-a5
	rts

expltable:
	dc.w 2280,2286,2292,2298,2304
	dc.w 3240,3246,3252,3258,3264
	dc.w 4200,4206,4212,4218,4224
	dc.w	4230,4230,4230,4230
	dc.w	4230,4230,4230,4230
	dc.w	4230,4230,4230,4230

explosion:
	move.b	#1,paused
	move	#1,endgame2
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
	move	#16,SoundCNT2
	move	#16,SoundCNT1
	move	#$8003,$96(A5)

	clr	power
	move.l	#4,schl
	move.l	#4,schl2
	move	mousx(pc),x
	move	mousx2(pc),x2
	clr.l	d6
explo2:
	move.l	gfxbase(pc),a6
	jsr	-270(A6)

	move.l	screen1,a2
	add.l	#7162,a2
	move.l	screen3,a3
	add.l	#$1192,a3	

	move	#14,$66(a5)		
	clr	$64(a5)			
	clr	$42(a5)			
	move	#$9f0,$dff040		
	move.l	#-1,$44(a5)	

	moveq	#5,d7
clear_explo:
	btst	#14,$2(a5)
	bne.s	clear_explo

	move.l	a2,$54(a5)		
	move.l	a3,$50(a5)		
	move	#%1010001101,$58(a5)	
	
	add.l	#8000,a2
	add.l	#5044,a3
	dbra	d7,clear_explo

	move.l	screen2,a0
	lsl	#1,d6	
	lea	expltable(pc),a4
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

	move.l	screen1,a2		
	add.l	#6804,a2		
	add.l	d0,a2
	
	moveq	#4,d7
draw_explo2:
	btst	#14,2(A5)
	bne.s	draw_explo2

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
	dbra	d7,draw_explo2

	move.l	screen2,a0
	lsl	#1,d6			
	lea	expltable(pc),a4
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

	move.l	screen1,a2		
	add.l	#6804,a2		
	add.l	d0,a2
	
	moveq	#4,d7
draw_explo23:
	btst	#14,2(a5)
	bne.s	draw_explo23

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
	dbra	d7,draw_explo23

	addq	#1,d6
	cmp	#18,d6
	bne	explo2

	clr	endgame2
	sub.b	#1,lives
	cmp.b	#-1,lives
	bne.s	notlives

	tst	cheat
	beq	game_over

	clr.b	lives			; CHEAT
notlives:
	bsr	dolives
	bsr	restorepower
	clr.b	exploding
	bra	haupt2		

game_over:
	move.l	stufe2,d0
	cmp.l	histufe,d0
	bls.s	dontcorr
	move.l	d0,histufe	
dontcorr:
	move.l	gfxbase(pc),a6
	moveq	#25,d7
waitexplo:
	jsr	-270(a6)
	dbra	d7,waitexplo	
	move	#1,endgame	
	bra	haupt		
DoHiScore:
	tst	Cheat
	bne.s	OhYeah
	tst.b	demo
	bne.s	OhYeah
	bra.s	OJJJ			
OhYeah:
	rts
OJJJ:
	move.l	score,d0
	bsr	GetPosition
	cmp	#100,d0
	beq.s	NoE
	tst	d0
	bne.s	scored
NoE:
	rts
Scored:				
	move.l	d0,d1
	subq.l	#1,d1
	mulu	#22*12,d1
	move.l	d1,ListCNT	

	tst.b	FromMenu
	bne.s	FMenu1

	move.l	#PlayerName,a1	
	move.l	Score,d1
	bsr	InsertScore		
FMenu1:
	bsr	ShowScore		
	move	#6,command
	bsr	StartTask

	lea	bob1,a1
	clr	8(A1)			
	move	#64,10(A1)		
	move	#-1,12(A1)		
	move	#-1,14(A1)		
	move.l	#animseq1,54(A1)
	move.l	#animcoord1,58(A1)
	clr	20(A1)
	clr.l	44(a1)
	clr.l	50(A1)
	clr	62(A1)
	clr	66(A1)			

	move	#$10,$dff09a
	move.l	$6c,Vblankveq
	move.l	#VblankInt,$6c
	move	#$8010,$dff09a

	tst.b	FromMenu
	bne	FMenu2
notre:
	lea	bob1,a1
	cmp	#244,8(A1)
	bne.s	notre

	bsr	GetName
	moveq	#50,d7
WaitJump:
	move.l	gfxbase,a6
	jsr	-270(A6)
	dbra	d7,WaitJump
	bsr	DrawEye
	lea	Bob1,a1
	clr.l	50(A1)
	move.l	#animseq3,54(A1)		
	move.l	#animcoord3,58(A1)
	moveq	#75,d7
WaitAnim:
	move.l	gfxbase,a6
	jsr	-270(A6)	
	dbra	d7,WaitAnim
FMenu2:
	move	#1,NoPrint
	bsr	ListScore
	move.l	gfxbase,a6
FadeSound:
	jsr	-270(A6)
	subq	#2,$20000+24
	tst	$20000+24
	bpl.s	FadeSound

	jsr	$20014
	move	#$10,$dff09a
	move.l	VblankVeq,$6c		

	move	#$100,$dff096
	bsr	ClearScore
	bsr	SaveHiScore
	move.l	#copperl4,$dff080
	move	#$8010,$dff09a		
	clr.b	FromMenu
	clr	Endgame
	clr	NoPrint
	rts
NoPrint:
	dc.w	0

ClearScore:
	lea	page1,a1
	move	#11999,d7
CLS:
	clr.l	(A1)+
	dbra	d7,CLS
	rts

	page3=$60000+55000		

	page4=$60000-40000		
FromMenu:
	dc.w	0,0
FromList:
	dc.w	0
ClearPic:
	lea	page4,a1
	move	#9999,d7
Clear_Page4:
	clr.l	(A1)+
	dbra	d7,Clear_Page4		
	rts

ListScore:				
	move	#1,FromList
	bsr	ClearPic		
	bsr	WritePic		
	clr.b	TwoPlayer
	clr.l	ticks
WaitSPACE:
	move	$dff006,d0
	and	#$ff00,d0
	cmp	#$c800,d0
	bne.s	WaitSPACE

	btst	#6,$bfe001
	beq	EndList

	addq.l	#1,Ticks
	cmp.l	#1000,Ticks
	beq	EndList
NoCount:
	bsr	MouseHandler
	move	Imgx,d0
	mulu	#66,d0
	move.l	d0,ListCNT2

	cmp.b	#$5f,$bfec01
	bne.s	ShowNotAll
	btst	#10,$dff016
	bne.s	ShowNotAll

	cmp.l	#$81f0,ListCNT2
	blo.s	EndJk
	move.l	#$81f0,ListCNT2
	bra.s	EndJk
ShowNotAll:
	cmp.l	#$6408,ListCNT2
	blo.s	endJk
	move.l	#$6408,ListCNT2
EndJk:
	move.l	ListCNT,d0
	cmp.l	ListCNT2,d0
	beq	WaitSPACE
	move.l	ListCNT2,ListCNT

	clr.l	Ticks
	bsr	CopyToPic		
	bra	WaitSPACE
EndList:
	clr	FromList
	rts

Ticks:
	dc.l	0
ListCNT:
	dc.l	0
ListCNT2:
	dc.l	0
TopText:
	dc.b	'HALL OF FAME',0

HUAText:
	DC.B	1,000,'--------------------',0
	DC.B	1,012,' SPECIAL THANKS TO',0
	DC.B	1,024,'--------------------',0		
	DC.B	6,040,'- CHRIS -',0
	DC.B	7,052,'- SCA -',0
	DC.B	6,064,'- TIGER -',0
	DC.B	4,076,'- BLACK BIRD -',0
	DC.B	4,088,'- CONTROLLER -',0
	DC.B	1,100,'- SIN - ALFI - DAK -',0
	DC.B	2,112,'AND TO ANYONE ELSE',0		
	DC.B	3,124,'WHO SUPPORTED ME',0
	DC.B	5,136,'IN ANY WAY.',0
	DC.B	1,160,'--------------------',0
	DC.B	8,172,'CRACK',0
	DC.B	1,184,'--------------------',0
	DC.B	4,196,'PLAY IT OR DIE',0	
	DC.B	1,208,'--------------------',0
	DC.B	16,230,'-C5-',0
	DC.B	0,0,0,0
even
HiCnt:
	dc.l	1
WriteText2:
	clr.l	d0
	move.l	d0,d1
	move.b	(A1)+,d0
	move.b	(A1)+,d1
	add.l	#1400,d1
	bsr	Write_Text
	addq.l	#1,a1
	tst.b	1(A1)
	bne.s	WriteText2
	rts
HiName:
	dc.b	'12345678',0,0
WritePic:
	move.l	#1,HiCnt
	moveq	#2,d0
	moveq	#70,d1
Print_Numero:
	move.l	HiCnt,d4
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
WriteName:
	lea	hiName,a4		
	lea	hilist-70,a5		
	add.l	d1,a5			
	move.l	(A5)+,(A4)+		
	move.l	(A5)+,(A4)+		

	lea	hiName,a1
	movem.l	d0-d7/a0-a5,-(sp)
	bsr	Write_text
	movem.l	(sp)+,d0-d7/a0-a5	

	add.l	#12,d1			
	dbra	d5,WriteName

	lea	TopText,a1
	moveq	#5,d0
	moveq	#40,d1
	bsr	Write_Text		

	moveq	#70,d1
	moveq	#14,d0
	moveq	#98,d7
PrintScore:
	lea	ScoreAscii+7,a3			
	lea	hilist+8-70,a4			
	move.l	(A4,d1.l),d4			
	moveq	#5,d6				
	bsr	MakeAscii			

	lea	ScoreAscii+2,a1
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	Write_Text			
	movem.l	(sp)+,d0-d7/a0-a6
	add.l	#12,d1
	dbra	d7,PrintScore			

	lea	HUAText,a1
	bsr	WriteText2
	rts

ScoreAscii:
	dc.b	'00000000',0,0
HiCntAscii:
	dc.b	'XX',0,0

MakeASCII:
	divu	#10,d4
	swap	d4
	add.b	#'0',d4
	move.b	d4,-(A3)
	clr	d4
	swap	d4
	dbra	d6,MakeASCII
	rts





Write_Text:
	lea	page4,a2	
	mulu	#22,d1
	add.l	d1,a2
	add.l	d0,a2			
Not_Finished:	
	tst.b	(A1)
	beq.s	EndWrite
	bsr	Write_Letter
	addq.l	#1,a2
	addq.l	#1,a1			
	bra.s	Not_Finished
EndWrite:
	rts

Write_Letter:
	move.l	a2,a0			
	lea	font,a3			
	clr.l	d0
	move.b	(A1),d0
	sub.b	#' ',d0
	mulu	#10,d0			
	
	add.l	d0,a3
	moveq	#9,d6			
Write_Letter2:	
	move.b	(A3)+,(a0)
	add.l	#22,a0
	dbra	d6,Write_Letter2	
	rts

CopyToPic:
	lea	$dff000,a5
	lea	page1+29450,a1
	moveq	#1,d7
Wait_Blit32:
	btst	#14,2(A5)
	bne.s	Wait_Blit32		

	move.l	#page4,A4
	add.l	ListCNT,A4		
	move.l	#page3,$50(A5)		
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
	dbra	d7,Wait_Blit32
	rts

	dc.w	$6021,$4ef9
	hisc=860*512

	pl=9600
	page1=$60000
	bobs=page1-90000
	save1=bobs-4000

ShowScore:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	LoadAll			
	bsr	InitBobList
	bsr	PrintName		
	move	#$8100,$dff096
	move.l	#copperl5,$dff080	
	bsr	CopyEye
	bsr	LoadSound
	jsr	$20008
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawEye:
	lea	EyeBuff,a2
	lea	page1+30017,a1
	move	#3,d7
DrawEye2:
	move.b	(a2)+,(A1)
	move.b	(a2)+,-19200(A1)
	move.b	(A2)+,-9600(A1)
	move.b	(A2)+,(A1)
	move.b	(A2)+,9600(A1)
	add.l	#48,a1
	dbra	d7,DrawEye2
	rts

CopyEye:
	lea	EyeBuff,a2
	lea	page1+30017,a1
	move	#3,d7
CpEye:
	move.b	-28800(a1),(A2)+
	move.b	-19200(A1),(a2)+
	move.b	-9600(A1),(A2)+
	move.b	(A1),(A2)+
	move.b	9600(A1),(A2)+
	add.l	#48,a1
	dbra	d7,CpEye
	rts
	
CloseEye:
	lea	page1+30017,a1
	move	#3,d7
CloEye:
	clr.b	-28800(A1)
	clr.b	-19200(A1)
	move.b	#$ff,-9600(A1)
	move.b	#$ff,(A1)
	clr.b	9600(A1)
	add.l	#48,a1
	dbra	d7,CloEye
	rts

DoPic:					
	lea	bobs+43520,a0		
	lea	copcol5+2,a2
	moveq	#31,d7
CM:
	MOVE	(A0)+,(A2)
	ADDQ.L	#4,A2
	DBF	D7,CM

	lea	bobs+43560,a1
	lea	RCol2+2,a2
	move	(A1),(A2)

	lea	Bobs,a0
	lea	Page3,a1
	move	#879,d7
Copy_mask:
	move.l	(A0)+,(A1)+
	dbra	d7,Copy_Mask		

	lea	page1,a1
	moveq	#4,d5
Copyplane:
	move	#199,d6
Copy:
	clr.l	(A1)+
	clr.l	(A1)+
	moveq	#9,d7
Copyline:
	move.l	(A0)+,(A1)+
	dbra	d7,copyline	
	dbra	d6,copy
	dbra	d5,copyplane
	rts

VBlankInt:
	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	$1e(A6),d0
	btst	#4,d0
	beq	EndVblank
	btst	#5,d0
	bne	EndVblank

	jsr	$2000c

	btst	#6,$bfe001
	bne.s	notclear
	move	#1,endinter
notclear:
	tst.b	FromMenu
	bne.s	NoBobs
	
	tst	NoPrint
	bne.s	NoBobs
	bsr	Drawbobs
	bsr	Movebobs
NoBobs:
	tst	eye2
	beq.s	zeroeye
	subq	#1,eye2
	bra.s	NoNewEye
zeroeye:
	bsr	rnd
	tst.b	d0
	bne.s	NoNewEye	
	move	#5,eye2
NoNewEye:
	tst	eye2
	bne.s	ClearEye
	bsr	DrawEye
	bra.s	EndEye
ClearEye:
	bsr	CloseEye
EndEye:
	move	#$10,$9c(a6)
EndVblank:
END:
	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9
VBlankveq:
	dc.l	0
eye:
	dc.w	0
MoveBobs:
	movem.l	d0-d5/a0-a2,-(sp)	
	move.l	boblist,a1
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
	bne.s	testpause		

	move.l	2(A3),8(A1)		
	addq.l	#6,58(A1)		
	bra.s	endmove
testpause:
	cmp	#-1,(A3)
	bne.L	nopause			

	addq.l	#4,58(A1)		
	move	2(A3),62(A1)		
nopause:
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

LoadAll:				
	move	#2,Command
	move.l	#Bobs,ziel
	move.l	#37*512,Laenge
	move.l	#Diskhipic,Offset
	bsr	StartTask
	bsr	Wait_Load
	cmp.l	#$7334c154,summ
	bne.s	LoadAll

	move.l	#Bobs+18924,readc	
	move.l	#Bobs,lowwr		
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
LoadErr5:
	move	#2,Command
	move.l	#Bobs,Ziel
	move.l	#58*512,Laenge
	move.l	#512*812,Offset
	bsr	StartTask
	bsr	Wait_Load
	cmp.l	#$be0ace5a,summ
	bne.s	LoadErr5

	move.l	#Bobs+29480,readc
	move.l	#Bobs,lowwr
	bsr	Decru			
NoLoad:
	rts

OverWrite:
	dc.b	'        ',0

diskhipic=512*871		
diskbob=512*812			

even
copperl5:
	dc.w	$120,7
	dc.w	$122,0
	dc.w	$124,7
	dc.w	$126,0
	dc.w	$128,7
	dc.w	$12a,0
	dc.w	$12c,7
	dc.w	$12e,0
	dc.w	$130,7
	dc.w	$132,0
	dc.w	$134,7
	dc.w	$136,0
	dc.w	$138,7
	dc.w	$13a,0
	dc.w	$13c,7
	dc.w	$13e,0

	dc.w	$1001,$fffe
	dc.w	$009c,$8010	
	dc.w 	$008e,$3a81
 	dc.w 	$0090,$02c1
	dc.w 	$0104,$0024
	dc.w 	$0092,$0038
	dc.w 	$0094,$00d2
	dc.w 	$0102,$0000
	dc.w 	$0108,8
	dc.w 	$010a,8
copcol5:
	dc.w	$0180,$0
	dc.w	$0182,$1
	dc.w	$0184,$2
	dc.w	$0186,$3
	dc.w	$0188,$4
	dc.w	$018a,$5
	dc.w	$018c,$6
	dc.w	$018e,$7
	dc.w	$0190,$8
	dc.w	$0192,$9
	dc.w	$0194,$a
	dc.w	$0196,$b
	dc.w	$0198,$c
	dc.w	$019a,$d
	dc.w	$019c,$e
	dc.w	$019e,$f
	dc.w	$01a0,$0
	dc.w	$01a2,$1
	dc.w	$01a4,$2
	dc.w	$01a6,$3
	dc.w	$01a8,$4
	dc.w	$01aa,$5
	dc.w	$01ac,$6
	dc.w	$01ae,$7
	dc.w	$01b0,$8
	dc.w	$01b2,$9
	dc.w	$01b4,$a
	dc.w	$01b6,$b
	dc.w	$01b8,$c
	dc.w	$01ba,$d
	dc.w	$01bc,$e
	dc.w	$01be,$f
BitmapPtr:
	dc.w 	$00e0,$0006
	dc.w 	$00e2,$0008
	dc.w 	$00e4,$0006
	dc.w 	$00e6,$2588
	dc.w 	$00e8,$0006
	dc.w 	$00ea,$4b08
	dc.w 	$00ec,$0006
	dc.w 	$00ee,$7088
	dc.w	$00f0,$0006
	dc.w	$00f2,$9608
	dc.w	$0100,$5200
	dc.w	$1a8,$00f
	dc.w	$3821,$fffe
	dc.w	$1b0,$0
	dc.w	$3c21,$fffe
	dc.w	$1b0,$100
	dc.w	$4021,$fffe
	dc.w	$1b0,$200
	dc.w	$4421,$fffe
	dc.w	$1b0,$300
	dc.w	$4821,$fffe
	dc.w	$1b0,$400
	dc.w	$4c21,$fffe
	dc.w	$1b0,$500
	dc.w	$5021,$fffe
	dc.w	$1b0,$600
	dc.w	$5421,$fffe
	dc.w	$1b0,$700
	dc.w	$5821,$fffe
	dc.w	$1b0,$800
	dc.w	$5c21,$fffe
	dc.w	$1b0,$900
	dc.w	$6021,$fffe
	dc.w	$1b0,$a00
	dc.w	$6421,$fffe
	dc.w	$1b0,$b10
	dc.w	$6821,$fffe
	dc.w	$1b0,$c20
	dc.w	$6c21,$fffe
	dc.w	$1b0,$d30
	dc.w	$7021,$fffe
	dc.w	$1b0,$e40
RCol2:
	dc.w	$1a8,$000
	dc.w	$7421,$fffe
	dc.w	$1b0,$f50
	dc.w	$7821,$fffe
	dc.w	$1b0,$f60
	dc.w	$7c21,$fffe
	dc.w	$1b0,$f70
	dc.w	$8021,$fffe
	dc.w	$1b0,$f80
	dc.w	$8421,$fffe
	dc.w	$1b0,$f90
	dc.w	$8821,$fffe
	dc.w	$1b0,$fa0
	dc.w	$8c21,$fffe
	dc.w	$1b0,$fc0
	dc.w	$9821,$fffe
	dc.w	$1b0,$fb0
	dc.w	$9e21,$fffe
	dc.w	$1b0,$fa0
	dc.w	$a221,$fffe
	dc.w	$1b0,$f90
	dc.w	$a621,$fffe
	dc.w	$1b0,$f80
	dc.w	$aa21,$fffe
	dc.w	$1b0,$f70
	dc.w	$ae21,$fffe
	dc.w	$1b0,$f60
	dc.w	$b221,$fffe
	dc.w	$1b0,$f50
	dc.w	$b621,$fffe
	dc.w	$1b0,$f40
	dc.w	$ba21,$fffe
	dc.w	$1b0,$e30
	dc.w	$be21,$fffe
	dc.w	$1b0,$d20
	dc.w	$c221,$fffe
	dc.w	$1b0,$c10
	dc.w	$c621,$fffe
	dc.w	$1b0,$b00
	dc.w	$ca21,$fffe
	dc.w	$1b0,$a00
	dc.w	$ce21,$fffe
	dc.w	$1b0,$900
	dc.w	$d221,$fffe
	dc.w	$1b0,$800
	dc.w	$d621,$fffe
	dc.w	$1b0,$700
	dc.w	$da21,$fffe
	dc.w	$1b0,$600
	dc.w	$de21,$fffe
	dc.w	$1b0,$500
	dc.w	$e221,$fffe
	dc.w	$1b0,$400
	dc.w	$e621,$fffe
	dc.w	$1b0,$300
	dc.w	$ea21,$fffe
	dc.w	$1b0,$200
	dc.w	$ee21,$fffe
	dc.w	$1b0,$0
	dc.w	$ffff,$fffe 

bitmstr1:
	dc.w	48
	dc.w	200
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page1
	dc.l	page1+pl
	dc.l	page1+[2*pl]
	dc.l	page1+[3*pl]
	dc.l	page1+[4*pl]




DrawBobs:
	movem.l	d0-d7/a0-a6,-(A7)
	move.l	BobList,a0
	lea	$dff000,a6
SearchLastBob:				
	tst.l	(A0)		
	beq.s	BobReconstLoop
	move.l	(A0),a0
	bra.s	SearchLastBob
	
BobReconstLoop:
	lea	bitmstr1,a2
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
BlitWait2:
	btst	#14,2(A6)
	bne.s	BlitWait2

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
	bra.L	BobReconstLoop
EndRecLoop:		

	lea	page1+$783c,a1
	lea	page1+4014+28800,a2
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
	lea	Bitmstr1,a2
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
BlitWait3:
	btst	#14,2(A6)
	bne.s	BlitWait3
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
BlitWait1:
	btst	#14,2(A6)
	bne.s	BlitWait1
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
	cmpi	#-3,d0
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
	bra.L	BobMainLoop
EndDrawBobs:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

InitBobList:
	movem.l	d0-d3/a0-a1,-(A7)
	move.l	BobList,a0
BobInitLoop:
	lea	Bitmstr1,a1
	move	(a1),d1
	move	4(a0),d0
	move	d0,d2
	lsr	#4,d0
	and	#15,d2
	tst	d2
	beq.s	BobEven
	addq	#1,d0
BobEven:
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
	beq.s	EndInitBobs
	move.l	(A0),a0
	bra.s	BobInitLoop
EndInitBobs:	
	movem.l	(a7)+,d0-d3/a0-a1
	rts

readc:
	dc.l	$0			
lowwr:
	dc.l	$0			


decru:
	move.l	readc,a0
	move.l	lowwr,a1		
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
	dc.l	bobs		
	dc.l	bobs+[1*3456]
	dc.l	bobs+[2*3456]
	dc.l	bobs+[3*3456]
	dc.l	bobs+[4*3456]
	dc.l	bobs+[5*3456]
	dc.l	bobs+[6*3456]
	dc.l	bobs+[7*3456]
	dc.l	bobs+[8*3456]
	dc.l	bobs+[9*3456]
	dc.l	bobs+[10*3456]
	dc.l	bobs+[11*3456]
	dc.l	bobs+[12*3456]
	dc.l	bobs+[13*3456]
	dc.l	bobs+[14*3456]
	dc.l	bobs+[15*3456]
	dc.l	bobs+[16*3456]
	dc.l	bobs+[17*3456]
	dc.l	bobs+[18*3456]
	dc.l	bobs+[19*3456]
	dc.l	bobs+[20*3456]
	dc.l	bobs+[21*3456]
	dc.l	bobs+[22*3456]
	dc.l	bobs+[23*3456]
	dc.l	bobs+[24*3456]
	dc.l	bobs+[25*3456]
boblist:
	dc.l	bob1
bob1:
	dc.l	0		
	dc.w	64,72		
	dc.w	100,0		
	dc.w	-1,-1		
	dc.w	-1,-1		
	dc.w	0		
	dc.w	0		
	dc.w	0		
	dc.l	save1		
	dc.l	save1		
	dc.w	0		
	dc.l	0		
	dc.l	0		
	dc.l	0		
	dc.w	4		
	dc.w	0		
	dc.w	0		
	dc.l	Animseq1	
	dc.l	Animcoord1	
	dc.w	0		
	dc.w	1		
	dc.w	0		
	dc.w	1		
	dc.w	1		

Animseq1:
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,13,14
	dc.w	-3

Animseq2:
	dc.w	14,15,16,17,18,16
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

Animseq3:
	dc.w	19,20,21,21,22,22,22,22,22,22,22,22,22
	dc.w	-2,-3

Animcoord3:
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

Animcoord1:
	dc.w	244,64
	dc.w	0,0
	
	dc.w	$4e71,$60fe
	dc.w	$4ef9,$fc40d8

moveschlleft:
	clr	timer
	clr.b	leftout
	move.b	#4,paused

	lea	$dff000,a5
	moveq	#31,d5
moveleft2:
	move.l	gfxbase(pc),a6
	jsr	-270(a6)

	tst	timer
	bne.s	w6
	move.l	screen1,a2
	add.l	#7162,a2
	move.l	screen3,a3
	add.l	#$1192,a3	

	move	#14,$66(a5)		
	clr	$64(a5)			
	clr	$42(a5)			
	move	#$9f0,$dff040		
	move.l	#-1,$44(a5)	

	moveq	#5,d7
clear_explo2:
	btst	#14,$2(a5)
	bne.s	clear_explo2

	move.l	a2,$54(a5)		
	move.l	a3,$50(a5)		
	move	#%0000001010001101,$58(a5)	
	
	add.l	#8000,a2
	add.l	#5044,a3
	dbra	d7,clear_explo2
	move	#1,timer
w6:
	move.l	screen1,a2
	add.l	#7162,a2
	move.l	screen3,a3
	add.l	#$1192,a3	

	move	#16,$66(A5)		
	move	#2,$64(a5)		
	clr	$42(A5)			
	move	#$9f0,$40(a5)		
	move.l	#$ffffffff,$44(A5)	

	moveq	#5,d7
clear_left:
	btst	#14,$2(A5)
	bne.s	clear_left

	move.l	a2,$54(a5)	
	move.l	a3,$50(a5)	
	move	#%0000001110001100,$58(a5)		
	
	add.l	#8000,a2
	add.l	#5044,a3
	dbra	d7,clear_left		

	move	d5,d3			
	move	d5,d0
	and	#$000F,d3		
	lsr	#3,d0			
	bclr	#0,d0
	lsl	#8,d3
	lsl	#4,d3
	move	d3,d2			
	add	#$fca,d2		

	move.l	screen2,a0	 
	add.l	#1064,a0		
	move.l	screen1,a2		
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
	dbra	d7,draw_left2

	move	d3,d2
	add	#$fca,d2
	add.l	#120,a2

	move.l	a4,a0
	sub.l	#400,a0	
	move.l	a0,a1
draw_schl332:
	btst	#14,$2(a5)
	bne.s	draw_schl332

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
	
	move.l	screen2,a0
	add.l	#1692,a0		
	move.l	a0,a1
	addq.l	#4,a1
	move.l	screen1,a2
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
	dbra	d7,clr_left4		
	moveq	#15,d6
corrd:
	clr.l	(A2)	
	add.l	#40,a2
	dbra	d6,corrd
	dbra	d5,moveleft2
	bra	prelevel

moveschlright:
	move.b	#4,paused
	lea	$dff000,a5
	clr.b	rightout
	clr	timer
	move	#148,d5
moveright2:
	move.l	gfxbase,a6
	jsr	-270(a6)

	tst	timer
	bne.s	w7

	move.l	screen1,a2
	add.l	#7162,a2
	move.l	screen3,a3
	add.l	#$1192,a3	

	move	#14,$66(a5)		
	clr	$64(a5)			
	clr	$42(a5)			
	move	#$9f0,$dff040		
	move.l	#-1,$44(a5)	

	moveq	#5,d7
clear_explo3:
	btst	#14,$2(a5)
	bne.s	clear_explo3

	move.l	a2,$54(a5)		
	move.l	a3,$50(a5)		
	move	#%0000001010001101,$58(a5)	
	
	add.l	#8000,a2
	add.l	#5044,a3
	dbra	d7,clear_explo3
	move	#1,timer
w7:
	move.l	screen1,a2
	add.l	#7180,a2

	move.l	screen3,a3
	add.l	#$11a4,a3	

	move	#32,$66(a5)		
	move	#18,$64(a5)		
	clr	$42(a5)			
	move	#$9f0,$40(a5)		
	move.l	#$ffffffff,$44(a5) 

	moveq	#5,d7
clear_right:
	btst	#14,2(a5)
	bne.s	clear_right

	move.l	a2,$54(a5)		
	move.l	a3,$50(a5)		
	move	#%0000001110000100,$58(a5)	
	
	add.l	#8000,a2
	add.l	#5044,a3
	dbra	d7,clear_right		

	move	d5,d3			
	move	d5,d0
	and	#$000F,d3		
	lsr	#3,d0			
	bclr	#0,d0
	lsl	#8,d3
	lsl	#4,d3
	move	d3,d2			
	add	#$fca,d2		

	move.l	screen2,a0	 
	add.l	#1064,a0		
	move.l	a0,a4

	move.l	screen1,a2		
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
	dbra	d7,draw_right2

	move	d3,d2
	add	#$fca,d2
	add.l	#120,a2

	move.l	a4,a0
	sub.l	#400,a0	
	move.l	a0,a1
draw_schl333:
	btst	#14,$2(a5)
	bne.s	draw_schl333

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
	move.l	screen2,a0
	add.l	#1700,a0		
	move.l	a0,a1
	addq.l	#4,a1			
	move.l	screen1,a2
	add.l	#7026,a2		
	moveq	#4,d7
clr_right4:
	btst	#14,$dff002
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
	dbra	d7,clr_right4		
	moveq	#15,d0
clrl:
	clr.l	(A2)
	clr	4(A2)
	add.l	#40,a2
	dbra	d0,clrl
	addq	#1,d5
	cmp	#181,d5
	bne	moveright2
	bra	nextlevel

Draw_Schl:
	movem.l d0-d7/a0-a5,-(sp)	
	move.l	gfxbase,a6
	jsr	-456(a6)
	tst.b	twoplayer
	bne.s	nt2
	move.l	schl,schl2
	move.l	extend,extend2
nt2:
	move.l	schl,d1
	move	mousx,d0

	clr.l	d5
	move	d0,d5
	move.l	d5,d0

	btst	#6,$bfe001
	bne.s	notauto
	tst.b	demo
	bne.s	notauto
	clr.b	auto
notauto:
	btst	#7,$bfe001
	bne.s	notauto2
	tst.b	demo
	bne.s	notauto2
	clr.b	auto
notauto2:
	
	tst.b	d0
	bhi.s	notcorrect

	tst.b	level
	beq.s	notlevel1

	move.b	#1,leftout
notlevel1:
	moveq	#1,d0
	move	#1,mousx
	move	#2,imgx
	bra.s	lo2
notcorrect:
	move	d1,d3
	lea	tabelle(pc),a5
	lsl	#1,d3
	add.l	d3,a5

	cmp	(a5),d0
	blt.s	lo2

	tst.b	level
	beq.s	notlevel2

	move.b	#1,rightout
notlevel2:				
	move	(a5),d0
	move	(a5),mousx
lo2:
	move.l	screen1,a2		
	add.l	#7084,a2

	move.l	screen3,a3
	add.l	#4448,a3	

	lea	$dff000,a5
	moveq	#5,d7
draw_schl1:
	btst	#14,2(a5)
	bne.s	draw_schl1

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
	dbra	d7,draw_schl1

	move	d0,d3			
	and	#$000F,d3		
	lsr	#3,d0			
	bclr	#0,d0
	lsl	#8,d3
	lsl	#4,d3
	move	d3,d2			
	add	#$fca,d2		

	move.l	screen2,a0	 
	add.l	#1040,a0		
	mulu	#6,d1
	add.l	d1,a0	
	move.l	a0,a4

	move.l	screen1,a2		
	add.l	#7164,a2		
	add.l	d0,a2
	
	move.l	a0,a1			
	add.l	#320,a1	
	
	moveq	#4,d7
draw_schl2:
	btst	#14,2(a5)
	bne.s	draw_schl2

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
	dbra	d7,draw_schl2

	move	d3,d2
	add	#$fca,d2
	add.l	#120,a2

	move.l	a4,a0
	sub.l	#400,a0	
	move.l	a0,a1
draw_schl3:
	btst	#14,$2(a5)
	bne.s	draw_schl3

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
	
	move	mousx2,d0
	move.l	schl,d1
	tst.b	d0
	bhi.s	notcorrect234

	tst.b	level
	beq.s	notlevel234

	move.b	#1,leftout
notlevel234:
	move	#1,d0
	move	#1,mousx2
	move	#2,imgx2
	bra.s	lo234
notcorrect234:
	move	d1,d3
	lea	tabelle(pc),a3
	lsl	#1,d3
	add.l	d3,a3

	cmp	(a3),d0
	blt.s	lo234

	tst.b	level
	beq.s	notlevel235

	move.b	#1,rightout
notlevel235:				
	move	(a3),d0
	move	(a3),mousx2
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
	move.l	screen2,a0	 
	add.l	#1040,a0		
	mulu	#6,d1
	add.l	d1,a0	
	move.l	a0,a4

	move.l	screen1,a2		
	add.l	#7164,a2		
	add.l	d0,a2
	
	move.l	a0,a1			
	add.l	#320,a1	
	
	moveq	#4,d7
draw_schl5:
	btst	#14,$2(a5)
	bne.s	draw_schl5

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
	dbra	d7,draw_schl5

	move	d3,d2
	add	#$fca,d2
	add.l	#120,a2

	move.l	a4,a0
	sub.l	#400,a0	
	move.l 	a0,a1
draw_schl6:
	btst	#14,2(a5)
	bne.s	draw_schl6

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
	move.l	gfxbase,a6
	jsr	-462(a6)
	movem.l (sp)+,d0-d7/a0-a5
	rts

tabelle:
	dc.w 140,142,144,146,148,148
tabelle2:
	dc.w 19,18,17,16,15,15
tabelle3:
	dc.w 150,152,154,156,158,158

decruncher:
	clr.l d0
eloop1:
	move.b (a0),d1
	and.b #$80,d1
	cmp.b #$80,d1            
	beq.s crunch
	
	clr.l d1
	move.b (a0),d1
	subq.l #1,d1
	addq.l #1,a0
normloop:
	move.b (a0)+,(a1)+
	addq.l #1,d0
	cmp.l d4,d0
	beq.s eende
	dbf d1,normloop
	bra.s eloop1
crunch:
	clr.l d1
	move.b (a0),d1
	and.b #$7f,d1	
	move.b 1(a0),d2
	subq #1,d1
eloop2:
	move.b d2,(a1)+
	addq.l #1,d0
	cmp.l d4,d0
	beq.s eende
	dbf d1,eloop2
	addq.l #2,a0	
	bra.s eloop1
eende:
	rts

initmouse:	
	move 	$dff00a,d0
	move	d0,d1
	lsr	#8,d1
	and	#$ff,d0
	move	d0,oldx
	rts
	
MouseHandler:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b	auto
	beq.s	handler2

	clr.l	d5
	lea	sprite1(pc),a3
	move.b	1(a3),d5
	lsl	#1,d5
	sub	#162,d5

	move	d5,mousx
	lsl	#1,d5
	move	d5,imgx
	bra	endhandler
handler2:
If	DemoVer
	bra.L	endhandler
Else

	tst.b	joy1
	beq	m24
	move	$dff00a,d0
	btst	#9,d0
	beq.s	nli1
	sub	#4,mousx
	sub	#8,imgx
	bra.s	endhandler
nli1:
	btst	#1,d0
	beq.s	nre1
	addq	#4,mousx
	add	#8,imgx
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
notrev:
	clr.w	d2

	move.b	oldx,d2
	move.b	d0,oldx

	sub.b	d0,d2			
	tst.b	d2
	beq.s	endhandler
	move.b	d2,d4
	tst.b	d2
	bpl.s	mous1
	neg.b	d2
mous1:	
	cmp.b	#127,d2
	bgt.s	mous2
	ext	d4
	sub	d4,imgx
	bra.s	endhandler
mous2:	
	sub.b	#255,d4
	ext	d4
	sub	d4,imgx
EndIf
endhandler:
	move	imgx,d0			
	asr	#1,d0			

	tst	d0
	bgt.s	mous7
	clr	d0
	clr	imgx
mous7:
	tst.b	battle
	bne.s	mous86
	tst.b	twoplayer
	bne.s	twocheck	
mous86:
	tst	FromList
	beq.s	NoList2

	cmp	#254,d0
	blt.s	mous8
	move	#255,d0
	move	#510,imgx
	bra.s	mous8
NoList2:
	cmp	#149,d0
	blt.s	mous8
	move	#150,d0
	move	#300,imgx
	bra.s	mous8
TwoCheck:
	cmp	#61,d0
	bls.s	mous8
	move	#61,d0
	move	#122,imgx
mous8:	
	move	d0,d5
	sub	d5,mousx
	move	mousx,dist
	move	d0,mousx

	tst.b	battle
	bne.s	tpl
	tst.b	twoplayer 
	bne.s	tpl
	tst.b	twoschl
	bne.s	tschl
	
	move	d0,mousx2
	lsl	#1,d0
	move	d0,imgx2
	bra	endhand		
tschl:
	move.l	schl(pc),d1
	lea	tabelle3(pc),a1
	lsr	#1,d1
	add.l	d1,a1
	move	(a1),d1
	sub	d0,d1
	move	d1,mousx2
	lsl	#1,d1
	move	d1,imgx2
	bra	endhand
tpl:
	tst.b	auto
	beq.s	handler22

	clr.l	d5
	lea	sprite1(pc),a3
	move.b	1(a3),d5
	lsl	#1,d5
	sub	#162,d5

	move	d5,mousx2
	lsl	#1,d5
	move	d5,imgx2
	bra	endhandler2
handler22:
If	DemoVer
Else

	tst.b	joy2
	beq.s	m25
	move	#4,d5
	move	#8,d6
	tst.b	revers
	beq.s	nrc
nrc:
	neg.b	d5
	neg.b	d6

	move $dff00c,d0
	btst #9,d0
	beq.s nli2
	sub #4,mousx2
	sub #8,imgx2
	bra.s endhandler2
nli2:
	btst	#1,d0
	beq.s	nre2
	add	#4,mousx2
	add	#8,imgx2
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
	sub.w	d4,imgx2
	bra.s	endhandler2
mous22:
	sub.b	#255,d4
	ext.w	d4
	sub.w	d4,imgx2
EndIf
endhandler2:
	move.w	imgx2,d0		
	asr.w	#1,d0			

	tst.b	battle
	beq.s	mous453

	cmp	#0,d0
	bgt.s	mous72
	move.w	#0,d0
	move.w	#0,imgx2
	bra.s	mous72
mous453:
	cmp	#90,d0
	bgt.s	mous72
	move.w	#91,d0
	move.w	#182,imgx2
mous72:	
	cmp.w	#149,d0
	blt.s	mous82
	move.w	#150,d0
	move.w	#300,imgx2
mous82:	
	move d0,d5
	sub d5,mousx2
	move mousx2,dist2
	move d0,mousx2
endhand:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

oldx:	dc.b	0,0
imgx:	dc.w	0

oldx2:	dc.b	0,0
imgx2:	dc.w	120

dist:	dc.w	0
mousx:	dc.w	0
mousy:	dc.w	0
dist2:	dc.w	0
mousx2:	dc.w	60

even
doslib:
	dc.b 'dos.library',0
even
gfxlib:
	dc.b 'graphics.library',0
even
picname1:
	dc.b 'rahmenc',0
even
picname2:
	dc.b 'backgroundc',0
even:
picname3:
	dc.b 'pic1',0
even
dosbase:
	dc.l 0
gfxbase:
	dc.l 0
screen1:
	dc.l $60000
screen2:
	dc.l $4a000
screen3:
	dc.l $56800
filehandle1:
	dc.l 0
filehandle2:
	dc.l 0
filehandle3:
	dc.l 0

copperl:
dc.w $00e0,$0006
dc.w $00e2,$0000	
dc.w $00e4,$0006
dc.w $00e6,$1f40	
dc.w $00e8,$0006
dc.w $00ea,$3e80	
dc.w $00ec,$0006
dc.w $00ee,$5dc0	
dc.w $00f0,$0006
dc.w $00f2,$7d00	
dc.w $00f4,$0006
dc.w $00f6,$9c40	
copperspr:
dc.w $0120,$7
dc.w $0122,$0	
dc.w $0124,$7
dc.w $0126,$0	
dc.w $0128,$7
dc.w $012a,$0	
dc.w $012c,$7
dc.w $012e,$0	
dc.w $0130,$7
dc.w $0132,$0	
dc.w $0134,$7
dc.w $0136,$0
dc.w $0138,$7
dc.w $013a,$0	
dc.w $013c,$7
dc.w $013e,$0	

coppercol:
	dc.w $0180,$0
	dc.w $0182,$0
	dc.w $0184,$0
	dc.w $0186,$0
	dc.w $0188,$0
	dc.w $018a,$0
	dc.w $018c,$0
	dc.w $018e,$0

	dc.w $0190,$0ddd
	dc.w $0192,$0aaa
	dc.w $0194,$0ccc
	dc.w $0196,$0f00
	dc.w $0198,$0666
	dc.w $019a,$0999
	dc.w $019c,$0aab
	dc.w $019e,$0960
piccol:
	dc.w $01a0,$003
	dc.w $01a2,$ddd	
	dc.w $01a4,$aaa
	dc.w $01a6,$113

	dc.w $01a8,$320
fsprcol:
	dc.w $01aa,$310
	dc.w $01ac,$850
	dc.w $01ae,$640
pic2col:
	dc.w $01b0,$740
	dc.w $01b2,$751
	dc.w $01b4,$a72
	dc.w $01b6,$850
	dc.w $01b8,$862
	dc.w $01ba,$a71
	dc.w $01bc,$d93
	dc.w $01be,$fff		

dc.w $0098,$f208
dc.w $0180,$0000	

dc.w $008e,$2c79	
dc.w $0090,$f4c1	
dc.w $0100,$6200	
dc.w $0104,$0024	
dc.w $0092,$0038	
dc.w $0094,$00d2	

dc.w $0102,$0000	
dc.w $0108,$0000	

powerturm:
dc.w $018a,$000
dc.w $010a,$0000	

dc.w $2e21,$fffe

dc.w $018a,$00f0
cycle2:
dc.w $01be,$f00

dc.w $3521,$fffe
dc.w $018a,$02f0
dc.w $1be,$f20

dc.w $3c21,$fffe
dc.w $018a,$03f0
dc.w $1be,$f40

dc.w $4321,$fffe
dc.w $018a,$04f0
dc.w $1be,$f60

dc.w $4a21,$fffe
dc.w $018a,$05f0
dc.w $1be,$f80

dc.w $5121,$fffe
dc.w $018a,$06f0
dc.w $1be,$fa0

dc.w $5821,$fffe
dc.w $018a,$07f0
dc.w $1be,$fc0

dc.w $5f21,$fffe
dc.w $018a,$08f0
dc.w $1be,$fe0

dc.w $6621,$fffe
dc.w $018a,$09f0
dc.w $1be,$ef0

dc.w $6d21,$fffe
dc.w $018a,$0af0
dc.w $1be,$cf0

dc.w $7421,$fffe
dc.w $018a,$0bf0
dc.w $1be,$af0

dc.w $7b21,$fffe
dc.w $018a,$0ce0
dc.w $1be,$8f0

dc.w $8221,$fffe
dc.w $018a,$0dd0
dc.w $1be,$6f0

dc.w $8921,$fffe
dc.w $018a,$0ed0
dc.w $1be,$4f0

dc.w $009c,$8010		

dc.w $9021,$fffe
dc.w $018a,$0fc0
dc.w $1be,$2f0

dc.w $9721,$fffe
dc.w $018a,$0fb0
dc.w $1be,$2f0

dc.w $9e21,$fffe
dc.w $018a,$0fa0
dc.w $1be,$2f0

dc.w $a521,$fffe
dc.w $018a,$0f90
dc.w $1be,$0f0

dc.w $ac21,$fffe
dc.w $018a,$0f80
dc.w $1be,$0f2

dc.w $b321,$fffe
dc.w $018a,$0f70
dc.w $1be,$0f4

dc.w $ba21,$fffe
dc.w $018a,$0f60
dc.w $01be,$0f6

dc.w $c121,$fffe
dc.w $018a,$0f50
dc.w $1be,$0f8

dc.w $c821,$fffe
dc.w $018a,$0f30
dc.w $1be,$0fa

dc.w $d821,$fffe
schl_col:
dc.w $018a,$f00
dc.w $0190,$ddd
dc.w $0192,$aaa
dc.w $0194,$ccc
dc.w $0196,$999
dc.w $0198,$666
dc.w $019a,$999
dc.w $019c,$fff
dc.w $019e,$aaa

cycle1:
dc.w $018a,$f00
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

copperl2:
	dc.w $00e0,$0006
	dc.w $00e2,$0000	
	dc.w $00e4,$0006
	dc.w $00e6,$1f40	
	dc.w $00e8,$0006
	dc.w $00ea,$3e80	
	dc.w $00ec,$0006
	dc.w $00ee,$5dc0	
	dc.w $00f0,$0006
	dc.w $00f2,$7d00	
	dc.w $00f4,$0006
	dc.w $00f6,$9c40	

	dc.w $0120,$7
	dc.w $0122,$0	
	dc.w $0124,$7
	dc.w $0126,$0	
	dc.w $0128,$7
	dc.w $012a,$0	
	dc.w $012c,$7
	dc.w $012e,$0	
	dc.w $0130,$7
	dc.w $0132,$0	
	dc.w $0134,$7
	dc.w $0136,$0	
	dc.w $0138,$7
	dc.w $013a,$0	
	dc.w $013c,$7
	dc.w $013e,$0	
coppercol2:
	dc.w $0180,$0
	dc.w $0182,$0
	dc.w $0184,$0
	dc.w $0186,$0
	dc.w $0188,$0
	dc.w $018a,$0
	dc.w $018c,$0
	dc.w $018e,$0
	dc.w $0190,$0
	dc.w $0192,$0
	dc.w $0194,$0
	dc.w $0196,$0
	dc.w $0198,$0
	dc.w $019a,$0
	dc.w $019c,$0
	dc.w $019e,$0
	dc.w $01a0,$0
	dc.w $01a2,$0	
	dc.w $01a4,$0
	dc.w $01a6,$3
	dc.w $01a8,$0
	dc.w $01aa,$0
	dc.w $01ac,$0
	dc.w $01ae,$0
	dc.w $01b0,$0
	dc.w $01b2,$0
	dc.w $01b4,$0
	dc.w $01b6,$0
	dc.w $01b8,$0
	dc.w $01ba,$0
	dc.w $01bc,$0
	dc.w $01be,$0		

	dc.w $0180,$0000	
	dc.w $18a,$0
	dc.w $008e,$2c79	
	dc.w $0090,$f4c1	
	dc.w $0100,$6200	
	dc.w $0104,$0024	
	dc.w $0092,$0038	
	dc.w $0094,$00d2	
	dc.w $0102,$0000	
	dc.w $0108,$0000	
	dc.w $010a,$0000	
	dc.w $ffff,$fffe

shoot1:
dc.w $0000,$0000
dc.w $4002,$4002
dc.w $E007,$E007
dc.w $E007,$E007
dc.w $4002,$4002
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
;dc.w $A005,$A005

fspr3:
dc.w 0,0
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
blk.l	10,0

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
dc.w $1DC0,$1dc0
dc.w $1DC0,$1dc0
dc.w $1DC0,$1dc0
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

sprite1:
	dc.w $0,$0
	dc.w $0,$00
	dc.w $38,$04
	dc.w $7C,$02
	dc.w $78,$06
	dc.w $78,$06
	dc.w $70,$0E
	dc.w $0,$3C
	dc.w $0,$0
sprite2:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $38,$04
	dc.w $7C,$02
	dc.w $78,$06
	dc.w $78,$06
	dc.w $70,$0E
	dc.w $0,$3C
	dc.w $0,$0
spr1:
	dc.l sprite1		
	dc.b 0,0,1,1	
spr2:
	dc.l sprite2		
	dc.b 0,0,1,2	
hit:
	dc.w 0
zspeicher:
	blk 300,0
flashlist:
	blk 300,0
even
checkball:
	move.l	(A1),a0
	move.b	4(A1),d1
	move.b	5(A1),d2
	move.b	6(A1),d3
	move.b	7(A1),d4

	tst.b	d4
	bmi	endcheck

	cmpi.b	#218,d2
	bls	endcheck
	cmpi.b	#222,d2
	bhi	endcheck
	
	move	mousx,d5
	lsr.b	#1,d5
	add.b	#74,d5

	tst.b	battle
	beq.s	daneben236
	cmp.l	#5,schl
	beq.s	daneben2
daneben236:
	cmp.b	d5,d1
	blo.s	daneben2
	bne.s	nr1
	move.b	#-1,d3
nr1:
	move.l	schl,d6
	lsl.l	#1,d6
	lea	tabelle2(pc),a2
	add.l	d6,a2
	add	(a2),d5			

	cmp.b	d5,d1
	bhi.s	daneben2
	bne.s	nr2
	move.b	#1,d3
nr2:
	move	dist,d6
	move.b	#-1,kept
	bra.s	treffer
daneben2:
	tst.b	battle
	beq.s	daneben237
	cmp.l	#5,schl2
	beq	daneben
daneben237:
	move	mousx2,d5
	lsr.b	#1,d5
	add.b	#74,d5

	cmp.b	d5,d1
	blo	daneben
	bne.s	nr3
	move.b	#-1,d3
nr3:
	move.l	schl,d6
	lsl.l	#1,d6
	lea	tabelle2(pc),a2
	add.l	d6,a2
	add	(a2),d5			

	cmp.b	d5,d1
	bhi	daneben
	bne.s	nr4
	move.b	#1,d3
nr4:
	move	dist2,d6
	move.b	#1,kept
treffer:
	bsr	soundon3
	move.b	#217,d2
	move.b	d2,(a0)
	addq.b	#7,d2
	move.b	d2,2(a0)
	subq.b	#7,d2

	tst.b	hold
	beq.s	donthold
	move	#1,kept2
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
	cmpi.b	#4,d4
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
	cmpi.b	#4,d4
	bhi.s	loop2
	moveq	#3,d4		

loop2:				
	neg.b	d4
daneben:
endcheck:
	move.b d4,7(a1)		
	move.b d3,6(a1)		
	move.b d2,5(a1)		
	move.b d1,4(a1)		
	rts
Lc:
	dc.w	0

checkspry:
	cmpi.b	#250,d2
	bhi.s	weiterc5
	rts
weiterc5:
	tst.b	twoball
	bne.s	extwo
	move.b	#1,exploding
	rts
Extwo:
	clr.b	twoball
	cmp.l	#sprite1,a0
	bne.s	notthe2

	lea	sprite1(pc),a4
	lea	sprite2(pc),a5
	move.l	(a5),(a4)
	lea	spr1+4,a4
	lea	spr2+4,a5
	move.l	(a5),(a4)
	move.b	(a5),d1
	move.b	1(a5),d2
	move.b	2(a5),d3
	move.b	3(a5),d4
notthe2:
	lea	sprite2(pc),a5
	clr.b	1(a5)
	rts

CheckBlock:
	move.b	d5,d1
	move.b	d6,d2

	cmp.b	#78,d1
	bhi.s	ok78
	rts
ok78:
	sub.b	#78,d1
	sub.b	#50,d2
	lsr	#3,d1
	lsr	#3,d2
	cmp	#13,d1
	bne.s	CheckBlock2
	move	#11,d1
CheckBlock2:
	clr.b	changed
	move	d1,x4
	lea	zspeicher+14(pc),a4
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
	add.l	#10,score
	clr.l	d0		
	clr.l	d1		
	lea	zspeicher+14(pc),a5
	mulu	#11,d2
	add	d2,a5
	divu	#11,d2
	moveq	#10,d6
testloop1:
	cmp.b	#8,(a5)
	beq.s	delnot1
	clr.b	(a5)
	bsr	draw_block
delnot1:
	addq	#1,d1
	addq	#1,a5
	dbra	d6,testloop1
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
	addq.l	#5,score
	clr.l	d0
	bsr	draw_block
	tst.b	smash
	bne.s	noinv
	neg.b	d4
	move.b	#1,changed
	bsr	soundon
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
	lea	flashlist(pc),a3
	add	x4,a3
	add	y4,a3
	move.b	d5,(A3)	

	neg.b	d4
	move.b	#1,changed
	bsr	SoundOn2
notcol:
	move.b	sicher,d0
	rts

SoundOn3:
	lea	$dff000,a5
	move	#1,$96(A5)
	move.l	#BallStock,$a0(A5)
	move	#2512,$a4(A5)
	move	#180,$a6(A5)
	move	#4,SoundCNT1
	move	#$8001,$96(A5)
	rts
SoundOn5:
	lea	$dff000,a5
	move	#4,$96(A5)
	move.l	#SpritePlopp,$c0(A5)
	move	#4217,$c4(A5)
	move	#250,$c6(A5)
	move	#20,SoundCNT3
	move	#$8004,$96(A5)
	rts
SoundOn6:
	lea	$dff000,a5
	move	#4,$96(A5)
	move.l	#SpritePlopp,$c0(A5)
	move	#4217,$c4(A5)
	move	#120,$c6(A5)
	move	#8,SoundCNT3
	move	#$8004,$96(A5)
	rts
SoundOn4:
	lea	$dff000,a5
	move	#4,$96(A5)
	move.l	#SpritePlopp,$c0(A5)
	move	#4217,$c4(A5)
	move	#180,$c6(A5)
	move	#15,SoundCNT3
	move	#$8004,$96(A5)
	rts
SoundOn7:
	lea	$dff000,a5
	move	#4,$96(A5)
	move.l	#Harve,$c0(A5)
	move	#13000,$c4(A5)
	move	#170,$c6(A5)
	move	#35,SoundCNT3
	move	#$8004,$96(A5)
	rts
SoundOn2:
	lea	$dff000,a5
	move	#2,$96(A5)
	move.l	#BallHolz,$b0(A5)
	move	#1166,$b4(a5)
	move	#180,$b6(A5)
	move	#2,SoundCNT2
	move	#$8002,$96(A5)
	rts
SoundOn:
	lea	$dff000,a5
	move	#1,$96(A5)
	move.l	#BallStein,$a0(a5)
	move	#2382,$a4(A5)
	move	#180,$a6(A5)
	move	#4,SoundCNT1
	move	#$8001,$96(A5)
	rts

Font:
	blk.b	[10*12],0
	dc.b	0,0,0,0,0,0,0,0,0,$3e
	dc.b	0,0,0,0,$7e,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,16,0,0
	blk.b	10,0
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
	blk.b	70,0
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
endfont:
sicher:
	dc.w	0
extend:
	dc.l 	0
extend2:
	dc.l	0
twoplayer:
	dc.b	0
battle:
	dc.b	0
twoball:
	dc.b	0
twoschl:
	dc.b	0
smash:
	dc.b	0
falling:
	dc.b	0
even
fcounter:
	dc.w	0
bonus:
	dc.b	0
lives:
	dc.b	0
oldlives:
	dc.b	0
excounter:
	dc.b	0
excounter2:
	dc.b	0
hold:
	dc.b	0
alter:
	dc.b	0
kept:
	dc.b	0
demo:
	dc.b	0
auto:
	dc.b	0
Key:
	dc.b	0
OldKey:
	dc.b	0
revers:
	dc.b	0
even
kept2:
	dc.w	0
Cheat:
	dc.w	0
laser:
	dc.b	0
piccounter:
	dc.b	'1'
c1cnt:
	dc.w	0
c2cnt:
	dc.w	0
lasercnt:
	dc.w	0
vol1:
	dc.w	60
vol2:
	dc.w	60
powercnt2:
	dc.w	0
power:
	dc.w	0
power2:
	dc.w	0
lcnt:
	dc.w	0
sprite3:
	dc.l	0
fdir:
	dc.b	1
level:
	dc.b	0
laenge1:
	dc.l	40000
score:
	dc.l	0
hiscore:
	dc.l	0
shiptable:
	dc.l	2500,5000,10000,25000,100000,250000,-1,-1
stc:
	dc.l 0
oldvek:
	dc.l 0
paused:
	dc.b 0
exploding:
	dc.b 0
leftout:
	dc.b 0
rightout:
	dc.b 0
nlevel:
	dc.b 0
plevel:
	dc.b 0
Y:
	dc.w 0
lochcnt:
	dc.w 0
lochcnt2:
	dc.w 1
lochdir:
	dc.w 0
locnt1:
	dc.l 0
open1:
	dc.w	280
locnt2:
	dc.w	0
open2:
	dc.w	0
powercol:
	blk.w	25,$a9b

orgpowercol:
	dc.w	$0f0,$2f0,$3f0,$4f0,$5f0,$6f0,$7f0,$8f0,$9f0
	dc.w	$af0,$bf0,$ce0,$dd0,$ed0,$fc0,$fb0,$fa0,$f90
	dc.w	$f80,$f70,$f60,$f50,$f30,$f00,$f00
X2:
	dc.w	0
X:
	dc.w	0
powersoll:
	dc.w	0
lochx:
	dc.w	80
lochdir2:
	dc.w	0
lgamecnt:
	dc.w	0
lgame:
	dc.b	0,0
bahn:
	dc.l	$75000
tempo:
	dc.w 20
playcnt:
	dc.w 0
tempo2:
	dc.w 0
waiter:
	dc.w 0
blink:
	dc.w 0
waitb:
	dc.w 0
slow:
	dc.w 0
slowcnt:
	dc.w	0
fast:
	dc.w 1
joy1:
	dc.b 0
joy2:
	dc.b 1
f2cnt:
	dc.w 0
menucnt:
	dc.w	0
mousepos:
	dc.w	0
oldmpos:
	dc.w	0

menucolor=$965
menucolor2=$ECA

LoadSound:
	cmp.l	#$600002d6,$20000
	beq.s	NoLoadSound
LoadErr10:
	move	#2,command
	move.l	#$20000,Ziel
	move.l	#188*512,Offset
	move.l	#220*512,Laenge
	bsr	StartTask
	bsr	Wait_Load
	cmp.l	#$c0690204,summ
	bne.s	LoadErr10
NoLoadSound:
	rts
Menu:
	lea	$dff000,a5
	move.l	#copperl4,$80(A5)
	clr	$a8(A5)
	clr	$b8(A5)
	clr	$c8(A5)
	clr	$d8(A5)

If	DemoVer
	clr	Lc
EndIf
	bsr	LoadSound
	jsr	$20008			; INIT
LoadBack:
	move	#2,Command
	move.l	Screen1,Ziel
	move.l	#79*512,Laenge
	move.l	#MenuPic,Offset
	bsr	StartTask
	bsr	Wait_Load
	cmp.l	#$ABDAEBCB,Summ
	bne.s	LoadBack

	move	#6,command
	bsr	StartTask

	move.l	#$c840,d4			
	move.l	screen2,a1			
	move.l	screen1,a0			
	bsr	decruncher

	move.l	screen2,a1
	add.l	#$c800,a1
	lea	copperl3col+2,a2

	moveq	#31,d7
colentry:
	move	(A1)+,(A2)
	addq.l	#4,a2
	dbra	d7,colentry		

	lea	rightcol2+2,a1
	lea	rightcol+2,a2
	move	(A1),(A2)		

	lea	CopMenuSpr+48,a1
	move.l	#MenuSpr,d0
	move	d0,6(A1)
	swap	d0
	move	d0,2(A1)
	lea	MenuSpr,a1
	move.l	#$7bb88900,(A1)		; Sprite positionieren

	clr	mousepos
	clr	menucnt
	move	#10,oldxpos2
	move	$dff00a,suber
	sub	#64,suber
	move.l	#copperl3,$dff080
	move	#$8120,$dff096
	move.l	$6c,OldInt2
	move.l	#MenuInt,$6c
repmenu:
	move.l	gfxbase(pc),a6
	jsr	-270(a6)

	addq	#1,menucnt
If	DemoVer
	cmp	#2000,MenuCnt
Else
	cmp	#4800,menucnt
EndIF
	bne.s	notfifteen

	lea	FromMenu+1,a1
	not.b	(A1)
	tst.b	(A1)
	bne.s	GoDemo
GoList:
	move.l	hiscore,score
	move.l	#'HISC',d0
	bra	endmenu
GoDemo:
	move.b	#1,Auto
	move.b	#1,Demo
	clr.b	TwoPlayer
	clr.b	Battle
	clr.l	d0
	bra	EndMenu			
NotFifteen:
	clr.l	d0
	move	oldmpos,d1
	move	$dff00a,d0
	sub	suber,d0
	move	d0,oldmpos	

	cmp	d0,d1
	beq	dontclear
	clr	menucnt
dontclear:
	and	#$ff00,d0
	lsr	#8,d0
	lsr	#5,d0
	move	d0,mousepos

	cmp	#7,mousepos
	bne.s	notsex
	move	#6,mousepos
notsex:
	lea	menut,a1
clearcol:
	move.l	(A1),a2
	move	#menucolor,2(A2)
	addq.l	#4,a1
	tst.l	(A1)
	bne.s	clearcol		

	lea	joystick+2(pc),a1
	lea	mouse+2(pc),a2
	lea	ccnon+2(pc),a3
	lea	ccnoff+2(pc),a4

	tst.b	joy2
	beq.s	notjoy2			
	move	#menucolor2,(A1)
	move	#menucolor,(A2)
	bra.s	weiter3
notjoy2:
	move	#menucolor,(A1)
	move	#menucolor2,(A2)
weiter3:
	tst.b	ccn
	beq.s	notccn2			
	move	#menucolor2,(A3)
	move	#menucolor,(A4)
	bra.s	weiter4
notccn2:
	move	#menucolor,(A3)
	move	#menucolor2,(A4)
weiter4:
	move	mousepos(pc),d0
	lsl	#2,d0
	lea	menut(pc),a1
	move.l	(A1,d0.w),a2
	move	#menucolor2,2(A2)

	bsr	PrintL

	btst	#10,$dff016
	beq.s	DF

	cmp.b	#$7f,$bfec01
	beq.s	DF

	btst	#6,$bfe001
	bne	RepMenu			
DF:
	cmp.b	#$7f,$bfec01
	beq	GoList

	move	MousePos(pc),d0
	tst	d0
	bne.s	notlb1

	clr.b	twoplayer
	clr.b	battle
	move.l	#'EDIT',d0
	bra	endmenu			
notlb1:
	cmp	#1,d0
	bne.s	notplay1

If	DemoVer
	move.b	#1,demo
EndIf
	clr.b	twoplayer
	clr.b	battle
	clr.l	d0
	bra	endmenu			
notplay1:
	cmp	#2,d0
	bne.s	notplay2

If	DemoVer
	move.b	#1,demo
EndIf
	clr.b	battle
	move.b	#1,twoplayer
	clr.l	d0
	bra	endmenu			
notplay2:
	cmp	#3,d0
	bne.s	notplay3
	
If	DemoVer
	move.b	#1,demo
	move.b	#1,twoplayer
	clr.b	battle
Else
	move.b	#1,twoplayer
	move.b	#1,battle
EndIf
	clr.l	d0
	bra	endmenu			
notplay3:
	cmp	#4,d0
	bne.s	notpl2

	bchg	#0,joy2
waitplease:
	btst	#6,$bfe001
	beq.s	waitplease
	btst	#10,$dff016
	beq.s	waitplease
notpl2:
	cmp	#5,d0
	bne.s	notccnt			
	bchg	#0,ccn
waitplease2:
	btst	#6,$bfe001
	beq.s	waitplease2	
	btst	#10,$dff016
	beq.s	waitplease2
notccnt:
	cmp	#6,d0
	bne.s	notst

	move	#5,verz
updown:
	move	verz,d7
updown2:
	move.l	gfxbase,a6
	jsr	-270(A6)
	dbra	d7,updown2

	cmp	#1,verz
	beq.s	nomoresub
	subq	#1,verz
nomoresub:
	lea	stagename+5(pc),a1
	btst	#6,$bfe001
	bne.s	nota

	subq.b	#1,(a1)
	cmp.b	#'A'-1,(A1)
	bne.s	notA
	move.b	#'A',(A1)
notA:
	btst	#10,$dff016
	bne.s	notb

	addq.b	#1,(A1)
	cmp.b	#'O'+1,(A1)
	bne.s	notb
	move.b	#'O',(A1)
notb:
	clr	MenuCnt
	bsr	printl
	btst	#6,$bfe001
	beq.s	updown
	btst	#10,$dff016
	beq.s	updown
notst:
	bra	repmenu

endmenu:
	lea	menuspr,a1
	clr.l	(A1)
	move.l	d0,wert
	bsr	delliner
	move.l	OldInt2,$6c
	jsr	$20014
	move.l	wert,d0
	rts

MenuInt:
	movem.l	d0-d7/a0-a6,-(A7)
	jsr	$2000c
	movem.l	(A7)+,d0-d7/a0-a6
	dc.w	$4ef9
OldInt2:
	dc.l	0

delliner2:
	move.l	screen1,scr
	move.l	#8000,plane
	clr.l	d4
	move.l	#199,d5
	move.l	d5,d2
	bra.s	delit23

delliner:
	move.l	#$2800,plane
	move.l	screen2,scr
	clr.l	d4
	move.l	#$ff,d5
	move.l	d5,d2
delit23:
	not.b	wert22
	tst.b	wert22
	beq.s	nowait		

	move.l	gfxbase,a6
	jsr	-270(A6)
nowait:
	tst	$20000+24
	beq.s	SchonNull
	subq	#1,$20000+24
SchonNull:
	move.l	scr,a1
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

delline:			
	movem.l	d0-d7/a0-a2,-(sp)
	mulu	#40,d3
	add.l	d3,a1

	moveq	#9,d7
clline:
	move.l	a1,a2
	moveq	#4,d6
clbpl:
	clr.l	(A2)
	add.l	plane,a2	
	dbra	d6,clbpl	

	addq.l	#4,a1
	dbra	d7,clline	
	movem.l	(sp)+,d0-d7/a0-a2
	rts

wert:
	dc.l	0	

endmenu2:
	tst	loading
	bne.s	endmenu2
	move	#$100,$dff096
	rts

printl:
	lea	stagename+5(pc),a0
	lea	MenuSpr+4,a1
	move.b	(A0),d0
	sub.b	#' ',d0
	mulu	#10,d0
	lea	font+1(pc),a2
	add	d0,a2

	moveq	#6,d7
prt:
	clr.l	d0
	move.l	d0,d1
	move.b	(A2)+,d0
	move.b	d0,d1
	moveq	#7,d3
double:
	roxr	#1,d0
	roxr	#1,d2
	roxr	#1,d1
	roxr	#1,d2	
	dbra	d3,double

	move	d2,(A1)
	move	d2,2(A1)
	move	d2,4(A1)
	move	d2,6(A1)
	addq.l	#8,a1
	dbra	d7,prt
	rts

copperl4:
	dc.w	$008e,$2c81
	dc.w	$0090,$20c1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0
	dc.w	$0100,$1200
	dc.w	$0108,$0
	dc.w	$010a,$0
	dc.w	$180,$0
	dc.w	$182,$0
	dc.w	$96,$120
	dc.w	$ffff,$fffe		

copperl3:
copperl3col:
	dc.w	$0180,$0
	dc.w	$0182,$0
	dc.w	$0184,$0
	dc.w	$0186,$0
	dc.w	$0188,$0
	dc.w	$018a,$0
	dc.w	$018c,$0
	dc.w	$018e,$0
	dc.w	$0190,$0
	dc.w	$0192,$0
	dc.w	$0194,$0
	dc.w	$0196,$0
	dc.w	$0198,$0
rightcol2:
	dc.w	$019a,$0
	dc.w	$019c,$0
	dc.w	$019e,$0
	dc.w	$01a0,$0
	dc.w	$01a2,$0
	dc.w	$01a4,$0
	dc.w	$01a6,$0
	dc.w	$01a8,$0
	dc.w	$01aa,$0
	dc.w	$01ac,$0
	dc.w	$01ae,$0
	dc.w	$01b0,$0
	dc.w	$01b2,$0
much:
	dc.w	$01b4,$0
stagecol:
	dc.w	$01b6,$0
mouse:
	dc.w	$01b8,$0
joystick:
	dc.w	$01ba,$0
ccnon:
	dc.w	$01bc,$0
	dc.w	$01be,$0

	dc.w	$00e0,$0004
	dc.w	$00e2,$a000

	dc.w	$00e4,$0004
	dc.w	$00e6,$c800

	dc.w	$00e8,$0004
	dc.w	$00ea,$f000

	dc.w	$00ec,$0005
	dc.w	$00ee,$1800

	dc.w	$00f0,$0005
	dc.w	$00f2,$4000

	dc.w	$008e,$2c81
	dc.w	$0090,$20c1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0
	dc.w	$0100,$5200
	dc.w	$0108,$0
	dc.w	$010a,$0
CopMenuSpr:
	dc.w	$0120,$7
	dc.w	$0122,$0
	dc.w	$0124,$7
	dc.w	$0126,$0
	dc.w	$0128,$7
	dc.w	$012a,$0
	dc.w	$012c,$7
	dc.w	$012e,$0
	dc.w	$0130,$7
	dc.w	$0132,$0
	dc.w	$0134,$7
	dc.w	$0136,$0
	dc.w	$0138,$7
	dc.w	$013a,$0
	dc.w	$013c,$7
	dc.w	$013e,$0

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
much1:
	dc.w	$1b4,$fff

	dc.w	$6421,$fffe
	dc.w	$19a,$70f
	dc.w	$1be,menucolor2

	dc.w	$6821,$fffe
	dc.w	$19a,$80f

	dc.w	$6c21,$fffe
	dc.w	$19a,$90f
much2:
	dc.w	$1b4,$f00

	dc.w	$7021,$fffe
	dc.w	$19a,$a0f
	
	dc.w	$7421,$fffe
	dc.w	$19a,$b0f

	dc.w	$7821,$fffe
	dc.w	$19a,$c0f

	dc.w	$7c21,$fffe
	dc.w	$19a,$d0f
much3:
	dc.w	$1b4,$0f0

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
much4:
	dc.w	$1b4,$f00
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
ccnoff:
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
much5:
	dc.w	$1b4,$0ff

	dc.w	$c421,$fffe
	dc.w	$19a,$f50

	dc.w	$c821,$fffe
	dc.w	$19a,$f60

	dc.w	$cc21,$fffe
	dc.w	$19a,$f70

	dc.w	$d021,$fffe
	dc.w	$19a,$f80

	dc.w	$d421,$fffe
rightcol:
	dc.w	$19a,$fff
	
	dc.w	$ffff,$fffe
demornd:
	dc.w	0
oldxpos:
	dc.w	0
oldxpos2:
	dc.w	6
suber:
	dc.w	0

opentrd:
	move.l	4,a6
	sub.l	a1,a1
	jsr	-294(a6)	
	move.l	d0,readrep+$10
	
	lea	readrep(pc),a1
	jsr	-354(a6)	
	
	lea	diskIO(pc),a1

If	Final
	moveq	#0,d0
Else
	moveq	#1,d0
EndIf
	clr.l	d1
	lea	trddevice(pc),a0
	jsr	-444(a6)	
	
	lea	diskIO(pc),a1
	move.l	#readrep,14(A1)
	rts

CloseTrd:
	move.l	4,a6
	lea	readrep(pc),a1
	jsr	-360(A6)

	lea	diskIO(pc),a1
	jsr	-450(A6)	
	rts

motor_off:
	move.l	4,a6
	lea	diskIO(pc),a1
	move	#9,28(A1)
	clr.l	36(A1)
	jsr	-456(a6)
	rts

clearbuff:
	move.l	4,a6
	lea	diskIO(pc),a1
	move	#5,28(A1)
	jsr	-456(a6)
	rts

diskIO:
	blk.l	20,0
readrep:
	blk.l	8,0
trddevice:
	dc.b	'trackdisk.device',0

	menupic=512*1364
	rahmenc=512*1328
	backgroundc=512*1278
	stagebase=512*1447
	picbase=512*910

even
InitTask:
	move.l	4,a6
	clr.l	d1
	move.l	#3000,d0
	jsr	-198(a6)
	tst.l	d0
	bne.s	OKmem
	rts
OKmem:
	move.l	d0,stackmem
	move.l	d0,stack1
	move.l	d0,stack2
	add.l	#4990,d0
	move.l	d0,stack3

	move.l	4,a6
	move.l	#-1,d0
	jsr	-330(A6)	

	move.l	d0,signalnummer
	clr.l	d1
	bset	d0,d1
	move.l	d1,signalmaske	

	lea	task(pc),a2
	lea	taskstrc(pc),a1
	sub.l	a3,a3
	jsr	-282(a6)		
	rts

RemoveTask:
	move	#6,command
	bsr	StartTask		
	move	#1,command
	bsr	StartTask		
	move.l	signalnummer,d0
	jsr	-336(a6)		
	move.l	stackmem,a1
	move.l	#3000,d0
	jsr	-210(A6)		
	rts

StartTask:
	move.l	4,a6
	lea	taskstrc(pc),a1	
	move.l	signalmaske,d0
	jsr	-324(a6)		
	rts
Task:
	bsr	OpenTrd
Task2:
	move.l	4,a6
	move.l	signalmaske,d0
	jsr	-318(a6)

	move	command,d0
	cmp	#1,d0
	beq	endtask

	cmp	#2,d0
	beq	readtrack

	cmp	#3,d0
	beq	writetrack

	cmp	#4,d0
	beq	readpic

	cmp	#5,d0
	beq	loadgame

	cmp	#6,d0
	beq	motor0

	cmp	#7,d0
	beq.s	Protect
	bra.s	task2
Protect:
	move	#1,loading
	move.l	4,a6
	lea	diskIO,a1
	move	#15,28(A1)
	jsr	-456(A6)
	move.l	32(A1),Result
	clr	loading
	bra.s	task2
motor0:
	bsr	motor_off
	bra	task2
diskscore=185*512

loadgame:
	move	#1,loading
	move.l	4,a6
	lea	diskIO(pc),a1
	move	#2,28(A1)
	move.l	#$5000,36(a1)
	move.l	#buffer,40(A1)
	move.l	#rahmenc,44(A1)
	jsr	-456(a6)		
	tst.l	d0
	beq.s	OkLoadGame
	bsr	Delay
	bra.s	LoadGame
OkLoadGame:
	move.l	screen1,a1
	lea	buffer,a0
	move.l	#40000,d4
	bsr	decruncher
notload5:
ReadPic:
	move	#1,loading
	sub.l	d0,d0
	move.b	piccounter,d0
	sub.b	#'1',d0
	mulu	#512*46,d0
	add.l	#picbase,d0
	move.l	4,a6
	lea	diskIO(pc),a1
	move	#2,28(A1)
	move.l	#512*46,36(a1)
	move.l	d0,44(A1)
	move.l	#buffer,40(A1)
	jsr	-456(a6)
	tst.l	d0
	beq.s	OKReadPic
	bsr	Delay
	bra.s	ReadPic
OkReadPic:
	bsr	motor_off
	clr	loading
	move	#1,loaded

	add.b	#1,piccounter
	cmp.b	#'9',piccounter
	bne.s	not65
	move.b	#'1',piccounter
not65:
	bra	task2
Result:
	dc.l	$60fc3e52
ReadTrack:
	move	#1,loading
	move.l	4,a6
	lea	diskIO,a1
	move	#5,28(A1)
	move.l	Offset,44(A1)
	move.l	Laenge,36(A1)
	move.l	Ziel,40(A1)
	jsr	-456(a6)
	lea	diskIO,a1
	move	#2,28(A1)
	move.l	Offset,44(A1)
	move.l	Laenge,36(A1)
	move.l	Ziel,40(A1)
	jsr	-456(a6)
	tst.l	d0
	beq.s	OkTrack
	bsr	Delay
	bra.s	ReadTrack
OkTrack:
	bsr	Check
	clr	loading
	bra	task2

WriteTrack:
	move	#1,loading
	move.l	4,a6
	lea	diskIO,a1
	move	#3,28(A1)
	move.l	Offset,44(A1)
	move.l	Laenge,36(A1)
	move.l	Ziel,40(A1)
	jsr	-456(a6)
	lea	diskIO(pc),a1
	move	#4,28(A1)
	move.l	Offset,44(A1)
	move.l	Laenge,36(A1)
	move.l	Ziel,40(A1)
	jsr	-456(A6)		
	tst.l	d0
	beq.s	OkWrite
	bsr	Delay
	bra.s	WriteTrack
OkWrite:
	clr	loading
	bra	task2
endtask:
	bsr	closetrd
	rts

Check:
	move.l	Ziel,a0
	move.l	Laenge,d7
	lsr	#2,d7
	subq	#1,d7
	clr.l	d0
CheckSum:
	add.l	(a0)+,d0
	neg.l	d0
	dbra	d7,CheckSum
	move.l	d0,SUMM
	rts
SUMM:
	bra	checksum
Delay:
	move.l	gfxbase,a6
	moveq	#25,d7
Dela:
	jsr	-270(A6)
	dbra	d7,Dela
	rts

taskstrc:
	dc.l 0
	dc.l 0
	dc.b 0			
	dc.b 0			
	dc.l 0			
	dc.l 0			
	dc.l 0			
	dc.l 0			
	dc.w 0			
	dc.w 0			
	dc.l 0			
	dc.l 0			
	dc.l 0			
	dc.l 0			
stack1:
	dc.l 0			
stack2:
	dc.l 0			
stack3:
	dc.l 0			
start:
	dc.l 0			
	dc.l 0			
	dc.l 0			
	dc.l 0
	dc.l 0
signalmaske:
	dc.l	0
signalnummer:
	dc.l	0
command:
	dc.w	0
stackmem:
	dc.l	0
loading:
	dc.w	0
Offset:
	dc.l	0
Laenge:
	dc.l	0
Ziel:
	dc.l	0
Read=2
Write=3
Remove=4
even

wait_load:
	tst	loading
	bne.s	wait_load
	rts
loaded:
	dc.w	0
mode1:
	dc.b	1

even
namenslaenge = 8	
max_entry    = 100

GetPosition:	
	movem.l	a0/d1/d2,-(a7)
	lea	hilist(pc),a0
	clr	d2
hi_score_loop1:
	addq	#1,d2
	cmp	#max_entry+1,d2
	beq.s	found_entry
	add.l	#namenslaenge,a0
	move.l	(A0)+,d1
	cmp.l	d0,d1
	bhi.s	hi_score_loop1
found_entry:
	move	d2,d0
	cmp	#max_entry+1,d2
	bne.s	end_search_score
	clr	d0
end_search_score: 
	movem.l	(a7)+,a0/d1/d2
	rts

SaveHiScore:
If	DemoVer
	rts
Else
	lea	copcol5(pc),a1
	move	#$f00,6(A1)

	move	#7,command
	bsr	StartTask
	bsr	Wait_Load
	tst.l	result
	beq.s	Prot

	lea	page1+[48*70]+16,a1
	lea	ProtText(pc),a0
	bsr	PrintText2

	lea	page1+[48*100]+10,a1
	lea	ProtText2(pc),a0
	bsr	PrintText2

	clr	Ticks
	move	#$8100,$dff096
waithi:
	move.l	GfxBase(pc),a6
	jsr	-270(A6)

	move	ticks,d0
	and	#$3f,d0
	cmp	#$1f,d0
	blo.s	Black

	move	#$f00,d4
	bra.s	DoCol
Black:
	move	#$a00,d4
DoCol:
	lea	copcol5(pc),a1
	move	d4,6(A1)

	addq	#1,Ticks
	cmp	#500,ticks
	beq.s	EndTick
	
	btst	#10,$dff016
	bne.s	waithi
EndTick:
	rts
Prot:
	move	#3,command
	move.l	#$600,laenge
	move.l	#DiskScore,offset
	move.l	#hilist,ziel
	bsr	StartTask
	bsr	Wait_Load
	rts
ProtText:
	dc.b	'COULD NOT SAVE HI-SCORE',0
ProtText2:
	dc.b	'PRESS RIGHT MOUSE-BUTTON TO CONTINUE',0
EndIf
even
PrintName:
	movem.l	d0-d7/a0-a5,-(sp)
	lea	playername,a0
	move.l	#page1+1981+[3*9600],a1	
	bsr	printtext2
	movem.l	(sp)+,d0-d7/a0-a5
	rts

GetName:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	playername,a4
Keyit:
	bsr	PrintName
	bsr	GetKey
	tst	d1
	beq.s	KeyIt

	lea	bob1,a1
	cmp.l	#animseq2,54(A1)
	beq.s	notkl
	move.l	#animseq2,54(A1)
notkl:
	cmp.b	#$FF,d0
	bne.s	node

	cmp.l	#PlayerName,a4
	beq.s	KeyIt
	move.b	#44,-(A4)
	bra.s	KeyIt
NoDe:
	cmp.b	#$FD,d0
	beq.s	EndEnter		
		
	cmp.l	#Endname,a4
	beq.s	NoInsert
	move.b	d0,(A4)			
NoInsert:	
	cmp.l	#EndName,a4		
	beq.s	NoAdd
	addq.l	#1,a4
NoAdd:
	bra.s	KeyIt
EndEnter:	
	lea	PlayerName,a0
	cmp.l	#'AMIG',(A0)
	bne.s	NoCheat
	cmp.l	#'A 88',4(A0)
	bne.s	NoCheat
	
	move.l	#' CRA',(A0)
	move.l	#'CK  ',4(A0)
	move	#1,cheat
NoCheat:
	lea	HiList,a1
	move.l	place,d0
	subq.l	#1,d0
	mulu	#12,d0
	add.l	d0,a1
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)		
	movem.l	(sp)+,d0-d7/a0-a6
	rts

	dc.w	$5400







InsertScore:
	movem.l	d0-d2/a0-a2,-(a7)
	tst	d0			
	beq.s	end_hi			
	subq	#1,d0
	lea	hilist(pc),a0
	move.l	a0,a2
	mulu	#namenslaenge+4,d0
	add.l	d0,a0			
	move	#max_entry,d2
	mulu	#namenslaenge+4,d2
	add.l	d2,a2			

	cmp.l	a2,a0			
	beq.s	not_last
hi_score_loop2:
	move	-12(a2),(a2)		
	subq	#2,a2			
	cmp.l	a2,a0
	bne.s	hi_score_loop2
not_last:
	move.l	(a1)+,(a0)+		
	move.l	(a1)+,(a0)+		
	move.l	d1,(a0)			
end_hi:
	movem.l	(a7)+,d0-d2/a0-a2
	rts

place:
	dc.l	0
points:
	dc.l	0
refresh:
	dc.w	0
blocks:
	dc.w	0,0,0
docnt:
	dc.w	0
refy:
	dc.w	0
flashcnt:
	dc.w	1
spr:
	dc.l	0
sprite:
	dc.l	0
changed:
	dc.b	0
even
GetKey:
	movem.l	d2-d7/a0-a5,-(sp)
	clr.l	d1
Get2:
	clr.l	d0
	move.b	$bfec01,d0
	btst	#0,d0
	beq.s	Get2		
Wait2:
	move.b	$bfec01,d0	
StillPress:
	not.b	d0
	ror.b	#1,d0
	lea	CodeTabelle,a1	
	move.b	(A1,d0),d0
	tst.b	d0
	beq.s	Get2

	move.b	d0,Key
	cmp.b	OldKey,d0
	bne.s	NotTheOld

	moveq	#10,d7
Verzo:
	move.l	gfxbase,a6
	jsr	-270(A6)
	dbra	d7,Verzo

	clr.b	OldKey
	bra.s	Get2
NotTheOld:
	move.b	Key,OldKey
	move.b	Key,d0
	moveq	#1,d1
EndGet:
	movem.l	(sp)+,d2-d7/a0-a5
	rts

CodeTabelle:
	DC.B	0,'1','2','3','4','5','6','7','8','9','0'
	DC.B	'-','=',0,0,'0','Q','W','E','R','T','Y','U'
	DC.B	'I','O','P',0,0,0,'1','2','3','A','S','D'
	DC.B	'F','G','H','J','K','L',0,0,0,0,'4','5','6'
	DC.B	0,'Z','X','C','V','B','N','M','.','.','?'
	DC.B	0,'.','7','8','9',' ',$FF,0,$FD,$FD,0,$FF
	dc.b	0,0,0,'-'
	BLK.B	100,0
even
hilist:
	blk.b	1536,0
PlayerName:
	dc.b	' CRACK  '
endname:
	dc.w	0
endgame:
	dc.w	0
endgame2:
	dc.w	0
menut:
	dc.l	much		
	dc.l	much1		
	dc.l	much2		
	dc.l	much3		
	dc.l	much4		
	dc.l	much5		
	dc.l	stagecol	

	dc.l	mouse		
	dc.l	joystick	
	dc.l	ccnon		
	dc.l	ccnoff		
	dc.l	0

off:
	move.l	gfxbase(pc),a6
	move.l	38(A6),$dff080
	rts
le=40*256*5

verz:
	dc.w	50
ccn:
	dc.b	1,0
x4:
	dc.w	0
y4:
	dc.w	0
wert22:
	dc.b	0,0
scr:
	dc.l	0
plane:
	dc.l	0
endinter:
	dc.w	0

l1   = 4788		
l2   = 1680		
l3   =  384		
page22 = $38000
page12 = page22+54400
bobs2 = page12+54400
worm2 = bobs2+[26*l1]
nut2 = worm2+[7*l2]			; ALLES REINLADEN
save12 = nut2+[5*l3]
save22 = save12+l1+2000
save32 = save22+l1+2000
save42 = save32+l2+2000
save52 = save42+l2+2000
save62 = save52+l3+2000
bildaddr=save62+600
ystart=176
yend=16

CCNut:
	movem.l	d1-d7/a0-a6,-(A7)	
	lea	$dff000,a4
	clr	$a8(A4)
	clr	$b8(A4)
	clr	$c8(A4)
	clr	$d8(A4)
	bsr	Wait_Load
Checker:
	cmp.l	#$91313781,summ
	beq.s	NoLoadErr

	move	#2,command
	move.l	#bobs2,ziel
	move.l	#512*96,laenge
	move.l	#512*627,offset
	bsr	StartTask
	bsr	Wait_Load
	bra.s	Checker
NoLoadErr:
	lea	bobs2,a0
	lea	page12,a1
	move.l	#51200,d4	
	bsr	decruncher		; BILD

	lea	nut2,a1
	move	#l3,d7
CNut:
	clr.l	(A1)+
	dbra	d7,CNut			; Nuss loeschen
LoadErr7:
	move	#2,command
	move.l	#bobs2,ziel
	move.l	#512*89,laenge
	move.l	#512*723,offset
	bsr	StartTask
	bsr	Wait_Load
	cmp.l	#$ac0d6320,Summ
	bne.s	LoadErr7
LoadErr8:
	move	#2,command
	move.l	#bildaddr,ziel
	move.l	#512*1,laenge
	move.l	#512*184,offset
	bsr	StartTask
	bsr	Wait_Load
	cmp.l	#$7bca88a9,summ
	bne.s	LoadErr8
	move.l	#bobs2,lowwr
	move.l	#bobs2+45448,readc
	bsr	decru			; BOBS

	move	#2,command
	move.l	#$20000,ziel
	move.l	#512*8,laenge
	move.l	#512*176,offset
	bsr	StartTask
	bsr	Wait_Load
	move	#6,command
	bsr	StartTask

	lea	Bob32,a1
	clr.l	8(A1)			; Nuss reseten
	lea	bob22,a1
	clr	8(A1)
	move	#150,10(A1)
	move	#29,20(A1)
	clr.l	50(A1)
	move.l	#animseq22,54(A1)
	move.l	#moveprg22,58(A1)
	clr	62(A1)
	move	#1,64(A1)
	clr.l	66(A1)		; Wurm reseten
	clr	70(A1)

	lea	Leer,a1
	lea	$dff000,a4
	move.l	a1,$a0(a4)
	move.l	a1,$b0(A4)
	moveq	#1,d4
	move	d4,$a4(A4)
	move	d4,$b4(A4)
	move.l	#$20064,$c0(A4)
	move	#1938,$c4(A4)
	move	#500,$c6(A4)
	move.l	#$20064,$d0(A4)
	move	#1938,$d4(A4)
	move	#500,$d6(A4)
	move	#$800f,$96(A4)

	clr.l	d0
	move	vol1,d0
	divu	#3,d0
	move	d0,$dff0c8
	move	d0,$dff0d8

	lea	page12,a1
	lea	page22,a2
	moveq	#4,d3
rcopy2:
	move	#2559,d6
recopy:
	move.l	(A1)+,(A2)+
	dbra	d6,recopy
	add.l	#640,a2
	dbra	d3,rcopy2

	lea	bob12,a1	
	lea	bob22,a2
	lea	bob32,a3
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

	move.l	#page22,a1
	move.l	#page12,a2
	move	#13599,d7	
CopyL:
	move.l	(A1)+,(A2)+
	dbra	d7,CopyL

	move	#160,y2
	move	#160,y1
	clr	stopcnt
	clr	timer
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
	lea	ColorMap2(pc),a0
	lea	ColorBuffer2(pc),a1

	moveq	#31,d7
Colorm2:
	move	(A0)+,(A1)+
	dbf	d7,Colorm2

	lea	bob12,a1	
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
	move.l	$6c,VBlankveq2		
	move.l	#VBlankInt2,$6c	
	move	#$8010,$dff09a		
wt:
	tst	stopCNT
	beq.s	wt

	move.l	VBlankVeq2,$6c		
	moveq	#40,d5
fer:
	move.l	gfxbase,a6
	jsr	-270(A6)
	dbra	d5,fer

	move	#$10F,$dff096
	move.l	#copperl4,$dff080
	move	NutCounter,d0		
	ext.l	d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts

BLS:
	lea	bildaddr+32,a1
	lsl.l	#5,d3
	add.l	d3,a1
	moveq	#16,d6
Msp:
	move	(A1)+,(A2)
	addq.l	#4,a2
	dbra	d6,Msp
	rts

DoTheSprite:
	move	NutCounter,d0
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
NoChange:
	subq	#1,y1
	cmp	#yend,y1
	bne.s	notend

	move	#ystart,y1	
	move	#1,flag1
notend:
	lea	CCNspr3,a0
	move	y1,d0
	bsr	dospr			; letzte Ziffer bewegen
	tst	flag1
	beq.s	notscroll2

	subq	#1,y2
	cmp	#yend,y2
	bne.s	noty2
	move	#ystart,y2
noty2:
	addq	#1,flag1
	cmp	#17,flag1
	bne.s	notflag1
	clr	flag1
notflag1:
	lea	CCNspr2,a0
	move	y2,d0
	bsr	dospr			; 2.Ziffer bewegen
notscroll2:
	rts

dospr:
	move.l	a0,a1
	add.l	#60,a1
	moveq	#14,d7			; d0=ypos
scroll:					; a1=spr
	move.l	(A1),4(A1)
	subq.l	#4,a1

	dbra	d7,scroll		; sprite scrollen

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

wspr:
	move.l	a0,a1
	add.l	#4,a1
	
	move.l	#bildaddr,a2
	move	d0,d1
	lsl	#1,d1
	add	d1,a2

	moveq	#15,d7			; d0=ypos
write23:
	move	(A2)+,(A1)+
	clr	(A1)+
	dbra	d7,write23
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

VBlankInt2:
	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	$1e(A6),d0
	btst	#4,d0			
	beq	EndVblank2
	btst	#5,d0
	bne	EndVblank2

	bsr	DoTheSprite
	lea	bitmstr12+8,a0
	tst	FlipFlag
	beq.s	NoFlip22
	lea	Bitmstr22+8,a0
NoFlip22:
	lea	BitmapPtr2+2,a1
	moveq	#4,d7
page_loop2:				
	move.l	(a0),d0			
	move	d0,4(a1)
	swap	d0
	move	d0,(A1)
	addq	#4,a0
	addq	#8,a1
	dbf	d7,page_loop2

	addq	#1,Timer
	cmp	#1583,Timer
	bne.s	CCNNotZero
	move	#1,stopcnt
CCNnotzero:
	tst	GameLock
	bne	NoMoveNut
LetsGame:
	bsr	AskJoy
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
	move	Hupfoffset2,d0		
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
	lea	bob12,a0			
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
	blt	NoxCor			
	sub	#38,8(A0)		
	tst	8(a0)
	bpl.s	NoXCor
	clr	8(a0)
NoxCor:
	addq	#1,d1			
	cmp	#10,d1			
	blt	NoDirCor2	
	clr	d1			
NoDirCor2:
	move	d1,20(A0)		
NoRight:
	btst	#7,d0			
	beq	NoJump
	move	8(A0),Xoffset2		
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
	bsr	rnd
	add	#20,d0
	move	d0,d1
	move	#33,20(A0)		
	move	d1,8(A0)
NoNewX:
If	DemoVer
	move	#1,d3
Else
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
	lea	$dff000,a5
	move	#$3,$96(A5)
	move.l	#NussFangen+500,$a0(A5)
	move	#550,$a4(A5)
	move	#180,$a6(A5)
	move.l	#NussFangen,$b0(A5)
	move	#800,$b4(A5)
	move	#170,$b6(A5)
	move	#$8003,$96(A5)
	move	vol1,$a8(A5)
	move	vol1,$b8(A5)

	move	#1000,d5
SndLoop:
	dbra	d5,SndLoop

	move.l	#Leer,$a0(A5)
	move	#1,$a4(A5)
	move.l	#Leer,$b0(A5)
	move	#1,$b4(A5)

	move	#5,WaitLock	
	bra.s	NoMoveNut
EndIf
NoFang:
	addq	#2,10(A0)	
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
	bsr	fang	
	bra	NoMoveNut
Fang:
	lea	Bob32,a0
	clr	10(A0)			
	move	#34,20(A0)		
	rts
NoMoveNut:
	bsr	drawbobs2		
	bsr	Cycle			
	bsr	SetCol			
	move	#$10,$dff09c
	not	FlipFlag
EndVblank2:
	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9			
VBlankveq2:
	dc.l	0			

ColorSum:
	dc.w	0
NutCounter:
	dc.w	0
AnimCounter2:
	dc.w	0
WaitCounter:
	dc.w	0
JoyWert:
	dc.w	0
WaitLock:
	dc.w	0
AskJoy:
	movem.l	a0/d1,-(A7)
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

AskMouse:
	move.l	Mouse2,a0
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
NOCrit2:
	cmp	d0,d1
	bhi	XLeft
	bset	#1,d2
	bra.s	NoXChange
XLeft:
	bset	#3,d2	
NoXchange:
	move	d3,OldMouse
	move	d2,d0
	move.b	$bfe001,d1
	not	d1
	and	#$40,d1
	lsl	#1,d1
	or	d1,d0
	bra	EndAskJoy
joy:
	dc.l	$dff00c
Mouse2:
	dc.l	$dff00a
OldMouse:
	dc.w	0
JoyMouseFlag:
	dc.w	-1
SetCol:
	lea	ColorBuffer2,a0
	lea	$dff180,a1
	moveq	#31,d0
SetColLoop:
	move	(A0)+,(A1)+
	dbf	d0,SetColLoop
	rts

Cycle:
	addq	#1,CycleCounter
	cmp	#5,CycleCounter
	bne	EndCycle
	clr	CycleCounter
	lea	ColorBuffer2,a0
	move	62(A0),d0
	move	60(A0),62(A0)
	move	58(A0),60(A0)
	move	56(A0),58(A0)
	move	d0,56(A0)
EndCycle:
	rts

CycleCounter:
	dc.w	0
JumpLock:
	dc.w	0
GameLock:
	dc.w	0
FlipFlag:
	dc.w	0

CopperlCCN:
	dc.w	$1001,$fffe
	dc.w	$009c,$8010
	dc.w 	$008e,$2881
	dc.w 	$0090,$28c1
	dc.w 	$0104,$0024
	dc.w 	$0092,$0038
	dc.w 	$0094,$00d2
	dc.w 	$0102,$0000
	dc.w 	$0108,0
	dc.w 	$010a,0

	dc.w	$0120,$7
	dc.w	$0122,$0
	dc.w	$0124,$7
	dc.w	$0126,$0
CCNCopperSpr:
	dc.w	$0128,$7
	dc.w	$012a,$0
	dc.w	$012c,$7
	dc.w	$012e,$0
	dc.w	$0130,$7
	dc.w	$0132,$0
	dc.w	$0134,$7
	dc.w	$0136,$0
	dc.w	$0138,$7
	dc.w	$013a,$0
	dc.w	$013c,$7
	dc.w	$013e,$0
BitmapPtr2:
	dc.w 	$00e0,$0004
	dc.w 	$00e2,$0000
	dc.w 	$00e4,$0004
	dc.w 	$00e6,$1f40
	dc.w 	$00e8,$0004
	dc.w 	$00ea,$3e80
	dc.w 	$00ec,$0004
	dc.w 	$00ee,$5dc0
	dc.w	$00f0,$0004
	dc.w	$00f2,$7d00
	dc.w	$0100,$5200
Color3:
	dc.w	$1aa,$fff
	dc.w	$1b2,$fff
	dc.w	$1b6,$c
	dc.w	$4021,$fffe
	dc.w	$1aa,$666
	dc.w	$1b2,$ddd
	dc.w	$ffff,$fffe 

bitmstr12:
	dc.w	40
	dc.w	256
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page12
	dc.l	page12+[1*10880]
	dc.l	page12+[2*10880]
	dc.l	page12+[3*10880]
	dc.l	page12+[4*10880]

bitmstr22:
	dc.w	40
	dc.w	256
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page22
	dc.l	page22+[1*10880]
	dc.l	page22+[2*10880]
	dc.l	page22+[3*10880]
	dc.l	page22+[4*10880]

DrawBobs2:
	movem.l	d0-d7/a0-a6,-(A7)
	lea	BobList2,a0
	lea	$dff000,a6

SearchLastBob2:				
	tst.l	(A0)		
	beq	BobReconstLoop2
	move.l	(A0),a0
	bra	SearchLastBob2
	
BobReconstLoop2:
	lea	bitmstr12,a2
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

BlitWait22:
	btst	#14,2(A6)
	bne	BlitWait22
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

	lea	Bitmstr12,a2
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

BlitWait32:
	btst	#14,2(A6)
	bne	BlitWait32
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
BlitWait12:
	btst	#14,2(A6)
	bne	BlitWait12
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
	lea	Bitmstr12,a1
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

BobImageList2:
	dc.l	bobs2		
	dc.l	bobs2+[1*l1]	
	dc.l	bobs2+[2*l1]	
	dc.l	bobs2+[3*l1]	
	dc.l	bobs2+[4*l1]	
	dc.l	bobs2+[5*l1]	
	dc.l	bobs2+[6*l1]	
	dc.l	bobs2+[7*l1]	
	dc.l	bobs2+[8*l1]	
	dc.l	bobs2+[9*l1]	
	dc.l	bobs2+[10*l1]	
	dc.l	bobs2+[11*l1]	
	dc.l	bobs2+[12*l1]	
	dc.l	bobs2+[13*l1]	
	dc.l	bobs2+[14*l1]	
	dc.l	bobs2+[15*l1]	
	dc.l	bobs2+[16*l1]	
	dc.l	bobs2+[17*l1]	
	dc.l	bobs2+[18*l1]	
	dc.l	bobs2+[19*l1]				
	dc.l	bobs2+[20*l1]				
	dc.l	bobs2+[21*l1]				
	dc.l	bobs2+[22*l1]				
	dc.l	bobs2+[23*l1]
	dc.l	bobs2+[24*l1]
	dc.l	bobs2+[25*l1]

	dc.l	Worm2+[0*l2] 	
	dc.l	Worm2+[1*l2]	
	dc.l	Worm2+[2*l2]	
	dc.l	Worm2+[3*l2]	
	dc.l	Worm2+[4*l2]	
	dc.l	Worm2+[5*l2]	
	dc.l	Worm2+[6*l2]	
	
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
	dc.l	save12		
	dc.l	save22		
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
	dc.l	Bob32		; WORM
	dc.w	80,28
	dc.w	0,150		
	dc.w	-1,-1		
	dc.w	-1,-1		
	dc.w	29	
	dc.w	0	
	dc.w	0		
	dc.l	save32		
	dc.l	save42		
	dc.w	0	
	dc.l	0	
	dc.l	0	
	dc.l	bob12		
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
	dc.l	save52		
	dc.l	save62		
	dc.w	0		
	dc.l	0		
	dc.l	0		
	dc.l	bob22		
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

MovePrg22:
	dc.w	247,1		
	dc.w	247,2		
	dc.w	-1

AnimSeq22:
	dc.w	26,27,26,27,26,27,26,27,26,27
	dc.w	26,27,26,27,26,27,26,27,26,27
	dc.w	26,27,26,27,26,27,26,27
	dc.w	32,31,30
	dc.w	28,29,28,29,28,29,28,29,28,29
	dc.w	28,29,28,29,28,29,28,29,28,29
	dc.w	28,29,28,29,28,29,28,29
	dc.w	30,31,32
	dc.w	-1

ColorMap2:
	DC.L	$00000EBA,$0DA90C98,$0B870A76,$09650854
	DC.L	$07540643,$05320421,$032108C8,$06A60484
	DC.L	$03730252,$03330444,$05550666,$07770999
	DC.L	$0BBB0DDD,$0c7900dd,$0BEF08EF,$07DF00DF

ColorBuffer2:
	blk.w	32,0

HupfOffset2:
	dc.w	0
XOffset2:
	dc.w	0

HupfTab2:
	dc.w	1,87
	dc.w	3,83
	dc.w	11,73
	dc.w	14,70
	dc.w	18,67,26,60,41,52,46,51,51,50,62,52,71,56,73,58
	dc.w	75,61,80,67,83,75,83,80,84,85,85,87,-1
		


away:
	dc.b	0,0
MenuSpr:
	blk.w	50,0
shape1:
	dc.w	0
shape2:
	dc.w	0
shape3:
	dc.w	0
shape4:
	dc.w	0
shape5:
	dc.w	0
EyeBuff:
	blk.b	20,0
eye2:
	dc.w	0

pal=50
explsound=$18000
countdown=$18000

CCNspr2:
	dc.w	$3046,$4000
	blk.l	17,0
CCNspr3:
	dc.w	$304c,$4000
	blk.l	17,0
y1:
	dc.w	160
y2:
	dc.w	160
flag1:
	dc.w	0
flag2:
	dc.w	0
stopcnt:
	dc.w	0
timer:
	dc.w	0
mesg:
	dc.b	'ADDING BONUS TO YOUR SCORE',0
ScoreASC:
	dc.b	'0000000',0
even
congtable:
	dc.l	$60000+3379
	dc.l	cong1
	dc.l	$60000+4808
	dc.l	cong2
	dc.l	$60000+5771
	dc.l	cong3
	dc.l	0,0,0
cong1:
	dc.b	'CONGRATULATIONS....',0
cong2:
	dc.b	'YOU ARE ONE OF THE GREATEST CRACK-PLAYER',0
cong3:
	dc.b	'THANK YOU VERY MUCH FOR PLAYING .',0
even
CNTSpr1:
	blk.l	20,0
CNTSpr2:
	blk.l	20,0
Nut22:
	dc.w	0
FromCCN:
	dc.w	0
BattleTime:
	dc.w	0
WaitSound:
	tst	SoundCNT1
	bhi.s	WaitSound
WaitSound2:
	tst	SoundCNT2
	bhi.s	WaitSound2
	rts

LANZE1:
	dc.w $0000,$0000
	dc.w $0100,$0080
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0000,$0180
	dc.w $0180,$0240
	dc.w $03C0,$0400
	dc.w $03C0,$0400
	dc.w $0380,$0440
	dc.w $0380,$0000
	dc.w $0100,$0280
	dc.w $0100,$0000
	dc.w $0000,$0000
GKUGEL1:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$07E0
	dc.w $0380,$0C70
	dc.w $0600,$19F8
	dc.w $0C00,$33FC
	dc.w $0800,$37FC
	dc.w $0808,$37F4
	dc.w $0008,$3FF4
	dc.w $0010,$3FEC
	dc.w $0000,$1FF8
	dc.w $0000,$0FF0
	dc.w $0000,$07E0
	dc.w $0000,$0000
	dc.w $0000,$0000
MAN1:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0200
	dc.w $0000,$0100
	dc.w $0000,$0080
	dc.w $0000,$0040
	dc.w $0000,$0020
	dc.w $0000,$0020
	dc.w $0000,$0020
	dc.w $0000,$0020
	dc.w $0000,$0040
	dc.w $0000,$0080
	dc.w $0000,$0100
	dc.w $0000,$0200
	dc.w $0000,$0200
	dc.w $0000,$0400
	dc.w $0000,$0400
	dc.w $0000,$0E00
	dc.w $0000,$1E00
	dc.w $0000,$1E00
	dc.w $0280,$0C00
	dc.w $0BE8,$0400
	dc.w $0FFC,$0000
	dc.w $1FFE,$0000
	dc.w $00FE,$0F00
	dc.w $007F,$1F80
	dc.w $007E,$1F80
	dc.w $10FF,$0F00
	dc.w $1FFE,$2000
	dc.w $14FC,$6B00
	dc.w $8000,$7FF8
	dc.w $C000,$3FF8
	dc.w $F000,$0FD8
	dc.w $E1C0,$1E3C
	dc.w $E0C0,$1F3E
	dc.w $60C0,$1F1E
	dc.w $3080,$0F00
	dc.w $0000,$3700
	dc.w $0000,$1800
	dc.w $0000,$7C00
	dc.w $0000,$0000
	dc.w $0000,$0000
MAN2:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0800
	dc.w $0000,$1000
	dc.w $0000,$2000
	dc.w $0000,$4000
	dc.w $0000,$C000
	dc.w $0000,$8000
	dc.w $0000,$8000
	dc.w $0000,$8000
	dc.w $0000,$4000
	dc.w $0000,$2000
	dc.w $0000,$1000
	dc.w $0000,$0800
	dc.w $0000,$0800
	dc.w $0000,$0400
	dc.w $0000,$0400
	dc.w $0000,$0E00
	dc.w $0000,$1E00
	dc.w $0000,$1E00
	dc.w $0280,$0C00
	dc.w $0BE8,$0400
	dc.w $0FFC,$0000
	dc.w $1FFE,$0000
	dc.w $00FE,$0F00
	dc.w $007F,$1F80
	dc.w $007E,$1F80
	dc.w $10FF,$0F00
	dc.w $1FFE,$2000
	dc.w $14FC,$6B00
	dc.w $8000,$7FF8
	dc.w $C000,$3FF8
	dc.w $F000,$0FD8
	dc.w $E1C0,$1E3C
	dc.w $E0C0,$1F3E
	dc.w $60C0,$1F1E
	dc.w $3080,$0F00
	dc.w $0000,$3700
	dc.w $0000,$1800
	dc.w $0000,$7C00
	dc.w $0000,$0000
	dc.w $0000,$0000
Blatt1:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$600C
	dc.w $600C,$9012
	dc.w $F01E,$0820
	dc.w $F83E,$0440
	dc.w $3C78,$0280
	dc.w $0780,$0040
	dc.w $0380,$0000
	dc.w $0000,$0100
	dc.w $0000,$0100
	dc.w $0000,$0100
	dc.w $0100,$0000
	dc.w $0380,$0000
	dc.w $0180,$0200
	dc.w $0180,$0200
	dc.w $0380,$0000
	dc.w $0380,$0000
	dc.w $0100,$0000
	dc.w $0000,$0000
Blatt2:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$3018
	dc.w $3018,$4824
	dc.w $745C,$0820
	dc.w $3AB8,$0440
	dc.w $1BB0,$0440
	dc.w $0540,$0280
	dc.w $0380,$0000
	dc.w $0000,$0100
	dc.w $0000,$0100
	dc.w $0000,$0100
	dc.w $0100,$0000
	dc.w $0380,$0000
	dc.w $0180,$0200
	dc.w $0180,$0200
	dc.w $0380,$0000
	dc.w $0380,$0000
	dc.w $0100,$0000
	dc.w $0000,$0000
Blatt3:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $1010,$0820
dc.w $0820,$1450
dc.w $1AB0,$0440
dc.w $0AA0,$0440
dc.w $0540,$0280
dc.w $0100,$0280
dc.w $0380,$0000
dc.w $0000,$0100
dc.w $0000,$0100
dc.w $0000,$0100
dc.w $0100,$0000
dc.w $0380,$0000
dc.w $0180,$0200
dc.w $0180,$0200
dc.w $0380,$0000
dc.w $0380,$0000
dc.w $0100,$0000
dc.w $0000,$0000
Blatt4:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0820
dc.w $0820,$0440
dc.w $0820,$0440
dc.w $0280,$0440
dc.w $0440,$0280
dc.w $0380,$0000
dc.w $0380,$0000
dc.w $0000,$0100
dc.w $0000,$0100
dc.w $0000,$0100
dc.w $0100,$0000
dc.w $0380,$0000
dc.w $0180,$0200
dc.w $0180,$0200
dc.w $0380,$0000
dc.w $0380,$0000
dc.w $0100,$0000
dc.w $0000,$0000
Blatt5:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0280,$0440
dc.w $0540,$0280
dc.w $0540,$0280
dc.w $06C0,$0100
dc.w $0280,$0100
dc.w $0280,$0100
dc.w $0380,$0000
dc.w $0000,$0100
dc.w $0000,$0100
dc.w $0000,$0100
dc.w $0100,$0000
dc.w $0380,$0000
dc.w $0180,$0200
dc.w $0180,$0200
dc.w $0380,$0000
dc.w $0380,$0000
dc.w $0100,$0000
dc.w $0000,$0000
Blatt6:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0100
dc.w $0100,$0000
dc.w $0100,$0000
dc.w $0100,$0000
dc.w $0100,$0000
dc.w $0100,$0000
dc.w $0100,$0000
dc.w $0000,$0100
dc.w $0000,$0100
dc.w $0000,$0100
dc.w $0100,$0000
dc.w $0380,$0000
dc.w $0180,$0200
dc.w $0180,$0200
dc.w $0380,$0000
dc.w $0380,$0000
dc.w $0100,$0000
dc.w $0000,$0000
CRACK1:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $03C0,$0000
dc.w $07E0,$0000
dc.w $0E70,$0180
dc.w $0C00,$0270
dc.w $0C00,$0200
dc.w $0C00,$0200
dc.w $0C60,$0210
dc.w $0FE0,$0010
dc.w $07C0,$0020
dc.w $0000,$03C0
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK2:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $07E0,$0000
dc.w $0E70,$0180
dc.w $0C00,$0270
dc.w $0C00,$0200
dc.w $0C60,$0210
dc.w $0FE0,$0010
dc.w $07C0,$0020
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK3:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $07E0,$0000
dc.w $0E70,$0180
dc.w $0C00,$0200
dc.w $0C60,$0390
dc.w $07C0,$0020
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK4:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0FE0,$0010
dc.w $0FE0,$0010
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK5:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0CE0,$0300
dc.w $0FE0,$0000
dc.w $0C60,$0390
dc.w $0FC0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK6:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0C60,$0210
dc.w $0FC0,$0000
dc.w $0FE0,$0000
dc.w $0C60,$0390
dc.w $0FE0,$0000
dc.w $0FC0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK7:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0840,$0630
dc.w $0C60,$0210
dc.w $0C60,$0210
dc.w $0CE0,$0300
dc.w $0FC0,$0000
dc.w $0FE0,$0000
dc.w $0C60,$0210
dc.w $0C60,$0390
dc.w $0FE0,$0000
dc.w $0FC0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK8:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0C60,$0210
dc.w $0FC0,$0000
dc.w $0FE0,$0000
dc.w $0C60,$0390
dc.w $0FE0,$0000
dc.w $0FC0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK9:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0CE0,$0300
dc.w $0FE0,$0000
dc.w $0C60,$0390
dc.w $0FC0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK10:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0FE0,$0010
dc.w $0FE0,$0010
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK11:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0FE0,$0010
dc.w $0C60,$0210
dc.w $0E60,$0190
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK12:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0C60,$0390
dc.w $0FE0,$0010
dc.w $0C60,$0210
dc.w $0E60,$0190
dc.w $0FF0,$0000
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK13:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0840,$0630
dc.w $0C60,$0210
dc.w $0C60,$0390
dc.w $0FE0,$0010
dc.w $0FE0,$0010
dc.w $0C60,$0210
dc.w $0C60,$0210
dc.w $0E60,$0190
dc.w $0FF0,$0000
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK14:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0C60,$0390
dc.w $0FE0,$0010
dc.w $0C60,$0210
dc.w $0E60,$0190
dc.w $0FF0,$0000
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK15:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0FE0,$0010
dc.w $0C60,$0210
dc.w $0E60,$0190
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK16:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0FE0,$0010
dc.w $0FE0,$0010
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK17:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $07C0,$0020
dc.w $0C60,$0390
dc.w $0C00,$0200
dc.w $0E70,$0180
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK18:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $07C0,$0020
dc.w $0FE0,$0010
dc.w $0C60,$0210
dc.w $0C00,$0200
dc.w $0C00,$0270
dc.w $0E70,$0180
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK19:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$03C0
dc.w $07C0,$0020
dc.w $0FE0,$0010
dc.w $0C60,$0210
dc.w $0C00,$0200
dc.w $0C00,$0200
dc.w $0C00,$0270
dc.w $0E70,$0180
dc.w $07E0,$0000
dc.w $03C0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK20:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $07C0,$0020
dc.w $0FE0,$0010
dc.w $0C60,$0210
dc.w $0C00,$0200
dc.w $0C00,$0270
dc.w $0E70,$0180
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK21:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $07C0,$0020
dc.w $0C60,$0390
dc.w $0C00,$0200
dc.w $0E70,$0180
dc.w $07E0,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK22:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0FE0,$0010
dc.w $0FE0,$0010
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK23:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0CF0,$0300
dc.w $0CF0,$0300
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK24:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0DE0,$0200
dc.w $0F80,$0040
dc.w $0CE0,$0210
dc.w $0E30,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK25:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0CF0,$0200
dc.w $0FC0,$0000
dc.w $0F80,$0040
dc.w $0FC0,$0020
dc.w $0C60,$0210
dc.w $0E30,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK26:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0820,$0610
dc.w $0C60,$0210
dc.w $0CF0,$0200
dc.w $0DE0,$0200
dc.w $0FC0,$0000
dc.w $0F80,$0040
dc.w $0FC0,$0020
dc.w $0CE0,$0210
dc.w $0C60,$0210
dc.w $0E30,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK27:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0CF0,$0200
dc.w $0FC0,$0000
dc.w $0F80,$0040
dc.w $0FC0,$0020
dc.w $0C60,$0210
dc.w $0E30,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK28:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0C60,$0210
dc.w $0DE0,$0200
dc.w $0F80,$0040
dc.w $0CE0,$0210
dc.w $0E30,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
CRACK29:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0CF0,$0300
dc.w $0CF0,$0300
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000

Rotate1:
dc.w $0000,$0000
dc.w $07C0,$0
dc.w $1830,$0
dc.w $2000,$18
dc.w $2000,$18
dc.w $4000,$C
dc.w $4000,$C
dc.w $4000,$C
dc.w $4000,$C
dc.w $4000,$C
dc.w $2000,$18
dc.w $2000,$18
dc.w $1830,$0
dc.w $07C0,$0
dc.w $0000,$0
dc.w $0000,$0
Rotate2:
dc.w $0000,$0000
dc.w $07C0,$0
dc.w $1830,$0
dc.w $2008,$0
dc.w $2008,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4000,$C
dc.w $4000,$C
dc.w $2000,$18
dc.w $2000,$38
dc.w $1800,$F0
dc.w $0700,$C0
dc.w $0000,$0
dc.w $0000,$0
Rotate3:
dc.w $0000,$0
dc.w $07C0,$0
dc.w $1830,$0
dc.w $2008,$0
dc.w $2008,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $2008,$0
dc.w $2008,$38
dc.w $1000,$FF0
dc.w $0000,$7C0
dc.w $0000,$0
dc.w $0000,$0
Rotate4:
dc.w $0000,$0
dc.w $07C0,$0
dc.w $1830,$0
dc.w $2008,$0
dc.w $2008,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $0008,$3000
dc.w $0008,$3800
dc.w $0030,$1F80
dc.w $0040,$0780
dc.w $0000,$0
dc.w $0000,$0
Rotate5:
dc.w $0000,$0000
dc.w $07C0,$0
dc.w $1830,$0
dc.w $2008,$0
dc.w $2008,$0
dc.w $4004,$0
dc.w $0004,$6000
dc.w $0004,$6000
dc.w $0004,$6000
dc.w $0004,$6000
dc.w $0008,$3000
dc.w $0008,$3800
dc.w $0030,$1800
dc.w $07C0,$0
dc.w $0000,$0
dc.w $0000,$0
Rotate6:
dc.w $0000,$0
dc.w $07C0,$0
dc.w $1830,$0
dc.w $0008,$3000
dc.w $0008,$3000
dc.w $0004,$6000
dc.w $0004,$6000
dc.w $0004,$6000
dc.w $0004,$6000
dc.w $0004,$6000
dc.w $0008,$2000
dc.w $0008,$3000
dc.w $1830,$0
dc.w $07C0,$0
dc.w $0000,$0
dc.w $0000,$0
Rotate7:
dc.w $0000,$0
dc.w $01C0,$06C0
dc.w $0030,$1E00
dc.w $0008,$3800
dc.w $0008,$3000
dc.w $0004,$7000
dc.w $0004,$6000
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $2008,$0
dc.w $2008,$0
dc.w $1830,$0
dc.w $07C0,$0
dc.w $0000,$0
dc.w $0000,$0
Rotate8:
dc.w $0000,$0000
dc.w $0000,$07C0
dc.w $0000,$1FF0
dc.w $2008,$1820
dc.w $2008,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $2008,$0
dc.w $2008,$0
dc.w $1830,$0
dc.w $07C0,$0
dc.w $0000,$0
dc.w $0000,$0
Rotate9:
dc.w $0000,$0
dc.w $0600,$1C0
dc.w $1800,$1F0
dc.w $2000,$38
dc.w $2000,$18
dc.w $4000,$C
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $4004,$0
dc.w $2008,$0
dc.w $2008,$0
dc.w $1830,$0
dc.w $07C0,$0
dc.w $0000,$0
dc.w $0000,$0
Rotate10:
dc.w $0000,$0
dc.w $07C0,$0
dc.w $1800,$30
dc.w $2000,$18
dc.w $2000,$18
dc.w $4000,$C
dc.w $4000,$C
dc.w $4000,$C
dc.w $4000,$C
dc.w $4000,$C
dc.w $2008,$0
dc.w $2008,$0
dc.w $1830,$0
dc.w $07C0,$0
dc.w $0000,$0
dc.w $0000,$0

fspr2:
	blk.l	100,0
spe:
	dc.w	0
Send:
