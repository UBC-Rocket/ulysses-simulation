% run_best.m — Run best known GA parameters and plot results
% Best result: z_final ~ -30 m (altitude control partially working)
% Attitude control (wx, wy) is stable; z-axis spin (wz) is damped

bdclose all
cd(fileparts(mfilename('fullpath')));
SimulationFULLAssembly_DataFile
PID_reset

% Best known parameters (GA-optimized, ZT joint run)
% T.C.* controls altitude (Thrust Control subsystem)
% Z.C.* controls attitude (Torque PD subsystem — Z axis)
% X.C.* and Y.C.* control attitude (X and Y axes) — set to 0, untuned
T.C.Kp = 2.72532; T.C.Ki = 0.10615; T.C.Kd = 0.11141;
Z.C.Kp = 2.00165; Z.C.Ki = 0.13626; Z.C.Kd = 0.07793;
Y.C.Kp = 0; Y.C.Ki = 0; Y.C.Kd = 0;
X.C.Kp = 0; X.C.Ki = 0; X.C.Kd = 0;

simIn = Simulink.SimulationInput('root');
simIn = simIn.setVariable('Z', Z);
simIn = simIn.setVariable('Y', Y);
simIn = simIn.setVariable('X', X);
simIn = simIn.setVariable('T', T);
simIn = simIn.setModelParameter('StopTime', '10');
simOut = sim(simIn);
logs = simOut.logsout;

zp = double(logs{1}.Values.Data(:));
xp = double(logs{2}.Values.Data(:)); xp = xp - xp(1);
yp = double(logs{3}.Values.Data(:)); yp = yp - yp(1);
w  = logs{5}.Values;
wa = double(w.Data);
if size(wa,1) ~= length(w.Time), wa = wa.'; end

fprintf('\n===== Simulation Results =====\n');
fprintf('final z  = %.2f m  (target = 10 m)\n', zp(end));
fprintf('max wmag = %.2f rad/s\n', max(sqrt(sum(wa.^2,2))));
fprintf('wz(end)  = %.2f rad/s\n', wa(end,3));
fprintf('x drift  = %.2f m\n', max(abs(xp)));
fprintf('y drift  = %.2f m\n', max(abs(yp)));

figure('Position', [100 100 1200 400]);
subplot(1,4,1);
plot(logs{1}.Values.Time, zp, 'b', 'LineWidth', 1.5);
yline(10, 'k--'); grid on;
title(sprintf('z final = %.1f m', zp(end))); xlabel('s'); ylabel('m');

subplot(1,4,2);
plot(logs{2}.Values.Time, xp, 'b', 'LineWidth', 1.5);
grid on; title(sprintf('x drift = %.1f m', max(abs(xp)))); xlabel('s'); ylabel('m');

subplot(1,4,3);
plot(logs{3}.Values.Time, yp, 'g', 'LineWidth', 1.5);
grid on; title(sprintf('y drift = %.1f m', max(abs(yp)))); xlabel('s'); ylabel('m');

subplot(1,4,4);
plot(w.Time, wa(:,1), 'b', w.Time, wa(:,2), 'r', w.Time, wa(:,3), 'g', 'LineWidth', 1.2);
legend('wx', 'wy', 'wz'); grid on;
title(sprintf('wz end = %.1f rad/s', wa(end,3))); xlabel('s'); ylabel('rad/s');

sgtitle('Best Result — GA Optimized (ZT Joint)');
