%{
#include <stdlib.h>
#include PARSER_HEADER
#include <math.h>
%}

%%

del    { return DEL; }
print_symtab { return PRINT_SYMTAB; }

([0-9]+|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?) {
                yylval.dvala = atof(yytext);
                return NUMBER;
        }

[ \t]   ;                /* ignore white space */

[A-Za-z_][A-Za-z_0-9]*    {       /* return symbol pointer */
                yylval.symp = sym_get_or_create(yytext);
                return NAME;
        }

"$"     { return 0; }

\n      |
.       return yytext[0];

%%

void yyerror(char*s){
        printf("%s\n",s);
}
