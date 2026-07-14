BITS 64 
;this tells the NASM assembler to generate 64-bit machine code.
;since UEFI firmware boots the processor in 640bit long mode by default
;unlike old BIOS systems which started in 16 bit mode everything i write 
;must be in 64 bit


DEFAULT REL
;this tells the assembler to use the RIP-Relative addressing by default
;ensuring my code is Position independent and 
;can run no matter where UEFI loads it in memory


section .text
;this tells the assembler that everything below 
;this line is executable code not data or variables.

global efi_main
;this exports the label efi_main so the linker can 
;find it and tell the UEFI firmware exactly where our program begins

efi_main:
  push rbp     ;this saves the base pointer to preserve the firmware
  mov rbp,rsp  ;this gives the os a fixed reference point for its local variables
  sub rsp,48   ;this allocates exactly 48 bytes of empty space on the stack to 
               ;guarantee the 32 byte shadow space and 16 byte alignment rules are met 

  mov [img_handle], rcx ;this copies them in to RAM so they don't get over writen 
  mov [sys_table], rdx

  mov rsi, [rdx + OFFSET_BOOT_SERVICES] ;this finds the boot services pointer and moves it to rsi 
  mov [boot_services], rsi 
  
  ; this moves the boot services pointer to RAM at boot_services
.retry_map:
  lea rcx, [mem_map_size]    ;this tells UEFI how big my buffer is 
  lea rdx, [mem_map_buffer]  ;this is the massive empty space where UEFI will write the memory map 
  lea r8, [mem_map_key]      ;this is where UEFI will drop the password
  lea r9, [mem_descr_size]   ;UEFI will fill this with the size of each individual entry in the map 
  lea rax, [mem_descr_ver]
  mov [rsp + 32],rax 
  call [OFFSET_GET_MEMORY_MAP + rsi]
  test rax, rax 
  jz .map_success

  jmp .retry_map

.map_success:
  mov rcx, [img_handle]
  mov rdx, [mem_map_key]
  call [OFFSET_EXIT_BOOT_SERV + rsi]

  cli

halt:
  hlt
  jmp halt

section .data
  OFFSET_BOOT_SERVICES equ 96
  OFFSET_GET_MEMORY_MAP equ 56
  OFFSET_EXIT_BOOT_SERV equ 24 

section .bss 
  img_handle     resq 1
  sys_table      resq 1
  boot_services  resq 1

  mem_map_size   resq 1
  mem_map_key    resq 1
  mem_descr_size resq 1
  mem_descr_ver  resq 1
  mem_map_buffer resq 4096 


