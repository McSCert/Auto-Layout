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
    
% % With this implementation, the connection can be blocked if a
% % corresponding block is within a subsystem.
%     param = cell(size(froms)); 
%     [param{:}] = deal('GotoTag');
%     fromTags = cellfun(@get_param, froms, param, 'un', 0);
%     
%     for i = 1:length(gotos)
%         matchIdx = find(strcmp(get_param(gotos{i}, 'GotoTag'), fromTags));
%         for j = 1:length(matchIdx)
%             k = matchIdx(j);
%             gotoName = applyNamingConvention(gotos{i});
%             fromName = applyNamingConvention(froms{k});
%             dgNew = addedge(dgNew, gotoName, fromName, 1);
%         end
%     end

    for i = 1:length(gotos)
        subFroms = findFromsInScope(gotos{i});
        for j = 1:length(subFroms)
            snk = getFirstAncestor(subFroms{j});
            srcName = applyNamingConvention(gotos{i});
            snkName = applyNamingConvention(snk);
            if ~edgeExists(dgNew, srcName, snkName)
                dgNew = addedge(dgNew, srcName, snkName, 1);
            end
        end
    end
    for i = 1:length(froms)
        subGotos = findGotosInScope(froms{i});
        for j = 1:length(subGotos)
            src = getFirstAncestor(subGotos{j});
            srcName = applyNamingConvention(src);
            snkName = applyNamingConvention(froms{i});
            if ~edgeExists(dgNew, srcName, snkName)
                dgNew = addedge(dgNew, srcName, snkName, 1);
            end
        end
    end

    % Add Data Store Read/Writes as edges
    writes = find_system(sys, 'SearchDepth', 1, 'BlockType', 'DataStoreWrite');
    reads = find_system(sys, 'SearchDepth', 1, 'BlockType', 'DataStoreRead');

% % With this implementation, the connection can be blocked if a
% % corresponding block is within a subsystem.
%     param = cell(size(reads)); 
%     [param{:}] = deal('DataStoreName');
%     readTags = cellfun(@get_param, reads, param, 'un', 0);
%     
%     for i = 1:length(writes)
%         matchIdx = find(strcmp(get_param(writes{i}, 'DataStoreName'), readTags));
%         for j = 1:length(matchIdx)
%             k = matchIdx(j);
%             writeName = applyNamingConvention(writes{i});
%             readName = applyNamingConvention(reads{k});
%             dgNew = addedge(dgNew, writeName, readName, 1);
%         end
%     end

    for i = 1:length(writes)
        subReads = findReadsInScope(writes{i});
        for j = 1:length(subReads)
            snk = getFirstAncestor(subReads{j});
            srcName = applyNamingConvention(writes{i});
            snkName = applyNamingConvention(snk);
            if ~edgeExists(dgNew, srcName, snkName)
                dgNew = addedge(dgNew, srcName, snkName, 1);
            end
        end
    end
    for i = 1:length(reads)
        subWrites = findWritesInScope(reads{i});
        for j = 1:length(subWrites)
            src = getFirstAncestor(subWrites{j});
            srcName = applyNamingConvention(src);
            snkName = applyNamingConvention(reads{i});
            if ~edgeExists(dgNew, srcName, snkName)
                dgNew = addedge(dgNew, srcName, snkName, 1);
            end
        end
    end
    
    function anc = getFirstAncestor(blk)
        % Recursively get ancestors of the block until reaching sys.
        %
        % For a block in sys at some depth > 1, find the subsystem at 
        % depth == 1 which contains that block.
        % If the block is at depth == 1, return the block.
        
        p = get_param(blk, 'Parent');
        if strcmp(p, sys)
            anc = blk;
        else
            anc = getFirstAncestor(p);
        end
    end

    function exists = edgeExists(dg, source, sink)
        exists = false;
        for z = 1:size(dg.Edges, 1)
            edgeFound = strcmp(source, dg.Edges{z,1}{1}) && strcmp(sink, dg.Edges{z,1}{2});
            if edgeFound
                exists = true;
            end
        end
    end
end