%{
/* scanner.l */

#include "linked_list.h"
#include "packages.h"
#include "grammar.h"

char litbuf[1024];
int line_number = 1;
static char *bufp;

%}

%x val lit

%%

"#".*			/* ignore */
":"			return(COLON);
";"			return(SEMICOLON);
","			return(COMMA);
"{"			return(LEFTPAREN);
"}"			return(RIGHTPAREN);
"*"			return(WILDCARD);
"+="[ \t]*		return(PLUSEQUALS);
"="[ \t]*		return(EQUALS);
"\""			bufp=litbuf; BEGIN(lit);
<lit>[^\"\n]*		strcpy(bufp, yytext); bufp += yyleng;
<lit>\n			line_number++;
<lit>"\""		BEGIN(INITIAL); return(LITERAL);
[\./][^ \t\n:,;]*	strcpy(litbuf, yytext); return(PATH);
[a-zA-Z0-9_\.]+		strcpy(litbuf, yytext); return(NAME);
[a-zA-Z0-9_]+\*		{ strcpy(litbuf, yytext); litbuf[yyleng-1] = '\0';
			  return(PREFIX); }
[ \t]+			/* ignore */
\n			line_number++;
.			fprintf(stderr, "scanner: ignoring weird character `%s'\n", yytext);

%%

