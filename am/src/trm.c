extern char _head_start;
extern char _head_end;

int main();

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