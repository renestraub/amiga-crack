;Neue Keymap! Diese Keymap wurde von der USA0  Disketten Keymap abgewandelt.
;Diese ist NICHT identisch mit der Kickstart USA0. Die Disk Keymap enthaelt
;keine DeadKeys. Meine Keymap anthaelt zusaetzlich folgende Tasten: 
 
;	F1	Dir		F2	List
;	F3	Seka		F4	Date
;	F5	Info		F6	Cd
;	F7	Cd DH0:		F8	Ed
;	F9	LoadWb		F10	Belegeung

;Weiter erhaelt man durch druecken von  Alt+a  = ae
;					Alt+u  = ue		
;					Alt+o  = oe

; Help = A + 2 * return fuer Seka


	dc.l	0	;node
	dc.l	0	;node
	dc.b	0	;type
	dc.b	0	;pri
	dc.l	Name

	dc.l	LowKeyMapTypes
	dc.l	LowKeyMap
	dc.l	LowCapsable
	dc.l	LoRepeatAble
	dc.l	HiKeyMapTypes
	dc.l	HiKeyMap
	dc.l	HiCapsAble
	dc.l	HiRepeatAble



LowCapsAble:
	dc.b	$00,$00,$FF,$03,$FF,$01,$FE,$00

HiCapsAble:
	dc.b	0,0,0,0,0,0,0

LoRepeatAble:
	DC.b	$FF,$BF,$FF,$EF,$FF,$EF,$FF,$F7

HiRepeatAble:
	dc.b	$47,$F4,$FF,$03,$00,$00,$00

LowKeyMapTypes:
	DC.L	$07070707,$07070707,$07070707,$07078007
	DC.L	$07070707,$07070707,$07070707,$80070707
	DC.L	$07070707,$07070707,$07070780,$80070707
	DC.L	$80070707,$07070707,$07070780,$07070707
	
HiKeyMapTypes:
	DC.b	$02,$00,$41,$41,$04,$02,$00,$80,$80,$80
	dc.b	$02,$80,$41,$41,$41,$41,$41,$41,$41,$41
	dc.b	$41,$41,$41,$41,$41,$41,$80,$80,$80,$80
	dc.b	$80,$40,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80

LowKeyMap:
	dc.B	$ff,$e0,$7E,$60			;~
	dc.b	$A1,$B1,$21,$31			;1
	DC.b	$C0,$B2,$40,$32			;2
	dc.b	$A3,$B3,$23,$33			;3
	dc.b	$A4,$B4,$24,$34			;4
	dc.b	$A5,$B5,$25,$35			;5
	DC.b	$DE,$B6,$5E,$36			;6
	dc.b	$A6,$B7,$26,$37			;7
	dc.b	$AA,$B8,$2A,$38			;8
	dc.b	$A8,$B9,$28,$39			;9
	DC.b	$A9,$B0,$29,$30			;0
	dc.l	$DFAD5F2D			;-
	dc.l	$ABBD2B3D			;=
	dc.l	$FCDC7C5C			;\
	DC.L	$00000000			
	dc.l	$B0B03030			;0 (NummernBlock)
	dc.l	$D1F15171			;q
	dc.l	$D7F75777			;w
	DC.L	$aea94565			;e
	dc.l	$D2F25272			;r
	dc.l	$D4F45474			;t
	dc.l	$D9F95979			;y
	DC.L	$dcfc5575			;u
	dc.l	$C9E94969			;i
	dc.l	$d6f64F6F			;o
	dc.l	$D0F05070			;p
	DC.L	$FBDB7B5B			;[
	dc.l	$FDDD7D5D			;]
	dc.l	$00000000
	dc.l	$B1B13131			;1 Nr
	DC.L	$B2B23232			;2 Nr	
	dc.l	$B3B33333			;3 Nr
	dc.l	$C4E44161			;a 
	dc.l	$D3F35373			;s
	DC.L	$C4E44464			;d
	dc.l	$C6E64666			;f
	dc.l	$C7E74767			;g
	dc.l	$C8E84868			;h
	DC.L	$CAEA4A6A			;j
	dc.l	$CBEB4B6B			;k
	dc.l	$CCEC4C6C			;l
	dc.l	$BABB3A3B			;;
	DC.L	$A2A72227			;'
	dc.l	$00000000			;
	dc.l	$00000000
	dc.l	$B4B43434			;4
	DC.L	$B5B53535			;5
	dc.l	$B6B63636			;6
	dc.l	$00000000			;
	dc.l	$DAFA5A7A			;z
	DC.L	$D8F85878			;x
	dc.l	$C3E34363			;c
	dc.l	$D6F65676			;v
	dc.l	$C2E24262			;b
	DC.L	$CEEE4E6E			;n
	dc.l	$CDED4D6D			;m
	dc.l	$BCAC3C2C			;,
	dc.l	$BEAE3E2E			;.
	DC.L	$BFAF3F2F			;/
	dc.l	$00000000
	dc.l	$AEAE2E2E			;. Nr
	dc.l	$B7B73737			;7 Nr
	DC.L	$B8B83838			;8 Nr
	dc.l	$B9B93939			;9 Nr

HiKeyMap:
	dc.l	$0000A020		;Space
	dc.l	$00000008		;BackSpace
	DC.L	Tab			;Tab
	dc.l	Enter			;Enter Nr
	dc.l	$00000A0D		;Return
	dc.l	$00009B1B		;Esc
	DC.L	$0000007F		;Del
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	DC.L	$0000FF2D		;- Nr
	dc.l	$00000000

	dc.l	auf			;Cursor
	dc.l	ab
	dc.l	vor
	dc.l	zurueck

	dc.l	f1
	dc.l	f2
	dc.l	f3
	dc.l	f4
	dc.l	f5
	dc.l	f6
	dc.l	f7
	dc.l	f8
	dc.l	f9
	dc.l	f10

	


	DC.L	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	DC.L	$00000000
	dc.l	Help			;Help
	dc.l	$00000000
	dc.l	$00000000
	DC.L	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	DC.L	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	DC.L	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	DC.L	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	DC.L	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	DC.L	$00000000
	dc.l	$00000000

Enter:	dc.b	3,4,3,4,'jo',13			;3 laenge, 4 offset 

Tab:	dc.b	$01,04,02,05,$09,$9B,$5A
Auf:	DC.b	02,$04,02,06,$9B,$41,$9B,$54
Ab:	dc.b	02,$04,02,06,$9B,$42,$9B,$53
Vor:	DC.b	02,$04,03,06,$9B,$43,$9B,$20,$40
Zurueck:
	dc.b	02,04,03,06,$9B,$44,$9B,$20,$41


f1:	dc.b	4,4,4,4,'dir',13
f2:	dc.b	5,4,5,4,'list',13
f3:	dc.b	5,4,4,9,'seka',13
	dc.b	'100',13	
f4:	dc.b	5,4,5,4,'date',13
f5:	dc.b	5,4,5,4,'info',13
f6:	dc.b	3,4,3,4,'cd '
f7:	dc.b	8,4,8,4,'cd dh0:',13
f8:	dc.b	3,4,3,4,'ed',13
f9:	dc.b	7,4,7,4,'loadwb',13

f10:	dc.b	127,4
	dc.b	88,102
	dc.b	10
	dc.b	';F1 Dir  	F2  List',13
	dc.b	';F3 Seka	F4  Date',13
	dc.b	';F5 Info	F6  Cd ',13
	dc.b	';F7 Cd dh0:	F8  Ed',13
	dc.b	';F9 Loadwb	F10 F-Tasten',13
a:	dc.b	10
	dc.b	'; ***** 6.1.1988 Chris ****',13
	dc.b	10
	dc.b	';Greetings to -C5-, Tytan and Swiss Cracking'
	dc.b	' Association',10,13

help:	dc.b	3,2,'A',13,13

Name:
	dc.b	'CHRIS',0
	dc.b	0,0
