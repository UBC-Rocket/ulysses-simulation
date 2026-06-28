function add_scenery(varargin)
% ADD_SCENERY  Add world-fixed reference scenery + a camera-anchor marker to the
% root_param Mechanics Explorer view, IN PLACE and additively.
%
% This does NOT run build_model and does NOT touch the existing block layout or
% the T_shell rotation -- it only ADDS blocks (all prefixed "SCN_") and a frame
% marker on the rocket, then saves. Running it again first removes the scenery
% it previously added, so it is safe/idempotent to re-run with new options.
%
% What it adds:
%   * a large GROUND plane
%   * a wide LATTICE of tall vertical poles  -> horizontal + vertical reference
%     spread over a big area, so sideways drift cannot leave the reference field
%   * a few translucent ALTITUDE planes at known heights -> altitude scale
%   * CAM_MARKER: a small marker at the rocket origin, as a camera AIM target.
%
% IMPORTANT (dynamics safety):
%   The world scenery is rigidly welded to World (zero DOF) -> it has NO effect
%   on the flight. The body marker is placed exactly at the rocket origin: an
%   OFFSET near-massless body on this tiny-inertia plant (Iyy~1.5e-3) is
%   numerically singular and destabilises the marginally-stable flight, so we do
%   NOT attach any offset "chase eye" body. For a true follow-camera, use the
%   decoupled replay animate_flight.m instead (it cannot affect the dynamics).
%
% Usage:
%   add_scenery                                  % defaults
%   add_scenery('latSpan',48,'groundW',80)       % widen if the rocket drifts far
%   add_scenery('latN',7,'poleH',30)             % denser / taller poles
%
% After running:
%   1) Re-simulate: run_param   (or press Run in Mechanics Explorer).
%   2) Camera Manager -> Tracking camera with Position = a fixed vantage (e.g. a
%      pole-top frame SCN_POLE01_R, or World) and Aim = SCN_CAM_MARKER. The
%      camera then keeps the rocket centred as it flies. (A fixed vantage is the
%      only body-safe option in Mechanics Explorer; for a constant-distance chase
%      cam use animate_flight.m.)

addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));  % this file is in _tools/; put the parent project folder on the path
m = 'root_param_gimbal'; S = [m '/Multibody Sim'];
if isempty(find_system('SearchDepth',0,'MatchFilter',@Simulink.match.allVariants,'Name',m))
    load_system(m);
end

% ---- tunable scenery extents ----
opt = struct('groundW',100,'latN',7,'latSpan',70,'poleH',25,'poleR',0.15, ...
             'diskR',45,'diskZ',[5 10 15 20],'groundTop',-2,'clearR',1.5);
for k = 1:2:numel(varargin), opt.(varargin{k}) = varargin{k+1}; end

% ---- remove any scenery a previous run added (idempotent) ----
old = find_system(S,'LookUnderMasks','all','Regexp','on','Name','^SCN_');
for i = 1:numel(old), delBlk(old{i}); end

% ---- frame anchors ----
W  = [S '/World'];  Wr = get_param(W,'PortHandles').RConn(1);   % World frame
bodyNode = get_param([S '/SixDOF'],'PortHandles').RConn(1);     % rocket body frame

x0 = 1500; y = 40; dy = 70;   % cosmetic canvas placement for the new blocks

% ---- ground plane (top surface at z = groundTop, lowered so it never buries
%      the rocket at launch) ----
y = addPiece(S, Wr, 'GROUND', 'sm_lib/Body Elements/Brick Solid', ...
    struct('BrickDimensions',sprintf('[%g %g 0.4]',opt.groundW,opt.groundW)), ...
    [0.33 0.52 0.30], 1, [0 0 opt.groundTop-0.2], false, x0, y, dy);

% ---- wide lattice of tall vertical poles (planted on the lowered ground) ----
% Poles within clearR of the launch axis are skipped so the central pole does
% not sit on top of the rocket.
g = linspace(-opt.latSpan/2, opt.latSpan/2, opt.latN);
poleZc = opt.groundTop + opt.poleH/2;
n = 0; nPoles = 0;
for ix = 1:numel(g)
    for iy = 1:numel(g)
        n = n + 1;
        if hypot(g(ix),g(iy)) < opt.clearR, continue; end   % keep the launch point clear
        nPoles = nPoles + 1;
        y = addPiece(S, Wr, sprintf('POLE%02d',n), 'sm_lib/Body Elements/Cylindrical Solid', ...
            struct('CylinderRadius',num2str(opt.poleR),'CylinderLength',num2str(opt.poleH)), ...
            [0.85 0.85 0.88], 1, [g(ix) g(iy) poleZc], false, x0, y, dy);
    end
end

% ---- translucent altitude planes (thin wide disks) ----
for i = 1:numel(opt.diskZ)
    y = addPiece(S, Wr, sprintf('ALT%02d',i), 'sm_lib/Body Elements/Cylindrical Solid', ...
        struct('CylinderRadius',num2str(opt.diskR),'CylinderLength','0.05'), ...
        [0.80 0.86 0.95], 0.10, [0 0 opt.diskZ(i)], false, x0, y, dy);
end

% ---- camera AIM marker on the rocket body ----
% A small marker at the rocket ORIGIN (r=0) -> camera aim target / CoM marker.
% Must stay at the origin and massless: an offset body here destabilises the
% plant (see header). Do NOT add an offset chase-eye body.
addPiece(S, bodyNode, 'CAM_MARKER', 'sm_lib/Body Elements/Brick Solid', ...
    struct('BrickDimensions','[0.12 0.12 0.12]'), [1 0.9 0.1], 0.5, [0 0 0], true, x0, y, dy);

% ---- save ----
try
    save_system(m);
    fprintf(['Scenery added: ground (top z=%g) + %d poles + %d altitude planes + CAM_MARKER\n' ...
             '(aim target at the rocket origin). World scenery does not affect the flight.\n' ...
             'Next: run_param to re-simulate, then in Mechanics Explorer set a Tracking camera\n' ...
             'with Position = a fixed vantage (e.g. SCN_POLE01_R) and Aim = SCN_CAM_MARKER.\n'], ...
             opt.groundTop, nPoles, numel(opt.diskZ));
catch e
    warning(['Could not save root_param (Mechanics Explorer may be locking the file). ' ...
             'Close the Mechanics Explorer window and re-run add_scenery.\n%s'], e.message);
end
end

% ========================================================================= %
function y = addPiece(S, anchor, name, lib, params, rgb, opac, xyz, massless, x0, y, dy)
% Add one world-/body-fixed solid: a Rigid Transform (placement) + a Solid,
% connect anchorFrame -> transform.base and transform.follower -> solid.frame.
% massless=true  -> near-zero custom inertia (ONLY for the body-mounted camera
%                   markers, which must not change the rocket's mass).
% massless=false -> default CalculateFromGeometry mass. Used for the world-fixed
%                   scenery: it is rigidly welded to World (zero DOF) so its mass
%                   never enters the dynamics, but real mass keeps the Simscape
%                   solver well-conditioned (near-zero masses on many solids were
%                   perturbing the marginally-stable flight).
t  = [S '/SCN_T_' name];
add_block('sm_lib/Frames and Transforms/Rigid Transform', t, 'Position',[x0 y x0+30 y+30]);
set_param(t,'TranslationMethod','Cartesian','TranslationCartesianOffset',sprintf('[%g %g %g]',xyz));

sb = [S '/SCN_' name];
add_block(lib, sb, 'Position',[x0+130 y x0+190 y+40]);
f = fieldnames(params); for i = 1:numel(f), set_param(sb, f{i}, params.(f{i})); end
if massless
    set_param(sb,'InertiaType','Custom','Mass','1e-9', ...
        'MomentsOfInertia','[1e-12 1e-12 1e-12]','ProductsOfInertia','[0 0 0]','CenterOfMass','[0 0 0]');
end
set_param(sb,'GraphicDiffuseColor',sprintf('[%g %g %g]',rgb),'GraphicOpacity',num2str(opac));

tph = get_param(t,'PortHandles');
add_line(S, anchor,        tph.LConn(1), 'autorouting','on');   % anchor -> base
add_line(S, tph.RConn(1),  firstFrame(sb), 'autorouting','on'); % follower -> solid
y = y + dy;
end

% ------------------------------------------------------------------------- %
function h = firstFrame(b)
% Return the (single) frame port handle of a Solid, whichever side it is on.
ph = get_param(b,'PortHandles'); c = [ph.RConn ph.LConn]; h = c(1);
end

% ------------------------------------------------------------------------- %
function delBlk(b)
% Delete a block after removing every line attached to its ports.
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
