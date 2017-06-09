function width = blockStringWidth(block, string)
% BLOCKSTRINGWIDTH Finds the width string has/would have within block
%
% TODO merge with blockStringHeight

    fontName = get_param(block, 'FontName');
    fontSize = get_param(block, 'FontSize');
    if fontSize == -1
        fontSize = get_param(bdroot(block), 'DefaultBlockFontSize');
    end
    width = getTextWidth(string,fontName,fontSize);
end