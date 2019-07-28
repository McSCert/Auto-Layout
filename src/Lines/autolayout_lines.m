function lines = autolayout_lines(lines)
    % AUTOLAYOUT_LINES Automatically lays out lines.
    %
    % Input:
    %   lines   Vector of Simulink line handles.
    %
    % Output:
    %   lines   Updated line handles (lines will have been deleted and re-added
    %           with new handles).
    %
    
    % Remove duplicate lines.
    lines = unique(lines);
    % Remove lines where a line parent (or other ancestor) is already in
    % the list.
    % Otherwise redraw_line could error later.
    lines = remove_child_lines(lines, 'All');
    
    % Get a base line layout using MATLAB's autorouting
    tmpLines = [];
    for i = 1:length(lines)
        newLines = redraw_line(lines(i), 'on');
        tmpLines = [newLines, tmpLines];
    end
    lines = tmpLines; % Update handles
    
    % Find diagonal line segments, make them run vertical and horizontal
    % TODO
    
    % Find vertical line segments, make them not overlap
    % TODO: Don't adjust if it would mean overlapping a block
    remove_vertical_line_overlap(lines);
end