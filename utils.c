
/* utils.c */

/* Jonathan AH Hogg */


/*** uses: ***/

#include <pwd.h>
#include <string.h>
#include <stdio.h>
#include "utils.h"


/*** functions: ***/

int is_csh_user(void)
{
   struct passwd *pwent;
   char *shell;

   pwent = getpwuid(getuid());
   shell = strrchr(pwent->pw_shell, '/');
   if (!shell) return(0);
   shell++;

   return ((!strcmp(shell, "csh")) || (!strcmp(shell, "tcsh")));
}


char* expand(char* filepath)
{
   static char newpath[256];
   static char username[32];
   struct passwd* pwent;
   int i,j;

   i = 0;
   newpath[0] = '\0';

   if (filepath[i] == '~')
   {
      i++;

      if (filepath[i] == '/')
      {
	 pwent = getpwuid(getuid());

	 if (!pwent)
	 {
	    fprintf(stderr, "usepackage: cannot obtain home directory.\n");
	    return(filepath);
	 }
      }
      else
      {
         j = i;
         while (filepath[i] && (filepath[i] != '/')) i++;
         strncpy(username, filepath + j, i - j);
	 pwent = getpwnam(username);

	 if (!pwent)
	 {
	    fprintf(stderr,
                    "usepackage: cannot obtain home directory of user `%s'.\n",
                    username);
	    return(filepath);
	 }
      }

      strcat(newpath, pwent->pw_dir);
   }

   strcat(newpath, filepath + i);

   return(newpath);
}

