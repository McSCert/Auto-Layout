function portlessBlocks = getPortlessBlocks(blocks)
%GETPORTLESSBLOCKS Finds blocks from a list which have no ports.
%
%   Inputs:
%       blocks          Cell array of block names.
%
%   Outputs:
%       portlessBlocks  Cell array of block names for blocks with no ports.

	portlessBlocks = [];
	for i = 1:length(blocks)
	    if ~hasPorts(blocks{i})
	        portlessBlocks = [portlessBlocks ; blocks(i)];
	    end
	end
end