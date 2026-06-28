function unweld_gimbal(varargin)
% UNWELD_GIMBAL  (REBUILD STEP — only ever touches root_param_gimbal)
%
% REQUIRES root_param.slx to exist. It is no longer kept day-to-day (the gimbal
% model is canonical), so this is now only a rebuild step: run _rebuild/build_model
% first (that regenerates the frozen root_param), then this. To just change the
% visual amplification, edit the cmd_upper_g / cmd_lower_g Gain blocks in
% root_param_gimbal directly instead of re-running this.
%
% Regenerates root_param_gimbal as a fresh copy of the (rebuilt) root_param, then
% UN-WELDS the two TVC gimbal joints in the V1.5 visual shell and drives them
% with the gimbal-angle commands (ang_upper_y / ang_lower_x), so the propeller
% actually articulates in Mechanics Explorer instead of being frozen.
%
% Gimbal chain in the shell:
%   FRAME_BASE --[W_Cylindrical, +90deg]--> Mid_Assembly --[W_Revolute1, -90deg]--> Propulsion(propeller)
% The other welds (Avionics_rods) stay welded.
%
% Re-runnable (always starts from a fresh copy). Parameters let me fix the
% direction/mapping without rebuilding by hand:
%   unweld_gimbal                 % defaults
%   unweld_gimbal('signU',-1)     % flip the upper gimbal's visual direction
%   unweld_gimbal('signL',-1)     % flip the lower gimbal
%   unweld_gimbal('swap',true)    % swap which command drives which joint
%   unweld_gimbal('filterTc',0.03)% more motion smoothing
%   unweld_gimbal('ampU',15,'ampL',15) % VISUAL exaggeration: show the gimbal angle
%                                      magnified Nx so the ~1deg real deflection is
%                                      visible. Purely cosmetic -- the visual gimbal
%                                      is massless decoration, so dynamics are
%                                      unchanged (real thrust vectoring uses the
%                                      true angle). Set 1 for true-scale.

opt = struct('signU',1,'signL',1,'swap',false,'filterTc',0.02,'ampU',15,'ampL',15);
for k = 1:2:numel(varargin), opt.(varargin{k}) = varargin{k+1}; end

proj = fileparts(fileparts(mfilename('fullpath')));     % parent project folder
addpath(genpath(proj));
addpath(genpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\ulysses-simulation-GA-Claude-Backup4'));
addpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\v1.5_simscape_0510_simplified');

% ---- always start from a FRESH copy of the working model ----
bdclose('all');
load_system('root_param');
save_system('root_param', fullfile(proj,'root_param_gimbal.slx'));
bdclose('root_param');
m = 'root_param_gimbal'; load_system(m);
MB = [m '/Multibody Sim']; S = [MB '/V15_Shell'];

% which command drives which gimbal
ups = 'ang_upper_y'; los = 'ang_lower_x';
if opt.swap, [ups,los] = deal(los,ups); end
% {weldName, restDeg, driveSignal, sign, visualAmp, shellInportName}
G = { 'W_Cylindrical',  90, ups, opt.signU, opt.ampU, 'cmd_upper';
      'W_Revolute1',   -90, los, opt.signL, opt.ampL, 'cmd_lower' };

x0 = 2200;
for i = 1:size(G,1)
    weld = G{i,1}; restDeg = G{i,2}; sgn = G{i,4}; amp = G{i,5}; cmd = G{i,6};
    y = 100 + 220*i;
    % --- capture the two frames the weld connected, then delete it ---
    b = [S '/' weld]; ph = get_param(b,'PortHandles');
    baseEnd = otherEnd(ph.LConn(1));      % FRAME_BASE / Mid side
    follEnd = otherEnd(ph.RConn(1));      % Mid / Propulsion side
    delBlk(b);
    % --- driven Revolute in its place (rotation about +Z) ---
    J = [S '/' strrep(weld,'W_','J_')];
    add_block('sm_lib/Joints/Revolute Joint', J, 'Position',[x0 y x0+40 y+60]);
    set_param(J,'MotionActuationMode','InputMotion','TorqueActuationMode','ComputedTorque');
    jph = get_param(J,'PortHandles');     % LConn1=base, LConn2=motion, RConn1=follower
    add_line(S, baseEnd, jph.LConn(1), 'autorouting','on');
    add_line(S, jph.RConn(1), follEnd, 'autorouting','on');
    % --- drive chain: Inport(deg) -> *sign*pi/180 -> + rest_rad -> PS(filter) -> joint motion ---
    ip = [S '/' cmd];        add_block('simulink/Sources/In1', ip, 'Position',[x0-420 y x0-390 y+14]);
    gn = [S '/' cmd '_g'];   add_block('simulink/Math Operations/Gain', gn, 'Gain',num2str(sgn*amp*pi/180,'%.10g'),'Position',[x0-340 y x0-310 y+14]);
    cc = [S '/' cmd '_rest']; add_block('simulink/Sources/Constant', cc, 'Value',num2str(restDeg*pi/180,'%.10g'),'Position',[x0-340 y+40 x0-310 y+54]);
    su = [S '/' cmd '_sum'];  add_block('simulink/Math Operations/Add', su, 'Inputs','++','Position',[x0-260 y+10 x0-240 y+44]);
    ps = [S '/' cmd '_ps'];   add_block('nesl_utility/Simulink-PS Converter', ps, 'Position',[x0-190 y+12 x0-160 y+42]);
    set_param(ps,'Unit','rad','FilteringAndDerivatives','filter','SimscapeFilterOrder','2','InputFilterTimeConstant',num2str(opt.filterTc));
    add_line(S, pout(ip), pin(gn),  'autorouting','on');
    add_line(S, pout(gn), pin(su,1),'autorouting','on');
    add_line(S, pout(cc), pin(su,2),'autorouting','on');
    add_line(S, pout(su), pin(ps),  'autorouting','on');
    add_line(S, get_param(ps,'PortHandles').RConn(1), jph.LConn(2), 'autorouting','on');
end

% ---- route ang_upper_y / ang_lower_x from Multibody Sim into the shell's new inports ----
shellPH = get_param(S,'PortHandles');     % Inport(1)=cmd_upper, Inport(2)=cmd_lower (creation order)
add_line(MB, pout([MB '/' ups]), shellPH.Inport(1), 'autorouting','on');
add_line(MB, pout([MB '/' los]), shellPH.Inport(2), 'autorouting','on');

% ---- restore the hand-tuned block/wire layout (no-op if none captured) ----
% The steps above build everything with autorouting at scripted positions; this
% re-applies the manual layout snapshot so a rebuild looks like the tuned model.
% Re-run _tools/capture_layout after rearranging blocks to refresh the snapshot.
apply_layout(m);

save_system(m);
fprintf(['DONE (experimental): %s built.\n' ...
         '  un-welded W_Cylindrical (<-%s, visual x%g) and W_Revolute1 (<-%s, visual x%g).\n' ...
         '  Propeller now articulates (angle shown magnified for visibility). root_param untouched.\n'], ...
         m, ups, opt.ampU, los, opt.ampL);
end

% ----------------------------------------------------------------------------
function h = otherEnd(porth)
% the frame port on the OTHER block across the connection line
l = get_param(porth,'Line'); h = [];
if l == -1, return; end
sp = get_param(l,'SrcPortHandle'); dp = get_param(l,'DstPortHandle');
ee = [sp(:); dp(:)]'; ee = ee(ee~=-1); me = get_param(porth,'Parent');
for e = ee, if ~strcmp(get_param(e,'Parent'), me), h = e; return; end, end
end
function p = pout(blk), p = get_param(blk,'PortHandles').Outport(1); end
function p = pin(blk,i), if nargin<2, i=1; end, ph=get_param(blk,'PortHandles'); p=ph.Inport(i); end
function delBlk(b)
try
    ph = get_param(b,'PortHandles'); fn = fieldnames(ph); lh = [];
    for f=1:numel(fn), for hh=ph.(fn{f})(:)', l=get_param(hh,'Line'); if l~=-1, lh(end+1)=l; end, end, end %#ok<AGROW>
    for l=unique(lh), try delete_line(l); catch, end, end
    delete_block(b);
catch
end
end
