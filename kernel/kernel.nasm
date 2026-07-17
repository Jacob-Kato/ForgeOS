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

  mov rax, div_error_handler     

  mov [idt_table], ax            

  shr rax, 16                   
  mov [idt_table + 6], ax        

  shr rax, 16                   
  mov [idt_table + 8], eax       


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
  dw 0x0000                      
  dw 0x0008                      
  db 0                           
  db 0x8E                        
  dw 0x0000                      
  dd 0x00000000                  
  dd 0x00000000                 

idtr_descriptor:
  dw 15                          
  dq idt_table                
