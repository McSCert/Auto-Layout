%% Register custom menu function to beginning of Simulink Editor's context menu
function sl_customization(cm)
    cm.addCustomMenuFcn('Simulink:PreContextMenu', @getMcMasterTool);
end

%% Define custom menu function
function schemaFcns = getMcMasterTool(callbackInfo)
    schemaFcns = {@getAutoLayoutTool};
end

%% Define the second action: Auto Layout
function schema = getAutoLayoutTool(callbackinfo)
    schema = sl_action_schema;
    schema.label = 'Auto Layout';
    schema.userdata = 'autolayout';
    schema.callback = @AutoLayoutToolCallback;
end

function AutoLayoutToolCallback(callbackInfo)
    try
        if strcmp(get_param(bdroot, 'Dirty'), 'on')
            AutoLayoutGUI;
        else
            if isempty(gcos)
                AutoLayoutSys(gcs);
            else
                objs = gcos;
                objs = objs(strcmp(get_param(objs, 'Parent'), gcs)); % Filter out selected objects not in the current system
                AutoLayout(objs);
            end
        end
    catch ME
        getReport(ME)
        rethrow(ME)
    end
end