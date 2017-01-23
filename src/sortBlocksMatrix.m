function blocksMatrix = sortBlocksMatrix(blocksMatrix, colLengths)
% Sorts blocks in blocksMatrix within columns by their top positions
% (it's assumed that blocks are already in their appropriate columns)

    for i = 1:size(blocksMatrix,2) % for each column
        colMat = getColMatrix(i, blocksMatrix);
        colMat = sortByTopPos(colMat);
        for j=1:colLengths(i) % for each non empty row in column
            blocksMatrix{j,i} = colMat{j};
        end
    end
end

function sortedMat1D = sortByTopPos(mat1d)
% Takes an unsorted matrix of blocks (format is important if some spaces are empty)
% and returns a matrix of blocks sorted in the order they appear in the block diagram

    tops = [];
    len = 0;   % len represents the number of non-empty values in mat1d
    
    for i = 1:length(mat1d)
        if ~isempty(mat1d{i})
            pos = get_param(mat1d{i}, 'Position');
            tops = [tops ; pos{1}(2)];
            len = len + 1;
        else
            break
        end
    end
    [vals, order] = sort(tops);
    sortedMat1D = mat1d(order);

    for i = len + 1:length(mat1d)
        sortedMat1D{i} = [];
    end
end

function colMatrix = getColMatrix(colNum, mat2d)
% Takes a 2-D matrix and a column number (less than size(mat2d,2)) and
% returns a 1-D matrix of the values in the designated column (in the same order)

    for i = 1:size(mat2d,1)
        colMatrix{i} = mat2d{i, colNum};
    end
end