function BODY = configure_body()
% configure_body  The ONLY dynamics the controller cares about. Change these to
% fit any mechanical iteration without touching the model. The V1.5 multibody
% keeps its appearance and moving gimbal, but every part's own mass/inertia is
% disabled; the body's dynamics come entirely from these lumped values.
%
% Pushes the variables to the base workspace (model blocks reference them).

BODY.M   = 0.643;        % total mass                              [kg]
BODY.cx  = 0.0;          % CoM offset along control X (0 = centred) [m]
BODY.cy  = 0.0;          % CoM offset along control Y (0 = centred) [m]
BODY.cz  = 0.0;          % CoM offset along control Z (thrust axis) [m]
BODY.Ixx = 1.50e-3;      % moment of inertia about control X       [kg*m^2]
BODY.Iyy = 1.50e-3;      % moment of inertia about control Y       [kg*m^2]
BODY.Izz = 1.00e-3;      % moment of inertia about control Z (roll)[kg*m^2]
BODY.L   = 0.15;         % gimbal moment arm: CoM -> nozzle          [m]

assignin('base','Larm',BODY.L);
assignin('base','M',  BODY.M);
assignin('base','cx', BODY.cx);
assignin('base','cy', BODY.cy);
assignin('base','cz', BODY.cz);
assignin('base','Ixx',BODY.Ixx);
assignin('base','Iyy',BODY.Iyy);
assignin('base','Izz',BODY.Izz);
end
