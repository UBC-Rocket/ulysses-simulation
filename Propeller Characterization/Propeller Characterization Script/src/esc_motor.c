#include "esc_motor.h"
#include <stddef.h>

/* ---- helpers ---- */

static uint16_t clamp_us(uint16_t us, uint16_t lo, uint16_t hi) {
    if (us < lo) return lo;
    if (us > hi) return hi;
    return us;
}

static uint16_t pct_to_us(uint16_t us_min, uint16_t us_max, float pct) {
    float usf = (float)us_min + (pct * 0.01f) * (float)(us_max - us_min);
    return (uint16_t)(usf + 0.5f);
}

static void write_us(esc_motor_t *m, uint16_t us) {
    uint16_t clamped = clamp_us(us, m->us_min, m->us_max);
    esc_hw_set_pulse_us(m->hw, m->channel, clamped);
    m->us_output = clamped;
}

/* ---- public API ---- */

void esc_motor_init(esc_motor_t *m, void *hw, uint32_t channel) {
    if (m == NULL || hw == NULL) return;

    m->hw      = hw;
    m->channel = channel;

    m->us_min    = ESC_PULSE_MIN_US;
    m->us_max    = ESC_PULSE_MAX_US;
    m->us_target = m->us_min;
    m->us_output = m->us_min;
    m->armed     = false;
    m->last_cmd_ms = 0U;
}

void esc_motor_arm(esc_motor_t *m, uint32_t now_ms) {
    if (m == NULL) return;

    if (!esc_hw_start_pwm(m->hw, m->channel)) return;

    m->armed       = true;
    m->last_cmd_ms = now_ms;
    m->us_target   = m->us_min;
    write_us(m, m->us_min);
}

void esc_motor_disarm(esc_motor_t *m) {
    if (m == NULL) return;

    m->armed     = false;
    m->us_target = m->us_min;
    write_us(m, m->us_min);
    esc_hw_stop_pwm(m->hw, m->channel);
}

void esc_motor_set_throttle_pct(esc_motor_t *m, float pct, uint32_t now_ms) {
    if (m == NULL || !m->armed) return;
    if (pct < 0.0f)   pct = 0.0f;
    if (pct > 100.0f)  pct = 100.0f;

    m->us_target   = pct_to_us(m->us_min, m->us_max, pct);
    m->last_cmd_ms = now_ms;
    write_us(m, m->us_target);
}

void esc_motor_set_us(esc_motor_t *m, uint16_t us, uint32_t now_ms) {
    if (m == NULL || !m->armed) return;

    m->us_target   = clamp_us(us, m->us_min, m->us_max);
    m->last_cmd_ms = now_ms;
    write_us(m, m->us_target);
}

void esc_motor_update(esc_motor_t *m, uint32_t now_ms) {
    if (m == NULL) return;

    if (!m->armed) {
        if (m->us_output != m->us_min) {
            write_us(m, m->us_min);
        }
        return;
    }

    /* Command timeout: auto-disarm if no command received while above idle. */
    if (m->us_output > m->us_min) {
        uint32_t dt = now_ms - m->last_cmd_ms;
        if (dt > ESC_CMD_TIMEOUT_MS) {
            m->armed     = false;
            m->us_target = m->us_min;
            write_us(m, m->us_min);
            esc_hw_stop_pwm(m->hw, m->channel);
            return;
        }
    }

    if (m->us_output != m->us_target) {
        write_us(m, m->us_target);
    }
}
