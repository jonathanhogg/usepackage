%{
/* scanner.l */

#include <string.h>
#include "packages.h"
#include "grammar.h"

char litbuf[1024];
static char *bufp;

extern int stack_pointer;
extern int line_number[10];
extern char file_name[10][256];
extern FILE* file[10];

extern int include(char* filename);

%}

%x val lit

name	[-a-z0-9_\.]*
path	(\.|\~|\.?\/[^ \t\n:,;]*|\~[^ \t\n:,;]+)


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


