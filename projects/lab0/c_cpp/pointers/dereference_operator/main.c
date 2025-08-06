#include <stdio.h>

int main() {
    int x = 100 ;
    printf("value of x: %d\n", x); // print x value

    int *x_p = &x;
    printf("address of x: %p\n", x_p); // print x address
    printf("dereference the pointer of x: %d\n", *x_p);
    return 0;
}
