#include "init_com1.h"
#include <stddef.h>
#include <stdint.h>

struct idt_entry {
  uint16_t offset_low;
  uint16_t selector;
  uint8_t ist;
  uint8_t type_attr;
  uint16_t offset_mid;
  uint32_t offset_high;
  uint32_t reserved;
};

struct interrupt_frame {
  uint64_t RAX;
  uint64_t RBX;
  uint64_t RCX;
  uint64_t RDX;
  uint64_t RSI;
  uint64_t RDI;
  uint64_t RBP;
  uint64_t R8;
  uint64_t R9;
  uint64_t R10;
  uint64_t R11;
  uint64_t R12;
  uint64_t R13;
  uint64_t R14;
  uint64_t R15;
  uint64_t Vector;
  uint64_t Error_Code;
  uint64_t RIP;
  uint64_t CS;
  uint64_t RFLAGS;
};
extern struct idt_entry idt_table[256];
extern void *isr_stub_table[256];

void idt_set_gate(int vector, void *handler) {
  uintptr_t addr = (uintptr_t)handler;
  idt_table[vector].offset_low = addr & 0xFFFF;
  idt_table[vector].selector = 0x08;
  idt_table[vector].ist = 0;
  idt_table[vector].type_attr = 0x8E;
  idt_table[vector].offset_mid = (addr >> 16) & 0xFFFF;
  idt_table[vector].offset_high = (addr >> 32) & 0xFFFFFFFF;
  idt_table[vector].reserved = 0;
}

void exception_handler(struct interrupt_frame *frame) {
  switch (frame->Vector) {
  case 0:
    serial_write_byte('A');
    break;
  case 6:
    break;
  case 13:
    break;
  case 14:
    break;
  default:
    break;
  }
  while (1) {
    __asm__ volatile("hlt");
  }
}

void idt_init(void) {
  for (int i = 0; i < 256; i++) {
    idt_set_gate(i, isr_stub_table[i]);
  }
}

void kernel_main(void) {
  init_serial();
  idt_init();
  serial_write_byte('X');
  while (1) {
    __asm__ volatile("hlt");
  }
}
