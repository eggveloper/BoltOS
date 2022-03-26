#ifndef CORE_ISR_H
#define CORE_ISR_H

#include <core/idt.h>
#include <stdint.h>

#define PIC1      0x20                    // Master PIC
#define PIC2      0xA0                    // Slave PIC
#define PIC1_DATA (PIC1 + 1)
#define PIC2_DATA (PIC2 + 1)
#define PIC_EOI   0x20                    // end of interrupt
#define IRQ_BASE  0x20

#define IRQ0 32
#define IRQ1 33
#define IRQ2 34
#define IRQ3 35
#define IRQ4 36

// These functions are declared in interrupt.asm file

extern void isr0();
extern void isr1();
extern void isr2();
extern void isr3();
extern void isr4();
extern void isr5();
extern void isr6();
extern void isr7();
extern void isr8();
extern void isr9();
extern void isr10();
extern void isr11();
extern void isr12();
extern void isr13();
extern void isr14();
extern void isr15();
extern void isr16();
extern void isr17();
extern void isr18();
extern void isr19();
extern void isr20();
extern void isr21();
extern void isr22();
extern void isr23();
extern void isr24();
extern void isr25();
extern void isr26();
extern void isr27();
extern void isr28();
extern void isr29();
extern void isr30();
extern void isr31();

extern void irq0();
extern void irq1();
extern void irq2();
extern void irq3();
extern void irq4();

typedef void (*isr_t)(uint64_t stack);

typedef struct registers {
    uint32_t ds;
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
    uint32_t int_no, err_code;
    uint32_t eip, cs, eflags, useresp, ss;
} registers_t;

void isr_init();
void irq_init();
void isr_handler(uint64_t id, uint64_t stack) __asm__("isr_handler");
void irq_handler(uint64_t id, uint64_t stack) __asm__("irq_handler");
void register_interrupt_handler(uint64_t id, isr_t handler);

#endif
