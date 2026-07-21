BITS 64
DEFAULT REL
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

  lea rax, [div_error_handler]     

  mov [idt_table], ax            

  shr rax, 16                   
  mov [idt_table + 6], ax        

  shr rax, 16                   
  mov [idt_table + 8], eax

  lea rax, [keyborad_handler]

  mov [idt_table + 16], ax
  shr rax, 16
  mov [main_loop]

  lidt [idtr_descriptor]
  sti

.main_loop:
  hlt
  jmp .main_loop

keyborad_handler:
  save_state

  in al, 0x60
  mov [last_key], al
  mov al, 0x20
  out 0x20, al

  load_state
  iretq

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
  times 256 dq 0,0 
idtr_descriptor:
  dw 4095                          
  dq idt_table                
