extern char _head_start;
extern char _head_end;

#define UART_BASE 0x10000000

int main();

void putch(char c) {
    
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