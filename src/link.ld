ENTRY(_start)
SECTIONS
{
	. = KERNEL_VMA;

	.text : AT(ADDR(.txt) - KERNEL_VMA)
	{
		_code = .;
		*(.text)
		*(.rodata)
		. = ALIGN(4096);
	}

	.data : AT(ADDR(.data) - KERNEL_VMA)
	{
		_data = .;
		*(.data)
		. = ALIGN(4096);
	}

	.bss : AT(ADDR(.bss) - KERNEL_VMA)
	{
		_bss = .;
		*(.bss)

		*(COMMON)
		. = ALIGN(4096);
	}

	_end = .;

	/DISCARD/ :
	{
		*(.comment)
	}
}
