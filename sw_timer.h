#ifndef SW_TIMER_H
#define SW_TIMER_H

#include <stdint.h>

// Типы таймеров
typedef enum {
    SW_TIMER_ONESHOT,    // Одиночный таймер
    SW_TIMER_MULTIPLE,   // Множественный таймер
    SW_TIMER_PERIODIC    // Периодический таймер
} sw_timer_type_t;

// Структура таймера
typedef struct {
    uint32_t id;
    uint32_t timeout;      // Время срабатывания (тики)
    uint32_t period;       // Период для периодических таймеров
    sw_timer_type_t type;
    int active;
    void (*callback)(void);
} sw_timer_t;

// API функций
void sw_timer_init(void);
uint32_t sw_timer_add(uint32_t timeout, sw_timer_type_t type, void (*callback)(void));
int sw_timer_is_active(uint32_t timer_id);
void irq_handler(void);

#endif // SW_TIMER_H