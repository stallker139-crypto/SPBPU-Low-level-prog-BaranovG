ENTRY(_start)

MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 16M
}

SECTIONS {
    .text : {
        *(.text.start)
        *(.text*)
    } > RAM

    .data : {
        *(.data*)
    } > RAM

    .bss : {
        *(COMMON)
        *(.bss*)
    } > RAM
}