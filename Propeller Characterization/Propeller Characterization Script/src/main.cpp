#include <Arduino.h>
#include "HX711.h"
#include "Servo.h"

#define calibration_factor_1 38000
#define calibration_factor_2 -98000
#define calibration_factor_3 41000

#define DOUT1  A0
#define CLK1  A1
#define DOUT2  A2
#define CLK2  A3
#define DOUT3  A4
#define CLK3  A5

HX711 scale1;
HX711 scale2;
HX711 scale3;

Servo ESCp; //Esc for the motor in the positive roll axis (motor p)
Servo ESCn; //Esc for the motor in the negative roll axis (motor n)

// Sweep variables initialization
unsigned long lastStep = 0;
const unsigned long stepTime = 500;

int maxPulse = 1800; //The maximum value the motors will be allowed to reach.

int pulsep = 1000; //Throttle for motor p
int pulsen = 1000; //Throttle for motor n

int pulseStep = 100; 

void printVals();
void stop();

void setup() {
 Serial.begin(9600);
 Serial.println("#Motor Calibration Experiment");

 // Load Cell Calibration

 scale1.begin(DOUT1, CLK1);
 scale1.set_scale(calibration_factor_1); //This value is obtained by using the SparkFun_HX711_Calibration sketch
 scale1.tare(); //Assuming there is no weight on the scale at start up, reset the scale to 0
 Serial.println("#scale 1 tare done");

 scale2.begin(DOUT2, CLK2);
 scale2.set_scale(calibration_factor_2); //This value is obtained by using the SparkFun_HX711_Calibration sketch
 scale2.tare(); //Assuming there is no weight on the scale at start up, reset the scale to 0
 Serial.println("#scale 2 tare done");

 scale3.begin(DOUT3, CLK3);
 scale3.set_scale(calibration_factor_3); //This value is obtained by using the SparkFun_HX711_Calibration sketch
 scale3.tare(); //Assuming there is no weight on the scale at start up, reset the scale to 0
 Serial.println("#scale 3 tare done");

 Serial.println("#Readings:");

 //Esc initialization
 pinMode(9, OUTPUT);
 pinMode(10, OUTPUT);

 ESCp.attach(9, 1000, 2000);
 ESCp.writeMicroseconds(1000);

 ESCp.attach(10, 1000, 2000);
 ESCp.writeMicroseconds(1000);

 delay(10000); // Wait 10 seconds for ESC to initialize

 Serial.println("pulsep,pulsen,f1,f2,f3");  // CSV header only
}

void loop() {
 unsigned long now = millis();

  if (now - lastStep >= stepTime) {
    lastStep = now;

    ESCp.writeMicroseconds(pulsep);

    printVals();

    pulsep += pulseStep; //Increment p motor

    if (pulsep >= maxPulse) {
      ESCp.writeMicroseconds(1000); //Reset p motor to 0

      pulsen += pulseStep; //Increment p motor
      ESCn.writeMicroseconds(pulsen);
    }

    if(pulsep >= maxPulse && pulsen >= maxPulse){
      Serial.print("#Experiment Stopped");
      stop();
    }
  }
  // safety checks

}

void printVals(){
 Serial.print(pulsep);
 Serial.print(",");
 Serial.print(pulsen);
 Serial.print(",");
 Serial.print(scale1.get_units(), 3);
 Serial.print(",");
 Serial.print(scale2.get_units(), 3);
 Serial.print(",");
 Serial.println(scale3.get_units(), 3);
}

void stop(){
  while(true){}
}