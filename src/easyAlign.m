function layout = easyAlign(layout)

% Align all blocks:
%   Align topmost block in leftmost column until all blocks are aligned (precedence to leftmost column)
%   Align with left side if only one inport, else if only one outport then align with right side else n/a
%%%       If aligning with left side, align blocks connecting to its inports (recursively)

%First pass
aligned = containers.Map;
for j = 1:size(layout.grid,2) % for each column
    for i = 1:layout.colLengths(j) % for each non empty row in column
        block1 = layout.grid{i,j}.fullname; % block to align
        [layout, aligned] = align(layout, aligned, block1, j);
    end
end

%Second pass
aligned = containers.Map;
for j = 1:size(layout.grid,2) % for each column
    for i = layout.colLengths(j):-1:1 % for each non empty row in column (reverse order)
        block1 = layout.grid{i,j}.fullname; % block to align
        [layout, aligned] = align(layout, aligned, block1, j);
    end
end
end

function [layout, aligned] = align(layout, aligned, block1, col)
%If only one inport, align block1 with its source
%else if only one outport, align block1 with its dest
%before aligning with a source or dest, try aligning that source or dest
%
%IN PROGRESS (DOUBLE CHECK HEADER COMMENTS)
%need to Handle branching lines

row = rowInCol(layout, block1, col); %note if row == 0, something went wrong

if ~isKey(aligned,block1)
    aligned(block1) = 'notaligned';
end
if ~strcmp(aligned(block1), 'aligned')
    ports1 = get_param(block1, 'Ports');
    portCon1 = get_param(block1, 'PortConnectivity');
    if length(portCon1(end).DstBlock) ~= 1 %>=2, therefore branching line
        %Don't bother with branching lines for now
        aligned(block1) = 'aligned';
    else
        if ports1(1) == 1 && ~strcmp(aligned(block1), 'triedleft')
            if strcmp(aligned(block1),'triedright')
                aligned(block1) = 'aligned'; %don't try again
            else
                aligned(block1) = 'triedleft';
            end
            
            block2 = getfullname(portCon1(1).SrcBlock);
            [layout, aligned] = align(layout, aligned, block2, col-1); % recursively align blocks that impact this one
            
            ports2 = get_param(portCon1(1).SrcBlock, 'Ports');
            portCon2 = get_param(portCon1(1).SrcBlock, 'PortConnectivity');
            endHeight = portCon2(end+1-ports2(2)+portCon1(1).SrcPort).Position(2);
            startHeight = portCon1(1).Position(2);
            shamt = endHeight - startHeight; %shift amount
            
            %if can move by shamt distance (i.e. no obstruction)
            %then move that distance and mark as aligned
            %else mark as triedleft or aligned if also triedright already
            if shamt < 0
                curPos = layout.grid{row,col}.position;
                if row == 1 || layout.grid{row-1,col}.position(4) < curPos(2) + shamt
                    layout.grid{row,col}.position = [curPos(1), curPos(2) + shamt, curPos(3), curPos(4) + shamt];
                    set_param(layout.grid{row,col}.fullname, 'Position', layout.grid{row,col}.position)
                    aligned(block1) = 'aligned';
                end
            elseif shamt > 0
                curPos = layout.grid{row,col}.position;
                if row == layout.colLengths(col) || layout.grid{row+1,col}.position(2) > curPos(4) + shamt
                    layout.grid{row,col}.position = [curPos(1), curPos(2) + shamt, curPos(3), curPos(4) + shamt];
                    set_param(layout.grid{row,col}.fullname, 'Position', layout.grid{row,col}.position)
                    aligned(block1) = 'aligned';
                end
            else
                aligned(block1) = 'aligned';
            end
            
        elseif ports1(2) == 1 && ~strcmp(aligned(block1), 'triedright')
            if strcmp(aligned(block1),'triedleft')
                aligned(block1) = 'aligned'; %don't try again
            else
                aligned(block1) = 'triedright';
            end
            
            block2 = getfullname(portCon1(end).DstBlock);
            [layout, aligned] = align(layout, aligned, block2, col+1); % recursively align blocks that impact this one
            
            %ports2 = get_param(portCon1(end).DstBlock, 'Ports'); %Not needed
            portCon2 = get_param(portCon1(end).DstBlock, 'PortConnectivity');
            endHeight = portCon2(1+portCon1(end).DstPort).Position(2);
            startHeight = portCon1(end).Position(2);
            shamt = endHeight - startHeight; %shift amount
            
            %if can move by shamt distance (i.e. no obstruction)
            %then move that distance and mark as aligned
            %else mark as triedright or aligned if also triedleft already
            if shamt < 0
                curPos = layout.grid{row,col}.position;
                if row == 1 || layout.grid{row-1,col}.position(4) < curPos(2) + shamt
                    layout.grid{row,col}.position = [curPos(1), curPos(2) + shamt, curPos(3), curPos(4) + shamt];
                    set_param(layout.grid{row,col}.fullname, 'Position', layout.grid{row,col}.position)
                    aligned(block1) = 'aligned';
                end
            elseif shamt > 0
                curPos = layout.grid{row,col}.position;
                if row == layout.colLengths(col) || layout.grid{row+1,col}.position(2) > curPos(4) + shamt
                    layout.grid{row,col}.position = [curPos(1), curPos(2) + shamt, curPos(3), curPos(4) + shamt];
                    set_param(layout.grid{row,col}.fullname, 'Position', layout.grid{row,col}.position)
                    aligned(block1) = 'aligned';
                end
            else
                aligned(block1) = 'aligned';
            end
            
        else % don't align at all so mark as aligned (as it will not attempt to align if already aligned)
            aligned(block1) = 'aligned';
        end
    end
end %else don't align
end