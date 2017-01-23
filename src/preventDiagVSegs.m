function preventDiagVSegs(systemLines)
    for i = 1:length(systemLines)
        line = systemLines(i);
        linePoints = get_param(line, 'points');

        if size(linePoints,1) >= 2
            if linePoints(1,1) == linePoints(2,1)
                p = linePoints;
                p21 = p(1,1) + 1;
                points = [p(1,:);...
                    p21,p(1,2);...
                    p21,p(2,2);...
                    p(3:end,:)];
                set_param(line, 'points', points);
            end
        end
    end
end