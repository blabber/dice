#pragma once

void yyerror(const char *_msg);
int yylex(void);
int yywrap(void);

struct dice {
	int count;
	int sides;
};
