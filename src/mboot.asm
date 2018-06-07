[BITS 32]
align 4
section .multiboot_header
multiboot_header:
	MBOOT_PAGE_ALIGN	equ 1
	MBOOT_MEMORY_INFO	equ 1 << 1
	MBOOT_AOUT_KLUDGE	equ 1 << 16
	MBOOT_HEADER_MAGIC	equ 0x1BADB002
	MBOOT_HEADER_FLAGS	equ MBOOT_PAGE_ALIGN | MBOOT_MEMORY_INFO | MBOOT_AOUT_KLUDGE
	MBOOT_CHECKSUM		equ -(MBOOT_HEADER_MAGIC + MBOOT_HEADER_FLAGS)

	dd MBOOT_HEADER_MAGIC
	dd MBOOT_HEADER_FLAGS
	dd MBOOT_CHECKSUM

	extern code, bss, end
	dd multiboot_header
	dd code
	dd bss
	dd end
	dd bootstrap

extern start
global bootstrap
bootstrap:
	jmp bootstrap
	mov esp, _sys_stack
	jmp start

align 4
section .bss
	resb 8192
_sys_stack:
