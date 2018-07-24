function blocks = find_in_blocks(blocks, varargin)
    % Find blocks of matching parameters and values indicated by varargin
    % Returns a vector of block handles even if blocks was given as a cell
    % array of block paths.
    %
    % varargin is given as parameter-value pairs, blocks in the input will
    % be removed in the output if their value for a given parameter does
    % not match that indicated by the value portion of the corresponding
    % parameter-value pair.
    
    blocks = inputToNumeric(blocks);
    
    assert(mod(length(varargin),2) == 0, 'Even number of varargin arguments expected.')
    for i = length(blocks):-1:1
        keep = true;
        for j = 1:2:length(varargin)
            param = varargin{j};
            value = varargin{j+1};
            if ~strcmp(get_param(blocks(i), param), value)
                keep = false;
                break
            end
        end
        
        if ~keep
            blocks(i) = [];
        end
    end
end