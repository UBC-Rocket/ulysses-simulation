#pragma once
#include <Arduino.h>
#include <Servo.h>

class ESC{
    private:
    Servo Esc;
    int val = 1000;

    int pin; //Initialization Values
    int minv;
    int maxv;
    bool initialized = 0;

    public:
    explicit ESC(int _pin, int _min, int _max):pin(_pin), minv(_min), maxv(_max){}

    bool init(){
        pinMode(pin, OUTPUT);
        Esc.attach(pin, minv, maxv);
        Esc.writeMicroseconds(val);
        initialized = 1;
        return true;
    }

    void setVal(int _val){
        if (!initialized){return;}
        val = _val;
        Esc.writeMicroseconds(val);
    }

    void incrementVal(int inc){
        setVal(val+inc);
    }
    int getVal(){
        if (!initialized){return;}
        return val;
    }
    void stop(){
        setVal(1000);
    }
};