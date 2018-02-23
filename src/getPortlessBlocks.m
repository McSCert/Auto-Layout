function portlessBlocks = getPortlessBlocks(blocks)
%GETPORTLESSBLOCKS Find blocks which have no ports from a list of blocks.
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