
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
 * Name   : linked_list.h
 * Author : Jonathan Hogg <me@jonathanhogg.com>
 * 
 ****************************************************************************/


/* linked_list.h */

#ifndef _linked_list_h
#define _linked_list_h

typedef struct list_node_struct {
   void	*value;
   struct list_node_struct	*next;
   struct list_node_struct	*previous;
} list_node;

typedef struct {
   list_node	*head;
   list_node	*tail;
} linked_list;


extern linked_list* new_list();
extern list_node* add_to_head(linked_list* l, void* s);
extern list_node* add_to_tail(linked_list* l, void* s);
extern void remove_node(linked_list* l, list_node* n, int k);
extern void free_list(linked_list* l, int k);
extern list_node* next(list_node* n);
extern list_node* previous(list_node* n);
extern list_node* head(linked_list* l);
extern list_node* list_tail(linked_list* l);
extern void* get_value(list_node* n);
extern void set_value(list_node* n, void* s);

#endif

