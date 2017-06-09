function handleAnnotations(layout, portlessInfo, annotations, note_rule)
% HANDLEANNOTATIONS Moves portless blocks to the right side of the system.
%   The annotations should not extend too far below the bottom of the
%   system.
%
%   Inputs:
%       layout          As returned by getRelativeLayout.
%       portlessInfo    As returned by getPortlessInfo.
%       annotations     Vector of all of the annotations in the system.
%       note_rule       Rule indicating what to do with annotations. See
%                       NOTE_RULE in config.txt.
%
%   Outputs:
%       N/A

if strcmp(note_rule, 'on-right')
    arbitraryBuffer = 50;
    
    ignorePortlessBlocks = false;
    [~,topBound,rightBound,botBound] = sideExtremes(layout, portlessInfo, ignorePortlessBlocks);
    
    top = topBound;
    right = rightBound + arbitraryBuffer;
    
    widest = 0;
    
    for i = 1:length(annotations)
        
        % Find width and height to maintain during repositioning
        pos = get_param(annotations(i),'Position');
        
        ver = version('-release');
        % Annotation position values used to only contain an anchor point
        % for top-left (given as [left, top]).
        %
        % Since the older version code seems to work in all versions,
        % the following should work in all versions even though I don't
        % know what version the change happened in (first new version is 
        % somewhere between 2012b and 2014b (inclusive)).
        isAnchorVer = str2num(ver(1:4)) < 2014 ...
            | (str2num(ver(1:4)) == 2014 & strcmp(str2num(ver(5)),'a')); % if pre-2014b
        
        % Annotation visual position used to depend on HorizontalAlignment
        % and VerticalAlignment parameters.
        %
        % First new version is somewhere between 2015b and 2016b
        % (inclusive).
        isPositionWithAlignmentVer = str2num(ver(1:4)) < 2016; % if pre-2016a
        
        if isAnchorVer %& isPositionWithAlignmentVer
            width = annotationStringWidth(annotations(i), get_param(annotations(i),'Text'));
            height = annotationStringHeight(annotations(i), get_param(annotations(i),'Text'));
            
            if strcmp(get_param(annotations(i), 'HorizontalAlignment'), 'center')
                adjustRight = ceil(0.5*width);
            elseif strcmp(get_param(annotations(i), 'HorizontalAlignment'), 'right')
                adjustRight = width;
            elseif strcmp(get_param(annotations(i), 'HorizontalAlignment'), 'left')
                adjustRight = 0;
            else
                error(['Error in ' mfilename ', unexpected HorizontalAlignment parameter value.']);
            end
            
            if strcmp(get_param(annotations(i), 'VerticalAlignment'), 'middle')
                adjustTop = ceil(0.5*height);
            elseif strcmp(get_param(annotations(i), 'VerticalAlignment'), 'bottom')
                adjustTop = height;
            elseif strcmp(get_param(annotations(i), 'VerticalAlignment'), 'top')
                adjustTop = 0;
            else
                error(['Error in ' mfilename ', unexpected VerticalAlignment parameter value.']);
            end
            
            effectiveRight = right + adjustRight;
            effectiveTop = top + adjustTop;

            % Place annotation below previous or in top-right
            set_param(annotations(i),'Position', [effectiveRight, effectiveTop])
        elseif isPositionWithAlignmentVer %& ~isAnchorVer
            width = pos(3) - pos(1);
            height = pos(4) - pos(2);
            
            if strcmp(get_param(annotations(i), 'HorizontalAlignment'), 'center')
                adjustRight = ceil(0.5*width);
            elseif strcmp(get_param(annotations(i), 'HorizontalAlignment'), 'right')
                adjustRight = width;
            elseif strcmp(get_param(annotations(i), 'HorizontalAlignment'), 'left')
                adjustRight = 0;
            else
                error(['Error in ' mfilename ', unexpected HorizontalAlignment parameter value.']);
            end
            
            if strcmp(get_param(annotations(i), 'VerticalAlignment'), 'middle')
                adjustTop = ceil(0.5*height);
            elseif strcmp(get_param(annotations(i), 'VerticalAlignment'), 'bottom')
                adjustTop = height;
            elseif strcmp(get_param(annotations(i), 'VerticalAlignment'), 'top')
                adjustTop = 0;
            else
                error(['Error in ' mfilename ', unexpected VerticalAlignment parameter value.']);
            end
            
            effectiveRight = right + adjustRight;
            effectiveTop = top + adjustTop;
            
            % Place annotation below previous or in top-right
            set_param(annotations(i),'Position', [effectiveRight, effectiveTop, effectiveRight + width, effectiveTop + height])
        else
            width = pos(3) - pos(1);
            height = pos(4) - pos(2);
            
            % Place annotation below previous or in top-right
            set_param(annotations(i),'Position', [right, top, right + width, top + height])
        end
        
        if width > widest
            widest = width;
        end
        
        if top + height > botBound % New annotation column to avoid extending too far down
            right = right + widest + arbitraryBuffer;
            top = topBound;
            widest = 0;
        else
            top = top + height + arbitraryBuffer;
        end
    end
elseif ~strcmp(note_rule, 'none')
    % Invalid config setting
    disp(['Error using ' mfilename ':' char(10) ...
        ' invalid config parameter: note_rule. Please fix in the config.txt.'])
    return
end % elseif 'none', then don't move the annotations at all
end