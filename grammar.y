%{

/* grammar.y */

#include "linked_list.h"

#define new(x) ((x*)malloc(sizeof(x)))

extern char litbuf[1024];
extern char *yytext;
extern int line_number;

%}

%union { 
   linked_list* list;
   list_node* node;
}

%token COLON SEMICOLON COMMA EQUALS PLUSEQUALS VALUE NAME PATH

%type <list> packages
%type <node> package

%%

packages: /* nothing */
          { $$ = new_list(); } |
          packages package
          { add_to_tail($$ = $1, (void *)$2); } ;

package: name pattern COLON variables SEMICOLON 
         { printf("done\n"); $$ = NULL; } ;

name: NAME { printf("package %s...", litbuf); } ;

pattern: arch os release host ;

arch: NAME ;

os: NAME ;

release: NAME ;

host: NAME ;

variables: variable |
        variables COMMA variable ;

variable: NAME EQUALS VALUE |
	  NAME PLUSEQUALS VALUE ;

%%

yyerror()
{
   printf("\nParse error on line %d, '%s'\n", line_number, yytext);
   exit(1);
}


