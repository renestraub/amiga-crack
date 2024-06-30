	

	org	$35000
	load	$35000

	pic=$50000
	plane=32000

o:
	bsr	opengfx
	bsr	opentrd

	move.l	4,a6
	lea	diskIO,a1
	move	#2,28(A1)
	move.l	#1300*512,44(A1)
	move.l	#pic,40(A1)
	move.l	#80*512,36(A1)
;	jsr	-456(a6)

	lea	diskIO,a1
	move	#9,28(A1)
	move.l	#0,36(A1)
;	jsr	-456(a6)

	move.l	#pic,a0
	move	#16000,d7
clear:
	clr.l	(A0)+
	dbra	d7,clear

	move.l	#lin,a1
	move.l	#pic+22+[80*200],a2

	moveq	#1,d3
loop1:
	moveq	#44,d5
loop:
	moveq	#18,d4
loop2:
	move	(A1)+,(A2)+
	dbra	d4,loop2
	add.l	#42,A2
	dbra	d5,loop
	add.l	#32000-3000-600,a2
	dbra	d3,loop1

	move.l	#$52580,d0
	bsr	setbitm

	move	#$20,$dff096
	move.l	#copperl,$dff080
	move	#$8100,$dff096
	bsr	closetrd
wait:
	move.l	gfxbase,a6
	jsr	-270(A6)

	addq.l	#3,counter
	move.l	counter,a1
	clr.l	d0
	move.b	(A1),d0
	tst	d0
	beq.s	ex
	mulu	#80,d0
	add.l	#pic-2400,d0
	bsr	setbitm

	btst	#6,$bfe001
	bne.s	wait
ex:
;	move	#$100,$dff096
	move.l	gfxbase,a6
	move.l	38(A6),$dff080
	rts

setbitm:
	moveq	#4,d5
	lea	copperb,a1
rep:
	move	d0,6(A1)
	swap	d0
	move	d0,2(A1)
	swap	d0
	add.l	#8,a1
	add.l	#plane,d0
	dbra	d5,rep	
	rts

opengfx:
	move.l	4,a6
	lea	gfxtext,a1
	jsr	-408(a6)
	move.l	d0,gfxbase
	rts
gfxtext:
	dc.b	'graphics.library',0
even
gfxbase:
	dc.l	0

opentrd:			; Oeffnet TRD-Device !!!!!!!
	move.l	4,a6
	sub.l	a1,a1
	jsr	-294(a6)	; find MY task
	move.l	d0,readrep+$10
	
	lea	readrep,a1
	jsr	-354(a6)	; addport
	
	lea	diskIO,a1
	move.l	#1,d0
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
diskIO:
	blk.l	20,0
readrep:
	blk.l	8,0
trddevice:
	dc.b	'trackdisk.device',0

even

copperl:
copperb:
	dc.w	$00e0,$0005
	dc.w	$00e2,$0000
	dc.w	$00e4,$0005
	dc.w	$00e6,$0000+8000
	dc.w	$00e8,$0005
	dc.w	$00ea,$0000+16000
	dc.w	$00ec,$0005
	dc.w	$00ee,$0000+24000
	dc.w	$00f0,$0005
	dc.w	$00f2,$0000+32000

	dc.w	$008e,$3781
	dc.w	$0094,$00d4
	dc.w	$0092,$003c
	dc.w	$0090,$ffc1
	dc.w	$0102,$0000
	dc.w	$0108,$0000
	dc.w	$010a,$0000
	dc.w	$0100,$a200
copcol:
	dc.w	$180,$fff
	dc.w	$182,$faf
	dc.w	$184,$f8f
	dc.w	$186,$f0f
	dc.w	$ffff,$fffe

counter:
	dc.l	coord

coord:
	blk.b	1670,0

lin:
	blk.b	4000,0

