function h = plotSimulinkDigraph(blocks, dg)
    % PLOTSIMULINKDIGRAPH Plot a digraph representing a Simulink (sub)system in the
    %   same fashion as a Simulink diagram, i.e., layered, left-to-right, etc.
    %
    % Inputs:
    %   blocks  Vector of block handles in which each block is at the
    %           top level of the same system.
    %   dg      Digraph representation of the system sys.
    %
    % Outputs:
    %   h       GraphPlot object (see
    %           www.mathworks.com/help/matlab/ref/graphplot.html).
    
    %%
    % Check first input
    assert(isa(blocks, 'double'), 'Blocks must be given as a vector of handles.')
    
    if ~isempty(blocks)
        sys = getCommonParent(blocks);
        assert(bdIsLoaded(getfullname(bdroot(sys))), 'The system containing the given Simulink blocks is invalid or not loaded.')
    end
    
    % Check second input
    assert(isdigraph(dg), 'Digraph argument provided is not a digraph');
    
    %%
    % Get sources and sinks
    srcs = zeros(1,length(blocks));
    snks = zeros(1,length(blocks));
    for i = 1:length(blocks)
        switch get_param(blocks(i), 'BlockType')
            case 'Inport'
                srcs(i) = blocks(i);
            case 'Outport'
                snks(i) = blocks(i);
        end
    end
    srcs = srcs(find(srcs));
    snks = snks(find(snks));
    srcs_cell = {};
    snks_cell = {};
    for i = 1:length(srcs)
        srcs_cell{end+1} = applyNamingConvention(srcs(i));
    end
    for i = 1:length(snks)
        snks_cell{end+1} = applyNamingConvention(snks(i));
    end
    
    %%
    % Use Simulink-like plot options
    % Info on options: https://www.mathworks.com/help/matlab/ref/graph.plot.html
    ops = {'Layout', 'layered', 'Direction', 'right', 'AssignLayers', 'alap'};
    if ~isempty(srcs_cell)
        ops = [ops 'Sources' {srcs_cell}];
    end
    if ~isempty(snks_cell)
        ops = [ops 'Sinks' {snks_cell}];
    end
    
    % Plot
    h = plot(dg, ops{:});
end