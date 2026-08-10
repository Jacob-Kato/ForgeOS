ASM = nasm
CC = x86_64-w64-mingw32-gcc
LD = ld

ASMFLAGS = -f win64 -g 
CFLAGS = -g -O0 -ffreestanding -c -Wall -Wextra

LDFLAGS = -m i386pep --subsystem 10 -shared -Bsymbolic -e efi_main

OUTPUT = BOOTX64.EFI

OBJS = boot.o kernel.o idtsetup.o initcom1.o main.o

all: $(OUTPUT)

$(OUTPUT): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(OUTPUT)

boot.o: boot/boot.nasm
	$(ASM) $(ASMFLAGS) $< -o $@

kernel.o: kernel/kernel.nasm
	$(ASM) $(ASMFLAGS) $< -o $@

idtsetup.o: kernel/idtsetup.c
	$(CC) $(CFLAGS) $< -o $@
	
initcom1.o: kernel/initcom1.c
	$(CC) $(CFLAGS) $< -o $@

main.o: kernel/main.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f *.o $(OUTPUT)
