#include <iostream>
#include <vector>

using namespace std;

int afibo(long long n, int mod){

    if (n == 1) return 1;
    if (n == 2) return 1;
    vector<int> v;

    v.push_back(0);
    v.push_back(1);

    long long i;
    int before = 1; //1번째꺼
    int cur = 1;    //2번째꺼
    int temp;
    for(i = 3; i <=n; i++){
        temp = cur;
        cur = (cur + before) % mod;
        before = temp;
        if(before == 0 && cur == 1)
            break;
        v.push_back(cur);
    }

    int index = n % v.size();

    return v.at(index-1);
}

int main(){
    long long n;
    int m;
    cin >> n >> m;

    cout << afibo(n, m) << endl;
}
