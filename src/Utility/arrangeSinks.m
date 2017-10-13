function [snks, snkPositions] = arrangeSinks(blk, doMove)
% ARRANGESINKS Finds sinks of block, blk, and swaps their vertical
%   positions to be ordered with respect to ports.
%
%   Inputs:
%       blk     A Simulink block fullname or handle
%       doMove  Logical true to move the blocks in the system. False to
%               just return information to do the move.
%   Outputs:
%       snks            Cell array of source block name.
%       snkPositions    Array of positions to move the srcs to 
%                       (uses same indexing as srcs).
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

if doMove
    % Set positions
    for j = 1:length(snks)
        set_param(snks{j}, 'Position', snkPositions(j, :))
    end
end
end