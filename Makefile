CFLAGS := -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2
LDFLAGS:= -n -Tsrc/link.ld

all:
	nasm -f elf32 -o obj/mboot.o src/mboot.asm
	nasm -f elf32 -o obj/start.o src/start.asm
	x86_64-elf-ld -melf_i386 $(LDFLAGS) -o kernel obj/mboot.o obj/start.o

allold:
	nasm -f elf -o obj/start.o src/start.asm
	x86_64-elf-ld -m32 -o kernel.elf obj/start.o

run:
	qemu -drive file=disk.img,format=raw
