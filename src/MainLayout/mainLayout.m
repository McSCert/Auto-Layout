function mainLayout(blocks, annotations)
    blocks = inputToNumeric(blocks);
    
    %% Make sum blocks rectangular so that they will look better
    makeSumsRectangular(blocks);
    
    %%
    % Find which blocks have no ports
    portlessBlocks = inputToNumeric(getPortlessBlocks(blocks));
    
    % Find where to place portless blocks in the final layout
    [portlessInfo, smallOrLargeHalf] = getPortlessInfo(blocks, portlessBlocks);
    
    %%
    % 1) For each block, show or do not show its name depending on the SHOW_NAMES
    % parameter.
    % 2) Create a map that contains the info about whether the block should show its
    % name
    nameShowing = getShowNameParams(blocks);
    
    %%
    % Perform initial layout using some graphing method
    % Determine which external software to use:
    %   1) MATLAB's GraphPlot objects; or
    %   2) Graphviz (requires separate install)
    % based on the configuration parameters and current version of MATLAB
    
    GRAPHING_METHOD = getAutoLayoutConfig('graphing_method', 'auto'); %Indicates which graphing method to use
    
    if strcmp(GRAPHING_METHOD, 'auto')
        % Check if MATLAB version is R2015b or newer (i.e. greater-or-equal to 2015b)
        ver = version('-release');
        ge2015b = str2num(ver(1:4)) > 2015 || strcmp(ver(1:5),'2015b');
        if ge2015b
            % Graphplot
            GraphPlotLayout(blocks);
        else
            % Graphviz
            GraphvizLayout(blocks);
        end
    elseif strcmp(GRAPHING_METHOD, 'graphplot')
        % Graphplot
        GraphPlotLayout(blocks);
    elseif strcmp(GRAPHING_METHOD, 'graphviz')
        % Graphviz
        GraphvizLayout(blocks);
    else
        ErrorInvalidConfig('graphing_method')
    end
    
    %%
    % blocksInfo -  keeps track of where to move blocks so that they can all be
    %               moved at the end as opposed to throughout all of AutoLayout
    blocksInfo = getBlocksInfo(blocks);
    
    %% Show/hide block names (the initial layout may have inadvertently set it off)
    setShowNameParams(blocks, nameShowing)
    
    %%
    % Separate portless blocks out from other blocks (they will be handled separately)
    % Go backwards to remove elements without disrupting the indices that need to be
    % checked after
    for i = length(blocksInfo):-1:1
        for j = 1:length(portlessInfo)
            if strcmp(blocksInfo(i).fullname, portlessInfo{j}.fullname)
                portlessInfo{j}.position = blocksInfo(i).position;
                blocksInfo(i) = [];
                break
            end
        end
    end
    % Replace above with the following when to deal with blocks directly
    % instead of with blocksInfo
    %[orig_blocks, blocks] = remove_portless_from_blocks(blocks, portlessBlocks)
    
    %%
    % Find relative positioning of blocks in the layout from initLayout
    layout = getRelativeLayout(blocksInfo); %layout will also take over the role of blocksInfo
    updateLayout(layout); % Only included here for feedback purposes
    
    %%
    [layout, portlessInfo] = resizeBlocks(layout, portlessInfo);
    
    layout = fixSizeOfBlocks(layout);
    
    % Update block positions according to layout that was changed by resizeBlocks()
    % and fixSizeOfBlocks()
    updateLayout(layout);
    
    % Move blocks with single inport/outport so their port is in line with
    % the source/destination port
    layout = vertAlign(layout);
    % % layout = easyAlign(layout); %old method, still relevant since it attempts to cover more cases
    
    %layout = layout2(address, layout, systemBlocks); %call layout2 after
    
    %% 
    % Align inport/outport blocks if set to do so by inport/outport rules
    system = getCommonParent(inputToCell(blocks));
    INPORT_RULE = getAutoLayoutConfig('inport_rule', 'none'); %Indicates how to place inports
    if strcmp(INPORT_RULE, 'left_align')
        % Left align the inports
        inports = find_in_blocks(blocks, 'BlockType', 'Inport');
        layout = justifyBlocks(system, layout, inports, 1);
    elseif ~strcmp(INPORT_RULE, 'none')
        ErrorInvalidConfig('inport_rule')
    end
    
    OUTPORT_RULE = getAutoLayoutConfig('outport_rule', 'none'); %Indicates how to place outports
    if strcmp(OUTPORT_RULE, 'right_align')
        % Right align the outports
        outports = find_in_blocks(blocks, 'BlockType', 'Outport');
        layout = justifyBlocks(system, layout, outports, 3);
    elseif ~strcmp(OUTPORT_RULE, 'none')
        ErrorInvalidConfig('outport_rule')
    end
    
    % Update block positions according to layout
    updateLayout(layout);
    
    %%
    % Check that sort_portless is set properly
    SORT_PORTLESS = getAutoLayoutConfig('sort_portless', 'blocktype'); %Indicates how to group portless blocks
    if ~AinB(SORT_PORTLESS, {'blocktype', 'masktype_blocktype', 'none'})
        ErrorInvalidConfig('sort_portless')
    end
    
    % Place blocks that have no ports in a line along the top/bottom or left/right
    % horizontally, depending on where they were initially in the system and the
    % config file.
    portlessInfo = repositionPortlessBlocks(portlessInfo, layout, smallOrLargeHalf);
    
    % Update block positions according to portlessInfo
    updatePortless(portlessInfo);
    
    %%
    % Move all annotations to the right of the system, if necessary
    NOTE_RULE = getAutoLayoutConfig('note_rule', 'on-right'); %Indicates what to do with annotations
    if ~(strcmp(NOTE_RULE, 'none') || strcmp(NOTE_RULE, 'on-right'))
        ErrorInvalidConfig('note_rule')
    else
        handleAnnotations(layout, portlessInfo, annotations, NOTE_RULE);
    end
    
    %%
    % Orient blocks left-to-right and place name on bottom
    %setOrientations(systemBlocks);
    setNamePlacements(blocks);
    
    %%
    % Zoom on system (if it ends up zoomed out that means there is
    % something near the borders)
    system = getCommonParent(blocks);
    set_param(system, 'Zoomfactor', 'Fit to view');
end

function [orig_blocks, blocks] = remove_portless_from_blocks(blocks, portlessBlocks)
    orig_blocks = blocks;
    for i = length(blocks):-1:1
        for j = 1:length(portlessBlocks)
            if strcmp(getfullname(blocks(i)), getfullname(portlessBlocks(j)))
                blocks(i) = [];
                break
            end
        end
    end
end

function X = getRelativePlacements(blocks)
    % GETRELATIVEPLACEMENTS Find the placement of blocks relative to
    % eachother in a grid based on their physical positions.
    %
    % Inputs:
    %   blocks  Cell array of block names
    %
    % Outputs:
    %   
    
    %% TODO: mimic getRelativeLayout but take blocks as input
end

function blocks = find_in_blocks(blocks, varargin)
    % Find blocks of matching parameters and values indicated by varargin
    % Returns a vector of block handles even if blocks was given as a cell
    % array of block paths.
    %
    % varargin is given as parameter-value pairs, blocks in the input will
    % be removed in the output if their value for a given parameter does
    % not match that indicated by the value portion of the corresponding
    % parameter-value pair.
    
    blocks = inputToNumeric(blocks);
    
    assert(mod(length(varargin),2) == 0, 'Even number of varargin arguments expected.')
    for i = length(blocks):-1:1
        keep = true;
        for j = 1:2:length(varargin)
            param = varargin{j};
            value = varargin{j+1};
            if ~strcmp(get_param(blocks(i), param), value)
                keep = false;
                break
            end
        end
        
        if ~keep
            blocks(i) = [];
        end
    end
end