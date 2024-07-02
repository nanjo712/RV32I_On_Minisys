#include "trap.h"

int led[16] = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768};

const uintptr_t GPIO_BASE = 0x10002000;
const uintptr_t UART_BASE = 0x10000000;

int main() {
    volatile uint32_t *gpio = (uint32_t *)GPIO_BASE;
    volatile uint32_t *uart = (uint32_t *)UART_BASE;
    
    while(gpio[1] != 0xdead);
    int id = 0, hex = 0;
    asm volatile(
        "csrr %0, marchid" \
        :"=r"(id) \
        :
    );
    for(int base = 1; id; base *= 16) {
        hex += base * (id % 10);
        id /= 10;
    }
    gpio[2] = hex;
    int cnt = 0;
    while(1) {
        gpio[0] = led[cnt];
        for(volatile int i = 0; i < 10000; i++);
        if(cnt == 15) cnt = 0;
        else cnt++;
    }
    return 0;
}