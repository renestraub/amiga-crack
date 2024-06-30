
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
	move.l a0,a4

	add.l #184,a0
	move (a0),d7
	move 2(a0),d6
	mulu d7,d6		; Lange in Bytes

;	cmpa #1,4(a0)
;	beq loop
	move #2,4(a0)		; nur noch 1 Bitmap
	move.l 10(a0),d5
	rts


;	move.l (a0),a0
;	move.l #640,d0
;	move.l #256,d1		; Breite & Hoehe holen

;	move.l gfxbase,a6
;	jsr -498(a6)		; Free Raster

	move.l intuibase,a6
	jsr -390(a6)		; Rethink Display
loop:
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