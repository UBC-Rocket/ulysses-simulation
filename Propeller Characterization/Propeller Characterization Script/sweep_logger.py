import serial
import time

ser = serial.Serial('COM5', 9600, timeout=1)
time.sleep(2)

try:
    with open("thrust_test.csv", "w") as f:
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
    print("Log saved to thrust_test.csv")