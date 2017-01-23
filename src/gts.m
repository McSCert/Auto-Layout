function system = gts
% Get top level of current system
    address = gcs;
    numChars = strfind(address, '/');
    if ~isempty(numChars)
        system = address(1:numChars(1)-1);
    else
        system = address;
    end
end