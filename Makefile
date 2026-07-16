ASM = nasm 
ASMFLAGS = -f win64
LD = ld 
LDFLAGS = -m i386pep -T linker/linker.ld --subsystem 10 

OUTPUT = BOOTX64.EFI 
OBJS boot.o kernel.o 

all: $(OUTPUT)

$(OUTPUT): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(OUTPUT)

boot.o: boot/boot.nasm
	$(ASM) $(ASMFLAGS) boot/boot.nasm -o boot.o

kernel.o: kernel/kernel.nasm
	$(ASM) $(ASMFLAGS) kernel/kernel.nasm -o kernel.o 
	
clean:
	rm -f *.o $(OUTPUT)

