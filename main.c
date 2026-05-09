
#include "sw_timer.h"
#include <stdio.h>

// Callback-функции для разных таймеров
void oneshot_callback(void) {
    printf("Oneshot timer expired!\n");
}

void multiple_callback(void) {
    printf("Multiple timer triggered!\n");
}

void periodic_callback(void) {
    printf("Periodic timer tick!\n");
}

int main(void) {
    // Инициализация программного таймера
    sw_timer_init();

    // Добавляем таймеры разных типов
    uint32_t oneshot_id = sw_timer_add(1000, SW_TIMER_ONESHOT, oneshot_callback);
    uint32_t multiple_id = sw_timer_add(2000, SW_TIMER_MULTIPLE, multiple_callback);
    uint32_t periodic_id = sw_timer_add(500, SW_TIMER_PERIODIC, periodic_callback);

    // Тестируем активность таймеров
    printf("Timer 1 active: %d\n", sw_timer_is_active(oneshot_id));
    printf("Timer 2 active: %d\n", sw_timer_is_active(multiple_id));
    printf("Timer 3 active: %d\n", sw_timer_is_active(periodic_id));

    // Бесконечный цикл — основная работа программы
    while (1) {
        // Здесь может быть другая логика приложения
    }

    return 0;
}