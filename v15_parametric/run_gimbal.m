function run_gimbal(cx, cy, STOP)
% RUN_GIMBAL  THE runner for the parametric test-bed. Simulates root_param_gimbal
% (the model whose propeller gimbal actually articulates) and:
%   * opens Mechanics Explorer with the 3D animation, and
%   * plots altitude / horizontal drift / tilt / body rates.
% Uses the same stable controller gains as before.
%
%   run_gimbal              % centred CoM -> clean vertical flight + plots
%   run_gimbal(0.003)       % CoM offset on x -> UPPER gimbal visibly deflects in ME
%   run_gimbal(0, 0.003)    % offset on y -> LOWER gimbal
%   run_gimbal(0.003,0.003,8)
%
% cx drives the upper gimbal, cy the lower. NOTE: this marginal plant diverges a
% few seconds after a CoM offset (plant limitation) -- keep STOP short to watch
% the gimbal. Centred (default) flies straight up.

if nargin<1 || isempty(cx),   cx   = 0;  end
if nargin<2 || isempty(cy),   cy   = 0;  end
if nargin<3 || isempty(STOP), STOP = 15; end

here = fileparts(mfilename('fullpath')); cd(here);
addpath(genpath(here));
addpath(genpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\ulysses-simulation-GA-Claude-Backup4'));
addpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\v1.5_simscape_0510_simplified');

% body params + CoM offset
configure_body(); assignin('base','cx',cx); assignin('base','cy',cy);
SimulationFULLAssembly_DataFile; PID_reset;

% stable gains (same as before)
s3 = load(fullfile(here,'GA_stage3_result.mat')); x = s3.xs3_15;   % local copy in this folder
mk = @(a,b,c) struct('C',struct('Kp',a,'Ki',b,'Kd',c));
sc = 0.3; kdm = 150;
T = mk(x(1)*3,   x(2)*6,   x(3)*25);
X = mk(x(4)*sc,  x(5)*sc,  x(6)*sc*kdm);
Y = mk(x(7)*sc,  x(8)*sc,  x(9)*sc*kdm);
Z = mk(x(10)*sc, x(11)*sc, x(12)*sc);

load_system('root_param_gimbal');
% make sure the CAD geometry (smiData) is loaded into the model workspace
mw = get_param('root_param_gimbal','ModelWorkspace');
mw.DataSource = 'MATLAB File'; mw.FileName = 'V1_5GimbalAssembly_DataFile.m'; mw.reload();

in = Simulink.SimulationInput('root_param_gimbal');
in = in.setVariable('Z',Z).setVariable('Y',Y).setVariable('X',X).setVariable('T',T) ...
       .setModelParameter('StopTime',num2str(STOP));
so = sim(in); lg = so.logsout;   % Mechanics Explorer opens with the animation

% ---- extract + plot ----
tz = lg{1}.Values.Time;  zp = squeeze(double(lg{1}.Values.Data)); zp = zp(:);
xp = squeeze(double(lg{2}.Values.Data)); xp = xp(:);
yp = squeeze(double(lg{3}.Values.Data)); yp = yp(:);
qa = squeeze(double(lg{5}.Values.Data)); if size(qa,1)~=4, qa = qa.'; end; tq = lg{5}.Values.Time;
tilt = acosd(max(-1,min(1,1-2*(qa(2,:).^2+qa(3,:).^2))));
wv = squeeze(double(lg{6}.Values.Data)); if size(wv,1)~=3, wv = wv.'; end; tw = lg{6}.Values.Time;

figure('Position',[80 80 1200 760],'Color','w');
subplot(2,2,1); plot(tz,zp,'b','LineWidth',1.5); yline(10,'k--'); grid on; title(sprintf('Altitude z (final %.1f m)',zp(end))); xlabel('s'); ylabel('m');
subplot(2,2,2); plot(tz,hypot(xp-xp(1),yp-yp(1)),'m','LineWidth',1.5); grid on; title('Horizontal drift'); xlabel('s'); ylabel('m');
subplot(2,2,3); plot(tq,tilt,'r','LineWidth',1.5); grid on; title(sprintf('Tilt from vertical (max %.1f, end %.1f deg)',max(tilt),tilt(end))); xlabel('s'); ylabel('deg');
subplot(2,2,4); plot(tw,wv(1,:),'b',tw,wv(2,:),'r',tw,wv(3,:),'g','LineWidth',1.1); legend('wx','wy','wz'); grid on; title('Body rates'); xlabel('s'); ylabel('rad/s');
sgtitle(sprintf('root\\_param\\_gimbal  (cx=%.3f, cy=%.3f)', cx, cy));

fprintf('z_final=%.2f  tilt_max=%.1f  tilt_end=%.1f  |w|max=%.2f   (cx=%.3f cy=%.3f)\n', ...
        zp(end), max(tilt), tilt(end), max(sqrt(sum(wv.^2,1))), cx, cy);
fprintf('Mechanics Explorer shows the 3D animation; give a CoM offset to see the gimbal deflect.\n');
end
