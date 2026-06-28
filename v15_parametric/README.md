# 06212026
Simplified model. The original weight, center of mass, inertia, unnecessary parts are all cancelled, and are able to be set manually. 

Overall Structure: 
**Outer Loop**: Two PIDs, new introduced, can be seen in the bottom-left corner in root_param_gimbal
            Input: Error of X and Y (desired values are 0)
            Output: Desired tilt (not gimbal angle, but rocket body tilt)
            Logic: If rocket drifts to X/Y, how to adjust body tilt to make it come back
**Inner Loop**: Four PIDs, original PID
            Input (Torque control * 3): Desired tilt (X/Y) from outer loop, and desired Z (0)
            Output (Torque control * 3): Torque command around X/Y/Z
            Logic: If rocket wants to go to certain tilt angle, how to apply torque to realize that
            Input (Thrust control * 1): Desired height - actual height
            Output (Thrust control * 1): Thrust magnitude
            Logic (Thrust control * 1): If rocket cannot reach desired height, how to adjust thrust. It also co-work with Torque control

Basic operations are listed below: 

1. **Check structure**: open root_param_gimbal

2. **Run simulation**: open run_gimbal and click run. It will refer to root_param_gimbal

3. **Change weight, center of mass, inertia, simulation time**: open and run body_dashboard, then those paras can be set arbitrarily. Go line 17 to 19 in run_gimbal if you just want to change x and y offset of mass center, or you want to change simulation time

4. **Change PID gains**: go line 34 to 37 in run_gimbal. Now it refers to GA_stage3_result, but exact values can also be set here directly 

5. **Add camera that follows rocket**: Multibody Explorer - Camera Manager - Create New Camera - Mode(Tracking) - Position(SCN_CamDrone - R) - Aim(SCN_CAM_MARKER - R) - Up Vector(+Z, World - W) - Save - Apply

6. **Create a good animation**: go to _tools and run animate flight

7. **Change layout of simscape and want to save it forever**: click save in simulink. Your layout will not be overwritten unless you run build_model again. If you want to apply your change in build_model, save your change and run capture_layout

8. **Hide weight shape on rocket**: The "weight" shape thing on rocket can be hidden in left manu "BodyDyn" if you don't want

9. **Run algorithm to find optimal configuration**: Use run_ga_param




# V1.5 Parametric Test-Bed — Quick Guide

> Original controller + a **parameter-adjustable rigid-body plant** (set mass / CoM / inertia / moment arm freely),
> with the full V1.5 appearance, and the **propeller gimbal articulates in response to the control commands**.
> Used to test / tune the controller in isolation.
>
> The only daily model is **`root_param_gimbal.slx`**, and the main runner is **`run_gimbal`**
> (`body_dashboard` and `run_ga_param` also run simulations).

---

## 1. What you use often (main folder)

| Goal | Use | How |
|---|---|---|
| **Run sim + plots + animation** | `run_gimbal` | Type `run_gimbal` (centred CoM → flies straight up; produces a 4-panel altitude / drift / tilt / body-rate figure; Mechanics Explorer shows the 3D animation) |
| **Change mass / CoM / inertia / moment arm** | `configure_body.m` | Edit `BODY.M / cx / cy / cz / Ixx / Iyy / Izz / L` inside it, then `run_gimbal` |
| **Interactive slider tuning + save as default** | `body_dashboard` | Type `body_dashboard`, drag the sliders → **Run & Plot**; when happy, click **Save as default** (writes back to `configure_body.m`) |
| **Auto-tune the 12 PID gains with a GA** | `run_ga_param` | e.g. `run_ga_param(20,30)` (generations, population) |

- **Watch the gimbal articulate**: give a CoM offset, e.g. `run_gimbal(0.003)` (offset on x → upper gimbal) or `run_gimbal(0,0.003)` (offset on y → lower gimbal).
  Note: under an offset, this marginally-stable plant diverges after a few seconds (a plant limitation); use `run_gimbal(0.003,0,6)` to shorten the duration and just watch the gimbal.
- **Change the PID gains**: tune by hand in `run_gimbal.m` (the `T / X / Y / Z` lines); auto-tune with `run_ga_param`.
  > Note: the Y (pitch) axis damping `Kd` is only ~1/5 of the X axis, which is the main cause of the head-wagging / drift; it can be evened out here.

---

## 2. Occasional visualization tools (`_tools/` folder)

After running `run_gimbal` or `body_dashboard` once, these can be called directly by name (the path is already added), and all act on `root_param_gimbal`:

| Tool | Purpose |
|---|---|
| `add_scenery` | Adds reference scenery (ground + pole lattice + altitude planes) to Mechanics Explorer. **Does not affect the dynamics.** Already added — normally you don't touch it. |
| `add_follow_cam` | Adds a "camera drone" `SCN_CamDrone` (hung off World, driven by the rocket's position). In the Camera Manager set Tracking, Position=`SCN_CamDrone`, Aim=`SCN_CAM_MARKER` to get a chase cam. Already added. |
| `animate_flight` | Standalone follow-camera replay animation (reads the sim result and draws its own rocket, exports `flight_animation.mp4`). Decoupled from the model. |
| `unweld_gimbal` | (Rebuild step) Un-welds and drives the gimbal joints + sets the visual amplification factor. **Requires `root_param` to exist first** (see below); not used day-to-day. To change just the amplification you can also edit the `cmd_upper_g`/`cmd_lower_g` Gain blocks inside `root_param_gimbal` directly. **Its last step automatically calls `apply_layout` to restore the hand-tuned layout.** |
| `capture_layout` | **Snapshots** the current `root_param_gimbal` block positions/orientations + wire routing to `_rebuild/layout_gimbal.mat`. **Run it once after you arrange the layout by hand in Simulink**, so that a future rebuild (`build_model`+`unweld_gimbal`) comes out looking the way you tuned it. |
| `apply_layout` | Re-applies that snapshot to the model (blocks/lines that don't match are skipped, no error). `unweld_gimbal` already calls it at the end, so you normally don't run it by hand. |

---

## 3. Don't touch (internal / rebuild only)

| File / folder | Notes |
|---|---|
| `root_param_gimbal.slx` | **The model itself** (you can open it in Simulink to inspect the structure, but change all parameters from the scripts above — don't hand-edit the values inside) |
| **`_rebuild/`** folder | **For rebuilding the model from CAD — normally leave it alone**: `build_model.m` + `V1_5GimbalAssembly_DataFile.m` + `plant_param.slx` + `mb_wiring.mat` + `layout_gimbal.mat` (the layout snapshot produced by `capture_layout`). Flow: first `build_model` (generates a temporary frozen `root_param`) → then `_tools/unweld_gimbal` (un-welds and drives the gimbal, generates `root_param_gimbal`, and **restores the layout from `layout_gimbal.mat` at the end**). |
| `*.slxc` · `slprj/` | Simulink auto-generated cache — ignore it (it regenerates if deleted) |

> Note: although `V1_5GimbalAssembly_DataFile.m` lives in `_rebuild/`, it is **also a runtime dependency** — `run_gimbal` loads it as the model workspace data source (it holds the CAD geometry `smiData`) on every run, so **do not delete it**.

---

## 4. One-liner to get started

```matlab
cd into this folder
configure_body          % (optional) edit mass / CoM / inertia
run_gimbal              % run + plots + 3D animation
% or:
body_dashboard          % slider UI tuning + Save as default
% watch the gimbal articulate:
run_gimbal(0.003,0,6)   % a bit of CoM offset + short duration
```
