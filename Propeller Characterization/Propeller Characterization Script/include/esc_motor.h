#ifndef ESC_MOTOR_H
#define ESC_MOTOR_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* 16-48 kHz bounds and corresponding period range in microseconds. */
#define ESC_PWM_FREQ_MIN_HZ   16000U
#define ESC_PWM_FREQ_MAX_HZ   48000U
#define ESC_PWM_PERIOD_MIN_US  21U   /* ceil(1e6 / 48kHz) */
#define ESC_PWM_PERIOD_MAX_US  62U   /* floor(1e6 / 16kHz) */

#define ESC_CMD_TIMEOUT_MS     200U

typedef struct {
    void    *hw;              /* platform-specific handle (TIM_HandleTypeDef*, ledc cfg, …) */
    uint32_t channel;         /* platform channel identifier */

    uint16_t us_min;          /* pulse width at 0% throttle */
    uint16_t us_max;          /* pulse width at 100% throttle */
    uint16_t us_target;       /* requested pulse width */
    uint16_t us_output;       /* last written pulse width */

    bool     armed;
    uint32_t last_cmd_ms;
} esc_motor_t;

/* ---- portable API (implemented in esc_motor.c / shared logic) ---- */
void     esc_motor_init(esc_motor_t *m, void *hw, uint32_t channel);
void     esc_motor_arm(esc_motor_t *m, uint32_t now_ms);
void     esc_motor_disarm(esc_motor_t *m);
void     esc_motor_set_throttle_pct(esc_motor_t *m, float pct, uint32_t now_ms);
void     esc_motor_update(esc_motor_t *m, uint32_t now_ms);

/* ---- platform hooks (implemented per-platform) ---- */
void     esc_hw_start_pwm(void *hw, uint32_t channel);
void     esc_hw_set_pulse_us(void *hw, uint32_t channel, uint16_t us);

#ifdef __cplusplus
}
#endif

#endif /* ESC_MOTOR_H */
