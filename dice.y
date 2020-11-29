%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include <unistd.h>

#include "dice.h"

extern FILE *yyin;

static int _roll(struct dice _d);

#ifdef WITH_LIBEDIT
#include <histedit.h>

EditLine *el;
History *hist;
HistEvent hev;
int is_interactive;

static char *_prompt(EditLine *_el);
#endif
%}

%token <dice> 	DICE
%token <value>	CONSTANT

%type <value>	expression
%type <value>	nonemptyexpr
%type <value>	value

%union {
	struct dice	dice;
	int		value;
}

%left '+' '-'
%left '*' '/'

%start expressions

%%

expressions	: /* empty */
			{ }
		| expressions expression ';'
			{
				printf("%d; ", $2);
			}
		| expressions expression lineend
			{
				printf("%d\n", $2);
			}
		| expressions error ';'
			{
				yyerrok;
				printf("<error>; ");
			}
		| expressions error lineend
			{
				yyerrok;
				printf("<error>\n");
			}

lineend		: '\n'
		| '\0'

expression	: /* empty */
			{
				$$ = 0;
			}
		| nonemptyexpr

nonemptyexpr	: nonemptyexpr '+' nonemptyexpr
			{
				$$ = $1 + $3;
			}
		| nonemptyexpr '-' nonemptyexpr
			{
				$$ = $1 - $3;
			}
		| nonemptyexpr '*' nonemptyexpr
			{
				$$ = $1 * $3;
			}
		| nonemptyexpr '/' nonemptyexpr
			{
				if ($3 == 0) {
					yyerror("div by zero");
					$$ = 0;
				} else {
					$$ = $1 / $3;
				}
			}
		| '(' nonemptyexpr ')'
			{
				$$ = $2;
			}
		| value

value		: DICE
			{
				$$ = _roll($1);
			}
		| CONSTANT

%%

int
main (int argc, char *argv[])
{
	(void) argc;
	(void) argv;

	yyin = stdin;

#ifdef WITH_LIBEDIT
	is_interactive = isatty(STDIN_FILENO);
	
	if (is_interactive) {
		hist = history_init();
		history(hist, &hev, H_SETSIZE, 100);

		el = el_init(*argv, yyin, stdout, stderr);
		el_set(el, EL_HIST, history, hist);
		el_set(el, EL_EDITOR, "emacs");
		el_set(el, EL_PROMPT, _prompt);
	}

	yywrap();
#endif

	srandomdev();

	return (yyparse());
}

void
yyerror(const char *msg)
{
	fprintf(stderr, "E: %s\n", msg);
}

static int
_roll(struct dice d)
{
	int s = 0;

	if (d.count == 0) {
		return (0);
	}

	if (d.sides == 0) {
		return (0);
	}

	for (int i = 0; i < d.count; i++) {
		int v = (random() % d.sides) + 1;
		s += v;
	}

	return (s);
}

#ifdef WITH_LIBEDIT
char *
_prompt(EditLine *el)
{
	return ("dice > ");
}
#endif
