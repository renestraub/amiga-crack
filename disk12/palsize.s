; Palsize : Oeffnet aktuelles Window auf Palgroesse

a:
	move.l 4,a6
	lea inttext,a1
	jsr -408(a6)
	move.l d0,a0
	move.l d0,a6
	move.l 56(a0),a0
	move.l 4(a0),a0

	move.l a0,-(sp)
	move 4(A0),d0
	move 6(a0),d1
	ext.l d0
	ext.l d1
	neg.l d0
	neg.l d1
	jsr -168(a6)		; Move Window to top left edge

	move.l (sp)+,a0
	move 10(a0),d3
	move 8(a0),d2
	move.l #640,d0
	move.l #256,d1
	sub.l d2,d0
	sub.l d3,d1
	jsr -288(a6)		; Size Window 

	clr.l d0
	rts

inttext:
	dc.b 'intuition.library',0
	dc.b 'PALSIZE by -C5- for all AMIGA-User'
