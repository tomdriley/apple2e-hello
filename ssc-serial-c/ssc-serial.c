#include "monitor.h"

/* 6551 status register bits */
#define ST_RDRF 0x08 /* receive data register full   */
#define ST_TDRE 0x10 /* transmit data register empty */

/* 6551 setup: 9600 baud, 8 data bits, 1 stop bit; no parity, no interrupts,
 * DTR and RTS asserted so the receiver is enabled. */
#define CTRL_9600_8N1 0x1E
#define CMD_NO_PARITY 0x0B

static const char BANNER[] = "\r"
                             "Super Serial Card demo\r"
                             "Type in the client; I echo it back:\r"
                             "\r";

/* Bring the 6551 up in a known state: reset, then set line format + mode. */
static void serial_init(void)
{
    ACIA_STATUS  = 0; /* any write triggers a soft reset */
    ACIA_CONTROL = CTRL_9600_8N1;
    ACIA_COMMAND = CMD_NO_PARITY;
}

/* Block until the transmitter is free, then push one byte out the wire. */
static void serial_raw(char c)
{
    while ((ACIA_STATUS & ST_TDRE) == 0) {
        /* wait for transmit data register empty */
    }
    ACIA_DATA = c;
}

/* Send a byte to both the serial port and the Apple screen. Remote terminals
 * expect CR+LF, so tack an LF onto every carriage return going out the wire. */
static void emit(char c)
{
    serial_raw(c);
    if (c == '\r') {
        serial_raw('\n');
    }
    COUT(c | 0x80); /* the 40-column screen wants high-bit ASCII */
}

void start(void)
{
    volatile unsigned char off = MOTOR_OFF; /* read soft switch: stop drive motor */
    unsigned char          i;
    unsigned char          ch;

    (void)off;

    HOME();
    serial_init();

    /* Greet the remote end and mirror the banner on the Apple screen. */
    for (i = 0; BANNER[i]; ++i) {
        emit(BANNER[i]);
    }

    /* Echo loop: anything that arrives over serial goes back out (proving the
     * round trip) and is shown on screen (proving we received it). */
    for (;;) {
        if (ACIA_STATUS & ST_RDRF) { /* a byte arrived over serial */
            ch = ACIA_DATA & 0x7F;   /* strip high bit -> clean 7-bit ASCII */
            emit(ch);
        }
    }
}
