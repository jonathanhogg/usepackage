
/* usepackage.c */

/*** uses: ***/

#include <stdio.h>
#include <stdlib.h>
#include <pwd.h>
#include <string.h>
#include <sys/utsname.h>
#include "linked_list.h"
#include "packages.h"


/*** macros: ***/

#define DEBUG if (debugging) printf


/*** prototypes: ***/

int is_csh_user(void);


/*** globals: ***/

int debugging = 0;
int csh_user;
struct utsname hostinfo;
linked_list* the_packages;


/*** main program: ***/

void main(int argc, char *argv[])
{
   int i;
   char *f;

   for (i=1; i<argc && *argv[i] == '-'; i++)
   {
      for (f=argv[i]+1; *f; f++)
	 switch (*f)
	 {
	    case 'v':
	       debugging = 1;
	       break;
	    default:
	       fprintf(stderr, "%s: unrecognised flag '%c'\n", argv[0], f);
	       exit(1);
	 }
   }

   if (i == argc)
   {
      fprintf(stderr, "usage: %s [-v] <package> [<package>...]\n", argv[0]);
      exit(1);
   }

   uname(&hostinfo);
   DEBUG("# host: %s\n", hostinfo.nodename);
   DEBUG("# operating system: %s\n", hostinfo.sysname);
   DEBUG("# release: %s\n", hostinfo.release);
   DEBUG("# architecture: %s\n", hostinfo.machine);

   csh_user = is_csh_user();

   the_packages = get_packages();
   if (!the_packages)
   {
      fprintf(stderr, "%s: couldn't load package information.\n", argv[0]);
      exit(2);
   }

   for (; i<argc; i++)
   {
      DEBUG("# using package %s...\n", argv[i]);
   }
}


/*** functions: ***/

int is_csh_user(void)
{
   struct passwd *pwent;
   char *shell;

   pwent = getpwuid(getuid());
   shell = strrchr(pwent->pw_shell, '/');
   if (!shell) return(0);
   shell++;

   DEBUG("# shell: %s\n", shell);

   return ((!strcmp(shell, "csh")) || (!strcmp(shell, "tcsh")));
}

