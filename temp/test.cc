#include <iostream>
#include <array>
#include <functional>
#include <vector>
#include <string>
#include <algorithm>

using namespace std;

bool IsOdd(int i)
{
  return ((i%2) ==1);
}

class CIsOdd
{
  public:
    bool operator()(int i)
    {
      return ((i%2) ==1);
    }
};

struct Accumulator
{
  Accumulator()
  {
    counter = 0;
  }

  int counter;
  int operator()(int i)
  {
    return counter += i;
  }
};

class Functor
{
  public:
    void operator()(){
      cout << "Simple Functor" << endl;
    }
};

class EvenOddFunctor
{
  public:
    EvenOddFunctor() : evenSum(0), oddSum(0) {}

    void operator() (int x)
    {
      if(x%2 == 0)
        evenSum += x;
      else
        oddSum += x;
    }
    int sumEven() const { return evenSum;}
    int sumOdd() const {return oddSum;}

  private:
    int evenSum;
    int oddSum;
};

int main()
{
  auto result = [] (int input) { return input * input;};
  cout << result(10) << endl;

  Functor func;
  func();

  Accumulator a;
  cout << a(10) << endl;
  cout << a(20) << endl;

  EvenOddFunctor functor;
  array <int, 10> theList = {1,2,3,4,5,6,7,8,9,10};
  functor = for_each(theList.cbegin(), theList.cend(), functor);

  cout << "Sum of evens: " << functor.sumEven() << endl;
  cout << "Sum of odds: " << functor.sumOdd() << endl;

  vector<int> v = {10,25,40,55};

  auto it = find_if(v.begin(), v.end(), IsOdd);

  CIsOdd objIsOdd;
  auto cit = find_if(v.cbegin(), v.cend(), objIsOdd);
  std::cout << "The first odd value is " << *(it+1) << std::endl;
  std::cout << "The first odd value is " << *cit << std::endl;
  return 0;
}
