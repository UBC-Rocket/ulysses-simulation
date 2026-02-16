#pragma once

#include <Arduino.h>
#include <esc_motor.h>
#include <string.h>

#if defined(ARDUINO_ARCH_ESP32) && __has_include(<ESP32Servo.h>)
#include <ESP32Servo.h>
#else
#include <Servo.h>
#endif

class ESC {
  private:
    Servo driver;
    esc_motor_t motor;
    int val;
    int pin;
    int minv;
    int maxv;

    static int clampInt(int v, int lo, int hi) {
        if (v < lo) return lo;
        if (v > hi) return hi;
        return v;
    }

  public:
    explicit ESC(int _pin, int _min_us, int _max_us)
        : val(_min_us), pin(_pin), minv(_min_us), maxv(_max_us) {
        memset(&motor, 0, sizeof(esc_motor_t));
    }

    bool init() {
#if defined(ARDUINO_ARCH_ESP32)
        driver.setPeriodHertz(ESC_PWM_FREQ_HZ);
#endif
        driver.attach(pin, minv, maxv);
        if (!driver.attached()) {
            return false;
        }
        esc_motor_init(&motor, &driver, (uint32_t)pin);
        motor.us_min = (uint16_t)minv;
        motor.us_max = (uint16_t)maxv;
        esc_motor_arm(&motor, millis());
        val = minv;
        return motor.armed;
    }

    void setVal(int us) {
        val = clampInt(us, minv, maxv);
        esc_motor_set_us(&motor, (uint16_t)val, millis());
    }

    void setPct(float pct) {
        if (pct < 0.0f) pct = 0.0f;
        if (pct > 100.0f) pct = 100.0f;
        esc_motor_set_throttle_pct(&motor, pct, millis());
        float us = (float)minv + (pct * 0.01f) * (float)(maxv - minv);
        val = clampInt((int)(us + 0.5f), minv, maxv);
    }

    void incrementVal(int inc) {
        setVal(val + inc);
    }

    int getVal() {
        return val;
    }

    void update() {
        uint32_t now = millis();
        esc_motor_set_us(&motor, (uint16_t)val, now);
        esc_motor_update(&motor, now);
    }

    bool isArmed() const {
        return motor.armed;
    }

    void stop() {
        val = minv;
        esc_motor_disarm(&motor);
    }
};
