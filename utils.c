
/*****************************************************************************
 * 
 * Copyright (C) 2001 Jonathan Hogg
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
 * Name   : utils.c
 * Author : Jonathan Hogg <jonathan@dcs.gla.ac.uk>
 * 
 ****************************************************************************/


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

      if (!filepath[i] || filepath[i] == '/')
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
         username[i-j] = '\0';
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

