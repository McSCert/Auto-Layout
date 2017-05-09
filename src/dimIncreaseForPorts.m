function [pos, yIncrease] = dimIncreaseForPorts(block, pos, varargin)
%DIMINCREASEFORPORTS Finds the amount to increase the top and bot
%   positions of block to reasonably accomodate its ports within it.
%
%   Inputs:
%       block       Full name of a block (character array).
%       pos         The current position coordinates of the block. Expected
%                   in same form as get_param(gcb, 'Position').
%       varargin{1} Indicates direction(s) to expand block to fit its
%                   ports.
%                   'top' - expand toward the top of the system.
%                   'equal' - expand toward the top and bot sides of the
%                   system equally.
%                   Other strings and no input result in a default of
%                   expanding toward the bot of the system.
%       varargin{2} Indicates desired space between ports. Defaults to 30.
%       varargin{3} Indicates desired space above/below the top/bottom
%                   ports of a block. Default uses a simple algorithm with
%                   a value of either 5 or 30 depending on the block.
%                   NOTE: varargin{2},{3} are just used to determine a net
%                   height (i.e. actual spacing between ports will not be
%                   controlled unfortunately)
%                   Arguments beyond the fifth are ignored.
%
%   Output:
%       pos         New position of the block. Given in same form as
%                   get_param(gcb, 'Position').
%       yIncrease   Amount this block's height should be adjusted.


%%
% notes (to delete):
% resize(block):
% if ~resized
%     find relevant blocks to this one
%     resize relevant blocks before current block
%     resize current block:
%         increase up until passing a signal, or height surpasses relevant blocks
%         increase down until passing a signal, or height surpasses relevant blocks
%         then increase evenly until minimum height
%             minimum height = max(# connections on a side)*min amount per port + buffer
%     mark as resized
%     adjust other blocks in same column as block
%%

if nargin == 4
    yIncrease = getPortYIncrease(block, pos, varargin{2});
elseif nargin > 4
    yIncrease = getPortYIncrease(block, pos, varargin{2}, varargin{3});
else
    yIncrease = getPortYIncrease(block, pos);
end

if nargin > 4
    if strcmp(varargin{1}, 'top')
        %Increase block size upward
        pos(2) = pos(2) - yIncrease;
    elseif strcmp(varargin{1}, 'equal')
        %Increase block size up and down equally
        pos(2) = pos(2) - yIncrease/2;
        pos(4) = pos(4) + yIncrease/2;
    else %Default case
        %Increase block size downward
        pos(4) = pos(4) + yIncrease;
    end
else %Default case
    %Increase block size downward
    pos(4) = pos(4) + yIncrease;
end
end

function yIncrease = getPortYIncrease(block, pos, varargin)
%GETPORTYINCREASE Finds the needed amount to increase the height of block
%   in order to reasonably accomodate its ports within it.
%
%   Input:
%       block       Full name of a block (character array).
%       pos         The current position coordinates of the block. Expected
%                   in same form as get_param(gcb, 'Position').
%       varargin{1} Indicates desired space between ports. Defaults to 30.
%       varargin{2} Indicates desired space above/below the top/bottom
%                   ports of a block. Default uses a simple algorithm with
%                   a value of either 5 or 30 depending on the block.
%                   NOTE: varargin{1},{2} are just used to determine a net
%                   height (i.e. actual spacing between ports will not be
%                   controlled unfortunately)
%                   Arguments beyond the forth are ignored.
%
%   Output:
%       yIncrease   Amount to increase block height for ports.

currentHeight = pos(4) - pos(2);

if nargin == 3
    desiredHeight = desiredHeightForPorts(block, varargin{2});
elseif nargin > 3
    desiredHeight = desiredHeightForPorts(block, varargin{2}, varargin{3});
else
    desiredHeight = desiredHeightForPorts(block);
end

yIncrease = max(0, desiredHeight - currentHeight);
end