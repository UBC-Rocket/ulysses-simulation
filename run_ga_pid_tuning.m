clc;
clear;
close all;

%% Load model parameters
SimulationFULLAssembly_DataFile
PID_reset

%% Model name
model = 'root';
load_system(model);

%% Optional: turn on Fast Restart manually in Simulink before running
% This can speed up repeated simulations.

%% Number of optimization variables
% [KpZ KiZ KdZ  KpY KiY KdY  KpX KiX KdX  KpT KiT KdT]
nvars = 12;

%% Initial guess from your current controller
x0 = [ ...
    0.01,  0.0025, 0.0005, ...   % Z
    0.185, 0.0025, 0.0015, ...   % Y
    0.14,  0.0025, 0.0005, ...   % X
    0.2,   0.0025, 0.00005 ...   % T
];

%% Lower bounds
lb = [ ...
    0, 0, 0, ...
    0, 0, 0, ...
    0, 0, 0, ...
    0, 0, 0 ...
];

%% Upper bounds
% Start conservative. Widen later if needed.
ub = [ ...
    0.5, 0.02, 0.01, ...   % Z
    0.5, 0.02, 0.01, ...   % Y
    0.5, 0.02, 0.01, ...   % X
    0.5, 0.02, 0.005 ...   % T
];

%% Objective function
objFun = @(x) ga_pid_cost_root(x, model);

%% Initial population (optional but helpful)
% Put your current gains into first row so GA starts from something reasonable.
popSize = 30;
initPop = zeros(popSize, nvars);
initPop(1,:) = x0;

for i = 2:popSize
    initPop(i,:) = lb + rand(1,nvars).*(ub-lb);
end

%% GA options
opts = optimoptions('ga', ...
    'PopulationSize', popSize, ...
    'MaxGenerations', 25, ...
    'EliteCount', 3, ...
    'CrossoverFraction', 0.8, ...
    'MutationFcn', @mutationadaptfeasible, ...
    'InitialPopulationMatrix', initPop, ...
    'Display', 'iter', ...
    'UseParallel', false, ...
    'PlotFcn', {@gaplotbestf});

%% Run GA
[xbest, fbest, exitflag, output] = ga(objFun, nvars, [], [], [], [], lb, ub, [], opts);

%% Convert best vector back into structs
Z.C.Kp = xbest(1);   Z.C.Ki = xbest(2);   Z.C.Kd = xbest(3);
Y.C.Kp = xbest(4);   Y.C.Ki = xbest(5);   Y.C.Kd = xbest(6);
X.C.Kp = xbest(7);   X.C.Ki = xbest(8);   X.C.Kd = xbest(9);
T.C.Kp = xbest(10);  T.C.Ki = xbest(11);  T.C.Kd = xbest(12);

%% Assign best gains to base workspace
assignin('base','Z',Z);
assignin('base','Y',Y);
assignin('base','X',X);
assignin('base','T',T);

%% Print result
disp(' ');
disp('========== BEST GA RESULT ==========');
fprintf('Best cost = %.8f\n', fbest);

fprintf('\nZ.C.Kp = %.8f; Z.C.Ki = %.8f; Z.C.Kd = %.8f;\n', Z.C.Kp, Z.C.Ki, Z.C.Kd);
fprintf('Y.C.Kp = %.8f; Y.C.Ki = %.8f; Y.C.Kd = %.8f;\n', Y.C.Kp, Y.C.Ki, Y.C.Kd);
fprintf('X.C.Kp = %.8f; X.C.Ki = %.8f; X.C.Kd = %.8f;\n', X.C.Kp, X.C.Ki, X.C.Kd);
fprintf('T.C.Kp = %.8f; T.C.Ki = %.8f; T.C.Kd = %.8f;\n', T.C.Kp, T.C.Ki, T.C.Kd);

%% Save result
save('ga_pid_best_result.mat', 'xbest', 'fbest', 'Z', 'Y', 'X', 'T', 'exitflag', 'output');

%% Run one final simulation with the best gains
simOutBest = sim(model, 'StopTime', '10');

disp(' ');
disp('Final simulation with best gains completed.');