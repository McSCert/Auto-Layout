function [leftBound,topBound,rightBound,botBound] = sideExtremes(layout, portlessInfo, ignorePortlessBlocks)
%COMMENTS NEED UPDATE
%EXTREMESIDE Finds the extreme position of a given side among blocks.

rightBound = -32767;
leftBound = 32767;
botBound = -32767;
topBound = 32767;

%TODO - optimize this to only check needed blocks
for j = 1:size(layout.grid,2)
    for i = 1:layout.colLengths(j)
        pos = layout.grid{i,j}.position;
        if pos(3) > rightBound
            rightBound = pos(3);
        end
        if pos(1) < leftBound
            leftBound = pos(1);
        end
        
        if pos(4) > botBound
            botBound = pos(4);
        end
        if pos(2) < topBound
            topBound = pos(2);
        end
    end
end

if ~ignorePortlessBlocks
    for i = 1:length(portlessInfo)
        pos = portlessInfo{i}.position;
        if pos(3) > rightBound
            rightBound = pos(3);
        end
        if pos(1) < leftBound
            leftBound = pos(1);
        end
        
        if pos(4) > botBound
            botBound = pos(4);
        end
        if pos(2) < topBound
            topBound = pos(2);
        end
    end
end
end