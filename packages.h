
/* packages.h */


#include "linked_list.h"


#define VAR_LIT_SET 0
#define VAR_PATH_SET 1
#define VAR_PATH_ADD 2

#define MATCH_EXACT 0
#define MATCH_PREFIX 1
#define MATCH_WILD 2


typedef struct {
   linked_list* name;
   linked_list* arch;
   linked_list* os;
   linked_list* host;
   linked_list* variables;
} package_t;

typedef struct {
   int type;
   char* text;
} match_t;

typedef struct {
   char* name;
   int type;
   char* literal;
   linked_list* pathlist;
} variable_t;


extern linked_list* get_packages();
extern int package_matches(package_t* package,
                           char* name, char* arch, char* os, char* host);

