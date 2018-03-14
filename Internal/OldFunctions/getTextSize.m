function size = getTextSize(string, block)
% GETTIXESIZE Find the width of a string inside a block
%
%   Inputs:
%       string Text inside the block
%       block  Block containing the string 
%
%   Output:
%       size   Width of the text inside the block that is determined by the
%       number of pixels

    fontName = get_param(block, 'FontName');
    fontSize = get_param(block, 'FontSize');
    if fontSize == -1 %  if default font size is determined by DefaultBlockFontSize block parameter
        fontSize = get_param(bdroot, 'DefaultBlockFontSize');
    end
    testFig = figure;
    uicontrol(testFig)
    x = uicontrol('Style', 'text', 'FontName', fontName, 'FontSize', fontSize);
    set(x, 'String', string);
    size = get(x, 'extent');
    size = size(3);
    close(testFig);
end