function remove_vertical_line_overlap(lines)
    
    vSegs = get_vertical_line_segments(lines);
    
    % Reorganize the placements of vertical line segments in the system
    spaceVSegs(vSegs, colDims);
end

function vSegs = get_vertical_line_segments(lines)
%   vSegs{#} has:
%       x - the x coordinate of the vertical segment
%       ymin - the minimum y coordinate of the vertical segment
%       ymax - the maximum y coordinate of the vertical segment
%       point1 - first point in the vertical segment
%       point2 - second point in the vertical segment
%       line - the handle of the line this vertical segment is apart of
%       pointsInLine - all points in line
%       pointIndex1 - point1's index in line
%       pointIndex2 - point2's index in line

    vSegs = {};
    linePoints = getAllLinePoints(lines);
    for i = 1:length(linePoints) % For all lines
        for j = 2:size(linePoints{i}, 1) % For all points after first in line
            points = linePoints{i};
            xnow = points(j, 1);
            xold = points(j-1, 1);
            if xnow == xold
                ynow = points(j, 2);
                yold = points(j-1, 2);
                if ynow ~= yold % Wouldn't be considered a vertical line if it had no length
                    ymin = (ynow < yold) * ynow + (yold < ynow) * yold;
                    ymax = (ynow > yold) * ynow + (yold > ynow) * yold;

                    vSegs{end+1} = struct( ...
                        'x', xnow, ...
                        'ymin', ymin, ...
                        'ymax', ymax, ...
                        'point1', points(j-1, :), ...
                        'point2', points(j,:), ...
                        'line', lines(i), ...
                        'pointsInLine', points, ...
                        'pointIndex1', j-1, ...
                        'pointIndex2', j);
                end
            end
        end
    end
end

function shift_vertical_line_segments(vSegs)
    
end

function spaceVSegs(vSegs, colDims)
% Re-places vSegs, evenly spacing them between the columns of blocks

    for i = 2:length(colDims) %for each column after first
        freeSpace = colDims{i}(1) - colDims{i-1}(2);
        if freeSpace > 0

            % Get vertical segments from anywhere between left side of previous
            % column and the left side of the current column.
            % If this code gets changed also change the equivalent part of adjustColWidths!
            tempVSegs = vSegsInRange(vSegs, colDims{i-1}(1), colDims{i}(1));
            arrangeVSegs(tempVSegs, colDims{i-1}(2), colDims{i}(1));
        else
            disp('Could not improve arrangement of vertical line segments within given space.')
        end
    end
end

function vSegs = vSegsInRange(vSegs, leftBound, rightBound)
% Find all vertical line segments among vSegs that lie between leftBound and rightBound

    tempVSegs = {};
    for i = 1:length(vSegs)
        if leftBound <= vSegs{i}.x && vSegs{i}.x <= rightBound
            tempVSegs{end + 1} = vSegs{i};
        end
    end
    vSegs = tempVSegs;
end

function arrangeVSegs(vSegs, leftBound, rightBound)
% Arranges vSegs evenly between leftBound and rightBound

    vSegs = sortVSegs(vSegs); %So that they can be rearranged somewhat logically

    for i = 1:length(vSegs)
        xnew = leftBound + (((rightBound - leftBound)*i)/(length(vSegs) + 1));
        index1 = vSegs{i}.pointIndex1;
        index2 = vSegs{i}.pointIndex2;
        vSegs{i}.pointsInLine(index1,1) = xnew;
        vSegs{i}.pointsInLine(index2,1) = xnew;

        set_param(vSegs{i}.line,'Points', vSegs{i}.pointsInLine); % Move points
        vSegs{i} = updateVSeg(vSegs{i});
    end
end

function vSegs = sortVSegs(vSegs)
% Sorts vertical line segments, vSegs, giving priority to lowest x value,
% and secondary priority to largest ymax value
% no third level of priority is applied

    % Sort vSegs from smallest x to largest x
    xVals = [];
    for i = 1:length(vSegs)
        xVals(end + 1) = vSegs{i}.x;
    end
    [~, orderX] = sort(xVals);
    vSegs = vSegs(orderX);

    % Maintain order of smallest x to largest x,
    % Break ties by placing larger ymax earlier
    unSortedY = true;
    while unSortedY
        unSortedY = false;
        for i = 2:length(vSegs)

            % Don't break the previous sorting
            if vSegs{i}.x == vSegs{i-1}.x
                if vSegs{i-1}.ymax < vSegs{i}.ymax
                    unSortedY = true;

                    temp = vSegs{i-1};
                    vSegs{i-1} = vSegs{i};
                    vSegs{i} = temp;
                end
            end

        end
    end
end

function vSeg = updateVSeg(vSeg)
% Returns an updated vSeg.
% The following properties are assumed to already be up to date:
%   vSeg.line,
%   vSeg.pointsInLine,
%   vSeg.pointIndex1,
%   vSeg.pointIndex2

    vSeg.x = vSeg.pointsInLine(vSeg.pointIndex1, 1);
    y1 = vSeg.pointsInLine(vSeg.pointIndex1, 2);
    y2 = vSeg.pointsInLine(vSeg.pointIndex2, 2);
    vSeg.ymin = (y1 < y2) * y1 + (y2 < y1) * y2;
    vSeg.ymax = (y1 > y2) * y1 + (y2 > y1) * y2;
    vSeg.point1 = vSeg.pointsInLine(vSeg.pointIndex1, :);
    vSeg.point2 = vSeg.pointsInLine(vSeg.pointIndex2, :);
end