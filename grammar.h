/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     COLON = 258,
     SEMICOLON = 259,
     COMMA = 260,
     EQUALS = 261,
     PLUSEQUALS = 262,
     EQUALSPLUS = 263,
     QEQUALS = 264,
     QPLUSEQUALS = 265,
     LITERAL = 266,
     NAME = 267,
     PATH = 268,
     LEFTPAREN = 269,
     RIGHTPAREN = 270,
     PREFIX = 271,
     WILDCARD = 272,
     ASSIGN = 273,
     WITH = 274,
     BEGIN_ANNOTATE = 275,
     END_ANNOTATE = 276,
     SCRIPT = 277,
     ALIAS = 278
   };
#endif
/* Tokens.  */
#define COLON 258
#define SEMICOLON 259
#define COMMA 260
#define EQUALS 261
#define PLUSEQUALS 262
#define EQUALSPLUS 263
#define QEQUALS 264
#define QPLUSEQUALS 265
#define LITERAL 266
#define NAME 267
#define PATH 268
#define LEFTPAREN 269
#define RIGHTPAREN 270
#define PREFIX 271
#define WILDCARD 272
#define ASSIGN 273
#define WITH 274
#define BEGIN_ANNOTATE 275
#define END_ANNOTATE 276
#define SCRIPT 277
#define ALIAS 278




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 63 "grammar.y"
{ 
   linked_list* list;
   char* string;
   package_t* package;
   variable_t* variable;
   match_t* match;
   group_t* group;
   annotation_t* annotation;
   script_t* script;
   alias_t* alias;
}
/* Line 1529 of yacc.c.  */
#line 107 "grammar.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

