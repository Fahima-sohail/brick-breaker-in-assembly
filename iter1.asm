
.model small
.stack 400h

.data

player_name  db 16 dup(0)
name_len     db 0
menu_sel     db 0

; shared rectangle inputs for fill_rect / draw_border
rx1   dw 0
ry1   dw 0
rx2   dw 0
ry2   dw 0
rcol  db 0

; cached copy used while drawing borders
sx1   dw 0
sy1   dw 0
sx2   dw 0
sy2   dw 0

; brick row layout for the game screen preview
bry1  dw 0
bry2  dw 0
brcol db 0

; top-left corner for small heart icons in the HUD
hx    dw 0
hy    dw 0

; 40 upper-sky stars (x,y byte pairs)
; fixed: 285 was invalid for DB, so it was replaced with 255
stars db  15,10,  42, 5,  78,18, 120, 3, 165,12
      db 200, 7, 240,15, 255, 2, 254, 9,  55,19
      db  90, 1, 135, 8, 180, 4, 225,11, 210, 6
      db 245,17,  30,14, 100,19, 200, 3, 180, 8
      db   8, 5,  60,13, 140, 2, 190,16, 170, 9
      db 210,12,  70, 7, 160,18, 230, 1, 250,14
      db  20,17, 110, 6, 150,11, 205,19, 220, 4
      db 255,13,  45, 8,  95,15, 175,10, 185, 5

stars2 db  25,40,  80,55, 145,35, 195,48, 200,42
       db 254,58,  35,62, 115,37, 210,53, 180,39
       db  50,70, 130,44, 185,66, 235,51, 220,47
       db  10,80, 100,73, 170,82, 200,68, 254,75

ltr_B  db 01111100b, 01000100b, 01000100b, 01111100b
       db 01000100b, 01000100b, 01111100b
ltr_R  db 01111100b, 01000100b, 01000100b, 01111100b
       db 01010000b, 01001000b, 01000100b
ltr_I  db 01111110b, 00011000b, 00011000b, 00011000b
       db 00011000b, 00011000b, 01111110b
ltr_C  db 00111110b, 01000000b, 01000000b, 01000000b
       db 01000000b, 01000000b, 00111110b
ltr_K  db 01000100b, 01001000b, 01010000b, 01100000b
       db 01010000b, 01001000b, 01000100b
ltr_E  db 01111110b, 01000000b, 01000000b, 01111100b
       db 01000000b, 01000000b, 01111110b
ltr_A  db 00011000b, 00100100b, 01000010b, 01111110b
       db 01000010b, 01000010b, 01000010b

ltr_ptr  dw 0

pal_tbl label byte
    db 16,  3,  0,  7
    db 17, 10,  0, 16
    db 18,  6,  0, 12
    db 19, 12,  0, 20
    db 20, 16,  3, 24
    db 21, 18, 52, 63
    db 22, 60,  6, 36
pal_end label byte

COL_BLACK  equ  0
COL_DKBLUE equ  1
COL_DKGRN  equ  2
COL_DKCYAN equ  3
COL_DKRED  equ  4
COL_DKMAG  equ  5
COL_BROWN  equ  6
COL_LTGRAY equ  7
COL_DKGRAY equ  8
COL_LTBLUE equ  9
COL_LTGRN  equ 10
COL_LTCYAN equ 11
COL_LTRED  equ 12
COL_LTMAG  equ 13
COL_YELLOW equ 14
COL_WHITE  equ 15

subtitle_str  db " ", 0
press_str     db "PRESS ANY KEY TO CONTINUE", 0

ni_title_str  db "PLAYER NAME", 0
ni_inst1      db "TYPE YOUR NAME AND PRESS ENTER", 0
ni_inst2      db "BACKSPACE REMOVES LAST LETTER", 0
ni_inst3      db "MAXIMUM 14 CHARACTERS", 0
ni_label      db "NAME: ", 0

mm_header_str db "BRICK BREAKER", 0
home_breaker_str db "B R E A K E R", 0
mm_sub_str    db "MAIN MENU", 0
mm_hint_str   db "UP/DOWN  ENTER SELECT", 0
mm_plyr_str   db "PLAYER ", 0

opt0_lbl db "START GAME", 0
opt1_lbl db "INSTRUCTIONS", 0
opt2_lbl db "HIGH SCORES", 0
opt3_lbl db "EXIT", 0

in_title db "HOW TO PLAY", 0
in_c_hdr db "CONTROLS", 0
in_c1    db "LEFT/RIGHT ARROWS MOVE PADDLE", 0
in_c2    db "A/D KEYS ALSO WORK", 0
in_o_hdr db "OBJECTIVE", 0
in_o1    db "BOUNCE BALL TO BREAK ALL BRICKS", 0
in_o2    db "CLEAR ALL BRICKS TO WIN", 0
in_l_hdr db "LIVES", 0
in_l1    db "YOU START WITH 3 LIVES", 0
in_l2    db "MISSING THE BALL COSTS 1 LIFE", 0
in_b_hdr db "BONUSES", 0
in_b1    db "SLOW BALL  LIFE UP  WIDER PADDLE", 0
back_str db "PRESS ANY KEY TO GO BACK", 0

hs_title db "HIGH SCORES", 0
hs_clbl  db "RANK   NAME              SCORE", 0
hs_r1    db "#1", 0
hs_r2    db "#2", 0
hs_r3    db "#3", 0
hs_r4    db "#4", 0
hs_r5    db "#5", 0
hs_n1    db "Ahmed Khan", 0
hs_n2    db "Sara Ali", 0
hs_n3    db "Usman Tariq", 0
hs_n4    db "Fatima Noor", 0
hs_n5    db "Bilal Hassan", 0
hs_s1    db "9500", 0
hs_s2    db "8200", 0
hs_s3    db "7100", 0
hs_s4    db "6300", 0
hs_s5    db "5000", 0

hud_score  db "SCORE 0", 0
hud_lives  db "LIVES", 0
hud_level  db "LVL 1", 0
hud_namelb db "P ", 0

.code

enter_mode13 proc
    push ax
    mov ax, 0013h
    int 10h
    mov ax, 0a000h
    mov es, ax
    pop ax
    ret
enter_mode13 endp

set_palette proc
    push ax
    push bx
    push cx
    push dx
    push si

    lea si, pal_tbl      ; custom neon palette used across screens

sp_loop:
    cmp si, offset pal_end
    jae sp_done

    xor bx, bx
    mov bl, [si]
    inc si
    mov dh, [si]
    inc si
    mov ch, [si]
    inc si
    mov cl, [si]
    inc si

    mov ax, 1010h
    int 10h
    jmp sp_loop

sp_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
set_palette endp

wait_key proc
    push ax
    mov ah, 00h
    int 16h
    pop ax
    ret
wait_key endp

set_cursor proc
    push ax
    push bx
    mov ah, 02h
    mov bh, 00h
    int 10h
    pop bx
    pop ax
    ret
set_cursor endp

print_char proc
    push ax
    push bx
    push cx
    push dx
    call set_cursor
    mov ah, 09h
    mov bh, 00h
    mov cx, 1
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_char endp

print_str proc
    push ax
    push bx
    push cx
    push dx
    push si

pstr_loop:
    mov al, [si]
    cmp al, 0
    je  pstr_done
    call print_char
    inc dl
    inc si
    jmp pstr_loop

pstr_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_str endp

fill_rect proc
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov si, ry1          ; start at the top row of the rectangle

fr_row_loop:
    cmp si, ry2
    jg  fr_done

    mov ax, si           ; DI = y * 320 + x
    mov dx, 320
    mul dx
    add ax, rx1
    mov di, ax

    mov cx, rx2          ; write one full horizontal span
    sub cx, rx1
    inc cx
    mov al, rcol
    rep stosb

    inc si
    jmp fr_row_loop

fr_done:
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
fill_rect endp

draw_border proc
    push ax
    push bx
    push cx
    push dx

    mov ax, rx1          ; save the caller's rectangle
    mov sx1, ax
    mov ax, ry1
    mov sy1, ax
    mov ax, rx2
    mov sx2, ax
    mov ax, ry2
    mov sy2, ax

    mov ax, sy1
    mov ry1, ax
    mov ry2, ax
    call fill_rect

    mov ax, sy1
    inc ax
    mov ry1, ax
    mov ry2, ax
    call fill_rect

    mov ax, sy2
    mov ry1, ax
    mov ry2, ax
    call fill_rect

    mov ax, sy2
    dec ax
    mov ry1, ax
    mov ry2, ax
    call fill_rect

    mov ax, sy1
    mov ry1, ax
    mov ax, sy2
    mov ry2, ax

    mov ax, sx1
    mov rx1, ax
    mov rx2, ax
    call fill_rect

    mov ax, sx1
    inc ax
    mov rx1, ax
    mov rx2, ax
    call fill_rect

    mov ax, sx2
    mov rx1, ax
    mov rx2, ax
    call fill_rect

    mov ax, sx2
    dec ax
    mov rx1, ax
    mov rx2, ax
    call fill_rect

    mov ax, sx1
    mov rx1, ax
    mov ax, sx2
    mov rx2, ax
    mov ax, sy1
    mov ry1, ax
    mov ax, sy2
    mov ry2, ax

    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_border endp

clear_screen proc
    push ax
    mov rx1, 0
    mov ry1, 0
    mov rx2, 319
    mov ry2, 199
    call fill_rect
    pop ax
    ret
clear_screen endp

draw_star_field proc
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    lea si, stars
    mov cx, 40

dsf1_loop:
    push cx
    xor bx, bx
    mov bl, [si]
    xor ax, ax
    mov al, [si+1]
    mov dx, 320
    mul dx
    add ax, bx
    mov di, ax
    mov byte ptr es:[di], COL_WHITE
    add si, 2
    pop cx
    loop dsf1_loop

    lea si, stars2
    mov cx, 20

dsf2_loop:
    push cx
    xor bx, bx
    mov bl, [si]
    xor ax, ax
    mov al, [si+1]
    mov dx, 320
    mul dx
    add ax, bx
    mov di, ax
    mov byte ptr es:[di],   COL_DKCYAN
    mov byte ptr es:[di+1], COL_DKCYAN
    add di, 320
    mov byte ptr es:[di],   COL_DKCYAN
    mov byte ptr es:[di+1], COL_DKCYAN
    add si, 2
    pop cx
    loop dsf2_loop

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_star_field endp

draw_diagonal_stripes proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov bx, 0

dds_outer:
    cmp bx, 11
    jge dds_done

    mov ax, bx
    mov cl, 5
    shl ax, cl

    mov cx, 0

dds_inner:
    cmp cx, 320
    jge dds_next

    push ax
    sub ax, cx
    cmp ax, 0
    jl  dds_skip
    cmp ax, 49
    jg  dds_skip

    push dx
    mov dx, 320
    mul dx
    add ax, cx
    mov di, ax
    mov byte ptr es:[di], 22
    pop dx

dds_skip:
    pop ax
    inc cx
    jmp dds_inner

dds_next:
    inc bx
    jmp dds_outer

dds_done:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_diagonal_stripes endp

draw_gradient_bg proc
    push ax

    mov rcol, 16
    mov rx1, 0
    mov rx2, 319
    mov ry1, 0
    mov ry2, 199
    call fill_rect

    mov rcol, 17
    mov ry1, 0
    mov ry2, 28
    call fill_rect

    mov rcol, 18
    mov ry1, 160
    mov ry2, 199
    call fill_rect

    mov rcol, 22
    mov ry1, 29
    mov ry2, 30
    call fill_rect

    mov rcol, 21
    mov ry1, 31
    mov ry2, 31
    call fill_rect

    call draw_star_field

    pop ax
    ret
draw_gradient_bg endp

draw_letter proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov bx, ltr_ptr
    mov dx, 7

dl_row:
    cmp dx, 0
    je  dl_done

    mov al, [bx]
    push dx

    mov dx, di
    mov cx, 8

dl_bit:
    test al, 10000000b
    jz  dl_skip

    push ax
    push cx
    push dx

    mov rx1, dx
    mov ax, dx
    add ax, 2
    mov rx2, ax
    mov ry1, si
    mov ax, si
    add ax, 4
    mov ry2, ax
    call fill_rect

    pop dx
    pop cx
    pop ax

dl_skip:
    shl al, 1
    add dx, 3
    loop dl_bit

    pop dx
    inc bx
    add si, 5
    dec dx
    jmp dl_row

dl_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_letter endp

draw_letter_short proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov bx, ltr_ptr
    mov dx, 7

dls_row:
    cmp dx, 0
    je  dls_done

    mov al, [bx]
    push dx

    mov dx, di
    mov cx, 8

dls_bit:
    test al, 10000000b
    jz  dls_skip

    push ax
    push cx
    push dx

    mov rx1, dx
    mov ax, dx
    add ax, 2
    mov rx2, ax
    mov ry1, si
    mov ax, si
    add ax, 3
    mov ry2, ax
    call fill_rect

    pop dx
    pop cx
    pop ax

dls_skip:
    shl al, 1
    add dx, 3
    loop dls_bit

    pop dx
    inc bx
    add si, 4
    dec dx
    jmp dls_row

dls_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_letter_short endp

draw_title proc
    push si
    push di

    ; big brick title used only on the home screen
    mov si, 60
    mov di, 92
    mov rcol, 22

    mov ltr_ptr, offset ltr_B
    call draw_letter_short
    add di, 28

    mov ltr_ptr, offset ltr_R
    call draw_letter_short
    add di, 28

    mov ltr_ptr, offset ltr_I
    call draw_letter_short
    add di, 28

    mov ltr_ptr, offset ltr_C
    call draw_letter_short
    add di, 28

    mov ltr_ptr, offset ltr_K
    call draw_letter_short

    pop di
    pop si
    ret
draw_title endp

draw_home_panel proc
    push ax

    mov rcol, 22
    mov rx1, 52
    mov ry1, 46
    mov rx2, 272
    mov ry2, 154
    call fill_rect

    mov rcol, 20
    mov rx1, 48
    mov ry1, 42
    mov rx2, 268
    mov ry2, 150
    call fill_rect

    mov rcol, 21
    call draw_border

    mov rcol, 22
    mov rx1, 52
    mov ry1, 46
    mov rx2, 264
    mov ry2, 49
    call fill_rect

    mov rcol, 21
    mov ry1, 142
    mov ry2, 143
    call fill_rect

    pop ax
    ret
draw_home_panel endp

show_home_screen proc
    call enter_mode13
    call set_palette

    call draw_gradient_bg
    call draw_diagonal_stripes
    call draw_title

    ; small sparkles around the title keep the screen lively without a full box
    mov rcol, 21
    mov rx1, 92
    mov ry1, 70
    mov rx2, 93
    mov ry2, 71
    call fill_rect

    mov rx1, 228
    mov rx2, 229
    call fill_rect

    mov rx1, 72
    mov ry1, 92
    mov rx2, 73
    mov ry2, 93
    call fill_rect

    mov rx1, 247
    mov rx2, 248
    call fill_rect

    mov rcol, 22
    mov rx1, 110
    mov ry1, 106
    mov rx2, 111
    mov ry2, 107
    call fill_rect

    mov rx1, 210
    mov rx2, 211
    call fill_rect

    mov rx1, 86
    mov ry1, 118
    mov rx2, 87
    mov ry2, 119
    call fill_rect

    mov rx1, 232
    mov rx2, 233
    call fill_rect

    ; clean title accents under the stack
    mov rcol, 22
    mov rx1, 104
    mov rx2, 216
    mov ry1, 98
    mov ry2, 98
    call fill_rect

    mov rcol, 21
    mov rx1, 112
    mov rx2, 208
    mov ry1, 101
    mov ry2, 101
    call fill_rect

    mov rcol, 21
    mov rx1, 82
    mov rx2, 110
    mov ry1, 111
    mov ry2, 111
    call fill_rect

    mov rx1, 210
    mov rx2, 238
    call fill_rect

    ; breaker sits closer to brick so the two lines feel like one logo
    mov dh, 13
    mov dl, 12
    mov bl, 0bh
    lea si, home_breaker_str
    call print_str

    mov dh, 21
    mov dl, 7
    mov bl, 08h
    lea si, press_str
    call print_str

    call wait_key
    ret
show_home_screen endp

show_name_input proc
    call enter_mode13
    call set_palette

    ; same background style as the other iteration 1 screens
    call draw_gradient_bg

    ; outer glow panel
    mov rcol, 22
    mov rx1, 44
    mov ry1, 26
    mov rx2, 284
    mov ry2, 166
    call fill_rect

    mov rcol, 20
    mov rx1, 40
    mov ry1, 22
    mov rx2, 280
    mov ry2, 162
    call fill_rect

    ; cyan border keeps the panel easy to read
    mov rcol, 21
    call draw_border

    ; top title strip
    mov rcol, 22
    mov rx1, 44
    mov ry1, 26
    mov rx2, 276
    mov ry2, 36
    call fill_rect

    mov rcol, 21
    mov ry1, 37
    mov ry2, 37
    call fill_rect

    ; centered input box
    mov rcol, 22
    mov rx1, 58
    mov ry1, 84
    mov rx2, 262
    mov ry2, 109
    call fill_rect

    mov rcol, 18
    mov rx1, 60
    mov ry1, 86
    mov rx2, 260
    mov ry2, 107
    call fill_rect

    mov rcol, 21
    call draw_border

    mov dh, 4
    mov dl, 14
    mov bl, 0dh
    lea si, ni_title_str
    call print_str

    ; keep the label above the input field so it stays visible
    mov dh, 9
    mov dl, 9
    mov bl, 0bh
    lea si, ni_label
    call print_str

    mov name_len, 0
    lea di, player_name
    mov cx, 16
    mov al, 0
    rep stosb

ni_loop:
    ; redraw the input field each keypress so typing looks clean
    mov rcol, 18
    mov rx1, 61
    mov ry1, 87
    mov rx2, 259
    mov ry2, 106
    call fill_rect

    ; typed text stays inside the middle of the box
    mov dh, 11
    mov dl, 13
    mov bl, 0fh
    lea si, player_name
    call print_str

    xor bx, bx
    mov bl, name_len
    add bl, 13
    mov dh, 11
    mov dl, bl
    mov al, '_'
    mov bl, 0eh
    call print_char

    mov ah, 00h          ; wait for one key
    int 16h

    cmp ah, 1ch
    je  ni_done

    cmp ah, 0eh
    je  ni_bksp

    cmp name_len, 14
    jge ni_loop

    cmp al, 32
    jl  ni_loop

ni_store:

    xor bx, bx
    mov bl, name_len
    lea si, player_name
    add si, bx
    mov [si], al
    inc name_len
    jmp ni_loop

ni_bksp:
    ; erase the last typed character
    cmp name_len, 0
    je  ni_loop
    dec name_len
    xor bx, bx
    mov bl, name_len
    lea si, player_name
    add si, bx
    mov byte ptr [si], 0
    jmp ni_loop

ni_done:
    ret
show_name_input endp

draw_menu_option proc
    push ax
    push bx
    push cx
    push dx

    mov rx1, 58
    mov rx2, 262
    mov ry1, cx
    mov ry2, bx
    cmp al, 1
    jne dmo_normal

    mov rcol, 22
    call fill_rect
    mov rcol, 21
    call draw_border
    push si
    push dx
    mov bl, 0fh
    call print_str
    pop dx
    pop si
    jmp dmo_done

dmo_normal:
    mov rcol, 18
    call fill_rect
    mov rcol, 22
    call draw_border
    push si
    push dx
    mov bl, 0dh
    call print_str
    pop dx
    pop si

dmo_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_menu_option endp

redraw_menu_options proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov cx, 80
    mov bx, 97
    mov dh, 11
    mov dl, 15
    lea si, opt0_lbl
    mov al, 0
    cmp menu_sel, 0
    jne rmo_0
    mov al, 1
rmo_0:
    call draw_menu_option

    mov cx, 106
    mov bx, 123
    mov dh, 14
    mov dl, 14
    lea si, opt1_lbl
    mov al, 0
    cmp menu_sel, 1
    jne rmo_1
    mov al, 1
rmo_1:
    call draw_menu_option

    mov cx, 132
    mov bx, 149
    mov dh, 17
    mov dl, 14
    lea si, opt2_lbl
    mov al, 0
    cmp menu_sel, 2
    jne rmo_2
    mov al, 1
rmo_2:
    call draw_menu_option

    mov cx, 158
    mov bx, 175
    mov dh, 20
    mov dl, 18
    lea si, opt3_lbl
    mov al, 0
    cmp menu_sel, 3
    jne rmo_3
    mov al, 1
rmo_3:
    call draw_menu_option

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
redraw_menu_options endp

draw_menu_static proc
    push ax
    push bx
    push si
    push dx

    call draw_gradient_bg

    mov rcol, 17
    mov ry1, 0
    mov ry2, 18
    call fill_rect

    mov rcol, 22
    mov ry1, 19
    mov ry2, 20
    call fill_rect

    mov rcol, 20
    mov rx1, 44
    mov ry1, 30
    mov rx2, 276
    mov ry2, 186
    call fill_rect

    mov rcol, 21
    call draw_border

    mov rcol, 22
    mov rx1, 48
    mov rx2, 272
    mov ry1, 53
    mov ry2, 54
    call fill_rect

    mov rcol, 22
    mov rx1, 50
    mov rx2, 56
    mov ry1, 31
    mov ry2, 185
    call fill_rect

    mov rx1, 264
    mov rx2, 270
    call fill_rect

    mov rcol, 17
    mov rx1, 0
    mov rx2, 319
    mov ry1, 191
    mov ry2, 199
    call fill_rect

    mov rcol, 21
    mov ry1, 191
    mov ry2, 191
    call fill_rect

    mov dh, 1
    mov dl, 13
    mov bl, 0dh
    lea si, mm_header_str
    call print_str

    mov dh, 5
    mov dl, 15
    mov bl, 0bh
    lea si, mm_sub_str
    call print_str

    mov dh, 24
    mov dl, 8
    mov bl, 08h
    lea si, mm_hint_str
    call print_str

    mov dh, 23
    mov dl, 15
    mov bl, 0bh
    lea si, mm_plyr_str
    call print_str

    lea si, player_name
    mov bl, 0fh
    call print_str

    pop dx
    pop si
    pop bx
    pop ax
    ret
draw_menu_static endp

show_main_menu proc
    call enter_mode13
    call set_palette

    call draw_menu_static
    mov menu_sel, 0
    call redraw_menu_options

smm_loop:
    mov ah, 00h
    int 16h

    cmp ah, 48h
    je  smm_up

    cmp ah, 50h
    je  smm_down

    cmp ah, 1ch
    je  smm_enter

    jmp smm_loop

smm_up:
    cmp menu_sel, 0
    je  smm_loop
    dec menu_sel
    call redraw_menu_options
    jmp smm_loop

smm_down:
    cmp menu_sel, 3
    je  smm_loop
    inc menu_sel
    call redraw_menu_options
    jmp smm_loop

smm_enter:
    cmp menu_sel, 0
    je  smm_start

    cmp menu_sel, 1
    je  smm_instr

    cmp menu_sel, 2
    je  smm_hiscore

    ret

smm_start:
    call show_game_screen
    call enter_mode13
    call set_palette
    call draw_menu_static
    call redraw_menu_options
    jmp smm_loop

smm_instr:
    call show_instructions
    call enter_mode13
    call set_palette
    call draw_menu_static
    call redraw_menu_options
    jmp smm_loop

smm_hiscore:
    call show_high_scores
    call enter_mode13
    call set_palette
    call draw_menu_static
    call redraw_menu_options
    jmp smm_loop
show_main_menu endp

show_instructions proc
    call enter_mode13
    call set_palette

    call draw_gradient_bg

    mov rcol, 17
    mov rx1, 0
    mov rx2, 319
    mov ry1, 0
    mov ry2, 18
    call fill_rect

    mov rcol, 22
    mov ry1, 19
    mov ry2, 20
    call fill_rect

    mov rcol, 20
    mov rx1, 10
    mov ry1, 22
    mov rx2, 309
    mov ry2, 186
    call fill_rect

    mov rcol, 21
    call draw_border

    mov rcol, 17
    mov rx1, 0
    mov rx2, 319
    mov ry1, 190
    mov ry2, 199
    call fill_rect

    mov rcol, 21
    mov ry1, 190
    mov ry2, 190
    call fill_rect

    mov rcol, 22
    mov rx1, 18
    mov rx2, 301

    mov ry1, 32
    mov ry2, 40
    call fill_rect

    mov ry1, 74
    mov ry2, 82
    call fill_rect

    mov ry1, 114
    mov ry2, 122
    call fill_rect

    mov ry1, 154
    mov ry2, 162
    call fill_rect

    mov dh, 1
    mov dl, 14
    mov bl, 0dh
    lea si, in_title
    call print_str

    mov dh, 4
    mov dl, 4
    mov bl, 0bh
    lea si, in_c_hdr
    call print_str

    mov dh, 6
    mov dl, 4
    mov bl, 0fh
    lea si, in_c1
    call print_str

    mov dh, 7
    mov dl, 4
    mov bl, 0fh
    lea si, in_c2
    call print_str

    mov dh, 10
    mov dl, 4
    mov bl, 0bh
    lea si, in_o_hdr
    call print_str

    mov dh, 12
    mov dl, 4
    mov bl, 0fh
    lea si, in_o1
    call print_str

    mov dh, 13
    mov dl, 4
    mov bl, 0fh
    lea si, in_o2
    call print_str

    mov dh, 15
    mov dl, 4
    mov bl, 0bh
    lea si, in_l_hdr
    call print_str

    mov dh, 17
    mov dl, 4
    mov bl, 0fh
    lea si, in_l1
    call print_str

    mov dh, 18
    mov dl, 4
    mov bl, 0fh
    lea si, in_l2
    call print_str

    mov dh, 20
    mov dl, 4
    mov bl, 0bh
    lea si, in_b_hdr
    call print_str

    mov dh, 22
    mov dl, 4
    mov bl, 0fh
    lea si, in_b1
    call print_str

    mov dh, 24
    mov dl, 7
    mov bl, 0fh
    lea si, back_str
    call print_str

    call wait_key
    ret
show_instructions endp

show_high_scores proc
    call enter_mode13
    call set_palette

    call draw_gradient_bg

    mov rcol, 17
    mov rx1, 0
    mov rx2, 319
    mov ry1, 0
    mov ry2, 18
    call fill_rect

    mov rcol, 22
    mov ry1, 19
    mov ry2, 20
    call fill_rect

    mov rcol, 20
    mov rx1, 18
    mov ry1, 24
    mov rx2, 301
    mov ry2, 186
    call fill_rect

    mov rcol, 21
    call draw_border

    mov rcol, 22
    mov rx1, 24
    mov ry1, 38
    mov rx2, 295
    mov ry2, 47
    call fill_rect

    mov rcol, 21
    mov ry1, 48
    mov ry2, 49
    call fill_rect

    mov rcol, 18
    mov rx1, 24
    mov rx2, 295

    mov ry1, 60
    mov ry2, 70
    call fill_rect

    mov ry1, 92
    mov ry2, 102
    call fill_rect

    mov ry1, 124
    mov ry2, 134
    call fill_rect

    mov rcol, 17
    mov rx1, 0
    mov rx2, 319
    mov ry1, 190
    mov ry2, 199
    call fill_rect

    mov rcol, 21
    mov ry1, 190
    mov ry2, 190
    call fill_rect

    mov dh, 1
    mov dl, 14
    mov bl, 0dh
    lea si, hs_title
    call print_str

    mov dh, 5
    mov dl, 4
    mov bl, 0fh
    lea si, hs_clbl
    call print_str

    mov dh, 8
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r1
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_n1
    call print_str
    mov dl, 30
    mov bl, 0eh
    lea si, hs_s1
    call print_str

    mov dh, 11
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r2
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_n2
    call print_str
    mov dl, 30
    mov bl, 0eh
    lea si, hs_s2
    call print_str

    mov dh, 14
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r3
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_n3
    call print_str
    mov dl, 30
    mov bl, 0eh
    lea si, hs_s3
    call print_str

    mov dh, 17
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r4
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_n4
    call print_str
    mov dl, 30
    mov bl, 0eh
    lea si, hs_s4
    call print_str

    mov dh, 20
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r5
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_n5
    call print_str
    mov dl, 30
    mov bl, 0eh
    lea si, hs_s5
    call print_str

    mov dh, 24
    mov dl, 7
    mov bl, 0fh
    lea si, back_str
    call print_str

    call wait_key
    ret
show_high_scores endp

draw_heart proc
    push ax

    ; top lobes
    mov ax, hx
    mov rx1, ax
    add ax, 2
    mov rx2, ax
    mov ax, hy
    mov ry1, ax
    add ax, 2
    mov ry2, ax
    call fill_rect

    mov ax, hx
    add ax, 4
    mov rx1, ax
    add ax, 2
    mov rx2, ax
    mov ax, hy
    mov ry1, ax
    add ax, 2
    mov ry2, ax
    call fill_rect

    ; middle band joins both sides
    mov ax, hx
    add ax, 1
    mov rx1, ax
    add ax, 4
    mov rx2, ax
    mov ax, hy
    add ax, 2
    mov ry1, ax
    add ax, 1
    mov ry2, ax
    call fill_rect

    ; lower body narrows the shape
    mov ax, hx
    add ax, 2
    mov rx1, ax
    add ax, 2
    mov rx2, ax
    mov ax, hy
    add ax, 4
    mov ry1, ax
    add ax, 1
    mov ry2, ax
    call fill_rect

    ; bottom tip finishes the heart
    mov ax, hx
    add ax, 3
    mov rx1, ax
    mov rx2, ax
    mov ax, hy
    add ax, 6
    mov ry1, ax
    add ax, 1
    mov ry2, ax
    call fill_rect

    pop ax
    ret
draw_heart endp

draw_brick_row_game proc
    push ax
    push bx
    push cx
    push si

    mov si, 0           ; si walks through all 9 bricks in the row

dbrg_loop:
    cmp si, 9
    jge dbrg_done

    mov ax, si          ; x position = 4 + index * 34
    mov bx, 34
    mul bx
    add ax, 4
    mov rx1, ax
    add ax, 28
    mov rx2, ax

    mov ax, bry1
    mov ry1, ax
    mov ax, bry2
    mov ry2, ax

    mov al, brcol       ; fill the brick with the current row color
    mov rcol, al
    call fill_rect

    mov ax, rx2         ; dark line on the right gives each brick separation
    inc ax
    mov rx1, ax
    mov rx2, ax
    mov rcol, COL_BLACK
    call fill_rect

    mov ax, si          ; dark line below the brick
    mov bx, 34
    mul bx
    add ax, 4
    mov rx1, ax
    add ax, 28
    mov rx2, ax
    mov ax, bry2
    inc ax
    mov ry1, ax
    mov ry2, ax
    call fill_rect

    mov ax, si          ; white corner highlight makes the brick pop a bit
    mov bx, 34
    mul bx
    add ax, 4
    mov rx1, ax
    mov rx2, ax
    mov ax, bry1
    mov ry1, ax
    mov ry2, ax
    mov rcol, COL_WHITE
    call fill_rect

    inc si
    jmp dbrg_loop

dbrg_done:
    pop si
    pop cx
    pop bx
    pop ax
    ret
draw_brick_row_game endp

show_game_screen proc
    call enter_mode13
    call set_palette

    ; dark frame first, then place the playable area inside it
    mov rcol, 16
    mov rx1, 0
    mov rx2, 319
    mov ry1, 0
    mov ry2, 199
    call fill_rect

    mov rcol, 18
    mov rx1, 4
    mov ry1, 17
    mov rx2, 315
    mov ry2, 199
    call fill_rect

    mov rcol, 22
    mov rx1, 0
    mov rx2, 319
    mov ry1, 0
    mov ry2, 14
    call fill_rect

    ; thin neon separator under the HUD
    mov rcol, 21
    mov ry1, 15
    mov ry2, 16
    call fill_rect

    ; side walls stay visible so later collision logic has clear bounds
    mov rcol, 20
    mov rx1, 0
    mov rx2, 3
    mov ry1, 17
    mov ry2, 199
    call fill_rect

    mov rcol, 21
    mov rx1, 3
    mov rx2, 3
    call fill_rect

    mov rcol, 20
    mov rx1, 316
    mov rx2, 319
    call fill_rect

    mov rcol, 21
    mov rx1, 316
    mov rx2, 316
    call fill_rect

    ; leave some open space under the brick rows for the real ball path later
    mov bry1, 24
    mov bry2, 34
    mov brcol, 22
    call draw_brick_row_game

    mov bry1, 40
    mov bry2, 50
    mov brcol, COL_LTMAG
    call draw_brick_row_game

    mov bry1, 56
    mov bry2, 66
    mov brcol, 21
    call draw_brick_row_game

    mov bry1, 72
    mov bry2, 82
    mov brcol, COL_LTBLUE
    call draw_brick_row_game

    mov bry1, 88
    mov bry2, 98
    mov brcol, COL_WHITE
    call draw_brick_row_game

    ; bright paddle so it stands out from the field
    mov rcol, 21
    mov rx1, 124
    mov ry1, 182
    mov rx2, 196
    mov ry2, 188
    call fill_rect

    mov rcol, COL_WHITE
    mov rx1, 124
    mov ry1, 182
    mov rx2, 196
    mov ry2, 183
    call fill_rect

    mov rcol, 22
    mov rx1, 124
    mov rx2, 126
    mov ry1, 182
    mov ry2, 188
    call fill_rect

    mov rx1, 194
    mov rx2, 196
    call fill_rect

    ; round-ish ball: red glow with bright center
    mov rcol, COL_LTRED
    mov rx1, 154
    mov ry1, 149
    mov rx2, 159
    mov ry2, 149
    call fill_rect

    mov rx1, 154
    mov ry1, 150
    mov rx2, 159
    mov ry2, 155
    call fill_rect

    mov rx1, 154
    mov ry1, 156
    mov rx2, 159
    mov ry2, 156
    call fill_rect

    mov rx1, 153
    mov ry1, 151
    mov rx2, 153
    mov ry2, 154
    call fill_rect

    mov rx1, 160
    mov ry1, 151
    mov rx2, 160
    mov ry2, 154
    call fill_rect

    mov rcol, COL_YELLOW
    mov rx1, 155
    mov ry1, 150
    mov rx2, 158
    mov ry2, 153
    call fill_rect

    mov rcol, COL_WHITE
    mov rx1, 156
    mov ry1, 150
    mov rx2, 156
    mov ry2, 151
    call fill_rect

    mov rcol, COL_DKGRAY
    mov rx1, 158
    mov ry1, 154
    mov rx2, 159
    mov ry2, 155
    call fill_rect

    ; level stays on the top-left
    mov dh, 0
    mov dl, 1
    mov bl, 0bh
    lea si, hud_level
    call print_str
    
    ; score sits just below it
    mov dh, 1
    mov dl, 1
    mov bl, 0fh
    lea si, hud_score
    call print_str
    
    ; dark backing makes the hearts visible against the hud bar
    mov rcol, 16
    mov rx1, 142
    mov rx2, 180
    mov ry1, 1
    mov ry2, 11
    call fill_rect

    ; hearts themselves act as the visual life counter
    mov rcol, 22
    mov hx, 146
    mov hy, 3
    call draw_heart

    mov hx, 158
    call draw_heart

    mov hx, 170
    call draw_heart

    ; player name stays on the right side of the HUD
    mov dh, 0
    mov dl, 26
    mov bl, 0fh
    lea si, player_name
    call print_str

    call wait_key

    mov ax, @data
    mov ds, ax
    ret
show_game_screen endp

main proc
    mov ax, @data
    mov ds, ax

    call show_home_screen

    mov ax, @data
    mov ds, ax

    call show_name_input

    mov ax, @data
    mov ds, ax

    call show_main_menu

    mov ax, 0003h
    int 10h

    mov ah, 4ch
    mov al, 0
    int 21h
main endp

end main
