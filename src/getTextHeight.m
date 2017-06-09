function height = getTextHeight(string,fontName,fontSize)
%GETTEXTHEIGHT Get width of string
%
%   Inputs:
%       string      A character array.
%       fontName    The name of the font that string is written in.
%       fontSize    The size of the font that string is written in.
%
%   Output:
%       height       The height of a string written with the given font info.

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

    %Create the text in a figure and check the size of that
    testFig = figure;
    uicontrol(testFig)
    y = uicontrol('Style', 'text', 'FontName', fontName, 'FontSize', fontSize);
    set(y, 'String', string);
    size = get(y, 'extent');
    height = size(4);
    close(testFig);
end