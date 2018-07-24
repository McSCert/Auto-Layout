function GraphPlotLayout(blocks)
    % GRAPHPLOTLAYOUT Creates a GraphPlot representing given blocks using
    % MATLAB functions and then lays out the blocks according to that
    % plot.
    %
    % Input:
    %   blocks  Vector of block handles in which each block is at the
    %           top level of the same system.
    %
    % Output:
    %   N/A
    
    blocks = inputToNumeric(blocks);
    
    dg = blocksToDigraph(blocks);
    dg2 = addImplicitEdgesBetweenBlocks(blocks, dg);
    
    defaultFigureVisible = get(0, 'DefaultFigureVisible');
    set(0, 'DefaultFigureVisible', 'off');    % Don't show the figure
    p = plotSimulinkDigraph(blocks, dg2);
    set(0,'DefaultFigureVisible', defaultFigureVisible);
    
    assert(length(blocks) == length(p.NodeLabel))
    blocks = p.NodeLabel'; % Update blocks to ensure the order corresponds with position data
    xs = p.XData;
    ys = p.YData;
    
    % keep = ~cellfun(@isempty,regexp(blocks,'(:b$)','once'));
    % toss = ~cellfun(@isempty,regexp(blocks,'(:[io][0-9]*$)','once')); % These aren't needed anymore
    % assert(all(xor(keep, toss)), 'Unexpected NodeLabel syntax.')
    % blocks = cellfun(@(x) x(1:end-2), blocks(keep), 'UniformOutput', false);
    % xs = xs(keep);
    % ys = ys(keep);
    % % blocks(toss) = [];
    % % xs(toss) = [];
    % % ys(toss) = [];
    
    blocks = cellfun(@(x) x(1:end-2), blocks, 'UniformOutput', false);
    
    % Set semi-arbitrary scaling factors to determine starting positions
    scale = 90; % Pixels per unit increase in x or y in the plot
    scaleBack = 3; % Scale-back factor to determine block size
    
    for i = 1:length(blocks)
        blockwidth  = scale/scaleBack;
        blockheight = scale/scaleBack;
        blockx      = scale * xs(i);
        blocky      = scale * (max(ys) + min(ys) - ys(i)); % Accounting for different coordinate system between the plot and Simulink
        
        % Keep the block centered where the node was
        left    = round(blockx - blockwidth/2);
        right   = round(blockx + blockwidth/2);
        top     = round(blocky - blockheight/2);
        bottom  = round(blocky + blockheight/2);
        
        pos = [left top right bottom];
        setPositionAL(blocks{i}, pos);
    end
    
    % Try to fix knots caused by the arbitrary ordering of out/inputs to a node
    for i = 1:length(blocks)
        ph = get_param(blocks{i}, 'PortHandles');
        out = ph.Outport;
        if length(out) > 1
            [snks, snkPositions, ~] = arrangeSinks(blocks{i}, false);
            for j = 1:length(snks)
                if any(get_param(snks{j}, 'Handle') == inputToNumeric(blocks))
                    set_param(snks{j}, 'Position', snkPositions(j, :))
                end
            end
        end
    end
    for i = 1:length(blocks)
        ph = get_param(blocks{i}, 'PortHandles');
        in = ph.Inport;
        if length(in) > 1
            [srcs, srcPositions, ~] = arrangeSources(blocks{i}, false);
            for j = 1:length(srcs)
                if any(get_param(srcs{j}, 'Handle') == inputToNumeric(blocks))
                    set_param(srcs{j}, 'Position', srcPositions(j, :))
                end
            end
        end
    end
end