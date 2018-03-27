classdef TplainParser < handle
% TPLAINPARSER A class for parsing a GraphViz output txt file, and moving Simulink
%   blocks to their appropriate locations.
%
%   Examples:
%       g = TplainParser('testModel', testModel.txt);
%       g.plain_wrappers;

    properties
        RootSystemName  % Simulink model name (or top-level system name).
        filename        % Name of the GraphViz output txt file.
        map             % ??
    end

    methods
        function object = TplainParser(RootSystemName, filename, replacementMap)
        % Constructor for the TplainParser object. This object represents the mapping
        %   between GraphViz and Simulink block locations. (?? MJ: check that this is accurate)
        %
        %   Inputs:
        %       RootSystemName      Simulink model name (or top-level system name).
        %       filename            Name of the GraphViz output txt file.
        %       replacementMap      ??
        %
        %   Outputs:
        %       object              TplainParser object.

            object.RootSystemName = RootSystemName;
            object.filename = filename;
            object.map = replacementMap;
        end

        function plain_wrappers(object)
        % Parse the GraphViz output file and find where to move the Simulink
        %   blocks in the system.
        %
        %   Inputs:
        %       object    TplainParser object.
        %
        %   Outputs:
        %       N/A

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
%             end
        end

        function [mapObj, graphinfo] = parse_the_Tplain(object, filename)
        % Parse the GraphViz output txt file and ??
        %
        %   Inputs:
        %       object    TplainParser object.
        %       filename  Name of the GraphViz output txt file.
        %
        %   Outputs:
        %       mapObj    Contains the height and width of the graph in graphinfo,
        %                 and the size and location of the blocks, with the names
        %                 of the blocks corresponsing to the keys and their info
        %                 in the values.
        %
        %       graphinfo   ??

            inputfile = fopen(filename);
            tline = fgetl(inputfile);
            C = textscan(tline, '%s %f %f %f');
            % Info for width and height of window
            graphinfo = [C{2} C{3} C{4}];
            % Map for the ?? (MJ:this comment was incomplete)
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

                    % Used for blocks names using certain characters
                    itemsToReplace = keys(object.map);
                    for item = 1:length(itemsToReplace)
                        mapkey = strrep(mapkey, itemsToReplace{item}, object.map(itemsToReplace{item}));
                    end

                    mapObj(mapkey) = values;
                end
                % TODO: Do something with tline.
                % GraphViz gives information about the edges in the graph
                % as well, but nothing is currently done with it
            end
            fclose(inputfile);
        end

        function find_the_right_spot(object, mapObj, graphinfo)
        % Find the right position for blocks using the info from graphinfo and mapObj.
        %
        %   Inputs:
        %       object      TplainParser object.
        %       mapObj      ??
        %       graphInfo   ??
        %
        %   Outputs:
        %       N/A

            % Get blocks in address
            systemBlocks = find_system(object.RootSystemName, 'SearchDepth',1);
            systemBlocks = systemBlocks(2:end); % Remove address itself

            blocklength = length(systemBlocks);
            width = round(graphinfo(2));
            height = round(graphinfo(3));

            for z = 1:blocklength
                subsystemblocksName = get_param(systemBlocks{z}, 'Name');
                % Block's position information from GraphViz
                blockPosInfo = mapObj(subsystemblocksName);

                blockwidth  = blockPosInfo{3};
                blockheight = blockPosInfo{4};
                blockx      = blockPosInfo{1};
                blocky      = round(height - blockPosInfo{2}); % Account for different coordinate system between GraphViz and MATLAB

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