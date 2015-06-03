
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
 * Name   : linked_list.c
 * Author : Jonathan Hogg <me@jonathanhogg.com>
 * 
 ****************************************************************************/


/* linked_list.c */

/* polymorphic linked-list ADT */

/* Jonathan AH Hogg */

/*
 * Assumes that the values are pointers to some 'alloc'ed data structures,
 * as 'remove_node' will attempt to 'free' the value pointer.
 */


#include <stdio.h>
#include <stdlib.h>
#include "linked_list.h"


list_node* new_node(void)
{
   list_node *node;

   node = (list_node*) malloc(sizeof(list_node));
   return(node);
} /* new_node */


linked_list* new_list(void)
{
   linked_list	*list;

   list = (linked_list*) malloc(sizeof(linked_list));
   list->head = NULL;
   list->tail = NULL;
   return(list);
} /* new_list */


list_node* add_to_head(linked_list* l, void* s)
{
   list_node *node;

   node = new_node();
   node->value = s;
   node->next = l->head;
   node->previous = NULL;
   if (l->head)
      l->head->previous = node;
   if (!l->tail)
      l->tail = node;
   l->head = node;
   return(node);
} /* add_to_head */


list_node* add_to_tail(linked_list* l, void* s)
{
   list_node *node;

   node = new_node();
   node->value = s;
   node->next = NULL;
   node->previous = l->tail;
   if (l->tail)
      l->tail->next = node;
   if (!l->head)
      l->head = node;
   l->tail = node;
   return(node);
} /* add_to_tail */


void remove_node(linked_list* l, list_node* n, int k)
{
   if (n->previous)
      n->previous->next = n->next;
   else
      l->head = n->next;
   if (n->next)
      n->next->previous = n->previous;
   else
      l->tail = n->previous;
   if (k) free(n->value);
   free(n);
} /* remove_node */


void free_list(linked_list* l, int k)
{
   list_node *node;
   list_node *next_node;

   node = l->head;
   while (node)
   {
      if (k) free(node->value);
      next_node = node->next;
      free(node);
      node = next_node;
   }
   free(l);
} /* free_list */


list_node* head(linked_list* l)
{
   return(l->head);
} /* head */


list_node* list_tail(linked_list* l)
{
   return(l->tail);
} /* list_tail */

list_node* next(list_node* n)
{
   return(n->next);
} /* next */


list_node* previous(list_node* n)
{
   return(n->previous);
} /* previous */


void* get_value(list_node* n)
{
   return(n->value);
} /* value */


void set_value(list_node* n, void* s)
{
   n->value = s;
} /* value */

