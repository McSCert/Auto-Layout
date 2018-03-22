function fixBlockSize(blocksMatrix, colLengths)
    for j = 1:size(blocksMatrix,2) % for each column
        largestX = 0;
        for i = 1:colLengths(j) % for each non empty row in column
            xDisplace = getNewSize(char(blocksMatrix{i,j})); % Resize and return amount to move other blocks
            if xDisplace > largestX
                largestX = xDisplace;
            end
        end
        horzMoveBlocks(blocksMatrix, colLengths, j, largestX);
    end
end