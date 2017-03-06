function layout = resizeForConnections(row, col, layout)
%in the end it seems like I don't need to move blocks before calling this

%need to consider branching signals too
%need to consider ports that go in through the top
%need to consider rotated blocks

block = layout.grid{row,col}.fullname;

%Get current height of block
currentPos = get_param(block,'Position');
currentHeight = currentPos(4) - currentPos(2);

%Amount of space to spare for above/below the top/bottom port (note this is
%not necessarily the actual amount of space that will be there)
topbotBuffer = 50; %Arbitrary choice

%Get the number of in/outports on given block
blockPorts = get_param(block,'Ports');
numInports = blockPorts(1);
numOutports = blockPorts(2);

%Find a reasonable distance to have between ports based on heights of 
%blocks it connects to in the next column over.
%(This method is somewhat arbitrary and may be changed in the future)
desiredLeftPortDist = 60; %Somwhat arbitrary value based on a model I looked at
desiredRightPortDist = 60;
%value should be from sum across i of (height of connected block(i) / number of in/outports as appropriate)

% connectivity = get_param(layout.grid{row,col}.fullname, 'PortConnectivity');
% if col-1 >= 1 %if there is a previous column
%     %if given block is connected to a block in col-1
%     %then 
% %     for i = 1:layout.colLengths(col-1) %for each non empty row in previous column
% %         for each inport
% %         if connected
% %     end
% else
%     desiredLeftPortDist = 0;
% end
% 
% if col+1 <= size(layout.grid,2) %if there is a following column
%     for i = 1:layout.colLengths(col+1) %for each non empty row in following column
%         %for each outport
%     end
% else
%     desiredRightPortDist = 0;
% end


%Determine desired block height based on max of what it is now and what
%would be appropriate to accomodate the blocks it connects to
desiredHeightLeft = 2*topbotBuffer + numInports*desiredLeftPortDist;
desiredHeightRight = 2*topbotBuffer + numOutports*desiredRightPortDist;
desiredHeight = max(max(desiredHeightLeft, desiredHeightRight),currentHeight);

newPos = [currentPos(1), currentPos(2)-desiredHeight/2, ...
    currentPos(3), currentPos(4)+desiredHeight/2];
set_param(block,'Position', newPos);
layout.grid{row,col}.position = get_param(block,'Position'); %Note: not necessarily equal to newPos
end