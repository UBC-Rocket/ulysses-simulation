lb = [  0, 0, 0, ...   % X
        0, 0, 0, ...   % Y
        0, 0, 0, ...   % Z
        0, 0, 0 ];     % Z_pos

ub = [150, 30, 40, ... % X 
      150, 30, 40, ... % Y
      100, 20, 30, ... % Z
       80, 15, 25 ];   % Z_pos


modelName = 'root.slx';  
stopTime  = 10;                       
nvars = 12;


costFcn = @(gains) pidCost_v1(gains, modelName, stopTime);

options = optimoptions('particleswarm', ...
    'SwarmSize', 100, ...              
    'MaxIterations', 200, ...
    'MaxStallIterations', 30, ...       
    'UseParallel', true, ...          
    'Display', 'iter', ...
    'FunctionTolerance', 1e-5, ...
    'PlotFcn', @pswplotbestf, ...
    'HybridFcn', {@patternsearch, optimoptions('patternsearch','UseParallel',true)});

rng(42);  % Reproducible independent runs

[optimalGains, fval, exitflag, output] = particleswarm(costFcn, nvars, lb, ub, options);

% Results handling
disp('Optimal gains [Roll_P,I,D  Pitch_P,I,D  Yaw_P,I,D  Thrust_P,I,D]:');
disp(reshape(optimalGains, 3, 4)');

save('pso_4pid_results.mat', 'optimalGains', 'fval', 'output', 'lb', 'ub');