
/*****************************************************************************
 * 
 * Copyright 1995-2002 Jonathan Hogg
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
 * Name   : usepackage.c
 * Author : Jonathan Hogg <jonathan@onegoodidea.com>
 * 
 ****************************************************************************/


/* usepackage.c */

/* Jonathan AH Hogg */


/*** uses: ***/

#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>
#include <dirent.h>
#include "linked_list.h"
#include "package.h"
#include "utils.h"


/*** prototypes: ***/

void add_package(package_t* package);
void use_package(char* name);
void use_group(group_t* group);
group_t* get_group(char* name);
void print_env(void);
list_node* get_into_env(variable_t* var);
linked_list* make_pathlist(char* path_string);
variable_t* update_var(variable_t* evar, variable_t* vvar);
void print_path(char* varname, linked_list* pathlist);
linked_list* merge_paths(linked_list* elist, linked_list* vlist);
void list_annotations();
void list_groups();


/*** globals: ***/

int debugging = 0;
int silent = 0;
int csh_user;
struct utsname the_host_info;
linked_list* the_packages;
linked_list* the_groups;
linked_list* the_annotations;
linked_list* the_environment;
char* main_package_filename = MASTER_PACKAGE_FILE;


/*** main program: ***/

int main(int argc, char *argv[])
{
   int first,i;
   char* f;
   group_t* group;
   int sh_override = -1;
   int list_packages = 0;

   for (i=1; i<argc && *argv[i] == '-'; i++)
   {
      for (f=argv[i]+1; *f; f++)
	 switch (*f)
	 {
	    case 'v':
	       debugging = 1;
	       silent = 0;
	       break;
	    case 's':
	       debugging = 0;
	       silent = 1;
	       break;
	    case 'c':
	       sh_override = 1;
	       break;
	    case 'b':
	       sh_override = 0;
	       break;
	    case 'f':
	       main_package_filename = argv[++i];
	       break;
	    case 'l':
	       list_packages = 1;
	       break;
	    default:
	       fprintf(stderr, "usepackage: unrecognised flag '%c'\n", *f);
               exit(1);
	 }
   }

   if (!list_packages && (i >= argc))
   {
      fprintf(stderr, "%s %s, %s\n", PACKAGE_NAME, PACKAGE_VERSION, COPYRIGHT);
      fprintf(stderr, "Bug reports and comments to: %s\n\n", PACKAGE_BUGREPORT);
      fprintf(stderr, "usage: use [-vscb] [-f <file>] <package> [<package>...]\n");
      fprintf(stderr, "       use -l\n\n");
      fprintf(stderr, "       -v : verbose\n");
      fprintf(stderr, "       -s : silence match warnings\n");
      fprintf(stderr, "       -c : force csh style output\n");
      fprintf(stderr, "       -b : force sh style output\n");
      fprintf(stderr, "       -f : use <file> as main packages file\n");
      fprintf(stderr, "       -l : list available packages\n");
      exit(1);
   }

   DEBUG(stderr, "%s\n", PACKAGE_NAME);
   DEBUG(stderr, "Version: %s\n", PACKAGE_VERSION);
   DEBUG(stderr, "%s\n", COPYRIGHT);

   uname(&the_host_info);
   DEBUG(stderr, "host: %s\n", the_host_info.nodename);
   DEBUG(stderr, "operating system: %s %s\n", the_host_info.sysname,
         the_host_info.release);
   DEBUG(stderr, "architecture: %s\n", the_host_info.machine);

   csh_user = is_csh_user();
   if (sh_override != -1) csh_user = sh_override;

   the_environment = new_list();
   if (get_packages(&the_packages, &the_groups, &the_annotations))
   {
      fprintf(stderr, "usepackage: couldn't load package information.\n");
      exit(2);
   }

   if (list_packages)
   {
      fprintf(stderr, "usepackage %s, %s\n\n", VERSION, COPYRIGHT);
      fprintf(stderr, "Available packages are:\n\n");
      list_annotations();
      fprintf(stderr, "\nAvailable groups are:\n\n");
      list_groups();
      exit(0);
   }

   for (first = i, i = argc - 1 ; i >= first ; i--)
   {
      if (group = get_group(argv[i]))
         use_group(group);
      else
         use_package(argv[i]);
   }

   print_env();

   return(0);
}


/*** functions: ***/

void use_package(char* name)
{
   package_t* package;
   list_node* node;
   int got_one = 0;

   DEBUG(stderr, "using package `%s'...\n", name);
      
   for (node = head(the_packages) ; node ; node = next(node))
   {
      package = (package_t*) get_value(node);

      if (package_matches(package, name, the_host_info.machine,
			  the_host_info.sysname, the_host_info.release,
                          the_host_info.nodename))
      {
	 add_package(package);
         got_one = 1;
      }
   }

   if ((!silent) && (!got_one))
      fprintf(stderr,
	      "warning: no match for package `%s' on this host.\n",
	      name);
}

void add_package(package_t* package)
{
   variable_t* evar;
   variable_t* vvar;
   list_node* enode;
   list_node* vnode;
   list_node* rnode;
   group_t* group;
   char* name;
   int got_one;
   
   if (package->requires)
   {
      DEBUG(stderr, "(pre-using required packages list)\n");

      for (rnode=list_tail(package->requires) ; rnode ; rnode=previous(rnode))
      {
         name = (char*) get_value(rnode);

	 if (group = get_group(name))
	    use_group(group);
	 else
	    use_package(name);
      }
   }

   for (vnode = head(package->variables) ; vnode ; vnode = next(vnode))
   {
      vvar = get_value(vnode);
      got_one = 0;
      for (enode = head(the_environment) ; enode ; enode = next(enode))
      {
         evar = get_value(enode);
         if (!strcmp(vvar->name, evar->name))
         {
            set_value(enode, update_var(evar, vvar));
            got_one = 1;
            break;
         }
      }
      if (!got_one)
      {
         enode = get_into_env(vvar);
         evar = get_value(enode);
	 set_value(enode, update_var(evar, vvar));
      }
   }
}

void use_group(group_t* group)
{
   list_node* node;

   DEBUG(stderr, "(expanding group `%s')\n", group->name);

   for (node = list_tail(group->packages) ; node ; node = previous(node))
      use_package((char*) get_value(node));
}

group_t* get_group(char* name)
{
   list_node* node;
   group_t* group;

   for (node = head(the_groups) ; node ; node = next(node))
   {
      group = (group_t*) get_value(node);
      if (!strcasecmp(name, group->name))
         return(group);
   }

   return(NULL);
}

void print_env(void)
{
   list_node* node;
   variable_t* var;

   DEBUG(stderr, "dumping environment...\n");

   for (node = head(the_environment) ; node ; node = next(node))
   {
      var = (variable_t*) get_value(node);
      if (csh_user)
         printf("setenv %s ", var->name);
      else
         printf("%s=", var->name);

      switch (var->type)
      {
         case VAR_LIT_SET:
            printf("\"%s\"", var->literal);
            break;

         case VAR_PATH_ADD:
         case VAR_PATH_SET:
            print_path(var->name, var->pathlist);
            break;

         default:
            break;
      }

      if (!csh_user)
         printf(" ;\nexport %s ;\n", var->name);
      else
         printf(" ;\n");
   }
}

void print_path(char* varname, linked_list* pathlist)
{
   list_node* node;
   char* dirname;
   DIR* dir;

   /* special case for the empty path: */
   node = head(pathlist);
   dirname = get_value(node);
   if ((strlen(dirname) == 0) && !next(node))
   {
      printf("\"\"");
      return;
   }

   for (node = head(pathlist) ; node ; node = next(node))
   {
      dirname = get_value(node);
      printf(next(node) ? "%s:" : "%s", dirname);
/*
      dir = opendir(dirname);
      if (!dir && !silent)
         fprintf(stderr,
                 "warning: unavailable directory `%s' in variable `%s'.\n",
                 dirname, varname);
      dir && closedir(dir);
*/
   }
}

list_node* get_into_env(variable_t* var)
{
   variable_t* env_var;

   env_var = new(variable_t);
   env_var->name = var->name;
   env_var->type = var->type;

   switch(var->type)
   {
      case VAR_LIT_SET:
         env_var->literal = NULL;
         break;

      case VAR_PATH_SET:
         env_var->pathlist = NULL;
         break;

      case VAR_PATH_ADD:
         env_var->pathlist = make_pathlist(getenv(var->name));
         break;

      default:
         break;
   }

   add_to_tail(the_environment, env_var);
   return(list_tail(the_environment));
}

linked_list* make_pathlist(char* path_string)
{
   linked_list* list;
   int start,i,end;
   char* path;

   list = new_list();

   if (!path_string)
      return(list);

   start = 0;
   i = 0;
   end = strlen(path_string);

   /* if (!end)
      return(list); */

   while (i <= end)
   {
      if ((path_string[i] == ':') || (path_string[i] == '\0'))
      {
	 path = (char*) malloc((i - start) + 1);
	 strncpy(path, path_string + start, i - start);
	 path[i - start] = '\0';
	 add_to_tail(list, path);
	 start = i + 1;
      }

      i++;
   }

   return(list);
}

variable_t* update_var(variable_t* evar, variable_t* vvar)
{
   switch (vvar->type)
   {
      case VAR_LIT_SET:
         evar->literal = vvar->literal;
         evar->type = VAR_LIT_SET;
         break;

      case VAR_PATH_SET:
         evar->pathlist = vvar->pathlist;
         evar->type = VAR_PATH_SET;
         break;

      case VAR_PATH_ADD:
         switch (evar->type)
         {
            case VAR_LIT_SET:
	       evar->pathlist = merge_paths(make_pathlist(evar->literal),
                                            vvar->pathlist);
               break;

            case VAR_PATH_SET:
            case VAR_PATH_ADD:
	       evar->pathlist = merge_paths(evar->pathlist, vvar->pathlist);
	       break;

	    default:
	       break;
         }
         evar->type = VAR_PATH_ADD;
         break;

      default:
         break;
   }

   return(evar);
}

linked_list* merge_paths(linked_list* elist, linked_list* vlist)
{
   list_node* enode;
   list_node* vnode;
   char* vpath;

   for (vnode = list_tail(vlist) ; vnode ; vnode = previous(vnode))
   {
      vpath = (char*) get_value(vnode);

      for (enode = head(elist) ; enode ; enode = next(enode))
         if (!strcmp(vpath, (char*) get_value(enode)))
         {
            remove_node(elist, enode, 0);
            break;
         }

      add_to_head(elist, get_value(vnode));
   }

   return(elist);
}

void list_annotations()
{
   list_node* node;
   annotation_t* annotation;
 
   for (node = head(the_annotations); node; node = next(node))
   {
      annotation = (annotation_t*) get_value(node);
 
      fprintf(stderr, "   %s - %s\n", annotation->name,
              annotation->description);
   }
}
 
void list_groups()
{
   list_node* gnode;
   list_node* pnode;
   group_t* group;

   for (gnode = head(the_groups) ; gnode ; gnode = next(gnode))
   {
      group = (group_t*) get_value(gnode);

      fprintf(stderr, "  %s - ", group->name);

      for (pnode = head(group->packages) ; pnode ; pnode = next(pnode))
      {
         fprintf(stderr, "%s", (char*) get_value(pnode));
         if (next(pnode))
            fprintf(stderr, ", ");
      }

      fprintf(stderr, "\n");
   }
} 

