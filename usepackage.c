
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
#define new(x) ((x*)malloc(sizeof(x)))


/*** prototypes: ***/

int is_csh_user(void);
void add_package(package_t* package);
int use_package(char* name);
void print_env(void);
list_node* get_into_env(variable_t* var);
linked_list* make_pathlist(char* path_string);
variable_t* update_var(variable_t* evar, variable_t* vvar);
void print_path(linked_list* pathlist);
linked_list* merge_paths(linked_list* elist, linked_list* vlist);


/*** globals: ***/

int debugging = 0;
int csh_user;
struct utsname the_host_info;
linked_list* the_packages;
linked_list* the_environment;
char* the_home;

/*** main program: ***/

void main(int argc, char *argv[])
{
   int first,i;
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

   uname(&the_host_info);
   DEBUG("# host: %s\n", the_host_info.nodename);
   DEBUG("# operating system: %s\n", the_host_info.sysname);
   DEBUG("# architecture: %s\n", the_host_info.machine);

   csh_user = is_csh_user();
   the_environment = new_list();
   the_packages = get_packages();
   if (!the_packages)
   {
      fprintf(stderr, "%s: couldn't load package information.\n", argv[0]);
      exit(2);
   }

   for (first = i, i = argc - 1 ; i >= first ; i--)
   {
      DEBUG("# using package %s...\n", argv[i]);
      
      if (!use_package(argv[i]))
         fprintf(stderr, "%s: no match for package `%s' on this host.\n",
                 argv[0], argv[i]);
   }

   print_env();

   exit(0);
}


/*** functions: ***/

int is_csh_user(void)
{
   struct passwd *pwent;
   char *shell;

   pwent = getpwuid(getuid());
   shell = strrchr(pwent->pw_shell, '/');
   the_home = strdup(pwent->pw_dir);
   if (!shell) return(0);
   shell++;

   DEBUG("# shell: %s\n", shell);

   return ((!strcmp(shell, "csh")) || (!strcmp(shell, "tcsh")));
}

int use_package(char* name)
{
   package_t* package;
   list_node* node;
   int got_one = 0;

   for (node = head(the_packages) ; node ; node = next(node))
   {
      package = (package_t*) get_value(node);

      if (package_matches(package, name, the_host_info.machine,
			  the_host_info.sysname, the_host_info.nodename))
      {
	 add_package(package);
         got_one = 1;
      }
   }

   return(got_one);
}

void add_package(package_t* package)
{
   variable_t* evar;
   variable_t* vvar;
   list_node* enode;
   list_node* vnode;
   int got_one;
   
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

void print_env(void)
{
   list_node* node;
   variable_t* var;

   DEBUG("# dumping environment...\n");

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
            printf("\"%s\"\n", var->literal);
            break;

         case VAR_PATH_ADD:
         case VAR_PATH_SET:
            print_path(var->pathlist);
            break;

         default:
            break;
      }

      if (!csh_user)
         printf("export %s\n", var->name);
   }
}

void print_path(linked_list* pathlist)
{
   list_node* node;

   for (node = head(pathlist) ; node ; node = next(node))
   {
      if (next(node))
	 printf("%s:", (char*) get_value(node));
      else
	 printf("%s\n", (char*) get_value(node));
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

   while (i <= end)
   {
      if ((path_string[i] == ':') || (path_string[i] == '\0'))
      {
         if (i > start)
         {
            path = (char*) malloc((i - start) + 1);
            strncpy(path, path_string + start, i - start);
            path[i - start] = '\0';
         }
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
         break;

      case VAR_PATH_SET:
         evar->pathlist = vvar->pathlist;
         break;

      case VAR_PATH_ADD:
         evar->pathlist = merge_paths(evar->pathlist, vvar->pathlist);
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

