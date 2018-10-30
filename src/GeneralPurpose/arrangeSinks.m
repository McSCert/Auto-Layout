function [snks, snkPositions, didMove] = arrangeSinks(blk, doMove)
    % ARRANGESINKS Find the destination blocks of a given block and swap their
    % vertical positions to be ordered with respect to ports.
    %
    % If there are branches or if a destination has multiple inports, then no
    % arranging will be attempted, but positions to rearrange them will still be
    % given as output.
    %
    % Inputs:
    %   blk             Simulink block fullname or handle.
    %   doMove          Whether to move the blocks (1) or not (0). If not,
    %                   position information required to do the move is still
    %                   returned.
    %
    % Outputs:
    %   snks            (Sinks) Cell array of destination block names. If a line
    %                   is branched, only one of the destination blocks will be
    %                   returned.
    %   snkPositions    Array of positions to move the snks to.
    %   didMove         Whether the blocks were moved (1) or not (0). Note: If
    %                   doMove is false, didMove will always be false. If doMove
    %                   is true, didMove may still be false as a result of
    %                   branches/excessive ports (described above).
    %
    % Assumes blocks use the tradional block rotation, with inports on the left,
    % and outports on the right.
    
    % TODO: Add support for triggers and if actions
    
    % Find desired order
    ph = get_param(blk, 'PortHandles');
    out = ph.Outport;
    % orderedSnks = cell(1, length(out));
    % positions = zeros(length(out),4);
    % tops = zeros(length(out),1);
    orderedSnks = {};
    positions = [];
    tops = [];
    for i = 1:length(out)
        lh = get_param(out(i), 'Line');
        if lh ~= -1
            dst = get_param(lh, 'DstPortHandle');
            if dst ~= -1
                if isBranching(lh)
                    doMove = false;
                    dst = dst(1); % Arbitrarily select a destination to use
                end
                orderedSnks{end+1} = get_param(dst, 'Parent');
                
                snkph = get_param(orderedSnks{end}, 'PortHandles');
                snkin = snkph.Inport;
                if length(snkin) > 1
                    doMove = false;
                end
                
                positions(end+1,:) = get_param(orderedSnks{end}, 'Position');
                tops(end+1) = positions(end, 2);
            end
        end
    end

    % Get old order
    newTops = sort(tops);
    
    % Use old order to swap top positions to place in the desired order
    newPositions = zeros(length(newTops),4);
    for j = 1:length(newTops)
        newTop = newTops(j);
        newBot = newTops(j) + positions(j,4) - positions(j,2);
        newPositions(j,:) = [positions(j,1), newTop, positions(j,3), newBot];
    end
    
    snks = orderedSnks;
    snkPositions = newPositions;
    
    if doMove
        % Set positions
        for j = 1:length(snks)
            set_param(snks{j}, 'Position', snkPositions(j, :))
        end
        didMove = true;
    else
        didMove = false;
    end
end