function depths = choose_impact_depths(blocks)
    % CHOOSE_IMPACT_DEPTHS Chooses an appropriate depth for blocks based on when
    % they are impacted with respect to other blocks.
    %
    % Input:
    %   blocks  List (cell array or vector) of Simulink blocks (fullnames or
    %           handles).
    %
    % Output:
    %   depths  Vector of strictly positive integers. Each element corresponds
    %           to the input block of the same index.
    %
    
    % This is just an arbitrary and reasonable approach (i.e. specific
    % choices about what depths a block should have were not made for
    % particular reasons)
    
    blocks = inputToNumeric(blocks); % Want cell array of block handles
    
    if isempty(blocks)
        depths = [];
    else
        % Convert from block handle to index in impactStruct.
        block2struct = containers.Map('KeyType', 'double', 'ValueType', 'double');
        %
        for i = 1:length(blocks)
            block = blocks(i);
            block2struct(block) = i;
        end
        
        impactStruct = cell(1, length(blocks));
        for i = 1:length(blocks)
            block = blocks(i);
            
            dsts = getDsts(block, 'IncludeImplicit', 'on', ...
                'ExitSubsystems', 'off', 'EnterSubsystems', 'off', ...
                'Method', 'RecurseUntilTypes', 'RecurseUntilTypes', {'block'});
            dsts = remove_if_not_key(dsts, block2struct);
            
            srcs = getSrcs(block, 'IncludeImplicit', 'on', ...
                'ExitSubsystems', 'off', 'EnterSubsystems', 'off', ...
                'Method', 'RecurseUntilTypes', 'RecurseUntilTypes', {'block'});
            srcs = remove_if_not_key(srcs,block2struct);
            
            impactStruct{i} =  struct('block', block, 'dstblocks', dsts, 'srcblocks', srcs);
        end
        
        first_sources = []; % Initial guess
        for i = 1:length(impactStruct)
            if isempty(impactStruct{i}.srcblocks)
                first_sources = [first_sources, impactStruct{i}.block];
            end
        end
        
        if isempty(first_sources)
            first_dests = []; % Initial guess
            for i = 1:length(impactStruct)
                if isempty(impactStruct{i}.dstblocks)
                    first_dests = [first_dests, impactStruct{i}.block];
                end
            end
            if isempty(first_dests)
                first_dests = blocks(1);
            end
            depths = get_depths(first_dests, impactStruct, block2struct, 'dst');
        else
            depths = get_depths(first_sources, impactStruct, block2struct, 'src');
        end
    end
end

function depths = get_depths(first_blocks, impactStruct, block2struct, type)
    % type - 'src' or 'dst'. Determines which auxiliary function to use.
    
    depths = zeros(1,length(impactStruct)); % Initialize (note: 0 is not allowed in final depths)
    switch type
        case 'src'
            depths = get_depths_from_sources_aux(first_blocks, impactStruct, block2struct, 1, depths);
        case 'dst'
            depths = get_depths_from_dests_aux(first_blocks, impactStruct, block2struct, -1, depths);
            % Make the minimum depth 1
            lowestDepth = min(depths);
            depths = depths - lowestDepth + 1; 
        otherwise
            error(['Unexpected argument value. For argument: type'])
    end
    assert(all(depths ~= 0))
end

function depths = get_depths_from_dests_aux(dsts, impactStruct, block2struct, maxDepth, depths)
    for i = 1:length(dsts)
        block = dsts(i);
        index = block2struct(block);
        
        depths(index) = maxDepth;
        
        srcs = impactStruct{index}.srcblocks;
        for j = 1:length(srcs)
            depth = depths(block2struct(srcs(j)));
            if 0 == depth
                depths = get_depths_from_dests_aux(impactStruct{index}.srcblocks, impactStruct, block2struct, maxDepth-1, depths);
            end
        end
    end
end

function depths = get_depths_from_sources_aux(srcs, impactStruct, block2struct, minDepth, depths)
    for i = 1:length(srcs)
        block = srcs(i);
        index = block2struct(block);
        
        depths(index) = minDepth;
        
        dsts = impactStruct{index}.dstblocks;
        for j = 1:length(dsts)
            depth = depths(block2struct(dsts(j)));
            if 0 == depth
                depths = get_depths_from_sources_aux(impactStruct{index}.dstblocks, impactStruct, block2struct, minDepth+1, depths);
            end
        end
    end
end

function keys = remove_if_not_key(items, map)
    keys = items;
    for i = length(keys):-1:1
        if ~map.isKey(keys(i))
            keys(i) = [];
        end
    end
end