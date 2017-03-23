function layout = resizeForPorts (layout)
% RESIZFORPORTS
%
%Difference from adjustForPorts():
% Method is dependent upon surroundings
%
% TODO: COMMENTING

resized = containers.Map;
for j = 1:size(layout.grid,2) % for each column
    for i = 1:layout.colLengths(j) % for each non empty row in column
        [layout, resized] = resizeBlockForPorts(layout, resized, i, j);
    end
end
end

function [layout, resized] = resizeBlockForPorts(layout, resized, row, col)

block1 = layout.grid{row, col}.fullname; % block to resize (referred to as current block)

if ~isKey(resized,block1)
    resized(block1) = 'notresized';
end
if ~strcmp(resized(block1), 'resized')
    % Find relevant blocks (i.e. blocks that will matter in determining what
    % size to make the current block)
    % Not relevant if:
    %   -not connected to current block
    %   -has multiple connections of same type that is going into current block
    %   -max(# connections on a side) >= max(# connections on a side of the
    %   current block)
    %   -not in adjacent column of layout.grid
    %   -not to the left (this is for inputs and trigger/etc.)
    %   -not to the right (this is for outputs)
    rel = {}; %list indices in layout.grid of "relevant" blocks
    portCon1 = get_param(block1, 'PortConnectivity');
    ports1 = get_param(block1, 'Ports');
    for i = 1:ports1(1)
        block2 = getfullname(portCon1(i).SrcBlock);
        ports2 = get_param(block2, 'Ports');
        portCon2 = get_param(block2, 'PortConnectivity');

        if ports2(2) == 1 ... % Only one connection exiting the block
                && max(ports2(1:2)) < max(ports1(1:2)) % Current block has more connections on one side
            col2 = col-1;
            row2 = rowInCol(layout, block2, col2);
            if row2 ~= 0 % block2 is in column to the left of the current block
                %Block is "relevant"
                rel{end+1} = {row2, col2};
            end
        end
    end
    for i = 1:ports1(2)
        block2 = getfullname(portCon1(end-ports1(2)+i).DstBlock);
        ports2 = get_param(block2, 'Ports');
        portCon2 = get_param(block2, 'PortConnectivity');

        if ports2(1) == 1 ... % Only one connection entering the block
                && max(ports2(1:2)) < max(ports1(1:2)) % Current block has more connections on one side
            col2 = col+1;
            row2 = rowInCol(layout, block2, col2);
            if row2 ~= 0 % block2 is in column to the right of the current block
                %Block is "relevant"
                rel{end+1} = {row2, col2};
            end
        end
    end

    % For a given block connection, if the connected block is "relevant", 
    % resize that first (no resizing happens if already resized)
    % (recursive step)
    for i = 1:length(rel)
        [layout, resized] = resizeBlockForPorts(layout, resized, rel{i}{1}, rel{i}{2});
    end

    % Find values for resizing such that:
    %   Increases up until any of the following:
    %       -Height would pass a block in a neighboring column with a signal going toward the current block
    %       -Height surpasses highest connected "relevant" block
    %   Increases down in the same way
    %   Increases height evenly (from top and bottom) until min height reached
    %       min height = max(# connections on a side)*min amount per port + buffer
    
    %start values for the highest and lowest points of the relevant blocks:
    highestRel = 32767; % max simulink y coord (the lowest position visually)
    lowestRel = -32767; % min simulink y coord (the highest position visually)
    
    for i = 1:length(rel)
        pos = layout.grid{rel{i}{1}, rel{i}{2}}.position;
        if pos(4) > lowestRel
            lowestRel = pos(4);
        end
        if pos(2) < highestRel
            highestRel = pos(2);
        end
    end
    
    %%%TODO/to improve
    %check height of blocks in neighbouring column with signal going
    %toward current block
    %%% (currently doesn't bother checking for a signal)
    buff = 30; % buffer for space between blocks
    top = layout.grid{row, col}.position(2);
    bot = layout.grid{row, col}.position(4);
    lowestTop = -32767; %most extreme top value of current block before interfering with other blocks
    highestBot = 32767; %most extreme bot value of current block before interfering with other blocks
    
    neighbors = [];
    if col > 1
        neighbors = [neighbors, col-1];
    end
    if col < size(layout.grid,2)
        neighbors = [neighbors, col+1];
    end
    for c = neighbors %left/right column from col if there is a left/right column
        for i = 1:layout.colLengths(c) % for blocks in column
            if ~inRel(rel, i,c) && layout.grid{i, c}.position(4) + buff < top && ...
                    layout.grid{i, c}.position(4) + buff > lowestTop
                lowestTop = layout.grid{i, c}.position(4) + buff;
            end
            if ~inRel(rel, i,c) && layout.grid{i, c}.position(2) - buff > bot && ...
                    layout.grid{i, c}.position(2) - buff < highestBot
                highestBot = layout.grid{i, c}.position(2) - buff;
            end
        end
    end
    
    top = max(highestRel, lowestTop);
    bot = min(lowestRel, highestBot);
    
    
    blockBuff = 30; % Buffer above and below the top and bottom port of a block
    minLeftHeight = 40*(ports1(1)-1) + 2*blockBuff; %minimum desirable height to accomodate ports on the left side
    minRightHeight = 40*(ports1(2)-1) + 2*blockBuff; %minimum desirable height to accomodate ports on the left side
    
    minHeight = max(minLeftHeight, minRightHeight);
    
    h = bot - top;
    if h < minHeight
        top = top - (minHeight - h)/2;
        bot = bot + (minHeight - h)/2;
    end
    
    currPos = layout.grid{row,col}.position;
    layout.grid{row,col}.position = [currPos(1), top, currPos(3), bot];
    
    % Mark as resized
    resized(block1) = 'resized';

    % Move blocks in the same column up and down as needed
    for i = row-1:-1:1 % for blocks above current block in column
        currPos = layout.grid{i,col}.position;
        if currPos(4) > layout.grid{i+1,col}.position(2) - buff
            shamt = currPos(4) - layout.grid{i+1,col}.position(2) + buff; %shift amount
            layout.grid{i,col}.position = [currPos(1), currPos(2)-shamt, currPos(3), currPos(4)-shamt];
        end
    end

    for i = row+1:layout.colLengths(col) % for blocks below current block in column
        currPos = layout.grid{i,col}.position;
        if currPos(2) < layout.grid{i-1,col}.position(4) + buff
            shamt = layout.grid{i-1,col}.position(4) + buff - currPos(2); %shift amount
            layout.grid{i,col}.position = [currPos(1), currPos(2)+shamt, currPos(3), currPos(4)+shamt];
        end
    end
end
end

function bool = inRel(rel, i, j)
bool = false;
for k = 1:length(rel)
    if rel{k}{1} == i && rel{k}{2} == j
        bool = true;
        return
    end
end
end