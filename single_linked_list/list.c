#include "list.h"
#include <stdlib.h>
#include <string.h>


// Desc : Initializing a linked list
// Param : head - head pointer of linked list
// Return : None
void init_list(Node **head)
{
  *head = (Node*)malloc(sizeof(Node));
  (*head)->data = 0;
  (*head)->next = NULL;
}

// Desc : Making a new node contaning the employee
// Param : ep - menu to be contained
// Return : Node dynamically allocated
Node* new_node(Employee* ep)
{
  Node *tp;

  tp=(Node *)malloc(sizeof(Node));
  tp->data = ep;
  tp->next=NULL;

  return tp;
}

// Desc : Inserting node to list
// Param : head - head pointer of linked list, tp - node to be inserted
// Return : None
void insert_node(Node* head, Node *tp)
{

  // TODO: Write code here
  Node* current;
  current = head;

  if (head->data == NULL){
    memcpy(head, tp, sizeof(Node));
    free(tp);
    return;
  }
  while(current->next != NULL){
    current = current->next;
  }

  if(tp != NULL){
    current->next = tp;
  }
}

// Desc : Sorting the list
// Param : head - head pointer of linked list, tp - node to be sorted
// Return : None
void sort_list(Node *head)
{


  // TODO: Write code here
  Node* current = head;
  Node* smallest = head;
  Node* start = head;
  Node* temp = NULL;
  //find smallest

  while(start != NULL){
    while(current != NULL){
        if ( strcmp( smallest->data->emp_no, current->data->emp_no) < 0){
            smallest = current;
        }
		Node temp;
        strcpy(temp.data->emp_no, start->data->emp_no);
        strcpy(temp.data->name, start->data->name);
        temp.data->salary = start->data->salary;

        strcpy(start->data->emp_no, smallest->data->emp_no);
        strcpy(start->data->name, smallest->data->name);
        start->data->salary = smallest->data->salary;

        strcpy(smallest->data->emp_no, temp.data->emp_no);
        strcpy(smallest->data->name, temp.data->name);
        smallest->data->salary = temp.data->salary;
        current = current->next;
    }
    start = start->next;
  }

}

// Desc : Removing a node from list
// Param : head - head pointer of linked list, tp - node to be removed
// Return : None
void remove_node(Node* head, Node *tp)
{


  // TODO: Write code here
  Node* current;
  current = head;
  while(current != NULL){
      if ( current->next == tp){
        current->next = tp->next;
        free(tp);
        return;
      }
    current = current->next;
  }

}

// Desc : Finding the node in position of the index
// Param : head - head pointer of linked list, new_emp_no - employee number to find
// Return : Node contains new_emp_no, NULL if not found
Node *find_node(Node *head, char *new_emp_no)
{
  // TODO: Write code here
  Node* current = head;

  while(current != NULL && current->data != NULL){
    if (strcmp(current->data->emp_no, new_emp_no)==0)
        return current;
    current = current->next;
  }
  return NULL;
}

// Desc : Deallocate all the momory of list
// Param : head - head pointer of linked list
// Return : None
void deallocate_list(Node *head)
{


  // TODO: Write code here
  Node* current = head;
  Node* target = NULL;
  while(current!= NULL){
    target = current;
    current = current->next;
    free(target);
  }

}

