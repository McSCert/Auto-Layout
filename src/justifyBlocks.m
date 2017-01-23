function [blocksMatrix, colLengths] = justifyBlocks(address, blocksMatrix, colLengths, blocks, justifyType)
% Pushes blocks either to far right or left.
% If doing so would cause line crossings then affected blocks won't be
% moved.
%
% justifyType:   1 - left justify
%                3 - right justify

    for i = 1:length(blocks)
        [row,col] = findInBlocksMatrix(blocksMatrix, colLengths, blocks(i));
        if ~alreadyFullyJustified(blocksMatrix, col, justifyType)
            if ~blocksInTheWay(blocksMatrix, colLengths, row, col, justifyType) && ~linesInTheWay(address, blocksMatrix, row, col, justifyType)
                % Nothing in the way of justifying blocks(i)

                if justifyType == 1 % (justify left)
                    newCol = 1;
                elseif justifyType == 3 % (justify right)
                    newCol = size(blocksMatrix,2);
                end
                [blocksMatrix, colLengths] = changeBlockColumn(blocksMatrix, colLengths, row, col, newCol);
            end
        end
    end
end

function [blocksMatrix, colLengths] = changeBlockColumn(blocksMatrix, colLengths, oldRow, oldCol, newCol)
% Removes block at blocksMatrix{oldRow, oldCol} from its column and adds it into newCol

    % Move blocksMatrix{oldRow,oldCol} (visually)
    pos = get_param(char(blocksMatrix{oldRow, oldCol}), 'Position');
    x = getBlockSidePositions(blocksMatrix{1, newCol}, 5) - getBlockSidePositions(blocksMatrix{oldRow, oldCol}, 5);
    set_param(char(blocksMatrix{oldRow, oldCol}), 'Position', [pos(1) + x, pos(2), pos(3) + x, pos(4)]);

    % Fix blocksMatrix (re-placing blocksMatrix{oldRow,oldCol} within the data structure)
    blocksMatrix{colLengths(newCol) + 1, newCol} = blocksMatrix{oldRow, oldCol};
    for i = oldRow:colLengths(oldCol) - 1
        blocksMatrix{i,oldCol} = blocksMatrix{i+1,oldCol};
    end
    blocksMatrix{colLengths(oldCol), oldCol} = [];
    colLengths(newCol) = colLengths(newCol) + 1;
    colLengths(oldCol) = colLengths(oldCol) - 1;

    blocksMatrix = sortBlocksMatrix(blocksMatrix, colLengths);
end

function linesInTheWay = linesInTheWay(address, blocksMatrix, row, col, jT)
% Checks if any line crossings will result from the indicated justification
% of block. Considers a line "in the way" if a box formed around the line
% would cross.

    linesInTheWay = false;

    pos = get_param(char(blocksMatrix{row,col}), 'Position');
    newCol = (jT == 1) * 1 + (jT == 3) * size(blocksMatrix, 2);
    x = getBlockSidePositions(blocksMatrix{1, newCol}, 5) ...
        - getBlockSidePositions(blocksMatrix{row, col} ,5);

    systemLines = find_system(address, 'SearchDepth', 1, 'findall', 'on', 'Type', 'Line');
    for i = 1:length(systemLines)
        points = get_param(systemLines(i), 'Points');
        point1 = points(1,:);
        
        for j = 2:length(points)
            point2 = points(j,:);

            if point1(1) == point2(1) || point1(2) == point2(2)
                % if vertical segment or horizontal segment
                if isRangeOverlap(point1(2), point2(2), pos(4), pos(2))
                    % vertical components overlap
                    if isRangeOverlap(point1(1), point2(1), pos(jT), pos(jT) + x)
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
                if isRangeOverlap(point1(2), point2(2), pos(4), pos(2))
                    % vertical components overlap
                    if isRangeOverlap(point1(1), point2(1), pos(jT), pos(jT) + x)
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

function isRangeOverlap = isRangeOverlap(range1Val1, range1Val2, range2Val1, range2Val2)
% The 1st 2 arguments form the 1st range,
% while the 2nd 2 form the 2nd range
% Returns whether or not the union of the two ranges have any intersection

    max1 = max(range1Val1, range1Val2);
    min1 = min(range1Val1, range1Val2);
    max2 = max(range2Val1, range2Val2);
    min2 = min(range2Val1, range2Val2);
    isRangeOverlap = (min2 <= max1 && max1 <= max2) || (min1 <= max2 && max2 <= max1);
end

function blocksInTheWay = blocksInTheWay(blocksMatrix, colLengths, row, col, jT)
% Determine whether or not any blocks are in the way of justifying 
% the block at blocksMatrix{row,col}
%   Considers a block "in the way" if 
%       it's in a column on the side of justification from col
%       and the top to bottom ranges of the 2 blocks overlap

    pos1 = get_param(char(blocksMatrix{row,col}), 'Position');

    if jT == 1 % (justify left)
        columns = 1:col-1;
    elseif jT == 3 % (justify right)
        columns = col + 1:size(blocksMatrix,2);
    end
    blocksInTheWay = false;
    for j = columns % for each column on the side of justification col
        for i = 1:colLengths(j) % for each non empty row in a given column
            pos2 = get_param(char(blocksMatrix{i,j}), 'Position');
            if isRangeOverlap(pos1(4), pos1(2), pos2(4), pos2(2))
                blocksInTheWay = true;
                return
            end
        end
    end
end

function [row,col] = findInBlocksMatrix(blocksMatrix, colLengths, block)
% Searches for block in blocksMatrix and returns its indices
% Returns row = [] and col = [] if block isn't found
    row = []; col = [];
    for j = 1:size(blocksMatrix,2) % for each column
        for i = 1:colLengths(j) % for each non empty row in column
            if strcmp(blocksMatrix{i,j}, block)
                row = i; col = j;
            end
        end
    end
end

function alreadyFullyJustified = alreadyFullyJustified(blocksMatrix, col, jT)
    alreadyFullyJustified = (jT == 1 && col == 1) ...
        || (jT == 3 && col == size(blocksMatrix, 2));
end