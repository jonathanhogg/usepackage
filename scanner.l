%{
/* scanner.l */

#include <string.h>
#include "linked_list.h"
#include "packages.h"
#include "grammar.h"

char litbuf[1024];
int line_number;
static char *bufp;

%}

%x val lit

name	[-a-z0-9_\.]*
path	(\.|\.?\/[^ \t\n:,;]*)

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
<lit>\n		line_number++;
<lit>"\""	BEGIN(INITIAL); return(LITERAL);
{path}		strcpy(litbuf, yytext); return(PATH);
{name}		strcpy(litbuf, yytext); return(NAME);
{name}\*	{ strcpy(litbuf, yytext); litbuf[yyleng-1] = '\0';
		  return(PREFIX); }
[ \t]+		/* ignore */
\n		line_number++;
.		fprintf(stderr, "usepackage: ignoring character `%s'\n", yytext);

%%

