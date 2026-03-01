import serial
import time

ser = serial.Serial('COM6', 115200, timeout = 1)
time.sleep(2)

try:
    with open("thrust_test1_propp.csv", "w") as f:
        while True:
            line = ser.readline().decode(errors="ignore").strip()
            if line:
                print(line)

                if not line.startswith("#"):
                    f.write(line + "\n")
                    f.flush()
except KeyboardInterrupt:
    print("\nLogging stopped by user.")
finally:
    ser.close()