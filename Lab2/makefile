CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OBJCOPY = riscv64-unknown-elf-objcopy

# Флаги компиляции с поддержкой необходимых расширений
CFLAGS = -march=rv64ima -mabi=lp64 -O2 -nostdlib -nostartfiles -ffreestanding
ASFLAGS = -march=rv64ima
LDFLAGS = -T link.ld

TARGET = kernel
SOURCES = start.S main.c
OBJECTS = $(SOURCES:.c=.o) $(SOURCES:.S=.o)

all: $(TARGET).elf

$(TARGET).elf: $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f *.o *.elf

.PHONY: all clean