#include "timer.h"

#include "hal_status.h"

HAL_TIMER_TypeDef timer = {NULL, NULL};

HAL_StatusTypeDef timer_init(HAL_TIMER_TypeDef *timer)
{
    timer->compare =
        (volatile uint64_t *)(TIMER_BASE_ADDR + TIMER_COMPARE_OFFSET);
    timer->counter =
        (volatile uint64_t *)(TIMER_BASE_ADDR + TIMER_COUNTER_OFFSET);
    return HAL_OK;
}

HAL_StatusTypeDef timer_set_compare(HAL_TIMER_TypeDef *timer, uint64_t value)
{
    *timer->compare = value;
    return HAL_OK;
}

HAL_StatusTypeDef timer_get_counter(HAL_TIMER_TypeDef *timer, uint64_t *value)
{
    *value = *timer->counter;
    return HAL_OK;
}