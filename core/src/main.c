#include "hal.h"

#define NULL ((void *)0)

int main()
{
    HAL_UART_LITE_TypeDef uart = {NULL, NULL, NULL, NULL};
    uart_lite_init(&uart);
    while (1)
    {
        uart_lite_send(&uart, (unsigned char *)"Hello, World!\n", 14);
    }
    return 0;
}