kernel = isofiles/boot/kernel.bin
linker = linker.ld
iso    = bolt.iso
objects := $(patsubst %.asm,%.o,$(wildcard *.asm))

default: iso
kernel: $(kernel)

.PHONY: kernel

$(kernel): $(objects)
	ld --nmagic --output=$@ --script=$(linker) $(objects)

$(objects): %.o: %.asm
	nasm -f elf64 $<

iso: $(iso)

.PHONY: iso

$(iso): $(kernel)
	grub2-mkrescue -o $@ isofiles

run: $(iso)
	qemu-system-x86_64 -cdrom bolt.iso

.PHONY: run

clean:
	rm -f $(objects) $(kernel) $(iso)

.PHONY: clean