; ---------------------------------------------------------------------------
; monitor.s — Apple II ROM entry points and soft-switch / register addresses.
;
; The single registry of hardware addresses for this project. Each line is a
; pure link-time symbol: `sym = addr` + `.export` emits NO bytes into the
; binary. To add an address, put it here and add the matching extern
; declaration in monitor.h.
;
; Note: cc65 mangles C names with a leading underscore (C `HOME` -> `_HOME`).
; ---------------------------------------------------------------------------

; --- Monitor ROM routines (called via jsr) — declared as functions in C ----
        .export _HOME, _COUT
_HOME   = $FC58                 ; clear screen + home cursor
_COUT   = $FDED                 ; print char in A (40-col text, high-bit ASCII)

; --- Soft switches / memory-mapped registers — declared as vars in C -------
        .export _MOTOR_OFF
_MOTOR_OFF = $C0E8              ; drive motor off (slot 6)
