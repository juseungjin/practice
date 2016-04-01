#ifndef __LIST_H__
#define __LIST_H__

#include <stdio.h>
#include <stdlib.h>

struct Node {
	unsigned int data;  // package data
	struct Node *next;
};

typedef struct Node MyNode;

void insertNode(MyNode **head, unsigned int data);
void deleteNode(MyNode **head, int delivery_id);
void deleteAllNodes(MyNode **head);
MyNode *searchNode(MyNode *head, int delivery_id);
void searchNodeByWeight(MyNode *head, int minWeight, int maxWeight);
void searchNodeByPayment(MyNode *head, int payment_method);
void printPackage(MyNode *node);
void printAllNodes(MyNode *head);

#endif
