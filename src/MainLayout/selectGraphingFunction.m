function initLayout = selectGraphingFunction()
    % Determine which initial layout graphing method to use
    % Determine which external software to use:
    %   1) MATLAB's GraphPlot objects; or
    %   2) Graphviz (requires separate install)
    % based on the configuration parameters and current version of MATLAB
    
    GRAPHING_METHOD = getAutoLayoutConfig('graphing_method', 'auto'); %Indicates which graphing method to use
    
    if strcmp(GRAPHING_METHOD, 'auto')
        % Check if MATLAB version is R2015b or newer (i.e. greater-or-equal to 2015b)
        ver = version('-release');
        ge2015b = str2num(ver(1:4)) > 2015 || strcmp(ver(1:5),'2015b');
        if ge2015b
            % Graphplot
            initLayout = @GraphPlotLayout;
        else
            % Graphviz
            initLayout = @GraphvizLayout;
        end
    elseif strcmp(GRAPHING_METHOD, 'graphplot')
        % Graphplot
        initLayout = @GraphPlotLayout;
    elseif strcmp(GRAPHING_METHOD, 'graphviz')
        % Graphviz
        initLayout = @GraphvizLayout;
    else
        ErrorInvalidConfig('graphing_method')
    end
end