#include "monitor.h"

void start(void)
{
    volatile unsigned char off = MOTOR_OFF; /* read soft switch: stop drive motor */

    (void)off;
    for (;;) {
        COUT(PREAD(0));
    }
}
