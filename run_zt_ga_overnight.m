% run_zt_ga_overnight.m — GA optimizer for ZT joint PID tuning
% Optimizes 12 parameters: T (altitude) + X/Y/Z (attitude, all 3 axes)
% Saves best result to GA_ZT_result.mat
% Recommended: 30 pop x 30 gen (~2 hours)

bdclose all
cd(fileparts(mfilename('fullpath')));
SimulationFULLAssembly_DataFile
PID_reset

% x = [KpT KiT KdT  KpX KiX KdX  KpY KiY KdY  KpZ KiZ KdZ]
lb = [0.1, 0.001, 0.01,  0.1, 0.001, 0.01,  0.1, 0.001, 0.01,  0.1, 0.001, 0.01];
ub = [3.0, 0.2,   0.5,   8.0, 0.5,   1.0,   8.0, 0.5,   1.0,   8.0, 0.5,   1.0 ];

opts = optimoptions('ga', ...
    'PopulationSize',   30, ...
    'MaxGenerations',   30, ...
    'Display',          'iter', ...
    'FunctionTolerance', 1e-4);

fprintf('=== GA started (30 pop x 30 gen) ===\n');
tic;

[x_best, J_best] = ga(@(x) cost_zt(x, 'root'), ...
    12, [], [], [], [], lb, ub, [], opts);

elapsed = toc;
fprintf('\n=== Done in %.1f min ===\n', elapsed/60);
fprintf('T:  Kp=%.5f  Ki=%.5f  Kd=%.5f\n', x_best(1), x_best(2), x_best(3));
fprintf('X:  Kp=%.5f  Ki=%.5f  Kd=%.5f\n', x_best(4), x_best(5), x_best(6));
fprintf('Y:  Kp=%.5f  Ki=%.5f  Kd=%.5f\n', x_best(7), x_best(8), x_best(9));
fprintf('Z:  Kp=%.5f  Ki=%.5f  Kd=%.5f\n', x_best(10),x_best(11),x_best(12));
fprintf('J = %.4f\n', J_best);

save('GA_ZT_result.mat', 'x_best', 'J_best');
fprintf('Saved to GA_ZT_result.mat\n');
