*Intro Nr.4   19.4.87 by CHRIS*



eins= $4da80+$288
zwei= $4dd10+$e70			;Spreite Move Schlusszeiger
drei= $4f000+$8e0
vier= $50000+$9f0
o:
	move.l pointer1,a0
	add.l #16,a0
	move.l a0,pointer2
	add.l #16,a0
	move.l a0,pointer3
	add.l #16,a0
	move.l a0,pointer4
	add.l #16,a0
	move.l a0,pointer5
	move.l pointer6,a0
	add.l #16,a0			;Sprite Move Anfang Init
	move.l a0,pointer7
	add.l #16,a0
	move.l a0,pointer8
	add.l #16,a0
	move.l a0,pointer9
	add.l #16,a0
	move.l a0,pointer10
	add.l #16,a0
	move.l a0,pointer11
	move.l pointer12,a0
	add.l #16,a0
	move.l a0,pointer13
	add.l #16,a0
	move.l a0,pointer14
	add.l #16,a0
	move.l a0,pointer15
	move.l pointer16,a0
	add.l #16,a0
	move.l a0,pointer17
	add.l #16,a0
	move.l a0,pointer18
	add.l #16,a0
	move.l a0,pointer19
	add.l #16,a0
	move.l a0,pointer20
	add.l #16,a0
	move.l a0,pointer21
	
	lea $4d560,a0
	move.l #$40404c00,(A0)
	move.l #$80408c00,52(a0)
	move.l #$c040cc00,104(a0)
	move.l #$f340ff00,156(a0)
	lea $4d630,a0
	move.l #$40504c00,(a0)
	move.l #$80508c00,52(a0)
	move.l #$c050cc00,104(a0)
	move.l #$f350ff00,156(a0)
	lea $4d700,a0
	move.l #$40604c00,(a0)
	move.l #$80608c00,52(a0)		;Sprite Anfang Position
	move.l #$c060cc00,104(a0)
	move.l #$f360ff00,156(a0)
	lea $4d7d0,a0
	move.l #$40704c00,(a0)
	move.l #$80708c00,52(a0)
	move.l #$c070cc00,104(a0)
	move.l #$f370ff00,156(a0)
	lea $4d8a0,a0
	move.l #$40804c00,(A0)
	move.l #$80808c00,52(a0)
	move.l #$c080cc00,104(a0)
	move.l #$f380ff00,156(a0)
	lea $4d970,a0
	move.l #$80908c00,(a0)
	move.l #$c090cc00,52(a0)
	move.l #$f390ff00,104(a0)
	lea $4da0c,a0
	move.l #$70a07c00,(a0)
	move.l #$a0a0ac00,52(a0)

	move.l 4,a6
	lea doslib,a1				;dos oeffnen
	jsr -408(a6)
	move.l d0,a6
	move.l #picname,d1			;Bild + Sprite laden
	move.l #$03ed,d2
	jsr -30(A6)
	bne loadw2				;Fehler ?
	rts
loadw2:
	move.l d0,file
	move.l d0,d1
	move.l #$60000,d2
	move.l #$10000,d3
	jsr -42(A6)
	move.l file,d1
	jsr -36(A6)
	bsr dec					;entcrunchen
	move.l #filename,d1			
	move.l #$03ed,d2			
	jsr -30(A6)				;Sound laden
	bne loadw				;Fehler ?
	rts
loadw:
	move.l d0,file
	move.l #$59000,d2
	move.l #$25000,d3
	jsr -42(a6)
	move.l file,d1
	jsr -36(a6)
	bsr g
	move.l 4,a6
	lea gfxlib,a1
	jsr -408(a6)
	move.l d0,gfxbase
	lea difolib,a1
	jsr -408(a6)				;Libraries oeffnen
	move.l d0,difobase
	move.l d0,a6
	lea textattr,a0				;Font oeffnen
	jsr -30(a6)
	move.l d0,font
	move.l gfxbase,a6
	lea bitmstr,a0
	move.l #2,d0
	move.l #384,d1
	move.l #248,d2
	jsr -390(a6)
	bsr initrapo				;Rasport erstellen
	lea rapo,a0
	move.l a0,rastport
	move.l rastport,a1
	move.l gfxbase,a6
	jsr -48(A6)
	move.l rastport,a1
	move.l font,a0
	jsr -66(a6)
	lea $51000,a0
	lea $30000,a1
	bsr write				;Hintergrund 2* kopieren
	bsr write
	bsr write
	bra cont

write:
	move.l #2727,d7
wr:
	move.l (a0)+,(a1)+
	dbf d7,wr
	bne wr
	sub.l #$2aa0,a0
	move.l #2727,d7
wr2:
	move.l (A0)+,(a1)+
	dbf d7,wr2
	rts

cont:
	bsr co					;Copperliste einschalten
	move.l #$2000,d0
del:
	dbf d0,del
	lea $58fe0,a0
	lea $dff180,a1
	move.l #7,d7
cm:
	move (a0)+,(a1)+
	dbf d7,cm

	bsr links				;die beiden Hackenteile Zeichn.
	bsr rechts

	move.l rastport,a0
	move.l rastport,a1
	move.l #120,d0
	move.l #60,d1
	move.l #140,d2
	move.l #60,d3					;Hacken kopieren
	move.l #195,d4
	move.l #150,d5
	move.l #$60,d6
	jsr -552(A6)
	bsr rechts					;geloeschter Teil nochmals
	bra start

rechts:
	move.l rastport,a1
	move.l gfxbase,a6
	move.l #2,d0
	jsr -342(A6)
	move.l #300,d0
	move.l #60,d1
	move.l #170,d2
	move.l #190,d3
	move.l #10,d7
make1:
	bsr line
	addq#1,d0
	addq#1,d2
	dbf d7,make1
	rts
links:
	move.l gfxbase,a6
	move.l rastport,a1
	move.l #3,d0
	jsr -342(A6)
	move.l #120,d0
	move.l #140,d1
	move.l #170,d2
	move.l #190,d3
	move.l #10,d7
make2:
	bsr line
	addq#1,d0
	addq#1,d2
	dbf d7,make2
	rts
start:
	lea int,a0
	move.l $6c,iveq
	move.l a0,$6c
mo:
	btst#6,$bfe001
	bne mo
	move.l iveq,$6c
	bra a


col1:
	lea tab1,a0
	lea tab2,a2
	lea colortable1,a1
	move.l #17,d7
col1m:
	move (A1),2(a2)
	move (A1)+,2(A0)
	add.l #8,a0
	add.l #8,a2
	dbf d7,col1m
	rts

cycle1:
	lea colortable1,a0
	move.l #23,d7
	move (a0),d1
cycle1m:
	move 2(A0),(A0)+
	dbf d7,cycle1m
	move d1,colortable1+48
	rts

line:
	movem.l d0-d7,-(A7)
	move.l gfxbase,a6
	move.l rastport,a1
	jsr -240(A6)
	movem.l (a7)+,d0-d3
	movem.l d0-d3,-(A7)
	move.l d2,d0
	move.l d3,d1
	move.l rastport,a1
	jsr -246(a6)
	movem.l (A7)+,d0-d7
	rts
	
;622fa
;922f
g:
	move.l #$59006,$dff0a0
	move #$db9f,$dff0a4
	move #64,$dff0a8
	move #350,$dff0a6
	move.l #$59006,$dff0b0
	move #$db9f,$dff0b4
	move #64,$dff0b8
	move #350,$dff0b6
	move #$8001,$dff096
	move.l #$1000,d0
sounddel:
	sub.l #1,d0
	bne sounddel
	move#$8002,$dff096
	move.l #$1000,d0
stdel:
	sub.l #1,d0
	bne stdel
	move.l #$622fa,$dff0a0
	move.l #$622fa,$dff0b0
	move #$922f,$dff0a4
	move #$922f,$dff0b4
	rts
off:
	move #3,$dff096
	rts

scroll:
	add#1,hackencounter
	cmp#30,hackencounter
	bne scr2
	clr hackencounter
	not flag
scr2:
	tst flag
	bne scrr
scrl:
	cmp#$30,mark
	beq scrlc
	sub #$40,mark
	rts
scrlc:
	add#2,scrb1
	add#2,scrb2
	move #$f0,mark
	rts
scrr:
	cmp#$f0,mark
	beq scrrc
	add #$40,mark
	rts
scrrc:
	sub#2,scrb1
	sub#2,scrb2
	move#$30,mark
	rts
copcor:
	move #0,bit1
	move #$5540,bit2
	move #$aa80,bit3
	rts
b:
	btst#14,$dff002
	bne b
	move.l #$400b8-46+2,a0
	move.l #$400b8-46,a1
	move.l a0,$dff050
	move.l a1,$dff054
	move #0,$dff064
	move #0,$dff066
	move #0,$dff042
	move #$e9f0,$dff040
	move.l #$ffffffff,$dff044
	move #%0000011000010101,$dff058
	;      hhhhhhhhhhwwwwww
	rts


int:
	movem.l d0-d7,-(A7)
	movem.l a0-a6,-(A7)
	move $dff01e,d0
	and #$10,d0
	cmp#$10,d0
	bne iende
	move#$10,$dff09c
	bsr scroll
	bsr cycle1
	bsr col1
	cmp #$2aa0,bit1
	bne raw
	bsr copcor
raw:
	add#1,scrcounter
	cmp#1,scrcounter
	bne notscr
	clr scrcounter
	add #44,bit1
	add #44,bit2
	add #44,bit3
notscr:
	bsr b
	move.l gfxbase,a6
	move.l rastport,a1
	move.l #352,d0
	move.l #20,d1
	jsr -240(a6)
	move.l #1,d0
	move.l rastport,a1
	jsr -342(a6)
	move.l pointer1,a0
	move.l (a0),$4d560
	cmp.l #eins,a0
	bne c1
	sub.l #$220,pointer1
c1:
	move.l pointer2,a0
	move.l (A0),$4d560+208
	cmp.l #eins,a0
	bne c2
	sub.l #$220,pointer2
c2:
	move.l pointer3,a0
	move.l (a0),$4d560+416
	cmp.l #eins,a0
	bne c3
	sub.l #$220,pointer3
c3:
	move.l pointer4,a0
	move.l (a0),$4d560+624
	cmp.l #eins,a0
	bne c4
	sub.l #$220,pointer4
c4:
	move.l pointer5,a0
	move.l (a0),$4d560+832
	cmp.l #eins,a0
	bne c5
	sub.l #$220,pointer5
c5:
	move.l pointer6,a0
	move.l (a0),$4d594
	cmp.l #zwei,a0
	bne c6
	sub.l #$1b0,pointer6
c6:
	move.l pointer7,a0
	move.l (A0),$4d594+208
	cmp.l #zwei,a0
	bne c7
	sub.l #$1b0,pointer7
c7:
	move.l pointer8,a0
	move.l (a0),$4d594+416
	cmp.l #zwei,a0
	bne c8
	sub.l #$1b0,pointer8
c8:
	move.l pointer9,a0
	move.l (a0),$4d594+624
	cmp.l #zwei,a0
	bne c9
	sub.l #$1b0,pointer9
c9:
	move.l pointer10,a0
	move.l (a0),$4d594+832
	cmp.l #zwei,a0
	bne c10
	sub.l #$1b0,pointer10
c10:
	move.l pointer11,a0
	move.l (a0),$4d594+832+156
	cmp.l #zwei,a0
	bne c11
	sub.l #$1b0,pointer11
c11:
	move.l pointer12,a0
	move.l (a0),$4d5c8
	cmp.l #drei,a0
	bne c12
	sub.l #$240,pointer12
c12:
	move.l pointer13,a0
	move.l (a0),$4d5c8+208
	cmp.l #drei,a0
	bne c13
	sub.l #$240,pointer13
c13:
	move.l pointer14,a0
	move.l (A0),$4d5c8+416
	cmp.l #drei,a0
	bne c14
	sub.l #$240,pointer14
c14:
	move.l pointer15,a0
	move.l (a0),$4d5c8+624
	cmp.l #drei,a0
	bne c15
	sub.l #$240,pointer15
c15:
	move.l pointer16,a0
	move.l (a0),$4d5fc
	cmp.l #vier,a0
	bne c16
	move.l #$50000,pointer16
c16:
	move.l pointer17,a0
	move.l (a0),$4d5fc+208
	cmp.l #vier,a0
	bne c17
	move.l #$50000,pointer17
c17:
	move.l pointer18,a0
	move.l (a0),$4d5fc+416
	cmp.l #vier,a0
	bne c18
	move.l #$50000,pointer18
c18:
	move.l pointer19,a0
	move.l (a0),$4d5fc+624
	cmp.l #vier,a0
	bne c19
	move.l #$50000,pointer19
c19:
	move.l pointer20,a0
	move.l (a0),$4d5fc+832
	cmp.l #vier,a0
	bne c20
	move.l #$50000,pointer20
c20:
	move.l pointer21,a0
	move.l (a0),$4d9d8
	cmp.l #vier,a0
	bne c21
	move.l #$50000,pointer21
c21:
	add.l #4,pointer1
	add.l #4,pointer2
	add.l #4,pointer3
	add.l #4,pointer4
	add.l #4,pointer5
	add.l #4,pointer6
	add.l #4,pointer7
	add.l #4,pointer8		;Sprite Move Zeiger erhoehen
	add.l #4,pointer9	
	add.l #4,pointer10
	add.l #4,pointer11
	add.l #4,pointer12		;Wuerg, Ich glaube dies waere
	add.l #4,pointer13		;auch einfacher zu loesen gewesen !!
	add.l #4,pointer14
	add.l #4,pointer15
	add.l #4,pointer16
	add.l #4,pointer17
	add.l #4,pointer18
	add.l #4,pointer19
	add.l #4,pointer20
	add.l #4,pointer21
	add #1,shift
	cmp#8,shift				;Neuer Buchstabe im Scroll
	bne iende				;schreiben ?
	clr shift
	move.l rastport,a1
	move.l gfxbase,a6
	move.l tp,a0
	cmp.b #0,(A0)				;Text zuende ?
	bne print
	move.l #textbuf,tp
	move.l tp,a0
print:
	move.l #1,d0
	jsr -60(A6)
	add.l #1,tp
iende:						;Ende der Interrupt Routine
	movem.l (A7)+,a0-a6
	movem.l (a7)+,d0-d7


dc.w $4ef9					;Op-Code fuer JMP
iveq:
dc.l 0						;Adresse fuer normalen Int.



co:
	lea copperl,a0
	move.l a0,$dff080			;Copperliste einschalten
	rts

a:
	bsr off					;Sound aus
	lea $22f8,a0				;Copperliste aus
	move.l a0,$dff080
	clr.l d0
rts


copperl:
dc.w $009c,$8010
dc.w $0120,$0004
dc.w $0122,$d560
dc.w $0124,$0004
dc.w $0126,$d630
dc.w $0128,$0004
dc.w $012a,$d700
dc.w $012c,$0004
dc.w $012e,$d7d0
dc.w $0130,$0004
dc.w $0132,$d8a0
dc.w $0134,$0004
dc.w $0136,$d970
dc.w $0138,0
dc.w $013a,0
dc.w $013c,0
dc.w $013e,0
dc.w $008e,$0501
dc.w $0090,$20e1
dc.w $0100,$0200
dc.w $0104,$0040
dc.w $0092,$0032
dc.w $0094,$00d4
dc.w $0102,$0000
dc.w $0108,$0000
dc.w $010a,$0004

dc.w $00e0,$0003
dc.w $00e2
bit1:
dc.w $0000
dc.w $00e8,$0003
dc.w $00ea
bit2:
dc.w $5540
dc.w $00f0,$0003
dc.w $00f2
bit3:
dc.w $aa80
dc.w $00e4,$0004
dc.w $00e6,$0000
dc.w $00ec,$0004

dc.w $00ee,$2e80

dc.w $01ac,$f80
dc.w $01ae,$08f
dc.w $01a6,$08f
dc.w $01a4,$f80
dc.w $01b4,$f80
dc.w $01b6,$08f
dc.w $01be,$f00
dc.w $01bc,$f80

dc.w $2201,$fffe
dc.w $0100,$5600
dc.w $0194,$f00
dc.w $0196,$00f
tab1:
dc.w $0192,$0f0
dc.w $2601,$fffe
dc.w $0192,$f00
dc.w $2701,$fffe
dc.w $0192,$f00
dc.w $2801,$fffe
dc.w $0192,$f00
dc.w $2901,$fffe
dc.w $0192,$f00
dc.w $2a01,$fffe
dc.w $0192,$f00
dc.w $2b01,$fffe
dc.w $0192,$f00
dc.w $2c01,$fffe
dc.w $0192,$f00
dc.w $2d01,$fffe
dc.w $0192,$f00
dc.w $2e01,$fffe
dc.w $0192,$f00
dc.w $2f01,$fffe
dc.w $0192,$f00
dc.w $3001,$fffe
dc.w $0192,$f00
dc.w $3101,$fffe
dc.w $0192,$f00
dc.w $3201,$fffe
dc.w $0192,$f00
dc.w $3301,$fffe
dc.w $0192,$f00
dc.w $3401,$fffe
dc.w $0192,$00f

dc.w $01a6,$f00
dc.w $01ae,$f00
dc.w $01b6,$f00

dc.w $4d01,$fffe
dc.w $01a6,$f20
dc.w $01ae,$f20
dc.w $01b6,$f20

dc.w $4e01,$fffe
dc.w $01a6,$f40
dc.w $01ae,$f40
dc.w $01b6,$f40

dc.w $4f01,$fffe
dc.w $01ae,$f60
dc.w $01a6,$f60
dc.w $01b6,$f60

dc.w $00e6
scrb1:
dc.w $870
dc.w $00ee
scrb2:
dc.w $2e80+$870

dc.w $5001,$fffe
dc.w $01ae,$f80
dc.w $01a6,$f80
dc.w $01b6,$f80

dc.w $5101,$fffe
dc.w $01ae,$fa0
dc.w $01a6,$fa0
dc.w $01b6,$fa0

dc.w $5201,$fffe
dc.w $01ae,$fc0
dc.w $01a6,$fc0
dc.w $01b6,$fc0

dc.w $5301,$fffe
dc.w $01ae,$fe0
dc.w $01b6,$fc0
dc.w $01a6,$fc0

dc.w $5401,$fffe
dc.w $01ae,$ef0
dc.w $01b6,$ef0
dc.w $01a6,$ef0

dc.w $5501,$fffe
dc.w $01b6,$cf0
dc.w $01ae,$cf0
dc.w $01a6,$cf0

dc.w $5601,$fffe
dc.w $01ae,$af0
dc.w $01b6,$af0
dc.w $01a6,$af0

dc.w $5701,$fffe
dc.w $01b6,$8f0
dc.w $01a6,$8f0
dc.w $01ae,$8f0

dc.w $5801,$fffe

dc.w $01a4,$80
dc.w $01b4,$80
dc.w $01aa,$80
dc.w $01a6,$f0
dc.w $01ac,$80
dc.w $01b6,$f0
dc.w $01ae,$f0

dc.w $0102
mark:
dc.w $00f0

dc.w $6001,$fffe
dc.w $0194,$f10
dc.w $6301,$fffe
dc.w $0194,$f20
dc.w $6601,$fffe
dc.w $0194,$f30
dc.w $6901,$fffe
dc.w $0194,$f40
dc.w $6c01,$fffe
dc.w $0194,$f50
dc.w $6f01,$fffe
dc.w $0194,$f60
dc.w $7201,$fffe
dc.w $0194,$f70
dc.w $7501,$fffe
dc.w $0194,$f80
dc.w $7801,$fffe
dc.w $0194,$f90
dc.w $7b01,$fffe
dc.w $0194,$fa0
dc.w $7e01,$fffe
dc.w $0194,$fb0
dc.w $8101,$fffe
dc.w $0194,$fc0
dc.w $8401,$fffe
dc.w $0194,$fd0
dc.w $8701,$fffe
dc.w $0194,$fe0
dc.w $8a01,$fffe
dc.w $0194,$ff0

dc.w $b001,$fffe
dc.w $0194,$ef0
dc.w $0196,$f

dc.w $b301,$fffe
dc.w $0194,$df0
dc.w $0196,$f
dc.w $b601,$fffe
dc.w $0194,$cf0
dc.w $0196,$f
dc.w $b901,$fffe
dc.w $0194,$bf0
dc.w $0196,$f
dc.w $bc01,$fffe
dc.w $0194,$af0
dc.w $0196,$1e
dc.w $bf01,$fffe
dc.w $0194,$9f0
dc.w $0196,$2d
dc.w $c201,$fffe
dc.w $0194,$8f0
dc.w $0196,$3c
dc.w $c501,$fffe
dc.w $0194,$7f0
dc.w $0196,$4b
dc.w $c801,$fffe
dc.w $0194,$6f0
dc.w $0196,$5a
dc.w $cb01,$fffe
dc.w $0194,$5f0
dc.w $0196,$69
dc.w $ce01,$fffe
dc.w $0194,$4f0
dc.w $0196,$78

dc.w $d101,$fffe
dc.w $0194,$3f0
dc.w $0196,$87
dc.w $d401,$fffe
dc.w $0194,$2f0
dc.w $0196,$96
dc.w $d701,$fffe
dc.w $0196,$a5
dc.w $0194,$1f0
dc.w $da01,$fffe
dc.w $0194,$0f0
dc.w $0196,$b4
dc.w $e001,$fffe

dc.w $01a4,$f80
dc.w $01ac,$f80
dc.w $01b4,$f80

dc.w $01a6,$ff0
dc.w $01b6,$ff0
dc.w $01ae,$ff0

dc.w $ec01,$fffe
dc.w $01b6,$f00
dc.w $01a6,$f00
dc.w $01ae,$f00

dc.w $ed01,$fffe
dc.w $01b6,$f20
dc.w $01a6,$f20
dc.w $01ae,$f20

dc.w $ee01,$fffe
dc.w $01b6,$f40
dc.w $01a6,$f40
dc.w $01ae,$f40

dc.w $f001,$fffe
dc.w $01b6,$f60
dc.w $01a6,$f60
dc.w $01ae,$f60

dc.w $f101,$fffe
dc.w $01b6,$f80
dc.w $01a6,$f80
dc.w $01ae,$f80

dc.w $f201,$fffe
dc.w $01b6,$fa0
dc.w $01a6,$fa0
dc.w $01ae,$fa0

dc.w $f301,$fffe
dc.w $01b6,$fc0
dc.w $01a6,$fc0
dc.w $01ae,$fc0

dc.w $f401,$fffe
dc.w $01b6,$fe0
dc.w $01a6,$fe0
dc.w $01ae,$fe0

dc.w $f501,$fffe
dc.w $01b6,$ff0
dc.w $01a6,$ff0
dc.w $01ae,$ff0
dc.w $fd01,$fffe
dc.w $0102,0
dc.w $00e6,0
dc.w $ffdf,$fffe
dc.w $0001,$fffe
tab2:
dc.w $0192,$f00
dc.w $0101,$fffe
dc.w $0192,$0
dc.w $0201,$fffe
dc.w $0192,0
dc.w $0301,$fffe
dc.w $0192,0
dc.w $0401,$fffe
dc.w $0192,0
dc.w $0501,$fffe
dc.w $0192,0
dc.w $0601,$fffe
dc.w $0192,0
dc.w $0701,$fffe
dc.w $0192,0
dc.w $0801,$fffe
dc.w $0192,0
dc.w $0901,$fffe
dc.w $0192,0
dc.w $0a01,$fffe
dc.w $0192,0
dc.w $0b01,$fffe
dc.w $0192,0
dc.w $0c01,$fffe
dc.w $0192,0
dc.w $0d01,$fffe
dc.w $0192,0
dc.w $0e01,$fffe
dc.w $0192,0
dc.w $0f01,$fffe
dc.w $0192,0
dc.w $1001,$fffe
dc.w $0192,$0f0
dc.w $1701,$fffe
dc.w $0100,$0200
dc.w $ffff,$fffe 

bitmstr:
	dc.w 0
	dc.w 0					;Bitmap Strct.
	dc.b 0
	dc.b 0
	dc.w 0

bitplane1:
	dc.l $40000
bitplane2:
	dc.l $42e80
bitplane3:
	dc.l $45540
bitplane4:
	dc.l $47fe0
bitplane5:
	dc.l $4aa80

gfxbase:
	dc.l 0
difobase:
	dc.l 0
font:
	dc.l 0				;diverse Zeiger
file:
	dc.l 0
rastport:
	dc.l 0

textattr:
	dc.l fontname
	dc.w 12
	dc.b 0
	dc.b 0

fontname:
	dc.b 'is.font',0

picname:
	dc.b 'usi.data',0
filename:
	dc.b 'yello',0
doslib:
	dc.b 'dos.library',0
gfxlib:
	dc.b 'graphics.library',0
difolib:
	dc.b 'diskfont.library',0

even


test:
	lea$50000,a0
	move#$4000,$dff09a
rat:
	btst#6,$bfe001			;Routine um Sprite Move Daten 
	beq ende			;zu kriegen.Nur fuer Kickstart 33.180
	cmp.b #1,$dff006		;Joystick in Port 2
	bne rat
	move.l #$800,d0
su:
	sub.l #1,d0
	bne su

	move $dff00c,d0
	and#$303,d0
	cmp#$3,d0
	beq r
	cmp#$300,d0
	beq r
	cmp#0,d0
	beq r1
	add.b#1,counter
	cmp.b#3,counter
	bne r1
	clr.b counter
	cmp#$100,d0
	beq up

	cmp.b#3,us
	beq r1
	add.b #1,us
	bra r1
up:
	cmp.b#-3,us
	beq r1
	sub.b #1,us
	bra r1

ende:
	rts

r:
	add.b #1,counter
	cmp.b #3,counter
	bne r1
	move.b #0,counter
	cmp#$300,d0
	bne sprr
	cmp.b #-3,rs
	beq r1
	sub.b #1,rs
	bra r1
sprr:
	cmp.b #3,rs
	beq re
	add.b #1,rs
re:
	move.b #0,counter
r1:
	move.b rs,d0
	add.b d0,$4ef1
	move.b us,d0
	and#$80,d0
	cmp#$80,d0
	beq r2
	move.b us,d0
	move.b $4ef0,d1
	add.b d0,d1
	cmp.b #$f0,d1                ;max tiefe
	bcc r3
	bra r4
r2:
	move.b us,d0
	move.b $4ef0,d1
	sub.b d0,d1
	cmp.b #$d4,d1                ;max hoehe
	bcs r3

r4:
	move.b us,d0
	add.b d0,$4ef0
r3:
	move.b $4ef0,d0
	add.b #$0c,d0
	move.b d0,$4ef2
	move.l $4ef0,(a0)+
	bra rat
rs:
	dc.b 0
us:
	dc.b 0
counter:
	dc.b 0

even

pointer1:
	dc.l $4da80
pointer2:
	dc.l 0
pointer3:
	dc.l 0
pointer4:				;Sprite Move Pointer
	dc.l 0
pointer5:
	dc.l 0
pointer6:
	dc.l $4dd10
pointer7:
	dc.l 0
pointer8:
	dc.l 0
pointer9:
	dc.l 0
pointer10:
	dc.l 0
pointer11:
	dc.l 0
pointer12:
	dc.l $4f000
pointer13:
	dc.l 0
pointer14:
	dc.l 0
pointer15:
	dc.l 0
pointer16:
	dc.l $50000
pointer17:
	dc.l 0
pointer18:
	dc.l 0
pointer19:
	dc.l 0
pointer20:
	dc.l 0
pointer21:
	dc.l 0
shift:
	dc.w 0
scrcounter:
	dc.w 0
tp:
	dc.l textbuf

initrapo:
	move.l gfxbase,a6
	lea rapo,a1				;Rastport Init
	jsr -198(a6)
	move.l#bitmstr,rapo+4
	rts
rapo:
dc.l 0
dc.l 0
dc.l 0
dc.l 0
dc.l 0
dc.l 0					;rastport Strct
dc.b 0
dc.b 0
dc.b 0
ao:
dc.b 0
dc.b 0
dc.b 0
dc.b 0
dc.b 0
dc.w 0
dc.w 0
xy:
dc.w 0
dc.w 0

dc.b 0,0,0,0,0,0,0,0

dc.w 0
dc.w 0

dc.l 0
dc.b 0
dc.b 0
dc.w 0
dc.w 0
dc.w 0
dc.w 0
dc.l 0
dc.l 0
dc.l 0
dc.w 0,0,0,0,0,0,0
dc.b 0,0,0,0,0,0,0,0

textbuf:
dc.b 'THE UNDERGROUND SOFT IMPORT (U.S.I)  AND  THE ASSEMBLER'
DC.B ' FORCE (T.A.F)  PRESENTS THE NEWEST DEMO VERSION OF "INS'
DC.B 'ANITY FIGHT" !   FIRST SOME GREETINGS'
DC.B ' TO : SWISS CRACKING ASSOCIATION (THANKS FOR THE INFOS!), '
DC.B 'THE SYNTHIWIZARD (THANKS FOR ALL THE SOUNDS), VIRUS (THROW'
DC.B ' AWAY YOUR ST !!), BIG APPLE, SUPRA SOFT INC., ' 
DC.B 'CHARLY (THANKS FOR THE HARDWARE), JMC, '
DC.B 'TAXOR AND GWL (THANKS FOR THE SOFTWARE),'
DC.B ' MEGABYTE (THE FIRST),  THE LIGHT CIRCLE ('
DC.B 'SUPER INTROS!), THE STAR FRONTIERS (I HOPE YOU ARE NOT TOO'
DC.B ' ANGRY, BUT I THINK YOUR FONT IS THE BEST ONE), ELECTRONIC CRACKI'
DC.B 'NG ASSOCIATION (THE BEST!!), HQC (SUPER SOUND IN YOUR INTRO-'
DC.B 'MULTILOADER), CREW 1001, DYNAMIC DUO, THE NEW AGE, ERRORSOFT,'
DC.B ' HOTLINE, THE DEAL '
DC.B ' AND TO ALL THE OTHERS.  MESSAGE TO ALL PROGRAM'
DC.B 'MERS ON THE AMIGA : "C" IS A SUPER LANGUAGE, BUT IF YOU WANT'
DC.B ' TO WRITE A GAME OR AN INTRO, YOU SHOULD THROW YOUR C-COMPILER'
DC.B ' IN THE TRASHCAN !!.       THIS INTRO WAS CODED 19.4.87' 
dc.b ' BY CHRIS,   '
DC.B ' THE SOUND IS FROM YELLO,      NOW YOU CAN PRESS THE'
DC.B ' LEFT MOUSE BUTTON TO LOAD WORKBENCH          '
DC.B 0
Even

colortable1:
	dc.w $f00,$f20,$f40,$f60,$f80,$fa0,$fc0,$fe0,$ef0,$cf0,$af0,$8f0
	dc.w $6f0,$4f0,$2f0,$0f0,$2e0,$4c0,$6a0,$880,$a60,$c40,$e20,$f00
	dc.w $f00
hackencounter:
	dc.w 0
flag:
	dc.w 0

dec:					;Entcruncher

	lea $60000,a0            ;gecrunchtes File
	lea $4d560,a1             ;Ziel
	move.l #$baa0,d4         ;Groesse des Ziel
	clr.l d0
loop1:
	move.b (a0),d1
	and.b #$80,d1
	cmp.b #$80,d1            ;gecruncht ?
	beq crunch
	
	clr.l d1
	move.b (a0),d1
	subq.l #1,d1
	addq.l #1,a0
normloop:
	move.b (a0)+,(a1)+
	addq.l #1,d0
	cmp.l d4,d0
	beq ende
	dbf d1,normloop
	bra loop1
crunch:
	clr.l d1
	move.b (a0),d1
	and.b #$7f,d1	
	move.b 1(a0),d2
	subq #1,d1
loop2:
	move.b d2,(a1)+
	addq.l #1,d0
	cmp.l d4,d0
	beq ende
	dbf d1,loop2
	addq.l #2,a0	
	bra loop1

