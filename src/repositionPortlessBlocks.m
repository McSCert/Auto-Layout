function portlessInfo = repositionPortlessBlocks(portlessInfo, layout, portless_rule, smallOrLargeHalf)

ignorePortlessBlocks = true;
[leftBound,topBound,rightBound,botBound] = sideExtremes(layout, portlessInfo, ignorePortlessBlocks);

vertSpace = 10; % Space to leave between blocks vertically
horzSpace = 10; % Space to leave between blocks horizontally

switch portless_rule
    case 'left'
        %         doCheck = false;
        portlessInfo = horzReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,'left');
    case 'top'
        %         doCheck = false;
        portlessInfo = vertReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,'top');
    case 'right'
        %         doCheck = false;
        portlessInfo = horzReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,'right');
    case 'bottom'
        %         doCheck = false;
        portlessInfo = vertReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,'bottom');
    case 'same_half_vertical'
        %         doCheck = true;
        portlessInfo = vertReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,'top');
        portlessInfo = vertReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,'bottom');
    case 'same_half_horizontal'
        %         doCheck = true;
        portlessInfo = horzReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,'left');
        portlessInfo = horzReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,'right');
end

end

function newPortlessInfo = sortPortlessInfo(portlessInfo)
% Sort portlessInfo by block types

blockTypes = {};
newPortlessInfo = {};

for i = 1:length(portlessInfo) % for each portless block
    isNewType = ~AinB(get_param(portlessInfo{i}.fullname,'BlockType'), blockTypes);
    if isNewType % if block type is new to blockTypes
        
        % Record block type
        blockTypes{end+1} = get_param(portlessInfo{i}.fullname,'BlockType');
        newPortlessInfo{end+1} = portlessInfo{i}; % (have to add each portlessInfo to the new one once)
        for j = i+1:length(portlessInfo) % for remaining portless blocks
            if strcmp(get_param(portlessInfo{j}.fullname,'BlockType'),blockTypes{end}) % if type matches
                % Add the portlessInfo
                newPortlessInfo{end+1} = portlessInfo{j};
            end
        end % All of blockTypes{end} should have been added now, so move on to find the next type
    end
end

end

function bool = AinB(A,B)
% AINB Returns true if character vector, A, is an element in cell array, B.
% There's probably a predefined MATLAB function for this that should be
%   used instead...

bool = false;
if ischar(A) && iscell(B)
    for i = 1:length(B)
        if ischar(B{i}) && strcmp(A,B{i})
            bool = true;
            return
        end
    end
end
end

% function portlessInfo = reposPortlessOnHalf(portlessInfo,layout,smallOrLargeHalf,side)
%
% ignorePortlessBlocks = true;
% [rightBound,leftBound,botBound,topBound] = sideExtremes(layout, portlessInfo, ignorePortlessBlocks);
%
% vertSpace = 10; % Space to leave between blocks vertically
% horzSpace = 10; % Space to leave between blocks horizontally
%
% if strcmp(side, 'left') || strcmp(side, 'right')
%     portlessInfo = horzReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,side);
% elseif strcmp(side, 'top') || strcmp(side, 'bottom')
%     portlessInfo = vertReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,side);
% end
%
% % switch side
% %     case 'left'
% %         portlessInfo = horzReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,botBound,vertSpace,horzSpace);
% %     case 'top'
% %         portlessInfo = vertReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,vertSpace,horzSpace);
% %     case 'right'
% %         portlessInfo = reposPortlessOnRight(portlessInfo,smallOrLargeHalf,topBound,rightBound,botBound,vertSpace,horzSpace);
% %     case 'bottom'
% %         portlessInfo = reposPortlessOnBot(portlessInfo,smallOrLargeHalf,leftBound,rightBound,botBound,vertSpace,horzSpace);
% % end
%
% end

function portlessInfo = vertReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,vertSide)

portlessInfo = sortPortlessInfo(portlessInfo);

nextLeft = leftBound;

if strcmp(vertSide, 'top')
    currRow = topBound - vertSpace;
    nextRow = topBound - vertSpace;
elseif strcmp(vertSide, 'bottom')
    currRow = botBound + vertSpace;
    nextRow = botBound + vertSpace;
end

if ~isempty(portlessInfo)
    oldBlockType = get_param(portlessInfo{1}.fullname, 'BlockType');
end
for i = 1:length(portlessInfo)
    block = portlessInfo{i}.fullname;
    newBlockType = get_param(block, 'BlockType');
    btChanged = ~strcmp(oldBlockType, newBlockType); % Check if block type changed (so we can start new rows/columns at new block types)
    
    if strcmp(smallOrLargeHalf(block),vertSide)
        
        pos = portlessInfo{i}.position;
        width = pos(3) - pos(1);
        height = pos(4) - pos(2);
        
        if (nextLeft == leftBound || nextLeft + width <= rightBound) && ~(btChanged)
            % Same row
            left = nextLeft;
        else
            % New row
            currRow = nextRow;
            left = leftBound;
        end
        right = left + width;
        nextLeft = right + horzSpace;
        
        if strcmp(vertSide, 'top')
            bot = currRow;
            top = bot - height;
            nextRow = min(nextRow, top - vertSpace);
        elseif strcmp(vertSide, 'bottom')
            top = currRow;
            bot = top + height;
            nextRow = max(nextRow, bot + vertSpace);
        end
        
        portlessInfo{i}.position = [left top right bot];
    end
    
    oldBlockType = newBlockType;
end
end

% function portlessInfo = reposPortlessOnBot(portlessInfo,smallOrLargeHalf,leftBound,rightBound,botBound,vertSpace,horzSpace)
%
% nextLeft = leftBound;
% currRowTop = botBound + vertSpace;
% nextRowTop = botBound + vertSpace;
%
% for i = 1:length(portlessInfo)
%     block = portlessInfo{i}.fullname;
%     if strcmp(smallOrLargeHalf(block),'bottom')
%
%         pos = portlessInfo{i}.position;
%         width = pos(3) - pos(1);
%         height = pos(4) - pos(2);
%
%         if nextLeft == leftBound || nextLeft + width <= rightBound
%             % Same row
%             left = nextLeft;
%         else
%             % New row
%             currRowTop = nextRowTop;
%             left = leftBound;
%         end
%         right = left + width;
%         nextLeft = right + horzSpace;
%
%         top = currRowTop;
%         bot = top + height;
%         nextRowTop = max(nextRowTop, bot + vertSpace);
%
%         portlessInfo{i}.position = [left top right bot];
%     end
% end
% end

function portlessInfo = horzReposPortless(portlessInfo,smallOrLargeHalf,leftBound,topBound,rightBound,botBound,vertSpace,horzSpace,horzSide)

portlessInfo = sortPortlessInfo(portlessInfo);

nextTop = topBound;

if strcmp(horzSide, 'left')
    currCol = leftBound - horzSpace;
    nextCol = leftBound - horzSpace;
elseif strcmp(horzSide, 'right')
    currCol = rightBound + horzSpace;
    nextCol = rightBound + horzSpace;
end

if ~isempty(portlessInfo)
    oldBlockType = get_param(portlessInfo{1}.fullname, 'BlockType');
end
for i = 1:length(portlessInfo)
    block = portlessInfo{i}.fullname;
    newBlockType = get_param(block, 'BlockType');
    btChanged = ~strcmp(oldBlockType, newBlockType); % Check if block type changed (so we can start new rows/columns at new block types)
    
    if strcmp(smallOrLargeHalf(block),horzSide)
        
        pos = portlessInfo{i}.position;
        width = pos(3) - pos(1);
        height = pos(4) - pos(2);
        
        if (nextTop == topBound || nextTop + height <= botBound) && ~(btChanged)
            % Same col
            top = nextTop;
        else
            % New col
            currCol = nextCol;
            top = topBound;
        end
        
        bot = top + height;
        nextTop = bot + vertSpace;
        
        if strcmp(horzSide, 'left')
            right = currCol;
            left = right - width;
            nextCol = min(nextCol, left - horzSpace);
        elseif strcmp(horzSide, 'right')
            left = currCol;
            right = left + width;
            nextCol = max(nextCol, right + horzSpace);
        end
        
        portlessInfo{i}.position = [left top right bot];
    end
    
    oldBlockType = newBlockType;
end
end

%%%Just a harder to read way of repositioning (but all in one function)
% function portlessInfo = repoPortless(portlessInfo,smallOrLargeHalf,topBound,rightBound,botBound,vertSpace,horzSpace,side)
% 
% if strcmp(side,'top') || strcmp(side,'bottom')
%     isVert = true;
%     smallestB = leftBound; % bound at which to begin placing blocks in an aisle
%     largestB = rightBound; % bound at which to stop placing blocks in an aisle (when to start a new aisle)
%     buff1 = horzSpace; % buff1 is space between individual block placements
%     aisleBuff = vertSpace; % aisleBuff is space between rows/columns (aisles) of block placements
%     
%     antiSmallSide = left;
%     smallSide = top;
%     antiLargeSide = right;
%     largeSide = bot;
%     
% else
%     isVert = false;
%     smallestB = topBound; % bound at which to begin placing blocks in an aisle
%     largestB = botBound; % bound at which to stop placing blocks in an aisle (when to start a new aisle)
%     buff1 = vertSpace; % buff1 is space between individual block placements
%     aisleBuff = horzSpace; % aisleBuff is space between rows/columns (aisles) of block placements
%     
%     smallSide = left;
%     antiSmallSide = top;
%     largeSide = right;
%     antiLargeSide = bot;
%     
% end
% 
% switch side
%     case 'left'
%         myBound = leftBound;
%         isSmallSide = true;
%     case 'top'
%         myBound = topBound;
%         isSmallSide = true;
%     case 'right'
%         myBound = rightBound;
%         isSmallSide = false;
%     case 'bottom'
%         myBound = botBound;
%         isSmallSide = false;
% end
% 
% next = smallestB;
% 
% currAisleBound = myBound + aisleBuff;
% nextAisleBound = myBound + aisleBuff;
% 
% for i = 1:length(portlessInfo)
%     block = portlessInfo{i}.fullname;
%     if strcmp(smallOrLargeHalf(block),side)
%         
%         pos = portlessInfo{i}.position;
%         width = pos(3) - pos(1);
%         height = pos(4) - pos(2);
%         
%         if isVert
%             bindingDim = width; % Width/height depending on which limits the number of blocks in an aisle
%             expandingDim = height; % Width/height depending on which controls how the aisles expand out
%         else
%             bindingDim = height; % Width/height depending on which limits the number of blocks in an aisle
%             expandingDim = width; % Width/height depending on which controls how the aisles expand out
%         end
%         
%         
%         if next == smallestB || next + bindingDim <= largestB
%             % Same aisle
%             antiSmallSide = next;
%         else
%             % New aisle
%             currAisleBound = nextAisleBound;
%             antiSmallSide = smallestB;
%         end
%         antiLargeSide = antiSmallSide + bindingDim;
%         next = antiLargeSide + buff1;
%         
%         if isSmallSide
%             largeSide = currAisleBound;
%             smallSide = largeSide - expandingDim;
%             nextAisleBound = min(nextAisleBound, smallSide - aisleBuff);
%         else
%             smallSide = currAisleBound;
%             largeSide = smallSide + expandingDim;
%             nextAisleBound = max(nextAisleBound, largeSide + aisleBuff);
%         end
%         
%         if isSmallSide
%             left = antiSmallSide;
%             top = smallSide;
%             right = antiLargeSide;
%             bot = largeSide;
%         else
%             left = smallSide;
%             top = antiSmallSide ;
%             right = largeSide;
%             bot = antiLargeSide;
%         end
%         
%         portlessInfo{i}.position = [left top right bot];
%     end
% end
% 
% end

% function portlessInfo = reposPortlessOnRight(portlessInfo,smallOrLargeHalf,topBound,rightBound,botBound,vertSpace,horzSpace)
%
% nextTop = topBound;
% currColLeft = rightBound + horzSpace;
% nextColLeft = rightBound + horzSpace;
%
% for i = 1:length(portlessInfo)
%     block = portlessInfo{i}.fullname;
%     if strcmp(smallOrLargeHalf(block),'right')
%
%         pos = portlessInfo{i}.position;
%         width = pos(3) - pos(1);
%         height = pos(4) - pos(2);
%
%         if nextTop == topBound || nextTop + height <= botBound
%             % Same col
%             top = nextTop;
%         else
%             % New col
%             currColLeft = nextColLeft;
%             top = topBound;
%         end
%
%         bot = top + height;
%         nextTop = bot + vertSpace;
%
%         left = currColLeft;
%         right = left + width;
%         nextColLeft = max(nextColLeft, right + horzSpace);
%
%         portlessInfo{i}.position = [left top right bot];
%     end
% end
% end

function [leftBound,topBound,rightBound,botBound] = sideExtremes(layout, portlessInfo, ignorePortlessBlocks)
%COMMENTS NEED UPDATE
%EXTREMESIDE Finds the extreme position of a given side among blocks.

rightBound = -32767;
leftBound = 32767;
botBound = -32767;
topBound = 32767;

%TODO - optimize this to only check needed blocks
for j = 1:size(layout.grid,2)
    for i = 1:layout.colLengths(j)
        pos = layout.grid{i,j}.position;
        if pos(3) > rightBound
            rightBound = pos(3);
        end
        if pos(1) < leftBound
            leftBound = pos(1);
        end
        
        if pos(4) > botBound
            botBound = pos(4);
        end
        if pos(2) < topBound
            topBound = pos(2);
        end
    end
end

if ~ignorePortlessBlocks
    for i = 1:length(portlessInfo)
        pos = portlessInfo{i}.position;
        if pos(3) > rightBound
            rightBound = pos(3);
        end
        if pos(1) < leftBound
            leftBound = pos(1);
        end
        
        if pos(4) > botBound
            botBound = pos(4);
        end
        if pos(2) < topBound
            topBound = pos(2);
        end
    end
end
end