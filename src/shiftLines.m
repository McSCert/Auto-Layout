function shiftLines(lines, shift)
    % SHIFTLINES Replace Simulink lines with respect to their current points by
    % adding a shift amount to them.
    %
    % Inputs:
    %   lines   List (cell array or vector) of Simulink lines.
    %   shift   1x2 vector to add to each point of each line.
    %
    
    lines = inputToNumeric(lines);
    
    for i = 1:length(lines)
        l = lines(i);
        points = get_param(l, 'Points');
        
        for j = 1:length(points)
            points(j) = points(j) + shift;
        end
        set_param(l, 'Points', points);
    end
end