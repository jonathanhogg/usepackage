%{
/* scanner.l */

#include "linked_list.h"
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
"+="[ \t]*		bufp=litbuf; BEGIN(val); return(PLUSEQUALS);
"="[ \t]*		bufp=litbuf; BEGIN(val); return(EQUALS);
<val>"\""		BEGIN(lit);
<val>[^ ,\\\"\t\n]*	strcpy(bufp, yytext); bufp += yyleng;
<val>"\\"[ \t]*\n[ \t]*	line_number++;
<val>[ ,\t]	 	BEGIN(INITIAL); yyless(0); return(VALUE);
<val>\n	 		line_number++; BEGIN(INITIAL); return(VALUE);
<lit>[^\"\n]*		strcpy(bufp, yytext); bufp += yyleng;
<lit>\n			line_number++;
<lit>"\""		BEGIN(val);
[^ \t\n:]+		strcpy(litbuf, yytext); return(NAME);
[ \t]+			/* ignore */
\n			line_number++;

%%

