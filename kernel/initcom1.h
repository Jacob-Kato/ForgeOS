#ifndef SERIAL_H
#define SERIAL_H
#define COM1 0x3F8
#include <stdint.h>

void serial_configure(void);
void serial_wait(void);
void serial_write(const char *byte);
void serial_write_hex_digit(const uint8_t value);
void serial_write_hex_8(const uint8_t byte);
void serial_write_hex_16(const uint16_t byte);
void serial_write_hex_32(const uint32_t byte);
void serial_write_hex_64(const uint64_t byte);
void init_serial();

#endif // !SERIAL_H
