#include "list.h"

void insertNode(MyNode **head, unsigned int data) {

    // TODO: Insert new node with package data to linked list.

    MyNode *current = *head;
    MyNode *newNode = (MyNode *) malloc(sizeof(MyNode));
    newNode->data = data;
    newNode->next = NULL;

    if (*head == NULL){
        *head = newNode;
        return;
    }

    while(1){
        if(current->next == NULL){
            current->next = newNode;
            break;
        }
        current = current->next;
    }

}

void deleteNode(MyNode **head, int delivery_id) {

    // TODO: Search node which has the same delivery_id as second argument
    // and delete it and print success message.
    // If there is no node with the delivery_id, print error message.

    MyNode *current = *head;
    if (searchNode(*head, delivery_id) == NULL){
        printf("The package does not exist.\n");
    }
    while(current != NULL){

        if( (current->data >> 21) == delivery_id){
            *head = current->next;
            free(current);
            printf("Success\n");
            return;
        }
        if( (current->next->data >> 21) == delivery_id){
            MyNode * target = current->next;
            current->next = current->next->next;
            free(target);
            printf("Success\n");
            return;
        }
        current = current->next;
    }

}

void deleteAllNodes(MyNode **head) {

    // TODO: Delete all nodes in linked list.

    MyNode * current = *head;
    while(current != NULL){
        MyNode * temp = current;
        current = current->next;
        free(temp);
    }
}

MyNode *searchNode(MyNode *head, int delivery_id) {

    // TODO: Search node which has the same delivery_id as second argument
    // and return the node. if there is no node with the delivery_id, return NULL

  MyNode * current = head;

    while(current != NULL){
        if ((current->data >> 21) == delivery_id) {
            return current;
        }
        current = current->next;
    }

	return NULL;
}

void searchNodeByWeight(MyNode *head, int minWeight, int maxWeight) {

    // TODO: Search pagkage data whose weight is between minWeight to maxWeight
    // and print the data by using printPackage() function.
    MyNode *current = head;
    while(current!= NULL){
        int weight = (current->data >> 11) & 0x3F;
        if (weight >= minWeight && weight <= maxWeight ){
            printPackage(current);
        }
        current = current->next;
    }

}

void searchNodeByPayment(MyNode *head, int payment_method) {

    // TODO: Search pagkage data whose payment_method is the same as second argument
    // and print the data by using printPackage() function.
    MyNode *current = head;
    while(current!= NULL){
        int payment = current->data & (0x1 << 10);
        if (payment == payment_method){
            printPackage(current);
        }
        current = current->next;
    }
}

void printPackage(MyNode *node) {

    // TODO: print package information in the node.
	unsigned int data;
    data = node->data;

    printf("------------------------------------\n");
    printf("Deivery id : %d\n", data >> 21);
    printf("Number of package : %d\n", (data >> 17) & 0xF);
    printf("Weight of package : %d\n", (data >> 11) & 0x3F);
    printf("Payment method : %s\n", (data & (0x1 << 10)) ? "deferred prepament" : "prepament");
    printf("Charge : %d\n", (data & 0x3FF));
    printf("------------------------------------\n");

}

void printAllNodes(MyNode *head) {

    // print all registred package information.                                                                             nb                                                             n
	MyNode *temp = head;

	while(temp != NULL) {
		printPackage(temp);
		temp = temp->next;
	}
}
