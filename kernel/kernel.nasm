BITS 64
DEFAULT REL
%macro ISR_NOERRCODE 1
  global isr%1
  isr%1:
    push 0 
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
global kernel_main
global isr_stub_table

kernel_main:

  xor rcx, rcx
  div 1, rcx

  lidt [idtr_descriptor]
  sti

.main_loop:
  hlt
  jmp .main_loop

isr_common_stub:
  hlt
  jmp $

section .data
isr_stub_table:
%assign i 0
%rep 256
  dq isr%+i
%assign i i+1
%endrep

idt_table:
  times 256 dq 0,0 
idtr_descriptor:
  dw 4095                          
  dq idt_table                
