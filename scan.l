%{
#include "dice.h"
#include "y.tab.h"

#define YY_DECL int yylex(void)

#ifdef WITH_LIBEDIT
#include <histedit.h>

extern EditLine *el;
extern History *hist;
extern HistEvent hev;
extern int is_interactive;

static const char *_exprline = NULL;
static YY_BUFFER_STATE _bs = { 0 };
#endif
%}

%option noinput
%option nounput

DIGIT	[0-9]
NUMBER	{DIGIT}+
DICE	[Dd]

%x indice

%%

{DIGIT}*{DICE}{NUMBER} {
		BEGIN(indice);
		yyless(0);
	}
<indice>{
	{DIGIT}*{DICE} {
		int count = 1;
		if (yyleng > 1) {
			yytext[yyleng - 1] = '\0';
			count = strtol(yytext, NULL, 10);
		}

		yylval.dice.count = count;
	}
	{NUMBER} {
		BEGIN(INITIAL);

		yylval.dice.sides = strtol(yytext, NULL, 10);
		return DICE;
	}
}


{NUMBER} {
		yylval.value = strtol(yytext, NULL, 10);
		return CONSTANT;
	}

[ \t]	/* eat up whitespace */
\n	return '\n';
.	return yytext[0];

%%

int
yywrap()
{
#ifdef WITH_LIBEDIT
	if (is_interactive) {
		free((void *)_exprline);
		yy_delete_buffer(_bs);
		
		int num;
		_exprline = el_gets(el, &num);
		if (_exprline == NULL || num <= 0) {
			return (1);
		}

		if (*_exprline != '\n') {
			history(hist, &hev, H_ENTER, _exprline);
		}

		_bs = yy_scan_string(_exprline);

		return (0);
	}
#endif

	return (1);
}
