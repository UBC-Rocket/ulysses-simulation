% test_underdamp.m — Underdamping fix test (Y.C.Kd=0.01, X.C.Kd=0.008, 15s)
bdclose all;
projPath = 'C:\Users\18203\Desktop\UBC\Rocket\ulysses-simulation-GA-Claude\ulysses-simulation.prj';
if isempty(matlab.project.rootProject())
    openProject(projPath);
end
SimulationFULLAssembly_DataFile;
PID_reset;
% Apply underdamping fix on top of Stage 3 GA gains
Y.C.Kd = 0.01;
X.C.Kd = 0.008;
fprintf('Gains: Y.C.Kd=%.5f  X.C.Kd=%.5f\n', Y.C.Kd, X.C.Kd);
simIn = Simulink.SimulationInput('root');
simIn = simIn.setVariable('Z', Z);
simIn = simIn.setVariable('Y', Y);
simIn = simIn.setVariable('X', X);
simIn = simIn.setVariable('T', T);
simIn = simIn.setModelParameter('StopTime', '15');
disp('Running 15s sim...');
simOut = sim(simIn);
disp('Done.');
t    = simOut.tout;
logs = simOut.logsout;
zp = double(logs{1}.Values.Data(:));
xp = double(logs{2}.Values.Data(:));
yp = double(logs{3}.Values.Data(:));
w  = logs{5}.Values;
wa = double(w.Data);
if size(wa,1) ~= length(w.Time), wa = wa.'; end
wx = wa(:,1); wy = wa(:,2); wz = wa(:,3);
wmag = sqrt(wx.^2 + wy.^2 + wz.^2);
tw   = w.Time;
i1   = tw <= 7.5; i2 = tw > 7.5;
fprintf('\n=== UNDERDAMP FIX RESULTS (15s) ===\n');
fprintf('wy max  first  half (0-7.5s):  %.4f rad/s\n', max(abs(wy(i1))));
fprintf('wy max  second half (7.5-15s): %.4f rad/s\n', max(abs(wy(i2))));
fprintf('wx max  first  half (0-7.5s):  %.4f rad/s\n', max(abs(wx(i1))));
fprintf('wx max  second half (7.5-15s): %.4f rad/s\n', max(abs(wx(i2))));
fprintf('wmag_max:  %.4f rad/s\n', max(wmag));
fprintf('z_final:   %.4f m\n', zp(end));
fprintf('z_max:     %.4f m\n', max(zp));
if max(abs(wy(i2))) < max(abs(wy(i1)))
    disp('>> wy: DAMPED (second half < first half — GOOD)');
else
    disp('>> wy: STILL GROWING in second half — needs more Kd');
end
fprintf('=====================================\n');
