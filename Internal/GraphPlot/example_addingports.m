sys = 'AutoLayoutDemo';
dg = systemToDigraph(sys);
dg2 = addImplicitEdges(sys, dg);

dgPorts = dg2; % Copy

% Adding outports for Sybsystem0
dgPorts = rmedge(dgPorts, 'AutoLayoutDemo/Subsystem0', 'AutoLayoutDemo/Int6');
dgPorts = rmedge(dgPorts, 'AutoLayoutDemo/Subsystem0', 'AutoLayoutDemo/Int7');

dgPorts = addnode(dgPorts, 'AutoLayoutDemo/Subsystem0_Port1');
dgPorts = addnode(dgPorts, 'AutoLayoutDemo/Subsystem0_Port2');

dgPorts = addedge(dgPorts, 'AutoLayoutDemo/Subsystem0', 'AutoLayoutDemo/Subsystem0_Port1', 1);
dgPorts = addedge(dgPorts, 'AutoLayoutDemo/Subsystem0', 'AutoLayoutDemo/Subsystem0_Port2', 1);

dgPorts = addedge(dgPorts, 'AutoLayoutDemo/Subsystem0_Port1', 'AutoLayoutDemo/Int6', 1);
dgPorts = addedge(dgPorts, 'AutoLayoutDemo/Subsystem0_Port2', 'AutoLayoutDemo/Int7', 1);

% Adding inports for Sum
dgPorts = rmedge(dgPorts, 'AutoLayoutDemo/Int6', 'AutoLayoutDemo/Sum');
dgPorts = rmedge(dgPorts, 'AutoLayoutDemo/Int7', 'AutoLayoutDemo/Sum');

dgPorts = addnode(dgPorts, 'AutoLayoutDemo/Sum_Port1');
dgPorts = addnode(dgPorts, 'AutoLayoutDemo/Sum_Port2');

dgPorts = addedge(dgPorts, 'AutoLayoutDemo/Sum_Port1', 'AutoLayoutDemo/Sum', 1);
dgPorts = addedge(dgPorts, 'AutoLayoutDemo/Sum_Port2', 'AutoLayoutDemo/Sum', 1);

dgPorts = addedge(dgPorts, 'AutoLayoutDemo/Int6', 'AutoLayoutDemo/Sum_Port1', 1);
dgPorts = addedge(dgPorts, 'AutoLayoutDemo/Int7', 'AutoLayoutDemo/Sum_Port2', 1);

p = plotSimulinkDigraph(sys, dgPorts);