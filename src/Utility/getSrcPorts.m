function srcPorts = getSrcPorts(object)
% GETSRCPORTS Gets the outports that act as sources for a given block or
%   dst port.
%
%   Input:
%       object      Can be either the name or the handle of a block or a
%                   port handle.
%
%   Output:
%       srcPorts    Handles of ports acting as sources to the object

    srcPorts = [];
    
    if strcmp(get_param(object, 'Type'), 'block')
        block = object;
        lines = get_param(block, 'LineHandles');
        lines = lines.Inport;
    elseif strcmp(get_param(object, 'Type'), 'port')
        port = object;
        lines = get_param(port, 'Line');
    end
    
    for i = 1:length(lines)
        srcPorts(end+1) = get_param(lines(i), 'SrcPortHandle');
    end

end