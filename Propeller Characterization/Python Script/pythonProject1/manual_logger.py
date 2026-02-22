#!/usr/bin/env python3
"""Manual serial logger for propeller characterization (macOS).

Logs all serial data to CSV and lets you type throttle commands.

Usage:
    python manual_logger.py
"""

import select
import sys
import time
from datetime import datetime

import serial
import serial.tools.list_ports


def pick_port():
    ports = serial.tools.list_ports.comports()
    if not ports:
        print("No serial ports found.")
        sys.exit(1)
    print("Available serial ports:")
    for i, p in enumerate(ports):
        print(f"  [{i}] {p.device}  -  {p.description}")
    try:
        idx = int(input("Select port number: "))
        return ports[idx].device
    except (ValueError, IndexError, KeyboardInterrupt):
        print("Invalid selection.")
        sys.exit(1)


port = pick_port()
ser = serial.Serial(port, 9600, timeout=0.05)
print(f"Connected to {port}")
time.sleep(2)

outfile = f"log_{datetime.now().strftime('%Y-%m-%d_%H%M%S')}.csv"
print(f"Logging to {outfile}")
print("Type a throttle percentage (0-100) and press Enter. Ctrl+C to quit.\n")

try:
    with open(outfile, "w") as f:
        buf = ""
        while True:
            # Read serial data (non-blocking, short timeout)
            raw = ser.readline()
            if raw:
                line = raw.decode("utf-8", errors="replace").strip()
                if line:
                    print(line)
                    f.write(line + "\n")
                    f.flush()

            # Check for keyboard input without blocking
            if select.select([sys.stdin], [], [], 0)[0]:
                cmd = sys.stdin.readline().strip()
                if cmd:
                    ser.write((cmd + "\n").encode("utf-8"))
except KeyboardInterrupt:
    print("\nStopping...")
finally:
    ser.close()
    print(f"Log saved to {outfile}")
