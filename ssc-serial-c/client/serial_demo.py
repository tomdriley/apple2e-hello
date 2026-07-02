#!/usr/bin/env python3
"""Serial demo client for the Apple IIe Super Serial Card example.

Two transports are supported:

  MAME (TCP): MAME's null_modem connects *out* to a socket we listen on, so
              start this first, then launch MAME.
      python serial_demo.py tcp [--host 127.0.0.1] [--port 6551]

  Real hardware (pyserial): talk to a USB/RS-232 adapter wired to the card.
      python serial_demo.py serial [--device COM3] [--baud 9600]

      With neither flag the client auto-detects: it scans the USB serial ports
      and common baud rates and keeps the pair where the Apple echoes a probe
      byte back. `serial --list` just lists the ports it can see.

Type a line and press Enter to send it to the Apple. Whatever the Apple sends
back — its banner and the echo of your keystrokes — is printed here. Seeing
your line echoed underneath is the round trip working. Press Ctrl+C to quit.
"""
from __future__ import annotations

import argparse
import socket
import sys
import threading
import time


def relay(read_bytes, write_bytes):
    """Pump remote -> stdout on a thread; pump stdin -> remote in the main loop.

    read_bytes() returns:
      * a non-empty bytes object with received data,
      * None when there is simply nothing to read yet (keep waiting), or
      * b"" when the remote end has closed (stop).
    """
    stop = threading.Event()

    def reader():
        try:
            while not stop.is_set():
                data = read_bytes()
                if data is None:
                    continue
                if data == b"":
                    break  # remote closed
                # The Apple sends 7-bit ASCII with CR+LF line endings.
                sys.stdout.write(data.decode("ascii", errors="replace"))
                sys.stdout.flush()
        finally:
            stop.set()

    t = threading.Thread(target=reader, daemon=True)
    t.start()

    try:
        while not stop.is_set():
            line = sys.stdin.readline()
            if not line:
                break  # stdin closed (Ctrl+Z / Ctrl+D)
            # Apple/serial convention: a carriage return ends a line.
            payload = line.rstrip("\n").encode("ascii", "replace") + b"\r"
            write_bytes(payload)
    except KeyboardInterrupt:
        pass
    finally:
        stop.set()


def run_tcp(host: str, port: int) -> None:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as srv:
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((host, port))
        srv.listen(1)
        print(f"[waiting for MAME to connect on {host}:{port} ...]", file=sys.stderr)
        conn, addr = srv.accept()
        print(f"[connected: {addr[0]}:{addr[1]}]", file=sys.stderr)
        with conn:
            conn.settimeout(0.2)

            def read_bytes():
                try:
                    return conn.recv(256)  # b"" here means the peer closed
                except socket.timeout:
                    return None

            relay(read_bytes, conn.sendall)


COMMON_BAUDS = (9600, 19200, 38400, 115200, 4800, 2400, 1200, 300)
_PROBE = b"ABC"  # the Apple echoes this straight back when the baud is right


def list_serial_ports():
    """Return pyserial ListPortInfo entries for every serial port on the host."""
    from serial.tools import list_ports

    return list(list_ports.comports())


def _candidate_ports():
    """Prefer real USB serial adapters — they report a USB vendor id."""
    ports = list_serial_ports()
    usb = [p for p in ports if getattr(p, "vid", None) is not None]
    return usb or ports


def _echoes_back(device: str, baud: int, timeout: float = 0.4) -> bool:
    """True if the probe sent to (device, baud) comes straight back.

    The demo firmware echoes whatever it receives, so a clean echo means the
    port and baud are both right; silence or garbage means they are not.
    """
    import serial

    try:
        with serial.Serial(device, baud, timeout=timeout, write_timeout=1) as ser:
            ser.reset_input_buffer()
            ser.write(_PROBE)
            ser.flush()
            deadline = time.time() + timeout * 2
            buf = b""
            while time.time() < deadline:
                buf += ser.read(len(_PROBE))
                if _PROBE in buf:
                    return True
            return False
    except serial.SerialException:
        return False


def autodetect(device=None, baud=None):
    """Find the (device, baud) at which the Apple echoes our probe."""
    devices = [device] if device else [p.device for p in _candidate_ports()]
    if not devices:
        sys.exit("No serial ports found — is a USB/RS-232 adapter connected?")
    bauds = [baud] if baud else list(COMMON_BAUDS)

    for dev in devices:
        for rate in bauds:
            if _echoes_back(dev, rate):
                return dev, rate

    # Nothing echoed: the Apple may be off or not running the demo. Fall back to
    # the firmware's fixed 9600 on the best port rather than give up outright.
    dev = device or devices[0]
    rate = baud or 9600
    print(f"[no echo seen; falling back to {dev} @ {rate} 8N1]", file=sys.stderr)
    return dev, rate


def run_serial(device, baud) -> None:
    try:
        import serial  # pyserial
    except ImportError:
        sys.exit("pyserial is not installed. Run: pip install pyserial")

    if device is None or baud is None:
        print("[auto-detecting serial port / baud ...]", file=sys.stderr)
        device, baud = autodetect(device, baud)

    with serial.Serial(device, baud, timeout=0.2) as ser:
        print(f"[open {device} @ {baud} 8N1 — Ctrl+C to quit]", file=sys.stderr)

        def read_bytes():
            data = ser.read(256)
            return data if data else None  # empty read just means "idle"

        relay(read_bytes, ser.write)


def main() -> None:
    p = argparse.ArgumentParser(
        description="Apple IIe Super Serial Card demo client",
    )
    sub = p.add_subparsers(dest="mode", required=True)

    t = sub.add_parser("tcp", help="listen for MAME's null_modem socket")
    t.add_argument("--host", default="127.0.0.1")
    t.add_argument("--port", type=int, default=6551)

    s = sub.add_parser("serial", help="talk to real hardware via a serial port")
    s.add_argument("--device",
                   help="e.g. COM3 or /dev/ttyUSB0 (auto-detected if omitted)")
    s.add_argument("--baud", type=int,
                   help="baud rate (auto-probed if omitted)")
    s.add_argument("--list", action="store_true",
                   help="list the serial ports the host can see, then exit")

    args = p.parse_args()
    if args.mode == "tcp":
        run_tcp(args.host, args.port)
    elif args.list:
        try:
            ports = list_serial_ports()
        except ImportError:
            sys.exit("pyserial is not installed. Run: pip install pyserial")
        for info in ports:
            print(f"{info.device:12} {info.description}")
        if not ports:
            print("No serial ports found.")
    else:
        run_serial(args.device, args.baud)


if __name__ == "__main__":
    main()
