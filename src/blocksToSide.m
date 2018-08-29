function blocksToSide(bounds, blocks, sides_map, sort_rule, varargin)
    % BLOCKSTOSIDE Reposition blocks to a side of some bounds. Organize
    % blocks into groups on the designated sides. 
    %
    % Inputs:
    %   bounds          Bounds to place given blocks around. Given as a 1x4
    %                   vector: [left top right bottom].
    %   blocks          A list (cell array or vector) of blocks (fullnames
    %                   or handles).
    %   sides_map       Map from sides {'left', 'right', 'top', 'bottom'}
    %                   to vectors of block handles to place on that side.
    %   sort_rule       Determines the way in which blocks will be placed
    %                   along a side. 
    %                       'blocktype' - blocks will be grouped by their
    %                           BlockType parameter
    %                       'masktype_blocktype' - blocks will be grouped
    %                           for each unique MaskType-BlockType pair
    %                       'none' - no grouping is done
    %   varargin        Parameter-Value pairs as detailed below.
    %
    % Parameter-Value pairs:
    %   Parameter: 'VerticalSpacing' - Space to leave between blocks
    %       vertically.
    %   Value:  Any number. Default: 20.
    %   Parameter: 'HorizontalSpacing' - Space to leave between blocks
    %       horizontally.
    %   Value:  Any number. Default: 20.
    %
    % Outputs:
    %   N/A
    %
    
    %% Input Handling
    
    % Handle parameter-value pairs
    VerticalSpacing = 20;
    HorizontalSpacing = 20;
    assert(mod(length(varargin),2) == 0, 'Even number of varargin arguments expected.')
    for i = 1:2:length(varargin)
        param = lower(varargin{i});
        value = lower(varargin{i+1});
        
        switch param
            case 'VerticalSpacing'
                assert(isnumeric(value), ...
                    ['Unexpected value for ' param ' parameter.'])
                VerticalSpacing = value;
            case 'HorizontalSpacing'
                assert(isnumeric(value), ...
                    ['Unexpected value for ' param ' parameter.'])
                HorizontalSpacing = value;
            otherwise
                error('Invalid parameter.')
        end
    end
    
    % Make blocks a vector of handles
    blocks = inputToNumeric(blocks);
    
    %% Sort blocks
    if strcmp(sort_rule, 'none')
        categorizedBlocks = {blocks};
    else
        categorizedBlocks = categorizeBlocks(blocks, sort_rule);
    end
    
    %% Do the actual function requirements...
    sides = {'left','top','right','bottom'};
    for i = 1:length(sides)
        putBlocksOnSide(categorizedBlocks, sides_map, bounds, VerticalSpacing, HorizontalSpacing, sides{i});
    end
end

function [categorizedBlocks, categories] = categorizeBlocks(blocks, categorize_rule, varargin)
    % CATEGORIZEBLOCKS Categorize blocks by the block parameter(s)
    % designated by categorize_rule.
    %
    % Input:
    %   blocks              Vector of block handles.
    %   categorize_rule     Designates the types of categories to put
    %                       blocks into.
    %   varargin{1}         Cell array of categories that must be included
    %                       in the output. Also dictates the order of the
    %                       categories. Default: {}.
    %
    % Output:
    %   categorizedBlocks   Cell array of vectors of block handles. Each
    %                       element corresponds with the element of the
    %                       same index in categories.
    %   categories          Cell array of category names.
    %
    
    % Init categories: a cell array of the different categories to put
    % blocks in i.e. if sorting on block type there might be a 'SubSystem'
    % or an 'Inport' category
    if isempty(varargin)
        categories = {};
    else
        categories = varargin{1};
    end
    
    categorizedBlocks = cell(1, length(categories));
    
    for i = 1:length(blocks)
        cat = getBlockCategory(blocks(i), categorize_rule);
        cat_idx = find(strcmp(cat, categories), 1, 'first');
        if isempty(cat_idx) 
            % the block's value for sort_rule is new to categories
            
            % Record category.
            categories{end+1} = cat;
            % Add first block to category.
            categorizedBlocks{end+1} = blocks(i);
        else
            categorizedBlocks{cat_idx}(end+1) = blocks(i);
        end
    end
end

function cat = getBlockCategory(block,sort_rule)
    if strcmp(sort_rule, 'blocktype')
        cat = get_param(block,sort_rule);
    elseif strcmp(sort_rule, 'masktype_blocktype')
        params = strsplit('masktype_blocktype','_');
        cat = [get_param(block,params{1}), '_', get_param(block,params{2})];
    end
end

function putBlocksOnSide(cat_blocks, sides_map, bounds, vertSpace, horzSpace, side)
    %
    
    % Variables named as though blocks would be placed in rows (e.g. of
    % chairs) facing the bounds (e.g. a stage)
    
    leftBound = bounds(1);
    topBound = bounds(2);
    rightBound = bounds(3);
    bottomBound = bounds(4);
    
    % Blocks are placed from rowStart toward rowEnd
    % First row is placed parallel with boundFront
    % Blocks in a within a common row are placed spaceBetweenBlocks apart
    % The front of rows are placed spaceBetweenRows away from the furthest back point of
    %   the row in front.
    switch side
        case {'left', 'right'}
            rowStart = topBound;
            rowEnd = bottomBound;
            switch side
                case 'left'
                    boundFront = leftBound;
                    spaceBetweenBlocks = vertSpace;
                    spaceBetweenRows = - horzSpace; % Placing blocks on left, so need to move negatively on x-axis
                case 'right'
                    boundFront = rightBound;
                    spaceBetweenBlocks = vertSpace;
                    spaceBetweenRows = horzSpace; 
            end
        case {'top', 'bottom'}
            rowStart = leftBound;
            rowEnd = rightBound;
            switch side
                case 'top'
                    boundFront = topBound;
                    spaceBetweenBlocks = horzSpace;
                    spaceBetweenRows = - vertSpace; % Placing blocks on top, so need to move negatively on y-axis
                case 'bottom'
                    boundFront = bottomBound;
                    spaceBetweenBlocks = horzSpace;
                    spaceBetweenRows = vertSpace;
            end
        otherwise
            error('Unexpected argument value.')
    end
    
    % rowFront:
    % represents the closest position to the bounds
    % e.g. when side is 'left' this is the right-most point of all blocks
    % in the current row
    %
    % initialize a short distance from the bounds
    rowFront = boundFront + spaceBetweenRows;
    
    % nextRowFront:
    % keeps track of where the next row will start when the current row
    % ends
    %
    % initialize to arbitrary default;
    nextRowFront = rowFront;
    
    % nextBlockStart:
    % represents a starting point for the next block to be placed in the
    % same row
    % i.e. when side is 'left' or 'right' blocks are placed from the top to
    % the bottom and the "start" of the block is the top-most point of the
    % next block for that row; when side is 'top' or 'bottom' it's the
    % left-most
    %
    % initialize the first block to be placed at the start of the row
    nextBlockStart = rowStart;
    
    for i = 1:length(cat_blocks) % For each category of block
        
        % Place new categories in a new row:
        % Advance row unless nothing placed in current row
        if nextBlockStart ~= rowStart
            % New row
            rowFront = nextRowFront;
            nextBlockStart = rowStart;
        end % else: nextBlockStart == rowStart; only occurs if nothing advanced nextBlockStart in current row which implies no block is in the current row
        
        %
        for j = 1:length(cat_blocks{i})
            block = cat_blocks{i}(j);
            if strcmp(sides_map(block), side) % otherwise block is not to be placed on this side of the bounds
                pos = get_param(block, 'Position');
                width = pos(3) - pos(1);
                height = pos(4) - pos(2);
                
                % Distance of a block parallel with the front of the bounds
                %   is blockLength; e.g. when side is 'left' or 'right'
                %   blockLength is the height of the block.
                % Similarly, distance perpendicular is blockDepth.
                switch side
                    case {'left', 'right'}
                        blockLength = height;
                    case {'top', 'bottom'}
                        blockLength = width;
                    otherwise
                        error('Unexpected argument value.')
                end
                
                if nextBlockStart ~= rowStart && nextBlockStart + blockLength > rowEnd % Not the start of a row and won't exceed bounds of the row
                    % New row
                    rowFront = nextRowFront;
                    nextBlockStart = rowStart;
                end
                
                % Get positions of current block
                switch side
                    case 'left'
                        right = rowFront;
                        top = nextBlockStart;
                        
                        left = right - width;
                        rowBack = left;
                        bottom = top + height;
                    case 'right'
                        left = rowFront;
                        top = nextBlockStart;
                        
                        right = left + width;
                        rowBack = right;
                        bottom = top + height;
                    case 'top'
                        bottom = rowFront;
                        left = nextBlockStart;
                        
                        top = bottom - height;
                        rowBack = top;
                        right = left + width;
                    case 'bottom'
                        top = rowFront;
                        left = nextBlockStart;
                        
                        bottom = top + height;
                        rowBack = bottom;
                        right = left + width;
                    otherwise
                        error('Unexpected argument value.')
                end
                set_param(block, 'Position', [left top right bottom]);
                
                % Update next block start point and next row front (if
                % changed)
                nextBlockStart = nextBlockStart + width + spaceBetweenBlocks;
                
                switch side
                    case {'left','top'} % additional rows placed further negative in Simulink coordinate system
                        nextRowFront = min(nextRowFront, rowBack + spaceBetweenRows);
                    case {'right','bottom'}
                        nextRowFront = max(nextRowFront, rowBack + spaceBetweenRows);
                    otherwise
                        error('Unexpected argument value.')
                end
            end % else skip, block doesn't go on this side
        end
    end
end
