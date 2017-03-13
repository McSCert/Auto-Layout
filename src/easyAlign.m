function easyAlign(layout)

% Align all blocks (separate function):
%   Align topmost block in leftmost column until all blocks are aligned (precedence to leftmost column)
%   Align with left side if only one inport, else if only one outport then align with right side else n/a
%%%       If aligning with left side, align blocks connecting to its inports (recursively)

aligned = containers.Map;
for j = 1:size(layout.grid,2) % for each column
    for i = 1:layout.colLengths(j) % for each non empty row in column
        block1 = layout.grid{i,j}.fullname; %block to align
        align(layout, aligned, block1, portCon, j);
    end
end
end

function bool = blockInCol(layout, block, col)
%Check if block is in column col of layout

bool = false;
try %error if col is out of bounds
    for k = 1:layout.colLengths(col)
        if strcmp(layout.grid{k,col}.fullname, block)
            bool = true;
        end
    end
end
end

function align(layout, aligned, block1, col)
%If only one inport, align block1 with its source
%else if only one outport, align block1 with its dest
%before aligning with a source or dest, try aligning that source or dest
%
%IN PROGRESS (DOUBLE CHECK HEADER COMMENTS)
%need to Handle branching lines

if ~isKey(aligned,block1)
    aligned(block1) = 'notaligned';
end
if ~strcmp(aligned(block1), 'aligned')
    ports1 = get_param(block1, 'Ports');
    portCon1 = get_param(block1, 'PortConnectivity');
    if ports1(1) == 1 && ~strcmp(aligned(block1), 'triedleft')
        block2 = getfullname(portCon1(1).SrcBlock);
        align(layout, aligned, block2, col-1); % recursively align blocks that impact this one

        ports2 = get_param(portCon1(1).SrcBlock, 'Ports');
        portCon2 = get_param(portCon1(1).SrcBlock, 'PortConnectivity');
        endHeight = portCon2(end+1-ports2(2)+portCon1(1).SrcPort).Position(2);
        startHeight = portCon1(1).Position(2);
        shamt = endHeight - startHeight; %shift amount

        %%%TODO
        %if can move that distance
        %then move that distance and mark as aligned
        %else mark as triedleft
        
    elseif ports1(2) == 1 && ~strcmp(aligned(block1), 'triedright')
        block2 = getfullname(portCon1(end).DstBlock);
        align(layout, aligned, block2, col+1); % recursively align blocks that impact this one
        
        %ports2 = get_param(portCon1(end).DstBlock, 'Ports'); %Not needed
        portCon2 = get_param(portCon1(end).DstBlock, 'PortConnectivity');
        endHeight = portCon2(1+portCon1(end).DstPort).Position(2);
        startHeight = portCon1(end).Position(2);
        shamt = endHeight - startHeight; %shift amount
        
        %%%TODO
        %if can move that distance
        %then move that distance and mark as aligned
        %else mark as triedright
        
    end %else don't align
end %else don't align
end