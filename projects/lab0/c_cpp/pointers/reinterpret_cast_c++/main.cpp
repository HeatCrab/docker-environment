#include <iostream>
using namespace std;

int main() {
    int num = 0x61; //0x61 is ASCII code 'a'
    int *pnum = &num;
    char *pstr = reinterpret_cast<char *>(pnum);
    cout << "pnum address: " << pnum << endl;
    cout << "pstr address: " << static_cast<void *>(pstr) << endl;
    cout << "pnum value: " << hex << *pnum << endl;
    cout << "pstr value: " << pstr << endl;
    return 0;
}