global reboot

reboot:
    xor al, al
    in al, 0x64
    test al, 0x02
    jnz reboot
    mov al, 0xfc
    out 0x64, al
