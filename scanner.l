
/*****************************************************************************
 * 
 * Usepackage Environment Manager
 * Copyright (C) 1995-2015  Jonathan Hogg  <me@jonathanhogg.com>
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
 * Name   : scanner.l
 * Author : Jonathan Hogg <me@jonathanhogg.com>
 * 
 ****************************************************************************/

%{
/* scanner.l */

#include <string.h>
#include "package.h"
#include "grammar.h"
#include "utils.h"

char litbuf[2048];
static char *bufp;

extern int stack_pointer;
extern int line_number[];
extern char file_name[][256];

extern linked_list* make_pathlist(char* path_string);
int include(char* filename);
int uninclude();
YY_BUFFER_STATE file[INCLUDE_STACK_DEPTH];

%}

%option noyywrap

%x lit scpt

name	[-A-Za-z0-9_\.]*
path	(\.|\~|\/|\$)[^ \t\n:,;]*

%%


"#".*		/* ignore */
":"		return(COLON);
";"		return(SEMICOLON);
","		return(COMMA);
"{"		return(LEFTPAREN);
"}"		return(RIGHTPAREN);
"*"		return(WILDCARD);
"="		return(EQUALS);
"+="		return(PLUSEQUALS);
"=+"		return(EQUALSPLUS);
"?="		return(QEQUALS);
"?+="		return(QPLUSEQUALS);
":="		return(ASSIGN);
"<="		return(WITH);
">>"		return(BEGIN_ANNOTATE);
"<<"		return(END_ANNOTATE);

"alias"		return(ALIAS);

"\""		bufp=litbuf; bufp[0] = '\0'; BEGIN(lit);
<lit>[^\"\n]*	strcpy(bufp, yytext); bufp += yyleng;
<lit>\n		{ strcpy(bufp, yytext); bufp += yyleng;
		  line_number[stack_pointer]++; }
<lit>"\""	BEGIN(INITIAL); return(LITERAL);

"<["		bufp=litbuf; bufp[0] = '\0'; BEGIN(scpt);
<scpt>[^\]\n]*	strcpy(bufp, yytext); bufp += yyleng;
<scpt>\n	{ strcpy(bufp, yytext); bufp += yyleng;
		  line_number[stack_pointer]++; }
<scpt>"]>"	BEGIN(INITIAL); return(SCRIPT);

{path}		strcpy(litbuf, yytext); return(PATH);
{name}		strcpy(litbuf, yytext); return(NAME);
{name}\*	{ strcpy(litbuf, yytext); litbuf[yyleng-1] = '\0';
		  return(PREFIX); }
[ \t]+		/* ignore */
\n		line_number[stack_pointer]++;

"(include "[^\)]+")"	yytext[yyleng-1] = '\0'; include(yytext+9);

.		fprintf(stderr, "usepackage: ignoring character `%s' on line %d of %s\n", yytext, line_number[stack_pointer], file_name[stack_pointer]);

<<EOF>>         if (uninclude()) yyterminate();

%%

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
   {
      the_file = fopen(the_file_name, "r");
   }
   else
   {
      for (node = head(include_path) ; !the_file && node ; node = next(node))
      {
         dir = (char*) get_value(node);
         sprintf(the_file_name, "%s/%s", expand(dir), filename);
         the_file = fopen(the_file_name, "r");
      }
   }

   if (!the_file)
   {
      DEBUG(stderr, "cannot open file `%s'\n", the_file_name);
      return(1);
   }

   if (stack_pointer == INCLUDE_STACK_DEPTH - 1)
   {
      DEBUG(stderr, "maximum include depth reached\n");
      return(1);
   }

   DEBUG(stderr, "reading from `%s'...\n", the_file_name);
   stack_pointer++;
   strcpy(file_name[stack_pointer], the_file_name);
   line_number[stack_pointer] = 1;
   yy_switch_to_buffer(file[stack_pointer] = yy_create_buffer(the_file, YY_BUF_SIZE));

   return(0);
}

int uninclude()
{
   DEBUG(stderr, "closing file %s\n", file_name[stack_pointer]);
   fclose(yyin);
   yy_delete_buffer(file[stack_pointer--]);

   if (stack_pointer != -1)
   {
      yy_switch_to_buffer(file[stack_pointer]);
      return(0);
   }

   return(1);
}

