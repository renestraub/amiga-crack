

;	org $40000
;	load $40000

; AMIGAnoid Version 0.86  20.11.87

; $3b500-??		:Musik
; $70030-??		:Buffer fuer entcruncher(buffer)
; $4c000-$57500		:Background(screen2)
; $56800-$5e320		:Pic1 (CO 16/6-208/194)(screen3)
; $5e400-$60000		:Hspeicher(hspeicher)
; $60000-$6bb80		:Rahmen(screen1)
; $6bc00-$6bc0f		:Leer-Sound
; $6bc10-$6cd0f		:Schuss-Sound
; $6cd10-??		:Explosions-Sound
; $75000-??		:Bahnen fuer Fspr2

	buffer=$70020
	bahn1=$75000
	bahn2=$75000+$1c6
	bahn3=$75000+$29e
	bahn4=$75000+$37e
	bahn5=$75000+$496
	bahn6=$75000+$596
	bahn7=$75000+$6de
	bahn8=$75000+$834
	bahn9=$75000+$a4e
	bahn10=$75000+$b78
	bahn11=$75000+$0
	bahn12=$75000+$0
	bahn13=$75000+$0
	bahn14=$75000+$0
	bahn15=$75000+$0
	bahn16=$75000+$0

o:
;	move	#$400,$dff096		; blitter nasty

	bsr	initlib
	bsr	inittask
	bsr	clear
o1:
	clr.b	demo
	bsr	menu

	cmp.l	#'EDIT',d0
	bne.s	o2
	bsr	removetask

	move.l	gfxbase,a6
	move.l	38(a6),$dff080
	move	#$8100,$dff096
	clr.l	d0
	rts

o2:
	bsr	o3
	bra.s	o1
o3:
	clr.l	score
	move.b	#1,kept
	move.l	$6c,oldvek
	move.l	oldvek,intvek
	move	#$8010,$dff09a	; Enable interrupts

	clr	power
	clr	powersoll
	bsr	restorepower

	tst.b	demo
	beq.s	notdemo

	move.b	#0,lives
	move.l	histufe,stufe2
	bchg	#0,mode1
	move.b	mode1,twoplayer
	bra.s	demo56
notdemo:
	move.b	#2,lives	
	clr.l	stufe2
demo56:
	move	#$20,$dff096

	bsr	loadscr

	bsr	loadstage
	bsr	initcopper
	bsr	initmouse
	bsr	buildlevel	
	bsr	clrshadow
	bsr	shadow

	move	#$8100,$dff096
	move.l	#int,$6c
haupt2:
	clr.b	paused
	bsr	wait_start
haupt:
	move.l	gfxbase,a6
;	jsr	-270(A6)
w9:
	tst.b	demo
	beq.s	dontask

;	add	#1,powercnt2
	cmp	#4,powercnt2
	bne.s	powr
	clr	powercnt2
	add	#1,powersoll
powr:	
	btst	#6,$bfe001
	beq	exit2
	btst	#7,$bfe001
	beq	exit2
dontask:
	tst.b	nlevel
	bne.L	explosion
nonextlevel:
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
	bne	las
	move.l	#4,schl
	move.l	#4,schl2
	clr.b	laser
las:
	tst.b	battle
	beq.s	nobtl		; nur falls battle
	cmp.l	#5,schl
	beq.s	nobtl
	cmp.l	#5,schl2
	beq.s	nobtl		; schon laser ??

	btst	#6,$bfe001
	bne.s	nc5
	move.l	#5,schl
	move	#250,lasercnt
	move.b	#1,laser
	bra.s	nobtl
nc5:
	btst	#7,$bfe001
	bne.s	nobtl
	move.l	#5,schl2	
	move	#250,lasercnt
	move.b	#1,laser
nobtl:
	bsr	print
	tst	refresh
	beq.s	noref
	bsr	shadow
noref:
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
	cmp	#230,power
	bhi.s	nopower

	btst	#10,$dff016
	bne.s	nopower2

	addq	#2,powersoll
	bra.s	nopower2
nopower:
	bra	explosion
nopower2:
	move	power,d0
	divu	#10,d0		; d0=n-te farbe
	move	d0,d5

	lea	orgpowercol,a2
	lea	powercol,a3
	lea	powerturm,a0
search:	
	cmp	#$18a,(a0)+
	bne.s	search
	move	(a3)+,(a0)
	addq	#2,a2
	dbra	d0,search

	cmp	#120,power
	bls.s	noblink	; im blinkbereich

	addq	#2,blink
	cmp	#24,blink
	bls.s	blink2	; x<25 -->2.farbe 
	cmp	#48,blink
	bne.s	blink3
	clr	blink	; sonst 1.farbe
blink3:
	move.l	a2,a3	
blink2:
	move	#23,d4
	sub	d5,d4
search23:	
	cmp	#$18a,(a0)+
	bne.s	search23
	move	(a3)+,(a0)
	addq	#2,a2
	dbra	d4,search23
noblink:
	move.b	$bfec01,d0
;	move.b	d0,key
	tst.b	d0
	beq.L	endcheck_key

	cmp.b	#$3f,d0
	beq	zitter

;	btst #6,$Bfe001
;	beq exit2

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
	move	#0,$dff0c8
	move	#0,$dff0d8

	cmp.b	#$67,d0
	bne.s	notlauter2
	cmp	#63,vol2
	bhi.s	notlauter2
	addq	#1,vol2
notlauter2:
	cmp.b	#$65,d0
	bne.s	notleiser2
	tst	vol2
	bls.s	notleiser2
	subq	#1,vol2
notleiser2:
	move	#0,$dff0a8
	move	#0,$dff0b8

	cmp.b	#$7f,d0
	beq	pause

;	cmp.b	#$35,d0
;	bne.s	notnextlev
;	move.b	#1,nlevel
;notnextlev:
;	cmp.b	#$37,d0
;	bne.s	notprelev
;	move.b	#1,plevel
;notprelev:
	cmp.b	#$79,d0
	beq	exit2
endcheck_key:
	bsr alles_geloescht
	tst d0
	bne.s notall
	move.b #1,exploding
notall:
	bra haupt

restorepower:
	clr power
	clr powersoll
	lea powerturm+2,a4
	
	move #22,d7
ser:
	cmp #$18a,(a4)+
	bne.s ser
	dbra d7,ser	; --> a4=letzte farbe
	sub #2,a4

	lea orgpowercol+48,a5

	move #23,d7
rploop:
	move.l gfxbase,a6
	jsr -270(A6)
	jsr -270(A6)

	move -(a5),2(a4)
cp1loop:
	cmp #$18a,-(A4)
	bne.s cp1loop

	dbra d7,rploop
	rts

clearpower:
	lea powerturm+2,a4
	lea powercol,a5
	move #23,d7
cploop:
	move (a5)+,(A4)
cp2loop:
	cmp #$18a,(A4)+	
	bne.s cp2loop
	dbra d7,cploop
	rts

dolives:
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
	cmp	d2,d0
	blo.s	liv4

endlives:
	rts

lplay:
	move	#20,tempo
	clr	tempo2
	clr	playcnt

	lea	pic2col+2,a0
	move	#5,d7
fill2:
	move	#$777,(a0)
	add	#4,a0
	dbra	d7,fill2

	bsr	hell
	bsr	restorepower		
	move.l	#copperl,$dff080
lplay2:
	move.l	gfxbase,a6
	jsr	-270(a6)

	lea	pic2col+2,a0
	move.l	a0,a1
	move	#5,d7
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

	move	#20,d7
verz23:
	move.l	gfxbase,a6
	jsr	-270(a6)
	dbf	d7,verz23

	clr	playcnt
	sub	#5,tempo
	cmp	#5,tempo
	bne	lplay2
endplay:
	bsr	dunk
	rts

rnd:
	clr.l	d0
	add.b	$dff004,d0
	add.b	$dff007,d0
	add.b	$dff00a,d0
	add.b	$dff00c,d0
	add.b	$dff01a,d0
	add.b	$bfe401,d0
	add.b	$bfe601,d0
	rts	

doloch:
	tst	lochcnt
	beq.s	nh
	add	#1,lochcnt
	cmp	#32,lochcnt
	bls.L	draw_loch
	clr	lochcnt
	move	lochdir2,lochdir
nh:
	move	lochdir,d0
	add	d0,lochx
	cmp	#134,lochx
	bls.s	nr
	neg	lochdir
nr:
	cmp	#10,lochx
	bhi.s	lr
	neg	lochdir
lr:
	tst.b	paused
	bne.s	draw_loch
	lea	fspr2,a1
	tst.b	(a1)
	bne.s	draw_loch

	bsr	rnd
	and.b	#$3f,d0
	cmp.b	#10,d0
	bne.s	draw_loch

	move.b	#34,(a1)
	clr.l	d0
	move	lochx,d0
	lsr.b	#1,d0
	add.b	#84,d0
	move.b	d0,1(A1)
	move.b	#39,2(a1)	; Neues fspr2
	
	clr.l	d0
	bsr	rnd
	and.b	#$f,d0
	lsl	#2,d0		; Bahn auswaehlen
	lea	bahnen_tabelle,a1
	add.l	d0,a1
	move.l	(A1),bahn	

	move	lochdir,lochdir2
	clr	lochdir
	move	#1,lochcnt
	clr	f2cnt
draw_loch:
	move.l	screen2,a0
	add.l	#336,a0		; Source
	move.l	a0,a1
	add.l	#8,a1		; Maske

	move.l	screen1,a2
	add	#2,a2		; Ziel

	move	lochx,d2
	and	#$000f,d2
	lsl	#8,d2
	lsl	#4,d2
	move	d2,d4
	add	#$0fca,d2		; Shift fuer Blitter

	move	lochx,d3
	lsr	#3,d3
	bclr	#0,d3
	add	d3,a2		; addieren

	moveq	#4,d7
	move.l	#$00000000,$dff044
paintit:
	btst	#14,$dff002
	bne.s	paintit
	move	#32,$dff066
	move	#32,$dff064
	move	#32,$dff056
	move	#32,$dff052
	move	d4,$dff042
	move	d2,$dff040
	move.l	a2,$dff048	; Ziel
	move.l	a1,$dff050	; Maske
	move.l	a0,$dff04c	; source
	move.l	a2,$dff054	; Ziel
	move	#%00000000111000100,$dff058
	add	#8000,a2
	add	#8000,a0
	dbra	d7,paintit
endloch:
	rts


dolaser:
	tst.b	laser
	beq.L	nolaser
	tst.b	battle
	bne.s	nbtl2
	move.l	#5,schl
nbtl2:
	tst.b	battle
	beq.s	nbtl3
	cmp.l	#5,schl2
	bne.s	nbtl3
	btst	#7,$bfe001
	beq	dlaser
nbtl3:
	cmp.l	#5,schl
	bne.L	nolaser
	btst	#6,$bfe001
	bne	nolaser
dlaser:
	lea shoot1,a1
	tst.b (a1)
	bne nolaser

	move #$0003,$dff096
	move #$8003,$dff096

	move.l #$70010,$dff0a0
	move #2157,$dff0a4
	move #307,$dff0a6
	move vol2,$dff0a8	; Start Sound

	move.b #212,(A1)
	move.b #229,2(A1)
	add #2,powersoll

	btst	#6,$bfe001
	beq.s	pl1
	move	mousx2,d5
	bra.s	pl2
pl1:
	move mousx,d5
pl2:
	lsr	#1,d5
	add.b	#83,d5
	move.b	d5,1(a1)

	move.l	#$70010+200,$dff0b0
	move	#2157,$dff0b4
	move	#307,$dff0b6
	move	vol2,$dff0b8	; Start Sound

	move.l	#$70000,$dff0a0
	move	#2,$dff0a4	; Zeiger auf NullSound

	move.l	#$70000,$dff0b0
	move	#2,$dff0b4	; Zeiger auf NullSound
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

do_blitz:
	rts
	add	#1,lcnt
	move	lcnt,d0
	cmp	#22,d0
	bne.s	nolevel2
	clr	lcnt
nolevel2:
	move.l	screen2,a4
	add.l	#1680,a4
	lsr	#1,d0
	add.l	d0,a4
	move.l	screen1,a3
	add.l	#7003,a3
	move.l	a3,a5
	add	#23,a5

	moveq	#15,d5
	move.l	#8000,d2
	move.l	#40,d1
wrlevel:
	move.l	a4,a2
	move.l	a3,a1
	move.l	a5,a0
	moveq	#5,d3
wrlevel2:
	move.b	(A2),d0
	and.b	#%10000000,(A0)
	and.b	#%00000001,(a1)
	tst.b	level
	bne.s	hier
	or.b	d0,(A0)
	or.b	d0,(A1)
hier:
	add.l	d2,a0
	add.l	d2,a1
	add.l	d2,a2
	dbra	d3,wrlevel2	

	add.l	d1,a3
	add.l	d1,a4
	add.l	d1,a5
	dbra	d5,wrlevel
	rts
ballb=4
ballh=4

movespr:
	tst	kept2
	beq.s	move2
	rts
move2:
	sub.l	d1,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4

	lea	spr1,a1	
	move.l	(A1),a0
	move.b	4(A1),d1		; X
	move.b	5(A1),d2		; Y
	move.b	6(A1),d3		; DeltaX
	move.b	7(A1),d4		; DeltaY

	cmp.b	#79,d1
;	ble	testit

	cmp.b	#167,d1
;	bhi	testit

	cmp.b	#49,d2
;	ble	testit

up1:
	tst.b	d3
	bmi.s	up2

	tst.b	d4
	bpl.s	up2			; DX=+,DY=-

	movem.l	d0-d7,-(sp)
	add.b	d4,d2
	move	d1,x
	move	d2,y

	add	#ballb/2,d1
	move	d1,d5
	move	d2,d6

	move.b	7(A1),d4
	bsr	check_block
	move.b	d4,7(A1)

	add	d3,x
	move	x,d5
	move	y,d6
	add	#ballh/2,d6
	add	#ballb,d5	

	move.b	6(A1),d4
	bsr	check_block
	move.b	d4,6(A1)

	movem.l	(sp)+,d0-d7
	move	x,d1
	move	y,d2
	bra.L	testit
up2:
	tst.b	d3
	bmi.s	up3

	tst.b	d4
	bmi.s	up3			; DX=+,DY=+

	movem.l	d0-d7,-(sp)
	add.b	d4,d2
	move	d1,x
	move	d2,y

	add	#ballb/2,d1
	add	#ballh,d2
	move	d1,d5
	move	d2,d6

	move.b	7(A1),d4
	bsr	check_block
	move.b	d4,7(A1)

	move	x,d5
	add	d3,d5
	add	d3,x
	move	y,d6
	add	#ballh/2,d6
	add	#ballb,d5	

	move.b	6(A1),d4
	bsr	check_block
	move.b	d4,6(A1)

	movem.l	(sp)+,d0-d7
	move	x,d1
	move	y,d2
	bra.L	testit
up3:
	tst.b	d3
	bpl.s	up4

	tst.b	d4
	bmi.s	up4			; DX=-,DY=+

	movem.l	d0-d7,-(sp)
	add.b	d4,d2
	move	d1,x
	move	d2,y

	add	#ballb/2,d1
	add	#ballh,d2
	move	d1,d5
	move	d2,d6

	move.b	7(A1),d4
	bsr	check_block
	move.b	d4,7(A1)

	move	x,d5
	add	d3,d5
	add	d3,x
	move	y,d6
	add	#ballh/2,d6

	move.b	6(A1),d4
	bsr	check_block
	move.b	d4,6(A1)

	movem.l	(sp)+,d0-d7
	move	x,d1
	move	y,d2
	bra.s	testit
up4:
	tst.b	d3
	bpl.s	up5

	tst.b	d4
	bpl.s	up5			; DX=-,DY=-

	movem.l	d0-d7,-(sp)
	add.b	d4,d2
	move	d1,x
	move	d2,y

	add	#ballb/2,d1
	move	d1,d5
	move	d2,d6

	move.b	7(A1),d4
	bsr	check_block
	move.b	d4,7(A1)

	move	x,d5
	add	d3,d5
	add	d3,x
	move	y,d6
	add	#ballh/2,d6

	move.b	6(A1),d4
	bsr	check_block
	move.b	d4,6(A1)

	movem.l	(sp)+,d0-d7
	move	x,d1
	move	y,d2
up5:
testit:
	lea	spr1,a1
	move	x,d1
	move	y,d2
	
	cmp.b	#79,d1
	bhi.s	notleft
	neg.b	6(A1)
	neg.b	d3
	bra.s	notright
notleft:
	cmp.b	#158,d1
	blo.s	notright		
	neg.b	6(A1)
	neg.b	d3
notright:	
	cmp.b	#50,d2
	bhi.s	notoben
	neg.b	7(A1)
notoben:
	move.l	(A1),a0
	move.b	d1,4(A1)
	move.b	d2,5(A1)

	move.b	d1,1(A0)
	move.b	d2,(A0)
	addq.b	#7,d2
	move.b	d2,2(A0)

	bsr	checkspry

	lea	spr1,a1
	bsr	check_ball
	rts

int:
	movem.l d0-d7/a0-a6,-(sp)

	btst	#4,$dff01f
	beq.s	endint

	tst.b	paused
	bne.s	endint2

	bsr	dolaser
	bsr	do_schl
	bsr	mousehandler
	bsr	draw_schl
	bsr	do_blitz
	bsr	movespr
	bsr	move_shoot
	bsr	move_shoot

;	bsr	doloch

	bsr	flash
endint2:
	bsr	dolives
	bsr	movefspr	
	bsr	movef2spr
	bsr	colorcycle1
	move	#$10,$dff09c
endint:
	movem.l (sp)+,d0-d7/a0-a6
	dc.w $4ef9
intvek:
	dc.l 0

prelevel:
	move.b	#1,paused
	clr.b plevel
	tst.l stufe2
	bne.s endprelevel
	add.l #190,stufe2
endprelevel:
	sub.l #380,stufe2
nextlevel:	
	move.b	#1,paused
	btst	#6,$bfe001
	beq.s	nextlevel

	bsr	clearflash
	clr.b	nlevel

	lea	fspr2,a1
	clr.b	(A1)
	lea	fspr3,a1
	clr.b	(A1)
	lea	sprite1,a1
	lea	sprite2,a2
	clr.b	1(a1)
	clr.b	1(A2)
	lea	spr1,a1
	lea	spr2,a2
	clr.b	4(a1)
	clr.b	4(a2)	; Sprites loeschen

	move.l	oldvek,$6c

	move	#4,command
	bsr	starttask

	moveq	#15,d7
waitit:
	move.l	gfxbase,a6
	jsr	-270(a6)
	dbra	d7,waitit

repeat:
	move.l	gfxbase,a6
	jsr	-270(a6)
repa2:
	move.l $dff004,d2
	and.l #$0001ff00,d2
	cmp.l #$fa00,d2
	bne.s repa2
sdf1:	
	add	#5,power
	add.l	#5,score
	cmp	#230,power
	bhi.s	sdf3

	move	power,d0
	divu	#10,d0
sdf2:
	lea	powerturm,a0
	lea	powercol,a3
sdf:
	cmp	#$18a,(a0)+
	bne.s	sdf
	move	(a3)+,(a0)
	dbra	d0,sdf

	bsr	print
	bra.s	repeat
sdf3:
	bsr	dunk
pic2:
	;clr lgame
	;add #1,lgamecnt
	;cmp #5,lgamecnt
	;bne.s pic3
	;clr lgamecnt
	;move #1,lgame
	;move.b #'2',d0
	;bra.s pic4
pic3:
;	move.b	piccounter,d0
pic4:	
	bsr	wait_load
	bsr	copypic

	move.l	#int,$6c
	;tst lgame
	;beq.s dontplay
	;bsr lplay
	;bra.s nextpic
dontplay:
	add.l	#190,stufe2
	cmp.l	#6080,stufe2
	bne	c5
	clr.l	stufe2
c5:
	clr.b	level
	clr.b	laser
	clr.b	auto
	clr.l	extend
	clr.l	extend2
	clr.b	hold
	clr.b	revers
	clr.b	twoball
	clr	power
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

	move	#100,mousx
	bsr	buildlevel
	
	bsr	print
	bsr	clrshadow
	bsr	shadow
	bsr	hell
	move.l	#copperl,$dff080
	bsr	restorepower
	bra	haupt2
schl:
	dc.l 4
schl2:
	dc.l 4

dunk:
	lea	coppercol2,a4
	lea	coppercol,a3
	moveq	#31,d7
copycopper:
	move.l	(A3)+,(a4)+
	dbra	d7,copycopper

	move.l	#copperl2,$dff080
	moveq	#15,d5
dunkel:
	move.l	gfxbase,a6
	jsr	-270(A6)
;	jsr	-270(A6)

	lea	coppercol2+2,a3
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
	rts
hell:
	lea	coppercol+58,a4
	move	#$aab,(a4)
	move	#$950,4(A4)
	bsr	clearpower
	moveq	#15,d5
heller:
	move.l	gfxbase,a6
	jsr	-270(A6)
;	jsr	-270(A6)

	lea	coppercol+2,a4
	lea	coppercol2+2,a3
	moveq	#31,d6
heller2:
	move.b	1(A4),d3
	and.b	#$0f,d3
	move.b	1(a3),d4
	and.b	#$0f,d4
	
	cmp.b	d4,d3
	beq.s	okh1
	add	#$0001,(a3)
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
	move	#$8020,$dff096
	move	#$000f,$dff096	; Sound aus

	move.l	oldvek,$6c
	rts
error:
	move	#$8020,$dff096
	move.l	oldvek,$6c
	move.l	gfxbase,a6
	move.l	38(a6),$dff080
	rts
count:
	dc.w	0
colorcycle1:
	lea	cycle1+2,a0
	lea	cyclelist1,a1
	add.l	#2,c1cnt
	cmp.l	#62,c1cnt
	bne.s	notc0
	clr.l	c1cnt
notc0:
	add.l	c1cnt,a1
	move	#8,d6
notc01:
	move	(a1)+,(a0)
notc02:
	cmp	#$18a,(a0)+
	bne.s	notc02

	cmp.l	#endclist1,a1
	bls.s	snext1
	lea	cyclelist1,a1
snext1:
	dbra	d6,notc01

	lea	cycle2+2,a0
	lea	cyclelist2,a1
	add.l	#2,c2cnt
	cmp.l	#180,c2cnt
	bne.s	notc1
	clr.l	c2cnt
notc1:
	add.l	c2cnt,a1
	moveq	#22,d6
notc11:
	move	(a1)+,(a0)
notc22:
	cmp	#$1be,(a0)+
	bne.s	notc22

	cmp.l	#endclist2,a1
	bls.s	snext2
	lea	cyclelist2,a1
snext2:
	dbra	d6,notc11
	rts

cyclelist1:
	dc.w $f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70
	dc.w $f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0
	dc.w $ff0,$ff0,$fe0,$fd0,$fc0,$fb0,$fa0,$f90
	dc.w $f80,$f70,$f60,$f50,$f40,$f30,$f20,$f10
	dc.w $f00,$f00
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
	move.b	#1,paused
	cmp.b	#$7f,$bfec01
	beq.s	pause

	move.l	#buffer,a2		; Ziel
	move.l	screen1,a1		; Source
	add.l	#6010,a1

	moveq	#9,d7			; Hoehe
copy11:
	moveq	#19,d6			; Breite
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

	lea	pausetext,a0
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

	move.l	#buffer,a2		; Ziel
	move.l	screen1,a1		; Source
	add.l	#6010,a1

	moveq	#9,d7			; Hoehe
copy21:
	moveq	#19,d6			; Breite
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

xpos:
	dc.w	0
wait_start:	
	clr	waiter
	move.b	#1,paused
	move	#1,kept2
	bsr	flashall
	bsr	clearflash

	neg.b	kept
	clr	mousx
	clr	imgx
	clr	lasercnt
	move.l	#4,schl
	move.l	#4,schl2

	move	#61,mousx2
	move	#124,imgx2

	lea	sprite1,a1
	move.b	#218,(a1)
	move.b	#225,2(a1)

;	move.b	#60,(A1)
;	move.b	#67,2(A1)
	move.b	#80,1(a1)
	
	lea	spr1,a2
	move.b	#218,5(a2)
;	move.b	#60,5(A2)
	move.b	#80,4(a2)
	move.b	#1,6(A2)
	move.b	#-3,7(a2)

	bsr	print
	bsr	rnd
	and	#$007f,d0
	move	d0,demornd
wait_start2:
	move.l	gfxbase,a6
	jsr	-270(a6)
	tst.b	demo
	beq.s	w3

	move	demornd,d4
	cmp	waiter,d4
	bne.s	w3
	bra	endwait23
w3:
	move.l	$dff004,d2
	and.l	#$0001ff00,d2
	cmp.l	#$fa00,d2           
	bne.s	W3

;	bsr	print
	bsr	mousehandler

	tst.b	twoplayer
	beq	take2

	tst.b	kept
	bmi.s	take2	; Falls neg = spieler2
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

	lea	sprite1,a1
	lea	spr1,a2
	move.b	d2,1(a1)	
	move.b	d2,4(a2)

	addq	#1,waiter
	cmp	#250,waiter
	bhi.s	endwait23	
	bra.L	wait_start2
endwait23:
	clr	kept2
	clr.b	paused
	rts

wait_ball:
	clr	waiter
	clr	waitb
	move.b	#1,paused

	lea	sprite1,a1
	lea	spr1,a2
	move	mousx,d4
	lsr	#1,d4
	move.b	1(a1),d3
	sub.b	d3,d4
wait_ball2:
	move.l	gfxbase,a6
	jsr	-270(a6)
w5:
	move.l	$dff004,d2
	and.l	#$0001ff00,d2
	cmp.l	#$fa00,d2           
	bne.s	w5

	lea	sprite1,a1
	tst.b	alter
	bne.L	endwaitball

	tst.b	twoplayer
	beq	take22

	tst.b	kept
	bmi.s	take22	; Falls neg = spieler1
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

	lea	sprite1,a1
	lea	spr1,a2
	move.b	d2,1(a1)	
	move.b	d2,4(a2)

	bsr	mousehandler

	clr.l	d0
	move	xpos,d0
	move.b	d0,d2
	lsr	#1,d2
	sub.b	d4,d2
	lea	spr1,a2
	move.b	d2,1(A1)	
	move.b	d2,4(a2)

	bsr	draw_schl

	add	#1,waiter
	cmp	#250,waiter
	bhi.s	endwaitball
	bra.L	wait_ball2
endwaitball:
	clr	kept2
	clr.b	paused
	bra	haupt

buildlevel:
	move	#$20,$dff096
	bsr	htoz
	bsr	initblockcolors
	lea	zspeicher+190,a0
buildlevel2:
	move.l	#15,d2
verti:
	move.l	#10,d1
horiz:
	clr.l	d0
	move.b	-(a0),d0
	and.b	#31,d0
	bsr	draw_block
	dbra	d1,horiz
	dbra	d2,verti
	move	#$8020,$dff096
	rts
clear:
	move.l	#$4a000,a0
	move.l	#$9800,d7
cloop:
	clr.l	(a0)+
	dbra	d7,cloop
	rts

copypic:
	move.l	#buffer,a0
	move.l	screen3,a1
	move.l	#25284,d4
	bsr	decruncher
cc:
	move.l	screen3,a1
	add.l	#25220,a1
	lea	coppercol+2,a2
	moveq	#7,d6
writecols:
	move	(a1),(a2)
	clr	(a1)+
	addq	#4,a2
	dbra	d6,writecols	; Farben einschreiben

	add	#16,a1
	add	#32,a2
	moveq	#14,d6
wrcol2:
	move	(A1),(a2)
	clr	(A1)+
	addq	#4,a2
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

even
loadscr:
	move	#2,command
	move.l	#buffer,ziel
	move.l	#36*512,laenge
	move.l	#rahmenc,offset
	bsr	starttask
	bsr	wait_load

	move.l	#buffer,a0
	move.l	screen1,a1
	move.l	#40000,d4
	bsr	decruncher
notload2:
	move	#2,command
	move.l	#buffer,ziel
	move.l	#50*512,laenge
	move.l	#backgroundc,offset
	bsr	starttask
	bsr	wait_load

	move.l	laenge1,d4
	move.l	#buffer,a0
	move.l	screen2,a1
	bsr	decruncher
notload3:
	move	#4,command
	bsr	starttask
	bsr	wait_load	; loadpic
	bsr	copypic		; copypic
notload4:
	rts

zitter:
	clr.l d2
	move $dff006,d2
	and #7,d2
	lsl #1,d2
	lea shake_table,a3
	add.l d2,a3
	lea spr1,a1
	move.b (a3)+,6(a1)
	move.b (a3),7(a1)

	lea spr2,a2
	move $dff006,d2
	and #7,d2
	lsl #1,d2
	lea shake_table,a3
	add.l d2,a3
	move.b (a3)+,6(a2)
	move.b (a3),7(a2)
	bra haupt
waitz:
	move #700,d6
wait_zitter2:
	dbra d6,wait_zitter2
	rts
chkschl:
	move dist,d2
	tst d2
	bpl ck1
	neg d2
ck1:
	move mousx,d0
	cmpi #1,d0
	bne.s ck2
	cmpi #10,d2
	bls.s ck2
	bsr.L zitter
ck2:
	clr.l d1
	move schl,d1
	lsl #1,d1
	lea tabelle,a4
	add.l d1,a4
	move (a4),d1	; Rechter Rand
	add.l #10,d1
	cmpi d1,d0
	bne.s ck3
	cmpi #10,d2
	bls.s ck3
	bsr.L zitter
ck3:
	rts

shake_table:
	dc.b 1,1
	dc.b -1,3
	dc.b 1,2
	dc.b -1,-3
	dc.b -1,-1
	dc.b -1,2
	dc.b 1,-2
	dc.b 1,-1

del_shoot:
	lea shoot1,a2
	move #4,d7
dsloop1:
	clr.b (a2)
	move.b #3,2(A2)
	add.l #16,a2
	dbra d7,dsloop1

printtext:
	clr.l	d0
	move.b	(a0)+,d0
	tst.b	d0
	beq.s	endpt
	bsr	printletter
	bra.s	printtext
endpt:
	rts

printletter:
	move.l	a1,a3
	sub.b	#'A',d0
	mulu	#10,d0
	lea	font2,a2
	add.l	d0,a2
	move	#9,d7
asc:
	move.b	(A2)+,d2
	or.b	d2,(a3)
	or.b	d2,8000(a3)
	or.b	d2,16000(a3)
	or.b	d2,24000(a3)
	or.b	d2,32000(a3)
	add	#40,a3
 	dbra	d7,asc
	addq	#1,a1
	rts
print:
	move.l	score,d0
	bsr	GetPosition
	move.l	d0,place

	tst	d0
	bne.s	notzero2
	move.l	#max_entry,d0
notzero2:
	lea	hilist+8,a1
	subq	#2,d0
	mulu	#12,d0
	add.l	d0,a1

	move.l	score,d2
	sub.l	(a1),d2
	move.l	d2,points	

	move.l	score,d0
	move.l	hiscore,d1
	cmp.l	d1,d0
	blo.s	notmore
	move.l	score,hiscore
notmore:
	lea	shiptable,a3
	add.l	stc,a3
	move.l	(A3),d2
	cmp.l	d0,d2
	bne.s	nolives
	add.b	#1,lives
	addq	#4,stc
nolives:
	move.l	screen1,a2
	add.l	#1876,a2
	move.l	a2,a0
	lea	font,a1
	bsr	wletter
	subq	#1,a2	
	move.l	score,d0	;points,d0
	moveq	#5,d6
	bsr	printcount	; points ausgeben

	move.l	screen1,a2
	add.l	#5516+40,a2
	move.l	a2,a0
	lea	font,a1
	bsr	wletter
	subq	#1,a2	
	move.l	score,d0
	moveq	#5,d6
	bsr	printcount	; score ausgeben
	
	move.l	screen1,a2
	add.l	#7436-40,a2
	move.l	a2,a0
	lea	font,a1
	bsr	wletter
	subq	#1,a2	
	move.l	hiscore,d0
	moveq	#5,d6
	bsr	printcount	; hiscore ausgeben

	move.l	screen1,a2
	add.l	#3711,a2
	move.l	stufe2,d0
	divu	#190,d0
	addq	#1,d0
	moveq	#1,d6
	bsr	printcount		; Level ausgeben

	move.l	screen1,a2
	add.l	#3717,a2
	move.l	place,d0
	moveq	#1,d6
	bsr	printcount		; Place ausgeben
	rts

printcount:
	move.l	a2,a0
	lea	font,a1
ploop2:
	move.l	a2,a0
	divu	#10,d0
	swap	d0
	move	d0,d1
	clr	d0
	swap	d0
	mulu	#10,d1
	lea	font,a1
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

move_shoot:
	movem.l	d0-d7/a0-a5,-(sp)
	lea	shoot1,a4
	tst.b	(a4)
	beq.s	dontchecks
	sub.b	#2,(a4)
 	sub.b	#2,2(a4)

	cmp.b	#60,(a4)
	bhi.s	nots1
	clr.b	(a4)
	move.b	#4,2(a4)
nots1:
	lea	shoot1,a4
	clr.l	d6
	clr.l	d5
	move.b	(a4),d6		; Y
	move.b	1(a4),d5	; X

	movem.l	d1-d7/a0-a6,-(sp)
	clr.l	d0
	bsr	check_block
	movem.l	(sp)+,d1-d7/a0-a6

	tst.b	d0
	beq.s	dontchecks

	lea	shoot1,a1
	clr.b	(a1)
dontchecks:
	movem.l	(sp)+,d0-d7/a0-a5
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
	dc.l	bahn10
	dc.l	bahn10
	dc.l	bahn10
	dc.l	bahn10

movef2spr:
	lea	fspr3,a1
	tst.b	(a1)
	beq	nmoveb
	add.b	#2,(A1)
	add.b	#2,2(A1)
	cmp.b	#254,(A1)
	bls.s	nmoveb
	clr.b	(A1)
	add	#10,powersoll	; Energie abziehen
nmoveb:
	lea	fspr3,a1
	lea	shoot1,a2
	tst.b	(A1)
	beq.s	dan

	move.b	1(A1),d0	; fspr3 x
	move.b	1(A2),d1	; schuss x
	add.b	#15,d0
	cmp.b	d0,d1
	bhi.s	dan

	move.b	1(A1),d0	; fspr3 x
	move.b	1(A2),d1	; schuss x
	add.b	#8,d1
	cmp.b	d1,d0
	bhi.s	dan

	move.b	(A1),d0
	move.b	(A2),d1
	cmp.b	d0,d1
	bhi.s	dan

	clr.b	(a1)
	clr.b	(A2)
	add.l	#50,score	; Sprites loeschen/score +
dan:
	lea	fspr2,a1
	tst.b	(a1)
	beq.L	endmove2

	addq	#2,f2cnt
	move.l	bahn,a3
	add	f2cnt,a3		; aktuelle position

	tst	(a3)
	bne.s	endfg1
	clr.b	(a1)	
	move.b	#4,2(a1)
	clr	f2cnt
	bra	endmove2
endfg1:
	move.b	(a3)+,d0
	move.b	(a3)+,d1
	move.b	(a3)+,d2
	move.b	(a3)+,d3		; x0,y0,x1,y1
	sub.b	d0,d2		; X offset
	sub.b	d1,d3		; Y offset
	add.b	d3,(A1)		; offsets addieren
	add.b	d3,2(A1)		; 	""
	add.b	d2,1(A1)		;	""

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

	tst.b	battle
	beq.s	nobomb
	lea	fspr2,a1
	cmp.b	#170,(A1)
	bhi	nobomb
	bsr	rnd
	and.b	#$3f,d0
	tst.b	d0
	bne.s	nobomb

	lea	fspr3,a2
	lea	fspr2,a1
	move	(a1),(A2)
	move.b	(a2),2(a2)
	add.b	#5,2(A2)	
nobomb:
	cmpi.b	#220,d2
	bls.L	endmove2
	cmpi.b	#232,d2
	bhi.L	endmove2

	move	mousx,d5
	lsr.b	#1,d5
	add.b	#74,d5

	cmp.b	d5,d1
	bls.s	daneben33

	move.l	schl,d6
	lsl.l	#1,d6
	lea	tabelle2,a2
	add.l	d6,a2
	add	(a2),d5	; Schlaeger getroffen ?

	cmp.b	d5,d1
	bhi.s	daneben33
	bra.s	treffer33
daneben33:
	move	mousx2,d5
	lsr.b	#1,d5
	add.b	#74,d5

	cmp.b	d5,d1
	bls.L	endmove2
	
	move.l	schl,d6
	lsl.l	#1,d6
	lea	tabelle2,a2
	add.l	d6,a2
	add	(a2),d5	; Schlaeger getroffen ?

	cmp.b	d5,d1
	bhi.s	endmove2
treffer33:
	btst	#10,$dff016
	beq.L	endmove2

	add	#30,powersoll
	lea	fspr2,a1
	clr.b	(a1)
endmove2:
	rts

movefspr:
	movem.l	d0-d7/a0-a5,-(sp)
	clr.b	alter
	tst.b	falling
	beq.L	f2

	lea	fspr1,a3
	add.b	#2,(A3)
	add.b	#2,2(a3)	; Y+1
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
	dbra	d6,writef

	lea	fspr1,a1
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
	lea	tabelle2,a2
	add.l	d6,a2
	add	(a2),d5	; Schlaeger getroffen ?

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
	lea	tabelle2,a2
	add.l	d6,a2
	add	(a2),d5	; Schlaeger getroffen ?

	cmp.b	d5,d1	
	bhi.L	hitschl
treffer2:
	btst	#10,$dff016
	beq.L	hitschl

	tst.b	bonus
	beq	hitschl

	cmp.b	#16,bonus
	bne.s	not16
	bsr	starttwo
	clr.b	hold
	clr.b	auto
	clr.b	twoschl
	clr.b	revers
	clr.b	laser
	clr.b	level
	bra.L	cfall
not16:
	cmp.b	#11,bonus
	bne.s	not11
	tst.b	twoplayer
	bne.s	not11
	tst.b	battle
	bne.s	endext
	lea	sprite2,a3
	clr.b	1(a3)
	tst.l	schl
	beq.s	endext
	move.l	#1,extend
	move.l	#1,extend2
endext:
	clr.b	twoball
	clr.b	laser
	clr.b	twoschl
	clr.b	hold	
	clr.b	auto
	clr.b	revers
	clr.b	level
	bra.L	cfall
not11:
	cmp.b	#10,bonus
	bne.s	not10
	lea	sprite2,a3
	clr.b	1(a3)
	clr.b	twoball	; TWO BALL ausschalten
	move.l	#-1,extend	; Extend ausschalten
	move.l	#-1,extend2
	addq.b	#1,lives
	clr.b	laser
	clr.b	twoschl
	clr.b	hold
	clr.b	auto
	clr.b	revers
	clr.b	level
	bra.L	cfall
not10:
	cmp.b	#12,bonus
	bne.s	not12
	move.b	#1,hold
	move.l	#-1,extend
	move.l	#-1,extend2
	lea	sprite2,a3
	clr.b	1(a3)
	clr.b	laser
	clr.b	twoschl
	clr.b	twoball	; TWO BALL ausschalten
	clr.b	auto
	clr.b	revers
	clr.b	level
	bra.L	cfall	
not12:
	cmp.b	#13,bonus
	bne.s	not13
	move.b	#1,auto
	move.l	#-1,extend
	move.l	#-1,extend2
	clr.b	twoball
	lea	sprite2,a3
	clr.b	1(A3)
	clr.b	twoschl
	clr.b	laser
	clr.b	hold
	clr.b	revers
	clr.b	level
	bra.L	cfall
not13:
	cmp.b	#9,bonus
	bne.s	not9
	tst.b	twoplayer
	bne.s	not9
	tst.b	battle
	bne.s	not9
	move.b	#1,laser
	clr.b	auto
	move.l	#-1,extend
	move.l	#-1,extend2
	clr.b	hold
	clr.b	twoschl
	clr.b	twoball
	clr.b	revers
	lea	sprite2,a3
	clr.b	1(A3)
	clr.b	level
	bra.L	cfall	; LASER
not9:
	cmp.b	#17,bonus
	bne.s	not17
	move.b	#1,revers
	clr.b	laser
	clr.b	auto
	move.l	#-1,extend
	move.l	#-1,extend2
	clr.b	hold
	clr.b	twoschl
	clr.b	twoball
	lea	sprite2,a3
	clr.b	1(A3)
	clr.b	level
	bra.L	cfall
not17:
	cmp.b	#15,bonus
	bne.s	not15
	move.b	#1,level
	clr.b	auto
	clr.b	twoball
	clr.b	laser
	clr.b	hold
	clr.b	revers
	clr.b	twoschl
	move.l	#-1,extend
	move.l	#-1,extend2
	lea	sprite2,a3
	clr.b	1(A3)
	bra.s	cfall
not15:
hitschl:
	cmp.b #240,(a3)
	bls.s f2
	clr.b falling
	clr.b (a3)
	move.b #$b,2(A3)
f2:
	movem.l (sp)+,d0-d7/a0-a5
	rts

starttwo:
	tst.b twoball
	beq ok3
	rts
ok3:
	move.b #1,twoball
	lea sprite1,a3
	lea sprite2,a4
	move.l (a3),(a4)
	
	lea spr1+4,a3
	lea spr2+4,a4
	move.l (a3),(a4); Daten kopieren

	move $dff006,d2
	and #7,d2
	lsl #1,d2
	lea shake_table,a3
	add.l d2,a3
	move.b 1(a3),3(a4)
	neg.b 2(a4)
	rts

cfall:
	move.b #1,alter
	lea fspr1,a3
	clr.b 1(a3)
	clr.b falling
	add.l #10,score
	bra.L hitschl
begin:
	movem.l d0-d7/a0-a5,-(sp)
	tst.b falling
	beq.s okl
	movem.l (sp)+,d0-d7/a0-a5
	rts
okl:
	lea falling,a2
	move.b #1,(a2)
	move.b d2,d6
	move.b d1,d5
	lsl.b #3,d5
	lsl.b #3,d6
	add.b #50,d6
	add.b #81,d5

	lea fspr1,a3
	move.b d6,(a3)+
	move.b d5,(a3)+
	add.b #13,d6
	move.b d6,(a3)+
	move.b d7,bonus
	movem.l (sp)+,d0-d7/a0-a5
	rts

alles_geloescht:
	lea zspeicher+14,a4
	move #175,d5
aloop:
	move.b (a4)+,d4
	tst.b d4
	bne.s aloop2
	dbra d5,aloop
	clr d0
	rts
aloop2:
	cmp.b #8,d4
	bne.s aloop3
	dbra d5,aloop
	clr d0
	rts
aloop3:
	move #$ffff,d0
	rts

initblockcolors:
	lea zspeicher+2,a0
	lea coppercol+32+2,a1
	move #5,d7
ibcloop1:
	move (a0)+,(a1)
	addq #4,a1
	dbra d7,ibcloop1
	rts
htoz:
	lea zspeicher,a0
	move.l hspeicher,a1
	add.l stufe2,a1
	move #94,d7
htoz1:
	move (a1)+,(a0)+
	dbra d7,htoz1
	rts
ztoh:
	move.l hspeicher,a0
	lea zspeicher,a1
	add.l stufe2,a0	
	move #94,d7
ztohloop:
	move (a1)+,(a0)+
	dbra d7,ztohloop
	rts
histufe:
	dc.l	0
stufe2:
	dc.l	0*190
allocmem:
	move.l 4,a6
	move.l #$56000,d0
	move.l #$28000,a1
	jsr -204(a6)
	rts

initlib:
	move.l 4,a6
	lea gfxlib,a1
	jsr -408(a6)
	beq exit
	move.l d0,gfxbase
	rts

initsound:
	move	#0,$dff0a8
	move	#0,$dff0b8
	move	#0,$dff0c8
	move	#0,$dff0d8

	move #$800f,$dff096		; Alle Kanaele on

	move.l #$3b500,$dff0c0
	move #30575+12,$dff0c4
	move #430,$dff0c6
	move #30,$dff0c8

	move #1000,d7
wait_music:
	dbra d7,wait_music	

	move.l #$3b500,$dff0d0
	move #30575+12,$dff0d4
	move #430,$dff0d6
	move #30,$dff0d8
	rts

initcopper:
	move.l #copperl+2,a0	

	lea copperspr+2,a0	
	move.l #sprite1,d0	; Beginn des 1. Sprites
	move d0,4(a0)		; Obere 16 Bit einschreiben
	swap d0
	move d0,(a0)		; Untere 16 Bit einschreiben

	move.l #sprite2,d0
	move d0,12(a0)
	swap d0
	move d0,8(a0)
	
	move.l #fspr3,d0
	move d0,36(a0)
	swap d0
	move d0,32(a0)

	move.l #fspr2,d0
	move d0,44(a0)
	swap d0
	move d0,40(a0)

	move.l #fspr1,d0
	move d0,60(a0)
	swap d0
	move d0,56(a0)

	move.l #shoot1,d0
 	move d0,52(a0)
	swap d0
	move d0,48(a0)

	move.l #copperl,$dff080	; Start Copper
	rts

loadsound:
	move.l dosbase,a6
	move.l #$3ed,d2
	move.l #sound,d1
	jsr -30(a6)
	cmp.l #0,d0
	beq error
	move.l d0,-(sp)
	
	move.l d0,d1
	move.l #$70010,d2
	move.l #50000,d3
	jsr -42(a6)

	move.l (sp)+,d1
	jsr -36(a6)
	rts
sound:
	dc.b 'sound',0
even

loadstage:
	move.l	4,a6
	lea	diskIO,a1
	move	#2,command
	
	sub.l	d0,d0
	lea	stagename,a2
	move.b	5(A2),d0
	move.b	#'A',d0
	sub.b	#'A',d0
	mulu	#6144,d0
	add.l	#stagebase,d0
	move.l	d0,offset		; offset
	move.l	#6144,laenge		; laenge
	move.l	hspeicher,ziel		; buffer
	bsr	starttask
	bsr	wait_load
	move	#6,command
	bsr	starttask
	rts

stagename:
	dc.b 'STAGEA',0
even
hspeicher:
	dc.l $5e400

clrshadow:
	move.l	screen1,a1
	add.l	#40000,a1
	move	#1999,d7
clss:
	clr.l	(A1)+
	dbra	d7,clss

	move.l	screen1,a1
	add.l	#40244,a1

	move	#10,d7
clss2:
	move	#$ffff,(A1)
	move	#$ffff,40(A1)
	move	#$ffff,80(A1)
	move	#$ffff,120(A1)
	addq	#2,a1
	dbra	d7,clss2

	move.l	screen1,a1
	add.l	#40244,a1

	move	#193,d7
clss3:
	or.b	#%11100000,(A1)
	add	#40,a1
	dbra	d7,clss3
	rts

shadow:
	clr	refresh
;	move	$dff006,d0
;	and	#$ff00,d0
;	lsr	#8,d0
;	cmp	#145,d0
;	bne.s	shadow
;sh2:
	move.l	screen1,a1
	lea	zspeicher+14,a2
	add.l	#40244+40,a1
	
	moveq	#15,d7
ylo:
	moveq	#10,d6
	clr	d5
xlo:
	addq	#1,d5
	cmp	#1,d5
	bne.s	ws2
	move.b	#%11100000,d0
	or.b	d0,(A1)
	or.b	d0,40(A1)
	or.b	d0,80(A1)
	or.b	d0,120(A1)
	or.b	d0,160(A1)
	or.b	d0,200(A1)
	or.b	d0,240(A1)
	or.b	d0,280(A1)
ws2:
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
	rts

makeflash:
	lea	flashlist,a2
	lea	zspeicher+14,a1
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
	moveq	#7,d6
	bsr	makeflash
flall1:
	move.l	gfxbase,a6
	jsr	-270(A6)
	bsr	flash
	dbra	d6,flall1
	rts

clearflash:
	lea	flashlist,a1
	move	#74,d0
cfl:
	clr.l	(a1)+
	dbra	d0,cfl
	rts

flash:	
	clr	d1
	clr	d2
	lea	flashlist,a1
	move	#175,d7
floop:
	tst.b	(a1)
	beq.s	endf4
	add.b	#1,(A1)
	cmp.b	#9,(a1)
	bne.L	f22
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
	add	#1,a1
	dbra	d7,floop
	rts

draw_flash:
	movem.l d0-d7/a0-a5,-(sp)

	move.l	screen2,a1
	add	#22,a1
	lsl	#1,d0
	add	d0,a1		; source im speicher

	move.l	screen1,a3
	add	#284,a3
	lsl	#1,d1
	add	d1,a3
	mulu	#320,d2
	add	d2,a3		; ziel
	
	moveq #4,d7
draw_flash2:
	btst #14,$dff002
	bne.s draw_flash2

	move.l	a3,$dff054	;ziel D
	move.l	a1,$dff050	;bild A
	move	#38,$dff064	;modulo
	move	#38,$dff066	;modulo
	clr	$dff042		;0
	move	#$09f0,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l	#$ffffffff,$dff044 ;mask
	move	#%0000001000000001,$dff058		;groesse
	;	   hhhhhhhhhhwwwwww
	add.l	#8000,a3
	add.l	#8000,a1
	dbra	d7,draw_flash2
	movem.l	(sp)+,d0-d7/a0-a5
	rts	

draw_block:
	movem.l d0-d7/a0-a5,-(sp)

	move	#1,refresh

	cmp #8,d0
	bls.s nobonus
	move.l #9,d0
nobonus:
	move.l screen2,a1	; Blockdaten
	lsl #1,d0		; Startadresse =
	add.l d0,a1		; D0 * 4 + screen2
	move.l screen1,a2	; Ziel in Bildspeicher
	add.l #284,a2		; Startadresse =
	lsl #1,d1		; screen1 + 2 * d1 + 320 * d2 + 570
	add.l d1,a2
	mulu #320,d2
	add.l d2,a2

	tst.b d0
	beq.L clear_block

	move #38,$dff064	;modulo
	move #38,$dff066	;modulo
	clr $dff042		;0
	move #$09f0,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffffffff,$dff044 ;mask

	moveq #4,d7
draw_block2:
	btst #14,$dff002
	bne.s draw_block2
	move.l a2,$dff054	;ziel D
	move.l a1,$dff050	;Source A
	move #%0000001000000001,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a1
	add.l #8000,a2
	dbra d7,draw_block2
	
	movem.l (sp)+,d0-d7/a0-a5
	rts

clear_block:
	move.l screen3,a3
	add.l #28,a3
	add.l d1,a3
	divu #320,d2
	mulu #208,d2
	add.l d2,a3

	move #38,$dff066	;moduloD
	move #24,$dff064	;moduloA
	clr $dff042		;0
	move #$09f0,$dff040	;0 = use d,a d=a

	moveq #5,d7
clear_block2:
	btst #14,$dff002
	bne clear_block2
	move.l a3,$dff050	;SourceA
	move.l a2,$dff054	;ziel D
 	move.l #$ffffffff,$dff044 ;mask
	move #%0000001000000001,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #5044,a3
	add.l #8000,a2
	dbra d7,clear_block2

	movem.l (sp)+,d0-d7/a0-a5
	rts

draw_live:
	movem.l d0-d7/a0-a5,-(sp)	; d0=x,d1=set/clr

	move.l screen2,a0
	add.l #20,a0		; Bild
	move.l a0,a1
	add.l #2,a1		; Maske

	move.l screen1,a2
	add.l #40*192+24,a2
	lsl #1,d0
	sub.l d0,a2

	tst.b d1
	beq.L clear_live

	move #38,$dff060	;modulo
	move #38,$dff062	;modulo
	move #38,$dff064	;modulo
	move #38,$dff066	;modulo
	clr $dff042		;0
	move #$0fca,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffffffff,$dff044 ;mask

	moveq #4,d7
draw_live2:
	btst #14,$dff002
	bne.s draw_live2
	move.l a0,$dff04c	;B
	move.l a2,$dff048	;C
	move.l a2,$dff054	;D
	move.l a1,$dff050	;A
	move #%0000001000000001,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_live2
	
	movem.l (sp)+,d0-d7/a0-a5
	rts

clear_live:
	move.l screen3,a3
	add.l #186*26+22,a3 ;26*192+0,a3
	sub.l d0,a3

	move #38,$dff066	;moduloD
	move #24,$dff064	;moduloA
	clr $dff042		;0
	move #$09f0,$dff040	;0 = use d,a d=a

	moveq #4,d7
clear_live2:
	btst #14,$dff002
	bne.s clear_live2
	move.l a3,$dff050	;SourceA
	move.l a2,$dff054	;ziel D
 	move.l #$ffffffff,$dff044 ;mask
	move #%0000001000000001,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #5044,a3
	add.l #8000,a2
	dbra d7,clear_live2

	movem.l (sp)+,d0-d7/a0-a5
	rts

expltable:
dc.w 2280,2286,2292,2298,2304,2310
dc.w 3240,3246,3252,3258,3264,3270
dc.w 4200,4206,4212,4218,4224,4230

explosion:
	move.b	#1,paused
	clr.b	exploding

	move	#3,$dff096
	move.l	#$71100,$dff0a0
	move	#12500,$dff0a4
	move	#255,$dff0a6
	move	#$8003,$dff096

	move.l	#$71500,$dff0b0
	move #12500,$dff0b4
	move #255,$dff0b6

	clr power
	clr.b laser
	clr.b auto
	move.l #4,schl
	clr.b hold
	clr.b twoball
	lea sprite1,a2
	clr.b 1(a2)
	lea sprite2,a2
	clr.b 1(A2)
	clr.b level
	clr.b revers

	lea sprite1,A0
	clr.b 1(a0)

	lea fspr1,a0
	clr.b 1(a0)

	lea shoot1,a0
	clr.b 1(A0)

	move mousx,x
	move mousx2,x2
	clr.l d6
	lea schl_col+2,a0
	move #$fb0,4(a0)
	move #$f90,8(A0)
	move #$f00,16(A0)
	move #$fe0,28(A0)
explo2:
	move.l gfxbase,a6
	jsr -270(a6)
	jsr -270(a6)
	jsr -270(a6)
	jsr -270(a6)
w8:
	move.l $dff004,d2
	and.l #$0001ff00,d2
	cmp.l #$fa00,d2
	bne.s w8

	move.l screen1,a2
	add.l #7162-320,a2
	move.l screen3,a3
	add.l #$1192-208,a3	

	move #14,$dff066	;moduloD
	move #0,$dff064	;moduloA
	clr $dff042		;0
	move #$09f0,$dff040	;0 = use d d=a
	move.l #$ffffffff,$dff044 ;mask

	moveq #4,d7
clear_explo:
	btst #14,$dff002
	bne.s clear_explo

	move.l a2,$dff054	;ziel D
	move.l a3,$dff050	;Source A
	move #%0000010100001101,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a2
	add.l #5044,a3
	dbra d7,clear_explo

	move.l screen2,a0
	lsl #1,d6	; Counter
	lea expltable,a4
	add.l d6,a4
	add (a4),a0	; Anfangadresse
	lsr #1,d6

	move.l a0,a1
	add.l #2880,a1	; Maske

	move x,d0
	move d0,d3		; D0 = X-Koordinate in Pixels
	and #$000F,d3		; Shift bestimmen
	lsr #3,d0		; Words bestimmen
	bclr #0,d0
	
	lsl #8,d3
	lsl #4,d3
	move d3,d2		; Shift fuer BPLcon0
	add #$0fca,d2		; Shift fuer BPLcon1

	move.l screen1,a2	; Ziel im Screen1
	add.l #7164-360,a2	; = screen1+14330+words
	add.l d0,a2
	
	moveq #4,d7
draw_explo2:
	btst #14,$dff002
	bne.s draw_explo2
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #34,$dff060	;modulo
	move #34,$dff062	;modulo
	move #34,$dff064	;modulo
	move #34,$dff066	;modulo
	move d3,$dff042	;d3	;0
	move d2,$dff040;d2	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffffffff,$dff044 ;mask
	move #%0000010111000011,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_explo2

	move.l screen2,a0
	lsl #1,d6	; Counter
	lea expltable,a4
	add.l d6,a4
	add (a4),a0	; Anfangadresse
	lsr #1,d6

	move.l a0,a1
	add.l #2880,a1	; Maske

	move x2,d0
	move d0,d3		; D0 = X-Koordinate in Pixels
	and #$000F,d3		; Shift bestimmen
	lsr #3,d0		; Words bestimmen
	bclr #0,d0
	
	lsl #8,d3
	lsl #4,d3
	move d3,d2		; Shift fuer BPLcon0
	add #$0fca,d2		; Shift fuer BPLcon1

	move.l screen1,a2	; Ziel im Screen1
	add.l #7164-360,a2	; = screen1+14330+words
	add.l d0,a2
	
	moveq #4,d7
draw_explo23:
	btst #14,$dff002
	bne.s draw_explo23
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #34,$dff060	;modulo
	move #34,$dff062	;modulo
	move #34,$dff064	;modulo
	move #34,$dff066	;modulo
	move d3,$dff042	;d3	;0
	move d2,$dff040;d2	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffffffff,$dff044 ;mask
	move #%0000010111000011,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_explo23

	add #1,d6
	cmp #18,d6
	bne.L explo2

	move.l #$70000,$dff0a0
	move #2,$dff0a4
	move.l #$70000,$dff0b0
	move #2,$dff0b4		; Sound off

	lea	schl_col+2,a0
	move	#$d00,(A0)
	move	#$ddd,4(a0)
	move	#$aaa,8(A0)
	move	#$999,16(A0)
	move	#$fff,28(A0)
	move	#$aaa,32(A0)

	sub.b	#1,lives
	cmp.b	#-1,lives
	bne.s	notlives
	bra.s	game_over
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
	move.l	gfxbase,a6
	moveq	#25,d7
waitexplo:
	jsr	-270(a6)
	dbra	d7,waitexplo
	bra	exit2

moveschlleft:
	clr.b	leftout
	move.b	#1,paused
	move	#31,d5
moveleft2:
	move.l	gfxbase,a6
	jsr	-270(a6)
w6:
	move.l $dff004,d2
	and.l #$0001ff00,d2
	cmp.l #$fa00,d2
	bne.s w6

	move.l screen1,a2
	add.l #7162,a2
	move.l screen3,a3
	add.l #$1192,a3	

	move #16,$dff066	;moduloD
	move #2,$dff064	;moduloA
	clr $dff042		;0
	move #$09f0,$dff040	;0 = use d d=a
	move.l #$ffffffff,$dff044 ;mask

	moveq #5,d7
clear_left:
	btst #14,$dff002
	bne.s clear_left

	move.l a2,$dff054	;ziel D
	move.l a3,$dff050	;Source A
	move #%0000001110001100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a2
	add.l #5044,a3
	dbra d7,clear_left

	move d5,d3		; D0 = X-Koordinate in Pixels
	move d5,d0
	and #$000F,d3		; Shift bestimmen
	lsr #3,d0		; Words bestimmen
	bclr #0,d0
	lsl #8,d3
	lsl #4,d3
	move d3,d2		; Shift fuer BPLcon0
	add #$0fca,d2		; Shift fuer BPLcon1

	move.l screen2,a0	 
	add.l #1040+24,a0		; Schlaeger
	move.l screen1,a2	; Ziel im Screen1
	add.l #7164-4,a2	; = screen1+14330+words
	add.l d0,a2

	move.l a0,a1		; Maske
	add.l #320,a1	

	move #4,d7
draw_left2:
	btst #14,$dff002
	bne draw_left2
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #32,$dff060	;modulo
	move #32,$dff062	;modulo
	move #32,$dff064	;modulo
	move #32,$dff066	;modulo
	move d3,$dff042		;0
	move d2,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffff0000,$dff044 ;mask
	move #%0000001000000100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_left2
	
	move.l screen2,a0
	add.l #1692,a0	; Source
			; Rand ueberdecken
	move.l a0,a1
	add.l #4,a1

	move.l screen1,a2
	add.l #7000,a2	; Ziel

	moveq #4,d7
clr_left4:
	btst #14,$dff002
	bne.s clr_left4

	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #36,$dff060	;modulo
	move #36,$dff062	;modulo
	move #36,$dff064	;modulo
	move #36,$dff066	;modulo
	clr $dff042		;0
	move #$0fca,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffffffff,$dff044 ;mask
	move #%0000010000000010,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a2
	add.l #8000,a0
	dbra d7,clr_left4

	dbra d5,moveleft2
	bra prelevel

moveschlright:
	clr.b rightout
	move.b #1,paused
	move #148,d5
moveright2:
	move.l gfxbase,a6
	jsr -270(a6)
w7:
	move.l $dff004,d2
	and.l #$0001ff00,d2
	cmp.l #$fa00,d2
	bne.s w7

	move.l screen1,a2
	add.l #7162+18,a2
	move.l screen3,a3
	add.l #$1192+18,a3	

	move #32,$dff066	;moduloD
	move #18,$dff064	;moduloA
	clr $dff042		;0
	move #$09f0,$dff040	;0 = use d d=a
	move.l #$ffffffff,$dff044 ;mask

	moveq #5,d7
clear_right:
	btst #14,$dff002
	bne.s clear_right

	move.l a2,$dff054	;ziel D
	move.l a3,$dff050	;Source A
	move #%0000001110000100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a2
	add.l #5044,a3
	dbra d7,clear_right

	move d5,d3		; D0 = X-Koordinate in Pixels
	move d5,d0
	and #$000F,d3		; Shift bestimmen
	lsr #3,d0		; Words bestimmen
	bclr #0,d0
	lsl #8,d3
	lsl #4,d3
	move d3,d2		; Shift fuer BPLcon0
	add #$0fca,d2		; Shift fuer BPLcon1

	move.l screen2,a0	 
	add.l #1040+24,a0		; Schlaeger
	move.l screen1,a2	; Ziel im Screen1
	add.l #7164,a2	; = screen1+14330+words
	add.l d0,a2
	move.l a0,a1		; Maske
	add.l #320,a1	

	move #4,d7
draw_right2:
	btst #14,$dff002
	bne.s draw_right2
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #32,$dff060	;modulo
	move #32,$dff062	;modulo
	move #32,$dff064	;modulo
	move #32,$dff066	;modulo
	move d3,$dff042		;0
	move d2,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffff0000,$dff044 ;mask
	move #%0000001000000100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_right2
	
	move.l screen2,a0
	add.l #1700,a0	; Source
	
	move.l a0,a1
	add.l #4,a1

	move.l screen1,a2
	add.l #7026,a2	; Ziel

	moveq #4,d7
clr_right4:
	btst #14,$dff002
	bne.s clr_right4

	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #36,$dff060	;modulo
	move #36,$dff062	;modulo
	move #36,$dff064	;modulo
	move #36,$dff066	;modulo
	clr $dff042		;0
	move #$0fca,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffffffff,$dff044 ;mask
	move #%0000010000000010,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a2
	add.l #8000,a0
	dbra d7,clr_right4

	add #1,d5
	cmp #181,d5
	bne.L moveright2
	bra nextlevel
	
draw_schl:
	movem.l d0-d7/a0-a5,-(sp)	; D1=Schlaeger
	tst.b	twoplayer
	bne.s	nt2
	move.l	schl,schl2
	move.l	extend,extend2
nt2:
	move.l schl,d1
	move mousx,d0

	clr.l d5
	move d0,d5
	move.l d5,d0

	btst	#6,$bfe001
	bne.s	notauto
	tst.b	demo
	bne.s	notauto
delauto:
	clr.b auto
notauto:
	tst.b d0
	bhi.s notcorrect

	tst.b level
	beq.s notlevel1

	move.b #1,leftout
notlevel1:
	move #1,d0
	move #1,mousx
	move #2,imgx
	bra.s lo2
notcorrect:
	move d1,d3
	lea tabelle,a5
	lsl #1,d3
	add.l d3,a5

	cmp (a5),d0
	blt.s lo2

	tst.b level
	beq.s notlevel2

	move.b #1,rightout
notlevel2:				; Unterprogramms
	move (a5),d0
	move (a5),mousx
lo2:
	move.l screen1,a2		; D0=X-Koordinate
	add.l #7084,a2

	move.l screen3,a3
	add.l #4448,a3	

	moveq #5,d7
draw_schl1:
	btst #14,$dff002
	bne.s draw_schl1

	move	#18,$dff066		;moduloD
	move	#4,$dff064		;moduloA
	clr	$dff042		
	move	#$09f0,$dff040
	move.l	#$ffffffff,$dff044 ;mask

	move.l a2,$dff054	;ziel D
	move.l a3,$dff050	;Source A
	move #%0000001110001011,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a2
	add.l #5044,a3
	dbra d7,draw_schl1

	move d0,d3		; D0 = X-Koordinate in Pixels
	and #$000F,d3		; Shift bestimmen
	lsr #3,d0		; Words bestimmen
	bclr #0,d0
	lsl #8,d3
	lsl #4,d3
	move d3,d2		; Shift fuer BPLcon0
	add #$0fca,d2		; Shift fuer BPLcon1

	move.l screen2,a0	 
	add.l #1040,a0		; Schlaeger
	mulu #6,d1
	add.l d1,a0	
	move.l a0,a4

	move.l screen1,a2	; Ziel im Screen1
	add.l #7164,a2		; = screen1+14330+words
	add.l d0,a2
	
	move.l a0,a1		; Maske
	add.l #320,a1	
	
	moveq #4,d7
draw_schl2:
	btst #14,$dff002
	bne.s draw_schl2
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #32,$dff060	;modulo
	move #32,$dff062	;modulo
	move #32,$dff064	;modulo
	move #32,$dff066	;modulo
	move d3,$dff042		;0
	move d2,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffff0000,$dff044 ;mask
	move #%0000001000000100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_schl2

	move d3,d2
	add #$0fca,d2
	add.l #120,a2

	move.l a4,a0
	sub.l #400,a0	
	move.l a0,a1
draw_schl3:
	btst #14,$dff002
	bne.s draw_schl3
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #32,$dff060	;modulo
	move #32,$dff062	;modulo
	move #32,$dff064	;modulo
	move #32,$dff066	;modulo
	move d3,$dff042		;0
	move d2,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffff0000,$dff044 ;mask
	move #%0000001000000100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww

	move mousx2,d0
	move.l schl,d1

	btst #6,$bfe001
	bne.s notauto234
	clr.b auto
notauto234:
	tst.b d0
	bhi.s notcorrect234

	tst.b level
	beq.s notlevel234

	move.b #1,leftout
notlevel234:
	move #1,d0
	move #1,mousx2
	move #2,imgx2
	bra.s lo234
notcorrect234:
	move d1,d3
	lea tabelle,a5
	lsl #1,d3
	add.l d3,a5

	cmp (a5),d0
	blt.s lo234

	tst.b level
	beq.s notlevel235

	move.b #1,rightout
notlevel235:			  ; Unterprogramms
	move (a5),d0
	move (a5),mousx2
lo234:
	move d0,d3		; D0 = X-Koordinate in Pixels
	and #$000F,d3		; Shift bestimmen
	lsr #3,d0		; Words bestimmen
	bclr #0,d0
	lsl #8,d3
	lsl #4,d3
	move d3,d2		; Shift fuer BPLcon0
	add #$0fca,d2		; Shift fuer BPLcon1

	move.l schl2,d1
	move.l screen2,a0	 
	add.l #1040,a0		; Schlaeger
	mulu #6,d1
	add.l d1,a0	
	move.l a0,a4

	move.l screen1,a2	; Ziel im Screen1
	add.l #7164,a2		; = screen1+14330+words
	add.l d0,a2
	
	move.l a0,a1		; Maske
	add.l #320,a1	
	
	moveq #4,d7
draw_schl5:
	btst #14,$dff002
	bne.s draw_schl5
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #32,$dff060	;modulo
	move #32,$dff062	;modulo
	move #32,$dff064	;modulo
	move #32,$dff066	;modulo
	move d3,$dff042		;0
	move d2,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffff0000,$dff044 ;mask
	move #%0000001000000100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_schl5

	move d3,d2
	add #$0fca,d2
	add.l #120,a2

	move.l a4,a0
	sub.l #400,a0	
	move.l a0,a1
draw_schl6:
	btst #14,$dff002
	bne.s draw_schl6
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #32,$dff060	;modulo
	move #32,$dff062	;modulo
	move #32,$dff064	;modulo
	move #32,$dff066	;modulo
	move d3,$dff042		;0
	move d2,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffff0000,$dff044 ;mask
	move #%0000001000000100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww

	move.l	screen1,a1
	add.l	#47044,a1
	moveq	#15,d7
dosh:
	or.b	#%11100000,(A1)
	and.b	#%01111111,22(A1)
	add	#40,a1
	dbra	d7,dosh

	movem.l (sp)+,d0-d7/a0-a5
	rts

tabelle:
	dc.w 140,142,144,146,148,148
tabelle2:
	dc.w 19,18,17,16,15,15
tabelle3:
	dc.w 150,152,154,156,158,158

decruncher:
;a0    ;gecrunchtes File
;a1    ;Ziel
;d4    ;Groesse des Ziel

	clr.l d0
eloop1:
	move.b (a0),d1
	and.b #$80,d1
	cmp.b #$80,d1            ;gecruncht ?
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
	move.w 	$dff00a,d0
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#$ff,d0
	move.b	d0,oldx
	
mousehandler:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b auto
	beq.s handler2

	clr.l d5
	lea sprite1,a3
	move.b 1(a3),d5
	lsl #1,d5
	sub #162,d5

	move d5,mousx
	lsl #1,d5
	move d5,imgx
	bra.L endhandler
handler2:
	tst joy1
	beq m24
	move $dff00a,d0
	btst #9,d0
	beq.s nli1
	sub #4,mousx
	sub #8,imgx
	bra.s endhandler
nli1:
	btst #1,d0
	beq.s nre1
	add #4,mousx
	add #8,imgx
	bra.s endhandler
nre1:
	clr d0
	bra.s endhandler
m24:
	move.w 	$dff00a,d0
	move.w	d0,d1
	lsr.w	#8,d1			; x in d0/y in d1
	and.w	#$ff,d0
m23:
	tst.b revers
	beq.s notrev
	neg.b d0
notrev:
	clr.w	d2

	move.b	oldx,d2
	move.b	d0,oldx

	sub.b	d0,d2			; x-cord
	tst.b	d2
	beq.s	endhandler
	move.b	d2,d4
	tst.b	d2
	bpl.s	mous1
	neg.b	d2
mous1:	
	cmp.b	#127,d2
	bgt.s	mous2
	ext.w	d4
	sub.w	d4,imgx
	bra.s	endhandler
mous2:	
	sub.b	#255,d4
	ext.w	d4
	sub.w	d4,imgx
endhandler:
	move.w	imgx,d0			; set real cords
	asr.w	#1,d0			; check boundary

	cmp	#0,d0
	bgt.s	mous7
	move.w	#0,d0
	move.w	#0,imgx
mous7:
	tst.b	battle
	bne.s	mous86
	tst.b	twoplayer
	bne.s	twocheck	; Falls 2 Spieler raender anpassen
mous86:
	cmp.w	#149,d0
	blt.s	mous8
	move.w	#150,d0
	move.w	#300,imgx
	bra.s	mous8
twocheck:
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
	
	move d0,mousx2
	lsl #1,d0
	move d0,imgx2
	bra.L endhand		; 1 Player 1 Schl
tschl:
	move.l schl,d1
	lea tabelle3,a1
	lsr #1,d1
	add.l d1,a1
	move (a1),d1
	sub d0,d1
	move d1,mousx2
	lsl #1,d1
	move d1,imgx2		; 2schl bonus
	bra endhand
tpl:
	tst.b auto
	beq.s handler22

	clr.l d5
	lea sprite1,a3
	move.b 1(a3),d5
	lsl #1,d5
	sub #162,d5

	move d5,mousx2
	lsl #1,d5
	move d5,imgx2
	bra.L endhandler2
handler22:
	tst	joy2
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
	lsr.w	#8,d1			; x in d0/y in d1
	and.w	#$ff,d0

	tst.b	revers
	beq.s	notrev2
	neg.b	d0
notrev2:
	clr	d2
	move.b	oldx2,d2
	move.b	d0,oldx2

	sub.b	d0,d2			; x-cord
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
endhandler2:
	move.w	imgx2,d0		; set real cords
	asr.w	#1,d0			; check boundary

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
	dc.l $4c000
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
dc.w $00e2,$0000	; Bitplane 1	
dc.w $00e4,$0006
dc.w $00e6,$1f40	; Bitplane 2
dc.w $00e8,$0006
dc.w $00ea,$3e80	; Bitplane 3
dc.w $00ec,$0006
dc.w $00ee,$5dc0	; Bitplane 4
dc.w $00f0,$0006
dc.w $00f2,$7d00	; Bitplane 5
dc.w $00f4,$0006
dc.w $00f6,$9c40	; Bitplane 6

copperspr:
dc.w $0120,$0000
dc.w $0122,$0000	; Sprite 0
dc.w $0124,$0000
dc.w $0126,$0000	; Sprite 1
dc.w $0128,$0000
dc.w $012a,$0000	; Sprite 2
dc.w $012c,$0000
dc.w $012e,$0000	; Sprite 3
dc.w $0130,$0000
dc.w $0132,$0000	; Sprite 4
dc.w $0134,$0000
dc.w $0136,$0000	; Sprite 5
dc.w $0138,$0000
dc.w $013a,$0000	; Sprite 6
dc.w $013c,$0000
dc.w $013e,$0000	; Sprite 7

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
	dc.w $01a2,$ddd	; Farben fuer Baelle
	dc.w $01a4,$aaa
	dc.w $01a6,$113
	dc.w $01a8,$320
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
	dc.w $01be,$fff		; Farbe fuer Laser

dc.w $0098,$f208
dc.w $0180,$0000	; Color0=schwarz

dc.w $008e,$2c79	; DIWstrt
dc.w $0090,$f4c1	; DIWstop
dc.w $0100,$6200	; BPLcon0
dc.w $0104,$0024	; BPLcon2
dc.w $0092,$0038	; DDFstrt
dc.w $0094,$00d2	; DDFstop

dc.w $0102,$0000	; BPLCON1
dc.w $0108,$0000	; BPL1mod

powerturm:
dc.w $018a,$000
dc.w $010a,$0000	; BPL2mod	

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

dc.w $9021,$fffe
dc.w $018a,$0fc0
dc.w $1be,$2f0

dc.w $9721,$fffe
dc.w $018a,$0fb0
dc.w $1be,$2f0

dc.w $009c,$8010		; Interrupt

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

dc.w $d321,$fffe

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
dc.w $018a,$0f00
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
dc.w $00e2,$0000	; Bitplane 1	
dc.w $00e4,$0006
dc.w $00e6,$1f40	; Bitplane 2
dc.w $00e8,$0006
dc.w $00ea,$3e80	; Bitplane 3
dc.w $00ec,$0006
dc.w $00ee,$5dc0	; Bitplane 4
dc.w $00f0,$0006
dc.w $00f2,$7d00	; Bitplane 5
dc.w $00f4,$0006
dc.w $00f6,$9c40	; Bitplane 6

dc.w $0120,$0007
dc.w $0122,$0000	; Sprite 0
dc.w $0124,$0007
dc.w $0126,$0000	; Sprite 1
dc.w $0128,$0007
dc.w $012a,$0000	; Sprite 2
dc.w $012c,$0007
dc.w $012e,$0000	; Sprite 3
dc.w $0130,$0007
dc.w $0132,$0000	; Sprite 4
dc.w $0134,$0007
dc.w $0136,$0000	; Sprite 5
dc.w $0138,$0007
dc.w $013a,$0000	; Sprite 6
dc.w $013c,$0007
dc.w $013e,$0000	; Sprite 7

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
dc.w $01a2,$0	; Farben fuer Baelle
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
dc.w $01be,$0		; Farbe fuer Laser

dc.w $0098,$f208
dc.w $0180,$0000	; Color0=schwarz

dc.w $008e,$2c79	; DIWstrt
dc.w $0090,$f4c1	; DIWstop
dc.w $0100,$6200	; BPLcon0
dc.w $0104,$0024	; BPLcon2
dc.w $0092,$0038	; DDFstrt
dc.w $0094,$00d2	; DDFstop

dc.w $0102,$0000	; BPLCON1
dc.w $0108,$0000	; BPL1mod
dc.w $010a,$0000	; BPL2mod	

dc.w $3021,$fffe
dc.w $018a,$0
dc.w $01be,$0

dc.w $3721,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $3e21,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $4521,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $4c21,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $5321,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $5a21,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $6121,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $6821,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $6f21,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $7621,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $7d21,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $8421,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $8b21,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $9221,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $9921,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $a021,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $a721,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $ae21,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $b521,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $bc21,$fffe
dc.w $018a,$0
dc.w $01be,$0

dc.w $c321,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $ca21,$fffe
dc.w $018a,$0
dc.w $1be,$0

dc.w $d921,$fffe
dc.w $018a,$0
dc.w $0190,$0
dc.w $0192,$0
dc.w $0194,$0
dc.w $0196,$0
dc.w $0198,$0
dc.w $019a,$0
dc.w $019c,$0
dc.w $019e,$0

dc.w $018a,$000
dc.w $e021,$fffe
dc.w $018a,$00
dc.w $e121,$fffe
dc.w $018a,$00
dc.w $e221,$fffe
dc.w $018a,$00
dc.w $e321,$fffe
dc.w $018a,$00
dc.w $e421,$fffe
dc.w $018a,$00
dc.w $e521,$fffe
dc.w $018a,$00
dc.w $e621,$fffe
dc.w $018a,$000
dc.w $e721,$fffe
dc.w $018a,$000
dc.w $ffff,$fffe 

shoot1:
dc.w $0000,$0000
dc.w $0080,$0080
dc.w $01C0,$01C0
dc.w $01C0,$01C0
dc.w $03E0,$03E0
dc.w $03E0,$03E0
dc.w $03E0,$03E0
dc.w $07F0,$07F0
dc.w $07F0,$07F0
dc.w $07F0,$07F0
dc.w $07F0,$07F0
dc.w $07F0,$07F0
dc.w $07F0,$07F0
dc.w $07F0,$07F0
dc.w $07F0,$07F0
dc.w $0000,$0000
dc.w $07F0,$07F0
dc.w $0000,$0000

fspr3:
dc.w $0,0
dc.w $ffff,$ffff
dc.w $ffff,$ffff
dc.w $ffff,$ffff
dc.w $ffff,$ffff
dc.w $ffff,$ffff
dc.w $ffff,$ffff
dc.w $0,0

fspr2:
dc.w $0080,$0
dc.w $0ff0,$0ff0
dc.w $0ff0,$0ff0
dc.w $0ff0,$0ff0
dc.w $0ff0,$0ff0
dc.w $0ff0,$0ff0
dc.w $0,$0

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

dc.w $0000,$0000
dc.w $0700,$0000
dc.w $0F80,$0000
dc.w $1FC0,$0000
dc.w $1FC0,$0000
dc.w $3DE0,$0000
dc.w $38E0,$0000
dc.w $38E0,$0000
dc.w $38E0,$0000
dc.w $3DE0,$0000
dc.w $1FC0,$0000
dc.w $1FC0,$0000
dc.w $0F80,$0000
dc.w $0700,$0000
dc.w $0000,$0000

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
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0078
	dc.w $0030,$00CC
	dc.w $0078,$0084
	dc.w $0078,$0084
	dc.w $0030,$00CC
	dc.w $0000,$0078
	dc.w $0000,$0000
sprite2:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0078
	dc.w $0030,$00CC
	dc.w $0078,$0084
	dc.w $0078,$0084
	dc.w $0030,$00CC
	dc.w $0000,$0078
	dc.w $0000,$0000
spr1:
	dc.l sprite1		; Adresse des Sprites
	dc.b 0,0,1,1	; x,y,dx,dy
spr2:
	dc.l sprite2		; Adresse des Sprites
	dc.b 0,0,1,2	; x,y,dx,dy
hit:
	dc.w 0
zspeicher:
	blk 300,0
flashlist:
	blk 300,0
even

check_ball:
	move.l	(A1),a0
	move.b	4(A1),d1
	move.b	5(A1),d2
	move.b	6(A1),d3
	move.b	7(A1),d4

	tst.b	d4
	bmi	endcheck

	cmpi.b	#218,d2
	bls	endcheck
	cmpi.b	#221,d2
	bhi.L	endcheck
	
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
	lea	tabelle2,a2
	add.l	d6,a2
	add	(a2),d5	; Schlaeger getroffen ?

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
	lea	tabelle2,a2
	add.l	d6,a2
	add	(a2),d5	; Schlaeger getroffen ?

	cmp.b	d5,d1
	bhi.L	daneben
	bne.s	nr4
	move.b	#1,d3
nr4:
	move	dist2,d6
	move.b	#1,kept
treffer:
	move.b	#218,d2
	move.b	d2,(a0)
	add.b	#7,d2
	move.b	d2,2(a0)
	sub.b	#7,d2

	tst.b	hold
	beq.s	donthold
	move	#1,kept2
	move	#1,waitb
	bra.s	loop2
donthold:
	tst	d6
	beq	loop2
	bpl	schllinks

	tst.b	d3		; (Schlaeger rechts)
	beq	loop2
	bpl	ballrechts1	; Ball links
balllinks1:
 	addq.b	#1,d4
	cmpi.b	#4,d4
	bhi.s	loop2
	moveq	#3,d4		; Winkel +
	bra.s	loop2
ballrechts1:			; Ball rechts
	subq.b	#1,d4
	tst.b	d4
	bne.s	loop2
	moveq	#1,d4		; Winkel -
	bra.s	loop2
schllinks:
	tst.b d4			; Schlaeger links
	beq.s loop2
	bpl.s ballrechts2
balllinks2:
	subq.b	#1,d4		; Ball links 
	tst.b	d3
	bne.s	loop2
	moveq	#1,d4		; Winkel -
	bra.s	loop2
ballrechts2:			; Ball rechts
	addq.b	#1,d4
	cmpi.b	#4,d4
	bhi.s	loop2
	moveq	#3,d4		; Winkel +
loop2:	
	neg.b	d4
daneben:
endcheck:
	move.b d4,7(a1)		; Delta Y sichern
	move.b d3,6(a1)		; Delta X sichern
	move.b d2,5(a1)		; Y sichern
	move.b d1,4(a1)		; X sichern
	rts

checkspry:
	cmpi.b	#250,d2
	bhi.s	weiterc5
	rts
weiterc5:
	tst.b	twoball
	bne.s	extwo
	move.b	#1,exploding
	rts
extwo:
	clr.b	twoball
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
notthe2:
	lea	sprite2,a5
	clr.b	1(a5)
	rts

check_block:
	movem.l	d0-d3/d5-d7/a0-a5,-(sp)

	move.b	d5,d1
	move.b	d6,d2

	sub.b	#78,d1
	sub.b	#49,d2

	lsr	#3,d1
	lsr	#3,d2

	move	d1,x4
	lea	zspeicher+14,a4
	add	d1,a4
	move	d2,d5
	mulu	#11,d5
	move	d5,y4
	add	d5,a4

	move.b	(A4),d7
	move.b	d7,sicher
	and.b	#31,d7
	tst.b	d7
	beq	notcol		; Kein Stein

	cmp.b	#8,d7
	beq	notdel		; Unzerstoerbar
	
	cmp.b	#6,d7
	bls.s	notmehr		; Falls kleiner als 7 -> loeschen

	cmp.b	#14,d7
	bne.s	not2		; Explosion

	movem.l	d0-d7/a0-a3,-(sp)
	add.l	#10,score
	clr.l	d0		; Block loeschen
	clr.l	d1		; Von 0-10, Y in d2

	lea	zspeicher+14,a5
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
	bne.s	notmehr	; Mehrmals treffen

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
	neg.b	d4
	bra.s	notcol
notdel:
	and.b	#$f,d7

	cmp.b	#8,d7
	beq.s	c68		; gold

	tst.b	smash
	bne.s 	notcol
	moveq	#1,d5		; silber
	bra.s	c69
c68:
	move.b	#149,d5		; gold
c69:
	lea	flashlist,a3
	add	x4,a3
	add	y4,a3
	move.b	d5,(A3)	
	neg.b	d4
notcol:
	movem.l	(sp)+,d0-d3/d5-d7/a0-a5
	move.b	sicher,d0
	rts


font:
dc.b $00,$F8,$48,$48,$48,$48,$48,$7C,$00,$00
dc.b $00,$10,$10,$10,$10,$10,$10,$10,$00,$00
dc.b $00,$3E,$04,$24,$3C,$20,$20,$7C,$00,$00
dc.b $00,$20,$10,$08,$3C,$08,$10,$20,$00,$00
dc.b $00,$20,$20,$28,$7C,$28,$08,$08,$00,$00
dc.b $00,$78,$20,$20,$78,$08,$08,$7C,$00,$00
dc.b $00,$04,$08,$10,$7C,$64,$24,$3C,$00,$00
dc.b $00,$7C,$08,$08,$08,$08,$08,$08,$00,$00
dc.b $00,$78,$28,$28,$7E,$44,$44,$7E,$00,$00
dc.b $00,$7C,$48,$4C,$78,$10,$20,$40,$00,$00
font2:
dc.b $FC,$FE,$06,$06,$7E,$FE,$C6,$C6,$FE,$7E
dc.b $FC,$FE,$06,$06,$FC,$FE,$C6,$C6,$FE,$FC
dc.b $7E,$FE,$00,$00,$C0,$C0,$C0,$C0,$FE,$7E
dc.b $FC,$FE,$06,$06,$C6,$C6,$C6,$C6,$FE,$FC
dc.b $FE,$FE,$00,$00,$F8,$F8,$C0,$C0,$FE,$FE
dc.b $FE,$FE,$00,$00,$F8,$F8,$C0,$C0,$C0,$C0
dc.b $7C,$FE,$06,$00,$DE,$DE,$C6,$C6,$FE,$7C
dc.b $C6,$C6,$06,$06,$FE,$FE,$C6,$C6,$C6,$C6
dc.b $7E,$7E,$00,$00,$18,$18,$18,$18,$7E,$7E
dc.b $06,$06,$06,$06,$06,$06,$06,$C6,$FE,$7C
dc.b $C6,$CE,$DC,$C8,$E0,$F0,$F8,$DC,$CE,$C6
dc.b $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$CE,$CE
dc.b $FE,$FF,$1B,$1B,$DB,$DB,$C3,$C3,$C3,$C3
dc.b $FC,$FE,$06,$06,$C6,$C6,$C6,$C6,$C6,$C6
dc.b $7C,$FE,$06,$06,$C6,$C6,$C6,$C6,$FE,$7C
dc.b $FC,$FE,$06,$06,$FE,$FC,$C0,$C0,$C0,$C0
dc.b $7C,$FE,$06,$06,$C6,$C6,$DE,$DC,$FE,$76
dc.b $FC,$FE,$06,$06,$FE,$FC,$F8,$DC,$CE,$C6
dc.b $7E,$FE,$00,$00,$FC,$7E,$06,$06,$FE,$FC
dc.b $FC,$FC,$00,$00,$30,$30,$30,$30,$30,$30
dc.b $C6,$C6,$C6,$C6,$C6,$C6,$06,$06,$FE,$7C
dc.b $C6,$C6,$C6,$C6,$C6,$C6,$8E,$1C,$38,$10
dc.b $C6,$C6,$C6,$C6,$D6,$D6,$FE,$FE,$EE,$44
dc.b $82,$C6,$E6,$72,$38,$7C,$FE,$EE,$C6,$82
dc.b $C3,$C3,$C3,$E7,$7E,$3C,$18,$18,$18,$18
dc.b $FE,$FE,$00,$00,$1C,$38,$70,$E0,$FE,$FE
dc.b $18,$18,$18,$18,$18,$18,$00,$00,$18,$18
dc.b $00,$00,$00,$00,$00,$00,$00,$00,$18,$18
dc.b $7C,$FE,$C6,$06,$1E,$3C,$30,$00,$30,$30
dc.b $00,$00,$01,$01,$07,$07,$01,$01,$00,$00
dc.b $00,$00,$80,$80,$E3,$E3,$80,$80,$00,$00
dc.b $00,$00,$01,$01,$F1,$F1,$01,$01,$00,$00
dc.b $60,$E0,$C0,$80,$80,$80,$80,$C0,$E0,$60
dc.b $60,$70,$38,$18,$18,$18,$18,$38,$70,$60
dc.b $00,$00,$F8,$F9,$00,$00,$F9,$F8,$00,$00
dc.b $00,$91,$93,$FB,$93,$91,$F8,$93,$93,$00
dc.b $A0,$F8,$F9,$A1,$F0,$F8,$B8,$F8,$F0,$A0
dc.b $70,$F8,$DC,$8C,$00,$00,$00,$00,$03,$03
dc.b $00,$00,$00,$00,$00,$00,$00,$00,$FC,$FC
dc.b $30,$30,$30,$30,$30,$30,$30,$30,$31,$31
dc.b $18,$19,$31,$30,$60,$60,$C0,$C0,$81,$81
dc.b $00,$80,$C0,$E0,$70,$38,$70,$E0,$C0,$80
dc.b $00,$0C,$1C,$38,$70,$E0,$70,$38,$1C,$0C
dc.b $00,$01,$01,$61,$F0,$F0,$60,$00,$00,$00
dc.b $00,$98,$98,$98,$00,$00,$00,$00,$00,$00
dc.b $00,$60,$60,$60,$00,$00,$00,$00,$00,$01
dc.b $00,$00,$01,$03,$07,$0E,$1F,$38,$70,$F8
dc.b $70,$F0,$F0,$F0,$70,$70,$F0,$70,$70,$F9
dc.b $00,$01,$02,$04,$09,$13,$20,$4F,$90,$F8
dc.b $F8,$08,$48,$C8,$49,$C9,$08,$C8,$48,$FC
dc.b $07,$0F,$0C,$0C,$EC,$EE,$0E,$0E,$0F,$07
dc.b $DF,$DF,$18,$18,$1F,$1F,$01,$01,$DF,$DF
dc.b $80,$80,$00,$00,$3C,$BC,$80,$80,$80,$00
dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00

endfont:
	dc.l	 0,0,0,0

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

even
falling:
	dc.b	0
even
fcounter:
	dc.w	0
bonus:
	dc.b	0
lives:
	dc.b	3
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
revers:
	dc.b	0
even
kept2:
	dc.w	0
key:
	dc.l	0
laser:
	dc.b	0
piccounter:
	dc.b	'1'
even
c1cnt:
	dc.l	0
c2cnt:
	dc.l	0
lasercnt:
	dc.w	0
even
vol1:
	dc.w	30
vol2:
	dc.w	60
powercnt2:
	dc.w	0
power:
	dc.w	0
lcnt:
	dc.w	0
sprite3:
	dc.l	0
fdir:
	dc.b	1
level:
	dc.b 0
even
laenge1:
	dc.l 40000

score:
	dc.l 0

hiscore:
	dc.l 50

shiptable:
	dc.l 50000,100000,200000,500000

stc:
	dc.l 0
stc2:
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
	

y:
	dc.w 0
lochcnt:
	dc.w 0
locnt1:
	dc.l 0
open1:
	dc.w 280
locnt2:
	dc.w 0
open2:
	dc.w 0
even
powercol:
	blk.w 25,$a9b

	;dc.w $060,$060,$160,$260,$360,$460,$560,$660,$760
	;dc.w $860,$960,$950,$950,$a50,$a50,$a50,$b40,$b40
	;dc.w $b30,$b30,$b20,$b10,$b00,$b00

orgpowercol:
	dc.w $0f0,$2f0,$3f0,$4f0,$5f0,$6f0,$7f0,$8f0,$9f0
	dc.w $af0,$bf0,$ce0,$dd0,$ed0,$fc0,$fb0,$fa0,$f90
	dc.w $f80,$f70,$f60,$f50,$f30,$f00,$f00

y4:
	dc.w	0
x4:
dc.w	0


x:
	dc.w 0
x2:
	dc.w 0
powersoll:
	dc.w 0
lochx:
	dc.w 80
lochdir:
	dc.w 1
lochdir2:
	dc.w 0
lgamecnt:
	dc.w 0
lgame:
	dc.b 0,0
bahn:
	dc.l $75000
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
fast:
	dc.w 0
joy1:
	dc.w 0
joy2:
	dc.w 1
f2cnt:
	dc.w 0
menucnt:
	dc.w	0
mousepos:
	dc.w	0
oldmpos:
	dc.w	0
mcol=$008
picfile:
	dc.b	'df0:menupic',0
even
menu:
	move	#2,command
	move.l	#buffer,ziel
	move.l	#512*10,laenge
	move.l	#menupic,offset
	bsr	starttask
	bsr	wait_load

	move	#6,command
	bsr	starttask

	move.l	#40000,d4
	move.l	screen2,a1
	move.l	#buffer,a0
	bsr	decruncher

	move.l	#copperl3,$dff080
	clr	mousepos
	clr	menucnt
	move	#10,oldxpos2
	move	$dff00a,suber
repmenu:
	move.l	gfxbase,a6
	jsr	-270(a6)

	add	#1,menucnt
	cmp	#50*1,menucnt
	bne.s	notfifteen		; 1 Sekunde auf DEMO warten

	move.b	#1,auto
	move.b	#1,demo
	clr.b	twoplayer
	clr.b	battle
	clr.l	d0
	bra	endmenu			; demo starten
notfifteen:
	clr.l	d0
	move	oldmpos,d1
	move	$dff00a,d0
	sub	suber,d0
	move	d0,oldmpos	

	cmp	d0,d1
	beq.s	dontclear
	clr	menucnt
dontclear:
	and	#$ff00,d0
	lsr	#8,d0
	lsr	#5,d0

	tst	d0
	bhi.s	okm
	move	#0,d0
okm:
	cmp	#6,d0
	blo.s	okm2
	move	#6,d0
okm2:
	move	d0,mousepos
	
	lea	copperl3+2,a1
	moveq	#14,d7
ccopp:
	move	#mcol,(A1)
	addq	#4,a1
	dbra	d7,ccopp	; alle farben geloescht

	add.l	#2,menucolcnt
	cmp.l	#endmenucol,menucolcnt
	blo.s	menu2
	move.l	#menucol,menucolcnt	
menu2:
	move.l	menucolcnt,a3

	move.l	screen2,a0
	add.l	#1670,a0

	lea	font,a1
	lea	stagename,a2
	clr.l	d0	
	move.b	5(A2),d0
	sub.b	#55,d0
	mulu	#10,d0
	add	d0,a1

	moveq	#9,d7
wl:
	move.b	(a1),(a0)
	move.b	(a1),8000(a0)
	move.b	(a1),16000(a0)
	move.b	(a1),24000(a0)
	move.b	(a1)+,32000(a0)

	add	#40,a0
	dbra	d7,wl

	lea	copperl3+30,a2
	tst.b	joy1
	beq.s	notjoy1
	move	(a3),(a2)	
	move	#mcol,4(A2)
	bra.s	chkjoy1
notjoy1:
	move	#mcol,(a2)
	move	(A3),4(A2)
chkjoy1:
	lea	copperl3+38,a2
	tst.b	joy2
	beq.s	notjoy2
	move	(a3),(a2)	
	move	#mcol,4(A2)
	bra.s	chkjoy2
notjoy2:
	move	#mcol,(a2)
	move	(a3),4(A2)
chkjoy2:
	lea	copperl3+2,a1
	move	mousepos,d0
	lsl	#2,d0
	add	d0,a1

	move	(a3),(A1)		; highlight
	
	btst	#6,$bfe001
	beq.s	dontset
	btst	#10,$dff016
	beq.s	dontset
	move	#6,oldxpos2
dontset:
	cmp	#6,mousepos
	bne.s	nota

	add	#1,oldxpos
	move	oldxpos2,d3
	cmp	oldxpos,d3
	bne.s	nota
	clr	oldxpos
	clr.l	d0

	btst	#6,$bfe001
	bne.s	nol
	move.b	#-1,d0
	bra.s	nor
nol:
	btst	#10,$dff016
	bne.s	nor
	move.b	#1,d0
nor:
	cmp	#2,oldxpos2
	beq.s	dontzero
	sub	#1,oldxpos2
dontzero:
	lea	stagename,a1
	add.b	d0,5(A1)

	cmp.b	#'Z',5(A1)
	bls.s	notz
	move.b	#'Z',5(A1)
notz:
	cmp.b	#64,5(A1)
	bhi.s	notA
	move.b	#'A',5(A1)
nota:
	btst	#6,$bfe001
	bne.L	repmenu

	clr	menucnt
	cmp	#4,mousepos
	bne.s	notlb
	bchg	#0,joy1
waitplease:
	btst	#6,$bfe001
	beq.s	waitplease
notlb:
	cmp	#5,mousepos
	bne.s	notlb22
	bchg	#0,joy2
waitplease2:
	btst	#6,$bfe001
	beq.s	waitplease2
notlb22:
	cmp	#0,mousepos
	bne.s	notlb4
	move.l	#'EDIT',d0
	bra.s	endmenu
notlb4:
;	cmp	#1,mousepos
;	bne.s	notlb5
;	clr.b	twoplayer
;	clr.b	battle
;	clr	d0
;	bra.s	endmenu
notlb5:
;	cmp	#2,mousepos
;	bne.s	notlb6
;	move.b	#1,twoplayer
;	clr.b	battle
;	clr	d0
;	bra.s	endmenu
notlb6:
;	cmp	#3,mousepos
;	bne.s	notlb2
;	move.b	#1,twoplayer
;	move.b	#1,battle
;	clr	d0
;	bra.s	endmenu
notlb2:
	bra.L	repmenu
endmenu:
	tst	loading
	bne.s	endmenu

	move	#$100,$dff096
	move.l	screen2,a0
	clr.l	24(a0)
	rts

menucolcnt:
	dc.l	menucol
menucol:
	dc.w	$f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80,$f90
	dc.w	$fa0,$fb0,$fc0,$fd0,$fe0,$ff0
	dc.w	$ef0,$df0,$cf0,$bf0,$af0,$9f0,$8f0,$7f0,$6f0,$5f0
	dc.w	$4f0,$3f0,$2f0,$1f0,$0f0,$0f1,$0f2,$0f3,$0f4,$0f5
	dc.w	$0f6,$0f7,$0f8,$0f9,$0fa,$0fb,$0fc,$0fd,$0fe,$0ff
	dc.w	$0ef,$0df,$0cf,$0bf,$0af,$09f,$08f,$07f,$06f,$05f
	dc.w	$04f,$03f,$02f,$01f,$00f,$10f,$20f,$30f,$40f,$50f
	dc.w	$60f,$70f,$80f,$90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f
	dc.w	$f0e,$f0d,$f0c,$f0b,$f0a,$f09,$f08,$f07,$f06,$f05
	dc.w	$f04,$f03,$f02,$f01
endmenucol:

copperl3:
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
	dc.w	$019a,$0
	dc.w	$019c,$0
	dc.w	$019e,$0
	dc.w	$0180,$0

	dc.w	$00e0,$0004
	dc.w	$00e2,$c000

	dc.w	$00e4,$0004
	dc.w	$00e6,$c000+8000

	dc.w	$00e8,$0004
	dc.w	$00ea,$c000+16000

	dc.w	$00ec,$0005
	dc.w	$00ee,$1dc0

	dc.w	$00f0,$0005
	dc.w	$00f2,$3d00

	dc.w	$008e,$2c81
	dc.w	$0090,$f4c1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0
	dc.w	$0100,$5200
	dc.w	$0108,$0
	dc.w	$010a,$0
	dc.w	$0102,$0
	dc.w	$0104,$0

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
	jsr	-294(a6)	; find MY task
	move.l	d0,readrep+$10
	
	lea	readrep,a1
	jsr	-354(a6)	; addport
	
	lea	diskIO,a1
	move.l	#0,d0
	clr.l	d1
	lea	trddevice,a0
	jsr	-444(a6)	; open device
	
	lea	diskIO,a1
	move.l	#readrep,14(A1)
	rts

closetrd:
	move.l	4,a6
	lea	readrep,a1
	jsr	-360(A6)

	lea	diskIO,a1
	jsr	-450(A6)	; close dev
	rts
motor_off:
	move.l	4,a6
	lea	diskIO,a1
	move	#9,28(A1)
	move.l	#0,36(A1)
	jsr	-456(a6)
	rts

clearbuff:
	move.l	4,a6
	lea	diskIO,a1
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
	jsr	-330(A6)	; alloc-signal

	move.l	d0,signalnummer
	clr.l	d1
	bset	d0,d1
	move.l	d1,signalmaske	

	lea	task,a2
	lea	taskstrc,a1
	sub.l	a3,a3
	jsr	-282(a6)		; AddTask
	rts

RemoveTask:
	move	#1,command
	bsr	StartTask		; RemoveTask

	move.l	signalnummer,d0
	jsr	-336(a6)		; FreeSignal

	move.l	stackmem,a1
	move.l	#3000,d0
	jsr	-210(A6)		; FreeMem
	rts

StartTask:
	move.l	4,a6
	lea	taskstrc,a1	
	move.l	signalmaske,d0
	jsr	-324(a6)		; Signal
	rts

task:
	bsr	opentrd
task2:
	move.l	4,a6
	move.l	signalmaske,d0
	jsr	-318(a6)

	move	command,d0
	cmp	#1,d0
	beq	endtask

	cmp	#2,d0
	beq.L	readtrack

	cmp	#3,d0
	beq	writetrack

	cmp	#4,d0
	beq	readpic

	cmp	#5,d0
	beq	loadgame

	cmp.b	#6,d0
	beq	motor0

	bra.s	task2

motor0:
	bsr	motor_off
	bra.s	task2

loadgame:
	move	#1,loading

	move.l	screen1,a0
	tst.l	(a0)
	bne.s	notload5

	move.l	4,a6
	lea	diskIO,a1
	move	#2,28(A1)
	move.l	#512*40,36(a1)
	move.l	#rahmenc,44(A1)
	move.l	#buffer,40(A1)
	jsr	-456(a6)		; rahmen

	move.l	screen1,a1
	move.l	#buffer,a0
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
	lea	diskIO,a1
	move	#2,28(A1)
	move.l	#512*46,36(a1)
	move.l	d0,44(A1)
	move.l	#buffer,40(A1)
	jsr	-456(a6)

	bsr	motor_off
	clr	loading
	move	#1,loaded

;	add.b	#1,piccounter
;	cmp.b	#'9',piccounter
;	bne.s	not65
;	move.b	#'1',piccounter
not65:
	bra	task2

ReadTrack:
	move	#1,loading

	move.l	4,a6
	lea	diskIO,a1
	move	#2,28(A1)
	move.l	Offset,44(A1)
	move.l	Laenge,36(A1)
	move.l	Ziel,40(A1)
	jsr	-456(a6)

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
	
	clr	loading
	bra	task2

endtask:
	bsr	closetrd
	rts

taskstrc:
	dc.l 0
	dc.l 0
	dc.b 0			; intr disabled nesting
	dc.b 0			; task disabled nesting
	dc.l 0			; sigs allocated
	dc.l 0			; sigs we are waiting for
	dc.l 0			; sigs we have received
	dc.l 0			; sigs we take as exceptions
	dc.w 0			; traps allocated
	dc.w 0			; traps enabl 
	dc.l 0			; data for except proc
	dc.l 0			; exception procedure
	dc.l 0			; data for proc trap proc
	dc.l 0			; proc trap procedure
stack1:
	dc.l 0			; stack pointer
stack2:
	dc.l 0			; stack lower bound
stack3:
	dc.l 0			; stack upper bound + 2
start:
	dc.l 0			; task losing CPU
	dc.l 0			; task getting CPU
	dc.l 0			; allocated memory
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
namenslaenge = 8	;maximale Laenge des Namens
max_entry    = 10	;maximale Anzahl der Eintraege

;GetPosition()
;Diese Routine stellt fest, an wievielter Stelle man sich in der 
;Liste befindet

;Input  : D0 = Score
;Output : D0 = Platz (Wenn D0 NULL ist, dann befindet man sich nicht
;		     in der Liste)

even
GetPosition:	
	movem.l	a0/d1/d2,-(a7)
	lea	hilist,a0
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

;Inputs  : A1 = Zeiger auf Name des Spielers (Gerade Adresse !!)
;	   D0 = Position in der Liste (erhalten von 'GetPosition()' )
;	   D1 = Score

;Outputs : Keine

InsertScore:
	movem.l	d0-d2/a0-a2,-(a7)
	tst	d0			;score = 0
	beq.s	end_hi			;wenn ja -> ende
	subq	#1,d0
	lea	hilist,a0
	move.l	a0,a2
	mulu	#namenslaenge+4,d0
	add.l	d0,a0			;a0 = Zeiger auf Eintrag
	move	#max_entry,d2
	mulu	#namenslaenge+4,d2
	add.l	d2,a2			;a2 = Zeiger auf Ende hi_list

	cmp.l	a2,a0			;ist es der letzte Eintrag
	beq.s	not_last
hi_score_loop2:
	move	-12(a2),(a2)		;!!!!???? (-10)
	subq	#2,a2			;verschieben
	cmp.l	a2,a0
	bne.s	hi_score_loop2
not_last:
	move.l	(a1)+,(a0)+		;erste 4 Buchsten des namens
	move.l	(a1)+,(a0)+		;die naechsten 4 Buchstaben
	move.l	d1,(a0)			;Score
end_hi:
	movem.l	(a7)+,d0-d2/a0-a2
	rts

	dc.b	'  -C5-  '
	dc.l	score
hilist:
	dc.b	'rene1',0,0,0
	dc.l	1000
	dc.b	'rene2',0,0,0
	dc.l	900
	dc.b	'rene3',0,0,0
	dc.l	800
	dc.b	'rene4',0,0,0
	dc.l	700
	dc.b	'rene5',0,0,0
	dc.l	600
	dc.b	'rene6',0,0,0
	dc.l	500
	dc.b	'rene7',0,0,0
	dc.l	400
	dc.b	'rene8',0,0,0
	dc.l	300
	dc.b	'rene9',0,0,0
	dc.l	200
place:
	dc.l	0
points:
	dc.l	0

; prueft ob ein bild noch im speicher ist, indem ueber dieses die 
; pruefsumme gebildet wird !!
; a0=zeiger auf bildanfang
; d0=pruefsumme in words



Pruef:
	move.l	#$4c000,a0
	move	#7999,d7
p2:
	add	(A0)+,d0
	not	d0
	dbra	d7,p2
	rts

refresh:
	dc.w	0
blocks:
	dc.w	0,0,0
docnt:
	dc.w	0
