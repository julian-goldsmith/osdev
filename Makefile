CFLAGS := -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2
LDFLAGS:= -Tsrc/link.ld

all:
	nasm -f elf64 -o obj/mboot.o src/mboot.asm
	x86_64-elf-gcc $(CFLAGS) -c -o obj/main.o src/main.c
	x86_64-elf-ld $(LDFLAGS) -o kernel obj/main.o obj/mboot.o

allold:
	nasm -f elf -o obj/start.o src/start.asm
	x86_64-elf-ld -m32 -o kernel.elf obj/start.o

run:
	qemu -drive file=disk.img,format=raw
