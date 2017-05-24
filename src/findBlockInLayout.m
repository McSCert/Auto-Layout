function [found, indices] = findBlockInLayout(layout,block)
% finds block in layout
%
%   Inputs:
% layout as given by the get relative layout function
% block can be given by handle or full name (with path)
%
%   Outputs:
% found bool indicating if block was in layout
% indices 1x2 vector of row by column indices of block in layout or [] if
% not found

found = false;
indices = [];

for j = 1:size(layout.grid,2) % for each column
    for i = 1:layout.colLengths(j) % for each non empty row in column
        if strcmp(getfullname(block), layout.grid{i,j}.fullname)
            found = true;
            indices = [i,j];
        end
    end
end
end