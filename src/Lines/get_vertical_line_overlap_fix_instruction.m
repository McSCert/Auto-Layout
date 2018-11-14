function message = get_vertical_line_overlap_fix_instruction(pair1, pair2)
    % GET_VERTICAL_LINE_OVERLAP_FIX_INSTRUCTION Determine how to prevent
    % vertical overlap of lines. See Outputs below for an explanation of the
    % output.
    %
    % Inputs:
    %   pair1   Pair of consecutive points in a Simulink line.
    %   pair2   As pair1.
    %
    % Outputs:
    %   message Possible results and meanings:
    %           'NoFix' - the pairs wouldn't benefit from being shifted
    %                     horizontally to prevent vertical overlap
    %           '1stLineLeft' - moving the first pair left will prevent the
    %                           overlap between the 2 lines
    %           '2ndLineLeft' - moving the second pair left will prevent the
    %                           overlap between the 2 lines
    %           'EitherLineLeft' - moving either line left will reduce the
    %                              overlap, but eliminate it (usually reduces to
    %                              a crossing)
    
    %% Some rules to help determine desired message
    % (used to inform the way this code should be written):
    %
    % These cases assume both pairs of points are vertical and share an x
    % coordinate. These ignored cases do not represent the problem this function
    % aims to fix.
    %
    % Let X represent the first pair and O represent the second.
    % X1 will represent the first point of X
    % X2 "    "         "   second "    "  X
    % O1 "    "         "   first  "    "  O
    % O2 "    "         "   second "    "  O
    % a > b will mean that point a is above b (though in Simulink's coordinate
    % system this is REVERSED - opposite symbols used in code)
    % Similar meanings are used for >=, <, <=, ==, ~=
    %
    % If X1 == O1,
    %   Move either
    % If X2 == O2,
    %   Move either
    %
    % For the remaining cases ASSUME X1 > O1
    % (similar rules can be applied if O1 > X1 and X1 == O1 is already
    % considered)
    %
    % If X1 == X2,
    %   No fix - one line is just a point
    % If O1 == O2,
    %   No fix - one line is just a point
    % If X1 and X2 are > O1 and O2,
    %   No fix - no overlap
    % ^ This case is mathematically written as the following 2 conditions:
    %   If X2 >= X1 && X1 > O1 && X1 > O2,
    %       No fix - no overlap
    %   If X1 >= X2 && X2 > O1 && X2 > O2,
    %       No fix - no overlap
    % If X1 > O1,
    %   If O2 >= X1 && X2 > O2,
    %       Move X left - standard case
    %   If O2 == X1 && O2 > X2 && X2 ~= O1
    %       Move X left - boundary case
    % If X1 > O1 && X1 > X2,
    %   If X2 > O2 && O1 >= X2,
    %       Move O left - standard case
    %   If O1 == X2 && O2 ~= X1 && O2 > X2
    %       Move O left - boundary case
    % In all other cases,
    %   Move either
    
    % Check if lines are vertical
    isVertical1 = pair1(1,1) == pair1(2,1);
    isVertical2 = pair2(1,1) == pair2(2,1);
    
    if ~isVertical1 || ~isVertical2
        message = 'NoFix';
    else
        % Check if lines share an x-coordinate
        sameColumn = pair1(1,1) == pair2(1,1);
        if ~sameColumn
            message = 'NoFix';
        else
            % From here on we only care about the y-coordinates.
            % So for pairN(i,j), j == 2 for the remaining cases.
            if pair1(1,2) == pair2(1,2) ...
                    || pair1(2,2) == pair2(2,2)
                message = 'EitherLineLeft';
            else
                if pair1(1,2) < pair2(1,2)
                    top = pair1(:, 2); % The 'top' pair begins higher than the 'bot' pair
                    bot = pair2(:, 2);
                    firstIsTop = true;
                elseif pair2(1,2) < pair1(1,2)
                    bot = pair1(:, 2); % The 'top' pair begins higher than the 'bot' pair
                    top = pair2(:, 2);
                    firstIsTop = false;
                else
                    error('This line of code is supposed to be unreachable.')
                end
                
                % top is akin to X in the comments near the top of this function
                % bot is akin to O
                if top(1) == top(2) ...
                        || bot(1) == bot(2) ...
                        || topAboveBot(top,bot)
                    tempMessage = 'NoFix';
                elseif (bot(2) <= top(1) && top(2) < bot(2)) ...
                        || (bot(2) == top(1) && bot(2) < top(2) && top(2) ~= bot(1))
                    tempMessage = 'MoveTopLeft';
                elseif top(1) < top(2) ...
                        && ((top(2) < bot(2) && bot(1) <= top(2)) ...
                        || (bot(1) == top(2) && bot(2) ~= top(1) && bot(2) < top(2)))
                    tempMessage = 'MoveBotLeft';
                else
                    tempMessage = 'EitherLineLeft';
                end
                
                switch tempMessage
                    case 'MoveTopLeft'
                        if firstIsTop
                            message = '1stLineLeft';
                        else
                            message = '2ndLineLeft';
                        end
                    case 'MoveBotLeft'
                        if firstIsTop
                            message = '2ndLineLeft';
                        else
                            message = '1stLineLeft';
                        end
                    otherwise
                        message = tempMessage;
                end
            end
        end
    end
end

function bool = topAboveBot(t,b)
    bool = (t(2) <= t(1) && t(1) < b(1) && t(1) < b(2)) ...
        || (t(1) <= t(2) && t(2) < b(1) && t(2) < b(2));
end