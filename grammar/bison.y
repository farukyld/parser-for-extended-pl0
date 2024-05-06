%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(char * s);
extern int yylineno;
#define ERROR_MISSING(in_what, missing)                                             \
    do {                                                                           \
      yyerrok;                                                                     \
      printf("error in " in_what ", missing " missing ". at line: %d\n", yylineno);\
    } while(0)

#define ERROR_IN(in_what)                                         \
    do {                                                       \
      yyerrok;                                                 \
      printf("error in " in_what ". at line: %d\n", yylineno); \
    } while(0)

#define GIVE_PARSE_INFO 0

#if GIVE_PARSE_INFO
#define PARSE_INFO(...) \
printf(__VA_ARGS__);
#else
#define PARSE_INFO(...) \
;
#endif
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
%token ELSE // ELSE
%token WHILE // while
%token FOR // while
%token DO // do
%token ODD // odd
%token NE // <>
%token LTE // <=
%token GTE // >=


%%
program: block  '.' {
      PARSE_INFO("completed parsing program\n");
      exit(0);
    }
  ;

block: const_decl var_decl func_decl proc_decl statement
  ;

// I got help from that video to understand the way of the error recovery: https://www.youtube.com/watch?v=eF9qWbuQLuw
const_decl:             CONST const_assignment_list ';'     { PARSE_INFO("completed parsing nonempty const_decl\n"); }
  |                                                         { PARSE_INFO("parsing empty const_decl\n"); }
  |                     CONST const_assignment_list error   { ERROR_MISSING("const declaration", "semicolon"); } // gives shift reduce conflict with comma seperated const assignmentts error handling
  ;

const_assignment_list:  const_assignment                              { PARSE_INFO("completed parsing const_assignment_list with single const_assignment\n"); }
  |                     const_assignment_list ',' const_assignment    { PARSE_INFO("completed parsing const_assignment_list with multiple const_assignments\n"); }
  /* |                     const_assignment_list error const_assignment  { ERROR_MISSING("const assignment list","comma"); } */ // gives shift reduce conflict with missing semicolon error handling in const declaration
  ;

const_assignment:       IDENTIFIER '=' NUMBER
  |                     error '=' NUMBER                              { ERROR_MISSING("const assignment", "identifier"); }
  |                     IDENTIFIER '=' error                          { ERROR_MISSING("const assignment", "rhs of the assignment"); }
  ;

var_decl:               VAR identifier_or_array_list ';'    { PARSE_INFO("completed nonempty var decl.\n");}
  |                     error identifier_or_array_list ';'  { ERROR_MISSING("variable declaration","keyword \"var\""); }
  |                     VAR identifier_or_array_list error  { ERROR_MISSING("variable declaration","semicolon"); } // gives shift reduce conflict with comma separated identifier/array list
  |                                                         { PARSE_INFO("completed empty var decl.\n");}
  ;

identifier_or_array_list:
  |                     identifier_or_array_list ',' IDENTIFIER
  /* |                     identifier_or_array_list error IDENTIFIER {ERROR_MISSING("identifier/array list","comma");} */  // gives shift reduce conflict with missing semicolon handling in variable declaration
  |                     identifier_or_array_list ',' array_access
  /* |                     identifier_or_array_list error array_access {ERROR_MISSING("identifier/array list","comma");} */ // gives shift reduce conflict with missing semicolon handling in variable declaration
  |                     IDENTIFIER
  |                     array_access
  ;

formal_argument_list:   IDENTIFIER
  |                     formal_argument_list ',' IDENTIFIER
  |                     formal_argument_list error IDENTIFIER {ERROR_MISSING("formal argument list","comma");}
  ;

proc_decl:              proc_decl PROCEDURE IDENTIFIER ';' block ';'
  /* |                     proc_decl error IDENTIFIER ';' block ';' {ERROR_MISSING("procedure declaration","keyword procedure");} */ // gives shift reduce conflict with var declaration: error identifier_list ';'.
  |                     proc_decl PROCEDURE error ';' block ';' {ERROR_MISSING("procedure declaration","procedure identifier");}
  |                     proc_decl PROCEDURE IDENTIFIER error block ';' {ERROR_MISSING("procedure declaration","semicolon after procedure identifier");}
  | { PARSE_INFO("parsed empty proc_decl\n"); }
  ;

func_decl:              func_decl FUNCTION IDENTIFIER '(' formal_argument_list ')' block ';'
  |                     func_decl FUNCTION error '(' formal_argument_list ')' block ';'           {ERROR_MISSING("function declaration","function identifier");}
  |                     func_decl FUNCTION IDENTIFIER error formal_argument_list ')' block ';'    {ERROR_MISSING("function declaration","open parantheses after function identifier");}
  |                     func_decl FUNCTION IDENTIFIER '(' error ')' block ';'                     {ERROR_IN("function declaration. check formal argument list");}
  /* |                     func_decl FUNCTION IDENTIFIER '(' formal_argument_list error block ';'    {ERROR_MISSING("function declaration", "close parantheses after formal argument list");} */ // gives shift reduce conflict with formal_argument_list's error production rule
  /* |                     func_decl FUNCTION IDENTIFIER '(' formal_argument_list ')' block ';' */
  | { PARSE_INFO("parsed empty func_decl\n"); }
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

statement:              matched_statement             { PARSE_INFO("parsed statement using matched statement\n"); }
  |                     open_statement                { PARSE_INFO("parsed statement using open statement\n"); }
  ;

matched_statement:      IF condition THEN matched_statement ELSE matched_statement  { PARSE_INFO("parsed matched_statement using if cond then matched else matched\n"); }
  |                     IF condition error matched_statement ELSE matched_statement { ERROR_MISSING("if statement", "keyword then"); }
  |                     IF error THEN matched_statement ELSE matched_statement      { ERROR_IN("if statement condition"); }
  |                     IDENTIFIER ASSIGN expression                                { PARSE_INFO("parsed matched_statement using assignment\n"); }
  |                     IDENTIFIER error expression                                 { ERROR_MISSING("assignment statement", "\":=\""); }
  |                     array_access ASSIGN expression                              { PARSE_INFO("parsed matched_statement using array assignment\n"); }
  |                     array_access error expression                               { ERROR_MISSING("assignment statement", "\":=\""); }
  |                     CALL IDENTIFIER                                             { PARSE_INFO("parsed matched_statement using call statement\n"); }
  |                     CALL error                                                  { ERROR_IN("call statement. check identifier"); }
  |                     BGN statement_list END                                      { PARSE_INFO("parsed matched_statement using block statement\n"); }
  |                     BGN statement_list error                                    { ERROR_MISSING("compound statement","keyword end"); }
  |                     RETURN expression                                           { PARSE_INFO("parsed matched_statement using return statement\n"); }
  |                     RETURN                                                      { PARSE_INFO("parsed matched_statement using return statement\n"); }
  |                     BREAK                                                       { PARSE_INFO("parsed matched_statement using break statement\n"); }
  |                     io_statement                                                { PARSE_INFO("parsed matched_statement using io statement\n"); }
  |                                                                                 { PARSE_INFO("parsed matched_statement using empty prod. rule\n"); }
  ;

// there was a shift/reduce conflict when the WHILE condition DO statement was one of the matched_statements productions.
// I intentionally make it one of the production rules of open_statement, because it lookes similar to the form of the open statement.
open_statement:         IF condition THEN statement                                { PARSE_INFO("parsed open_statement using if cond then statement\n"); }
  |                     IF condition error statement                               { ERROR_MISSING("if statement","keyword then"); }
  |                     IF error THEN statement                                    { ERROR_IN("if statement condition"); }
  |                     IF condition THEN matched_statement ELSE open_statement    { PARSE_INFO("parsed open_statement using if cond then matched else open\n"); }
  |                     IF condition error matched_statement ELSE open_statement   { ERROR_MISSING("if statement","keyword then"); }
  |                     IF error THEN matched_statement ELSE open_statement        { ERROR_IN("if statement condition"); }
  |                     WHILE condition DO statement                               { PARSE_INFO("parsed open_statement using while cond do statement\n"); }
  |                     WHILE error DO statement                                   { ERROR_IN("while statement condition"); }
  |                     WHILE condition error statement                            { ERROR_MISSING("while statement","keyword do"); }
  |                     FOR for_loop_header DO statement                           { // similar to the while cond do stmt, for for_header do stmt looks like an open statement
                                                                                      PARSE_INFO("parsed open_statement using for for_loop_header do statement\n"); }
  |                     FOR for_loop_header error statement                        { ERROR_MISSING("for statement","do"); }
  ;

for_loop_header:        '(' for_init_list ';' condition ';' for_step_list ')'
  |                     error for_init_list ';' condition ';' for_step_list ')'      {ERROR_MISSING("for loop header", "open parantheses"); }
  |                     '(' error ';' condition ';' for_step_list ')'                {ERROR_IN("for loop header initialization part"); }
  |                     '(' for_init_list ';' error ';' for_step_list ')'            {ERROR_IN("for loop header condition"); }
  |                     '(' for_init_list ';' condition ';' error ')'                {ERROR_IN("for loop header stepping part"); }
  |                     '(' for_init_list error condition ';' for_step_list ')'      {ERROR_MISSING("for loop header", "semicolon after initialization part"); }
  |                     '(' for_init_list ';' condition error for_step_list ')'      {ERROR_MISSING("for loop header", "semicolon after condition"); }
  |                     '(' for_init_list ';' condition ';' for_step_list error      {ERROR_MISSING("for loop header", "close parantheses"); }
  ;

for_init_list:           IDENTIFIER ASSIGN expression
  |                      for_init_list ','  IDENTIFIER ASSIGN expression
  ;

for_step_list:          IDENTIFIER ASSIGN expression
  |                     for_step_list ',' IDENTIFIER ASSIGN expression
  ;


statement_list:         statement                     { PARSE_INFO("parsed statement list using single statement\n"); }
  |                     statement_list ';' statement  { PARSE_INFO("parsed statement list combining a statement to the statement_list\n"); }
  ;

io_statement:           READ '(' IDENTIFIER ')'
  |                     READ error IDENTIFIER ')'    { ERROR_MISSING("io statement", "open parantheses after read"); }
  |                     READ '(' error ')'           { ERROR_MISSING("io statement", "identifier after open parantheses"); }
  |                     READ '(' IDENTIFIER error    { ERROR_MISSING("io statement", "close parantheses after identifier"); }
  |                     WRITE '(' IDENTIFIER ')'
  |                     WRITE error IDENTIFIER ')'   { ERROR_MISSING("io statement", "open parantheses after write"); }
  |                     WRITE '(' error ')'          { ERROR_MISSING("io statement", "identifier after open parantheses"); }
  |                     WRITE '(' IDENTIFIER error   { ERROR_MISSING("io statement", "close parantheses after identifier"); }
  |                     WRITELINE '(' IDENTIFIER ')'
  |                     WRITELINE error IDENTIFIER ')' { ERROR_MISSING("io statement", "open parantheses after writeline"); }
  |                     WRITELINE '(' error ')'        { ERROR_MISSING("io statement", "identifier after open parantheses"); }
  |                     WRITELINE '(' IDENTIFIER error { ERROR_MISSING("io statement", "close parantheses after identifier"); }
  ;

condition:              ODD expression
  |                     ODD error                      { ERROR_IN("odd condition expression"); }
  |                     expression relation expression
  |                     error relation expression      { ERROR_IN("lhs expression of the condition"); }
  |                     expression error expression    { ERROR_IN("condition operator"); }
  |                     expression relation error      { ERROR_IN("rhs expression of the condition"); }
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
  |                     IDENTIFIER '[' error ']'          { ERROR_IN("array access/creation index ing expression"); }
  |                     IDENTIFIER '[' expression error   { ERROR_MISSING("array acess/creation", "closing square bracet"); }
  |                     array_access '[' expression ']'
  |                     array_access '[' error ']'        { ERROR_IN("array access/creation index ing expression"); }
  |                     array_access '[' expression error { ERROR_MISSING("array acess/creation", "closing square bracet"); }
  ;

expression:             term
  |                     add_sub_operator term
  |                     add_sub_operator error            { ERROR_IN("expression. unexpected token after unary operator."); }
  |                     expression add_sub_operator term  
  /* |                     expression error term             { ERROR_IN("expression. expecting addition or substraction operator."); } */ // gives too much shift reduce conflicts
  |                     expression add_sub_operator error { ERROR_IN("expression. unexpected token after addition or substraction operator."); }
  ;

add_sub_operator:       '+'
  |                     '-'
  ;

term:                   factor
  |                     term mul_div_operator factor          // see printting percent sign: https://stackoverflow.com/questions/17774821/how-do-i-print-the-percent-sign-in-c
  |                     term mul_div_operator error       { ERROR_IN("expression. unexpected token after \"*, /, %%\" operator."); }
  ;

mul_div_operator:       '*'
  |                     '/'
  |                     '%'
  ;

factor:                 IDENTIFIER
  |                     NUMBER
  |                     array_access
  |                     '(' expression ')'
  |                     '(' expression error { ERROR_MISSING("expression", "close parantheses"); }
  ;
