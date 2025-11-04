section .data
    char db 'a'
    newline db 0xA

section .text
    global _start

_start:
print_loop:
    ; 输出当前字符
    mov eax, 4           ; sys_write
    mov ebx, 1           ; stdout
    lea ecx, [char]
    mov edx, 1
    int 0x80

    ; 延迟循环（简单忙等）
    mov ecx, 50000000    ; 调整这个值可以改变速度
delay:
    loop delay

    ; 下一个字符
    inc byte [char]
    cmp byte [char], 'z'+1
    jne print_loop

    ; 输出换行
    mov eax, 4
    mov ebx, 1
    lea ecx, [newline]
    mov edx, 1
    int 0x80

    ; 退出程序
    mov eax, 1
    xor ebx, ebx
    int 0x80
