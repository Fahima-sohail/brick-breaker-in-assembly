; ================================================================
; brick_breaker_iter1_fixed.asm
; iteration 1 - graphics and ui prototype
; ee-2003 computer organization and assembly language
; fast-nuces islamabad, spring 2026
;
; compile in dosbox with masm615:
;   ml brick_breaker_iter1_fixed.asm
;   link brick_breaker_iter1_fixed;
;   brick_breaker_iter1_fixed.exe
; ================================================================

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

GAME_LEFT      equ 4
GAME_RIGHT     equ 315
GAME_TOP       equ 17
GAME_BOTTOM    equ 199

PADDLE_Y       equ 182
PADDLE_H       equ 7
PADDLE_W       equ 56
PADDLE_MIN_X   equ GAME_LEFT
PADDLE_MAX_X   equ GAME_RIGHT - PADDLE_W + 1
PADDLE_SPEED   equ 4

BALL_SIZE      equ 4
BALL_STEP      equ 2

BRICK_ROWS     equ 5
BRICK_COLS     equ 9
BRICK_STEP_X   equ 34
BRICK_STEP_Y   equ 16
BRICK_START_Y  equ 24
BRICK_DRAW_W   equ 30
BRICK_DRAW_H   equ 12
BRICK_FILL_W   equ 29
BRICK_FILL_H   equ 11
BRICK_SCORE    equ 10

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

hud_score  db "SCORE 0000", 0
hud_lives  db "LIVES 3", 0
hud_level  db "LEVEL 1", 0
hud_namelb db "PLAYER:", 0

go_title   db "GAME OVER", 0
go_score   db "FINAL SCORE 0000", 0
go_hint    db "PRESS ANY KEY FOR MENU", 0

lc_title   db "LEVEL COMPLETE!", 0
lc_score   db "SCORE 0000", 0
lc_hint    db "PRESS ANY KEY FOR MENU", 0

life_msg1  db "YOU LOST A LIFE!", 0
life_msg2  db "GET READY...", 0

input_dir      db 0
lives_left     db 3
game_over_flag     db 0
level_complete_flag db 0

; ---------------------------------------------------------------
; ITERATION 3 STUBS - variables reserved for future use
; current_level   db 1   ; active level number (1-3)
; bonus_active    db 0   ; 1 = a bonus is falling on screen
; bonus_x         dw 0   ; falling bonus pixel X
; bonus_y         dw 0   ; falling bonus pixel Y
; bonus_type      db 0   ; 1=SlowBall 2=ExtraLife 3=WidePaddle
; bonus_timer     dw 0   ; frames remaining for timed effects
; ball_dx2        dw 0   ; second ball for multi-ball bonus (iter3)
; ball_dy2        dw 0
; ball_x2         dw 0
; ball_y2         dw 0
; ---------------------------------------------------------------

score_value  dw 0
bricks_left  dw 45
paddle_x     dw 132
ball_x       dw 158
ball_y       dw 176
ball_dx      dw BALL_STEP
ball_dy      dw -BALL_STEP

brick_row_idx db 0
brick_col_idx db 0
brick_colors  db 22, COL_LTMAG, 21, COL_LTBLUE, COL_WHITE
brick_state   db 45 dup(1)

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
    ; teletype output looks cleaner here because it does not paint a full black cell
    mov ah, 0eh
    mov bh, 00h
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

write_ax_4digits proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov bx, 10
    mov cx, 4

w4_loop:
    xor dx, dx
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    loop w4_loop

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
write_ax_4digits endp

update_score_string proc
    push ax
    push di

    mov ax, score_value
    lea di, hud_score + 9
    call write_ax_4digits

    mov ax, score_value
    lea di, go_score + 15
    call write_ax_4digits

    mov ax, score_value
    lea di, lc_score + 9
    call write_ax_4digits

    pop di
    pop ax
    ret
update_score_string endp

update_lives_string proc
    push ax

    mov al, lives_left
    add al, '0'
    mov byte ptr [hud_lives+6], al

    pop ax
    ret
update_lives_string endp

init_bricks proc
    push ax
    push cx
    push di
    push es

    ; Save ES and point it at the data segment so rep stosb
    ; writes to brick_state in .DATA, not to video memory (A000h)
    ; which ES may still point at after enter_mode13.
    push ds
    pop es

    lea di, brick_state
    mov al, 1
    mov cx, 45
    rep stosb
    mov bricks_left, 45

    pop es
    pop di
    pop cx
    pop ax
    ret
init_bricks endp

reset_paddle_and_ball proc
    mov paddle_x, 132
    mov ball_x, 158
    mov ball_y, 176
    mov ball_dx, BALL_STEP
    mov ball_dy, -BALL_STEP
    ret
reset_paddle_and_ball endp

init_level_state proc
    mov score_value, 0
    mov lives_left, 3
    mov game_over_flag, 0
    mov level_complete_flag, 0
    call init_bricks
    call reset_paddle_and_ball
    call update_score_string
    call update_lives_string
    ret
init_level_state endp

build_brick_rect proc
    push ax
    push bx

    xor ax, ax
    mov al, brick_col_idx
    mov bx, BRICK_STEP_X
    mul bx
    add ax, GAME_LEFT
    mov rx1, ax
    add ax, BRICK_DRAW_W - 1
    mov rx2, ax

    xor ax, ax
    mov al, brick_row_idx
    mov bx, BRICK_STEP_Y
    mul bx
    add ax, BRICK_START_Y
    mov ry1, ax
    add ax, BRICK_DRAW_H - 1
    mov ry2, ax

    pop bx
    pop ax
    ret
build_brick_rect endp

draw_current_brick proc
    push ax
    push bx

    call build_brick_rect

    mov ax, rx1
    mov sx1, ax
    mov ax, ry1
    mov sy1, ax

    xor bx, bx
    mov bl, brick_row_idx
    mov al, brick_colors[bx]
    mov rcol, al

    mov ax, sx1
    mov rx1, ax
    add ax, BRICK_FILL_W - 1
    mov rx2, ax
    mov ax, sy1
    mov ry1, ax
    add ax, BRICK_FILL_H - 1
    mov ry2, ax
    call fill_rect

    mov rcol, COL_BLACK
    mov ax, sx1
    add ax, BRICK_DRAW_W - 1
    mov rx1, ax
    mov rx2, ax
    mov ax, sy1
    mov ry1, ax
    add ax, BRICK_FILL_H - 1
    mov ry2, ax
    call fill_rect

    mov ax, sx1
    mov rx1, ax
    add ax, BRICK_FILL_W - 1
    mov rx2, ax
    mov ax, sy1
    add ax, BRICK_DRAW_H - 1
    mov ry1, ax
    mov ry2, ax
    call fill_rect

    mov rcol, COL_WHITE
    mov ax, sx1
    mov rx1, ax
    mov rx2, ax
    mov ax, sy1
    mov ry1, ax
    mov ry2, ax
    call fill_rect

    pop bx
    pop ax
    ret
draw_current_brick endp

erase_current_brick proc
    call build_brick_rect
    mov rcol, 18
    call fill_rect
    ret
erase_current_brick endp

draw_all_bricks proc
    push ax
    push bx
    push cx
    push di

    xor di, di
    xor bx, bx

dab_row:
    cmp bl, BRICK_ROWS
    jge dab_done

    xor cx, cx

dab_col:
    cmp cl, BRICK_COLS
    jge dab_next_row

    mov al, brick_state[di]
    cmp al, 0
    je  dab_skip

    mov brick_row_idx, bl
    mov brick_col_idx, cl
    call draw_current_brick

dab_skip:
    inc di
    inc cl
    jmp dab_col

dab_next_row:
    inc bl
    jmp dab_row

dab_done:
    pop di
    pop cx
    pop bx
    pop ax
    ret
draw_all_bricks endp

draw_game_background proc
    mov rcol, 16
    mov rx1, 0
    mov ry1, 0
    mov rx2, 319
    mov ry2, 199
    call fill_rect

    mov rcol, 18
    mov rx1, GAME_LEFT
    mov ry1, GAME_TOP
    mov rx2, GAME_RIGHT
    mov ry2, GAME_BOTTOM
    call fill_rect

    mov rcol, 20
    mov rx1, 0
    mov rx2, 3
    mov ry1, GAME_TOP
    mov ry2, GAME_BOTTOM
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
    ret
draw_game_background endp

refresh_hud proc
    push ax
    push bx
    push dx
    push si

    call update_lives_string

    mov rcol, 22
    mov rx1, 0
    mov rx2, 319
    mov ry1, 0
    mov ry2, 14
    call fill_rect

    mov rcol, 21
    mov ry1, 15
    mov ry2, 16
    call fill_rect

    mov dh, 0
    mov dl, 1
    mov bl, 0bh
    lea si, hud_level
    call print_str

    mov dh, 1
    mov dl, 1
    mov bl, 0fh
    lea si, hud_score
    call print_str

    mov dh, 0
    mov dl, 12
    mov bl, 0eh
    lea si, hud_lives
    call print_str

    mov dh, 0
    mov dl, 22
    mov bl, 0fh
    lea si, hud_namelb
    call print_str

    mov dh, 0
    mov dl, 30
    mov bl, 0eh
    lea si, player_name
    call print_str

    pop si
    pop dx
    pop bx
    pop ax
    ret
refresh_hud endp

draw_paddle proc
    push ax

    mov rcol, 21
    mov ax, paddle_x
    mov rx1, ax
    mov ry1, PADDLE_Y
    add ax, PADDLE_W - 1
    mov rx2, ax
    mov ry2, PADDLE_Y + PADDLE_H - 1
    call fill_rect

    mov rcol, COL_WHITE
    mov ax, paddle_x
    mov rx1, ax
    mov ry1, PADDLE_Y
    add ax, PADDLE_W - 1
    mov rx2, ax
    mov ry2, PADDLE_Y + 1
    call fill_rect

    mov rcol, 22
    mov ax, paddle_x
    mov rx1, ax
    add ax, 1
    mov rx2, ax
    mov ry1, PADDLE_Y
    mov ry2, PADDLE_Y + PADDLE_H - 1
    call fill_rect

    mov ax, paddle_x
    add ax, PADDLE_W - 2
    mov rx1, ax
    add ax, 1
    mov rx2, ax
    call fill_rect

    pop ax
    ret
draw_paddle endp

erase_paddle proc
    push ax

    mov rcol, 18
    mov ax, paddle_x
    mov rx1, ax
    mov ry1, PADDLE_Y
    add ax, PADDLE_W - 1
    mov rx2, ax
    mov ry2, PADDLE_Y + PADDLE_H - 1
    call fill_rect

    pop ax
    ret
erase_paddle endp

draw_ball proc
    push ax

    mov rcol, COL_LTRED
    mov ax, ball_x
    mov rx1, ax
    mov ax, ball_y
    mov ry1, ax
    mov ax, ball_x
    add ax, BALL_SIZE - 1
    mov rx2, ax
    mov ax, ball_y
    add ax, BALL_SIZE - 1
    mov ry2, ax
    call fill_rect

    mov rcol, COL_YELLOW
    mov ax, ball_x
    inc ax
    mov rx1, ax
    mov ax, ball_y
    inc ax
    mov ry1, ax
    mov ax, ball_x
    add ax, 2
    mov rx2, ax
    mov ax, ball_y
    add ax, 2
    mov ry2, ax
    call fill_rect

    pop ax
    ret
draw_ball endp

erase_ball proc
    push ax

    mov rcol, 18
    mov ax, ball_x
    mov rx1, ax
    mov ax, ball_y
    mov ry1, ax
    mov ax, ball_x
    add ax, BALL_SIZE - 1
    mov rx2, ax
    mov ax, ball_y
    add ax, BALL_SIZE - 1
    mov ry2, ax
    call fill_rect

    pop ax
    ret
erase_ball endp

draw_game_scene proc
    call draw_game_background
    call draw_all_bricks
    call refresh_hud
    call draw_paddle
    call draw_ball
    ret
draw_game_scene endp

read_game_input proc
    push ax

    mov input_dir, 0
    mov ah, 01h
    int 16h
    jz  rgi_done

    mov ah, 00h
    int 16h

    cmp ah, 4bh
    je  rgi_left
    cmp ah, 4dh
    je  rgi_right
    cmp al, 'a'
    je  rgi_left
    cmp al, 'A'
    je  rgi_left
    cmp al, 'd'
    je  rgi_right
    cmp al, 'D'
    je  rgi_right
    cmp al, 27
    je  rgi_escape
    jmp rgi_done

rgi_left:
    mov input_dir, 0ffh
    jmp rgi_done

rgi_right:
    mov input_dir, 1
    jmp rgi_done

rgi_escape:
    mov game_over_flag, 1

rgi_done:
    pop ax
    ret
read_game_input endp

update_paddle_position proc
    push ax
    push bx

    mov bl, input_dir
    cmp bl, 0
    je  upp_done

    mov ax, paddle_x
    cmp bl, 0ffh
    je  upp_left

    add ax, PADDLE_SPEED
    cmp ax, PADDLE_MAX_X
    jle upp_apply
    mov ax, PADDLE_MAX_X
    jmp upp_apply

upp_left:
    sub ax, PADDLE_SPEED
    cmp ax, PADDLE_MIN_X
    jge upp_apply
    mov ax, PADDLE_MIN_X

upp_apply:
    cmp ax, paddle_x
    je  upp_done
    call erase_paddle
    mov paddle_x, ax
    call draw_paddle

upp_done:
    pop bx
    pop ax
    ret
update_paddle_position endp

update_ball_position proc
    push ax

    mov ax, ball_x
    add ax, ball_dx
    mov ball_x, ax

    mov ax, ball_y
    add ax, ball_dy
    mov ball_y, ax

    pop ax
    ret
update_ball_position endp

check_wall_collisions proc
    push ax

    mov ax, ball_x
    cmp ax, GAME_LEFT
    jge cwc_right
    mov ball_x, GAME_LEFT
    neg word ptr ball_dx

cwc_right:
    mov ax, ball_x
    cmp ax, GAME_RIGHT - BALL_SIZE + 1
    jle cwc_top
    mov ball_x, GAME_RIGHT - BALL_SIZE + 1
    neg word ptr ball_dx

cwc_top:
    mov ax, ball_y
    cmp ax, GAME_TOP
    jge cwc_done
    mov ball_y, GAME_TOP
    neg word ptr ball_dy

cwc_done:
    pop ax
    ret
check_wall_collisions endp

check_paddle_collision proc
    push ax
    push bx
    push cx
    push dx

    mov ax, ball_dy
    cmp ax, 0
    jle cpc_done

    mov ax, ball_y
    add ax, BALL_SIZE - 1
    cmp ax, PADDLE_Y
    jl  cpc_done

    mov ax, ball_y
    cmp ax, PADDLE_Y + PADDLE_H - 1
    jg  cpc_done

    mov ax, paddle_x
    mov bx, ball_x
    add bx, BALL_SIZE - 1
    cmp bx, ax
    jl  cpc_done

    mov cx, ax
    add cx, PADDLE_W - 1
    mov dx, ball_x
    cmp dx, cx
    jg  cpc_done

    mov ball_y, PADDLE_Y - BALL_SIZE
    mov ball_dy, -BALL_STEP

    mov dx, ball_x
    add dx, 2
    sub dx, ax
    cmp dx, 18
    jl  cpc_left
    cmp dx, 38
    jg  cpc_right

    mov bx, ball_dx
    cmp bx, 0
    jl  cpc_left
    mov ball_dx, BALL_STEP
    jmp cpc_done

cpc_left:
    mov ball_dx, -BALL_STEP
    jmp cpc_done

cpc_right:
    mov ball_dx, BALL_STEP

cpc_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_paddle_collision endp

check_brick_collision proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov ax, ball_y
    cmp ax, BRICK_START_Y + (BRICK_ROWS * BRICK_STEP_Y)
    jg  cbc_done

    xor di, di
    xor bx, bx

cbc_row:
    cmp bl, BRICK_ROWS
    jge cbc_done

    xor cx, cx

cbc_col:
    cmp cl, BRICK_COLS
    jge cbc_next_row

    mov al, brick_state[di]
    cmp al, 0
    je  cbc_skip

    mov brick_row_idx, bl
    mov brick_col_idx, cl
    call build_brick_rect

    mov ax, ball_x
    add ax, BALL_SIZE - 1
    cmp ax, rx1
    jl  cbc_skip

    mov ax, ball_x
    cmp ax, rx2
    jg  cbc_skip

    mov ax, ball_y
    add ax, BALL_SIZE - 1
    cmp ax, ry1
    jl  cbc_skip

    mov ax, ball_y
    cmp ax, ry2
    jg  cbc_skip

    mov byte ptr brick_state[di], 0
    dec word ptr bricks_left
    call erase_current_brick
    add score_value, BRICK_SCORE
    call update_score_string

    neg word ptr ball_dy
    mov ax, ball_dy
    cmp ax, 0
    jg  cbc_push_down

    mov ax, ry1
    sub ax, BALL_SIZE
    mov ball_y, ax
    jmp cbc_done

cbc_push_down:
    mov ax, ry2
    inc ax
    mov ball_y, ax
    jmp cbc_done

cbc_skip:
    inc di
    inc cl
    jmp cbc_col

cbc_next_row:
    inc bl
    jmp cbc_row

cbc_done:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_brick_collision endp

frame_delay proc
    push cx
    push dx

    mov cx, 35

fd_outer:
    mov dx, 2600

fd_inner:
    dec dx
    jne fd_inner
    loop fd_outer

    pop dx
    pop cx
    ret
frame_delay endp

; ---------------------------------------------------------------
; SHOW LIFE LOST MESSAGE
; Draws a dark banner in the centre of the play field, prints
; "YOU LOST A LIFE!" and "GET READY...", waits ~1.5 seconds
; (90 frame-delay ticks at the current frame rate), then erases
; the banner so the game screen is clean before resuming.
; ---------------------------------------------------------------
show_life_lost_msg proc
    push ax
    push cx

    ; Draw dark semi-transparent banner across the middle of the
    ; play field (y 88-118, full play-field width)
    mov rcol, 20
    mov rx1, GAME_LEFT
    mov rx2, GAME_RIGHT
    mov ry1, 88
    mov ry2, 118
    call fill_rect

    mov rcol, 21
    call draw_border

    ; "YOU LOST A LIFE!" -- centred at row 11 (y~90), col 10
    mov dh, 11
    mov dl, 10
    mov bl, 0ch          ; bright red
    lea si, life_msg1
    call print_str

    ; "GET READY..." -- one row below, slightly indented
    mov dh, 13
    mov dl, 14
    mov bl, 0eh          ; yellow
    lea si, life_msg2
    call print_str

    ; 50 frame-delay iterations
    ; (each frame_delay is ~35*2600 loop ticks; 50 of them ≈1 sec s
    ;  in DOSBox at standard speed -- adjust cx if too fast/slow)
    mov cx, 50

sll_wait:
    call frame_delay
    loop sll_wait

    ; Erase the banner by repainting the background colour over
    ; the same rectangle so bricks/paddle underneath are restored
    ; by the next draw_game_scene call.
    mov rcol, 18
    mov rx1, GAME_LEFT
    mov rx2, GAME_RIGHT
    mov ry1, 88
    mov ry2, 118
    call fill_rect

    pop cx
    pop ax
    ret
show_life_lost_msg endp

handle_ball_missed proc
    push ax

    mov ax, ball_y
    cmp ax, GAME_BOTTOM
    jle hbm_done

    dec lives_left
    call update_lives_string
    cmp lives_left, 0
    jne hbm_reset
    mov game_over_flag, 1
    jmp hbm_done

hbm_reset:
    call reset_paddle_and_ball
    ; Show the "YOU LOST A LIFE!" banner for ~1.5 s, then erase it
    call show_life_lost_msg
    ; Redraw everything cleanly after the banner is gone
    call draw_game_scene

hbm_done:
    pop ax
    ret
handle_ball_missed endp

check_game_end proc
    cmp lives_left, 0
    je  cge_over
    cmp bricks_left, 0
    je  cge_win
    ret

cge_win:
    mov level_complete_flag, 1
    ret

cge_over:
    mov game_over_flag, 1
    ret
check_game_end endp

show_game_over_screen proc
    call enter_mode13
    call set_palette
    call draw_gradient_bg
    call update_score_string

    mov rcol, 20
    mov rx1, 52
    mov ry1, 58
    mov rx2, 267
    mov ry2, 146
    call fill_rect

    mov rcol, 21
    call draw_border

    mov dh, 9
    mov dl, 14
    mov bl, 0eh
    lea si, go_title
    call print_str

    mov dh, 12
    mov dl, 11
    mov bl, 0fh
    lea si, go_score
    call print_str

    mov dh, 14
    mov dl, 11
    mov bl, 0fh
    lea si, mm_plyr_str
    call print_str

    mov dh, 14
    mov dl, 18
    mov bl, 0fh
    lea si, player_name
    call print_str

    mov dh, 17
    mov dl, 7
    mov bl, 0bh
    lea si, go_hint
    call print_str

    call wait_key
    ret
show_game_over_screen endp

; ---------------------------------------------------------------
; LEVEL COMPLETE SCREEN
; Shown when bricks_left reaches 0. Displays score, player name,
; and waits for a key before returning to the main menu.
; In Iteration 3 this will transition to the next level instead.
; ---------------------------------------------------------------
show_level_complete_screen proc
    call enter_mode13
    call set_palette
    call draw_gradient_bg

    ; update lc_score string digits from score_value
    push ax
    push di
    mov ax, score_value
    lea di, lc_score + 9
    call write_ax_4digits
    pop di
    pop ax

    mov rcol, 22
    mov rx1, 52
    mov ry1, 54
    mov rx2, 267
    mov ry2, 150
    call fill_rect

    mov rcol, 21
    call draw_border

    ; Green flash bar at top of panel
    mov rcol, COL_LTGRN
    mov rx1, 54
    mov rx2, 265
    mov ry1, 56
    mov ry2, 64
    call fill_rect

    mov dh, 8
    mov dl, 13
    mov bl, 0ah          ; bright green
    lea si, lc_title
    call print_str

    mov dh, 11
    mov dl, 14
    mov bl, 0fh
    lea si, lc_score
    call print_str

    mov dh, 13
    mov dl, 11
    mov bl, 0fh
    lea si, mm_plyr_str
    call print_str

    mov dh, 13
    mov dl, 18
    mov bl, 0fh
    lea si, player_name
    call print_str

    mov dh, 17
    mov dl, 7
    mov bl, 0bh
    lea si, lc_hint
    call print_str

    call wait_key
    ret
show_level_complete_screen endp
; ---------------------------------------------------------------
; ITERATION 3 HOOK: replace show_level_complete_screen body with
; a call to load_next_level which increments current_level,
; reinitialises bricks with the new layout, resets ball/paddle,
; and jumps back into the game loop rather than returning here.
; ---------------------------------------------------------------

show_game_screen proc
    call enter_mode13
    call set_palette
    call init_level_state
    call draw_game_scene

sg_loop:
    call read_game_input
    cmp game_over_flag, 1
    je  sg_done

    call update_paddle_position
    call erase_ball
    call update_ball_position
    call check_wall_collisions
    call check_paddle_collision
    call check_brick_collision
    call handle_ball_missed
    cmp game_over_flag, 1
    je  sg_done

    call draw_ball
    call refresh_hud
    call frame_delay
    call check_game_end

    ; Check win condition first
    cmp level_complete_flag, 1
    je  sg_level_done

    cmp game_over_flag, 0
    je  sg_loop

sg_done:
    call show_game_over_screen
    mov ax, @data
    mov ds, ax
    ret

sg_level_done:
    call show_level_complete_screen
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