function size = getTextSize(string, block)

    fontName = get_param(block, 'FontName');
    fontSize = get_param(block, 'FontSize');
    if fontSize == -1
        fontSize = get_param(gts, 'DefaultBlockFontSize');
    end
    testFig = figure;
    uicontrol(testFig)
    x = uicontrol('Style', 'text', 'FontName', fontName, 'FontSize', fontSize);
    set(x, 'String', string);
    size = get(x, 'extent');
    size = size(3);
    close(testFig);
end