KERNEL_VMA = 1M;

ENTRY(bootstrap)
SECTIONS
{
	. = KERNEL_VMA;

	.boot : AT(ADDR(.boot) - KERNEL_VMA)
	{
		*(.multiboot_header)
	}

	.text : AT(ADDR(.text) - KERNEL_VMA)
	{
		code = .;
		*(.text)
		*(.rodata)
		. = ALIGN(4096);
	}

	.data : AT(ADDR(.data) - KERNEL_VMA)
	{
		data = .;
		*(.data)
		. = ALIGN(4096);
	}

	.bss : AT(ADDR(.bss) - KERNEL_VMA)
	{
		bss = .;
		*(.bss)

		*(COMMON)
		. = ALIGN(4096);
	}

	end = .;

	/DISCARD/ :
	{
		*(.comment)
	}
}
