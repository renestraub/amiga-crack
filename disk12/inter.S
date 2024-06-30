a:

move.l $6c,a0
move.l a0,a2
lea lab,a1
move.l a0,(a1)
lea prog,a1
move.l a1,(a0)

prog:
move #$0,$dff180
wait:
btst #6,$bfe001
beq exit

dc.w $4ef9
lab:
dc.l 0

exit:
move.l a2,$6c
rts


