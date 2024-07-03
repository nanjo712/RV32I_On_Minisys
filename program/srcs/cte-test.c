#include "../../am/include/am.h"

Context *simple_trap(Event ev, Context *ctx) {
    switch(ev.event) {
        case EVENT_YIELD:
            putch('y'); break;
        default:
            assert(0); break;
    }
    return ctx;
}

int main() {
    cte_init(simple_trap);
    while(1) {
        for(volatile int i = 0; i < 1000000; i++);
        yield();
    }
    return 0;
}