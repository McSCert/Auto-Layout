function height = annotationStringHeight(annotation, string)
% ANNOTATIONSTRINGHEIGHT Finds the height string has/would have within block
%
% TODO merge with blockStringHeight

    fontName = get_param(annotation, 'FontName');
    fontSize = get_param(annotation, 'FontSize');
    if fontSize == -1
        fontSize = get_param(bdroot(annotation), 'DefaultBlockFontSize');
    end
    height = getTextHeight(string,fontName,fontSize);
end