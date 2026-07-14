BITS 64           ;sense i'm using UEFI instead of BIOS the cpu is alread in 64 bit mode 
DEFAULT REL       ;this sets the default to REL that means the assembler will auto use RIP

;UEFI Table Offsets
OFFSET_BOOT_SERVICES equ 96    ;this says that BootServicess table pointer is located exactly 96 bytes away from the start of the UEFI system table

OFFSET_GET_MEMORY_MAP equ 56   ;this means that inside the efi_boot_services table, the function pointer to fetch the system's memory map is at exactly 56 bytes away from the start of that table

OFFSET_EXIT_BOOT_SERV equ 232  ;this is says the function pointer to shut down UEFI boot services is exactly 232 bytes away from the start of that table

section .text    ;this tells the assembler that it is reading the code part of my program
global efi_main  ;makes the function public

efi_main:          
    push rbp       ;push rbp saves the firmware's state
    mov rbp, rsp   ;this copies the current value of rsp into rbp, it creates a fixed anchor point for the function
    sub rsp, 48    ;by subtracthing 48 from the stack pointer, im taking 48 bytes of empty space on the stack
    
    mov [img_handle], rcx ; saves UEFI image handle at rcx
    mov [sys_table], rdx  ; saves UEFI system table 

    ;Get the memory map (Mandatory proof-of state befro exit)
    lea rcx, [mem_map_size]
    lea rdx, [mem_map_buffer]
    lea r8, [mem_map_key]      ;why use lea instead of mov; in 64 bit UEFI program the firmware loads my bootloader into a random spot in memory every time
    lea r9, [mem_descr_size]   ;this mean i could not hardcode the exact memory addresses. i have to write Position Independent Code (PIC)
    lea rax, [mem_descr_ver]   ;
    mov [rsp + 32], rax
    call [rsi + OFFSET_GET_MEMORY_MAP]

    ;Check if exit was successful
    test rax, rax
    jnz .failed

; the handoff 

    jmp ForgeOS_main

.failed:
    cli
    hlt
    jmp .failed

; ForgeOS 
ForgeOS_main:
    cli            ;Clear interrupts; my kernel will handle it 


    ;Initialize the serial port hardware (COM1 Base = 0x3F8)
    mov dx, 0x3F9 ; interrupt Enable register
    xor al, al 
    out dx, al    ;Disable all serial interrupts

    mov dx, 0x3FB ;Line control register
    mov al, 0x03  ;8 bits, no parity, 1 stop bit
    out dx, al 

    lea rsi, [kernel_msg]  ;Load message address
.print_loop:     
    lodsb                  ;read next character into AL
    or al, al              ;is it the null terminator(0)
    jz .kernel_halt        ;if yes, finish printing

    mov dx, ox3F8          ;COM1 Data port
    out dx, al             ;Send character straight to serial hardware
    jmp .print_loop        ;

.kernel_halt:
    hlt                    ;halt the cpu processor core safely
    jmp .kernel_halt

; data
section .data
img_handle:     dq 0 
sys_table:      dq 0
boot_services:  dq 0

mem_map_size:   dq 4096
mem_map_key:    dq 0
mem_descr_size: dq 0
mem_descr_ver:  dq 0

kernel_msg:     db "--ForgeOS--". 0x0D, 0x0A, 0 

section .bss 
align 16
mem_map_buffer: resb 4096
