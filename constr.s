
; Name    : AMIGAnoid Construction Set 
; Menu's  : About,Quit,Scroll,Load,Save,Delete,Clear,Undo
; Gadget's: Level,Bloecke,Hits,Colors
; Date    : 2.10.87 
;           23.5.94 ReWrite f�r DOS-Version
; Remarks : Final Version 1.00 (Jippy !!!)
; Include : Back2 nach Plane2



		SECTION	text,Code


		INCDIR	"INCLUDE:"

		INCLUDE	"graphics/gfx.i"
		INCLUDE "iff.i"
		INCLUDE "exec.i"
		INCLUDE "dos.i"
		INCLUDE "intuition.i"


StageBase:	EQU	512*1447
ConstrLength:	EQU	25600



Main:		bsr	OpenLib		; Open Intuition


		bsr	AllocHMemory

		move.l	_IntuitionBase,a6
		lea	prefbuffer,a0
		moveq	#120,d0
		jsr	-132(a6)		; Get prefs

		lea	prefbuffer,a1
		move.b	#8,(A1)			; Font
		move	#1,108(a1)		; MouseSpeed
		lea	prefbuffer,a0
		moveq	#120,d0
		moveq	#24,d1
		jsr	-324(a6)

		move.l	_IntuitionBase,a6
		lea	NewScreen,a0		; Open Screen
		jsr	-198(a6)
		tst.l	d0
		beq	Exit

		move.l	d0,Scr
		move.l	d0,Screen 

		add.l	#$c0-8,d0
		move.l	d0,bitmstr

	;	add.l	#$c0,d0
		addq.l	#8,d0
		move.l	d0,a0

		lea	bitplane1,a1
		moveq	#4-1,d0
get_planes:	move.l	(a0)+,(a1)+
		dbra	d0,get_planes


		lea	NewWindow,a0		; Openwindow
		jsr	-204(a6)
		tst.l	d0
		beq	Exit
		move.l	d0,Window

		bsr	getrapo			; View- und Rastport des Scr. holen
		bsr	colorblack
		bsr	SetStrip

		bsr	LoadScr
		bsr	entpack			; Entcrunchen
		bsr	FreeScr
		bsr	initcolors		; Farben setzen

		move.l	Window,a0
		move.l	$56(a0),MsgPort	; Messageport bestimmen
	
		bsr	ToFront
		bra	loadfirst



WaitMsg:	bsr	WaitMsg2
		cmp.l	#$100,class
		beq	exmenu
		cmp.l	#$40,class
		beq	exgadget
		cmp.l	#$8,class
		bne.s	nobutt
		cmp	#$e8,code
		beq.s	nobutt
		bra.s	exmousebuttons

nobutt:		bsr	replymsg
		bra	WaitMsg



exmousebuttons:	bsr	CopyToUndo
		bsr	replymsg

mouse2:		btst	#10,$dff016
		beq	WaitMsg

		move.l	Screen,a0
		move	16(a0),MouseY
		move	18(a0),MouseX
		cmp	#88,MouseX
		blt	notinrect
		cmp	#9,MouseY
		blt	notinrect
		cmp	#424,MouseX
		bhi	notinrect
		cmp	#132,MouseY
		bhi	notinrect
		move	MouseX,d1
		sub	#80,d1
		lsr	#5,d1
		move	d1,BlockX
		move	MouseY,d2
		sub	#7,d2
		lsr	#3,d2
		move	d2,BlockY
		move.l	blocknr,d0
		bsr	DrawBlock		; Block zeichnen

		lea	zspeicher+14,a1
		add	BlockX,a1
		move	BlockY,d2
		mulu	#11,d2
		add.l	d2,a1

		cmp	#7,d0
		bne.s	write21
		move	zspeicher,d5
		move.b	d5,d4
		lsl	#5,d4
		add.b	d4,d0	
write21:
		move.b	d0,(a1)
notinrect:
		btst	#6,$bfe001
		beq	mouse2
		bra	WaitMsg


exgadget:	bsr	replymsg
		cmp.l	#Gadget2,gadg	; Farben wechseln
		beq	colors
		cmp.l	#Gadget1,gadg	; Hits-1
		beq	dechits
		cmp.l	#Gadget14,gadg	; Hits+1	
		beq	inchits
		cmp.l	#Gadget4,gadg	; Naechster Level
		beq	nextlevel
		cmp.l	#Gadget3,gadg	; Vorheriger Level
		beq	prelevel
		cmp.l	#Gadget5,gadg	; Block1
		beq	BlockRot
		cmp.l	#Gadget6,gadg	; Block2
		beq	BlockOrange
		cmp.l	#Gadget7,gadg	; Block3
		beq	BlockGelb
		cmp.l	#Gadget8,gadg	; Block4
		beq	BlockGruen
		cmp.l	#Gadget9,gadg	; Block5
		beq	BlockViolett
		cmp.l	#Gadget10,gadg	; Block6
		beq	BlockBlau
		cmp.l	#Gadget11,gadg	; Block7
		beq	BlockGrau
		cmp.l	#Gadget12,gadg	; Block8
		beq	BlockBraun
		cmp.l	#Gadget13,gadg	; Hintergrund
		beq	Hintergrund
		cmp.l	#LaserGadg,gadg
		beq	laser
		cmp.l	#LivesGadg,gadg
		beq	lives
		cmp.l	#ExtGadg,gadg
		beq	ext
		cmp.l	#HoldGadg,gadg
		beq	hold
		cmp.l	#AutoGadg,gadg
		beq	auto
		cmp.l	#BonusGadg,gadg
		beq	bonus
		cmp.l	#LevelGadg,gadg
		beq	level
		cmp.l	#ThreeGadg,gadg
		beq	three
		cmp.l	#SurpriseGadg,gadg
		beq	surprise
		bra	WaitMsg



exmenu:		bsr	replymsg
		cmp	#$f860,code		; Quit
		beq	Quit
		cmp	#$f840,code		; About
		beq	about
		cmp	#$f801,code		; Clear 
		beq	clear	
		cmp	#$f800,code		; Load
		beq	load
		cmp	#$f820,code		; Save
		beq	save
		cmp	#$f841,code		; Undo
		beq	undo
		cmp	#$0021,code		; Scroll up
		beq	scrollup
		cmp	#$0821,code		; Scroll down
		beq	scrolldown
		cmp	#$1021,code		; Scroll left
		beq	scrollleft
		cmp	#$1821,code		; Scroll right
		beq	scrollright	
		bra	WaitMsg


WaitMsg2:	move.l	MsgPort,a0
		Exec	WaitPort

		move.l	4.w,a6
		move.l	MsgPort,a0
		jsr	-372(a6)		; Getmessage
		tst.l	d0
		beq	WaitMsg2	

		move.l	d0,message		; Zeiger auf Messagestruktur
		move.l	message,a0
	
		move.l	20(a0),class		; Class (IDCMP)
		move	24(a0),code		; Code
		move.l	28(a0),gadg		; Gagdet
		rts




laser:		move.l	#9,blocknr	
		bra	WaitMsg

lives:		move.l	#10,blocknr	
		bra	WaitMsg

ext:		move.l	#11,blocknr	
		bra	WaitMsg

hold:		move.l	#12,blocknr
		bra	WaitMsg

auto:		move.l	#13,blocknr
		bra	WaitMsg

bonus:		move.l	#14,blocknr
		bra	WaitMsg

level:		move.l	#15,blocknr
		bra	WaitMsg

three:		move.l	#16,blocknr
		bra	WaitMsg

surprise:	move.l	#17,blocknr
		bra	WaitMsg

colors:		move.l	_IntuitionBase,a6
		lea	crequester,a0
		move.l	Window,a1
		jsr	-240(a6)
		bsr	colortobuf
		bsr	initcolors

colors2:	bsr	WaitMsg2
		bsr	replymsg
		cmp.l	#$40,class
		beq	cls1
		cmp.l	#$20,class
		bne.s	colors2	
	
		cmp.l	#propgadget1,gadg
		beq	RedCol
		cmp.l	#propgadget2,gadg
		beq	GreenCol
		cmp.l	#propgadget3,gadg
		beq	BlueCol
		bra	colors2

cls1:		cmp.l	#continuecol,gadg
		beq	cancelcolors
		cmp.l	#color1,gadg
		beq	cl1
		cmp.l	#color2,gadg
		beq	cl2
		cmp.l	#color3,gadg
		beq	cl3
		cmp.l	#color4,gadg
		beq	cl4
		cmp.l	#color5,gadg
		beq	cl5
		cmp.l	#color6,gadg
		beq	cl6
		cmp.l	#defaultcolors,gadg
		beq	defcl
		cmp.l	#excolor,gadg
		beq	excl
		cmp.l	#copycolor,gadg
		beq	copycl
		bra	colors2

RedCol:
		lea	propinfo1+4,a1
		move	(a1),d0
		and	#$f000,d0
		move	#$f000,d1
		sub	d0,d1
		lsr	#4,d1
		lea	zspeicher+2,a1
		add.l	newcolor,a1
		and	#$f0ff,(a1)
		add	d1,(a1)
		bsr	colortobuf
		bsr	initcolors
		btst	#6,$bfe001
		beq.s	RedCol
		bra	colors2

GreenCol:
		lea	propinfo2+4,a1
		move	(a1),d0
		and	#$f000,d0
		move	#$f000,d1
		sub	d0,d1
		lsr	#8,d1
		lea	zspeicher+2,a1
		add.l	newcolor,a1
		and	#$ff0f,(a1)
		add	d1,(a1)
		bsr	colortobuf
		bsr	initcolors
		btst	#6,$bfe001
		beq.s	GreenCol
		bra	colors2

BlueCol:
		lea	propinfo3+4,a1
		move	(a1),d0
		and	#$f000,d0
		move	#$f000,d1
		sub	d0,d1
		lsr	#8,d1
		lsr	#4,d1
		lea	zspeicher+2,a1
		add.l	newcolor,a1
		and	#$fff0,(a1)
		add	d1,(a1)
		bsr	colortobuf
		bsr	initcolors
		btst	#6,$bfe001
		beq.s	BlueCol	
		bra	colors2



colortobuf:	lea	zspeicher+2,a1
		lea	colorbuf+16,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1),(a2)
		rts



cl1:		moveq	#6,d0
		bsr	colortoprop
		bra	colors2

cl2:		moveq	#4,d0
		bsr	colortoprop
		bra	colors2

cl3:		moveq	#2,d0
		bsr	colortoprop
		bra	colors2

cl4:		clr.l	d0
		bsr	colortoprop
		bra	colors2

cl5:		moveq	#10,d0
		bsr	colortoprop
		bra	colors2

cl6:
		moveq	#8,d0
		bsr	colortoprop
		bra	colors2

copycl:
		move.l	_IntuitionBase,a6	
		move.l	Window,a0
		lea	copypointer,a1
		moveq	#15,d0
		moveq	#16,d1
		move.l	#-16,d2
		move.l	#-14,d3
		jsr	-270(a6)
wcol:
		bsr	WaitMsg2
		bsr	replymsg
		cmp.l	#color1,gadg
		beq	ccol4
		cmp.l	#color2,gadg
		beq	ccol3
		cmp.l	#color3,gadg
		beq	ccol2
		cmp.l	#color4,gadg
		beq	ccol1
		cmp.l	#color5,gadg
		beq	ccol6
		cmp.l	#color6,gadg
		beq	ccol5
		bra	wcol
ccol1:
		clr.l	d0
		bra	ccol9
ccol2:
		moveq	#2,d0
		bra	ccol9
ccol3:
		moveq	#4,d0
		bra	ccol9
ccol4:
		moveq	#6,d0
		bra	ccol9
ccol5:
		moveq	#8,d0
		bra	ccol9
ccol6:
		moveq	#10,d0
ccol9:
		lea	zspeicher+2,a0
		move.l	a0,a1
		add.l	newcolor,a0
		move	(a0),(a1,d0.l)

		bsr	colortobuf
		bsr	colortoprop
		bsr	initcolors
		move.l	_IntuitionBase,a6
		move.l	Window,a0
		jsr	-60(a6)
		bra	colors2


excl:		move.l	_IntuitionBase,a6	
		move.l	Window,a0
		lea	expointer,a1
		moveq	#18,d0
		moveq	#16,d1
		move.l	#-16,d2
		move.l	#-17,d3
		jsr	-270(a6)

ecol:		bsr	WaitMsg2
		bsr	replymsg
		cmp.l	#color1,gadg
		beq	ecol4
		cmp.l	#color2,gadg
		beq	ecol3
		cmp.l	#color3,gadg
		beq	ecol2
		cmp.l	#color4,gadg
		beq	ecol1
		cmp.l	#color5,gadg
		beq	ecol6
		cmp.l	#color6,gadg
		beq	ecol5
		bra.s	ecol

ecol1:		clr.l	d0
		bra	ecol9

ecol2:		moveq	#2,d0
		bra	ecol9

ecol3:		moveq	#4,d0
		bra	ecol9

ecol4:		moveq	#6,d0
		bra	ecol9

ecol5:		moveq	#8,d0
		bra	ecol9

ecol6:		moveq	#10,d0

ecol9:		lea	zspeicher+2,a0
		move.l	a0,a1
		add.l	d0,a1
		add.l	newcolor,a0
		move	(a0),d2
		move	(a1),(a0)
		move	d2,(a1)

		bsr	colortobuf
		bsr	colortoprop
		bsr	initcolors
		move.l	_IntuitionBase,a6
		move.l	Window,a0
		jsr	-60(a6)
		bra	colors2

defcl:		lea	zspeicher+2,a0
		move	#$0f0,(a0)+
		move	#$ff0,(a0)+
		move	#$fa0,(a0)+
		move	#$f00,(a0)+
		move	#$00f,(a0)+
		move	#$0ff,(a0)
		bsr	colortobuf
		bsr	initcolors
		bra	colors2

colortoprop:	move.l	d0,newcolor
		lea	zspeicher+2,a0	
		move	(a0,d0.l),d0
		move	d0,d1
		and	#$000f,d1
		lea	propinfo3+4,a1
		mulu	#$1111,d1
		move	#$ffff,d3
		sub	d1,d3
		move	d3,(a1)
		move	d0,d1
		and	#$00f0,d1
		lsr	#4,d1
		lea	propinfo2+4,a1
		mulu	#$1111,d1
		move	#$ffff,d3
		sub	d1,d3
		move	d3,(A1)
		move	d0,d1
		and	#$0f00,d1
		lsr	#8,d1
		lea	propinfo1+4,a1
		mulu	#$1111,d1
		move	#$ffff,d3
		sub	d1,d3
		move	d3,(A1)
		move.l	_IntuitionBase,a6
		lea	propgadget1,a0
		move.l	Window,a1
		lea	crequester,a2
		jmp	-222(a6)







cancelcolors:	lea	crequester,a0
		bsr	endrequest	
		bra	WaitMsg

inchits:	addq	#1,zspeicher
		cmp	#9,zspeicher
		bne.s	inc2
		move	#2,zspeicher

inc2:		bsr	printhits
		bra	WaitMsg

dechits:	subq	#1,zspeicher
		cmp	#1,zspeicher
		bne.s	dec2
		move	#8,zspeicher

dec2:		bsr	printhits
		bra	WaitMsg

writehits:	moveq	#31,d3
		clr.l	d2

test345:	move.l	hspeicher,a4
		clr	d5
		move	(a4,d2.w),d5		; hits fuer diese stufe
		lsl.b	#5,d5			; richtiges format

		move.l	hspeicher,a4
		add.l	d2,a4			; richtiger level
		add.l	#14,a4

		move	#175,d7
test:		move.b	(a4),d6
		and.b	#31,d6
		cmp.b	#7,d6
		bne.s	endtest
		add.b	d5,d6			; sonst hits addieren
endtest:
		move.b	d6,(a4)+
		dbra	d7,test

		add.l	#190,d2			; Naechste Stufe
		dbra	d3,test345
		rts
	

nextlevel:	bsr	ztoh
		addq.l	#1,stufe
		add.l	#190,stufe2
		cmp.l	#33,stufe
		bne	nlevel1

		clr.l	stufe2
		move.l	#1,stufe

nlevel1:	bsr	hToz
		bsr	BuildLevel
		bsr	CopyToUndo
		bra	WaitMsg

prelevel:	bsr	ztoh
		subq.l	#1,stufe
		sub.l	#190,stufe2
		tst.l	stufe
		bne.s	plevel1

		move.l	#32,stufe
		move.l	#31*190,stufe2

plevel1:	bsr	hToz
		bsr	BuildLevel
		bsr	CopyToUndo
		bra	WaitMsg


scrolldown:	bsr	CopyToUndo
		lea	zspeicher+178,a1
		move	#164,d7
sdown1:
		move.b	(a1),11(a1)
		subq.l	#1,a1
		dbra	d7,sdown1
		lea	zspeicher+14,a1
		moveq	#10,d7
sdown2:
		clr.b	(A1)+
		dbra	d7,sdown2
		bsr	BuildLevel
		bra	WaitMsg

scrollup:	bsr	CopyToUndo
		lea	zspeicher+14,a1
		move	#164,d7
sup1:
		move.b	11(a1),(a1)+
		dbra	d7,sup1
		moveq	#10,d7
sup2:
		clr.b	(a1)+
		dbra	d7,sup2
		bsr	BuildLevel
		bra	WaitMsg

scrollleft:	bsr	CopyToUndo
		lea	zspeicher+14,a1
		move	#174,d7
sleft1:		move.b	1(a1),(a1)+
		dbra	d7,sleft1
		moveq	#15,d7
		lea	zspeicher+24,a1
sleft2:		clr.b	(a1)
		add.l	#11,a1
		dbra	d7,sleft2
		bsr	BuildLevel
		bra	WaitMsg

scrollright:	bsr	CopyToUndo
		lea	zspeicher+188,a1
		move	#174,d7
sright1:	move.b	(a1),1(a1)
		sub.l	#1,a1
		dbra	d7,sright1
		moveq	#15,d7
		lea	zspeicher+14,a1
sright2:	clr.b	(a1)
		add.l	#11,a1
		dbra	d7,sright2
		bsr	BuildLevel
		bra	WaitMsg

BlockRot:	move.l	#4,blocknr
		bra	WaitMsg

BlockOrange:	move.l	#3,blocknr
		bra	WaitMsg

BlockGelb:	move.l	#2,blocknr
		bra	WaitMsg

BlockGruen:	move.l	#1,blocknr
		bra	WaitMsg

BlockViolett:	move.l	#6,blocknr
		bra	WaitMsg

BlockBlau:	move.l	#5,blocknr
		bra	WaitMsg

BlockGrau:	move.l	#7,blocknr
		bra	WaitMsg

BlockBraun:	move.l	#8,blocknr
		bra	WaitMsg

Hintergrund:	clr.l	blocknr
		bra	WaitMsg


loadfirst:	move.b	#'A',stagenr
		bra	LoadIt2


load:		move.l	_IntuitionBase,a6
		lea	lrequester,a0
		move.l	Window,a1
		jsr	-240(a6)

load2:		bsr	printstg
		bsr	WaitMsg2

		move.l	20(a0),class
		move	24(a0),code
		move.l	28(a0),gadg
		bsr	replymsg
		cmp.l	#$40,class
		bne	load2
	
		cmp.l	#lcancelgadg,gadg
		beq	cancelload

		cmp.l	#loadgadg,gadg
		beq	LoadIt

		cmp.l	#incstage,gadg
		bne	loa1
		bsr	incstg

loa1:		cmp.l	#decstage,gadg
		bne	loa2
		bsr	decstg
loa2:
		bra	load2




incstg:		add.b	#1,stagenr
		cmp.b	#'O'+1,stagenr
		bne.s	1$

		move.b	#'A',stagenr
1$:		rts


decstg:		sub.b	#1,stagenr
		cmp.b	#'A'-1,stagenr
		bne.s	1$

		move.b	#'O',stagenr
1$:		rts




printstg:	move.l	GFXBase,a6
		moveq	#2,d0
		move.l	rapo,a1
		jsr	-342(A6)

		move.l	#334,d0
		moveq	#80,d1
		move.l	rapo,a1
		jsr	-240(a6)		; Move x,y

		moveq	#1,d0
		move.l	rapo,a1
		lea	stagenr,a0
		jsr	-60(a6)			; Print
		rts


cancelload:	lea	lrequester,a0
		bsr	endrequest	
		bra	WaitMsg


LoadIt:		lea	lrequester,a0
		bsr	endrequest

LoadIt2:	bsr	ClearStrip

		lea	Stage_File,a0
		move.b	stagenr,13(a0)
		move.l	hspeicher,a1
		move.l	#12*512,d0
		bsr	LoadFile
	;	tst	d0
	;	beq	2$

3$:	;	move.w	#$f00,$dff180
	;	btst	#6,$bfe001
	;	bne	3$


2$:		bsr	hToz
		bsr	BuildLevel
		bsr	CopyToUndo
		bsr	SetStrip
		bra	WaitMsg





endrequest:	move.l	_IntuitionBase,a6
		move.l	Window,a1
		jmp	-120(a6)


save:		bsr	writehits
		move.l	_IntuitionBase,a6
		lea	srequester,a0
		move.l	Window,a1
		jsr	-240(a6)
save2:
		bsr	printstg
		bsr	WaitMsg2

		move.l	20(a0),class
		move	24(a0),code
		move.l	28(a0),gadg

		bsr	replymsg
		cmp.l	#$40,class
		bne.s	save2
	
		cmp.l	#scancelgadg,gadg
		beq	CancelSave
		cmp.l	#savegadg,gadg
		beq	SaveIt
		cmp.l	#incstage,gadg
		bne.s	sav1
		bsr	incstg
sav1:
		cmp.l	#decstage,gadg
		bne.s	sav2
		bsr	decstg
sav2:
		bra	save2
CancelSave:
		lea	srequester,a0
		bsr	endrequest
		bra	WaitMsg



SaveIt:		lea	srequester,a0
		bsr	endrequest
		bsr	ztoh
		bsr	ClearStrip


Retry:

		lea	Stage_File,a0
		move.b	stagenr,13(a0)
		move.l	hspeicher,a1
		move.l	#12*512,d0
		bsr	SaveFile
	;	tst	d0
	;	beq	2$

3$:	;	move.w	#$f00,$dff180
	;	btst	#6,$bfe001
	;	bne	3$

		bra.s	OkSave


	*** Errorhandling einbauen ***



DiskError:	move.l	_IntuitionBase,a6
		move.l	Window,a0
		lea	bodytext,a1
		lea	postext,a2
		lea	negtext,a3
		clr.l	d0
		clr.l	d1
		move.l	#240,d2
		moveq	#60,d3
		jsr	-348(a6)
		tst.l	d0
		bne	Retry

		bsr	SetStrip
		bra	WaitMsg

OkSave:		bsr	SetStrip
		bra	WaitMsg



undo:		bsr	CopyFromUndo
		bsr	BuildLevel
		bra	WaitMsg



clear:		bsr	CopyToUndo
		lea	zspeicher,a0
		move	#2,(a0)
		add.l	#14,a0
		move	#43,d6

clear1:		clr.l	(a0)+
		dbra	d6,clear1
		bsr	BuildLevel
		bra	WaitMsg



ztoh:		lea	zspeicher,a0
		move.l	hspeicher,a1
		add.l	stufe2,a1
		move	#94,d7

ztoh1:		move	(a0)+,(a1)+
		dbra	d7,ztoh1
		rts



CopyToUndo:	lea	zspeicher,a1
		lea	undobuffer,a2
		move	#94,d7

ctou:		move	(A1)+,(A2)+
		dbra	d7,ctou
		rts




CopyFromUndo:	lea	zspeicher,a1
		lea	undobuffer,a2
		move	#94,d7

ctou2:		move	(A2)+,(A1)+
		dbra	d7,ctou2
		bsr	ztoh
		rts



hToz:		lea	zspeicher,a0
		move.l	hspeicher,a1
		add.l	stufe2,a1
		move	#94,d7

hToz1:		move	(a1)+,(a0)+
		dbra 	d7,hToz1

		bsr	CopyToUndo
		rts



BuildLevel:	bsr	colortobuf
		bsr	initcolors

		lea	zspeicher,a0
		add.l	#14,a0
		moveq	#0,d0
		moveq	#0,d2

blevel1:	moveq	#0,d1
blevel2:	move.b	(a0)+,d0
		and.b	#$1F,d0

		bsr	DrawBlock

		addq	#1,d1
		cmp	#11,d1
		bne	blevel2
		add	#1,d2
		cmp	#16,d2
		bne	blevel1


		bsr	printhits
		move.l	stufe,d0
		bsr	intasc

		rts




printhits:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	GFXBase,a6

		move.l	rapo,a1
		moveq.l	#2,d0
		jsr	-342(a6)

		move.l	rapo,a1
		move.l	#565,d0
		moveq.l	#123,d1
		jsr	-240(a6)

		move.l	rapo,a1
		add.b	#48,zspeicher+1
		moveq	#1,d0
		lea	zspeicher+1,a0
		jsr	-60(a6)

		sub.b	#48,zspeicher+1

		movem.l	(sp)+,d0-d7/a0-a6
		rts



LoadScr:	move.l	#ConstrLength,d0
		moveq.l	#0,d1
		Exec	AllocMem
		move.l	d0,ifffile
		beq	Exit

		lea	filename,a0
		move.l	ifffile,a1
		bsr	LoadFile
		rts



FreeScr:	move.l	#ConstrLength,d0
		move.l	ifffile,a1
		Exec	FreeMem
		rts
	

ToFront:	move.l	Screen,a0
		Intui	ScreenToFront
		rts



AllocHMemory:	move.l	#7000,d0
		moveq	#2,d1
		Exec	AllocMem
		move.l	d0,hspeicher
		rts



FreeHMemory:	tst.l	hspeicher
		beq	1$

		move.l	#7000,d0
		move.l	hspeicher,a1
		Exec	FreeMem

1$:		rts



Quit:		move.l	_IntuitionBase,a6
		move.l	Window,a0
		lea	bodytext2,a1
		lea	postext2,a2
		lea	negtext2,a3
		moveq	#0,d0
		moveq	#0,d1
		move.l	#240,d2
		moveq	#60,d3
		jsr	-348(a6)
		tst.l	d0
		bne.s	Exit

		bra	WaitMsg


Exit:		bsr	FreeHMemory

		move.l	_IntuitionBase,a6
		bsr	ClearStrip	

		move.l	Window,a0
		move.l	a0,d0
		tst.l	d0
		beq	quit3
		Intui	CloseWindow

quit3:		move.l	Screen,a0
		move.l	a0,d0
		tst.l	d0
		beq	quit4
		Intui	CloseScreen

quit4:		bsr	CloseLib

		moveq	#0,d0
		rts



DrawBlock:	movem.l d0-d7/a0-a5,-(sp); D0=Klotz/D1=X/D2=Y

WaitRight:	btst	#10,$dff016
		beq.s	WaitRight

		move.l	d0,d5
	
		lea	plane2,a0	; Blockdaten
		lsl.l	#2,d0		; Startadresse =
		add.l	d0,a0		; D0 * 4 + Screen2

		clr.l	dist
		add.l	#570,dist	; Startadresse =
		asl.l	#2,d1		; Screen1 + 4 * d1 + 640 * d2 + 570
		add.l	d1,dist
		mulu	#640,d2
		add.l	d2,dist

		lea	bitplane1,a3

		tst.l	d0
		beq	clear_block
	
		cmp.l	#8,d5
		bhi	db2

		sub.l	#1008-36,a0
db2:		add.l	#1008-36,a0

		moveq	#4-1,d7

DrawBlock2:	move.l	(a3)+,a2
		add.l	dist,a2

		move.l	(a0),(a2)
		move.l	36(a0),80(a2)
		move.l	72(a0),160(a2)
		move.l	108(a0),240(a2)
		move.l	144(a0),320(a2)
		move.l	180(a0),400(a2)
		move.l	216(a0),480(a2)
		add.l	#252,a0

		dbra	d7,DrawBlock2

		movem.l	(sp)+,d0-d7/a0-a5
		rts



clear_block:	moveq	#4-1,d7

clear_block2:	move.l	(a3)+,a2
		add.l	dist,a2

		clr.l	(a2)
		clr.l	80(a2)
		clr.l	160(a2)
		clr.l	240(a2)
		clr.l	320(a2)
		clr.l	400(a2)
		clr.l	480(a2)
		clr.l	480(a2)

		dbra d7,clear_block2

		movem.l (sp)+,d0-d7/a0-a5
		rts



SetStrip:	move.l	_IntuitionBase,a6
		move.l	Window,a0		; Set menustrip
		lea	MenuList,a1
		jsr	-264(a6)
		move.b	#1,StripSet
		rts



ClearStrip:	tst.b	StripSet
		beq	1$

		move.l	_IntuitionBase,a6
		move.l	Window,a0
		jsr	-54(a6)
		clr.b	StripSet
1$:		rts


about:		bsr	ClearStrip
		move.l	_IntuitionBase,a6	; Requester oeffnen
		lea	requester,a0
		move.l	Window,a1
		jsr	-240(a6)
		bsr	SetStrip
		bra	WaitMsg



intasc:		clr.l	d2
		lea	buf,a0
		cmp.l	#100000,d0
		bcs	gretend
		move.l	d0,d1
		lsr.l	#1,d1
		divu	#50000,d1
		move	d1,d2
		sub	#1,d1
		clr.l	d3
gret:
		add.l	#100000,d3
		dbf	d1,gret
		sub.l	d3,d0
gretend:
		add	#$30,d2
		move.b	d2,(a0)
		divs	#10000,d0
		add.b	#$30,d0
		move.b	d0,1(a0)
		clr	d0
		swap	d0
		divs	#1000,d0
		add.b	#$30,d0
		move.b	d0,2(a0)
		clr	d0
		swap	d0
		divs	#100,d0
		add.b	#$30,d0
		move.b	d0,3(a0)
		clr	d0
		swap	d0
		divs	#10,d0
		add.b	#$30,d0
		move.b	d0,4(a0)
		clr	d0
		swap	d0
		add.b	#$30,d0
		move.b	d0,5(a0)

		move.l	GFXBase,a6
		move.l	rapo,a1
		move	#558,d0
		move	#149,d1
		jsr	-240(a6)

		lea	buf+4,a0
		moveq	#2,d0
		move.l	rapo,a1
		jsr	-60(a6)
		rts



OpenLib:	lea	intuitext,a1
		Exec	OldOpenLibrary
		move.l	d0,_IntuitionBase

		lea	gfxtext,a1
		Last	OldOpenLibrary
		move.l	d0,GFXBase

		lea	dostext,a1
		Last	OldOpenLibrary
		move.l	d0,_DOSBase
		rts


CloseLib:	move.l	_IntuitionBase,a1
		Exec	CloseLibrary

		move.l	GFXBase,a1
		Last	CloseLibrary

		move.l	_DOSBase,a1
		Last	CloseLibrary
		rts



replymsg:	move.l	message,a1
		Exec	ReplyMsg
		rts



initcolors:	move.l	GFXBase,a6	; Farben initialisieren
		move.l	viewport,a0
		lea	colorbuf,a1
		moveq	#16,d0	
		jmp	-192(a6)



colorblack:	move.l	GFXBase,a6	; Farben initialisieren
		move.l	viewport,a0
		lea	colorbuf2,a1
		moveq	#16,d0	
		jmp	-192(a6)



getrapo:	move.l	Screen,a3	; Rastport bestimmen
		add.l	#$54,a3
		move.l	A3,rapo

		move.l	Screen,a3	; Viewport bestimmen
		add.l	#$2c,a3
		move.l	a3,viewport
		rts



entpack:	move.l	bitmstr,a0
		move.l	ifffile,a1
		bsr	@DecodePic

		lea	colorbuf,a0
		move.l	ifffile,a1
		bsr	@GetColorTab

		rts



**********************************************************************************
* File abspeichern
* A0 = Name
* A1 = Buffer
* D0 = Gr�sse
**********************************************************************************

SaveFile:	movem.l	d0-d7/a0-a6,-(sp)

		move.l	d0,d6			* Size
		move.l	a1,a4

		move.l	a0,d1
		move.l	#1006,d2
		DOS	Open
		move.l	d0,d7
		bne	1$


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
* D0 = Gr�sse
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

		move.l	d7,d1
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





		SECTION	Daten,DATA


NewWindow:	dc.w	0,0		;start-position
		dc.w	640,200		;breite und hoehe
		dc.b	0,1		;farbe fuer menue und gadgets
		dc.l	$0168		;IDCMP - Flags
		dc.l	$1804		;Aussehen des Windows
		dc.l	gadgetlist	;pointer zu speziellem gadget
		dc.l	0		;pointer zu user check mark
		dc.l	0		;pointer zum title
Scr:		dc.l	0		;pointer zum Screen 0=A-Dos 
		dc.l	0		;pointer zu superbitmap
		dc.w	0,0		;kleinste groesse
		dc.w	0,0		;groesste Groesse
		dc.w	$000f		;Screen type


NewScreen:	dc.w	0,0		;x,y
		dc.w	640		;Breite
		dc.w	200		;Hoehe
		dc.w	4		;Anzahl Bitplanes
		dc.b	3,0		;Farben fuer Menuebalken und Gadgets
		dc.w	$8000		;Viewmode
		dc.w	$008f		;Screentype
		dc.l	0		;Zeiger auf Zeichensatz
		dc.l	0		;Zeiger auf Title
		dc.l	0		;Zeiger auf spez.Gadgets
		dc.l	0   		;Zeiger auf eigene Bitmap-Structur

		dc.l	0	;;;	ScrTags

ScrTags:	dc.l	$80000000+32+$1a,MyPens
		dc.l	0,0

MyPens:		dc.l	-1,0



NULL:		EQU	$0	; Equates fuer PowerWindow
MENUENABLED:	EQU	$1
ITEMTEXT:	EQU	$2
ITEMENABLED:	EQU	$10
HIGHCOMP:	EQU	$40
RP_COMPLEMENT:	EQU	$1

GADGHCOMP:	EQU	0
GADGHBOX:	EQU	1
RELVERIFY:	EQU	1
BOOLGADGET:	EQU	1
RP_JAM1:	EQU	0
RP_JAM2:	EQU	1



MenuList:
Menu1:
		dc.l	Menu2	;next Menu structure
		dc.w	0,0	;Xft
		dc.w	75,0	;Menu hit box width and height
		dc.w	MENUENABLED	;Menu flags
		dc.l	Menu1Name	;text of Menu name
		dc.l	MenuItem1	;MenuItem linked list pointer
		dc.w	0,0,0,0	;Intuition mystery variables
Menu1Name:
		dc.b	'Project',0


	CNOP 0,2

MenuItem1:
		dc.l	MenuItem2	;next MenuItem structure
		dc.w	0,0	;rent hitbox
		dc.w	112,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excludes a same-level Item
		dc.l	IText1	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'O'	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;SubItem list
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText1:
		dc.b	3,1,RP_COMPLEMENT,0	;ens, drawmode and fill byte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText1	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText1:
		dc.b	'Load',0

	CNOP 0,2

MenuItem2:
		dc.l	MenuItem4
		dc.w	0,11	
		dc.w	112,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excludes a same-level Item
		dc.l	IText2	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'W'	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;SubItem list
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText2:
		dc.b	3,1,RP_COMPLEMENT,0	;frens, drawmode and fill byte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText2	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText2:
		dc.b	'Save',0

	CNOP 0,2    

MenuItem4:
		dc.l	MenuItem5	;next MenuItem structure
		dc.w	0,22	;XY of Item hitbox TopLeft of parent hitbox
		dc.w	112,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excludes a same-level Item
		dc.l	IText4	;Item render  (IntuText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'?'	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;SubItem list
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText4:
		dc.b	3,1,RP_COMPLEMENT,0	;fronde and fill byte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText4	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText4:
		dc.b	'About',0
	
		CNOP 0,2    

MenuItem5:
		dc.l	NULL	;next MenuItem structure
		dc.w	0,33	;XY of Item hitbox rearent hitbox
		dc.w	112,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excludes a same-level Item
		dc.l	IText5	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'Q'	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;SubItem list
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText5:
		dc.b	3,1,RP_COMPLEMENT,0	;front mode and fill byte
		dc.w	1,1	;XY origin relative to tainer TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText5	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText5:
		dc.b	'Quit',0


	CNOP 0,2    

Menu2:
		dc.l	NULL	;next Menu structure
		dc.w	81,0	;XY origin of Menu to Screen TopLeft
		dc.w	57,0	;Menu hit box width and height
		dc.w	MENUENABLED	;Menu flags
		dc.l	Menu2Name	;text of Menu name
		dc.l	MenuItem7	;MenuItem linked list pointer
		dc.w	0,0,0,0	;Intuition mystery variables
Menu2Name:
		dc.b	'Level',0
	
		CNOP 0,2    

MenuItem7:
		dc.l	MenuItem8	;next MenuItem structure
		dc.w	0,0	;XY of Item hitbox relteft of parent hitbox
		dc.w	86,10	
		dc.w	ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-ecludes a same-level Item
		dc.l	IText7	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render	
		dc.b	NULL	;altand-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;SubItem list
		dc.w	$FFFF	;filled in by Intuitiorag selections
IText7:
		dc.b	3,1,RP_COMPLEMENT,0	;mode and fill byte
		dc.w	1,1	;XY origin relatiTopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText7	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText7:
		dc.b	'Clear',0
	
		CNOP 0,2    
	
MenuItem8:
		dc.l	MenuItem9	;next MenuItem structure
		dc.w	0,11	;XY of Item hitbox TopLeft of parent hitbox
		dc.w	86,10	;hit box width and t
		dc.w	ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excludes a same-level Item
		dc.l	IText8	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	NULL	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	SubItem1	;SubItem list
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText8:
		dc.b	3,1,RP_COMPLEMENT,0	;t pens, drawmode anbyte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText8	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText8:
		dc.b	'Scroll',0
	
		CNOP 0,2    
	
SubItem1:
		dc.l	SubItem2	;next SubItem structure
		dc.w	50,0	;XY of Item hitboxe to parent hitbox
		dc.w	92,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excevel Item
		dc.l	IText9	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'U'	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;no SubItem list for SubItems
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText9:
		dc.b	3,1,RP_COMPLEMENT,0	;front annd fill byte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText9	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText9:
		dc.b	'Up',0
	
		CNOP 0,2    
	
SubItem2:
		dc.l	SubItem3	;next SubItem structure
		dc.w	50,10	;XY of Item hitbox rf parent hitbox
		dc.w	92,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excluvel Item
		dc.l	IText10	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'D'	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;no SubItem list for SubItems
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText10:
		dc.b	3,1,RP_COMPLEMENT,0	;frontand fill byte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText10	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText10:
		dc.b	'Down ',0
	
		CNOP 0,2    

SubItem3:
		dc.l	SubItem4	;next SubItem structure
		dc.w	50,20	;XY of Item hitbox relparent hitbox
		dc.w	92,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excludes a same-level Item
		dc.l	IText11	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'L'	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;no SubItem list for SubItems
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText11:
		dc.b	3,1,RP_COMPLEMENT,0	;front arawmode and fill byte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText11	;pointer to tex
		dc.l	NULL	;next IntuiText structure
ITextText11:
		dc.b	'Left',0
	
		CNOP 0,2    

SubItem4:
		dc.l	NULL	;next SubItem structure
		dc.w	50,30	;XY of Item hitbox  parent hitbox
		dc.w	92,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excludes a same-level Item
		dc.l	IText12	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'R'	;alternate command-key
		dc.b	0	;fill byte
		dc.l	NULL	;no SubItem list for SubItems
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText12:
		dc.b	3,1,RP_COMPLEMENT,0	;frontrawmode and fill byte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText12	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText12:
		dc.b	'Right',0
	
		CNOP 0,2    

MenuItem9:
		dc.l	NULL	;next MenuItem structure
		dc.w	0,22	;XY of Item hitboxrent hitbox
		dc.w	92,10	
		dc.w	4+ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
		dc.l	0	;each bit mutually-excludes a same-level Item
		dc.l	IText13	;Item render  (IntuiText or Image or NULL)
		dc.l	NULL	;Select render
		dc.b	'Q'	;alternate command-key
		dc.b	NULL	;fill byte
		dc.l	NULL	;SubItem list
		dc.w	$FFFF	;filled in by Intuition for drag selections
IText13:
		dc.b	3,1,RP_COMPLEMENT,0	;front ande and fill byte
		dc.w	1,1	;XY origin relative to container TopLeft
		dc.l	NULL	;font pointer or NULL for defaults
		dc.l	ITextText13	;pointer to text
		dc.l	NULL	;next IntuiText structure
ITextText13:
		dc.b	'Undo',0
	
		CNOP 0,2    


gadgetlist:
Gadget1:
		dc.l	Gadget14 ;(HITS)
		dc.w	478,112	
		dc.w	35,16	
		dc.w	$2	
		dc.w	1	
		dc.w	1	
		dc.l	Border31
		dc.l	border32;alternate imagery for selection
		dc.l	0   	;first IntuiText structure
		dc.l	0   	
		dc.l	0	
		dc.w	1	
		dc.l	0   	

Gadget14:
		dc.l	Gadget2	 ;(HITS)
		dc.w	587,112	
		dc.w	35,16	
		dc.w	$2	
		dc.w	1	
		dc.w	1	
		dc.l	Border41
		dc.l	Border42;alternate imagery for selection
		dc.l	0   	;first IntuiText structure
		dc.l	0   	
		dc.l	0	
		dc.w	0	
		dc.l	0   	

Gadget2:
		dc.l	Gadget3	 ;(COLOR)
		dc.w	485,164	;orelative to Window TopLeft
		dc.w	115,15	
		dc.w	2    	
		dc.w	1     	
		dc.w	1     	
		dc.l	Border21
		dc.l	border22;alternate imagery for selection
		dc.l	0   	;first IntuiText structure
		dc.l	0   	
		dc.l	0   	
		dc.w	2	
		dc.l	0   	
Border21:
		dc.w	2,0	;boe to container TopLeft
		dc.b	0,0,0   ;front pen, back pen and drawmode
		dc.b	9	;number of XY vectors
		dc.l	BorderVectors21	;pointer to XY vectors
		dc.l	0   	;next border in list
BorderVectors21:
		dc.w 5,1	
		dc.w 105,1
		dc.w 109,3
		dc.w 109,12
		dc.w 104,14
		dc.w 5,14
		dc.w 1,12
		dc.w 1,3
		dc.w 5,1

border22:
		dc.w	2,0	;boe to container TopLeft
		dc.b	3,0,0   ;front pen, back pen and drawmode
		dc.b	9	;number of XY vectors
		dc.l	BorderVectors21	;pointer to XY vectors
		dc.l	0   	;next border in list

	
Gadget3:
		dc.l	Gadget4	 ;(LEVEL <)
		dc.w	478,138
		dc.w	22,16	
		dc.w	2
		dc.w	1
		dc.w	1
		dc.l	Border31
		dc.l	border32
		dc.l	0
		dc.l	0
		dc.l	0
		dc.w	3
		dc.l	0
Border31:
		dc.w	-1,-1
		dc.b	2,0,1
		dc.b	7
		dc.l	BorderVectors31
		dc.l	0
BorderVectors31:
		dc.w	13,3
		dc.w	18,3
		dc.w	18,14
		dc.w	14,14
		dc.w 	5,10
		dc.w 	5,7
		dc.w 	14,3
border32:
		dc.w	-1,-1	;botive to container TopLeft
		dc.b	3,0,1   ;front pen, back pen and drawmode
		dc.b	7	;number of XY vectors
		dc.l	BorderVectors31	;pointer to XY vectors
		dc.l	0   	;next border in list

Gadget4:
		dc.l	Gadget5	 ;(LEVEL >)
		dc.w	586,138	;hit box relative to Window TopLeft
		dc.w	22,16	
		dc.w	2 	
		dc.w	1	
		dc.w	1	
		dc.l	Border41
		dc.l	Border42;alternate imagery for selection
		dc.l	0	;first IntuiText structure
		dc.l	0	
		dc.l	0	
		dc.w	0	
		dc.l	0   	
Border41:
		dc.w	0,0	;rigin relative to container TopLeft
		dc.b	2,0,1  	;front pen, back pen and drawmode
		dc.b	7	;number of XY vectors
		dc.l	BorderVectors41	;pointer to XY vectors
		dc.l	0   	;next border in list
BorderVectors41:
		dc.w	4,2
		dc.w	8,2
		dc.w	17,6
		dc.w	17,9
		dc.w 	8,13
		dc.w	4,13
		dc.w	4,2
Border42:
		dc.w	0,0	; relative to container TopLeft
		dc.b	3,0,1  	;front pen, back pen and drawmode
		dc.b	7	;number of XY vectors
		dc.l	BorderVectors41	;pointer to XY vectors
		dc.l	0   	;next border in list

Gadget5:
		dc.l	Gadget6	
		dc.w	480,16	;origin XY of hit box relWindow TopLeft
		dc.w	38,11	
		dc.w	$2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border51
		dc.l	Border52	;alternate imagery for selection
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	1	
		dc.l	NULL	
Border51:
		dc.w	4,2	
		dc.b	11,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Border52:
		dc.w	4,2	
		dc.b	1,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in listBorder51:
	
Gadget6:
		dc.l	Gadget7	
		dc.w	524,16	;o of hit box relative to Window TopLeft
		dc.w	38,11	
		dc.w	$2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border61
		dc.l	Border62;alternate imagery for selection
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	2	
		dc.l	NULL	
Border61:
		dc.w	4,2	
		dc.b	10,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Border62:
		dc.w	4,2	
		dc.b	1,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in listBorder61:
Gadget7:
		dc.l	Gadget8	
		dc.w	568,16	;orY of hit box relative to Window TopLeft
		dc.w	38,11	
		dc.w	$2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border71
		dc.l	border72	;alternate imagery for selection
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	3	
		dc.l	NULL	
Border71:
		dc.w	4,2	
		dc.b	9,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
border72:
		dc.w	4,2	
		dc.b	1,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in listBorder71	
Gadget8:
		dc.l	Gadget9	
		dc.w	480,28	;origin XY of hit box relative to Window TopLeft
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border81	
		dc.l	Border82	;alternate imagery for selection
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	4	
		dc.l	NULL	
Border81:
		dc.w	4,2	
		dc.b	8,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Border82:
		dc.w	4,2	
		dc.b	1,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in listBorder81:


Gadget9:
		dc.l	Gadget10	
		dc.w	524,28	;origin XY of hit box relative to Window TopLeft
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border91
		dc.l	Border92;alternate imagery for selection
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	5	
		dc.l	NULL	
Border91:
		dc.w	4,2	
		dc.b	13,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Border92:
		dc.w	4,2	
		dc.b	1,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in listBorder91:
	
Gadget10:
		dc.l	Gadget11	
		dc.w	568,28	;origin XY of hto Window TopLeft
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border101	
		dc.l	Border102	;alternate imagery for selection
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	6	
		dc.l	NULL	
Border101:
		dc.w	4,2	
		dc.b	12,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Border102:
		dc.w	4,2	
		dc.b	1,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Gadget11:
		dc.l	Gadget12
		dc.w	480,40	;origin XY of hit box relative to Window TopLeft
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border111	
		dc.l	Border112	;alternate imagery for selection
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	7	
		dc.l	NULL	
Border111:
		dc.w	4,2	
		dc.b	14,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Border112:
		dc.w	4,2	
		dc.b	1,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Gadget12:
		dc.l	Gadget13
		dc.w	524,40	;
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border121
		dc.l	Border122;alternate imagery for selection
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	8	
		dc.l	NULL	
Border121:
		dc.w	4,2	
		dc.b	15,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list
Border122:
		dc.w	4,2	
		dc.b	1,0,0	;front pen, back pen and drawmode
		dc.b	17	;number of XY vectors
		dc.l	BorderVectors121;pointer to XY vectors
		dc.l	NULL	;next border in list


BorderVectors121:
		dc.w	2,0
		dc.w	28,0
		dc.w	30,2
		dc.w	30,4
		dc.w	28,6
		dc.w	2,6
		dc.w	0,4
		dc.w	0,2
		dc.w	2,0
		dc.w	27,0
		dc.w	29,2
		dc.w	29,4
		dc.w	27,6
		dc.w	3,6
		dc.w	1,4
		dc.w	1,2
		dc.w	3,0
Gadget13:
		dc.l	LaserGadg
		dc.w	567,40	;
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border131
		dc.l	Border132
		dc.l	NULL	;first IntuiText structure
		dc.l	NULL	
		dc.l	NULL	
		dc.w	8	
		dc.l	NULL	
Border131:
		dc.w	-1,-1	
		dc.b	0,0,RP_JAM1
		dc.b	5
		dc.l	BorderVectors131
		dc.l	0
BorderVectors131:
		dc.w	6,3
		dc.w	34,3
		dc.w	34,10
		dc.w	6,10
		dc.w	6,3
Border132:
		dc.w	-1,-1	
		dc.b	1,0,RP_JAM1
		dc.b	5
		dc.l	BorderVectors131
		dc.l	0
LaserGadg:
		dc.l	LivesGadg
		dc.w	480,64
		dc.w	38,11
		dc.w	$2
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border211
		dc.l	Border212	
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	1	
		dc.l	0	

LivesGadg:
		dc.l	ExtGadg
		dc.w	524,64
		dc.w	38,11	
		dc.w	$2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border211
		dc.l	Border212
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	2	
		dc.l	0	

ExtGadg:
		dc.l	HoldGadg
		dc.w	568,64	;orY of hit box relative to Window TopLeft
		dc.w	38,11	
		dc.w	$2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border211
		dc.l	Border212	
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	3	
		dc.l	0	

HoldGadg:
		dc.l	AutoGadg
		dc.w	480,76	;origin XY of hit box relative to Window TopLeft
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border211	
		dc.l	Border212	
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	4	
		dc.l	0	

AutoGadg:
		dc.l	BonusGadg	
		dc.w	524,76
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border211
		dc.l	Border212
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	5	
		dc.l	0	

BonusGadg:
		dc.l	LevelGadg	
		dc.w	568,76
		dc.w	38,11
		dc.w	2
		dc.w	RELVERIFY
		dc.w	BOOLGADGET
		dc.l	Border211
		dc.l	Border212	
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	6	
		dc.l	0	

LevelGadg:
		dc.l	ThreeGadg
		dc.w	480,88
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border211	
		dc.l	Border212	
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	7	
		dc.l	0	

ThreeGadg:
		dc.l	SurpriseGadg
		dc.w	524,88
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border211	
		dc.l	Border212	
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	6	
		dc.l	0	

SurpriseGadg:
		dc.l	0
		dc.w	568,88
		dc.w	38,11	
		dc.w	2 	
		dc.w	RELVERIFY	
		dc.w	BOOLGADGET	
		dc.l	Border211	
		dc.l	Border212	
		dc.l	0	 
		dc.l	0	
		dc.l	0	
		dc.w	6	
		dc.l	0	

Border211:
		dc.w	4,2	
		dc.b	0,0,0
		dc.b	17
		dc.l	BorderVectors121
		dc.l	NULL
Border212:
		dc.w	4,2	
		dc.b	2,0,0
		dc.b	17
		dc.l	BorderVectors121
		dc.l	NULL



crequester:	dc.l 0
		dc.w 160,20
		dc.w 200,140
		dc.w 0,0
		dc.l propgadget1
		dc.l crborder1
		dc.l crtext
		dc.w 0
		dc.b 0
		dc.b 0	
		dc.l 0
	;;	blk 32,0
	;;	ds.b	32
		REPT	32
		 dc.b	0
		ENDR
		dc.l 0
		dc.l 0
		REPT	36
		 dc.b	0
		ENDR
	;;	blk 36,0
	;;	ds.b	36

propgadget1:
		dc.l	propgadget2
		dc.w	20,30
		dc.w	16,80
		dc.w	0
		dc.w	2
		dc.w	$1003
		dc.l	pBorder1
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	propinfo1
		dc.w	1
		dc.l	0
propinfo1:
		dc.w 5
		dc.w 0		; X Koord
		dc.w 0		; Y Koord
		dc.w $ffff	; Verhaeltniss X
		dc.w $1111	; Verhaeltniss Y
		dc.w 0,0,0,1,0,0

propgadget2:
		dc.l	propgadget3
		dc.w	38,30	;o XY of hit box relative to Window TopLeft
		dc.w	16,80	
		dc.w	0	
		dc.w	2	;activation flags
		dc.w	$1003	
		dc.l	pBorder2
		dc.l	0	;alternate imagery for selection
		dc.l	0	;first IntuiText structure
		dc.l	0	
		dc.l	propinfo2;ecialInfo structure for string gadgets
		dc.w	1	
		dc.l	0	
propinfo2:
		dc.w 5
		dc.w 0		; X Koord
		dc.w $ffff	; Y Koord
		dc.w $ffff	; Verhaeltniss X
		dc.w $1111	; Verhaeltniss Y
		dc.w 0,0,0,1,0,0
propgadget3:
		dc.l	color1
		dc.w	56,30
		dc.w	16,80
		dc.w	0
		dc.w	2
		dc.w	$1003
		dc.l	pBorder3
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	propinfo3
		dc.w	1
		dc.l	0
propinfo3:
		dc.w 5
		dc.w 0		; X Koord
		dc.w $ffff	; Y Koord
		dc.w $ffff	; Verhaeltniss X
		dc.w $1111	; Verhaeltniss Y
		dc.w 0,0,0,1,0,0
pBorder1:
		dc.w	-2,-1	;border XY in relative to container TopLeft
		dc.b	2,0,0	;front pen, back pen and drawmode
		dc.b	5	;number of XY vectors
		dc.l	pBorderVectors1	;pointer to XY vectors
		dc.l	0	;next border in list
pBorderVectors1:
		dc.w	0,0
		dc.w	18,0
		dc.w	18,85
		dc.w	0,85
		dc.w	0,0
pBorder2:
		dc.w	-2,-1	;border XY in relative to container TopLeft
		dc.b	2,0,0	;front pen, back pen and drawmode
		dc.b	5	;number of XY vectors
		dc.l	pBorderVectors2	;pointer to XY vectors
		dc.l	0	;next border in list
pBorderVectors2:
		dc.w	0,0
		dc.w	18,0
		dc.w	18,26
		dc.w	0,26
		dc.w	0,0
pBorder3:
		dc.w	-2,-1	;border XY in relative to container TopLeft
		dc.b	2,0,0	;front pen, back pen and drawmode
		dc.b	5	;number of XY vectors
		dc.l	pBorderVectors3	;pointer to XY vectors
		dc.l	0	;next border in list
pBorderVectors3:
		dc.w	0,0
		dc.w	18,0
		dc.w	18,26
		dc.w	0,26
		dc.w	0,0


color1:
		dc.l	color2
		dc.w	106,32
		dc.w	32,8
		dc.w	1	
		dc.w	1	
		dc.w	$1001	
		dc.l	cborder4
		dc.l	0	;alternate imagery for selection
		dc.l	0	;first IntuiText structure
		dc.l	0	
		dc.l	0	;SpecialInfo structure for string gadgets
		dc.w	0	
		dc.l	0	
color2:
		dc.l	color3	
		dc.w	146,32
		dc.w	32,8	
		dc.w	1	
		dc.w	1	
		dc.w	$1001	
		dc.l	cborder3
		dc.l	0	;alternate imagery for selection
		dc.l	0	;first IntuiText structure
		dc.l	0	
		dc.l	0	
		dc.w	2	
		dc.l	0	
color3:
		dc.l	color4	
		dc.w	106,44
		dc.w	32,8
		dc.w	1	
		dc.w	1	
		dc.w	$1001	
		dc.l	cborder2
		dc.l	0	;alternate imagery for selection
		dc.l	0	;first IntuiText structure
		dc.l	0	
		dc.l	0	
		dc.w	3	
		dc.l	0	
color4:
		dc.l	color5	
		dc.w	146,44
		dc.w	32,8
		dc.w	1	
		dc.w	1	
		dc.w	$1001	
		dc.l	cborder1
		dc.l	0	;alternate imagery for selection
		dc.l	0	;first IntuiText structure
		dc.l	0	
		dc.l	0	
		dc.w	4	
		dc.l	0	
color5:
		dc.l	color6	
		dc.w	106,56
		dc.w	32,8
		dc.w	1	
		dc.w	1	
		dc.w	$1001	
		dc.l	cborder6
		dc.l	0	;alternate imagery for selection
		dc.l	0	;first IntuiText structure
		dc.l	0	
		dc.l	0	
		dc.w	5	
		dc.l	0	
color6:
		dc.l	copycolor
		dc.w	146,56	
		dc.w	32,8
		dc.w	1
		dc.w	1
		dc.w	$1001
		dc.l	cborder5
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.w	6
		dc.l	0
copycolor:
		dc.l	excolor
		dc.w	108,75
		dc.w	70,14	
		dc.w	2
		dc.w	1	
		dc.w	$1001	
		dc.l	lrgborder1
		dc.l	lrgborder2
		dc.l	copytext
		dc.l	0	
		dc.l	0	
		dc.w	7	
		dc.l	0	

excolor:
		dc.l	defaultcolors
		dc.w	108,95	;Window TopLeft
		dc.w	70,14	
		dc.w	2	
		dc.w	1	
		dc.w	$1001	
		dc.l	lrgborder1
		dc.l	lrgborder2
		dc.l	extext
		dc.l	0	
		dc.l	0	
		dc.w	8	
		dc.l	0	
defaultcolors:
		dc.l	continuecol
		dc.w	108,115
		dc.w	70,14
		dc.w	2
		dc.w	1
		dc.w	$1001
		dc.l	lrgborder1
		dc.l	lrgborder2	;alternate imagery for selection
		dc.l	deftext	;first IntuiText structure
		dc.l	0	
		dc.l	0	
		dc.w	9	
		dc.l	0	

continuecol:
		dc.l	0
		dc.w	16,115
		dc.w	70,14
		dc.w	2
		dc.w	1
		dc.w	$1001	
		dc.l	lrgborder1
		dc.l	lrgborder2
		dc.l	conttext
		dc.l	0
		dc.l	0
		dc.w	10
		dc.l	0

conttext:
		dc.b 2,0,0,0
		dc.w 2,3
		dc.l 0,conttext2
		dc.l 0
conttext2:
		dc.b 'Continue',0
	
		CNOP 0,2
	

deftext:
		dc.b 2,0,0,0
		dc.w 6,3
		dc.l 0,deftext2
		dc.l 0
deftext2:
		dc.b 'Default',0
	
		CNOP 0,2
	
copytext:
		dc.b 2,0,0,0
		dc.w 18,3
		dc.l 0,copytext2
		dc.l 0
copytext2:
		dc.b 'Copy',0
	
		CNOP 0,2

extext:
		dc.b 2,0,0,0
		dc.w 2,3
		dc.l 0,extext2
		dc.l 0
extext2:
		dc.b 'Exchange',0
	
		CNOP 0,2

crborder1:
		dc.w 0,0
		dc.b 4,0,0
		dc.b 10
		dc.l cxy1
		dc.l crborder2
cxy1:
		dc.w 0,0
		dc.w 0,139
		dc.w 1,139
		dc.w 1,0
		dc.w 198,0
		dc.w 198,139
		dc.w 199,0
		dc.w 199,139
		dc.w 0,139
		dc.w 0,0
crborder2:
		dc.w 0,0
		dc.b 5,0,0
		dc.b 10
		dc.l cxy2
		dc.l crborder3	
cxy2:
		dc.w 2,1
		dc.w 2,138
		dc.w 3,138
		dc.w 3,1
		dc.w 196,1
		dc.w 196,138
		dc.w 197,1
		dc.w 197,138
		dc.w 2,138
		dc.w 2,1
crborder3:
		dc.w 0,0
		dc.b 6,0,0
		dc.b 10
		dc.l cxy3
		dc.l crborder4	
cxy3:
		dc.w 4,2
		dc.w 4,137
		dc.w 5,137
		dc.w 5,2
		dc.w 194,2
		dc.w 194,137
		dc.w 195,2
		dc.w 195,137
		dc.w 4,137
		dc.w 4,2
crborder4:
		dc.w 0,0
		dc.b 5,0,0,2
		dc.l cxy4
		dc.l crborder5
crborder5:
		dc.w 0,1
		dc.b 6,0,0,2
		dc.l cxy4
		dc.l 0
cxy4:
		dc.w 6,14,193,14


cborder1:
		dc.w 0,0
		dc.b 8,0,0
		dc.b 16
		dc.l cxy11
		dc.l 0
cborder2:
		dc.w 0,0
		dc.b 9,0,0
		dc.b 16
		dc.l cxy11
		dc.l 0
cborder3:
		dc.w 0,0
		dc.b 10,0,0
		dc.b 16
		dc.l cxy11
		dc.l 0
cborder4:
		dc.w 0,0
		dc.b 11,0,0
		dc.b 16
		dc.l cxy11
		dc.l 0
cborder5:
		dc.w 0,0
		dc.b 12,0,0
		dc.b 16
		dc.l cxy11
		dc.l 0
cborder6:
		dc.w 0,0
		dc.b 13,0,0
		dc.b 16
		dc.l cxy11
		dc.l 0

cxy11:
		dc.w 0,0,32,0,0,1,32,1,0,2,32,2,0,3,32,3,0,4,32,4,0,5,32,5
		dc.w 0,6,32,6,0,7,32,7,0,8,32,8
	
crtext:
		dc.b 2,0,0,0
		dc.w 68,5
		dc.l 0
		dc.l crtext11
		dc.l crtext2
crtext11:
		dc.b 'COLORS',0

		CNOP 0,2
crtext2:
		dc.b 2,0,0,0
		dc.w 26,20
		dc.l 0
		dc.l crtext21
		dc.l 0
crtext21:
		dc.b 'R G B',0





bodytext:
		dc.b	3,0,0,0
		dc.w	60,6
		dc.l	0
		dc.l	btext
		dc.l	btext2
btext:
		dc.b	'DISK ERROR',0

		CNOP 0,2
btext2:
		dc.b	3,0,0,0
		dc.w	20,15
		dc.l	0
		dc.l	btext21
		dc.l	0
btext21:
		dc.b	'Could not save stage !!',0

		CNOP 0,2
postext:
		dc.b	3,0,0,0
		dc.w	6,3
		dc.l	0
		dc.l	ptext
		dc.l	0
ptext:
		dc.b	'Retry',0

		CNOP 0,2
negtext:
		dc.b	3,0,0,0
		dc.w	6,3
		dc.l	0
		dc.l	ntext
		dc.l	0
ntext:
		dc.b	'Cancel',0

		CNOP 0,2

bodytext2:
		dc.b	3,0,0,0
		dc.w	56,10
		dc.l	0
		dc.l	btext22
		dc.l	0
btext22:
		dc.b	'ARE YOU SURE ?',0
	
		CNOP 0,2

postext2:
		dc.b	3,0,0,0
		dc.w	6,3
		dc.l	0
		dc.l	ptext2
		dc.l	0
ptext2:
		dc.b	'OK',0
	
		CNOP 0,2

negtext2:
		dc.b	3,0,0,0
		dc.w	6,3
		dc.l	0
		dc.l	ntext
		dc.l	0

srequester:
		dc.l	0		; Older Requester
		dc.w	160,50		; linke obere Ecke
		dc.w	320,64		; breite,hoehe
		dc.w	0,0
		dc.l	scancelgadg; gadget
		dc.l	lrborder1	; border
		dc.l	srtext		; text
		dc.w	0		; Flags
		dc.b	0		; Backfill
		dc.b	0	
		dc.l	0		; Layer	
		REPT	32
		 dc.b	0
		ENDR
	;;	blk	32,0		; ReqPad1
	;;	ds.b	32
		dc.l	0		; Bitmap
		dc.l	0		; Window
	;;	blk	36,0		; ReqPad2
	;;	ds.b	36
		REPT	36
		 dc.b	0
		ENDR


srtext:
		dc.b	2,0,0,0
		dc.w	120,5
		dc.l	0
		dc.l	srtext21
		dc.l	lrtext2
srtext21:
		dc.b	'SAVE STAGE',0

		CNOP 0,2

scancelgadg:
		dc.l	savegadg
		dc.w	230,42
		dc.w	70,14
		dc.w	2
		dc.w	1		; Relver.
		dc.w	$1001
		dc.l	lrgborder1
		dc.l	lrgborder2
		dc.l	lrgtext1
		dc.l	0,0,0,0

savegadg:
		dc.l decstage
		dc.w 20,42
		dc.w 70,14
		dc.w 2
		dc.w 1		; Relver.
		dc.w $1001
		dc.l lrgborder1
		dc.l lrgborder2
		dc.l srgtext2
		dc.l 0
		dc.l 0,0,0
srgtext2:
		dc.b 2,0,0,0
		dc.w 18,4
		dc.l 0
		dc.l srgtext21
		dc.l 0
srgtext21:
		dc.b 'SAVE',0



		CNOP 0,2

stagenr:	dc.b 'A',0,0,0



		CNOP 0,2

lrequester:	dc.l 0		; Older Requester
		dc.w 160,50	; linke obere Ecke
		dc.w 320,64	; breite,hoehe
		dc.w 0,0
		dc.l lcancelgadg; gadget
		dc.l lrborder1	; border
		dc.l lrtext	; text
		dc.w 0		; Flags
		dc.b 0		; Backfill
		dc.b 0	
		dc.l 0	
	;;	blk 32,0
	;;	ds.b	32
		REPT	32
		 dc.b	0
		ENDR
		dc.l 0		; Bitmap
		dc.l 0		; Window
		REPT	36
		 dc.b	0
		ENDR
	;;	ds.b		36
	;;	blk 36,0	; ReqPad2


lrtext:		dc.b 2,0,0,0
		dc.w 120,5
		dc.l 0
		dc.l lrtext21
		dc.l lrtext2

lrtext21:	dc.b 'LOAD STAGE',0


		CNOP 0,2

lrtext2:	dc.b 2,0,0,0
		dc.w 112,24
		dc.l 0
		dc.l lrtext22
		dc.l 0
lrtext22:	dc.b 'STAGE :',0
lcancelgadg:
		dc.l loadgadg
		dc.w 230,42
		dc.w 70,14
		dc.w 2
		dc.w 1		; Relver.
		dc.w $1001
		dc.l lrgborder1
		dc.l lrgborder2
		dc.l lrgtext1
		dc.l 0
		dc.l 0,0,0

lrgborder1:
		dc.w -2,-1
		dc.b 4,0,1
		dc.b 5
		dc.l lrgxy1
		dc.l lrgborder12
lrgxy1:
		dc.w 0,0
		dc.w 70,0
		dc.w 70,15
		dc.w 0,15
		dc.w 0,0
lrgborder12:
		dc.w -2,-1
		dc.b 0,0,1
		dc.b 5
		dc.l lrgxy12
		dc.l 0
lrgxy12:
		dc.w -2,-1
		dc.w 72,-1
		dc.w 72,16
		dc.w -2,16
		dc.w -2,-1
lrgborder2:
		dc.w -2,-1
		dc.b 0,0,1
		dc.b 5
		dc.l lrgxy1
		dc.l lrgborder21

lrgborder21:
		dc.w -2,-1
		dc.b 2,0,1
		dc.b 5
		dc.l lrgxy12
		dc.l 0
lrgtext1:
		dc.b 2,0,0,0
		dc.w 11,3
		dc.l 0
		dc.l lrgtext11
		dc.l 0
lrgtext11:
		dc.b 'Cancel',0

		CNOP 0,2

lrborder1:
		dc.w 0,0
		dc.b 4,0,0
		dc.b 10
		dc.l lxy1
		dc.l lrborder2
lxy1:
	dc.w 0,0
	dc.w 0,63
	dc.w 1,63
	dc.w 1,0
	dc.w 318,0
	dc.w 318,63
	dc.w 319,0
	dc.w 319,63
	dc.w 0,63
	dc.w 0,0
lrborder2:
	dc.w 0,0
	dc.b 5,0,0
	dc.b 10
	dc.l lxy2
	dc.l lrborder3	
lxy2:
	dc.w 2,1
	dc.w 2,62
	dc.w 3,62
	dc.w 3,1
	dc.w 316,1
	dc.w 316,62
	dc.w 317,1
	dc.w 317,62
	dc.w 2,62
	dc.w 2,1
lrborder3:
	dc.w 0,0
	dc.b 6,0,0
	dc.b 10
	dc.l lxy3
	dc.l lborder4	
lxy3:
	dc.w 4,2
	dc.w 4,61
	dc.w 5,61
	dc.w 5,2
	dc.w 314,2
	dc.w 314,61
	dc.w 315,2
	dc.w 315,61
	dc.w 4,61
	dc.w 4,2
lborder4:
	dc.w 0,0
	dc.b 5,0,0,2
	dc.l lxy4
	dc.l lborder5
lborder5:
	dc.w 0,1
	dc.b 6,0,0,2
	dc.l lxy4
	dc.l 0
lxy4:
	dc.w 6,14,313,14

loadgadg:
	dc.l decstage
	dc.w 20,42
	dc.w 70,14
	dc.w 2
	dc.w 1		; Relver.
	dc.w $1001
	dc.l lrgborder1
	dc.l lrgborder2
	dc.l lrgtext2
	dc.l 0
	dc.l 0,0,0
lrgtext2:
	dc.b 2,0,0,0
	dc.w 18,4
	dc.l 0
	dc.l lrgtext21
	dc.l 0
lrgtext21:
	dc.b 'LOAD',0

	CNOP 0,2

decstage:
	dc.l incstage
	dc.w 20,22
	dc.w 70,14
	dc.w 2
	dc.w 1		; Relver.
	dc.w $1001
	dc.l lrgborder1
	dc.l lrgborder2
	dc.l ldectext2
	dc.l 0
	dc.l 0,0,0
ldectext2:
	dc.b 2,0,0,0
	dc.w 32,4
	dc.l 0
	dc.l ldectext21
	dc.l 0
ldectext21:
	dc.b '-',0

	CNOP 0,2

incstage:
	dc.l 0
	dc.w 230,22
	dc.w 70,14
	dc.w 2
	dc.w 1		; Relver.
	dc.w $1001
	dc.l lrgborder1
	dc.l lrgborder2
	dc.l linctext2
	dc.l 0
	dc.l 0,0,0
linctext2:
	dc.b 2,0,0,0
	dc.w 32,4
	dc.l 0
	dc.l linctext21
	dc.l 0
linctext21:
	dc.b '+',0

	CNOP 0,2




requester:	dc.l 0		; Older Requester
		dc.w 120,40	; linke obere Ecke
		dc.w 400,120	; breite,hoehe
		dc.w 0,0
		dc.l rgadget	; gadget
		dc.l rborder1	; border
		dc.l rtext	; text
		dc.w 0		; Flags
		dc.b 0		; Backfill
		dc.b 0	
		dc.l 0		; Layer	
	;;	blk 32,0	; ReqPad1
	;;	ds.b	32
		REPT	32
		 dc.b	0
		ENDR
		dc.l 0		; Bitmap
		dc.l 0		; Window
	;;	blk 36,0	; ReqPad2
	;;	ds.b	36
		REPT	36
		 dc.b	0
		ENDR

rgadget:	dc.l 0
		dc.w 150,90
		dc.w 100,14
		dc.w 2
		dc.w 4		; Relver. + Endgadget
		dc.w $1001
		dc.l rgborder1
		dc.l rgborder2
		dc.l rgtext1
		dc.l 0
		dc.l 0,0,0

rgborder1:	dc.w -2,-1
		dc.b 4,0,1
		dc.b 5
		dc.l rgxy1
		dc.l rgborder12

rgxy1:		dc.w 0,0
		dc.w 100,0
		dc.w 100,15
		dc.w 0,15
		dc.w 0,0
rgborder12:
		dc.w -2,-1
		dc.b 0,0,1
		dc.b 5
		dc.l rgxy12
		dc.l 0
rgxy12:
		dc.w -2,-1
		dc.w 102,-1
		dc.w 102,16
		dc.w -2,16
		dc.w -2,-1
rgborder2:
		dc.w -2,-1
		dc.b 0,0,1
		dc.b 5
		dc.l rgxy2
		dc.l rgborder21
rgxy2:
		dc.w 0,0
		dc.w 100,0
		dc.w 100,15
		dc.w 0,15
		dc.w 0,0
rgborder21:
		dc.w -2,-1
		dc.b 2,0,1
		dc.b 5
		dc.l rgxy21
		dc.l 0
rgxy21:
		dc.w -2,-1
		dc.w 102,-1
		dc.w 102,16
		dc.w -2,16
		dc.w -2,-1
rgtext1:
		dc.b 2,0,0,0
		dc.w 18,3
		dc.l 0
		dc.l rgtext11
		dc.l 0

rgtext11:	dc.b 'Continue',0



		CNOP 0,2

rborder1:	dc.w 0,0
		dc.b 4,0,0
		dc.b 10
		dc.l xy1
		dc.l rborder2
xy1:
		dc.w 0,0
		dc.w 0,119
		dc.w 1,119
		dc.w 1,0
		dc.w 398,0
		dc.w 398,119
		dc.w 399,0
		dc.w 399,119
		dc.w 0,119
		dc.w 0,0
rborder2:
		dc.w 0,0
		dc.b 5,0,0
		dc.b 10
		dc.l xy2
		dc.l rborder3	
xy2:
		dc.w 2,1
		dc.w 2,118
		dc.w 3,118
		dc.w 3,1
		dc.w 396,1
		dc.w 396,118
		dc.w 397,1
		dc.w 397,118
		dc.w 2,118
		dc.w 2,1
rborder3:
		dc.w 0,0
		dc.b 6,0,0
		dc.b 10
		dc.l xy3
		dc.l rborder4	
xy3:
		dc.w 4,2
		dc.w 4,117
		dc.w 5,117
		dc.w 5,2
		dc.w 394,2
		dc.w 394,117
		dc.w 395,2
		dc.w 395,117
		dc.w 4,117	
		dc.w 4,2
rborder4:
		dc.w 0,0
		dc.b 4,0,0
		dc.b 2
		dc.l xy4
		dc.l rborder5
xy4:
		dc.w 89+16,20
		dc.w 296-16,20
rborder5:
		dc.w 0,-1
		dc.b 5,0,0
		dc.b 2
		dc.l xy5
		dc.l 0
xy5:
		dc.w 85+16,20
		dc.w 300-16,20

rtext:
		dc.b 2,0,1,0
		dc.w 106,9
		dc.l 0
		dc.l rtext11
		dc.l rtext2
rtext11:
		dc.b 'CRACK Playfield-Editor',0

		CNOP 0,2

rtext2:
		dc.b 2,0,1,0
		dc.w 50,32
		dc.l 0
		dc.l rtext21
		dc.l rtext3
rtext21:
		dc.b 'Copyright by LINEL-Switzerland in 1988',0

		CNOP 0,2

rtext3:
		dc.b 2,0,1,0
		dc.w 152,50
		dc.l 0
		dc.l rtext31
		dc.l rtext4
rtext31:
		dc.b 'Programming',0

		CNOP 0,2

rtext4:
		dc.b 2,0,1,0
		dc.w 186,60
		dc.l 0
		dc.l rtext41
		dc.l rtext5
rtext41:
		dc.b 'by',0

		CNOP 0,2

rtext5:
		dc.b 2,0,1,0
		dc.w 152,70
		dc.l 0
		dc.l rtext51
		dc.l 0
rtext51:	dc.b 'Ren� Straub',0
	



plane2:		INCBIN	"back2"
		
zspeicher:	dc.w	3					; Hits
		dc.w	$fff,$ff0,$0f0,$f0f,$0ff,$00f		; Farben 1-6
		REPT	200
		 dc.b	200
		ENDR
	;;	ds.b	200

stufe:		dc.l	1
stufe2:		dc.l	0
newcolor:	dc.l	6

trddevice:	dc.b	'trackdisk.device',0
gfxtext:	dc.b	'graphics.library',0
intuitext:	dc.b	'intuition.library',0
dostext:	dc.b	'dos.library',0
filename:	dc.b	'Gfx/Constr_Pic',0
Stage_File:	dc.b	"Stages/Stage_A",0




		SECTION	ChipDaten,DATA_C

expointer:	dc.w $0000,$0000
		dc.w $E8B8,$E8B8
		dc.w $8520,$8520
		dc.w $C220,$C220
		dc.w $8522,$8522
		dc.w $E8BA,$E8BA
		dc.w $0000,$0000
		dc.w $8AE9,$8AE9
		dc.w $8A49,$8A49
		dc.w $AA4F,$AA4F
		dc.w $AA49,$AA49
		dc.w $FA49,$FA49
		dc.w $0000,$0000
		dc.w $0010,$0000
		dc.w $0039,$0000
		dc.w $001D,$0000
		dc.w $000F,$0000
		dc.w $0007,$0000
		dc.w $001F,$0000
		dc.w $0000,$0000

copypointer:	dc.w $0000,$0000
		dc.w $6CE5,$6CE5
		dc.w $9295,$9295
		dc.w $9295,$9295
		dc.w $92E7,$92E7
		dc.w $9282,$9282
		dc.w $9282,$9282
		dc.w $6C82,$6C82
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $E610,$E600
		dc.w $4939,$4900
		dc.w $491D,$4900
		dc.w $490F,$4900
		dc.w $4907,$4900
		dc.w $461F,$4600
		dc.w $0000,$0000
		dc.w 0,0




		SECTION ConstrBSS,BSS

GFXBase:	ds.l	1
_DOSBase:	ds.l	1
_IntuitionBase:	ds.l	1
Window:		ds.l	1
Screen:		ds.l	1
rapo:		ds.l	1
viewport:	ds.l	1
MsgPort:	ds.l	1	
message:	ds.l	1
class:		ds.l	1
code:		ds.l	1
gadg:		ds.l	1

dist:		ds.l	1
ifffile:	ds.l	1
hspeicher:	ds.l	1

bitplane1:	ds.l	1
bitplane2:	ds.l	1
bitplane3:	ds.l	1
bitplane4:	ds.l	1

bitmstr:	ds.l	1

BlockX:		ds.w	1
BlockY:		ds.w	1
blocknr:	ds.l	1

colorbuf2:	ds.w	32
colorbuf:	ds.w	32

counter:	ds.w	1
MouseX:		ds.w	1
MouseY:		ds.w	1

prefbuffer:
undobuffer:	ds.b	200
StripSet:	ds.b	1
buf:		ds.b	8
