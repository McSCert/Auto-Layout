function blocksInfo = getGraphPlotLayout(address)
% GETGRAPHPLOTLAYOUT Creates a GraphPlot representing the system using MATLAB 
%   functions and then lays out the system according to that plot.
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

% Set semi-arbitrary scaling factors to determine starting positions
scale = 90; % Pixels per unit increase in x or y in the plot
scaleBack = 3; % Scale-back factor to determine block size

for i = 1:length(systemBlocks)
    blockwidth  = scale/scaleBack;
    blockheight = scale/scaleBack;
    blockx      = scale*p.XData(i);
    blocky      = scale*yflip(yMax, yMin, p.YData(i));
    
    % Keep the block centered where the node was
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