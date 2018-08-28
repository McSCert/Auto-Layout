function layout = find_relative_layout(blocks)
    % FIND_RELATIVE_LAYOUT Sort a set of blocks into columns and order within
    % columns by their height.
    %
    % Inputs:
    %   blocks  List (cell array or vector) of blocks (fullnames or
    %           handles).
    %
    % Outputs:
    %   layout  Cell array where each element represents a column of blocks
    %           (here we define a column of blocks to be the maximum set of
    %           blocks in which every block shares an x-coordinate with any
    %           other block in the set) represented by a cell array of block
    %           handles ordered such that the first element has the least top
    %           position and following elements have increasing top positions.
    
    blocks = inputToNumeric(blocks);
    
    layout = {};
    while ~isempty(blocks) % Delete at least 1 block every loop
        
        % Initialize a new column with the first block.
        layout{end+1} = {blocks(1)}; % Put column at the end as default
        
        % Remove first block since it has been added to a column.
        blocks(1) = [];
        
        % Put the new column in the correct order with respect to other columns
        % (further left columns get lower indices).
        pos1 = get_param(layout{end}{1}, 'Position');
        idx = length(layout); % init
        for i = 1:length(layout)-1
            col = layout{i}; % current column
            pos2 = get_param(col{1}, 'Position');
            if pos1(1) < pos2(1) % Compare any x-coord of one column with any x-coord of another column
                % New column is left of the current column.
                layout = [layout(1:i-1) layout(end) layout(i:end-1)];
                idx = i; break; % If break removed, still need to preserve idx
            end
        end
        
        % Add other blocks to the new column
        stillAddingBlocks = true;
        while stillAddingBlocks
            stillAddingBlocks = false; % Switch to true if something gets added.
            for i = length(blocks):-1:1 % Reverse order so blocks can be deleted as it goes.
                block = blocks(i);
                % If current block shares an x-coord with any block already
                % added to the column, then add current block to the column and
                % remove from blocks list if added to a column.
                [overlap_exists, ~] = detectOverlaps(block, layout{idx}, 'OverlapType', 'Horizontal');
                if overlap_exists
                    % Add block to column.
                    layout{idx}{end+1} = block;
                    stillAddingBlocks = true;
                    % Remove block from blocks list.
                    blocks(i) = [];
                    % Put the block in the correct order such that blocks with
                    % lower top positions get lower indices in the column).
                    pos1 = get_param(layout{idx}{end}, 'Position');
                    for j = 1:length(layout(idx))-1 % For every block in column except the new one.
                        pos2 = get_param(layout{idx}{j}, 'Position');
                        if pos1(2) < pos2(2)
                            % Move block before the jth block in the column.
                            layout{idx} = [layout{idx}(1:j-1) layout{idx}(end) layout{idx}(j:end-1)];
                            break
                        end
                    end
                end
            end
        end
        
        % The remaining blocks do not fit in any columns that have been made.
    end
end

function layout = getRelativeLayout_using_x_centers(blocks)
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
    
    %
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