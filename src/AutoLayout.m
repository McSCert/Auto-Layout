function AutoLayout(address)
%AUTOLAYOUT Make a system more readable by automatically laying out all
%   system components (blocks, lines, annotations).
%
%   Inputs:
%       address     Simulink system name or path.
%
%   Outputs:
%       N/A
%
%   Example:
%       AutoLayout('AutoLayoutDemo')
%           Overwrites the AutoLayoutDemo system/subsystem with one that
%           performs the same functionally, but is laid out to be more
%           human readable.

% Constants:
SHOW_NAMES = getAutoLayoutConfig('show_names', 'no-change'); %Indicates which block names to show
PORTLESS_RULE = getAutoLayoutConfig('portless_rule', 'bottom'); %Indicates how to place portless blocks
INPORT_RULE = getAutoLayoutConfig('inport_rule', 'none'); %Indicates how to place inports
OUTPORT_RULE = getAutoLayoutConfig('outport_rule', 'none'); %Indicates how to place outports
SORT_PORTLESS = getAutoLayoutConfig('sort_portless', 'blocktype'); %Indicates how to group portless blocks
NOTE_RULE = getAutoLayoutConfig('note_rule', 'on-right'); %Indicates what to do with annotations

% Check number of arguments
try
    assert(nargin == 1)
catch
    disp(['Error using ' mfilename ':' char(10) ...
        ' Wrong number of arguments.' char(10)])
    return
end

% Check address argument
% 1) Check model at address is open
try
    assert(ischar(address));
    assert(bdIsLoaded(bdroot(address)));
catch
    disp(['Error using ' mfilename ':' char(10) ...
        ' Invalid argument: address. Model may not be loaded or name is invalid.' char(10)])
    return
end

% 2) Check that model is unlocked
try
    assert(strcmp(get_param(bdroot(address), 'Lock'), 'off'));
catch ME
    if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
            strcmp(ME.identifier, 'MATLAB:assertion:failed')
        disp(['Error using ' mfilename ':' char(10) ...
            ' File is locked.'])
        return
    end
end

% Get blocks in address
systemBlocks = find_system(address, 'SearchDepth',1);
systemBlocks = systemBlocks(2:end); %Remove address itself

% Find which blocks have no ports
portlessBlocks = getPortlessBlocks(systemBlocks);

% Check that portless_rule is set properly
if ~AinB(PORTLESS_RULE, {'top', 'left', 'bottom', 'right', 'same_half_vertical', 'same_half_horizontal'})
    % Invalid config setting
    disp(['Error using ' mfilename ':' char(10) ...
        ' invalid config parameter: portless_rule. Please fix in the config.txt.'])
    return
end

% Find where to place portless blocks in the final layout
[portlessInfo, smallOrLargeHalf] = getPortlessInfo(PORTLESS_RULE, systemBlocks, portlessBlocks);

if strcmp(SHOW_NAMES, 'no-change')
    % Find which block names are showing at the start
    nameShowing = containers.Map();
    for i = 1:length(systemBlocks)
        if strcmp(get_param(systemBlocks(i), 'ShowName'), 'on')
            nameShowing(getfullname(systemBlocks{i})) = 'on';
            set_param(systemBlocks{i}, 'ShowName', 'off')
        elseif strcmp(get_param(systemBlocks(i), 'ShowName'), 'off')
            nameShowing(getfullname(systemBlocks{i})) = 'off';
        end
    end
end

% Get rough layout using graphviz
blocksInfo = getLayout(address); %blocksInfo keeps track of where to move blocks so that they can all be moved at the end as opposed to throughout all of AutoLayout

% Show block names as appropriate (getLayout sets it off)
if strcmp(SHOW_NAMES, 'no-change')
    % Return block names to be showing or not showing as they were
    % initially
    for i = 1:length(systemBlocks)
        if strcmp(nameShowing(getfullname(systemBlocks{i})), 'on')
            set_param(systemBlocks{i}, 'ShowName', 'on')
        else
            % This should be redundant with the implementation, but is in place as a fail-safe
            set_param(systemBlocks{i}, 'ShowName', 'off')
        end
    end
elseif strcmp(SHOW_NAMES, 'all')
    % Show all block names
    for i = 1:length(systemBlocks)
        set_param(systemBlocks{i}, 'ShowName', 'on')
    end
elseif strcmp(SHOW_NAMES, 'none')
    % Show no block names
    for i = 1:length(systemBlocks)
        set_param(systemBlocks{i}, 'ShowName', 'off')
    end
else
    % Invalid config setting
    disp(['Error using ' mfilename ':' char(10) ...
        ' invalid config parameter: show_names. Please fix in the config.txt.'])
    return
end

% Remove portless blocks from blocksInfo (they will be handled
% separately at the end)
for i = length(blocksInfo):-1:1 % Go backwards to remove elements without disrupting the indices that need to be checked after
    for j = 1:length(portlessInfo)
        if strcmp(blocksInfo(i).fullname, portlessInfo{j}.fullname)
            portlessInfo{j}.position = blocksInfo(i).position;
            blocksInfo(i) = [];
            break
        end
    end
end

% Find relative positioning of blocks in the layout from getLayout
layout = getRelativeLayout(blocksInfo); %layout will also take over the role of blocksInfo
updateLayout(address, layout); % Only included here for feedback purposes

%TODO Split into three functions:
%-ResizeBlocks in which blocks are resized while others are moved to
%accomodate the changes
%-RepositionBlocks in which the blocks undergo their more dramatic
%repositioning (for better alignment primarily)
%-FixLines in which the lines are routed as best as possible

[layout, portlessInfo] = resizeBlocks(layout, portlessInfo);

%Update block positions according to layout
updateLayout(address, layout);

% Move blocks with single inport/outport so their port is in line with
% the source/destination port
layout = vertAlign(layout);
% % layout = easyAlign(layout); %old method, still relevant since it attempts to cover more cases

% % layout = layout2(address, layout, systemBlocks); %temp removed, adding
% it won't error, it's just not too likely to help

% Align in/outport blocks if set to do so by in/outport rules
if strcmp(INPORT_RULE, 'left_align')
    % Left align the inports
    inports = find_system(address,'SearchDepth',1,'BlockType','Inport');
    layout = justifyBlocks(address, layout, inports, 1);
elseif ~strcmp(INPORT_RULE, 'none')
    % Invalid config setting
    disp(['Error using ' mfilename ':' char(10) ...
        ' invalid config parameter: inport_rule. Please fix in the config.txt.'])
    return
end % elseif 'none', then do nothing
if strcmp(OUTPORT_RULE, 'right_align')
    % Right align the outports
    outports = find_system(address,'SearchDepth',1,'BlockType','Outport');
    layout = justifyBlocks(address, layout, outports, 3);
elseif ~strcmp(OUTPORT_RULE, 'none')
    % Invalid config setting
    disp(['Error using ' mfilename ':' char(10) ...
        ' invalid config parameter: outport_rule. Please fix in the config.txt.'])
    return
end % elseif 'none', then do nothing
%Update block positions according to layout
updateLayout(address, layout);

% Check that sort_portless is set properly
if ~AinB(SORT_PORTLESS, {'blocktype', 'masktype_blocktype', 'none'})
    % Invalid config setting
    disp(['Error using ' mfilename ':' char(10) ...
        ' invalid config parameter: sort_portless. Please fix in the config.txt.'])
    return
end

% Place blocks that have no ports in a line along top/bottom or left/right
% horizontally depending on where they were initially in the system, and on
% PORTLESS_RULE.
portlessInfo = repositionPortlessBlocks(portlessInfo, layout, PORTLESS_RULE, smallOrLargeHalf, SORT_PORTLESS);

%Update block positions according to portlessInfo
updatePortless(address, portlessInfo);

% Get all annotations in address
annotations = find_system(address,'FindAll','on','SearchDepth',1,'Type','annotation');
% Move all annotations to the right of the system
handleAnnotations(layout, portlessInfo, annotations, NOTE_RULE);

% Orient blocks left-to-right and place name on bottom
%setOrientations(systemBlocks);
setNamePlacements(systemBlocks);

% Zoom on system (if it ends up zoomed out that should mean there is
% something near the borders)
set_param(address, 'Zoomfactor', 'Fit to view');
end