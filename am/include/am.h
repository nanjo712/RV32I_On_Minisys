#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

typedef struct {
    void *start, *end;
} Area;

typedef struct {
    uintptr_t gpr[32], mcause, mstatus, mepc;
    void *pdir;
} Context;

typedef struct {
    enum {
        EVENT_NULL = 0,
        EVENT_YIELD,
        EVENT_ERROR,
    } event;
    uintptr_t cause, ref;
    const char *msg;
} Event;

// Base functions
void putch(char c);
void getch(char *c);

void halt(int code);
void assert(int cond) {
    if(!cond) {
        halt(1);
    }
}

// CTE functions
bool cte_init(Context *(*handler)(Event, Context*));
void yield();
Context *kcontext(Area kstack, void (*entry)(void *), void *arg);