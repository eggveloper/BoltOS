#include <stdint.h>
#include <drivers/screen.h>
#include "kmain.h"

void kmain(void) {
    uint16_t* vga = (uint16_t*)0xB8000;
    uint8_t scheme = new_scheme(COLOR_WHITE, COLOR_BLACK);

    vga[0] = vga_print('H', scheme);
    vga[1] = vga_print('e', scheme);
    vga[2] = vga_print('l', scheme);
    vga[3] = vga_print('l', scheme);
    vga[4] = vga_print('o', scheme);
}
