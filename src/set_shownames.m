function set_shownames(showingNamesMap)
    % SET_SHOWNAMES Sets ShowName parameters of blocks to indicated values.
    %
    % Input:
    %   showingNamesMap Map from block fullnames to corresponding desired
    %                   ShowName values ('on' or 'off').
    %
    % Output:
    %   N/A
    %
    
    keys = showingNamesMap.keys;
    for i = 1:length(keys)
        set_param(keys{i}, 'ShowName', showingNamesMap(keys{i}))
    end
end