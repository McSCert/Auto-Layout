function [srcs, srcPositions] = arrangeSources(blk, doMove)
% ARRANGESOURCES Finds sources of block, blk, and swaps their vertical
%   positions to be ordered with respect to ports.
%
%   Inputs:
%       blk     A Simulink block fullname or handle
%       doMove  Logical true to move the blocks in the system. False to
%               just return information to do the move.
%   Outputs:
%       srcs            Cell array of source block name.
%       srcPositions    Array of positions to move the srcs to 
%                       (uses same indexing as srcs).
% 
% Assumes blocks use the tradional rotation (inports on left, outports on right)

% TODO implement for triggers and if actions
% TODO account for branches
% TODO account for connected blocks with numerous outports

% Find desired order
ph = get_param(blk, 'PortHandles');
in = ph.Inport;
orderedSrcs = {};
positions = [];
tops = [];
for i = 1:length(in)
    lh = get_param(in(i), 'Line');
    src = get_param(lh, 'SrcPortHandle');
    orderedSrcs = [orderedSrcs, {get_param(src, 'Parent')}];
    
    positions = [positions; get_param(orderedSrcs{i}, 'Position')];
    tops = [tops, positions(i, 2)];
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

srcs = orderedSrcs;
srcPositions = newPositions;

if doMove
    % Set positions
    for j = 1:length(srcs)
        set_param(srcs{j}, 'Position', srcPositions(j, :))
    end
end
end