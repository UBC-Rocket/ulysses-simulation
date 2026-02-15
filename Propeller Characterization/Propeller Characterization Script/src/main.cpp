#include <Arduino.h>
#include "../include/ESC.h"
#include "HX711.h"
#include "Servo.h"

#define calibration_factor_1 38000
#define calibration_factor_2 -98000

#define DOUT1  A0
#define CLK1  A1
#define DOUT2  A2
#define CLK2  A3

HX711 scale1;
HX711 scale2;

ESC ESCp(9, 1000, 2000); //Esc for the motor in the positive roll axis (motor p)
ESC ESCn(10, 1000, 2000); //Esc for the motor in the negative roll axis (motor n)

// Sweep variables initialization
unsigned long lastStep = 0;
const unsigned long stepTime = 500;

int maxPulse = 1500; //The maximum value the motors will be allowed to reach.
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

 if(ESCp.init()){
  Serial.println("#ESCp initialized.");
 }
 if(ESCn.init()){
  Serial.println("#ESCn initialized.");
 }

 delay(10000); // Wait 10 seconds for ESC to initialize

 Serial.println("#Readings:");

 Serial.println("pulsep,pulsen,f1,f2,f3");  // CSV header only
}

void loop() {
 unsigned long now = millis();

  if (now - lastStep >= stepTime) {
    lastStep = now;

    printVals();

    ESCp.incrementVal(pulseStep);

    if (ESCp.getVal() >= maxPulse) {
      ESCp.setVal(1000);
      ESCn.incrementVal(pulseStep);
    }

    if(ESCp.getVal() >= maxPulse && ESCn.getVal() >= maxPulse){
      Serial.print("#Experiment Stopped");
      stop();
    }
  }
  // safety checks

  



}

void printVals(){
 Serial.print(ESCp.getVal());
 Serial.print(",");
 Serial.print(ESCn.getVal());
 Serial.print(",");
 Serial.print(scale1.get_units(), 3);
 Serial.print(",");
 Serial.println(scale2.get_units(), 3);
}

void stop(){
 ESCp.stop();
 ESCn.stop();
 while(true){}
}