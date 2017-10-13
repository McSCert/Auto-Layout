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
% dg3 = addPorts(address, dg2);
finalDg = dg2;
p = plotSimulinkDigraph(address, finalDg);
set(0,'DefaultFigureVisible',defaultFigureVisible);

systemBlocks = p.NodeLabel';
xs = p.XData;
ys = p.YData;

% keep = ~cellfun(@isempty,regexp(systemBlocks,'(:b$)','once'));
% toss = ~cellfun(@isempty,regexp(systemBlocks,'(:[io][0-9]*$)','once')); % These aren't needed anymore
% assert(all(xor(keep, toss)), 'Unexpected NodeLabel syntax.')
% systemBlocks = cellfun(@(x) x(1:end-2), systemBlocks(keep), 'UniformOutput', false);
% xs = xs(keep);
% ys = ys(keep);
% % systemBlocks(toss) = [];
% % xs(toss) = [];
% % ys(toss) = [];

systemBlocks = cellfun(@(x) x(1:end-2), systemBlocks, 'UniformOutput', false);

blocksInfo = struct('fullname', systemBlocks);

% Set semi-arbitrary scaling factors to determine starting positions
scale = 90; % Pixels per unit increase in x or y in the plot
scaleBack = 3; % Scale-back factor to determine block size

for i = 1:length(systemBlocks)
    blockwidth  = scale/scaleBack;
    blockheight = scale/scaleBack;
    blockx      = scale*xs(i);
    blocky      = scale*(max(ys) + min(ys) - ys(i)); % Accounting for different coordinate system between the plot and Simulink
    
    % Keep the block centered where the node was
    left    = round(blockx - blockwidth/2);
    right   = round(blockx + blockwidth/2);
    top     = round(blocky - blockheight/2);
    bottom  = round(blocky + blockheight/2);
    
    pos = [left top right bottom];
    blocksInfo(i).position = pos;
end
end