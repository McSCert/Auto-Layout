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
%	parse_the_Tplain and finds where to move the simulink blocks in the 
%   system using find_the_right_spot
% 
%	[mapObj, graphinfo]=parse_the_Tplain(object,filename)
%		parses the graphviz output txt file, outputs the height and
%		width of the graph in graphinfo, and the size and location of
%		the blocks in a map called mapObj, with the names of the blocks
%		corresponsing to the keys and tehir info in the values.
%		filename is the name of the graphviz txt file		
%	
%	blocksInfo=find_the_right_spot(object, mapObj, graphinfo)
%		finds the right position for blocks using the info from graphinfo 
%       and mapObj.
%       blocksInfo is a struct containing the fullname and right position
%       for blocks in RootSystemName.
	
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
            find_the_right_spot(object, mapObj, graphinfo);
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
                    
                    % C{3} - desired block center X coord
                    % C{4} - desired block center Y coord
                    % C{5} - desired block width
                    % C{6} - desired block height
                    values = {C{3} C{4} C{5} C{6}};
                    mapkey = C{2}{1}; % Block name
                    
                    %Used for blocks names using certain characters
                    itemsToReplace = keys(object.map);
                    for item = 1:length(itemsToReplace)
                        mapkey = strrep(mapkey, itemsToReplace{item}, object.map(itemsToReplace{item}));
                    end
                    
                    mapObj(mapkey) = values;
                end
                % TODO Do stuff with tline here
                % ...
                % (graphviz gives information about the edges in the graph
                % as well, but nothing is currently done with it)
            end
            fclose(inputfile); 
        end
        
        function find_the_right_spot(object, mapObj, graphinfo)            
            % Get blocks in address
            systemBlocks = find_system(object.RootSystemName, 'SearchDepth',1);
            systemBlocks = systemBlocks(2:end); %Remove address itself

            blocklength = length(systemBlocks);
            width = round(graphinfo(2));
            height = round(graphinfo(3));
            
            for z = 1:blocklength
                subsystemblocksName = get_param(systemBlocks{z}, 'Name');
                blockPosInfo = mapObj(subsystemblocksName); %Block's position information from graphviz
                
                blockwidth  = blockPosInfo{3};
                blockheight = blockPosInfo{4};
                blockx      = blockPosInfo{1};
                blocky      = round(height - blockPosInfo{2}); % Accounting for different coordinate system between graphviz and MATLAB
                
                left    = round(blockx - blockwidth/2);
                right   = round(blockx + blockwidth/2);
                top     = round(blocky - blockheight/2);
                bottom  = round(blocky + blockheight/2);
                
                pos = [left top right bottom];
                setPositionAL(systemBlocks{z}, pos);
            end
        end
    end
end