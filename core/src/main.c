#include <stdint.h>

#include "hal.h"

// #define NULL ((void *)0)

#define MAX_STACK_SIZE 100

void task_for_serial();

unsigned char space = 32;
int ind = 0;
uintptr_t last_pc = (uintptr_t)&task_for_serial;

uint64_t period = 10000000;
uint64_t counter;

unsigned int patterns[] = {
    0x00001, 0x00002, 0x00004, 0x00008, 0x00010, 0x00020, 0x00040,
    0x00080, 0x00100, 0x00200, 0x00400, 0x00800, 0x01000, 0x02000,
    0x04000, 0x08000, 0x10000, 0x20000, 0x40000, 0x80000,  // 从低位到高位
    0x80000, 0x40000, 0x20000, 0x10000, 0x08000, 0x04000, 0x02000,
    0x01000, 0x00800, 0x00400, 0x00200, 0x00100, 0x00080, 0x00040,
    0x00020, 0x00010, 0x00008, 0x00004, 0x00002, 0x00001,  // 从高位到低位
    0x80001, 0x40002, 0x20004, 0x10008, 0x08010, 0x04020, 0x02040,
    0x01080, 0x00900, 0x01200, 0x02400, 0x04800, 0x09000, 0x12000,
    0x24000, 0x48000,
    0x90000,  // 从两边到中间
    0x48000, 0x24000, 0x12000, 0x09000, 0x04800, 0x02400, 0x01200,
    0x00900, 0x01080, 0x02040, 0x04020, 0x08010, 0x10008, 0x20004,
    0x40002, 0x80001  // 中间碰撞后回弹
};

void enable_interrupt()
{
    asm volatile("csrsi mstatus, 0x8");
    asm volatile("li t0, 0x888");
    asm volatile("csrs mie, t0");
}

// 模拟isdigit函数
int is_digit(char c) { return c >= '0' && c <= '9'; }

// 运算符优先级
int precedence(char op)
{
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
}

// 进行运算
int applyOp(int a, int b, char op, int *error)
{
    if (op == '/' && b == 0)
    {  // 处理除零错误
        *error = 1;
        return 0;
    }
    switch (op)
    {
        case '+':
            return a + b;
        case '-':
            return a - b;
        case '*':
            return a * b;
        case '/':
            return a / b;
    }
    *error = 1;  // 未知操作符错误
    return 0;
}

// 计算器函数
int caculate(const char *str, int *result)
{
    int values[MAX_STACK_SIZE];  // 数值栈
    char ops[MAX_STACK_SIZE];    // 操作符栈
    int valTop = -1;             // 数值栈顶指针
    int opTop = -1;              // 操作符栈顶指针
    int error = 0;               // 错误标志
    int i = 0;
    int expectOperand = 1;  // 期待操作数标志

    while (str[i] != '\0')
    {
        // 跳过空格
        if (str[i] == ' ')
        {
            i++;
            continue;
        }

        // 当前字符是数字
        if (is_digit(str[i]))
        {
            if (!expectOperand) return 1;  // 如果期待操作符但遇到操作数，报错
            int value = 0;
            // 处理多位数
            while (is_digit(str[i]))
            {
                value = value * 10 + (str[i] - '0');
                i++;
            }
            values[++valTop] = value;
            // 回退一步以处理当前字符
            i--;
            expectOperand = 0;  // 下一个期待操作符
        }
        // 当前字符是左括号
        else if (str[i] == '(')
        {
            ops[++opTop] = str[i];
            expectOperand = 1;  // 左括号后期待操作数
        }
        // 当前字符是右括号
        else if (str[i] == ')')
        {
            if (expectOperand) return 1;  // 如果期待操作数但遇到右括号，报错
            // 处理括号内的表达式
            while (opTop != -1 && ops[opTop] != '(')
            {
                if (valTop < 1) return 1;  // 检查是否有足够的操作数
                int val2 = values[valTop--];
                int val1 = values[valTop--];
                char op = ops[opTop--];
                values[++valTop] = applyOp(val1, val2, op, &error);
                if (error) return 1;  // 发生错误，返回1
            }
            // 检查是否有匹配的左括号
            if (opTop == -1) return 1;  // 括号不匹配错误
            // 移除左括号
            opTop--;
            expectOperand = 0;  // 右括号后期待操作符
        }
        // 当前字符是操作符
        else if (str[i] == '+' || str[i] == '-' || str[i] == '*' ||
                 str[i] == '/')
        {
            if (expectOperand) return 1;  // 如果期待操作数但遇到操作符，报错
            // 处理优先级较高的操作符
            while (opTop != -1 && precedence(ops[opTop]) >= precedence(str[i]))
            {
                if (valTop < 1) return 1;  // 检查是否有足够的操作数
                int val2 = values[valTop--];
                int val1 = values[valTop--];
                char op = ops[opTop--];
                values[++valTop] = applyOp(val1, val2, op, &error);
                if (error) return 1;  // 发生错误，返回1
            }
            ops[++opTop] = str[i];
            expectOperand = 1;  // 操作符后期待操作数
        }
        else
        {
            return 1;  // 非法字符错误
        }
        i++;
    }

    // 处理剩余的操作符
    while (opTop != -1)
    {
        if (ops[opTop] == '(') return 1;  // 括号不匹配错误
        if (valTop < 1) return 1;         // 检查是否有足够的操作数
        int val2 = values[valTop--];
        int val1 = values[valTop--];
        char op = ops[opTop--];
        values[++valTop] = applyOp(val1, val2, op, &error);
        if (error) return 1;  // 发生错误，返回1
    }

    if (valTop != 0) return 1;  // 表达式格式错误
    // 最终结果
    *result = values[valTop];
    return 0;  // 成功，返回0
}

void swap(int *a, int *b)
{
    int temp = *a;
    *a = *b;
    *b = temp;
}

int partition(int arr[], int low, int high)
{
    int pivot = arr[high];  // 选择最后一个元素作为枢轴
    int i = low - 1;        // i是较小元素的索引

    for (int j = low; j < high; j++)
    {
        if (arr[j] < pivot)
        {
            i++;
            swap(&arr[i], &arr[j]);
        }
    }
    swap(&arr[i + 1], &arr[high]);
    return i + 1;
}

void quick_sort(int arr[], int low, int high)
{
    if (low < high)
    {
        int pi = partition(arr, low, high);  // pi是分区索引
        quick_sort(arr, low, pi - 1);        // 递归排序左半部分
        quick_sort(arr, pi + 1, high);       // 递归排序右半部分
    }
}

void get_line(HAL_UART_LITE_TypeDef *uart, char *buffer)
{
    int i = 0;
    while (1)
    {
        unsigned char c;
        uart_lite_recv_byte(uart, &c);
        if (c == '\n')
        {
            buffer[i] = '\0';
            break;
        }
        buffer[i++] = c;
    }
}

int select_mode(HAL_UART_LITE_TypeDef *uart, char *buffer)
{
    while (1)
    {
        uart_lite_send(uart, (unsigned char *)"Please select mode:\n", 21);
        uart_lite_send(uart, (unsigned char *)"1. Calculator\n", 15);
        uart_lite_send(uart, (unsigned char *)"2. Quick Sort\n", 15);
        get_line(uart, buffer);
        if (buffer[0] == '1' || buffer[0] == '2') return buffer[0] - '0';
        uart_lite_send(
            uart, (unsigned char *)"Invalid mode! Please try again.\n", 33);
    }
}

int serialize_int(char *buffer, int value)
{
    int i = 0;
    if (value == 0)
    {
        buffer[i++] = '0';
        buffer[i] = '\0';
        return i;
    }
    if (value < 0)
    {
        buffer[i++] = '-';
        value = -value;
    }
    char temp[10];
    int j = 0;
    while (value)
    {
        temp[j++] = value % 10 + '0';
        value /= 10;
    }
    while (j)
    {
        buffer[i++] = temp[--j];
    }
    buffer[i] = '\0';
    return i;
}

int parse_int(char *buffer, int *value)
{
    int i = 0;
    int result = 0;
    int sign = 1;
    if (buffer[i] == '-')
    {
        sign = -1;
        i++;
    }
    while (buffer[i] != '\0' && buffer[i] != ' ' && buffer[i] != '\n')
    {
        result = result * 10 + (buffer[i] - '0');
        i++;
    }
    *value = result * sign;
    return i + 1;
}

Context *it_handler(Event ev, Context *prev)
{
    if (ev.event == EVENT_IRQ_TIMER)
    {
        gpio_write(&gpio, GPIO_PORT_A, patterns[ind]);
        gpio_write(&gpio, GPIO_PORT_B, patterns[ind]);
        ind++;
        ind %= 73;
        timer_get_counter(&timer, &counter);
        timer_set_compare(&timer, period + counter);
    }
    return prev;
}

int main()
{
    // init
    gpio_init(&gpio);
    timer_init(&timer);
    uart_lite_init(&uart);
    timer_get_counter(&timer, &counter);
    timer_set_compare(&timer, period + counter);

    enable_interrupt();
    cte_init(it_handler);

    task_for_serial();
    return 0;
}

void task_for_serial()
{
    char buffer[256];
    int array[100];
    int mode = select_mode(&uart, buffer);
    while (1)
    {
        if (mode == 1)
        {
            uart_lite_send(&uart,
                           (unsigned char *)"Please input an expression:", 28);
            get_line(&uart, buffer);
            int result;
            if (caculate(buffer, &result))
            {
                uart_lite_send(&uart, (unsigned char *)"Invalid expression!",
                               20);
            }
            else
            {
                int len = serialize_int(buffer, result);
                uart_lite_send(&uart, (unsigned char *)buffer, len);
            }
            uart_lite_send(&uart, (unsigned char *)"\n", 2);
        }
        else if (mode == 2)
        {
            int count;
            int offset = 0;
            uart_lite_send(
                &uart,
                (unsigned char *)"Please input the length of the array:", 38);
            get_line(&uart, buffer);
            parse_int(buffer, &count);
            uart_lite_send(&uart,
                           (unsigned char *)"Please input the array:", 24);
            get_line(&uart, buffer);
            for (int i = 0; i < count; i++)
            {
                offset += parse_int(buffer + offset, &array[i]);
            }
            quick_sort(array, 0, count - 1);
            uart_lite_send(&uart, (unsigned char *)"Sorted array:\n", 15);
            for (int i = 0; i < count; i++)
            {
                int len = serialize_int(buffer, array[i]);
                // buffer[len++] = '\n';
                // buffer[len++] = '\0';
                uart_lite_send(&uart, (unsigned char *)buffer, len);
                uart_lite_send(&uart, (unsigned char *)"\n", 2);
            }
            uart_lite_send(&uart, (unsigned char *)"\n", 2);
        }
    }
}