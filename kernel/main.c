#include "initcom1.h"
#include <stddef.h>
#include <stdint.h>
void main_c(void) {
  while (1) {
    serial_write("\n-Forge OS-\n");
    __asm__ __volatile__("hlt");
  }
}
