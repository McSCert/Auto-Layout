function fixLabelOutOfBounds(blocksMatrix, colLengths)
    for j = 1:size(blocksMatrix,2) % for each column
        largestX = 0;
        for i = 1:colLengths(j) % for each non empty row in column
            pos = get_param(blocksMatrix{i,j}, 'Position');
            midXPos = (pos{1}(3) + pos{1}(1))/2;
            labelSize = getLabelSize(char(blocksMatrix{i,j}));
            xDisplace = (labelSize/2) - midXPos;
            if xDisplace > 0
                if xDisplace > largestX
                    largestX = xDisplace;
                end
            end
        end
        horzMoveBlocks(blocksMatrix, colLengths, j-1, largestX);
    end
end

function labelSize = getLabelSize(block)
% Get the size of a block's label, since it can create an offset for where
% AutoLayout places it initially and we don't want to take that into account

    if strcmp(get_param(block, 'ShowName'),'on')
        labelSize = getTextSize(get_param(block, 'Name'), block);
    else
        labelSize = 0;
    end
end