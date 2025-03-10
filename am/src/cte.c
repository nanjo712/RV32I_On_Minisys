#include "../include/am.h"

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
    if(user_handler) {
        Event ev = {0};
        switch (c->mcause) {
        case -1: 
            c->mepc = c->mepc + 4;
            ev.event = EVENT_YIELD; 
            break;
        case 0x8000000b: 
            ev.event = EVENT_IRQ_EXTERNAL;
            break;
        case 0x80000007:
            ev.event = EVENT_IRQ_TIMER;
            break;
        case 0x80000003:
            ev.event = EVENT_IRQ_SOFTWARE;
            break;
        default: ev.event = EVENT_ERROR; break;
        }
        c = user_handler(ev, c);
        assert(c != NULL);
    }
    return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
    // initialize exception entry
    asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

    // register event handler
    user_handler = handler;

return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
    Context *ct = (Context *)((uintptr_t)kstack.end - sizeof(Context));
    ct->mepc = (uintptr_t)entry;
    ct->gpr[10] = (uintptr_t)arg; //$a0
    return ct;
}

void yield() {
    asm volatile("li a7, -1; ecall");
}