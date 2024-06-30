
	org	$50000
	load	$50000

	dc.b	'DOS',0
	dc.l	0
	dc.l	0
o:
	lea	copperl(pc),a3
	move.l	a3,$dff080
	move.l	a1,a5
	bsr	MINISCR

	btst	#10,$dff016
	beq.s	NoIntro

	move.l	#11*512,d0
	move.l	#512*156,d1
	lea	$11000,a0
	bsr	LOAD			; Intro1

	btst	#10,$dff016
	beq.s	NoIntro

	move.l	#24*512,d0
	move.l	#512*132,d1
	lea	$12000,A0
	bsr	LOAD			; Intro2
NoIntro:
o2:
	bsr	ALLOC
	move.l	#78*512,d0
	move.l	#512*22,d1
	lea	$12000,a0
	bsr	LOAD			; Game
	bsr	FREE

	move.l	#32*512,d0
	move.l	#512*100,d1
	lea	$12000,a0
	bsr	LOAD			; Editor
	bra.s	o2			; Wiederholen

MOTOR:
	move.l	a5,a1
	move	#9,28(a1)
	clr.l	36(A1)
	jsr	-456(A6)
	rts

ALLOC:
	move.l	4,a6
	lea	$11000,a1
	move.l	#$6b000,d0
	jsr	-204(A6)		; AllocABS
	rts
FREE:
	move.l	4,a6
	lea	$11000,a1
	move.l	#$6b000,d0
	jsr	-210(A6)		; FreeMEM
	rts

	; LOAD
	; D0=Laenge
	; D1=Offset
	; A0=Ziel

LOAD:
	move.l	4,a6
	move.l	a5,a1
	move.l	a0,a4
	move.l	d0,d6
	move.l	d1,d7
ReadErr:
	move	#2,28(A1)
	move.l	d0,36(A1)
	move.l	a0,40(A1)
	move.l	d1,44(A1)
	jsr	-456(A6)
	tst.l	d0
	beq.s	OKLoad
	move.l	a5,a1
	move.l	a4,a0
	move.l	d6,d0
	move.l	d7,d1
	bra.s	ReadErr
OKLoad:
	bsr	MOTOR
	move.l	#$ffff,d7
WAIT:
	sub.l	#1,d7
	bne.s	WAIT

	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(a4)
	movem.l	(sp)+,d0-d7/a0-a6	; Laden & Starten
	rts

MINISCR:
	move.l	4,a6
	lea	Copperl(pc),a1
	move.l	a1,$dff080
	lea	IntText(pc),a1
	jsr	-408(A6)
	move.l	d0,a6
	lea	NewScreen(pc),a0
	jsr	-198(A6)		; OpenMiniScreen
	rts

IntText:
	dc.b	'intuition.library',0
even
NewScreen:
	dc.w	0,0,32,11,1		; Ecke,Breite,Hoehe,Tiefe
	dc.w	0			; APen,BPen
	dc.w	0			; ViewModes
	dc.w	$f			; Type
	dc.l	0,0,0,0			; Font/Title/Gadgets/Bitmap
Copperl:
	dc.w	$180,$0
	dc.w	$96,$120
	dc.w	$100,$0
	dc.w	$ffff,$fffe
