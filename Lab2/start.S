#include "riscv.h"

#if __riscv_xlen == 64
# define LREG         ld
# define SREG         sd
# define REGBYTES     8
#else
# define LREG         lw
# define SREG         sw
# define REGBYTES     4
#endif

.global _start
.global trap_vector

_start:
    # Инициализация глобального указателя (gp)
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    # Установка стека
    la sp, stack_top

    # Проверка ID ядра: если не 0, переходим в park
    csrr t0, mhartid
    bnez t0, park

    # Разрешение прерываний таймера
    li t0, (1 << 7)          # MIE_MTIE = 0x80 (бит 7)
    csrw mie, t0

    # Включение глобальных прерываний
    li t0, (1 << 3)          # MSTATUS_MIE = 0x8 (бит 3)
    csrs mstatus, t0

    # Настройка PMP (Physical Memory Protection)
    li t0, -1
    csrw pmpaddr0, t0
    li t0, 0x1F
    csrw pmpcfg0, t0

    # Установка вектора прерываний (режим прямого отображения)
    la t0, trap_vector
    csrw mtvec, t0

    # Переход к основной программе
    j main

park:
    wfi                    # Ожидание прерывания
    j park               # Бесконечный цикл для неактивных ядер

trap_vector:
    # Сохраняем регистры в стеке (32 регистра × размер слова)
    addi sp, sp, -32*REGBYTES
    SREG x1, 1*REGBYTES(sp)
    SREG x2, 2*REGBYTES(sp)
    SREG x3, 3*REGBYTES(sp)
    SREG x4, 4*REGBYTES(sp)
    SREG x5, 5*REGBYTES(sp)
    SREG x6, 6*REGBYTES(sp)
    SREG x7, 7*REGBYTES(sp)
    SREG x8, 8*REGBYTES(sp)
    SREG x9, 9*REGBYTES(sp)
    SREG x10, 10*REGBYTES(sp)
    SREG x11, 11*REGBYTES(sp)
    SREG x12, 12*REGBYTES(sp)
    SREG x13, 13*REGBYTES(sp)
    SREG x14, 14*REGBYTES(sp)
    SREG x15, 15*REGBYTES(sp)
    SREG x16, 16*REGBYTES(sp)
    SREG x17, 17*REGBYTES(sp)
    SREG x18, 18*REGBYTES(sp)
    SREG x19, 19*REGBYTES(sp)
    SREG x20, 20*REGBYTES(sp)
    SREG x21, 21*REGBYTES(sp)
    SREG x22, 22*REGBYTES(sp)
    SREG x23, 23*REGBYTES(sp)
    SREG x24, 24*REGBYTES(sp)
    SREG x25, 25*REGBYTES(sp)
    SREG x26, 26*REGBYTES(sp)
    SREG x27, 27*REGBYTES(sp)
    SREG x28, 28*REGBYTES(sp)
    SREG x29, 29*REGBYTES(sp)
    SREG x30, 30*REGBYTES(sp)
    SREG x31, 31*REGBYTES(sp)

    # Получаем причину прерывания и адрес возврата
    csrr a0, mcause
    csrr a1, mepc

    # Проверяем, прерывание это или исключение
    andi a0, a0, 0x80000000
    beq a0, zero, handle_exception

    # Извлекаем номер причины прерывания
    andi a0, a0, 0x7FF

    # Обработчик прерывания таймера
    li t0, MCAUSE_MTIMER
    beq a0, t0, handle_timer_irq

    # Обработчики ECALL (системных вызовов)
    li t0, ECALL_UART_PUTCHAR
    beq a0, t0, handle_uart_ecall

    li t0, ECALL_ENABLE_TIMER
    beq a0, t0, handle_timer_ecall

    j unknown_handler

handle_timer_irq:
    # Отключаем прерывания таймера на время обработки
    li t0, ~(1 << 7)
    csrw mie, t0
    jal x1, handle_timer
    csrw mepc, a1
    j restore_regs

handle_uart_ecall:
    jal x1, uart_putchar
    csrw mepc, a1
    j restore_regs

handle_timer_ecall:
    jal x1, enable_timer
    csrw mepc, a1
    j restore_regs

handle_exception:
    j handle_exception_routine

unknown_handler:
    j unknown_handler_routine

restore_regs:
    # Восстанавливаем регистры из стека
    LREG x1, 1*REGBYTES(sp)
    LREG x2, 2*REGBYTES(sp)
    LREG x3, 3*REGBYTES(sp)
    LREG x4, 4*REGBYTES(sp)
    LREG x5, 5*REGBYTES(sp)
    LREG x6, 6*REGBYTES(sp)
    LREG x7, 7*REGBYTES(sp)
    LREG x8, 8*REGBYTES(sp)
    LREG x9, 9*REGBYTES(sp)
    LREG x10, 10*REGBYTES(sp)
    LREG x11, 11*REGBYTES(sp)
    LREG x12, 12*REGBYTES(sp)
    LREG x13, 13*REGBYTES(sp)
    LREG x14, 14*REGBYTES(sp)
    LREG x15, 15*REGBYTES(sp)
    LREG x16, 16*REGBYTES(sp)
    LREG x17, 17*REGBYTES(sp)
    LREG x18, 18*REGBYTES(sp)
    LREG x19, 19*REGBYTES(sp)
    LREG x20, 20*REGBYTES(sp)
    LREG x21, 21*REGBYTES(sp)
    LREG x22, 22*REGBYTES(sp)
    LREG x23, 23*REGBYTES(sp)
    LREG x24, 24*REGBYTES(sp)
    LREG x25, 25*REGBYTES(sp)
    LREG x26, 26*REGBYTES(sp)
    LREG x27, 27*REGBYTES(sp)
    LREG x28, 28*REGBYTES(sp)
    LREG x29, 29*REGBYTES(sp)
    LREG x30, 30*REGBYTES(sp)
    LREG x31, 31*REGBYTES(sp)

    # Восстанавливаем указатель стека
    addi sp, sp, 32*REGBYTES

    # Возвращаемся из прерывания
    mret

handle_exception_routine:
    # Заглушка для обработки исключений
    # В реальной системе здесь должна быть детальная обработка
    j restore_regs

unknown_handler_routine:
    # Обработка неизвестных прерываний/исключений
    # Можно добавить логирование или перезагрузку
    j restore_regs

# Секция данных и стека
.section .bss
.align 3
stack_bottom:
    .space 4096  # 4 KB стека
stack_top:

# Символ для глобального указателя
.global __global_pointer$
__global_pointer$ = . + 0x800