
page1 = $7f000-80000		
page2 = page1 + 40000


o:
	move	#$8010,$dff09a		;Copper Interrupt
	move	#$8400,$dff096		;Blitter Nasty
	move	#$20,$dff096		;Sprite DMA off
	move.l	#copperl,$dff080

WaitMidScreen:
	cmp.b	#100,$dff006
	bne	WaitMidScreen


	lea	$dff180,a2
	move	#31,d7
cm:
	move	(a0)+,(A2)+
	dbf	d7,cm	


	clr	FlipFlag
	bsr	InitBobList

	move.l	$6c,VBlankveq
	move.l	#VBlankInt,$6c
wait:
	btst	#6,$bfe001
	bne	wait
	bsr	a
	rts

screen:
	dc.l	0
intbase:
	dc.l	0
intlib:
	dc.b	`intuition.library`
	
even

a:
	move.l	VBlankVeq,$6c
	lea 	$0420,a0
	move.l 	a0,$dff080
	rts

VBlankInt:
	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	$1e(A6),d0
	btst	#4,d0
	beq	EndVblank
	btst	#6,$bfe001
	beq	EndVblank
	move	#$f00,$dff180
	move	#$10,$9c(a6)
	lea	bitmstr1,a0
	tst	FlipFlag
	beq	NoFlip
	lea	Bitmstr2,a0

NoFlip:
	lea	BitmapPtr,a1
	addq	#8,a0
	moveq	#4,d7
page_loop:
	move.l	(a0),d0
	move	d0,6(a1)
	swap	d0
	move	d0,2(A1)
	addq	#4,a0
	addq	#8,a1
	dbf	d7,page_loop
	not	FlipFlag
	bsr	drawbobs
	move	#$0,$dff180

EndVblank:
	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9

VBlankveq:
	dc.l	0

FlipFlag:
	dc.w	0



copperl:
	dc.w	$009c,$8010

	dc.w	$1001,$fffe
	dc.w 	$008e,$2c81
	dc.w 	$0090,$f4c1
	dc.w 	$0104,$0024
	dc.w 	$0092,$0038
	dc.w 	$0094,$00d2
	dc.w 	$0102,$0000
	dc.w 	$0108,0
	dc.w 	$010a,0

BitmapPtr:
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
	dc.w	$ffff,$fffe 


bitmstr1:
	dc.w	40
	dc.w	200
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page1
	dc.l	page1+8000
	dc.l	page1+16000
	dc.l	page1+24000
	dc.l	page1+32000


bitmstr2:
	dc.w	40
	dc.w	200
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page2
	dc.l	page2+8000
	dc.l	page2+16000
	dc.l	page2+24000
	dc.l	page2+32000


;Bob Master Routine (c) 1987 by Chris


DrawBobs:
	movem.l	d0-d7/a0-a6,-(A7)
	lea	BobList,a0
	lea	$dff000,a6

SearchLastBob:				;letztes Bob suchen
	tst.l	(A0)		
	beq	BobReconstLoop
	move.l	(A0),a0
	bra	SearchLastBob
	
BobReconstLoop:
	lea	bitmstr1,a2
	move.l	26(a0),a3
	move.l	a0,a5			;alle Hintergruende
	add	#12,a5			;rueckwaerts regenerieren
	tst	FlipFlag
	beq	NoFlip3
	lea	BitmStr2,a2
	move.l	30(a0),a3
	addq	#4,a5
NoFlip3:
					;a0 Zeiger auf aktuelles Bob
					;a2 Zeiger auf Unsichtbare Bitmstr
					;a3 auf Save Buffer	
					;a5 auf Old x,y
	Move.l	(A5),d0
	move.l	8(a0),(A5)
	cmp.l	#-1,d0
	beq	EndReconst
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
	bne	BlitWait2
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
	beq	EndRecLoop
	move.l	44(A0),a0
	bra	BobReconstLoop
	
EndRecLoop:		


;Jetzt werden all Hintergruende an der neuen Koordinate gerettet
	

	lea	BobList,a0
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
	tst	FlipFlag
	beq	NoFlip2
	lea	BitmStr2,a2
	move.l	30(A0),a3

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
	bne	BlitWait3
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
	beq	NoAnimate
BlitWait1:
	btst	#14,2(A6)
	bne	BlitWait1
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
	bne	NoAnim
	clr	50(A0)
AnimLoop:
	tst.l	54(A0)			;Animation zugelassen ?
	beq	NoAnim
	move.l	54(A0),a1
	move	52(a0),d0
	add	d0,a1
	move	(A1),d0			;Neue BobImageNummer holen
	cmp	#-3,d0
	beq	NoAnim
	cmp	#-1,d0			;Ende?
	bne	LetsAnim
	clr	52(A0)			;Neustart
	bra	AnimLoop
LetsAnim:
	move	d0,20(A0)		;BobImageNummer eintragen
	addq	#2,52(a0)		;PC erhoehen
NoAnim:
	tst.l	(a0)			;Letztes Bob in der Liste ?
	beq	EndDrawBobs
	move.l	(A0),a0			;Naechstes Bob = aktuelles Bob
	bra	BobMainLoop

EndDrawBobs:
	movem.l	(a7)+,d0-d7/a0-a6
	rts




		



	


InitBobList:
	movem.l	d0-d3/a0-a1,-(A7)
	lea	BobList,a0

BobInitLoop:
	lea	Bitmstr1,a1
	move	(a1),d1
	move	4(a0),d0
	move	d0,d2
	lsr	#4,d0
	and	#15,d2
	tst	d2
	beq	BobEven
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
	beq	EndInitBobs
	move.l	(A0),a0
	bra	BobInitLoop
EndInitBobs:	
	movem.l	(a7)+,d0-d3/a0-a1
	rts




BobImageList:
	dc.l	$40000		;erstes bob
	dc.l	$30000		;zweites Bob
				;u.s.w


BobList:
		

Bob1:
	dc.l	bob2		;Next Bob		0
	dc.w	89,45		;Breite,Hoehe		4
	dc.w	61,13		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	0		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	$5b000		;save1			26
	dc.l	$5c000		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	0		;Last Bob		44
	dc.w	1		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	animseq2	;AnimProgramm		54

Bob2:
	dc.l	0		;Next Bob		0
	dc.w	89,36		;Breite,Hoehe		4
	dc.w	60,48		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	0		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	$5d000		;save1			26
	dc.l	$5e000		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	bob1		;Last Bob		44
	dc.w	1		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	animseq1	;AnimProgramm		54


Animseq1:
	dc.w	0,1,2,3,4,-2,-3,-2,-2,-2,-2,-2,-2,-2,4,3,2,1,0,-1

Animseq2:
	dc.w	-2,-2,-2,-2,-2,6,7,8,9,10,-3


;-1  ende
;-2  leeres Bob
;-3  ende ohne frischbeginn

