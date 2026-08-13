#include "initcom1.h"
#include <stddef.h>
#include <stdint.h>
#define kernel_cs 0x38
#define total_vector 256
#define gate_type 0x8E
#define div_by0 0
#define invalid_opcode 6
#define MSR_fault 13

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
  uint64_t CR2;
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
  uint64_t RSP;
  uint64_t SS;
};

extern struct idt_entry idt_table[total_vector];
extern void *isr_stub_table[total_vector];

void idt_set_gate(int vector, void *handler) {
  uintptr_t addr = (uintptr_t)handler;
  idt_table[vector].offset_low = addr & 0xFFFF;
  idt_table[vector].selector = kernel_cs;
  idt_table[vector].ist = 0;
  idt_table[vector].type_attr = gate_type;
  idt_table[vector].offset_mid = (addr >> 16) & 0xFFFF;
  idt_table[vector].offset_high = (addr >> 32) & 0xFFFFFFFF;
  idt_table[vector].reserved = 0;
}

void base_register_write(const struct interrupt_frame *frame) {
  serial_write("\n");
  serial_write("Vector: ");
  serial_write_hex_64(frame->Vector);
  serial_write("\n");
  serial_write("Error Code: ");
  serial_write_hex_64(frame->Error_Code);
  serial_write("\n");
  serial_write("RIP: ");
  serial_write_hex_64(frame->RIP);
  serial_write("\n");
  serial_write("RFLAGS: ");
  serial_write_hex_64(frame->RFLAGS);
  serial_write("\n");
}

void explicit_instruction_error(struct interrupt_frame *frame) {
  base_register_write(frame);
  frame->RFLAGS |= 0x1ULL;
  frame->RIP += 2;
}
void general_protection_error(struct interrupt_frame *frame) {
  base_register_write(frame);
  const uint16_t RDMSR = 0x320F;
  const uint16_t WRMSR = 0x300F;
  const uint64_t CARRY_FLAG_MASK = 0x1ULL;
  const uint64_t ERROR_STATUS_CODE = 0xFFFFFFFFFFFFFFFFULL;
  const uint8_t MSR_INSTRUCTION_SIZE = 2;

  uint16_t *opcode = (uint16_t *)frame->RIP;
  if (*opcode == RDMSR || *opcode == WRMSR) {
    frame->RAX = 0;
    frame->RFLAGS &= ~CARRY_FLAG_MASK;
    frame->RIP += MSR_INSTRUCTION_SIZE;
    return;
  }

  frame->RAX = ERROR_STATUS_CODE;
  frame->RFLAGS |= CARRY_FLAG_MASK;
  frame->RIP += MSR_INSTRUCTION_SIZE;
}

void exception_handler(struct interrupt_frame *frame) {
  switch (frame->Vector) {
  case div_by0:
    base_register_write(frame);
    while (1) {
      __asm__ __volatile__("hlt");
    }
    break;
  case invalid_opcode:
    explicit_instruction_error(frame);
    break;
  case MSR_fault:
    serial_write("MSR_fault");
    general_protection_error(frame);
    break;
  case 14:
    break;
  default:
    base_register_write(frame);
    break;
  }
}

void idt_init(void) {
  for (int i = 0; i < total_vector; i++) {
    idt_set_gate(i, isr_stub_table[i]);
  }
}

void kernel_main(void) {
  init_serial();
  idt_init();
  serial_write("kernel_main\n");
}
