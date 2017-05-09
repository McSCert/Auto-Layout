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
%   Example 1:
%       AutoLayout('AutoLayoutDemo')
%           Overwrites the AutoLayoutDemo system/subsystem with one that
%           performs the same functionally, but is laid out to be more
%           human readable.

    % Constants:
    SHOW_NAMES = getAutoLayoutConfig('show_names', 'no-change'); %Indicates which block names to show
    PORTLESS_RULE = getAutoLayoutConfig('portless_rule', 'bottom'); %Indicates how to place portless blocks
    
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
            ' invalid config parameter: show_names. Please fix in the config.txt.' char(10)])
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

%    updateLayout(address, layout);
    
    %TODO Split into three functions:
    %-ResizeBlocks in which blocks are resized while others are moved to
    %accomodate the changes
    %-RepositionBlocks in which the blocks undergo their more dramatic
    %repositioning (for better alignment primarily)
    %-FixLines in which the lines are routed as best as possible
    
    [layout, portlessInfo] = resizeBlocks(layout, portlessInfo);
    
    

%     % Left and right justify the inports and outports
%     inports = find_system(address,'SearchDepth',1,'BlockType','Inport');
%     outports = find_system(address,'SearchDepth',1,'BlockType','Outport');
%     [blocksMatrix, colLengths] = justifyBlocks(address, blocksMatrix, colLengths, inports, 1);  % Left justify inports
%     [blocksMatrix, colLengths] = justifyBlocks(address, blocksMatrix, colLengths, outports, 3);  % Right justify outports
% 


    
    

    %Update block positions according to layout
    updateLayout(address, layout);
    
    % Move blocks with single inport/outport so their port is in line with
    % the source/destination port
    % Uses layout for the grid (does not use the positions which may have
    % been altered from moveBlocks() )
    layout = easyAlign(layout);
    
    layout = layout2(address, layout, systemBlocks);

    % Place blocks that have no ports in a line along top or bottom horizontally
    % depending on where they were initially in the system
    portlessInfo = repositionPortlessBlocks(portlessInfo, layout, PORTLESS_RULE, smallOrLargeHalf);

    %Update block positions according to portlessInfo
    updatePortless(address, portlessInfo);
    
%     [blocksMatrix, colLengths] = getOrderMatrix(systemBlocks);
    
    % Perform a second layout to improve upon the first
%     secondLayout(address, systemBlocks, portlessInfo);
    

end

function [x,y] = systemCenter(blocks)
%SYSTEMCENTER Finds the center of the system (relative to block positions).

largestX = -32767;
smallestX = 32767;
largestY = -32767;
smallestY = 32767;

for i = 1:length(blocks)
    leftPos = getBlockSidePositions(blocks(i), 1);
    topPos = getBlockSidePositions(blocks(i), 2);
    rightPos = getBlockSidePositions(blocks(i), 3);
    botPos = getBlockSidePositions(blocks(i), 4);
    
    if topPos < smallestY
        smallestY = topPos;
    elseif botPos > largestY
        largestY = botPos;
    end
    
    if leftPos < smallestX
        smallestX = leftPos;
    elseif rightPos > largestX
        largestX = rightPos;
    end
end

y = (largestY + smallestY) / 2;
x = (largestX + smallestX) / 2;
end

function bool = onSide(block, center, side)
%ONSIDE Determines whether or not the center of block is on the given 
%   side of the system.
%
%   INPUTS
%       block   Full block name
%       center  Center of the system for the given side (e.g. if side is
%               'left', center will be halfway between the largest and
%               smallest X positions of blocks in the system).
%       side    Either 'left' or 'top'. Indicates the side to compare
%               the given block's center with. E.g. If side is 'left', the
%               function checks if the center of the block is on the left
%               half of the system (if it's a tie then choose left)
%
%   OUTPUTS
%       bool    Indicates whether or not the given block is on the
%               indicated side of the system.

switch side
    case 'left'
        midPos = getBlockSidePositions({block}, 5);
    case 'top'
        midPos = getBlockSidePositions({block}, 6);
end
bool = midPos <= center;
end

% function inLeftHalf = inLeftHalf(blocks,block)
% %INLEFTHALF Determines whether or not the middle of block is Left of the majority of blocks
% 
%     midXPos = getBlockSidePositions({block}, 5);
%     numBlocksOnRight = 0;
%     numBlocksOnLeft = 0;
%     for i = 1:length(blocks)
%         midXPos2 = getBlockSidePositions(blocks(i), 5);
%         if midXPos > midXPos2
%             numBlocksOnRight = numBlocksOnRight + 1;
%         elseif midXPos < midXPos2
%             numBlocksOnLeft = numBlocksOnLeft + 1;
%         end % Do nothing if equal 
%     end
%     if numBlocksOnLeft < numBlocksOnRight % if more blocks are above than below
%         inLeftHalf = true;
%     else
%         inLeftHalf = false;
%     end
% end

function [portlessInfo, smallOrLargeHalf] = getPortlessInfo(portlessRule, systemBlocks, portlessBlocks)
switch portlessRule
    case 'top'
        portlessInfo = struct('fullname', {}, ...
            'position', {});
        smallOrLargeHalf = containers.Map();
        
        for i = 1:length(portlessBlocks)
            smallOrLargeHalf(portlessBlocks{i}) = 'top';
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'left'
        portlessInfo = struct('fullname', {}, ...
            'position', {});
        smallOrLargeHalf = containers.Map();
        
        for i = 1:length(portlessBlocks)
            smallOrLargeHalf(portlessBlocks{i}) = 'left';
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'right'
        portlessInfo = struct('fullname', {}, ...
            'position', {});
        smallOrLargeHalf = containers.Map();
        
        for i = 1:length(portlessBlocks)
            smallOrLargeHalf(portlessBlocks{i}) = 'right';
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'same_half_vertical'
        [~,center] = systemCenter(systemBlocks);
        
        portlessInfo = struct('fullname', {}, ...
                    'position', {});
        smallOrLargeHalf = containers.Map();

        for i = 1:length(portlessBlocks)
            bool = onSide(portlessBlocks{i}, center, 'top');
            if bool
                smallOrLargeHalf(portlessBlocks{i}) = 'top';
            else
                smallOrLargeHalf(portlessBlocks{i}) = 'bottom';
            end
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'same_half_horizontal'
        [center,~] = systemCenter(systemBlocks);
        
        portlessInfo = struct('fullname', {}, ...
                    'position', {});
        smallOrLargeHalf = containers.Map();

        for i = 1:length(portlessBlocks)
            bool = onSide(portlessBlocks{i}, center, 'top');
            if bool
                smallOrLargeHalf(portlessBlocks{i}) = 'left';
            else
                smallOrLargeHalf(portlessBlocks{i}) = 'right';
            end
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    otherwise % 'bottom'
        portlessInfo = struct('fullname', {}, ...
            'position', {});
        smallOrLargeHalf = containers.Map();
        
        for i = 1:length(portlessBlocks)
            smallOrLargeHalf(portlessBlocks{i}) = 'bottom';
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
end
end