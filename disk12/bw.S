o:
move.l 4,a6
move.l #0,a1
jsr -294(a6)
move.l d0,a4
tst.l 172(a4)
beq wb
bsr main
clr.l d0
rts
wb:
lea 92(a4),a0
jsr -384(a6)
lea 92(a4),a0
jsr -372(a6)
move.l d0,wbmsg
bsr main
move.l 4,a6
jsr -132(a6)
move.l wbmsg,a1
jsr -378(a6)
rts
wbmsg:
dc.l 0

main:
rp_jam1 = 0
boolgadget = 1
relverify = 1
gadghcomp = 0
reserve = 4096
null = 0
menuenabled = 1
;wbenchscreen = $000f
Itemtext = 2
Itemenabled = $10
Highcomp = $80
rp_complement = 1


move.l 4,a6
lea doslib,a1
move.l #33,d0
jsr -552(A6)
cmp.l #0,d0
bne l60
rts
l60:
move.l d0,dosbase
lea gfxlib,a1
jsr -408(A6)
move.l d0,gfxbase
lea intlib,a1
jsr -408(A6)
move.l d0,intbase
bsr off_display
lea newscreen,a0
move.l intbase,a6
jsr -198(a6)
move.l d0,screen
move.l d0,w_screen
add.l #$2c,d0
move.l d0,viewport
add.l #$28,d0
move.l d0,rastport1
move.l viewport,d0
add.l #20,d0
move.l d0,ucop
bsr openwindow
move.l d0,a0
move.l 86(a0),msgport
move.l d0,wi1
bsr setmenue
move.l screen,a0
add.l #$c0,a0
move.l (A0),bitplane1
move.l 4(a0),bitplane2
move.l 8(a0),bitplane3
move.l 12(A0),bitplane4
move.l 16(A0),bitplane5
add.l #400,bitplane1
add.l #400,bitplane2
add.l #400,bitplane3
add.l #400,bitplane4
add.l #400,bitplane5
move.l 4,a6
move.l #$400,d0
move.l #$10003,d1
jsr -198(a6)
move.l d0,chip_block
bsr off_display
move.l #picture,ifffile
move.l #$240000,ifffile
bsr dec
bsr setdefcolors
bsr on_display
bsr ref_gadgets
bra getm
dec:

clr.l d0
move.l ifffile,a0
add.l #12,a0
cmp.l #"BMHD",(A0)+
bne fehler
clr.l d1
move.l (a0)+,d0
move (a0)+,d1
divs#8,d1
swap d1
cmp#0,d1
beq notcor
clr d1
swap d1
addq#1,d1
swap d1
notcor:
swap d1
and.l #$ffff,d1
move d1,bright
move(a0)+,hight
add.l #4,a0
move.b (A0),d2
move.b d2,d1
move d1,bitpl
cmp#6,d1
beq fehler
add.l #2,a0
clr.l d3
move.b (a0),d3
move d3,comp
sub #10,d0
add.l d0,a0
clr.l d0
loop1:
move.l (a0)+,d0
cmp.l #"CMAP",d0
beq w1
bsr icor
bra loop1
w1:
move.l (a0)+,d1
divs #3,d1
sub #1,d1
lea colorbuf,a1
loop2:
clr.l d2
clr.l d3
clr.l d4
move.b (a0)+,d2
move.b (a0)+,d3
move.b (a0)+,d4
muls #$10,d2
divs #$10,d4
add d2,d3
add d4,d3
move d3,(A1)+
dbf d1,loop2
loop3:
cmp.l #"BODY",(a0)+
beq w2
bsr icor
bra loop3
w2:
move.l (a0)+,d0
move.l a0,bodybuffer
tst comp
beq notcomp
move.l a0,a5
add.l d0,a5
decomploop:
move.l bitplane1,a6
move bright,d4
bsr mainloop
cmp#1,bitpl
beq corbitpl
move.l bitplane2,a6
move bright,d4
bsr mainloop
cmp#2,bitpl
beq corbitpl
move.l bitplane3,a6
move bright,d4
bsr mainloop
cmp#3,bitpl
beq corbitpl
move.l bitplane4,a6
move bright,d4
bsr mainloop
cmp#4,bitpl
beq corbitpl
move.l bitplane5,a6
move bright,d4
bsr mainloop
corbitpl:
clr.l d5
move bright,d5
add.l d5,bitplane1
add.l d5,bitplane2
add.l d5,bitplane3
add.l d5,bitplane4
add.l d5,bitplane5
cmp#$ffff,d4
bne decomploop
clr.l d1
clr.l d2
clr.l d3
clr.l d4
move bright,d2
move hight,d1
muls d1,d2
sub.l d2,bitplane1
sub.l d2,bitplane2
sub.l d2,bitplane3
sub.l d2,bitplane4
sub.l d2,bitplane5
clr.l d0
rts
mainloop:
clr.l d3
move.b (a0)+,d1
move.b d1,d3
and.b #$80,d1
cmp.b #$80,d1
beq decrunch
loop5:
move.b (a0)+,(a6)+
subq#1,d4
cmp.l a0,a5
beq picfin
dbra d3,loop5
cmp#0,d4
bne mainloop
clr d4
rts
decrunch:
neg.b d3
move.b (a0)+,d1
and.l #$ff,d3
loop4:
move.b d1,(a6)+
subq#1,d4
dbf d3,loop4
cmp.l a0,a5
beq picfin
cmp#0,d4
bne mainloop
clr d4
rts
icor:
move.l (a0)+,d1
add.l d1,a0
rts
picfin:
move.l #$ffff,d4
rts
notcomp:
move.l bodybuffer,a0
move.l bitplane1,a1
move.l bitplane2,a2
move.l bitplane3,a3
move.l bitplane4,a4
move.l bitplane5,a5
clr.l d0
clr.l d1
move bright,d0
;divs#4,d0
move d0,bright
move hight,d1
subq#1,d1
bloop:
move bright,d0
subq#1,d0
b1:
move (a0)+,(a1)+
dbf d0,b1
cmp#1,bitpl
beq verende
move bright,d0
subq#1,d0
b2:
move (a0)+,(a2)+
dbf d0,b2
cmp#2,bitpl
beq verende
move bright,d0
subq#1,d0
b3:
move (a0)+,(a3)+
dbf d0,b3
cmp#3,bitpl
beq verende
move bright,d0
subq#1,d0
b4:
move (a0)+,(a4)+
dbf d0,b4
cmp#4,bitpl
beq verende
move bright,d0
subq#1,d0
b5:
move (a0)+,(a5)+
dbf d0,b5
verende:
dbf d1,bloop
clr.l d0
rts
fehler:
move#-1,d0
rts
colorbuf:
blk 64,0
bright:
dc.w 0
hight:
dc.w 0
bitpl:
dc.w 0
comp:
dc.w 0
bodybuffer:
dc.l 0
bitplane1:
dc.l $40000
bitplane2:
dc.l $41f40
bitplane3:
dc.l $43e80
bitplane4:
dc.l $45dc0
bitplane5:
dc.l $47d00
ifffile:
dc.l $240000



getm:
bsr getmsg
move.l d0,a0
move.l 20(A0),d0
cmp#$100,d0
beq menupick
cmp#$400,d0
beq rawkey
cmp#$40,d0
beq gadgetup
bsr replymsg
bra getm

gadgetup:
bsr replymsg
bra getm


menupick:
clr.l d0
move 24(A0),d0
cmp #$f840,d0
beq quit
cmp #0,d0
beq w_df0
cmp #$800,d0
beq w_df1
cmp #$f820,d0
beq help
bsr replymsg
bra getm

help:
bsr replymsg
bsr request
mo:
btst#6,$bfe001
bne mo
bsr end_request
bra getm


w_df1:
move.l #1,drive
bra write

w_df0:
clr.l drive

write:
bsr replymsg
clr.l bb_chksum
lea boot_block,a0
move.l a0,a1
add.l #$400,a1
clr.l d0
m:
add.l (A0)+,d0
bcc c
add.l #1,d0
c:
cmp.l a0,a1
bne m
move.l #-1,d1
sub.l d0,d1
move.l d1,bb_chksum
move.l 4,a6
move.l msgport,io_msgport
lea dev,a0
move.l drive,d0
clr.l d1
lea ioreq,a1
jsr -444(a6)
lea boot_block,a0
move.l chip_block,a1
move #255,d7
chip_move:
move.l (a0)+,(a1)+
dbf d7,chip_move

	clr.b disk_error
	lea ioreq,a1
	move #5,28(A1)
	jsr -456(A6)
	lea ioreq,a1
	move #3,28(A1)			;command = 2 (read)
	move.l #$400,36(a1)		;laenge = $10000 Bytes
	move.l chip_block,40(A1)		;Diskbuffer = $50000
	move.l #$00,44(a1)		;Offset = $6e000 (block 880)
	jsr -456(A6)
	move d0,disk_error
	lea ioreq,a1
	move #4,28(a1)
	jsr -456(a6)
	move.b d0,disk_error
	lea ioreq,a1
	move.l #0,36(A1)		;laenge auf 0
	move #9,28(a1)			;Command = Motor on/off
	jsr -456(a6)
	lea ioreq,a1
	jsr -450(a6)
	cmp #0,disk_error
	beq getm
	move.l intbase,a6
	move.l wi1,a0
	lea bodytext,a1
	lea ertext,a3
	move.l #0,a2
	clr.l d0
	clr.l d1
	move.l #140,d2
	move.l #60,d3
	jsr -348(a6)
	bra getm

rawkey:
bsr replymsg
bra getm

on_display:
move#$8100,$dff096
rts

off_display:
move#$100,$dff096
rts

start_int:
move.l 4,a6
lea intnode,a1
move.l #5,d0
jsr -168(A6)
rts

stop_int:
move.l 4,a6
lea intnode,a1
move.l #5,d0
jsr -174(a6)
rts



intcode:
move #0,d0
move#$f00,$dff180
rts


intnode:
dc.l 0,0
dc.b 2,-60
dc.l intname
dc.l 0
dc.l intcode

intname:
dc.b 'vertb.interrupt',0



getmsg:
move.l 4,a6
move.l msgport,a0
jsr -372(A6)
cmp.l #0,d0
beq getmsg

move.l d0,msg
rts

replymsg:
move.l 4,a6
move.l msg,a1
jsr -378(A6)
rts



setdefcolors:
move.l gfxbase,a6
move.l viewport,a0
lea colorbuf,a1
move.l #32,d0
jsr -192(a6)
rts


quit:
bsr replymsg
q:
bsr clearmenue
bsr closewindow
bsr closescreen
move.l 4,a6
move.l chip_block,a1
move.l #$400,d0
jsr -210(a6)
clr.l d0
rts


freemem:
move.l 4,a6
move.l #100000,d0
jsr -210(a6)

move.l #100000,d0
jsr -210(a6)

jsr -210(A6)
rts


setmenue:
move.l intbase,a6
lea menulist,a1
move.l wi1,a0
jsr -264(a6)
rts

clearmenue:
move.l intbase,a6
move.l wi1,a0
jsr -54(a6)
rts


openwindow:
move.l intbase,a6
lea newwindowstructure,a0
jsr -204(a6)
rts

closewindow:
move.l intbase,a6
move.l wi1,a0
jsr -72(a6)
rts

closescreen:
move.l intbase,a6
move.l screen,a0
jsr -66(a6)
rts

ref_gadgets:
move.l intbase,a6
lea gadget1,a0
move.l wi1,a1
move.l #0,a2
jsr -222(a6)
rts


request:
move.l intbase,a6
lea requester,a0
move.l wi1,a1
jsr -240(a6)
rts

end_request:
move.l intbase,a6
lea requester,a0
move.l wi1,a1
jsr -120(a6)
rts



rastport1:
dc.l 0
screen:
dc.l 0
intbase:
dc.l 0
dosbase:
dc.l 0
gfxbase:
dc.l 0

ucop:
dc.l 0
cop:
dc.l 0
chip_block:
dc.l 0
disk_error:
dc.w 0
wi1:
dc.l 0
drive:
dc.l 0
viewport:
dc.l 0
msgport:
dc.l 0
msg:
dc.l 0


newscreen:
dc.w 0,0
dc.w 320,256
dc.w 5
dc.b 0,1
mode:
dc.w $0000
dc.w $000f
dc.l 0
dc.l screentitle
dc.l 0
dc.l 0

screentitle:
dc.b 'U.S.I Bootwriter',0

doslib:
dc.b 'dos.library',0
intlib:
dc.b 'intuition.library',0
gfxlib:
dc.b 'graphics.library',0


propinfo1:
dc.w 11
dc.w 0,0
dc.w 2
dc.w 2
dc.w 20
dc.w 10
dc.w 1,1
dc.l 0
dc.l 0




requester:
dc.l 0
reqpos:
dc.w 20,20
reqw:
dc.w 280,110
dc.w 0,0
gadg:
dc.l 0		;gagdget
dc.l rborder1		;border
reqtext:
dc.l Load_i_t		;text
dc.w 0
bf:
dc.b 26	;backfill
dc.b 00		;even
dc.l 0
blk 32,0
dc.l 0
dc.l 0
blk 36,0

load_i_t:
dc.b 0,1,0,0
dc.w 70,8
dc.l 0
dc.l rtext1
dc.l it2

it2:
dc.b 8,1,0,0
dc.w 10,25
dc.l 0
dc.l rtext2
dc.l it3

it3:
dc.b 8,1,0,0
dc.w 10,35
dc.l 0
dc.l rtext3
dc.l it4

it4:
dc.b 8,1,0,0
dc.w 10,45
dc.l 0
dc.l rtext4
dc.l it5

it5:
dc.b 8,1,0,0
dc.w 10,55
dc.l 0
dc.l rtext5
dc.l it6

it6:
dc.b 2,1,0,0
dc.w 5,70
dc.l 0
dc.l rtext6
dc.l it7
it7:
dc.b 2,1,0,0
dc.w 5,80
dc.l 0
dc.l rtext7
dc.l it8

it8:
dc.b 2,1,0,0
dc.w 30,90
dc.l 0
dc.l rtext8
dc.l 0

bodytext:
dc.b 28,0,0,0
dc.w 10,10
dc.l 0
dc.l body
dc.l 0

body:
dc.b 'Disk Error !!',0

ertext:
dc.b 28,1,0,0
dc.w 5,3
dc.l 0
dc.l er2
dc.l 0

er2:
dc.b 'Cancel',0

rtext1:
dc.b 'U.S.I Bootwriter',0
rtext2:
dc.b 'Click in the Stringgadget.Press ',0
rtext3:
dc.b 'right Amiga-Key + x. Edit Text.',0
rtext4:
dc.b 'Press Menue Button and write to',0
rtext5:
dc.b 'Disc.',0
rtext6:
dc.b 'Programm by Chris (U.S.I) assisted',0
rtext7:
dc.b 'by Tytan (Digital Force).The super',0
rtext8:
dc.b 'Title-Graphic is from Wotan',0 
even
rborder1:
dc.w -2,-1
dc.b 4,2,1
dc.b 7
dc.l vectors1
dc.l 0

vectors1:
dc.w 2,1
dc.w 2,110
dc.w 281,110
dc.w 281,1
dc.w 2,1
dc.w 2,20
dc.w 281,20


NewWindowStructure:
	dc.w	0,10	;window XY origin relative to TopLeft of screen
	dc.w	320,246	;window width and height
	dc.b	0,1	;detail and block pens
	dc.l	$540	;IDCMP flags
	dc.l	$1800	;other window flags
	dc.l	Gadget1	;first gadget in gadget list
	dc.l	NULL	;custom CHECKMARK imagery
	dc.l	0	;window title
w_screen:	dc.l	NULL	;custom screen
	dc.l	NULL	;custom bitmap
	dc.w	5,5	;minimum width and height
	dc.w	320,190	;maximum width and height
	dc.w	$f
;destination screen type

	even

GadgetList:
Gadget1:
	dc.l	0	;next gadget
	dc.w	10,206	;o
	dc.w	300,10	;hit box width and height
	dc.w	GADGHCOMP	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	4	;gadget type
	dc.l	0	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	NULL	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	GadgetSI1	;SpecialInfo structure for string gadgets
	dc.w	1	;user-definable data (ordinal gadget number)
	dc.l	NULL	;pointer to user-definable data
GadgetSI1:
	dc.l	text	;buffer where text will be edited
	dc.l	NULL	;optional undo buffer
	dc.w	0	;character position in buffer
	dc.w	433	;maximum number of characters to allow
	dc.w	0	;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition initialized and maintained variables
	dc.l	0	;Rastport of gadget
	dc.l	NULL	;initial value for integer gadgets
	dc.l	NULL	;alternate keymap (fill in if you set the flag)
	even

MenuList:
Menu1:
	dc.l	NULL	;next Menu structure
	dc.w	2,0	;XY origin of Menu hit box relative to screen TopLeft
	dc.w	75,0	;Menu hit box width and height
	dc.w	MENUENABLED	;Menu flags
	dc.l	Menu1Name	;text of Menu name
	dc.l	MenuItem1	;MenuItem linked list pointer
	dc.w	0,0,0,0	;Intuition mystery variables
Menu1Name:
	dc.b	'Project',0
	even
MenuItem1:
	dc.l	MenuItem2	;next MenuItem structure
	dc.w	0,0	;XY of Item hitbox relative to TopLeft of parent hitbox
	dc.w	65,10	;hit box width and height
	dc.w	ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
	dc.l	0	;each bit mutually-excludes a same-level Item
	dc.l	IText1	;Item render  (IntuiText or Image or NULL)
	dc.l	NULL	;Select render
	dc.b	NULL	;alternate command-key
	dc.b	NULL	;fill byte
	dc.l	SubItem1	;SubItem list
	dc.w	$FFFF	;filled in by Intuition for drag selections
IText1:
	dc.b	3,1,RP_COMPLEMENT,0	;front and back text pens, drawmode and fill byte
	dc.w	1,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for defaults
	dc.l	ITextText1	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText1:
	dc.b	'Write to',0
	even
SubItem1:
	dc.l	SubItem2	;next SubItem structure
	dc.w	50,-8	;XY of Item hitbox relative to TopLeft of parent hitbox
	dc.w	33,10	;hit box width and height
	dc.w	ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
	dc.l	0	;each bit mutually-excludes a same-level Item
	dc.l	IText2	;Item render  (IntuiText or Image or NULL)
	dc.l	NULL	;Select render
	dc.b	NULL	;alternate command-key
	dc.b	NULL	;fill byte
	dc.l	NULL	;no SubItem list for SubItems
	dc.w	$FFFF	;filled in by Intuition for drag selections
IText2:
	dc.b	3,1,RP_COMPLEMENT,0	;front and back text pens, drawmode and fill byte
	dc.w	1,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for defaults
	dc.l	ITextText2	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText2:
	dc.b	'Df0:',0
	even
SubItem2:
	dc.l	NULL	;next SubItem structure
	dc.w	50,2	;XY of Item hitbox relative to TopLeft of parent hitbox
	dc.w	33,10	;hit box width and height
	dc.w	ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
	dc.l	0	;each bit mutually-excludes a same-level Item
	dc.l	IText3	;Item render  (IntuiText or Image or NULL)
	dc.l	NULL	;Select render
	dc.b	NULL	;alternate command-key
	dc.b	NULL	;fill byte
	dc.l	NULL	;no SubItem list for SubItems
	dc.w	$FFFF	;filled in by Intuition for drag selections
IText3:
	dc.b	3,1,RP_COMPLEMENT,0	;front and back text pens, drawmode and fill byte
	dc.w	1,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for defaults
	dc.l	ITextText3	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText3:
	dc.b	'Df1:',0
	even
MenuItem2:
	dc.l	MenuItem3	;next MenuItem structure
	dc.w	0,11	;XY of Item hitbox relative to TopLeft of parent hitbox
	dc.w	65,10	;hit box width and height
	dc.w	ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
	dc.l	0	;each bit mutually-excludes a same-level Item
	dc.l	IText4	;Item render  (IntuiText or Image or NULL)
	dc.l	NULL	;Select render
	dc.b	NULL	;alternate command-key
	dc.b	NULL	;fill byte
	dc.l	NULL	;SubItem list
	dc.w	$FFFF	;filled in by Intuition for drag selections
IText4:
	dc.b	3,1,RP_COMPLEMENT,0	;front and back text pens, drawmode and fill byte
	dc.w	1,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for defaults
	dc.l	ITextText4	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText4:
	dc.b	'Help',0
	even
MenuItem3:
	dc.l	NULL	;next MenuItem structure
	dc.w	0,22	;XY of Item hitbox relative to TopLeft of parent hitbox
	dc.w	65,10	;hit box width and height
	dc.w	ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
	dc.l	0	;each bit mutually-excludes a same-level Item
	dc.l	IText5	;Item render  (IntuiText or Image or NULL)
	dc.l	NULL	;Select render
	dc.b	NULL	;alternate command-key
	dc.b	NULL	;fill byte
	dc.l	NULL	;SubItem list
	dc.w	$FFFF	;filled in by Intuition for drag selections
IText5:
	dc.b	3,1,RP_COMPLEMENT,0	;front and back text pens, drawmode and fill byte
	dc.w	1,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for defaults
	dc.l	ITextText5	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText5:
	dc.b	'Quit',0
	even

; end of PowerWindows source generation


boot_block:
dc.b 'DOS',0
bb_chksum:
dc.l 0
dc.l $370
bsr scroll
	move.l 4,a6
	lea dlib(pc),a1
	jsr -96(a6)
	move.l d0,a0
	move.l $16(a0),a0
	moveq#0,d0
	rts
dlib:
	dc.b 'dos.library',0
scroll:
move #$8380,$dff096
move#$4000,$dff09a
lea $40000,a0
move#100,d7
cl:
clr.l (a0)+
dbf d7,cl
move.l 4,a6
lea lib(pc),a1
jsr -408(a6)
move.l d0,a6
lea $45000,a1
jsr -198(a6)
lea bitmstr(pc),a0
move.l a0,$45004
ch1:
lea text(pc),a0
lea tp(pc),a1
move.l a0,(A1)
lea $45000,a1
move.l #1,d0
jsr -354(A6)
ch:
lea $45000,a1
move.l #364,d0
move.l #6,d1
jsr -240(a6)
lea $45000,a1
lea tp(pc),a2
move.l (A2),a0
move.l #1,d0
jsr -60(A6)

rast:
btst#6,$bfe001
beq a
cmp.b #1,$dff006
bne rast
bsr cy
lea $40190,a0
move #$c7,d0 
sc:
roxl -(a0)
dbf d0,sc
lea counter(pc),a0
add#1,(a0)
cmp#9,(a0) 
bne rast
clr (a0)
lea tp(pc),a0
add.l #1,(a0)
move.l (a0),a1
cmp.b #0,(a1)
beq ch1
bra ch





a:
move#$c000,$dff09a
move.l 38(A6),$dff080
rts

cy:
lea $46000,a0
move.l #$00e00004,(A0)+
move.l #$00e20000,(A0)+
move.l #$01001200,(A0)+
move.l #$2021fffe,d0
move.l #$0021fffe,d2
bsr clct
move.l #$ffdffffe,(a0)+
move.l #$2b21fffe,d2
move.l #$0021fffe,d0
bsr ncl
move.l #$46000,$dff080
lea $dff000,a0
move #$9471,$8e(a0)
move #$9ce1,$90(A0)
move #$0024,$104(a0)
move #$0028,$92(a0)
move #$00d8,$94(a0)
clr $102(a0)
clr.l $108(a0)
lea ct(pc),a0
lea ctende(pc),a1
move (a0),d2
move#30,d7
fg:
move 2(A0),(A0)+
dbf d7,fg
move d2,(A0)
rts


clct:
lea ct(pc),a1
lea ctende(pc),a2
ncl:
cmp.l d2,d0
beq nclend
move #$0180,d1
move #$0182,d4
swap d4
swap d1
move (a1),d4
not d4
move (A1)+,d1
move.l d0,(a0)+
move.l d1,(A0)+
move.l d4,(a0)+
add.l #$01000000,d0
cmp.l a2,a1
beq clct
bra ncl
nclend:

rts


ct:
dc.w $f00,$f20,$f40,$f60,$f80,$fa0,$fc0,$fe0
dc.w $ef0,$cf0,$af0,$8f0,$6f0,$4f0,$2f0,$0f0
dc.w $0e2,$c4,$a6,$88,$6a,$4c,$2e,$0f
dc.w $20e,$40c,$60a,$808,$a06,$c04,$e02,$f00
ctende:




bitmstr:
dc.w 46
dc.w 20
dc.b 0
dc.b 1
dc.w 0
dc.l $40000
tp:
dc.l 0
counter:
dc.w 0

lib:
dc.b 'graphics.library',0

text:
dc.b 'Click this Box and write your text'
blk 433,0





te:


even
ioreq:
	dc.l 0		
	dc.l 0		
	dc.b 5			;node_type = NT_MESSAGE		
	dc.b 0	
	dc.l mn_node_name		

io_msgport:
	dc.l 0
	dc.w 0

	dc.l 0  	;dev
	dc.l 0		;Unit
	dc.w 0 		;command
	dc.b 0		;flags
er:	dc.b 0		;errors
	dc.l 0 		;actual
	dc.l 0		;lenght
	dc.l 0		;data
	dc.l 0		;offset
	dc.l 0		;reserved1
	dc.l 0		;reserved2
 


mn_node_name:
	dc.b 'myport',0

dev:
	dc.b 'trackdisk.device',0
picture:
;blk 31960,0
