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
   match_t* match;
}

%token COLON SEMICOLON COMMA EQUALS PLUSEQUALS LITERAL NAME PATH
%token LEFTPAREN RIGHTPAREN PREFIX WILDCARD

%type <package> package
%type <list> variables pathlist matchlist matches
%type <string> name literal path prefix
%type <variable> variable
%type <match> match

%%

packages: /* nothing */
          { packages = new_list(); } |
          packages package
          { add_to_tail(packages, (void*) $2); } ;

package: matchlist matchlist matchlist matchlist COLON variables SEMICOLON 
         { $$ = new(package_t);
           $$->name = $1; $$->arch = $2; $$->os = $3;
           $$->host = $4; $$->variables = $6; } ;

variables: variable
           { $$ = new_list(); add_to_tail($$, (void*) $1); } |
           variables COMMA variable
           { add_to_tail($$ = $1, (void*) $3); } ;

variable: name EQUALS literal
          { $$ = new(variable_t);
            $$->name = $1; $$->type = VAR_LIT_SET;
            $$->literal = $3; $$->pathlist = NULL; } |
          name EQUALS pathlist
          { $$ = new(variable_t);
            $$->name = $1; $$->type = VAR_PATH_SET;
            $$->literal = NULL; $$->pathlist = $3; } |
	  name PLUSEQUALS pathlist
          { $$ = new(variable_t); 
            $$->name = $1; $$->type = VAR_PATH_ADD;
            $$->literal = NULL; $$->pathlist = $3; } ;

matchlist: match
       { $$ = new_list(); add_to_tail($$, (void*) $1); } |
       LEFTPAREN matches RIGHTPAREN
       { $$ = $2; } ;

matches: match
       { $$ = new_list(); add_to_tail($$, (void*) $1); } |
       matches COMMA match
       { add_to_tail($$ = $1, (void*) $3); } ;

match: name
       { $$ = new(match_t); $$->type = MATCH_EXACT; $$->text = $1; } |
       prefix
       { $$ = new(match_t); $$->type = MATCH_PREFIX; $$->text = $1; } |
       WILDCARD
       { $$ = new(match_t); $$->type = MATCH_WILD; $$->text = NULL; } ;

pathlist: path
          { $$ = new_list(); add_to_tail($$, (void*) $1); } |
          pathlist COLON path
          { add_to_tail($$ = $1, (void*) $3); } ;

path: PATH
	{ $$ = strdup(litbuf); } ;

prefix: PREFIX
	{ $$ = strdup(litbuf); } ;

name: NAME
	{ $$ = strdup(litbuf); } ;

literal: LITERAL
	{ $$ = strdup(litbuf); } ;

%%

yyerror()
{
   printf("\nParse error on line %d, '%s'\n", line_number, yytext);
   yyerrors++;
}

linked_list* get_packages()
{
#ifdef YYDEBUG
   yydebug = 1;
#endif
   yyerrors = 0;
   yyin = fopen("packages", "r");
   yyparse();
   fclose(yyin);

   if (yyerrors)
      return(NULL);

   return(packages);
}


