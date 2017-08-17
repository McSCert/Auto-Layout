function height = blockStringHeight(block, string)
% BLOCKSTRINGHEIGHT Finds the height string has/would have within block
%
% TODO merge with blockStringWidth

    fontName = get_param(block, 'FontName');
    fontSize = get_param(block, 'FontSize');
    if fontSize == -1
        fontSize = get_param(bdroot(block), 'DefaultBlockFontSize');
    end
    dims = getTextDims(string, fontName, fontSize, get_param(block, 'Parent'));
    height = dims(2);
end