function getGraphvizLayout(address)
% GETGRAPHVIZLAYOUT Perform the layout analysis on the system with Graphviz.
%
%   Input:
%       address     System address in which to perform the analysis.
%
%	first get the mdl file and the specific subsystem or system to
%	autolayout
%	next create the dotfile from the system or subsystem using
%	dotfile_creator
%	use batchthingie.bat to automatically create the graphviz output
%	files
%	use Tplainparser class to use graphviz output to reposition
%	simulink system/subsystem

% Get current directory
% Change directory to predetermined batch location
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
        [~, ~] = system('autoLayout.bat'); %Suppressed output with "[~, ~] ="
    else
        [~, ~] = system('sh autoLayout.sh'); %Suppressed output with "[~, ~] ="
    end
    % Change directory

    % Do the initial layout.
    g = TplainParser(address, filename, map);
    g.plain_wrappers;

    dotfilename = [filename '.dot'];
    delete(dotfilename);
    plainfilename = [filename '-plain.txt'];
    pdffilename = [filename '.pdf'];
    delete(plainfilename);
    delete(pdffilename);
    cd(oldDir);
end