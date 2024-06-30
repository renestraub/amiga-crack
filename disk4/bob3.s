

	org	$35000
	load	$35000



;
;Includes	BACK nach Page1
;		Anim nach Bobs
;		Title1 nach Pic
;		(wird jetzt alles nachgeladen)
;
;		INTRO V0.66
;		(-C5- 7.Dezember 1987)


	pl=13056
	drawer=363;+300
	page1=$7e000-[10*pl]
	page2= page1 + [5*pl]
	pic=page1-8000	
	bobs=pic-86800
	save1=bobs-4000
	save2=save1-4000
	save3=save2-4000
	save4=save3-4000
	save5=save4-4000
	save6=save5-4000
o:
	clr.l	0
	move.l	#text,textcounter
	bsr	opentrd
	bsr	loadall
	bsr	closetrd

	move.l	4,a6
	lea	gfxtext,a1
	jsr	-408(a6)
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		; OWN blitter (hae,hae)

	move	#$8010,$dff09a		;Copper Interrupt
	move	#$8400,$dff096		;Blitter Nasty

	move.l	boblist,a1
loop:
	move.l	58(A1),a2
	move.l	(A2),8(A1)
	addq.l	#4,58(A1)

	move.l	(A1),a1
	cmp.l	#0,a1
	bne.s	loop

	bsr	initspr

	clr	FlipFlag
	bsr	InitBobList

	move.l	#copperl,$dff080
	move	#$83a0,$dff096
	move.l	$6c,VBlankveq
	move.l	#VBlankInt,$6c
wait:
	tst	endit
	bne.s	endprg

	btst	#10,$dff016
	bne.s	nopause2
	move	#1,stop			; gedrueckt
np3:
	btst	#6,$bfe001
	bne.s	np3			; erneut gedrueckt

	clr	stop
nopause2:
	cmp.b	#$7f,$bfec01
	bne.s	wait
endprg:
	move.l	VBlankVeq,$6c
	move.l	gfxbase,a6
	move.l 	38(a6),$dff080
	jsr	-462(a6)		; Disown blit
	move	#$8020,$dff096
	rts

dopic:
	move.l	#bobs,a0
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
	add.l	#pl-9600,a1
	add.l	#pl-9600,a2
	dbra	d5,copyplane

	move.l	#bobs+40000,a0
	lea	copcol+2,a2
	moveq	#31,d7
cm:
	move	(a0)+,(A2)
	addq.l	#4,a2
	dbf	d7,cm	
	rts

VBlankInt:
	movem.l	d0-d7/a0-a6,-(a7)
	tst	stop
	bne	END

	lea	$dff000,a6
	move	$1e(A6),d0
	btst	#4,d0
	beq	EndVblank

	cmp.b	#$7f,$bfec01
	beq	EndVblank

	bsr	liane
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

	cmp.l	#1500,counter2
	bne.s	notend
	move	#1,endit
notend:
;	cmp.l	#300,counter2
;	blo.s	endint

	bsr	Drawbobs
	bsr	Movebobs

	cmp.l	#900,counter2;+300,counter2
	blo.s	noscroll

;	bsr	cycle
;	bsr	print
;	bsr	copyscroll
endint:
noscroll:
	move	#$10,$9c(a6)
EndVblank:
	addq.l	#1,counter
	addq.l	#1,counter2
	cmp.l	#800,counter2;+300,counter2
	bne.s	notre
	move.l	#bob4,boblist
	bsr	initboblist
notre:
END:
	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9
VBlankveq:
	dc.l	0

liane:
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
 	add	#45+14,d0
	cmp	#160,d0
	ble.s	ok2345
	move	#160,d0
ok2345:
	move.b	d0,2(A1)
	rts


initspr:
	lea	copperl,a1
	lea	sprlist,a2
	moveq	#7,d6
ispr:
	move.l	(A2)+,d0
	move	d0,6(A1)
	swap	d0
	move	d0,2(A1)
	add.l	#8,a1
	dbra	d6,ispr
	rts

sprlist:
	dc.l	0;sprite1
	dc.l	0;spr2
	dc.l	0;spr3
	dc.l	0;spr4
	dc.l	sprite1
	dc.l	0;spr6
	dc.l	0;spr7
	dc.l	0;spr8

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

loadall:
	move.l	4,a6
	lea	diskIO,a1
	move	#2,28(A1)
	move.l	#bobs,40(A1)
	move.l	#512*90,36(A1)
	move.l	#512*120,44(A1)
	jsr	-456(A6)
	bsr	dopic		; Back laden

	lea	diskIO,a1
	move	#2,28(A1)
	move.l	#bobs,40(A1)
	move.l	#512*70,36(A1)
	move.l	#512*220,44(A1)
	jsr	-456(A6)

	move.l	#bobs,lowwr
	move.l	#bobs+29688,read
	bsr	decru		; BOB's laden und decrunchen

	lea	diskIO,a1
	move	#2,28(A1)
	move.l	#pic,40(A1)
	move.l	#512*10,36(A1)
	move.l	#512*400,44(A1)
	jsr	-456(A6)	; CRACK laden

	lea	diskIO,a1
	move	#9,28(A1)
	move.l	#0,36(A1)
	jsr	-456(a6)
	rts

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

FlipFlag:
	dc.w	0

colorcnt:
	dc.l	endlist

colorlist:
	dc.w	$f50,$f50,$f50,$f60,$f60,$f70,$f70,$f80
	dc.w	$f80,$f90,$f90,$fa0,$fa0,$fb0,$fb0,$fc0,$fc0
	dc.w	$fd0,$fd0,$fe0,$fe0,$fd0,$fd0
	dc.w	$fc0,$fc0,$fb0,$fb0,$fa0,$fa0,$f90,$f90,$f80,$f80
	dc.w	$f70,$f70,$f60,$f60
endlist:
	dc.w	$f50,$f50,$f50,$f60,$f60,$f70,$f70,$f80
	dc.w	$f80,$f90

copperl:
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
	dc.w 	$008e,$3a81
 	dc.w 	$0090,$02c1
	dc.w 	$0104,$0024
	dc.w 	$0092,$0038
	dc.w 	$0094,$00d2
	dc.w 	$0102,$0000
	dc.w 	$0108,8
	dc.w 	$010a,8

copcol:
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
	dc.w	$01b4,$0
	dc.w	$01b6,$0
	dc.w	$01b8,$0
	dc.w	$01ba,$0
	dc.w	$01bc,$0
	dc.w	$01be,$0
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
;copcol:
	dc.w	$6f21,$fffe
	dc.w	$1be,$f00

	dc.w	$7021,$fffe
	dc.w	$1ba,$b
	dc.w	$1be,$f00

	dc.w	$7121,$fffe
	dc.w	$1be,$f00

	dc.w	$7221,$fffe
	dc.w	$1be,$f00

	dc.w	$7321,$fffe
	dc.w	$1be,$f00

	dc.w	$7421,$fffe
	dc.w	$1be,$f00

	dc.w	$7521,$fffe
	dc.w	$1be,$f00

	dc.w	$7521,$fffe
	dc.w	$1be,$f00

	dc.w	$7621,$fffe
	dc.w	$1be,$f00

	dc.w	$7721,$fffe
	dc.w	$1be,$f00

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
	dc.l	page1+pl+8
	dc.l	page1+[2*pl]+8
	dc.l	page1+[3*pl]+8
	dc.l	page1+[4*pl]+8

bitmstr2:
	dc.w	48
	dc.w	200
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page2+8
	dc.l	page2+pl+8
	dc.l	page2+[2*pl]+8
	dc.l	page2+[3*pl]+8
	dc.l	page2+[4*pl]+8

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
;	add.l	#pl,a2
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

	add.l	#pl,a2		; Page1
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

; CYCLE

cycle:
	subq.l	#2,colorcnt
	move.l	colorcnt,a1
	cmp.l	#colorlist,colorcnt
	bne.s	nend
	move.l	#endlist,colorcnt
nend:
	moveq	#9,d6
	lea	copcol,a1
	move.l	colorcnt,a2
cyc2:
findit:
	cmp	#$1be,(A1)+
	bne.s	findit
	move	(A2)+,(A1)+
	dbra	d6,cyc2
	rts


; COPY

copyscroll:
	lea	$dff000,a6
	move.l	#source,a2
	move.l	#sourcemask,a3
	moveq	#4,d5
	move.l	#page1+[48*62]+20,a1

	tst	flipflag
	beq.s	blitwait5
	move.l	#page2+[48*62]+20,a1
BlitWait5:
	btst	#14,2(A6)
	bne.s	BlitWait5

	move.l	a1,$48(A6)		;Source c (background)
	move.l	a2,$4c(A6)		;Source b (data)
	move.l	a3,$50(A6)		;Source a (Maske)
	move.l	a1,$54(A6)		;Dest C
	clr	$42(a6)			;BltCon1
	move	#$fca,$40(a6)		;BltCon0
	move	#32,$66(A6)		;Modulo Dest
	move	#32,$60(a6)		;Modulo c
	move	#2,$64(a6)
	move	#4,$62(A6)
	move.l	#$ffffffff,$44(a6)
	move	#%0000010100001000,$58(a6)

	add.l	#pl,a1
	add.l	#400,a2

	dbra	d5,BlitWait5
BlitWait7:
	btst	#14,2(A6)
	bne.s	BlitWait7
	rts


; SCROLL

scroll:
	lea	$dff000,a6
	move.l	#source+2,a1
	move.l	a1,a2
	subq.l	#2,a2
	moveq	#4,d5
blitwait6:
	btst	#14,2(A6)
	bne.s	blitwait6

	move.l	a1,$50(a6)		;Source A
	move.l	a2,$54(a6)		;Dest D
	clr	$42(a6)			;BltCon1
	move	#$f9f0,$40(a6)		;BltCon0
	move	#2,$66(A6)		;Modulo Dest
	move	#2,$64(a6)
	move.l	#$ffffffff,$44(a6)
	move	#%0000010100001001,$58(a6)

	add.l	#400,a2
	add.l	#400,a1
	dbra	d5,blitwait6
	rts

; PRINT :
; A0=Zeiger auf 1.Bitplane
; A1=Zeiger auf text
; D0=Anzahl Zeichen
; D1=X
; D2=Y

print:	
	bsr	scroll
	add	#1,tcnt
	cmp	#7,tcnt
	bgt.s	p2
	rts
p2:
	move	#0,tcnt
	move.l	#source+[18*5]+26,a0
	move.l	textcounter,a1
	tst.b	(A1)
	bne.s	ok34
	move.l	#text,textcounter
ok34:
	move.l	textcounter,a1
	cmp.b	#-1,(A1)
	bne.s	notp

	clr.l	d2
	move.b	1(A1),d2
	move	d2,timer
	add.l	#2,textcounter
	rts
notp:
	bsr	Writeletter
	addq.l	#1,textcounter
	rts

; a1=Zeiger auf Text
; a0=Zeiger in Bitplane

writeletter:
	sub.l	d4,d4
	lea	font,a3
	move.b	(A1),d4
	sub	#' ',d4
	mulu	#10,d4
	add.l	d4,a3

	moveq	#9,d7
writechar:
	move.b	(A3)+,d3
	or.b	d3,(A0)
	or.b	d3,400(A0)
	or.b	d3,800(A0)
	or.b	d3,1200(A0)
	or.b	d3,1600(A0)

	add.l	#20,a0
	dbra	d7,writechar
	rts
textcounter:
	dc.l	text
text:
	DC.B	'THIS IS THE INTRO FOR A BRANDNEW GAME '
	DC.B	'CALLED C R A C K             '
	dc.b	-1,150,' JETZT WARTEN WIR EIN BISSCHEN'
	DC.B	-1,100,' UND NOCH EINMAL     ',0

even
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
	dc.w	720,0		;New x,y Pos		8
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
	dc.w	370,70
	dc.w	-1,50
	dc.w	-2,370,71
	dc.w	-2,370,73
	dc.w	-2,370,76
	dc.w	-2,370,80
	dc.w	-2,370,85
	dc.w	-2,370,91
	dc.w	-2,370,98
	dc.w	-2,370,106
	dc.w	-2,370,115
	dc.w	-2,370,125
	dc.w	-2,370,136
	dc.w	-2,370,148
	dc.w	-2,370,161
	dc.w	-2,370,175
	dc.w	-2,370,204

	dc.w	0,0

;-1  ende
;-2  leeres Bob
;-3  ende ohne frischbeginn


sprite1:
dc.w $3880,$2b00
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
gfxtext:
	dc.b	'graphics.library',0
file1:
	dc.b	'df1:Animc',0
even
file2:
	dc.b	'df1:back',0
even
file3:
	dc.b	'df1:titel1',0
even
file4:
	dc.b	'df1:maske',0
even
font:
	blk.b	160,0
	dc.b $7C,$FE,$C6,$CE,$DE,$F6,$E6,$C6,$FE,$7C
	dc.b $18,$18,$18,$18,$18,$18,$18,$18,$18,$18
	dc.b $FC,$FE,$06,$06,$7E,$FC,$C0,$C0,$FE,$7E
	dc.b $FC,$FE,$06,$06,$3E,$3E,$06,$06,$FE,$FC
	dc.b $CC,$CC,$CC,$CC,$FE,$FE,$0C,$0C,$0C,$0C
	dc.b $7E,$FE,$C0,$C0,$FC,$7E,$06,$06,$FE,$FC
	dc.b $7E,$FE,$C0,$C0,$FC,$FE,$C6,$C6,$FE,$7C
	dc.b $FC,$FE,$06,$06,$06,$06,$06,$06,$06,$06
	dc.b $7C,$FE,$C6,$C6,$7C,$FE,$C6,$C6,$FE,$7C
	dc.b $7C,$FE,$C6,$C6,$FE,$7E,$06,$06,$7E,$7C
	blk.b	70,$0
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

even
spr1:
dc.w $8080,$a000
dc.w $2FCD,$213A
dc.w $AAB0,$65E0
dc.w $BD90,$4170
dc.w $3F40,$80C0
dc.w $EC02,$A802
dc.w $2808,$7008
dc.w $702D,$682D
dc.w $3039,$D039
dc.w $C037,$2037
dc.w $2066,$6067
dc.w $00D1,$40D2
dc.w $C33B,$8339
dc.w $8FFC,$CFF8
dc.w $8F38,$0F3C
dc.w $2E5C,$AE58
dc.w $3FC0,$BFF8
dc.w $27E8,$A7F8
dc.w $1FF4,$9FF8
dc.w $CFA4,$4FF8
dc.w $2FFC,$AFF9
dc.w $1D23,$5FFC
dc.w $7E64,$BFFB
dc.w $E0F0,$BFFF
dc.w $0B27,$7FF8
dc.w $AAF3,$1FCC
dc.w $980F,$6FF0
dc.w $7C1F,$4FE0
dc.w $DEC4,$2F3B
dc.w $7C2F,$83D0
dc.w $8A69,$C596
dc.w $2BAE,$2950
dc.w $139C,$8540
dc.w $0000,$0000
spr2:
dc.w $8088,$a000
dc.w $8C00,$6000
dc.w $1E61,$1FB0
dc.w $B3FC,$B3C8
dc.w $3C98,$3FF2
dc.w $EF62,$EFFC
dc.w $FD00,$FFFF
dc.w $F7A3,$FFFC
dc.w $DE74,$FFE9
dc.w $D008,$EFF2
dc.w $E6E0,$6614
dc.w $9CB1,$CF88
dc.w $0F21,$05F1
dc.w $6782,$1188
dc.w $7B80,$1981
dc.w $50B7,$0861
dc.w $40FA,$3822
dc.w $59FA,$38F2
dc.w $DA00,$39A0
dc.w $32AE,$108E
dc.w $006C,$081A
dc.w $13F3,$4809
dc.w $99FA,$3603
dc.w $51C0,$AC02
dc.w $2F88,$D000
dc.w $6FCA,$9000
dc.w $FF40,$0000
dc.w $7E18,$8000
dc.w $7C81,$8001
dc.w $F802,$0000
dc.w $CF02,$0005
dc.w $BD14,$0013
dc.w $90DF,$00E1
dc.w $0000,$0000
spr3:
dc.w $8090,$a000
dc.w $B3F4,$4A38
dc.w $5851,$2841
dc.w $3096,$C097
dc.w $65B7,$65B7
dc.w $02EF,$C2EF
dc.w $407F,$407F
dc.w $C8DF,$E8DF
dc.w $187E,$187F
dc.w $71EA,$F1F5
dc.w $0FE7,$8FD0
dc.w $CFC6,$CF82
dc.w $0F41,$0FC7
dc.w $8E87,$8EC3
dc.w $FE02,$FF8E
dc.w $FF4B,$FF87
dc.w $FFA5,$FF82
dc.w $FFDC,$FFC1
dc.w $FF9A,$FFF6
dc.w $E14F,$FFF0
dc.w $FC48,$FFF7
dc.w $C004,$FFFB
dc.w $5A17,$FFE8
dc.w $810D,$7FF2
dc.w $C0AF,$BF50
dc.w $238A,$1C95
dc.w $46FE,$7920
dc.w $190B,$A424
dc.w $3C1F,$2250
dc.w $C24E,$B840
dc.w $D810,$A080
dc.w $E89E,$1000
dc.w $381B,$CCA0
dc.w $0000,$0000
spr4:
dc.w $8098,$a000
dc.w $520E,$2938
dc.w $4A10,$87E0
dc.w $2340,$3020
dc.w $9040,$E0E0
dc.w $D900,$FC00
dc.w $D407,$FF17
dc.w $9280,$FF00
dc.w $0850,$FFA0
dc.w $6029,$BFF1
dc.w $80AF,$1F47
dc.w $A0E6,$7F0A
dc.w $70BB,$5747
dc.w $F6F7,$F10D
dc.w $9FDE,$F02C
dc.w $CFE2,$1004
dc.w $53BC,$BC09
dc.w $0DE3,$6203
dc.w $1ED7,$8013
dc.w $D6C1,$2803
dc.w $7ADD,$8057
dc.w $FE5A,$003F
dc.w $B23A,$433F
dc.w $E031,$103F
dc.w $EAA0,$103F
dc.w $E8A2,$09BF
dc.w $DA80,$04BF
dc.w $F008,$02BF
dc.w $1120,$003F
dc.w $C909,$0036
dc.w $810E,$0031
dc.w $7133,$000C
dc.w $0005,$013A
dc.w $0000,$0000
spr5:
dc.w $80a0,$a000
dc.w $3250,$2812
dc.w $0025,$000A
dc.w $1404,$1514
dc.w $3F88,$3F04
dc.w $3B43,$3BC6
dc.w $3FE3,$3FA2
dc.w $7FF2,$7FD1
dc.w $3F54,$3FE3
dc.w $7E63,$7FF2
dc.w $CFD2,$E7F2
dc.w $2F94,$63FA
dc.w $E511,$E7FA
dc.w $E314,$E1F8
dc.w $A30F,$E2F1
dc.w $C015,$E5E9
dc.w $05A7,$E4D8
dc.w $44C5,$E4BA
dc.w $4795,$E16A
dc.w $9C9B,$F364
dc.w $00DD,$FF22
dc.w $04EF,$FB10
dc.w $003F,$FFC0
dc.w $037F,$FDC0
dc.w $040F,$FA50
dc.w $201E,$DCA0
dc.w $59D3,$A0F0
dc.w $485E,$B0B8
dc.w $3CF2,$C470
dc.w $7A80,$8048
dc.w $DEC4,$204C
dc.w $5802,$A34F
dc.w $546C,$AE28
dc.w $0000,$0000
spr6:
dc.w $0000,$0000
dc.w $48EA,$B11F
dc.w $6A52,$37D2
dc.w $9C46,$4646
dc.w $7C04,$9404
dc.w $10BC,$50BC
dc.w $81AF,$E1AF
dc.w $CB55,$0B55
dc.w $097D,$897D
dc.w $07AD,$07AF
dc.w $05A6,$05BF
dc.w $01B3,$01BC
dc.w $0D72,$0D7C
dc.w $DFE9,$DFF0
dc.w $4ED0,$CFE0
dc.w $9E93,$5FE0
dc.w $8FE0,$CFC1
dc.w $DFA3,$BFC0
dc.w $8F23,$1FD0
dc.w $AEB1,$2FD0
dc.w $D610,$37E0
dc.w $E400,$07F0
dc.w $BC08,$17F2
dc.w $2A01,$07FE
dc.w $800F,$01F0
dc.w $C146,$06B9
dc.w $C1DF,$0120
dc.w $0253,$002C
dc.w $00CB,$0174
dc.w $001E,$0040
dc.w $004F,$0220
dc.w $E4E6,$25E0
dc.w $6122,$3200
dc.w $0000,$0000
spr7:
dc.w $0000,$0000
dc.w $F025,$E41E
dc.w $7B86,$7CC6
dc.w $7F40,$7FA0
dc.w $EE20,$FFD0
dc.w $F604,$FFF8
dc.w $FC02,$FFFC
dc.w $D911,$FFEF
dc.w $C230,$FFCF
dc.w $C815,$FFE8
dc.w $B90D,$C6F3
dc.w $8137,$ECC2
dc.w $00E7,$0333
dc.w $B543,$6C87
dc.w $269F,$E20F
dc.w $2D33,$E333
dc.w $B3A7,$7067
dc.w $12F7,$F127
dc.w $E7E7,$E177
dc.w $2717,$E007
dc.w $0AAD,$C20F
dc.w $7124,$382B
dc.w $1300,$2213
dc.w $E995,$380B
dc.w $B102,$0001
dc.w $B304,$0004
dc.w $FF80,$0006
dc.w $D800,$0002
dc.w $0E01,$0001
dc.w $C409,$000B
dc.w $8835,$0034
dc.w $E0EA,$00C9
dc.w $A380,$0317
dc.w $0000,$0000
spr8:
dc.w $0000,$0000
dc.w $F6D4,$2DE6
dc.w $A1E0,$A1D4
dc.w $130C,$1312
dc.w $0712,$0706
dc.w $0E0A,$0E06
dc.w $1B84,$1B8E
dc.w $FF82,$FF8E
dc.w $839A,$431E
dc.w $BF80,$7F9E
dc.w $DD70,$5FFE
dc.w $CC80,$CFFE
dc.w $D530,$DFFE
dc.w $E656,$FFF8
dc.w $F202,$FFFC
dc.w $B74A,$FFF4
dc.w $FC00,$FFFE
dc.w $840E,$FFF0
dc.w $701E,$FFE0
dc.w $906E,$FF90
dc.w $8000,$FFFE
dc.w $801E,$FFE0
dc.w $888C,$F732
dc.w $0C2E,$F3F0
dc.w $448A,$FB30
dc.w $8488,$7B10
dc.w $4D86,$3208
dc.w $4E82,$B108
dc.w $4184,$3E04
dc.w $1902,$E616
dc.w $1F88,$E012
dc.w $3F9A,$C01C
dc.w $5B0C,$A41C
blk.l	200,0
dc.w $0000,$0000

source:
	blk.b	400,$ff
	blk.b	400,$0
	blk.b	400,$0
	blk.b	400,$0
	blk.b	400,$0
sourcemask:
	blk.b	360,0
tcnt:
	dc.w	0
timer:
	dc.w	0
counter2:
	dc.l	0
endit:
	dc.w	0
