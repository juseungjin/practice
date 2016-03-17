#ifndef __LIST_H__
#define __LIST_H__

// Employee structure
typedef struct {
  char emp_no[7];
  char* name;
  int salary;
} Employee;

// Node for linked list 
typedef struct node {
  Employee *data;     
  struct node *next;  
} Node;

Node *find_node(Node *head, char *new_emp_no);
void remove_node(Node* head, Node *tp);
Node* new_node(Employee* ep);
void insert_node(Node* head, Node *tp);

void init_list(Node **head);
void sort_list(Node *head);
void deallocate_list(Node *head);

#endif
