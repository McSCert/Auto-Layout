function xIncrease = getNewSizeX(block)
% GETNEWSIZEX calculate and increase the width of a block based on the string(s) inside the
% block.
%
%   Inputs:
%       block          Block that changes size.
%
%   Outputs:
%       xIncrease      Amount the block's width is changed.

    xIncrease = 0;
    blockType = get_param(block, 'BlockType');
    
    
    %Determine what strings to look for based on the type of block
    switch blockType
        case 'SubSystem'
            inports = find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'Inport');
            inports = [inports; find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'EnablePort')];
            inports = [inports; find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'TriggerPort')];
            inports = [inports; find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'ActionPort')];
            largestWidth = 0;
            for i = 1:length(inports)
                name = get_param(inports{i}, 'Name');
                width = getTextSize(name, block);
                if width > largestWidth
                    largestWidth = width;
                end
            end
            width = largestWidth * 2;
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
            
        case 'Goto'
            gotoTag = get_param(block, 'gototag');
            width = getTextSize(gotoTag, block);
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
            
        case 'From'
            gotoTag = get_param(block, 'gototag');
            width = getTextSize(gotoTag, block);
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
            
        case 'GotoTagVisibility'
            gotoTag = get_param(block, 'gototag');
            width = getTextSize(gotoTag, block);
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
            
        case 'DataStoreRead'
            dataStoreName = get_param(block, 'DataStoreName');
            width = getTextSize(dataStoreName, block);
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
            
        case 'DataStoreWrite'
            dataStoreName = get_param(block, 'DataStoreName');
            width = getTextSize(dataStoreName, block);
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
            
        case 'DataStoreMemory'
            dataStoreName = get_param(block, 'DataStoreName');
            width = getTextSize(dataStoreName, block);
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
            
        case 'Constant'
            name = get_param(block, 'Name');
            width = getTextSize(name, block);
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
            
        case 'If'
            ifExpression = get_param(block, 'ifExpression');
            elseIfExpressions = get_param(block, 'ElseIfExpressions');
            elseIfExpressions = strsplit(elseIfExpressions, ',');
            if isempty(elseIfExpressions{1})
                elseIfExpressions = {};
            end
            expressions = [{ifExpression} elseIfExpressions];
            largestWidth = 0;
            for i = 1:length(expressions)
                width = getTextSize(expressions{1}, block);
                if width > largestWidth
                    largestWidth = width;
                end
            end
            width = largestWidth * 2;
            blockPos = get_param(block, 'position');
            xSize = blockPos(3) - blockPos(1);
            if xSize < width
                xIncrease = width - xSize;
                blockPos(3) = blockPos(3) + xIncrease;
                set_param(block, 'position', blockPos);
            else
                xIncrease = 0;
            end
    end
end