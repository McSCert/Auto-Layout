function width = annotationStringWidth(annotation, string)
% ANNOTATIONSTRINGWIDTH Finds the width string has/would have within block
%
% TODO merge with blockStringWidth

    fontName = get_param(annotation, 'FontName');
    fontSize = get_param(annotation, 'FontSize');
    if fontSize == -1
        fontSize = get_param(bdroot(annotation), 'DefaultBlockFontSize');
    end
    width = getTextWidth(string,fontName,fontSize);
end