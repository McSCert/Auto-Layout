function portlessBlocks = getPortlessBlocks(blocks)
	portlessBlocks = [];
	for i = 1:length(blocks)
	    if ~hasPorts(blocks{i})
	        portlessBlocks = [portlessBlocks ; blocks(i)];
	    end
	end
end