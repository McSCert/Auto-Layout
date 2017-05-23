function cSegs = getConnectedSegments(blocks)
% GETCONNECTEDSEGMENTS For a list of blocks, finds the different groups of
%   blocks which are all connected through lines in Simulink. For each 
%   group, all blocks within that group will be given regardless of whether
%   or not the block was in the original list of blocks. These groups will
%   be referred to as segments in this file.
%
%   Inputs:
%       blocks  Cell array of blocks to use to find segments.
%
%   Outputs:
%       cSegs   Cell array of segments of blocks. Each segment is
%               represented by a cell array of blocks within cSegs. cSegs 
%               may include new blocks not originally given in the blocks
%               variable.

cSegs = {};
while ~isempty(blocks)
    %find all blocks in same segment as a given block (choose arbitrarily)
    cBlocks = findConnected(blocks{1});
    cSegs{end+1} = cBlocks;
    
    %remove all blocks in this segment from blocks
    blocks = setdiff(blocks, cBlocks);
end
end

function cBlocks = findConnected(block, varargin)
%Given a block, find blocks it's connected to via a line or series of lines

% Add block to connected blocks
% Find blocks connected to block
% Recurse on new blocks

if nargin == 1
    cBlocks = {};
elseif nargin == 2
    cBlocks = varargin{1};
else
    assert(false, 'Wrong number of input arguments to findConnected.')
end
cBlocks{end+1} = block;

portConn = get_param(block, 'PortConnectivity');
for i = 1:length(portConn)
    for j = 1:length(portConn(i).SrcBlock) % Always length 1 or 0?
        cBlock = getfullname(portConn(i).SrcBlock(j));
        if isempty(find(strcmp(cBlocks,cBlock),1))
            cBlocks = findConnected(cBlock, cBlocks);
        end % else it and its connected blocks will already be handled
    end
    for j = 1:length(portConn(i).DstBlock) % Can be more than 1 through branches
        cBlock = getfullname(portConn(i).DstBlock(j));
        if isempty(find(strcmp(cBlocks,cBlock),1))
            cBlocks = findConnected(cBlock, cBlocks);
        end % else it and its connected blocks will already be handled
    end
end

end