% run_stage2_ga.m — Stage 2 GA: pop=10 gen=5 StopTime=10s
% Seed: Test L (best manual, J=183.5, div at t=7.47s)
% cost_zt penalty: min_z < -30m (updated from -20)
cd(fileparts(mfilename('fullpath')));
SimulationFULLAssembly_DataFile;
PID_reset;

model = 'root';

% Search bounds — conservative, biased toward seed region
% x = [KpT KiT KdT  KpX KiX KdX  KpY KiY KdY  KpZ KiZ KdZ]
lb = [0.05, 0.005, 0.005,  0.10, 0.005, 0.001,  0.10, 0.005, 0.001,  0.005, 0.001, 0.0001];
ub = [0.60, 0.200, 0.200,  2.00, 0.300, 0.050,  2.00, 0.300, 0.050,  0.100, 0.020, 0.005 ];

% Seed row: warm-start GA at our best known point
x0 = [T.C.Kp, T.C.Ki, T.C.Kd, ...
      X.C.Kp, X.C.Ki, X.C.Kd, ...
      Y.C.Kp, Y.C.Ki, Y.C.Kd, ...
      Z.C.Kp, Z.C.Ki, Z.C.Kd];

opts = optimoptions('ga', ...
    'PopulationSize',          10, ...
    'MaxGenerations',           5, ...
    'InitialPopulationMatrix', x0, ...
    'Display',                 'iter', ...
    'FunctionTolerance',        1e-3, ...
    'UseParallel',              false);

fprintf('=== Stage 2 GA started: pop=10 gen=5 ===\n');
fprintf('Seed J = 183.48  |  Each eval ~5s  |  ~50 evals ~4min\n');
tic;
[x_best, J_best] = ga(@(x) cost_zt(x, model), ...
    12, [], [], [], [], lb, ub, [], opts);
elapsed = toc;

fprintf('\n=== Stage 2 GA Done in %.1f min ===\n', elapsed/60);
fprintf('J_best = %.4f\n', J_best);
fprintf('T:  Kp=%.6f  Ki=%.6f  Kd=%.6f\n', x_best(1),x_best(2),x_best(3));
fprintf('X:  Kp=%.6f  Ki=%.6f  Kd=%.6f\n', x_best(4),x_best(5),x_best(6));
fprintf('Y:  Kp=%.6f  Ki=%.6f  Kd=%.6f\n', x_best(7),x_best(8),x_best(9));
fprintf('Z:  Kp=%.6f  Ki=%.6f  Kd=%.6f\n', x_best(10),x_best(11),x_best(12));

save('GA_stage2_result.mat', 'x_best', 'J_best', 'elapsed');
fprintf('Saved to GA_stage2_result.mat\n');
