.global	keyMixing, byteSubstitution, shiftRows, cipher

.section	.data
sbox:	.byte	99,124,119,123,-14,107,111,-59,48,1,103,43,-2,-41,-85,118
		.byte	-54,-126,-55,125,-6,89,71,-16,-83,-44,-94,-81,-100,-92,114,-64
		.byte	-73,-3,-109,38,54,63,-9,-52,52,-91,-27,-15,113,-40,49,21
		.byte	4,-57,35,-61,24,-106,5,-102,7,18,-128,-30,-21,39,-78,117
		.byte	9,-125,44,26,27,110,90,-96,82,59,-42,-77,41,-29,47,-124
		.byte	83,-47,0,-19,32,-4,-79,91,106,-53,-66,57,74,76,88,-49
		.byte	-48,-17,-86,-5,67,77,51,-123,69,-7,2,127,80,60,-97,-88
		.byte	81,-93,64,-113,-110,-99,56,-11,-68,-74,-38,33,16,-1,-13,-46
		.byte	-51,12,19,-20,95,-105,68,23,-60,-89,126,61,100,93,25,115
		.byte	96,-127,79,-36,34,42,-112,-120,70,-18,-72,20,-34,94,11,-37
		.byte	-32,50,58,10,73,6,36,92,-62,-45,-84,98,-111,-107,-28,121
		.byte	-25,-56,55,109,-115,-43,78,-87,108,86,-12,-22,101,122,-82,8
		.byte	-70,120,37,46,28,-90,-76,-58,-24,-35,116,31,75,-67,-117,-118
		.byte	112,62,-75,102,72,3,-10,14,97,53,87,-71,-122,-63,29,-98
		.byte	-31,-8,-104,17,105,-39,-114,-108,-101,30,-121,-23,-50,85,40,-33
		.byte	-116,-95,-119,13,-65,-26,66,104,65,-103,45,15,-80,84,-69,22

.section	.text
keyMixing:
	xorq %rax, %rax
	xorq %r9, %r9
	
	movq (%rdi), %rax # input is %rdi
	movq (%rsi), %r9 # key is %rsi 
	xorq %r9, %rax # xor with key
	movq %rax, (%rdi) # save xor result

	movq 8(%rdi), %rax
	movq 8(%rsi), %r9
	xorq %r9, %rax
	movq %rax, 8(%rdi)
	ret


byteSubstitution:
	xor %rax, %rax
	xor %rcx, %rcx
	xor %r10, %r10
	movq $16, %rcx
	lea sbox(%rip), %r9 # r9 is the address of sbox
_byte_sub_loop:
	movb (%rdi), %al
	movb (%r9, %rax), %al
	movb %al, (%rdi)
	leaq 1(%rdi), %rdi
	loop _byte_sub_loop
	ret


shiftRows:
	xor %rax, %rax
	
# row 1
	movl 4(%rdi), %eax
	rorl $8, %eax
	movl %eax, 4(%rdi)

# row 2
	movl 8(%rdi), %eax
	rorl $16, %eax
	movl %eax, 8(%rdi)

# row 3
	movl 12(%rdi), %eax
	rorl $24, %eax
	movl %eax, 12(%rdi)
	ret

# rdi = input, rsi = key, rdx = len
cipher:
	xor %rcx, %rcx # rcx is the counter of the loop_block, need to run len times
_loop_block: # do len times
	pushq %rdi
	pushq %rsi
	pushq %rcx
	call keyMixing # inupt -> rdi, key -> rsi
	popq %rcx
	popq %rsi
	popq %rdi
	movq $0, %r15 # r15 is counter for loop_cipher, to run the loop 9 times
	jmp _loop_cipher

_finish_loop_cipher:
	pushq %rdi
	pushq %rcx
	call byteSubstitution # input -> rdi
	popq %rcx
	popq %rdi

	pushq %rdi
	pushq %rcx
	call shiftRows # input -> rdi
	popq %rcx
	popq %rdi

	pushq %rdi
	pushq %rsi
	pushq %rcx
	call keyMixing # inupt -> rdi, key -> rsi
	popq %rcx
	popq %rsi
	popq %rdi

	inc %rcx
	leaq 16(%rdi), %rdi
	cmp %rdx, %rcx
	jne _loop_block
	je _finish


	
_loop_cipher:
	
	# do key-mixing on key
	# do 9 times: byte-sub, shift-rows, mix-col, key-mix
	pushq %rdi
	pushq %rcx
	call byteSubstitution # input -> rdi
	popq %rcx
	popq %rdi

	pushq %rdi
	pushq %rcx
	call shiftRows # input -> rdi
	popq %rcx
	popq %rdi

	pushq %rdi
	pushq %rcx
	pushq %rsi
	pushq %rdx
	call mixColumns # input -> rdi
	popq %rdx
	popq %rsi
	popq %rcx
	popq %rdi

	pushq %rdi
	pushq %rsi
	pushq %rcx
	call keyMixing # inupt -> rdi, key -> rsi
	popq %rcx
	popq %rsi
	popq %rdi
_came_back:
	inc %r15
	cmpq $9, %r15
	jne _loop_cipher
	je _finish_loop_cipher


_finish:
	ret
