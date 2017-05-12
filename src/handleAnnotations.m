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
        width = pos(3) - pos(1);
        height = pos(4) - pos(2);
        
        if width > widest
            widest = width;
        end
        
        % Place annotation below previous or in top-right
        set_param(annotations(i),'Position', [right, top, right + width, top + height])
        
        if top + height > botBound % New annotation column to avoid extending too far down
            right = right + widest + arbitraryBuffer;
            top = topBound;
            widest = 0;
        end
        
        top = top + height + arbitraryBuffer;
        
    end
elseif ~strcmp(note_rule, 'none')
    % Invalid config setting
    disp(['Error using ' mfilename ':' char(10) ...
        ' invalid config parameter: note_rule. Please fix in the config.txt.'])
    return
end % elseif 'none', then don't move the annotations at all
end