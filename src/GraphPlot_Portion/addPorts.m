function dgNew = addPorts(sys, dg)
% ADDPORTS Add nodes to a digraph representing the ports of multi-port blocks.
%
%   Inputs:
%       sys     Path of the system that the digraph represents.
%       dg      Digraph representation of the system sys.
%
%   Outputs:
%       dgNew   Updated digraph.

    % Duplicate
    dgNew = dg;

    % Get nodes
    nodes = find_system(sys, 'SearchDepth', '1', 'FindAll','off', 'Type', 'block');
    nodes(strcmp(nodes, sys), :) = [];  % If sys is a subsysttem, remove itself from the list
    numNodes = length(nodes);
    
    for i = 1:numNodes
        % Check if it has mutiple ports in and/or out
        nodeName = nodes(i);
        nodeName = nodeName{:};
        portInfo = get_param(nodeName, 'PortConnectivity');
        inPortIdxs = find(~cellfun(@isempty, {portInfo.SrcPort}));
        outPortIdxs = find(~cellfun(@isempty, {portInfo.DstPort}));
        
        if  length(inPortIdxs) > 1     % If multiple in ports
            newInPorts = cell(1, length(inPortIdxs));
            for j = 1:length(inPortIdxs)   % For each port  
                portName = [nodeName ':i' num2str(j)];
                newInPorts{j} = portName;
                inInfo = portInfo(inPortIdxs(j));       
                inName = getfullname(inInfo.SrcBlock);  
                
                dgNew = addnode(dgNew, portName);           % Add port node
                dgNew = rmedge(dgNew, inName, nodeName);	% Delete incoming edge
                dgNew = addedge(dgNew, inName, portName, 1);	% Add incoming edge to new port
                dgNew = addedge(dgNew, portName, nodeName, 1); % Connect new port to block node    
            end
            for k = 1:length(newInPorts)-1
                dgNew = addedge(dgNew, newInPorts{k}, newInPorts{k+1}, 1); % Connect ports to each other to impose ordering
                %dgNew = addedge(dgNew, newInPorts{k+1}, newInPorts{k}, 1);
            end
        end
        if length(outPortIdxs) > 1      % If multiple out ports
            newOutPorts = cell(1, length(inPortIdxs));
            for j = 1:length(outPortIdxs)   % For each port  
                portName = [nodeName ':o' num2str(j)];
                newOutPorts{j} = portName;
                outInfo = portInfo(outPortIdxs(j));       
                outName = getfullname(outInfo.DstBlock);  

                dgNew = addnode(dgNew, portName);           % Add port node
                dgNew = rmedge(dgNew, nodeName, outName);	% Delete outgoing edge
                dgNew = addedge(dgNew, portName, outName, 1);	% Add outgoing edge from new port
                dgNew = addedge(dgNew, nodeName, portName, 1); % Connect new port to block node            
            end
            for k = 1:length(newOutPorts)-1
                dgNew = addedge(dgNew, newOutPorts{k}, newOutPorts{k+1}, 1); % Connect ports to each other to impose ordering
                %dgNew = addedge(dgNew, newOutPorts{k+1}, newOutPorts{k}, 1); 
            end
        end
    end
end