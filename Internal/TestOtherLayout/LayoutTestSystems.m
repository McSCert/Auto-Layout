% Run a layout function on a list of systems
% This script expects the layout function to simply take a system as input

%%%
% Replace AutoLayout with your layout function
layoutFun = @AutoLayout;
%%%

systems = {'test1', ...
    'test2', ...
    'test3', ...
    'test4', ...
    'test5', ...
    'sldemo_bounce_two_integrators', ...
    'sldemo_eml_galaxy', ...
    'aero_guidance', ...
    'aero_guidance/Guidance', ...
    'aero_guidance/Seeker//Tracker/Tracker and Sightline Rate Estimator'};

for i = 1:length(systems)
    load_system(systems{i});
    disp(['Working on system ', num2str(i), ' of ', num2str(length(systems))])
    
    % Layout the system - may need to modify the following line
    layoutFun(systems{i});
end

for i = 1:8 % Skip the subsystems
    disp(['Saving system ', num2str(i), ' of ', num2str(length(1:8))])
    close_system(systems{i}, [systems{i}, '_post_layout']);
end