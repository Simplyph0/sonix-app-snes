#!/usr/bin/env python3
"""Writes a tiny SNES ROM that fills the screen with one colour, for trying the app without a game.

    python3 tools/mkrom.py test.sfc

Fifteen bytes of 65816: switch to native mode, set the backdrop colour in palette memory to
red, turn the picture on, loop. A LoROM of 32 KB with a header and a correct checksum.
Nothing in it belongs to anybody.
"""
import struct
import sys

LOOP = 0x8000 + 24
code = bytes([
    0x78,                    # SEI
    0x18,                    # CLC
    0xFB,                    # XCE            (native mode)
    0xE2, 0x30,              # SEP #$30       (8-bit registers)
    0xA9, 0x8F,              # LDA #$8F
    0x8D, 0x00, 0x21,        # STA $2100      (screen off)
    0x9C, 0x21, 0x21,        # STZ $2121      (palette entry 0)
    0xA9, 0x1F,              # LDA #$1F
    0x8D, 0x22, 0x21,        # STA $2122      (low byte: red)
    0xA9, 0x00,              # LDA #$00
    0x8D, 0x22, 0x21,        # STA $2122      (high byte)
    0xA9, 0x0F,              # LDA #$0F
    0x8D, 0x00, 0x21,        # STA $2100      (screen on, full brightness)
])
loop_at = 0x8000 + len(code)
code += bytes([0x4C, loop_at & 0xFF, loop_at >> 8])   # JMP loop

rom = bytearray(0x8000)
rom[:len(code)] = code

header = 0x7FC0
rom[header:header + 21] = b'SONIX TEST ROM       '
rom[header + 0x15] = 0x20            # LoROM
rom[header + 0x16] = 0x00            # no extra chips
rom[header + 0x17] = 0x05            # 32 KB
rom[header + 0x18] = 0x00            # no RAM
rom[header + 0x19] = 0x00            # Japan
rom[header + 0x1A] = 0x33            # extended header
rom[header + 0x1B] = 0x00            # version
rom[0x7FFC:0x7FFE] = struct.pack('<H', 0x8000)   # reset
rom[0x7FEA:0x7FEC] = struct.pack('<H', 0x8000)   # NMI (native), unused
rom[0x7FFA:0x7FFC] = struct.pack('<H', 0x8000)   # NMI (emulation), unused
rom[0x7FFE:0x8000] = struct.pack('<H', 0x8000)   # IRQ/BRK

rom[header + 0x1C:header + 0x1E] = b'\xff\xff'
rom[header + 0x1E:header + 0x20] = b'\x00\x00'
total = sum(rom) & 0xFFFF
rom[header + 0x1E:header + 0x20] = struct.pack('<H', total)
rom[header + 0x1C:header + 0x1E] = struct.pack('<H', total ^ 0xFFFF)

open(sys.argv[1] if len(sys.argv) > 1 else 'test.sfc', 'wb').write(rom)
