function dg  = systemToDigraph(sys)
% SYSTEMTODIGRAPH Create a digraph out of the subsystem. Takes Simulink blocks 
%   as nodes and their singal line connections as edges. Weights are the
%   default 1.
%
%   Inputs:
%       sys     Path of the system for which to generate a digraph.
%
%   Outputs:
%       dg      Digraph representing the system.

    % Check first input
    try
        assert(ischar(sys));
    catch
        error('A string to a valid Simulink (sub)system must be provided.');     
    end
    
    try
        assert(bdIsLoaded(bdroot(sys)));
    catch
        error('Simulink system provided is invalid or not loaded.');     
    end

    % Get nodes
    nodes = find_system(sys, 'SearchDepth', '1', 'FindAll','off', 'Type', 'block');
    nodes(strcmp(nodes, sys), :) = [];  % If sys is a subsysttem, remove itself from the list
    numNodes = length(nodes);
    
    % Get neighbour data 
    param = cell(size(nodes)); 
    [param{:}] = deal('PortConnectivity');
    allPorts = cellfun(@get_param, nodes, param, 'un', 0);
    
    % Construct adjacency matrix
    A = zeros(numNodes);
    
    % Populate adjacency matrix
    for i = 1:numNodes
        data = allPorts{i};   
        neighbours = [data.DstBlock];
        if ~isempty(neighbours)
            for j = 1:length(neighbours)
                n = getfullname(neighbours(j));
                [row,~] = find(strcmp(nodes, n)); 
                A(i,row) = true;
            end
        end
    end
    dg = digraph(A, nodes);
end