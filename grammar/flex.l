%{
#include PARSER_HEADER
#define GIVE_LEX_INFO 0
#if GIVE_LEX_INFO
// see variadic macros: https://gcc.gnu.org/onlinedocs/cpp/Variadic-Macros.html
#define LEX_INFO(...) \
  printf("lexer: "__VA_ARGS__);
#else 
#define LEX_INFO(...) \
;
#endif
void multiline_comment();
// below line works.
// \/\/.*$                                     { LEX_INFO("consumnig single line comment: %s\n", yytext); }
%}

%%

\/\*                                        { /*unfortunetely, flex, and lex do not support lazy matching pattern.
                                              https://stackoverflow.com/questions/4166194/how-do-i-write-a-non-greedy-match-in-lex-flex
                                              https://www.lysator.liu.se/c/ANSI-C-grammar-l.html */ multiline_comment(); } 
const                                       { LEX_INFO("lexer: returning token CONST\n"); return CONST; } /* reserved multicharacter tokens */
var                                         { return VAR; }
procedure                                   { return PROCEDURE; }
function                                    { return FUNCTION; }
return                                      { return RETURN; }
break                                       { return BREAK; }
writeline                                   { return WRITELINE; }
write                                       { return WRITE; }
read                                        { return READ; }
:=                                          { return ASSIGN; }
call                                        { return CALL; }
begin                                       { return BGN; }
end                                         { LEX_INFO("lexer: returning token end at line %d\n",yylineno);return END; }
if                                          { return IF; }
else                                        { return ELSE; }
then                                        { return THEN; }
while                                       { return WHILE; }
for                                         { return FOR; }
do                                          { return DO; }
odd                                         { return ODD; }
\<\>                                        { return NE; }
\<=                                         { return LTE; }
\>=                                         { return GTE; }



([0-9]+|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?) { LEX_INFO("lexer: returning token number: %f\n", atof(yytext)); return NUMBER; } /* from lecture slides */ /* pattern matching tokens */

[A-Za-z_][A-Za-z_0-9]*                      { LEX_INFO("lexer: returning token identifier: %s\n", yytext); return IDENTIFIER; } /* from lecture slides */

[ \t]                                     ; /* consume those */
\n                                          { /*https://stackoverflow.com/questions/3747603/lex-print-line-numbers*/ yylineno++; }
.                                           { LEX_INFO("lexer: returning identically: %s\n", yytext); return *yytext; } /* return other single characters directly */ /* special */

%%

void yyerror(char*s){
printf("%s at line: %d\n",s,yylineno);
}

// consume the stream until the first */ as done in the https://www.lysator.liu.se/c/ANSI-C-grammar-l.html
void multiline_comment(){
  // copied from https://www.lysator.liu.se/c/ANSI-C-grammar-l.html#comment:~:text=yywrap()%0A%7B%0A%09return(1)%3B%0A%7D-,comment,-()%0A%7B%0A%09char%20c%2C%20c1
  /* comment()
  {*/
    char c, c1;

  loop:
    while ((c = input()) != '*' && c != 0){
      // putchar(c); // I checked the assembly dump of the generated object file (object generated from lexer.c generated from this lex file)
      // it seems putchar is not used. and man putchar says putchar is to put character to standart output. and from the debug prints I made, I decide to comment this out.
      LEX_INFO("lexer: enumerating characters in the multiline comment: %c\n",c);
      if (c == '\n') yylineno++;
    }

    if ((c1 = input()) != '/' && c != 0)
    {
      unput(c1);
      goto loop;
    }

    // if (c != 0)
    //   putchar(c1); // same here.
  /*} */
  
}