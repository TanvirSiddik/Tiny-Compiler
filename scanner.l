%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void yyerror(const char* msg);
%}

%option noyywrap

%%

[ \t\n]+                 { /* ignore whitespace */ }
"//".*                   { /* ignore single-line comments */ }

"if"                     { return IF; }
"else"                   { return ELSE; }
"for"                    { return FOR; }
"print"                  { return PRINT; }

"=="                     { return EQ; }
"!="                     { return NEQ; }
"<="                     { return LE; }
">="                     { return GE; }
"<"                      { return LT; }
">"                      { return GT; }

"+"                      { return PLUS; }
"-"                      { return MINUS; }
"*"                      { return TIMES; }
"/"                      { return DIVIDE; }
"="                      { return ASSIGN; }

"("                      { return LPAREN; }
")"                      { return RPAREN; }
"{"                      { return LBRACE; }
"}"                      { return RBRACE; }
";"                      { return SEMICOLON; }

[0-9]+(\.[0-9]+)?        { 
                           yylval.num = atof(yytext); 
                           return NUMBER; 
                         }

[a-zA-Z][a-zA-Z0-9_]*    { 
                           yylval.id = malloc(strlen(yytext) + 1);
                           strcpy(yylval.id, yytext);
                           return IDENTIFIER; 
                         }

\"[^\"]*\"               { 
                           int len = strlen(yytext) - 2;
                           yylval.str = malloc(len + 1);
                           strncpy(yylval.str, yytext + 1, len);
                           yylval.str[len] = '\0';
                           return STRING; 
                         }

.                        { yyerror("Invalid character"); }

%%