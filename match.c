
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
 * Name   : match.c
 * Author : Jonathan Hogg <me@jonathanhogg.com>
 * 
 ****************************************************************************/


/* match.c */

/*** uses: ***/

#include "linked_list.h"
#include "package.h"
#include <string.h>


/*** prototypes: ***/

int text_matches(char* text, linked_list* matches);


/*** globals: ***/


/*** functions: ***/

int package_matches(package_t* package, char* name, char* arch,
                    char* os, char* version, char* host, char* shell)
{
   if (!text_matches(name, package->name))
      return(0);
   if (!text_matches(arch, package->arch))
      return(0);
   if (!text_matches(os, package->os))
      return(0);
   if (!text_matches(version, package->version))
      return(0);
   if (!text_matches(host, package->host))
      return(0);
   if (!text_matches(shell, package->shell))
      return(0);
   return(1);
}

int text_matches(char* text, linked_list* matches)
{
   list_node* node;
   match_t* match;

   if ( !matches )
      return(1);

   for (node = head(matches) ; node ; node = next(node))
   {
      match = (match_t*) get_value(node);

      switch (match->type)
      {
	 case MATCH_WILD:
	    return(1);

	 case MATCH_PREFIX:
	    if (!strncasecmp(text, match->text, strlen(match->text)))
               return(1);
	    break;

	 case MATCH_EXACT:
	    if (!strcasecmp(text, match->text))
               return(1);
	    break;
      }
   }
   return(0);
}

