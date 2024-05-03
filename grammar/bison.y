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
%token FUNCTION // function
%token RETURN // return
%token ASSIGN // :=
%token BREAK // break
%token WRITELINE // writeline
%token WRITE // write
%token READ // read
%token CALL // call
%token BGN // begin
%token END // end
%token IF // if
%token THEN // then
%token ELSE // then
%token WHILE // while
%token DO // do
%token ODD // odd
%token NE // <>
%token LTE // <=
%token GTE // >=


%%
program: block  '.' {
      printf("completed parsing program\n");
      exit(0);
    }
  ;

block: const_decl var_decl func_decl proc_decl statement
  ;

const_decl:             CONST const_assignment_list ';'     { printf("completed parsing nonempty const_decl\n"); }
  |                                                         { printf("parsing empty const_decl\n"); }
  ;

const_assignment_list:  const_assignment                            { printf("completed parsing const_assignment_list with single const_assignment"); }
  |                     const_assignment_list ',' const_assignment  { printf("completed parsing const_assignment_list with multiple const_assignments\n"); }
  ;

const_assignment:       IDENTIFIER '=' NUMBER
  ;

var_decl:               VAR identifier_or_array_list ';'    { printf("completed nonempty var decl.");}
  |                                                         { printf("completed empty var decl.");}
  ;

identifier_or_array_list:
  |                     identifier_or_array_list ',' IDENTIFIER
  |                     identifier_or_array_list ',' array_access
  |                     IDENTIFIER
  |                     array_access
  ;

identifier_list:        IDENTIFIER
  |                     identifier_list ',' IDENTIFIER
  ;

proc_decl:              proc_decl PROCEDURE IDENTIFIER ';' block ';'
  |
  ;

func_decl:              func_decl FUNCTION IDENTIFIER '(' identifier_list ')' block ';'
  |
  ;

// to modify the existing structure of this statement to adapt to
// include if then else statement, use the grammar in Figure 4.10
// in the book. (Compilers, principles and techniques, tools 2nd ed. by alfred v. aho, monica s. lam, ravi sethi, jeffrey d. ullman)
// the rule without if then else structure:
/* statement:              IDENTIFIER ASSIGN expression
  |                     CALL IDENTIFIER
  |                     BGN statement_list END
  |                     IF condition THEN statement
  |                     WHILE condition DO statement
  |
  ; */

statement:              matched_statement             { printf("parsed statement using matched statement\n"); }
  |                     open_statement                { printf("parsed statement using open statement\n"); }
  ;

matched_statement:      IF condition THEN matched_statement ELSE matched_statement { printf("parsed matched_statement using if cond then matched else matched\n"); }
  |                     IDENTIFIER ASSIGN expression                               { printf("parsed matched_statement using assignment\n"); }
  |                     array_access ASSIGN expression                             { printf("parsed matched_statement using array assignment\n"); }
  |                     CALL IDENTIFIER                                            { printf("parsed matched_statement using call statement\n"); }
  |                     BGN statement_list END                                     { printf("parsed matched_statement using block statement\n"); }
  |                     RETURN expression                                          { printf("parsed matched_statement using return statement\n"); }
  |                     BREAK                                                      { printf("parsed matched_statement using break statement\n"); }
  |                     io_statement                                               { printf("parsed matched_statement using io statement\n"); }
  |                                                                                { printf("parsed matched_statement using empty prod. rule\n"); }
  ;

// there was a shift/reduce conflict when the WHILE condition DO statement was one of the matched_statements productions.
// I intentionally make it one of the production rules of open_statement, because it lookes similar to the form of the open statement.
open_statement:         IF condition THEN statement                                { printf("parsed open_statement using if cond then statement\n"); }
  |                     IF condition THEN matched_statement ELSE open_statement    { printf("parsed open_statement using if cond then matched else open\n"); }
  |                     WHILE condition DO statement                               { printf("parsed open_statement using while cond do statement\n"); }
  ;

statement_list:         statement                     { printf("parsed statement list using single statement\n"); }
  |                     statement_list ';' statement  { printf("parsed statement list combining a statement to the statement_list\n"); }
  ;

io_statement:           READ '(' IDENTIFIER ')'
  |                     WRITE '(' IDENTIFIER ')'
  |                     WRITELINE '(' IDENTIFIER ')'

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

// I think pl0 language (ı guess from the overall structure) do not have expressions evaluating to pointers. so, the base of an array access is always an identifier.
array_access:           IDENTIFIER '[' expression ']'
  |                     array_access '[' expression ']'
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
  |                     '%'
  ;

factor:                 IDENTIFIER
  |                     NUMBER
  |                     array_access
  |                     '(' expression ')'
  ;
