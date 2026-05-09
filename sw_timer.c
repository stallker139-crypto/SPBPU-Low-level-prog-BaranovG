#include "sw_timer.h"
#include <stdint.h>
#include <stddef.h>

#ifdef MAX_SOFT_TIMERS
#define MAX_TIMERS MAX_SOFT_TIMERS
#else
#define MAX_TIMERS 10
#endif

static sw_timer_t timers[MAX_TIMERS];
static uint32_t next_timer_id = 0;
static uint64_t current_time = 0;

// Чтение MTIME регистра
static inline uint64_t read_mtime(void) {
    uint32_t low, high;
    do {
        high = *(volatile uint32_t*)0x0200BFFC;
        low = *(volatile uint32_t*)0x0200BFF8;
    } while (high != *(volatile uint32_t*)0x0200BFFC);
    return ((uint64_t)high << 32) | low;
}

void sw_timer_init(void) {
    for (int i = 0; i < MAX_TIMERS; i++) {
        timers[i].active = 0;
    }
    current_time = read_mtime();
}

uint32_t sw_timer_add(uint32_t timeout, sw_timer_type_t type, void (*callback)(void)) {
    if (next_timer_id >= MAX_TIMERS) {
        return 0; // Ошибка: превышено максимальное количество таймеров
    }

    uint32_t timer_id = next_timer_id++;
    timers[timer_id].id = timer_id;
    timers[timer_id].timeout = current_time + timeout;
    timers[timer_id].period = timeout;
    timers[timer_id].type = type;
    timers[timer_id].active = 1;
    timers[timer_id].callback = callback;

    return timer_id;
}

int sw_timer_is_active(uint32_t timer_id) {
    if (timer_id >= MAX_TIMERS) {
        return 0;
    }
    return timers[timer_id].active;
}

void irq_handler(void) {
    // Читаем текущий MTIME
    current_time = read_mtime();

    // Обрабатываем все активные таймеры
    for (int i = 0; i < next_timer_id; i++) {
        if (!timers[i].active) continue;

        if (current_time >= timers[i].timeout) {
            // Вызываем callback
            if (timers[i].callback) {
                timers[i].callback();
            }

            // Обновляем состояние таймера в зависимости от типа
            switch (timers[i].type) {
                case SW_TIMER_ONESHOT:
                    timers[i].active = 0;
                    break;
                case SW_TIMER_MULTIPLE:
                    // Таймер остаётся активным, но не перезапускается
                    break;
                case SW_TIMER_PERIODIC:
                    // Перезапускаем периодический таймер
                    timers[i].timeout = current_time + timers[i].period;
                    break;
            }
        }
    }
}