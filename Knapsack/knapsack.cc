#include <iostream>
#include <utility>
#include <vector>
#include <algorithm>
#include <iomanip>

using namespace std;

double max_combi(vector<pair<int, int> > v, int target) {
	double max=0.0;
	int temp_target = target;

	if (v.size() == 1) {
		if (target > v.front().first )
			return v.front().first;
		else
			return 0;
	}

	for(int i=0; i<v.size(); i++){
		vector<pair<int, int> > temp_v = v;
		temp_target = target;
		if (temp_target < temp_v[i].second) {
			continue;
		}
		int pick = temp_v[i].first;
		temp_target -= temp_v[i].second;
		temp_v.erase(temp_v.begin() + i);

		int temp = pick + max_combi(temp_v, temp_target);
		if (temp > max)
			max = temp;
	}

	return max;
}

int main(){
  int n, target;
  int key, value;
  double ret;
  vector<pair<int, int> > v;

  cin >> n >> target ;

  for(int i=0; i<n; i++){
    cin >> key >> value;
    v.push_back(make_pair(key, value));
  }

  sort(v.begin(), v.end());
  ret = max_combi(v, target);
  cout << fixed << setprecision(4) << ret << endl;

  return 0;
}
