function layout = updateLayout(layout)
    % UPDATELAYOUT Updates layout given potentially new positions.
    %
    %   Inputs:
    %       layout  Same form as returned by getRelativeLayout.
    %
    %   Outputs:
    %       layout  As returned by getRelativeLayout.

    blocksInLayout = {};
    for i = 1:length(layout)
        for j = 1:length(layout{i})
            blocksInLayout{end+1} = layout{i}{j};
        end
    end
    layout = getRelativeLayout(blocksInLayout);
end