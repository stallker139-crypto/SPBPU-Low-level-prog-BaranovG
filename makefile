# Компилятор RISC-V
CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy

# Параметры компиляции
CFLAGS = -march=rv32imac -mabi=ilp32 -O2 \
         -ffunction-sections -fdata-sections \
         -DMAX_SOFT_TIMERS=10
LDFLAGS = -T linker.ld -nostdlib -Wl,--gc-sections

# Файлы проекта
SOURCES = start.S sw_timer.c main.c
OBJECTS = $(SOURCES:.c=.o)
TARGET = firmware.elf

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJECTS) $(TARGET) firmware.bin

firmware.bin: $(TARGET)
	$(OBJCOPY) -O binary $(TARGET) $@