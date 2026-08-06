#include "init_com1.h"
#include <stdint.h>
#define COM1 0x3F8
#define COM1_LSR (COM1 + 5)
#define COM1_FCR (COM1 + 2)
#define COM1_LCR (COM1 + 3)
#define COM1_MCR (COM1 + 4)

static inline void outb(unsigned short port, unsigned char val) {
  __asm__ volatile("outb %0, %w1" ::"a"(val), "Nd"(port));
}

static inline unsigned char inb(unsigned short port) {
  unsigned char ret;
  __asm__ volatile("inb %w1, %0" : "=a"(ret) : "Nd"(port));
  return ret;
}

void serial_configure() {
  outb(COM1 + 1, 0x00);
  outb(COM1_LCR, 0x80);
  outb(COM1 + 0, 0x03);
  outb(COM1 + 1, 0x00);
  outb(COM1_LCR, 0x03);
  outb(COM1_FCR, 0xC7);
  outb(COM1_MCR, 0x0B);
}

void serial_wait() {
  while ((inb(COM1_LSR) & 0x20) == 0)
    ;
}
void serial_write(char *byte) {
  while (*byte != '\0') {
    serial_wait();
    outb(COM1, *byte);
    byte++;
  }
}

void serial_write_hex_digit(uint8_t value) {
  serial_wait();
  uint8_t low4bit = value & 0x0F;
  uint8_t ascii_char;
  if (low4bit < 10)
    ascii_char = '0' + low4bit;
  else
    ascii_char = 'A' + (low4bit - 10);

  outb(COM1, ascii_char);
}

void serial_write_hex(uint8_t byte) {
  serial_write_hex_digit(byte >> 4);
  serial_write_hex_digit(byte);
}
void init_serial() { serial_configure(); }
