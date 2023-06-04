.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
  # saving registers on kernel stack
  pushq %rax
  pushq %rbx
  pushq %rcx
  pushq %rdx	
  pushq %r8
  pushq %r9
  pushq %r10
  pushq %r11
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15
  pushq %rsi
  pushq %rbp
  pushq %rsp

  # the rip that caused the exception is stored in 120(%rsp)
  xorq %rbx, %rbx
  xorq %rdi, %rdi
  xorq %rax, %rax
  xorq %rcx, %rcx
  movq 120(%rsp), %rbx
  movq (%rbx), %rbx
  cmpb 0x0f, %bl
  je _two_bytes_opcode
  # if not jumped, only one byte opcode
  movq %rbx, %rdi
  call what_to_do
  cmpq $0, %rax
  je _original
  jne _continue_handler

_two_bytes_opcode:
  movb %bh, %cl
  movq %rcx, %rdi
  call what_to_do
  cmpq $0, %rax
  je _original
  jne _continue_handler


_original:
  popq %rsp
  popq %rbp
  popq %rsi
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %r11
  popq %r10
  popq %r9
  popq %r8
  popq %rdx
  popq %rcx
  popq %rbx
  popq %rax

  jmp * old_ili_handler
  jmp _finish_handler

_continue_handler:
  movq %rax, %rdi
  popq %rsp
  popq %rbp
  popq %rsi
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %r11
  popq %r10
  popq %r9
  popq %r8
  popq %rdx
  popq %rcx
  popq %rbx
  popq %rax

  # update rip to point to the next instruction
  addq $2, (%rsp)

_finish_handler:
  iretq
