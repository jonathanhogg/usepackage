%{

/* grammar.y */

#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include "linked_list.h"
#include "packages.h"


#define new(x) ((x*)malloc(sizeof(x)))
#define DEBUG if (debugging) printf


extern char litbuf[1024];
extern char *yytext;
extern int line_number;
extern FILE *yyin;
extern char* the_home;
extern int debugging;


linked_list* loaded_packages;
linked_list* loaded_groups;
int yyerrors;
int local_file;

%}

%union { 
   linked_list* list;
   char* string;
   package_t* package;
   variable_t* variable;
   match_t* match;
   group_t* group;
}

%token COLON SEMICOLON COMMA EQUALS PLUSEQUALS LITERAL NAME PATH
%token LEFTPAREN RIGHTPAREN PREFIX WILDCARD ASSIGN

%type <package> package
%type <list> variables pathlist matchlist matches names
%type <string> name literal path prefix
%type <variable> variable
%type <match> match
%type <group> group

%%

entries: /* nothing */
         { loaded_packages = new_list(); loaded_groups = new_list(); } |
         entries package
         { add_to_tail(loaded_packages, (void*) $2); } |
         entries group
         { add_to_tail(loaded_groups, (void*) $2); } |

package: matchlist matchlist matchlist matchlist COLON variables SEMICOLON 
         { $$ = new(package_t);
           $$->name = $1; $$->arch = $2; $$->os = $3;
           $$->host = $4; $$->variables = $6; } ;

group: name ASSIGN names SEMICOLON
       { $$ = new(group_t); $$->name = $1; $$->packages = $3;} ;

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

names: name
       { $$ = new_list(); add_to_tail($$, (void*) $1); } |
       names COMMA name
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
   fprintf(stderr, "usepackage: parse error on line %d, '%s'\n", line_number,
           yytext);
   yyerrors++;
}

int get_packages(linked_list** packages, linked_list** groups)
{
#ifdef YYDEBUG
   yydebug = debugging;
#endif

   yyerrors = 0;
   local_file = 0;
   line_number = 1;

   yyin = fopen(MAIN_PACKAGE_FILE, "r");
   if (!yyin)
      return(1);

   yyparse();
   fclose(yyin);

   if (yyerrors)
      return(2);

   *packages = loaded_packages;
   *groups = loaded_groups;
   return(0);
}

int yywrap()
{
   char buf[256];

   if (!local_file)
   {
      sprintf(buf, "%s/%s", the_home, USERS_PACKAGE_FILE);
      yyin = fopen(buf, "r");
      if (!yyin)
         return(1);

      DEBUG("# reading personal packages file\n");
      local_file = 1;
      line_number = 1;
      return(0);
   }
   return(1);
}


