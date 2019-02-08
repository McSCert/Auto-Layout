function remove_vertical_line_overlap(lines, varargin)
    % REMOVE_VERTICAL_LINE_OVERLAP Offset vertical line segments to prevent them
    % from overlapping with each other.
    % 
    % Inputs:
    %   lines       Vector of Simulink lines.
    %   varargin    Parameter-Value pairs as detailed below.
    %
    % Outputs:
    %   N/A
    %
    % Parameter-Value pairs:
    %   Parameter: 'ShiftAmount' - Amount to shift vertical segments by.
    %   Value: Positive integer. Default: 3.
    %   Parameter: 'Mode' - Affects the approach used to determine how lines
    %       need to be moved with respect to each other.
    %   Value:  'PairByPair' - Handles one pair of lines at a time.
    %           'AllOverlappingTogether' - (Default) Handles all overlapping
    %               lines together.
    %
    
    % TODO - Param-Val pairs to add support for in the future
    %   Parameter: 'ShiftBounds' - Left and right bounds for where lines can be
    %       shifted to.
    %   Value: 1x2 array with left bound given first. Default: No bounds used.
    %   Parameter: 'ShiftType'
    %   Value:  'Even' - Shift evenly between the ShiftBounds (requires ShiftBounds
    %               to be given first).
    %           'Left' - (Default) Shift lines left.
    %           'Right' - Shift lines right.
    %   Parameter: 'OverlapDefn' - Used to determine what is considered an
    %       overlap.
    %   Value:  'Literal' - (Default) Lines must be directly overlapping.
    %           'Close' - If ShiftAmount pixels or less off of a direct overlap.
    
    % TODO - Currently expect issues if flow is from right to left (test and
    % fix).
    
    % Input Handling
    ShiftAmount = getInput('ShiftAmount', varargin, 3);
    assert(isnumeric(ShiftAmount))
    Mode = lower(getInput('Mode', varargin, 'AllOverlappingTogether'));
    assert(any(strcmpi(Mode, {'PairByPair', 'AllOverlappingTogether'})))
    
    switch Mode
        case lower('AllOverlappingTogether')
            remove_vertical_line_overlap_all_overlapping_together(lines, ShiftAmount)
        case lower('PairByPair')
            remove_vertical_line_overlap_pair_by_pair(lines, ShiftAmount);
        otherwise
            error('Error: Unexpected parameter value.')
    end
end

function remove_vertical_line_overlap_all_overlapping_together(lines, ShiftAmount)
    %
    vertSegsList = find_vertical_line_segments(lines);
    vertSegs = sort_vert_segs(vertSegsList);
    
    % Reorganize the placements of vertical line segments in the system
    while ~isempty(vertSegs)
        % Until there are no groups of candidates to fix.
        % Loop invariant: Each iteration removes at least one segment from
        % vertSegs.
        
        numOfSegs = get_total_num_of_vertSegs(vertSegs);
        
        i = 1;
        shiftList = zeros(1,length(vertSegs{i}));
        dontCarePairs = []; % nx2 list of indices where 1 of the 2 should be moved
        for j = 1:length(vertSegs{i}) - 1
            if true %~shiftList(j) % may be able to use some condition to skip this sometimes
                for k = j+1:length(vertSegs{i})
                    % For each pair in vertSegs{i}
                    if true %~shiftList(k) % may be able to use some condition to skip this sometimes
                        
                        instruction = get_vertical_line_overlap_fix_instruction( ...
                            [vertSegs{i}{j}.point1; vertSegs{i}{j}.point2], ...
                            [vertSegs{i}{k}.point1; vertSegs{i}{k}.point2]);
                        
                        switch instruction
                            case '1stLineLeft'
                                shiftList(j) = 1;
                                break; % Advance to next j
                            case '2ndLineLeft'
                                shiftList(k) = 1;
                            case 'EitherLineLeft'
                                dontCarePairs(end+1,:) = [j k];
                            case 'NoFix'
                                % Continue
                            otherwise
                                error('Unexpected case.')
                        end
                    end
                end
            end
        end
        % Choose which segments in dontCarePairs to shift.
        % TODO: Improve selection method to select the minimum necessary to
        % move.
        for m = 1:size(dontCarePairs, 1)
            if shiftList(dontCarePairs(m,1)) || shiftList(dontCarePairs(m,2))
                % Pair is already addressed
            else
                % Arbitrarily choose the first indexed to be shifted.
                shiftList(dontCarePairs(m,1)) = 1;
            end
        end
        %
        if all(shiftList)
            % Can't shift all because then nothing will change.
            % Arbitrarily choose first to not shift.
            shiftList(1) = 0;
        end
        
        %
        shiftList2 = zeros(1,length(shiftList)); % To be populated with things to try shifting on a second pass
        insertIdxs = zeros(1,length(shiftList));
        for j = find(shiftList)
            [success, vertSegs{i}{j}] = move_segment_left(vertSegs{i}{j}, ShiftAmount);
            if ~success
                % Forget this line.
                
                if ~isempty(dontCarePairs)
                    %% Search dontCarePairs to see which need to be moved (in the
                    % second pass) since this one didn't move.
                    
                    % Assume j is in the first column of dontCarePairs:
                    jIdxs1 = find(j == dontCarePairs(:,1)); % Indexes with j in the 1st column
                    pairVals1 = dontCarePairs(jIdxs1,2); % Values of numbers paired with j (given the assumption)
                    shiftList2(pairVals1) = 1;
                    
                    % Assume j is in the second fcolumn of dontCarePairs:
                    jIdxs2 = find(j == dontCarePairs(:,2)); % Indexes with j in the 2nd column
                    pairVals2 = dontCarePairs(jIdxs2,1); % Values of numbers paired with j (given the assumption);
                    shiftList2(pairVals2) = 1;
                end
            else
                insertIdxs(j) = 1;
            end
        end
        for j = find(shiftList2)
            if shiftList(j)
                % Already tried on first pass
            else
                [success, vertSegs{i}{j}] = move_segment_left(vertSegs{i}{j}, ShiftAmount);
                if ~success
                    % Forget this line.
                else
                    insertIdxs(j) = 1;
                end
            end
        end
        
        % Remove unmoved segments and update vertSegs for the remaining
        % segments.
        tempVertSegs = vertSegs;
        vertSegs = vertSegs(2:end); % Removes the first group of vertSegs
        for j = find(insertIdxs)
            tempVertSeg = tempVertSegs{i}{j};
            [vertSegs, ~] = insert_segment(vertSegs, tempVertSeg);
        end
        
        newNumOfSegs = get_total_num_of_vertSegs(vertSegs);
        assert(newNumOfSegs < numOfSegs) % Asserting the loop invariant
    end
end

function remove_vertical_line_overlap_pair_by_pair(lines, ShiftAmount)
    %
    vertSegsList = find_vertical_line_segments(lines);
    vertSegs = sort_vert_segs(vertSegsList);
    
    % Reorganize the placements of vertical line segments in the system
    while ~isempty(vertSegs)
        % Until there are no groups of candidates to fix.
        % Loop invariant: Each iteration removes at least one segment from
        % vertSegs.
        
        numOfSegs = get_total_num_of_vertSegs(vertSegs);
        
        % Initialize indexes to refer to two vertical segments.
        %   vertSegs{i}{j} will refer to the 'first'
        %   vertSegs{i}{k} will refer to the 'second'
        % (the first segment is updated when the old one is removed from
        % vertSegs, the second segment updates this way and also by incrementing
        % k).
        i = 1; j = 1; k = 2;
        
        while 2 <= length(vertSegs{i})
            % Until the ith group of candidates has 1 or no members.
            % Loop invariant: Each iteration removes at least one segment from
            % vertSegs{i}, but leaves at least one segment (this does not
            % prohibit moving the removed segment(s) to another location in
            % vertSegs).
            
            lengthOfSegsI = length(vertSegs{i});
            
            k = 2;
            flag_firstSegUpdated = false; % Flag indicating when the first vertical segment being looked at changes
            while ~flag_firstSegUpdated && k <= length(vertSegs{i})
                % Continue until there are no more pairs to make with the
                % current first segment, or until the first segment changes.
                % Loop invariant: k increases
                
                % One segment is removed from vertSegs{i} on each iteration
                % unless the instruction is NoFix.
                % One segment is always removed from vertSegs{i} on the final
                % iteration (this does not prohibit moving the removed
                % segment(s) to another location in vertSegs).
                
                instruction = get_vertical_line_overlap_fix_instruction( ...
                    [vertSegs{i}{j}.point1; vertSegs{i}{j}.point2], ...
                    [vertSegs{i}{k}.point1; vertSegs{i}{k}.point2]);
                switch instruction
                    case '1stLineLeft'
                        [success, vertSegs{i}{j}] = move_segment_left(vertSegs{i}{j}, ShiftAmount);
                        if ~success
                            % Forget this line.
                            vertSegs = delete_segment(vertSegs, i, j); % Delete vertSegs{i}{j}
                        else
                            tempVertSeg = vertSegs{i}{j};
                            vertSegs = delete_segment(vertSegs, i, j); % Delete vertSegs{i}{j}
                            [vertSegs, insertIndex] = insert_segment(vertSegs, tempVertSeg);
                            assert(insertIndex(1) > i) % Failed to move line segment left or it was inserted improperly
                        end
                        
                        flag_firstSegUpdated = true;
                    case 'EitherLineLeft'
                        [success, vertSegs{i}{j}] = move_segment_left(vertSegs{i}{j}, ShiftAmount);
                        if ~success
                            % Try 2nd line.
                            [success2, vertSegs{i}{k}] = move_segment_left(vertSegs{i}{k}, ShiftAmount);
                            if ~success2
                                % Forget this line.
                                vertSegs = delete_segment(vertSegs, i, k); % Delete vertSegs{i}{k}
                            else
                                tempVertSeg = vertSegs{i}{k};
                                vertSegs = delete_segment(vertSegs, i, k); % Delete vertSegs{i}{k}
                                [vertSegs, insertIndex] = insert_segment(vertSegs, tempVertSeg);
                                assert(insertIndex(1) > i) % Failed to move line segment left or it was inserted improperly
                            end
                        else
                            tempVertSeg = vertSegs{i}{j};
                            vertSegs = delete_segment(vertSegs, i, j); % Delete vertSegs{i}{j}
                            [vertSegs, insertIndex] = insert_segment(vertSegs, tempVertSeg);
                            assert(insertIndex(1) > i) % Failed to move line segment left or it was inserted improperly
                            
                            flag_firstSegUpdated = true;
                        end
                    case '2ndLineLeft'
                        [success, vertSegs{i}{k}] = move_segment_left(vertSegs{i}{k}, ShiftAmount);
                        if ~success
                            % Forget this line.
                            vertSegs = delete_segment(vertSegs, i, k); % Delete vertSegs{i}{k}
                        else
                            tempVertSeg = vertSegs{i}{k};
                            vertSegs = delete_segment(vertSegs, i, k); % Delete vertSegs{i}{k}
                            [vertSegs, insertIndex] = insert_segment(vertSegs, tempVertSeg);
                            assert(insertIndex(1) > i) % Failed to move line segment left or it was inserted improperly
                        end
                    case 'NoFix'
                        if k == length(vertSegs{i})
                            % No fixes found where vertSegs{i}{j} moved (for any
                            % k), so remove it from consideration.
                            vertSegs = delete_segment(vertSegs, i, j); % Delete vertSegs{i}{j}
                            
                            flag_firstSegUpdated = true;
                        end
                    otherwise
                        error('Unexpected case.')
                end
                k = k + 1; % Loop invariant
            end
            
            newLengthOfSegsI = length(vertSegs{i});
            assert(newLengthOfSegsI < lengthOfSegsI) % Asserting the loop invariant
        end
        assert(length(vertSegs{i}) == 1)
        vertSegs = vertSegs(2:end); % Removes a segment from vertSegs
        
        newNumOfSegs = get_total_num_of_vertSegs(vertSegs);
        assert(newNumOfSegs < numOfSegs) % Asserting the loop invariant
    end
end

function num = get_total_num_of_vertSegs(vertSegs)
    % Gets number of vertical line segments contained in the vertSegs structure.
    num = 0;
    for i = 1:length(vertSegs)
        num = num + length(vertSegs{i});
    end
end

function vertSegs = delete_segment(vertSegs, i, j)
    vertSegs{i} = [vertSegs{i}(1:j-1), vertSegs{i}(j+1:end)];
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

function vSegs = sort_vert_segs(vSegsList)
    % Input as unsorted list of vertical line segments
    % Output as list of lists where for all i,j,k vSegs{i}{j} is right of
    %   vSegs{i+1}{k} and for all i,j vSegs{i}{j} begins higher than
    %   vertSegs{i}{j+1}
    
    vSegs = {};
    for i = 1:length(vSegsList)
        vertSeg = vSegsList{i};
        vSegs = insert_segment(vSegs, vertSeg);
    end
end

function [sortedVertSegs, index] = insert_segment(sortedVertSegs, vertSeg)
    % INSERT_SEGMENT Inserts vertSeg appropriately into sortedVertSegs as per
    % the sorting of sort_vert_segs.
    %
    % Inputs:
    %   sortedVertSegs
    %   vertSeg         Segment to insert.
    %
    % Outputs:
    %   sortedVertSegs
    %   index           Index of the inserted segment in the resulting
    %                   sortedVertSegs as a vector such that
    %                   sortedVertSegs{index(1)}{index(2)} returns the segment.
    
    inserted = false;
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
                sortedVertSegs = [sortedVertSegs(1:i-1), {{vertSeg}}, sortedVertSegs(i:end)];
                index = [i,1];
                inserted = true;
                break
            elseif vertSeg.x == sortedVertSegs{i}{1}.x
                [sortedVertSegs{i}, index2] = insert_segment_aux(sortedVertSegs{i}, vertSeg);
                index = [i, index2];
                inserted = true;
                break
            end % else vertSeg.x < sortedVertSegs{i}{1}.x: Keep checking.
        end % else case should not occur possible, but would be ignored
    end
    if ~inserted
        % Add to end
        sortedVertSegs{end+1} = {vertSeg};
        index = [length(sortedVertSegs),1];
    end
    
    function [sortedSegs, idx2] = insert_segment_aux(sortedSegs, seg)
        % sortedSegs is a list of vSegs with common x parameter
        
        inserted2 = false;
        for j = 1:length(sortedSegs)
            % if seg above sortedSegs{j}
            % insert before
            % inserted2 = true;
            % else continue
            
            if seg.point1(2) < sortedSegs{j}.point1(2)
                sortedSegs = [sortedSegs(1:j-1), {seg}, sortedSegs(j:end)];
                idx2 = j;
                inserted2 = true;
                break
            end % else continue
        end
        if ~inserted2
            % Add to end
            sortedSegs{end+1} = seg;
            idx2 = length(sortedSegs);
        end
    end
end

function [success, vertSeg] = move_segment_left(vertSeg, shift_amount)
    % Only move if within some bounds defined by the rest of the line
    
    xnew = vertSeg.x - shift_amount;
    index1 = vertSeg.pointIndex1;
    index2 = vertSeg.pointIndex2;
    if index1 ~= 1 && vertSeg.x > vertSeg.pointsInLine(index1-1,1)
        vertSeg.pointsInLine(index1,1) = xnew;
        vertSeg.pointsInLine(index2,1) = xnew;
        
        set_param(vertSeg.line, 'Points', vertSeg.pointsInLine); % Move points
        vertSeg = update_vertical_segment(vertSeg);
        success = true;
    else
        success = false;
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

%% Old functions (still relevant for reference)
function vSegs = sort_vert_segs_old(vSegs)
    % Sorts vertical line segments, vSegs, giving priority to lowest x value,
    % and secondary priority to largest ymax value
    % no third level of priority is applied
    
    % Sort vSegs from smallest x to largest x
    xVals = zeros(1,length(vSegs));
    for i = 1:length(vSegs)
        xVals(i) = vSegs{i}.x;
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
