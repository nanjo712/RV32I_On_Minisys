#ifndef UART_LITE_H
#define UART_LITE_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "hal.h"

#define UART_LITE_BASEADDR 0x10000000
#define UART_LITE_RXFIFO_OFFSET 0x0
#define UART_LITE_TXFIFO_OFFSET 0x4
#define UART_LITE_STATUS_OFFSET 0x8
#define UART_LITE_CONTROL_OFFSET 0xC
#define UART_LITE_CONTROL_IT (1 << 4)
#define UART_LITE_CONTROL_RST_TX (1 << 0)
#define UART_LITE_CONTROL_RST_RX (1 << 1)

    typedef struct
    {
        unsigned char *rx_fifo;
        unsigned char *tx_fifo;
        unsigned int *status;
        unsigned int *control;
    } HAL_UART_LITE_TypeDef;

    HAL_StatusTypeDef uart_lite_init(HAL_UART_LITE_TypeDef *uart);
    HAL_StatusTypeDef uart_lite_enable_interrupt(HAL_UART_LITE_TypeDef *uart);
    HAL_StatusTypeDef uart_lite_disable_interrupt(HAL_UART_LITE_TypeDef *uart);
    HAL_StatusTypeDef uart_lite_send_byte(HAL_UART_LITE_TypeDef *uart,
                                          unsigned char *data);
    HAL_StatusTypeDef uart_lite_recv_byte(HAL_UART_LITE_TypeDef *uart,
                                          unsigned char *data);
    HAL_StatusTypeDef uart_lite_send(HAL_UART_LITE_TypeDef *uart,
                                     unsigned char *data, unsigned int size);
    HAL_StatusTypeDef uart_lite_recv(HAL_UART_LITE_TypeDef *uart,
                                     unsigned char *data, unsigned int size);

#ifdef __cplusplus
}
#endif

#endif