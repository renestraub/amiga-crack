o:
move.l $6c,oldveq
move.l #int,$6c
rts

ioff:
move.l oldveq,$6c
rts

int:
movem.l d0-d7,-(a7)
movem.l a0-a6,-(a7)

move#0,$dff180

movem.l (a7)+,a0-a6
movem.l (a7)+,d0-d7

dc.w $4ef9
oldveq:
dc.l 0

