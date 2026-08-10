BITS 64  
DEFAULT REL
%define skip_bytes 16 
%define total_vector 256 
%define descriptor_size 4095
%define kernel_size 16384
%define COM1 0x3F8

%macro write_byte 1
  mov dx, COM1
  mov al, %1
  out dx, al
%endmacro

%macro PUSHA 0 
  push r15
  push r14
  push r13
  push r12
  push r11
  push r10
  push r9
  push r8
  push rbp
  push rdi
  push rsi
  push rdx
  push rcx
  push rbx
  push rax
%endmacro

%macro POPA 0
  pop rax
  pop rbx
  pop rcx
  pop rdx
  pop rsi
  pop rdi
  pop rbp
  pop r8
  pop r9
  pop r10
  pop r11
  pop r12
  pop r13
  pop r14
  pop r15
%endmacro

%macro ISR_NOERRCODE 1
  global isr%1
  isr%1:
    push %1
    push %1
    jmp isr_common_stub
%endmacro

%macro ISR_ERRCODE 1
  global isr%1
  isr%1:
    push %1
    jmp isr_common_stub
%endmacro

ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE 8
ISR_NOERRCODE 9
ISR_ERRCODE 10 
ISR_ERRCODE 11 
ISR_ERRCODE 12
ISR_ERRCODE 13 
ISR_ERRCODE 14 
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_ERRCODE 17 
ISR_NOERRCODE 18
ISR_NOERRCODE 19 
ISR_NOERRCODE 20 
ISR_ERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_ERRCODE 29
ISR_ERRCODE 30
ISR_NOERRCODE 31



%assign i 32
%rep 224
  ISR_NOERRCODE i
%assign i i+1
%endrep


section .text 

global isr_common_stub
global _start
global isr_stub_table
global idt_table
global error_test
global main_loop
extern kernel_main
extern exception_handler
extern main_c 
_start:
  mov rsp, kernel_stack_top
  call kernel_main
  lidt [idtr_descriptor]
  
  sti


error_test:
write_byte 'e'
  clc
  mov rax, 0xAAAAAAAAAAAAAAAA
  mov rbx, 0xBBBBBBBBBBBBBBBB
  mov rcx, 0xDEADBEEF
  xor rdx, rdx
  wrmsr


call main_c 

isr_common_stub:
  write_byte 'c'

  PUSHA
  mov rax, cr2
  push rax
  mov rcx,rsp

  call exception_handler
  pop rax
  POPA
  add rsp,skip_bytes
  iretq 

  hlt
  call main_c 

section .data

isr_stub_table:
%assign i 0
%rep total_vector
  dq isr%+i
%assign i i+1
%endrep

idt_table:
  times total_vector  dq 0,0 
idtr_descriptor:
  dw descriptor_size
  dq idt_table
  


section .bss
align 16
  	
kernel_stack:
	resb kernel_size
	
kernel_stack_top:
