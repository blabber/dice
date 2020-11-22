PROGRAM ?=	dice

CC ?=		clang
CFLAGS +=	-pipe -Wall -std=c11

LEX ?=		lex
YACC ?=		yacc
YFLAGS +=	-d

.if defined(WITH_LIBEDIT)
CFLAGS +=	-DWITH_LIBEDIT
LDFLAGS +=	-ledit -ltermcap
.endif

dice: lex.yy.c y.tab.h y.tab.c dice.h
	${CC} -o ${PROGRAM} ${LDFLAGS} ${CFLAGS} lex.yy.c y.tab.c

y.tab.c: dice.y
	${YACC} ${YFLAGS} dice.y

y.tab.h: dice.y
	${YACC} ${YFLAGS} dice.y

lex.yy.c: scan.l
	${LEX} scan.l

clean:
	rm -f lex.yy.c y.tab.c y.tab.h y.output ${PROGRAM}.core ${PROGRAM}
