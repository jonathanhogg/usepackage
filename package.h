
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
 * Name   : package.h
 * Author : Jonathan Hogg <jonathan@dcs.gla.ac.uk>
 * 
 ****************************************************************************/


/* packages.h */


/*** uses: ***/

#include <stdio.h>
#include "linked_list.h"


/*** macros: ***/

#ifndef MASTER_PACKAGE_FILE
#define MASTER_PACKAGE_FILE "packages.master"
#endif

#ifndef PACKAGE_PATH_VAR
#define PACKAGE_PATH_VAR "PACKAGES_PATH"
#endif

#ifndef DEFAULT_PACKAGE_PATH
#define DEFAULT_PACKAGE_PATH "/usr/local/lib/usepackage:~:."
#endif

#define VAR_LIT_SET 0
#define VAR_PATH_SET 1
#define VAR_PATH_ADD 2

#define MATCH_EXACT 0
#define MATCH_PREFIX 1
#define MATCH_WILD 2

#define DEBUG if (debugging) fprintf
#define new(x) ((x*)malloc(sizeof(x)))


/*** types: ***/

typedef struct {
   linked_list* name;
   linked_list* arch;
   linked_list* os;
   linked_list* version;
   linked_list* host;
   linked_list* variables;
   linked_list* requires;
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

typedef struct {
   char* name;
   linked_list* packages;
} group_t;

typedef struct {
   char* name;
   char* description;
} annotation_t;


/*** globals: ***/

extern int debugging;


/*** prototypes: ***/

extern int get_packages(linked_list** packages, linked_list** groups,
                        linked_list** annotations);
extern int package_matches(package_t* package, char* name, char* arch,
                           char* os, char* version, char* host);

