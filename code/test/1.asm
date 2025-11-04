section .data
    msg db "Hello, NASM!", 0xA  ; 0xA = 换行

section .text
    global _start

_start:
    mov rax, 1        ; 系统调用号 sys_write
    mov rdi, 1        ; 文件描述符 stdout
    mov rsi, msg      ; 消息地址
    mov rdx, 13       ; 消息长度
    syscall

    mov rax, 60       ; 系统调用号 sys_exit
    xor rdi, rdi      ; 返回值 0
    syscall

