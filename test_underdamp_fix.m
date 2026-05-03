% test_underdamp_fix.m — with smiData init
SimulationFULLAssembly_DataFile;
Z.C.Kp = 0.00264052; Z.C.Ki = 0.00690042; Z.C.Kd = 0.00271555;
Y.C.Kp = 0.47095420; Y.C.Ki = 0.02832272; Y.C.Kd = 0.01;
X.C.Kp = 0.63869669; X.C.Ki = 0.03187948; X.C.Kd = 0.008;
T.C.Kp = 0.24245203; T.C.Ki = 0.02191524; T.C.Kd = 0.03592343;
disp('Gains set. Running 15s sim...');
simOut = sim('root', 'StopTime', '15');
disp('Sim done.');
logsout = simOut.logsout;
t   = logsout{'omega_body'}.Values.Time;
wx  = logsout{'omega_body'}.Values.Data(:,1);
wy  = logsout{'omega_body'}.Values.Data(:,2);
wz  = logsout{'omega_body'}.Values.Data(:,3);
wmag = sqrt(wx.^2 + wy.^2 + wz.^2);
t_alt = logsout{'altitude'}.Values.Time;
alt   = logsout{'altitude'}.Values.Data;
t_att = logsout{'attitude_error'}.Values.Time;
att   = logsout{'attitude_error'}.Values.Data;
z_final  = alt(end);
z_max    = max(alt);
wmag_max = max(wmag);
att_mean = mean(abs(att));
idx1 = t <= 7.5; idx2 = t > 7.5;
wy_rms1 = rms(wy(idx1)); wy_rms2 = rms(wy(idx2));
div_idx = find(abs(att) > 1.0, 1);
fprintf('\n=== RESULTS ===\n');
fprintf('  z_final  : %.4f m\n', z_final);
fprintf('  z_max    : %.4f m\n', z_max);
fprintf('  wmag_max : %.4f rad/s\n', wmag_max);
fprintf('  att_mean : %.6f\n', att_mean);
fprintf('  wy RMS 0-7.5s  : %.6f\n', wy_rms1);
fprintf('  wy RMS 7.5-15s : %.6f\n', wy_rms2);
if isempty(div_idx)
    disp('  att_diverge: NONE in 15s');
else
    fprintf('  att_diverge: YES at t=%.2fs\n', t_att(div_idx));
end
if wy_rms2 > 1.5*wy_rms1
    fprintf('  wy growth: GROWING (ratio=%.2f)\n', wy_rms2/wy_rms1);
else
    fprintf('  wy growth: SUPPRESSED (ratio=%.2f)\n', wy_rms2/wy_rms1);
end
figure('Name','UnderdampFix15s','NumberTitle','off');
subplot(3,1,1); plot(t_alt,alt,'b-','LineWidth',1.5); hold on;
yline(10,'r--','10m'); yline(0,'k:'); grid on;
xlabel('t(s)'); ylabel('Alt(m)'); title('Altitude — Fix Y.Kd=0.01 X.Kd=0.008');
subplot(3,1,2); plot(t,wx,'r',t,wy,'g',t,wz,'b','LineWidth',1.2);
xline(7.5,'k--'); legend('wx','wy','wz'); grid on;
xlabel('t(s)'); ylabel('rad/s'); title('Angular rates — wy damping check');
subplot(3,1,3); plot(t_att,att,'m','LineWidth',1.2);
yline(1,'r--'); yline(-1,'r--'); grid on;
xlabel('t(s)'); ylabel('att err'); title('Attitude Error');
saveas(gcf,'underdamp_fix_result.png');
disp('Plot saved.');
