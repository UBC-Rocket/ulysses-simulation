function capture_layout(model)
% CAPTURE_LAYOUT  Snapshot the manual block/line layout of the gimbal model so
% it can be re-applied after a full rebuild (build_model + unweld_gimbal).
%
%   capture_layout                 % captures root_param_gimbal (default)
%   capture_layout('root_param')   % capture some other open/loadable model
%
% Writes _rebuild/layout_gimbal.mat (keyed on layout for root_param_gimbal).
% Re-run this whenever you rearrange blocks/wires and want the new look to
% survive a rebuild. apply_layout.m consumes the file; unweld_gimbal.m calls
% apply_layout automatically as its last step.
%
% Keys are RELATIVE paths (model name stripped) so they stay valid even though
% the model is regenerated from scratch -- only the block *names* have to match.

if nargin < 1 || isempty(model), model = 'root_param_gimbal'; end

here = fileparts(mfilename('fullpath'));         % _tools
proj = fileparts(here);                          % v15_parametric
outfile = fullfile(proj, '_rebuild', 'layout_gimbal.mat');

wasLoaded = any(strcmp(find_system('SearchDepth',0,'type','block_diagram'), model));
if ~wasLoaded, load_system(model); end

% ---------------------------------------------------------------- blocks
blks = find_system(model, 'LookUnderMasks','all', 'FollowLinks','off', 'Type','block');
B = struct('rel',{}, 'pos',{}, 'ori',{});
clear e
for i = 1:numel(blks)
    b = blks{i};
    rel = relpath(b, model);
    if isempty(rel), continue; end               % the model block itself
    e.rel = rel;
    e.pos = get_param(b, 'Position');
    try e.ori = get_param(b, 'Orientation'); catch, e.ori = ''; end
    B(end+1) = e; %#ok<AGROW>
end

% ---------------------------------------------------------------- lines
% Only point-to-point segments (both endpoints are real block ports). Branch
% mid-segments (SrcPort or DstPort == -1) are skipped; they re-route fine once
% the endpoint blocks are back in place.
lns = find_system(model, 'LookUnderMasks','all', 'FollowLinks','off', ...
                  'FindAll','on', 'Type','line');
L = struct('parent',{}, 'src',{}, 'dst',{}, 'pts',{});
clear e
for i = 1:numel(lns)
    ln = lns(i);
    sp = get_param(ln, 'SrcPortHandle');
    dp = get_param(ln, 'DstPortHandle');
    if numel(sp)~=1 || numel(dp)~=1 || sp==-1 || dp==-1, continue; end
    e.parent = relpath(get_param(ln,'Parent'), model);
    e.src = portKey(sp, model);
    e.dst = portKey(dp, model);
    if isempty(e.src) || isempty(e.dst), continue; end
    e.pts = get_param(ln, 'Points');
    L(end+1) = e; %#ok<AGROW>
end

save(outfile, 'B', 'L', 'model');
if ~wasLoaded, close_system(model, 0); end

fprintf('capture_layout: %d blocks, %d lines -> %s\n', numel(B), numel(L), outfile);
end

% ======================================================================= helpers
function rel = relpath(p, model)
% Strip the leading model name, leaving e.g. '/Multibody Sim/V15_Shell/...'.
% Works regardless of '//'-escaped names deeper in the path.
if strcmp(p, model), rel = ''; return; end
rel = extractAfter(p, model);                    % keeps the leading '/'
end

function k = portKey(porth, model)
% Identify a port by its owner block (relative) + port type + port number,
% so the same connection can be found after a rebuild.
k = '';
try
    blk = get_param(porth, 'Parent');
    k = struct('blk', relpath(blk, model), ...
               'type', get_param(porth, 'PortType'), ...
               'num',  get_param(porth, 'PortNumber'));
catch
end
end
