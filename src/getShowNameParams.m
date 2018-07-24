function nameShowing = getShowNameParams(blocks)
    %
    % Input:
    %   blocks          Cell array of block fullnames. If given a vector of
    %                   handles, it will be converted to cell array of
    %                   block fullnames.
    %
    % Output:
    %   nameShowing
    
    blocks = inputToCell(blocks);
    
    SHOW_NAMES = getAutoLayoutConfig('show_names', 'no-change'); %Indicates which block names to show
    
    nameShowing = containers.Map();
    if strcmp(SHOW_NAMES, 'no-change')
        % Find which block names are showing at the start
        for i = 1:length(blocks)
            if strcmp(get_param(blocks(i), 'ShowName'), 'on')
                nameShowing(getfullname(blocks{i})) = 'on';
                set_param(blocks{i}, 'ShowName', 'off')
            elseif strcmp(get_param(blocks(i), 'ShowName'), 'off')
                nameShowing(getfullname(blocks{i})) = 'off';
            end
        end
    end
end