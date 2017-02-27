function [pos, xIncrease] = dimIncreaseForText(block, pos, varargin)
%DIMINCREASEFORTEXT Finds the amount to increase the right and left
%   positions of block to fit its text within it.
%
%   Inputs:
%       block       Full name of a block (character array).
%       pos         The current position coordinates of the block. Expected
%                   in same form as get_param(gcb, 'Position').
%       varargin    Indicates how to expand block to fit its text.
%                   'left' - expand toward the left of the system.
%                   'equal' - expand toward the left and right sides of the
%                   system equally.
%                   Other strings and no input result in a default of
%                   expanding toward the right of the system.
%                   Arguments beyond the first are ignored.
%
%   Output:
%       pos         New position of the block. Given in same form as
%                   get_param(gcb, 'Position').
%       xIncrease   Amount this block's width needed to be adjusted.

    xIncrease = getTextXIncrease(block, pos);

    if nargin > 0
        if strcmp(varargin{1}, 'left') 
            %Increase block size toward the left
            pos(1) = pos(1) - xIncrease;
        elseif strcmp(varargin{1}, 'equal')
            %Increase block size left and right equally
            pos(1) = pos(1) - xIncrease/2;
            pos(3) = pos(3) + xIncrease/2;
        else %Default case
            %Increase block size toward the right
            pos(3) = pos(3) + xIncrease;
        end
    end
end

function xIncrease = getTextXIncrease(block, pos)
%GETTEXTXINCREASE Finds the needed amount to increase the width of block 
%   in order to fit the text within it.
%
%   Input:
%       block       Full name of a block (character array).
%   
%   Output:
%       xIncrease   Amount to increase block width to fit its text.

    currentWidth = pos(3) - pos(1);

    neededWidth = getBlockTextWidth(block);
    
    xIncrease = max(0, neededWidth - currentWidth);
end