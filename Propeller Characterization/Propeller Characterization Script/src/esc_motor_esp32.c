#ifdef ESP_PLATFORM

#include "esc_motor.h"
#include "driver/ledc.h"

/*
 * ESP32 LEDC platform hooks for esc_motor.
 *
 * hw   = pointer to a ledc_channel_config_t (caller owns storage)
 * channel = ignored (channel is already inside the ledc config)
 *
 * The LEDC timer must be configured by the caller before esc_motor_init().
 * Example setup (in main or board init):
 *
 *   ledc_timer_config_t timer_cfg = {
 *       .speed_mode      = LEDC_LOW_SPEED_MODE,
 *       .timer_num       = LEDC_TIMER_0,
 *       .duty_resolution = LEDC_TIMER_14_BIT,   // 16384 steps
 *       .freq_hz         = 24000,                // 24 kHz — within ESC range
 *       .clk_cfg         = LEDC_AUTO_CLK,
 *   };
 *   ledc_timer_config(&timer_cfg);
 *
 *   ledc_channel_config_t ch_cfg = {
 *       .speed_mode = LEDC_LOW_SPEED_MODE,
 *       .channel    = LEDC_CHANNEL_0,
 *       .timer_sel  = LEDC_TIMER_0,
 *       .gpio_num   = GPIO_NUM_18,
 *       .duty       = 0,
 *       .hpoint     = 0,
 *   };
 *   ledc_channel_config(&ch_cfg);
 *
 *   esc_motor_init(&motor, &ch_cfg, 0);
 */

void esc_hw_start_pwm(void *hw, uint32_t channel) {
    (void)channel;
    if (hw == NULL) return;
    /* LEDC starts outputting as soon as ledc_channel_config() is called,
     * so nothing extra needed here. Just ensure duty is applied. */
    ledc_channel_config_t *cfg = (ledc_channel_config_t *)hw;
    ledc_update_duty(cfg->speed_mode, cfg->channel);
}

void esc_hw_set_pulse_us(void *hw, uint32_t channel, uint16_t us) {
    (void)channel;
    if (hw == NULL) return;
    ledc_channel_config_t *cfg = (ledc_channel_config_t *)hw;

    /* Look up the timer attached to this channel to get freq and resolution. */
    ledc_timer_t timer   = cfg->timer_sel;
    uint32_t     freq_hz = ledc_get_freq(cfg->speed_mode, timer);
    if (freq_hz == 0U) return;

    /* period_us = 1_000_000 / freq_hz
     * duty_max = (1 << resolution) — we use the full range
     * duty     = us * duty_max / period_us = us * freq_hz * duty_max / 1_000_000 */
    uint32_t duty_max  = (1U << LEDC_TIMER_14_BIT);  /* must match timer config */
    uint64_t duty_val  = (uint64_t)us * (uint64_t)freq_hz * (uint64_t)duty_max
                         / 1000000ULL;
    if (duty_val > duty_max) duty_val = duty_max;

    ledc_set_duty(cfg->speed_mode, cfg->channel, (uint32_t)duty_val);
    ledc_update_duty(cfg->speed_mode, cfg->channel);
}

#endif /* ESP_PLATFORM */
