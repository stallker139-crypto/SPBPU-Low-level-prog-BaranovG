.section .text.start
.globl _start

_start:
    # Настройка PMP для ограничения доступа к MTIME/MTIMECMP только в M-моде
    li t0, 0xFFFFFFFF
    csrw pmpcfg0, t0
    li t1, 0x02000000  # Адрес MTIME
    addi t1, t1, -0x1000  # Выравнивание на 4KB
    csrw pmpaddr0, t1

    # Установка базового вектора прерываний
    la t0, trap_vector
    csrw mtvec, t0

    # Разрешение таймерных прерываний
    li t0, 1 << 7  # Бит таймерного прерывания
    csrs mie, t0

    # Включение прерываний
    csrs mstatus, 8  # MIE бит

    # Переход в U-мод через mret
    li a0, 0  # Код возврата
    mv a1, sp  # Указатель стека
    li a2, 0x80000000  # Флаг перехода в U-мод
    mret

.section .text.trap
trap_vector:
    # Сохраняем контекст
    addi sp, sp, -32
    sd x1, 24(sp)
    sd x2, 16(sp)
    sd x3, 8(sp)
    sd x4, 0(sp)

    # Вызов обработчика прерываний
    call irq_handler

    # Восстанавливаем контекст
    ld x1, 24(sp)
    ld x2, 16(sp)
    ld x3, 8(sp)
    ld x4, 0(sp)
    addi sp, sp, 32

    mret