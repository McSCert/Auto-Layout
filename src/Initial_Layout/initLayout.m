function initLayout(address)
% Note this file used to be AutoLayout.m, so reference to autolayout in this
% file and the files it uses refer to this function as opposed to the more
% recent AutoLayout.m
    % testinglayout.m
	%	combine all autolayout components into one script file that takes
	%	user input 
	%	
	%	first get the mdl file and the specific subsystem or system to
	%	autolayout
	%	next create the dotfile from the system or subsystem using
	%	dotfile_creator
	%	use batchthingie.bat to automatically create the graphviz output
	%	files
	%	use Tplainparser class to use graphviz output to reposition
	%	simulink system/subsystem
	%
	
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