function sels = gcls
%% gcls Get all currently selected lines
%   gcls Returns a cell array of the currently selected line handles.
%   M. Bialy

    objs = find_system(gcs,'LookUnderMasks','on','Findall','on','FollowLinks','on','Type','line','Selected','on');
    sels = flipud(objs);    % Flip to put in correct order (top to bottom position in model)
end