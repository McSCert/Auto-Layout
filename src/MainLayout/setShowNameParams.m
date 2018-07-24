function setShowNameParams(blocks, nameShowing)
    %
    % Input:
    %   blocks          Cell array of block fullnames. If given a vector of
    %                   handles, it will be converted to cell array of
    %                   block fullnames.
    %   nameShowing
    
    blocks = inputToCell(blocks);
    
    SHOW_NAMES = getAutoLayoutConfig('show_names', 'no-change'); %Indicates which block names to show
    
    if strcmp(SHOW_NAMES, 'no-change')
        % Return block names to be showing or hidden, as they were initially
        for i = 1:length(blocks)
            if strcmp(nameShowing(getfullname(blocks{i})), 'on')
                set_param(blocks{i}, 'ShowName', 'on')
            else
                % This should be redundant with the implementation, but is in place as a fail-safe
                set_param(blocks{i}, 'ShowName', 'off')
            end
        end
    elseif strcmp(SHOW_NAMES, 'all')
        % Show all block names
        for i = 1:length(blocks)
            set_param(blocks{i}, 'ShowName', 'on')
        end
    elseif strcmp(SHOW_NAMES, 'none')
        % Show no block names
        for i = 1:length(blocks)
            set_param(blocks{i}, 'ShowName', 'off')
        end
    else
        ErrorInvalidConfig('show_names')
    end
end