#ifndef SERIAL_H
#define SERIAL_H

#define COM1 0x3F8

void serial_configure(void);
void serial_wait(void);
void serial_write(char *byte);
void init_serial();
#endif // !SERIAL_H
