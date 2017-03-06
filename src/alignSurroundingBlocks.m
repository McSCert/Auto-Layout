function alignSurroundingBlocks(block, side)
%ALIGNSURROUNDINGBLOCKS repositions blocks surrounding a given block such
%that lines are straight or something
%
%
%
%
%FUNCTION IN PROGRESS

    if strcmp(side,'left')
        %if side is left/input:
        ports=get_param(block,'Ports')
        numIn = ports(1) %should be 1
        x=get_param(block,'PortConnectivity')
        z=get_param(x(1).SrcBlock,'PortConnectivity')

        ports=get_param(x(1).SrcBlock,'Ports')
        numIn = ports(1) %should be 1
        
        pos=get_param(block,'Position')
        topbuffer = x(1).Position(2) - pos(2)

        set_param(block,'Position',...
            [pos(1), z(numIn+x(1).SrcPort+1).Position(2) - topbuffer, ...
            pos(3), z(numIn+x(1).SrcPort+1).Position(2) + topbuffer])
    
    elseif strcmp(side,'right')

       
    end

end