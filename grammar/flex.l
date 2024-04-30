%{
#include PARSER_HEADER
%}

%%
const                                       { printf("lexer: returning token CONST\n"); return CONST; } /* reserved multicharacter tokens */
var                                         { return VAR; }
procedure                                   { return PROCEDURE; }
:=                                          { return ASSIGN; }
call                                        { return CALL; }
begin                                       { return BGN; }
end                                         { return END; }
if                                          { return IF; }
then                                        { return THEN; }
while                                       { return WHILE; }
do                                          { return DO; }
odd                                         { return ODD; }
\<\>                                        { return NE; }
\<=                                         { return LTE; }
\>=                                         { return GTE; }



([0-9]+|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?) {return NUMBER; } /* from lecture slides */ /* pattern matching tokens */

[A-Za-z_][A-Za-z_0-9]*                      { printf("lexer: returning token identifier: %s\n", yytext); return IDENTIFIER; } /* from lecture slides */

[ \t\n]                                     ; /* consume those */

.                                           { return *yytext; } /* return other single characters directly */ /* special */

%%

void yyerror(char*s){
printf("%s\n",s);
}
