#ifndef TIMER_H_
#define TIMER_H_

#include <stdint.h>

#include "am.h"
#include "hal_status.h"

#define TIMER_BASE_ADDR 0x10000000
#define TIMER_COMPARE_OFFSET 0x8
#define TIMER_COUNTER_OFFSET 0x10

typedef struct
{
    volatile uint64_t *compare;
    volatile uint64_t *counter;
} HAL_TIMER_TypeDef;

HAL_StatusTypeDef timer_init(HAL_TIMER_TypeDef *timer);
HAL_StatusTypeDef timer_set_compare(HAL_TIMER_TypeDef *timer, uint64_t value);
HAL_StatusTypeDef timer_get_counter(HAL_TIMER_TypeDef *timer, uint64_t *value);

extern HAL_TIMER_TypeDef timer;

#endif