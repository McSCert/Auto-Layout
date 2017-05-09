function updatePortless(address, portlessInfo)
%UPDATEPORTLESS Moves blocks to their new positions designated by
%   portlessInfo.

%Get blocknames and desired positions for moveBlocks()
fullnames = {}; positions = {};
for i = 1:length(portlessInfo)
    fullnames{end+1} = portlessInfo{i}.fullname;
    positions{end+1} = portlessInfo{i}.position;
end

% Move blocks to the desired positions
moveBlocks(address, fullnames, positions);
end