% baseline_15s.m — Stage 3 gains unchanged, 15s sim (divergence baseline)
bdclose all;
projPath = 'C:\Users\18203\Desktop\UBC\Rocket\ulysses-simulation-GA-Claude\ulysses-simulation.prj';
if isempty(matlab.project.rootProject())
    openProject(projPath);
end
SimulationFULLAssembly_DataFile;
PID_reset;
fprintf('Stage 3 gains — NO fix applied:\n');
fprintf('Y.C.Kd=%.5f  X.C.Kd=%.5f\n', Y.C.Kd, X.C.Kd);
simIn = Simulink.SimulationInput('root');
simIn = simIn.setVariable('Z', Z);
simIn = simIn.setVariable('Y', Y);
simIn = simIn.setVariable('X', X);
simIn = simIn.setVariable('T', T);
simIn = simIn.setModelParameter('StopTime', '15');
disp('Running 15s baseline sim...');
simOut = sim(simIn);
disp('Done.');
logs = simOut.logsout;
zp = double(logs{1}.Values.Data(:));
w  = logs{5}.Values;
wa = double(w.Data);
if size(wa,1) ~= length(w.Time), wa = wa.'; end
wx = wa(:,1); wy = wa(:,2);
wmag = sqrt(sum(wa.^2,2));
tw = w.Time;
i1 = tw<=7.5; i2 = tw>7.5;
fprintf('\n=== STAGE 3 BASELINE (15s, unmodified) ===\n');
fprintf('wy max first  half: %.4f rad/s\n', max(abs(wy(i1))));
fprintf('wy max second half: %.4f rad/s\n', max(abs(wy(i2))));
fprintf('wx max first  half: %.4f rad/s\n', max(abs(wx(i1))));
fprintf('wx max second half: %.4f rad/s\n', max(abs(wx(i2))));
fprintf('wmag_max: %.4f rad/s\n', max(wmag));
fprintf('z_final:  %.4f m\n', zp(end));
fprintf('===========================================\n');
