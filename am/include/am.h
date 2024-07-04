#ifndef __AM_H__
#define __AM_H__

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct
{
    void *start, *end;
} Area;

typedef struct
{
    uintptr_t gpr[32], mcause, mstatus, mepc;
    void *pdir;
} Context;

typedef struct
{
    enum
    {
        EVENT_NULL = 0,
        EVENT_YIELD,
        EVENT_IRQ_TIMER,
        EVENT_IRQ_SOFTWARE,
        EVENT_IRQ_EXTERNAL,
        EVENT_ERROR,
    } event;
    uintptr_t cause, ref;
    const char *msg;
} Event;

// Base functions

extern Area heap;

extern Area heap;
void putch(char c);
void getch(char *c);

void halt(int code);
void assert(int cond);

// CTE functions
bool cte_init(Context *(*handler)(Event, Context *));
void yield();
Context *kcontext(Area kstack, void (*entry)(void *), void *arg);

Context *kcontext(Area kstack, void (*entry)(void *), void *arg);
Context *kcontext(Area kstack, void (*entry)(void *), void *arg);

#endif