

;€
;Includes	BACK nach Page1
;		Anim nach Bobs

	drawer=363

	page1=$7e000-140000
	page2= page1 + 70000
	pic=page1-5000	
	bobs=pic-86000
	save1=bobs-4000
	save2=save1-4000
	save3=save2-4000
	save4=save3-4000
	save5=save4-4000
	save6=save5-4000
	page=save6-40064

o:
	clr.l	0

	move.l	4,a6
	lea	dostext,a1
	jsr	-408(a6)
	move.l	d0,dosbase
	move.l	d0,a6

	move.l	#file1,d1
	move.l	#$3ed,d2
	jsr	-30(a6)
	tst.l	d0
	bne.s	ok
	rts
ok:
	move.l	d0,-(sp)
	move.l	d0,d1
	move.l	#bobs,d2
	move.l	#30000,d3
	jsr	-42(a6)

	move.l	(sp)+,d1
	jsr	-36(a6)

	move.l	#bobs,lowwr
	move.l	#bobs+29688,read
	bsr	decru		; BOB's laden und decrunchen

	move.l	4,a6
	lea	gfxtext,a1
	jsr	-408(a6)
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		; OWN blitter (hae,hae)

	lea	copspr,a1
	move.l	#sprite1,d2
	move	d2,6(A1)
	swap	d2
	move	d2,2(A1)
	
	move	#$8010,$dff09a		;Copper Interrupt
	move	#$8400,$dff096		;Blitter Nasty

	move.l	#page,a0
	move.l	#page1,a1
	move.l	#page2,a2

	moveq	#4,d5
copyplane:
	move	#199,d6
copy:
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A2)+
	clr.l	(A2)+

	moveq	#9,d7
copyline:
	move.l	(A0),(A1)+
	move.l	(A0)+,(A2)+
	dbra	d7,copyline	
	dbra	d6,copy
	dbra	d5,copyplane

	move.l	boblist,a1
loop:
	move.l	58(A1),a2
	move.l	(A2),8(A1)
	addq.l	#4,58(A1)

	move.l	(A1),a1
	cmp.l	#0,a1
	bne.s	loop

WaitMidScreen:
	cmp.b	#100,$dff006
	bne	WaitMidScreen

	move.l	#page+40000,a0
	lea	$dff180,a2
	moveq	#31,d7
cm:
	move	(a0)+,(A2)+
	dbf	d7,cm	

	clr	FlipFlag
	bsr	InitBobList

	move.l	#copperl,$dff080
	move.l	$6c,VBlankveq
	move.l	#VBlankInt,$6c
wait:
	btst	#10,$dff016
	bne.s	nopause2
	move	#1,stop
waitkey:
	btst	#10,$dff016
	beq.s	waitkey
	clr	stop
nopause2:
	btst	#6,$bfe001
	bne.s	wait

	move.l	VBlankVeq,$6c
	move.l	gfxbase,a6
	move.l 	38(a6),$dff080
	jsr	-462(a6)		; Disown blit
	move	#$8020,$dff096
	rts

VBlankInt:
	movem.l	d0-d7/a0-a6,-(a7)
	tst	stop
	bne.L	END

	lea	$dff000,a6
	move	$1e(A6),d0
	btst	#4,d0
	beq	EndVblank
	btst	#6,$bfe001
	beq	EndVblank

	lea	sprite1,a1
	lea	bob4,a2
	move	8(A2),d0
	cmp	#370,d0
	bne.s	noto
	sub	#4,d0
noto:
	sub	#238,d0
	btst	#0,d0
	bne.s	not0bit
	bclr	#0,3(A1)
	bra.s	not1bit
not0bit:
	bset	#0,3(A1)
not1bit:
	lsr	#1,d0
	move.b	d0,1(A1)

	move	10(A2),d0
	add.b	#45,d0
	move.b	d0,2(A1)

	lea	bitmstr1,a0
	tst	FlipFlag
	beq.s	NoFlip
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
	bsr	Drawbobs
	bsr	Movebobs
	move	#$10,$9c(a6)
EndVblank:
	addq.l	#1,counter
	cmp.l	#800,counter
	bne.s	notre
	move.l	#bob4,boblist
	bsr	initboblist
notre:
;	move	#$f00,$dff180

END:
	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9
VBlankveq:
	dc.l	0

movebobs:
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

FlipFlag:
	dc.w	0

copperl:
	dc.w	$0180,$0
	dc.w	$120,0
	dc.w	$122,0
	dc.w	$124,0
	dc.w	$126,0
	dc.w	$128,0
	dc.w	$12a,0
	dc.w	$12c,0
	dc.w	$12e,0
copspr:
	dc.w	$130,0
	dc.w	$132,0
	dc.w	$134,0
	dc.w	$136,0
	dc.w	$138,0
	dc.w	$13a,0
	dc.w	$13c,0
	dc.w	$13e,0

	dc.w	$009c,$8010
	dc.w	$1001,$fffe
	dc.w 	$008e,$2c81
	dc.w 	$0090,$f4c1
	dc.w 	$0104,$0024
	dc.w 	$0092,$0038
	dc.w 	$0094,$00d2
	dc.w 	$0102,$0000
	dc.w 	$0108,8
	dc.w 	$010a,8

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

	dc.w	$2021,$fffe
	dc.w	$1ba,$f

	dc.w	$4021,$fffe
	dc.w	$1ba,$e

	dc.w	$5821,$fffe
	dc.w	$1ba,$d

	dc.w	$6021,$fffe
	dc.w	$1ba,$c

	dc.w	$6d21,$fffe
	dc.w	$01bc,$f00
	dc.w	$01be,$f00

	dc.w	$6e21,$fffe
	dc.w	$01bc,$f50
	dc.w	$01be,$f50

	dc.w	$6f21,$fffe
	dc.w	$01bc,$f70
	dc.w	$01be,$f70

	dc.w	$7021,$fffe
	dc.w	$1ba,$b

	dc.w	$7121,$fffe
	dc.w	$01bc,$f80
	dc.w	$01be,$f80

	dc.w	$7221,$fffe
	dc.w	$01bc,$f90
	dc.w	$01be,$f90

	dc.w	$7321,$fffe
	dc.w	$01bc,$f90
	dc.w	$01be,$f90

	dc.w	$7421,$fffe
	dc.w	$01bc,$fa0
	dc.w	$01be,$fa0

	dc.w	$7521,$fffe
	dc.w	$01bc,$fa0
	dc.w	$01be,$fa0

	dc.w	$7621,$fffe
	dc.w	$01bc,$fb0
	dc.w	$01be,$fb0

	dc.w	$7721,$fffe
	dc.w	$01bc,$fb0
	dc.w	$01be,$fb0

	dc.w	$7821,$fffe
	dc.w	$01bc,$fc0
	dc.w	$01be,$fc0

	dc.w	$7921,$fffe
	dc.w	$01bc,$fc0
	dc.w	$01be,$fc0

	dc.w	$7a21,$fffe
	dc.w	$01bc,$fd0
	dc.w	$01be,$fd0

	dc.w	$7b21,$fffe
	dc.w	$01bc,$fd0
	dc.w	$01be,$fd0

	dc.w	$7c21,$fffe
	dc.w	$01bc,$fe0
	dc.w	$01be,$fe0

	dc.w	$7d21,$fffe
	dc.w	$01bc,$ff0
	dc.w	$01be,$ff0

	dc.w	$8021,$fffe
	dc.w	$1ba,$a

	dc.w	$9021,$fffe
	dc.w	$1ba,$9

	dc.w	$a021,$fffe
	dc.w	$1ba,$8

	dc.w	$b021,$fffe
	dc.w	$1ba,$7

	dc.w	$c021,$fffe
	dc.w	$1ba,$6

	dc.w	$d021,$fffe
	dc.w	$1ba,$5

	dc.w	$e021,$fffe
	dc.w	$1ba,$4

	dc.w	$6021,$fffe
	dc.w	$1ba,$3

	dc.w	$ffff,$fffe 

bitmstr1:
	dc.w	48
	dc.w	200
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page1+8
	dc.l	page1+9600+8
	dc.l	page1+[2*9600]+8
	dc.l	page1+[3*9600]+8
	dc.l	page1+[4*9600]+8

bitmstr2:
	dc.w	48
	dc.w	200
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page2+8
	dc.l	page2+9608
	dc.l	page2+[2*9600]+8
	dc.l	page2+[3*9600]+8
	dc.l	page2+[4*9600]+8

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
	tst	FlipFlag
	beq.s	NoFlip3
	lea	BitmStr2,a2
	move.l	30(a0),a3
	addq	#4,a5
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
	move.l	counter,d3
	cmp	#drawer+1,d3
	blo	notr
	cmp	#drawer+70,d3
	bgt	notr
	
	lsr.l	#1,d3
	sub.l	#drawer/2,d3
	move.l	d3,d4
	mulu	#18,d3
	mulu	#48,d4

	move.l	#pic,a1
	move.l	#page2+[48*123]+18,a2
	add.l	d3,a1
	add.l	d4,a2
;	add.l	#9600,a2
;	add.l	#648,a1

	moveq	#4,d6

	tst	flipflag
	bne.s	repeatit
	move.l	#page1+[48*123]+18,a2
	add.l	d4,a2
repeatit:
	btst	#14,2(A6)
	bne.s	repeatit

	clr	$64(A6)			; Modulo A
	move	#30,$66(a6)		; Modulo D
	move.l	a2,$54(A6)		; Ziel D
	move.l	a1,$50(A6)		; Source A
	move	#$9f0,$40(A6)		; BlitterMode
	clr	$42(A6)
	move.l	#$ffffffff,$44(A6)
	move	#%0000000001001001,$dff058

	add.l	#9600,a2		; Page1
	add.l	#648,a1			; Pic

	dbra	d6,repeatit
notr:
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
	tst	FlipFlag
	beq.s	NoFlip2
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

read:
	dc.l	$40000+29688
lowwr:
	dc.l	$40000	; set destination address
decru:
	move.l	read,a0
	move.l 	lowwr,a1		
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
	blt.L 	notfinished
	tst.l 	d5
	bne.S 	damage
	rts

damage:
	move.w 	#$ffffffff,d0
damloop:
	move.w 	d0,$dff180
	subi.l 	#1,d0
	bne.S 	damloop
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

; Written by LORD BLITTER
; Belgium






BobImageList:
	dc.l	bobs		;erstes bob
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
clear:
	dc.l	bobs+[24*3456]
	dc.l	bobs+[25*3456]

boblist:
	dc.l	bob1

bob1:
	dc.l	bob2		;Next Bob		0
	dc.w	64,72		;Breite,Hoehe		4
	dc.w	80,102		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	0		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	save1		;save1			26
	dc.l	save2		;save2			30
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
	dc.w	0,1,2,3,4,13		; Laufen
	dc.w	14,15,16,17,18,16
	dc.w	14,14,15,16,17,18,16
	dc.w	14,15,16,17,18,16
	dc.w	14,14,14,15,16,17,18,16
	dc.w	14,15,16,17,18,16
	dc.w	14,14,15,16,17,18,16
	dc.w	14,15,16,17,18,16
	dc.w	14,14,14,15,16,17,18,16		; Haemmern
	dc.w	13,0,1,2,3,4,5,6,7,8,9,10,11,12	; Laufen
	dc.w	0,1,2
	dc.w	19,20,21,22
	dc.w	22,22,22,22,22,22,22,22,-2
	dc.w	-3				; Jump (Oh, Yeah !!!!)

Animcoord1:
	dc.w	320,104
	dc.w	550,104
	dc.w	-1,220
	dc.w	615,104

	dc.w	-2,611,103
	dc.w	-2,612,103
	dc.w	-2,613,102
	dc.w	-2,614,102
	dc.w	-2,616,101
	dc.w	-2,618,101
	dc.w	-2,620,100
	dc.w	-2,622,99
	dc.w	-2,624,97
	dc.w	-2,626,95
	dc.w	-2,628,93
	dc.w	-2,630,91
	dc.w	-2,632,89
	dc.w	-2,634,88
	dc.w	-2,636,87
	dc.w	-2,638,86
	dc.w	-2,640,86
	dc.w	-2,642,84
	dc.w	-2,644,84
	dc.w	-2,646,85
	dc.w	-2,648,85
	dc.w	-2,650,86
	dc.w	-2,652,87
	dc.w	-2,654,88
	dc.w	-2,656,89
	dc.w	-2,658,90
	dc.w	-2,660,92
	dc.w	-2,662,94
	dc.w	-2,664,96
	dc.w	-2,666,100
	dc.w	-2,668,100
	dc.w	-2,670,102
	dc.w	-2,672,104
	dc.w	-2,674,105
	dc.w	-2,676,106
	dc.w	-2,678,108
	dc.w	-2,680,111
	dc.w	-2,683,114
	dc.w	-2,686,118
	dc.w	-2,689,122
	dc.w	-2,692,129
	dc.w	-2,695,135
	dc.w	-2,698,141
	dc.w	-2,701,148
	dc.w	-2,704,156
	dc.w	-2,707,164
	dc.w	-2,710,172
	dc.w	-2,713,181

	dc.w	0,0


	;	0,0	= END
	;	-1,t	= t/50 sek. pause
	;	-2,x,y	= moveimmediate to x,y

bob2:
	dc.l	bob3		;Next Bob		0
	dc.w	64,72		;Breite,Hoehe		4
	dc.w	360,10		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	0		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	save3		;save1			26
	dc.l	save4		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	bob1		;Last Bob		44
	dc.w	4		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	Animseq2	;AnimProgramm		54
	dc.l	Animcoord2	;Zeiger auf MoveListe	58
	dc.w	0		;PauseCounter		62
	dc.w	1		;MoveSpeed		64
	dc.w	0		;MoveCounter		66
	dc.w	1		;MoveDistX		68
	dc.w	1		;MoveDistY		70

Animseq2:
	dc.w	3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8		; Laufen
	dc.w	13				; Drehen
	dc.w	14,15,16,17,18,16,14
	dc.w	14,15,16,17,18,17,16,15,14
	dc.w	14,15,16,17,18,16,14
	dc.w	14,15,16,17,18,17,16,15,14
	dc.w	14,16,18,16,15,14
	dc.w	14,15,16,18,17,15,14
	dc.w	14,15,16,18,14
	dc.w	13
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	1
	dc.w	19,20,21,22,22,22,22,22,22,22,22,-2
	dc.w	-3

Animcoord2:
	dc.w	320,104
	dc.w	-1,100
	dc.w	510,104
	dc.w	-1,210
	dc.w	610,104

	dc.w	-2,611,103
	dc.w	-2,612,103
	dc.w	-2,613,102
	dc.w	-2,614,102
	dc.w	-2,616,101
	dc.w	-2,618,101
	dc.w	-2,620,100
	dc.w	-2,622,99
	dc.w	-2,624,97
	dc.w	-2,626,95
	dc.w	-2,628,93
	dc.w	-2,630,91
	dc.w	-2,632,89
	dc.w	-2,634,88
	dc.w	-2,636,87
	dc.w	-2,638,86
	dc.w	-2,640,86
	dc.w	-2,642,84
	dc.w	-2,644,84
	dc.w	-2,646,85
	dc.w	-2,648,85
	dc.w	-2,650,86
	dc.w	-2,652,87
	dc.w	-2,654,88
	dc.w	-2,656,89
	dc.w	-2,658,90
	dc.w	-2,660,92
	dc.w	-2,662,94
	dc.w	-2,664,96
	dc.w	-2,666,100
	dc.w	-2,668,100
	dc.w	-2,670,102
	dc.w	-2,672,104
	dc.w	-2,674,105
	dc.w	-2,676,106
	dc.w	-2,678,108
	dc.w	-2,680,111
	dc.w	-2,683,114
	dc.w	-2,686,118
	dc.w	-2,689,122
	dc.w	-2,692,129
	dc.w	-2,695,135
	dc.w	-2,698,141
	dc.w	-2,701,148
	dc.w	-2,704,156
	dc.w	-2,707,164
	dc.w	-2,710,172
	dc.w	-2,713,181
	dc.w	0,0

bob3:
	dc.l	0		;Next Bob		0
	dc.w	64,72		;Breite,Hoehe		4
	dc.w	360,10		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	0		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	save5		;save1			26
	dc.l	save6		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	bob2		;Last Bob		44
	dc.w	4		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	Animseq3	;AnimProgramm		54
	dc.l	Animcoord3	;Zeiger auf MoveListe	58
	dc.w	0		;PauseCounter		62
	dc.w	1		;MoveSpeed		64
	dc.w	0		;MoveCounter		66
	dc.w	1		;MoveDistX		68
	dc.w	1		;MoveDistY		70

Animcoord3:
	dc.w	320,103
	dc.w	-1,160
	dc.w	470,103
	dc.w	-1,200
	dc.w	610,103
	dc.w	-2,611,103
	dc.w	-2,612,103
	dc.w	-2,613,102
	dc.w	-2,614,102
	dc.w	-2,616,101
	dc.w	-2,618,101
	dc.w	-2,620,100
	dc.w	-2,622,99
	dc.w	-2,624,97
	dc.w	-2,626,95
	dc.w	-2,628,93
	dc.w	-2,630,91
	dc.w	-2,632,89
	dc.w	-2,634,88
	dc.w	-2,636,87
	dc.w	-2,638,86
	dc.w	-2,640,86
	dc.w	-2,642,84
	dc.w	-2,644,84
	dc.w	-2,646,85
	dc.w	-2,648,85
	dc.w	-2,650,86
	dc.w	-2,652,87
	dc.w	-2,654,88
	dc.w	-2,656,89
	dc.w	-2,658,90
	dc.w	-2,660,92
	dc.w	-2,662,94
	dc.w	-2,664,96
	dc.w	-2,666,100
	dc.w	-2,668,100
	dc.w	-2,670,102
	dc.w	-2,672,104
	dc.w	-2,674,105
	dc.w	-2,676,106
	dc.w	-2,678,108
	dc.w	-2,680,111
	dc.w	-2,683,114
	dc.w	-2,686,118
	dc.w	-2,689,122
	dc.w	-2,692,129
	dc.w	-2,695,135
	dc.w	-2,698,141
	dc.w	-2,701,148
	dc.w	-2,704,156
	dc.w	-2,707,164
	dc.w	-2,710,172
	dc.w	-2,713,181
	dc.w	0,0

Animseq3:
	dc.w	1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	1,2,3,4

	dc.w	13
	dc.w	14,15,16,18,17,16,15
	dc.w	14,15,16,18,17,16,15
	dc.w	14,15,16,17,18,17,15
	dc.w	14,15,17,18,17,15
	dc.w	14,15,18,17,16,15
	dc.w	14,16,18,15
	dc.w	14,15,16,17,18,16,15
	dc.w	15,17,18,16,15
	dc.w	13
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
	dc.w	0,1,2,3,4,5,6,7,8,9

	dc.w	19,20,21,22,22,22,22,22,22,22,22,22,22
	dc.w	-2
	dc.w	-3

bob4:
	dc.l	0		;Next Bob		0
	dc.w	64,72		;Breite,Hoehe		4
	dc.w	720,10		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	23		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	save5		;save1			26
	dc.l	save6		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	0		;Last Bob		44
	dc.w	0		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	0		;AnimProgramm		54
	dc.l	Animcoord4	;Zeiger auf MoveListe	58
	dc.w	0		;PauseCounter		62
	dc.w	1		;MoveSpeed		64
	dc.w	0		;MoveCounter		66
	dc.w	5		;MoveDistX		68
	dc.w	1		;MoveDistY		70

Animcoord4:
	dc.w	320,90
	dc.w	0,0

	dc.w	-2,720,08
	dc.w	-2,715,10
	dc.w	-2,710,12
	dc.w	-2,705,14
	dc.w	-2,700,16
	dc.w	-2,695,19
	dc.w	-2,690,22
	dc.w	-2,685,25
	dc.w	-2,680,28
	dc.w	-2,675,29
	dc.w	-2,670,31
	dc.w	-2,665,32
	dc.w	-2,660,34
	dc.w	-2,655,37
	dc.w	-2,650,40
	dc.w	-2,645,48
	dc.w	-2,640,56
	dc.w	-2,635,57
	dc.w	-2,630,58
	dc.w	-2,625,59
	dc.w	-2,620,60
	dc.w	-2,615,61
	dc.w	-2,610,63
	dc.w	-2,605,64
	dc.w	-2,600,66
	dc.w	-2,595,69
	dc.w	-2,590,70
	dc.w	-2,585,77
	dc.w	-2,580,84
	dc.w	-2,575,86
	dc.w	-2,570,87
	dc.w	-2,565,89
	dc.w	-2,560,90
	dc.w	-2,555,91
	dc.w	-2,550,92
	dc.w	-2,545,93
	dc.w	-2,540,94
	dc.w	-2,535,95
	dc.w	-2,530,96
	dc.w	-2,525,97
	dc.w	-2,520,98
	dc.w	-2,515,99
	dc.w	-2,510,100
	dc.w	-2,505,101
	dc.w	-2,500,102
	dc.w	-2,495,103
	dc.w	-2,490,104
	dc.w	-2,485,105
	dc.w	-2,480,106
	dc.w	-2,475,106
	dc.w	-2,470,106
	dc.w	-2,465,106
	dc.w	-2,460,106
	dc.w	-2,455,107
	dc.w	-2,450,107
	dc.w	-2,445,107
	dc.w	-2,440,108
	dc.w	-2,435,108
	dc.w	-2,430,108
	dc.w	-2,425,108
	dc.w	-2,420,109
	dc.w	-2,415,109
	dc.w	-2,410,109
	dc.w	-2,405,109
	dc.w	-2,400,110
	dc.w	-2,395,110
	dc.w	-2,390,110
	dc.w	-2,385,110
	dc.w	-2,380,110
	dc.w	-2,375,110
	dc.w	-2,370,110
	dc.w	-2,365,110
	dc.w	-2,360,110
	dc.w	-2,355,110
	dc.w	-2,350,110
	dc.w	-2,345,110
	dc.w	-2,340,110
	dc.w	-2,335,110
	dc.w	-2,330,110
	dc.w	-2,325,110
	dc.w	-2,320,110

	dc.w	0,0


;-1  ende
;-2  leeres Bob
;-3  ende ohne frischbeginn


sprite1:
dc.w $2a80,$2b00
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $2800,$3000
dc.w $0,$0
blk.l	100,0

key:
	dc.w	0
stop:
	dc.w	0
counter:
	dc.l	0
gfxbase:
	dc.l	0
dosbase:
	dc.l	0
gfxtext:
	dc.b	'graphics.library',0
dostext:
	dc.b	'dos.library',0
file1:
	dc.b	'df1:Animc',0
