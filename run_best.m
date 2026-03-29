% run_best.m — Stage 3 GA best (J=16.67)
% Run from cold MATLAB restart — no prior workspace needed.

bdclose all;
cd(fileparts(mfilename('fullpath')));

%% 1. Initialize models and workspace (same as original)
SimulationFULLAssembly_DataFile
PID_reset

%% 2. Load Stage 3 GA best gains directly from saved result
s3 = load('GA_stage3_result.mat');
x = s3.xs3_15;
T.C.Kp=x(1);  T.C.Ki=x(2);  T.C.Kd=x(3);
X.C.Kp=x(4);  X.C.Ki=x(5);  X.C.Kd=x(6);
Y.C.Kp=x(7);  Y.C.Ki=x(8);  Y.C.Kd=x(9);
Z.C.Kp=x(10); Z.C.Ki=x(11); Z.C.Kd=x(12);
fprintf('Loaded Stage 3 best — J=%.4f\n', s3.Js3_15);

%% 3. Run simulation (10s)
simIn = Simulink.SimulationInput('root');
simIn = simIn.setVariable('Z', Z);
simIn = simIn.setVariable('Y', Y);
simIn = simIn.setVariable('X', X);
simIn = simIn.setVariable('T', T);
simIn = simIn.setModelParameter('StopTime', '10');
simOut = sim(simIn);

%% 4. Extract and display results
logs = simOut.logsout;
zp   = double(logs{1}.Values.Data(:));
xp   = double(logs{2}.Values.Data(:)); xp = xp - xp(1);
yp   = double(logs{3}.Values.Data(:)); yp = yp - yp(1);
w    = logs{5}.Values;
wa   = double(w.Data);
if size(wa,1) ~= length(w.Time), wa = wa.'; end
wmag = sqrt(sum(wa.^2, 2));
fprintf('\n===== Stage 3 GA Best — Results =====\n');
fprintf('z_final   = %.2f m  (target = 10 m)\n', zp(end));
fprintf('z_max     = %.2f m\n', max(zp));
fprintf('wmag_max  = %.2f rad/s\n', max(wmag));
fprintf('x_drift   = %.2f m\n', xp(end));

%% 5. Plot
figure('Position', [100 100 1200 400]);
subplot(1,4,1);
plot(logs{1}.Values.Time, zp, 'b', 'LineWidth', 1.5); yline(10,'k--');
grid on; title(sprintf('z final = %.1f m', zp(end))); xlabel('s'); ylabel('m');
subplot(1,4,2);
plot(logs{2}.Values.Time, xp, 'b', 'LineWidth', 1.5);
grid on; title(sprintf('x drift = %.1f m', xp(end))); xlabel('s'); ylabel('m');
subplot(1,4,3);
plot(w.Time, wmag, 'r', 'LineWidth', 1.5);
grid on; title(sprintf('wmag max = %.2f rad/s', max(wmag))); xlabel('s'); ylabel('rad/s');
subplot(1,4,4);
plot(w.Time, wa(:,1), 'b', w.Time, wa(:,2), 'r', w.Time, wa(:,3), 'g', 'LineWidth', 1.2);
legend('wx','wy','wz'); grid on;
title('Angular rates'); xlabel('s'); ylabel('rad/s');
sgtitle('Stage 3 GA Best — J=16.67');
