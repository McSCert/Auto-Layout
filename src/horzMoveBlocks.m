function horzMoveBlocks(blocksMatrix, colLengths, col, x)
% Horizontally moves blocks in blocksMatrix to the right of column, col, right by x

    for j = col + 1:size(blocksMatrix,2)
        for i = 1:colLengths(j)
            pos = get_param(char(blocksMatrix{i,j}), 'Position');
            set_param(char(blocksMatrix{i,j}), 'Position', [pos(1) + x, pos(2), pos(3) + x, pos(4)]);
        end
    end
end