prj_path = 'C:\Users\18203\Desktop\UBC\Rocket\ulysses-simulation-GA-Claude\ulysses-simulation.prj';
if isempty(matlab.project.currentProject); openProject(prj_path); end
if ~bdIsLoaded('root'); open_system('root.slx'); end
run('PID_reset.m');
Y.C.Kd = 0.01;  X.C.Kd = 0.008;
set_param('root','StopTime','15');
simOut = sim('root');
t=simOut.tout; z=simOut.z_pos.Data; wx=simOut.wx.Data; wy=simOut.wy.Data; wz=simOut.wz.Data;
wmag=sqrt(wx.^2+wy.^2+wz.^2);
idx1=t<=7.5; idx2=t>7.5;
fprintf('z_final=%.3f  z_max=%.3f  wmag_max=%.4f\n',z(end),max(z),max(wmag));
fprintf('wy_rms 0-7.5s=%.5f  7.5-15s=%.5f\n',rms(wy(idx1)),rms(wy(idx2)));
fprintf('wy_peak 0-7.5s=%.5f  7.5-15s=%.5f\n',max(abs(wy(idx1))),max(abs(wy(idx2))));
save('underdamp_fix_result.mat','t','z','wx','wy','wz','wmag');
fig=figure('Visible','off','Position',[100 100 1100 700]);
subplot(2,2,1); plot(t,z,'b'); yline(10,'r--'); grid on; title('Altitude'); xlabel('t'); ylabel('z(m)');
subplot(2,2,2); plot(t,wmag,'m'); grid on; title('wmag'); xlabel('t'); ylabel('rad/s');
subplot(2,2,3); plot(t,wy,'b'); xline(7.5,'k--'); grid on; title('wy pitch'); xlabel('t'); ylabel('rad/s');
subplot(2,2,4); plot(t,abs(wy),'b'); grid on; title('|wy| envelope'); xlabel('t'); ylabel('rad/s');
sgtitle(sprintf('Underdamp Fix YKd=0.01 XKd=0.008  z\\_end=%.2f  wmag=%.3f',z(end),max(wmag)));
saveas(fig,'underdamp_fix_result.png');
disp('DONE');
