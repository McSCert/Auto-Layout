function shiftLines(lines, shift)
    % SHIFTLINES Replace Simulink lines with respect to their current points by
    % adding a shift amount to them.
    %
    % Inputs:
    %   lines   List (cell array or vector) of Simulink lines.
    %   shift   1x2 vector to add to each point of each line. Disregards
    %           elements beyond the first 2.
    %
    
    lines = inputToNumeric(lines);
    
    for i = 1:length(lines)
        l = lines(i);
        points = get_param(l, 'Points');
        
        for j = 2:length(points)-1
            points(j,:) = points(j,:) + shift(1:2);
        end
        set_param(l, 'Points', points);
    end
end