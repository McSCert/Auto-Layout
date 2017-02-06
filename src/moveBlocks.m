function moveBlocks(address, blocksInfo)
%MOVEBLOCKS Moves blocks to their assigned positions according to
%   blocksInfo and redraws lines.
%
%   Inputs:
%       address     Simulink system name or path.
%       blocksInfo  Cell array of structs with 'fullname' and 'position'
%                   fields.
%                   fullname: Char of the full name of a block. E.g. gcb.
%                   position: Vector of the desired position of a block.
%                   Uses the same format as get_param(gcb, 'Position').
%
%   Outputs:
%       N/A
%
%   Example:
%       blocksInfo = struct('fullname',{'AutoLayoutDemo/In1', ...
%           'AutoLayoutDemo/In2'},'position', ...
%           {[-35,50,-15,70],[-35,185,-15,205]})
%       moveBlocks('AutoLayoutDemo',blocksInfo)
    
    % Check number of arguments
    try
        assert(nargin == 2)
    catch
        disp(['Error using ' mfilename ':' char(10) ...
            ' Wrong number of arguments.' char(10)])
        return
    end
    
    % Check address argument
    % 1) Check model at address is open
    try
       assert(ischar(address));
       assert(bdIsLoaded(bdroot(address)));
    catch
        disp(['Error using ' mfilename ':' char(10) ...
            ' Invalid argument: address. Model may not be loaded or name is invalid.' char(10)])
        return
    end

    % 2) Check that model is unlocked
    try
        assert(strcmp(get_param(bdroot(address), 'Lock'), 'off'));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
                strcmp(ME.identifier, 'MATLAB:assertion:failed')
            disp(['Error using ' mfilename ':' char(10) ...
                ' File is locked.'])
            return
        end
    end

    blocklength = length(blocksInfo);
    for z = 1:blocklength
        set_param(blocksInfo(z).fullname, 'Position', blocksInfo(z).position);
    end
    redraw_lines(address, 'autorouting', 'on');
end