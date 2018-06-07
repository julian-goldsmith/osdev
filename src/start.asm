bits 64
global start
start:
	mov edi, 0xb8000
	mov rax, 0x0720072007200720
	mov ecx, 500
	rep stosq

	mov dword [0xb8000], 0x074b074f

	hlt
