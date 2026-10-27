# Super Nintendo for Sonix Plus: Snes9x 2005, the libretro core, linked into the SDK's
# libretro frontend as one static program.
#
# Snes9x's licence allows non-commercial use only, which is not compatible with the GPL that
# Sonix Plus is under. That is why this is an app on the card and not part of the firmware, and
# why this repository holds only the recipe: it does not contain the emulator's code or a built
# program, and none is offered for download. You build it yourself, for your own use.
#
#   make fetch    clones the SDK frontend and the core into ./sdk and ./core
#   make          builds build/snes for the player (needs the MIPS toolchain)
#   make host     builds a program for this computer, to try it off the player
#   make package  makes dist/SNES/ ready to copy to <card>/Apps/
#
# Variables worth knowing: CROSS (the toolchain prefix), SDK (a checkout of
# sonix-app-sdk, default ./sdk), CORE (a checkout of libretro/snes9x2005).

CORE_URL := https://github.com/libretro/snes9x2005
CORE_REV := a79dfe9047e7fec58808aefe48ad2bf499c7af11
SDK_URL  := https://github.com/Simplyph0/sonix-app-sdk

SDK   ?= sdk
CORE  ?= core
CROSS ?= mipsel-rockbox-linux-gnu-
OUT   ?= build

COMMON := $(CORE)/libretro-common

CROSS_CFLAGS := -O2 -march=mips32r2 -mno-madd4 -mhard-float
HOST_CFLAGS  := -O2

.PHONY: all host fetch package clean

all:
	$(MAKE) build-for CC=$(CROSS)gcc AR=$(CROSS)ar CFLAGS_ARCH="$(CROSS_CFLAGS)" LDFLAGS_EXTRA="-static -s" OUTDIR=$(OUT)

host:
	$(MAKE) build-for CC=gcc AR=ar CFLAGS_ARCH="$(HOST_CFLAGS)" LDFLAGS_EXTRA= OUTDIR=$(OUT)-host

fetch:
	test -d $(SDK) || git clone --depth 1 $(SDK_URL) $(SDK)
	test -d $(CORE) || (git clone $(CORE_URL) $(CORE) && git -C $(CORE) checkout $(CORE_REV))

# ---- the real build ----

build-for: $(OUTDIR)/snes

CORE_LIB := $(OUTDIR)/libsnes9x2005.a

# CFLAGS goes in through the environment: the core's Makefile adds its own flags with +=, which
# a value on the command line would silence.
$(CORE_LIB):
	mkdir -p $(OUTDIR)
	CFLAGS="$(CFLAGS_ARCH)" $(MAKE) -C $(CORE) platform=unix STATIC_LINKING=1 fpic= CC="$(CC)" AR="$(AR)" clean
	CFLAGS="$(CFLAGS_ARCH)" $(MAKE) -C $(CORE) platform=unix STATIC_LINKING=1 fpic= CC="$(CC)" AR="$(AR)" -j$$(nproc)
	cp $(CORE)/snes9x2005_libretro.so $@

$(OUTDIR)/snes: $(CORE_LIB) $(SDK)/frontend/sonix_libretro.c $(SDK)/include/sonixapp.h
	$(CC) $(CFLAGS_ARCH) -Wall -I$(SDK)/include -I$(COMMON)/include \
		-DSONIX_SYSTEM='"SNES"' -DSONIX_LAYOUT=LAYOUT_SNES -D__LIBRETRO__ \
		-o $@ $(SDK)/frontend/sonix_libretro.c $(CORE_LIB) -lm $(LDFLAGS_EXTRA)

package: all
	rm -rf dist/SNES && mkdir -p dist/SNES
	cp $(OUT)/snes dist/SNES/snes
	cp manifest.ini icon.png dist/SNES/
	@echo "dist/SNES is ready: copy it to <card>/Apps/"

clean:
	rm -rf $(OUT) $(OUT)-host dist
