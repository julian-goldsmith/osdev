bits 32
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

section .text
global bootstrap
extern start
bootstrap:
	; Test for long mode
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb load_failed
	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29
	jz load_failed

	; Disable paging
	mov eax, cr0
	and eax, ~(1 << 31)
	mov cr0, eax

	; Clear paging table
	mov edi, 0x1000
	mov cr3, edi
	xor eax, eax
	mov ecx, 4096
	rep stosd
	mov edi, cr3

	; Set up PML4T
	mov dword [edi], 0x2003		; First PDPT is at 0x2000, and is present, readable, and writable
	add edi, 0x1000

	; Set up PDPT
	mov dword [edi], 0x3003		; First PDT is at 0x3000, and is present, readable, and writable
	add edi, 0x1000

	; Set up PDT
	mov dword [edi], 0x4003		; First PDPT is at 0x2000, and is present, readable, and writable
	add edi, 0x1000

	; Set up PTs
	mov ebx, 0x3
	mov ecx, 512

.set_pt_entry:
	mov dword [edi], ebx
	add ebx, 0x1000
	add edi, 8
	loop .set_pt_entry

	; Set PAE paging
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	; Move into compatibility mode
	mov ecx, 0xc0000080		; Read EFER MSR
	rdmsr
	or eax, 1 << 8			; Set LM bit
	wrmsr

	; Enable paging
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	; Load our 64-bit GDT
	lgdt [gdt64.end]

	; Jump to our 64-bit code segment
	jmp gdt64.code:bootstrap64

load_failed:
	hlt

gdt64:
	.null: equ $ - gdt64		; NULL GDT descriptor
	dw 0xFFFF
	dw 0
	db 0
	db 0
	db 1
	db 0

	.code: equ $ - gdt64		; Code GDT descriptor
	dw 0
	dw 0
	db 0
	db 10011010b			; Access: execute and read
	db 10101111b
	db 0

	.data: equ $ - gdt64		; Data GDT descriptor
	dw 0
	dw 0
	db 0
	db 10010010b			; Access: read and write
	db 0
	db 0

	.end: dw $ - gdt64 - 1
	dq gdt64

bits 64
bootstrap64:
	cli
	mov ax, gdt64.data
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov esp, _sys_stack

	jmp start
	hlt

align 4
section .bss
	resb 8192
_sys_stack:
