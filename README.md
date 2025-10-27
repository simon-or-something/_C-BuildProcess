# _C-BuildProcess
This repository contains information on how C builds things, from the actual compilation to resources and own attempts at making a compiler

[CRT0](https://en.wikipedia.org/wiki/Crt0)
```asm
.text

.globl _start

_start: # _start is the entry point known to the linker
    xor %ebp, %ebp            # effectively RBP := 0, mark the end of stack frames
    mov (%rsp), %edi          # get argc from the stack (implicitly zero-extended to 64-bit)
    lea 8(%rsp), %rsi         # take the address of argv from the stack
    lea 16(%rsp,%rdi,8), %rdx # take the address of envp from the stack
    xor %eax, %eax            # per ABI and compatibility with icc
    call main                 # %edi, %rsi, %rdx are the three args (of which first two are C standard) to main

    mov %eax, %edi    # transfer the return of main to the first argument of _exit
    xor %eax, %eax    # per ABI and compatibility with icc
    call _exit        # terminate the program
# In compilation if you dont link crt0 you get entry point errors (cant find the entry point _start)
# So if you rename main to _start you mitigate those issues (it wont run anyway though*)
# The same thing happens if you replace `call main` with `call foo` because it looks for foo then
```
\*If you want it to run you need to either generate the assembly without standard library

`gcc -S -nostdlib %.c -o %.s`

Then assemble / link it from there, or you do it manually (as seen in the makefile)

`as -o main.o main.s && ld -o main main.o`

Both of them have equal compilation steps, just the linking stage is different
> "This is where the magic happens"

The code 
