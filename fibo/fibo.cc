#include <stdio.h>

int fibo(int n){
    if (n == 1) return 1;
    if (n == 2) return 1;

    int i;
    int before = 1; //1번째꺼
    int cur = 1;    //2번째꺼
    int temp;
    for(i = 3; i <=n; i++){
        temp = cur;
        cur = (cur + before) % 10;
        before = temp;
    }
    return cur;
}

int main(){
    int n;
    scanf("%d", &n);

    printf("%d", fibo(n));
}
