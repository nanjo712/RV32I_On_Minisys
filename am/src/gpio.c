#include "gpio.h"

#include "hal_status.h"

HAL_GPIO_TypeDef gpio = {NULL, NULL, NULL};

HAL_StatusTypeDef gpio_init(HAL_GPIO_TypeDef *gpio)
{
    gpio->port_a =
        (volatile unsigned int *)(GPIO_BASE_ADDR + GPIO_PORT_A_OFFSET);
    gpio->port_b =
        (volatile unsigned int *)(GPIO_BASE_ADDR + GPIO_PORT_B_OFFSET);
    gpio->port_c =
        (volatile unsigned int *)(GPIO_BASE_ADDR + GPIO_PORT_C_OFFSET);
    return HAL_OK;
}

HAL_StatusTypeDef gpio_write(HAL_GPIO_TypeDef *gpio, GPIO_PORT port,
                             unsigned int data)
{
    switch (port)
    {
        case GPIO_PORT_A:
            *gpio->port_a = data;
            break;
        case GPIO_PORT_B:
            *gpio->port_b = data;
            break;
        case GPIO_PORT_C:
            break;
        default:
            return HAL_ERROR;
    }
    return HAL_OK;
}

HAL_StatusTypeDef gpio_read(HAL_GPIO_TypeDef *gpio, GPIO_PORT port,
                            unsigned int *data)
{
    switch (port)
    {
        case GPIO_PORT_A:
            break;
        case GPIO_PORT_B:
            break;
        case GPIO_PORT_C:
            *data = *gpio->port_c;
            break;
        default:
            return HAL_ERROR;
    }
    return HAL_OK;
}