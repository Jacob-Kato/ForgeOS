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


