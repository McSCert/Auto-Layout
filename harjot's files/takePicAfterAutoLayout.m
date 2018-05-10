%takePicAfterAutoLayout
model_name = gcs;
pic_dir = 'E:\AutoLayout_pics\';
subsystem_name = strrep(gcs,'/','_');
pic_name = [pic_dir subsystem_name];
print('-dpng', ['-s' gcs], [pic_name '_after_graphplot_asap.png']);