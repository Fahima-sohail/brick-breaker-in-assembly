# 🧱 Brick Breaker — Pixel-by-Pixel VGA Game in x86 Assembly

A complete brick-breaker (Breakout-style) game written from scratch in 16-bit
x86 assembly for MS-DOS, rendering directly to VGA mode 13h one pixel at a
time — no game engine, no graphics library, just raw assembly and the BIOS.

Built for **EE-2003: Computer Organization and Assembly Language**,
FAST-NUCES Islamabad, Spring 2026.

## Features

- Animated home screen with a starfield background and pixel-drawn logo
- Player name entry and a navigable main menu (arrow keys + Enter)
- Instructions screen
- Persistent **high score table**, saved to and loaded from `BBSCORES.DAT`
- Real-time paddle and ball physics with wall/paddle/brick collision detection
- 45-brick layout with per-brick collision and destruction
- Falling bonus power-ups: slow ball, extra life, wide paddle
- Lives, scoring, and level system with increasing ball speed
- "Life lost", "Level complete", "Game over", and "You win" screens
- Full HUD: live score, lives, and level display

Everything above — every pixel, every menu, every collision check — is done
by hand in assembly, without any external graphics or game library.

## Files

| File        | Description                                                    |
|-------------|------------------------------------------------------------------|
| `iter1.asm` | Iteration 1 — early graphics & UI prototype                      |
| `iter2.asm` | Iteration 2 — expanded gameplay logic                            |
| `iter3.asm` | Iteration 3 — final, complete, playable game                     |

`iter3.asm` is the finished project and the one worth running.
`iter1.asm` / `iter2.asm` are kept to show the project's progression.

Each file is fully self-contained: no external `.inc` files or third-party
libraries are required, only the MASM assembler and linker.

## Tech details

- **Target**: MS-DOS, 16-bit real mode
- **Model**: `.model small`, 400h-byte stack
- **Graphics**: VGA mode 13h (320×200, 256 colors), drawn pixel-by-pixel via
  direct video memory writes
- **Input**: keyboard, via BIOS interrupts
- **Persistence**: high scores read/written to a flat file (`BBSCORES.DAT`)
  next to the executable
- **Toolchain**: MASM 6.15 (`ML.EXE` / `LINK.EXE`)

## How to build & run

You need an MS-DOS environment with **MASM (Microsoft Macro Assembler, v6.15
or compatible)** and **LINK**. The easiest way to get one today is
[DOSBox](https://www.dosbox.com/) plus a copy of the MASM 6.15 toolkit.

1. Install DOSBox.
2. Mount a folder containing `ML.EXE`, `LINK.EXE`, and this repo's `.asm`
   files:
   ```
   mount c C:\path\to\masm-tools-and-source
   c:
   ```
3. Assemble and link:
   ```
   ml iter3.asm
   ```
   (`ml` normally drives both the assembler and linker in one step. If it
   stops after producing `iter3.obj`, link it manually with `link iter3;`.)
4. Run it:
   ```
   iter3.exe
   ```
5. Use the arrow keys to navigate menus, and the left/right arrow keys to
   move the paddle in-game.

> **Note on tooling:** MASM/TASM and the rest of a DOS dev toolkit are
> proprietary Microsoft/Borland tools from the 1990s and are **not** included
> in this repo. You'll need to source your own copy (commonly found in
> archived DOS developer toolkits) and check its license/redistribution
> terms yourself before sharing it further.

## Playing it in a browser (optional, no install required)

Because the game is a single self-contained `.exe` once built, it can be made
playable directly in a browser with zero setup for the player:

1. Build `iter3.exe` locally as described above.
2. Use [js-dos](https://js-dos.com/) to wrap `iter3.exe` in a small HTML page
   that runs it through an in-browser DOSBox emulator.
3. Host that page for free with **GitHub Pages**, enabled from this repo's
   Settings → Pages.

This repo currently ships source only. A `/web` folder with a ready-to-go
js-dos build can be added later if you want a live "Play in browser" link.

## Course info

EE-2003 Computer Organization and Assembly Language — FAST-NUCES Islamabad, Spring 2026.
