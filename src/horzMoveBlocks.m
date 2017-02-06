function horzMoveBlocks(blocksMatrix, colLengths, col, x)
%HORZMOVEBLOCKS Horizontally moves blocks in blocksMatrix to the right of 
%   column col right by x
%
%   Inputs:
%       blocksMatrix    From result of getOrderMatrix
%       colLengths      From result of getOrderMatrix
%       col             Column number. Blocks in this column of
%                       blocksMatrix and to its left will not be moved.
%       x               Number of pixels to move blocks.
%
%   Outputs:
%       N/A

    for j = col + 1:size(blocksMatrix,2)
        for i = 1:colLengths(j)
            pos = get_param(char(blocksMatrix{i,j}), 'Position');
            set_param(char(blocksMatrix{i,j}), 'Position', [pos(1) + x, pos(2), pos(3) + x, pos(4)]);
        end
    end
end