#ifndef MONITOR_H
#define MONITOR_H

/* Apple II hardware addresses. Definitions live in monitor.s; this header is
 * just the C view of them. ROM routines are declared as functions (compile to
 * a direct jsr); soft switches / registers are declared as extern volatile
 * variables (compile to a direct lda/sta).
 *
 * PLOT and SCRN take their arguments in specific CPU registers (A = vertical,
 * Y = horizontal), which the cc65 calling convention does not match. They are
 * therefore declared here as ordinary C functions and given tiny assembly
 * shims in monitor.s that move the arguments into the registers the ROM wants. */

/* --- Monitor ROM routines (called via jsr) ------------------------------- */
void HOME(void);                                /* $FC58  clear text screen + home cursor   */
void CLRTOP(void);                              /* $F836  clear top 40 lo-res rows to black  */
void SETCOL(unsigned char colour);              /* $F864  set lo-res colour (0-15)           */
void PLOT(unsigned char row, unsigned char col);            /* $F800  plot lo-res block      */
unsigned char SCRN(unsigned char row, unsigned char col);   /* $F871  read lo-res colour     */
void DOSWARM(void);                             /* $03D0  DOS 3.3 warm-start (never returns)  */

/* --- Soft switches / memory-mapped registers ----------------------------- */
extern volatile unsigned char KBD;      /* $C000  bit7 set => key available           */
extern volatile unsigned char KBDSTRB;  /* $C010  any access clears the strobe        */
extern volatile unsigned char TXTCLR;   /* $C050  graphics                            */
extern volatile unsigned char TXTSET;   /* $C051  text                                */
extern volatile unsigned char MIXSET;   /* $C053  mixed (4 text lines at the bottom)  */
extern volatile unsigned char LOWSCR;   /* $C054  display page 1                      */
extern volatile unsigned char LORES;    /* $C056  lo-res                              */

#endif /* MONITOR_H */
