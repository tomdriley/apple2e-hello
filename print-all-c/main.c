#include "monitor.h"

void start(void)
{
    volatile unsigned char off = MOTOR_OFF; /* read soft switch: stop drive motor */
    unsigned char          i;

    (void)off;

    HOME();

    i = 0x00;
    do {
        COUT(i); // Print every byte from 0x00 to 0xFF
        ++i;
    } while (i);

    for (;;) {
        /* Do nothing */
    }
}
