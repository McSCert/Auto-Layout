function bool = AinB(A,B)
% AINB Determines if A is an element B.
% There's probably a predefined MATLAB function for this that should be
%   used instead...
%
%   Inputs:
%       A       Character vector
%       B       Cell array
%
%   Outputs:
%       bool    Logical

bool = false;
if ischar(A) && iscell(B)
    for i = 1:length(B)
        if ischar(B{i}) && strcmp(A,B{i})
            bool = true;
            return
        end
    end
end
end