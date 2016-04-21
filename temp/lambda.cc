#include <iostream>
#include <functional>
#include <string>
#include <vector>
#include <array>

int main(int argc, char** argv)
{
  std::vector<int> v = {1, 2, 3, 4, 5};

  // 람다 사용 X
  std::cout << "람다 사용 X" << std::endl;

  for (auto it = v.begin(); it != v.end(); it++)
  {
    std::cout << *it << std::endl;
  }

  std::for_each(v.begin(), v.end(), [](int val)
  {
    std::cout << val << std::endl;
  });

  return 0;
}
