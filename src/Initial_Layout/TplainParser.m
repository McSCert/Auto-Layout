classdef TplainParser < handle
%  TPLAINPARSER - A class which contains functions that parses a
%  graphviz output txt file, and moves the simulink blocks to the
%  appropriate locations.
%  
%
%   Typical use:
%   g = TplainParser('testModel', testModel.txt);
%   
%   g.plain_wrappers;
%  
%   Methods:
%   TplainParser(RootSystemName, filename)-Initialize the class with the parent
%   system and the filename of the graphviz output txt file
%
%	plain_wrappers- parses the graphviz output file using
%	parse_the_Tplain and moves the simulink blocks in the system using 
%	go_to_the_right_spot
% 
%	[mapObj, graphinfo]=parse_the_Tplain(object,filename)
%		parses the graphviz output txt file, outputs the height and
%		width of the graph in graphinfo, and the size and location of
%		the blocks in a map called mapObj, with the names of the blocks
%		corresponsing to the keys and tehir info in the values.
%		filename is the name of the graphviz txt file		
%	
%	go_to_the_right_spot(object, block, mapObj, graphinfo)
%		moves the block to teh right position using the info gotten
%		from graphinfo and mapObj
	
    properties
        RootSystemName
        filename
        map
    end
    
    methods
        function object = TplainParser(RootSystemName, filename, replacementMap)
            object.RootSystemName = RootSystemName;
            object.filename = filename;
            object.map = replacementMap;
        end
        
        function plain_wrappers(object)
            filename = [object.filename '-plain.txt'];
            [mapObj, graphinfo] = parse_the_Tplain(object, filename);
            go_to_the_right_spot(object, object.RootSystemName, mapObj, graphinfo);
%             subsystems = find_system(object.RootSystemName,'Blocktype','SubSystem');
%             sublength = length(subsystems);
%             for z = 1:sublength
%                 protofilename = subsystems{z};
%                 protofilename = strrep(protofilename,'/' ,'' );
%                 filename = [protofilename '-plain.txt']
%                 [mapObj, graphinfo] = parse_the_Tplain(object, filename );
%                 go_to_the_right_spot(object, subsystems{z},mapObj, graphinfo);
%                 
%             end
        end
        
        function [mapObj, graphinfo] = parse_the_Tplain(object,filename)
            inputfile = fopen(filename);
            tline = fgetl(inputfile);
            C = textscan(tline, '%s %f %f %f');
			% Info for width and height of window
            graphinfo = [C{2} C{3} C{4}];
			% Map for the 
            mapObj = containers.Map();
            while 1
                % Get a line from the input file
                tline = fgetl(inputfile);
                % Quit if end of file
                if ~ischar(tline)
                    break
                end
                C = textscan(tline, '%s %s %f %f %f %f %s %s %s %s %s');
                if strcmp(C{1}{1}, 'node')
                    values = {C{3} C{4} C{5} C{6}};
                    mapkey = C{2}{1};
                    itemsToReplace = keys(object.map);
                    for item = 1:length(itemsToReplace)
                        mapkey = strrep(mapkey, itemsToReplace{item}, object.map(itemsToReplace{item}));
                    end
                    mapObj(mapkey) = values;
                end
                % Do stuff with tline here
                % ...
            end
            fclose(inputfile); 
        end
        
        function go_to_the_right_spot(object, block, mapObj, graphinfo)
            subsystemblocks = find_system(block, 'SearchDepth', 1);
            blockcell = {block};
            subsystemblocks = setdiff(subsystemblocks, blockcell);
            
            blocklength = length(subsystemblocks);
            width = round(graphinfo(2));
            height = round(graphinfo(3));
            
            for z = 1:blocklength
                subsystemblocksName = get_param(subsystemblocks{z}, 'Name');
                blockinfo = mapObj(subsystemblocksName);
                
                blockwidth  = blockinfo{3};
                blockheight = blockinfo{4};
                blockx      = blockinfo{1};
                blocky      = round(height - blockinfo{2});
                
                left    = round(blockx - blockwidth  / 2);
                right   = round(blockx + blockwidth  / 2);
                top     = round(blocky - blockheight / 2);
                bottom  = round(blocky + blockheight / 2);
                
                set_param(subsystemblocks{z}, 'Position', [left top right bottom]);
            end
            redraw_lines(block, 'autorouting', 'on');
        end
    end
end