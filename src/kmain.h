#ifndef KMAIN_H
#define KMAIN_H

#define KERNEL_NAME    "Bolt"
#define KERNEL_VERSION "0.0.1a"
#define KERNEL_DATE     __DATE__
#define KERNEL_TIME     __TIME__

void kmain(void) __asm__("kmain");

#endif
