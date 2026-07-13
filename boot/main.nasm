BITS 64           ;sense i'm using UEFI instead of BIOS the cpu is alread in 64 bit mode 
DEFAULT REL       ;this sets the default to REL that means the assembler will auto use RIP

;UEFI Table Offsets
OFFSET_BOOT_SERVICES equ 96    ;this says that BootServicess table pointer is located exactly 96 bytes away from the start of the UEFI system table

OFFSET_GET_MEMORY_MAP equ 56   ;this means that inside the efi_boot_services table, the function pointer to fetch the system's memory map is at exactly 56 bytes away from the start of that table

OFFSET_EXIT_BOOT_SERV equ 232  ;this is says the function pointer to shut down UEFI boot services is exactly 232 bytes away from the start of that table

section .text    ;this tells the assembler that it is reading the code part of my program
global efi_main


