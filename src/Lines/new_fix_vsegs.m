function new_fix_vsegs(lines)
    vertSegsList = find_vertical_segments(lines);
    vertSegs = sort_vert_segs(vertSegsList);
    
    shift_amount = 5;
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
                            %forget this line
                        end
                        tempVertSeg = vertSegs{1}{1};
                        delete_segment(vertSegs, vertSegs{1}{1}); % No function required
                        insert_segment(vertSegs, tempVertSeg);
                        break % Pick a new first vertical segment
                    case 'EitherLineLeft'
                        success = move_segment_left(vertSegs{1}{1}, shift_amount);
                        if ~success
                            %try 2nd line
                        end
                        tempVertSeg = vertSegs{1}{1};
                        delete_segment(vertSegs, vertSegs{1}{1}); % No function required
                        insert_segment(vertSegs, tempVertSeg);
                        break % Pick a new first vertical segment
                    case '2ndLineLeft'
                        move_segment_left(vertSegs{1}{k}, shift_amount);
                        tempVertSeg = vertSegs{1}{k};
                        delete_segment(vertSegs, vertSegs{1}{k}); % No function required
                        insert_segment(vertSegs, tempVertSeg);
                        % Keep checking current vertical segment
                    case 'NoFix'
                        if k == length(vertSegs{1}{k})
                            % No fixes found where vertSegs{1}{1} moved, so
                            % remove it from consideration.
                            delete_segment(vertSegs, vertSegs{1}{1}); % No function required
                        end % else keep checking current vertical segment
                    otherwise
                        error('Unexpected case.')
                end
            end
        end
    end
end

function vSegs = sort_vert_segs(vSegsList)
    % Input as unsorted list
    % Output as list of lists where for all i,j,k vSegs{i}{j} is right of
    %   vSegs{i+1}{k} and for all i,j vSegs{i}{j} begins higher than
    %   vertSegs{i}{j+1}
    
end
    
function success = move_segment_left(vertSeg, shift_amount)
    % Only move if within some bounds defined by the rest of the line
end

function sortedVertSegs = insert_segment(sortedVertSegs, vertSeg)
    % INSERT_SEGMENT Inserts vertSeg appropriately into sortedVertSegs as per
    % the sorting of sort_vert_segs.
    
    for i = 1:length(sortedVertSegs)
        if ~isempty(sortedVertSegs{i})
            % if vertSeg right of sortedVertSegs{i}{1}
            % insert vertSeg before sortedVertSegs{i}
            % inserted = true;
            % if vertSeg left of sortedVertSegs{i}{1}
            % keep checking
            % if vertSeg at sortedVertSegs{i}{1}
            % insert_segment_aux(sortedVertSegs{i}, vertSeg)
            % inserted = true;
        end % else case should not occur possible, but would be ignored
    end
    if ~inserted
        % Add to end
        sortedVertSegs{end+1} = {vertSeg};
    end
    
    function sortedSegs = insert_segment_aux(sortedSegs, seg)
        for j = 1:length(sortedSegs)
            % if seg above sortedSegs{j}
            % insert before
            % inserted2 = true;
            % else continue
        end
        if ~inserted2
            % Add to end
            sortedSegs{end+1} = seg;
        end
    end
end