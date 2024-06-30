

LaserGadg:
	dc.l	Livesgadg
	dc.w	480,56
	dc.w	38,11
	dc.w	$2
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type
	dc.l	Border111;gadget border or image to be rendered
	dc.l	Border122	
	dc.l	0	 
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure for string gadgets
	dc.w	1	;user-definable data (ordinal gadget number)
	dc.l	0	;pointer to user-definable data

Livesgadg:
	dc.l	ExtGadg	;next gadget
	dc.w	524,56	;o of hit box relative to window TopLeft
	dc.w	38,11	;hit box width and height
	dc.w	$2 	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type
	dc.l	Border111;gadget border or image to be rendered
	dc.l	Border112
	dc.l	0	 
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure for string gadgets
	dc.w	2	;user-definable data (ordinal gadget number)
	dc.l	0	;pointer to user-definable data

extgadg:
	dc.l	holdgadg
	dc.w	568,56	;orY of hit box relative to window TopLeft
	dc.w	38,11	;hit box width and height
	dc.w	$2 	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type
	dc.l	Border111
	dc.l	border112	
	dc.l	0	 
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure for string gadgets
	dc.w	3	;user-definable data (ordinal gadget number)
	dc.l	0	;pointer to user-definable data

holdgadg:
	dc.l	autogadg
	dc.w	480,78	;origin XY of hit box relative to window TopLeft
	dc.w	38,11	;hit box width and height
	dc.w	2 	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type
	dc.l	Border111	;gadget border or image to be rendered
	dc.l	border112	
	dc.l	0	 
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure for string gadgets
	dc.w	4	;user-definable data (ordinal gadget number)
	dc.l	0	;pointer to user-definable data

autogadg:
	dc.l	bonusgadg	;next gadget
	dc.w	524,78	;origin XY of hit box relative to window TopLeft
	dc.w	38,11	;hit box width and height
	dc.w	2 	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type
	dc.l	Border111;gadget border or image to be rendered
	dc.l	Border112
	dc.l	0	 
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure for string gadgets
	dc.w	5	;user-definable data (ordinal gadget number)
	dc.l	0	;pointer to user-definable data

bonusgadg:
	dc.l	levelgadg	;next gadget
	dc.w	568,78	;origin XY of hto window TopLeft
	dc.w	38,11	;hit box width and height
	dc.w	2 	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type
	dc.l	Border111	;gadget border or image to be rendered
	dc.l	Border112	
	dc.l	0	 
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure for string gadgets
	dc.w	6	;user-definable data (ordinal gadget number)
	dc.l	0	;pointer to user-definable data
levelgadg:
	dc.l	threegadg
	dc.w	480,90
	dc.w	38,11	;hit box width and height
	dc.w	2 	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type
	dc.l	Border111	;gadget border or image to be rendered
	dc.l	Border112	
	dc.l	0	 
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure for string gadgets
	dc.w	7	;user-definable data (ordinal gadget number)
	dc.l	0	;pointer to user-definable data

threegadg:
	dc.l	0
	dc.w	524,90
	dc.w	38,11	;hit box width and height
	dc.w	2 	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type
	dc.l	Border111	;gadget border or image to be rendered
	dc.l	Border112	
	dc.l	0	 
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure for string gadgets
	dc.w	6	;user-definable data (ordinal gadget number)
	dc.l	0	;pointer to user-definable data
