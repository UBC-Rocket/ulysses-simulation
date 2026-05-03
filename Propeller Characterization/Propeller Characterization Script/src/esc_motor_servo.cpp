#if !defined(ESP_PLATFORM) || defined(ARDUINO)

#include "esc_motor.h"
#include <stddef.h>

#if defined(ARDUINO_ARCH_ESP32) && __has_include(<ESP32Servo.h>)
#include <ESP32Servo.h>
#else
#include <Servo.h>
#endif

extern "C" {

bool esc_hw_start_pwm(void *hw, uint32_t channel) {
    if (hw == NULL) return false;
    Servo *servo = (Servo *)hw;
    if (!servo->attached()) {
        servo->attach((int)channel, ESC_PULSE_MIN_US, ESC_PULSE_MAX_US);
    }
    return servo->attached();
}

void esc_hw_stop_pwm(void *hw, uint32_t channel) {
    (void)channel;
    if (hw == NULL) return;
    Servo *servo = (Servo *)hw;
    if (servo->attached()) {
        servo->detach();
    }
}

void esc_hw_set_pulse_us(void *hw, uint32_t channel, uint16_t us) {
    (void)channel;
    if (hw == NULL) return;
    Servo *servo = (Servo *)hw;
    servo->writeMicroseconds(us);
}

} /* extern "C" */

#endif /* !ESP_PLATFORM || ARDUINO */
