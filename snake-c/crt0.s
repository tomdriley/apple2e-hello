; crt0.s — startup shim for the C build of Snake on DOS 3.3.
;
; Unlike the self-booting hello/keyboard-test programs (which the Disk II boot
; ROM loads into a single sector at $0800), Snake is too big for one sector, so
; it ships as a normal DOS 3.3 binary loaded with `BRUN SNAKE` at $0800. DOS
; jumps to $0800 — i.e. straight to the `start` label below. crt0 sets up the
; cc65 C software stack, zeroes BSS (the ring buffers and game state), then
; calls _start (our C entry point).

        .export   _exit
        .import   _start, zerobss
        .import   __STACKSTART__
        .importzp c_sp

        .segment  "STARTUP"

start:                            ; $0800: DOS BRUN jumps here
        lda     #<__STACKSTART__  ; init cc65 C stack pointer
        sta     c_sp
        lda     #>__STACKSTART__
        sta     c_sp+1
        jsr     zerobss           ; clear BSS: snake ring buffers + game state
        jsr     _start            ; run the C program
_exit:  jmp     $03D0             ; if start() ever returns, fall back to DOS warm-start
