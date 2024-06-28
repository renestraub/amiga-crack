#ifndef IFF_H
#define IFF_H

typedef void *IFFFILE;              /* The IFF 'FileHandle' structure */

/************** FUNCTION DECLARATIONS ***********************************/

struct BitMapHeader *GetBMHD(IFFFILE);
LONG GetColorTab(WORD *,IFFFILE);
BYTE DecodePic(struct BitMap *,IFFFILE);

/************** COMMON IFF IDs ******************************************/

#define MakeID(a,b,c,d) ((ULONG)(a)<<24L|(ULONG)(b)<<16L|(c)<<8|(d))

/* List of the most useful IDs, NOT complete (to be continued sometimes...) */

#define ID_FORM MakeID('F','O','R','M')
#define ID_PROP MakeID('P','R','O','P')
#define ID_LIST MakeID('L','I','S','T')
#define ID_CAT  MakeID('C','A','T',' ')

#define ID_ANIM MakeID('A','N','I','M')
#define ID_ANHD MakeID('A','N','H','D')
#define ID_BMHD MakeID('B','M','H','D')
#define ID_BODY MakeID('B','O','D','Y')
#define ID_CAMG MakeID('C','A','M','G')
#define ID_CLUT MakeID('C','L','U','T')
#define ID_CMAP MakeID('C','M','A','P')
#define ID_CRNG MakeID('C','R','N','G')
#define ID_DLTA MakeID('D','L','T','A')
#define ID_ILBM MakeID('I','L','B','M')
#define ID_SHAM MakeID('S','H','A','M')

#define ID_8SVX MakeID('8','S','V','X')
#define ID_ATAK MakeID('A','T','A','K')
#define ID_NAME MakeID('N','A','M','E')
#define ID_RLSE MakeID('R','L','S','E')
#define ID_VHDR MakeID('V','H','D','R')


/************** STRUCTURES **********************************************/

struct Chunk			/* Generic IFF chunk structure */
{
	LONG  ckID;
	LONG  ckSize;
};

struct BitMapHeader		/* BMHD chunk for ILBM files */
{
	UWORD w,h;
	WORD  x,y;
	UBYTE nPlanes;
	UBYTE masking;
	UBYTE compression;
	UBYTE pad1;
	UWORD transparentColor;
	UBYTE xAspect,yAspect;
	WORD  pageWidth,pageHeight;
};

struct AnimHeader		/* ANHD chunk for ANIM files */
{
	UBYTE	Operation;
	UBYTE	Mask;
	UWORD	W;
	UWORD	H;
	WORD	X;
	WORD	Y;
	ULONG	AbsTime;
	ULONG	RelTime;
	UBYTE	Interleave;
	UBYTE	pad0;
	ULONG	Bits;
	UBYTE	pad[16];
};


#endif
