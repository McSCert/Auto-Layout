fileID_systems = fopen('_system_names','a');
model_name = bdroot;
pic_dir = 'F:\AutoLayout_pics\';
pic_name = [pic_dir model_name];
print('-dpng', ['-s' gcs], [pic_name '_before_graphplot.png']);
AutoLayout(gcs);
print('-dpng', ['-s' gcs], [pic_name '_after_graphplot_asap.png']);

%loop through all subsystems
model_sub_systems = find_system(model_name,'FollowLinks','on','BlockType','SubSystem', 'Mask', 'off');
for i = 1:length(model_sub_systems)
    try
        if(strcmp(get_param(model_sub_systems{i},'SFBlockType'), 'Chart'))
            continue
        end
        open_system(model_sub_systems{i});
        set_param(gcs, 'LinkStatus', 'inactive');
        subsystem_name = [model_name '_subsys_' num2str(i)];
        fprintf(fileID_systems,'%s: %d\n',model_sub_systems{i},i);
        pic_name = [pic_dir subsystem_name];
        print('-dpng', ['-s' gcs], [pic_name '_before.png'])
        try
            AutoLayout(gcs);
            print('-dpng', ['-s' gcs], [pic_name '_after_graphplot_asap.png'])
        catch
            disp(['Autolayout broke on model ''' model_sub_systems{i} ''''])
        end
    catch
        disp(['Code broke on model ''' model_sub_systems{i} ''''])
    end
end
fclose(fileID_systems);