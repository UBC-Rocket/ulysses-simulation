%% Thrust Vectoring Rocket Drone — Particle Swarm Optimization Tuning
% *Author:* Hannah |  *Date:* 2026-09-20 |  *Subteam:* Controls

%% Environment Check

openProject('ulysses-simulation.prj');

%{ 
Dependencies: Aerospace Blockset, Global Optimization Toolbox, MATLAB
Optimization Toolbox, Simscape, Simscape Electrical, Simscape Multibody, Simulink, Simulink Control Design, UAV Toolbox
%}

% Confirms required toolboxes are on the path before anything else runs. 

requiredToolboxes = ["Aerospace Blockset", "Global Optimization Toolbox", "MATLAB", "Optimization Toolbox", "Simscape", "Simscape Electrical", "Simscape Multibody", "Simulink", "Simulink Control Design", "UAV Toolbox"];
installed = struct2table(ver).Name;

missing = requiredToolboxes(~ismember(requiredToolboxes, installed));
if ~isempty(missing)
    error("Missing required toolbox(es): %s", strjoin(missing, ", "));
else
    disp("All required toolboxes found.")
end



%% PSO Configuration
% Configure the following section to set up the PSO algorithm

% Define bounds for search space 
lb = [  0, 0, 0, ...   % X
        0, 0, 0, ...   % Y
        0, 0, 0, ...   % Z
        0, 0, 0 ];     % Z_pos

ub = [0.25, 0, 0.1, ... % X 
      0.25, 0, 0.1, ... % Y
      0.25, 0, 0.1, ... % Z
      0.25, 0.1, 0.1];   % Z_pos


stopTime  = 10;  % Per-round simulation stop time                     
nvars = 12; % Number of particles to start

gains = [0.5, 0, 0, ...
         0.5, 0, 0, ...
         0.5, 0, 0, ...
         0.5, 0, 0];

%% Run PSO Algorithm

costFcn = @(gains) pidCost_v1(gains, 10);


options = optimoptions('particleswarm', ...
    'SwarmSize', 5, ...
    'MaxIterations', 50, ...
    'Display', 'iter');

[optGains, fval] = particleswarm(costFcn, nvars, lb, ub, options);

%% Save Results to CSV File 

% Create table with headers and write new file
T = array2table(optGains, "VariableNames", compose("Gain%d",1:numel(optGains)));
T.Fval = fval;
writetable(T, "optResults.csv");  


