#include "../../am/include/am.h"

#define CLINT_BASE 0x10000000

void enable_interrupt() {
    asm volatile("csrsi mstatus, 0x8");
    asm volatile("li t0, 0x888");
    asm volatile("csrs mie, t0");
}

void set_timer(uint64_t time) {
    uint64_t now = *(uint64_t *)(CLINT_BASE + 16);
    *(uint64_t *)(CLINT_BASE + 8) = now + time;
}

static Context *schedule(Event ev, Context *prev) {
    if(ev.event == EVENT_IRQ_TIMER) {
        putch('T');
        set_timer(50000000);
    }
    else if(ev.event == EVENT_IRQ_SOFTWARE) {
        putch('S');
    }
    else if(ev.event == EVENT_IRQ_EXTERNAL) {
        putch('E');
    }
    return prev;
}

int main() {
    cte_init(schedule);
    enable_interrupt();
    set_timer(50000000);
    while(1) {
        // do nothing
    }
    assert(0);
}