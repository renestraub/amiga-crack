

 	pl=64*230
	y=10
	page1=$3b000
	save1=page1+[5*pl]
	save3=save1+4320
	bobs=page1-82944
	bobs2=bobs-6600
	page3=bobs2-2000
	bl=5184

	final=0

	org	$11000
	load	$11000
o:
	move	#$100,$dff096
	move.l	#copperl3,$dff080
	move.l	#starlist,starcnt
	clr.l	$70000
	bsr	cls
	move.l	4,a6
	lea	inttext,a1
	jsr	-408(a6)
	move.l	d0,a6
	lea	prefbuffer,a0
	moveq	#120,d0
	jsr	-132(a6)		; Get prefs
	lea	prefbuffer,a1
	move.b	#8,(A1)
	move	#1,108(a1)
	lea	prefbuffer,a0
	moveq	#120,d0
	moveq	#24,d1
	jsr	-324(a6)

	move.l	4,a6
	lea	GfxText,a1
	jsr	-408(A6)
	move.l	d0,GfxBase
	move.l	d0,a6
	lea	rapo,a1
	jsr	-198(A6)
	lea	rapo+4,a1
	move.l	#bitm,(A1)
	lea	rapo,a1
	move.l	#420,d0
	moveq	#10,d1
	jsr	-240(A6)
	lea	text,a0
	moveq	#27,d0
	jsr	-60(A6)

	bsr	InitCopp
	move	#$100,$dff096
	move.l	#copperl2,$dff080
	bsr	opentrd
Err1:
	move.l	4,a6
	lea	diskIO,a1
	move	#2,28(A1)
	move.l	#43*512,36(A1)
	move.l	#bobs2,40(A1)
	move.l	#574*512,44(A1)
	jsr	-456(A6)
	tst.l	d0
	bne.s	Err1

	move.l	#bobs2+21900,read
	move.l	#bobs2,lowwr
	bsr	decru
Err2:
	lea	diskIO,a1
	move	#2,28(A1)
	move.l	#15*512,36(A1)
	move.l	#page1,40(A1)
	move.l	#559*512,44(A1)
	jsr	-456(A6)
	tst.l	d0
	bne.s	Err2

	move	#9,28(A1)
	clr.l	36(A1)
	jsr	-456(A6)
	move.l	#page1+7484,read
	move.l	#page1,lowwr
	bsr	decru

	move	#$8010,$dff09a		;Copper Interrupt
	move	#$8400,$dff096		;Blitter Nasty
	bsr	InitBobList
	bsr	SetCol

	move.l	gfxbase,a6
	move.l	#copperl,$dff080
	bsr	waitit
	move	#$8100,$dff096
	lea	o1,a5
	moveq	#14,d6
col2:
	jsr	-270(A6)
	jsr	-270(A6)
	moveq	#7,d5
	lea	fadecol+2,a4
col:
	move	(A5)+,(A4)
	addq.l	#4,a4
	dbra	d5,col
	dbra	d6,col2

	move.l	$6c,VBlankveq
	move.l	#VBlankInt,$6c
Wait:
	tst	endit
	beq.s	Wait

	move.l	VBlankVeq,$6c
	bsr	Fade
	bsr	waitit
	bsr	Cls
	bsr	Clr
	bsr	CloseTrd

	If	Final
	move.l	#copperl4,$dff080
	move	#$20,$dff096
	Else	
	move.l	GfxBase,a6
	move.l 	38(a6),$dff080
	move	#$8020,$dff096
	EndIf
	rts

clr:
	bsr	FadeOut
	rts

CLS:
	lea	page3,a1
	move	#500,d7
cl:
	clr.l	(A1)+
	dbra	d7,cl
	rts

waitit:	
	moveq	#100,d7
rep:
	jsr	-270(A6)
	dbra	d7,rep
	rts

FadeOut:
	moveq	#25,d2
Fade2:
	move.l	d2,-(sp)
	move.l	gfxbase,a6
	jsr	-270(A6)
	move.l	(sp)+,d2

	lea	ColorMap+2,a1
	moveq	#30,d4
Fade1:
	move	(A1),d0			; Ist
	move	#$222,d1		; Soll
	bsr	CorrRed
	move	d5,d3
	bsr	CorrGreen
	or	d5,d3
	bsr	CorrBlue
	or	d5,d3
	move	d3,(A1)
	addq.l	#4,a1
	dbra	d4,Fade1
	dbra	d2,Fade2
	rts

; Corr		; d0=ist,d1=soll
CorrRed:
	move	d0,d5
	move	d1,d6
	and	#$0f00,d5
	and	#$0f00,d6
	cmp	d5,d6
	beq.s	EndCR
	bhi.s	Rkleiner
	sub	#$100,d5
	rts
RKleiner:	
	add	#$100,d5
EndCR:
	rts

CorrGreen:
	move	d0,d5
	move	d1,d6
	and	#$00f0,d5
	and	#$00f0,d6
	cmp	d5,d6
	beq.s	EndCG
	bhi.s	Gkleiner
	sub	#$0010,d5
	rts
GKleiner:	
	add	#$0010,d5
EndCG:
	rts

CorrBlue:
	move	d0,d5
	move	d1,d6
	and	#$000f,d5
	and	#$000f,d6
	cmp	d5,d6
	beq.s	EndCB
	bhi.s	Bkleiner
	sub	#$0001,d5
	rts
BKleiner:	
	add	#$0001,d5
EndCB:
	rts
Fade:
	moveq	#9,d7
	lea	c5,a4
preson:
	JSR	-270(A6)
	lea	prescol+2,a5
	move	(A4)+,(A5)
	move	(A4)+,4(A5)
	move	(A4)+,8(A5)
	dbra	d7,preson
	rts

SetCol:
	lea	bitmstr1,a0
	lea	BitmapPtr,a1
	moveq	#4,d7
	addq.l	#8,a0
page_loop:
	move.l	(a0),d0
	move	d0,6(a1)
	swap	d0
	move	d0,2(A1)
	addq	#4,a0
	addq	#8,a1
	dbf	d7,page_loop
	rts

VBlankInt:
	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	$1e(A6),d0
	btst	#4,d0
	beq	EndVblank

	addq	#1,cnt
	move.l	StarCnt,a1
	move	(A1),d5
	cmp	cnt,d5
	bhi.s	NoStar

	lea	Star,a2
	move	2(A1),d0
	move	4(A1),d1
	addq.l	#6,StarCnt
	move.b	d1,(A2)
	add	#24,d1
	move.b	d1,2(A2)
	move.b	d0,1(A2)
	move	#1,Str		; Stern beginnen
NoStar:
	tst	Str
	beq.s	NoStar2

	lea	StList,a1
	move	Str,d0
	lsl	#2,d0
	move.l	(A1,d0.w),a1

	lea	Star+4,a2
	moveq	#24,d7
Draw:
	move.l	(A1)+,(A2)+
	dbra	d7,Draw

	addq	#1,scnt
	cmp	#2,scnt
	bne.s	NoStar2
	clr	scnt

	addq	#1,Str
	cmp	#9,Str
	bne.s	NoStar2
	clr	Str
	lea	Star,a1
	clr.l	(A1)
NoStar2:
	cmp	#332,cnt
	blo.s	m2	
	move	#1,endit
	bra.s	end
m2:
	btst	#6,$bfe001
	bne.s	m3
	move	#1,endit
	bra.s	end
m3:
	bsr	SetCol
	bsr	Drawbobs
	bsr	Movebobs
End:
	move	#$10,$9c(a6)
EndVblank:
	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9
VBlankveq:
	dc.l	0
FlipFlag:
	dc.w	0

MoveBobs:
	movem.l	d0-d5/a0-a2,-(sp)	; Zeiger auf Bob in A1
	move.l	boblist,a1
Repeat:
	add	#1,66(A1)
	move	66(A1),d3
	cmp	64(A1),d3
	bne	endmove
	move	#0,66(A1)

	move.l	58(A1),a3		; Zeiger auf MoveStruktur
	cmp.l	#0,a3
	beq.s	endmove			; keine MoveListe -> bye

	tst.l	(A3)
	beq.s	endmove			; Move beendet -> bye

	cmp	#-2,(A3)
	bne.s	testpause		; -2 = direkt Koordinaten bye

	move.l	2(A3),8(A1)		; X,Y Werte kopieren
	addq.l	#6,58(A1)		; und Zeiger um 6 erhoehen
	bra.s	endmove
testpause:
	cmp	#-1,(A3)
	bne.L	nopause			; -1 = Pause

	addq.l	#4,58(A1)		; Zeiger erhoehen
	move	2(A3),62(A1)		; Pause Zaehler setzen
nopause:
	tst	62(a1)			; Pause abgelaufen
	beq.s	doit			; ja

	subq	#1,62(A1)		; sonst 1 abzaehlen
	bra.s	endmove			; und NICHTS tun
doit:
	move	8(a1),d0		; Aktuelles X
	move	10(A1),d1		; Aktuelles Y
	move	(A3),d2			; Ziel X
	move	2(A3),d3		; Ziel Y
	move	68(A1),d4
	move	70(A1),d5

	cmp	d0,d2
	bne.s	notreached
	cmp	d1,d3
	bne.s	notreached
	addq.l	#4,58(A1)		; gew. Position erreicht 
notreached:
	cmp	d0,d2
	beq.s	notx
	bhi.s	subx
	sub	d4,8(A1)		; X-1
	bra.s	notx
subx:
	add	d4,8(A1)		; X+1
notx:
	cmp	d1,d3
	beq.s	endmove
	bhi.s	suby
	sub	d5,10(A1)		; Y-1
	bra.s	endmove
suby:
	add	d5,10(A1)		; Y+1
endmove:
	move.l	(A1),a1			; Zeiger auf naechstes BOB
	cmp.l	#0,a1
	bne	repeat			; Wiederholen bis alle bewegt
	movem.l	(sp)+,d0-d5/a0-a2
	rts

copperl2:
	dc.w	$100,0
	dc.w	$180,0
	dc.w	$3821,$fffe
	dc.w	$180,$222
	dc.w	$ffdd,$fffe
	dc.w	$0711,$fffe
	dc.w	$180,$0
	dc.w	$182,$0
	dc.w	$100,$9200
	dc.w	$0801,$fffe
	dc.w	$e0,$2
	dc.w	$e2,$4a68
	dc.w	$92,$3c
	dc.w	$94,$d4
	dc.w	$0b01,$fffe
	dc.w	$182,$eee
	dc.w	$0c01,$fffe
	dc.w	$182,$dde
	dc.w	$0d01,$fffe
	dc.w	$182,$cce
	dc.w	$0e01,$fffe
	dc.w	$182,$bbe
	dc.w	$0f01,$fffe
	dc.w	$182,$aae
	dc.w	$1001,$fffe
	dc.w	$182,$99e
	dc.w	$1101,$fffe
	dc.w	$182,$77e
	dc.w	$1201,$fffe
	dc.w	$182,$55e
	dc.w	$1301,$fffe
	dc.w	$182,$33e
	dc.w	$ffff,$fffe
copperl4:
	dc.w	$100,0
	dc.w	$180,0
	dc.w	$182,$0
	dc.w	$3821,$fffe
	dc.w	$180,$222
	dc.w	$ffdd,$fffe
	dc.w	$0711,$fffe
	dc.w	$180,$0
	dc.w	$ffff,$fffe

copperl:
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
coppspr:
	dc.w	$134,7
	dc.w	$136,0
	dc.w	$138,7
	dc.w	$13a,0
	dc.w	$13c,7
	dc.w	$13e,0

	dc.w	$1001,$fffe
	dc.w 	$008e,$3871
 	dc.w 	$0090,$16c8
	dc.w 	$0104,$0024
	dc.w 	$0092,$0030
	dc.w 	$0094,$00df
	dc.w 	$0102,$0000
	dc.w 	$0108,20
	dc.w 	$010a,20
copcol:
ColorMap:
	dc.w	$182,$EBA
	dc.w	$184,$DA9
	dc.w	$186,$C98
	dc.w	$188,$B87
	dc.w	$18a,$a76
	dc.w	$18c,$965
	dc.w	$18e,$854
	dc.w	$190,$754
	dc.w	$192,$643
	dc.w	$194,$532
	dc.w	$196,$421
	dc.w	$198,$321
	dc.w	$19a,$8c8
	dc.w	$19c,$6a6
	dc.w	$19e,$484
fadecol:
	dc.w	$1a0,$222
	dc.w	$1a2,$222
	dc.w	$1a4,$222
	dc.w	$1a6,$222
	dc.w	$1a8,$222
	dc.w	$1aa,$222
	dc.w	$1ac,$222
	dc.w	$1ae,$222
prescol:
	dc.w	$1b0,$222
	dc.w	$1b2,$222
	dc.w	$1b4,$222
	dc.w	$1b6,$eef
	dc.w	$1b8,$ddf
	dc.w	$1ba,$ccf
	dc.w	$1bc,$bbf
	dc.w	$1be,$fff
BitmapPtr:
	dc.w 	$00e0,$0005
	dc.w 	$00e2,$0000
	dc.w 	$00e4,$0005
	dc.w 	$00e6,$1f40
	dc.w 	$00e8,$0005
	dc.w 	$00ea,$3e80
	dc.w 	$00ec,$0005
	dc.w 	$00ee,$5dc0
	dc.w	$00f0,$0005
	dc.w	$00f2,$7d00
	dc.w	$0100,$5200

	dc.w	$3821,$fffe
	dc.w	$180,$222

	dc.w	$6501,$fffe
	dc.w	$009c,$8010
	dc.w	$ffdf,$fffe
	dc.w	$0711,$fffe
	dc.w	$180,$0
	dc.w	$182,$0
	dc.w	$100,$9200
	dc.w	$0801,$fffe
	dc.w	$e0,$2
	dc.w	$e2,$4a68
	dc.w	$92,$3c
	dc.w	$94,$d4
	dc.w	$0b01,$fffe
	dc.w	$182,$eee
	dc.w	$0c01,$fffe
	dc.w	$182,$dde
	dc.w	$0d01,$fffe
	dc.w	$182,$cce
	dc.w	$0e01,$fffe
	dc.w	$182,$bbe
	dc.w	$0f01,$fffe
	dc.w	$182,$aae
	dc.w	$1001,$fffe
	dc.w	$182,$99e
	dc.w	$1101,$fffe
	dc.w	$182,$77e
	dc.w	$1201,$fffe
	dc.w	$182,$55e
	dc.w	$1301,$fffe
	dc.w	$182,$33e
	dc.w	$ffff,$fffe

bitmstr1:
	dc.w	pl/230
	dc.w	200
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page1+20
	dc.l	page1+pl+20
	dc.l	page1+[2*pl]+20
	dc.l	page1+[3*pl]+20
	dc.l	page1+[4*pl]+20

bitm:
	dc.w	100
	dc.w	20
	dc.b	0
	dc.b	1
	dc.w	0
	dc.l	page3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

;Bob Master Routine (c) 1987 by Chris

DrawBobs:
	movem.l	d0-d7/a0-a6,-(A7)
	move.l	BobList,a0
	lea	$dff000,a6
SearchLastBob:				;letztes Bob suchen
	tst.l	(A0)		
	beq.s	BobReconstLoop
	move.l	(A0),a0
	bra.s	SearchLastBob
	
BobReconstLoop:
	lea	bitmstr1,a2
	move.l	26(a0),a3
	move.l	a0,a5			;alle Hintergruende
	add	#12,a5			;rueckwaerts regenerieren

;	tst	FlipFlag
;	beq.s	NoFlip3
;	lea	BitmStr2,a2
;	move.l	30(a0),a3
;	addq	#4,a5
NoFlip3:
				;a0 Zeiger auf aktuelles Bob
				;a2 Zeiger auf Unsichtbare Bitmstr
				;a3 auf Save Buffer	
				;a5 auf Old x,y
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

;Jetzt werden all Hintergruende an der neuen Koordinate gerettet
	
	move.l	BobList,a0
BobMainLoop:
	moveq	#0,d0
	move	20(a0),d0
	lsl	#2,d0
	lea	BobImageList,a1
	move.l	(a1,d0.l),a1		;a1 = zeiger auf Bob
	move.l	a1,a4
	add.l	40(A0),a4		;a4 Zeiger auf Maske

	lea	Bitmstr1,a2
	move.l	26(A0),a3		;a3 = save1		
;	tst	FlipFlag
;	beq.s	NoFlip2
;	lea	BitmStr2,a2
;	move.l	30(A0),a3

;a1 Zeiger auf Bob, a2 Zeiger auf unsichtbare Bitmapstr
;a3 Zeiger auf Hintergrundbuffer, a4 Zeiger auf Maske

NoFlip2:		
	clr.l	d0
	move	8(a0),d0
	move	d0,d2
	and	#15,d2
	moveq	#12,d3
	lsl	d3,d2			;d2 = shift
	lsr	#3,d0
	move	10(A0),d1
	mulu	(A2),d1
	add	d1,d0			;d0 = Offset auf Dest.

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
	move.l	a3,$54(a6)		;Dest
	move.l	d3,$50(a6)
	clr	$42(a6)			;BltCon1
	move	#$9f0,$40(A6)		;BltCon0
	move	24(a0),$64(A6)		;Modulo Source
	clr	$66(a6)
	move.l	#-1,$44(a6)
	move	22(a0),$58(a6)
	add.l	36(A0),a3
	dbf	d7,BlitWait3
	movem.l	(a7)+,a2-a3
	
;Jetzt werden alle Bobs mit Maske in das Bild kopiert

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
	move.l	a3,$48(a6)		;Source c (background)
	move.l	a1,$4c(A6)		;Source b (data)
	move.l	a4,$50(a6)		;Source a (Maske)
	move.l	a3,$54(a6)		;Dest C
	move	d2,$42(a6)		;BltCon1
	move	#$0fca,d3
	or	d2,d3
	move	d3,$40(a6)		;BltCon0
	move	24(a0),$60(a6)		;Modulo c
	move	24(a0),$66(A6)		;Modulo Dest
	clr	$64(a6)
	clr	$62(A6)
	move.l	#$ffffffff,$44(a6)
	move	22(a0),$58(a6)
	add.l	36(A0),a1
	dbf	d7,BlitWait1
NoAnimate:
	addq	#1,50(A0)		;Speedcounter
	move	50(A0),d0
	cmp	48(a0),d0		;Limite erreicht?
	bne.s	NoAnim
	clr	50(A0)
AnimLoop:
	tst.l	54(A0)			;Animation zugelassen ?
	beq.s	NoAnim
	move.l	54(A0),a1
	move	52(a0),d0
	add	d0,a1
	move	(A1),d0			;Neue BobImageNummer holen
	cmpi	#-3,d0
	beq.s	NoAnim
	cmp	#-1,d0			;Ende?
	bne.s	LetsAnim
	clr	52(A0)			;Neustart
	bra.s	AnimLoop
LetsAnim:
	move	d0,20(A0)		;BobImageNummer eintragen
	addq	#2,52(a0)		;PC erhoehen
NoAnim:
	tst.l	(a0)			;Letztes Bob in der Liste ?
	beq.s	EndDrawBobs
	move.l	(A0),a0			;Naechstes Bob = aktuelles Bob
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
	move	d2,22(a0)	;BltSize

	lsl	#1,d0		;Breite in Bytes
	sub	d0,d1
	move	d1,24(a0)	;Modulo
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

BobImageList:
	dc.l	bobs		;erstes bob
	dc.l	bobs+[1*bl]
	dc.l	bobs+[2*bl]
	dc.l	bobs+[3*bl]
	dc.l	bobs+[4*bl]
	dc.l	bobs+[5*bl]
	dc.l	bobs+[6*bl]
	dc.l	bobs+[7*bl]
	dc.l	bobs+[8*bl]
	dc.l	bobs+[9*bl]
	dc.l	bobs+[10*bl]
	dc.l	bobs+[11*bl]
	dc.l	bobs+[12*bl]
	dc.l	bobs+[13*bl]
	dc.l	bobs+[14*bl]
	dc.l	bobs+[15*bl]
	dc.l	bobs2

BobList:
	dc.l	bob1

bob1:
	dc.l	bob2		;Next Bob		0
	dc.w	96,72		;Breite,Hoehe		4
	dc.w	352,y		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	0		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	save1		;save1			26
	dc.l	0		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	0		;Last Bob		44
	dc.w	4		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	Animseq1	;AnimProgramm		54
	dc.l	Animcoord1	;Zeiger auf MoveListe	58
	dc.w	0		;PauseCounter		62
	dc.w	1		;MoveSpeed		64
	dc.w	0		;MoveCounter		66
	dc.w	1		;MoveDistX		68
	dc.w	1		;MoveDistY		70

Animseq1:
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0
	dc.w	13,13,14,14,15,15,14,14,13,13,1
	dc.w	-3

AnimCoord1:
	dc.w	-1,53,547-16+32,y,0,0

bob2:
	dc.l	0		;Next Bob		0
	dc.w	172,50		;Breite,Hoehe		4
	dc.w	352,y		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	16		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	save3		;save1			26
	dc.l	0		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	bob1		;Last Bob		44
	dc.w	4		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	0		;AnimProgramm		54
	dc.l	Animcoord2	;Zeiger auf MoveListe	58
	dc.w	0		;PauseCounter		62
	dc.w	1		;MoveSpeed		64
	dc.w	0		;MoveCounter		66
	dc.w	1		;MoveDistX		68
	dc.w	1		;MoveDistY		70

AnimCoord2:
	dc.w	632-48+32,y,0,0
endit:
	dc.w	0
gfxbase:
	dc.l	0
gfxtext:
	dc.b	'graphics.library',0
even
rapo:
	blk.b	100,0
text:
	dc.b	'© 1988 by LINEL Switzerland',0
o1:
	dc.w	$222,$222,$222,$222,$222,$222,$222,$222
	dc.w	$323,$323,$223,$222,$322,$222,$222,$222
	dc.w	$424,$424,$334,$333,$322,$222,$323,$222
	dc.w	$525,$524,$435,$444,$423,$323,$433,$322
	dc.w	$626,$625,$546,$555,$423,$323,$534,$322
	dc.w	$727,$715,$647,$666,$514,$413,$644,$313
	dc.w	$828,$816,$758,$777,$514,$413,$745,$413
	dc.w	$939,$916,$859,$888,$615,$514,$855,$413
	dc.w	$a39,$a17,$95a,$999,$615,$514,$956,$413
	dc.w	$a3a,$a17,$a6a,$aaa,$716,$614,$a66,$513
	dc.w	$b3a,$b08,$b6b,$bbb,$706,$604,$b67,$504
	dc.w	$b3b,$b08,$c6b,$ccc,$807,$705,$c77,$604
	dc.w	$c3b,$c09,$d7c,$ddd,$907,$705,$d78,$604
	dc.w	$c3c,$c09,$e7c,$eee,$a08,$805,$e89,$704
	dc.w	$d3c,$d0a,$e7d,$fff,$b08,$805,$f8a,$704

read:
	dc.l	0
lowwr:
	dc.l	0
decru:
	move.l	read,a0
	move.l	lowwr,a1		
	move.l 	-(a0),a2		
	add.l 	a1,a2		
	move.l 	-(a0),d5		
	move.l 	-(a0),d0		
	eor.l 	d0,d5		
notfinished:
	lsr.l 	#1,d0
	bne.S 	notempty1
	jsr 	getnextlwd
notempty1:
	bcs.S 	bigone		
	moveq 	#8,d1	
	moveq 	#1,d3	
	lsr.l 	#1,d0
	bne.S 	notempty2
	jsr 	getnextlwd
notempty2:
	bcs.S 	dodupl	
	moveq 	#3,d1	
	clr.w 	d4	
dojmp:		
	jsr 	rdd1bits	
	move.w 	d2,d3	
	add.w 	d4,d3	
getd3chr:
	moveq 	#7,d1	
get8bits:
	lsr.l 	#1,d0
	bne.S 	notempty3
	jsr 	getnextlwd
notempty3:
	roxl.l 	#1,d2
	dbf 	d1,get8bits	
	move.b 	d2,-(a2)
	dbf 	d3,getd3chr	
	jmp 	nextcmd
bigjmp:
	moveq 	#8,d1	
	moveq 	#8,d4			
	jmp 	dojmp
bigone:
	moveq 	#2,d1	
	jsr 	rdd1bits
	cmp.b 	#2,d2	
	blt.S 	midjumps	
	cmp.b 	#3,d2	
	beq.S 	bigjmp	

	moveq 	#8,d1	
	jsr 	rdd1bits	
	move.w 	d2,d3	
	move.w 	#12,d1	
	jmp 	dodupl	
midjumps:
	move.w 	#9,d1	
	add.w 	d2,d1
	addq 	#2,d2
	move.w 	d2,d3	
dodupl:
	jsr 	rdd1bits	
copyd3bytes:
	subq 	#1,a2
	move.b 	(a2,d2.w),(a2)
	dbf 	d3,copyd3bytes
nextcmd:
	cmp.l 	a2,a1
	blt 	notfinished
	tst.l 	d5
	bne.S 	damage
	rts
damage:
	move	#$ffff,d7
dam:
	move	d7,$dff180
	dbra	d7,dam
	rts

getnextlwd:
	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.w 	#$10,ccr
	roxr.l 	#1,d0
	rts
rdd1bits:	
	subq.w 	#1,d1
	clr.w 	d2
getbits:
	lsr.l 	#1,d0
	bne.S 	notempty
	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.w 	#$10,ccr
	roxr.l 	#1,d0
notempty:
	roxl.l 	#1,d2
	dbf 	d1,getbits
	rts
cnt:
	dc.w	0

InitCopp:
	move.l	#star,d0
	lea	coppspr+2,a2
	move	d0,4(A2)
	swap	d0
	move	d0,(A2)
	rts

opentrd:			; Oeffnet TRD-Device !!!!!!!
	move.l	4,a6
	sub.l	a1,a1
	jsr	-294(a6)	; find MY task
	move.l	d0,readrep+$10
	
	lea	readrep,a1
	jsr	-354(a6)	; addport
	
	lea	diskIO,a1
	If	Final
	clr.l	d0
	Else
	moveq	#1,d0
	EndIf
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
c5:
	dc.w	$222,$222,$222
	dc.w	$322,$222,$222
	dc.w	$433,$322,$332
	dc.w	$533,$332,$333
	dc.w	$644,$433,$443
	dc.w	$744,$433,$543
	dc.w	$855,$543,$654
	dc.w	$965,$644,$754
	dc.w	$a76,$754,$865
	dc.w	$b87,$854,$965
Star:
	dc.l	0
	blk.l	100,0
	dc.l	0

StarCnt:
	dc.l	0
StarList:
	dc.w	10,206,53
	dc.w	40,132,145
	dc.w	80,204,175
	dc.w	100,133,205
	dc.w	120,132,145
	dc.w	190,204,175
	dc.w	210,206,53
	dc.w	230,133,205
	dc.w	280,117,58
	dc.w	10000,0,0
Str:
	dc.w	0
StList:
	dc.l	stern7
	dc.l	stern6
	dc.l	stern5
	dc.l	stern4
	dc.l	stern3
	dc.l	stern2
	dc.l	stern2
	dc.l	stern1
	dc.l	stern0

prefbuffer:
	blk.b	150,0
inttext:
	dc.b	'intuition.library',0
stern0:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0040,$0040
	dc.w $0000,$0000
	dc.w $0400,$0400
	dc.w $0000,$0000
	dc.w $4000,$4000
	dc.w $0001,$0001
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0400,$0400
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
stern1:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0200,$0200
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $8000,$8000
	dc.w $0010,$0010
	dc.w $0000,$0000
	dc.w $0100,$0100
	dc.w $0000,$0000
	dc.w $1000,$1000
	dc.w $0005,$0005
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0100,$0100
	dc.w $0000,$0000
	dc.w $0010,$0010
	dc.w $8000,$8000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0200,$0200
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
stern2:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0200,$0200
	dc.w $0000,$0000
	dc.w $0200,$0200
	dc.w $0000,$0000
	dc.w $4010,$4010
	dc.w $0000,$0000
	dc.w $0500,$0500
	dc.w $0000,$0000
	dc.w $1040,$1040
	dc.w $0005,$0005
	dc.w $1040,$1040
	dc.w $0000,$0000
	dc.w $0500,$0500
	dc.w $0000,$0000
	dc.w $4010,$4010
	dc.w $0000,$0000
	dc.w $0200,$0200
	dc.w $0000,$0000
	dc.w $0200,$0200
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
stern3:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $4010,$4010
dc.w $2220,$2220
dc.w $0500,$0500
dc.w $0200,$0200
dc.w $1040,$1040
dc.w $A8AD,$A8AD
dc.w $1040,$1040
dc.w $0200,$0200
dc.w $0500,$0500
dc.w $2220,$2220
dc.w $4010,$4010
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000

stern4:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $4010,$4010
dc.w $2220,$2220
dc.w $1AC0,$1AC0
dc.w $1FC0,$1FC0
dc.w $0F80,$0F80
dc.w $BDEC,$BDEC
dc.w $0F80,$0F80
dc.w $1FC0,$1FC0
dc.w $1AC0,$1AC0
dc.w $2220,$2220
dc.w $4010,$4010
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000

stern5:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $0A80,$0A80
dc.w $0700,$0700
dc.w $DFD8,$DFD8
dc.w $0700,$0700
dc.w $0A80,$0A80
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000

stern6:
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $2FA0,$2FA0
dc.w $0200,$0200
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0200,$0200
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000
dc.w $0000,$0000

stern7:
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0200,$0200
	dc.w $0700,$0700
	dc.w $0200,$0200
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
	dc.w $0000,$0000
copperl3:
	dc.w	$180,$0
	dc.w	$100,$0
	dc.w	$ffff,$fffe
scnt:
	dc.w	0
send:
