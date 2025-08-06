#include <iostream>
using namespace std;

int main() {
    int a = 10;
    int &ref = a; // ref is a reference to a
    cout << "Before modification: a = " << a << endl;
    ref = 20; // Modifying ref also modifies a
    cout << "After modification: a = " << a << endl;
    return 0;
}
