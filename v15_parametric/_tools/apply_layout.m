function apply_layout(model)
% APPLY_LAYOUT  Re-apply a captured manual layout (block positions/orientation
% and wire routing) to a freshly rebuilt model. Counterpart of capture_layout.
%
%   apply_layout                 % applies to root_param_gimbal (default)
%   apply_layout('root_param_gimbal')
%
% Reads _rebuild/layout_gimbal.mat. Fully defensive: blocks/lines that no
% longer exist are skipped, individual failures never abort the run, and a
% short hit-rate report is printed. unweld_gimbal.m calls this as its last
% step so a rebuild reproduces the hand-tuned layout. No-op (with a notice)
% if the layout file is missing.

if nargin < 1 || isempty(model), model = 'root_param_gimbal'; end

here = fileparts(mfilename('fullpath'));          % _tools
proj = fileparts(here);                           % v15_parametric
infile = fullfile(proj, '_rebuild', 'layout_gimbal.mat');

if ~exist(infile, 'file')
    fprintf('apply_layout: no layout file (%s) -- skipping.\n', infile);
    return
end
S = load(infile, 'B', 'L');
B = S.B; L = S.L;

% ---------------------------------------------------------------- blocks
okB = 0; missB = 0; failB = 0;
for i = 1:numel(B)
    b = [model B(i).rel];
    if ~blockExists(b), missB = missB + 1; continue; end
    moved = false;
    try set_param(b, 'Position', B(i).pos); moved = true; catch, end
    if ~isempty(B(i).ori)
        try set_param(b, 'Orientation', B(i).ori); catch, end
    end
    if moved, okB = okB + 1; else, failB = failB + 1; end
end

% ---------------------------------------------------------------- lines
% Block positions are restored above, so endpoints are already where the user
% left them; here we restore the exact captured wire routing on top.
okL = 0; missL = 0;
for i = 1:numel(L)
    ln = findLine(model, L(i));
    if isempty(ln) || ln == -1, missL = missL + 1; continue; end
    try set_param(ln, 'Points', L(i).pts); okL = okL + 1; catch, missL = missL + 1; end
end

fprintf(['apply_layout: blocks %d/%d set (%d missing, %d failed); ' ...
         'lines %d/%d routed (%d unmatched).\n'], ...
         okB, numel(B), missB, failB, okL, numel(L), missL);
end

% ======================================================================= helpers
function tf = blockExists(b)
tf = false;
try, get_param(b, 'Handle'); tf = true; catch, end
end

function ln = findLine(model, e)
% Find the line in parent system 'e.parent' whose source and destination
% ports match the captured port keys. Returns -1 if not found.
ln = -1;
parent = [model e.parent];
if ~blockExists(parent) && ~strcmp(parent, model), return; end
lns = find_system(parent, 'SearchDepth',1, 'LookUnderMasks','all', ...
                  'FollowLinks','off', 'FindAll','on', 'Type','line');
for i = 1:numel(lns)
    sp = get_param(lns(i), 'SrcPortHandle');
    dp = get_param(lns(i), 'DstPortHandle');
    if numel(sp)~=1 || numel(dp)~=1 || sp==-1 || dp==-1, continue; end
    if portMatch(sp, e.src, model) && portMatch(dp, e.dst, model)
        ln = lns(i); return
    end
end
end

function tf = portMatch(porth, key, model)
tf = false;
if isempty(key), return; end
try
    blk = get_param(porth, 'Parent');
    rel = extractAfter(blk, model);
    tf = strcmp(rel, key.blk) && ...
         strcmp(get_param(porth,'PortType'), key.type) && ...
         isequal(get_param(porth,'PortNumber'), key.num);
catch
end
end
