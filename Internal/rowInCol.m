function row = rowInCol(layout, block, col)
    %Check if block is in column col of layout. If it is then return the row,
    %else return 0.
    %
    % block is given as a handle
    
    row = 0;
    try %error if col is out of bounds
        for k = 1:length(layout{col})
            if layout{col}{k} == block
                row = k;
            end
        end
    end
end