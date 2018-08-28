function updatePortless(portlessInfo)
% UPDATEPORTLESS Move blocks to their new positions designated by portlessInfo.
%
%   Inputs:
%       portlessInfo    As returned by getPortlessInfo.
%
%   Outputs:
%       N/A

    % Get blocknames and desired positions
    fullnames = {}; positions = {};
    for i = 1:length(portlessInfo)
        fullnames{end+1} = portlessInfo{i}.fullname;
        positions{end+1} = portlessInfo{i}.position;
    end

    % Move blocks to the desired positions
    moveBlocks(fullnames, positions);
end