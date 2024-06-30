;integer wert in d0 uebergeben
;in a0 erhaelt man zeiger auf ASCII

intasc:
clr.l d2
lea buf(pc),a0
cmp.l #100000,d0
bcs gretend
move.l d0,d1
lsr.l #1,d1
divu #50000,d1
move d1,d2
sub#1,d1
clr.l d3
gret:
add.l #100000,d3
dbf d1,gret
sub.l d3,d0
gretend:
add#$30,d2
move.b d2,(a0)
divs #10000,d0
add.b #$30,d0
move.b d0,1(a0)
clr d0
swap d0
divs#1000,d0
add.b #$30,d0
move.b d0,2(a0)
clr d0
swap d0
divs#100,d0
add.b #$30,d0
move.b d0,3(a0)
clr d0
swap d0
divs#10,d0
add.b #$30,d0
move.b d0,4(a0)
clr d0
swap d0
add.b #$30,d0
move.b d0,5(a0)
rts
buf:
blk 6,0
dc.w 0
