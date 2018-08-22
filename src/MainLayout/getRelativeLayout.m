function layout = getRelativeLayout(blocks)
    % GETRELATIVELAYOUT Sort a set of blocks into columns and order within
    % columns by their height.
    %
    % Inputs:
    %   blocks  List (cell array or vector) of blocks (fullnames or
    %           handles).
    %
    % Outputs:
    %   layout  Cell array where each element represents a column of blocks
    %           (blocks centered on the same x coordinate). The column is
    %           represented by a cell array of block handles ordered such
    %           that the first element has the least top position and
    %           following elements have increasing top positions.
    
    blocks = inputToNumeric(blocks);
    
    centers = position_center(get_param(blocks, 'Position'));
    x_centers = centers(:, 1);
    
    [x_centers_sorted, I] = sort(x_centers);
    blocks_sorted = blocks(I);
    column_centers = unique(x_centers_sorted);
    
    layout = cell(1, length(unique(x_centers))); % An element for each unique x that a block is centered on
    for i = 1:length(layout)
        % Initialize elements to empty cell arrays
        layout{i} = {};
    end
    col = 1;
    for i = 1:length(blocks_sorted)
        
        % Update column
        if column_centers(col) ~= x_centers_sorted(i)
            assert(column_centers(col+1) == x_centers_sorted(i))
            col = col + 1;
        end
        
        % Insert current block into column.
        % Preserve sorting of ascending top positions.
        pos_i = get_param(blocks_sorted(i), 'Position');
        col_length_before = length(layout{col}); % Column length before adding the current block
        layout{col} = [layout{col} {blocks_sorted(i)}]; % Add block to the end as default
        for j = 1:col_length_before
            pos_j = get_param(layout{col}{j}, 'Position');
            if pos_i(2) < pos_j(2)
                layout{col} = [layout{col}(1:j-1) {blocks_sorted(i)} layout{col}(j:end-1)]; % Move block before the jth block in the column
                break
            end
        end
        assert(col_length_before + 1 == length(layout{col}), 'Something went wrong. Column length did not go up by 1 when adding a block to it.')
    end
end