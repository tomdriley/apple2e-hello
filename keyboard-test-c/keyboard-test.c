#include "monitor.h"

const char MESSAGE[] = "\r"
                       "Keyboard Test!\r"
                       "--------------\r"
                       "Press any key to see it echo:\r"
                       "\r";

void start(void)
{
    volatile unsigned char off = MOTOR_OFF; /* read soft switch: stop drive motor */
    unsigned char          i;

    (void)off;
    HOME();

    for (i = 0; MESSAGE[i]; ++i) {
        COUT1(MESSAGE[i] | 0x80); /* Apple II text wants high-bit ASCII */
    }

    for (;;) {
        unsigned char key_data = KEY_DATA; /* high bit = strobe */
        if (key_data & 0x80) {             /* a key is waiting */
            COUT1(key_data);               /* echo it (already high-bit ASCII) */
            KEY_FLAG = 0;                  /* any access to KEY_FLAG clears the strobe */
        }
    }
}
