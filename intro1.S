*****************************************************************************
*                                                                           *
* INTRO 1                                 Project started  : xx.yy.1987     *
* -------                                         finished : ..........     *
*                                                                           *
* 1. Introteil zu 'Crack'                                                   *
*                                                                           *
* Author René Straub                Tel.  +41 64 462 661                    *
*        Talstrasse 820             Fax.  +41 64 461 417                    *
*        5726 Unterkulm (Schweiz)   EMail straub@crack.aare.net.ch          *
*                                                                           *
* Modification History:                                                     *
* ---------------------                                                     * 
*                                                                           *
* xx.yy.87  RHS  Created this file                                          *
* 03.02.95  RHS  Updated file, makes it more system friendly                *
* 13.02.95  RHS  Runs under OS with some problems concerning copperlist     *
*                                                                           *
*****************************************************************************



		INCLUDE "Dos.i"
		INCLUDE "Exec.i"
		INCLUDE "Intuition.i"
		INCLUDE "Graphics.i"




MaxTimer:	EQU	250

PageWidth:	EQU	64
PageHeight:	EQU	230
PageDepth:	EQU	5

PageSize:	EQU	PageWidth*PageHeight

YPos:		EQU	10
BobLen:		EQU	5184





Main:		cmp.b	#'D',(a0)
		bne	.System

	*** Keep screen dark on exit ***


		st.b	DarkFlag
.System:

	*** Libraries öffnen ***

		lea	dostext,a1
		Exec	OldOpenLibrary
		move.l	d0,_DOSBase

		lea	gfxtext,a1
		Exec	OldOpenLibrary
		move.l	d0,_GfxBase

		lea	inttext,a1
		Last	OldOpenLibrary
		move.l	d0,_IntuitionBase


	*** Dummy Screen öffnen ***

		bsr	OpenScr
		tst.l	d0
		bne	ExitDOS



	*** Default View (disables AGA) ***

		sub.l	a1,a1
		Gfx	LoadView



	*** Set Font to Topaz 80 ***

		lea	PrefsBuf,a0
		moveq	#120,d0
		Intui	GetPrefs

		lea	PrefsBuf,a1
		move.b	#8,(A1)
		move	#1,108(a1)

		lea	PrefsBuf,a0
		moveq	#120,d0
		moveq	#0,d1
		Last	SetPrefs



	*** Ab hier geht's los ***


		move.w	#$20,$dff1dc		* PAL-Screen
	;;	move.w	#$0100,$dff096		* Dunkel
		move.l	#copperl3,$dff080	* Ganz dunkel



	*** Create Rastport ***

		lea	RastPort,a1
		Gfx	InitRastPort

		lea	RastPort,a1
		move.l	#bitm,4(A1)


	*** Print Text ***

		move.l	#420,d0
		moveq	#10,d1
		Last	Move

		lea	text,a0
		moveq	#endtext-text-1,d0
		Last	Text



	*** Set Copperlist ***

		move	#$8400,$dff096		* Blitter Nasty
	;;	move	#$8100,$dff096		* Bitplane DMA
		bsr	InitCopp
		move.l	#copperl2,$dff080



	*** Load Files ***

		lea	bobs_file,a0
		lea	bobs2,a1
		move.l	#43*512,d0
		bsr	LoadFile

		move.l	#bobs2+21900,read
		move.l	#bobs2,lowwr
		bsr	decru


		lea	gfx_file,a0
		lea	page1,a1
		move.l	#15*512,d0
		bsr	LoadFile

		move.l	#page1+7484,read
		move.l	#page1,lowwr
		bsr	decru


	*** Initializations, set MainCopperlist ***

		bsr	InitBobList
		bsr	SetPages
		move.l	#Starlist,StarCnt
		move.l	#copperl,$dff080



	*** Fade in ***

		lea	o1,a5
		moveq	#15-1,d6
		move.l	_GfxBase,a6

.CopyMap:	Last	WaitTOF
		Last	WaitTOF

		moveq	#8-1,d5
		lea	fadecol+2,a4

.CopyCol:	move	(A5)+,(A4)
		addq.l	#4,a4			* Linel Logo einfaden

		dbra	d5,.CopyCol
		dbra	d6,.CopyMap



	*** CopperInt anhängen ***

		moveq	#4,d0
		lea	IntStruct,a1
		Exec	AddIntServer


	*** Main loop ***

.wait:		Gfx	WaitTOF

		tst.w	endit
		beq.s	.wait


	*** Remove int ***

		moveq	#4,d0
		lea	IntStruct,a1
		Exec	RemIntServer



	*** Presents einblenden ***

		bsr	FadeInLogo
		bsr	ShortDelay



	*** Wait ***


		clr	Timer

.Wait:		Gfx	WaitTOF

		addq.l	#1,Timer
		cmp.l	#MaxTimer,Timer
		beq.s	.Abort

		btst	#6,$bfe001
		bne	.Wait


	*** Ausblenden ***

.Abort:		bsr	FadeOut


	*** Intro1 verlassen ***

ExitDOS:	bsr	CloseScr


		tst.b	DarkFlag
		beq	.System

		move.w	#$0100,$dff096
		bra.s	.Exit


.System:	move.l	_GfxBase,a6
		move.l 	38(a6),$dff080		* Original Copperlist

		sub.l	a1,a1
		Gfx	LoadView
		Intui	RemakeDisplay		* Restore Display


.Exit:		move.l	_DOSBase,a1		* Close Libs
		Exec	CloseLibrary

		move.l	_GfxBase,a1		* Close Libs
		Exec	CloseLibrary

		move.l	_IntuitionBase,a1
		Last	CloseLibrary

		moveq	#0,d0			* Exit succesfully
		rts



	IFD	fjdsakl

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

	ENDC



**********************************************************************************
* File laden
* A0 = Name
* A1 = Buffer
* D0 = Grösse
**********************************************************************************

LoadFile:	movem.l	d0-d7/a0-a6,-(sp)

		move.l	d0,d6			* Size
		move.l	a1,a4

		move.l	a0,d1
		move.l	#1005,d2
		DOS	Open
		move.l	d0,d7

		bne	1$

		move.w	#$f00,$dff180


1$:		move.l	d7,d1
		move.l	a4,d2
		move.l	d6,d3
		Last	Read

		move.l	d7,d1
		Last	Close
	
		movem.l	(sp)+,d0-d7/a0-a6
		rts



*******************************************************************************
* Copper-Interrupt
*******************************************************************************

VBlankInt:	movem.l	d0-d7/a0-a6,-(a7)

		addq	#1,Cnt
		move.l	StarCnt,a1
		move	(A1),d5
		cmp	Cnt,d5
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
		moveq	#25-1,d7
LDraw:		move.l	(A1)+,(A2)+
		dbra	d7,LDraw

		addq	#1,SCnt
		cmp	#2,SCnt
		bne.s	NoStar2
		clr.w	SCnt

		addq	#1,Str
		cmp	#9,Str
		bne.s	NoStar2
		clr	Str
		lea	Star,a1
		clr.l	(A1)
NoStar2:
		cmp	#332,Cnt
		blo.s	m2	

		move	#1,endit
		bra.s	end

m2:		btst	#6,$bfe001
		bne.s	m3

		move	#1,endit
		bra.s	end

m3:		bsr	SetPages
		bsr	DrawBobs
		bsr	MoveBobs

end:		movem.l	(a7)+,d0-d7/a0-a6
		moveq	#0,d0
		rts





*******************************************************************************
* ca. 2 sek. Delay
*******************************************************************************

ShortDelay:	moveq	#100,d0
		DOS	Delay
		rts



*******************************************************************************
* Farbpalette ausblenden
*******************************************************************************


FadeOut:	moveq	#25,d2
Fade2:		move.l	d2,-(sp)
		Gfx	WaitTOF
		move.l	(sp)+,d2

		lea	ColorMap+2,a1
		moveq	#30,d4

Fade1:		move	(A1),d0			; Ist
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
		beq.s	endCR
		bhi.s	rkleiner
		sub	#$100,d5
		rts

rkleiner:	add	#$100,d5
endCR:		rts

CorrGreen:
		move	d0,d5
		move	d1,d6
		and	#$00f0,d5
		and	#$00f0,d6
		cmp	d5,d6
		beq.s	endCG
		bhi.s	gkleiner
		sub	#$0010,d5
		rts
gkleiner:	
		add	#$0010,d5
endCG:
		rts

CorrBlue:
		move	d0,d5
		move	d1,d6
		and	#$000f,d5
		and	#$000f,d6
		cmp	d5,d6
		beq.s	endCB
		bhi.s	bkleiner
		sub	#$0001,d5
		rts
bkleiner:	
		add	#$0001,d5
endCB:
		rts



*******************************************************************************
* Logo 'presents' einblenden
*******************************************************************************

FadeInLogo:	moveq	#9,d7
		lea	c5,a4

1$:		Gfx	WaitTOF

		lea	prescol+2,a5
		move	(A4)+,(A5)
		move	(A4)+,4(A5)
		move	(A4)+,8(A5)
		dbra	d7,1$

		rts



*******************************************************************************
* Bitmaps eintragen
*******************************************************************************

SetPages:	lea	bitmstr1,a0
		lea	BitmapPtr,a1
		moveq	#5-1,d7
		addq.l	#8,a0

.SetPage:	move.l	(a0),d0
		move	d0,6(a1)
		swap	d0
		move	d0,2(A1)
		addq.l	#4,a0
		addq.l	#8,a1
		dbf	d7,.SetPage

		rts





*******************************************************************************
* Der Name sagts
*******************************************************************************

MoveBobs:
		movem.l	d0-d5/a0-a2,-(sp)	; Zeiger auf Bob in A1
		move.l	boblist,a1
repeat:
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
		bne	nopause			; -1 = Pause

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



*******************************************************************************
* Bobs zeichnen
*******************************************************************************

;Bob Master Routine (c) 1987 by Chris

DrawBobs:
		movem.l	d0-d7/a0-a6,-(A7)
		move.l	boblist,a0
		lea	$dff000,a6
SearchLastBob:				;letztes Bob suchen
		tst.l	(A0)		
		beq.s	bobreconstloop
		move.l	(A0),a0
		bra.s	SearchLastBob
	
bobreconstloop:
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
		beq.s	endReconst
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
endReconst:
		tst.l	44(A0)
		beq.s	endRecLoop
		move.l	44(A0),a0
		bra	bobreconstloop
endRecLoop:		

	;Jetzt werden all Hintergruende an der neuen Koordinate gerettet
	
		move.l	boblist,a0
bobmainloop:
		moveq	#0,d0
		move	20(a0),d0
		lsl	#2,d0
		lea	BobImageList,a1
		move.l	(a1,d0.l),a1		;a1 = zeiger auf Bob
		move.l	a1,a4
		add.l	40(A0),a4		;a4 Zeiger auf Maske

		lea	bitmstr1,a2
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
		beq.s	Noanimate
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
Noanimate:
		addq	#1,50(A0)		;Speedcounter
		move	50(A0),d0
		cmp	48(a0),d0		;Limite erreicht?
		bne.s	Noanim
		clr	50(A0)
animLoop:
		tst.l	54(A0)			;animation zugelassen ?
		beq.s	Noanim
		move.l	54(A0),a1
		move	52(a0),d0
		add	d0,a1
		move	(A1),d0			;Neue BobImageNummer holen
		cmpi	#-3,d0
		beq.s	Noanim
		cmp	#-1,d0			;ende?
		bne.s	Letsanim
		clr	52(A0)			;NeuStart
		bra.s	animLoop
Letsanim:
		move	d0,20(A0)		;BobImageNummer eintragen
		addq	#2,52(a0)		;PC erhoehen
Noanim:
		tst.l	(a0)			;Letztes Bob in der Liste ?
		beq.s	endDrawBobs
		move.l	(A0),a0			;Naechstes Bob = aktuelles Bob
		bra	bobmainloop
endDrawBobs:
		movem.l	(a7)+,d0-d7/a0-a6
		rts



*******************************************************************************
* Bobliste initialisieren
*******************************************************************************

InitBobList:
		movem.l	d0-d3/a0-a1,-(A7)
		move.l	boblist,a0
BobInitLoop:
		lea	bitmstr1,a1
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
		beq.s	endInitBobs
		move.l	(A0),a0
		bra.s	BobInitLoop
endInitBobs:	
		movem.l	(a7)+,d0-d3/a0-a1
		rts



*******************************************************************************
* Decruncher
*******************************************************************************

decru:		move.l	read,a0
		move.l	lowwr,a1		
		move.l 	-(a0),a2		
		add.l 	a1,a2		
		move.l 	-(a0),d5		
		move.l 	-(a0),d0		
		eor.l 	d0,d5		
notfinished:
		lsr.l 	#1,d0
		bne.S 	notempty1
		bsr 	getnextlwd
notempty1:
		bcs.S 	bigone		
		moveq 	#8,d1	
		moveq 	#1,d3	
		lsr.l 	#1,d0
		bne.S 	notempty2
		bsr 	getnextlwd
notempty2:
		bcs.S 	dodupl	
		moveq 	#3,d1	
		clr.w 	d4	
dojmp:		
		bsr 	rdd1bits	
		move.w 	d2,d3	
		add.w 	d4,d3	
getd3chr:
		moveq 	#7,d1	
get8bits:
		lsr.l 	#1,d0
		bne.S 	notempty3
		bsr 	getnextlwd
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
		bsr 	rdd1bits
		cmp.b 	#2,d2	
		blt.S 	midjumps	
		cmp.b 	#3,d2	
		beq.S 	bigjmp	

		moveq 	#8,d1	
		bsr 	rdd1bits	
		move.w 	d2,d3	
		move.w 	#12,d1	
		jmp 	dodupl	
midjumps:
		move.w 	#9,d1	
		add.w 	d2,d1
		addq 	#2,d2
		move.w 	d2,d3	
dodupl:
		bsr 	rdd1bits	
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




*******************************************************************************
* Set Sprites and Bitplane Pointers into Copperlist
*******************************************************************************

InitCopp:	lea	plane2,a0
		move.l	#page3,d0
		bsr	SetLong

		lea	plane4,a0
		move.l	#page3,d0
		bsr	SetLong

		lea	sprites2,a0
		bsr	ClearSprites

		lea	sprites4,a0
		bsr	ClearSprites

		move.l	#Star,d0
		lea	coppspr,a0
		bsr	SetLong

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
		rts




*******************************************************************************
* Open Screen (LoRes 320x200x1)
* Result: D0 = Success (Exit if False)
*******************************************************************************

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




*******************************************************************************
* Close Screen
*******************************************************************************

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





*** Data Segment *********************************************************************


		SECTION Intro1Data,DATA_C

dostext:	dc.b	'dos.library',0
gfxtext:	dc.b	'graphics.library',0
inttext:	dc.b	'intuition.library',0
trddevice:	dc.b	'trackdisk.device',0
;;text:		dc.b	'© 1988 by LINEL Switzerland',0
text:		dc.b	'   © 1988-95 by René Straub',0
endtext:
IntName:	dc.b	"Crack Intro 1",0

bobs_file:	dc.b	"Gfx/Intro1_Bobs",0
gfx_file:	dc.b	"Gfx/Intro1_Gfx",0



bitmstr1:	dc.w	PageWidth
		dc.w	PageHeight
		dc.b	0
		dc.b	PageDepth
		dc.w	0
		dc.l	page1+(0*PageSize)+20
		dc.l	page1+(1*PageSize)+20
		dc.l	page1+(2*PageSize)+20
		dc.l	page1+(3*PageSize)+20
		dc.l	page1+(4*PageSize)+20


bitm:		dc.w	100
		dc.w	20
		dc.b	0
		dc.b	1
		dc.w	0
		dc.l	page3
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0


c5:		dc.w	$222,$222,$222
		dc.w	$322,$222,$222
		dc.w	$433,$322,$332
		dc.w	$533,$332,$333
		dc.w	$644,$433,$443
		dc.w	$744,$433,$543
		dc.w	$855,$543,$654
		dc.w	$965,$644,$754
		dc.w	$a76,$754,$865
		dc.w	$b87,$854,$965


Starlist:	dc.w	10,206,53
		dc.w	40,132,145
		dc.w	80,204,175
		dc.w	100,133,205
		dc.w	120,132,145
		dc.w	190,204,175
		dc.w	210,206,53
		dc.w	230,133,205
		dc.w	280,117,58
		dc.w	10000,0,0


StList:		dc.l	stern7
		dc.l	stern6
		dc.l	stern5
		dc.l	stern4
		dc.l	stern3
		dc.l	stern2
		dc.l	stern2
		dc.l	stern1
		dc.l	stern0



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
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0200,$0200
		dc.w	$0700,$0700
		dc.w	$0200,$0200
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000



copperl3:	dc.w	$1021,$fffe
		dc.w	$0180,$0000
		dc.w	$0100,$0000
		dc.w	$ffff,$fffe



copperl2:	dc.w	$1021,$fffe
		dc.w	$0100,$0000
		dc.w	$0180,$0000

sprites2:	dc.w	$0120,$0000
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


		dc.w	$3821,$fffe
		dc.w	$0180,$0222

		dc.w	$ffdf,$fffe
		dc.w	$0721,$fffe

		dc.w	$0180,$0000

		dc.w	$0182,$0000
		dc.w	$0100,$9200
		dc.w	$0801,$fffe

plane2:		dc.w	$00e0,$0000
		dc.w	$00e2,$0000		* Bitplanes

		dc.w	$0092,$003c
		dc.w	$0094,$00d4		* DDFStart/Stop

	;	dc.w 	$008e,$3871
	; 	dc.w 	$0090,$16c8		* DIWStart/Stop

		dc.w 	$008e,$3881
	 	dc.w 	$0090,$16c1		* DIWStart/Stop

		dc.w	$0108,$0014
		dc.w	$010a,$0014		* Modulo

		dc.w 	$0102,$0000		* BplCon0
		dc.w 	$0104,$0024		* BplCon1

		dc.w	$0b21,$fffe
		dc.w	$0182,$0eee
		dc.w	$0c21,$fffe
		dc.w	$0182,$0dde
		dc.w	$0d21,$fffe
		dc.w	$0182,$0cce
		dc.w	$0e21,$fffe
		dc.w	$0182,$0bbe
		dc.w	$0f21,$fffe
		dc.w	$0182,$0aae
		dc.w	$1021,$fffe
		dc.w	$0182,$099e
		dc.w	$1121,$fffe
		dc.w	$0182,$077e
		dc.w	$1221,$fffe
		dc.w	$0182,$055e
		dc.w	$1321,$fffe
		dc.w	$0182,$033e

		dc.w	$ffff,$fffe



copperl:	dc.w	$1021,$fffe
sprites4:	dc.w	$0120,$0000
		dc.w	$0122,$0000
		dc.w	$0124,$0000
		dc.w	$0126,$0000
		dc.w	$0128,$0000
		dc.w	$012a,$0000
		dc.w	$012c,$0000
		dc.w	$012e,$0000
		dc.w	$0130,$0000
		dc.w	$0132,$0000
coppspr:	dc.w	$0134,$0000
		dc.w	$0136,$0000
		dc.w	$0138,$0000
		dc.w	$013a,$0000
		dc.w	$013c,$0000
		dc.w	$013e,$0000

		dc.w	$1221,$fffe
		dc.w 	$008e,$3881	;71
	 	dc.w 	$0090,$16c1	;c8
		dc.w 	$0104,$0024

		dc.w 	$0092,$0030
		dc.w 	$0094,$00dc

		dc.w 	$0102,$0000
		dc.w 	$0108,20
		dc.w 	$010a,20

ColorMap:	dc.w	$0182,$0EBA
		dc.w	$0184,$0DA9
		dc.w	$0186,$0C98
		dc.w	$0188,$0B87
		dc.w	$018a,$0a76
		dc.w	$018c,$0965
		dc.w	$018e,$0854
		dc.w	$0190,$0754
		dc.w	$0192,$0643
		dc.w	$0194,$0532
		dc.w	$0196,$0421
		dc.w	$0198,$0321
		dc.w	$019a,$08c8
		dc.w	$019c,$06a6
		dc.w	$019e,$0484

fadecol:	dc.w	$01a0,$0222
		dc.w	$01a2,$0222
		dc.w	$01a4,$0222
		dc.w	$01a6,$0222
		dc.w	$01a8,$0222
		dc.w	$01aa,$0222
		dc.w	$01ac,$0222
		dc.w	$01ae,$0222

prescol:	dc.w	$01b0,$0222
		dc.w	$01b2,$0222
		dc.w	$01b4,$0222
		dc.w	$01b6,$0eef
		dc.w	$01b8,$0ddf
		dc.w	$01ba,$0ccf
		dc.w	$01bc,$0bbf
		dc.w	$01be,$0fff

BitmapPtr:	dc.w 	$00e0,$0000
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

		dc.w	$3821,$fffe
		dc.w	$0180,$0222

		dc.w	$6521,$fffe
		dc.w	$009c,$8010

		dc.w	$ffdf,$fffe
		dc.w	$0721,$fffe

		dc.w	$0180,$0000
		dc.w	$0182,$0000
		dc.w	$0100,$9200

		dc.w	$0821,$fffe

plane4:		dc.w	$00e0,$0000
		dc.w	$00e2,$0000

		dc.w	$0092,$003c
		dc.w	$0094,$00d4
		dc.w	$0b21,$fffe
		dc.w	$0182,$0eee
		dc.w	$0c21,$fffe
		dc.w	$0182,$0dde
		dc.w	$0d21,$fffe
		dc.w	$0182,$0cce
		dc.w	$0e21,$fffe
		dc.w	$0182,$0bbe
		dc.w	$0f21,$fffe
		dc.w	$0182,$0aae
		dc.w	$1021,$fffe
		dc.w	$0182,$099e
		dc.w	$1121,$fffe
		dc.w	$0182,$077e
		dc.w	$1221,$fffe
		dc.w	$0182,$055e
		dc.w	$1321,$fffe
		dc.w	$0182,$033e

		dc.w	$ffff,$fffe



BobImageList:	dc.l	bobs		;erstes bob
		dc.l	bobs+(1*BobLen)
		dc.l	bobs+(2*BobLen)
		dc.l	bobs+(3*BobLen)
		dc.l	bobs+(4*BobLen)
		dc.l	bobs+(5*BobLen)
		dc.l	bobs+(6*BobLen)
		dc.l	bobs+(7*BobLen)
		dc.l	bobs+(8*BobLen)
		dc.l	bobs+(9*BobLen)
		dc.l	bobs+(10*BobLen)
		dc.l	bobs+(11*BobLen)
		dc.l	bobs+(12*BobLen)
		dc.l	bobs+(13*BobLen)
		dc.l	bobs+(14*BobLen)
		dc.l	bobs+(15*BobLen)
		dc.l	bobs2
	

boblist:	dc.l	bob1


bob1:		dc.l	bob2		;Next Bob		0
		dc.w	96,72		;Breite,Hoehe		4
		dc.w	352,YPos	;New x,y Pos		8
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
		dc.w	4		;animSpeed		48	
		dc.w	0		;SpeedCounter		50
		dc.w	0		;animOffset		52
		dc.l	animseq1	;animProgramm		54
		dc.l	animcoord1	;Zeiger auf MoveListe	58
		dc.w	0		;PauseCounter		62
		dc.w	1		;MoveSpeed		64
		dc.w	0		;MoveCounter		66
		dc.w	1		;MoveDistX		68
		dc.w	1		;MoveDistY		70


animseq1:	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0
		dc.w	13,13,14,14,15,15,14,14,13,13,1
		dc.w	-3

animcoord1:	dc.w	-1,53,547-16+32,YPos,0,0


bob2:		dc.l	0		;Next Bob		0
		dc.w	172,50		;Breite,Hoehe		4
		dc.w	352,YPos	;New x,y Pos		8
		dc.w	-1,-1		;Old x,y Pos1		12
		dc.w	-1,-1		;Old x,y Pos2		16
		dc.w	16		;BobImageNumber		20
		dc.w	0		;BltSize		22
		dc.w	0		;Modulo			24
		dc.l	save2		;save1			26
		dc.l	0		;save2			30
		dc.w	0		;flags			34
		dc.l	0		;Laenge	einer Plane	36
		dc.l	0		;Offset to Mask		40
		dc.l	bob1		;Last Bob		44
		dc.w	4		;animSpeed		48	
		dc.w	0		;SpeedCounter		50
		dc.w	0		;animOffset		52
		dc.l	0		;animProgramm		54
		dc.l	animcoord2	;Zeiger auf MoveListe	58
		dc.w	0		;PauseCounter		62
		dc.w	1		;MoveSpeed		64
		dc.w	0		;MoveCounter		66
		dc.w	1		;MoveDistX		68
		dc.w	1		;MoveDistY		70


animcoord2:	dc.w	632-16,YPos,0,0
endit:		dc.w	0



		CNOP	0,2


o1:		dc.w	$222,$222,$222,$222,$222,$222,$222,$222
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




IntStruct:	dc.l	0,0
		dc.b	0,0
		dc.l	IntName			* Node
		dc.l	0
		dc.l	VBlankInt


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




*** BSS Segment **********************************************************************


		SECTION IntroBSS,BSS_C

_DOSBase:	ds.l	1
_GfxBase:	ds.l	1
_IntuitionBase:	ds.l	1

Window:		ds.l	1
Screen:		ds.l	1

Star:		ds.l	102
read:		ds.l	1
lowwr:		ds.l	1
DummySprite:	ds.l	2
StarCnt:	ds.l	1
Timer:		ds.l	1

SCnt:		ds.w	1
Cnt:		ds.w	1
FlipFlag:	ds.w	1
Str:		ds.w	1


PrefsBuf:	ds.b	150
RastPort:	ds.b	100

DarkFlag:	ds.b	2

page3:		ds.b	2000
bobs2:		ds.b	6600
bobs:		ds.b	82944			* Dont change order of bobs/bobs2
save2:		ds.b	5500
save1:		ds.b	4320
page1:		ds.b	5*PageSize
