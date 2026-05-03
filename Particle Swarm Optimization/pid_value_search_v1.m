
% PID Value Search for the 4 PID controllers 



% PID Tuning Setup
controllerType = 'PID';

targetPM_z = 55;
targetBW_z = 7;
opts_z = pidtuneOptions('PhaseMargin', targetPM_z, 'DesignFocus', 'reference-tracking');  

targetPM_y = 55;
targetBW_y = 6;
opts_y = pidtuneOptions('PhaseMargin', targetPM_y, 'DesignFocus', 'reference-tracking');  

targetPM_x = 55;
targetBW_x = 6;
opts_x = pidtuneOptions('PhaseMargin', targetPM_x, 'DesignFocus', 'reference-tracking');  

targetPM_t = 45;
targetBW_t = 5;
opts_t = pidtuneOptions('PhaseMargin', targetPM_t, 'DesignFocus', 'reference-tracking');

%run('model_datafile.m');

% Axial PID Controllers - ZYX, Thrust - T
warning('off','all');


% Simulink File
modelFile = 'root';

% Check if model is open
if ~bdIsLoaded(modelFile)
    load_system(modelFile);
end

op = operpoint(modelFile);

% Pull I/Os from the model - Double Check Before Running!!!
Z.io(1) = linio('root/Z_ang', 1, 'input');
Y.io(1) = linio('root/Y_ang', 1, 'input');
X.io(1) = linio('root/X_ang', 1, 'input');
T.io(1) = linio('root/Z_body', 1, 'input');

Z.io(2) = linio('root/Demux2', 1, 'output');
Y.io(2) = linio('root/Demux2', 2, 'output');
X.io(2) = linio('root/Demux2', 3, 'output');
T.io(2) = linio('root/Demux', 3, 'output');


% Linearize each system
Z.sys = linearize(modelFile, Z.io);
Y.sys = linearize(modelFile, Y.io);
X.sys = linearize(modelFile, X.io);
T.sys = linearize(modelFile, T.io);


% Convert to s-domain transfer function
Z.G = tf(Z.sys); Z.G = minreal(Z.G);
Y.G = tf(Y.sys); Y.G = minreal(Y.G);
X.G = tf(X.sys); X.G = minreal(X.G);
T.G = tf(T.sys); T.G = minreal(T.G);


% Tune Controllers
[Z.C, Z.info] = pidtune(Z.G, controllerType, targetBW_z, opts_z);
[Y.C, Y.info] = pidtune(Y.G, controllerType, targetBW_y, opts_y);
[X.C, X.info] = pidtune(X.G, controllerType, targetBW_x, opts_x);
[T.C, T.info] = pidtune(T.G, controllerType, targetBW_t, opts_t);

[Z.C.Kp, Z.C.Ki, Z.C.Kd]
[Y.C.Kp, Y.C.Ki, Y.C.Kd]
[X.C.Kp, X.C.Ki, X.C.Kd]
[T.C.Kp, T.C.Ki, T.C.Kd]