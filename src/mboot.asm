[BITS 64]
ALIGN 4
multiboot_header:
	MBOOT_PAGE_ALIGN	equ 1
	MBOOT_MEMORY_INFO	equ 1 << 1
	MBOOT_AOUT_KLUDGE	equ 1 << 16
	MBOOT_HEADER_MAGIC	equ 0x1BADB002
	MBOOT_HEADER_FLAGS	equ MBOOT_PAGE_ALIGN | MBOOT_MEMORY_INFO | MBOOT_AOUT_KLUDGE
	MBOOT_CHECKSUM		equ -(MBOOT_HEADER_MAGIC + MBOOT_HEADER_FLAGS)
	EXTERN _code, _bss, _end, _start

	dd MBOOT_HEADER_MAGIC
	dd MBOOT_HEADER_FLAGS
	dd MBOOT_CHECKSUM

	dd multiboot_header
	dd _code
	dd _bss
	dd _end
	dd _start
