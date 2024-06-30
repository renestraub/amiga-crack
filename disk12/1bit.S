
a:
	move.l 4,a6
	lea gfxtext,a1
	jsr -408(a6)
	move.l d0,gfxbase	; Open GFX

	lea inttext,a1
	jsr -408(a6)		; Open Intuition
	move.l d0,intuibase

	move.l d0,a0
	move.l d0,a6
	move.l 56(a0),a0	; Zeiger auf Screen-Struktur
	move 12(a0),d5
	move 14(a0),d6
	lsr #3,d5
	mulu d5,d6
	move.l d6,d0

	add.l #188,a0		; Zeiger auf Bitmap-Struktur
	cmpa #1,(a0)
	beq loop
	move #1,(a0)		; nur noch 1 Bitmap

	move.l 4,a6
	move.l 8(a0),a1

	jsr -210(a6)
	move.l intuibase,a6
	jsr -390(a6)		; Rethink Display
loop:
	clr.l d0
	rts

gfxbase:
	dc.l 0
intuibase:
	dc.l 0
breite:
	dc.w 0
hoehe:
	dc.w 0
inttext:
	dc.b 'intuition.library',0
even
gfxtext:
	dc.b 'graphics.library',0
