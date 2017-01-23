function AutoLayout(address)
%AUTOLAYOUT Make a system more readable by automatically laying out all
%   system components (blocks, lines, annotations).
%
%   Inputs:
%       address     Simulink model name or path.
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
    systemBlocks = systemBlocks(2:end);
    
    % Find which blocks have no ports
    portlessBlocks = getPortlessBlocks(systemBlocks);
    
    % Find which half (top/bottom) of the system portless blocks started in
    topOrBottomMap = containers.Map();
    numBot = 0;
    numTop = 0;
    for i = 1:length(portlessBlocks)
        if inBottomHalf(systemBlocks, portlessBlocks{i})
            topOrBottomMap(getfullname(portlessBlocks{i})) = 'bottom';
            numBot = numBot + 1;
        else
            topOrBottomMap(getfullname(portlessBlocks{i})) = 'top'; %in the event of a draw, top is the default
            numTop = numTop + 1;
        end
    end
    portlessInfo = struct('portlessBlocks', portlessBlocks,...
        'topOrBottomMap',topOrBottomMap,...
        'numTop',numTop,...
        'numBot',numBot);
    
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

    % Perform a first layout using graphviz
    initLayout(address);

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
    
    % Perform a second layout to improve upon the first
    secondLayout(address, systemBlocks, portlessInfo);
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