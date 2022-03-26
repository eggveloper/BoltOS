CC   = ./toolchain/x86_64/bin/x86_64-elf-gcc
LD   = ./toolchain/x86_64/bin/x86_64-elf-ld
AR   = ./toolchain/x86_64/bin/x86_64-elf-ar
NASM = nasm

kernel 	 = isofiles/boot/kernel.bin
linker 	 = linker.ld
iso    	 = bolt.iso
lib		 = libbolt.a

OBJECTS := $(patsubst %.asm,%.o,$(wildcard *.asm))
SOURCES := $(patsubst %.c,%.o,$(wildcard src/*.c))

CFLAGS = -W -Wall -ansi -pedantic -std=c99 -O2 -ffreestanding -nostdlib \
		 -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs \
		 -Isrc/include/

default: iso
kernel: $(kernel)

.PHONY: kernel

$(kernel): $(OBJECTS) $(lib)
	$(LD) --nmagic --output=$@ --script=$(linker) $(OBJECTS) $(lib)

$(OBJECTS): %.o: %.asm
	$(NASM) -f elf64 $<

$(SOURCES): %.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

$(lib): $(SOURCES)
	$(AR) rcs $@ $^

iso: $(iso)

.PHONY: iso

$(iso): $(kernel)
	grub-mkrescue -o $@ isofiles

run: $(iso)
	qemu-system-x86_64 -cdrom bolt.iso

.PHONY: run

toolchain:
	@-mkdir toolchain/x86_64
	@-[ ! -f toolchain/x86_64-elf-tools-linux.zip ] && wget https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/x86_64-elf-tools-linux.zip -P toolchain
	@echo "Unzipping toolchain"
	@unzip -qq toolchain/x86_64-elf-tools-linux -d toolchain/x86_64
	@echo "Unzipped toolchain"

.PHONY: toolchain

clean_toolchain:
	rm -rf toolchain/x86_64/

.PHONY: clean_toolchain

clean:
	rm -f $(OBJECTS) $(SOURCES) $(kernel) $(iso) $(lib)

.PHONY: clean