function makeSumsRectangular(blocks)
%
%
%   Inputs:
%       blocks  Cell array of blocks. Non-Sum blocks will not be affected

for i = 1:length(blocks)
    if strcmp(get_param(blocks{i},'BlockType'),'Sum')
        set_param(blocks{i},'IconShape','rectangular');
    end
end

end