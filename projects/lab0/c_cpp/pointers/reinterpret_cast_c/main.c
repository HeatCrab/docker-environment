#include <stdio.h>

int main() {
    int num = 0x61;
    int *pnum = &num;
    char *pstr = (char *)pnum;
    printf("pnum address: %p\n", (void *)pnum);
    printf("pstr address: %p\n", (void *)pstr);
    printf("pnum value: 0x%x\n", *pnum);
    printf("pstr value: %s\n", pstr);
    printf("pstr address: %p\n", pstr);
    return 0;
}
