#include <iostream>

using namespace std;

class Node {
  public:
    int data;
    Node *next;

    Node(int data =0){{
      next = NULL;
      this->data = data;
    }
    }
};

class List{
  public :
    int length;
    Node head;
    Node *last;

    List() : head(0)
    {
      length = 0;
      last = &head;
    };

    void out () {
      for (Node *tmp = &head; tmp != NULL; tmp = tmp->next){
        tmp = tmp->next;
        cout << tmp->data << endl;
      }
    }

    void insert (int data){
      Node *newN = new Node(data);
      last->next = newN;
      last = newN;
      length++;
    }
};

int main(){
  List *list  = new List();
  list->insert(10);
  list->insert(12);
  list->insert(13);
  list->out();
  return 0;
}
