#include <stdio.h>

int gcd(int m, int n){
    int diff = 0;
    int i;

    if (m == n) return m;
    if(m > n)
        diff = m - n;
    else
        diff = n - m;
    for (i = diff ; i >0; i--){
        if (((m % i) == 0) && ((n % i) == 0))
            return i;
    }
}


int main(){
    int m, n;
    scanf("%d %d", &m, &n);

    printf("%d\n", gcd(m, n));
    return 0;
}
