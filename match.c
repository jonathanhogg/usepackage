
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
                    char* os, char* version, char* host)
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
   return(1);
}

int text_matches(char* text, linked_list* matches)
{
   list_node* node;
   match_t* match;

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

