; ---------------------------------------------------------------------------
; monitor.s — Apple II ROM entry points and soft-switch / register addresses.
; ---------------------------------------------------------------------------

; --- Monitor ROM routines (called via jsr) — declared as functions in C ----
        .export _HOME, _COUT, _MOTOR_OFF, _PREAD
_HOME      = $FC58              ; clear screen + home cursor
_COUT      = $FDED              ; print char in A (40-col text, high-bit ASCII)
_MOTOR_OFF = $C0E8              ; drive motor off (slot 6)

        .segment "CODE"

; PREAD monitor routine ($FB1E) expects paddle index in X and returns count in Y.
; This wrapper reads paddle of first arg and returns the count in A to C.
_PREAD:
        tax
        jsr $FB1E
        tya
        rts
