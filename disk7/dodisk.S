
o:
	lea	tabelle,a1
	move.l	a1,tabcnt
	bsr	init
repeat:
	bsr	getpara
	tst	d0
	bne.s	end

	bsr	loadfile
	tst	d0
	bne.s	end

	bsr	format
	bra.s	repeat
end:
	bsr	motoroff
	bsr	qu
	rts

loadfile:
	move.l	dosbase,a6
	move.l	filepointer,d1
	move.l	#$3ed,d2
	jsr	-30(a6)
	tst.l	d0
	beq.s	notfound
	move.l	d0,-(sp)
	move.l	d0,d1
	move.l	#100000,d3
	move.l	buffer,d2
	jsr	-42(a6)
	move.l	(sp)+,d1
	jsr	-36(a6)
	clr	d0
	rts
notfound:
	move	#$ffff,d0
	rts
getpara:
	move.l	tabcnt,a1
	move.l	a1,filepointer
search:		
	tst.b	(A1)+
	bne.s	search

	move.l	a1,d1
	btst	#0,d1
	beq.s	ok
	addq	#1,a1		; ungerade adresse korrigieren
ok:
	move.l	(A1)+,laenge
	move.l	(A1)+,offset
	tst.l	laenge
	beq.s	endser
	tst.l	offset
	beq.s	endser
	move.l	a1,tabcnt
	clr	d0
	rts
endser:
	move	#$ffff,d0
	rts
init:
	move.l	4,a6
	lea	dosname,a1
	jsr	-408(A6)
	move.l	d0,dosbase
	lea	inttext,a1
	jsr	-408(A6)
	move.l	d0,intbase

	move.l	intbase,a6
	lea	newwindow,a0
	jsr	-204(A6)
	tst.l	d0
	beq.L	error
	move.l	d0,window

	move.l	d0,a0

	add.l	#$56,a0
	move.l	(a0),msgport2
	lea	diskIO2,a1
	move.l	msgport2,14(A1)

	move.l	4,a6
	move.l	#1,d0		; Drive 1
	clr.l	d1
	lea	trddevice,a0
	jsr	-444(a6)		; Open Device
	tst.l	d0
	bne.L	error
	rts

motoroff:
	move.l	4,a6
	lea	diskIO2,a1
	move	#9,28(A1)			; Motor
	move.l	#0,36(A1)		; D0 = 1/0
	jsr	-456(A6)
	rts

seek:
	move.l	4,a6
	lea	diskIO1,a1
	move	#10,28(A1)			; Seek
	move.l	d0,44(A1)		; Offset in D0
	jsr	-456(a6)			; DoIO
	rts

read:
	move.l 4,a6
	lea diskIO1,a1
	move #2,28(a1)			; Read
	move.l mem,40(A1)		; Puffer in A0
	move.l #11*512,36(a1)		; Sektoren in D0
	move.l d1,44(A1)		; Offset in D1
	jsr -456(a6)			; DoIO
	rts

format:
	move.l	4,a6
	lea	diskIO2,a1
	move	#3,28(A1)
	move.l	laenge,36(a1)		; Laenge
	move.l	offset,44(A1)		; Offset
	move.l	buffer,40(A1)		; Puffer
	jsr	-456(a6)

	lea	diskio2,a1
	move	#4,28(A1)
	jsr	-456(a6)		; update
	rts

error:
	move.l #-1,d7
	rts
qu:
	move.l 4,a6
	lea diskIO2,a1
	jsr -450(A6)	; Close Device2
close:
	move.l window,a0
	move.l intbase,a6
	jsr -72(a6)	; Close Window1
	rts

dosname:
dc.b 'dos.library',0
even
inttext:
dc.b 'intuition.library',0
even
trddevice:
dc.b 'trackdisk.device',0

even
intbase:
dc.l 0
dosbase:
dc.l 0
window:
dc.l 0

diskIO1:
blk.l 20,0
diskIO2:
blk.l 20,0


msgport:
dc.l 0
msgport2:
dc.l 0
diskbuff:
dc.l $50000



null=0
newwindow:
	dc.w	160,10	;window  relative to TopLeft of screen
	dc.w	320,20	;window width and height
	dc.b	0,1	;detail and blocks
	dc.l	$200	;IDCMP flags
	dc.l	$f	;other window flags
	dc.l	NULL	;first gadget in gadget list
	dc.l	NULL	;custom CHECKMARK imagery
	dc.l	NewWindowName	;window title
	dc.l	NULL	;custom screen
	dc.l	NULL	;custom bitmap
	dc.w	80,10	;minimum width and height
	dc.w	640,50	;maximum width and height
	dc.w	1	;destination screen type
NewWindowName:
	dc.b	'Click Mouse Button to start !',0

even
counter:
dc.w 0
mem:
dc.l 0

filepointer:
	dc.l	0
buffer:
	dc.l	$50000
laenge:
	dc.l	0
offset:
	dc.l	0
tabcnt:
	dc.l	0

tabelle:
	dc.b	'hi',0		; HiScore Bild
even
	dc.l	512*39
	dc.l	512*871

	dc.b	'anim',0	; Animationssequenz
even
	dc.l	512*56
	dc.l	512*812
	dc.l	0,0,0,0,0,0,0

	dc.b	'menuc2',0
even
	dc.l	512*79
	dc.l	512*1364

	dc.b	'pic1c',0	;'FILENAME',0
even
	dc.l	512*46		;LAENGE
	dc.l	512*910		;OFFSET

	dc.b	'pic2c',0	;'FILENAME',0
even
	dc.l	512*46		;LAENGE
	dc.l	512*956		;OFFSET

	dc.b	'pic3c',0	;'FILENAME',0
even
	dc.l	512*46		;LAENGE
	dc.l	512*1002	;OFFSET

	dc.b	'pic4c',0	;'FILENAME',0
even
	dc.l	512*46		;LAENGE
	dc.l	512*1048	;OFFSET

	dc.b	'pic5c',0	;'FILENAME',0
even
	dc.l	512*46		;LAENGE
	dc.l	512*1094	;OFFSET

	dc.b	'pic6c',0	;'FILENAME',0
even
	dc.l	512*46		;LAENGE
	dc.l	512*1140	;OFFSET

	dc.b	'pic7c',0	;'FILENAME',0
even
	dc.l	512*46		;LAENGE
	dc.l	512*1186	;OFFSET

	dc.b	'pic8c',0	;'FILENAME',0
even
	dc.l	512*46		;LAENGE
	dc.l	512*1232	;OFFSET

	dc.b	'rahmenc',0	;'FILENAME',0
even
	dc.l	512*36		;LAENGE
	dc.l	512*1328	;OFFSET

	dc.b	'backgroundc',0	;'FILENAME',0
even
	dc.l	512*50		;LAENGE
	dc.l	512*1278	;OFFSET
	dc.l	0,0,0,0		; ENDE
