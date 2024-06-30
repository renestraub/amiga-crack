
a:	; Rs 22.7.87
	; Load-scr V0.5
	; Leadt Screen1,screen2 mit draw_block routine

	bsr initlib
	bsr allocmem
	bsr loadscr
	bsr loadstage
	bsr initcolors
	bsr initcopper
	bsr initmouse
	bsr buildlevel	

wait2:
	move.l gfxbase,a6
	jsr -270(a6)
;	jsr -270(a6)
;	jsr -270(a6)
;	jsr -270(a6)
;	jsr -270(a6)

	bsr mousehandler
	clr.l d0
	move mousx,d0
	move.l schl,d1
	bsr draw_schl

	lea spr1,a1
	bsr movesprx
	clr d7
	move.b 7(A1),d7
	tst.b d7
	bpl.s notneg
	neg.b d7
notneg:	
	subq.b #1,d7
movey:
	bsr movespry
	dbra d7,movey
	btst #6,$bfe001
	beq exit2
	btst #10,$dff016
	beq nextstage
	bra wait2

nextstage:	
	add.l #190,stufe2
	cmp.l #6080,stufe2
	bne c5
	move.l #0,stufe2
c5:
	bsr buildlevel
	bra wait2

schl:
	dc.l 0
exit2:
	move #$8020,$dff096
	jsr freemem
	bra exit	
error:
exit:
	move.l gfxbase,a6
	move.l 38(a6),$dff080
	rts
count:
	dc.w 0

buildlevel:
;	move.l #190,stufe2
	jsr htoz
	jsr initblockcolors
	lea zspeicher+190,a0

	move.l #15,d2
verti:
	move.l #10,d1
horiz:
	move.l #0,d0
	move.b -(a0),d0
	and.b #31,d0
	bsr draw_block
	dbra d1,horiz
	dbra d2,verti
	rts

loadscr:
	move.l #picname1,d1	; File1 oeffnen
	jsr open
	move.l d0,filedat1	
	move.l screen1,d2	; File1 laden
	move.l filedat1,d1
	jsr read
	move.l filedat1,d1	; File1 schliessen
	jsr close
	move.l #picname2,d1	; File2 oeffnen	
	jsr open
	move.l d0,filedat2
	move.l screen2,d2	; File2 laden
	move.l filedat2,d1
	jsr read
	move.l filedat2,d1	; File2 schliessen
	jsr close
open:
	move.l dosbase,a6
	move.l #$03ed,d2
	jsr -30(a6)		; File oeffnen
	beq error		; File nicht gefunden
	rts
read:
	move.l dosbase,a6
	move.l #49000,d3	; Laenge des Files
	jsr -42(a6)		; Read !
	cmp.l #-1,d0
	beq error
	rts
initcolors:
	move.l #$dff180,a1
	lea colorlist,a0
	move #15,d2
colors:
	move (a0)+,(a1)+
	dbra d2,colors
	rts
colorlist:
	dc.w 0
	dc.w $eee,$d93,$fa4,$640,$310,$530,$850

	;dc.w $eee,$ff0,$0,$bbb,$aaa,$999,$888,
	dc.w $00f,$0f0,$0ff
	dc.w $0f0,$f0f,$ff0,$aab,$b60

initblockcolors:
	lea zspeicher+2,a0
	move.l #$dff190,a1
	move #5,d7
ibcloop1:
	move (a0)+,(a1)+
	dbra d7,ibcloop1
	rts
htoz:
	lea zspeicher,a0
	move.l hspeicher,a1
	add.l stufe2,a1
	move #94,d7
htoz1:
	move (a1)+,(a0)+
	dbra d7,htoz1
	rts
ztoh:
	move.l hspeicher,a0
	lea zspeicher,a1
	add.l stufe2,a0	
	move #94,d7
ztohloop:
	move (a1)+,(a0)+
	dbra d7,ztohloop
	rts
stufe2:
	dc.l 8*190
stufe:
	dc.l 0
initlib:
	move.l 4,a6
	lea doslib,a1
	jsr -408(a6)		; Open DOS-Library
	beq exit
	move.l d0,dosbase
	lea gfxlib,a1
	jsr -408(a6)
	beq exit
	move.l d0,gfxbase
	rts

initcopper:
	move.l #copperl+2,a0	
	move.l screen1,d0	; Beginn des Bildspeichers
	move #5,d1		; 4 Bitplanes
writescr:
	swap d0			
	move d0,(a0)		; Obere 16 Bit einschreiben
	swap d0
	move d0,4(a0)		; Untere 16 Bit einschreiben
	add.l #8,a0		; Neue Copperadresse
	add.l #8000,d0		; Neue Bitplane
	dbra d1,writescr

	lea copperspr+2,a0	
	move.l #sprite1,d0	; Beginn des 1. Sprites
	move d0,4(a0)		; Obere 16 Bit einschreiben
	swap d0
	move d0,(a0)		; Untere 16 Bit einschreiben
	
	move.l #copperl,$dff080	; Start Copper
	rts
close:
	move.l dosbase,a6
	jsr -36(a6)		; Close file
	rts

loadstage:
	move.l dosbase,a6
	move.l #$3ed,d2
	move.l #stagename,d1
	jsr -30(a6)
	cmp.l #0,d0
	beq error
	move.l d0,-(sp)
	
	move.l d0,d1
	move.l hspeicher,d2
	move.l #7000,d3
	jsr -42(a6)

	move.l (sp)+,d1
	jsr -36(a6)
	rts

stagename:
	dc.b 'STAGEA',0
even
hspeicher:
	dc.l 0
allocmem:
	move.l 4,a6
	move.l #110000,d0
	move.l #$10002,d1
	jsr -198(a6)
	beq error
	move.l d0,screen1
	add.l #49000,d0
	move.l d0,screen2
	add.l #49000,d0
	move.l d0,hspeicher
	rts

freemem:
	move.l 4,a6
	move.l screen1,a1
	move.l #110000,d0
	jsr -210(a6)
	rts

draw_block:
	movem.l d0-d7/a0-a5,-(sp)

	move.l screen2,a0	; Blockdaten
	lsl #1,d0		; Startadresse =
	add.l d0,a0		; D0 * 4 + screen2
	move.l screen1,a2	; Ziel in Bildspeicher
	add.l #284,a2		; Startadresse =
	lsl #1,d1		; screen1 + 2 * d1 + 320 * d2 + 570
	add.l d1,a2
	mulu #320,d2
	add.l d2,a2
	move.l screen2,a1	; Maske

	cmp.b #0,d0
	beq clear_block

	move #3,d7
draw_block2:
	btst #14,$dff002
	bne draw_block2
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #38,$dff060	;modulo
	move #38,$dff062	;modulo
	move #38,$dff064	;modulo
	move #38,$dff066	;modulo
	move #0,$dff042		;0
	move #$0fca,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffffffff,$dff044 ;mask
	move #%0000000111000001,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_block2
	movem.l (sp)+,d0-d7/a0-a5
	rts

clear_block:
	move #3,d7
clear_block2:
	btst #14,$dff002
	bne clear_block2
	move.l a0,$dff050	;Source A
	move.l a2,$dff054	;ziel D
	move #38,$dff066	;modulo
	move #38,$dff064	;modulo
	clr $dff074
	clr $dff042		;0
	move #$0100,$dff040	;0 = use d keine verknuepfung
	move.l #$ffffffff,$dff044 ;mask
	move #%0000000111000001,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a2
	dbra d7,clear_block2
	movem.l (sp)+,d0-d7/a0-a5
	rts

draw_schl:
	movem.l d0-d7/a0-a5,-(sp)	; D1=Schlaeger
	move.l screen1,a0		; D0=X-Koordinate
	add.l #7165,a0
	move.l screen2,a1
	add.l #7640,a1
	move #3,d7
draw_schl1:
	btst #14,$dff002
	bne draw_schl1
	
	move.l a0,$dff054	;ziel D
	move.l a1,$dff050	;source A
	move #33,$dff064	;modulo A
	move #18,$dff066	;modulo d
	clr $dff074
	move d3,$dff042		;0
	move #$01f0,$dff040	;0 = shift use a,d d=a
	move.l #$fffffff,$dff044 ;mask
	move #%0000001000001011,$dff058		;groesse
	add.l #8000,a0
	add.l #8000,a1
	dbra d7,draw_schl1

	move.l d1,d3
	lea tabelle,a5
	asl #1,d3
	add.l d3,a5

	cmp (a5),d0
	blt lo2
	move (a5),d0
lo2:
	move d0,d3		; D0 = X-Koordinate in Pixels
	and #$000F,d3		; Shift bestimmen
	lsr #3,d0		; Words bestimmen
	bclr #0,d0
	lsl #8,d3
	lsl #4,d3
	move d3,d2		; Shift fuer BPLcon0
	add #$0fca,d2		; Shift fuer BPLcon1

	move.l screen2,a0	 
	add.l #840,a0		; Schlaeger
	mulu #6,d1
	add.l d1,a0	

	move.l screen1,a2	; Ziel im Screen1
	add.l #7165,a2		; = screen1+14330+words
	add.l d0,a2
	
	move.l a0,a1		; Maske
	add.l #320,a1	

	move #3,d7
draw_schl2:
	btst #14,$dff002
	bne draw_schl2
	move.l a2,$dff048	;ziel C
	move.l a2,$dff054	;ziel D
	move.l a0,$dff04c	;bild B
	move.l a1,$dff050	;maske A
	move #33,$dff060	;modulo
	move #33,$dff062	;modulo
	move #33,$dff064	;modulo
	move #33,$dff066	;modulo
	move d3,$dff042		;0
	move d2,$dff040	;0 = shift use a,b,c,d d=ab+(a)c
	move.l #$ffff0000,$dff044 ;mask
	move #%0000001000000100,$dff058		;groesse
	;      hhhhhhhhhhwwwwww
	add.l #8000,a0
	add.l #8000,a2
	dbra d7,draw_schl2
	movem.l (sp)+,d0-d7/a0-a5
	rts
tabelle:
	dc.w 140,142,144,146,148,148
tabelle2:
	dc.w 17,16,15,14,13,13

initmouse:	
	move.w 	$dff00a,d0
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#$ff,d0
	move.b	d0,oldx
	move.b	d1,oldy
	
mousehandler:
	movem.l	d0-d7/a0-a6,-(sp)

	move.w 	$dff00a,d0
	move.w	d0,d1
	lsr.w	#8,d1			; x in d0/y in d1
	and.w	#$ff,d0

	clr.w	d2
	clr.w	d3
	clr.w	d4

	move.b	oldx,d2
	move.b	oldy,d3
	move.b	d0,oldx
	move.b	d1,oldy

	sub.b	d0,d2			; x-cord
	tst.b	d2
	beq	mous3
	move.b	d2,d4
	tst.b	d2
	bpl	mous1
	neg.b	d2
mous1:	cmp.b	#127,d2
	bgt	mous2
	ext.w	d4
	sub.w	d4,imgx
	bra	mous3
mous2:	sub.b	#255,d4
	ext.w	d4
	sub.w	d4,imgx

mous3:	sub.b	d1,d3			; y-cord
;	tst.b	d3
;	beq	mous6
;	move.b	d3,d4
;	tst.b	d3
;	bpl	mous4
;	neg.b	d3
mous4:	cmp.b	#127,d3
;	bgt	mous5
;	ext.w	d4
;	sub.w	d4,imgy
;	bra	mous6
mous5:	sub.b	#255,d4
;	ext.w	d4
;	sub.w	d4,imgy
;
mous6:	move.w	imgx,d0			; set real cords
	asr.w	#1,d0			; check boundary
;	move.w	imgy,d1
;	asr.w	#1,d1
	cmp #1,d0
	bgt	mous7
	move.w	#1,d0
	move.w	#2,imgx
mous7:	cmp.w	#149,d0
	blt	mous8
	move.w	#150,d0
	move.w	#300,imgx
mous8:	cmp #0,d1
;	bgt mous9
;	move	#0,d1
;	move.w	#0,imgy
mous9:	cmp.w	#200,d1
;	blt	mous10
;	move.w	#199,d1
;	move.w	#398,imgy

mous10:	
	move d0,d5
	sub d5,mousx
	move mousx,dist
	move d0,mousx
;	move d1,mousy
	movem.l	(sp)+,d0-d7/a0-a6
	rts

oldx:	dc.b	0
oldy:	dc.b	0
imgx:	dc.w	0
imgy:	dc.w	0

dist:	dc.w	0
mousx:	dc.w	0
mousy:	dc.w	0

even
doslib:
	dc.b 'dos.library',0
even
gfxlib:
	dc.b 'graphics.library',0
even
picname1:
	dc.b 'rahmen2',0
even
picname2:
	dc.b 'pic1'
even
dosbase:
	dc.l 0
gfxbase:
	dc.l 0
screen1:
	dc.l 0
screen2:
	dc.l 0
filedat1:
	dc.l 0
filedat2:
	dc.l 0

copperl:

dc.w $00e0,$0004
dc.w $00e2,$0000	; Bitplane 1	
dc.w $00e4,$0004
dc.w $00e6,$3e80	; Bitplane 2
dc.w $00e8,$0004
dc.w $00ea,$7d00	; Bitplane 3
dc.w $00ec,$0004
dc.w $00ee,$bb80	; Bitplane 4
dc.w $00f0,$0000
dc.w $00f2,$0000	; Bitplane 5
dc.w $00f4,$0000
dc.w $00f6,$0000	; Bitplane 6

copperspr:
dc.w $0120,$0000
dc.w $0122,$0000	; Sprite 0
dc.w $0124,$0000
dc.w $0126,$0000	; Sprite 1
dc.w $0128,$0000
dc.w $012a,$0000	; Sprite 2
dc.w $012c,$0000
dc.w $012e,$0000	; Sprite 3
dc.w $0130,$0000
dc.w $0132,$0000	; Sprite 4
dc.w $0134,$0000
dc.w $0136,$0000	; Sprite 5
dc.w $0138,$0000
dc.w $013a,$0000	; Sprite 6
dc.w $013c,$0000
dc.w $013e,$0000	; Sprite 7


dc.w $0098,$f208
dc.w $0180,$0000	; Color0=schwarz
dc.w $01a0,$0000
dc.w $01a2,$0dde
dc.w $01a4,$0aab
dc.w $01a6,$0f00
dc.w $008e,$2c79	; DIWstrt
dc.w $0090,$f4c1	; DIWstop
dc.w $0100,$6200	; BPLcon0
dc.w $0104,$0024	; BPLcon2
dc.w $0092,$0038	; DDFstrt
dc.w $0094,$00d2	; DDFstop
dc.w $0102,$0000	; BPLcon1
dc.w $0108,$0000	; BPL1mod
dc.w $010a,$0000	; BPL2mod	
dc.w $df21,$fffe
dc.w $0098,$f1c4
dc.w $0104,$0040
dc.w $ffff,$fffe 

sprite1:
	dc.w $5a40,$6100
	dc.w $0000,$0000
	dc.w $0000,$0078
	dc.w $0030,$00CC
	dc.w $0078,$0084
	dc.w $0078,$0084
	dc.w $0030,$00CC
	dc.w $0000,$0078
	dc.w $0000,$0000
spr1:
	dc.l sprite1		; Adresse des Sprites
	dc.b 76+8,155,1,1	; x,y,dx,dy
hit:
	dc.w 0
zspeicher:
	blk 200,0

movespry:
	movem.l d0-d7/a0-a6,-(a7)
	clr.l d1
	clr.l d2
	clr.l d3

	move.l (A1)+,a0
	move.b (a1)+,d1	; X holen
	move.b (a1)+,d2	; Y holen
	move.b (a1)+,d3	; DX holen
	move.b (a1)+,d4 ; DY holen

	tst.b d4
	beq endmovey
	bpl.s add
	subq.b #1,d2
	bra.s sub
add:
	addq.b #1,d2	; Y-Wert korrigieren
sub:
	cmpi.b #225,d2
	bne weiterc5
	move #50,d2
weiterc5:
	cmpi.b #218,d2
	bls.L notschlaeger
	cmpi.b #222,d2
	bhi.L notschlaeger
	
	move mousx,d5
	lsr #1,d5
	add #75,d5

	cmp.b d5,d1
	bls.s daneben
	
	move.l schl,d6
	lsl.l #1,d6
	lea tabelle2,a2
	add.l d6,a2
	move (a2),d6
	add d6,d5	; Schlaeger getroffen ?

	cmp.b d5,d1
	bhi.s daneben
	
	tst dist
	beq loop2
	bpl schllinks

	tst.b d3		; (Schlaeger rechts)
	beq loop2
	bpl ballrechts1		; Ball links

balllinks1:
 	addq.b #1,d4
	cmpi.b #5,d4
	bne loop2
	moveq #4,d4		; Winkel +
	bra loop2

ballrechts1:			; Ball rechts
	subq.b #1,d4
	tst.b d4
	bne loop2
	moveq #1,d4		; Winkel -
	bra loop2

schllinks:
	tst.b d4			; Schlaeger links
	beq loop2
	bpl ballrechts2
	
balllinks2:
	subq.b #1,d4		; Ball links 
	tst.b d3
	bne loop2
	moveq #1,d4		; Winkel -
	bra loop2

ballrechts2:			; Ball rechts
	addq.b #1,d4
	cmpi.b #5,d4
	bne loop2
	moveq #4,d4		; Winkel +
loop2:	
	neg.b d4
	bra.L endmovey
daneben:
	bra.L endmovey

notschlaeger:
	cmpi.b #49,d2
	bhi.s blockcoll
	neg.b d4
blockcoll:
	cmpi.b #172,d2
	bhi.L nocoll

	move d2,d5
	tst.b d4
	bpl.s collup

	sub.b #56,d5
	and.b #7,d5
	tst.b d5
	bne.L nocoll
;	move #$f00,$dff180
	move d2,d6
	move d1,d5
	sub.b #75,d1
	sub.b #54,d2
	lsr #3,d1
	lsr #3,d2
	lea zspeicher+14,a4
	add d1,a4
	mulu #11,d2
	add d2,a4
	divu #11,d2
	move.b (A4),d7
	move.b d7,sicher
	and.b #31,d7
	tst.b d7
	beq.L nocol1	; Kein Stein
	cmp.b #8,d7
	beq.s nodel1	; Unzerstoerbar
	cmp.b #7,d7
	bne.s notmehr11	; Mehrmals treffen

	move.b sicher,d7
	sub.b #32,d7
	move.b d7,(a4)
	cmp.b #7,d7
	bne.s nodel1
notmehr11:
	clr.b (a4)
	clr.l d0
	bsr draw_block
nodel1:
	neg.b d4
nocol1:
	move d6,d2
	move d5,d1
	bra.s nocoll	
collup:
	sub.b #46,d5
	and.b #7,d5
	tst.b d5
	bne.s nocoll

	move d2,d6
	move d1,d5
	sub.b #75,d1
	sub.b #44,d2
	lsr #3,d1
	lsr #3,d2
	lea zspeicher+14,a4
	add d1,a4
	mulu #11,d2
	add d2,a4
	divu #11,d2
	move.b (A4),d7
	move.b d7,sicher
	and.b #31,d7
	tst.b d7
	beq.s nocol2	; Kein Stein
	cmp.b #8,d7
	beq.s nodel2	; Unzerstoerbar
	cmp.b #7,d7
	bne.s notmehr12	; Mehrmals treffen

	move.b sicher,d7
	sub.b #32,d7
	move.b d7,(a4)
	cmp.b #7,d7
	bne.s nodel2
notmehr12:
	clr.b (a4)
	clr.l d0
	bsr draw_block
nodel2:
	neg.b d4
nocol2:
	move d6,d2
	move d5,d1
nocoll:
endmovey:
	move.b d2,(a0)	
	move.b d2,d6	
	addi.b #7,d6
	move.b d6,2(a0)
	
	move.b d4,-(a1)		; Delta X sichern
	move.b d3,-(a1)		; Delta Y sichern
	move.b d2,-(a1)		; Y sichern
	move.b d1,-(a1)		; X sichern
	movem.l (A7)+,d0-d7/a0-a6
	rts

movesprx:
	movem.l d0-d7/a0-a6,-(a7)
	clr.l d1
	clr.l d2
	clr.l d3

	move.l (a1)+,a0
	move.b (a1)+,d1	; X holen
	move.b (a1)+,d2	; Y holen
	move.b (a1)+,d3	; DX holen

	addi.b d3,d1

	cmpi.b #75,d1
	bhi.s rechterrand
	neg.b d3
rechterrand:
	cmpi.b #161,d1
	bls.s enderand
	neg.b d3
enderand:
	cmpi.b #172,d2
	bhi.L nocoll2

	tst.b d3
	bpl.s colllinks

	move.b d1,d5
	sub.b #83,d5
	and #7,d5
	tst.b d5
	bne.L nocoll2
	move d1,d5
	move d2,d6
	sub.b #47,d2
	sub.b #79,d1
	lsr.b #3,d2
	lsr.b #3,d1

	lea zspeicher+14,a4
	add d1,a4
	mulu #11,d2
	add d2,a4
	divu #11,d2
	move.b (A4),d7
	move.b d7,sicher
	and.b #31,d7
	tst.b d7
	beq.s nocolL21	; Kein Stein
	cmp.b #8,d7
	beq.s notdel21	; Unzerstoerbar
	cmp.b #7,d7
	bne.s notmehr21	; Mehrmals treffen

	move.b sicher,d7
	sub.b #32,d7
	move.b d7,(a4)
	cmp.b #7,d7
	bne.s notdel21
notmehr21:
	clr.b (a4)
	clr.l d0
	bsr draw_block
notdel21:
	neg.b d3
nocoll21:
	move.b d6,d2
	move.b d5,d1
	bra.s endmovex
colllinks:
	move.b d1,d5
	sub.b #82,d5
	and #7,d5
	tst.b d5
	bne.s nocoll2

	move d1,d5
	move d2,d6
	sub.b #47,d2
	sub.b #74,d1
	lsr.b #3,d2
	lsr.b #3,d1

	lea zspeicher+14,a4
	add d1,a4
	mulu #11,d2
	add d2,a4
	divu #11,d2
	move.b (A4),d7
	move.b d7,sicher
	and.b #31,d7
	tst.b d7
	beq.s notcol22	; Kein Stein
	cmp.b #8,d7
	beq.s notdel22	; Unzerstoerbar
	cmp.b #7,d7
	bne.s notmehr22	; Mehrmals treffen

	move.b sicher,d7
	sub.b #32,d7
	move.b d7,(a4)
	cmp.b #7,d7
	bne.s notdel22
notmehr22:
	clr.b (a4)
del22:
	clr.l d0
	bsr draw_block
notdel22:
	neg.b d3
notcol22:
	move.b d6,d2
	move.b d5,d1
nocoll2:
endmovex:
	addq.l #1,a0
	move.b d1,(a0)+
	
	move.b d3,-(a1)		; Delta X sichern
	move.b d2,-(a1)		; Y sichern
	move.b d1,-(a1)		; X sichern

	movem.l (A7)+,d0-d7/a0-a6
	rts

x:
dc.l 0
y:
dc.l 0
z:
dc.l 0
sicher:
dc.w 0
