function name = applyNamingConvention(handle)
% APPLYNAMINGCONVENTION Apply a naming convention to blocks and ports.
%   May be expanded to other elements in the future.
%
%   Inputs:
%       handle  Handle of the block/port. Block name is also accepted.
%
%   Outputs:
%       name    Name with convention applied to it.
    
    if isempty(handle)
        name = [];
    else
        
        rows = size(handle, 1);
        cols = size(handle, 2);
        
        if (ischar(handle) || isnumeric(handle)) && rows == 1  % Scalar or string
            % Handle is a single block name or block handle
            % Return name as a char
            type = get_param(handle, 'Type');
            if strcmp(type, 'block')
                % Blocks
                oldName = getfullname(handle);
                if iscell(oldName)
                    oldName = cell2mat(oldName);
                end
                name = strcat([oldName ':b']);
            elseif strcmp(type, 'port')
                % Block ports
                parName = get_param(handle, 'Parent');
                portType = get_param(handle, 'PortType');
                portNum = get_param(handle, 'PortNumber');
                if strcmp(portType, 'inport')
                    name = [parName ':i' num2str(portNum)];
                elseif strcmp(portType, 'outport')
                    name = [parName ':o' num2str(portNum)];
                else
                    error('Ports other than inports and outports are not supported.');
                end
            end
        elseif ischar(handle) % && rows ~= 1
            % Handle is a list of chars
            % Return name as a cell array of chars
            name = cell(rows, 1);
            for i = 1:rows
                name(i) = {applyNamingConvention(handle(i,:))}; % Recurse
            end
        elseif isnumeric(handle) % && rows ~= 1
            % Handle is a list of handles
            % Return name as a cell array of chars
            name = cell(rows, cols);
            for i = 1:rows
                for j = 1:cols
                    name(i,j) = {applyNamingConvention(handle(i,j))}; % Recurse
                end
            end
        elseif iscell(handle)
            % Handle is a cell array
            % Return name as a cell array with the same structure
            name = cell(rows, cols);
            for i = 1:rows
                for j = 1:cols
                    name(i,j) = {applyNamingConvention(handle{i,j})}; % Recurse
                end
            end
        else
            error('Unexpected type of input.')
        end
    end
end