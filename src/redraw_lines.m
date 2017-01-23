function redraw_lines(name, varargin)
%   Function:
%       redraw_lines(name)
%       redraw_lines(name, autorouting, off)

    if isempty(varargin)
        autorouting = 'off';
    else
        if isequal(varargin(1), {'autorouting'});
            autorouting = varargin{2};
        end
    end

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