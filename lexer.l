%{
#include "parser.tab.h"
#include <string.h>

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;

extern void yyerror_lexico(int linea, const char* lexema);
%}

%option noyywrap
%option yylineno

%%

"{"         { return LBRACE; }
"}"         { return RBRACE; }
"["         { return LBRACKET; }
"]"         { return RBRACKET; }
":"         { return COLON; }
","         { return COMMA; }

"true"|"false" { yylval.sval = strdup(yytext); return BOOLEAN; }
"null"         { yylval.sval = strdup(yytext); return NULL_TOKEN; }

\"([^\"\\]|\\.)*\"                      { yylval.sval = strdup(yytext); return STRING; }
\-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?  { yylval.sval = strdup(yytext); return NUMBER; }

[ \t\r\n]+  { /* Ignorar espacios y saltos de línea */ }

.           { yyerror_lexico(yylineno, yytext); return -1; }

%%