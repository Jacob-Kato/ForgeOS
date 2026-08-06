#ifndef SERIAL_H
#define SERIAL_H
#define COM1 0x3F8
#include <stdint.h>

void serial_configure(void);
void serial_wait(void);
void serial_write(char *byte);
void serial_write_hex_digit(uint8_t value);
void serial_write_hex(uint8_t byte);
void init_serial();

#endif // !SERIAL_H
