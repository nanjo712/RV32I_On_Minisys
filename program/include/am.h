void halt(int code);
void check(int cond) {
    if(!cond) {
        halt(1);
    }
}