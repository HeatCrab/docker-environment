#include <stdio.h>
#include <limits.h>

int main() {
    int n = INT_MAX - 5; // 2147483647 - 5 = 2147483642
    int k = INT_MIN + 5; // -2147483648 + 5 = -2147483643
    for (int i = 0; i < 10; i++) {
        printf("%d , %d\n", n + i, k - i);
    }
    return 0;
}
