function quadrants = getWhichQuadrantBlocksAreIn(anchor, blocks)
    % GETWHICHQUADRANTBLOCKSAREIN Creates a map indicating which blocks are
    % left/right and above/below an anchor point.
    %
    % Inputs:
    %   anchor  A point in a Simulink diagram given as: [x y].
    %   blocks  List (cell array or vector) of blocks (fullnames or
    %           handles).
    %
    % Outputs:
    %   quadrants   A containers.Map object mapping from block handles of
    %               the given blocks to the quadrant its center is in
    %               relative to the anchor. The quadrant is represented by
    %               a point in the cartesian coordinate system:
    %                   [1, 1] - top-right
    %                   [1, -1] - bottom-right
    %                   [-1, 1] - top-left
    %                   [-1, -1] - bottom-left
    %               Left is favoured when the x-axis of the block's center
    %               is in line with the anchor. Top is favoured when the
    %               y-axis of the block's center is in line with the
    %               anchor.
    %
    
    blocks = inputToNumeric(blocks);
    
    quadrants = containers.Map();
    
    for i = 1:length(blocks)
        pos = get_param(blocks(i), 'Position');
        center = position_center(pos);
        if center(1) <= anchor(1)
            x = -1; % left
        else
            x = 1; % right
        end
        if center(2) <= anchor(2)
            y = 1; % top
        else
            y = -1; % bottom
        end
        quadrants(blocks(i)) = [x y];
    end
end