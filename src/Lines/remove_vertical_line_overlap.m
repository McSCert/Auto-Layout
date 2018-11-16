function remove_vertical_line_overlap(lines)
    
    vertSegsList = find_vertical_line_segments(lines);
    vertSegs = sort_vert_segs(vertSegsList);
    
    shift_amount = 3;
    while ~isempty(vertSegs)
        % Until there are no groups of candidates to fix
        while length(vertSegs{1}) > 1
            % Until the first group of candidates has 1 or no members
            k = 2; % counter for following loop (may not be safe to use a for loop)
            while k <= length(vertSegs{1}{k})
                instruction = get_vertical_line_overlap_fix_instruction(vertSegs{1}{1}, vertSegs{1}{k});
                switch instruction
                    case '1stLineLeft'
                        success = move_segment_left(vertSegs{1}{1}, shift_amount);
                        if ~success
                            % Forget this line.
                            vertSegs = delete_segment(vertSegs, 1, 1); % Delete vertSegs{1}{1}
                        else
                            tempVertSeg = vertSegs{1}{1};
                            vertSegs = delete_segment(vertSegs, 1, 1); % Delete vertSegs{1}{1}
                            insert_segment(vertSegs, tempVertSeg);
                        end
                        break % Pick a new first vertical segment
                    case 'EitherLineLeft'
                        success = move_segment_left(vertSegs{1}{1}, shift_amount);
                        if ~success
                            % Try 2nd line.
                            success2 = move_segment_left(vertSegs{1}{k}, shift_amount);
                            if ~success2
                                % Forget this line.
                                vertSegs = delete_segment(vertSegs, 1, k); % Delete vertSegs{1}{k}
                            else
                                tempVertSeg = vertSegs{1}{k};
                                vertSegs = delete_segment(vertSegs, 1, k); % Delete vertSegs{1}{k}
                                insert_segment(vertSegs, tempVertSeg);
                            end
                        else
                            tempVertSeg = vertSegs{1}{1};
                            vertSegs = delete_segment(vertSegs, 1, 1); % Delete vertSegs{1}{1}
                            insert_segment(vertSegs, tempVertSeg);
                            break % Pick a new first vertical segment
                        end
                    case '2ndLineLeft'
                        success = move_segment_left(vertSegs{1}{k}, shift_amount);
                        if ~success
                            % Forget this line.
                            vertSegs = delete_segment(vertSegs, 1, k); % Delete vertSegs{1}{k}
                        else
                            tempVertSeg = vertSegs{1}{k};
                            vertSegs = delete_segment(vertSegs, 1, k); % Delete vertSegs{1}{k}
                            insert_segment(vertSegs, tempVertSeg);
                        end
                        % Keep checking current vertical segment
                    case 'NoFix'
                        if k == length(vertSegs{1})
                            % No fixes found where vertSegs{1}{1} moved, so
                            % remove it from consideration.
                            vertSegs = delete_segment(vertSegs, 1, 1); % Delete vertSegs{1}{1}
                        end % else keep checking current vertical segment
                    otherwise
                        error('Unexpected case.')
                end
            end
        end
        if length(vertSegs{1}) == 1
            vertSegs = vertSegs{2:end};
        end
    end
    
    % Reorganize the placements of vertical line segments in the system
    spaceVSegs(vSegs, colDims);
end

function vertSegs = delete_segment(vertSegs, i, j)
    vertSegs{i} = [vertSegs{i}{1:j-1}, vertSegs{i}{j+1:end}];
end

function vSegs = find_vertical_line_segments(lines)
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
                    ymin = (ynow < yold) * ynow + (yold < ynow) * yold; % min([ynow, yold])
                    ymax = (ynow > yold) * ynow + (yold > ynow) * yold; % max([ynow, yold])

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

function vSeg = update_vertical_segment(vSeg)
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

function vSegs = sort_vert_segs(vSegsList)
    % Input as unsorted list
    % Output as list of lists where for all i,j,k vSegs{i}{j} is right of
    %   vSegs{i+1}{k} and for all i,j vSegs{i}{j} begins higher than
    %   vertSegs{i}{j+1}
    
    vSegs = {};
    for i = 1:length(vSegsList)
        vertSegs = vSegsList{i};
        vSegs = insert_segment(vSegs, vertSeg);
    end
end

function vSegs = sort_vert_segs_old(vSegs)
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

function sortedVertSegs = insert_segment(sortedVertSegs, vertSeg)
    % INSERT_SEGMENT Inserts vertSeg appropriately into sortedVertSegs as per
    % the sorting of sort_vert_segs.
    
    for i = 1:length(sortedVertSegs)
        if ~isempty(sortedVertSegs{i})
            % if vertSeg right of sortedVertSegs{i}{1}
            % insert vertSeg before sortedVertSegs{i} in new group
            % inserted = true;
            % if vertSeg left of sortedVertSegs{i}{1}
            % keep checking
            % if vertSeg at sortedVertSegs{i}{1}
            % insert_segment_aux(sortedVertSegs{i}, vertSeg)
            % inserted = true;
            
            if vertSeg.x > sortedVertSegs{i}{1}.x
                sortedVertSegs = [sortedVertSegs{1:i-1}, {{vertSeg}}, sortedVertSegs{i:end}];
                inserted = true;
                break
            elseif vertSeg.x == sortedVertSegs{i}{1}.x
                insert_segment_aux(sortedVertSegs{i}, vertSeg)
                inserted = true;
                break
            end % else vertSeg.x < sortedVertSegs{i}{1}.x: Keep checking.
        end % else case should not occur possible, but would be ignored
    end
    if ~inserted
        % Add to end
        sortedVertSegs{end+1} = {vertSeg};
    end
    
    function sortedSegs = insert_segment_aux(sortedSegs, seg)
        % sortedSegs is a list of vSegs with common x parameter
        
        inserted2 = false;
        for j = 1:length(sortedSegs)
            % if seg above sortedSegs{j}
            % insert before
            % inserted2 = true;
            % else continue
            
            if seg.point1(2) < sortedSegs{j}.point1(2)
                sortedSegs = [sortedSegs{1:j-1}, {seg}, sortedSegs{j:end}];
                inserted2 = true;
                break
            end % else continue
        end
        if ~inserted2
            % Add to end
            sortedSegs{end+1} = seg;
        end
    end
end

function success = move_segment_left(vertSeg, shift_amount)
    % Only move if within some bounds defined by the rest of the line
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

    vSegs = sort_vert_segs_old(vSegs); %So that they can be rearranged somewhat logically

    for i = 1:length(vSegs)
        xnew = leftBound + (((rightBound - leftBound)*i)/(length(vSegs) + 1));
        index1 = vSegs{i}.pointIndex1;
        index2 = vSegs{i}.pointIndex2;
        vSegs{i}.pointsInLine(index1,1) = xnew;
        vSegs{i}.pointsInLine(index2,1) = xnew;

        set_param(vSegs{i}.line,'Points', vSegs{i}.pointsInLine); % Move points
        vSegs{i} = update_vertical_segment(vSegs{i});
    end
end
