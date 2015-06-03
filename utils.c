
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
 * Name   : utils.c
 * Author : Jonathan Hogg <me@jonathanhogg.com>
 * 
 ****************************************************************************/


/* utils.c */

/* Jonathan AH Hogg */


/*** uses: ***/

#include <pwd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include "utils.h"


/*** functions: ***/

char* get_user_shell(void)
{
   struct passwd *pwent;
   char *shell = getenv("SHELL");

   if (!shell)
   {
      pwent = getpwuid(getuid());
      shell = pwent->pw_shell;
   }
   shell = strrchr(shell, '/');
   if (!shell)
      return("sh");
   shell++;

   return strdup(shell);
}


char* expand(char* filepath)
{
   static char newpath[256];
   static char username[32];
   struct passwd* pwent;
   char* home;
   int i,j;

   i = 0;
   newpath[0] = '\0';

   if (filepath[i] == '~')
   {
      i++;

      if (!filepath[i] || filepath[i] == '/')
      {
      	 home = getenv("HOME");
      	 if (home)
      	 {
     	    strcat(newpath, home);
      	 }
      	 else
      	 {
	    pwent = getpwuid(getuid());

	    if (!pwent)
	    {
	       fprintf(stderr, "usepackage: cannot obtain home directory.\n");
	       return(filepath);
	    }
	    
	    strcat(newpath, pwent->pw_dir);
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

         strcat(newpath, pwent->pw_dir);
      }
   }

   strcat(newpath, filepath + i);

   return(newpath);
}

