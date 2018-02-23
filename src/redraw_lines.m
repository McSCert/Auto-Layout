function redraw_lines(name, varargin)
%REDRAWBYBLOCKS Redraw all lines in the input system.
%
%   Inputs:
%       name            System address.
%       varargin{1}     Set to 'autorouting' to enable use of varargin{2}.
%       varargin{2}     Indicates whether or not the program should attempt
%                       autorouting. Values: 'on' or 'off'. Default: 'off'.
%   Examples:
%       redraw_lines(name) -- redraws lines with autorouting off
%       redraw_lines(name, 'autorouting', 'on') -- redraws lines with
%           autorouting on

    if isempty(varargin) || length(varargin) < 2
        autorouting = 'off';
    else
        if isequal(varargin{1}, 'autorouting')
            autorouting = varargin{2};
        end
    end

    redrawByBlocks(name,autorouting);
%     redrawByLines(name,autorouting);
    
end

function redrawByBlocks(name, autorouting)
%REDRAWBYBLOCKS Redraws all lines by using get_param(name,'Blocks') and 
%   then finding the line handles of each line on each block to find all
%   lines.
%
%   Inputs:
%       name            System address.
%       autorouting     Indicates whether or not the program should attempt
%                       autorouting. Values ('on' or 'off').

    Blocks = get_param(name,'Blocks');
    for n = 1:length(Blocks)
        Blocks{n} = strrep(Blocks{n}, '/', '//');
        linesH = get_param([name, '/', Blocks{n}], 'LineHandles');
        if ~isempty(linesH.Inport)
            for m = 1:length(linesH.Inport)
                src = get_param(linesH.Inport(m), 'SrcBlockHandle');
                srcport = get_param(linesH.Inport(m), 'SrcPortHandle');
                dest = get_param(linesH.Inport(m), 'DstBlockHandle');
                destport = get_param(linesH.Inport(m), 'DstPortHandle');
                delete_line(linesH.Inport(m))
                add_line(name, srcport, destport, 'autorouting', autorouting);
            end
        end
    end
end

% function redrawByLines(name, autorouting)
% %REDRAWBYLINES Redraws all lines by using get_param(name,'Lines') to find
% %   all lines.
% %   This method is untested, but may be better than the 'ByBlocks' method
% %   (robustness, speed, modifiability, etc.).
% %   UPDATE: Current implementation does not account for Branching lines
% %
% %   Inputs:
% %       name            System address.
% %       autorouting     Indicates whether or not the program should attempt
% %                       autorouting. Values ('on' or 'off').
% 
%     lines = get_param(name,'Lines');
%     for n = 1:length(lines)
%         %src = lines(n).SrcBlock;
%         srcport = get_param(lines(n).Handle, 'SrcPortHandle');
%         %dest = lines(n).DstBlock;
%         destport = get_param(lines(n).Handle, 'DstPortHandle');
%         delete_line(lines(n).Handle);
%         add_line(name, srcport, destport, 'autorouting', autorouting);
%     end
% end