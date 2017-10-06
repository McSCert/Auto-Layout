function blocksInfo = getDigraphLayout(address)
% GETDIGRAPHLAYOUT Perform the layout analysis on the system with MATLAB's 
%   digraph function.
%
%   Input:
%       address     System address in which to perform the analysis.
%
%   Output:
%       blocksInfo  Struct of data representing the results of the
%                   analysis.

dg = systemToDigraph(address);
dg2 = addImplicitEdges(address, dg);

defaultFigureVisible = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');    % Don't show the figure
p = plotSimulinkDigraph(address, dg2);
set(0,'DefaultFigureVisible',defaultFigureVisible);

systemBlocks = p.NodeLabel';
blocksInfo = struct('fullname', systemBlocks);

yMax = max(p.YData);
yMin = min(p.YData);

scale = 90; % Arbitrary scaling factor to determine starting positions

for i = 1:length(systemBlocks)
    blockwidth  = scale/3;
    blockheight = scale/3;
    blockx      = scale*p.XData(i);
    blocky      = scale*yflip(yMax, yMin, p.YData(i));
    
    left    = round(blockx - blockwidth/2);
    right   = round(blockx + blockwidth/2);
    top     = round(blocky - blockheight/2);
    bottom  = round(blocky + blockheight/2);
    
    pos = [left top right bottom];
    blocksInfo(i).position = pos;
end

    function ynew = yflip(ymax,ymin,y)
        % Accounting for different coordinate system between the plot and Simulink
        ynew = ymax + ymin - y;
    end
end