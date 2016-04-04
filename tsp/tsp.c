#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#define MAX_CITY	8
#define INF			90000
#define TRUE		1
#define FALSE		0

// �� ���ð� �Ÿ��� �����ϴ� dist�迭�� ���� �� N
int **dist;
int n;

// Linked List Node ����ü
typedef struct n{
	int num;	
	struct n* next;
	struct n* prev;
}Node;

// Linked List ���� �Լ�
void InitLinkedList(Node* Head, Node* Tail);
Node* CreateNode(int newData);
void PushNode( Node* Tail, Node* newNode);
int ReadPopNode( Node* Tail );
void DelPopNode( Node* Tail );
void Finalize(Node* Head, Node* Tail);
int GetNodeCount(Node* Head, Node* Tail);

// Main ��� �Լ�
void PrintAll();
void InsertData();
void RandomData();
void LoadData();
void SaveData();
int shortestPath(Node* Head, Node* Tail, int* visited, int currentLength);

// TSP ������ ���� �Լ� (���ȣ��)
int shortestPath(Node* Head, Node* Tail, int* visited, int currentLength)
{
	Node* newNode;

	if (GetNodeCount(Head, Tail) == n)
		return currentLength;

	int ret = INF;
 
	for(int next = 0; next < n ; ++next)
	{
		if(visited[next]) continue;
		int here;
  
		if(GetNodeCount(Head, Tail) == 0)
			here = next;  
		else
			here = ReadPopNode(Tail);

		newNode = CreateNode(next);
		PushNode(Tail, newNode);

		visited[next] = TRUE;
		
		int cand = shortestPath(Head, Tail, visited, currentLength + dist[here][next]);
		ret = (ret < cand ? ret : cand);
		visited[next] = FALSE;

		DelPopNode(Tail);
	}
	return ret;
}

// �޴� ���
void printMenu()
{
	printf("\n========================================================================\n");
	printf("                  TSP \n");
	printf("========================================================================\n");
	printf("1. Print ALL\n");

	// ���(�Է�/����) �� ���� ��� �޴� ����
	if(n == 0)
	{
		printf("2. Insert Data\n");
		printf("3. Random Data Generation\n");
		printf("4. Load Data\n");
	}
	else
	{
		printf("5. Save Data\n");
		printf("6. Resolve\n");
		printf("7. Initialization\n");
	}
	
	printf("0. Exit\n");
	printf(">> Select Menu : ");
}

// ������ ���̺� �Է�
void InsertData()
{
	int i, j;
	char temp[128];
	char *pStr;

	do
	{
		printf("How many City : ");
		scanf("%d", &n);
	}while(n > 8);		// �ִ� ���� �� ����ó��

	// 2���� �迭 �����Ҵ�
	dist = (int**)malloc(sizeof(double*) * n);
	for(i = 0 ; i < n ; i++)
		dist[i] = (int*)malloc(sizeof(double) * n);


	for(i = 0 ; i < n ; i++)
	{
		for(j = 0 ; j < n ; j++)
		{
			if(i == j)
				dist[i][j] = 0;
			else if (i > j)
				dist[i][j] = dist[j][i];
			else
			{
				do
				{
				printf("[ %d ][ %d ] : ", i+1, j+1);
				scanf("%d", &dist[i][j]);
				}while(dist[i][j] <= 0 || dist[i][j] >= 1000);	// ���� �� �Ÿ� ����ó��
			}
		}
	}

	printf(":: Success\n");
}

// ���� �Է�
void RandomData()
{
	int i, j;
	char temp[128];
	char *pStr;

	
	do
	{
		printf("How many City : ");
		scanf("%d", &n);
	}while(n > 8);
	dist = (int**)malloc(sizeof(double*) * n);
	for(i = 0 ; i < n ; i++)
		dist[i] = (int*)malloc(sizeof(double) * n);


	// �õ尪 ����
	srand(time(NULL));
	
	for(i = 0 ; i < n ; i++)
	{
		for(j = 0 ; j < n ; j++)
		{
			if(i == j)
				dist[i][j] = 0;
			else if (i > j)
				dist[i][j] = dist[j][i];
			else
				dist[i][j] = rand() % 999 + 1;
		}
	}

	printf(":: Success\n");
}

// ���� ����
void SaveData()
{
	int i, j;
	FILE *fp;

	fp = fopen("question.txt", "w+");
	if(fp == NULL)
	{
		printf(":: File Open Error!\n"); 
		return;
	}

	fprintf(fp, "%d\n", n);

	for(i = 0 ; i < n ; i++)
	{
		for(j = 0 ; j < n ; j++)
		{
			fprintf(fp, "%d", dist[i][j]);
			if(j < n - 1)
				fprintf(fp, "\t");
		}
		fprintf(fp, "\n");
	}

	fclose(fp);
	printf(":: Success\n");

}

// ���� �б�
void LoadData()
{
	int i, j;
	FILE *fp;

	fp = fopen("question.txt", "r+");
	if(fp == NULL)
	{
		printf(":: File Open Error!\n"); 
		return;
	}

	fscanf(fp, "%d", &n);

	dist = (int**)malloc(sizeof(double*) * n);
	for(i = 0 ; i < n ; i++)
		dist[i] = (int*)malloc(sizeof(double) * n);


	for(i = 0 ; i < n ; i++)
	{
		for(j = 0 ; j < n ; j++)
		{
			fscanf(fp, "%d", &dist[i][j]);
		}
	}

	fclose(fp);
	printf(":: Success\n");
}


// ������ ���̺� ���
void PrintAll()
{
	int i, j;

	if (n == 0)
		printf(":: Stack is empty \n");

	printf("      ");
	for(i = 0 ; i < n ; i++)
		printf("[%3d]", i+1);

	printf("\n");
	
	for(i = 0 ; i < n ; i++)
	{
		printf("[%2d]  ", i+1);
		for(j = 0 ; j < n ; j++)
		{
			printf(" %3d ", dist[i][j]);
		}
		printf("\n");
	}
	printf("\n");

}

int main(int argc, char* argv[])
{
	Node pathHead, pathTail;
	int visited[MAX_CITY] = {0,};
	char inputData = 0;
	
	int i;
	InitLinkedList(&pathHead, &pathTail);

	while(inputData != '0')
	{	
		
		fflush(stdin);
		printMenu();
		scanf("%c", &inputData);

		printf("\n");

			switch(inputData)
			{
				case '1':
					PrintAll();
					break;			
				case '2':
					if(n > 0) continue;
					InsertData();
					break;
				case '3':
					if(n > 0) continue;
					RandomData();
					break;
				case '4':
					if(n > 0) continue;
					LoadData();
					break;
				case '5':
					if(n == 0) continue;
					SaveData();
					break;
				case '6':
					if(n == 0) continue;
					printf(":: Result : %d\n", shortestPath(&pathHead, &pathTail, visited, 0));
					break;
				case '7':
					if(n == 0) continue;

					for(i = 0 ; i < n ; i++)
						free(dist[i]);
					free(dist);

					n = 0;
					
					printf(":: Success\n");
					break;
	
				case '0':
					Finalize(&pathHead, &pathTail);

					if( n > 0)
					{
						for(i = 0 ; i < n ; i++)
							free(dist[i]);
						free(dist);
					}

					break;
			}
	}
	
	return 0;
}



// [ Linked-List ] ��� ����
Node* CreateNode(int newData)
{

}

// [ Linked-List ] ��� �߰� 
void PushNode( Node* Tail, Node* newNode)
{

}

// [ Linked-List ] ��� �б�
int ReadPopNode( Node* Tail)
{
	
}

// [ Linked-List ] ��� ����
void DelPopNode( Node* Tail )
{
	
}

// [ Linked-List ] ��� ��ü ����
void Finalize(Node* Head, Node *Tail)
{
	
}

// [ Linked-List ] ��� ī��Ʈ
int GetNodeCount(Node* Head, Node* Tail)
{
	
}

// [ Linked-List ] �ʱ�ȭ �Լ� (head, tail �ʱ�ȭ)
void InitLinkedList(Node* Head, Node* Tail)
{
	
}
