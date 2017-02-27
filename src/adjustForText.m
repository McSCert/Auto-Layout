function layout = adjustForText(layout)
%ADJUSTFORTEXT Adjusts blockInfo to resize blocks to fit their text without
%   disturbing relative layout.
%
%   Inputs:
%       blocksInfo  As returned by getLayout.
%       layout      As returned by getRelativeLayout.
%
%   Output:
%       N/A

    for j = 1:size(layout.grid,2) % for each column
        largestX = 0; % This is the minimum coordinate in Simulink
        for i = 1:layout.colLengths(j) % for each non empty row in column
            [layout.grid{i,j}.position, xDisplace] = dimIncreaseForText(...
                layout.grid{i,j}.fullname,layout.grid{i,j}.position,'right'); % Returns amount to move other blocks
            if xDisplace > largestX
                largestX = xDisplace;
            end
        end

        layout = horzAdjustBlocks(layout, j, largestX);
    end
end