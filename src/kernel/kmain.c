#include "kmain.h"
#include <core/isr.h>
#include <core/timer.h>
#include <core/debug.h>
#include <core/check.h>
#include <core/cmos.h>
#include <mmu/mmu.h>
#include <kernel/panic.h>
#include <drivers/screen.h>
#include <drivers/serial.h>
#include <drivers/keyboard.h>
#include <stdio.h>

void print_welcome_message() {
    printf("%s\n", KERNEL_ASCII);
    printf("%s %s / Built on: %s at %s\n\n", KERNEL_NAME, KERNEL_VERSION, KERNEL_DATE, KERNEL_TIME);
}

void kmain(unsigned long magic, unsigned long addr) {
    screen_init();
    screen_clear();

    if (multiboot_is_valid(magic, addr) == false) {
        PANIC("invalid multiboot");

        return;
    }

    multiboot_info_t* mbi = (multiboot_info_t*)addr;
    reserved_areas_t reserved = read_multiboot_info(mbi);

    print_welcome_message();

#ifdef ENABLE_KERNEL_DEBUG
    printf("multiboot_start = 0x%X, multiboot_end = 0x%X\n", reserved.multiboot_start, reserved.multiboot_end);
    printf("kernel_start    = 0x%X, kernel_end    = 0x%X\n", reserved.kernel_start, reserved.kernel_end);
#endif

    isr_init();
    irq_init();
    printf("Interrupts enabled.\n");

    timer_init(50); // 50 Hz
    printf("Scheduler (timer) enabled.\n");

    // Self-checks
    check_interrupts();

    serial_init(SERIAL_COM1, SERIAL_SPEED_115200);
    printf("Initialized serial 0x%X.\n", SERIAL_COM1);

    keyboard_init();
    printf("Keyboard driver enabled.\n");

    // Memory
    multiboot_tag_mmap_t* mmap = find_multiboot_tag(mbi->tags, MULTIBOOT_TAG_TYPE_MMAP);

    mmap_init(mmap, reserved);
    paging_init();
    printf("Frame allocator and paging enabled.\n");

    cmos_rtc_t rtc = cmos_read_rtc();
    printf(
        "\nToday is %2d/%2d/%2d %2d:%2d:%2d UTC\n",
        rtc.year, rtc.month, rtc.day,
        rtc.hours, rtc.minutes, rtc.seconds
    );

    printf("$ ");

    while (1) {
        __asm__("hlt");
    }
}
