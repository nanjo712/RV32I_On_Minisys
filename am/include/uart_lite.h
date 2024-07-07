#ifndef UART_LITE_H
#define UART_LITE_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>
#include <stddef.h>

#include "hal_status.h"

#define UART_LITE_BASEADDR 0x40000000
#define UART_LITE_RXFIFO_OFFSET 0x0
#define UART_LITE_TXFIFO_OFFSET 0x4
#define UART_LITE_STATUS_OFFSET 0x8
#define UART_LITE_CONTROL_OFFSET 0xC
#define UART_LITE_CONTROL_IT (1 << 4)
#define UART_LITE_CONTROL_RST_TX (1 << 0)
#define UART_LITE_CONTROL_RST_RX (1 << 1)
#define UART_LITE_STATUS_TX_FULL (1 << 3)
#define UART_LITE_STATUS_TX_EMPTY (1 << 2)
#define UART_LITE_STATUS_RX_FULL (1 << 1)
#define UART_LITE_STATUS_RX_VALID (1 << 0)

    typedef struct
    {
        volatile unsigned char *rx_fifo;
        volatile unsigned char *tx_fifo;
        volatile unsigned int *status;
        volatile unsigned int *control;
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
    void uart_interrupt_callback();
    HAL_StatusTypeDef uart_lite_recv_it(HAL_UART_LITE_TypeDef *uart,
                                        unsigned char *data, unsigned int size,
                                        volatile bool *done);

    extern HAL_UART_LITE_TypeDef uart;

#ifdef __cplusplus
}
#endif

#endif