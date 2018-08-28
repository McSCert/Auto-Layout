function portlessBlocks = getPortlessBlocks(blocks)
    % GETPORTLESSBLOCKS Find blocks that have no ports from a list of
    % blocks.
    %
    % Inputs:
    %   blocks  List (cell array or vector) of blocks (fullnames or
    %           handles).
    %
    % Outputs:
    %   portlessBlocks  Vector of block handles.
    
    blocks = inputToNumeric(blocks);
    
    portlessBlocks = [];
    for i = 1:length(blocks)
        if ~hasPorts(blocks(i))
            portlessBlocks = [portlessBlocks ; blocks(i)];
        end
    end
end