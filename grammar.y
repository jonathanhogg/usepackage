%{

/* grammar.y */

#include <stdio.h>
#include <string.h>
#include "linked_list.h"
#include "packages.h"

#define new(x) ((x*)malloc(sizeof(x)))

extern char litbuf[1024];
extern char *yytext;
extern int line_number;
extern FILE *yyin;

linked_list* packages;
int yyerrors;

%}

%union { 
   linked_list* list;
   char* string;
   package_t* package;
   variable_t* variable;
}

%token COLON SEMICOLON COMMA EQUALS PLUSEQUALS VALUE NAME PATH

%type <package> package
%type <list> variables
%type <string> name value
%type <variable> variable

%%

packages: /* nothing */
          { packages = new_list(); } |
          packages package
          { add_to_tail(packages, (void*) $2); } ;

package: name name name name name COLON variables SEMICOLON 
         { $$ = new(package_t);
           $$->name = $1; $$->arch = $2; $$->os = $3; $$->release = $4;
           $$->host = $5; $$->variables = $7; } ;

variables: variable
           { $$ = new_list(); add_to_tail($$, (void*) $1); } |
           variables COMMA variable
           { add_to_tail($$ = $1, (void*) $3); } ;

variable: name EQUALS value
          { $$ = new(variable_t);
            $$->name = $1; $$->type = VAR_SET; $$->value = $3; } |
	  name PLUSEQUALS value
          { $$ = new(variable_t); 
            $$->name = $1; $$->type = VAR_ADD; $$->value = $3; } ;

name: NAME
	{ $$ = strdup(litbuf); }

value: VALUE
	{ $$ = strdup(litbuf); }

%%

yyerror()
{
   printf("\nParse error on line %d, '%s'\n", line_number, yytext);
   yyerrors++;
}

linked_list* get_packages()
{
   yyerrors = 0;
   yyin = fopen("packages", "r");
   yyparse();
   fclose(yyin);

   if (yyerrors)
      return(NULL);

   return(packages);
}


