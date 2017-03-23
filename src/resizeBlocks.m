function [layout, portlessInfo] = resizeBlocks(layout, portlessInfo)
%RESIZEBLOCKS Determines desired end sizes for all blocks.
%
%   Inputs:
%       layout      As returned by getRelativeLayout.
%
%   Output:
%       layout      With modified position information.

%Resize horizontally to fit the strings within blocks
layout = adjustForText(layout);

%TODO Horizontally resize portless blocks for text too
% for i = 1:length(portlessInfo)
%     portlessInfo(i).position(3) = portlessInfo(i).position(1) + ...
%         getBlockTextWidth(portlessInfo(i).fullname);
% end

%Resize vertically to comfortably fit ports
layout = adjustForPorts(layout);

end