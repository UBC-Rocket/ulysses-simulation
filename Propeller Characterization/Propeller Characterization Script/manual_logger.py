#!/usr/bin/env python3
"""Manual serial logger for propeller characterization (Windows/macOS).

Logs all serial data to CSV and lets you type throttle commands.

Usage:
    python manual_logger.py
"""

import sys
import time
import threading
from datetime import datetime

import serial
import serial.tools.list_ports


def keyboard_thread(ser, running):
    """Background thread to handle user input without blocking serial reads."""
    while running[0]:
        try:
            cmd = input().strip()
            if cmd:
                ser.write((cmd + "\n").encode("utf-8"))
        except (EOFError, OSError):
            break


def pick_port():
    """Interactive port selection."""
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


def main():
    # Force unbuffered output for real-time display
    sys.stdout.reconfigure(line_buffering=True)
    
    # Setup serial connection
    port = pick_port()
    
    # Higher baud rate reduces Windows buffering delays
    ser = serial.Serial(port, 115200, timeout=0.001)
    
    # Windows-specific: minimize serial buffer latency
    if sys.platform == 'win32':
        try:
            ser.set_buffer_size(rx_size=64, tx_size=64)
        except (AttributeError, NotImplementedError):
            pass
    
    print(f"Connected to {port} at 115200 baud")
    print("NOTE: Make sure ESP32 is using Serial.begin(115200)!")
    sys.stdout.flush()
    time.sleep(2)
    
    # Start background thread for keyboard input
    running = [True]
    kbd = threading.Thread(target=keyboard_thread, args=(ser, running), daemon=True)
    kbd.start()
    
    # Setup logging
    outfile = f"log_{datetime.now().strftime('%Y-%m-%d_%H%M%S')}.csv"
    print(f"Logging to {outfile}")
    print("Type a throttle percentage (0-100) and press Enter. Ctrl+C to quit.\n")
    sys.stdout.flush()
    
    try:
        with open(outfile, "w", encoding="utf-8", buffering=1) as f:  # Line buffering
            line_buffer = ""
            
            while True:
                # Read all available data immediately
                bytes_waiting = ser.in_waiting
                
                if bytes_waiting > 0:
                    raw = ser.read(bytes_waiting)
                    line_buffer += raw.decode("utf-8", errors="replace")
                    
                    # Process all complete lines
                    while "\n" in line_buffer:
                        line, line_buffer = line_buffer.split("\n", 1)
                        line = line.strip()
                        
                        if line:
                            # Write to file
                            f.write(line + "\n")
                            
                            # Force immediate console output
                            sys.stdout.write(line + "\n")
                            sys.stdout.flush()
                
                else:
                    # Brief sleep to prevent CPU spinning
                    time.sleep(0.0001)
    
    except KeyboardInterrupt:
        print("\nStopping...")
    finally:
        running[0] = False
        time.sleep(0.1)
        ser.close()
        print(f"Log saved to {outfile}")


if __name__ == "__main__":
    main()