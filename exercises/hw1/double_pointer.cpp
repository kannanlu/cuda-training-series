#include <stdio.h>

int main(int argc, char **argv)
{
    // a variable
    int var = 10;

    // pointer to int
    int *p1 = &var;

    // pointer to pointer
    int **p2 = &p1;

    printf("var: %d\n", var);
    printf("*p1: %d\n", *p1);
    printf("**p2: %d\n", **p2);

    return 0;
}