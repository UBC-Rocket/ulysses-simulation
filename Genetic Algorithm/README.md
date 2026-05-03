# Rocket Gimbal Control Simulation

MATLAB R2025b + Simulink + Simscape Multibody

---

## Quick Start

Open MATLAB, `cd` to this folder, then run:

```matlab
run_best
```

This loads the model, applies the best known GA-tuned PID parameters, runs a 10-second simulation, and plots results.

---

## Current Results

| Metric | Value | Target |
|--------|-------|--------|
| Final altitude z | ~−30 m | 10 m |
| Tilt rate (wx, wy) | ~±5 rad/s | ~0 |
| Z-axis spin (wz) | ~±10 rad/s | ~0 |
| Lateral drift (x/y) | large | 0 |

Altitude control is partially working — the rocket generates upward thrust and the attitude is partially stabilized, but the Z-axis PID mapping issue (see Known Issues) prevents full convergence.

---

## Files Required to Run

### Root model
- `root.slx` — top-level Simulink model

### Submodels (referenced by root.slx)
- `Gimbal Control Module/Gimbal_Control.slx`
- `Torque Module/torque_control.slx`
- `Torque Module/torque_decompose.slx`
- `Thrust Control Module/thrust_control.slx`
- `Skeleton Body/skeleton_v6_sub.slx`

### MATLAB scripts (required)
- `SimulationFULLAssembly_DataFile.m` — Simscape Multibody data (mass, inertia, geometry)
- `PID_reset.m` — initializes all PID structs to zero
- `run_best.m` — runs best known parameters and plots results

### 3D model files (required by Simscape)
- `models/` folder — all `.STEP` files must remain in place

---

## PID Variable Mapping (Important)

The variable naming in this model is counterintuitive:

| Variable | Controls | Location in model |
|----------|----------|-------------------|
| `T.C.Kp/Ki/Kd` | **Altitude** (thrust magnitude) | Thrust Control subsystem |
| `Z.C.Kp/Ki/Kd` | **Attitude Z-axis** torque | Torque PD subsystem |
| `X.C.Kp/Ki/Kd` | Attitude X-axis torque | Torque PD subsystem |
| `Y.C.Kp/Ki/Kd` | Attitude Y-axis torque | Torque PD subsystem |

X and Y attitude axes are currently set to zero (untuned).

---

## Known Issues / Limitations

1. **Altitude overshoots / diverges** — The attitude controller only controls the Z body axis; X and Y axes are open-loop (gains = 0), causing lateral tip-over that disrupts altitude tracking.

2. **Lateral drift (x/y)** — No closed-loop lateral position control. X/Y PID outputs are not connected to any effective actuator path.

3. **Z-axis spin (wz)** — The gimbal has no authority over the body Z-axis. Roll spin cannot be controlled without an additional actuator.

4. **Quaternion unwinding** — The attitude error signal uses a sign switch on q0, which causes discontinuities as the rocket attitude changes. This contributes to oscillation.

---

## To Re-run the GA Optimizer

```matlab
% Uses cost_zt.m — 12-parameter joint optimization
run_zt_ga_overnight
```

Results are saved to `GA_ZT_result.mat`.

---

## Dependencies

- MATLAB R2025b
- Simulink
- Simscape Multibody
- Global Optimization Toolbox (for `ga`)
