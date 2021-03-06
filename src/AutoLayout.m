function AutoLayout(selected_objects, varargin)
    % AUTOLAYOUT Make a system more readable by automatically laying out
    % the given Simulink objects (blocks and annotations only) with respect
    % to each other. Other objects in the system are shifted to prevent
    % overlapping with the laid out objects.
    %
    % Inputs:
    %   selected_objects    List (vector or cell array) of Simulink objects
    %                       (fullnames or handles) with the same parent
    %                       system. Lines and ports are ignored, however,
    %                       lines and ports associated with a given block
    %                       are laid out along with the corresponding
    %                       block.
    %   varargin            Parameter-Value pairs as detailed below. Some of the
    %                       options are also found in config.txt of the same
    %                       directory as AutoLayout.m, if not specified via
    %                       direct input, the default value of these parameters
    %                       will be picked up from that file (these defaults are
    %                       marked with "config.txt").
    %
    % Parameter-Value pairs:
    %   Parameters related to moving unselected objects in the system
    %   Parameter: 'LayoutStartBounds'
    %   Value: Vector given like a block's position parameter as
    %       [left top right bot] specifying the bounds of the positions of
    %       the given objects. Default: [] indicating that this should be
    %       determined by the object positions when this function is
    %       called.
    %	Parameter: 'ShiftAll'
    %   Value:  'on' - (Default) All objects in the same system as the selected
    %               objects may be shifted to prevent overlaps. I.e. unselected
    %               objects are just shifted out of the way.
    %           'off' - Only objects given as input may be shifted.
    %
    %   Parameters related to initial layout:
    %   Parameter: 'LayoutType' - Indicates the type of layout to perform
    %       to get the initial layout. This may affect other aspects of the
    %       layout that occur after as well since assumptions about the
    %       initial layout can sometimes be used to make other
    %       modifications.
    %   Value:  'GraphPlot' - Uses MATLAB's built-in GraphPlot objects to
    %               construct a graph where the blocks are nodes and signal
    %               lines are edges and then lays out blocks using the plot
    %               function with a layered layout.
    %           'Graphviz' - Uses Graphviz (a 3rd-party tool) which must be
    %               installed to generate an initial layout in a similar
    %               fashion to GraphPlot (however Graphviz is generally
    %               able to provide a somewhat improved initial layout).
    %           'DepthBased' - Assigns initial columns to place blocks in
    %               based on when a block is reached. Essentially, if block
    %               A connects to block B, then block B will have a depth
    %               equal to the depth of A + 1 and depth directly
    %               determines the column.
    %           From config.txt - (Default)
    %   Parameter: 'Columns' - Only available if LayoutType parameter is
    %       'DepthBased'.
    %   Value:  A containers.Map() variable mapping from block handles to
    %       the desired column number for the corresponding block. The
    %       minimum column is 1 and it will be the furthest left in the
    %       Simulink diagram. Blocks that are not in the map, but are in
    %       the input may be assigned a column arbitrarily. (Default) Use
    %       built-in functions to find reasonable columns automatically
    %       based on distance from other blocks.
    %	Parameter: 'ColumnWidthMode' - Column width refers to the space
    %       allocated for blocks in a given column (used for spacing
    %       between columns.
    %   Value:  'MaxBlock' - Each column is as wide as the widest block
    %               in the input set of blocks.
    %           'MaxColBlock' - (Default) Each column is as wide as the
    %               widest block in that column.
    %   Parameter: 'ColumnAlignment' - Available if LayoutType parameter is
    %       one of the following: 'GraphPlot', 'Graphviz', 'DepthBased'
    %       (all current layout types Aug. 20, 2018).
    %   Value:  'left' - (Default) All blocks in a column will share a
    %               left position.
    %           'right' - All blocks in a column will share a right
    %               position.
    %           'center' - All blocks in a column will be centered around
    %               the same point on the horizontal axis.
    %   Parameter: 'HorizSpacing' - Refers to space between columns.
    %   Value:  Any double. Default: 80.
    %
    %   Parameters related to block width:
    %   Parameter: 'AdjustWidthParams'
    %   Value:  Cell array of optional arguments to pass to adjustWidth.m,
    %       'PerformOperation', 'off' is passed automatically. (Default)
    %       Empty cell array (pass no optional arguments except
    %       'PerformOperation').
    %   Parameter: 'WidthMode' - Rule used for consistency of widths of
    %       blocks.
    %   Value:  'AsIs' - (Default) After initial adjustment of widths, no
    %               change is made.
    %           'MaxBlock' - After initial adjustment of widths, each block
    %               in each column is made as wide as the widest block in
    %               the input set of blocks.
    %           'MaxColBlock' - After initial adjustment of widths, each
    %               block in each column is made as wide as the widest
    %               block in that column.
    %           'MaxOfType' - After initial adjustment of widths, each
    %               block is made as wide as the widest block of its type.
    %               Here, blocks have the same type if they share mask type
    %               and block type.
    %
    %   Parameters related to block height:
    %   Parameter: 'AdjustHeightParams'
    %   Value:  Cell array of optional arguments to pass to adjustHeight.m,
    %       'PerformOperation', 'off' is passed automatically. (Default)
    %       Empty cell array (pass no optional arguments except
    %       'PerformOperation').
    %   Parameter: 'SubHeightMethod' - Refers to the "Method" used to determine
    %       heights of SubSystem blocks (options are the same as in 
    %       adjustHeightForConnectedBlocks).
    %   Value:  Options are 'Sum', 'SumMax' (Default), 'MinMax', and 'Compact'.
    %   Parameter: 'VertSpacing' - Refers to space between blocks within a
    %       column (essentially this is used where alignment fails).
    %   Value:  Any double. Default: 20.
    %   Parameter: 'AlignmentType'
    %   Value:  'Source' - (Default) Try to align a blocks with a source.
    %           'Dest' - Try to align a blocks with a destination.
    %
    %   Miscellaneous:
    %   Parameter: 'DesiredSumShape'
    %   Value:  'rectangular' - Changes the shapes of Sum blocks to be
    %               rectangular.
    %           'round' - Changes the shapes of Sum blocks to be round.
    %           'any' - (Default) Does not change the shapes of Sum blocks.
    %   Parameter: 'PortlessRule' - Determines where blocks with no ports should
    %       be placed in the layout with respect to the bounds of the rest of
    %       the selected objects after they have been laid out.
    %   Value:  'left' - Portless blocks placed left of the bounds.
    %           'top' - Portless blocks placed above the bounds.
    %           'right' - Portless blocks placed right of the bounds.
    %           'bottom' - Portless blocks placed below the bounds.
    %           'same_half_vertical' - Portless blocks placed above if they
    %               began in the top-half of the starting bounds, below
    %               otherwise.
    %           'same_half_horizontal' - Portless blocks placed on the left if
    %               they began in the top-half of the starting bounds, on the
    %               right otherwise.
    %           From config.txt - (Default)
    %   Parameter: 'PortlessSortRule' - Determines the way blocks with no ports
    %       will be grouped with their placements defined by PortlessRule.
    %   Value:  'blocktype' - Portless blocks will be grouped by their BlockType
    %               parameter.
    %           'masktype_blocktype' - Portless blocks will be grouped into
    %           unique MaskType-BlockType pairs.
    %           'none' - No grouping is done.
    %           From config.txt - (Default) See the sort_portless config
    %   Parameter: 'InportRule' - Determines how to layout inport blocks.
    %   Value:  'left-align' - Inports are aligned on the far left of the layout
    %               bounds unless there are obstructions.
    %           'none' - Inports are treated the same as other blocks in the
    %               layout.
    %           From config.txt - (Default)
    %   Parameter: 'OutportRule' - Determines how to layout outport blocks.
    %   Value:  'right-align' - Outports are aligned on the far right of the
    %               layout bounds unless there are obstructions.
    %           'none' - Outports are treated the same as other blocks in the
    %               layout.
    %           From config.txt - (Default)
    %   Parameter: 'NoteRule' - Determines how to layout annotations.
    %   Value:  'on-right' - Selected annotations are moved to the right side of
    %               the system so they can be found easily.
    %           'none' - Annotations are not moved at all.
    %           From config.txt - (Default)
    %   Parameter: 'ShowNames' - Determines whether or not to show block names.
    %   Value:  'no-change' - Block names will remain showing/hidden without
    %               change.
    %           'all' - All blocks will show their name.
    %           'none' - No blocks will show their name.
    %           From config.txt - (Default)
    %
    % Outputs:
    %   N/A
    %
    % Example:
    %   >> open_system('AutoLayoutDemo')
    %   *Select everything in AutoLayoutDemo (ctrl + A)*
    %   >> AutoLayout(gcbs)
    %   Result: Modifies the AutoLayoutDemo system with one that performs
    %   the same functionally, but is laid out to be more readable.
    
    %% Input handling
    
    % Handle parameter-value pairs
    LayoutStartBounds = [];
    ShiftAll = 'on';
    LayoutType = default_layout_type();
    Columns = containers.Map(); % indicates to find columns automatically
    ColumnWidthMode = lower('MaxColBlock');
    ColumnAlignment = 'left';
    HorizSpacing = 80;
    AdjustWidthParams = {};
    WidthMode = lower('AsIs');
    AdjustHeightParams = {};
    SubHeightMethod = 'SumMax';
    VertSpacing = 20;
    AlignmentType = lower('Source');
    DesiredSumShape = 'any';
    PortlessRule = getAutoLayoutConfig('portless_rule', 'top');
    PortlessSortRule = getAutoLayoutConfig('sort_portless', 'blocktype');
    InportRule = getAutoLayoutConfig('inport_rule', 'left-align');
    OutportRule = getAutoLayoutConfig('outport_rule', 'right-align');
    NoteRule = getAutoLayoutConfig('note_rule', 'on-right');
    ShowNames = getAutoLayoutConfig('show_names', 'no-change');
    assert(mod(length(varargin),2) == 0, 'Even number of varargin arguments expected.')
    for i = 1:2:length(varargin)
        param = lower(varargin{i});
        value = varargin{i+1};
        if ischar(value) || (iscell(value) && all(cellfun(@(a) ischar(a), value)))
            value = lower(value);
        end
        
        switch param
            case lower('LayoutStartBounds')
                assert(isa(value, 'double') && any(length(value) == [4 0]), ...
                    ['Unexpected value for ' param ' parameter.'])
                LayoutStartBounds = value;
            case lower('ShiftAll')
                assert(any(strcmpi(value, {'on','off'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                ShiftAll = value;
            case lower('LayoutType')
                if strcmpi(value, 'Default')
                    tmp_value = default_layout_type();
                else
                    tmp_value = value;
                end
                assert(any(strcmpi(tmp_value, {'GraphPlot', 'Graphviz', 'DepthBased'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                LayoutType = tmp_value;
            case lower('Columns')
                assert(isa(value, 'containers.Map'), ...
                    ['Unexpected value for ' param ' parameter.'])
                if strcmp(value.KeyType, 'char')
                    Columns = fullname_map2handle_map(value);
                else
                    Columns = value;
                end
            case lower('ColumnWidthMode')
                assert(any(strcmpi(value,{'MaxBlock','MaxColBlock'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                ColumnWidthMode = value;
            case lower('ColumnAlignment')
                assert(any(strcmpi(value,{'left','right','center'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                ColumnAlignment = value;
            case lower('HorizSpacing')
                assert(isnumeric(value), ...
                    ['Unexpected value for ' param ' parameter.'])
                HorizSpacing = value;
            case lower('AdjustWidthParams')
                assert(iscell(value), ...
                    ['Unexpected value for ' param ' parameter.'])
                AdjustWidthParams = value;
            case lower('WidthMode')
                assert(any(strcmpi(value,{'AsIs','MaxBlock','MaxColBlock'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                WidthMode = value;
            case lower('AdjustHeightParams')
                assert(iscell(value), ...
                    ['Unexpected value for ' param ' parameter.'])
                AdjustHeightParams = value;
            case lower('SubHeightMethod')
                assert(any(strcmpi(value, {'Sum', 'SumMax', 'MinMax', 'Compact'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                SubHeightMethod = value;
            case lower('VertSpacing')
                assert(isnumeric(value), ...
                    ['Unexpected value for ' param ' parameter.'])
                VertSpacing = value;
            case lower('AlignmentType')
                assert(any(strcmpi(value,{'Source','Dest'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                AlignmentType = value;
            case lower('PortlessRule')
                assert(any(strcmpi(value, ...
                    {'left', 'top', 'right', 'bottom', 'same_half_vertical', 'same_half_horizontal'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                PortlessRule = value;
            case lower('DesiredSumShape')
                assert(any(strcmpi(value, {'rectangular', 'round', 'any'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                DesiredSumShape = value;
            case lower('PortlessSortRule')
                assert(any(strcmpi(value, {'blocktype', 'masktype_blocktype', 'none'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                PortlessSortRule = value;
            case lower('InportRule')
                assert(any(strcmpi(value, {'left-align', 'none'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                InportRule = value;
            case lower('OutportRule')
                assert(any(strcmpi(value, {'right-align', 'none'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                OutportRule = value;
            case lower('NoteRule')
                assert(any(strcmpi(value, {'on-right', 'none'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                NoteRule = value;
            case lower('ShowNames')
                assert(any(strcmpi(value, {'no-change', 'all', 'none'})), ...
                    ['Unexpected value for ' param ' parameter.'])
                ShowNames = value;
            otherwise
                error(['Invalid parameter: ' param '.'])
        end
    end
    
    % Check number of arguments
    try
        assert(nargin - length(varargin) == 1)
    catch
        error(' Expected 1 argument before optional parameters.');
    end
    
    % Make selected_objects a vector of handles
    selected_objects = inputToNumeric(selected_objects);
    % Remove lines and ports from selected_objects
    [selected_blocks, ~, selected_annotations, ~] = separate_objects_by_type(selected_objects);
    selected_objects = [selected_blocks, selected_annotations];
    
    % Check first argument
    % 1) Determine the system in which the layout is taking place
    % 2) Check that all objects are in the system
    % 3) Check that model is unlocked
    % 4) If address has a LinkStatus, then check that it is 'none' or
    % 'inactive'
    if isempty(selected_objects)
        disp('Nothing selected to lay out.')
        return
    else
        % 1), 2)
        system = getCommonParent(selected_objects);
        
        % 3)
        try
            assert(strcmp(get_param(bdroot(system), 'Lock'), 'off'));
        catch ME
            if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
                    strcmp(ME.identifier, 'MATLAB:assertion:failed')
                error('File is locked');
            end
        end
        
        % 4)
        try
            assert(any(strcmp(get_param(system, 'LinkStatus'), {'none','inactive'})), 'LinkStatus must be ''none'' or ''inactive''.')
        catch ME
            if ~strcmp(ME.identifier,'Simulink:Commands:ParamUnknown')
                rethrow(ME)
            end
        end
    end
    
    %% Identify the bounds of the layout prior to automatic layout
    if isempty(LayoutStartBounds)
        % Get current bounds of given objects
        orig_bounds = bounds_of_sim_objects(selected_objects);
    else
        % Use given bounds
        orig_bounds = LayoutStartBounds;
    end
    
    %% Rotate given blocks to a right orientation (for left-to-right dataflow)
    setOrientations(selected_blocks);
    
    %%
    switch DesiredSumShape
        case 'round'
            change_sum_shape(selected_blocks, 'rectangular');
        case 'rectangular'
            change_sum_shape(selected_blocks, 'round');
        case 'any'
            % Skip, leave the sums alone
        otherwise
            error('Unexpected parameter value. Parameter: DesiredSumShape')
    end
    
    %%
    showingNamesMap = get_showname_map(selected_blocks, ShowNames);
    
    %% Determine which blocks should be laid out separate to the rest
    % This refers primarily to laying out blocks with no ports as the
    % layout approaches will generally use ports and connections through
    % them to figure out where blocks belong.
    %
    % selected_objects - all objects to lay out
    % objects - vector of object handles to lay out based on dataflow
    % objectsToIsolate - vector of object handles to lay out separately
    switch PortlessRule
        case {'bottom','top','left','right','same_half_vertical','same_half_horizontal'}
            % Remove portless blocks from the set of objects so they can be
            % handled separately.
            objectsToIsolate = getPortlessBlocks(selected_blocks);
            objects = setdiff(selected_objects, objectsToIsolate);
        case {'none'}
            objectsToIsolate = [];
            objects = selected_objects;
        otherwise
            error('Unexpected parameter value.')
    end
    
    %% Remove objects that aren't blocks or annotations
    % Also get the blocks and annotations
    
    % Separate objects into the different types
    [blocks, ~, annotations, ~] = separate_objects_by_type(objects);
    % Update objects to blocks and annotations
    objects = [blocks, annotations];
    
    blockLines = get_block_lines(blocks); % Lines connected to the given blocks
    
    % Get just lines associated with the blocks
    % TODO - involve the selected lines at least as an option
    if ~isempty(blocks)
        lines = get_block_lines(blocks);
    else
        lines = [];
    end
    
    %% Determine how to lay out blocks that should be laid out separately
    
    % Get just blocks:
    [blocksToIsolate, ~, ~, ~] = separate_objects_by_type(objectsToIsolate);
    
    %
    switch PortlessRule
        case {'left', 'top', 'right', 'bottom'}
            % Give all blocks a corresponding 'quadrant' value indicating
            % where to place blocks (on the left, top, right, or bottom of
            % other blocks). A quadrant is indicated by a point in the
            % cartesian coordinate system.
            
            sides = {'left', 'top', 'right', 'bottom'};
            quads = [-1 0; 0 1; 1 0; 0 -1]; % Value for quadrants map corresponding with different PortlessRule values. 0 means doesn't matter. Values are points on a cartesian map.
            quadrant = quads(strcmp(PortlessRule, sides), :);
            
            quadrants_map = containers.Map('KeyType', 'double', 'ValueType', 'any');
            for i = 1:length(blocksToIsolate)
                quadrants_map(blocksToIsolate(i)) = quadrant;
            end
        case {'same_half_vertical', 'same_half_horizontal'}
            center_of_blocks = position_center(bounds_of_sim_objects(blocksToIsolate));
            quadrants_map = getWhichQuadrantBlocksAreIn(center_of_blocks, blocksToIsolate);
        otherwise
            error('Unexpected parameter value.')
    end
    
    %% Get a representation of the desired layout
    % Only need to represent where things belong with respect to each
    % other for now, not specific positions, sizing, or line routing
    %
    % layoutRepresentation - Cell array where each element represents a
    %   column in the final layout as a cell array of blocks. For
    %   LayoutType of GraphPlot and Graphviz the order of blocks within a
    %   column should be preserved in the final layout (for DepthBased the
    %   order within a column will not be considered when setting
    %   layoutRepresentation).
    
    switch LayoutType
        case lower({'GraphPlot','Graphviz'})
            %%
            % Perform initial layout using some graphing method
            % Determine which approach to use:
            %   1) MATLAB's GraphPlot objects; or
            %   2) Graphviz (requires separate install)
            
            switch LayoutType
                case lower('GraphPlot')
                    GraphPlotLayout(blocks);
                case lower('Graphviz')
                    GraphvizLayout(blocks);
                otherwise
                    error(['Unexpected value, ' LayoutType ', to parameter, LayoutType.']);
            end
            
            layoutRepresentation = find_relative_layout(blocks);
        case lower('DepthBased')
            % Get a list of columns corresponding to the blocks list
            if isempty(Columns)
                % Use default function
                cols = choose_impact_depths(blocks);
            else
                % Use given map
                % For blocks not in the given map use the default function ...
                % to get a column for them.
                for i = 1:length(blocks)
                    tmp_blocks = [];
                    if ~Columns.isKey(blocks(i))
                        tmp_blocks(end+1) = blocks(i);
                    end
                end
                tmp_cols = getImpactDepths(tmp_blocks);
                for i = 1:length(tmp_blocks)
                    Columns(tmp_blocks(i)) = tmp_cols(i);
                end
                cols = zeros(1, length(blocks));
                for i = 1:length(blocks)
                    cols(i) = Columns(blocks(i));
                end
            end
            assert(length(cols) == length(blocks))
            % TODO: Add option when determining columns to place in/outports in the
            % first/last column specfically
            
            % Sort blocks into a cell array based on designated column.
            % i.e. All column X blocks will be in a cell array in the Xth
            % cell of blx_by_col
            blx_by_col = cell(1,length(blocks));
            for i = 1:length(blocks)
                d = cols(i);
                if isempty(blx_by_col{d})
                    blx_by_col{d} = cell(1,length(blocks));
                end
                blx_by_col{d}{i} = blocks(i);
            end
            blx_by_col(cellfun('isempty',blx_by_col)) = [];
            for i = 1:length(blx_by_col)
                blx_by_col{i}(cellfun('isempty',blx_by_col{i})) = [];
            end
            
            layoutRepresentation = blx_by_col;
        otherwise
            error('Unexpected parameter value.')
    end
    
    %% Set blocks to desired base widths
    % Actual position horizontally doesn't matter yet
    for i = 1:length(selected_blocks)
        [~, pos] = adjustWidth(selected_blocks(i), 'PerformOperation', 'off', AdjustWidthParams{:});
        set_param(selected_blocks(i), 'Position', pos);
    end
    
    %% Place blocks in their columns and adjust widths based on columns
    layoutUsesColumns = any(strcmpi(LayoutType, {'GraphPlot', 'Graphviz', 'DepthBased'})); % Layout places blocks in columns.
    if layoutUsesColumns
        %% Set blocks to widths desired for consistency
        % Adjust widths again to make them more consistent within a column
        % (depending on an input parameter)
        switch WidthMode
            case lower('AsIs')
                blockWidths = -1*ones(1,length(blocks)); % -1 to indicate no change
            case lower('MaxBlock')
                width = getMaxWidth(blocks); % Maximum width among all blocks
                blockWidths = width*ones(1,length(blocks));
            case lower('MaxColBlock')
                blockWidths = -2*ones(1,length(blocks)); % No blocks should indicate a width of -2 when being set
                count = 0;
                for i = 1:length(layoutRepresentation)
                    width = getMaxWidth(layoutRepresentation{i}); % Maximum width in ith column
                    for j = 1:length(layoutRepresentation{i})
                        blockWidths(count+j) = width;
                    end
                    count = count + length(layoutRepresentation{i});
                end
            case lower('MaxOfType')
                % Make blocks as wide as the widest block of its type
                blockWidths = -2*ones(1,length(blocks)); % No blocks should indicate a width of -2 when being set
                for i = 1:length(blocks)
                    width = getBlockWidth(blocks(i)); % initial width
                    for j = 1:length(blocks)
                        if cmp_type_of_block(blocks(i), blocks(j)) % blocks are same type
                            width_j = getBlockWidth(blocks(j));
                            if width_j > width % block is wider
                                width = width_j; % update maxwidth for the type
                            end
                        end
                    end
                    blockWidths(i) = width;
                end
            otherwise
                error('Unexpected parameter.')
        end
        % set positions based on widths found above
        count = 0;
        for i = 1:length(layoutRepresentation)
            for j = 1:length(layoutRepresentation{i})
                b = layoutRepresentation{i}{j};
                pos = get_param(b, 'Position');
                if blockWidths(count+j) ~= -1
                    set_param(b, 'Position', pos + [0 0 pos(1)-pos(3)+blockWidths(count+j) 0]);
                end
            end
            count = count + length(layoutRepresentation{i});
        end
        
        %% Get desired column widths in a vector
        switch ColumnWidthMode
            case lower('MaxBlock')
                width = getMaxWidth(blocks); % Maximum width among all blocks
                colWidths = width*ones(1,length(layoutRepresentation));
            case lower('MaxColBlock')
                colWidths = zeros(1,length(layoutRepresentation));
                for i = 1:length(layoutRepresentation)
                    width = getMaxWidth(layoutRepresentation{i}); % Maximum width in ith column
                    colWidths(i) = width;
                end
            otherwise
                error('Unexpected parameter value.')
        end
        
        %% Place blocks in their respective columns
        % Height doesn't matter yet.
        columnLeft = 100; % Left-most point in the current column. Arbitrarily 100 for first column.
        for i = 1:length(layoutRepresentation)
            % For each column:
            
            columnWidth = colWidths(i); % Get width of current column

            alignBlocksInColumn(layoutRepresentation{i}, ColumnAlignment, columnLeft, columnWidth)
            
            % Advance column
            columnLeft = columnLeft + columnWidth + HorizSpacing;
        end
    else
        % Currently all layouts use columns so this shouldn't happen
        % If a new type of layout is used this should be changed appropriately.
        error('Unexpected result.')
    end
    
    %% Place names on bottom of blocks
    setNamePlacements(blocks)
    
    %% Set heights and vertical positions
    switch LayoutType
        case lower({'GraphPlot','Graphviz'})
            %% Set blocks to desired heights
            colOrder = 1:length(layoutRepresentation);
            pType = 'Outport';
            notPType = 'Inport';
            
            set_blocks_to_desired_heights(layoutRepresentation, colOrder, SubHeightMethod, AdjustHeightParams, notPType);
            
            %% Align and spread vertically
            align_and_spread_vertically(layoutRepresentation, colOrder, pType, VertSpacing)
            %%%Old approach
            % Move blocks with single inport/outport so their port is in line with
            % the source/destination port
            %layoutRepresentation = vertAlign(layoutRepresentation);
            % % layout = easyAlign(layout); %old method, still may be relevant since it attempts to cover more cases
            %layout = layout2(address, layout, systemBlocks); %call layout2 after
        case lower('DepthBased')
            %% Set variables determined by AlignmentType parameter
            switch AlignmentType
                case lower('Source')
                    colOrder = 1:length(layoutRepresentation);
                    pType = 'Inport';
                    notPType = 'Outport';
                case lower('Dest')
                    colOrder = length(layoutRepresentation):-1:1;
                    pType = 'Outport';
                    notPType = 'Inport';
                otherwise
                    error('Unexpected parameter.')
            end
            
            %% Set blocks to desired heights
            set_blocks_to_desired_heights(layoutRepresentation, colOrder, SubHeightMethod, AdjustHeightParams, notPType);
            
            %% Align and spread vertically
            align_and_spread_vertically(layoutRepresentation, colOrder, pType, VertSpacing);
        otherwise
            error('Unexpected parameter value.')
    end
    
    %% Handle Inports specially?
    switch InportRule
        case 'left-align'
            % Inports go on the left of the selected_blocks
            inports = find_in_blocks(blocks, 'BlockType', 'Inport');
            layoutRepresentation = justifyBlocks(system, layoutRepresentation, inports, 1);
        case 'none'
            % Skip
        otherwise
            error('Unexpected parameter value.')
    end
    
    %% Handle Outports specially?
    switch OutportRule
        case 'right-align'
            % Outports go on the left of the selected_blocks
            outports = find_in_blocks(blocks, 'BlockType', 'Outport');
            layoutRepresentation = justifyBlocks(system, layoutRepresentation, outports, 3);
        case 'none'
            % Skip
        otherwise
            error('Unexpected parameter value.')
    end
    
    %% Reposition portless blocks
    % Place blocks that have no ports in a line along a side of the system
    % determined by quadrants_map.
    
    % Get bounds to place blocks around
    bounds = bounds_of_sim_objects(blocks);
    
    % Get axis to be used when deciding which side to place blocks on
    switch PortlessRule
        case {'left', 'right', 'same_half_horizontal'}
            axis = 'x';
        case {'top', 'bottom', 'same_half_vertical'}
            axis = 'y';
        otherwise
            error('Unexpected parameter value.')
    end
    
    % Get map from sides to list of block handles
    sides_map = quadrants_map2sides_map(quadrants_map, axis);
    
    % Place blocks along a side of the system
    blocksToSide(bounds, blocksToIsolate, sides_map, PortlessSortRule);
    
    %% Do something with annotations
    
    % Get bounds to place annotations around
    bounds = bounds_of_sim_objects(setdiff(selected_objects, selected_annotations));
    
    % Move all annotations to the right of the system, or leave them
    switch NoteRule
        case 'on-right'
            placeAnnotationsRightOfBounds(bounds, selected_annotations)
        case 'none'
            % Do not layout annotations
        otherwise
            error('Unexpected parameter value.')
    end
    
    %% Show/hide block names 
    %(the initial layout may have inadvertently set it off)
    %TODO make it so that the names don't need to be found earlier on at least -
    %i.e. so this can be done whenever)
    set_shownames(showingNamesMap)
    
    %% Redraw lines
    blockLines = autolayout_lines(blockLines);
    
    %% Center objects on the original center
    % I.e. Shift selected_objects so that the center of their bounds is in
    % the same spot the center of the bounds was in to begin with.
    
    % Get new bounds of objects
    new_bounds = bounds_of_sim_objects(selected_objects);
    % Get center of original bounds
    orig_center = position_center(orig_bounds);
    % Get center of new bounds
    new_center = position_center(new_bounds);
    % Get offset between new and original center
    center_offset = orig_center - new_center;
    % Shift objects by the offset
    shift_sim_objects(selected_blocks, [], selected_annotations, center_offset);
    new_bounds = bounds_of_sim_objects(selected_objects); % Update new bounds. Can't simply add the offset since shifting isn't always precise
    
    %% Shift unselected objects to avoid overlap
    switch ShiftAll
        case lower('on')
            % Push remaining blocks and annotations in the system away from
            % the new bounds (if the bounds have expanded) or pull them
            % toward the new bounds (otherwise)
            
            % Get the objects that need to be shifted
            system_blocks = find_blocks_in_system(system)';
            non_layout_blocks = setdiff(system_blocks, selected_blocks);
            
            system_annotations = find_annotations_in_system(system)';
            non_layout_annotations = setdiff(system_annotations, selected_annotations);
            
            % Figure out how to shift blocks and annotations
            bound_shift = new_bounds - orig_bounds;
            adjustObjectsAroundLayout(non_layout_blocks, orig_bounds, bound_shift, 'block');
            adjustObjectsAroundLayout(non_layout_annotations, orig_bounds, bound_shift, 'annotation');
            % TODO - depending on input parameters redraw/shift/etc lines
            % affected by previous shifting
            %             non_layout_lines = get_block_lines(non_layout_blocks);
            %             adjustObjectsAroundLayout(non_layout_lines, orig_bounds, bound_shift, 'line');
            %             redraw_block_lines(blocks, 'autorouting', 'on')
            %             redraw_lines(getfullname(system), 'autorouting', 'on')
        case lower('off')
            % Shifting already done.
        otherwise
            error('Unexpected parameter value.')
    end
    
    %% Redraw lines
    blockLines = autolayout_lines(blockLines);
    
    %% Zoom on system
    % If it ends up zoomed out that means there is something near the
    % borders.
    if exist('system', 'var') == 1
        set_param(system, 'Zoomfactor', 'Fit to view');
    end
end

function shift_sim_objects(blocks, lines, annotations, offset)
    %
    
    % Note: Shifting blocks in Simulink also shifts the connected lines
    % (though not always in the desired manner).
    
    %%%The commented out approach fails if shift amount is rounded in
    %%%different ways for different blocks e.g. if instead of being moved
    %%%by 2.5, the source block of a line is moved by 0 and the dest block
    %%%of the line is moved by 5 -- maybe just round the offset right away
    %%%(add parameter to allow this rounding probably)
%     lineShift = {};
%     for i = 1:length(blocks)
%         ports = get_param(blocks(i), 'PortHandles');
%         oports = ports.Outport;
%         for j = 1:length(oports)
%             lh = get_param(oports(j), 'Line');
%             dstBlocks = get_param(lh, 'DstBlockHandle');
%             if all(ismember(dstBlocks, blocks))
%                 % Sources and destinations of lh are in blocks - it will be
%                 % appropriate to shift all points in lh by the same amount
%                 % as the sources and destinations.
%                 
%                 % Record info related to this line to help shift it
%                 % appropriately later.
%                 points = get_param(lh, 'Points');
%                 srcBlockPos = get_param(blocks(i), 'Position');
%                 dstBlocksPos = get_param(dstBlocks, 'Position');
%                 lineShift{end+1} = struct('line', lh, 'points', points, ...
%                     'srcBlock', blocks(i), 'srcBlockPos', srcBlockPos, ...
%                     'dstBlocks', dstBlocks, 'dstBlocksPos', dstBlocksPos);
%             end
%         end
%     end
    shiftBlocks(blocks, [offset, offset]); % Takes 1x4 vector
%     for i = 1:length(lineShift)
%         % Shift lines with the blocks that shifted.
%         realOffset = get_param(lineShift{i}.srcBlock, 'Position') - lineShift{i}.srcBlockPos;
%         
%         newPoints = lineShift{i}.points; % Initialize
%         for j = 1:length(lineShift{i}.points)
%             newPoints(j,:) = lineShift{i}.points(j,:) + realOffset(1:2);
%         end
%         set_param(lineShift{i}.line, 'Points', newPoints);
%     end
    
    shiftAnnotations(annotations, [offset, offset]); % Takes 1x4 vector
    shiftLines(lines, offset); % Takes 1x2 vector
end

function adjustObjectsAroundLayout(objects, origBounds, boundShift, type)
    % objects are all of the given type
    %
    % Move objects with the shift in bounds between original and new
    % layout. The approach taken aims to keep objects in the same position
    % relative to the original layout. This approach will not handle
    % objects that were within the original bounds well, however, this is
    % not considered a big problem because of the degree of difficulty in
    % appropriately handling these cases even manually and further it's
    % also a bizarre case that should generally be avoidable. If it turns
    % out to need to be handled, a simple approach is to pick some
    % direction to shift the objects that were within the original bounds
    % and to do so as well as potentially increase the overall shift amount
    % in that direction accordingly.
    %
    % Update: negative bound_shifts will be ignored. Better to leave free
    % space than to disturb the other blocks.
    
    switch type
        case 'block'
            getBounds = @blockBounds;
            shiftObjects = @shiftBlocks;
        case 'line'
            getBounds = @lineBounds;
            shiftObjects = @shiftLines;
        case 'annotation'
            getBounds = @annotationBounds;
            shiftObjects = @shiftAnnotations;
        otherwise
            error('Unexpected object type.')
    end
    
    for i = 1:length(objects)
        object = objects(i);
        
        % Get bounds of the block
        myBounds = getBounds(object);
        
        myShift = [0 0 0 0]; % Desired shift for current object
        
        idx = 1; % Left
        if myBounds(idx) < origBounds(idx) && boundShift(idx) > 0
            myShift = myShift + [boundShift(idx) 0 boundShift(idx) 0];
        end
        idx = 2; % Top
        if myBounds(idx) < origBounds(idx) && boundShift(idx) > 0
            myShift = myShift + [0 boundShift(idx) 0 boundShift(idx)];
        end
        idx = 3; % Right
        if myBounds(idx) > origBounds(idx) && boundShift(idx) > 0
            myShift = myShift + [boundShift(idx) 0 boundShift(idx) 0];
        end
        idx = 4; % Bottom
        if myBounds(idx) > origBounds(idx) && boundShift(idx) > 0
            myShift = myShift + [0 boundShift(idx) 0 boundShift(idx)];
        end
        
        shiftObjects({object}, myShift);
    end
end

function blocks = find_blocks_in_system(system)
    blocks = find_system(system, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'block', 'Parent', getfullname(system));
end
function annotations = find_annotations_in_system(system)
    annotations = find_system(system, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'annotation');
end

function setHeights(layoutRepresentation, colOrder, subsMethod, AdjustHeightParams, connType, firstPass)
    
    % TODO Current implementation expands blocks down regardless of
    % input parameters - fix that - though it doesn't really matter
    % since alignment will occur still.
    
    %
    portParamsIdx = find(strcmpi('PortParams', AdjustHeightParams));
    if isempty(portParamsIdx)
        % Add 'PortParams' with default value
        AdjustHeightParams{end+1} = 'PortParams';
        AdjustHeightParams{end+1} = {};
        portParamsIdx = find(strcmpi('PortParams', AdjustHeightParams));
        assert(~isempty(portParamsIdx))
    end
    portParamsVal = AdjustHeightParams{portParamsIdx(1)+1};
    
    %
    connTypeIdx = find(strcmpi('ConnectionType', portParamsVal));
    if isempty(connTypeIdx)
        % Add 'ConnectionType' with given value
        portParamsVal{end+1} = 'ConnectionType';
        portParamsVal{end+1} = connType;
    end % else: Do nothing, if a user explicitly chose a ConnectionType.
    
    % Set base method (will be updated during the loop below for certain
    % blocks).
    methodIdx = find(strcmpi('Method', portParamsVal));
    if firstPass
        firstPassMethod = 'Compact';
    end
    %subsMethod = 'SumMax';
    if isempty(methodIdx)
        callerMethod = 'Compact'; % Because Compact is default for the adjustHeight function.
        
        % Add 'Method' parameter.
        portParamsVal{end+1} = 'Method';
        portParamsVal{end+1} = [];
    else % The caller set a method.
        callerMethod = portParamsVal{methodIdx(1)+1};
    end
    % Update methodIdx.
    methodIdx = find(strcmpi('Method', portParamsVal));
    
    %
    for i = colOrder(length(colOrder):-1:1) % Reverse column order
        for j = 1:length(layoutRepresentation{i})
            b = layoutRepresentation{i}{j}; % Get current block
            
            pos = get_param(b, 'Position');
            
            % Set Method parameter.
            % (Conditions here are based on what has seemed best in testing and
            % could probably be improved.)
            if firstPass
                portParamsVal{methodIdx(1)+1} = firstPassMethod;
            elseif strcmp(get_param(b, 'BlockType'), 'SubSystem')
                portParamsVal{methodIdx(1)+1} = subsMethod;
            else
                portParamsVal{methodIdx(1)+1} = callerMethod;
            end
            
            AdjustHeightParams{portParamsIdx(1)+1} = portParamsVal;
            
            [~, adj_position] = adjustHeight(b, 'PerformOperation', 'off', ...
                AdjustHeightParams{:});
            
            % TODO use the following parameter in the call above:
            %   'ConnectedBlocks', connBlocks,
            % connBlocks should be either the blocks that connect
            % to the current block and are 1 column right or left
            % depending on AlignmentType
            % If going 1 column over would exit bounds or if there
            % are no connBlocks then just get the compactHeight
            
            desiredHeight = adj_position(4) - adj_position(2);
            
            set_param(b, 'Position', pos + [0, 0, 0, -pos(4)+pos(2)+desiredHeight]);
        end
    end
end

function type = default_layout_type()
    %
    
    type = getAutoLayoutConfig('layout_type', 'default');
    
    if strcmp(type, 'default')
        
        % Check if MATLAB version is R2015b or newer (i.e. greater-or-equal to 2015b)
        ver = version('-release');
        ge2015b = str2num(ver(1:4)) > 2015 || strcmp(ver(1:5),'2015b'); % true if version is 2015b or later
        if ge2015b
            type = 'GraphPlot';
        else
            type = 'DepthBased';
        end
        type = lower(type);
    end % else type is already decided
end

function lines = get_block_lines(blocks)
    lines = [];
    for k = 1:length(blocks)
        b = blocks(k);
        phs = getPorts(b,'All');
        for i = 1:length(phs)
            lh = get_param(phs(i), 'Line');
            if lh ~= -1
                lines(end+1) = lh;
            end
        end
    end
    
    lines = unique(lines); % No repeats
end

function set_blocks_to_desired_heights(layoutRepresentation, colOrder, SubHeightMethod, AdjustHeightParams, notPType)
    %
    
    % Actual position vertically doesn't matter yet.
    firstPass = true;
    setHeights(layoutRepresentation, colOrder, SubHeightMethod, AdjustHeightParams, notPType, firstPass); % First pass to set to base heights using Compact Method
    firstPass = false;
    % Second pass to determine new heights based on previous Compact
    % ones -- this is redundant if the method for getting heights is the
    % same as is used for the first pass
    setHeights(layoutRepresentation, colOrder, SubHeightMethod, AdjustHeightParams, notPType, firstPass);
end

function align_and_spread_vertically(layoutRepresentation, colOrder, pType, VertSpacing)
    %
    
    % Vertical position matters now.
    for i = colOrder
        % For each column:
        
        % Align blocks (make diagram cleaner and provides a means of
        % ordering when determining heights)
        [ports, ~] = alignBlocks(layoutRepresentation{i}, 'PortType', pType);
        
        % Get a desired ordering for which blocks are higher
        % First sort by port heights
        [orderedPorts, ~] = sortPortsByTop(ports);
        orderedParents = inputToNumeric(get_param(orderedPorts, 'Parent'));
        % But not all blocks will have a port, so add the blocks that
        % aren't accounted for
        orderedColumn = [orderedParents; setdiff(inputToNumeric(layoutRepresentation{i}), orderedParents)'];
        
        % Alternate ordering approach
        %orderedColumn = sortBlocksByTop(layoutRepresentation{i});
        
        % Spread out blocks that overlap vertically
        for j = 1:length(orderedColumn)
            %
            
            b = orderedColumn(j);
            
            % Detect any remaining blocks in current column overlapping
            % current block
            [~, overlaps] = detectOverlaps(b,orderedColumn(j+1:end), ...
                'OverlapType', 'Vertical', 'VirtualBounds', [0 0 0 VertSpacing]);
            
            % If there is any overlap, move all overlappings blocks below b
            for over = overlaps
                
                % TODO When setting buffer use an input option to determine
                % whether or not to increase the buffer based on parameters
                % of b showing below b
                buffer = VertSpacing;
                moveBelow(b,over,buffer);
            end
        end
    end
end

function cols = getImpactDepths(blocks)
    % Set default depths - default is 0.
    cols = zeros(1, length(blocks));
end