IFF_S:
		SECTION	text,CODE

		OPT	O+
		OPT	OW-

		INCDIR	"INCLUDE:"

		INCLUDE	"graphics/gfx.i"
		INCLUDE "iff.i"

ClearError:
SetError:	rts


@DecodePic:
DecodePicFunc:	movem.l	d1-d7/a0-a6,-(sp)

		lea	-LINKSIZE(SP),SP	; Lokalen Datenraum schaffen
	;;;	movea.l	a6,a5			; A5: IFFBase für SetError()
		movea.l	a0,a3			; A3: BitMap
		movea.l	a1,a4			; A4: IFFFile

	*** Testen ob ILBM-File

	*** BitMapHeader suchen und nach A2

		bsr	GetBMHDFunc		; BitMapHeader suchen
2$:		movea.l	d0,a2			; A2: BitMapHeader

	*** Testen ob Bild-Depth <= BitMap Depth

		move.b	bmh_nPlanes(a2),d2	; D2: Depth (Minimum)
		beq	.Okay			; Bild hat 0 planes --->
3$:
	*** Planes in Arbeitsbereich kopieren

		moveq.l	#23,d0			; Max. 24 Bitplanes
		lea	bm_Planes(a3),a0	; Source
		lea	WorkPlanes(SP),a1	; Destination
.CopyLoop:	move.l	(a0)+,(a1)+
		dbf	d0,.CopyLoop

	*** BODY-Chunk suchen und nach A0, BODY-Ende nach A4

		move.l	#'BODY',d0
		movea.l	a4,a1			; IFF-File
		bsr	FindChunkFunc
		movea.l	d0,a0			; A0 :  Body-Adresse
		addq.l	#4,a0			; 'BODY' überspringen
		movea.l	(a0)+,a4		; Chunk-size
		adda.l	a0,a4			; A4 :  Body-Endadresse

	*** Compression testen und entsprechende Routine nach A6

		move.b	bmh_compression(a2),d0
		bne.b	5$
		lea	CopyRow(PC),a6		; Not crunched
		bra.b	7$			; --->
5$:
		subq.b	#1,d0				; CmpByteRun1 ?
		bne.b	6$				; ja --->
		lea	Decompress_BYTERUN1(PC),a6	; DecompressBlock.S
		bra.b	7$				; --->
6$:
	;;	moveq	#IFFL_ERROR_BADCOMPRESSION,d0
		bra.b	.Error
7$:
	*** Masking testen und wenn 'hasmask' (Stencil) D7.B:=$FF, sonst $00

		cmpi.b	#1,bmh_masking(a2)	; 'mskHasMask' ?
		seq	d7			; wenn ja: D7 := $FF

	*** Modulos setzen etc.

.doit:		moveq.l	#0,d4			; D4 :  Source-Modulo
		move.w	bmh_w(a2),d4
		add.w	#15,d4			; auf WORD aufrunden
		lsr.l	#3,d4
		bclr	#0,d4			; auf WORD aufrunden

		moveq.l	#0,d5
		move.w	bm_BytesPerRow(a3),d5	; D5 :  Destination-Modulo

		moveq.l	#0,d6
		move.w	bm_Rows(a3),d6		; D6 :  Max. Anzahl Zeilen
		cmp.w	bmh_h(a2),d6		; BitMap zu groß ?
		ble.b	8$			; nein --->
		move.w	bmh_h(a2),d6		; Sonst Höhe aus bmh nehmen
8$:
		bra.b	.CheckCond		; ---> für dbf

	*** Hauptschleife

.body1:		moveq	#0,d3			; Init plane-counter
		lea	WorkPlanes(SP),a2	; A2 : Arbeitskopie der Planes

.body2:		move.l	d4,d0			; Source bytes per row
		cmp.b	bm_Depth(a3),d3		; Is there a dest-plane ?
		bhs.b	.NoDest			; nope ---> skip it
		movea.l	(a2),a1			; Adrese der aktuellen Plane
		add.l	d5,(a2)+		; Plane auf nächste Linie
		bra.b	9$
.NoDest:	lea	LineBuffer(SP),a1	; Plane ins NIL kopieren
9$:		jsr	(a6)			; Linie copyren / decrunchen
		addq.b	#1,d3			; INC planecounter
		cmp.b	d2,d3
		blt.b	.body2			; ---> Nächste Plane

		tst.b	d7			; Maske zu überhüpfen ?
		beq.b	.NoMask			; nein --->
		move.l	d4,d0			; Source bytes per row
		lea	LineBuffer(SP),a1	; Maske zur Hölle schicken
		jsr	(a6)			; Linie copyren / decrunchen
.NoMask:
.CheckCond:	cmpa.l	a4,a0			; fertig ?
		dbhs	d6,.body1		; wenn nicht: nächste Linie

.Okay:		;;bsr	ClearError		; IFFError rücksetzen, D0 := 1
		;;bra.b	.Ende

.Error:		;;bsr	SetError		; IFFError setzen, clr.l d0

.Ende:		lea	LINKSIZE(SP),SP

		movem.l	(sp)+,d1-d7/a0-a6
		rts

*************** 1 Linie kopieren *****************************************

copyloop:	move.b	(a0)+,(a1)+
CopyRow:	dbf	d0,copyloop
		rts


DecompressBlockFunc:
		subq.l	#1,d1
		beq.b	Decompress_BYTERUN1	; Modus == 1
;;;;;		bmi	Compress_NONE		; Modus == 0

	*** Unbekannter Modus --> Error setzen

	;;	movem.l	a5-a6,-(SP)
	;;	movea.l	a6,a5			; A5 :  IFFBase für SetError()
	;;	moveq.l	#IFFL_ERROR_BADCOMPRESSION,d0
	;;	bsr	SetError		; Setzt auch D0 auf 0
		movem.l	(SP)+,a5-a6
		rts

*****************************************************************************
**	CmpByteRun1 dekomprimieren

Decompress_BYTERUN1:
		movem.l	d0/d2,-(SP)

1$:		moveq.l	#0,d1
		move.b	(a0)+,d1	; D1 :  nächstes Kommando-Byte
		bmi.b	2$		; crunched --->

.CopyLoop:	move.b	(a0)+,(a1)+	; D1+1 Bytes normal kopieren
		subq.l	#1,d0		; DEC length counter
		dble	d1,.CopyLoop
		bra.b	3$		; --->
2$:
		neg.b	d1
		bmi.b	3$		; ~$80 (== $80) ist 'NOP'
		move.b	(a0)+,d2	; Zu repetierender Wert
.RepLoop:	move.b	d2,(a1)+
		subq.l	#1,d0		; DEC length counter
		dble	d1,.RepLoop
3$:
		tst.l	d0		; Linie fertig ? (Braucht's das tst??)
		bgt.b	1$		; noch nicht ---> Loop

		movem.l	(SP)+,d0/d2
		rts


FindChunkFunc:	movea.l	4(a1),a0	; FORM-Länge
		addq.l	#8,a1		; FORM.... überspringen
		adda.l	a1,a0		; A0 zeigt jetzt ans Ende
		addq.l	#4,a1		; FORM-Typ überspringen
		tst.l	d0		; Chunk-ID == 0 ?
		bne.s	1$		; nein --->
		movea.l	a0,a1		; Sonst Ende des FORMs
		bra.s	99$		; zurückgeben

1$:		cmp.l	(a1),d0		; Chunk gefunden ?
		beq.s	99$		; ja!
		move.l	4(a1),d1	; Länge dieses Chunks
		addq.l	#1,d1		; auf WORD ...
		bclr	#0,d1		; ... aufrunden
		lea	8(a1,d1.l),a1	; Name & Länge dazu und zu A1 dazu
		cmpa.l	a0,a1		; FORM-Ende erreicht ?
		bcs.s	1$		; noch nicht --->
		suba.l	a1,a1		; Code für "nicht gefunden"
99$:
		move.l	a1,d0		; Resultat nach D0, set/reset Z-Flag
		rts


@GetBMHD:
GetBMHDFunc:	movem.l	d1-d7/a0-a6,-(sp)

		move.l	#'BMHD',d0
		bsr	FindChunkFunc		; setzt Z-Flag wenn not found
		addq.l	#8,d0			; BMHD.... überspringen
99$:
		movem.l	(sp)+,d1-d7/a0-a6
		rts


@GetColorTab:
GetColorTabFunc:
		movem.l	d1-d7/a0-a6,-(sp)
		movea.l	a0,a2			; Ziel-Adresse

		move.l	#'CMAP',d0
		bsr	FindChunkFunc
	;;	tst.l	d0
		beq.s	99$			; nicht gefunden --->
		movea.l	d0,a0

		addq.l	#4,a0			; Chunk-Namen überlesen
		move.l	(a0)+,d4		; Chunk-size
		divs	#3,d4			; Anzahl Farben
		ext.l	d4			; für D0
		move.l	d4,d0			; Resultat: Anzahl Farben

		moveq	#256-$f0,d5		; Color-Maske $f0
		neg.b	d5			; Toebes-Optimierlung
		bra.s	1$			; Für dbf

.Loop:		move.b	(a0)+,d1		; rot
		and.w	d5,d1			; Nur Bits 7-4 benützen
		move.b	(a0)+,d2		; grün
		and.w	d5,d2			; Nur Bits 7-4 benützen
		move.b	(a0)+,d3		; blau
		and.w	d5,d3			; Nur Bits 7-4 benützen
		lsl.w	#4,d1			; rot  << 4
		lsr.w	#4,d3			; blau >> 4
		or.w	d2,d1
		or.w	d3,d1
		move.w	d1,(a2)+		; in Farbtabelle eintragen
1$:		dbf	d4,.Loop
99$:
		movem.l	(sp)+,d1-d7/a0-a6
		rts
