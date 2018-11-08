function autolayout_lines(lines)
    % AUTOLAYOUT_LINES Automatically lays out lines.
    %
    % Input:
    %   lines   Vector of Simulink line handles.
    %
    % Output:
    %   N/A
    %
    
    % Get a base line layout using MATLABs autorouting
    for i = 1:length(lines)
        redraw_line(lines(i), 'on');
    end
    
    % Find diagonal line segments, make them run vertical and horizontal
    % TODO
    
    % Find vertical line segments, make them not overlap (unless it means
    % overlapping a block)
    remove_vertical_line_overlap(lines)
    
    lines
    XXX    colDims = getColumnDimensions(layout);
    vSegs = getVSegs(lines);
    
    % Reorganize the placements of vertical line segments in the system
    spaceVSegs(vSegs, colDims);
end

function redraw_line(line, autorouting)
    % Redraw line.
    
    sys = get_param(line, 'Parent');
    
    srcport = get_param(line, 'SrcPortHandle');
    dstports = get_param(line, 'DstPortHandle');
    % Delete and re-add.
    delete_line(line)
    for k = 1:length(dstports)
        dstport = dstports(k);
        add_line(sys, srcport, dstport, 'autorouting', autorouting);
    end
end