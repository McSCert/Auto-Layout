function [portlessInfo, smallOrLargeHalf] = getPortlessInfo(blocks, portlessBlocks)
    % GETPORTLESSINFO Find the name and position about the portless blocks. For
    %   position, also check which half of the system each block is in, relative
    %   to the others (checks top/bottom vs. left/right half based on relevance
    %   with portless_rule).
    %
    %   Inputs:
    %       blocks          Cell array of blocks.
    %       portlesBlocks   Cell array of portless blocks in blocks. If
    %                       given a vector of handles, it will be converted
    %                       to cell array of block fullnames.
    %
    %   Outputs:
    %       portlessInfo        Struct of portless blocks' fullname and position.
    %       smallOrLargeHalf    Map relating blocks with the side of the system
    %                           they should be placed on.
    
    %%
    % See PORTLESS_RULE in config.txt.
    PORTLESS_RULE = getAutoLayoutConfig('portless_rule', 'top'); %Indicates how to place portless blocks
    
    % Check that portless_rule is set properly
    if ~AinB(PORTLESS_RULE, {'top', 'left', 'bottom', 'right', 'same_half_vertical', 'same_half_horizontal'})
        ErrorInvalidConfig('portless_rule')
    end
    
    %%
    portlessBlocks = inputToCell(portlessBlocks);
    
    %%
    % For each case:
    % 1) Create a struct array portlessInfo which contains the name of the portless
    % blocks and has their position for the struct set to null.
    % 2) Create a map which specifies relative to where the portless blocks will be
    % placed.
    switch PORTLESS_RULE
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
        case 'bottom'
            portlessInfo = struct('fullname', {}, ...
                'position', {});
            smallOrLargeHalf = containers.Map();
            
            for i = 1:length(portlessBlocks)
                smallOrLargeHalf(portlessBlocks{i}) = 'bottom';
                portlessInfo{end+1} = struct('fullname', portlessBlocks{i}, ...
                    'position', []);
            end
        case 'same_half_vertical'
            [~,center] = systemCenter(blocks);
            
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
            [center,~] = systemCenter(blocks);
            
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
        otherwise
            % Invalid portless_rule
            error(['portless_rule must be in the following ' ...
                '{''top'', ''left'', ''bottom'', ''right'', ' ...
                '''same_half_vertical'', ''same_half_horizontal''}']);
    end
end