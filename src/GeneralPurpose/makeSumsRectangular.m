function makeSumsRectangular(blocks)
    % MAKESUMSRECTANGULAR Change the shape of sum blocks to be rectangular.
    %
    %   Inputs:
    %       blocks  List (cell array or vector) of Simulink blocks (fullnames or
    %               handles). Non-Sum blocks will be ignored.
    %
    %   Outputs:
    %       N/A
    
    blocks = inputToNumeric(blocks);
    
    for i = 1:length(blocks)
        b = blocks(i);
        if strcmp(get_param(b,'BlockType'), 'Sum') % Check if Sum
            % Change to shape to be rectangular
            set_param(b,'IconShape', 'rectangular');
            % Remove spacers (|). They manipulate the positions of the input ports
            signs = strrep(get_param(b, 'ListOfSigns'), '|', '');
            set_param(b, 'ListOfSigns', signs);
        end
    end
end