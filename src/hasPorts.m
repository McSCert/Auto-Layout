function hasPorts = hasPorts(block)
% Checks if a block has any ports (true if there are one or more else false)

    if iscell(block)
        block = block{1};
    end
    
    ports = get_param(block,'PortConnectivity');
    if isempty(ports)
        hasPorts = false;
    else
        hasPorts = true;
    end
end