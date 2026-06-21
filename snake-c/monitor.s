; ---------------------------------------------------------------------------
; monitor.s — Apple II ROM entry points and soft-switch / register addresses.
;
; The single registry of hardware addresses for this project. Most lines are a
; pure link-time symbol: `sym = addr` + `.export` emits NO bytes into the
; binary. To add a plain address, put it here and add the matching extern
; declaration in monitor.h.
;
; PLOT and SCRN are the exception: the ROM wants A = vertical and Y = horizontal,
; but cc65 passes the last argument in A and the rest on its parameter stack.
; The shims below pull the arguments into the registers the ROM expects. They
; are the only code this file emits.
;
; Note: cc65 mangles C names with a leading underscore (C `HOME` -> `_HOME`).
; ---------------------------------------------------------------------------

        .import popa                    ; cc65 runtime: pop one byte off C stack -> A
        .importzp tmp1                  ; cc65 runtime: zero-page scratch byte

; --- ROM addresses used by the shims ---------------------------------------
PLOT    = $F800                 ; A=vertical(0-47), Y=horizontal(0-39); colour=COLOR
SETCOL  = $F864                 ; A=lo-res colour (0-15) -> COLOR
SCRN    = $F871                 ; A=vertical, Y=horizontal -> returns colour in A

; --- Plain ROM routines (called via jsr) — declared as functions in C ------
        .export _HOME, _CLRTOP, _DOSWARM
_HOME    = $FC58                ; clear text screen + home cursor
_CLRTOP  = $F836                ; clear top 40 lo-res rows
_DOSWARM = $03D0                ; DOS 3.3 warm-start vector

; --- SETCOL: void SETCOL(unsigned char colour) — colour already in A -------
        .export _SETCOL
_SETCOL:
        jmp     SETCOL

; --- PLOT: void PLOT(unsigned char row, unsigned char col) -----------------
;   col (last arg) arrives in A; row is on the cc65 parameter stack.
        .export _PLOT
_PLOT:
        sta     tmp1            ; stash col
        jsr     popa            ; A = row
        ldy     tmp1            ; Y = col
        jmp     PLOT            ; ROM: A=vertical(row), Y=horizontal(col)

; --- SCRN: unsigned char SCRN(unsigned char row, unsigned char col) --------
        .export _SCRN
_SCRN:
        sta     tmp1            ; stash col
        jsr     popa            ; A = row
        ldy     tmp1            ; Y = col
        jsr     SCRN            ; ROM returns colour in A
        ldx     #0              ; cc65 unsigned char return: high byte = 0
        rts

; --- Soft switches / memory-mapped registers — declared as vars in C -------
        .export _KBD, _KBDSTRB
        .export _TXTCLR, _TXTSET, _MIXSET, _LOWSCR, _LORES
_KBD     = $C000
_KBDSTRB = $C010
_TXTCLR  = $C050
_TXTSET  = $C051
_MIXSET  = $C053
_LOWSCR  = $C054
_LORES   = $C056
