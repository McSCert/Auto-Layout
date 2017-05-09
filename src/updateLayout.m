function updateLayout(address, layout)
%UPDATELAYOUT Moves blocks to their new positions designated by layout

%Get blocknames and desired positions for moveBlocks()
fullnames = {}; positions = {};
for j = 1:size(layout.grid,2)
    for i = 1:layout.colLengths(j)
        fullnames{end+1} = layout.grid{i,j}.fullname;
        positions{end+1} = layout.grid{i,j}.position;
    end
end

% Move blocks to the desired positions
moveBlocks(address, fullnames, positions);
end