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
    
    % Remove lines where a line parent (or other ancestor) is already in
    % the list.
    % Otherwise redraw_line could  error later.
    lines = remove_child_lines(lines, 'All');
    
    % Get a base line layout using MATLABs autorouting
    tmpLines = [];
    for i = 1:length(lines)
        tmpLines = [redraw_line(lines(i), 'on'), tmpLines];
    end
    lines = tmpLines; % Update handles
    
    % Find diagonal line segments, make them run vertical and horizontal
    % TODO
    
    % Find vertical line segments, make them not overlap (unless it means
    % overlapping a block)
    remove_vertical_line_overlap(lines);
end