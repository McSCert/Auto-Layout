function width = getTextWidth(string,fontName,fontSize)
%GETTEXTWIDTH Get width of string
%
%   Inputs:
%       string      A character array.
%       fontName    The name of the font that string is written in.
%       fontSize    The size of the font that string is written in.
%
%   Output:
%       width       The width of a string written with the given font info.

    % Check number of arguments
    try
        assert(nargin == 3)
    catch
        disp(['Error using ' mfilename ':' char(10) ...
            ' Wrong number of arguments.' char(10)])
        return
    end
    
    % Check fontSize argument
    try
       assert(fontSize > 0);
    catch
        disp(['Error using ' mfilename ':' char(10) ...
            ' Invalid argument: fontSize. Value must be greater than 0.' char(10)])
        return
    end

    % Create the text in a figure and check the size of that
    testFig = figure;
    uicontrol(testFig)
    x = uicontrol('Style', 'text', 'FontName', fontName, 'FontSize', fontSize);
    set(x, 'String', string);
    size = get(x, 'extent');
    width = size(3)-size(1);
    close(testFig);
end