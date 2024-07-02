extern char _head_start;
extern char _head_end;

int main();

void putch(char c) {
  while((*((volatile char *)0x10000005) & 65) != 65);
  *((volatile char *)0x10000000) = c;
}

void getch(char *c) {
    
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