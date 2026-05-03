import serial
import time
from datetime import datetime

ser = serial.Serial('COM5', 9600, timeout=1)
time.sleep(2)

outfile = f"sweep_{datetime.now().strftime('%Y-%m-%d_%H%M%S')}.csv"

try:
    with open(outfile, "w") as f:
        while True:
            line = ser.readline().decode(errors="ignore").strip()
            if line:
                print(line)
                f.write(line + "\n")
                f.flush()
except KeyboardInterrupt:
    print("\nLogging stopped by user.")
finally:
    ser.close()
    print(f"Log saved to {outfile}")