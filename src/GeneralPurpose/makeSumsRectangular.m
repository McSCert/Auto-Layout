function makeSumsRectangular(blocks)
% MAKESUMSRECTANGULAR change the same of a 'sum' block to rectangular
%
%   Inputs:
%       blocks  Cell array of blocks. Non-Sum blocks will not be affected

for i = 1:length(blocks)
    if strcmp(get_param(blocks{i},'BlockType'),'Sum')
        set_param(blocks{i},'IconShape','rectangular');
        signs = strrep(get_param(blocks{i},'ListOfSigns'),'|','');
        set_param(blocks{i},'ListOfSigns',signs);
    end
end

end