function GraphvizLayout(blocks)
    % GRAPHVIZLAYOUT Perform the layout analysis on the system with
    % Graphviz.
    %
    % Inputs:
    %   blocks  Vector of block handles in which each block is at the
    %           top level of the same system.
    %
    % Outputs:
    %   N/A
    
    %%
    % Check first input
    assert(isa(blocks, 'double'), 'Blocks must be given as a vector of handles.')
    
    if ~isempty(blocks)
        sys = getCommonParent(blocks);
        assert(bdIsLoaded(getfullname(bdroot(sys))), 'The system containing the given Simulink blocks is invalid or not loaded.')
    end
    
    %   Implementation Approach:
    %   1) Create the dotfile from the system or subsystem using dotfile_creator.
    %   2) Use autoLayout.bat/.sh to automatically create the graphviz output files.
    %   3) Use Tplainparser class to use Graphviz output to reposition Simulink (sub)system.
    
    % Get current directory
    if ~isunix
        oldDir = pwd;
        batchDir = mfilename('fullpath');
        numChars = strfind(batchDir, '\');
        if ~isempty(numChars)
            numChars = numChars(end);
            batchDir = batchDir(1:numChars-1);
        end
    else
        oldDir = pwd;
        batchDir = mfilename('fullpath');
        numChars = strfind(batchDir, '/');
        if ~isempty(numChars)
            numChars = numChars(end);
            batchDir = batchDir(1:numChars-1);
        end
    end
    
    % Change directory to predetermined batch location
    cd(batchDir);
    
    % 1) Create the dotfile from the system or subsystem using dotfile_creator.
    [filename, map] = dotfile_creator(blocks);
    
    % 2) Use autoLayout.bat/.sh to automatically create the graphviz output files.
    if ~isunix
        [~, ~] = system('autoLayout.bat'); % Suppressed output with "[~, ~] ="
    else
        [~, ~] = system('sh autoLayout.sh'); % Suppressed output with "[~, ~] ="
    end
    
    % 3) Use Tplainparser class to use Graphviz output to reposition Simulink (sub)system.
    % Do the initial layout
    g = TplainParser(blocks, filename, map);
    g.plain_wrappers;
    
    % Delete unneeded files
    dotfilename = [filename '.dot'];
    delete(dotfilename);
    plainfilename = [filename '-plain.txt'];
    pdffilename = [filename '.pdf'];
    delete(plainfilename);
    delete(pdffilename);
    
    % Change directory back
    cd(oldDir);
end