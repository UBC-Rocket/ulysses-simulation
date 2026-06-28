function animate_flight(varargin)
% ANIMATE_FLIGHT  Follow-camera replay of the closed-loop flight, with a
% reference world (ground grid, vertical poles, altitude planes) so the motion
% is readable and the rocket never disappears off-screen.
%
% This is a lightweight alternative to the Mechanics Explorer view: instead of
% the detailed V1.5 CAD mesh it draws a simple rocket (body + nose + fins)
% oriented by the logged body quaternion, and a camera that locks onto the
% rocket every frame. Reference scenery stays fixed in the world, so as the
% rocket climbs/drifts the scenery scrolls past -- giving a clear sense of
% altitude and motion.
%
% Usage:
%   animate_flight                         % run sim (same gains as run_param), replay, save MP4
%   animate_flight(so)                     % replay an existing SimulationOutput
%   animate_flight(..., 'fps', 30)         % output/playback frame rate (default 30)
%   animate_flight(..., 'mp4', 'name.mp4') % output file ('' to skip saving; default 'flight_animation.mp4')
%   animate_flight(..., 'stop', 15)        % sim StopTime when no SimulationOutput is given
%   animate_flight(..., 'camoff', [-7 -10 3]) % camera offset from rocket, world frame [m]
%   animate_flight(..., 'camva', 28)       % camera view angle [deg] (smaller = more zoom)
%   animate_flight(..., 'trail', true)     % draw the travelled path as a trailing line
%
% The logged-signal indexing (z=1, x=2, y=3, quaternion=5) mirrors run_param.m.

here = fileparts(mfilename('fullpath')); cd(here);
addpath(genpath(fileparts(here)));   % this file is in _tools/; deps (configure_body, root_param, ...) live in the parent folder

% ---- options -------------------------------------------------------------
so = [];
if ~isempty(varargin) && isa(varargin{1},'Simulink.SimulationOutput')
    so = varargin{1}; varargin(1) = [];
end
opt = struct('fps',30,'mp4','flight_animation.mp4','stop',15, ...
             'camoff',[-7 -10 3],'camva',28,'trail',true);
for k = 1:2:numel(varargin)
    f = lower(varargin{k});
    assert(isfield(opt,f),'animate_flight: unknown option "%s"',varargin{k});
    opt.(f) = varargin{k+1};
end

% ---- get a flight log ----------------------------------------------------
if isempty(so)
    so = runFlight(opt.stop);
end
lg = so.logsout;
tz = lg{1}.Values.Time;
zp = col(squeeze(double(lg{1}.Values.Data)));
xp = col(squeeze(double(lg{2}.Values.Data)));
yp = col(squeeze(double(lg{3}.Values.Data)));
qa = squeeze(double(lg{5}.Values.Data)); if size(qa,1)~=4, qa = qa.'; end  % [4 x N], [w x y z]
tq = lg{5}.Values.Time;

% ---- resample everything onto a uniform frame grid -----------------------
t0 = max(tz(1),tq(1)); t1 = min(tz(end),tq(end));
tf = (t0:1/opt.fps:t1).';
X  = interp1(tz,xp,tf);  Y = interp1(tz,yp,tf);  Z = interp1(tz,zp,tf);
Q  = interp1(tq,qa.',tf);                      % [Nf x 4]
Q  = Q ./ vecnorm(Q,2,2);                      % renormalise after interpolation
Nf = numel(tf);

% ---- world extents for the scenery --------------------------------------
padXY = 4;
xlo = min(X)-padXY; xhi = max(X)+padXY;
ylo = min(Y)-padXY; yhi = max(Y)+padXY;
zhi = max(Z)+3;

% ---- figure & static scenery --------------------------------------------
fig = figure('Color',[0.53 0.70 0.92],'Position',[80 60 1100 760], ...
             'Name','Flight animation','NumberTitle','off');
ax  = axes('Parent',fig,'Color',[0.53 0.70 0.92]); hold(ax,'on');
axis(ax,'vis3d'); axis(ax,'off');
ax.Clipping = 'off';
ax.XLim = [xlo xhi]; ax.YLim = [ylo yhi]; ax.ZLim = [-0.2 zhi];

drawScenery(ax, xlo, xhi, ylo, yhi, zhi);

% rocket geometry (body frame, long axis = +Z, origin at mid-body)
rk = rocketGeometry();
hBody = surf(ax, rk.bx, rk.by, rk.bz, 'FaceColor',[0.85 0.10 0.12], ...
             'EdgeColor','none','FaceLighting','gouraud');
hNose = surf(ax, rk.nx, rk.ny, rk.nz, 'FaceColor',[0.95 0.95 0.97], ...
             'EdgeColor','none','FaceLighting','gouraud');
hFins = gobjects(size(rk.fins));
for i = 1:numel(rk.fins)
    hFins(i) = patch(ax,'Faces',rk.fins{i}.f,'Vertices',rk.fins{i}.v, ...
                     'FaceColor',[0.10 0.15 0.20],'EdgeColor','none');
end
hTrail = gobjects(1);
if opt.trail
    hTrail = plot3(ax,X(1),Y(1),Z(1),'-','Color',[1 1 1 0.6],'LineWidth',1.5);
end

camlight(ax,'headlight'); camlight(ax,'left'); material(ax,'dull');
ax.CameraViewAngleMode = 'manual'; camva(ax, opt.camva);
ax.CameraUpVector = [0 0 1];

hTxt = text(ax,0,0,0,'','Units','normalized','Position',[0.02 0.95 0], ...
            'Color','w','FontSize',12,'FontWeight','bold');

% ---- video writer --------------------------------------------------------
vw = [];
if ~isempty(opt.mp4)
    vw = VideoWriter(fullfile(here,opt.mp4),'MPEG-4');
    vw.FrameRate = opt.fps; vw.Quality = 95; open(vw);
end

% ---- animate -------------------------------------------------------------
for k = 1:Nf
    R = quat2R(Q(k,:));            % body -> world
    p = [X(k); Y(k); Z(k)];

    setGrid(hBody, R, p, rk.bx, rk.by, rk.bz);
    setGrid(hNose, R, p, rk.nx, rk.ny, rk.nz);
    for i = 1:numel(rk.fins)
        set(hFins(i),'Vertices',(R*rk.fins{i}.v.' + p).');
    end
    if opt.trail, set(hTrail,'XData',X(1:k),'YData',Y(1:k),'ZData',Z(1:k)); end

    % follow camera: fixed world-frame offset, always aimed at the rocket
    camtarget(ax, p.');
    campos(ax, p.' + opt.camoff);

    set(hTxt,'String',sprintf('t = %4.1f s   alt = %5.2f m   drift = %4.2f m', ...
        tf(k), Z(k), hypot(X(k)-X(1), Y(k)-Y(1))));

    drawnow;
    if ~isempty(vw), writeVideo(vw, getframe(fig)); end
    if ~ishghandle(fig), break; end   % allow the user to close the window early
end

if ~isempty(vw)
    close(vw);
    fprintf('Saved animation -> %s\n', fullfile(here,opt.mp4));
end
end

% ========================================================================= %
function so = runFlight(stop)
% Mirror of run_param.m's sim setup (gains kept in sync by hand).
addpath(genpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\ulysses-simulation-GA-Claude-Backup4'));
addpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\v1.5_simscape_0510_simplified');
configure_body(); SimulationFULLAssembly_DataFile; PID_reset;
s3 = load(fullfile(fileparts(fileparts(mfilename('fullpath'))),'GA_stage3_result.mat')); x = s3.xs3_15;   % local copy in the parent (v15_parametric) folder
mk = @(a,b,c) struct('C',struct('Kp',a,'Ki',b,'Kd',c));
sc = 0.3; kdm = 150;
T = mk(x(1)*3,   x(2)*6,   x(3)*25);
X = mk(x(4)*sc,  x(5)*sc,  x(6)*sc*kdm);
Y = mk(x(7)*sc,  x(8)*sc,  x(9)*sc*kdm);
Z = mk(x(10)*sc, x(11)*sc, x(12)*sc);
in = Simulink.SimulationInput('root_param_gimbal');
in = in.setVariable('Z',Z).setVariable('Y',Y).setVariable('X',X).setVariable('T',T) ...
       .setModelParameter('StopTime',num2str(stop));
so = sim(in);
end

% ------------------------------------------------------------------------- %
function drawScenery(ax, xlo, xhi, ylo, yhi, zhi)
% Ground grid, vertical reference poles and faint altitude planes -- all fixed
% in the world so the climbing/drifting rocket scrolls past them.

% ground plane (flat shaded quad) + grid lines
patch(ax,'XData',[xlo xhi xhi xlo],'YData',[ylo ylo yhi yhi],'ZData',[0 0 0 0], ...
      'FaceColor',[0.35 0.55 0.30],'EdgeColor','none','FaceAlpha',0.95);
gx = ceil(xlo):floor(xhi); gy = ceil(ylo):floor(yhi);
for v = gx, plot3(ax,[v v],[ylo yhi],[0 0],'-','Color',[1 1 1 0.25]); end
for v = gy, plot3(ax,[xlo xhi],[v v],[0 0],'-','Color',[1 1 1 0.25]); end

% vertical reference poles on a coarse lattice -> strong parallax + height cue
px = linspace(xlo+1, xhi-1, 4); py = linspace(ylo+1, yhi-1, 4);
for ix = 1:numel(px)
    for iy = 1:numel(py)
        plot3(ax,[px(ix) px(ix)],[py(iy) py(iy)],[0 zhi], ...
              '-','Color',[0.30 0.30 0.35 0.7],'LineWidth',1.5);
    end
end

% faint horizontal altitude planes + labels every 2 m
for z = 2:2:zhi
    plot3(ax,[xlo xhi xhi xlo xlo],[ylo ylo yhi yhi ylo],z*ones(1,5), ...
          '-','Color',[1 1 1 0.18]);
    text(ax,xlo,ylo,z,sprintf('  %d m',z),'Color',[1 1 1 0.6],'FontSize',8);
end
end

% ------------------------------------------------------------------------- %
function rk = rocketGeometry()
% Simple rocket in the body frame: long axis = +Z, origin at mid-body.
r = 0.18; Lb = 1.0; Ln = 0.5;          % body radius, body length, nose length
z0 = -Lb/2;                            % body base
n  = 24;

% body (cylinder)
[bx,by,bz] = cylinder(r, n);
bz = z0 + bz*Lb;
% nose cone (cylinder tapering to a point)
[nx,ny,nz] = cylinder([r 0], n);
nz = (z0+Lb) + nz*Ln;

% three fins at the base, 120 deg apart
fins = cell(1,3); finH = 0.45; finBz = z0; finTz = z0+0.35; finOut = 0.35;
for i = 1:3
    a = (i-1)*2*pi/3; c = cos(a); s = sin(a);
    % fin in the local x-z plane, then rotate about z by angle a
    P = [ r,        finBz;
          r+finOut, finBz;
          r,        finTz ];           % (radial, z) triangle
    v = [P(:,1)*c, P(:,1)*s, P(:,2)];  % map radial onto direction a
    fins{i} = struct('v',v,'f',[1 2 3]);
end

rk = struct('bx',bx,'by',by,'bz',bz,'nx',nx,'ny',ny,'nz',nz,'fins',{fins});
end

% ------------------------------------------------------------------------- %
function setGrid(h, R, p, x, y, z)
% Apply body->world rotation R and translation p to a surf grid, in place.
sz = size(x);
P  = R*[x(:).'; y(:).'; z(:).'] + p;
set(h,'XData',reshape(P(1,:),sz),'YData',reshape(P(2,:),sz),'ZData',reshape(P(3,:),sz));
end

% ------------------------------------------------------------------------- %
function R = quat2R(q)
% Quaternion [w x y z] (body->world) to rotation matrix.
w=q(1); x=q(2); y=q(3); z=q(4);
R = [1-2*(y^2+z^2),  2*(x*y-w*z),    2*(x*z+w*y);
     2*(x*y+w*z),    1-2*(x^2+z^2),  2*(y*z-w*x);
     2*(x*z-w*y),    2*(y*z+w*x),    1-2*(x^2+y^2)];
end

% ------------------------------------------------------------------------- %
function v = col(v), v = v(:); end
