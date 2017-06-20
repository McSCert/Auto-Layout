function bool = isConnected(source, dest)
%ISCONNECTED Checks for a connection from source to dest.
%
%   Inputs:
%       source  Fullname of source block.
%       dest    Fullname of destination block.
%
%   Outputs:
%       bool    Logical indicating whether or not there is a direct signal 
%               line connection from source to dest.

connectivity1 = get_param(dest, 'PortConnectivity');
srcs = [];

%Room for optimization below due to structure of the 'PortConnectivity'
%parameter
for i = 1:length(connectivity1)
    srcs = [srcs, connectivity1(i).SrcBlock];
end

srcHandle = get_param(source, 'Handle');

bool = any(srcHandle==srcs);
end