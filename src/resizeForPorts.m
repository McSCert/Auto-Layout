function layout = resizeForPorts (layout)
% RESIZFORPORTS
%FUNCTION IN PROGRESS!

% Start with first block in the layout
%%Does it make more sense to start with a more central block?
%%Does it make more sense to start with blocks with the fewest connections?

startBlock = layout.grid(1,1); % start at top-left in grid
resizeBlockForPorts(layout, startBlock);
end

function resizeBlockForPorts(layout, block)

% Find _relevant_ blocks
% Not relevant if 
%   -has multiple connections of same type that is going into current block
%   -max(# connections on a side) >= max(# connections on a side of the
%   current block)
%   -not in adjacent column of layout.grid
%   -not to the left (this is for inputs and trigger/etc.)
%   -not to the right (this is for outputs)
relevantIndices 

% For a given block connection, if the connected block has not been 
% resized, and is _relevant_, resize that first

% Begin resizing:
%   Increase up until any of the following:
%       -Height would pass a block in a neighboring column with a signal going toward the current block
%       -Height surpasses highest connected _relevant_ block
%   Increase down in the same way
%   Increase height evenly (from top and bottom) until min height reached
%       min height = max(# connections on a side)*min amount per port + buffer

% Move blocks in the same column up and down as needed
%   (<-- this part is tricky since it shouldn't ruin other block alignment
%   that has occurred)

end

function layout = align(layout, block, side)
end