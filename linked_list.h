
/* linked_list.h */


typedef struct list_node_struct {
   void	*value;
   struct list_node_struct	*next;
   struct list_node_struct	*previous;
} list_node;

typedef struct {
   list_node	*head;
   list_node	*tail;
} linked_list;


extern linked_list *new_list();
extern void add_to_head();
extern void add_to_tail();
extern void remove_node();
extern list_node *next();
extern list_node *previous();
extern list_node *head();
extern list_node *tail();
extern void *value();

