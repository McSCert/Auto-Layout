function change_sum_shape(blocks, shape)
    % CHANGE_SUM_SHAPE Change the shape of sum blocks.
    %
    % Inputs:
    %   blocks  List (cell array or vector) of Simulink blocks (fullnames or
    %           handles). Non-Sum blocks will be ignored.
    %   shape   Char array of an icon shape to use.
    %
    % Outputs:
    %   N/A
    
    blocks = inputToNumeric(blocks);
    
    for i = 1:length(blocks)
        b = blocks(i);
        if strcmp(get_param(b,'BlockType'), 'Sum') % Check if Sum
            % Set the shape
            set_param(b,'IconShape', shape);
            
            if strcmp(shape, 'rectangular')
                % Remove spacers (|). They manipulate the positions of the input
                % ports.
                signs = strrep(get_param(b, 'ListOfSigns'), '|', '');
                set_param(b, 'ListOfSigns', signs);
            end
        end
    end
end