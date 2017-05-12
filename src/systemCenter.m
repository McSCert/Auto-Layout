function [x,y] = systemCenter(blocks)
% SYSTEMCENTER Finds the center of the system (relative to block positions).
%
%   Inputs:
%       blocks  List of blocks.
%
%   Outputs:
%       x       x coordinate of the center of the bounds of the blocks.
%       y       y coordinate of the center of the bounds of the blocks.

largestX = -32767;
smallestX = 32767;
largestY = -32767;
smallestY = 32767;

for i = 1:length(blocks)
    leftPos = getBlockSidePositions(blocks(i), 1);
    topPos = getBlockSidePositions(blocks(i), 2);
    rightPos = getBlockSidePositions(blocks(i), 3);
    botPos = getBlockSidePositions(blocks(i), 4);
    
    if topPos < smallestY
        smallestY = topPos;
    elseif botPos > largestY
        largestY = botPos;
    end
    
    if leftPos < smallestX
        smallestX = leftPos;
    elseif rightPos > largestX
        largestX = rightPos;
    end
end

y = (largestY + smallestY) / 2;
x = (largestX + smallestX) / 2;
end