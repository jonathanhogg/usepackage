
/*****************************************************************************
 * 
 * Usepackage Environment Manager
 * Copyright (C) 1995-2004  Jonathan Hogg  <jonathan@onegoodidea.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, 
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software 
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * Name   : grammar.y
 * Author : Jonathan Hogg <jonathan@onegoodidea.com>
 * 
 ****************************************************************************/

%{

/* grammar.y */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include "linked_list.h"
#include "package.h"
#include "utils.h"


extern char litbuf[1024];
int yydebug;
extern char *yytext;
extern FILE *yyin;
extern char* main_package_filename;
extern linked_list* make_pathlist(char* path_string);


linked_list* loaded_packages;
linked_list* loaded_groups;
linked_list* loaded_annotations;
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
   annotation_t* annotation;
   script_t* script;
}

%token COLON SEMICOLON COMMA EQUALS PLUSEQUALS QEQUALS QPLUSEQUALS LITERAL NAME PATH
%token LEFTPAREN RIGHTPAREN PREFIX WILDCARD ASSIGN WITH
%token BEGIN_ANNOTATE END_ANNOTATE SCRIPT

%type <package> package settings
%type <list> pathlist matchlist matches names requires
%type <string> name literal path prefix
%type <variable> variable
%type <match> match
%type <group> group
%type <annotation> annotation
%type <script> script

%%

entries: /* nothing */
         { loaded_packages = new_list();
           loaded_groups = new_list();
           loaded_annotations = new_list(); } |
         entries entry ;

entry: package
       { add_to_tail(loaded_packages, (void*) $1); } |
       group
       { add_to_tail(loaded_groups, (void*) $1); } |
       annotation
       { add_to_tail(loaded_annotations, (void*) $1); } ;

package: matchlist requires COLON
         settings SEMICOLON 
         { $$ = $4;
           $$->name = $1; $$->arch = NULL; $$->os = NULL; $$->version = NULL;
           $$->host = NULL; $$->shell = NULL; $$->requires = $2; } |
         matchlist matchlist requires COLON
         settings SEMICOLON 
         { $$ = $5;
           $$->name = $1; $$->arch = $2; $$->os = NULL; $$->version = NULL;
           $$->host = NULL; $$->shell = NULL; $$->requires = $3; } |
         matchlist matchlist matchlist requires COLON
         settings SEMICOLON 
         { $$ = $6;
           $$->name = $1; $$->arch = $2; $$->os = $3; $$->version = NULL;
           $$->host = NULL; $$->shell = NULL; $$->requires = $4; } |
         matchlist matchlist matchlist matchlist requires COLON
         settings SEMICOLON 
         { $$ = $7;
           $$->name = $1; $$->arch = $2; $$->os = $3; $$->version = $4;
           $$->host = NULL; $$->shell = NULL; $$->requires = $5; } |
         matchlist matchlist matchlist matchlist matchlist requires COLON
         settings SEMICOLON 
         { $$ = $8;
           $$->name = $1; $$->arch = $2; $$->os = $3; $$->version = $4;
           $$->host = $5; $$->shell = NULL; $$->requires = $6; } |
         matchlist matchlist matchlist matchlist matchlist matchlist requires COLON
         settings SEMICOLON 
         { $$ = $9;
           $$->name = $1; $$->arch = $2; $$->os = $3; $$->version = $4;
           $$->host = $5; $$->shell = $6; $$->requires = $7; } ;

requires: /* nothing */
          { $$ = NULL; } |
          WITH names
          { $$ = $2; } ;

group: name ASSIGN names SEMICOLON
       { $$ = new(group_t); $$->name = $1; $$->packages = $3;} ;


annotation: BEGIN_ANNOTATE name COLON literal END_ANNOTATE
            { $$ = new(annotation_t);
              $$->name = $2;
              $$->description = $4; } ;

settings: variable
          { $$ = new(package_t);
            $$->variables = new_list();
            $$->scripts = new_list();
            add_to_tail($$->variables, (void*) $1); } |
          script
          { $$ = new(package_t);
            $$->variables = new_list();
            $$->scripts = new_list();
            add_to_tail($$->scripts, (void*) $1); } |
          settings COMMA variable
          { $$ = $1;
            add_to_tail($$->variables, (void*) $3); } |
          settings COMMA script
          { $$ = $1;
            add_to_tail($$->scripts, (void*) $3); } ;

variable: name EQUALS literal
          { $$ = new(variable_t);
            $$->name = $1; $$->type = VAR_LIT_SET;
            $$->literal = $3; $$->pathlist = NULL; } |
          name EQUALS pathlist
          { $$ = new(variable_t);
            $$->name = $1; $$->type = VAR_PATH_SET;
            $$->literal = NULL; $$->pathlist = $3; } |
	  name PLUSEQUALS literal
          { $$ = new(variable_t); 
            $$->name = $1; $$->type = VAR_PATH_ADD;
            $$->literal = NULL; $$->pathlist = make_pathlist($3); } |
	  name PLUSEQUALS pathlist
          { $$ = new(variable_t); 
            $$->name = $1; $$->type = VAR_PATH_ADD;
            $$->literal = NULL; $$->pathlist = $3; } |
	  name QEQUALS pathlist
          { $$ = new(variable_t); 
            $$->name = $1; $$->type = VAR_PATH_TESTSET;
            $$->literal = NULL; $$->pathlist = $3; } |
	  name QPLUSEQUALS literal
          { $$ = new(variable_t); 
            $$->name = $1; $$->type = VAR_PATH_TESTADD;
            $$->literal = NULL; $$->pathlist = make_pathlist($3); } |
	  name QPLUSEQUALS pathlist
          { $$ = new(variable_t); 
            $$->name = $1; $$->type = VAR_PATH_TESTADD;
            $$->literal = NULL; $$->pathlist = $3; } ;

script: SCRIPT
	{ $$ = new(script_t);
	  $$->text = strdup(litbuf); } ;

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

int get_packages(linked_list** packages, linked_list** groups,
                 linked_list** annotations)
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
   *annotations = loaded_annotations;
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
   static linked_list* include_path = NULL;
   list_node* node;
   char* dir;
   char the_file_name[256];
   FILE* the_file = NULL;
   char* path;

   if (!include_path)
   {
      path = getenv(PACKAGE_PATH_VAR);
      if (!path)
         path = DEFAULT_PACKAGE_PATH;

      include_path = make_pathlist(path);
   }

   strcpy(the_file_name, expand(filename));
   if (the_file_name[0] == '/')
      the_file = fopen(the_file_name, "r");

   for (node = head(include_path) ; !the_file && node ; node = next(node))
   {
      dir = (char*) get_value(node);
      sprintf(the_file_name, "%s/%s", expand(dir), filename);
      the_file = fopen(the_file_name, "r");
   }

   if (!the_file)
   {
      DEBUG(stderr, "cannot open file `%s'\n", filename);
      return(1);
   }

   DEBUG(stderr, "reading from `%s'...\n", the_file_name);
   stack_pointer++;
   strcpy(file_name[stack_pointer], the_file_name);
   line_number[stack_pointer] = 1;
   yyin = file[stack_pointer] = the_file;

   return(0);
}

