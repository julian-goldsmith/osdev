[BITS 32]
global start
start:
	mov esp, _sys_stack
	jmp bootstrap

ALIGN 4
multiboot_header:
	MBOOT_PAGE_ALIGN	equ 1
	MBOOT_MEMORY_INFO	equ 1 << 1
	MBOOT_AOUT_KLUDGE	equ 1 << 16
	MBOOT_HEADER_MAGIC	equ 0x1BADB002
	MBOOT_HEADER_FLAGS	equ MBOOT_PAGE_ALIGN | MBOOT_MEMORY_INFO | MBOOT_AOUT_KLUDGE
	MBOOT_CHECKSUM		equ -(MBOOT_HEADER_MAGIC + MBOOT_HEADER_FLAGS)
	EXTERN code, bss, end

	dd MBOOT_HEADER_MAGIC
	dd MBOOT_HEADER_FLAGS
	dd MBOOT_CHECKSUM

	dd multiboot_header
	dd code
	dd bss
	dd end
	dd start

bootstrap:
	jmp bootstrap

SECTION .bss
	resb 8192
_sys_stack:

