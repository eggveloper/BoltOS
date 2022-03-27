extern long_mode_start
global start

section .text
bits 32
start:
    mov esp, stack_top

    ; ebx points to a boot information structure
    ; We move it to esi to pass it to our kernel
    mov esi, ebx

    ; eax should contain multiboot2 magic number
    mov edi, eax

    call check_multiboot
    call check_cpuid
    call check_long_mode

    call set_up_page_tables
    call enable_paging

    lgdt [gdt64.pointer]

    jmp gdt64.code:long_mode_start

    ; Should not be reached
    hlt

check_multiboot:
    cmp eax, 0x36d76289
    jne .no_multiboot
    ret

.no_multiboot:
    mov al, "0"
    jmp error

check_cpuid:
    ; Check if the CPUID is supported by attempting to flip the ID bit
    ; in the FLAGS register. If we can flip it, CPUID is available

    ; Copy FLAGS in eax via stack
    pushfd
    pop eax

    ; Copy to ecx as well for comparing later on
    mov ecx, eax

    ; Flip the ID bit
    xor eax, 1 << 21

    ; Copy eax to FLAGS via the stack
    push eax
    popfd

    ; Copy FLAGS back to eax (with the flipped bit if CPUID is supported)
    pushfd
    pop eax

    ; Restore FLAGS from old version stored in ecx (i.e. flipping the
    ; ID bit back if it was never flipped)
    push ecx
    popfd

    ; Compare eax and ecx. If they are equal then that means the bit
    ; wasn't flipped, and CPUID isn't supported
    cmp eax, ecx
    je .no_cpuid
    ret

.no_cpuid:
    mov al, "1"
    jmp error

check_long_mode:
    ; Test if the extended processor info is in available
    mov eax, 0x80000000                 ; implicit argument for cpuid
    cpuid                               ; get highest supported argument
    cmp eax, 0x80000001                 ; it needs to be atleast 0x80000001
    jb .no_long_mode                    ; CPU is too old for long mode

    ; Use extended info to test if long mode is available
    mov eax, 0x80000001                 ; argument for extended processor info
    cpuid                               ; returns various feature bits in ecx and edx
    test edx, 1 << 29                   ; test if LM-bit is set in D-register
    jz .no_long_mode                    ; no long mode
    ret

.no_long_mode:
    mov al, "2"
    jmp error

set_up_page_tables:
    ; Required to implement recursive mapping (paging)
    mov eax, p4_table
    or eax, 0b11                        ; present + writable
    mov [p4_table + 511 * 8], eax

    mov eax, p3_table
    or eax, 0b11
    mov dword [p4_table + 0], eax

    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax

    mov ecx, 0

.map_p2_table:
    mov eax, 0x200000
    mul ecx
    or eax, 0b10000011
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ret

enable_paging:
    ; Move page table address to cr3
    mov eax, p4_table
    mov cr3, eax

    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Set long mode bit
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    ret

; Prints 'ERR: ' and the given error code to screen and hangs
; param: err code (in ascii) in al
error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt

section .bss
align 4096

p4_table:
    resb 4096

p3_table:
    resb 4096

p2_table:
    resb 4096

stack_bottom:
    resb 4096 * 4
stack_top:

section .rodata

gdt64:
    dq 0

.code: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41) | (1 << 43) | (1 << 53)

.data: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41)

.pointer:
    dw .pointer - gdt64 - 1
    dq gdt64
