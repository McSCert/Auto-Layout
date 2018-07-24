function blocksInfo = getBlocksInfo(blocks)
    % GETBLOCKSINFO Get a struct with name and position information of
    % input blocks.
    %
    % Input:
    %   blocks                  Vector of blocks for which to get blocksInfo.
    %
    % Outputs:
    %   blocksInfo              Struct of data representing current block data.
    %   blocksInfo(i).fullname  Fullname of a block.
    %   blocksInfo(i).position  Position of a block.
    
    for i = 1:length(blocks)
        % Add names to struct
        blocksInfo(i).fullname = getfullname(blocks(i));
        
        % Add positions to struct
        pos = get_param(blocks(i), 'Position');
        blocksInfo(i).position = pos;
    end
end

function blocksInfo = getBlocksInfo_Sys(sys)
% GETBLOCKSINFO_SYS Different version of getBlocksInfo that takes a system
% instead of blocks and finds info for all blocks in the system.
%
%   Input:
%       sys     System address for which to get blocksInfo.
%
%   Outputs:
%       blocksInfo              Struct of data representing current block data.
%       blocksInfo(i).fullname  Fullname of a block.
%       blocksInfo(i).position  Position of a block.

    % Get blocks in sys
    blocks = find_system(sys, 'SearchDepth', 1);
    blocks = blocks(2:end); % Remove sys

    % Add names to struct
    blocksInfo = struct('fullname', blocks);

    % Add positions to struct
    for i = 1:length(blocks)
        pos = get_param(blocks{i}, 'Position');
        blocksInfo(i).position = pos;
    end
end