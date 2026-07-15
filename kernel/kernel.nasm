  %macro save_state 0 
    push rax
    push rbx
    push rcx
    push rdx
    push rbp
    push rsi
    push rdi
    push r8
    push r9 
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
  %endmacro


  %macro load_state 0 
    pop  r15
    pop  r14
    pop  r13
    pop  r12
    pop  r11
    pop  r10
    pop  r9 
    pop  r8
    pop  rdi
    pop  rsi
    pop  rbp
    pop  rdx
    pop  rcx
    pop  rbx
    pop rax
  %endmacro




section .text 

global div_error_handler
global kernel_main

kernel_main:
  lidt [idtr_descriptor]
  sti
.main_loop:
  hlt
  jmp .main_loop

div_error_handler:
  save_state

  cli
.panic:
  hlt
  jmp .panic

  load_state
  iretq 

section .data

idt_table:
  dw (div_error_handler & 0xFFFF)
  dw 0x08
  db 0
  db 0x8E
  dw ((div_error_handler >> 16) & 0xFFFF)
  dd (div_error_handler >> 32)
  dd 0

idtr_descriptor:
  dw 15
  dq idt_table
