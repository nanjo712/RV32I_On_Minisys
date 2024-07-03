#include "../include/am.h"

extern char _head_start;
extern char _head_end;

Area heap = {
    .start = &_head_end,
    .end = &_head_end
};

int main();

void putch(char c) {
    while((*((volatile char *)0x10000008) & 0x00000004) != 0x00000004);
    *((volatile char *)0x10000004) = c;
}

void getch(char *c) {
    *c = *((volatile char *)0x10000000);
}

void halt(int code) {
    asm volatile(
        "mv a0, %0\n" \
        : \
        : "r"(code));
    while(1);
}

void _trm_init() {
    int ret = main();
    halt(ret);
}