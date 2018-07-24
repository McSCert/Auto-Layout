function AutoLayout(objects)
    % AUTOLAYOUT Make a system more readable by automatically laying out
    % the given Simulink objects (blocks, lines, annotations) with respect
    % to each other. Other objects in the system are shifted to prevent
    % overlapping with the laid out objects.
    %
    % Inputs:
    %   blocks      List (vector or cell array) of Simulink objects
    %               (fullnames or handles).
    %   varargin    TODO - allow parameter to determine whether or not
    %               to shift other blocks in the system other than
    %               those selected.
    %
    % Outputs:
    %   N/A
    %
    % Example:
    %   >> open_system('AutoLayoutDemo')
    %   *Select everything in AutoLayoutDemo (ctrl + A)*
    %   >> AutoLayout(gcbs)
    %   Result: Modifies the AutoLayoutDemo system with one that performs
    %   the same functionally, but is laid out to be more readable.

    %%
    % Check number of arguments
    try
        assert(nargin == 1)
    catch
        error(' Wrong number of arguments.');
    end
    
    % Convert first argument to cell array of handles
    if ~iscell(objects)
        tmp_objects = cell(1,length(objects));
        assert(~ischar(objects), 'First input expected to be a vector or cell array not char array.')
        for i = 1:length(objects)
            tmp_objects{i} = objects(i);
        end
        objects = tmp_objects;
    end
    for i = 1:length(objects)
        objects{i} = get_param(objects{i}, 'Handle');
    end
    
    % Check first argument
    % 1) Determine the system in which the layout is taking place
    % 2) Check that all objects are in the system
    % 3) Check that model is unlocked
    % 4) If address has a LinkStatus, then check that it is 'none' or
    % 'inactive'
    if isempty(objects)
        disp('Nothing to simplify.')
    else
        % 1), 2)
        system = getCommonParent(objects);
        
        % 3)
        try
            assert(strcmp(get_param(bdroot(system), 'Lock'), 'off'));
        catch ME
            if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
                    strcmp(ME.identifier, 'MATLAB:assertion:failed')
                error('File is locked');
            end
        end
        
        % 4)
        try
            assert(any(strcmp(get_param(system, 'LinkStatus'), {'none','inactive'})), 'LinkStatus must be ''none'' or ''inactive''.')
        catch ME
            if ~strcmp(ME.identifier,'Simulink:Commands:ParamUnknown')
                rethrow(ME)
            end
        end
    end
    
    %%
    % Separate objects into the different types
    [blocks, lines, annotations, ports] = separate_objects_by_type(objects);
    assert(isempty(ports))
    
    %%
    % FUTURE WORK:
    % Use input parameter to constrain acceptable objects
    % Use input parameter to automatically add certain lines to the set of
    % objects depending on the blocks in objects 
    % Update set of objects as needed
    
    %%
    % Get bounds of objects
    orig_bounds = bounds_of_sim_objects(objects);
    
    %%
    % Layout selected objects ignoring others
    IsoLayout(blocks, annotations, '3rdparty'); % Automatic Isolated Layout
    
    %%
    % Get new bounds of objects
    new_bounds = bounds_of_sim_objects(objects);
    
    %%
    % Shift objects so that the center of their bounds is in the same spot
    % the center of the bounds was in to begin with
    
    % Get center of orginal bounds
    orig_center = position_center(orig_bounds);
    % Get center of new bounds
    new_center = position_center(new_bounds);
    % Get offset between new and original center
    center_offset = orig_center - new_center;
    % Shift objects by the offset
    shift_sim_objects(blocks, lines, annotations, center_offset);
    new_bounds = bounds_of_sim_objects(objects); % Update new bounds. Can't simply add the offset since shifting isn't always precise
    
    %%
    % Push remaining blocks and annotations in the system away from the new
    % bounds (if the bounds have expanded) or pull them toward the new
    % bounds (otherwise)
    
    % Get the objects that need to be shifted
    system_blocks = find_blocks_in_system(system);
    system_annotations = find_annotations_in_system(system);
    system_lines = find_lines_in_system(system);
    non_layout_blocks = vectorToCell(setdiff(system_blocks, cellToVector(blocks)'));
    non_layout_annotations = vectorToCell(setdiff(system_annotations, cellToVector(annotations)'));
    non_layout_lines = vectorToCell(setdiff(system_lines, cellToVector(lines)'));
    
    % Figure out how to shift blocks and annotations
    bound_shift = new_bounds - orig_bounds;
    adjustObjectsAroundLayout(non_layout_blocks, orig_bounds, bound_shift, 'block');
    adjustObjectsAroundLayout(non_layout_annotations, orig_bounds, bound_shift, 'annotation');
    
    % TODO - depending on input parameters redraw lines affected by
    % previous shifting
    redraw_lines(getfullname(system), 'autorouting', 'on')
end

function shift_sim_objects(blocks, lines, annotations, offset)
    %
    
    shiftBlocks(blocks, [offset, offset]); % Takes 1x4 vector
    shiftAnnotations(annotations, [offset, offset]); % Takes 1x4 vector
    shiftLines(lines, offset); % Takes 1x2 vector
end

function adjustObjectsAroundLayout(objects, orig_bounds, bound_shift, type)
    % objects are all of the given type
    %
    % Move objects with the shift in bounds between original and new
    % layout. The approach taken aims to keep objects in the same position
    % relative to the original layout. This approach will not handle
    % objects that were within the original bounds well, however, this is
    % not considered a big problem because of the degree of difficulty in
    % appropriately handling these cases even manually and further it's
    % also a bizarre case that should generally be avoidable. If it turns
    % out to need to be handled, a simple approach is to pick some
    % direction to shift the objects that were within the original bounds
    % and to do so as well as potentially increase the overall shift amount
    % in that direction accordingly.
    
    switch type
        case 'block'
            getBounds = @blockBounds;
            shiftObjects = @shiftBlocks;
        case 'line'
            getBounds = @lineBounds;
            shiftObjects = @shiftLines;
        case 'annotation'
            getBounds = @annotationBounds;
            shiftObjects = @shiftAnnotations;
        otherwise
            error('Unexpected object type.')
    end
    
    for i = 1:length(objects)
        object = objects{i};
        
        % Get bounds of the block
        my_bounds = getBounds(object);
        
        my_shift = [0 0 0 0];
        
        idx = 1; % Left
        if my_bounds(idx) < orig_bounds(idx)
            my_shift = my_shift + [bound_shift(idx) 0 bound_shift(idx) 0];
        end
        idx = 2; % Top
        if my_bounds(idx) < orig_bounds(idx)
            my_shift = my_shift + [0 bound_shift(idx) 0 bound_shift(idx)];
        end
        idx = 3; % Right
        if my_bounds(idx) > orig_bounds(idx)
            my_shift = my_shift + [bound_shift(idx) 0 bound_shift(idx) 0];
        end
        idx = 4; % Bottom
        if my_bounds(idx) > orig_bounds(idx)
            my_shift = my_shift + [0 bound_shift(idx) 0 bound_shift(idx)];
        end
        
        shiftObjects({object}, my_shift);
    end
end

function blocks = find_blocks_in_system(system)
    blocks = find_system(system, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'block', 'Parent', getfullname(system));
end
function annotations = find_annotations_in_system(system)
    annotations = find_system(system, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'annotation');
end
function lines = find_lines_in_system(system)
    lines = find_system(system, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'line');
end

function IsoLayout(blocks, annotations, mode)
    % Isolated layout of only the blocks and annotations given (relevant
    % lines will also be laid out, but otherwise nothing else in the system
    % is touched)
    
    if strcmp(mode, 'columnbased')
        columnBasedLayout(blocks, 'WidthMode', 'MaxColBlock', 'MethodForDesiredHeight', 'Compact', 'AlignmentType', 'Dest');
    elseif strcmp(mode, '3rdparty')
        mainLayout(blocks, annotations);
    else
        error('Unexpected mode.')
    end
    
end