section .multiboot_header

%define MULTIBOOT_MAGIC_NUMBER 0xe85250d6
%define MULTIBOOT_MODE_CODE 0

header_start:
    dd MULTIBOOT_MAGIC_NUMBER               ; magic
    dd MULTIBOOT_MODE_CODE                  ; protected mode code
    dd header_end - header_start            ; header length

    ; checksum
    dd 0x100000000 - (MULTIBOOT_MAGIC_NUMBER + 0 + (header_end - header_start))

    ; required end tag
    dw 0                                    ; type
    dw 0                                    ; flags
    dd 8                                    ; size
header_end:
