function setNamePlacements(blocks,varargin)
% SETNAMEPLACEMENTS Set the name placements for Simulink blocks. Default 
%   will place names along the bottom.
%
%   Inputs:
%       blocks      Cell array of blocks to use to find segments.
%       varargin    Character array indicating where to place a block's 
%                   name with respect to it. Options correspond with the 
%                   'NamePlacement' block property e.g. 'normal' (default)
%                   and 'alternate'.
%
%   Example:
%       setNamePlacements(gcbs,'normal')
%       setNamePlacements(gcbs,'alternate')

if nargin > 1
    namePlacement = varargin{1};
else
    namePlacement = 'normal';
end %ignore inputs beyond the second

for i = 1:length(blocks)
    set_param(blocks{i}, 'NamePlacement', namePlacement);
end
end