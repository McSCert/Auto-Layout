function portlessBlocks = getPortlessBlocks(blocks)
% GETPORTLESSBLOCKS Find blocks that have no ports from a list of blocks.
%
%   Inputs:
%       blocks          Cell array of block fullnames. If given a vector of
%                       handles, it will be converted to cell array of
%                       block fullnames.
%
%   Outputs:
%       portlessBlocks  Cell array of block names with no ports.

    blocks = inputToCell(blocks);

	portlessBlocks = [];
	for i = 1:length(blocks)
	    if ~hasPorts(blocks{i})
	        portlessBlocks = [portlessBlocks ; blocks(i)];
	    end
	end
end