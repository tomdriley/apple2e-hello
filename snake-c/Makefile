# Apple IIe Snake in C — cc65 cross-compile build
# Requires: GNU Make (scoop install make), cc65, AppleCommander, MAME, Git Bash
#
# Targets:
#   make        — compile, assemble, link, build disk image → build/snake.dsk
#   make run    — build + launch in MAME
#   make debug  — build + launch in MAME with debugger
#   make clean  — remove build/ directory

# Git Bash — 8.3 short path avoids the space in "Program Files"
SHELL       := C:/PROGRA~1/Git/bin/bash.exe
.SHELLFLAGS := -c

# --- Tool paths -----------------------------------------------------------
CC65    := C:/cc65/bin/cc65.exe
CA65    := C:/cc65/bin/ca65.exe
LD65    := C:/cc65/bin/ld65.exe
AC      := C:/AppleCommander/ac.cmd
MAME    := C:/mame/mame.exe
# none.lib = bare 6502 runtime (cc65 helpers), no OS/platform startup
NONELIB := C:/cc65/lib/none.lib

# --- Build artefacts -------------------------------------------------------
BUILDDIR := build
ASM      := $(BUILDDIR)/snake.s
OBJ      := $(BUILDDIR)/snake.o
CRT0     := $(BUILDDIR)/crt0.o
MON      := $(BUILDDIR)/monitor.o
BIN      := $(BUILDDIR)/SNAKE.BIN
DSK      := $(BUILDDIR)/snake.dsk
BASE     := dos33-base.dsk

# --------------------------------------------------------------------------
.PHONY: all run debug clean

all: $(DSK)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Compile C -> 6502 assembly
#   -O   optimize
#   -Cl  static locals (fixed addresses, not the software stack): smaller/faster
#        loops. Safe here because nothing is reentrant (no recursion/interrupts).
$(ASM): snake.c monitor.h | $(BUILDDIR)
	"$(CC65)" -O -Cl -t none -o $(ASM) snake.c

# Assemble compiler output -> relocatable object
$(OBJ): $(ASM)
	"$(CA65)" -t none -l $(BUILDDIR)/snake.lst -o $(OBJ) $(ASM)

# Assemble the startup shim (sets up C stack, zeroes BSS, calls _start)
$(CRT0): crt0.s | $(BUILDDIR)
	"$(CA65)" -t none -o $(CRT0) crt0.s

# Assemble the hardware address registry + PLOT/SCRN shims
$(MON): monitor.s | $(BUILDDIR)
	"$(CA65)" -t none -o $(MON) monitor.s

# Link -> raw binary placed at $0800; runtime helpers pulled from none.lib
$(BIN): $(CRT0) $(OBJ) $(MON) snake.cfg
	"$(LD65)" -C snake.cfg -m $(BUILDDIR)/snake.map -o $(BIN) $(CRT0) $(OBJ) $(MON) "$(NONELIB)"

# DOS 3.3 disk image: copy base, then inject the binary via AppleCommander
$(DSK): $(BIN)
	cp $(BASE) $(DSK)
	"$(AC)" -d $(DSK) SNAKE 2>/dev/null || true
	"$(AC)" -p $(DSK) SNAKE BIN 0x0800 < $(BIN)

MAME_FLAGS := -skip_gameinfo -video bgfx -bgfx_backend d3d11

# MAME must run from its own directory so the relative rompath resolves
run: $(DSK)
	cd "$(dir $(MAME))" && "$(MAME)" apple2e \
		-flop1 "$(CURDIR)/$(DSK)" $(MAME_FLAGS)

debug: $(DSK)
	cd "$(dir $(MAME))" && "$(MAME)" apple2e \
		-flop1 "$(CURDIR)/$(DSK)" $(MAME_FLAGS) -debug

clean:
	rm -rf $(BUILDDIR)
