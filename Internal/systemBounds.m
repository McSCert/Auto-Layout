function [leftBound,topBound,rightBound,botBound] = systemBounds(system, varargin)
% SYSTEMBOUNDS Finds the left, top, right, and bottom bounds among blocks,
%   lines, and annotations in a system. Does not account for showing names.
%
%   Inputs:
%       system      Name of a Simulink system.
%       varargin    This may be used to set which items to use instead of
%                   automatically checking everything in the system. All 3
%                   options are required if any are given.
%       varargin{1} List of blocks to use.
%       varargin{2} List of annotations to use.
%       varargin{3} List of lines to use.
%
%   Outputs:
%       leftBound   Left bound.
%       topBound    Top bound.
%       rightBound  Right bound.
%       botBound    Bottom bound.
%
%   Example 1:
%       [l,t,r,b] = systemBounds(gcs);
%   Example 2:
%       B = find_system(gcs,'SearchDepth',1); % B is a cell array
%       B = B(2:end);
%       A = {}; % Exclude annotations, [] or '' would also work
%       L = find_system(gcs,'FindAll','on','SearchDepth',1,'type','line');
%       [l,t,r,b] = systemBounds(gcs, B, A, L);

if nargin == 1
    % Get list of block, line, and annotation handles
    B = find_system(system,'FindAll','on','SearchDepth',1,'type','block');
    A = find_system(system,'FindAll','on','SearchDepth',1,'type','annotation');
    L = find_system(system,'FindAll','on','SearchDepth',1,'type','line');
else
    assert(nargin == 1 | nargin == 4, ['Error: There should be 1 or 4 inputs to ' mfilename '.m.']);
    B = varargin{1};
    A = varargin{2};
    L = varargin{3};
end

% Find the bounds for blocks, lines, and annotations separately
[lb,tb,rb,bb] = blocksBounds(B);
[la,ta,ra,ba] = annotationsBounds(A);
[ll,tl,rl,bl] = linesBounds(L);

% Find the most extreme bounds
leftBound   = min([lb,ll,la]);
topBound    = min([tb,tl,ta]);
rightBound  = max([rb,rl,ra]);
botBound    = max([bb,bl,ba]);

end

% TODO - create function to do the common parts of
% blocksBounds, annotationsBounds, and linesBounds
% Only difference is how they calculate itemBounds

function [leftBound,topBound,rightBound,botBound] = blocksBounds(blocks)
% BLOCKSBOUNDS Finds the left, top, right, and bottom bounds among a set of
%   blocks.
%
%   Inputs:
%       blocks      Cell array of full block names/handles.
%
%   Outputs:
%       leftBound   Left bound of blocks.
%       topBound    Top bound of blocks.
%       rightBound  Right bound of blocks.
%       botBound    Bottom bound of blocks.
%
%   Example 1:
%       B = find_system(gcs,'FindAll','on','SearchDepth',1,'type','block');
%       [leftB,topB,rightB,bottomB] = blocksBounds(B);
%   Example 2:
%       B = find_system(gcs,'SearchDepth',1); % B is a cell array
%       B = B(2:end);
%       [leftB,topB,rightB,bottomB] = blocksBounds(B);

% Set default bounds
rightBound = -32767;    % Simulink's left-most coordinate (NOT RIGHT-MOST)
leftBound = 32767;      % Simulink's right-most coordinate
botBound = -32767;      % Simulink's top-most coordinate
topBound = 32767;       % Simulink's bottom-most coordinate

% Loop through blocks to find the most extreme points of each
for i = 1:length(blocks)
    if iscell(blocks(i))
        itemBounds = get_param(blocks{i}, 'Position');
    else
        itemBounds = get_param(blocks(i), 'Position');
    end
    
    % itemBounds is a vector of coordinates: [left top right bottom]
    
    if itemBounds(3) > rightBound
        % The block has the new right-most position
        rightBound = itemBounds(3);
    end
    if itemBounds(1) < leftBound
        % The block has the new left-most position
        leftBound = itemBounds(1);
    end
    
    if itemBounds(4) > botBound
        % The block has the new bottom-most position
        botBound = itemBounds(4);
    end
    if itemBounds(2) < topBound
        % The block has the new top-most position
        topBound = itemBounds(2);
    end
end
end

function [leftBound,topBound,rightBound,botBound] = annotationsBounds(annotations)
% ANNOTATIONSBOUNDS Finds the left, top, right, and bottom bounds among a
%   set of annotations.
%
%   Inputs:
%       annotations List of annotation handles.
%
%   Outputs:
%       leftBound   Left bound of annotations.
%       topBound    Top bound of annotations.
%       rightBound  Right bound of annotations.
%       botBound    Bottom bound of annotations.
%
%   Example:
%       A = find_system(gcs,'FindAll','on','SearchDepth',1,'type','annotation');
%       [leftA,topA,rightA,bottomA] = annotationsBounds(A);

% Set default bounds
rightBound = -32767;    % Simulink's left-most coordinate (NOT RIGHT-MOST)
leftBound = 32767;      % Simulink's right-most coordinate
botBound = -32767;      % Simulink's top-most coordinate
topBound = 32767;       % Simulink's bottom-most coordinate

% Loop through annotations to find the most extreme points of each
for i = 1:length(annotations)
    if iscell(annotations(i))
        itemBounds = get_param(annotations{i}, 'Position');
    else
        itemBounds = get_param(annotations(i), 'Position');
    end
    
    % itemBounds is a vector of coordinates: [left top right bottom]
    
    if itemBounds(3) > rightBound
        % The block has the new right-most position
        rightBound = itemBounds(3);
    end
    if itemBounds(1) < leftBound
        % The block has the new left-most position
        leftBound = itemBounds(1);
    end
    
    if itemBounds(4) > botBound
        % The block has the new bottom-most position
        botBound = itemBounds(4);
    end
    if itemBounds(2) < topBound
        % The block has the new top-most position
        topBound = itemBounds(2);
    end
end
end

function [leftBound,topBound,rightBound,botBound] = linesBounds(lines)
% LINESBOUNDS Finds the left, top, right, and bottom bounds among a
%   set of lines.
%
%   Inputs:
%       lines       List of line handles.
%
%   Outputs:
%       leftBound   Left bound of lines.
%       topBound    Top bound of lines.
%       rightBound  Right bound of lines.
%       botBound    Bottom bound of lines.
%
%   Example:
%       L = find_system(gcs,'FindAll','on','SearchDepth',1,'type','line');
%       [leftL,topL,rightL,bottomL] = linesBounds(L);

% Set default bounds
rightBound = -32767;    % Simulink's left-most coordinate (NOT RIGHT-MOST)
leftBound = 32767;      % Simulink's right-most coordinate
botBound = -32767;      % Simulink's top-most coordinate
topBound = 32767;       % Simulink's bottom-most coordinate

% Loop through lines to find the most extreme points of each
for i = 1:length(lines)
    if iscell(lines(i))
        points = get_param(lines{i}, 'Points');
        itemBounds = [min(points(:,1)) min(points(:,2)) max(points(:,1)) max(points(:,2))];
    else
        points = get_param(lines(i), 'Points');
        itemBounds = [min(points(:,1)) min(points(:,2)) max(points(:,1)) max(points(:,2))];
    end
    
    % itemBounds is a vector of coordinates: [left top right bottom]
    
    if itemBounds(3) > rightBound
        % The block has the new right-most position
        rightBound = itemBounds(3);
    end
    if itemBounds(1) < leftBound
        % The block has the new left-most position
        leftBound = itemBounds(1);
    end
    
    if itemBounds(4) > botBound
        % The block has the new bottom-most position
        botBound = itemBounds(4);
    end
    if itemBounds(2) < topBound
        % The block has the new top-most position
        topBound = itemBounds(2);
    end
end
end