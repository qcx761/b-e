; mbr.asm - 裸机 MBR 程序示例
org 0x7C00           ; MBR 固定加载地址

; 数据段
char db 'a'           ; 当前字符
color db 0x0E         ; 初始颜色（黄字黑底）

start:
    ; 每次循环显示一个字符
print_loop:
    mov ah, 0x0E      ; teletype 输出字符
    mov al, [char]    ; 当前字符
    mov bh, 0         ; 页号
    int 0x10

    ; 检测按键
    mov ah, 0x01      ; 检查键盘按键
    int 0x16
    jz no_key         ; 没有按键则继续

    mov ah, 0x00      ; 读取按键
    int 0x16
    cmp al, 1Bh       ; ESC ASCII = 27
    jne no_key
    xor byte [color], 0x0F ; 改变前景颜色

no_key:
    ; 下一字符
    inc byte [char]
    cmp byte [char], 'z'+1
    jne print_loop

    ; 输出换行
    mov ah, 0x0E
    mov al, 0x0A       ; LF
    int 0x10

hang:
    jmp hang           ; 停在这里，防止返回

; 填充到 510 字节
times 510-($-$$) db 0
dw 0xAA55             ; MBR 标志
