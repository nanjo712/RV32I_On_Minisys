#include "../include/uart_lite.h"

HAL_StatusTypeDef uart_lite_init(HAL_UART_LITE_TypeDef *uart)
{
    uart->rx_fifo =
        (unsigned char *)(UART_LITE_BASEADDR + UART_LITE_RXFIFO_OFFSET);
    uart->tx_fifo =
        (unsigned char *)(UART_LITE_BASEADDR + UART_LITE_TXFIFO_OFFSET);
    uart->status =
        (unsigned int *)(UART_LITE_BASEADDR + UART_LITE_STATUS_OFFSET);
    uart->control =
        (unsigned int *)(UART_LITE_BASEADDR + UART_LITE_CONTROL_OFFSET);
    *uart->control = UART_LITE_CONTROL_RST_TX | UART_LITE_CONTROL_RST_RX;
    return HAL_OK;
}

HAL_StatusTypeDef uart_lite_enable_interrupt(HAL_UART_LITE_TypeDef *uart)
{
    *uart->control |= UART_LITE_CONTROL_IT;
    return HAL_OK;
}

HAL_StatusTypeDef uart_lite_disable_interrupt(HAL_UART_LITE_TypeDef *uart)
{
    *uart->control &= ~UART_LITE_CONTROL_IT;
    return HAL_OK;
}

HAL_StatusTypeDef uart_lite_send_byte(HAL_UART_LITE_TypeDef *uart,
                                      unsigned char *data)
{
    while ((*uart->status & 0x2) == 0);
    *uart->tx_fifo = *data;
    return HAL_OK;
}

HAL_StatusTypeDef uart_lite_recv_byte(HAL_UART_LITE_TypeDef *uart,
                                      unsigned char *data)
{
    while ((*uart->status & 0x1) == 0);
    *data = *uart->rx_fifo;
    return HAL_OK;
}

HAL_StatusTypeDef uart_lite_send(HAL_UART_LITE_TypeDef *uart,
                                 unsigned char *data, unsigned int size)
{
    for (unsigned int i = 0; i < size; i++)
    {
        uart_lite_send_byte(uart, &data[i]);
    }
    return HAL_OK;
}

HAL_StatusTypeDef uart_lite_recv(HAL_UART_LITE_TypeDef *uart,
                                 unsigned char *data, unsigned int size)
{
    for (unsigned int i = 0; i < size; i++)
    {
        uart_lite_recv_byte(uart, &data[i]);
    }
    return HAL_OK;
}


