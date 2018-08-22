function center = position_center(positions)
    % POSITION_CENTER Finds the center of rectangles.
    %
    % Input:
    %   positions   nx4 matrix where each row represents a rectangle or a
    %               cell array of 1x4 position vectors where each row
    %               represents a rectangle. Rectangles are represented in
    %               the same way as the position parameter of a Simulink
    %               block: [left top right bottom]
    %
    % Output:
    %   center  nx2 matrix where each row represents the center of a
    %           rectangle as a 1x2 vector, [x_center y_center], of the
    %           center of the rectangle.
    
    if iscell(positions)
        positions_mat = zeros(length(positions),4);
        for i = 1:length(positions)
            positions_mat(i,:) = positions{i};
        end
    else
        positions_mat = positions;
    end

    left = positions_mat(:,1);
    top = positions_mat(:,2);
    right = positions_mat(:,3);
    bottom = positions_mat(:,4);
    
    x = (left+right)/2;
    y = (top+bottom)/2;
    
    center = [x y];
end
    