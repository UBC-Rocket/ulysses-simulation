%% Thrust Vectoring Rocket Drone — Simulation
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


%% Parameters

% CAD component parameters
model_datafile;

% Reset PID values so that simulation can compile 
Z.C.Kp = 1; Z.C.Ki = 0; Z.C.Kd = 0;
Y.C.Kp = 1; Y.C.Ki = 0; Y.C.Kd = 0;
X.C.Kp = 1; X.C.Ki = 0; X.C.Kd = 0;
T.C.Kp = 1; T.C.Ki = 0; T.C.Kd = 0;


%% Load Model

open("root.slx")