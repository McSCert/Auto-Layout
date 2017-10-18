function pos = setPositionAL(block, pos)
% SETPOSITIONAL Currently just sets block position. Use this function when
%   setting positions in AutoLayout in case we want to change this in some
%   way later.

set_param(block, 'Position', pos);
pos = get_param(block, 'Position'); % Since set_param won't always set it exactly

end