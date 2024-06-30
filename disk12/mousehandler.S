
	move.l #$40000,a0
	move.w #10000,d0
cls:	move.l #0,(a0)+
	dbra d0,cls

	move.w 	$dff00a,d0
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#$ff,d0
	move.b	d0,oldx
	move.b	d1,oldy

	move.l	#sprite,d0
	move.w	d0,copperl+6
	swap	d0
	move.w	d0,copperl+2
	move.l	#copperl,$dff080
	move.l	$6c,iveq
	move.l	#mousehandler,$6c

loop:	btst	#6,$bfe001
	bne	loop
	move.l	#$22f8,$dff080
	move.l	iveq,$6c
	rts

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
	tst.b	d3
	beq	mous6
	move.b	d3,d4
	tst.b	d3
	bpl	mous4
	neg.b	d3
mous4:	cmp.b	#127,d3
	bgt	mous5
	ext.w	d4
	sub.w	d4,imgy
	bra	mous6
mous5:	sub.b	#255,d4
	ext.w	d4
	sub.w	d4,imgy

mous6:	move.w	imgx,d0			; set real cords
	asr.w	#1,d0			; check boundary
	move.w	imgy,d1
	asr.w	#1,d1
	tst.w	d0
	bpl	mous7
	move.w	#0,d0
	move.w	#0,imgx
mous7:	cmp.w	#320,d0
	blt	mous8
	move.w	#319,d0
	move.w	#638,imgx
mous8:	tst.w	d1
	bpl	mous9
	move.w	#0,d1
	move.w	#0,imgy
mous9:	cmp.w	#200,d1
	blt	mous10
	move.w	#199,d1
	move.w	#398,imgy

mous10:	move.w	d0,mousx
	move.w	d1,mousy

	add.w	#128,d0			; set sprite x
	btst	#0,d0
	beq	spr1
	bset	#0,sprite+3
	bra	spr2
spr1:	bclr	#0,sprite+3
spr2:	lsr.w	#1,d0
	move.b	d0,sprite+1

	add.w	#44,d1			; set sprite y
	move.b	d1,sprite
	add.b	#13,d1
	move.b	d1,sprite+2

	movem.l	(sp)+,d0-d7/a0-a6
	dc.w	$4ef9			; jump back
iveq:	dc.l	0

oldx:	dc.b	0
oldy:	dc.b	0
imgx:	dc.w	0
imgy:	dc.w	0

mousx:	dc.w	0
mousy:	dc.w	0

copperl:
dc.w $0120,$0000
dc.w $0122,$0000
dc.w $0124,$0000
dc.w $0126,$0000
dc.w $0128,$0000
dc.w $012a,$0000
dc.w $012c,$0000
dc.w $012e,$0000
dc.w $0130,$0000
dc.w $0132,$0000
dc.w $0134,$0000
dc.w $0136,$0000
dc.w $0138,$0000
dc.w $013a,$0000
dc.w $013c,$0000
dc.w $013e,$0000

dc.w $008e,$2c81
dc.w $0090,$f4c1
dc.w $0104,$0024
dc.w $0092,$0038
dc.w $0094,$00d2
dc.w $0102,$0000
dc.w $0108,$0000
dc.w $010a,$0000
dc.w $00e0,$0004;Bit plane 1
dc.w $00e2,$0000
dc.w $00e4,$0004;Bit plane 2
dc.w $00e6,$1f40
dc.w $00e8,$0004;Bit plane 3
dc.w $00ea,$3e80
dc.w $00ec,$0004;Bit plane 4
dc.w $00ee,$5dc0
dc.w $00f0,$0004;Bit plane 5
dc.w $00f2,$7d00

dc.w $0180,$0000
dc.w $01a0,$0000
dc.w $01a2,$0777
dc.w $01a4,$0555
dc.w $01a6,$0999

dc.w $0100,$5200
dc.w $ffff,$fffe

sprite:	dc.w	$6d60,$7200
	dc.w	$ff00,$ff00
	dc.w	$ff80,$8080
	dc.w	$c0c0,$bf40
	dc.w	$c180,$be80
	dc.w	$c300,$bd00
	dc.w	$c180,$be80
	dc.w	$c8c0,$b740
	dc.w	$dc60,$aba0
	dc.w	$7630,$55d0
	dc.w	$2318,$22e8
	dc.w	$01b0,$0150
	dc.w	$00e0,$00a0
	dc.w	$0040,$0040
	dc.w	$0000,$0000

