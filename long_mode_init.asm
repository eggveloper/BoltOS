global long_mode_start
extern kmain

section .text
bits 64

long_mode_start:
    call kmain

    ; Should not be reached
    hlt
