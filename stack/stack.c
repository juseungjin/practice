#include <stdio.h>

#define SIZE 5

int top = 0;
int s[SIZE];

void push (int d){
  if (top >= SIZE) {printf("overflow\n");}
  else{
    s[top] = d;
    top ++;
  }
}

void pop () {
  if (top == 0) { printf("empty\n"); }
  else {
    printf("value is %d\n", s[top-1]);
    s[top-1] = 0;
    top--;
  }
}

int main(){
  int menu =0;
  int data;
  printf("menu= %d\n", menu);

  while(menu <= 3){
    printf("select menu 1.push  2.pop  3.exit\n");
    scanf("%d", &menu);

    switch(menu){
      case 1:
        printf("input data: ");
        scanf("%d", &data);
        push(data);
        break;
      case 2:
        pop();
        break;
      case 3:
        printf("bye-bye\n");
        return 0;
      }
   }
}
