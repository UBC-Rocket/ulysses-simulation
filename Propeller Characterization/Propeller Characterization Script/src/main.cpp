#include <Arduino.h>
#include "../include/ESC.h"
#include "HX711.h"


#define calibration_factor_1 38000
#define calibration_factor_2 -98000

// ── GPIO pins (ESP32 testboard) ──
#define PWM1_PIN    25
#define PWM2_PIN    26

#define DOUT1       16   // HX711 #1 DT
#define CLK1        17   // HX711 #1 SCK
#define DOUT2       18   // HX711 #2 DT
#define CLK2        19   // HX711 #2 SCK

#define VBAT1_PIN   32   // Battery voltage ADC
#define VBAT2_PIN   33
#define VBAT3_PIN   34

#define TACH1_PIN   21
#define TACH2_PIN   22
#define LED1_PIN    27
#define LED2_PIN    14

HX711 scale1;
HX711 scale2;

ESC ESCp(PWM1_PIN, 1000, 2000);  // Esc for the motor in the positive roll axis (motor p)
ESC ESCn(PWM2_PIN, 1000, 2000);  // Esc for the motor in the negative roll axis (motor n)

// Load cell sampling
unsigned long lastSample = 0;
const unsigned long sampleTime = 50; // 20 Hz load cell reads

// Throttle from serial (0.0 – 100.0 %)
float throttlePct = 0.0f;

// ── Original sweep logic (1000–2000 µs, step 100) ──
 //Sweeps every combination of throttle between the 2 motors.
 unsigned long lastStep = 0;
 const unsigned long stepTime = 2000;
 int maxPulse = 1500;
 int pulsep = 1000;
 int pulsen = 1000;
 int pulseStep = 100;

// ADC -> voltage conversion (ESP32: 12-bit, 3.3V ref)
const float ADC_TO_V = 3.3f / 4095.0f;

// Counter for the tachs
volatile int pulseCount1 = 0;
volatile int pulseCount2 = 0;

// last sample time
unsigned long tachLastSampleMs = 0;

// rpm values for the two propellers
float rpm1 = 0.0f;
float rpm2 = 0.0f;


void printLoadCells();
void readSerialThrottle();
void stop();
void read_rpm();

// ISR for tach
void IRAM_ATTR tachISR1(){
    pulseCount1++;
};
void IRAM_ATTR tachISR2(){
    pulseCount2++;
};

void setup()
{
    Serial.begin(115200);
    Serial.println("#Motor Calibration Experiment");

    // Load Cell Calibration

    scale1.begin(DOUT1, CLK1);
    scale1.set_scale(22000/50); // This value is obtained by using the SparkFun_HX711_Calibration sketch
    scale1.tare();                          // Assuming there is no weight on the scale at start up, reset the scale to 0
    Serial.println("#scale 1 tare done");

    scale2.begin(DOUT2, CLK2);
    scale2.set_scale(21000/50); // This value is obtained by using the SparkFun_HX711_Calibration sketch
    scale2.tare();                          // Assuming there is no weight on the scale at start up, reset the scale to 0
    Serial.println("#scale 2 tare done");

    bool escp_ok = ESCp.init();
    bool escn_ok = ESCn.init();

    if (escp_ok) {
        Serial.println("#ESCp initialized.");
    } else {
        Serial.println("#ESCp initialization failed.");
    }

    if (escn_ok) {
        Serial.println("#ESCn initialized.");
    } else {
        Serial.println("#ESCn initialization failed.");
    }

    if (!escp_ok || !escn_ok) {
        Serial.println("#Experiment stopped: ESC init failed.");
        stop();
    }


    delay(10000); // Wait 10 seconds for ESC to initialize
    
    // setup tach interrupts
    pinMode(TACH1_PIN, INPUT_PULLUP);
    pinMode(TACH2_PIN, INPUT_PULLUP);
    pinMode(LED1_PIN, OUTPUT);
    pinMode(LED2_PIN, OUTPUT);
    attachInterrupt(digitalPinToInterrupt(TACH1_PIN), tachISR1, FALLING);
    attachInterrupt(digitalPinToInterrupt(TACH2_PIN), tachISR2, FALLING);
    
    tachLastSampleMs = millis(); // update tach last sample time at setup to make sure the first vlaue read is good

    Serial.println("#Readings:");

    Serial.println("time_ms,throttle_pct,pulsep,pulsen,f1,f2,vbat1,vbat2,vbat3,vbat_tot"); // CSV header
}

void loop()
{
    /*
    // Read throttle from serial if available
    readSerialThrottle();

    // Apply throttle to both ESCs
    ESCp.setPct(throttlePct);
    ESCn.setPct(throttlePct);

    ESCp.update();
    ESCn.update();

    unsigned long now = millis();

    // Print load cell data at sampleTime rate (20 Hz)
    if (now - lastSample >= sampleTime) {
        lastSample = now;
        printLoadCells();
    }
    */

    // ── Original sweep logic (uncomment to auto-sweep) ──
    // Sweeps pulsep from 1000 to maxPulse in steps of pulseStep.
    // When pulsep reaches maxPulse, resets pulsep to 1000 and increments pulsen.
    // Stops when pulsen exceeds maxPulse.
    //
    
/*
    unsigned long now = millis();
     if (now - lastStep >= stepTime) {
         lastStep = now;
/*
            ESCp.setVal(1000);
            ESCn.setVal(1000);

            
            delay(500);
            
            scale1.tare();
            scale2.tare();

            ESCp.setVal(pulsep);
            ESCn.setVal(pulsen);

*/
    /*
         ESCp.setVal(pulsep);
    
         //delay(500);
         //printLoadCells();
    
         pulsep += pulseStep;
    
         if (pulsep > maxPulse) {
             pulsep = 1000;
             ESCp.setVal(1000);
    
             pulsen += pulseStep;
             if (pulsen > maxPulse) {
                 ESCn.setVal(1000);
                 Serial.println("#Experiment Stopped");
                 stop();
             }
             ESCn.setVal(pulsen);
         }
     }
    */
    
     read_rpm();

     delay(10);

}

void printLoadCells()
{
    Serial.print(millis());
    Serial.print(",");
    Serial.print(throttlePct, 1);
    Serial.print(",");
    Serial.print(ESCp.getVal());
    Serial.print(",");
    Serial.print(ESCn.getVal());
    Serial.print(",");
    double scale1_val = scale1.get_units(); // Convert to Newtons (negative sign accounts for load cell orientation)
    Serial.print(scale1_val, 3);
    Serial.print(",");
    double scale2_val = scale2.get_units(); // Convert to Newtons (negative sign accounts for load cell orientation)
    Serial.print(scale2_val, 3);
    Serial.print(",");
    Serial.print((analogRead(VBAT1_PIN) * 4.267 - analogRead(VBAT2_PIN) * 4.243) * ADC_TO_V, 3);
    Serial.print(",");
    Serial.print((analogRead(VBAT2_PIN) * 4.243 - analogRead(VBAT3_PIN) * 4.252) * ADC_TO_V, 3);
    Serial.print(",");
    Serial.print(analogRead(VBAT3_PIN) * ADC_TO_V * 4.252, 3);
    Serial.print(",");
    Serial.println((analogRead(VBAT1_PIN) * ADC_TO_V * 4.267) / 3.0, 3);
    Serial.print(rpm1);
    Serial.print(rpm2);
}


void readSerialThrottle()
{
    if (!Serial.available()) return;

    String input = Serial.readStringUntil('\n');
    input.trim();
    float val = input.toFloat();
 
    if (val < 0.0f) val = 0.0f;
    if (val > 100.0f) val = 100.0f;

    throttlePct = val;
    Serial.print("#Throttle set to ");
    Serial.print(throttlePct, 1);
    Serial.println("%");
}

void read_rpm(){
    // sample the propeller with a window greater than 100ms
     unsigned long nowTach = millis();
     unsigned long tach_sample_time_ms = nowTach - tachLastSampleMs;
     
     if(tach_sample_time_ms >= 100){
        noInterrupts();
        int c1 = pulseCount1;
        int c2 = pulseCount2;
        pulseCount1 = 0;
        pulseCount2 = 0;
        interrupts();

        tachLastSampleMs = nowTach;

        rpm1 = (c1 * 60000.0f) / tach_sample_time_ms;
        rpm2 = (c2 * 60000.0f) / tach_sample_time_ms;
     }
     /*
     Serial.print(digitalRead(TACH1_PIN));
     Serial.print(", ");
     Serial.println(digitalRead(TACH2_PIN));
     */

     digitalWrite(LED1_PIN, digitalRead(TACH1_PIN));
     digitalWrite(LED2_PIN, digitalRead(TACH2_PIN));

     /*
    int p1 = pulseCount1;
    int p2 = pulseCount2;
     Serial.printf("p1: %d ", p1);
     Serial.printf("p2: %d\n", p2);
     Serial.printf("rpm1: %f ", rpm1);
     Serial.printf("rpm2: %f\n", rpm2);
     */
}

void stop()
{
    ESCp.stop();
    ESCn.stop();
    while (true)
    {
    }
}
