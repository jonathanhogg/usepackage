
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


list_node *
new_node()
{
   list_node *node;

   node = (list_node*) malloc(sizeof(list_node));
   return(node);
} /* new_node */


linked_list *
new_list()
{
   linked_list	*list;

   list = (linked_list*) malloc(sizeof(linked_list));
   list->head = NULL;
   list->tail = NULL;
   return(list);
} /* new_list */


void
add_to_head(l, s)
linked_list	*l;
void	*s;
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
} /* add_to_head */


void
add_to_tail(l, s)
linked_list	*l;
void	*s;
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
} /* add_to_tail */


void
remove_node(l, n)
linked_list	*l;
list_node	*n;
{
   if (n->previous)
      n->previous->next = n->next;
   else
      l->head = n->next;
   if (n->next)
      n->next->previous = n->previous;
   else
      l->tail = n->previous;
   free(n->value);
   free(n);
} /* remove_node */


list_node *
head(l)
linked_list	*l;
{
   return(l->head);
} /* head */


list_node *
tail(l)
linked_list	*l;
{
   return(l->tail);
} /* tail */


list_node *
next(n)
list_node	*n;
{
   return(n->next);
} /* next */


list_node *
previous(n)
list_node	*n;
{
   return(n->previous);
} /* previous */


void *
value(n)
list_node	*n;
{
   return(n->value);
} /* value */


