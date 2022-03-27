#include <core/isr.h>
#include <core/timer.h>
#include <core/debug.h>
#include <mmu/mmap.h>
#include <mmu/paging.h>
#include <drivers/screen.h>
#include <drivers/serial.h>
#include <drivers/keyboard.h>
#include <stdio.h>
#include "kmain.h"

void kmain(unsigned long magic, unsigned long addr) {
    screen_init();
    screen_clear();

    if (multiboot_is_valid(magic, addr) != 0) {
        printf("\nsystem halted");

        return;
    }

    multiboot_info_t* mbi = (multiboot_info_t*)addr;
    reserved_areas_t reserved = read_multiboot_info(mbi);

    printf("%s\n", KERNEL_ASCII);
    printf("%s %s / Built on: %s at %s\n\n", KERNEL_NAME, KERNEL_VERSION, KERNEL_DATE, KERNEL_TIME);

    printf("multiboot_start = 0x%X, multiboot_end = 0x%X\n", reserved.multiboot_start, reserved.multiboot_end);
    printf("kernel_start = 0x%X, kernel_end = 0x%X\n", reserved.kernel_start, reserved.kernel_end);

    isr_init();
    irq_init();
    printf("Interrupts enabled.\n");

    timer_init(50);
    printf("Scheduler (timer) enabled.\n");

    serial_init(SERIAL_COM1, SERIAL_SPEED_115200);

    DEBUG("%s has started!", KERNEL_NAME);

    keyboard_init();
    printf("Keyboard driver enabled.\n");

    // Memory
    multiboot_tag_mmap_t* mmap = find_multiboot_tag(mbi->tags, MULTIBOOT_TAG_TYPE_MMAP);

    mmap_init(mmap, reserved);
    paging_init();
    printf("Frame allocator and paging enabled.\n");

    printf("Bolt has been loaded. Welcome!\n$ ");

    while (1) {
        __asm__("hlt");
    }
}
