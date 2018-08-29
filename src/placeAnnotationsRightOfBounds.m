function placeAnnotationsRightOfBounds(bounds, annotations, varargin)
    % PLACEANNOTATIONSRIGHTOFBOUNDS Move annotations to the right of the
    % given bounds. The annotations should not extend above the top of the
    % bounds. The annotations should not extend below the bottom of the
    % bounds where possible.
    %
    % Inputs:
    %   bounds          Bounds to place given blocks around. Given as a 1x4
    %                   vector: [left top right bottom].
    %   annotations     Vector of annotation handles.
    %   varargin        Parameter-Value pairs as detailed below.
    %
    % Parameter-Value pairs:
    %   Parameter: 'VerticalSpacing' - Space to leave between annotations
    %       vertically.
    %   Value:  Any number. Default: 50.
    %   Parameter: 'HorizontalSpacing' - Space to leave between annotations
    %       horizontally.
    %   Value:  Any number. Default: 50.
    %
    % Outputs:
    %   N/A
    %
    
    %% Input Handling
    
    % Handle parameter-value pairs
    VerticalSpacing = 50;
    HorizontalSpacing = 50;
    assert(mod(length(varargin),2) == 0, 'Even number of varargin arguments expected.')
    for i = 1:2:length(varargin)
        param = lower(varargin{i});
        value = lower(varargin{i+1});
        
        switch param
            case 'VerticalSpacing'
                assert(isnumeric(value), ...
                    ['Unexpected value for ' param ' parameter.'])
                VerticalSpacing = value;
            case 'HorizontalSpacing'
                assert(isnumeric(value), ...
                    ['Unexpected value for ' param ' parameter.'])
                HorizontalSpacing = value;
            otherwise
                error('Invalid parameter.')
        end
    end
    
    %%
    
    % First annotation position anchor
    top = bounds(2);
    left = bounds(3) + HorizontalSpacing;
    
    %
    widest = 0;
    
    for i = 1:length(annotations)
        note = annotations(i);
        
        % Find width and height to maintain during repositioning
        noteBounds = annotationBounds(note);
        
        width = noteBounds(3) - noteBounds(1);
        height = noteBounds(4) - noteBounds(2);
        
        % Get current position
        pos = get_param(note,'Position');
        % pos and noteBounds contain the same values, so adjust values will
        % always be 0
        adjustX = pos(1) - noteBounds(1);
        adjustY = pos(2) - noteBounds(2);
        
        if length(pos) == 2 % Older MATLAB version
            set_param(note,'Position', [left + adjustX, top + adjustY])
        elseif length(pos) == 4
            set_param(note,'Position', [left + adjustX, top + adjustY, left + adjustX + width, top + adjustY + height])
        else
            error(['Error in ', mfilename, '. Expecting 2 or 4 values in annotation position parameter.'])
        end
        
        if width > widest
            widest = width;
        end
        
        if top + height > bounds(4) % New annotation column to avoid extending too far down
            left = left + widest + HorizontalSpacing;
            top = bounds(2);
            widest = 0;
        else
            top = top + height + VerticalSpacing;
        end
    end
end