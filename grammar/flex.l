%{
#include PARSER_HEADER
%}

%%
const                                       { return CONST; } /* reserved multicharacter tokens */
var                                         { return VAR; }
procedure                                   { return PROCEDURE; }
:=                                          { return ASSIGN; }
call                                        { return CALL; }
begin                                       { return BEGIN; }
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

[A-Za-z_][A-Za-z_0-9]*                      { return NAME; } /* from lecture slides */


.                                           { return yytext[0]; } /* return other single characters directly */ /* special */

[ \t\n]                                     ; /* consume those */


%%
int main(){
  yylex();
}
void yyerror(char*s){
printf("%s\n",s);
}
