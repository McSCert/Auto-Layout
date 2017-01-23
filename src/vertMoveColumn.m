function vertMoveColumn(blocksMatrix, colLengths, row, col, y)
% Vertically moves blocks in col and below row in blocksMatrix downward by y

    j = col;
    for i = row + 1:colLengths(j)
        pos = get_param(char(blocksMatrix{i, j}),'Position');
        set_param(char(blocksMatrix{i, j}), 'Position', ...
            [pos(1), pos(2) + y, pos(3), pos(4) + y]);
    end
end