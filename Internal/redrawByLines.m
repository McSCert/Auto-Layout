function redrawByLines(name, autorouting)
%REDRAWBYLINES Redraws all lines by using get_param(name,'Lines') to find
%   all lines.
%   This method is untested, but may be better than the 'ByBlocks' method
%   (robustness, speed, modifiability, etc.).
%   UPDATE: Current implementation does not account for Branching lines
%
%   Inputs:
%       name            System address.
%       autorouting     Indicates whether or not the program should attempt
%                       autorouting. Values ('on' or 'off').

    lines = get_param(name,'Lines');
    for n = 1:length(lines)
        %src = lines(n).SrcBlock;
        srcport = get_param(lines(n).Handle, 'SrcPortHandle');
        %dest = lines(n).DstBlock;
        destport = get_param(lines(n).Handle, 'DstPortHandle');
        delete_line(lines(n).Handle);
        add_line(name, srcport, destport, 'autorouting', 'smart');
    end
end