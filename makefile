
#### Allgemeine Flags:

AFLAGS		= -ih: -l
LFLAGS		= NOICONS
ASM		= Genim2

CMODS		= constr.o iff.o
I1MODS		= intro1.o
I2MODS		= intro2.o
GMODS		= game.o

#### Regeln: 

.S.O:
		$(ASM) $*.S -o$*.o $(AFLAGS)

.C.O:
		SC $*.c

#### Programme:

All:		constr intro1 intro2 game

Constr:		$(CMODS)
		SLink FROM $(CMODS) TO $* \
		VERBOSE SMALLCODE NODEBUG NOICONS


Intro1:		$(I1MODS)
		SLink FROM $(I1MODS) TO $* \
		VERBOSE SMALLCODE NODEBUG NOICONS

Intro2:		$(I2MODS)
		SLink FROM $(I2MODS) TO $* \
		VERBOSE SMALLCODE NODEBUG NOICONS


Game:		$(GMODS)
		SLink FROM $(GMODS) TO $* \
		VERBOSE SMALLCODE NODEBUG NOICONS


