;iter3 wania fahima

.model small
.stack 400h

.data

player_name  db 16 dup(0)
name_len     db 0
menu_sel     db 0   ;which menu option is currently highlighted(0-3)

; shared rectangle inputs for fill_rect / draw_border
rx1   dw 0  ;left X
ry1   dw 0  ;top Y
rx2   dw 0  ;right X
ry2   dw 0  ;bottom Y
rcol  db 0  ;color index to fill with

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
    db 16,  3,  0,  7   ; Color index 16 → R=3, G=0, B=7  (dark indigo)
    db 17, 10,  0, 16   ; Color index 17 → R=10, G=0, B=16
    db 18,  6,  0, 12   ; Color index 18 (used as game background)
    db 19, 12,  0, 20  
    db 20, 16,  3, 24   ; Color index 20 (panel background)
    db 21, 18, 52, 63   ; Color index 21 (bright cyan border)
    db 22, 60,  6, 36   ; Color index 22 (neon green/teal accent)
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
GAME_TOP       equ 17    ; Top wall Y pixel (below HUD
GAME_BOTTOM    equ 199   ; Bottom edge (ball falls off here → life lost)

PADDLE_Y       equ 182
PADDLE_H       equ 7     ; Paddle height in pixels
PADDLE_W       equ 64
PADDLE_WIDE    equ 86
PADDLE_MIN_X   equ GAME_LEFT
PADDLE_MAX_X   equ GAME_RIGHT - PADDLE_W + 1
PADDLE_SPEED   equ 4     ; Pixels moved per keypress

BALL_SIZE      equ 4    ; Ball is a 4×4 pixel square
BALL_STEP      equ 2    ; Base movement speed (pixels per frame)
BONUS_SIZE     equ 8    ; falling bonus item is 8x8 pixcels 
BONUS_FALL     equ 2    ; falls 2 pixel per frame
EFFECT_TIME    equ 450   ;timed bonus lasts 450 game ticks

BRICK_ROWS     equ 5
BRICK_COLS     equ 9  ;45 total bricks
BRICK_STEP_X   equ 34   ; Horizontal gap between brick left edges
BRICK_STEP_Y   equ 16   ; Vertical gap between brick top edges
BRICK_START_Y  equ 24   ; Y coordinate of first brick row
BRICK_DRAW_W   equ 30   ; Total brick width including shadow
BRICK_DRAW_H   equ 12   ; Total brick height including shadow
BRICK_FILL_W   equ 29   ; Colored fill area (1px less than draw)
BRICK_FILL_H   equ 11
BRICK_SCORE    equ 10   ; Points awarded per brick destroyed

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
hs_file  db "BBSCORES.DAT", 0
hs_empty db "---", 0
hs_score_buf db "0000", 0
default_player db "PLAYER", 0

; Five saved rows. Each name gets 16 bytes so it is always safe
; to print as a zero-terminated string.
hs_names  db "---",0,12 dup(0)
          db "---",0,12 dup(0)
          db "---",0,12 dup(0)
          db "---",0,12 dup(0)
          db "---",0,12 dup(0)
hs_scores dw 5 dup(0)

hud_score  db "SCORE 0000", 0
hud_lives  db "LIVES 3", 0
hud_level  db "LEVEL 1", 0
hud_namelb db "PLAYER:", 0

go_title   db "GAME OVER", 0
go_score   db "FINAL SCORE 0000", 0
go_hint    db "PRESS ANY KEY FOR MENU", 0

lc_title   db "LEVEL COMPLETE!", 0
lc_score   db "SCORE 0000", 0
lc_hint    db "PRESS ANY KEY FOR NEXT LEVEL", 0

win_title  db "YOU WIN!", 0
win_score  db "FINAL SCORE 0000", 0
win_hint   db "PRESS ANY KEY FOR MENU", 0

life_msg1  db "YOU LOST A LIFE!", 0
life_msg2  db "GET READY...", 0

input_dir      db 0      ; 0=none, 1=right, 0FFh=left
lives_left     db 3
game_over_flag     db 0
level_complete_flag db 0
quit_to_menu_flag db 0

; ---------------------------------------------------------------
; ITERATION 3 STATE
; These values make the single-level Iteration 2 game behave like a
; full game: three levels, one falling bonus at a time, and timed
; effects that safely return to normal after a few seconds.
; ---------------------------------------------------------------
current_level   db 1
ball_speed      dw BALL_STEP  ;current speed (changes per level)
current_paddle_w dw PADDLE_W  ;current paddle width (changes with bonus)

bonus_active    db 0      ; Is a bonus item currently falling?
bonus_x         dw 0
bonus_y         dw 0      
                ; Position of falling bonus
bonus_type      db 0      ; 1=slow ball, 2=extra life, 3=wide paddle
bonus_timer     dw 0       
timed_effect    db 0      ; remembers which timed effect must be undone
rand_seed       db 37

score_value  dw 0         ; Current score
bricks_left  dw 45        ; Bricks still alive
paddle_x     dw 132       ; Paddle left edge X position
ball_x       dw 158       ; Ball top-left X
ball_y       dw 176       ; Ball top-left Y
ball_dx      dw BALL_STEP    ; Ball horizontal velocity (signed)
ball_dy      dw -BALL_STEP   ; Ball vertical velocity (negative = moving up)

brick_row_idx db 0     ; Loop variable: which row is being processed
brick_col_idx db 0     ; Loop variable: which column
brick_colors  db 22, COL_LTMAG, 21, COL_LTBLUE, COL_WHITE
                       ; One color per row [0..4]: teal, magenta, cyan, blue, white
brick_state   db 45 dup(1)

level1_map db 1,1,1,1,1,1,1,1,1
           db 1,1,1,1,1,1,1,1,1
           db 1,1,1,1,1,1,1,1,1
           db 1,1,1,1,1,1,1,1,1
           db 1,1,1,1,1,1,1,1,1

; Level 2 opens small lanes, so the faster ball changes angle more often.
level2_map db 1,0,1,1,1,1,1,0,1
           db 1,1,1,0,1,0,1,1,1
           db 0,1,1,1,1,1,1,1,0
           db 1,1,0,1,1,1,0,1,1
           db 1,0,1,1,0,1,1,0,1

; Level 3 is a tighter target pattern with the fastest ball speed.
level3_map db 1,1,0,1,1,1,0,1,1
           db 0,1,1,1,0,1,1,1,0
           db 1,1,1,0,1,0,1,1,1
           db 0,1,1,1,1,1,1,1,0
           db 1,0,1,1,1,1,1,0,1

.code

enter_mode13 proc
    push ax
    mov ax, 0013h
    int 10h     ; BIOS: switch to VGA Mode 13h (320×200, 256 colors)
    mov ax, 0a000h
    mov es, ax  ; ES now points to video memory at segment A000h
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
    int 10h    ;this customizes 7 game colors 16-22 into neon game colors
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
    int 16h  ;wait for keypress returns scan code into ah
    pop ax
    ret
wait_key endp

set_cursor proc
    push ax
    push bx
    mov ah, 02h
    mov bh, 00h
    int 10h    ;set text cursos to rox dh col dl
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
    ;text cursor must be there before printing a char
    mov ah, 0eh
    mov bh, 00h
    int 10h   ;pritn al character in color bl
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

; Inputs: rx1, ry1 (top-left), rx2, ry2 (bottom-right), rcol (color)
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
    jg  fr_done          ;stop when past bottom row

    mov ax, si           ; DI = y * 320 + x
    mov dx, 320
    mul dx               ; AX = row * 320  (offset to start of this row)
    add ax, rx1
    mov di, ax           ; di is the destination of vid memory

    mov cx, rx2          ; write one full horizontal span
    sub cx, rx1
    inc cx               ; cs is width or number of pixels to write
    mov al, rcol
    rep stosb            ; Fill CX pixels with color AL  (ES:DI is video memory)

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

;Draws a double-thick border around a rectangle. It:

;Saves rx1/ry1/rx2/ry2 into sx1/sy1/sx2/sy2
;Calls fill_rect 8 times top row, top+1 row, bottom row, bottom-1 row, left column, left+1 column, right column, right-1 column
;Restores the saved coordinat es
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
; 40 single pixel white stars from stars array
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
; 20 double pixel stars from stars 2
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
;draw 11 diagonal stripes across the screen 
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
;full entire screen with color 16 (dark indigo bg)
    mov rcol, 16
    mov rx1, 0
    mov rx2, 319
    mov ry1, 0
    mov ry2, 199
    call fill_rect
;fill top strip with color 17 slightly diff
    mov rcol, 17
    mov ry1, 0
    mov ry2, 28
    call fill_rect
;fill bottom strip with color 18 (game bg)
    mov rcol, 18
    mov ry1, 160
    mov ry2, 199
    call fill_rect
;draw two thin accent lines with colors 22 ND 21
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

    mov al, [bx]    ;load the bitmap byte bx = ltr_ ptr
    push dx

    mov dx, di
    mov cx, 8

dl_bit:
    test al, 10000000b   ;checks the msb
    jz  dl_skip
    ;if msb set call filrect to draw a small block draw letter
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
    shl al, 1   ; now next bit becomes msb
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
; draw letter short is used for home screen brick title
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
    add di, 28  ; space bw brick letters

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
    int 16h ;wait for key press

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
    cmp al, 1     ;al = 1 means highlight flag on
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
    int 16h      ; wait for key

    cmp ah, 48h  ; up -> ( dec menu select ) -> redraw 
    je  smm_up  
   
    cmp ah, 50h   ; down -> (inc menu select) -> redraw
    je  smm_down

    cmp ah, 1ch   ; enter -> branch on menu select
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

load_high_scores proc
    push ax
    push bx
    push cx
    push dx

    mov ah, 3dh    ; open file bbscore.dat
    mov al, 00h
    lea dx, hs_file
    int 21h    
    jc  lhs_done

    mov bx, ax

    mov ah, 3fh  ; read 80 bytes name 
    mov cx, 80
    lea dx, hs_names
    int 21h

    mov ah, 3fh   ; read 10 byte scores
    mov cx, 10
    lea dx, hs_scores
    int 21h

    mov ah, 3eh  ; close
    int 21h

lhs_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
load_high_scores endp

save_high_scores proc
    push ax
    push bx
    push cx
    push dx

    mov ah, 3ch    ; create / overwrite file
    mov cx, 0
    lea dx, hs_file
    int 21h
    jc  shs_done

    mov bx, ax

    mov ah, 40h    ; write  to file
    mov cx, 80
    lea dx, hs_names
    int 21h

    mov ah, 40h  ; write to file
    mov cx, 10
    lea dx, hs_scores
    int 21h

    mov ah, 3eh
    int 21h

shs_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
save_high_scores endp

update_high_scores proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    call load_high_scores

    cmp score_value, 0
    je  uhs_done

    push ds
    pop es

    xor si, si              ; SI is the score-table byte offset
;find where the score value fits into hsscores array
uhs_find_place:
    cmp si, 10
    jae uhs_done
    mov ax, score_value
    cmp ax, hs_scores[si]
    ja  uhs_insert
    add si, 2
    jmp uhs_find_place

uhs_insert:
    mov bx, 8               ; last score offset: row 5 is 4*2

uhs_shift_down:
    cmp bx, si
    jle uhs_write_new

    mov ax, hs_scores[bx-2]
    mov hs_scores[bx], ax

    ; Move the matching name down one row too.
    push si
    push bx
    mov ax, bx
    shl ax, 1
    shl ax, 1
    shl ax, 1               ; score offset * 8 = name offset
    lea di, hs_names
    add di, ax
    mov si, di
    sub si, 16
    mov cx, 16
    cld
    rep movsb   ; shift lower entries fown one position
    pop bx
    pop si

    sub bx, 2
    jmp uhs_shift_down

uhs_write_new:
    mov ax, score_value
    mov hs_scores[si], ax

    mov ax, si
    shl ax, 1
    shl ax, 1
    shl ax, 1
    lea di, hs_names
    add di, ax

    push di
    mov cx, 16
    xor al, al
    cld
    rep stosb
    pop di

    cmp name_len, 0
    jne uhs_use_player_name
    lea si, default_player
    jmp uhs_copy_name

uhs_use_player_name:
    lea si, player_name

uhs_copy_name:
    mov cx, 15

uhs_copy_loop:
    lodsb
    stosb
    cmp al, 0
    je  uhs_saved
    loop uhs_copy_loop
    mov byte ptr [di], 0

uhs_saved:
    call save_high_scores

uhs_done:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
update_high_scores endp

show_high_scores proc
    call enter_mode13
    call set_palette
    call load_high_scores

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
    lea si, hs_names
    call print_str
    mov dl, 30
    mov bl, 0eh
    mov ax, word ptr hs_scores[0]
    lea di, hs_score_buf + 3
    call write_ax_4digits
    lea si, hs_score_buf
    call print_str

    mov dh, 11
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r2
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_names + 16
    call print_str
    mov dl, 30
    mov bl, 0eh
    mov ax, word ptr hs_scores[2]
    lea di, hs_score_buf + 3
    call write_ax_4digits
    lea si, hs_score_buf
    call print_str

    mov dh, 14
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r3
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_names + 32
    call print_str
    mov dl, 30
    mov bl, 0eh
    mov ax, word ptr hs_scores[4]
    lea di, hs_score_buf + 3
    call write_ax_4digits
    lea si, hs_score_buf
    call print_str

    mov dh, 17
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r4
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_names + 48
    call print_str
    mov dl, 30
    mov bl, 0eh
    mov ax, word ptr hs_scores[6]
    lea di, hs_score_buf + 3
    call write_ax_4digits
    lea si, hs_score_buf
    call print_str

    mov dh, 20
    mov dl, 2
    mov bl, 0bh
    lea si, hs_r5
    call print_str
    mov dl, 8
    mov bl, 0fh
    lea si, hs_names + 64
    call print_str
    mov dl, 30
    mov bl, 0eh
    mov ax, word ptr hs_scores[8]
    lea di, hs_score_buf + 3
    call write_ax_4digits
    lea si, hs_score_buf
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
;converts ax a number to 4 digit decimal string stored backwards
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

    mov ax, score_value
    lea di, win_score + 15
    call write_ax_4digits

    pop di
    pop ax
    ret
update_score_string endp

update_level_string proc
    push ax

    mov al, current_level
    add al, '0'     ; convert  digit 1/2/3 to asci 
    mov byte ptr [hud_level+6], al ; overwrite the number character in level 1

    pop ax
    ret
update_level_string endp

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
    push bx
    push cx
    push di
    push si
    push es

    ; ES often points at video memory after drawing. Bring it back
    ; to DS before touching brick_state, otherwise bricks turn into
    ; pixels and the game gets very confused.
    push ds
    pop es

    lea si, level1_map
    cmp current_level, 1
    je  ib_have_map
    lea si, level2_map
    cmp current_level, 2
    je  ib_have_map
    lea si, level3_map

ib_have_map:
    lea di, brick_state
    mov cx, 45
    mov bricks_left, 0

ib_copy:
    lodsb   ; load byte from map into al, advance si
    stosb   ;  store into brick_state, advance di
    cmp al, 0
    je  ib_next
    inc word ptr bricks_left  ; count left bticks

ib_next:
    loop ib_copy

    pop es
    pop si
    pop di
    pop cx
    pop bx
    pop ax
    ret
init_bricks endp

set_level_speed proc
    mov ball_speed, 3      ; level 1 slow
    cmp current_level, 1
    je  sls_done
    mov ball_speed, 5    ; level 2 medium
    cmp current_level, 2
    je  sls_done
    mov ball_speed, 7   ; level 3 fast

sls_done:
    ret
set_level_speed endp

reset_paddle_and_ball proc
    push ax

    mov paddle_x, 132
    mov ball_x, 158
    mov ball_y, 176
    mov ax, ball_speed
    mov ball_dx, ax
    neg ax      ; negate the velocity
    mov ball_dy, ax

    pop ax
    ret
reset_paddle_and_ball endp

init_level_state proc
    mov game_over_flag, 0
    mov level_complete_flag, 0
    mov quit_to_menu_flag, 0
    mov bonus_active, 0
    mov bonus_type, 0
    mov bonus_timer, 0
    mov timed_effect, 0
    mov current_paddle_w, PADDLE_W
    call set_level_speed
    call init_bricks
    call reset_paddle_and_ball
    call update_score_string
    call update_lives_string
    call update_level_string
    ret
init_level_state endp

init_new_game proc
    mov current_level, 1
    mov score_value, 0
    mov lives_left, 3
    call init_level_state
    ret
init_new_game endp

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
    mov al, brick_colors[bx] ;row based color
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
    mov rcol, 16  ; fill entire screen dark
    mov rx1, 0
    mov ry1, 0
    mov rx2, 319
    mov ry2, 199
    call fill_rect

    mov rcol, 18   ; fill the play field with color 18
    mov rx1, GAME_LEFT
    mov ry1, GAME_TOP
    mov rx2, GAME_RIGHT
    mov ry2, GAME_BOTTOM
    call fill_rect

    mov rcol, 20   ; draw left wall in color 20
    mov rx1, 0
    mov rx2, 3
    mov ry1, GAME_TOP
    mov ry2, GAME_BOTTOM
    call fill_rect

    mov rcol, 21   ; left wall accent  line in 21
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
    push bx

    mov bx, current_paddle_w
    dec bx

    mov rcol, 21     ; paddle in cyan colro
    mov ax, paddle_x
    mov rx1, ax
    mov ry1, PADDLE_Y
    add ax, bx
    mov rx2, ax
    mov ry2, PADDLE_Y + PADDLE_H - 1
    call fill_rect

    mov rcol, COL_WHITE  ; top 2 rows in white
    mov ax, paddle_x
    mov rx1, ax
    mov ry1, PADDLE_Y
    add ax, bx
    mov rx2, ax
    mov ry2, PADDLE_Y + 1
    call fill_rect

    mov rcol, 22  ; left andright 2 cols in color 22
    mov ax, paddle_x
    mov rx1, ax
    add ax, 1
    mov rx2, ax
    mov ry1, PADDLE_Y
    mov ry2, PADDLE_Y + PADDLE_H - 1
    call fill_rect

    mov ax, paddle_x
    add ax, bx
    dec ax
    mov rx1, ax
    add ax, 1
    mov rx2, ax
    call fill_rect

    pop bx
    pop ax
    ret
draw_paddle endp

erase_paddle proc ;just fills the paddle area with color 18 (background )
    push ax
    push bx

    mov rcol, 18
    mov ax, paddle_x
    mov rx1, ax
    mov ry1, PADDLE_Y
    mov bx, current_paddle_w
    dec bx
    add ax, bx
    mov rx2, ax
    mov ry2, PADDLE_Y + PADDLE_H - 1
    call fill_rect

    pop bx
    pop ax
    ret
erase_paddle endp

draw_ball proc  ; draws two overlapping squares
    push ax

    mov rcol, COL_LTRED  ; outer square
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

    mov rcol, COL_YELLOW  ; inner square
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

erase_ball proc  ; just fill ball area with color 18
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
    int 16h    ; check if key is in buffer ( non blocking)
    jz  rgi_done  ; no key ?? skip

    mov ah, 00h
    int 16h       ; read the key


; Check scan codes:
; 4Bh = Left arrow  → input_dir = 0FFh (−1)
; 4Dh = Right arrow → input_dir = 1
; 'a' or 'A'        → input_dir = 0FFh
; 'd' or 'D'        → input_dir = 1
; 27 (ESC)          → quit_to_menu_flag = 1
 
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
    mov quit_to_menu_flag, 1

rgi_done:
    pop ax
    ret
read_game_input endp
; read paddle direction if left subtract speed 
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
    jmp upp_apply

upp_left:
    sub ax, PADDLE_SPEED
    cmp ax, PADDLE_MIN_X
    jge upp_apply
    mov ax, PADDLE_MIN_X

upp_apply:
    ; Wide-paddle bonus changes the right wall limit at runtime.
    mov bx, GAME_RIGHT + 1
    sub bx, current_paddle_w
    cmp ax, bx
    jle upp_check_left
    mov ax, bx

upp_check_left:
    cmp ax, PADDLE_MIN_X
    jge upp_compare
    mov ax, PADDLE_MIN_X

upp_compare:
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
; add velocity to position each frame
update_ball_position proc
    push ax

    mov ax, ball_x
    add ax, ball_dx    ; move horizontally
    mov ball_x, ax

    mov ax, ball_y
    add ax, ball_dy   ; move upwards
    mov ball_y, ax

    pop ax
    ret
update_ball_position endp

check_wall_collisions proc
    push ax

    mov ax, ball_x
    cmp ax, GAME_LEFT   ; chcek ball_x < GAME_LEFT
    jge cwc_right
    mov ball_x, GAME_LEFT  ; ball_x = GAME_LEFT
    neg word ptr ball_dx    ; negate ball_dx
 
cwc_right:
    mov ax, ball_x
    cmp ax, GAME_RIGHT - BALL_SIZE + 1
    jle cwc_top
    mov ball_x, GAME_RIGHT - BALL_SIZE + 1
    neg word ptr ball_dx

cwc_top:
    mov ax, ball_y
    cmp ax, GAME_TOP   ;ball_y < game_top
    jge cwc_done
    mov ball_y, GAME_TOP
    neg word ptr ball_dy ;negate ball_dy

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
    add cx, current_paddle_w
    dec cx
    mov dx, ball_x
    cmp dx, cx
    jg  cpc_done

    mov bx, paddle_x
    mov ball_y, PADDLE_Y - BALL_SIZE
    mov ax, ball_speed
    neg ax
    mov ball_dy, ax

    mov dx, ball_x
    add dx, 2
    sub dx, bx

    ; Three simple zones. Every hit keeps the same upward level
    ; speed; center-ish hits use a smaller sideways step so the
    ; ball rises instead of shooting straight into a corner loop.
    cmp dx, 14
    jl  cpc_left

    mov cx, current_paddle_w
    sub cx, 14
    cmp dx, cx
    jg  cpc_right

    mov ax, ball_speed
    inc ax
    shr ax, 1
    cmp input_dir, 0ffh
    je  cpc_center_left
    cmp input_dir, 1
    je  cpc_center_right
    cmp ball_dx, 0
    jl  cpc_center_left
    jmp cpc_center_right

cpc_center_left:
    neg ax
    mov ball_dx, ax
    jmp cpc_done

cpc_center_right:
    mov ball_dx, ax
    jmp cpc_done

cpc_left:
    mov ax, ball_speed
    neg ax
    mov ball_dx, ax
    jmp cpc_done

cpc_right:
    mov ax, ball_speed
    mov ball_dx, ax

cpc_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_paddle_collision endp

random_byte proc
    push bx
    push cx
    push dx

    ; Mix the BIOS timer with a tiny software seed. It is simple,
    ; but for bonus drops it feels random enough in DOSBox.
    mov ah, 00h
    int 1ah
    mov al, dl
    xor al, dh
    add al, rand_seed
    mov bl, al
    shl al, 1
    add al, bl
    add al, 17
    mov rand_seed, al

    pop dx
    pop cx
    pop bx
    ret
random_byte endp

apply_speed_to_ball proc
    push ax

    mov ax, ball_speed
    cmp ball_dx, 0
    je  astb_x_right
    jge astb_x_ok
    neg ax

astb_x_ok:
    mov ball_dx, ax
    jmp astb_y

astb_x_right:
    mov ball_dx, ax

astb_y:
    mov ax, ball_speed
    cmp ball_dy, 0
    jge astb_y_ok
    neg ax

astb_y_ok:
    mov ball_dy, ax

    pop ax
    ret
apply_speed_to_ball endp

clear_timed_effect proc
    push ax

    cmp timed_effect, 0
    je  cte_done
    cmp timed_effect, 1
    je  cte_restore_speed
    cmp timed_effect, 3
    je  cte_restore_paddle
    jmp cte_clear

cte_restore_speed:
    call set_level_speed
    call apply_speed_to_ball
    jmp cte_clear

cte_restore_paddle:
    call erase_paddle
    mov current_paddle_w, PADDLE_W

    ; If the wide paddle was near the right wall, pull it back
    ; before redrawing the normal one.
    mov ax, GAME_RIGHT + 1
    sub ax, current_paddle_w
    cmp paddle_x, ax
    jle cte_draw_paddle
    mov paddle_x, ax

cte_draw_paddle:
    call draw_paddle

cte_clear:
    mov timed_effect, 0
    mov bonus_timer, 0

cte_done:
    pop ax
    ret
clear_timed_effect endp

tick_timed_effect proc
    cmp bonus_timer, 0
    je  tte_done
    dec word ptr bonus_timer
    cmp bonus_timer, 0
    jne tte_done
    call clear_timed_effect

tte_done:
    ret
tick_timed_effect endp

try_spawn_bonus proc
    push ax
    push bx

    cmp bonus_active, 0
    jne tsb_done

    call random_byte
    and al, 03h
    cmp al, 0
    jne tsb_done

    mov ax, rx1
    add ax, rx2
    shr ax, 1
    sub ax, 4
    cmp ax, GAME_LEFT
    jge tsb_x_left_ok
    mov ax, GAME_LEFT

tsb_x_left_ok:
    cmp ax, GAME_RIGHT - BONUS_SIZE
    jle tsb_x_ready
    mov ax, GAME_RIGHT - BONUS_SIZE

tsb_x_ready:
    mov bonus_x, ax
    mov ax, ry2
    inc ax
    mov bonus_y, ax

    call random_byte
    xor ah, ah
    mov bl, 3
    div bl
    mov al, ah
    inc al
    mov bonus_type, al
    mov bonus_active, 1

tsb_done:
    pop bx
    pop ax
    ret
try_spawn_bonus endp

draw_bonus proc
    push ax

    cmp bonus_active, 1
    jne db_done

    mov rcol, COL_LTCYAN
    cmp bonus_type, 1
    je  db_color_ready
    mov rcol, COL_LTGRN
    cmp bonus_type, 2
    je  db_color_ready
    mov rcol, COL_YELLOW

db_color_ready:
    mov ax, bonus_x
    mov rx1, ax
    add ax, BONUS_SIZE - 1
    mov rx2, ax
    mov ax, bonus_y
    mov ry1, ax
    add ax, BONUS_SIZE - 1
    mov ry2, ax
    call fill_rect

    mov rcol, COL_WHITE
    mov ax, bonus_x
    add ax, 2
    mov rx1, ax
    add ax, 3
    mov rx2, ax
    mov ax, bonus_y
    add ax, 2
    mov ry1, ax
    add ax, 3
    mov ry2, ax
    call fill_rect

db_done:
    pop ax
    ret
draw_bonus endp

erase_bonus proc
    push ax

    cmp bonus_active, 1
    jne eb_done

    mov rcol, 18
    mov ax, bonus_x
    mov rx1, ax
    add ax, BONUS_SIZE - 1
    mov rx2, ax
    mov ax, bonus_y
    mov ry1, ax
    add ax, BONUS_SIZE - 1
    mov ry2, ax
    call fill_rect

    ; A falling bonus can pass over bricks, so redraw active bricks
    ; behind it. This prevents ugly square trails.
    call draw_all_bricks

eb_done:
    pop ax
    ret
erase_bonus endp

apply_collected_bonus proc
    push ax

    cmp bonus_type, 1
    je  acb_slow
    cmp bonus_type, 2
    je  acb_life
    cmp bonus_type, 3
    je  acb_wide
    jmp acb_done

acb_slow:
    call clear_timed_effect
    mov ball_speed, 1
    call apply_speed_to_ball
    mov bonus_timer, EFFECT_TIME
    mov timed_effect, 1
    jmp acb_done

acb_life:
    cmp lives_left, 9
    jae acb_done
    inc lives_left
    call update_lives_string
    jmp acb_done

acb_wide:
    call clear_timed_effect
    call erase_paddle
    mov current_paddle_w, PADDLE_WIDE
    mov ax, GAME_RIGHT + 1
    sub ax, current_paddle_w
    cmp paddle_x, ax
    jle acb_draw_wide
    mov paddle_x, ax

acb_draw_wide:
    call draw_paddle
    mov bonus_timer, EFFECT_TIME
    mov timed_effect, 3

acb_done:
    pop ax
    ret
apply_collected_bonus endp

update_bonus proc
    push ax
    push bx
    push dx

    cmp bonus_active, 1
    jne ub_done

    add bonus_y, BONUS_FALL
    cmp bonus_y, GAME_BOTTOM
    jg  ub_drop_lost

    mov ax, bonus_y
    add ax, BONUS_SIZE - 1
    cmp ax, PADDLE_Y
    jl  ub_draw

    mov ax, bonus_y
    cmp ax, PADDLE_Y + PADDLE_H - 1
    jg  ub_draw

    mov ax, paddle_x
    mov bx, bonus_x
    add bx, BONUS_SIZE - 1
    cmp bx, ax
    jl  ub_draw

    mov dx, ax
    add dx, current_paddle_w
    dec dx
    mov bx, bonus_x
    cmp bx, dx
    jg  ub_draw

    mov bonus_active, 0
    call apply_collected_bonus
    jmp ub_done

ub_drop_lost:
    mov bonus_active, 0
    jmp ub_done

ub_draw:
    call draw_bonus

ub_done:
    pop dx
    pop bx
    pop ax
    ret
update_bonus endp

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
    call try_spawn_bonus
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

show_win_screen proc
    call enter_mode13
    call set_palette
    call draw_gradient_bg
    call update_score_string

    mov rcol, 22
    mov rx1, 48
    mov ry1, 52
    mov rx2, 271
    mov ry2, 152
    call fill_rect

    mov rcol, 21
    call draw_border

    mov rcol, COL_YELLOW
    mov rx1, 52
    mov rx2, 267
    mov ry1, 56
    mov ry2, 64
    call fill_rect

    mov dh, 8
    mov dl, 16
    mov bl, 0eh
    lea si, win_title
    call print_str

    mov dh, 11
    mov dl, 11
    mov bl, 0fh
    lea si, win_score
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
    lea si, win_hint
    call print_str

    call wait_key
    ret
show_win_screen endp

show_game_screen proc
    call enter_mode13
    call set_palette
    call init_new_game
    call draw_game_scene

sg_loop:
    call read_game_input
    cmp quit_to_menu_flag, 1
    je  sg_quit_menu
    cmp game_over_flag, 1
    je  sg_done

    call update_paddle_position
    call erase_ball
    call erase_bonus
    call update_ball_position
    call check_wall_collisions
    call check_paddle_collision
    call check_brick_collision
    call update_bonus
    call tick_timed_effect
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
    call update_high_scores
    call show_game_over_screen
    mov ax, @data
    mov ds, ax
    ret

sg_quit_menu:
    mov ax, @data
    mov ds, ax
    ret

sg_level_done:
    cmp current_level, 3
    je  sg_game_won
    call show_level_complete_screen
    inc current_level
    call enter_mode13
    call set_palette
    call init_level_state
    call draw_game_scene
    jmp sg_loop

sg_game_won:
    call update_high_scores
    call show_win_screen
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
