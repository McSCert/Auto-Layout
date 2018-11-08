function lines = get_block_lines(blocks)
    % GET_BLOCK_LINES Get the lines connected to any given block.
    %
    % Input:
    %   blocks  Vector of Simulink block handles.
    %
    % Output:
    %   lines   Vector of Simulink line handles.
    %
    
    lines = [];
    for n = 1:length(blocks)
        block = blocks(n);
        sys = getParentSystem(block);
        
        % Get the block's lines.
        lineHdls = get_param(block, 'LineHandles');
        fields = fieldnames(lineHdls);
        for i = 1:length(fields)
            field = fields{i};
            tmp_lines = getfield(lineHdls, field);
            for j = 1:length(tmp_lines)
                line = tmp_lines(j);
                if line ~= -1
                    % Add line
                    lines(end+1) = line;
                end
            end
        end
    end
end