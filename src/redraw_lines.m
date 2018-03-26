function redraw_lines(name, varargin)
% REDRAWBYBLOCKS Redraw all lines in the system.
%
%   Inputs:
%       name            Simulink system name or path.
%       varargin{1}     Set to 'autorouting' to enable use of varargin{2}.
%       varargin{2}     Indicates whether or not the program should attempt
%                       autorouting. Values: 'on' or 'off'. Default: 'off'.
%
%   Outputs:
%       N/A
%
%   Examples:
%       redraw_lines(name)
%           Redraws lines with autorouting off.
%
%       redraw_lines(name, 'autorouting', 'on')
%           Redraws lines with autorouting on.

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
% REDRAWBYBLOCKS Redraw all lines by using get_param(name,'Blocks') and
%   then finding the line handles of each line on each block to find all
%   lines.
%
%   Inputs:
%       name            System address.
%       autorouting     Indicates whether or not the program should attempt
%                       autorouting. Values ('on' or 'off').
%
%   Outputs:
%       N/A

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