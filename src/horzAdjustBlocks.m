function layout = horzAdjustBlocks(layout, col, x)
%HORZADJUSTBLOCKS Horizontally moves blocks in layout to the right of 
%   column col right by x
%
%   Inputs:
%       layout          As returned by getRelativeLayout.
%       col             Column number. Blocks in this column of
%                       layout.grid and to its left will not be moved.
%       x               Number of pixels to move blocks.
%
%   Outputs:
%       layout      With modified position information.

    for j = col + 1:size(layout.grid,2)
        for i = 1:layout.colLengths(j)
            pos = layout.grid{i,j}.position;
            layout.grid{i,j}.position = [pos(1) + x, pos(2), pos(3) + x, pos(4)];
        end
    end
end