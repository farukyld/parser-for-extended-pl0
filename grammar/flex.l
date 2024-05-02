%{
#include PARSER_HEADER
void multiline_comment();
// below line works.
// \/\/.*$                                     { printf("consumnig single line comment: %s\n", yytext); }
%}

%%

\/\*                                        { /*unfortunetely, flex, and lex do not support lazy matching pattern.
                                              https://stackoverflow.com/questions/4166194/how-do-i-write-a-non-greedy-match-in-lex-flex
                                              https://www.lysator.liu.se/c/ANSI-C-grammar-l.html */ multiline_comment(); } 
const                                       { printf("lexer: returning token CONST\n"); return CONST; } /* reserved multicharacter tokens */
var                                         { return VAR; }
procedure                                   { return PROCEDURE; }
:=                                          { return ASSIGN; }
call                                        { return CALL; }
begin                                       { return BGN; }
end                                         { printf("lexer: returning token end at line %d\n",yylineno);return END; }
if                                          { return IF; }
else                                        { return ELSE; }
then                                        { return THEN; }
while                                       { return WHILE; }
do                                          { return DO; }
odd                                         { return ODD; }
\<\>                                        { return NE; }
\<=                                         { return LTE; }
\>=                                         { return GTE; }



([0-9]+|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?) { printf("lexer: returning token number: %f\n", atof(yytext)); return NUMBER; } /* from lecture slides */ /* pattern matching tokens */

[A-Za-z_][A-Za-z_0-9]*                      { printf("lexer: returning token identifier: %s\n", yytext); return IDENTIFIER; } /* from lecture slides */

[ \t]                                     ; /* consume those */
\n                                          { yylineno++; }
.                                           { printf("lexer: returning identically: %s\n", yytext); return *yytext; } /* return other single characters directly */ /* special */

%%

void yyerror(char*s){
printf("%s\n",s);
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
      printf("lexer: enumerating characters in the multiline comment: %c\n",c);
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