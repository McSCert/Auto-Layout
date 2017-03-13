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
    
    %%%TODO - currently only set up for 'same_half_vertical'%%%
    %Find where to place portless blocks in the final layout
    if strcmp(PORTLESS_RULE, 'same_half_vertical')
        % Find which half (top/bottom) of the system portless blocks are in
        topOrBottomMap = containers.Map();
        numBot = 0;
        numTop = 0;
        for i = 1:length(portlessBlocks)
            if inBottomHalf(systemBlocks, portlessBlocks{i})
                topOrBottomMap(getfullname(portlessBlocks{i})) = 'top';
                numTop = numTop + 1;
            else
                topOrBottomMap(getfullname(portlessBlocks{i})) = 'bottom'; %in the event of a draw, bottom is the default
                numBot = numBot + 1;
            end
        end
        portlessInfo = struct('portlessBlocks', portlessBlocks,...
            'topOrBottomMap',topOrBottomMap,...
            'numTop',numTop,...
            'numBot',numBot); 
    elseif strcmp(PORTLESS_RULE, 'same_half_horizontal')
        % Find which half (left/right) of the system portless blocks are in
        rightOrLeftMap = containers.Map();
        numLeft = 0;
        numRight = 0;
        for i = 1:length(portlessBlocks)
            if inLeftHalf(systemBlocks, portlessBlocks{i})
                rightOrLeftMap(getfullname(portlessBlocks{i})) = 'right';
                numRight = numRight + 1;
            else
                rightOrLeftMap(getfullname(portlessBlocks{i})) = 'left'; %in the event of a draw, left is the default
                numLeft = numLeft + 1;
            end
        end
        portlessInfo = struct('portlessBlocks', portlessBlocks,...
            'rightOrLeftMap',rightOrLeftMap,...
            'numRight',numRight,...
            'numLeft',numLeft); 
    else %Rule is top, left, bottom, or right
        %set portlessInfo
    end
    
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
    
    % Remove portless blocks from blocksInfo (they will be handled
    % separately at the end)
    for i = length(blocksInfo):-1:1 % Go backwards to remove elements without disrupting the indices that need to be checked after
        for j = 1:length(portlessBlocks)
            if strcmp(blocksInfo(i).fullname, portlessBlocks{j})
                blocksInfo(i) = [];
                break
            end
        end
    end
    
    % Find relative positioning of blocks in the layout from getLayout
	layout = getRelativeLayout(blocksInfo); %layout will also take over the role of blocksInfo

    % Enlarge block widths to fit the strings within them
    layout = adjustForText(layout);

%     % Left and right justify the inports and outports
%     inports = find_system(address,'SearchDepth',1,'BlockType','Inport');
%     outports = find_system(address,'SearchDepth',1,'BlockType','Outport');
%     [blocksMatrix, colLengths] = justifyBlocks(address, blocksMatrix, colLengths, inports, 1);  % Left justify inports
%     [blocksMatrix, colLengths] = justifyBlocks(address, blocksMatrix, colLengths, outports, 3);  % Right justify outports
% 
%     % Place blocks that have no ports in a line along top or bottom horizontally
%     % depending on where they were initially in the system
%     placePortlessBlocks(address, portlessInfo, blocksMatrix, colLengths, 'top', false);
%     placePortlessBlocks(address, portlessInfo, blocksMatrix, colLengths, 'bottom', false);
    
    % Resize block heights to better align ports with connected blocks
    %TODO
% %     Needs to happen after moving blocks once in order to know port
% %     locations
    %if inputs and outputs
%     for j = 1:size(layout.grid,2) % for each column
%         for i = 1:layout.colLengths(j) % for each non empty row in column
%             layout = resizeForConnections(i, j, layout);
%         end
%     end
    layout = resizeForPorts(layout);

    % Prepare to move blocks to indicated positions in layout
    fullnames = {}; positions = {};
    for j = 1:size(layout.grid,2)
        for i = 1:layout.colLengths(j)
            fullnames{end+1} = layout.grid{i,j}.fullname;
            positions{end+1} = layout.grid{i,j}.position;
        end
    end
    
    % Move blocks to the desired positions
    moveBlocks(address, fullnames, positions);
    
    % Move blocks with single inport/outport so their port is in line with
    % the source/destination port
    % Only uses layout for the grid (which is unchanged) not the positions
    % (which may have changed slightly)
    easyAlign(layout);

%     [blocksMatrix, colLengths] = getOrderMatrix(systemBlocks);
    
    % Perform a second layout to improve upon the first
%     secondLayout(address, systemBlocks, portlessInfo);
    
    % Show block names as appropriate
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
end

function inBottomHalf = inBottomHalf(blocks,block)
%INBOTTOMHALF Determines whether or not the middle of block is below the majority of blocks

    midYPos = getBlockSidePositions({block}, 6);
    numBlocksAbove = 0;
    numBlocksBelow = 0;
    for i = 1:length(blocks)
        midYPos2 = getBlockSidePositions(blocks(i), 6);
        if midYPos > midYPos2
            numBlocksAbove = numBlocksAbove + 1;
        elseif midYPos < midYPos2
            numBlocksBelow = numBlocksBelow + 1;
        end % Do nothing if equal 
    end
    if numBlocksBelow < numBlocksAbove % if more blocks are above than below
        inBottomHalf = true;
    else
        inBottomHalf = false;
    end
end

function inLeftHalf = inLeftHalf(blocks,block)
%INLEFTHALF Determines whether or not the middle of block is Left of the majority of blocks

    midXPos = getBlockSidePositions({block}, 5);
    numBlocksOnRight = 0;
    numBlocksOnLeft = 0;
    for i = 1:length(blocks)
        midXPos2 = getBlockSidePositions(blocks(i), 5);
        if midXPos > midXPos2
            numBlocksOnRight = numBlocksOnRight + 1;
        elseif midXPos < midXPos2
            numBlocksOnLeft = numBlocksOnLeft + 1;
        end % Do nothing if equal 
    end
    if numBlocksOnLeft < numBlocksOnRight % if more blocks are above than below
        inLeftHalf = true;
    else
        inLeftHalf = false;
    end
end