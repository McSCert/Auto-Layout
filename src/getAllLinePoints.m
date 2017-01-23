function linePoints = getAllLinePoints(lines)
% Returns a cell array where each element is the set of points associated
% with each of the corresponding input lines
%
%   Inputs:
%       lines   Array of lines

    linePoints = {};
    for i = 1:length(lines)
        linePoints{i} = get_param(lines(i), 'Points');
    end
end