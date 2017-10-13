function srcPorts = getSrcPorts(block)
% GETSRCPORTS Gets the outports that act as sources for a given block
%
%   Input:
%       block   Can be either the name or the handle
%
%   Output:
%       srcPorts    Handles of ports acting as sources to block

    srcPorts = [];
    
    lines = get_param(block, 'LineHandles');
    lines = lines.Inport;
    
    for i = 1:length(lines)
        srcPorts(end+1) = get_param(lines(i), 'SrcPortHandle');
    end

end