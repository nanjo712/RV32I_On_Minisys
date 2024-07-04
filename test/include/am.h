void putch(char c);
void getch(char *c);

void halt(int code);
void check(int cond) {
    if(!cond) {
        halt(1);
    }
}