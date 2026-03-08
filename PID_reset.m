% Use when tuning starts going nowhere
Z.C.Kp = 0.5; Z.C.Ki = 0.0025; Z.C.Kd = 0.0005; 
Y.C.Kp = 0.3; Y.C.Ki = 0.0025; Y.C.Kd = 0.0015; 
X.C.Kp = 0.3; X.C.Ki = 0.0025; X.C.Kd = 0.0005; 
T.C.Kp = 0.2; T.C.Ki = 0.0025; T.C.Kd = 0.00005; 

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