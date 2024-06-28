*****************************************************************************
*                                                                           *
* INTRO 2                                 Project started  : xx.yy.1987     *
* -------                                         finished : ..........     *
*                                                                           *
* 2. Introteil zu 'Crack'                                                   *
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
*                                                                           *
*****************************************************************************


		INCLUDE "Dos.i"
		INCLUDE "Exec.i"
		INCLUDE "Intuition.i"
		INCLUDE "Graphics.i"



d:		EQU	360
pl:		EQU	14496
drawer:		EQU	363



Main:		move.w	#$20,$dff1dc		* PAL-Screen
		move.w	#$0100,$dff096		* Dunkel
		move	#$8400,$dff096		* Blitter Nasty
		move.l	#copperl2,$dff080	* Ganz dunkel

		lea	dostext,a1
		Exec	OldOpenLibrary
		move.l	d0,_DOSBase

		lea	gfxtext,a1
		Exec	OldOpenLibrary
		move.l	d0,_GfxBase

		lea	inttext,a1
		Last	OldOpenLibrary
		move.l	d0,_IntuitionBase	* Open Libs


		move.l	#text,textCounter
		move.l	#CopyListe,CopyCnt	* Init


		bsr	LoadAll			* Files laden


		lea	RastPort,a1
		Gfx	InitRastPort

		lea	RastPort,a1
		move.l	#BitmStr0,4(A1)		* Create Rastport

		move.l	#420,d0
		moveq	#10,d1
		Last	Move

		lea	LINELtext,a0
		move.l	#EndLINELtext-LINELtext-1,d0
		Last	Text			* Print Text


		move.l	BobList,a1
.loop:		move.l	58(A1),a2
		move.l	(A2),8(A1)
		addq.l	#4,58(A1)
		move.l	(A1),a1
		cmp.l	#0,a1

		bne.s	.loop			* Irgendwas mit BobListe anstellen



		clr.w	FlipFlag
		bsr	InitBobList		* BobListe initialisieren
		bsr	InitSpr			* Sprites setzen
		bsr	InitCopper		* Copperliste erstellen
		bsr	InitSource

		move.l	#copperl,$dff080	* Hauptcopperliste


		move	#$83a0,$dff096
		bsr	CopyToScr		* Bild aufbauen

		moveq	#4,d0
		lea	IntStruct,a1
		Exec	AddIntServer		* CopperInt anhängen


		tst.w	SongFlag
		beq	.NoSong

		jsr	$20004
.NoSong:


.Wait:		tst	sdf
		bne.s	.NoNew

		cmp.l	#1050,Counter
		bls.s	.NoNew


		tst.w	SongFlag
		beq	.NoSong2

		jsr	$20008
.NoSong2:

		move	#1,sdf

.NoNew:		Gfx	WaitTOF

		btst	#6,$bfe001
		beq.s	.Break

		tst	EndIt
		beq.s	.Wait


.Break:		moveq	#4,d0
		lea	IntStruct,a1
		Exec	RemIntServer

		bsr	DelScr			* Bildschirm ausblenden

		move.l	_GfxBase,a6
		move.l 	38(a6),$dff080

		tst.w	SongFlag
		beq	.NoSong3

		jsr	$20014
.NoSong3:

		bsr	FreeSong

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





VBlankInt:	movem.l	d0-d7/a0-a6,-(a7)

		cmp.l	#465,Counter
		bls.s	.NoSound

		tst.w	SongFlag
		beq	.NoSong

		jsr	$2000c
.NoSong:

.NoSound:	tst	EndIt
		bne	End

		cmp.l	#10420,Counter
		bhi.s	End22

		btst	#6,$bfe001
		bne.s	NoExit

		cmp.l	#900,Counter
		bls.s	NoExit

End22:		move	#1,EndIt
		bra	EndVBlank

NoExit:		bsr	Liane

		lea	BitmStr1,a0
		tst	FlipFlag
		beq.s	NoFlip

		lea	BitmStr2,a0

NoFlip:		lea	BitmapPtr,a1
		addq.l	#8,a0
		moveq	#5-1,d7

page_loop:	move.l	(a0),d0
		move	d0,6(a1)
		swap	d0
		move	d0,2(A1)
		addq	#4,a0
		addq	#8,a1
		dbf	d7,page_loop

		lea	bob4,a1
		cmp	#378,8(A1)
		bne.s	notleft
		move	#24,20(A1)

notleft:	bsr	DrawBobs
		bsr	MoveBobs

		cmp.l	#900,Counter
		bhi.s	NoFl
		not	FlipFlag

NoFl:		cmp.l	#900,Counter2
		blo.s	EndVBlank

		bsr	Print
		bsr	CopyScroll

EndVBlank:	addq.l	#1,Counter
		addq.l	#1,Counter2
		cmp.l	#800,Counter2
		bne.s	End

		move.l	#bob4,BobList
		bsr	InitBobList

End:		movem.l	(a7)+,d0-d7/a0-a6

		moveq	#0,d0
		rts




Liane:		lea	Sprite1,a1
		lea	bob4,a2
		move	8(A2),d0

		add.w	#4,d0


		cmp	#378,d0
		bne.s	noto

		sub	#20,d0

noto:		sub	#246,d0

		btst	#0,d0
		bne.s	not0bit

		bclr	#0,3(A1)
		bra.s	not1bit

not0bit:	bset	#0,3(A1)
not1bit:	lsr	#1,d0
		move.b	d0,1(A1)
		move	10(A2),d0
 		add	#45+14,d0
		cmp	#160,d0
		ble.s	ok2345
		move	#160,d0

ok2345:		move.b	d0,2(A1)
		rts




InitSpr:	movem.l	d0-d7/a0-a6,-(sp)

		lea	copperl,a1
		lea	SprList,a2

		moveq	#8-1,d6

.ispr:		move.l	(A2)+,d0
		move	d0,6(A1)
		swap	d0
		move	d0,2(A1)
		add.l	#8,a1
		dbf	d6,.ispr


		lea	Sprite1,a0
		move	#200-1,d0
1$:		move.l	#$28003000,(a0)+
		dbf	d0,1$
	
		movem.l	(sp)+,d0-d7/a0-a6
		rts
	


*******************************************************************************
* Files laden (Grafik, Bobs, 'Crack'-Signet, evtl. Song)
*******************************************************************************

LoadAll:	clr.w	SongFlag

	;	move.l	#512*220+16,d0
	;	lea	$20000-8,a1
	;	Exec	AllocAbs		* Try to allocate Mem at $20000
						* for Song and FX
	;	tst.l	d0
	;	beq.s	.NoMem

1$:	;	move.w	#$fff,$dff180
	;	btst	#6,$bfe001
	;	bne	1$

	;	lea	Song_File,a0
	;	lea	$20000,a1
	;	move.l	#512*220,d0
	;	bsr	LoadFile

	;	move.w	#-1,SongFlag


.NoMem:		lea	Gfx_File,a0
		lea	bobs,a1
		move.l	#512*90,d0
		bsr	LoadFile

		bsr	SetupPic


		lea	Bobs_File,a0
		lea	bobs,a1
		move.l	#512*58,d0
		bsr	LoadFile

		move.l	#bobs,lowwr
		move.l	#bobs+29480,read
		bsr	decru		; BOB's laden und decrunchen


		lea	Gfx2_File,a0
		lea	pic,a1
		move.l	#512*10,d0
		bsr	LoadFile

		rts



*******************************************************************************
* Speicher für Song freigeben (falls reserviert)
*******************************************************************************

FreeSong:	tst.w	SongFlag
		beq	.End


		move.l	#512*220,d0
		lea	$20000,a1
		Exec	FreeMem

.End:		rts





*******************************************************************************
* Bildschirmseiten aufbauen. Page1 löschen, Grafik nach Page2 kopieren
*******************************************************************************

SetupPic:	lea	bobs,a0
		lea	page2,a1
		lea	page1,a2
		moveq	#4,d5

.copyplane:	move	#230-1,d6

.copy:		clr.l	(A1)+
		clr.l	(A1)+
		clr.l	(A2)+
		clr.l	(A2)+

		moveq	#40/4-1,d7
.copyline:	move.l	(A0)+,(A1)+
		clr.l	(A2)+
		dbra	d7,.copyline

		dbra	d6,.copy

		add.l	#pl-11040,a1		* Next Plane
		add.l	#pl-11040,a2

		dbra	d5,.copyplane

		lea	bobs+46000,a0
		lea	copcol+2,a2
		moveq	#32-1,d7

.cm:		move.w	(a0)+,(a2)
		addq.l	#4,a2
		dbf	d7,.cm	

		rts



*******************************************************************************
* Bildschirm linienweise aufbauen. Page2->Page1
*******************************************************************************

CopyToScr:	move	#206,d7			* Zeile unten
		moveq	#1,d6			* Zeile oben

		moveq	#103,d5			* 104 Durchläufe
		clr.w	FlipFlag

.copy2:		tst.w	FlipFlag
		bne.s	.NoWait2

		Gfx	WaitTOF

.NoWait2:	not.w	FlipFlag

		move	d7,d0
		bsr	CopyLine2

		move	d6,d0
		bsr	CopyLine2		* Zeilen kopieren

		addq	#2,d6
		subq	#2,d7

		dbra	d5,.copy2

		rts





*******************************************************************************
* Zeile von Page2 nach Page1 kopieren
* D0 = Zeile
*******************************************************************************

CopyLine2:	movem.l	d0/d7/a1-a2,-(sp)

		mulu	#48,d0
		lea	page1+(2*pl),a1
		lea	page2+(2*pl),a2
		add.l	d0,a1
		add.l	d0,a2			; Anfang

		moveq	#12-1,d7

.CopyLine:	move.l	-(2*pl)(a2),-(2*pl)(a1)
		move.l	-(1*pl)(a2),-(1*pl)(a1)
		move.l	 (1*pl)(a2),(1*pl)(a1)
		move.l	 (2*pl)(a2),(2*pl)(a1)
		move.l	(a2)+,(a1)+

		dbra	d7,.CopyLine

		movem.l	(sp)+,d0/d7/a1-a2
		rts
	



*******************************************************************************
* Bildschirm abblenden (linienweise)
*******************************************************************************

DelScr:		clr.w	FlipFlag
		move.w	#206,d7
		moveq	#1,d6
		moveq	#103,d5

.Delete:	tst.w	FlipFlag
		bne.s	.DontWait

		Gfx	WaitTOF

.DontWait:	not.w	FlipFlag	

		move.w	d6,d0
		bsr	DelLine2
		move.w	d7,d0
		bsr	DelLine2	


		tst.w	SongFlag
		beq	.NoSong

		tst	$20000+24
		beq.s	.NoMoreSub
		subq	#1,$20000+24		* Song ausblenden
.NoMoreSub:
.NoSong:
		addq	#2,d6
		subq	#2,d7
		dbra	d5,.Delete

		rts




*******************************************************************************
* Linie löschen
*******************************************************************************

DelLine2:	movem.l	d0/d7/a1-a2,-(sp)

		mulu	#48,d0
		lea	page1+(2*pl),a1
		lea	page2+(2*pl),a2
		add.l	d0,a1
		add.l	d0,a2
		moveq	#12-1,d7

.ClearLine:	clr.l	-(2*pl)(a2)
		clr.l	-pl(a2)
		clr.l	pl(a2)
		clr.l	(2*pl)(a2)
		clr.l	(a2)+

		clr.l	-(2*pl)(a1)
		clr.l	-pl(a1)
		clr.l	pl(a1)
		clr.l	(2*pl)(a1)
		clr.l	(a1)+

		dbf	d7,.ClearLine

		movem.l	(sp)+,d0/d7/a1-a2
		rts





*******************************************************************************
* Set Sprites and Bitplane Pointers into Copperlist
*******************************************************************************

InitCopper:	lea	plane2,a0
		move.l	#page3,d0
		bsr	SetLong

		lea	BitmStr1,a0
	;	tst.w	FlipFlag
	;	beq.s	.NoFlip

	;	lea	BitmStr2,a0

.NoFlip:	lea	BitmapPtr,a1
		addq.l	#8,a0
		moveq	#5-1,d7

.page_loop:	move.l	(a0),d0
		move	d0,6(a1)
		swap	d0
		move	d0,2(A1)
		addq	#4,a0
		addq	#8,a1
		dbf	d7,.page_loop

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




*******************************************************************************
* Bobs zeichnen
*******************************************************************************

DrawBobs:	movem.l	d0-d7/a0-a6,-(A7)
		move.l	BobList,a0
		lea	$dff000,a6
SearchLastBob:				;letztes Bob suchen
		tst.l	(A0)		
		beq.s	BobReconstLoop
		move.l	(A0),a0
		bra.s	SearchLastBob
	
BobReconstLoop:
		lea	BitmStr1,a2
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
				;a2 Zeiger auf Unsichtbare BitmStr
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
		bra	BobReconstLoop
EndRecLoop:		
		move.l	Counter,d3
		cmp	#drawer+2,d3
		blo	notr
		cmp	#drawer+73,d3
		bgt	notr

		move.l	CopyCnt,a2
		move	(A2),d3
		move	d3,d4
		mulu	#18,d3
		mulu	#48,d4

		lea	pic,a1
		lea	page2+(48*123)+18,a2
		add.l	d3,a1
		add.l	d4,a2

		moveq	#4,d6
		tst	FlipFlag
		bne.s	Repeatit
		lea	page1+(48*123)+18,a2
		add.l	d4,a2
		addq.l	#2,CopyCnt
Repeatit:
		btst	#14,2(A6)
		bne.s	Repeatit
	
		clr	$64(A6)			; Modulo A
		move	#30,$66(a6)		; Modulo D
		move.l	a2,$54(A6)		; Ziel D
		move.l	a1,$50(A6)		; Source A
		move	#$9f0,$40(A6)		; BlitterMode
		clr	$42(A6)
		move.l	#-1,$44(A6)
		move	#%0000000001001001,$dff058
		add.l	#pl,a2		; Page1
		add.l	#648,a1		; Pic
		dbra	d6,Repeatit
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

		lea	BitmStr1,a2
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
		addq	#1,50(A0)		;SpeedCounter
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
		bra	BobMainLoop
EndDrawBobs:
		movem.l	(a7)+,d0-d7/a0-a6
		rts



*******************************************************************************
* BobListe initialisieren
*******************************************************************************

InitBobList:
		movem.l	d0-d3/a0-a1,-(A7)
		move.l	BobList,a0
BobInitLoop:
		lea	BitmStr1,a1
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



*******************************************************************************
* Der Name sagts
*******************************************************************************

MoveBobs:
		movem.l	d0-d5/a0-a2,-(sp)	; Zeiger auf Bob in A1

		move.l	BobList,a1
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
		bne	NoPause			; -1 = Pause

		addq.l	#4,58(A1)		; Zeiger erhoehen
		move	2(A3),62(A1)		; Pause Zaehler setzen
NoPause:
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
		bne	Repeat			; Wiederholen bis alle bewegt

		movem.l	(sp)+,d0-d5/a0-a2
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





InitSource:	movem.l	d0-d7/a0-a6,-(sp)

		lea	source,a0
		move.w	#400-1,d0
1$:		move.b	#-1,(a0)+
		dbf	d0,1$

		movem.l	(sp)+,d0-d7/a0-a6
		rts






; COPY

CopyScroll:	lea	$dff000,a6
		move.l	#source,a2
		move.l	#sourcemask,a3
		moveq	#4,d5
		move.l	#page1+(48*62)+18,a1

		tst	FlipFlag
		beq.s	BlitWait5
		move.l	#page2+(48*62)+18,a1
BlitWait5:
		btst	#14,2(A6)
		bne.s	BlitWait5

		move.l	a1,$48(A6)		;Source c (background)
		move.l	a2,$4c(A6)		;Source b (data)
		move.l	a3,$50(A6)		;Source a (Maske)
		move.l	a1,$54(A6)		;Dest C
		move	#$f000,$42(a6)			;BltCon1
		move	#$ffca,$40(a6)		;BltCon0
		move	#30,$66(A6)		;Modulo Dest
		move	#30,$60(a6)		;Modulo c
		move	#0,$64(a6)
		move	#2,$62(A6)
		move.l	#$ffffffff,$44(a6)
		move	#%0000010100001001,$58(a6)
		add.l	#pl,a1
		add.l	#400,a2
		dbra	d5,BlitWait5
BlitWait7:
		btst	#14,2(A6)
		bne.s	BlitWait7
		rts



; SCROLL

scroll:		lea	$dff000,a6
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
		move	#$d9f0,$40(a6)		;BltCon0
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

Print:		tst	Timer
		beq.s	oktime
		subq	#1,Timer
		rts

oktime:		bsr	scroll
		add	#1,TCnt
		cmp	#1,TCnt
		bgt.s	p2
		rts

p2:		clr	TCnt
		move.l	#source+(18*5)+26,a0
		move.l	textCounter,a1
		tst.b	(A1)
		bne.s	ok34
		move.l	#text,textCounter

ok34:		move.l	textCounter,a1
		cmp.b	#-1,(A1)
		bne.s	notp

		clr.l	d2
		move.b	1(A1),d2
		move	d2,Timer
		addq.l	#2,textCounter
		rts

notp:		bsr	WriteLetter
		addq.l	#1,textCounter
		rts




* a0=Zeiger in Bitplane
* a1=Zeiger auf Text

WriteLetter:	moveq	#0,d4
		lea	font,a3
		move.b	(A1),d4
		sub	#' ',d4
		mulu	#10,d4
		add.l	d4,a3

		moveq	#10-1,d7

.writechar:	move.b	(A3)+,d3
		or.b	d3,(A0)
		or.b	d3,400(A0)
		or.b	d3,800(A0)
		or.b	d3,1200(A0)
		or.b	d3,1600(A0)

		add.l	#20,a0
		dbf	d7,.writechar
		rts





		SECTION Intro2Data,DATA_C

dostext:	dc.b	'dos.library',0
gfxtext:	dc.b	'graphics.library',0
inttext:	dc.b	'intuition.library',0
trddevice:	dc.b	'trackdisk.device',0

;;LINELtext:	dc.b	'© 1988 by LINEL Switzerland',0
LINELtext:	dc.b	'   © 1988-95 by René Straub',0
EndLINELtext:
IntName:	dc.b	"Crack Intro 2",0

Gfx_File:	dc.b	"Gfx/Intro2_Gfx",0
Gfx2_File:	dc.b	"Gfx/Intro2_Gfx2",0
Bobs_File:	dc.b	"Gfx/Intro2_Bobs",0
Song_File:	dc.b	"Sound/Intro2_Song",0

		even

textCounter:	dc.l	text

text:		dc.b	'  A PROGRAM BY    ',-1,40
		dc.b	'LINEL SWITZERLAND ',-1,40
		dc.b	'                  '
		DC.B	'   PROGRAMMING:   ',-1,40
		DC.B	'     R.STRAUB     ',-1,40
		DC.B	'    CH.HALLER     ',-1,40
		DC.B	'    CH.WEBER      ',-1,40
		dc.b	'                  '
		DC.B	'     GRAPHIC:     ',-1,40
		DC.B	'   O.PETERMANN    ',-1,40
		DC.B	'    M.GRIMMER     ',-1,40
		DC.B	'    R.STRAUB      ',-1,40
		dc.b	'                  '
		DC.B	'      MUSIC:      ',-1,40
		DC.B	'   H.MELCHER      ',-1,40
		dc.b	'                  '
		DC.B	'      SOUND:      ',-1,40
		dc.b	'   W.TRUMLER      ',-1,40
		dc.b	'                  '
		DC.B	'     CONCEPT:     ',-1,40
		DC.B	'    R.STRAUB      ',-1,40
		DC.B	'    M.GRIMMER     ',-1,40
		dc.b	'                  '
		dc.b	'     LEVELS:      ',-1,40
		DC.B	'   RETO STRAUB    ',-1,40
		DC.B	'   RENE STRAUB    ',-1,40
		dc.b	'                  '
		DC.B	'    STARRING:     ',-1,40
		DC.B	'  HERBIE STONE    ',-1,80
		dc.b	'                  '
		dc.b	'                  ',0





		CNOP	0,2

BobImageList:	dc.l	bobs				* erstes bob
		dc.l	bobs+(1*3456)
		dc.l	bobs+(2*3456)
		dc.l	bobs+(3*3456)
		dc.l	bobs+(4*3456)
		dc.l	bobs+(5*3456)
		dc.l	bobs+(6*3456)
		dc.l	bobs+(7*3456)
		dc.l	bobs+(8*3456)
		dc.l	bobs+(9*3456)
		dc.l	bobs+(10*3456)
		dc.l	bobs+(11*3456)
		dc.l	bobs+(12*3456)
		dc.l	bobs+(13*3456)

		dc.l	bobs+(14*3456)
		dc.l	bobs+(15*3456)
		dc.l	bobs+(16*3456)
		dc.l	bobs+(17*3456)
		dc.l	bobs+(18*3456)
		dc.l	bobs+(19*3456)
		dc.l	bobs+(20*3456)
		dc.l	bobs+(21*3456)
		dc.l	bobs+(22*3456)
		dc.l	bobs+(23*3456)

clear:		dc.l	bobs+(24*3456)
		dc.l	bobs+(25*3456)


BobList:	dc.l	bob1

bob1:		dc.l	bob2		;Next Bob		0
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


Animseq1:	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.w	0,1,2,3,4,13				* Laufen
		dc.w	14,15,16,17,18,16
		dc.w	14,14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	14,14,14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	14,14,15,16,17,18,16
		dc.w	14,15,16,17,18,16
		dc.w	14,14,14,15,16,17,18,16			* Haemmern
		dc.w	13,0,1,2,3,4,5,6,7,8,9,10,11,12		* Laufen
		dc.w	0,1,2
		dc.w	19,20,21,22
		dc.w	22,22,22,22,22,22,22,22,-2
		dc.w	-3					* Jump (Oh, Yeah !!!!)


Animcoord1:	dc.w	320,104
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


bob2:		dc.l	bob3		;Next Bob		0
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


Animseq2:	dc.w	3,4,5,6,7,8,9,10,11,12
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

Animcoord2:	dc.w	320,104
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

bob3:		dc.l	0		;Next Bob		0
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


Animcoord3:	dc.w	320,103
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
	
Animseq3:	dc.w	1,2,3,4,5,6,7,8,9,10,11,12
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
		dc.w	1		;MoveDistX		68
		dc.w	1		;MoveDistY		70

Animcoord4:	dc.w	-2,366+d,2
		dc.w	-2,360+d,6
		dc.w	-2,354+d,8
		dc.w	-2,348+d,10
		dc.w	-2,342+d,12
		dc.w	-2,336+d,14
		dc.w	-2,330+d,16
		dc.w	-2,324+d,18
		dc.w	-2,318+d,20
		dc.w	-2,312+d,22
		dc.w	-2,306+d,24
		dc.w	-2,300+d,26
		dc.w	-2,294+d,28
		dc.w	-2,288+d,30
		dc.w	-2,282+d,32
		dc.w	-2,276+d,34
		dc.w	-2,270+d,36
		dc.w	-2,264+d,38
		dc.w	-2,258+d,40
		dc.w	-2,252+d,42
		dc.w	-2,246+d,43
		dc.w	-2,240+d,44
		dc.w	-2,234+d,46
		dc.w	-2,228+d,48
		dc.w	-2,222+d,50
		dc.w	-2,216+d,52
		dc.w	-2,210+d,53
		dc.w	-2,204+d,54
		dc.w	-2,198+d,56
		dc.w	-2,192+d,58
		dc.w	-2,186+d,59
		dc.w	-2,180+d,60
		dc.w	-2,174+d,61
		dc.w	-2,168+d,62
		dc.w	-2,162+d,63
		dc.w	-2,156+d,64
		dc.w	-2,150+d,66
		dc.w	-2,144+d,68
		dc.w	-2,138+d,70
		dc.w	-2,132+d,71
		dc.w	-2,126+d,72
		dc.w	-2,120+d,73
		dc.w	-2,114+d,74
		dc.w	-2,108+d,76
		dc.w	-2,102+d,77
		dc.w	-2,96+d,78
		dc.w	-2,90+d,78
		dc.w	-2,84+d,79
		dc.w	-2,78+d,79
		dc.w	-2,72+d,80
		dc.w	-2,66+d,80
		dc.w	-2,58+d,81
		dc.w	-2,52+d,81
		dc.w	-2,46+d,82
		dc.w	-2,40+d,82
		dc.w	-2,34+d,83
		dc.w	-2,28+d,83
		dc.w	-2,22+d,84
		dc.w	-2,16+d,84
		dc.w	-2,d+10,85
		dc.w	-2,d+5,85
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,d+5,86
		dc.w	-2,365,88
		dc.w	-2,365,91
		dc.w	-2,365,98
		dc.w	-2,365,106
		dc.w	-2,365,115
		dc.w	-2,365,125
		dc.w	-2,365,136
		dc.w	-2,365,148
		dc.w	-2,365,161
		dc.w	-2,365,175
		dc.w	-2,365,203
		dc.w	0,0



font:		REPT	140
		 dc.b 0
		ENDR
		dc.b 0,0,0,0,0,0,0,0,0,8
		dc.b 0,0,0,0,0,0,0,0,0,0
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
		dc.b 0,0,0,8,0,0,0,8,0,0
		REPT 60
		 dc.b	0
		ENDR
		dc.b $00,$3E,$22,$22,$22,$3E,$22,$22,$22,$22
		dc.b $00,$28,$24,$22,$24,$28,$24,$22,$24,$28
		dc.b $00,$02,$04,$08,$10,$20,$10,$08,$04,$02
		dc.b $00,$30,$28,$24,$22,$22,$22,$24,$28,$30
		dc.b $00,$06,$08,$10,$20,$3C,$20,$10,$08,$06
		dc.b $00,$3E,$10,$10,$10,$38,$10,$10,$10,$10
		dc.b $00,$06,$0A,$10,$20,$26,$22,$12,$0A,$06
		dc.b $00,$22,$22,$22,$3E,$22,$22,$22,$22,$22
		dc.b $00,$1C,$08,$08,$08,$08,$08,$08,$08,$1C
		dc.b $00,$04,$04,$04,$04,$04,$04,$04,$24,$3E
		dc.b $00,$22,$22,$24,$28,$30,$28,$24,$22,$22
		dc.b $00,$10,$10,$10,$10,$10,$10,$10,$10,$3E
		dc.b $00,$22,$36,$2A,$22,$22,$22,$22,$22,$22
		dc.b $00,$22,$32,$2A,$26,$22,$22,$22,$22,$22
		dc.b $00,$3E,$22,$22,$22,$22,$22,$22,$22,$3E
		dc.b $00,$30,$28,$24,$22,$24,$28,$30,$20,$20
		dc.b $00,$3E,$22,$22,$22,$22,$22,$22,$24,$3A
		dc.b $00,$30,$28,$24,$22,$24,$28,$30,$28,$24
		dc.b $00,$1E,$20,$20,$10,$08,$04,$02,$02,$3C
		dc.b $00,$3E,$08,$08,$08,$08,$08,$08,$08,$08
		dc.b $00,$22,$22,$22,$22,$22,$22,$22,$22,$3E
		dc.b $00,$22,$22,$22,$22,$22,$22,$22,$14,$08
		dc.b $00,$22,$22,$22,$22,$22,$22,$2A,$2A,$14
		dc.b $00,$22,$22,$22,$14,$08,$14,$22,$22,$22
		dc.b $00,$22,$22,$14,$08,$08,$08,$08,$08,$08
		dc.b $00,$3C,$02,$02,$04,$08,$10,$20,$20,$1E


sourcemask:	INCBIN	"maske"


		CNOP	0,2

CopyCnt:	dc.l	CopyListe

CopyListe:	dc.w	1,34
		dc.w	2,33
		dc.w	4,31
		dc.w	6,29
		dc.w	8,27
		dc.w	10,25
		dc.w	12,23
		dc.w	14,21
		dc.w	16,19
		dc.w	18,17
		dc.w	20,15
		dc.w	22,13
		dc.w	24,11
		dc.w	26,9
		dc.w	28,7
		dc.w	30,5
		dc.w	32,3
		dc.w	34,1


SprList:	dc.l	Sprite2
		dc.l	Sprite2
		dc.l	Sprite2
		dc.l	Sprite2
		dc.l	Sprite1
		dc.l	Sprite2
		dc.l	Sprite2
		dc.l	Sprite2


IntStruct:	dc.l	0,0
		dc.b	0,0
		dc.l	IntName			* Node
		dc.l	0
		dc.l	VBlankInt



copperl2:	dc.w	$1021,$fffe
		dc.w	$0180,$0000
		dc.w	$0096,$0120
		dc.w	$ffff,$fffe


copperl:	dc.w	$1021,$fffe
sprites1:	dc.w	$0120,$0000
		dc.w	$0122,$0000
		dc.w	$0124,$0000
		dc.w	$0126,$0000
		dc.w	$0128,$0000
		dc.w	$012a,$0000
		dc.w	$012c,$0000
		dc.w	$012e,$0000

copspr:		dc.w	$0130,$0000
		dc.w	$0132,$0000
		dc.w	$0134,$0000
		dc.w	$0136,$0000
		dc.w	$0138,$0000
		dc.w	$013a,$0000
		dc.w	$013c,$0000
		dc.w	$013e,$0000

		dc.w	$0c01,$fffe
	;	dc.w	$009c,$8010

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

		dc.w 	$008e,$3881
 		dc.w 	$0090,$14c1
		dc.w 	$0092,$0038
		dc.w 	$0094,$00d0
		dc.w 	$0104,$0024

		dc.w 	$0102,$0000
		dc.w 	$0108,$0008
		dc.w 	$010a,$0008

copcol:		dc.w	$0180,$0000
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
		dc.w	$019a,$0000
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
		dc.w	$01b4,$0000
		dc.w	$01b6,$0000
		dc.w	$01b8,$0000
		dc.w	$01ba,$0000
		dc.w	$01bc,$0000
		dc.w	$01be,$0000

		dc.w	$0100,$5200

		dc.w	$2021,$fffe
		dc.w	$01ba,$000f
		dc.w	$3821,$fffe
		dc.w	$0180,$0222
		dc.w	$4021,$fffe
		dc.w	$01ba,$000e
		dc.w	$5821,$fffe
		dc.w	$01ba,$000d
		dc.w	$6021,$fffe
		dc.w	$01ba,$000c

		dc.w	$6f21,$fffe

		dc.w	$009c,$8010


		dc.w	$7021,$fffe
		dc.w	$01ba,$000b
		dc.w	$7121,$fffe
		dc.w	$7221,$fffe
		dc.w	$7321,$fffe
		dc.w	$7421,$fffe
		dc.w	$7521,$fffe
		dc.w	$7521,$fffe
		dc.w	$7621,$fffe
		dc.w	$01be,$0950
		dc.w	$7721,$fffe
		dc.w	$8021,$fffe
		dc.w	$01ba,$000a
		dc.w	$9021,$fffe
		dc.w	$01ba,$0009
		dc.w	$a021,$fffe
		dc.w	$01ba,$0008
		dc.w	$b021,$fffe
		dc.w	$01ba,$0007
		dc.w	$c021,$fffe
		dc.w	$01ba,$0006
		dc.w	$d021,$fffe
		dc.w	$01ba,$0005
		dc.w	$e021,$fffe
		dc.w	$01ba,$0004
		dc.w	$6021,$fffe
		dc.w	$01ba,$0003
		dc.w	$ffdf,$fffe
		dc.w	$0711,$fffe
		dc.w	$0180,$0000
		dc.w	$0182,$0000
		dc.w	$0100,$9200
		dc.w	$0801,$fffe
		dc.w	$0108,$0000
		dc.w	$010a,$0000

plane2:		dc.w	$00e0,$0000
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


BitmStr0:	dc.w	80
		dc.w	20
		dc.b	0
		dc.b	1
		dc.w	0
		dc.l	page3
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0

BitmStr1:	dc.w	48
		dc.w	230
		dc.b	0
		dc.b	5
		dc.w	0
		dc.l	page1+(0*pl)+8
		dc.l	page1+(1*pl)+8
		dc.l	page1+(2*pl)+8
		dc.l	page1+(3*pl)+8
		dc.l	page1+(4*pl)+8

BitmStr2:	dc.w	48
		dc.w	230
		dc.b	0
		dc.b	5
		dc.w	0
		dc.l	page2+(0*pl)+8
		dc.l	page2+(1*pl)+8
		dc.l	page2+(2*pl)+8
		dc.l	page2+(3*pl)+8
		dc.l	page2+(4*pl)+8




		SECTION IntroBSS,BSS_C

_DOSBase:	ds.l	1
_GfxBase:	ds.l	1
_IntuitionBase:	ds.l	1

IOReq:		ds.l	20
MsgPort:	ds.l	8
DummySprite:	ds.l	2
Sprite1:	ds.l	300
Sprite2:	ds.l	10
Counter:	ds.l	1
Counter2:	ds.l	1
read:		ds.l	1
lowwr:		ds.l	1

FlipFlag:	ds.w	1
TCnt:		ds.w	1
Timer:		ds.w	1
EndIt:		ds.w	1
SongFlag:	ds.w	1
sdf:		ds.w	1

RastPort:	ds.b	100

page3:		ds.b	2000
save6:		ds.b	3600
save5:		ds.b	3600
save4:		ds.b	3600
save3:		ds.b	3600
save2:		ds.b	3600
save1:		ds.b	3600
bobs:		ds.b	86800
pic:		ds.b	8000
page1:		ds.b	5*pl
page2:		ds.b	5*pl
source:		ds.b	2000

