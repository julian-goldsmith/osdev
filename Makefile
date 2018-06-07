CFLAGS  := -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2
LDFLAGS := -n -Tsrc/link.ld
LOOPDEV := $(shell losetup --list --raw | cut -d " " -f 1,6 | grep disk.img | cut -d " " -f 1)

.PHONY: mount

all:
	@nasm -f elf64 -o obj/start.o src/start.asm
	@RUST_TARGET_PATH=$(shell pwd) xargo build --target x86_64-kernel
	@x86_64-elf-ld $(LDFLAGS) -o kernel obj/start.o target/x86_64-kernel/debug/libkernel.a

allold:
	@nasm -f elf -o obj/start.o src/start.asm
	@x86_64-elf-ld -m32 -o kernel.elf obj/start.o

install:
	@cp kernel mount/

run:
	@qemu -drive file=disk.img,format=raw

mount:
	# FIXME: Don't hardcode this
	@echo "Mounting $(LOOPDEV)p1"
	@mount -o sync "$(LOOPDEV)p1" mount
