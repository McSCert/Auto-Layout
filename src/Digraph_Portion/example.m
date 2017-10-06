sys = 'AutoLayoutDemo';

open_system(sys);
dg = systemToDigraph(sys);
dg2 = addImplicitEdges(sys, dg);   
p = plotSimulinkDigraph(sys, dg2);
% x,y coordinates are in p.XData and p.YData respectively

% Fix/invert the axes so that origin (0,0) is in upper right?
% Problem is that the graph becomes inverted too, and sometimes inputs aren't in order
%set(p.Parent,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');