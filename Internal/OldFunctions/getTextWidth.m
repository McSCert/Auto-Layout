function width = getTextWidth(string,fontName,fontSize)
% GETTEXTWIDTH Get width of string.
%
%   Inputs:
%       string      A character array.
%       fontName    The name of the font that string is written in.
%       fontSize    The size of the font that string is written in.
%
%   Output:
%       width       The width of a string written with the given font info.

dims = getTextDims(string, fontName, fontSize);

width = dims(1);

end