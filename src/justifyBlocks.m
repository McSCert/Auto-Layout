function layout = justifyBlocks(address, layout, blocks, justifyType)
    % JUSTIFYBLOCKS Align inports to the left edge of the layout if possible or
    % align outports to the right edge of the layout if possible.
    %
    %   Inputs:
    %       address         Simulink system name or path.
    %       layout          As returned by find_relative_layout.
    %       blocks          List of blocks to be affected by the justification.
    %       justifyType     How the blocks will be aligned: left justified (1) or
    %                       right justified (3) (The numbers correspond with
    %                       the position parameter of blocks i.e. a block with
    %                       position [1 2 3 4] has a left position 1 and a
    %                       right position of 3).
    %
    %   Output:
    %       layout          With modified position information.
    %
    % Pushes blocks either too far right or left.
    % If doing so would cause line crossings then affected blocks won't be moved.
    
    
    for i = 1:length(blocks)
        [row,col] = findInLayout(layout, getfullname(blocks(i)));
        if ~alreadyFullyJustified(layout, col, justifyType)
            if ~blocksInTheWay(layout, row, col, justifyType) ...
                    && ~linesInTheWay(address, layout, row, col, justifyType)
                % Nothing in the way of justifying blocks(i)
                
                if justifyType == 1 % (justify left)
                    newCol = 1;
                elseif justifyType == 3 % (justify right)
                    newCol = length(layout);
                end
                layout = changeBlockColumn(layout, row, col, newCol);
            end
        end
    end
end

function layout = changeBlockColumn(layout, oldRow, oldCol, newCol)
    % CHANGEBLOCKCOLUMN Remove block at layout{oldCol}{oldRow} from its
    % column and adds it into newCol.
    
    % Move layout{oldCol}{oldRow} (visually)
    pos = get_param(layout{oldCol}{oldRow}, 'Position');
    x = getBlockSidePositions({layout{newCol}{1}}, 5) - getBlockSidePositions({layout{oldCol}{oldRow}}, 5);
    set_param(layout{oldCol}{oldRow}, 'Position', pos + [x, 0, x, 0]);
    
    % Update layout
    layout = updateLayout(layout);
end

function linesInTheWay = linesInTheWay(address, layout, row, col, jT)
    % LINESINTHEWAY Check if any line crossings will result from the indicated justification
    % of block. Considers a line "in the way" if a box formed around the line
    % would cross.
    
    linesInTheWay = false;
    
    pos = get_param(layout{col}{row}, 'Position');
    newCol = (jT == 1) * 1 + (jT == 3) * length(layout);
    x = getBlockSidePositions({layout{newCol}{1}}, 5) ...
        - getBlockSidePositions({layout{col}{row}}, 5);
    
    systemLines = find_system(address, 'SearchDepth', 1, 'findall', 'on', 'Type', 'Line');
    for i = 1:length(systemLines)
        points = get_param(systemLines(i), 'Points');
        point1 = points(1,:);
        
        for j = 2:length(points)
            point2 = points(j,:);
            
            if point1(1) == point2(1) || point1(2) == point2(2)
                % if vertical segment or horizontal segment
                if is_range_overlap_wrapper(point1(2), point2(2), pos(4), pos(2))
                    % vertical components overlap
                    if is_range_overlap_wrapper(point1(1), point2(1), pos(jT), pos(jT) + x)
                        % horizontal components overlap and is left justify
                        linesInTheWay = true;
                        return
                    end
                end
            else
                % if segment is on an angle
                % uses same method as above,
                % if this returns true it will not always mean there would be a crossing
                % if it returns false then there cannot be a crossing
                if is_range_overlap_wrapper(point1(2), point2(2), pos(4), pos(2))
                    % vertical components overlap
                    if is_range_overlap_wrapper(point1(1), point2(1), pos(jT), pos(jT) + x)
                        % horizontal components overlap and is left justify
                        linesInTheWay = true;
                        return
                    end
                end
            end
            point1 = point2;
        end
    end
end

function bool = is_range_overlap_wrapper(range1Val1, range1Val2, range2Val1, range2Val2)
    % IS_RANGE_OVERLAP_WRAPPER Detect whether or not the union of the two ranges
    % have any intersection. Acts as a wrapper for a similar external function.
    %
    % The 1st two arguments form the 1st range, while the 2nd two form the 2nd range.
    
    max1 = max(range1Val1, range1Val2);
    min1 = min(range1Val1, range1Val2);
    max2 = max(range2Val1, range2Val2);
    min2 = min(range2Val1, range2Val2);
    
    bool = isRangeOverlap([min1, max1], [min2, max2]);
end

function blocksInTheWay = blocksInTheWay(layout, row, col, jT)
    % BLOCKSINTHEWAY Determine whether or not any blocks are in the way of
    % justifying the block at layout{col}{row}. Considers a block "in
    % the way" if:
    %   it's in a column on the side of justification from col and the top
    %   to bottom ranges of the 2 blocks overlap
    
    pos1 = get_param(layout{col}{row}, 'Position');
    
    if jT == 1 % (justify left)
        columns = 1:col-1;
    elseif jT == 3 % (justify right)
        columns = col + 1:length(layout);
    end
    blocksInTheWay = false;
    for j = columns % for each column on the side of justification col
        for i = 1:length(layout{j}) % for each non empty row in a given column
            pos2 = get_param(layout{j}{i}, 'Position');
            if is_range_overlap_wrapper(pos1(4), pos1(2), pos2(4), pos2(2))
                blocksInTheWay = true;
                return
            end
        end
    end
end

function [row,col] = findInLayout(layout, block)
    % FINDINLAYOUT Searches for block in layout and returns its indices.
    % Returns row = [] and col = [] if block isn't found.
    row = []; col = [];
    for j = 1:length(layout) % for each column
        for i = 1:length(layout{j}) % for each non empty row in column
            if strcmp(getfullname(layout{j}{i}), block)
                row = i; col = j;
            end
        end
    end
end

function alreadyFullyJustified = alreadyFullyJustified(layout, col, jT)
    alreadyFullyJustified = (jT == 1 && col == 1) || ...
                            (jT == 3 && col == length(layout));
end