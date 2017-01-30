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
%                       Uses the same format as get_param(gcb, 'Position').
%
%   Outputs:
%       N/A

    blocklength = length(blocksInfo);
    for z = 1:blocklength
        set_param(blocksInfo(z).fullname, 'Position', blocksInfo(z).position);
    end
    redraw_lines(address, 'autorouting', 'on');
end