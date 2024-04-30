%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(char * s);
/* the declarations and includes made here are put into parser.c, not parser.h */
%}

%token CONST // 'const'
%token IDENTIFIER
%token NUMBER
%token VAR  // var
%token PROCEDURE // procedure
%token ASSIGN // :=
%token CALL // call
%token BGN // begin
%token END // end
%token IF // if
%token THEN // then
%token WHILE // while
%token DO // do
%token ODD // odd
%token NE // <>
%token LTE // <=
%token GTE // >=


%%
program:
    {
      printf("started parsing program\n");
    } block {
      printf("in between block and dot\n");
    } '.' {
      printf("completed parsing program\n");
      exit(0);
    }
  ;

block:
    {
      printf("started parsing block\n");
    }
    const_decl {
      printf("in between const_decl and var_decl\n");
      /* I put those debugging printf calls in between with the help of copilot */
    } var_decl {
      printf("in between var_decl and proc_decl\n");
    }
    proc_decl {
      printf("in between proc_decl and statement\n");
    }
    statement {
      printf("completed parsing block\n");
    }
  ;

const_decl:
  {
    printf("started parsing nonempty const_decl\n");
  } CONST {
    printf("in between token CONST and const_assignment_list\n");
  } const_assignment_list {
    printf(" in between const_assignment_list and ;\n");
  }';' {
    printf("completed parsing nonempty const_decl\n");
  }
  | {
    printf("parsing empty const_decl\n");
  }
  ;

const_assignment_list:
  {
    printf("started parsing const_assignment_list with single single asignment\n");
  } 
  /*burayi yorum yapip asagidaki kuraldakini yorumdan cikarinca direkt oradan baslamaya calisiyor, ve sonsuz donguye giriyor.*/
  const_assignment
  {
    printf("completed parsing const_assignment_list with single single asignment\n");
  }
  | 
  /* {
    printf("started parsing const_assignment_list with multiple const_assignments\n");
  }   */
  /*buraya bir sey koyamiyoruz cunku koydugumuz zaman, const_assignment_list'e cokludan mi tekliden mi girebilecegini bilemedigi icin hata veriyor? */
  const_assignment_list 
  {
    printf("in between const_assignment_list and ,\n");
  }
  ','
  {
    printf("in between , and single asignment\n");
  }
  const_assignment
  {
    printf("completed parsing const_assignment_list with multiple const_assignments\n");
  }
  ;

const_assignment:
  {
    printf("started parsing const_assignment\n");
  } 
  IDENTIFIER 
  {
    printf("in between IDENTIFIER and =\n");
  } 
  '=' 
  {
    printf("in between = and NUMBER\n");
  } 
  NUMBER 
  {
    printf("completed parsing const_assignment\n");
  }
  ;

var_decl:               VAR identifier_list ';'
  |
  ;

identifier_list:        IDENTIFIER
  |                     identifier_list ',' IDENTIFIER
  ;

proc_decl:              proc_decl PROCEDURE IDENTIFIER ';' block ';'
  |
  ;

statement:              IDENTIFIER ASSIGN expression
  |                     CALL IDENTIFIER
  |                     BGN statement_list END
  |                     IF condition THEN statement
  |                     WHILE condition DO statement
  |
  ;

statement_list:         statement
  |                     statement_list ';' statement
  ;

condition:              ODD expression
  |                     expression relation expression
  ;

relation:               '='
  |                     NE
  |                     '<'
  |                     '>'
  |                     LTE
  |                     GTE
  ;

expression:             term
  |                     add_sub_operator term
  |                     expression add_sub_operator term
  ;

add_sub_operator:       '+'
  |                     '-'
  ;

term:                   factor
  |                     term mul_div_operator factor
  ;

mul_div_operator:       '*'
  |                     '/'
  ;

factor:                 IDENTIFIER
  |                     NUMBER
  |                     '(' expression ')'
  ;
