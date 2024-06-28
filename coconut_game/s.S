

coli    = 0		;Kollsion ein/aus
watch   = 0		;Kollisionsmap anschauen/ein/aus
seetime = 0		;Timing anschauen ein/aus
Game    = 0		;Demo oder Game

l1   = 4788		;laenge eines Herbies
l2   = 1680		;laenge eines Wurmes
l3   =  384		;laenge der Kokosnuss
Bobs = $1b000		;hier sind die Herbies
worm = Bobs+[26*l1]	;hier sind die Wuermer
Nut  = worm+[7*l2]	;hier ist die Nuss (nicht Ich !!!)
picture = Nut+[2*l3]	;hierhin muss das Hintergrund Bild(320*256)
save1 = picture+52000
save2 = save1+l1
save3 = save2+l1
save4 = save3+l2
save5 = save4+l2
save6 = save5+l3
page1 = save6+l3

KollisionsPlane = $19000

;page1 = $78000-[51200*2]-6400		
page2 = page1 + 51200 +3200

o:
	movem.l	d1-d7/a0-a6,-(A7)
	bra.s	Start

	dc.b	'Crack Coconut-Game.Written 1987 by'
	dc.b	'Christian H(i)aller, Graphics by Orlando'
	dc.b	'© 1987 by Linel '


start:
	move.l	4,a6
	lea	GfxLib,a1
	jsr	-408(A6)
	move.l	d0,GfxBase
	lea	ColorMap,a0
	lea	ColorBuffer,a1
	moveq	#31,d7
Colorm:
	move	(a0)+,(A1)+
	dbf	d7,Colorm
	
	move	#0,Bob1+8		;start x fuer herbie
	move	#123,Bob1+10		;start y
	clr	Bob1+20			;start Image
	clr	AnimCounter
	clr	WaitCounter
	clr	HupfOffset

	clr	NutCounter		;Nusszaehler
	clr	JumpLock		;SteuerSperre loeschen
	clr	GameLock		
	move	#-1,ColorSum
	lea	Picture,a0
	lea	BitMstr1,a1
	add.l	#8,a1
	moveq	#4,d7
m1:	move.l	(A1)+,a2

	move	#2559,d6
m2:
	move.l	(A0)+,(a2)+
	dbf	d6,m2
	dbf	d7,m1

	lea	Picture,a0
	lea	BitMstr2,a1
	add.l	#8,a1
	moveq	#4,d7
m3:	move.l	(A1)+,a2

	move	#2559,d6
m4:
	move.l	(A0)+,(a2)+
	dbf	d6,m4
	dbf	d7,m3

	move	#$8010,$dff09a		;Copper Interrupt
	move	#$8400,$dff096		;Blitter Nasty
	move	#$0020,$dff096		;Sprites aus
	
	move.l	#copperl,$dff080

	clr	FlipFlag		;fuer page-flipping
	bsr	InitBobList
	move.l	$6c,VBlankveq		;Game starten
	move.l	#VBlankInt,$6c	
wait:
	tst	ColorSum		;enthaelt die Summe aller 
					;Farbwerte
	beq	EndWait			;wenn 0 -> fertig 
	cmp.b	#$7f,$bfec01
	bne	Wait
EndWait:
	move.l	VBlankVeq,$6c		;Game stoppen
	tst	GameLock
	beq	Ende
	move.l	#$20000,d0
subl:
	sub.l	#1,d0
	bne	subl
	bra	start

Ende:
	move.l	GfxBase,a0
	move.l	38(A0),$dff080
	move	NutCounter,d0		;Anzahl gefangener Nuesse
	ext.l	d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts

FadeOut:				;verdunkelt jeder Wert der
					;Colormap um eine Stufe
	lea	ColorBuffer,a0
	clr.l	d1
	moveq	#31,d7
FadeLoop:
	move	(a0),d0
	bsr	FadeCol
	move	d0,(A0)+
	add	d0,d1			;Summe der Farben zusammenzaehlen
	dbf	d7,FadeLoop
	rts

FadeCol:
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

		



GfxBase:
	dc.l	0
GfxLib:
	dc.b	'graphics.library',0

even



VBlankInt:
	movem.l	d0-d7/a0-a6,-(a7)
	lea	$dff000,a6
	move	$1e(A6),d0
	btst	#4,d0			;Ist es Copper Interrupt?
	beq	EndVblank

if	seetime
	move	#$f00,$dff180
endif
	
	lea	bitmstr1,a0
	tst	FlipFlag
	beq	NoFlip
	lea	Bitmstr2,a0

NoFlip:
	lea	BitmapPtr,a1
	addq	#8,a0
	moveq	#4,d7
page_loop:				;Sichtbare Bitmaps
	move.l	(a0),d0			;in copperliste eintragen
	move	d0,6(a1)
	swap	d0
	move	d0,2(A1)
	addq	#4,a0
	addq	#8,a1
	dbf	d7,page_loop
	not	FlipFlag		;fuer Page-Flipping
	tst	GameLock		;Spiel fertig?
	beq.s	LetsGame
	bsr	FadeOut			;Farben abdunkeln
	move	d1,ColorSum		;Summe aller Farben
	bra	NoMoveNut		;Wenn die Summe 0 ist,
					;bricht das Hauptprogramm 
					;das Spiel ab
LetsGame:
	bsr	AskJoy
	move	d0,JoyWert
	tst	JumpLock		;sind wir am huepfen ?
	beq	MoveHerbie		;wenn nicht-> normal weiter
	lea	Bob1,a0			;Herbie huepft.
	lea	HupfTab,a1		;Koordinaten fuer Huepfer
	clr.l	d0
	move	Hupfoffset,d0		;aktuelle Koordinate
	move.w	(a1,d0),d1		;holen
	cmp	#-1,d1			;ende der Koordinatenliste?
	beq.s	HerbieNoHupf
	cmp	#22,20(A0)		;in welche richtung huepfen wir?
	bhi.s	JumpRight
	moveq	#5,d2
	sub	d1,d2			;wenn wir nach rechts huepfen
	move	d2,d1			;muessen wir die x Koordinaten
JumpRight:				;umkehren
	add	XOffset,d1
	cmp	#200,d1			;sind wir am rechten Rand?
	blt.s	NoHigher		;wenn ja -> nicht weiter 
	move	#210,d1			;als 210

NoHigher:
	cmp	#10,d1			;sind wir am linken Rand?
	bpl	NoLower			;wenn ja -> nicht weiter
	move	#5,d1			;als 5
NoLower:
	move	d1,8(A0)		;Neue x Koordinate setzen
	move	2(A1,d0),d1		;y Koordiante holen
	add	#37,d1			;Offset addieren
	move	d1,10(A0)		;neue y Koordinate setzen
	add	#4,HupfOffset		;Huepf PC erhoehen

HerbieNoHupf:
	addq	#1,AnimCounter		;nach jedem 6. VBlank
	cmp	#6,AnimCounter		;HuefSequenz erhoehen
	bne	NoJump
	clr	AnimCounter
	addq	#1,20(A0)		;Sequenz erhoehen
	cmp	#26,20(A0)		;fertig nach links ?
	beq.s	EndJump
	cmp	#23,20(A0)		;fertig nach rechts
	beq	EndJump2
	bra	NoJump
EndJump:
	clr	JumpLock		;Flag fuer 'Huepfend'
	clr	HupfOffset		;Huepf PC auf Beginn
	move	#19,20(A0)		;Normaler links Herbie
	move	#3,AnimCounter
	bra.s	MoveHerbie
EndJump2:
	clr	JumpLock		;Flag fuer 'Huepfend'
	clr	HupfOffset		;Huepf PC auf Beginn
	clr	20(A0)			;Normaler rechts Herbie
	
MoveHerbie:
	move	JoyWert,d0		;Joystick (Maus) abfragen
	lea	bob1,a0			;Herbie Bob
	move	20(A0),d1
	btst	#1,d0			;nach rechts ?
	beq	NoLeft
	cmp	#320-110,8(A0)		;schon am Rand
	bhi	XMax
	addq	#2,8(A0)		;x Position erhoehen
XMax:
	cmp	#9,d1
	bhi	NoDirCor		;falls richtung gewechselt
	add	#38,8(A0)		;x koordinate koorigieren
	move	#10,d1			;auf start setzen
	bra.s	NoEnd
NoDirCor:
	addq	#1,AnimCounter		;Bei jedem 4. VBlank
	cmp	#4,AnimCounter		;animieren
	bne	NoLeft
	clr	AnimCounter
	addq	#1,d1			;Image erhoehen
	cmp	#20,d1
	bne	NoEnd
	moveq	#10,d1			;von vorne
NoEnd:
	move	d1,20(A0)		;neu setzen

NoLeft:
	btst	#3,d0			;nach links ?		
	beq	NoRight			;(right sollte left sein)
	cmp	#3,8(A0)		;schon am rand?
	blt	XMin
	subq	#2,8(A0)		;erniedrigen
	move	8(a0),d7
	tst	d7
	bpl.s	XMin
	clr	8(a0)
XMin:
	addq	#1,AnimCounter		;Bei jedem 4. VBlank
	cmp	#4,AnimCounter		;animieren
	bne	NoDirCor2
	clr	AnimCounter	
	cmp	#10,d1			;Richtung gewechselt?
	blt	NoxCor			;wenn ja ->
	sub	#38,8(A0)		;x Koordinate korrigieren
	tst	8(a0)
	bpl.s	NoXCor
	clr	8(a0)
NoxCor:
	addq	#1,d1			;Image erhoehen
	cmp	#10,d1			;schon letztes
	blt	NoDirCor2	
	clr	d1			;wenn ja -> von vorne
NoDirCor2:
	move	d1,20(A0)		;neu setzen

NoRight:
	btst	#7,d0			;muessen wir springen ?
	beq	NoJump
	move	8(A0),Xoffset		;Offset fuer Sprung
	move	20(A0),d1		;aktuelles Image holen
	cmp	#10,d1			;nach links oder rechts ?
	blt.s	JumpLeft
	moveq	#23,d2			;Anfang fuer Sprung nach rechts
	move	d2,20(A0)		;setzen
	move	#-1,JumpLock		;Steuerung sperren
	bra.s	NoJump
JumpLeft:
	moveq	#20,d2			;Anfang fuer Sprung nach links
	move	d2,20(A0)		;setzen
	move	#-1,JumpLock		;Steuerung sperren

NoJump:
					;Jetzt CocoNut !
	lea	Bob3,a0			;Nut Bob
	cmp	#34,20(A0)		;ist es leere Nuss?
	bne	MoveNut
	addq	#1,WaitCounter
	cmp	#50,WaitCounter		;erst nach einer Sekunde
	bne	NoMoveNut
	clr	WaitCounter		;naechste Nuss
MoveNut:
	tst	10(A0)			;y = 0?
	bne.s	NoNewX			;

TakeNewX:
	bsr	rnd
	add	#20,d0
	move	d0,d1
	move	#33,20(A0)		;Nuss sichtbar machen
	move	d1,8(A0)

NoNewX:
	tst	JumpLock		;sind wir am huepfen?
	bne	NoFang			;wenn ja -> keine Kollisionen
	lea	Bob1,a1
	move	10(A0),d1		;Nuss y
	move	10(a1),d0		;Herbie y
	add	#20,d0			;Herbie korrigieren
	move	d0,d2
	add	#10,d2			;y Fangbereich
	cmp	d0,d1			;ist die Nuss	
	blt	NoFang			;im Bereich ? (y)
	cmp	d2,d1
	bhi	NoFang
	move	8(a1),d0		;Herbie x
	addq	#5,d0			;korrigieren
	cmp	#10,20(a1)		;links oder rechts Herbie?
	blt	CorHerbX
	add	#50,d0			;x korrigieren
CorHerbX:
	move	d0,d2		
	add	#33,d2			;Breite des Fangbereichs
	move	8(A0),d1		;Nuss x
	cmp	d0,d1
	blt	NoFang			;feststellen ob Nuss
	cmp	d2,d1			;im FangBereich
	bhi	NoFAng
	addq	#1,NutCounter		;Nuss gefangen

	;Hier kann Sound eingebaut werden!!!!!!!!!	

if	game
	bra.s	Fang			
endif

NoFang:
	addq	#2,10(A0)		;y Nuss erhoehen
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
	cmp	#256,10(A0)		;Unten angekommen
	blt	NoMoveNut	

if	game
	move	#-1,GameLock		;Spiel sperren 
endif

Fang:
	clr	10(A0)			;y Nuss = 0
	move	#34,20(A0)		;invisible Nut


NoMoveNut:
	bsr	drawbobs		;Bobs zeichnen

	bsr	Cycle			;Colormap cyclen
	bsr	SetCol			;und in die register setzen

if seetime
	move	#$0,$dff180
endif

	
	move	#$10,$9c(a6)		;Interrupt Flag loeschen
EndVblank:
	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9			;JMP
VBlankveq:
	dc.l	0			;($fc0cd8 ?)



ColorSum:
	dc.w	0
NutCounter:
	dc.w	0
AnimCounter:
	dc.w	0
WaitCounter:
	dc.w	0
JoyWert:
	dc.w	0

AskJoy:

	;	0=unten
	;	1=rechts
	;	2=hinauf
	;	3=links
	;	7=FeuerTaste (1 wenn gedrueckt)
	
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
	move.l	Mouse,a0
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

Mouse:
	dc.l	$dff00a

OldMouse:
	dc.w	0
JoyMouseFlag:
	dc.w	-1



SetCol:
	lea	ColorBuffer,a0
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
	lea	ColorBuffer,a0
	move	62(A0),d0
	move	60(A0),62(A0)
	move	58(A0),60(A0)
	move	56(A0),58(A0)
	move	d0,56(A0)
EndCycle:
	rts


Rnd:
	move.b 	$bfe801,d0
	add.b 	$bfd800,d0
	add.b 	$dff008,d0
	add.b 	$dff009,d0
	add.b 	$dff00a,d0
	add.b 	$dff00b,d0
	rts




	
CycleCounter:
	dc.w	0
	
JumpLock:
	dc.w	0
GameLock:
	dc.w	0
FlipFlag:
	dc.w	0



copperl:
	dc.w	$009c,$8010
	dc.w	$1001,$fffe
	dc.w 	$008e,$2881
	dc.w 	$0090,$28c1
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
if watch
	dc.w	$00e0,$0001
	dc.w	$00e2,$9000
	dc.w	$0100,$1200
	
endif
	dc.w	$ffff,$fffe 


bitmstr1:
	dc.w	40
	dc.w	256
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page1
	dc.l	page1+[1*10880]
	dc.l	page1+[2*10880]
	dc.l	page1+[3*10880]
	dc.l	page1+[4*10880]


bitmstr2:
	dc.w	40
	dc.w	256
	dc.b	0
	dc.b	5
	dc.w	0
	dc.l	page2
	dc.l	page2+[1*10880]
	dc.l	page2+[2*10880]
	dc.l	page2+[3*10880]
	dc.l	page2+[4*10880]

MaskPlane:
	dc.l	KollisionsPlane


dc.b	'Bob Master Routine (c) 1987 by Chris 1.2 (28.12.87)'

even


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

	bsr	TestModify

	Move.l	(A5),d1
	move.l	8(a0),(A5)
	

	cmp.l	#-1,d1
	beq	EndReconst

	tst	d0
	beq	EndReconst

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

if 	coli	
	move.l	MaskPlane,a3
	add.l	d0,a3
BlitWait5:
	btst	#14,2(A6)
	bne	BlitWait5
	move	24(A0),$66(a6)
	clr	$42(a6)
	move	#$100,$40(A6)
	move.l	a3,$54(A6)
	move	22(A0),$58(A6)
endif	

	tst.l	44(A0)
	beq	EndRecLoop
	move.l	44(A0),a0
	bra	BobReconstLoop
	
EndRecLoop:		


;Jetzt werden all Hintergruende an der neuen Koordinate gerettet
	

	lea	BobList,a0
BobMainLoop:
	tst.b	34(A0)
	beq	NoAnimate
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

	if	coli

	move.l	MaskPlane,a1
	add.l	d0,a1


BlitWait4:
	btst	#14,$2(A6)
	move	24(A0),$66(A6)
	move	24(A0),$62(A6)
	move.l	a4,$50(A6)
	move.l	a1,$54(A6)
	move.l	a1,$4c(A6)
	clr	$64(A6)
	clr	$42(A6)
	move	#$0cc0,d3
	cmp.l	#Bob1,a0
	bne	Nu
	move	#$9f0,d3
Nu:
	or	d2,d3
	move	d3,$40(A6)
	move	22(A0),$58(A6)
BlitWait6:
	btst	#14,2(A6)
	bne	BlitWait6
	clr	d0
	cmp.l	#Bob2,a0
	bne	NoAnimate
	btst	#13,2(A6)
	bne	NoAnimate
	move	#$0f,$dff180

	endif


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
	tst.l	58(A0)			;MovePrg ?
	beq	NoMove
	addq	#1,66(A0)
	move	64(A0),d0
	cmp	66(A0),d0		;Geschwindigkeit?	
	bne	NoMove
	clr	66(A0)
	tst	70(A0)			;Naechstes Kommando
	bne	NoNextCommand	
MoveIt:
	move	62(A0),d0
	move.l	58(A0),a1		;Zeiger auf Tabelle
	addq	#4,62(a0)
	move	(a1,d0.w),d1		;Anzahl Kommand
	cmp	#-1,d1			;Ende des Programms?
	bne	NoEndPrg
	clr	62(A0)			;Offset loeschen	
	bra.s	NoMove

NoEndPrg:
	move	d1,70(A0)		;Neue Anzahl Kommandos
	move	2(A1,d0.w),68(A0)	;Neues Kommando

NoNextCommand:
	subq	#1,70(A0)		;KommandoZaehler minus
	move	68(A0),d0		;Aktuelles Kommando
	btst	#0,d0
	beq	NoXadd		
	addq	#1,8(A0)
NoXadd:
	btst	#1,d0
	beq	NoXsub	
	subq	#1,8(A0)
NoXsub:
	btst	#2,d0
	beq	NoYadd
	addq	#1,10(A0)
NoYadd:
	btst	#3,d0
	beq	NoYsub
	subq	#1,10(A0)
NoYsub:
	
NoMove:
	tst.l	(a0)			;Letztes Bob in der Liste ?
	beq	EndDrawBobs
	move.l	(A0),a0			;Naechstes Bob = aktuelles Bob
	bra	BobMainLoop

EndDrawBobs:
	movem.l	(a7)+,d0-d7/a0-a6
	rts




		


TestModify:			;testet ob aktuelles Bob verschoben
				;wurde, oder ob es animiert werden soll

	movem.l	d1/d2,-(sp)
	clr.l	d0

	move	50(A0),d1
	addq	#1,d1
	cmp	48(A0),d1
	beq	Modified


	addq	#1,d1
	cmp	48(A0),d1
	beq	Modified

	move.l	8(A0),d1
	move.l	12(A0),d2
	tst	FlipFlag
	beq	Mody1
	move.l	16(A0),d2
Mody1:
	cmp.l	d2,d1
	bra	Modified
	movem.l	(sp)+,d1/d2
	move.b	d0,34(A0)
	rts

Modified:
	st	d0
	move.b	d0,34(A0)
	movem.l	(sp)+,d1/d2
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
	dc.l	bobs		;erstes bob
	dc.l	bobs+[1*l1]	
	dc.l	bobs+[2*l1]	
	dc.l	bobs+[3*l1]	
	dc.l	bobs+[4*l1]	
	dc.l	bobs+[5*l1]	
	dc.l	bobs+[6*l1]	
	dc.l	bobs+[7*l1]	
	dc.l	bobs+[8*l1]	
	dc.l	bobs+[9*l1]	
	dc.l	bobs+[10*l1]	
	dc.l	bobs+[11*l1]	
	dc.l	bobs+[12*l1]	
	dc.l	bobs+[13*l1]	
	dc.l	bobs+[14*l1]	
	dc.l	bobs+[15*l1]	
	dc.l	bobs+[16*l1]	
	dc.l	bobs+[17*l1]	
	dc.l	bobs+[18*l1]	
	dc.l	bobs+[19*l1]				
	dc.l	bobs+[20*l1]				
	dc.l	bobs+[21*l1]				
	dc.l	bobs+[22*l1]				
	dc.l	bobs+[23*l1]
	dc.l	bobs+[24*l1]
	dc.l	bobs+[25*l1]


	dc.l	Worm+[0*l2] 	;wurm nach rechts
	dc.l	Worm+[1*l2]	;wurm nach rechts
	dc.l	Worm+[2*l2]	;Wurm nach links
	dc.l	Worm+[3*l2]	;Wurm nach links
	dc.l	Worm+[4*l2]	;Wurm halb links
	dc.l	Worm+[5*l2]	;Wurm mitte
	dc.l	Worm+[6*l2]	;Wurm halb rechts
	
	dc.l	Nut		;Nuss (Image 33)
	dc.l	Nut+l3

BobList:
	

Bob1:
	dc.l	Bob2		;Next Bob		0
	dc.w	112,57		;Breite,Hoehe		4
	dc.w	0,123		;New x,y Pos		8
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
	dc.w	1		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	0		;AnimProgramm		54
	dc.l	0		;BewgungPrg		58
	dc.w	0		;BewegungsOffset	62
	dc.w	1		;Speed			64
	dc.w	0		;SpeedCounter		66	
	dc.w	0		;Aktuelles Komando	68
	dc.w	0		;CommandCounter		70

Bob2:
	dc.l	Bob3		;Next Bob		0
	dc.w	80,28		;Breite,Hoehe		4
	dc.w	00,150		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	29		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	save3		;save1			26
	dc.l	save4		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	bob1		;Last Bob		44
	dc.w	8		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	AnimSeq		;AnimProgramm		54
	dc.l	MovePrg		;BewgungPrg		58
	dc.w	0		;BewegungsOffset	62
	dc.w	1		;Speed			64
	dc.w	0		;SpeedCounter		66	
	dc.w	0		;Aktuelles Komando	68
	dc.w	0		;CommandCounter		70


Bob3:		;Kugel Bob
	dc.l	0		;Next Bob		0
	dc.w	32,16		;Breite,Hoehe		4
	dc.w	100,0		;New x,y Pos		8
	dc.w	-1,-1		;Old x,y Pos1		12
	dc.w	-1,-1		;Old x,y Pos2		16
	dc.w	33		;BobImageNumber		20
	dc.w	0		;BltSize		22
	dc.w	0		;Modulo			24
	dc.l	save5		;save1			26
	dc.l	save6		;save2			30
	dc.w	0		;flags			34
	dc.l	0		;Laenge	einer Plane	36
	dc.l	0		;Offset to Mask		40
	dc.l	bob2		;Last Bob		44
	dc.w	1		;AnimSpeed		48	
	dc.w	0		;SpeedCounter		50
	dc.w	0		;AnimOffset		52
	dc.l	0		;AnimProgramm		54
	dc.l	0		;BewgungPrg		58
	dc.w	0		;BewegungsOffset	62
	dc.w	1		;Speed			64
	dc.w	0		;SpeedCounter		66	
	dc.w	0		;Aktuelles Komando	68
	dc.w	0		;CommandCounter		70

;BewegungsProgramm fuer Wurm

MovePrg:
	dc.w	247,1		;247 mal rechts
	dc.w	247,2		;247 mal links
	dc.w	-1




;AnimationsSequenz fuer Wurm

AnimSeq:

	dc.w	26,27,26,27,26,27,26,27,26,27
	dc.w	26,27,26,27,26,27,26,27,26,27
	dc.w	26,27,26,27,26,27,26,27
	dc.w	32,31,30
	dc.w	28,29,28,29,28,29,28,29,28,29
	dc.w	28,29,28,29,28,29,28,29,28,29
	dc.w	28,29,28,29,28,29,28,29
	dc.w	30,31,32
	dc.w	-1


ColorMap:
	DC.L	$00000EBA,$0DA90C98,$0B870A76,$09650854
	DC.L	$07540643,$05320421,$032108C8,$06A60484
	DC.L	$03730252,$03330444,$05550666,$07770999
	DC.L	$0BBB0DDD,$0c7900dd,$0BEF08EF,$07DF00DF

ColorBuffer:
	blk.w	32,0



HupfOffset:
	dc.w	0


;Wenn der Feuerknopf gedrueckt wird, wir hier die aktuelle x
;Position gespeichert. Waehrend dem Huepfen wird diese
;immer zu der in der Tabelle dazu addiert.
XOffset:
	dc.w	0

;x und y Koordinaten fuer Huepfer

HupfTab:
	dc.w	1,87,3,83,11,73,18,67,26,60,41,52,51,50
	dc.w	62,52,71,56,75,61,80,67,83,75,84,81,85,87
	dc.w	-1



