function shiftAnnotations(annotations, shift)
    % SHIFTANNOTATIONS Reposition Simulink annotations with respect to their
    % current positions by adding a shift amount to their position values.
    %
    % Inputs:
    %   annotations     List (cell array or vector) of Simulink annotations.
    %   shift           1x4 vector to add to position value of annotations (in
    %                   older versions of MATLAB there are only 2 position
    %                   values so the extra 2 values will be ignored and don't
    %                   need to be given).
    
    %
    annotations = inputToNumeric(annotations);
    
    %
    for i = 1:length(annotations)
        a = annotations(i);
        pos = get_param(a, 'Position');
        
        switch length(pos)
            case 2 % Older MATLAB version
                set_param(a,'Position', pos+shift(1:2))
            case 4
                set_param(a,'Position', pos+shift)
            otherwise
                error(['Error in ', mfilename, '. Expecting 2 or 4 values in annotation position parameter.'])
        end
    end
end