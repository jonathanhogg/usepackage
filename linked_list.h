
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
extern void add_to_head(linked_list* l, void* s);
extern void add_to_tail(linked_list* l, void* s);
extern void remove_node(linked_list* l, list_node* n);
extern list_node* next(list_node* n);
extern list_node* previous(list_node* n);
extern list_node* head(linked_list* l);
extern list_node* tail(linked_list* l);
extern void* value(list_node* n);

#endif

