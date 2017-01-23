function AutoLayout(address)

    systemBlocks = find_system(address, 'SearchDepth',1);
    systemBlocks = systemBlocks(2:end);
    nameShowing = containers.Map();
    portlessBlocks = getPortlessBlocks(systemBlocks);
    topOrBottomMap = containers.Map();
    numBot = 0;
    numTop = 0;
    for i = 1:length(portlessBlocks)
        if inBottomHalf(systemBlocks, portlessBlocks{i})
            topOrBottomMap(getfullname(portlessBlocks{i})) = 'bottom';
            numBot = numBot + 1;
        else
            topOrBottomMap(getfullname(portlessBlocks{i})) = 'top'; %in the event of a draw, top is the default
            numTop = numTop + 1;
        end
    end
    portlessInfo = struct('portlessBlocks', portlessBlocks,...
        'topOrBottomMap',topOrBottomMap,...
        'numTop',numTop,...
        'numBot',numBot);
    for i = 1:length(systemBlocks)
        if strcmp(get_param(systemBlocks(i), 'ShowName'), 'on')
            nameShowing(getfullname(systemBlocks{i})) = 'on';
            set_param(systemBlocks{i}, 'ShowName', 'off')
        elseif strcmp(get_param(systemBlocks(i), 'ShowName'), 'off')
            nameShowing(getfullname(systemBlocks{i})) = 'off';
        end
    end

    initLayout(address);

    for i = 1:length(systemBlocks)
        if strcmp(nameShowing(getfullname(systemBlocks{i})), 'on')
            set_param(systemBlocks{i}, 'ShowName', 'on')
        end % Don't need to do anything for ones that should be 'off'
    end

    secondLayout(address, systemBlocks, portlessInfo);
end

function inBottomHalf = inBottomHalf(blocks,block)
% Determines whether or not the middle of block is below the majority of blocks

    midYPos = getBlockSidePositions({block}, 6);
    numBlocksAbove = 0;
    numBlocksBelow = 0;
    for i = 1:length(blocks)
        midYPos2 = getBlockSidePositions(blocks(i), 6);
        if midYPos > midYPos2
            numBlocksAbove = numBlocksAbove + 1;
        elseif midYPos < midYPos2
            numBlocksBelow = numBlocksBelow + 1;
        end % Do nothing if equal 
    end
    if numBlocksBelow < numBlocksAbove % if more blocks are above than below
        inBottomHalf = true;
    else
        inBottomHalf = false;
    end
end