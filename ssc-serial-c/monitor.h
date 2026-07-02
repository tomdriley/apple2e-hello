#ifndef MONITOR_H
#define MONITOR_H

/* Apple II hardware addresses. Definitions live in monitor.s; this header is
 * just the C view of them. ROM routines are declared as functions (compile to
 * a direct jsr); soft switches / registers are declared as extern volatile
 * variables (compile to a direct lda/sta). */

/* --- Monitor ROM routines ------------------------------------------------ */
void HOME(void);   /* $FC58  clear screen + home cursor       */
void COUT(char c); /* $FDED  print char in A (high-bit ASCII) */

/* --- Soft switches / memory-mapped registers ----------------------------- */
extern volatile unsigned char MOTOR_OFF; /* $C0E8  drive motor off (slot 6) */

/* --- Super Serial Card 6551 ACIA in slot 2 ($C0A8-$C0AB) ----------------- */
extern volatile unsigned char ACIA_DATA;    /* $C0A8  read = RX byte, write = TX byte  */
extern volatile unsigned char ACIA_STATUS;  /* $C0A9  read = status, any write = reset */
extern volatile unsigned char ACIA_COMMAND; /* $C0AA  parity / echo / IRQ / DTR / RTS  */
extern volatile unsigned char ACIA_CONTROL; /* $C0AB  baud rate / word length / stop   */

#endif /* MONITOR_H */
