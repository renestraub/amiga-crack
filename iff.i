
*** Strukturen ******************************************************************

	STRUCTURE BitMapHeader,0		; BMHD chunk for ILBM files
		WORD	bmh_w
		WORD	bmh_h
		WORD	bmh_x
		WORD	bmh_y
		UBYTE	bmh_nPlanes
		UBYTE	bmh_masking
		UBYTE	bmh_compression
		UBYTE	bmh_pad1
		UWORD	bmh_transparentColor
		UBYTE	bmh_xAspect
		UBYTE	bmh_yAspect
		WORD	bmh_pageWidth
		WORD	bmh_pageHeight
	LABEL	bmh_SIZEOF

	STRUCTURE DecodePicStackFrame,0
		STRUCT	WorkPlanes,24*4		; muﬂ am Anfang sein
		STRUCT	LineBuffer,400		; max 3200 pixel bei stencil
	LABEL	LINKSIZE


*** Prototypes ******************************************************************

	IFD IFF_S
	 XDEF	@DecodePic
	 XDEF	@GetBMHD
	 XDEF	@GetColorTab
	ENDC

	IFND	IFF_S
	 XREF	@DecodePic
	 XREF	@GetBMHD
	 XREF	@GetColorTab
	ENDC
