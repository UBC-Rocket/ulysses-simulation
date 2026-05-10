% Use when tuning starts going nowhere
Z.C.Kp = 0.00245; Z.C.Ki = 0.00612; Z.C.Kd = 0.00250; 
Y.C.Kp = 0.34743; Y.C.Ki = 0.01867; Y.C.Kd = 0.00300; 
X.C.Kp = 0.53550; X.C.Ki = 0.03137; X.C.Kd = 0.00325; 
T.C.Kp = 0.18390; T.C.Ki = 0.01970; T.C.Kd = 0.03439; 

%     0.2405         0    0.0024    0.1180         0    0.0392    0.2047         0    0.0476    0.2497    0.0858    0.0069

%Inner Loop Attitude PID:

%T (Thrust): Kp=
% 0.18390, Ki=0.01970, Kd=0.03439
%X (Roll): Kp=0.53550, Ki=0.03137, Kd=0.00325
%Y (Pitch): Kp=0.34743, Ki=0.01867, Kd=0.00300
%Z (Yaw): Kp=0.00245, Ki=0.00612, Kd=0.00250
%{
Feedforward Torque Compensation:

TAU_COMP = [0; -0.020; 0] Nm
Compensates Avionics Bay CoM offset (x=+4.8mm, z=+21.3mm)
Outer Position Loop:

Kp=0.200, Ki=0.050, Kd=0.050, output saturation ±5°, LPF cutoff 0.5 Hz
%}
%{

Good Set:

Z.C.Kp = 0.01; Z.C.Ki = 0; Z.C.Kd = 0.001; 
Y.C.Kp = 0.18; Y.C.Ki = 0; Y.C.Kd = 0.001; 
X.C.Kp = 0.15; X.C.Ki = 0; X.C.Kd = 0.001; 
T.C.Kp = 0.2; T.C.Ki = 0.001; T.C.Kd = 0.0001; 
%}


%{
pid_value_search_v1

ans =

   1.0e+08 *

   -1.2559   -0.0769   -5.1258


ans =

   1.0e+04 *

   -0.2654   -0.0139   -1.2636


ans =

   1.0e+05 *

   -0.3323   -0.0174   -1.5821


ans =

   1.0e+09 *

    1.5212    0.0666    8.6923


pid_value_search_v1
[Z.C.Kp, Z.C.Ki, Z.C.Kd] = 1.0e+08 *[-1.2555, -0.1099, -3.5870]

[Y.C.Kp, Y.C.Ki, Y.C.Kd] = 1.0e+03 *[-2.6554, -0.2324, -7.5867]

[X.C.Kp, X.C.Ki, X.C.Kd] = 1.0e+04 *[-3.3199, -0.2905, -9.4852]

[T.C.Kp, T.C.Ki, T.C.Kd] = 1.0e+09 *[1.5213, 0.1331, 4.3464]

%}