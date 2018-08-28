function hasPorts = hasPorts(blocks)
    % HASPORTS Check if a block has any ports.
    %
    %   Inputs:
    %       blocks      List (cell array or vector) of blocks (full names or
    %                   handles).
    %
    %   Outputs:
    %       hasPorts    Vector of logicals. Indices correspond with the indices
    %                   of blocks indicating whether the block has one or more
    %                   ports (1), or none (0).
    
    %
    blocks = inputToNumeric(blocks);
    
    %
    hasPorts = -1*ones(1,length(blocks)); % -1 should be absent from the final output
    for i = 1:length(blocks)
        b = blocks(i);
        % The block has no ports if its parameter PortConnectivity is empty
        ports = get_param(b,'PortConnectivity');
        if isempty(ports)
            hasPorts(i) = false;
        else
            hasPorts(i) = true;
        end
    end
end