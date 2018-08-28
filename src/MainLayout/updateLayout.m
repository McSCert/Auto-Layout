function layout = updateLayout(layout)
    % UPDATELAYOUT Updates layout given potentially new positions.
    %
    %   Inputs:
    %       layout  Same form as returned by find_relative_layout.
    %
    %   Outputs:
    %       layout  As returned by find_relative_layout now.

    blocksInLayout = {};
    for i = 1:length(layout)
        for j = 1:length(layout{i})
            blocksInLayout{end+1} = layout{i}{j};
        end
    end
    layout = find_relative_layout(blocksInLayout);
end