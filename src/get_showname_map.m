function showingNamesMap = get_showname_map(blocks, showNameRule)
    % GET_SHOWNAME_MAP Generates a map from blocks to their desired ShowName
    % parameter value.
    %
    % Input:
    %   blocks          List (cell array or vector) of blocks (fullnames or
    %                   handles).
    %   showNameRule    'no-change' - desire the current ShowName value.
    %                   'all' - desire all ShowName values to be 'on'.
    %                   'none' - desire all ShowName values to be 'off'.
    %
    % Output:
    %   showingNamesMap Map from block fullnames to corresponding desired
    %                   ShowName values ('on' or 'off').
    
    blocks = inputToNumeric(blocks);
    
    showingNamesMap = containers.Map();
    switch showNameRule
        case 'no-change'
            % Find which block names are showing.
            for i = 1:length(blocks)
                b = blocks(i);
                showingNamesMap(getfullname(b)) = get_param(b, 'ShowName');
            end
        case 'all'
            for i = 1:length(blocks)
                b = blocks(i);
                showingNamesMap(getfullname(b)) = 'on';
            end
        case 'none'
            for i = 1:length(blocks)
                b = blocks(i);
                showingNamesMap(getfullname(b)) = 'off';
            end
        otherwise
            error('Unexpected argument value.')
    end
end