/*
 *  * Program of priority queue using linked list
 *   */
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#define TRUE                    1
#define FALSE                   0

#define INSERT_MODE             1
#define SEARCH_MODE             2

#define D_WORK_SUCCESS          1
#define D_WORK_FAIL             (-1) 
#define MAX_VIP_NAME_LENGT      32
#define MAX_VIP_PHONE_LENGT     32

typedef enum{
  D_RETURN_CODE_WRONG_NAME        =   0,
  D_RETURN_CODE_WRONG_PHONE       =   1,
  D_RETURN_CODE_WRONG_PRIORITY    =   2,
  D_RETURN_CODE_WRONG_INPUT       =   3,
  D_RETURN_CODE_SUCCESS           =   4
}D_RETURN_CODE_TYPE;
struct VIP_DATA
{
  int  vPriority;
  char vip_name[MAX_VIP_NAME_LENGT]; 
  char vip_phone[MAX_VIP_PHONE_LENGT];
};
struct QUEUE
{
  struct VIP_DATA vData;
  struct QUEUE     *prev;
  struct QUEUE     *next;
};

typedef struct QUEUE *priorityQueue;
priorityQueue first=NULL;
priorityQueue last=NULL;
char *strInputError[] = {
  "\n...name is wrong...\n\n",
  "\n...phone is wrong...\n\n",
  "\n...priority is wrong...\n\n",
  "\n...input is wrong...\n\n"
};

int  displayPriorityQueue(void);                                             // 큐의 모든 Node를 출력 한다. 
int  isExistedCustomer(char * searchName, struct VIP_DATA *getCusTomerInfo); // 큐에 해당 이미 Customer가 존재 하는지 Check 한다. 
int  isExistedSamePriority(int priority, struct VIP_DATA *getCusTomerInfo);  // 큐에 해당 이미 같은  priority를 가지는 Customer가 존재 하는지 Check 한다. 
int  getCustomerInfo( struct VIP_DATA *CusTomerInfo);                        // 고객 정보를 키보드로 부터 입력 받는다. 
void insertPriorityQueue(struct VIP_DATA customer);                          // 큐에 고객 정보를 우선 순위에 입각하여 정렬한다. 
struct VIP_DATA deletePriorityQueue(void);                                   // 큐로부터 우선 순위가 가장 높은 Node를 빼낸다. 
int updatePriorityQueue(struct VIP_DATA updateCustomerInfo);                 // 기존에 존재하는 고객의 우선 순위가 변경되었을 때 큐를 재정렬하여 삽입한다. 

int main(void)
{
  int select;
  int result;
  char buffer[256]={0,};
  struct VIP_DATA tempCustomerData;
  while(1)
  {
    memset(&tempCustomerData, 0x00, sizeof(struct VIP_DATA));
    printf("==============================================\n");
    printf("\tVIP Customer Management System\n");
    printf("==============================================\n");
    printf("1. Insert VIP Customer\n");
    printf("2. Delete VIP Customer\n");
    printf("3. Display All VIP Customer\n");
    printf("4. Search VIP Customer\n");
    printf("5. Change VIP Customer Priority\n");
    printf("6. Program Exit\n");
    printf(">> Select menu: ");
    fgets(buffer,256,stdin);
    switch(atoi(buffer))
    {
      case 1: 
        {
          printf("> Insert Customer's info[ ex) name, phone, priority ] :");
          result = getCustomerInfo(&tempCustomerData);
          if( result != D_RETURN_CODE_SUCCESS)
          {
            printf("%s",strInputError[result]);
            break;
          }
          insertPriorityQueue(tempCustomerData);
          printf("\n... Insert Customer's info...Success ! \n\n");
          break;
        }
      case 2: 
        {
          tempCustomerData = deletePriorityQueue();
          if(strlen(tempCustomerData.vip_name) <= 0 || strlen(tempCustomerData.vip_phone) <= 0)
          {
            printf("\n... Customer Queue is empty...\n\n");
            break;
          }
          printf("========================================================\n");
          printf("\n... Delete Customer's info...Success ! \n\n");
          printf("Customer's Information\n");
          printf("> customer name    : %s\n", tempCustomerData.vip_name);
          printf("> customer phone   : %s\n", tempCustomerData.vip_phone);
          printf("> customer priority: %d\n", tempCustomerData.vPriority);
          break;
        }
      case 3: 
        {
          if(displayPriorityQueue() == D_WORK_FAIL)
          {
            printf("\n... Customer is empty...\n\n");
          }
          break;
        }
      case 4: 
        {
          printf("> Search Customer's info[ ex) name ] :");
          fflush(stdin);
          fgets(buffer,256,stdin);
          if(isExistedCustomer(buffer, &tempCustomerData) == TRUE)
          {
            printf("========================================================\n");
            printf("Search Customer's Information\n");
            printf("> customer name    : %s\n", tempCustomerData.vip_name);
            printf("> customer phone   : %s\n", tempCustomerData.vip_phone);
            printf("> customer priority: %d\n", tempCustomerData.vPriority);
          }
          else
          {
            printf("\n...Customer is not existed ...\n\n");
          }
          break;
        }
      case 5: 
        {
          printf("> Change Customer's info[ ex) name, phone, priority ] :");
          result = getCustomerInfo(&tempCustomerData);
          if( result != D_RETURN_CODE_SUCCESS)
          {
            printf("%s",strInputError[result]);
            break;
          }
          updatePriorityQueue(tempCustomerData);
          printf("\n...Change Customer's info Success! ...\n\n");
          break;
        }
      case 6:
        {
          while(1)
          {
            tempCustomerData = deletePriorityQueue();
            if(strlen(tempCustomerData.vip_name) <= 0 || strlen(tempCustomerData.vip_phone) <= 0)
            {
              printf("\n========================================================\n");
              printf("ByeBye\n");
              return 0;
            }
          }
        }
      default:
        {
          printf("menu is not supported \n");
          break;
        }
    }
  }
  return 0;
} 

int displayPriorityQueue(void)
{
  int count = 1;
  priorityQueue temp=NULL;

  if(first==NULL)
  {
    return D_WORK_FAIL;
  }
  temp=first;
  while(temp != NULL)
  {
    printf("========================================================\n");
    printf("%d. customer info\n",count);
    printf("> customer name    : %s\n", temp->vData.vip_name);
    printf("> customer phone   : %s\n", temp->vData.vip_phone);
    printf("> customer priority: %d\n", temp->vData.vPriority);
    temp=temp->next;
    count++;
  }
  return D_WORK_SUCCESS;
}
int isExistedCustomer(char * searchName, struct VIP_DATA *getCusTomerInfo)
{
  priorityQueue temp=NULL;
  if(first==NULL)
  {
    return FALSE;
  }
  temp=first;
  while(temp != NULL)
  {
    if(!strcmp(temp->vData.vip_name, searchName))
    {
      if(getCusTomerInfo != NULL)
      {
        memcpy(getCusTomerInfo->vip_name, temp->vData.vip_name, strlen(temp->vData.vip_name));
        memcpy(getCusTomerInfo->vip_phone, temp->vData.vip_phone, strlen(temp->vData.vip_phone));
        getCusTomerInfo->vPriority = temp->vData.vPriority;
      }
      return TRUE;
    }
    temp=temp->next;
  }
  return FALSE;
}
int isExistedSamePriority(int priority, struct VIP_DATA *getCusTomerInfo)
{
  priorityQueue temp=NULL;
  if(first==NULL)
  {
    return FALSE;
  }
  temp=first;
  while(temp != NULL)
  {
    if(temp->vData.vPriority == priority)
    {
      if(getCusTomerInfo != NULL)
      {
        memcpy(getCusTomerInfo->vip_name, temp->vData.vip_name, strlen(temp->vData.vip_name));
        memcpy(getCusTomerInfo->vip_phone, temp->vData.vip_phone, strlen(temp->vData.vip_phone));
        getCusTomerInfo->vPriority = temp->vData.vPriority;
      }
      return TRUE;
    }
    temp=temp->next;
  }
  return FALSE;
}
int getCustomerInfo( struct VIP_DATA *CusTomerInfo)
{
  char buffer[256]={0,};
  char *context=NULL;
  char *token=NULL;
  int step = 0;

  fflush(stdin);
  fgets(buffer,256,stdin);

  /*
   *   * 키보드로 부터 입력을 받을 때 name과 phone과 우선순위를 파싱
   *       * 다음과 같은 모든 경우에 대하여 파싱 가능 (쉽표, 마침표, 공백, :)
   *           * name,phone,priority
   *               * name.phone.priority
   *                   * name phone priority
   *                       * name:phone:priority
   *                           */
  token = strtok(buffer, " .,:");
  while(token != NULL)
  {
    if(step == 0)
    {
      if(strlen(token) > MAX_VIP_NAME_LENGT || strlen(token) <= 0)
      {
        return D_RETURN_CODE_WRONG_NAME;
      }
      memcpy(CusTomerInfo->vip_name, token, strlen(token));
      step++;
    }
    else if(step == 1)
    {
      if(strlen(token) > MAX_VIP_PHONE_LENGT || strlen(token) <= 0)
      {
        return D_RETURN_CODE_WRONG_PHONE;
      }
      memcpy(CusTomerInfo->vip_phone, token, strlen(token));
      step++;
    }
    else if(step == 2)
    {
      if(atoi(token) < 0  || strlen(token) <= 0)
      {
        return D_RETURN_CODE_WRONG_PRIORITY;
      }
      CusTomerInfo->vPriority = atoi(token);
    }
    else
    {
      ;
    }
    token = strtok(NULL, " .,:");
  }
  if(step != 2)
  {
    return D_RETURN_CODE_WRONG_INPUT;
  }

  return D_RETURN_CODE_SUCCESS;
}
void insertPriorityQueue(struct VIP_DATA customer)
{
  priorityQueue temp=NULL;
  priorityQueue temp1=NULL;

  /*
   *   * 1. 삽입 하고 자 하는 고객이 큐에 존재 하는지 체크 
   *       */
  if(isExistedCustomer(customer.vip_name, NULL) == TRUE)
  {
    printf("\n... Customer exist already...\n\n");
    return;
  }
  /*
   *   * 2. 삽입 하고 자 하는 고객의 우선순위와 같은 우선 선위를 가지는 고객이 큐에 존재 하는지 체크 
   *       */
  if(isExistedSamePriority(customer.vPriority, NULL) == TRUE)
  {
    printf("\n... there already exist a customer has same priority ...\n\n");
    return;
  }
  /*
   *   * 3. 삽입 할 node를 만든다. 
   *       */
  temp=(struct QUEUE *)malloc(sizeof(struct QUEUE));
  memset(temp, 0x00, sizeof(struct QUEUE));
  memcpy(temp->vData.vip_name, customer.vip_name, strlen(customer.vip_name));
  memcpy(temp->vData.vip_phone, customer.vip_phone, strlen(customer.vip_phone));
  temp->vData.vPriority=customer.vPriority;
  temp->next=NULL;
  /*
   *   * 4. 우선 순위가 높은 Node가 항상 first에 오도록 정렬하여 삽입
   *       */ 
  if(first==NULL)
  {
    first=last=temp;
    first->prev=NULL;
    return;
  }
  else
  {
    if(customer.vPriority < last->vData.vPriority)
    {
      first->prev=temp;
      temp->next=first;
      temp->prev=NULL;
      first=temp;
      return;
    }
    else if(customer.vPriority > last->vData.vPriority)
    {
      last->next=temp;
      temp->prev=last;
      last=temp;
      return;
    }
    temp1=first;
    while(1)
    {
      if((customer.vPriority > temp1->vData.vPriority) && (customer.vPriority < temp1->next->vData.vPriority))
      {
        temp->prev=temp1;
        temp->next=temp1->next;
        temp1->next->prev=temp;
        temp1->next=temp;
        return;
      }
      else
      {
        temp1=temp1->next;
      }
    }
  }
}

struct VIP_DATA deletePriorityQueue(void)
{
  priorityQueue temp=NULL;
  struct VIP_DATA delCustomerData;
  memset(&delCustomerData, 0x00, sizeof(struct VIP_DATA));
  if(first==NULL)
  {
    return delCustomerData;
  }
  /*
   *   * 항상 우선 순위가 높은 Node가 first에 있으므로 first Node를 빼내면 됨 
   *       */ 
  if(first==last)
  {
    memcpy(&delCustomerData,&(first->vData), sizeof(struct VIP_DATA));
    free(first);
    first=NULL;
    return delCustomerData;
  }
  temp=first;
  memcpy(&delCustomerData, &(temp->vData), sizeof(struct VIP_DATA));
  first=first->next;
  free(temp);
  return delCustomerData;

}
int updatePriorityQueue(struct VIP_DATA updateCustomerInfo)
{
  priorityQueue temp=NULL;
  if(first==NULL)
  {
    return D_WORK_FAIL;
  }
  /*
   *   * 업데이트 하고 자 하는 고객이 큐에 존재 하는지 체크 
   *       */
  if(isExistedCustomer(updateCustomerInfo.vip_name, NULL) == FALSE)
  {
    printf("\n...Customer is not existed ...\n\n");
    return D_WORK_FAIL;
  }
  /*
   *   * 우선 순위가 변했을 시 해당 node를 삭제 후 재 삽입 과정을 통해 우선 순위 재정렬 
   *       */
  temp=first;
  while(temp != NULL)
  {
    if(!strcmp(temp->vData.vip_name, updateCustomerInfo.vip_name))
    {
      if(temp == first)
      {
        /*
         *               * 1. 삭제 하고자 하는 node가 first일 때 
         *                               */
        deletePriorityQueue();
      }
      else if(temp == last)
      {
        /*
         *               * 2. 삭제 하고자 하는 node가 last일 때 
         *                               */
        last = temp->prev;
        last->next = NULL;
        free(temp);
      }
      else
      {
        /*
         *               * 3. 삭제 하고자 하는 node가 중간 어딘가 일 때 
         *                               */
        temp->next->prev = temp->prev;
        temp->prev->next = temp->next;
        free(temp);
      }
      break;
    }
    temp=temp->next;
  }
  /*
   *   * 우선 순위 중복 체크 
   *       */ 
  if(isExistedSamePriority(updateCustomerInfo.vPriority, NULL) == TRUE)
  {
    printf("\n... there already exist a customer has same priority ...\n\n");
    return D_WORK_FAIL;
  }
  /*
   *   * 업데이트 된 Node의 삽입 및 우선 순위 재정렬 
   *       */ 
  insertPriorityQueue(updateCustomerInfo);
  return D_WORK_SUCCESS;
}

