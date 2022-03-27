CC   ?= gcc
LD   ?= ld
AR   ?= ar
NASM ?= nasm

ifeq ($(shell uname -s),Linux)
	CC = ./toolchain/x86_64/bin/x86_64-elf-gcc
	LD = ./toolchain/x86_64/bin/x86_64-elf-ld
	AR = ./toolchain/x86_64/bin/x86_64-elf-ar
endif

OS_NAME    = bolt
BUILD_DIR  = build
LINKER     = linker.ld
ISO_DIR    = $(BUILD_DIR)/isofiles
KERNEL_DIR = $(ISO_DIR)/boot
GRUB_DIR   = $(KERNEL_DIR)/grub
KERNEL     = $(KERNEL_DIR)/kernel.bin
ISO        = $(BUILD_DIR)/$(OS_NAME).iso
LIB        = $(BUILD_DIR)/lib$(OS_NAME).a

OBJECTS := $(patsubst %.asm,%.o,$(shell find asm -name '*.asm'))
SOURCES := $(patsubst %.c,%.o,$(shell find src -name '*.c'))

CFLAGS = -W -Wall -pedantic -std=c11 -O2 -ffreestanding -nostdlib \
		 -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs \
		 -mno-red-zone -Isrc/include/ -Isrc/

default: iso
kernel: $(KERNEL)

.PHONY: kernel

$(KERNEL): $(OBJECTS) $(LIB)
	mkdir -p $(KERNEL_DIR)
	$(LD) --nmagic --output=$@ --script=$(LINKER) $(OBJECTS) $(LIB)
	@echo "[LD] $@"

$(OBJECTS): %.o: %.asm
	@mkdir -p $(BUILD_DIR)
	@$(NASM) -f elf64 $<
	@echo "[AS] $<"

$(SOURCES): %.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "[CC] $<"

$(LIB): $(SOURCES)
	@$(AR) rcs $@ $^
	@echo "[AR] $@"

iso: $(ISO)

.PHONY: iso

$(ISO): $(KERNEL)
	@mkdir -p $(GRUB_DIR)
	@cp -R grub/* $(GRUB_DIR)
	grub-mkrescue -o $@ $(ISO_DIR)

run: $(ISO)
	qemu-system-x86_64 -cdrom $<

.PHONY: run

debug: CFLAGS += -DENABLE_KERNEL_DEBUG
debug: $(ISO)
	qemu-system-x86_64 -cdrom $< -chardev stdio,id=char0,logfile=/tmp/serial.log,signal=off -serial chardev:char0

.PHONY: debug

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
	rm -f $(OBJECTS) $(SOURCES) $(KERNEL) $(ISO) $(LIB)
	rm -rf $(BUILD_DIR)

.PHONY: clean