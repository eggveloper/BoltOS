section .multiboot_header

%define MULTIBOOT_HEADER_MAGIC 0xe85250d6
%define MULTIBOOT_HEADER_FLAGS 0

header_start:
    dd MULTIBOOT_HEADER_MAGIC               ; magic
    dd MULTIBOOT_HEADER_FLAGS               ; protected mode code
    dd header_end - header_start            ; header length

    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; required end tag
    dw 0                                    ; type
    dw 0                                    ; flags
    dd 8                                    ; size
header_end:
