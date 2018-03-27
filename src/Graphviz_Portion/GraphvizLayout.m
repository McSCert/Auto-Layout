function getGraphvizLayout(address)
% GETGRAPHVIZLAYOUT Perform the layout analysis on the system with Graphviz.
%
%   Inputs:
%       address     System address in which to perform the analysis.
%
%   Outputs:
%       N/A
%
%   1) Get the mdl file and the specific (sub)system to auto layout.
%   2) Create the dotfile from the system or subsystem using dotfile_creator.
%   3) Use batchthingie.bat to automatically create the graphviz output files.
%   4) Use Tplainparser class to use Graphviz output to reposition Simulink (sub)system.

    % 1) Get current directory
    % 2) Change directory to predetermined batch location
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

    cd(batchDir);
    [filename, map] = dotfile_creator(address);
    if ~isunix
        [~, ~] = system('autoLayout.bat'); % Suppressed output with "[~, ~] ="
    else
        [~, ~] = system('sh autoLayout.sh'); % Suppressed output with "[~, ~] ="
    end

    % Do the initial layout
    g = TplainParser(address, filename, map);
    g.plain_wrappers;

    % Delete unneeded files
    dotfilename = [filename '.dot'];
    delete(dotfilename);
    plainfilename = [filename '-plain.txt'];
    pdffilename = [filename '.pdf'];
    delete(plainfilename);
    delete(pdffilename);

    % Change directory
    cd(oldDir);
end