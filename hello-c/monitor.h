#ifndef MONITOR_H
#define MONITOR_H

/* Apple II hardware addresses. Definitions live in monitor.s; this header is
 * just the C view of them. ROM routines are declared as functions (compile to
 * a direct jsr); soft switches / registers are declared as extern volatile
 * variables (compile to a direct lda/sta). */

/* --- Monitor ROM routines ------------------------------------------------ */
void HOME(void);    /* $FC58  clear screen + home cursor       */
void COUT1(char c); /* $FDF0  print char in A (high-bit ASCII) */

/* --- Soft switches / memory-mapped registers ----------------------------- */
extern volatile unsigned char MOTOR_OFF; /* $C0E8  drive motor off (slot 6)         */

#endif /* MONITOR_H */
