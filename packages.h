
/* packages.h */


#include "linked_list.h"


#define VAR_SET 0
#define VAR_ADD 1


typedef struct {
   char* name;
   char* arch;
   char* os;
   char* release;
   char* host;
   linked_list* variables;
} package_t;

typedef struct {
   char* name;
   int type;
   char* value;
} variable_t;


extern linked_list* get_packages();

