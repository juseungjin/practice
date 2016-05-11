#include <stdio.h>

int main(){
    int n, i=0 ;
    int num;
    int first =0;
    int second = 0;

    scanf("%d", &n);

    for ( i =0; i < n; i++){
        scanf("%d", &num);
        if ( first < num ) {
            second = first;
            first = num;
        } else if (second < num) {
            second = num;
        }
    }
    printf("first %d * second %d = %d\n", first, second, (first * second));
    return 0;
}
