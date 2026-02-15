#pragma once
#include <Arduino.h>
#include <Servo.h>
#include <esc_motor.h>

// class ESC{
//     private:
//     Servo Esc;
//     int val = 1000;

//     int pin; //Initialization Values
//     int minv;
//     int maxv;
//     bool initialized = 0;

//     public:
//     explicit ESC(int _pin, int _min, int _max):pin(_pin), minv(_min), maxv(_max){}

//     bool init(){
//         pinMode(pin, OUTPUT);
//         Esc.attach(pin, minv, maxv);
//         Esc.writeMicroseconds(val);
//         initialized = 1;
//         return true;
//     }

//     void setVal(int _val){
//         if (!initialized){return;}
//         val = _val;
//         Esc.writeMicroseconds(val);
//     }

//     void incrementVal(int inc){
//         setVal(val+inc);
//     }
//     int getVal(){
//         if (!initialized){return;}
//         return val;
//     }
//     void stop(){
//         setVal(1000);
//     }
// };

class ESC {
    private:
    Servo driver;       // The actual Arduino driver
    esc_motor_t motor;  // The C-struct holding the state

    public:
    // Constructor: Initialize the C-struct fields
    explicit ESC(int _pin, int _min_us, int _max_us) {
        // Zero out the struct first (good practice)
        memset(&motor, 0, sizeof(esc_motor_t));

        // Map Inputs to Struct
        motor.channel = _pin;       // We use 'channel' to store the Arduino Pin
        motor.us_min = _min_us;
        motor.us_max = _max_us;
        
        // specific defaults
        motor.us_target = 1000;
        motor.us_output = 1000;
        motor.armed = false;

        // IMPORTANT: Link the C struct 'hw' pointer to our C++ Servo object
        // This allows C functions to potentially access the driver if cast back
        motor.hw = (void*)&driver; 
    }

    bool init() {
        // Use the struct data to attach the servo
        // Note: .hw needs to be cast back to Servo* to be used, 
        // but here we just use the member 'driver' directly.
        uint8_t pin = (uint8_t)motor.channel;
        
        driver.attach(pin, motor.us_min, motor.us_max);
        
        // Set initial state
        motor.armed = true;
        setVal(motor.us_min); // Start at 0 throttle
        
        return true;
    }

    void setVal(int _us_target) {
        if (!motor.armed) return;

        // 1. Update Target
        motor.us_target = _us_target;
        motor.last_cmd_ms = millis(); // Track when we last got a command

        // 2. Safety Clamp (using struct limits)
        if (motor.us_target < motor.us_min) motor.us_target = motor.us_min;
        if (motor.us_target > motor.us_max) motor.us_target = motor.us_max;

        // 3. Write to Hardware
        motor.us_output = motor.us_target;
        driver.writeMicroseconds(motor.us_output);
    }

    void incrementVal(int inc) {
        // Use the current target from the struct as the base
        setVal(motor.us_target + inc);
    }

    int getVal() {
        if (!motor.armed) return 0;
        return motor.us_output;
    }

    void stop() {
        setVal(motor.us_min); // Use the struct's defined minimum
    }

    // Helper: Expose the raw struct in case C functions need it
    esc_motor_t* getRawState() {
        return &motor;
    }
};