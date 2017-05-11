function neededWidth = getBlockTextWidth(block)
%GETBLOCKTEXTWIDTH Determines appropriate block width in order to fit the
%   text within it.
%
%   Inputs:
%       block           Full name of a block (character array).
%   
%   Outputs:
%       neededWidth     Needed block width in order to fit its text.

    blockType = get_param(block, 'BlockType');
    
    msgID = 'GotoTag:UnexpectedVis';
    msg = ['Unexpected Tag Visibility On ' block ' - Please Report Bug'];
    tagVisException = MException(msgID, msg);
    
    switch blockType
        case 'SubSystem'
            inports = find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'Inport');
            
            %Don't worry about triggers for now unless an example arises in
            %which they are an issue as they seem to just use symbols of
            %less width then the ports
%             inports = [inports; find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'EnablePort')];
%             inports = [inports; find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'TriggerPort')];
%             inports = [inports; find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'ActionPort')];
            
            outports = find_system(block, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'Outport');
            
            leftWidth = 0;
            for i = 1:length(inports)
                string = get_param(inports{i}, 'Name');
                width = blockStringWidth(block, string);
                if width > leftWidth
                    leftWidth = width;
                end
            end
            
            rightWidth = 0;
            for i = 1:length(outports)
                string = get_param(outports{i}, 'Name');
                width = blockStringWidth(block, string);
                if width > rightWidth
                    rightWidth = width;
                end
            end
            
            if strcmp(get_param(block, 'Mask'),'on')
                maskType = get_param(block, 'MaskType');
                centerWidth = max(blockStringWidth(block, block),blockStringWidth(block, maskType));
            else
%                 maskType = '';
                centerWidth = 0;
            end
            
%             if strcmp(get_param(block,'ShowName'),'on')
%                 string = block;
%                 width = blockStringWidth(block, string);
%                 if width > centerWidth
%                     centerWidth = width;
%                 end
%             end
            
            width = sum([leftWidth, rightWidth, centerWidth]);
            neededWidth = width;   %To fit different blocks of text within the block

        case 'If'
            ifExpression = get_param(block, 'ifExpression');
            elseIfExpressions = get_param(block, 'ElseIfExpressions');
            elseIfExpressions = strsplit(elseIfExpressions, ',');
            if isempty(elseIfExpressions{1})
                elseIfExpressions = {};
            end
            expressions = [{ifExpression} elseIfExpressions];
            width = 0;
            for i = 1:length(expressions)
                width = blockStringWidth(block, expressions{i});
                if width > width
                    width = width;
                end
            end
            neededWidth = width * 2;   %To fit different blocks of text within the block

        case 'Goto'
            string = get_param(block, 'gototag');
            if strcmp(get_param(block,'TagVisibility'), 'local')
                string = ['[' string ']'];
            elseif strcmp(get_param(block,'TagVisibility'), 'scoped')
                string = ['{' string '}'];
            elseif strcmp(get_param(block,'TagVisibility'), 'global')
                %Do nothing
            else
                throw(tagVisException)
            end
            neededWidth = blockStringWidth(block, string);
            
        case 'From'
            string = get_param(block, 'gototag');
            if strcmp(get_param(block,'TagVisibility'), 'local')
                string = ['[' string ']'];
            elseif strcmp(get_param(block,'TagVisibility'), 'scoped')
                string = ['{' string '}'];
            elseif strcmp(get_param(block,'TagVisibility'), 'global')
                %Do nothing
            else
                throw(tagVisException)
            end
            neededWidth = blockStringWidth(block, string);

        case 'GotoTagVisibility'
            string = get_param(block, 'gototag');
            string = ['[' string ']']; % Add for good measure (ideally would know how to check what brackets if any)
            neededWidth = blockStringWidth(block, string);
            
        case 'DataStoreRead'
            string = get_param(block, 'DataStoreName');
            neededWidth = blockStringWidth(block, string);
            
        case 'DataStoreWrite'
            string = get_param(block, 'DataStoreName');
            neededWidth = blockStringWidth(block, string);

        case 'DataStoreMemory'
            string = get_param(block, 'DataStoreName');
            neededWidth = blockStringWidth(block, string);
            
        case 'Constant'
            string = get_param(block, 'Name');
            neededWidth = blockStringWidth(block, string);
            
        otherwise
            neededWidth = 0;
    end
end