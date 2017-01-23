function placePortlessBlocks(address, portlessInfo, blocksMatrix, colLengths, topOrBot, preserveFormat)
% Places blocks with no ports along the top or bottom of the system
% topOrBot should be 'top' or 'bottom' depending on where blocks are being placed
% preserveFormat is a boolean which decides the method to be used for spacing the blocks
%   if preserveFormat is true, then blocks will be placed in line with the
%       columns dictated in blocksMatrix (though the blocks being moved
%       will not necessarily stay in the same column they were originally in
%   if preserveFormat is false, then no regard will be made to the columns
%       and the blocks will be placed close together (to be more aesthetically pleasing)
% portlessInfo is a struct defined as in AutoLayout.m
% blocksMatrix and colLengths are from the output of getOrderMatrix.m

    isTop = strcmp(topOrBot, 'top');
    isBot = strcmp(topOrBot, 'bottom');
    if isTop
        % Find the row index for the highest block in each column
        num = portlessInfo(1).numTop;
        sideNum = 2;
        greatestInCol = ones(1,length(colLengths)); %refers to the row numbers of the highest blocks in blocksMatrix
    elseif isBot
        % Find the row index for the lowest block in each column
        num = portlessInfo(1).numBot;
        sideNum = 4;
        greatestInCol = colLengths; %refers to the row numbers of the lowest blocks in blocksMatrix
    end

    if num > 0 % If any blocks need to be moved to the side designated by topOrBot

        portlessBlocks = {portlessInfo.portlessBlocks};
        topOrBottomMap = portlessInfo(1).topOrBottomMap;

        % Find the highest (if isTop)/lowest (if isBot) dimension 
        for i = 1:length(colLengths)
            dim = getBlockSidePositions(blocksMatrix(greatestInCol(i),i),sideNum);
            if hasPorts(blocksMatrix{greatestInCol(i), i})
                if ~exist('greatestOfDim', 'var') || ...
                        (dim < greatestOfDim && isTop) || ...   % recall top positions are higher the smaller they are 
                        (dim > greatestOfDim && isBot)          % (opposite for bottom positions)
                    greatestOfDim = dim;
                end
            end
        end

        % Find left most position among the blocks
        for i = 1:colLengths(1)
            leftSide = getBlockSidePositions(blocksMatrix(i,1),1);
            if ~exist('leftBound', 'var') || leftSide < leftBound
                leftBound = leftSide;
            end
        end
        nextLeft = leftBound;
        for i = 1:colLengths(end)
            rightSide = getBlockSidePositions(blocksMatrix(i,length(colLengths)),3);
            if ~exist('rightBound', 'var') || rightSide > rightBound
                rightBound = rightSide;
            end
        end
        midXs = getBlockSidePositions(blocksMatrix(1,:),5);
        newGreatestOfDim = greatestOfDim;

        for i = 1:length(portlessBlocks)
            if strcmp(topOrBottomMap(portlessBlocks{i}),topOrBot)
                pos = get_param(portlessBlocks{i}, 'Position');
                width = pos(3) - pos(1);
                height = pos(4) - pos(2);

                numCol = length(colLengths);
                if preserveFormat
                    midX = midXs(mod(i-1,numCol) + 1);
                    left = midX - width/2;
                    if mod(i,numCol) == 1
                        greatestOfDim = newGreatestOfDim;
                    end

                    [top, right, bot, newGreatestOfDim] = getTopRightBotAndNGOD(greatestOfDim, newGreatestOfDim, width, height, left, isTop, isBot);

                    % If isTop, need to make sure the portlessBlocks won't be assigned negative positions:
                    if top <= 0
                        [top, bot, greatestOfDim, newGreatestOfDim] = moveEverythingDown(address,blocksMatrix,colLengths,colLengths,top,bot,greatestOfDim,newGreatestOfDim);
                    end

                    set_param(portlessBlocks{i}, 'Position', [left top right bot]);

                    assert(midX == (left+right)/2)
                else % ~preserveFormat
                    if nextLeft == leftBound || nextLeft + width <= rightBound
                        left = nextLeft;
                    else
                        left = leftBound;
                        greatestOfDim = newGreatestOfDim;
                    end
                    horzSpace = 10;

                    [top, right, bot, newGreatestOfDim] = getTopRightBotAndNGOD(greatestOfDim, newGreatestOfDim, width, height, left, isTop, isBot);

                    % If isTop, need to make sure the portlessBlocks won't be assigned negative positions:
                    if top <= 0
                        [top, bot, greatestOfDim, newGreatestOfDim] = moveEverythingDown(address,blocksMatrix,colLengths,top,bot,greatestOfDim,newGreatestOfDim);
                    end

                    set_param(portlessBlocks{i}, 'Position', [left top right bot]);

                    nextLeft = right + horzSpace;
                end
            end
        end
        if newGreatestOfDim < 0
            for j = 1:length(colLengths)
                vertMoveColumn(blocksMatrix, colLengths, 0, j, -top);
            end
        end
    end
end

function [top, right, bot, newGreatestOfDim] = getTopRightBotAndNGOD(greatestOfDim, newGreatestOfDim, width, height, left, isTop, isBot)
% This function is mostly just to save from a copy and paste
    vertSpace = 30;
    right = left + width;
    if isTop
        bot = greatestOfDim - vertSpace;
        top = bot - height;
        dim = top;
    elseif isBot
        top = greatestOfDim + vertSpace;
        bot = top + height;
        dim = bot;
    end
    if (dim < newGreatestOfDim && isTop) || ...   % recall top positions are higher the smaller they are
            (dim > newGreatestOfDim && isBot)          % (opposite for bottom positions)
        newGreatestOfDim = dim;
    end
end

function [top, bot, greatestOfDim, newGreatestOfDim] = moveEverythingDown(address,blocksMatrix,colLengths,top,bot,greatestOfDim,newGreatestOfDim)
% Move all blocks down appropriately. Move all lines to where they should go.
% Adjust top and bot appropriately. Adjust the greatestOfDim and 
% newGreatestOfDim appropriately. Other things may have been forgotten...

    buffer = 30;
    shiftAmount = -top + buffer;

    systemLines = find_system(address, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'Line');
    linePoints = determineNewLinePoints(systemLines,shiftAmount);

    moveBlocksDown(blocksMatrix,colLengths,shiftAmount)

    moveLinePoints(systemLines,linePoints)

    % moveUIObjectsDown(address,shiftAmount);

    top = top + shiftAmount;
    bot = bot + shiftAmount;
    greatestOfDim = greatestOfDim + shiftAmount;
    newGreatestOfDim = newGreatestOfDim + shiftAmount;
end

function linePoints = determineNewLinePoints(lines,shiftAmount)
% Determines what the shifted positions of the points that form the lines will be

    linePoints = getAllLinePoints(lines);
    for i = 1:length(linePoints) % for all lines
        for j = 1:length(linePoints{i})
            linePoints{i}(j,2) = linePoints{i}(j,2) + shiftAmount;
        end
    end
end

function moveBlocksDown(blocksMatrix,colLengths,shiftAmount)
% Moves blocks in blocksMatrix down by shiftAmount

    for i = 1:size(blocksMatrix,2) % for each column
        for j = 1:colLengths(i) % for each non empty row in column
            pos = get_param(char(blocksMatrix{j,i}), 'Position');
            set_param(char(blocksMatrix{j,i}), 'Position', [pos(1) pos(2)+shiftAmount pos(3) pos(4)+shiftAmount]);
        end
    end
end

function moveLinePoints(lines,linePoints)
% Moves lines to linePoints

    for i = 1:length(lines) % for all lines
        currentPoints = get_param(lines(i), 'Points');
        if linePoints{i}(1,2) == linePoints{i}(2,2)
            linePoints{i}(2,2) = currentPoints(1,2);
        end
        if linePoints{i}(end,2) == linePoints{i}(end-1,2)
            linePoints{i}(end-1,2) = currentPoints(end,2);
        end
        linePoints{i}(1,2) = currentPoints(1,2);
        linePoints{i}(end,2) = currentPoints(end,2);

        set_param(lines(i), 'Points',linePoints{i});
    end
end

%%% May not need the functions below

function findMaxPortlessBlockHeight(portlessBlocks,topOrBottomMap)
% Finds the maximum height among relevant portlessBlocks:
    for i = 1:length(portlessBlocks)
        if strcmp(topOrBottomMap(portlessBlocks{i}), 'top') % If the block is being moved to the top
            pos = get_param(portlessBlocks{i}, 'Position');
            height = pos(4) - pos(2); % height = bot - top
            if ~exist('portlessMaxHeight', 'var') || height > portlessMaxHeight % if current block is the new tallest
                portlessMaxHeight = height;
            end
        end
    end
end

function moveUIObjectsDown(address,shiftAmount)
    allUIObjects = find_system(address, 'SearchDepth',1, 'FindAll', 'on');
    for i = 1:length(allUIObjects)
        pos = get_param(allUIObjects(i), 'Position');
        set_param(allUIObjects(i), 'Position', [pos(1) pos(2)+shiftAmount pos(3) pos(4)+shiftAmount]);
    end
end