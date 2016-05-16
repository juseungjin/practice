#include <stdio.h>

int get_gcd(int m, int n){
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

long long lcm(int m, int n){
    int gcd = get_gcd(m , n);
    long long lcm = 0;

    if (m == n) return m;

    if (m > n)
        lcm = (long)((m / gcd) * n);
    else
        lcm = (long)(m * ( n / gcd));
    return lcm;
}

int main(){
    int m, n;
    scanf("%d %d", &m, &n);

    printf("%lld\n", lcm(m, n));
    return 0;
}
