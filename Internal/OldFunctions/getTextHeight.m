function height = getTextHeight(string,fontName,fontSize)
% GETTEXTHEIGHT Get height of string.
%
%   Inputs:
%       string      A character array.
%       fontName    The name of the font that string is written in.
%       fontSize    The size of the font that string is written in.
%
%   Output:
%       height       The height of a string written with the given font info.

dims = getTextDims(string, fontName, fontSize);

height = dims(2);
end