;-------------
; 创建页目录及页表
;---------------
setup_page:
;先把页目录占用的空间逐字节清 0
    mov ecx, 4096
    mov esi, 0
.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

;开始创建页目录项(PDE)
.create_pde: ; 创建 Page Directory Entry
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x1000
    ; 此时 eax 为第一个页表的位置及属性
    mov ebx, eax
    ; 此处为 ebx 赋值，是为.create_pte 做准备，ebx 为基址

    ;
    ; 下面将页目录项 0 和 0xc00 都存为第一个页表的地址，每个页表表示 4MB 内存
    ;
    ; 这样 0xc03fffff 以下的地址和 0x003fffff 以下的地址都指向相同的页表
    ; 这是为将地址映射为内核地址做准备
    or eax, PG_US_U | PG_RW_W | PG_P
    ; 页目录项的属性 RW 和 P 位为 1，US 为 1，表示用户属性，所有特权级别都可以访问
    mov [PAGE_DIR_TABLE_POS + 0x0], eax
    ; 第 1 个目录项
    ; 在页目录表中的第 1 个目录项写入第一个页表的位置(0x101000)及属性(7)
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax
    ; 一个页表项占用 4 字节
    ; 0xc00 表示第 768 个页表占用的目录项，0xc00 以上的目录项用于内核空间
    ; 也就是页表的 0xc0000000～0xffffffff 共计 1G 属于内核
    ; 0x0～0xbfffffff 共计 3G 属于用户进程
    sub eax, 0x1000
    mov [PAGE_DIR_TABLE_POS + 4092], eax
    ; 使最后一个目录项指向页目录表自己的地址

;下面创建页表项(PTE)
    mov ecx, 256
    ; 1M 低端内存 / 每页大小 4k = 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P
    ; 属性为 7，US=1，RW=1，P=1
.create_pte:
    ; 创建 Page Table Entry
    mov [ebx+esi*4],edx
    ; 此时的 ebx 已经在上面通过 eax 赋值为 0x101000，也就是第一个页表的地址
    add edx,4096
    inc esi
    loop .create_pte

;创建内核其他页表的 PDE
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000
    ; 此时 eax 为第二个页表的位置
    or eax, PG_US_U | PG_RW_W | PG_P ; 页目录项的属性 US､ RW 和 P 位都为 1
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254
    ; 范围为第 769～1022 的所有目录项数量
    mov esi, 769
.create_kernel_pde:
    mov [ebx+esi*4], eax
    inc esi
    add eax, 0x1000
    loop .create_kernel_pde

    ret



0xC0000000 ~ 0xC03FFFFF 





代码 5-2 （project/c5/b/boot/loader.S）
181 ;-------------
创建页目录及页表
---------------
182 setup_page:
183 ;先把页目录占用的空间逐字节清 0
184
mov ecx, 4096
185
mov esi, 0
186 .clear_page_dir:
187
mov byte [PAGE_DIR_TABLE_POS + esi], 0
188
inc esi
189
loop .clear_page_dir
190
191 ;开始创建页目录项(PDE)
192 .create_pde: ; 创建 Page Directory Entry
193
mov eax, PAGE_DIR_TABLE_POS
194
add eax, 0x1000
; 此时 eax 为第一个页表的位置及属性
195
mov ebx, eax
; 此处为 ebx 赋值，是为.create_pte 做准备，ebx 为基址
196
197 ;
下面将页目录项 0 和 0xc00 都存为第一个页表的地址，每个页表表示 4MB 内存
198 ;
这样 0xc03fffff 以下的地址和 0x003fffff 以下的地址都指向相同的页表
199 ;
这是为将地址映射为内核地址做准备
200
or eax, PG_US_U | PG_RW_W | PG_P
; 页目录项的属性 RW 和 P 位为 1，US 为 1，表示用户属性，所有特权级别都可以访问
201
mov [PAGE_DIR_TABLE_POS + 0x0], eax
; 第 1 个目录项
;在页目录表中的第 1 个目录项写入第一个页表的位置(0x101000)及属性(7)
202
mov [PAGE_DIR_TABLE_POS + 0xc00], eax
; 一个页表项占用 4 字节
; 0xc00 表示第 768 个页表占用的目录项，0xc00 以上的目录项用于内核空间
203
;也就是页表的 0xc0000000～0xffffffff 共计 1G 属于内核
; 0x0～0xbfffffff 共计 3G 属于用户进程
204
sub eax, 0x1000
205
mov [PAGE_DIR_TABLE_POS + 4092], eax
; 使最后一个目录项指向页目录表自己的地址
206
207 ;下面创建页表项(PTE)
208
mov ecx, 256
; 1M 低端内存 / 每页大小 4k = 256
209
mov esi, 0
210
mov edx, PG_US_U | PG_RW_W | PG_P
; 属性为 7，US=1，RW=1，P=1
211 .create_pte:
; 创建 Page Table Entry
212
mov [ebx+esi*4],edx
; 此时的 ebx 已经在上面通过 eax 赋值为 0x101000，也就是第一个页表的地址
213
add edx,4096
214
inc esi
215
loop .create_pte
216
217 ;创建内核其他页表的 PDE
218
mov eax, PAGE_DIR_TABLE_POS
219
add eax, 0x2000
; 此时 eax 为第二个页表的位置
220
or eax, PG_US_U | PG_RW_W | PG_P ; 页目录项的属性 US､ RW 和 P 位都为 1
221
mov ebx, PAGE_DIR_TABLE_POS
222
mov ecx, 254
; 范围为第 769～1022 的所有目录项数量
223
mov esi, 769
224 .create_kernel_pde:
225
mov [ebx+esi*4], eax
226
inc esi
227
add eax, 0x1000
228
loop .create_kernel_pde
229
ret