function [snks, snkPositions] = arrangeSinks(blk)
% Swap block vertical positions to order destination blocks to the given block, 
%   blk. -- Just finds the positions to allow for this.
% 
% Assumes blocks use the tradional rotation (inports on left, outports on right)

% TODO implement for triggers and if actions
% TODO account for branches
% TODO account for connected blocks with numerous inports

% Find desired order
ph = get_param(blk, 'PortHandles');
out = ph.Outport;
orderedSnks = {};
positions = [];
tops = [];
for i = 1:length(out)
    lh = get_param(out(i), 'Line');
    dst = get_param(lh, 'DstPortHandle');
    orderedSnks = [orderedSnks, {get_param(dst, 'Parent')}];
    
    positions = [positions; get_param(orderedSnks{i}, 'Position')];
    tops = [tops; positions(i, 2)];
end

% Get old order
newTops = sort(tops);

% Use old order to swap top positions to place in the desired order
newPositions = [];
for j = 1:length(newTops)
    newTop = newTops(j);
    newBot = newTops(j) + positions(j,4) - positions(j,2);
    newPositions = [newPositions; positions(j,1), newTop, positions(j,3), newBot];
end

snks = orderedSnks;
snkPositions = newPositions;
end