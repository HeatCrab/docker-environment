#include <stdio.h>

int main() {
    int arr[] = {10, 20, 30, 40, 50};
    int *ptr = arr;
    printf("Initial pointer: %p, Value: %d\n", (void*)ptr, *ptr);

    ptr++;
    printf("After ptr++:\n");
    printf("Pointer: %p, Value: %d\n", (void*)ptr, *ptr);

    ptr += 2;
    printf("After ptr += 2:\n");
    printf("Pointer: %p, Value: %d\n", (void*)ptr, *ptr);

    ptr--;
    printf("After ptr--:\n");
    printf("Pointer: %p, Value: %d\n", (void*)ptr, *ptr);

    int *end = arr + 5;
    printf("--------------- Iterating over array using pointer ---------------\n");
    for (ptr = arr; ptr < end; ptr++) {
        printf("Pointer: %p, Value: %d\n", (void*)ptr, *ptr);
    }
    return 0;
}
