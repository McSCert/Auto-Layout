function layout = resizeInOutBlocks(layout)
%RESIZEINOUTBLOCKS Set inport and outport blocks to default sizes
%
%   Inputs:
%       layout          As returned by getRelativeLayout.
%
%   Output:
%       layout          With modified position information.

for j = 1:size(layout.grid,2) % for each column
    for i = 1:layout.colLengths(j) % for each non empty row in column
        btype = get_param(layout.grid{i,j}.fullname, 'BlockType');
        
        if strcmp(btype, 'Inport') || strcmp(btype, 'Outport')
            pos = layout.grid{i,j}.position;
            center = [(pos(3)+pos(1))/2, (pos(4)+pos(2))/2];
            height = 14;
            width = 30;
            layout.grid{i,j}.position = [center(1)-width/2, center(2)-height/2, center(1)+width/2, center(2)+height/2];
        end
    end
end

end