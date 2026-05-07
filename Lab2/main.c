#include <stdint.h>

// Объявления функций из ассемблерного кода
void handle_timer(void);
void uart_putchar(char c);
void enable_timer(void);

void handle_timer(void) {
    uart_putchar('T');  // Выводим символ 'T' при срабатывании таймера
}

void uart_putchar(char c) {
    volatile uint32_t *uart_tx = (volatile uint32_t *)0x10000000;
    *uart_tx = c;
}

void enable_timer(void) {
    // Заглушка для включения таймера
    // В реальной реализации нужно настроить регистры таймера
}

int main(void) {
    const char *greeting = "Приветствие: Здравствуйте! Меня зовут [Имя студента]\n";
    while (*greeting) {
        uart_putchar(*greeting++);
    }

    // Здесь можно вызвать enable_timer() для активации таймера

    while (1) {
        asm volatile ("wfi");  // Ожидание прерывания
    }
    return 0;
}