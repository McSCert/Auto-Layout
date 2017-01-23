function [ blocksMatrix colLengths ] = getOrderMatrix(systemBlocks)
% Orders blocks on a given level of a system in a matrix according to
% position
%   blocksMatrix is organized such that all blocks in blocksMatrix{i,j}, 
%   with the same j, have the same x coordinate at their centre
%   and such that the top position decreases with increase in i
%   
%   The maximum j for blocksMatrix{i,j} is size(blocksMatrix,2)
%   If (i <= colLengths(j)) then a block will be returned
%   If (colLengths(j) < i <= size(blocksMatrix,1)) then [] will be returned

% For future, consider making a BlocksMatrix class (it would simplify the
% justifyBlocks function and remove need to pass colLengths with
% blocksMatrix everywhere)

	blocksMatrix = {};

	% Order is based on the horizontal midpoints of blocks. The justification 
    % of justify blocks assumes this and needs to be updated if it changes.
	midXPositions = getBlockSidePositions(systemBlocks, 5);
	midXPositions = sort(midXPositions);

	% Get column lengths and make an unsorted blocksMatrix
	colLengths = zeros(1,length(midXPositions));
	for i = 1:length(systemBlocks)
	    midXPos = getBlockSidePositions(systemBlocks(i), 5);
	    col = isWhere(midXPos, midXPositions);
	    colLengths(col) = colLengths(col) + 1;
	    blocksMatrix{colLengths(col), col} = systemBlocks(i);
    end

    % Sort blocksMatrix
	blocksMatrix = sortBlocksMatrix(blocksMatrix, colLengths); 
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