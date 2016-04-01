#include <stdio.h>

#include "list.h"

int display_menu();
void add_package();
void delete_package();
void search_package_with_delivery_id();
void search_package_with_weight();
void search_package_with_payment_method();
void update_package();

MyNode *head;   // This points the first node of linked list.

int main() {

	int menu_num;

	while(1) {
		menu_num = display_menu();
		switch(menu_num) {
			case 1:
					add_package();
					break;
			case 2:
					delete_package();
					break;
			case 3:
					search_package_with_delivery_id();
					break;
			case 4:
					search_package_with_weight();
					break;
			case 5:
					search_package_with_payment_method();
					break;
			case 6:
					printAllNodes(head);
					break;
			case 7:
					deleteAllNodes(&head);
					exit(0);
			default:
                    printf("Wrong menu number\n");
					break;

		}
	}
	return 0;
}

int display_menu() {
	int num;

	printf("\n======= Delivery Service =======\n");
	printf("1. Add a package\n");
	printf("2. Delete a package\n");
	printf("3. Search a package with deliver id\n");
	printf("4. Search packages with weight\n");
	printf("5. Search packages with payment method\n");
	printf("6. Print All packages\n");
	printf("7. Exit\n");
	printf("================================\n");

	printf("\n>> Select: ");
	scanf("%d", &num);
    printf("\n");

	return num;
}

void add_package() {

	unsigned int data = 0;
	int delivery_id;
	int count;
	int weight;
	int payment_method;
	int charge;

    // Input information of package and add it to linked list.
	//
	// |	1bit	|    10bit		|		4bit	|		6bit		|	1bit	|	10bit	|
	// |			|  delivery id	| # of packages | weight of packages|	method	|	charge	|

	printf(">> Delivery id(1~1023) : ");
	scanf("%d", &delivery_id);
	printf(">> Number of packages(1~15) : ");
	scanf("%d", &count);
	printf(">> Weight of packages(1~63kg) : ");
	scanf("%d", &weight);
	printf(">> Payment method(prepament: 0, deferred payment: 1) : ");
	scanf("%d",&payment_method);
	printf(">> Charge(1~1023) : ");
	scanf("%d", &charge);

	// TODO: input the information to unsinged int data and
	//       insert it to linked list by calling insertNode() function.

    data |= (delivery_id << 21);
    data |= (count << 17);
    data |= (weight << 11);
    data |= (payment_method << 10);
    data |= charge;

    insertNode(&head, data);
}

void delete_package() {
	int delivery_id;

	printf(">> delivery id : ");
	scanf("%d", &delivery_id);

	deleteNode(&head, delivery_id);

}

void search_package_with_delivery_id() {

	int delivery_id;
	MyNode *node;

	printf(">> delivery id : ");
	scanf("%d", &delivery_id);

	node = searchNode(head, delivery_id);

	if (node != NULL) {
		printPackage(node);
	} else {
		printf("The delivery id does not exist.\n\n");
	}

}

void search_package_with_weight() {
	int min_weight;
	int max_weight;

	printf(">> minimum weight : ");
	scanf("%d", &min_weight);
	printf(">> maximum weight : ");
	scanf("%d", &max_weight);

	searchNodeByWeight(head, min_weight, max_weight);

}

void search_package_with_payment_method() {
	int payment_method;

	printf(">> patment method(prepament: 0, deferred payment: 1) : ");
	scanf("%d", &payment_method);

	searchNodeByPayment(head, payment_method);

}


