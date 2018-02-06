function [portlessInfo, smallOrLargeHalf] = getPortlessInfo(portless_rule, systemBlocks, portlessBlocks)
% GETPORTLESSINFO Find name and position about the portless blocks. For
%   position, also check which half of the system each block is in relative
%   to the others (checks top/bot vs. left/right half based on relevance
%   with portless_rule).
%
%   Inports:
%       portless_rule   Rule by which portless blocks should later be
%                       positioned. See PORTLESS_RULE in config.txt.
%       systemBlocks    List of all blocks in a system.
%       portlesBlocks   List of portless blocks in a system.
%
%   Outports:
%       portlessInfo        Struct of portless blocks' fullname and 
%                           position.
%       smallOrLargeHalf    Map relating blocks with the side of the system
%                           they should be placed on.

switch portless_rule
    case 'top'
        portlessInfo = struct('fullname', {}, ...
            'position', {});
        smallOrLargeHalf = containers.Map();
        
        for i = 1:length(portlessBlocks)
            smallOrLargeHalf(portlessBlocks{i}) = 'top';
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'left'
        portlessInfo = struct('fullname', {}, ...
            'position', {});
        smallOrLargeHalf = containers.Map();
        
        for i = 1:length(portlessBlocks)
            smallOrLargeHalf(portlessBlocks{i}) = 'left';
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'right'
        portlessInfo = struct('fullname', {}, ...
            'position', {});
        smallOrLargeHalf = containers.Map();
        
        for i = 1:length(portlessBlocks)
            smallOrLargeHalf(portlessBlocks{i}) = 'right';
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'same_half_vertical'
        [~,center] = systemCenter(systemBlocks);
        
        portlessInfo = struct('fullname', {}, ...
                    'position', {});
        smallOrLargeHalf = containers.Map();

        for i = 1:length(portlessBlocks)
            bool = onSide(portlessBlocks{i}, center, 'top');
            if bool
                smallOrLargeHalf(portlessBlocks{i}) = 'top';
            else
                smallOrLargeHalf(portlessBlocks{i}) = 'bottom';
            end
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'same_half_horizontal'
        [center,~] = systemCenter(systemBlocks);
        
        portlessInfo = struct('fullname', {}, ...
                    'position', {});
        smallOrLargeHalf = containers.Map();

        for i = 1:length(portlessBlocks)
            bool = onSide(portlessBlocks{i}, center, 'top');
            if bool
                smallOrLargeHalf(portlessBlocks{i}) = 'left';
            else
                smallOrLargeHalf(portlessBlocks{i}) = 'right';
            end
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    case 'bottom'
        portlessInfo = struct('fullname', {}, ...
            'position', {});
        smallOrLargeHalf = containers.Map();
        
        for i = 1:length(portlessBlocks)
            smallOrLargeHalf(portlessBlocks{i}) = 'bottom';
            portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                'position', []);
        end
    otherwise
        % Invalid portless_rule
        error(['portless_rule must be in the following ' ...
            '{''top'', ''left'', ''bot'', ''right'', ' ...
            '''same_half_vertical'', ''same_half_horizontal''}']);
        return
end
end

%%
%This function is related, but outdated.
%%
% function inLeftHalf = inLeftHalf(blocks,block)
% %INLEFTHALF Determines whether or not the middle of block is Left of the majority of blocks
% 
%     midXPos = getBlockSidePositions({block}, 5);
%     numBlocksOnRight = 0;
%     numBlocksOnLeft = 0;
%     for i = 1:length(blocks)
%         midXPos2 = getBlockSidePositions(blocks(i), 5);
%         if midXPos > midXPos2
%             numBlocksOnRight = numBlocksOnRight + 1;
%         elseif midXPos < midXPos2
%             numBlocksOnLeft = numBlocksOnLeft + 1;
%         end % Do nothing if equal 
%     end
%     if numBlocksOnLeft < numBlocksOnRight % if more blocks are above than below
%         inLeftHalf = true;
%     else
%         inLeftHalf = false;
%     end
% end