; ============================================================
; GDT 段描述符属性位定义（所有 equ 都包含正确的位移）
; ============================================================

; ---------------- Flags（高 4 位）----------------
DESC_G_4K        equ 1 << 23            ; G 粒度：1=4KB
DESC_D_32        equ 1 << 22            ; D/B：1=32位段
DESC_L           equ 0 << 21            ; L=0（64 位代码段标志）
DESC_AVL         equ 0 << 20            ; AVL=0（CPU 不用）

; ---------------- Limit 高 4 位 ----------------
DESC_LIMIT_CODE2 equ 0xF << 16          ; limit 高 4bit = 1111b
DESC_LIMIT_DATA2 equ 0xF << 16
DESC_LIMIT_VIDEO2 equ 0x0 << 16         ; 显存段 limit 很小

; ---------------- Access Byte -----------------
DESC_P           equ 1 << 15            ; P：段存在
DESC_DPL_0       equ 0 << 13            ; DPL=0
DESC_S_CODE      equ 1 << 12            ; S=1（代码/数据段）
DESC_S_DATA      equ 1 << 12
DESC_S_SYS       equ 0 << 12            ; 系统段（TSS/LDT）

; Type 字段（bit 11-8）
DESC_TYPE_CODE   equ 0x8 << 8           ; x=1,c=0,r=0,a=0
DESC_TYPE_DATA   equ 0x2 << 8           ; x=0,e=0,w=1,a=0

; ============================================================
; 组合描述符高 4 字节（Descriptor High 4 Bytes）
; ============================================================

; 代码段
DESC_CODE_HIGH4 equ (0 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + \
                    DESC_LIMIT_CODE2 + DESC_P + DESC_DPL_0 + \
                    DESC_S_CODE + DESC_TYPE_CODE + 0

; 数据段
DESC_DATA_HIGH4 equ (0 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + \
                    DESC_LIMIT_DATA2 + DESC_P + DESC_DPL_0 + \
                    DESC_S_DATA + DESC_TYPE_DATA + 0

; 显存段（Base=0xB8000）
DESC_VIDEO_HIGH4 equ (0x0B << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + \
                     DESC_LIMIT_VIDEO2 + DESC_P + DESC_DPL_0 + \
                     DESC_S_DATA + DESC_TYPE_DATA + 0x80

; ============================================================
; GDT 表本体
; ============================================================

gdt_base:
    dq 0x0000000000000000        ; 第 0 个描述符必须全 0

CODE_DESC:
    dd 0x0000FFFF                ; base0-15 = 0, limit0-15 = 0xFFFF
    dd DESC_CODE_HIGH4           ; 高 4 字节（上边组合）

DATA_DESC:
    dd 0x0000FFFF
    dd DESC_DATA_HIGH4

VIDEO_DESC:                       ; 显示缓冲区段 base=0xB8000
    dd 0x8000FFFF                 ; base 0xB8000 低 16bit 在这里
    dd DESC_VIDEO_HIGH4

gdt_size equ $ - gdt_base
gdt_limit equ gdt_size - 1

gdt_ptr:
    dw gdt_limit
    dd gdt_base

; ============================================================
; 选择子
; ============================================================

RPL0 equ 0
TI_GDT equ 0

SEL_CODE equ (1 << 3) + TI_GDT + RPL0
SEL_DATA equ (2 << 3) + TI_GDT + RPL0
SEL_VIDEO equ (3 << 3) + TI_GDT + RPL0

