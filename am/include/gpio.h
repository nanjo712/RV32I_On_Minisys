#ifndef GPIO_H_
#define GPIO_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stddef.h>

#include "hal_status.h"

#define GPIO_BASE_ADDR 0xA0000000
#define GPIO_PORT_A_OFFSET 0x0  // A for 7-Segment Display (write only)
#define GPIO_PORT_B_OFFSET 0x4  // B for LEDs (write only)
#define GPIO_PORT_C_OFFSET 0x8  // C for Switches (readout only)

    typedef enum
    {
        GPIO_PORT_A,
        GPIO_PORT_B,
        GPIO_PORT_C
    } GPIO_PORT;

    typedef struct
    {
        volatile unsigned int *port_a;
        volatile unsigned int *port_b;
        volatile unsigned int *port_c;
    } HAL_GPIO_TypeDef;

    HAL_StatusTypeDef gpio_init(HAL_GPIO_TypeDef *gpio);
    HAL_StatusTypeDef gpio_write(HAL_GPIO_TypeDef *gpio, GPIO_PORT port,
                                 unsigned int data);
    HAL_StatusTypeDef gpio_read(HAL_GPIO_TypeDef *gpio, GPIO_PORT port,
                                unsigned int *data);

    extern HAL_GPIO_TypeDef gpio;

#ifdef __cplusplus
}
#endif

#endif