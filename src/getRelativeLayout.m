function [layout] = getRelativeLayout(blocksInfo)
%GETRELATIVELAYOUT Finds the relative layout of the blocks within a grid.
%
%   Input:
%       blocksInfo  As returned by getLayout.
%
%   Output:
%       layout      Struct describing the layout of blocks in blocks info.
%                   layout.grid is organized such that all blocks in
%                   layout.grid{i,j} with the same j have the same x 
%                   coordinate at their centre and such that the top 
%                   position decreases with increase in i.
%                   layout.colLengths is created such that
%                   layout.colLengths{j} is the number of blocks in the
%                   grid with that j value (i.e. number of blocks in that
%                   column).
%                   The maximum j for layout.grid{i,j} is
%                   size(layout.grid,2).
%                   If (i <= colLengths(j)) then a block will be returned.
%                   If (colLengths(j) < i <= size(blocksMatrix,1)) 
%                   then [] will be returned.

    % Ordering is based on the horizontal midpoints of blocks. The justification 
    % of justifyBlocks assumes this and needs to be updated if it changes.
	[midXPositions, ~] = rectCenter({blocksInfo.position});
	midXPositions = sort(unique(midXPositions));

	% Get column lengths and make an unsorted blocksMatrix
	colLengths = zeros(1,length(midXPositions));
	for i = 1:length(blocksInfo)
	    [midXPos, ~] = rectCenter({blocksInfo(i).position});
	    col = isWhere(midXPos, midXPositions);
	    colLengths(col) = colLengths(col) + 1;
% 	    grid{colLengths(col), col} = struct('fullname',{blocksInfo(i).fullname},'position',{blocksInfo(i).position});
        grid{colLengths(col), col} = blocksInfo(i);
    end

    % Sort blocksMatrix
% 	grid = sortBlocksMatrix(grid, colLengths);
    grid = sortRelativeLayout(grid, colLengths);
    
    layout = struct('grid', {grid}, 'colLengths', {colLengths});
end

function i = isWhere(val, mat1d)
% Returns position of value, val, in 1-D matrix, mat1d
% Returns 0 if val not found in mat1d
	for i = 1:length(mat1d)
	    if val == mat1d(i)
	        return
	    end
	end
	i = 0;
end