function dgNew = addImplicitEdges(sys, dg)
% ADDIMPLICITEDGES Add edges to a digraph representing the implicit connections 
%    between goto/froms.
%
%   Inputs:
%       sys     Path of the system that the digraph represents.
%       dg      Digraph representation of the system sys.
%
%   Outputs:
%       dgNew   Updated digraph.

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
    
    % Check second input
    try
        assert(isdigraph(dg));
    catch
        error('Digraph argument provided is not a digraph');
    end
    
    % Duplicate
    dgNew = dg;
    
    % Add Goto/Froms as edges
    gotos = find_system(sys, 'SearchDepth', 1, 'BlockType', 'Goto');
    froms = find_system(sys, 'SearchDepth', 1, 'BlockType', 'From');
    
    param = cell(size(froms)); 
    [param{:}] = deal('GotoTag');
    fromTags = cellfun(@get_param, froms, param, 'un', 0);
    
    for i = 1:length(gotos)
        matchIdx = find(strcmp(get_param(gotos{i}, 'GotoTag'), fromTags));
        for j = 1:length(matchIdx)
            k = matchIdx(j);
            gotoName = applyNamingConvention(gotos{i});
            fromName = applyNamingConvention(froms{k});
            dgNew = addedge(dgNew, gotoName, fromName, 1);
        end
    end
    
    % TODO: Add Data Store Read/Writes as edges?
end