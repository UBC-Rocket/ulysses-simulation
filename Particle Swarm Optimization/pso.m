lb = [  0, 0, 0, ...   % X
        0, 0, 0, ...   % Y
        0, 0, 0, ...   % Z
        0, 0, 0 ];     % Z_pos

ub = [0.25, 0, 0.1, ... % X 
      0.25, 0, 0.1, ... % Y
      0.25, 0, 0.1, ... % Z
      0.25, 0.1, 0.1];   % Z_pos


stopTime  = 10;                       
nvars = 12;

gains = [0.5, 0, 0, ...
         0.5, 0, 0, ...
         0.5, 0, 0, ...
         0.5, 0, 0];

costFcn = @(gains) pidCost_v1(gains, 10);

% start off with just 10 LOL 
options = optimoptions('particleswarm', ...
    'SwarmSize', 5, ...
    'MaxIterations', 50, ...
    'Display', 'iter');

[optGains, fval] = particleswarm(costFcn, nvars, lb, ub, options)
