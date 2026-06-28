function build_model()
% BUILD_MODEL  One-shot build of the parametric V1.5 controller test-bed.
%   Step 1: clean parametric plant (lumped, adjustable dynamics)  -> plant_param.slx
%   Step 2: graft the full V1.5 geometry as a rigid massless visual shell
%   Step 3: drop the plant under the original controller          -> root_param.slx
%
% Run this ONCE to (re)generate the models. Day to day you only need
% configure_body.m (set the dynamics) and run_param.m / body_dashboard.m.
%
% NOTE: close root_param in Simulink/Mechanics Explorer before running, or
% step 3 cannot overwrite root_param.slx.

here = fileparts(mfilename('fullpath')); cd(here);
ULY = 'C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\ulysses-simulation-GA-Claude-Backup4';
V15 = 'C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\v1.5_simscape_0510_simplified';
addpath(ULY); addpath(V15);

fprintf('[1/3] building clean parametric plant ...\n'); buildPlant(here);
fprintf('[2/3] grafting full V1.5 visual shell ...\n');  graftShell();
fprintf('[3/3] integrating controller -> root_param ...\n'); integrateController(here, ULY);
fprintf('DONE.  Run:  configure_body;  run_param        (or:  body_dashboard)\n');
end

% ===================================================================== step 1
function buildPlant(here)
m='plant_param'; bdclose('all');
if exist([m '.slx'],'file'), try, delete([m '.slx']); catch, end, end
new_system(m);
add_block('sm_lib/Frames and Transforms/World Frame',[m '/World'],'Position',[-300 0 -260 40]);
add_block('nesl_utility/Solver Configuration',[m '/Solver'],'Position',[-300 80 -260 110]);
add_block('sm_lib/Utilities/Mechanism Configuration',[m '/Mech'],'Position',[-300 -80 -260 -50]);
set_param([m '/Mech'],'GravityVector','[0 0 -9.80665]');
add_block('sm_lib/Joints/6-DOF Joint',[m '/SixDOF'],'Position',[-150 0 -110 60]);
add_block('sm_lib/Body Elements/Inertia',[m '/Body'],'Position',[0 -20 60 40]);
set_param([m '/Body'],'InertiaType','Custom','Mass','M','MomentsOfInertia','[Ixx Iyy Izz]', ...
    'ProductsOfInertia','[0 0 0]','CenterOfMass','[cx cy cz]');
add_block('sm_lib/Forces and Torques/External Force and Torque',[m '/ExtFT'],'Position',[200 -40 260 60]);
set_param([m '/ExtFT'],'EnableForceX','on','EnableForceY','on','EnableForceZ','on', ...
    'EnableTorqueX','on','EnableTorqueY','on','EnableTorqueZ','on', ...
    'ForceResolutionFrame','AttachedFrame','TorqueResolutionFrame','AttachedFrame');
add_block('sm_lib/Frames and Transforms/Transform Sensor',[m '/TS_q'],  'Position',[-150 200 -110 260]);
add_block('sm_lib/Frames and Transforms/Transform Sensor',[m '/TS_pos'],'Position',[-150 300 -110 360]);
add_block('sm_lib/Frames and Transforms/Transform Sensor',[m '/TS_w'],  'Position',[-150 400 -110 460]);
son([m '/TS_q'],'SenseQ'); son([m '/TS_pos'],'SenseXYZ'); son([m '/TS_w'],'SenseOmega');
add_block('simulink/Signal Routing/Mux',[m '/uvec'],'Inputs','3','Position',[-260 250 -255 320]);
add_block('simulink/User-Defined Functions/Fcn',[m '/Fx'],'Expr','u(3)*sin(u(1)*pi/180)*cos(u(2)*pi/180)','Position',[-200 250 -150 270]);
add_block('simulink/User-Defined Functions/Fcn',[m '/Fy'],'Expr','-u(3)*sin(u(2)*pi/180)','Position',[-200 290 -150 310]);
add_block('simulink/User-Defined Functions/Fcn',[m '/Fz'],'Expr','u(3)*cos(u(1)*pi/180)*cos(u(2)*pi/180)','Position',[-200 330 -150 350]);
add_block('simulink/Math Operations/Gain',[m '/Gtx'],'Gain','Larm','Position',[-120 290 -90 310]);
add_block('simulink/Math Operations/Gain',[m '/Gty'],'Gain','-Larm','Position',[-120 250 -90 270]);
for c={'psFx','psFy','psFz','psTx','psTy','psTz'}, add_block('nesl_utility/Simulink-PS Converter',[m '/' c{1}]); end
for c={'y_q','y_pos','y_w'}, add_block('nesl_utility/PS-Simulink Converter',[m '/' c{1}]); end
add_block('simulink/Sources/Constant',[m '/MASS_c'],'Value','M','Position',[-150 520 -110 550]);
add_block('simulink/Sources/Constant',[m '/INERTIA_c'],'Value','[Ixx 0 0;0 Iyy 0;0 0 Izz]','Position',[-150 560 -110 600]);
add_block('simulink/Sources/Constant',[m '/LGIM_c'],'Value','Larm','Position',[-150 620 -110 650]);
addin([m '/ang_upper_y'],1); addin([m '/ang_lower_x'],2); addin([m '/thrust'],3); addin([m '/torque_thrust'],4);
addout([m '/q'],1); addout([m '/angular_vel'],2); addout([m '/pos'],3); addout([m '/MASS'],4); addout([m '/INERTIA_MATRIX'],5); addout([m '/L_GIM'],6);
add_line(m,'ang_upper_y/1','uvec/1','autorouting','on');
add_line(m,'ang_lower_x/1','uvec/2','autorouting','on');
add_line(m,'thrust/1','uvec/3','autorouting','on');
add_line(m,'uvec/1','Fx/1','autorouting','on'); add_line(m,'uvec/1','Fy/1','autorouting','on'); add_line(m,'uvec/1','Fz/1','autorouting','on');
add_line(m,'Fx/1','psFx/1','autorouting','on'); add_line(m,'Fy/1','psFy/1','autorouting','on'); add_line(m,'Fz/1','psFz/1','autorouting','on');
add_line(m,'Fy/1','Gtx/1','autorouting','on'); add_line(m,'Gtx/1','psTx/1','autorouting','on');
add_line(m,'Fx/1','Gty/1','autorouting','on'); add_line(m,'Gty/1','psTy/1','autorouting','on');
add_line(m,'torque_thrust/1','psTz/1','autorouting','on');
add_line(m,'y_q/1','q/1','autorouting','on'); add_line(m,'y_pos/1','pos/1','autorouting','on'); add_line(m,'y_w/1','angular_vel/1','autorouting','on');
add_line(m,'MASS_c/1','MASS/1','autorouting','on'); add_line(m,'INERTIA_c/1','INERTIA_MATRIX/1','autorouting','on'); add_line(m,'LGIM_c/1','L_GIM/1','autorouting','on');
Wr=fp([m '/World'],'RConn',1);
conn(Wr, jp([m '/SixDOF'],'LConn1')); conn(Wr, jp([m '/Solver'],'RConn1')); conn(Wr, jp([m '/Mech'],'RConn1'));
bodyNode=jp([m '/SixDOF'],'RConn1');
conn(bodyNode, fp([m '/Body'],'RConn',1)); conn(bodyNode, jp([m '/ExtFT'],'RConn1'));
conn(Wr, fp([m '/TS_q'],'LConn',1));   conn(fp([m '/TS_q'],'RConn',1), bodyNode);   conn(fp([m '/TS_q'],'RConn',2), fp([m '/y_q'],'LConn',1));
conn(Wr, fp([m '/TS_pos'],'LConn',1)); conn(fp([m '/TS_pos'],'RConn',1), bodyNode); conn(fp([m '/TS_pos'],'RConn',2), fp([m '/y_pos'],'LConn',1));
conn(Wr, fp([m '/TS_w'],'LConn',1));   conn(fp([m '/TS_w'],'RConn',1), bodyNode);   conn(fp([m '/TS_w'],'RConn',2), fp([m '/y_w'],'LConn',1));
phE=get_param([m '/ExtFT'],'PortHandles');
conn(fp([m '/psFx'],'RConn',1), phE.LConn(1)); conn(fp([m '/psFy'],'RConn',1), phE.LConn(2));
conn(fp([m '/psFz'],'RConn',1), phE.LConn(3)); conn(fp([m '/psTx'],'RConn',1), phE.LConn(4));
conn(fp([m '/psTy'],'RConn',1), phE.LConn(5)); conn(fp([m '/psTz'],'RConn',1), phE.LConn(6));
save_system(m,[here '/' m '.slx']);
end

% ===================================================================== step 2
function graftShell()
m='plant_param'; src='V1_5GimbalAssembly'; bdclose('all');
load_system(src);
mws=get_param(src,'ModelWorkspace'); mws.DataSource='MATLAB File'; mws.FileName='V1_5GimbalAssembly_DataFile.m'; mws.reload();
load_system(m);
mwm=get_param(m,'ModelWorkspace'); mwm.DataSource='MATLAB File'; mwm.FileName='V1_5GimbalAssembly_DataFile.m'; mwm.reload();
ctrl=get_param([m '/SixDOF'],'PortHandles').RConn(1);
% lumped dynamics block (the only thing the controller sees)
delBlk([m '/Body']);
add_block('sm_lib/Body Elements/Inertia',[m '/BodyDyn'],'Position',[0 -30 70 40]);
set_param([m '/BodyDyn'],'InertiaType','Custom','Mass','M', ...
    'MomentsOfInertia','[Ixx Iyy Izz]','ProductsOfInertia','[0 0 0]','CenterOfMass','[cx cy cz]');
conn(get_param([m '/BodyDyn'],'PortHandles').RConn(1), ctrl);
% bring whole V1.5 mechanism into a subsystem, turn it into a rigid massless shell
add_block('built-in/Subsystem',[m '/V15_Shell'],'Position',[180 120 320 220]);
inner=find_system([m '/V15_Shell'],'SearchDepth',1,'LookUnderMasks','all','Type','Block');
for i=1:numel(inner), if ~strcmp(inner{i},[m '/V15_Shell']), try delete_block(inner{i}); catch, end, end, end
Simulink.BlockDiagram.copyContentsToSubsystem(src,[m '/V15_Shell']);
S=[m '/V15_Shell'];
for b={'World','Solver Configuration','MechanismConfiguration','Transform','Parallel','Revolute'}
    delBlk([S '/' b{1}]);
end
% Weld each gimbal/rod joint at its CAD ASSEMBLED rest angle (NOT identity).
% The SolidWorks import stores those angles in smiData; welding at 0 deg
% (the old behaviour) rotated the cage 90 deg, the propeller -90 deg and the
% rods ~170 deg away from their true rest pose, which broke the gear mesh and
% the propeller orientation. Read the real angles and bake them into the welds.
run('V1_5GimbalAssembly_DataFile.m');   %#ok<*NASGU>  defines smiData locally
weldJoint([S '/Cylindrical'], smiData.CylindricalJoint(1).Rz.Pos, smiData.CylindricalJoint(1).Pz.Pos);
for j={'Revolute1','Revolute2','Revolute3','Revolute11','Revolute12'}
    jb=[S '/' j{1}];
    ang=eval(get_param(jb,'PositionTargetValue'));  % e.g. 'smiData.RevoluteJoint(2).Rz.Pos'
    weldJoint(jb, ang, 0);
end
sol=find_system(S,'LookUnderMasks','all','FollowLinks','on','BlockType','SimscapeMultibodyBlock');
for i=1:numel(sol)
    if any(strcmpi(get_param(sol{i},'ClassName'),{'Solid','FileSolid','BrickSolid'}))
        set_param(sol{i},'InertiaType','Custom','Mass','1e-9', ...
            'MomentsOfInertia','[1e-12 1e-12 1e-12]','ProductsOfInertia','[0 0 0]','CenterOfMass','[0 0 0]');
    end
end
fb=framePortHandle([S '/x1_5_FRAME_BASE_1_RIGID'],'F17');
add_block('nesl_utility/Connection Port',[S '/ShellMount'],'Position',[-60 0 -40 20]);
cp=get_param([S '/ShellMount'],'PortHandles'); cph=[cp.LConn cp.RConn];
add_line(S, cph(1), fb,'autorouting','on');
add_block('sm_lib/Frames and Transforms/Rigid Transform',[m '/T_shell'], ...
    'RotationMethod','StandardAxis','RotationStandardAxis','+X','RotationAngle','-90','Position',[120 120 160 160]);
conn(get_param([m '/T_shell'],'PortHandles').LConn(1), ctrl);
sp=get_param(S,'PortHandles'); spc=[sp.LConn sp.RConn];
conn(get_param([m '/T_shell'],'PortHandles').RConn(1), spc(1));
save_system(m);
end

% ===================================================================== step 3
function integrateController(here, ULY)
% NOTE: build_model.m lives in the _rebuild/ subfolder, but root_param.slx must
% stay in the parent project folder (proj) where run_param/body_dashboard expect it.
proj=fileparts(here);
sys='root_param'; bdclose('all');
try
    copyfile(fullfile(ULY,'root.slx'), fullfile(proj,[sys '.slx']),'f');
catch
    error('build_model:locked', ...
      'Cannot write root_param.slx -- close it in Simulink/Mechanics Explorer and re-run build_model.');
end
load('mb_wiring.mat','INFO');
for i=1:numel(INFO.in),  INFO.in{i}.block  = remap(INFO.in{i}.block, sys);  end
for i=1:numel(INFO.out)
    for k=1:numel(INFO.out{i}), INFO.out{i}{k}.block = remap(INFO.out{i}{k}.block, sys); end
end
bdclose('all'); load_system('plant_param'); load_system(fullfile(proj,[sys '.slx']));
rws=get_param(sys,'ModelWorkspace'); rws.DataSource='MATLAB File'; rws.FileName='V1_5GimbalAssembly_DataFile.m'; rws.reload();
mb=[sys '/Multibody Sim']; pos=get_param(mb,'Position');
delete_block(mb); add_block('built-in/Subsystem',mb,'Position',pos);
inner=find_system(mb,'SearchDepth',1,'LookUnderMasks','all','Type','Block');
for i=1:numel(inner), if ~strcmp(inner{i},mb), try delete_block(inner{i}); catch, end, end, end
Simulink.BlockDiagram.copyContentsToSubsystem('plant_param', mb);
mbPH=get_param(mb,'PortHandles');
for i=1:numel(INFO.in)
    s=INFO.in{i}; sPH=get_param(s.block,'PortHandles');
    clearLine(mbPH.Inport(i)); add_line(sys, sPH.Outport(s.port), mbPH.Inport(i),'autorouting','on');
end
for i=1:numel(INFO.out)
    for k=1:numel(INFO.out{i})
        d=INFO.out{i}{k}; dPH=get_param(d.block,'PortHandles');
        clearLine(dPH.Inport(d.port)); add_line(sys, mbPH.Outport(i), dPH.Inport(d.port),'autorouting','on');
    end
end
save_system(sys);
end

% ========================================================================= helpers
function son(b,w), for p={'SenseQ','SenseXYZ','SenseOmega','SenseZ','SenseX','SenseY'}, try set_param(b,p{1},'off'); catch, end, end; set_param(b,w,'on'); end
function addin(b,n),  add_block('simulink/Sources/In1',b,'Port',num2str(n)); end
function addout(b,n), add_block('simulink/Sinks/Out1',b,'Port',num2str(n)); end
function h=fp(b,s,i), ph=get_param(b,'PortHandles'); h=ph.(s)(i); end
function h=jp(b,t),   ph=get_param(b,'PortHandles'); h=ph.(t(1:5))(str2double(t(6:end))); end
function conn(a,b),   add_line(bdroot(get_param(a,'Parent')),a,b,'autorouting','on'); end
function weldJoint(j, angDeg, transZ)
    % Replace a joint with a Rigid Transform frozen at the joint's rest pose:
    % rotation angDeg [deg] about +Z and translation transZ along +Z (the
    % joint's own motion axis). angDeg/transZ default to 0 (plain weld).
    if nargin<2, angDeg=0; end
    if nargin<3, transZ=0; end
    if isempty(find_system(bdroot(strtok(j,'/')),'LookUnderMasks','all','Name',localname(j))), return; end
    ph=get_param(j,'PortHandles'); bh=endFrame(ph.LConn(1)); fh=endFrame(ph.RConn(1)); sys=get_param(j,'Parent');
    delBlk(j); if isempty(bh)||isempty(fh), return; end
    rt=[sys '/W_' localname(j)]; add_block('sm_lib/Frames and Transforms/Rigid Transform',rt,'Position',[0 0 30 30]);
    set_param(rt,'RotationMethod','StandardAxis','RotationStandardAxis','+Z','RotationAngle',num2str(angDeg,'%.6f'));
    if abs(transZ)>0
        set_param(rt,'TranslationMethod','Cartesian','TranslationCartesianOffset',['[0 0 ' num2str(transZ,'%.6f') ']']);
    end
    rp=get_param(rt,'PortHandles'); add_line(sys, bh, rp.LConn(1),'autorouting','on'); add_line(sys, rp.RConn(1), fh,'autorouting','on');
end
function h=endFrame(porth)
    l=get_param(porth,'Line'); h=[]; if l==-1, return; end
    sp=get_param(l,'SrcPortHandle'); dp=get_param(l,'DstPortHandle'); ee=[sp(:);dp(:)]'; ee=ee(ee~=-1); me=get_param(porth,'Parent');
    for e=ee, if ~strcmp(get_param(e,'Parent'),me), h=e; return; end, end
end
function h=framePortHandle(body,frame)
    pmi=find_system(body,'SearchDepth',1,'LookUnderMasks','all','BlockType','PMIOPort','Name',frame);
    k=str2double(get_param(pmi{1},'Port')); pc=get_param(body,'PortConnectivity'); ty=pc(k).Type;
    ph=get_param(body,'PortHandles'); h=ph.(ty(1:5))(str2double(ty(6:end)));
end
function delBlk(b)
    if isempty(find_system(bdroot(strtok(b,'/')),'LookUnderMasks','all','Name',localname(b))), return; end
    try
        ph=get_param(b,'PortHandles'); fn=fieldnames(ph); lh=[];
        for f=1:numel(fn), for h=ph.(fn{f})(:)', l=get_param(h,'Line'); if l~=-1, lh(end+1)=l; end, end, end
        for l=unique(lh), try delete_line(l); catch, end, end
        delete_block(b);
    catch
    end
end
function n=localname(b), p=strsplit(b,'/'); n=p{end}; end
function clearLine(porth), l=get_param(porth,'Line'); if ~isempty(l)&&l~=-1, delete_line(l); end, end
function p=remap(p,sys), k=strfind(p,'/'); p=[sys p(k(1):end)]; end
