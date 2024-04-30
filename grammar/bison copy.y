%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(char * s);
/* the declarations and includes made here are put into parser.c, not parser.h */
%}

%union {
        double dvala;
        void* symp;
}


%token <symp> NAME
%token <dvala> NUMBER
%token DEL
%token PRINT_SYMTAB
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS


%type <dvala> expression

%%
start_symbol:   statement_list
        ;
// running this statement:
// a_newly_symbol = another_new_symbol ... the_last_new_symbol ...
// assigns the lhs value with the name the_last_new_symbol
statement_list: statement '\n'                  //{printf("parsed first statement\n");}
        |       statement_list statement '\n'   //{printf("parsed another statement\n");}
        //|       statement_list '\n'           //{printf("parsed another statement\n");}
        //|       '\n'                          //{printf("parsed first statement\n");}
        ;

statement:      NAME '=' expression     {  }
        |       expression              {  }
        |       DEL NAME                {  }  // the name apperaing in that rule
                                                                // creates a symbol at global_entry, if not present in the table.
                                                                // we shall also release the lock for the global entry here.
        |       PRINT_SYMTAB            {  }
        |       // allow empty lines.
        ;

expression:     expression '+' expression { $$ = $1 + $3; }
        |       expression '-' expression { $$ = $1 - $3; }
        |       expression '*' expression { $$ = $1 * $3; }
        |       expression '/' expression
                                {       if($3 == 0.0)
                                                yyerror("divide by zero");
                                        else
                                                $$ = $1 / $3;
                                }
        |       '-' expression %prec UMINUS     { $$ = -$2; }
        |       '(' expression ')'      { $$ = $2; }
        |       NUMBER
        |       NAME                    { $$ = $1->value; }
        ;
%%
