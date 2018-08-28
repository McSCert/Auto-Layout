function vertMoveColumn(layout, row, col, y)
    % VERTMOVECOLUMN Vertically move blocks in col and below row in layout
    % downward by y.
    %
    % Inputs:
    %   layout  Cell array of columns. Columns are cell arrays of blocks.
    %   row     Row number, below which blocks will be moved.
    %   col     Column number, in whihch blocks will be moved.
    %   y       Number of pixels to move blocks down.
    %
    % Outputs:
    % 	layout  With modified position information.
    
    for i = row + 1:length(layout{col})
        pos = get_param(layout{col}{i}, 'Position');
        set_param(layout{col}{i}, 'Position', pos + [0 y 0 y]);
    end
end