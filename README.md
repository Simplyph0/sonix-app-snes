# SNES for Sonix Plus

Super Nintendo games on the HiBy R1 and R3 Pro II, as an
[app](https://github.com/Simplyph0/sonix-plus/blob/main/APPS.md) for
[Sonix Plus](https://github.com/Simplyph0/sonix-plus): the
[Snes9x 2005](https://github.com/libretro/snes9x2005) libretro core linked into the
[SDK](https://github.com/Simplyph0/sonix-app-sdk)'s frontend as one static program.

The game fills the top of the screen and an on-screen pad is below it: a D-pad, A B X Y, L and R,
SELECT and START, and SAVE, LOAD, MENU and EXIT keys. SAVE and LOAD keep one save state per game. MENU
opens the options (FPS counter, sound on or off, frame skip) and pauses the game. EXIT takes two taps. Battery saves are written to
`Saves/SNES/<game>.srm` on the card.

## This repository has no program in it

Snes9x's licence allows **non-commercial use only**. That is not compatible with the GNU GPL that
Sonix Plus is under, so SNES cannot be part of the firmware, and I do not offer a built program for
download either. This repository is only the recipe: you build the app yourself, for your own use,
and the emulator's code is fetched from its own repository when you do.

## Building

You need the MIPS toolchain that `make target` builds in the Sonix Plus repository, and `git`.

```bash
make fetch
make package CROSS=/path/to/sonix-plus/sonix-player/rockbox-toolchain/bin/mipsel-rockbox-linux-gnu-
```

Copy `dist/SNES/` to `Apps/` on the card, put games (`.sfc`, `.smc`) in `Games/SNES/`, and open
**More > Emulators > SNES**. `make host` builds a program for your computer, and
`python3 tools/mkrom.py test.sfc` writes a small ROM of my own to try it with.

**How fast it runs on a player is not known yet.** Snes9x 2005 is written for low-power CPUs, but
this one is a plain 1.1 GHz MIPS with no vector unit, and I have only run it on a computer.

## Licences

The files in this repository (the Makefile, manifest, icon and the test ROM generator) are MIT.
Snes9x is under its own non-commercial licence, which you accept by building it.
