function AutoLayout(address)
    % AUTOLAYOUT Make a system more readable by automatically laying out all
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
    %           Modifies the AutoLayoutDemo system with one that performs the same
    %           functionally, but is laid out to be more readable.
    
    %%
    % Check number of arguments
    try
        assert(nargin == 1)
    catch
        error(' Wrong number of arguments.');
    end
    
    % Check address argument
    % 1) Check model at address is open
    try
        assert(ischar(address));
        assert(bdIsLoaded(bdroot(address)));
    catch
        error(' Invalid argument: address. Model may not be loaded or name is invalid.');
    end
    
    % 2) Check that model is unlocked
    try
        assert(strcmp(get_param(bdroot(address), 'Lock'), 'off'));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
                strcmp(ME.identifier, 'MATLAB:assertion:failed')
            error('File is locked');
        end
    end
    
    % 3) If address has a LinkStatus, then it is 'none' or 'inactive'
    try
        assert(any(strcmp(get_param(address, 'LinkStatus'), {'none','inactive'})), 'LinkStatus must be ''none'' or ''inactive''.')
    catch ME
        if ~strcmp(ME.identifier,'Simulink:Commands:ParamUnknown')
            rethrow(ME)
        end
    end
    
    %% Get blocks in address
    systemBlocks = find_system(address, 'SearchDepth', 1);
    systemBlocks = systemBlocks(2:end); %Remove address itself
    
    %% Make sum blocks rectangular so that they will look better
    makeSumsRectangular(systemBlocks);
    
    %%
    % Find which blocks have no ports
    portlessBlocks = getPortlessBlocks(systemBlocks);
    
    % Find where to place portless blocks in the final layout
    [portlessInfo, smallOrLargeHalf] = getPortlessInfo(systemBlocks, portlessBlocks);
    
    %%
    % 1) For each block, show or do not show its name depending on the SHOW_NAMES
    % parameter.
    % 2) Create a map that contains the info about whether the block should show its
    % name
    nameShowing = getShowNameParams(systemBlocks);
    
    %% Determine which initial layout graphing method to use
    initLayout = selectGraphingFunction();
    
    %% Get the intial layout using a graphing algorithm
    initLayout(address);
    % If using GraphvizLayout, the layout at this point will be organized based on
    % the GraphPlot and the blocks will be resized to the same size
    %%
    % blocksInfo -  keeps track of where to move blocks so that they can all be
    %               moved at the end as opposed to throughout all of AutoLayout
    blocksInfo = getBlocksInfo(address);
    
    %% Show/hide block names (initLayout may inadvertently set it off)
    setShowNameParams(systemBlocks, nameShowing)
    
    %%
    % 1) Remove portless blocks from blocksInfo (they will be handled separately)
    % 2) Add the position information of the portless block to the struct array of
    % portless blocks
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
    
    %%
    % Find relative positioning of blocks in the layout from initLayout
    layout = getRelativeLayout(blocksInfo); %layout will also take over the role of blocksInfo
    updateLayout(address, layout); % Only included here for feedback purposes
    
    %%
    [layout, portlessInfo] = resizeBlocks(layout, portlessInfo);
    
    layout = fixSizeOfBlocks(layout);
    
    % Update block positions according to layout that was changed by resizeBlocks()
    % and fixSizeOfBlocks()
    updateLayout(address, layout);
    
    % Move blocks with single inport/outport so their port is in line with
    % the source/destination port
    layout = vertAlign(layout);
    % % layout = easyAlign(layout); %old method, still relevant since it attempts to cover more cases
    
    %layout = layout2(address, layout, systemBlocks); %call layout2 after
    
    % Align inport/outport blocks if set to do so by inport/outport rules
    INPORT_RULE = getAutoLayoutConfig('inport_rule', 'none'); %Indicates how to place inports
    if strcmp(INPORT_RULE, 'left_align')
        % Left align the inports
        inports = find_system(address,'SearchDepth',1,'BlockType','Inport');
        layout = justifyBlocks(address, layout, inports, 1);
    elseif ~strcmp(INPORT_RULE, 'none')
        ErrorInvalidConfig('inport_rule')
    end
    
    OUTPORT_RULE = getAutoLayoutConfig('outport_rule', 'none'); %Indicates how to place outports
    if strcmp(OUTPORT_RULE, 'right_align')
        % Right align the outports
        outports = find_system(address,'SearchDepth',1,'BlockType','Outport');
        layout = justifyBlocks(address, layout, outports, 3);
    elseif ~strcmp(OUTPORT_RULE, 'none')
        ErrorInvalidConfig('outport_rule')
    end
    
    % Update block positions according to layout
    updateLayout(address, layout);
    
    %%
    % Place blocks that have no ports in a line along the top/bottom or left/right
    % horizontally, depending on where they were initially in the system and the
    % PORTLESS_RULE.
    portlessInfo = repositionPortlessBlocks(portlessInfo, layout, smallOrLargeHalf);
    
    % Update block positions according to portlessInfo
    updatePortless(address, portlessInfo);
    
    %%
    % Get all the annotations
    annotations = find_system(address,'FindAll','on','SearchDepth',1,'Type','annotation');
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
    setNamePlacements(systemBlocks);
    
    %%
    % Zoom on system (if it ends up zoomed out that means there is
    % something near the borders)
    set_param(address, 'Zoomfactor', 'Fit to view');
end