sys = 'AutoLayoutDemo';
open_system(sys);

dg = systemToDigraph(sys);
dg2 = addImplicitEdges(sys, dg);

%set(0,'DefaultFigureVisible','off');    % Don't show the figure
p = plotSimulinkDigraph(sys, dg2);
%set(0,'DefaultFigureVisible','on');

dg3 = addPorts(sys, dg2);
p2 = plotSimulinkDigraph(sys, dg3);

% Fix/invert the axes so that origin (0,0) is in upper right?
% Problem is that the graph becomes inverted too, and sometimes inputs aren't in order
%set(p.Parent,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');