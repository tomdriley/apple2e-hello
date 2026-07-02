; ---------------------------------------------------------------------------
; monitor.s — Apple II ROM entry points and soft-switch / register addresses.
;
; The single registry of hardware addresses for this project. Each `sym = addr`
; + `.export` line is a pure link-time symbol and emits NO bytes into the
; binary. To add an address, put it here and add the matching extern
; declaration in monitor.h.
;
; Note: cc65 mangles C names with a leading underscore (C `COUT` -> `_COUT`).
; ---------------------------------------------------------------------------

; --- Monitor ROM routines (called via jsr) — declared as functions in C ----
        .export _HOME, _COUT
_HOME   = $FC58                 ; clear screen + home cursor
_COUT   = $FDED                 ; print char in A (40-col text, high-bit ASCII)

; --- Soft switches / memory-mapped registers — declared as vars in C -------
        .export _MOTOR_OFF
_MOTOR_OFF = $C0E8              ; drive motor off (slot 6)

; --- Super Serial Card 6551 ACIA in slot 2 --------------------------------
; Peripheral I/O for slot N lives at $C080 + N*$10; the 6551's four registers
; sit at offset $8..$B within that window, so slot 2 = $C0A8..$C0AB. Put the
; Super Serial Card in slot 2 (its traditional home) for these addresses.
        .export _ACIA_DATA, _ACIA_STATUS, _ACIA_COMMAND, _ACIA_CONTROL
_ACIA_DATA    = $C0A8           ; read received byte / write byte to send
_ACIA_STATUS  = $C0A9           ; read status; any write does a soft reset
_ACIA_COMMAND = $C0AA           ; command: parity, echo, IRQ, DTR/RTS
_ACIA_CONTROL = $C0AB           ; control: baud rate, word length, stop bits
