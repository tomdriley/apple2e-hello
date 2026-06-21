#include "monitor.h"

const char MESSAGE[] = "\rHELLO, WORLD!\r";

void start(void) {
    volatile unsigned char off = MOTOR_OFF;   /* read soft switch: stop drive motor */
    unsigned char i;

    (void)off;
    HOME();
    for (i = 0; MESSAGE[i]; ++i) {
        COUT1(MESSAGE[i] | 0x80);             /* Apple II text wants high-bit ASCII */
    }

    for (;;) {
        /* Do nothing */
    }
}
