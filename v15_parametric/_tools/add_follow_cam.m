function add_follow_cam(varargin)
% ADD_FOLLOW_CAM  Build a decoupled "camera drone" that follows the rocket so a
% Mechanics Explorer camera can keep the rocket at CONSTANT SIZE, without
% touching the (marginally-stable) rocket dynamics.
%
% Why this is dynamics-safe (unlike a body bolted to the rocket):
%   The drone is a small body hung off WORLD through a Cartesian joint (3
%   translational DOF, no rotation -> it stays level). The joint motion is
%   PRESCRIBED to the rocket's sensed world position (the `pos` signal). That is
%   a ONE-WAY feed: the drone reads where the rocket is and goes there; it never
%   pushes back on the rocket. So it adds zero load to the plant -- the flight is
%   unchanged. A Rigid Transform offsets the camera frame from the drone.
%
% Run AFTER add_scenery (which adds SCN_CAM_MARKER, the aim target). Then in
% Mechanics Explorer -> Camera Manager:
%   Mode = Tracking,  Position = SCN_CamDrone frame,  Aim = SCN_CAM_MARKER.
% Result: a constant-distance chase cam with a level horizon.
%
%   add_follow_cam                        % default camera offset
%   add_follow_cam('eyeOff',[-2 -2.5 1.2]) % pull the camera back (smaller rocket)
%   add_follow_cam('eyeOff',[-0.8 -1 0.5]) % move in (bigger rocket)
%   add_follow_cam('filterTc',0.03)       % more motion smoothing (more lag)
%
% Idempotent: re-running removes the rig it previously added before rebuilding.

addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));  % this file is in _tools/; put the parent project folder on the path
m = 'root_param_gimbal'; S = [m '/Multibody Sim'];
if isempty(find_system('SearchDepth',0,'MatchFilter',@Simulink.match.allVariants,'Name',m)), load_system(m); end

opt = struct('eyeOff',[-1.2 -1.5 0.8],'filterTc',0.02);
for k = 1:2:numel(varargin), opt.(varargin{k}) = varargin{k+1}; end

% ---- remove a previous rig (idempotent) ----
old = find_system(S,'LookUnderMasks','all','Regexp','on','Name','^SCN_Cam(World|Solver|Mech|Joint|Offset|Drone|Demux|Pos[XYZ])$');
for i = 1:numel(old), delBlkF(old{i}); end

yp = get_param([S '/y_pos'],'PortHandles').Outport(1);        % rocket world position (Simulink 3-vec)

x0 = 2000;
% ---- the drone lives in its OWN Simscape network (own World + Solver +
%      Mechanism cfg) so the one-way position feed does not form an algebraic
%      loop with the rocket's solver ----
CW = [S '/SCN_CamWorld'];  add_block('sm_lib/Frames and Transforms/World Frame', CW, 'Position',[x0-70 50 x0-30 90]);
CS = [S '/SCN_CamSolver']; add_block('nesl_utility/Solver Configuration', CS, 'Position',[x0-70 200 x0-30 230]);
CM = [S '/SCN_CamMech'];   add_block('sm_lib/Utilities/Mechanism Configuration', CM, 'Position',[x0-70 130 x0-30 160]);
cwf = get_param(CW,'PortHandles').RConn(1);
add_line(S, cwf, get_param(CS,'PortHandles').RConn(1), 'autorouting','on');
add_line(S, cwf, get_param(CM,'PortHandles').RConn(1), 'autorouting','on');

% ---- Cartesian joint CamWorld -> drone, translation prescribed by input ----
J = [S '/SCN_CamJoint'];
add_block('sm_lib/Joints/Cartesian Joint', J, 'Position',[x0 100 x0+40 170]);
set_param(J,'PxMotionActuationMode','InputMotion', ...
            'PyMotionActuationMode','InputMotion', ...
            'PzMotionActuationMode','InputMotion', ...
            'PxTorqueActuationMode','ComputedTorque', ...   % joint solves the force to follow the motion
            'PyTorqueActuationMode','ComputedTorque', ...
            'PzTorqueActuationMode','ComputedTorque');
jph = get_param(J,'PortHandles');   % LConn1=base, LConn2/3/4=Px/Py/Pz motion, RConn1=follower
add_line(S, cwf, jph.LConn(1), 'autorouting','on');

% ---- camera-frame offset from the drone, then the drone body ----
OT = [S '/SCN_CamOffset'];
add_block('sm_lib/Frames and Transforms/Rigid Transform', OT, 'Position',[x0+90 100 x0+120 130]);
set_param(OT,'TranslationMethod','Cartesian','TranslationCartesianOffset',sprintf('[%g %g %g]',opt.eyeOff));
oph = get_param(OT,'PortHandles');
add_line(S, jph.RConn(1), oph.LConn(1), 'autorouting','on');

D = [S '/SCN_CamDrone'];
add_block('sm_lib/Body Elements/Brick Solid', D, 'Position',[x0+170 100 x0+230 140]);
set_param(D,'BrickDimensions','[0.08 0.08 0.08]','GraphicDiffuseColor','[0.1 0.1 0.1]','GraphicOpacity','0');
dph = get_param(D,'PortHandles'); dframe = [dph.RConn dph.LConn];
add_line(S, oph.RConn(1), dframe(1), 'autorouting','on');

% ---- rocket position -> demux -> 2nd-order PS converters -> joint motion ----
DM = [S '/SCN_CamDemux'];
add_block('simulink/Signal Routing/Demux', DM, 'Outputs','3','Position',[x0-220 200 x0-215 280]);
add_line(S, yp, get_param(DM,'PortHandles').Inport(1), 'autorouting','on');   % branch the pos line
ax = {'X','Y','Z'};
for i = 1:3
    C = [S '/SCN_CamPos' ax{i}];
    add_block('nesl_utility/Simulink-PS Converter', C, 'Position',[x0-140 180+24*i x0-105 200+24*i]);
    set_param(C,'Unit','m','FilteringAndDerivatives','filter','SimscapeFilterOrder','2', ...
                'InputFilterTimeConstant',num2str(opt.filterTc));   % m input; filter -> derivatives computed internally
    cph = get_param(C,'PortHandles');
    add_line(S, get_param(DM,'PortHandles').Outport(i), cph.Inport(1), 'autorouting','on');
    add_line(S, cph.RConn(1), jph.LConn(1+i), 'autorouting','on');   % Px/Py/Pz motion inputs
end

try
    save_system(m);
    fprintf(['Follow-cam drone added (offset [%g %g %g], filter %.3gs).\n' ...
             'Mechanics Explorer -> Camera Manager -> Tracking:\n' ...
             '  Position = SCN_CamDrone ,  Aim = SCN_CAM_MARKER\n'], opt.eyeOff, opt.filterTc);
catch e
    warning('Could not save (close Mechanics Explorer and re-run). %s', e.message);
end
end

% ------------------------------------------------------------------------- %
function delBlkF(b)
try
    ph = get_param(b,'PortHandles'); fn = fieldnames(ph); lh = [];
    for f = 1:numel(fn)
        for h = ph.(fn{f})(:)'
            l = get_param(h,'Line'); if l ~= -1, lh(end+1) = l; end %#ok<AGROW>
        end
    end
    for l = unique(lh), try delete_line(l); catch, end, end
    delete_block(b);
catch
end
end
