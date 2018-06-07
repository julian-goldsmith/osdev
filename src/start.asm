[BITS 32]
global start
start:
	mov dword [0xB800], 0x2F4B2F4F
loop:
	jmp loop

