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
%token BEGIN // begin
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
program: block '.'
  ;

block:                  const_decl var_decl proc_decl statement
  ;

const_decl:             CONST const_assignment_list ';'
  |
  ;

const_assignment_list:  const_assignment
  |                     const_assignment_list ',' const_assignment
  ;

const_assignment:       IDENTIFIER '=' NUMBER;

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
  |                     BEGIN statement_list END
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
