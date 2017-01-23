function hasPorts = hasPorts(block)
% HASPORTS Checks if a block has any ports.
%
%   Inputs:
%       block       Full name of a block (a char). If a cell array is 
%                   given, the first element is used.
%
%   Outputs:
%       hasPorts    Logical. True if one or more ports, else false.

    %Allow cell array input
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