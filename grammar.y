%{

/* grammar.y */

#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include "linked_list.h"
#include "packages.h"
#include "utils.h"


extern char litbuf[1024];
extern char *yytext;
extern FILE *yyin;
extern char* main_package_filename;


linked_list* loaded_packages;
linked_list* loaded_groups;
int yyerrors;

int stack_pointer;
int line_number[10];
char file_name[10][256];
FILE* file[10];

int include(char* filename);

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
         entries entry ;

entry: package
       { add_to_tail(loaded_packages, (void*) $1); } |
       group
       { add_to_tail(loaded_groups, (void*) $1); } ;

package: matchlist matchlist matchlist matchlist matchlist COLON
         variables SEMICOLON 
         { $$ = new(package_t);
           $$->name = $1; $$->arch = $2; $$->os = $3; $$->version = $4;
           $$->host = $5; $$->variables = $7; } ;

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
	{ $$ = strdup(expand(litbuf)); } ;

prefix: PREFIX
	{ $$ = strdup(litbuf); } ;

name: NAME
	{ $$ = strdup(litbuf); } ;

literal: LITERAL
	{ $$ = strdup(litbuf); } ;

%%

yyerror()
{
   if (stack_pointer < 0)
      fprintf(stderr, "usepackage: parse error, unexpected end of input (possibly missing semicolon?)\n");
   else
   {
      fprintf(stderr, "usepackage: parse error on line %d of %s, input '%s'\n",
	      line_number[stack_pointer], file_name[stack_pointer],
	      yytext);
   }
   yyerrors++;
}

int get_packages(linked_list** packages, linked_list** groups)
{
#ifdef YYDEBUG
   yydebug = debugging;
#endif

   yyerrors = 0;

   stack_pointer = -1;
   if (include(main_package_filename))
      return(1);

   yyparse();

   if (yyerrors)
      return(2);

   *packages = loaded_packages;
   *groups = loaded_groups;
   return(0);
}

int yywrap()
{
   close(file[stack_pointer--]);

   if (stack_pointer != -1)
   {
      yyin = file[stack_pointer];
      return(0);
   }

   return(1);
}

int include(char* filename)
{
   stack_pointer++;
   line_number[stack_pointer] = 1;

   strcpy(file_name[stack_pointer], expand(filename));

   if (!(file[stack_pointer] = fopen(file_name[stack_pointer], "r")))
   {
      DEBUG("# cannot open file `%s'\n", file_name[stack_pointer]);
      stack_pointer--;
      return(1);
   }

   DEBUG("# reading from `%s'...\n", file_name[stack_pointer]);
   yyin = file[stack_pointer];
   return(0);
}


