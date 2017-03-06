function alignPorts(block, side)
%ALIGNPORTS Resizes given block so that its input/output ports better line
%   up with the source/destination of the input/output signal.
%
%   Inputs:
%       block       String of the fullpath of a block.
%       side        Indicating the side of the block to align.
%%%%%%%             (what input means what)
%%%%%%%       layout      As returned by getRelativeLayout.
%
%   Outputs:
%%%%%%%       layout      With modified position information.
%
%FUNCTION IS IN PROGRESS

    if strcmp(side,'left')
        %if side is left/input:
        ports=get_param(block,'Ports')
        numIn = ports(1)
        x=get_param(block,'PortConnectivity')
        y=get_param(x(numIn).SrcBlock,'PortConnectivity')
        z=get_param(x(1).SrcBlock,'PortConnectivity')

        pos=get_param(block,'Position')
        topbuffer = x(1).Position(2) - pos(2)
        botbuffer = pos(4) - x(numIn).Position(2)

        set_param(block,'Position',...
            [pos(1), z(x(1).SrcPort+1).Position(2) - topbuffer, ...
            pos(3), y(x(numIn).SrcPort+1).Position(2) + botbuffer])

    elseif strcmp(side,'right')

        %if side is right/output:
        ports=get_param(block,'Ports')
        numIn = ports(1)
        numOut = ports(2)
        x=get_param(block,'PortConnectivity')
        y=get_param(x(numIn+numOut).DstBlock,'PortConnectivity')
        z=get_param(x(numIn+1).DstBlock,'PortConnectivity')

        pos=get_param(block,'Position')
        topbuffer = x(numIn+1).Position(2) - pos(2)
        botbuffer = pos(4) - x(numIn+numOut).Position(2)

        set_param(block,'Position',...
            [pos(1), z(x(numIn+1).DstPort+1).Position(2) - topbuffer, ...
            pos(3), y(x(numIn+numOut).DstPort+1).Position(2) + botbuffer])
    end
end