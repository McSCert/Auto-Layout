function sides_map = quadrants_map2sides_map(quadrants_map, axis)
    % QUADRANTS_MAP2SIDES_MAP Goes from one map type to another. See below
    % for details on the input and output map types.
    %
    % Input:
    %   quadrants_map   A containers.Map object mapping from block handles
    %                   of the given blocks to a quadrant. The quadrant is
    %                   represented by a point in the cartesian coordinate
    %                   system:
    %                       [1, 1] - top-right
    %                       [1, -1] - bottom-right
    %                       [-1, 1] - top-left
    %                       [-1, -1] - bottom-left
    %   axis            Indicates which value of quadrants_map to refer to
    %                   to decide where to place blocks.
    %                       'x' - means the side is 'left'/'right'
    %                       'y' - means the side is 'top'/'bottom'
    % Output:
    %   sides_map       Map from block handles to sides: {'left', 'right',
    %                   'top', 'bottom'}.
    %
    
    sides_map = containers.Map();
    keys = quadrants_map.keys;
    for i = 1:length(keys)
        quad = quadrants_map(keys{i});
        side = quad2side(quad, axis);
        sides_map(keys{i}) = side;
    end
end

function side = quad2side(quad, axis)
    switch axis
        case 'x'
            if quad(1) == 1
                side = 'right';
            elseif quad(1) == -1
                side = 'left';
            else
                error('Unexpected quadrant value in quadrant_map.')
            end
        case 'y'
            if quad(2) == 1
                side = 'top';
            elseif quad(2) == -1
                side = 'bottom';
            else
                error('Unexpected quadrant value in quadrant_map.')
            end
        otherwise
            error('Unexpected argument value.')
    end
end

function inv_sides_map = quadrants_map2inv_sides_map(quadrants_map, axis)
    % Similar quadrants_map2sides_map, but maps from side to list of
    % blocks.
    %
    % Input:
    %   quadrants_map   A containers.Map object mapping from block handles
    %                   of the given blocks to a quadrant. The quadrant is
    %                   represented by a point in the cartesian coordinate
    %                   system:
    %                       [1, 1] - top-right
    %                       [1, -1] - bottom-right
    %                       [-1, 1] - top-left
    %                       [-1, -1] - bottom-left
    %   axis            Indicates which value of quadrants_map to refer to
    %                   to decide where to place blocks.
    %                       'x' - means the side is 'left'/'right'
    %                       'y' - means the side is 'top'/'bottom'
    % Output:
    %   inv_sides_map   Map from sides {'left', 'right', 'top', 'bottom'}
    %                   to vectors of block handles to place on that side.
    %
    
    inv_sides_map = containers.Map();
    switch axis
        case 'x'
            inv_sides_map('left') = [];
            inv_sides_map('right') = [];
        case 'y'
            inv_sides_map('top') = [];
            inv_sides_map('bottom') = [];
        otherwise
            error('Unexpected argument value.')
    end
    
    keys = quadrants_map.keys;
    
    for i = 1:length(keys)
        quad = quadrants_map(keys{i});
        side = quad2side(quad, axis);
        inv_sides_map(side) = [inv_sides_map(side), keys{i}];
    end
end