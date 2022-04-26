%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
%}

%option yylineno
%option noyywrap
%option caseless

%%
[\n\t\s ]+                    /* ignore whitespace */ ;
BEGINING                      { return START; }
[Xx]+                         { yylval.sval = strdup(yytext); return SIZE; }
[0-9]+                        {
                                // converting *char to integer with atoi() removes leading zeros
                                yylval.ival = atoi((strdup(yytext)));
                                return INTEGER;
                              }
BODY                          { return BODY; }
MOVE                          { return MOVE; }
ADD                           { return ADD; }
TO                            { return TO; }
INPUT                         { return INPUT; }
PRINT                         { return PRINT; }
["][^"]*["]                   { return TEXT; }
\;                            { return SEMICOLON; }
END                           { return FINISH; }
\.                            { return TERMINATOR; }
[A-za-z]+[A-Za-z0-9\-]*       { yylval.sval = strdup(yytext); return IDENTIFIER; }
.                             { return INVALID; }
%%