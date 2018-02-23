function fixDiagonalLines(systemLines)
% FIXDIAGONALLINES remove diagonal lines by
%   Inputs:
%       systemLines     lines that are checked to see if they are diagonal
% 
%   Output:
%       N/A

    for i = 1:length(systemLines)
        line = systemLines(i);
        linePoints = get_param(line, 'points');
        for j = 1:size(linePoints,1) - 1
            % determine if the next point in the line is on the same row or
            % column, if not, the line is diagonal at the current point
            if linePoints(j,1) ~= linePoints(j+1,1) && linePoints(j,2) ~= linePoints(j+1,2)
                firstPoint = linePoints(1,:);
                sLastPoint = linePoints(end-1,:);
                lastPoint = linePoints(end,:);
                middlePixel = floor((firstPoint(1) + lastPoint(1)) / 2);
                firstMidpoint = [middlePixel, firstPoint(2)];
                secondMidpoint = [middlePixel, sLastPoint(2)];
                points = [firstPoint; firstMidpoint; secondMidpoint; sLastPoint; lastPoint];
                set_param(line, 'points', points);
            end
        end
    end
end