#include "../include/am.h"

char *str = "Hello, World!";

int main() {
    int a = 1;
    int b = 1;
    int c = a + b;
    for(int i = 0; i < 13; i++) {
        if(str[i] == 'o') {
            c++;
        }
    }
    check(c == 4);
    return 0;
}