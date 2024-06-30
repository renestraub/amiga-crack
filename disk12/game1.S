

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

wait:
	move #300,d7
wait2:
	btst #6,$bfe001
	beq exit2
	
	move.l gfxbase,a6
	jsr -270(a6)
	bsr mousehandler
	clr.l d0
	move mousx,d0
	move.l schl,d1
	bsr draw_schl
	lea spr1,a1
	bsr sprmove

;	dbra d7,wait2
;	add.l #190,stufe2
;	cmp.l #3800,stufe2
;	bne c5
;	move.l #0,stufe2
;c5:
;	b