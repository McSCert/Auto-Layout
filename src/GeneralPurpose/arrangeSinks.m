function [snks, snkPositions, didMove] = arrangeSinks(blk, doMove)
% ARRANGESINKS Finds sinks of block, blk, and swaps their vertical
%   positions to be ordered with respect to ports.
%   
%   If there are branches or if a sink has multiple inports,
%   then no arranging will be attempted, but positions to rearrange them
%   will still be given as output.
%
%   Inputs:
%       blk     A Simulink block fullname or handle
%       doMove  Logical true to move the blocks in the system. False to
%               just return information to do the move.
%
%   Outputs:
%       snks            Cell array of source block name. If a line is branching,
%                       only one of those snks will be returned.
%       snkPositions    Array of positions to move the srcs to 
%                       (uses same indexing as srcs).
%       didMove         True if the blocks were moved, else false. 
%                       Notes: If doMove is false, this will always be false.
%                       If doMove is true, this may still be false as a
%                       result of branches/excessive ports (described
%                       above).
%
% Assumes blocks use the tradional rotation (inports on left, outports on right)
%

% TODO implement for triggers and if actions

% Find desired order
ph = get_param(blk, 'PortHandles');
out = ph.Outport;
len = length(out);
orderedSnks = cell(1, len);
positions = zeros(len,4);
tops = zeros(len,1);
for i = 1:length(out)
    lh = get_param(out(i), 'Line');
    dst = get_param(lh, 'DstPortHandle');
    if isBranching(lh)
        doMove = false;
        dst = dst(1); % Arbitrarily select a destination to use.
    end
    orderedSnks{i} = get_param(dst, 'Parent');
    
    snkph = get_param(orderedSnks{i}, 'PortHandles');
    snkin = snkph.Inport;
    if length(snkin) > 1
        doMove = false;
    end
    
    positions(i,:) = get_param(orderedSnks{i}, 'Position');
    tops(i) = positions(i, 2);
end

% Get old order
newTops = sort(tops);

% Use old order to swap top positions to place in the desired order
newPositions = zeros(len,4);
for j = 1:len %length(newTops)
    newTop = newTops(j);
    newBot = newTops(j) + positions(j,4) - positions(j,2);
    newPositions(j,:) = [positions(j,1), newTop, positions(j,3), newBot];
end

snks = orderedSnks;
snkPositions = newPositions;

if doMove
    % Set positions
    for j = 1:len %length(snks)
        set_param(snks{j}, 'Position', snkPositions(j, :))
    end
    didMove = true;
else
    didMove = false;
end
end