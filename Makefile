CFLAGS := -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2
LDFLAGS:= -n -Tsrc/link.ld

.PHONY: mount

all:
	nasm -f elf64 -o obj/mboot.o src/mboot.asm
	nasm -f elf64 -o obj/start.o src/start.asm
	x86_64-elf-ld $(LDFLAGS) -o kernel obj/mboot.o obj/start.o

allold:
	nasm -f elf -o obj/start.o src/start.asm
	x86_64-elf-ld -m32 -o kernel.elf obj/start.o

install:
	cp kernel mount/

run:
	qemu -drive file=disk.img,format=raw

mount:
	# FIXME: Don't hardcode this
	mount -o sync /dev/loop0p1 mount
