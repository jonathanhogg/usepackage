
/*****************************************************************************
 * 
 * Copyright 1995-2002 Jonathan Hogg
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
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 * Name   : scanner.l
 * Author : Jonathan Hogg <jonathan@onegoodidea.com>
 * 
 ****************************************************************************/

%{
/* scanner.l */

#include <string.h>
#include "package.h"
#include "grammar.h"

char litbuf[1024];
static char *bufp;

extern int stack_pointer;
extern int line_number[10];
extern char file_name[10][256];
extern FILE* file[10];

extern int include(char* filename);

%}

%x lit

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
"+="		return(PLUSEQUALS);
"="		return(EQUALS);
":="		return(ASSIGN);
"<="		return(WITH);
">>"		return(BEGIN_ANNOTATE);
"<<"		return(END_ANNOTATE);
"\""		bufp=litbuf; bufp[0] = '\0'; BEGIN(lit);
<lit>[^\"\n]*	strcpy(bufp, yytext); bufp += yyleng;
<lit>\n		{ strcpy(bufp, yytext); bufp += yyleng;
		  line_number[stack_pointer]++; }
<lit>"\""	BEGIN(INITIAL); return(LITERAL);
{path}		strcpy(litbuf, yytext); return(PATH);
{name}		strcpy(litbuf, yytext); return(NAME);
{name}\*	{ strcpy(litbuf, yytext); litbuf[yyleng-1] = '\0';
		  return(PREFIX); }
[ \t]+		/* ignore */
\n		line_number[stack_pointer]++;

"(include "[^\)]+")"	yytext[yyleng-1] = '\0'; include(yytext+9);

.		fprintf(stderr, "usepackage: ignoring character `%s' on line %d of %s\n", yytext, line_number[stack_pointer], file_name[stack_pointer]);

%%


